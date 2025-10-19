pragma solidity ^0.8.21;
import "@solmate/tokens/ERC4626.sol";
import "@solmate/utils/FixedPointMathLib.sol";
import "@solmate/utils/ReentrancyGuard.sol";
import "@solmate/utils/SafeTransferLib.sol";
import "../../interfaces/pools/IBaseInterestAllocator.sol";
import "../../interfaces/pools/IFeeManager.sol";
import "../../interfaces/pools/IPool.sol";
import "../../interfaces/pools/IPoolWithWithdrawalQueues.sol";
import "../../interfaces/pools/IPoolOfferHandler.sol";
import "../loans/LoanManager.sol";
import "../utils/Interest.sol";
import "./WithdrawalQueue.sol";
contract Pool is ERC4626, InputChecker, IPool, IPoolWithWithdrawalQueues, LoanManager, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using FixedPointMathLib for uint128;
    using FixedPointMathLib for uint256;
    using Interest for uint256;
    using SafeTransferLib for ERC20;
    uint80 public constant PRINCIPAL_PRECISION = 1e20;
    uint256 private constant _SECONDS_PER_YEAR = 31536000;
    uint16 private constant _BPS = 10000;
    uint16 private _MAX_BONUS = 500;
    uint256 public getCollectedFees;
    struct OutstandingValues {
        uint128 principalAmount;
        uint128 accruedInterest;
        uint128 sumApr;
        uint128 lastTs;
    }
    struct QueueAccounting {
        uint128 thisQueueFraction;
        uint128 netPoolFraction;
    }
    uint256 private constant _LOAN_BUFFER_TIME = 7 days;
    address public immutable getFeeManager;
    uint256 public immutable getMaxTotalWithdrawalQueues;
    uint256 public immutable getMinTimeBetweenWithdrawalQueues;
    uint256 public getReallocationBonus;
    address public getPendingBaseInterestAllocator;
    address public getBaseInterestAllocator;
    uint256 public getPendingBaseInterestAllocatorSetTime;
    bool public isActive;
    OptimalIdleRange public getOptimalIdleRange;
    mapping(uint256 queueIndex => mapping(address loanContract => uint256 loanId)) public getLastLoanId;
    mapping(uint256 queueIndex => uint256 totalReceived) public getTotalReceived;
    uint256 public getAvailableToWithdraw;
    DeployedQueue[] private _deployedQueues;
    OutstandingValues private _outstandingValues;
    uint256 private _pendingQueueIndex;
    OutstandingValues[] private _queueOutstandingValues;
    QueueAccounting[] private _queueAccounting;
    error PoolStatusError();
    error InsufficientAssetsError();
    error AllocationAlreadyOptimalError();
    error CannotDeployQueueTooSoonError();
    error NoSharesPendingWithdrawalError();
    event ReallocationBonusUpdated(uint256 newReallocationBonus);
    event PendingBaseInterestAllocatorSet(address newBaseInterestAllocator);
    event BaseInterestAllocatorSet(address newBaseInterestAllocator);
    event OptimalIdleRangeSet(OptimalIdleRange optimalIdleRange);
    event QueueClaimed(address queue, uint256 amount);
    event Reallocated(uint256 delta, uint256 bonusShares);
    constructor(
        address _feeManager,
        address _offerHandler,
        uint256 _waitingTimeBetweenUpdates,
        OptimalIdleRange memory _optimalIdleRange,
        uint256 _maxTotalWithdrawalQueues,
        uint256 _reallocationBonus,
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset, _name, _symbol) LoanManager(tx.origin, _offerHandler, _waitingTimeBetweenUpdates) {
        getFeeManager = _feeManager;
        isActive = true;
        _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) / 2;
        getOptimalIdleRange = _optimalIdleRange;
        getPendingBaseInterestAllocatorSetTime = type(uint256).max;
        if (_reallocationBonus > _MAX_BONUS) {
            revert InvalidInputError();
        }
        getReallocationBonus = _reallocationBonus;
        getMaxTotalWithdrawalQueues = _maxTotalWithdrawalQueues;
        getMinTimeBetweenWithdrawalQueues = (IPoolOfferHandler(_offerHandler).getMaxDuration() + _LOAN_BUFFER_TIME)
            .mulDivUp(1, _maxTotalWithdrawalQueues);
        _deployedQueues = new DeployedQueue[](_maxTotalWithdrawalQueues + 1);
        DeployedQueue memory deployedQueue = _deployQueue(_asset);
        _deployedQueues[_pendingQueueIndex] = deployedQueue;
        _queueOutstandingValues = new OutstandingValues[](_maxTotalWithdrawalQueues + 1);
        _queueAccounting = new QueueAccounting[](_maxTotalWithdrawalQueues + 1);
        _asset.approve(address(_feeManager), type(uint256).max);
    }
    function pausePool() external onlyOwner {
        isActive = !isActive;
        emit PoolPaused(isActive);
    }
    function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external onlyOwner {
        _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) / 2;
        getOptimalIdleRange = _optimalIdleRange;
        emit OptimalIdleRangeSet(_optimalIdleRange);
    }
    function setBaseInterestAllocator(address _newBaseInterestAllocator) external onlyOwner {
        _checkAddressNotZero(_newBaseInterestAllocator);
        getPendingBaseInterestAllocator = _newBaseInterestAllocator;
        getPendingBaseInterestAllocatorSetTime = block.timestamp;
        emit PendingBaseInterestAllocatorSet(_newBaseInterestAllocator);
    }
    function confirmBaseInterestAllocator(address _newBaseInterestAllocator) external {
        address cachedAllocator = getBaseInterestAllocator;
        if (cachedAllocator != address(0)) {
            if (getPendingBaseInterestAllocatorSetTime + UPDATE_WAITING_TIME > block.timestamp) {
                revert TooSoonError();
            }
            if (getPendingBaseInterestAllocator != _newBaseInterestAllocator) {
                revert InvalidInputError();
            }
            IBaseInterestAllocator(cachedAllocator).transferAll();
            asset.approve(cachedAllocator, 0);
        }
        asset.approve(_newBaseInterestAllocator, type(uint256).max);
        getBaseInterestAllocator = _newBaseInterestAllocator;
        getPendingBaseInterestAllocator = address(0);
        getPendingBaseInterestAllocatorSetTime = type(uint256).max;
        emit BaseInterestAllocatorSet(_newBaseInterestAllocator);
    }
    function setReallocationBonus(uint256 _newReallocationBonus) external onlyOwner {
        if (_newReallocationBonus > _MAX_BONUS) {
            revert InvalidInputError();
        }
        getReallocationBonus = _newReallocationBonus;
        emit ReallocationBonusUpdated(_newReallocationBonus);
    }
    function afterCallerAdded(address _caller) internal override onlyOwner {
        asset.approve(_caller, type(uint256).max);
    }
    function totalAssets() public view override returns (uint256) {
        return _getUndeployedAssets() + _getTotalOutstandingValue();
    }
    function getOutstandingValues() external view returns (OutstandingValues memory) {
        return _outstandingValues;
    }
    function getDeployedQueue(uint256 _idx) external view returns (DeployedQueue memory) {
        return _deployedQueues[_idx];
    }
    function getOutstandingValuesForQueue(uint256 _idx) external view returns (OutstandingValues memory) {
        return _queueOutstandingValues[_idx];
    }
    function getPendingQueueIndex() external view returns (uint256) {
        return _pendingQueueIndex;
    }
    function getAccountingValuesForQueue(uint256 _idx) external view returns (QueueAccounting memory) {
        return _queueAccounting[_idx];
    }
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256 shares) {
        shares = previewWithdraw(assets); 
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        _withdraw(owner, receiver, assets, shares);
    }
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
        _withdraw(owner, receiver, assets, shares);
    }
    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        _preDeposit();
        return super.deposit(assets, receiver);
    }
    function mint(uint256 shares, address receiver) public override returns (uint256) {
        _preDeposit();
        return super.mint(shares, receiver);
    }
    function queueClaimAll() external nonReentrant {
        _queueClaimAll(getAvailableToWithdraw, _pendingQueueIndex);
    }
    function deployWithdrawalQueue() external nonReentrant {
        uint256 pendingQueueIndex = _pendingQueueIndex;
        DeployedQueue memory queue = _deployedQueues[pendingQueueIndex];
        if (block.timestamp - queue.deployedTime < getMinTimeBetweenWithdrawalQueues) {
            revert TooSoonError();
        }
        uint256 sharesPendingWithdrawal = WithdrawalQueue(queue.contractAddress).getTotalShares();
        if (sharesPendingWithdrawal == 0) {
            revert NoSharesPendingWithdrawalError();
        }
        uint256 totalQueues = _deployedQueues.length;
        uint256 lastQueueIndex = (pendingQueueIndex + 1) % totalQueues;
        uint256 totalSupplyCached = totalSupply;
        uint256 proRataLiquid = _getUndeployedAssets().mulDivDown(sharesPendingWithdrawal, totalSupplyCached);
        uint128 poolFraction =
            uint128((totalSupplyCached - sharesPendingWithdrawal).mulDivDown(PRINCIPAL_PRECISION, totalSupplyCached));
        _queueAccounting[pendingQueueIndex] = QueueAccounting(
            uint128(sharesPendingWithdrawal.mulDivDown(PRINCIPAL_PRECISION, totalSupplyCached)), poolFraction
        );
        _queueClaimAll(proRataLiquid + getAvailableToWithdraw, pendingQueueIndex);
        asset.safeTransfer(queue.contractAddress, proRataLiquid);
        _deployedQueues[lastQueueIndex] = _deployQueue(asset);
        uint256 baseIdx = pendingQueueIndex + totalQueues;
        for (uint256 i = 1; i < totalQueues - 1;) {
            uint256 idx = (baseIdx - i) % totalQueues;
            if (_deployedQueues[idx].contractAddress == address(0)) {
                break;
            }
            QueueAccounting memory thisQueueAccounting = _queueAccounting[idx];
            uint128 newQueueFraction =
                uint128(thisQueueAccounting.netPoolFraction.mulDivDown(sharesPendingWithdrawal, totalSupplyCached));
            _queueAccounting[idx].netPoolFraction -= newQueueFraction;
            unchecked {
                ++i;
            }
        }
        _queueOutstandingValues[pendingQueueIndex] = _outstandingValues;
        delete _queueOutstandingValues[lastQueueIndex];
        delete _outstandingValues;
        _updateLoanLastIds();
        _pendingQueueIndex = lastQueueIndex;
        unchecked {
            totalSupply -= sharesPendingWithdrawal;
        }
    }
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external override onlyAcceptedCallers {
        if (!isActive) {
            revert PoolStatusError();
        }
        uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw;
        uint256 baseRateBalance = IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated();
        uint256 undeployedAssets = currentBalance + baseRateBalance;
        (uint256 principalAmount, uint256 apr) = IPoolOfferHandler(getUnderwriter).validateOffer(
            IBaseInterestAllocator(getBaseInterestAllocator).getBaseAprWithUpdate(), _offer
        );
        if (principalAmount > undeployedAssets) {
            revert InsufficientAssetsError();
        } else if (principalAmount > currentBalance) {
            IBaseInterestAllocator(getBaseInterestAllocator).reallocate(
                currentBalance, principalAmount - currentBalance, true
            );
        }
        _outstandingValues = _getNewLoanAccounting(principalAmount, _netApr(apr, _protocolFee));
    }
    function reallocate() external nonReentrant returns (uint256) {
        (uint256 currentBalance, uint256 targetIdle) = _reallocate();
        uint256 delta = currentBalance > targetIdle ? currentBalance - targetIdle : targetIdle - currentBalance;
        uint256 shares = delta.mulDivDown(totalSupply * getReallocationBonus, totalAssets() * _BPS);
        _mint(msg.sender, shares);
        emit Reallocated(delta, shares);
        return shares;
    }
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256,
        uint256 _protocolFee,
        uint256 _startTime
    ) external override onlyAcceptedCallers {
        uint256 netApr = _netApr(_apr, _protocolFee);
        uint256 interestEarned = _principalAmount.getInterest(netApr, block.timestamp - _startTime);
        uint256 received = _principalAmount + interestEarned;
        uint256 fees = IFeeManager(getFeeManager).processFees(_principalAmount, interestEarned);
        getCollectedFees += fees;
        _loanTermination(msg.sender, _loanId, _principalAmount, netApr, interestEarned, received - fees);
    }
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external override onlyAcceptedCallers {
        uint256 netApr = _netApr(_apr, _protocolFee);
        uint256 interestEarned = _principalAmount.getInterest(netApr, block.timestamp - _startTime);
        uint256 fees = IFeeManager(getFeeManager).processFees(_received, 0);
        getCollectedFees += fees;
        _loanTermination(msg.sender, _loanId, _principalAmount, netApr, interestEarned, _received - fees);
    }
    function _getTotalOutstandingValue() private view returns (uint256) {
        uint256 totalOutstandingValue = _getOutstandingValue(_outstandingValues);
        uint256 totalQueues = _queueOutstandingValues.length;
        uint256 newest = (_pendingQueueIndex + totalQueues - 1) % totalQueues;
        for (uint256 i; i < totalQueues - 1;) {
            uint256 idx = (newest + totalQueues - i) % totalQueues;
            OutstandingValues memory queueOutstandingValues = _queueOutstandingValues[idx];
            totalOutstandingValue += _getOutstandingValue(queueOutstandingValues).mulDivDown(
                _queueAccounting[idx].netPoolFraction, PRINCIPAL_PRECISION
            );
            unchecked {
                ++i;
            }
        }
        return totalOutstandingValue;
    }
    function _getOutstandingValue(OutstandingValues memory __outstandingValues) private view returns (uint256) {
        uint256 principal = uint256(__outstandingValues.principalAmount);
        return principal + uint256(__outstandingValues.accruedInterest)
            + principal.getInterest(
                uint256(_outstandingApr(__outstandingValues)), block.timestamp - uint256(__outstandingValues.lastTs)
            );
    }
    function _getNewLoanAccounting(uint256 _principalAmount, uint256 _apr)
        private
        view
        returns (OutstandingValues memory outstandingValues)
    {
        outstandingValues = _outstandingValues;
        outstandingValues.accruedInterest += uint128(
            uint256(outstandingValues.principalAmount).getInterest(
                uint256(_outstandingApr(outstandingValues)), block.timestamp - uint256(outstandingValues.lastTs)
            )
        );
        outstandingValues.sumApr += uint128(_apr * _principalAmount);
        outstandingValues.principalAmount += uint128(_principalAmount);
        outstandingValues.lastTs = uint128(block.timestamp);
    }
    function _loanTermination(
        address _loanContract,
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _interestEarned,
        uint256 _received
    ) private {
        uint256 pendingIndex = _pendingQueueIndex;
        uint256 totalQueues = getMaxTotalWithdrawalQueues + 1;
        uint256 idx;
        uint256 i;
        for (i = 1; i < totalQueues;) {
            idx = (pendingIndex + i) % totalQueues;
            if (getLastLoanId[idx][_loanContract] >= _loanId) {
                break;
            }
            unchecked {
                ++i;
            }
        }
        if (i == totalQueues) {
            _outstandingValues =
                _updateOutstandingValuesOnTermination(_outstandingValues, _principalAmount, _apr, _interestEarned);
            return;
        } else {
            uint256 pendingToQueue =
                _received.mulDivDown(PRINCIPAL_PRECISION - _queueAccounting[idx].netPoolFraction, PRINCIPAL_PRECISION);
            getTotalReceived[idx] += _received;
            getAvailableToWithdraw += pendingToQueue;
            _queueOutstandingValues[idx] = _updateOutstandingValuesOnTermination(
                _queueOutstandingValues[idx], _principalAmount, _apr, _interestEarned
            );
        }
    }
    function _preDeposit() private view {
        if (!isActive) {
            revert PoolStatusError();
        }
    }
    function _getUndeployedAssets() private view returns (uint256) {
        return asset.balanceOf(address(this)) + IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated()
            - getAvailableToWithdraw - getCollectedFees;
    }
    function _reallocate() private returns (uint256, uint256) {
        uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw;
        if (currentBalance == 0) {
            revert AllocationAlreadyOptimalError();
        }
        uint256 baseRateBalance = IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated();
        uint256 total = currentBalance + baseRateBalance;
        uint256 fraction = currentBalance.mulDivDown(PRINCIPAL_PRECISION, total);
        OptimalIdleRange memory optimalIdleRange = getOptimalIdleRange;
        if (fraction >= optimalIdleRange.min && fraction < optimalIdleRange.max) {
            revert AllocationAlreadyOptimalError();
        }
        uint256 targetIdle = total.mulDivDown(optimalIdleRange.mid, PRINCIPAL_PRECISION);
        IBaseInterestAllocator(getBaseInterestAllocator).reallocate(currentBalance, targetIdle, false);
        return (currentBalance, targetIdle);
    }
    function _reallocateOnWithdrawal(uint256 _withdrawn) private {
        uint256 currentBalance = asset.balanceOf(address(this));
        if (currentBalance > _withdrawn) {
            return;
        }
        uint256 baseRateBalance = IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated();
        uint256 finalBalance = currentBalance + baseRateBalance - _withdrawn;
        uint256 targetIdle = finalBalance.mulDivDown(getOptimalIdleRange.mid, PRINCIPAL_PRECISION);
        IBaseInterestAllocator(getBaseInterestAllocator).reallocate(currentBalance, _withdrawn + targetIdle, true);
    }
    function _netApr(uint256 _apr, uint256 _protocolFee) private pure returns (uint256) {
        return _apr.mulDivDown(_BPS - _protocolFee, _BPS);
    }
    function _deployQueue(ERC20 _asset) private returns (DeployedQueue memory) {
        address deployed = address(new WithdrawalQueue(_asset));
        return DeployedQueue(deployed, uint96(block.timestamp));
    }
    function _burn(address from, uint256 amount) internal override {
        balanceOf[from] -= amount;
        emit Transfer(from, address(0), amount);
    }
    function _updateLoanLastIds() private {
        for (uint256 i; i < _acceptedCallers.length();) {
            address caller = _acceptedCallers.at(i);
            if (_isLoanContract[caller]) {
                getLastLoanId[_pendingQueueIndex][caller] = IBaseLoan(caller).getTotalLoansIssued();
            }
            unchecked {
                ++i;
            }
        }
    }
    function _updatePendingWithdrawalWithQueue(
        uint256 _idx,
        uint256 _cachedPendingQueueIndex,
        uint256[] memory _pendingWithdrawal
    ) private returns (uint256[] memory) {
        uint256 totalReceived = getTotalReceived[_idx];
        uint256 totalQueues = getMaxTotalWithdrawalQueues + 1;
        if (totalReceived == 0) {
            return _pendingWithdrawal;
        }
        getTotalReceived[_idx] = 0;
        for (uint256 i; i < totalQueues;) {
            uint256 secondIdx = (_idx + i) % totalQueues;
            QueueAccounting memory queueAccounting = _queueAccounting[secondIdx];
            if (queueAccounting.thisQueueFraction == 0) {
                unchecked {
                    ++i;
                }
                continue;
            }
            if (secondIdx == _cachedPendingQueueIndex + 1) {
                break;
            }
            uint256 pendingForQueue = totalReceived.mulDivDown(queueAccounting.thisQueueFraction, PRINCIPAL_PRECISION);
            totalReceived -= pendingForQueue;
            _pendingWithdrawal[secondIdx] = pendingForQueue;
            unchecked {
                ++i;
            }
        }
        return _pendingWithdrawal;
    }
    function _queueClaimAll(uint256 _totalToBeWithdrawn, uint256 _cachedPendingQueueIndex) private {
        _reallocateOnWithdrawal(_totalToBeWithdrawn);
        uint256 totalQueues = (getMaxTotalWithdrawalQueues + 1);
        uint256 oldestQueueIdx = (_cachedPendingQueueIndex + 1) % totalQueues;
        uint256[] memory pendingWithdrawal = new uint256[](totalQueues);
        for (uint256 i; i < pendingWithdrawal.length;) {
            uint256 idx = (oldestQueueIdx + i) % totalQueues;
            _updatePendingWithdrawalWithQueue(idx, _cachedPendingQueueIndex, pendingWithdrawal);
            unchecked {
                ++i;
            }
        }
        getAvailableToWithdraw = 0;
        for (uint256 i; i < pendingWithdrawal.length;) {
            if (pendingWithdrawal[i] == 0) {
                unchecked {
                    ++i;
                }
                continue;
            }
            address queueAddr = _deployedQueues[i].contractAddress;
            uint256 amount = pendingWithdrawal[i];
            asset.safeTransfer(queueAddr, amount);
            emit QueueClaimed(queueAddr, amount);
            unchecked {
                ++i;
            }
        }
    }
    function _outstandingApr(OutstandingValues memory __outstandingValues) private pure returns (uint128) {
        if (__outstandingValues.principalAmount == 0) {
            return 0;
        }
        return __outstandingValues.sumApr / __outstandingValues.principalAmount;
    }
    function _updateOutstandingValuesOnTermination(
        OutstandingValues memory __outstandingValues,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _interestEarned
    ) private view returns (OutstandingValues memory) {
        uint256 newlyAccrued = uint256(__outstandingValues.sumApr).mulDivUp(
            block.timestamp - uint256(__outstandingValues.lastTs), _SECONDS_PER_YEAR * _BPS
        );
        uint256 total = __outstandingValues.accruedInterest + newlyAccrued;
        if (total < _interestEarned) {
            __outstandingValues.accruedInterest = 0;
        } else {
            __outstandingValues.accruedInterest = uint128(total - _interestEarned);
        }
        __outstandingValues.sumApr -= uint128(_apr * _principalAmount);
        __outstandingValues.principalAmount -= uint128(_principalAmount);
        __outstandingValues.lastTs = uint128(block.timestamp);
        return __outstandingValues;
    }
    function _withdraw(address owner, address receiver, uint256 assets, uint256 shares) private {
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        WithdrawalQueue(_deployedQueues[_pendingQueueIndex].contractAddress).mint(receiver, shares);
    }
}