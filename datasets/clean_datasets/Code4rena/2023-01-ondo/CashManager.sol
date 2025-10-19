pragma solidity 0.8.16;
import "contracts/cash/interfaces/ICashManager.sol";
import "contracts/cash/interfaces/IMulticall.sol";
import "contracts/cash/token/Cash.sol";
import "contracts/cash/kyc/KYCRegistryClientConstructable.sol";
import "contracts/cash/external/openzeppelin/contracts/security/Pausable.sol";
import "contracts/cash/external/openzeppelin/contracts/token/IERC20.sol";
import "contracts/cash/external/openzeppelin/contracts/token/IERC20Metadata.sol";
import "contracts/cash/external/openzeppelin/contracts/token/SafeERC20.sol";
import "contracts/cash/external/openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "contracts/cash/external/openzeppelin/contracts/security/ReentrancyGuard.sol";
contract CashManager is
  ICashManager,
  IMulticall,
  AccessControlEnumerable,
  KYCRegistryClientConstructable,
  Pausable,
  ReentrancyGuard
{
  using SafeERC20 for IERC20;
  IERC20 public immutable collateral;
  Cash public immutable cash;
  address public assetRecipient;
  address public feeRecipient;
  address public assetSender;
  uint256 public minimumDepositAmount = 10_000;
  uint256 public minimumRedeemAmount;
  uint256 public mintFee = 0;
  uint256 public exchangeRateDeltaLimit = 100;
  struct RedemptionRequests {
    uint256 totalBurned;
    mapping(address => uint256) addressToBurnAmt;
  }
  mapping(uint256 => RedemptionRequests) public redemptionInfoPerEpoch;
  mapping(uint256 => uint256) public epochToExchangeRate;
  mapping(uint256 => mapping(address => uint256)) public mintRequestsPerEpoch;
  uint256 public constant BPS_DENOMINATOR = 10_000;
  uint256 public immutable decimalsMultiplier;
  uint256 public currentEpoch;
  uint256 public epochDuration;
  uint256 public currentEpochStartTimestamp;
  uint256 public lastSetMintExchangeRate = 1e6;
  uint256 public mintLimit;
  uint256 public currentMintAmount;
  uint256 public redeemLimit;
  uint256 public currentRedeemAmount;
  bytes32 public constant MANAGER_ADMIN = keccak256("MANAGER_ADMIN");
  bytes32 public constant PAUSER_ADMIN = keccak256("PAUSER_ADMIN");
  bytes32 public constant SETTER_ADMIN = keccak256("SETTER_ADMIN");
  constructor(
    address _collateral,
    address _cash,
    address managerAdmin,
    address pauser,
    address _assetRecipient,
    address _assetSender,
    address _feeRecipient,
    uint256 _mintLimit,
    uint256 _redeemLimit,
    uint256 _epochDuration,
    address _kycRegistry,
    uint256 _kycRequirementGroup
  ) KYCRegistryClientConstructable(_kycRegistry, _kycRequirementGroup) {
    if (_collateral == address(0)) {
      revert CollateralZeroAddress();
    }
    if (_cash == address(0)) {
      revert CashZeroAddress();
    }
    if (_assetRecipient == address(0)) {
      revert AssetRecipientZeroAddress();
    }
    if (_assetSender == address(0)) {
      revert AssetSenderZeroAddress();
    }
    if (_feeRecipient == address(0)) {
      revert FeeRecipientZeroAddress();
    }
    _grantRole(DEFAULT_ADMIN_ROLE, managerAdmin);
    _grantRole(MANAGER_ADMIN, managerAdmin);
    _setRoleAdmin(PAUSER_ADMIN, MANAGER_ADMIN);
    _setRoleAdmin(SETTER_ADMIN, MANAGER_ADMIN);
    _grantRole(PAUSER_ADMIN, pauser);
    collateral = IERC20(_collateral);
    cash = Cash(_cash);
    feeRecipient = _feeRecipient;
    assetRecipient = _assetRecipient;
    assetSender = _assetSender;
    currentEpoch = currentEpoch;
    mintLimit = _mintLimit;
    redeemLimit = _redeemLimit;
    epochDuration = _epochDuration;
    currentEpochStartTimestamp =
      block.timestamp -
      (block.timestamp % epochDuration);
    decimalsMultiplier =
      10 **
        (IERC20Metadata(_cash).decimals() -
          IERC20Metadata(_collateral).decimals());
  }
  function requestMint(
    uint256 collateralAmountIn
  )
    external
    override
    updateEpoch
    nonReentrant
    whenNotPaused
    checkKYC(msg.sender)
  {
    if (collateralAmountIn < minimumDepositAmount) {
      revert MintRequestAmountTooSmall();
    }
    uint256 feesInCollateral = _getMintFees(collateralAmountIn);
    uint256 depositValueAfterFees = collateralAmountIn - feesInCollateral;
    _checkAndUpdateMintLimit(depositValueAfterFees);
    collateral.safeTransferFrom(msg.sender, feeRecipient, feesInCollateral);
    collateral.safeTransferFrom(
      msg.sender,
      assetRecipient,
      depositValueAfterFees
    );
    mintRequestsPerEpoch[currentEpoch][msg.sender] += depositValueAfterFees;
    emit MintRequested(
      msg.sender,
      currentEpoch,
      collateralAmountIn,
      depositValueAfterFees,
      feesInCollateral
    );
  }
  function claimMint(
    address user,
    uint256 epochToClaim
  ) external override updateEpoch nonReentrant whenNotPaused checkKYC(user) {
    uint256 collateralDeposited = mintRequestsPerEpoch[epochToClaim][user];
    if (collateralDeposited == 0) {
      revert NoCashToClaim();
    }
    if (epochToExchangeRate[epochToClaim] == 0) {
      revert ExchangeRateNotSet();
    }
    uint256 cashOwed = _getMintAmountForEpoch(
      collateralDeposited,
      epochToClaim
    );
    mintRequestsPerEpoch[epochToClaim][user] = 0;
    cash.mint(user, cashOwed);
    emit MintCompleted(
      user,
      cashOwed,
      collateralDeposited,
      epochToExchangeRate[epochToClaim],
      epochToClaim
    );
  }
  function setMintExchangeRate(
    uint256 exchangeRate,
    uint256 epochToSet
  ) external override updateEpoch onlyRole(SETTER_ADMIN) {
    if (exchangeRate == 0) {
      revert ZeroExchangeRate();
    }
    if (epochToSet >= currentEpoch) {
      revert EpochNotElapsed();
    }
    if (epochToExchangeRate[epochToSet] != 0) {
      revert EpochExchangeRateAlreadySet();
    }
    uint256 rateDifference;
    if (exchangeRate > lastSetMintExchangeRate) {
      rateDifference = exchangeRate - lastSetMintExchangeRate;
    } else if (exchangeRate < lastSetMintExchangeRate) {
      rateDifference = lastSetMintExchangeRate - exchangeRate;
    }
    uint256 maxDifferenceThisEpoch = (lastSetMintExchangeRate *
      exchangeRateDeltaLimit) / BPS_DENOMINATOR;
    if (rateDifference > maxDifferenceThisEpoch) {
      epochToExchangeRate[epochToSet] = exchangeRate;
      _pause();
      emit MintExchangeRateCheckFailed(
        epochToSet,
        lastSetMintExchangeRate,
        exchangeRate
      );
    } else {
      uint256 oldExchangeRate = lastSetMintExchangeRate;
      epochToExchangeRate[epochToSet] = exchangeRate;
      lastSetMintExchangeRate = exchangeRate;
      emit MintExchangeRateSet(epochToSet, oldExchangeRate, exchangeRate);
    }
  }
  function setPendingMintBalance(
    address user,
    uint256 epoch,
    uint256 oldBalance,
    uint256 newBalance
  ) external updateEpoch onlyRole(MANAGER_ADMIN) {
    if (oldBalance != mintRequestsPerEpoch[epoch][user]) {
      revert UnexpectedMintBalance();
    }
    if (epoch > currentEpoch) {
      revert CannotServiceFutureEpoch();
    }
    mintRequestsPerEpoch[epoch][user] = newBalance;
    emit PendingMintBalanceSet(user, epoch, oldBalance, newBalance);
  }
  function overrideExchangeRate(
    uint256 correctExchangeRate,
    uint256 epochToSet,
    uint256 _lastSetMintExchangeRate
  ) external override updateEpoch onlyRole(MANAGER_ADMIN) {
    if (epochToSet >= currentEpoch) {
      revert MustServicePastEpoch();
    }
    uint256 incorrectRate = epochToExchangeRate[epochToSet];
    epochToExchangeRate[epochToSet] = correctExchangeRate;
    if (_lastSetMintExchangeRate != 0) {
      lastSetMintExchangeRate = _lastSetMintExchangeRate;
    }
    emit MintExchangeRateOverridden(
      epochToSet,
      incorrectRate,
      correctExchangeRate,
      lastSetMintExchangeRate
    );
  }
  function setMintExchangeRateDeltaLimit(
    uint256 _exchangeRateDeltaLimit
  ) external override onlyRole(MANAGER_ADMIN) {
    uint256 oldExchangeRateDeltaLimit = exchangeRateDeltaLimit;
    exchangeRateDeltaLimit = _exchangeRateDeltaLimit;
    emit ExchangeRateDeltaLimitSet(
      oldExchangeRateDeltaLimit,
      _exchangeRateDeltaLimit
    );
  }
  function setMintFee(
    uint256 _mintFee
  ) external override onlyRole(MANAGER_ADMIN) {
    if (_mintFee >= BPS_DENOMINATOR) {
      revert MintFeeTooLarge();
    }
    uint256 oldMintFee = mintFee;
    mintFee = _mintFee;
    emit MintFeeSet(oldMintFee, _mintFee);
  }
  function setMinimumDepositAmount(
    uint256 _minimumDepositAmount
  ) external override onlyRole(MANAGER_ADMIN) {
    if (_minimumDepositAmount < BPS_DENOMINATOR) {
      revert MinimumDepositAmountTooSmall();
    }
    uint256 oldMinimumDepositAmount = minimumDepositAmount;
    minimumDepositAmount = _minimumDepositAmount;
    emit MinimumDepositAmountSet(
      oldMinimumDepositAmount,
      _minimumDepositAmount
    );
  }
  function setFeeRecipient(
    address _feeRecipient
  ) external override onlyRole(MANAGER_ADMIN) {
    address oldFeeRecipient = feeRecipient;
    feeRecipient = _feeRecipient;
    emit FeeRecipientSet(oldFeeRecipient, _feeRecipient);
  }
  function setAssetRecipient(
    address _assetRecipient
  ) external override onlyRole(MANAGER_ADMIN) {
    address oldAssetRecipient = assetRecipient;
    assetRecipient = _assetRecipient;
    emit AssetRecipientSet(oldAssetRecipient, _assetRecipient);
  }
  function _getMintAmountForEpoch(
    uint256 collateralAmountIn,
    uint256 epoch
  ) private view returns (uint256 cashAmountOut) {
    uint256 amountE24 = _scaleUp(collateralAmountIn) * 1e6;
    cashAmountOut = amountE24 / epochToExchangeRate[epoch];
  }
  function _getMintFees(
    uint256 collateralAmount
  ) private view returns (uint256) {
    return (collateralAmount * mintFee) / BPS_DENOMINATOR;
  }
  function _scaleUp(uint256 amount) private view returns (uint256) {
    return amount * decimalsMultiplier;
  }
  function pause() external onlyRole(PAUSER_ADMIN) {
    _pause();
  }
  function unpause() external onlyRole(MANAGER_ADMIN) {
    _unpause();
  }
  function setEpochDuration(
    uint256 _epochDuration
  ) external onlyRole(MANAGER_ADMIN) {
    uint256 oldEpochDuration = epochDuration;
    epochDuration = _epochDuration;
    emit EpochDurationSet(oldEpochDuration, _epochDuration);
  }
  modifier updateEpoch() {
    transitionEpoch();
    _;
  }
  function transitionEpoch() public {
    uint256 epochDifference = (block.timestamp - currentEpochStartTimestamp) /
      epochDuration;
    if (epochDifference > 0) {
      currentRedeemAmount = 0;
      currentMintAmount = 0;
      currentEpoch += epochDifference;
      currentEpochStartTimestamp =
        block.timestamp -
        (block.timestamp % epochDuration);
    }
  }
  function setMintLimit(uint256 _mintLimit) external onlyRole(MANAGER_ADMIN) {
    uint256 oldMintLimit = mintLimit;
    mintLimit = _mintLimit;
    emit MintLimitSet(oldMintLimit, _mintLimit);
  }
  function setRedeemLimit(
    uint256 _redeemLimit
  ) external onlyRole(MANAGER_ADMIN) {
    uint256 oldRedeemLimit = redeemLimit;
    redeemLimit = _redeemLimit;
    emit RedeemLimitSet(oldRedeemLimit, _redeemLimit);
  }
  function _checkAndUpdateMintLimit(uint256 collateralAmountIn) private {
    if (collateralAmountIn > mintLimit - currentMintAmount) {
      revert MintExceedsRateLimit();
    }
    currentMintAmount += collateralAmountIn;
  }
  function _checkAndUpdateRedeemLimit(uint256 amount) private {
    if (amount == 0) {
      revert RedeemAmountCannotBeZero();
    }
    if (amount > redeemLimit - currentRedeemAmount) {
      revert RedeemExceedsRateLimit();
    }
    currentRedeemAmount += amount;
  }
  function requestRedemption(
    uint256 amountCashToRedeem
  )
    external
    override
    updateEpoch
    nonReentrant
    whenNotPaused
    checkKYC(msg.sender)
  {
    if (amountCashToRedeem < minimumRedeemAmount) {
      revert WithdrawRequestAmountTooSmall();
    }
    _checkAndUpdateRedeemLimit(amountCashToRedeem);
    redemptionInfoPerEpoch[currentEpoch].addressToBurnAmt[
        msg.sender
      ] += amountCashToRedeem;
    redemptionInfoPerEpoch[currentEpoch].totalBurned += amountCashToRedeem;
    cash.burnFrom(msg.sender, amountCashToRedeem);
    emit RedemptionRequested(msg.sender, amountCashToRedeem, currentEpoch);
  }
  function completeRedemptions(
    address[] calldata redeemers,
    address[] calldata refundees,
    uint256 collateralAmountToDist,
    uint256 epochToService,
    uint256 fees
  ) external override updateEpoch onlyRole(MANAGER_ADMIN) {
    _checkAddressesKYC(redeemers);
    _checkAddressesKYC(refundees);
    if (epochToService >= currentEpoch) {
      revert MustServicePastEpoch();
    }
    uint256 refundedAmt = _processRefund(refundees, epochToService);
    uint256 quantityBurned = redemptionInfoPerEpoch[epochToService]
      .totalBurned - refundedAmt;
    uint256 amountToDist = collateralAmountToDist - fees;
    _processRedemption(redeemers, amountToDist, quantityBurned, epochToService);
    collateral.safeTransferFrom(assetSender, feeRecipient, fees);
    emit RedemptionFeesCollected(feeRecipient, fees, epochToService);
  }
  function _processRedemption(
    address[] calldata redeemers,
    uint256 amountToDist,
    uint256 quantityBurned,
    uint256 epochToService
  ) private {
    uint256 size = redeemers.length;
    for (uint256 i = 0; i < size; ++i) {
      address redeemer = redeemers[i];
      uint256 cashAmountReturned = redemptionInfoPerEpoch[epochToService]
        .addressToBurnAmt[redeemer];
      redemptionInfoPerEpoch[epochToService].addressToBurnAmt[redeemer] = 0;
      uint256 collateralAmountDue = (amountToDist * cashAmountReturned) /
        quantityBurned;
      if (collateralAmountDue == 0) {
        revert CollateralRedemptionTooSmall();
      }
      collateral.safeTransferFrom(assetSender, redeemer, collateralAmountDue);
      emit RedemptionCompleted(
        redeemer,
        cashAmountReturned,
        collateralAmountDue,
        epochToService
      );
    }
  }
  function _processRefund(
    address[] calldata refundees,
    uint256 epochToService
  ) private returns (uint256 totalCashAmountRefunded) {
    uint256 size = refundees.length;
    for (uint256 i = 0; i < size; ++i) {
      address refundee = refundees[i];
      uint256 cashAmountBurned = redemptionInfoPerEpoch[epochToService]
        .addressToBurnAmt[refundee];
      redemptionInfoPerEpoch[epochToService].addressToBurnAmt[refundee] = 0;
      cash.mint(refundee, cashAmountBurned);
      totalCashAmountRefunded += cashAmountBurned;
      emit RefundIssued(refundee, cashAmountBurned, epochToService);
    }
    return totalCashAmountRefunded;
  }
  function setAssetSender(
    address newAssetSender
  ) external onlyRole(MANAGER_ADMIN) {
    address oldAssetSender = assetSender;
    assetSender = newAssetSender;
    emit AssetSenderSet(oldAssetSender, newAssetSender);
  }
  function setRedeemMinimum(
    uint256 newRedeemMinimum
  ) external onlyRole(MANAGER_ADMIN) {
    uint256 oldRedeemMin = minimumRedeemAmount;
    minimumRedeemAmount = newRedeemMinimum;
    emit MinimumRedeemAmountSet(oldRedeemMin, minimumRedeemAmount);
  }
  function getBurnedQuantity(
    uint256 epoch,
    address user
  ) external view returns (uint256) {
    return redemptionInfoPerEpoch[epoch].addressToBurnAmt[user];
  }
  function setPendingRedemptionBalance(
    address user,
    uint256 epoch,
    uint256 balance
  ) external updateEpoch onlyRole(MANAGER_ADMIN) {
    if (epoch > currentEpoch) {
      revert CannotServiceFutureEpoch();
    }
    uint256 previousBalance = redemptionInfoPerEpoch[epoch].addressToBurnAmt[
      user
    ];
    if (balance < previousBalance) {
      redemptionInfoPerEpoch[epoch].totalBurned -= previousBalance - balance;
    } else if (balance > previousBalance) {
      redemptionInfoPerEpoch[epoch].totalBurned += balance - previousBalance;
    }
    redemptionInfoPerEpoch[epoch].addressToBurnAmt[user] = balance;
    emit PendingRedemptionBalanceSet(
      user,
      epoch,
      balance,
      redemptionInfoPerEpoch[epoch].totalBurned
    );
  }
  modifier checkKYC(address account) {
    _checkKYC(account);
    _;
  }
  function setKYCRequirementGroup(
    uint256 _kycRequirementGroup
  ) external override onlyRole(MANAGER_ADMIN) {
    _setKYCRequirementGroup(_kycRequirementGroup);
  }
  function setKYCRegistry(
    address _kycRegistry
  ) external override onlyRole(MANAGER_ADMIN) {
    _setKYCRegistry(_kycRegistry);
  }
  function _checkKYC(address account) private view {
    if (!_getKYCStatus(account)) {
      revert KYCCheckFailed();
    }
  }
  function _checkAddressesKYC(address[] calldata accounts) private view {
    uint256 size = accounts.length;
    for (uint256 i = 0; i < size; ++i) {
      _checkKYC(accounts[i]);
    }
  }
  function multiexcall(
    ExCallData[] calldata exCallData
  )
    external
    payable
    override
    nonReentrant
    onlyRole(MANAGER_ADMIN)
    whenPaused
    returns (bytes[] memory results)
  {
    results = new bytes[](exCallData.length);
    for (uint256 i = 0; i < exCallData.length; ++i) {
      (bool success, bytes memory ret) = address(exCallData[i].target).call{
        value: exCallData[i].value
      }(exCallData[i].data);
      require(success, "Call Failed");
      results[i] = ret;
    }
  }
}