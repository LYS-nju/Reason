pragma solidity ^0.8.7;
interface IMapleLoanEvents {
    event BorrowerAccepted(address indexed borrower_);
    event CollateralPosted(uint256 amount_);
    event CollateralRemoved(uint256 amount_, address indexed destination_);
    event Funded(address indexed lender_, uint256 amount_, uint256 nextPaymentDueDate_);
    event FundsClaimed(uint256 amount_, address indexed destination_);
    event FundsDrawnDown(uint256 amount_, address indexed destination_);
    event FundsRedirected(uint256 amount_, address indexed destination_);
    event FundsReturned(uint256 amount_);
    event Initialized(address indexed borrower_, address[2] assets_, uint256[3] termDetails_, uint256[3] amounts_, uint256[4] rates_);
    event LenderAccepted(address indexed lender_);
    event LoanClosed(uint256 principalPaid_, uint256 interestPaid_);
    event NewTermsAccepted(bytes32 refinanceCommitment_, address refinancer_, bytes[] calls_);
    event NewTermsProposed(bytes32 refinanceCommitment_, address refinancer_, bytes[] calls_);
    event PaymentMade(uint256 principalPaid_, uint256 interestPaid_);
    event PendingBorrowerSet(address pendingBorrower_);
    event PendingLenderSet(address pendingLender_);
    event Repossessed(uint256 collateralRepossessed_, uint256 fundsRepossessed_, address indexed destination_);
    event Skimmed(address indexed token_, uint256 amount_, address indexed destination_);
}
interface IProxied {
    function factory() external view returns (address factory_);
    function implementation() external view returns (address implementation_);
    function setImplementation(address newImplementation_) external;
    function migrate(address migrator_, bytes calldata arguments_) external;
}
interface IMapleProxied is IProxied {
    event Upgraded(uint256 toVersion_, bytes arguments_);
    function upgrade(uint256 toVersion_, bytes calldata arguments_) external;
}
interface IMapleLoan is IMapleProxied, IMapleLoanEvents {
    function borrower() external view returns (address borrower_);
    function claimableFunds() external view returns (uint256 claimableFunds_);
    function collateral() external view returns (uint256 collateral_);
    function collateralAsset() external view returns (address collateralAsset_);
    function collateralRequired() external view returns (uint256 collateralRequired_);
    function drawableFunds() external view returns (uint256 drawableFunds_);
    function earlyFeeRate() external view returns (uint256 earlyFeeRate_);
    function endingPrincipal() external view returns (uint256 endingPrincipal_);
    function fundsAsset() external view returns (address fundsAsset_);
    function gracePeriod() external view returns (uint256 gracePeriod_);
    function interestRate() external view returns (uint256 interestRate_);
    function lateFeeRate() external view returns (uint256 lateFeeRate_);
    function lateInterestPremium() external view returns (uint256 lateInterestPremium_);
    function lender() external view returns (address lender_);
    function nextPaymentDueDate() external view returns (uint256 nextPaymentDueDate_);
    function paymentInterval() external view returns (uint256 paymentInterval_);
    function paymentsRemaining() external view returns (uint256 paymentsRemaining_);
    function pendingBorrower() external view returns (address pendingBorrower_);
    function pendingLender() external view returns (address pendingLender_);
    function principal() external view returns (uint256 principal_);
    function principalRequested() external view returns (uint256 principalRequested_);
    function superFactory() external view returns (address superFactory_);
    function acceptBorrower() external;
    function acceptLender() external;
    function acceptNewTerms(address refinancer_, bytes[] calldata calls_, uint256 amount_) external;
    function claimFunds(uint256 amount_, address destination_) external;
    function closeLoan(uint256 amount_) external returns (uint256 principal_, uint256 interest_);
    function drawdownFunds(uint256 amount_, address destination_) external returns (uint256 collateralPosted_);
    function fundLoan(address lender_, uint256 amount_) external returns (uint256 fundsLent_);
    function makePayment(uint256 amount_) external returns (uint256 principal_, uint256 interest_);
    function postCollateral(uint256 amount_) external returns (uint256 collateralPosted_);
    function proposeNewTerms(address refinancer_, bytes[] calldata calls_) external;
    function removeCollateral(uint256 amount_, address destination_) external;
    function returnFunds(uint256 amount_) external returns (uint256 fundsReturned_);
    function repossess(address destination_) external returns (uint256 collateralRepossessed_, uint256 fundsRepossessed_);
    function setPendingBorrower(address pendingBorrower_) external;
    function setPendingLender(address pendingLender_) external;
    function skim(address token_, address destination_) external returns (uint256 skimmed_);
    function excessCollateral() external view returns (uint256 excessCollateral_);
    function getAdditionalCollateralRequiredFor(uint256 drawdown_) external view returns (uint256 additionalCollateral_);
    function getEarlyPaymentBreakdown() external view returns (
        uint256 totalPrincipalAmount_,
        uint256 totalInterestFees_
    );
    function getNextPaymentBreakdown() external view returns (
        uint256 totalPrincipalAmount_,
        uint256 totalInterestFees_
    );
    function isProtocolPaused() external view returns (bool paused_);
}
interface ILenderLike {
    function investorFee() external view returns (uint256 investorFee_);
    function mapleTreasury() external view returns (address mapleTreasury_);
    function poolDelegate() external view returns (address poolDelegate_);
    function treasuryFee() external view returns (uint256 treasuryFee_);
}
interface IMapleGlobalsLike {
    function governor() external view returns (address governor_);
    function protocolPaused() external view returns (bool paused_);
}
interface IERC20Like {
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address owner, address recipient, uint256 amount) external returns (bool);
}
library ERC20Helper {
    function transfer(address token, address to, uint256 amount) internal returns (bool) {
        return _call(token, abi.encodeWithSelector(IERC20Like.transfer.selector, to, amount));
    }
    function transferFrom(address token, address from, address to, uint256 amount) internal returns (bool) {
        return _call(token, abi.encodeWithSelector(IERC20Like.transferFrom.selector, from, to, amount));
    }
    function approve(address token, address spender, uint256 amount) internal returns (bool) {
        return _call(token, abi.encodeWithSelector(IERC20Like.approve.selector, spender, amount));
    }
    function _call(address token, bytes memory data) private returns (bool success) {
        uint256 size;
        assembly {
            size := extcodesize(token)
        }
        if (size == uint256(0)) return false;
        bytes memory returnData;
        (success, returnData) = token.call(data);
        return success && (returnData.length == 0 || abi.decode(returnData, (bool)));
    }
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address owner, address recipient, uint256 amount) external returns (bool);
}
contract SlotManipulatable {
    function _getReferenceTypeSlot(bytes32 slot_, bytes32 key_) internal pure returns (bytes32 value_) {
        return keccak256(abi.encodePacked(key_, slot_));
    }
    function _getSlotValue(bytes32 slot_) internal view returns (bytes32 value_) {
        assembly {
            value_ := sload(slot_)
        }
    }
    function _setSlotValue(bytes32 slot_, bytes32 value_) internal {
        assembly {
            sstore(slot_, value_)
        }
    }
}
contract Proxied is SlotManipulatable {
    bytes32 private constant FACTORY_SLOT = bytes32(0x7a45a402e4cb6e08ebc196f20f66d5d30e67285a2a8aa80503fa409e727a4af1);
    bytes32 private constant IMPLEMENTATION_SLOT = bytes32(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc);
    function _migrate(address migrator_, bytes calldata arguments_) internal virtual returns (bool success_) {
        uint256 size;
        assembly {
            size := extcodesize(migrator_)
        }
        if (size == uint256(0)) return false;
        ( success_, ) = migrator_.delegatecall(arguments_);
    }
    function _setImplementation(address newImplementation_) internal virtual returns (bool success_) {
        _setSlotValue(IMPLEMENTATION_SLOT, bytes32(uint256(uint160(newImplementation_))));
        return true;
    }
    function _factory() internal view virtual returns (address factory_) {
        return address(uint160(uint256(_getSlotValue(FACTORY_SLOT))));
    }
    function _implementation() internal view virtual returns (address implementation_) {
        return address(uint160(uint256(_getSlotValue(IMPLEMENTATION_SLOT))));
    }
}
contract MapleProxied is Proxied {}
contract MapleLoanInternals is MapleProxied {
    uint256 private constant SCALED_ONE = uint256(10 ** 18);
    address internal _borrower;         
    address internal _lender;           
    address internal _pendingBorrower;  
    address internal _pendingLender;    
    address internal _collateralAsset;  
    address internal _fundsAsset;       
    uint256 internal _gracePeriod;      
    uint256 internal _paymentInterval;  
    uint256 internal _interestRate;         
    uint256 internal _earlyFeeRate;         
    uint256 internal _lateFeeRate;          
    uint256 internal _lateInterestPremium;  
    uint256 internal _collateralRequired;  
    uint256 internal _principalRequested;  
    uint256 internal _endingPrincipal;     
    uint256 internal _drawableFunds;       
    uint256 internal _claimableFunds;      
    uint256 internal _collateral;          
    uint256 internal _nextPaymentDueDate;  
    uint256 internal _paymentsRemaining;   
    uint256 internal _principal;           
    bytes32 internal _refinanceCommitment;
    function _clearLoanAccounting() internal {
        _gracePeriod     = uint256(0);
        _paymentInterval = uint256(0);
        _interestRate        = uint256(0);
        _earlyFeeRate        = uint256(0);
        _lateFeeRate         = uint256(0);
        _lateInterestPremium = uint256(0);
        _endingPrincipal = uint256(0);
        _nextPaymentDueDate = uint256(0);
        _paymentsRemaining  = uint256(0);
        _principal          = uint256(0);
    }
    function _initialize(
        address borrower_,
        address[2] memory assets_,
        uint256[3] memory termDetails_,
        uint256[3] memory amounts_,
        uint256[4] memory rates_
    )
        internal
    {
        require(amounts_[1] > uint256(0), "MLI:I:INVALID_PRINCIPAL");
        require(amounts_[2] <= amounts_[1], "MLI:I:INVALID_ENDING_PRINCIPAL");
        _borrower = borrower_;
        _collateralAsset = assets_[0];
        _fundsAsset      = assets_[1];
        _gracePeriod       = termDetails_[0];
        _paymentInterval   = termDetails_[1];
        _paymentsRemaining = termDetails_[2];
        _collateralRequired = amounts_[0];
        _principalRequested = amounts_[1];
        _endingPrincipal    = amounts_[2];
        _interestRate        = rates_[0];
        _earlyFeeRate        = rates_[1];
        _lateFeeRate         = rates_[2];
        _lateInterestPremium = rates_[3];
    }
    function _closeLoan() internal returns (uint256 principal_, uint256 interest_) {
        require(block.timestamp <= _nextPaymentDueDate, "MLI:CL:PAYMENT_IS_LATE");
        ( principal_, interest_ ) = _getEarlyPaymentBreakdown();
        uint256 totalPaid_ = principal_ + interest_;
        _drawableFunds = _drawableFunds + _getUnaccountedAmount(_fundsAsset) - totalPaid_;
        _claimableFunds += totalPaid_;
        _clearLoanAccounting();
    }
    function _drawdownFunds(uint256 amount_, address destination_) internal {
        _drawableFunds -= amount_;
        require(ERC20Helper.transfer(_fundsAsset, destination_, amount_), "MLI:DF:TRANSFER_FAILED");
        require(_isCollateralMaintained(),                                "MLI:DF:INSUFFICIENT_COLLATERAL");
    }
    function _makePayment() internal returns (uint256 principal_, uint256 interest_) {
        ( principal_, interest_ ) = _getNextPaymentBreakdown();
        uint256 totalPaid_ = principal_ + interest_;
        _drawableFunds = (_drawableFunds + _getUnaccountedAmount(_fundsAsset)) - totalPaid_;
        _claimableFunds += totalPaid_;
        if (_paymentsRemaining == uint256(1)) {
            _clearLoanAccounting();  
        } else {
            _nextPaymentDueDate += _paymentInterval;
            _principal          -= principal_;
            _paymentsRemaining--;
        }
    }
    function _postCollateral() internal returns (uint256 collateralPosted_) {
        _collateral += (collateralPosted_ = _getUnaccountedAmount(_collateralAsset));
    }
    function _proposeNewTerms(address refinancer_, bytes[] calldata calls_) internal returns (bytes32 proposedRefinanceCommitment_) {
        return _refinanceCommitment =
            calls_.length > uint256(0)
                ? _getRefinanceCommitment(refinancer_, calls_)
                : bytes32(0);
    }
    function _removeCollateral(uint256 amount_, address destination_) internal {
        _collateral -= amount_;
        require(ERC20Helper.transfer(_collateralAsset, destination_, amount_), "MLI:RC:TRANSFER_FAILED");
        require(_isCollateralMaintained(),                                     "MLI:RC:INSUFFICIENT_COLLATERAL");
    }
    function _returnFunds() internal returns (uint256 fundsReturned_) {
        _drawableFunds += (fundsReturned_ = _getUnaccountedAmount(_fundsAsset));
    }
    function _acceptNewTerms(address refinancer_, bytes[] calldata calls_) internal returns (bytes32 acceptedRefinanceCommitment_) {
        require(_refinanceCommitment == (acceptedRefinanceCommitment_ = _getRefinanceCommitment(refinancer_, calls_)), "MLI:ANT:COMMITMENT_MISMATCH");
        uint256 size;
        assembly {
            size := extcodesize(refinancer_)
        }
        require(size != uint256(0), "MLI:ANT:INVALID_REFINANCER");
        _refinanceCommitment = bytes32(0);
        uint256 callCount = calls_.length;
        for (uint256 i; i < callCount; ++i) {
            ( bool success, ) = refinancer_.delegatecall(calls_[i]);
            require(success, "MLI:ANT:FAILED");
        }
        require(_isCollateralMaintained(), "MLI:ANT:INSUFFICIENT_COLLATERAL");
    }
    function _claimFunds(uint256 amount_, address destination_) internal {
        _claimableFunds -= amount_;
        require(ERC20Helper.transfer(_fundsAsset, destination_, amount_), "MLI:CF:TRANSFER_FAILED");
    }
    function _fundLoan(address lender_) internal returns (uint256 fundsLent_) {
        require((_nextPaymentDueDate == uint256(0)) && (_paymentsRemaining != uint256(0)), "MLI:FL:LOAN_ACTIVE");
        _lender             = lender_;
        _nextPaymentDueDate = block.timestamp + _paymentInterval;
        fundsLent_ = _principal = _principalRequested;
        require(_getUnaccountedAmount(_fundsAsset) >= fundsLent_, "MLI:FL:WRONG_FUND_AMOUNT");
        uint256 treasuryFee = (fundsLent_ * ILenderLike(lender_).treasuryFee() * _paymentInterval * _paymentsRemaining) / uint256(365 days * 10_000);
        uint256 delegateFee = (fundsLent_ * ILenderLike(lender_).investorFee() * _paymentInterval * _paymentsRemaining) / uint256(365 days * 10_000);
        _drawableFunds = fundsLent_ - treasuryFee - delegateFee;
        require(
            treasuryFee == uint256(0) || ERC20Helper.transfer(_fundsAsset, ILenderLike(lender_).mapleTreasury(), treasuryFee),
            "MLI:FL:T_TRANSFER_FAILED"
        );
        require(
            delegateFee == uint256(0) || ERC20Helper.transfer(_fundsAsset, ILenderLike(lender_).poolDelegate(), delegateFee),
            "MLI:FL:PD_TRANSFER_FAILED"
        );
    }
    function _repossess(address destination_) internal returns (uint256 collateralRepossessed_, uint256 fundsRepossessed_) {
        uint256 nextPaymentDueDate = _nextPaymentDueDate;
        require(
            nextPaymentDueDate != uint256(0) && (block.timestamp > nextPaymentDueDate + _gracePeriod),
            "MLI:R:NOT_IN_DEFAULT"
        );
        _clearLoanAccounting();
        _collateral     = uint256(0);
        _claimableFunds = uint256(0);
        _drawableFunds  = uint256(0);
        require(
            (collateralRepossessed_ = _getUnaccountedAmount(_collateralAsset)) == uint256(0) ||
            ERC20Helper.transfer(_collateralAsset, destination_, collateralRepossessed_),
            "MLI:R:C_TRANSFER_FAILED"
        );
        require(
            (fundsRepossessed_ = _getUnaccountedAmount(_fundsAsset)) == uint256(0) ||
            ERC20Helper.transfer(_fundsAsset, destination_, fundsRepossessed_),
            "MLI:R:F_TRANSFER_FAILED"
        );
    }
    function _isCollateralMaintained() internal view returns (bool isMaintained_) {
        return _collateral >= _getCollateralRequiredFor(_principal, _drawableFunds, _principalRequested, _collateralRequired);
    }
    function _getEarlyPaymentBreakdown() internal view returns (uint256 principal_, uint256 interest_) {
        principal_ = _principal;
        interest_  = (_principal * _earlyFeeRate) / SCALED_ONE;
    }
    function _getNextPaymentBreakdown() internal view returns (uint256 principal_, uint256 interest_) {
        ( principal_, interest_ ) = _getPaymentBreakdown(
            block.timestamp,
            _nextPaymentDueDate,
            _paymentInterval,
            _principal,
            _endingPrincipal,
            _paymentsRemaining,
            _interestRate,
            _lateFeeRate,
            _lateInterestPremium
        );
    }
    function _getUnaccountedAmount(address asset_) internal view virtual returns (uint256 unaccountedAmount_) {
        return IERC20(asset_).balanceOf(address(this))
            - (asset_ == _collateralAsset ? _collateral : uint256(0))                   
            - (asset_ == _fundsAsset ? _claimableFunds + _drawableFunds : uint256(0));  
    }
    function _getCollateralRequiredFor(
        uint256 principal_,
        uint256 drawableFunds_,
        uint256 principalRequested_,
        uint256 collateralRequired_
    )
        internal pure returns (uint256 collateral_)
    {
        return (collateralRequired_ * (principal_ > drawableFunds_ ? principal_ - drawableFunds_ : uint256(0))) / principalRequested_;
    }
    function _getInstallment(uint256 principal_, uint256 endingPrincipal_, uint256 interestRate_, uint256 paymentInterval_, uint256 totalPayments_)
        internal pure virtual returns (uint256 principalAmount_, uint256 interestAmount_)
    {
        uint256 periodicRate = _getPeriodicInterestRate(interestRate_, paymentInterval_);
        uint256 raisedRate   = _scaledExponent(SCALED_ONE + periodicRate, totalPayments_, SCALED_ONE);
        if (raisedRate <= SCALED_ONE) return ((principal_ - endingPrincipal_) / totalPayments_, uint256(0));
        uint256 total = ((((principal_ * raisedRate) / SCALED_ONE) - endingPrincipal_) * periodicRate) / (raisedRate - SCALED_ONE);
        interestAmount_  = _getInterest(principal_, interestRate_, paymentInterval_);
        principalAmount_ = total >= interestAmount_ ? total - interestAmount_ : uint256(0);
    }
    function _getInterest(uint256 principal_, uint256 interestRate_, uint256 interval_) internal pure virtual returns (uint256 interest_) {
        return (principal_ * _getPeriodicInterestRate(interestRate_, interval_)) / SCALED_ONE;
    }
    function _getPaymentBreakdown(
        uint256 currentTime_,
        uint256 nextPaymentDueDate_,
        uint256 paymentInterval_,
        uint256 principal_,
        uint256 endingPrincipal_,
        uint256 paymentsRemaining_,
        uint256 interestRate_,
        uint256 lateFeeRate_,
        uint256 lateInterestPremium_
    )
        internal pure virtual
        returns (uint256 principalAmount_, uint256 interestAmount_)
    {
        ( principalAmount_,interestAmount_ ) = _getInstallment(
            principal_,
            endingPrincipal_,
            interestRate_,
            paymentInterval_,
            paymentsRemaining_
        );
        principalAmount_ = paymentsRemaining_ == uint256(1) ? principal_ : principalAmount_;
        if (currentTime_ > nextPaymentDueDate_) {
            interestAmount_ += _getInterest(principal_, interestRate_ + lateInterestPremium_, currentTime_ - nextPaymentDueDate_);
            interestAmount_ += (lateFeeRate_ * principal_) / SCALED_ONE;
        }
    }
    function _getPeriodicInterestRate(uint256 interestRate_, uint256 interval_) internal pure virtual returns (uint256 periodicInterestRate_) {
        return (interestRate_ * interval_) / uint256(365 days);
    }
    function _getRefinanceCommitment(address refinancer_, bytes[] calldata calls_) internal pure returns (bytes32 refinanceCommitment_) {
        return keccak256(abi.encode(refinancer_, calls_));
    }
    function _scaledExponent(uint256 base_, uint256 exponent_, uint256 one_) internal pure returns (uint256 result_) {
        result_ = exponent_ & uint256(1) != uint256(0) ? base_ : one_;          
        while ((exponent_ >>= uint256(1)) != uint256(0)) {                      
            base_ = (base_ * base_) / one_;                                     
            if (exponent_ & uint256(1) == uint256(0)) continue;
            result_ = (result_ * base_) / one_;                                 
        }
    }
}
interface IDefaultImplementationBeacon {
    function defaultImplementation() external view returns (address defaultImplementation_);
}
interface IMapleProxyFactory is IDefaultImplementationBeacon {
    event DefaultVersionSet(uint256 indexed version);
    event ImplementationRegistered(uint256 indexed version, address indexed implementationAddress, address indexed initializer);
    event InstanceDeployed(uint256 indexed version, address indexed instance, bytes initializationArguments);
    event InstanceUpgraded(address indexed instance, uint256 indexed fromVersion, uint256 indexed toVersion, bytes migrationArguments);
    event UpgradePathDisabled(uint256 indexed fromVersion, uint256 indexed toVersion);
    event UpgradePathEnabled(uint256 indexed fromVersion, uint256 indexed toVersion, address indexed migrator);
    function defaultVersion() external view returns (uint256 defaultVersion_);
    function mapleGlobals() external view returns (address mapleGlobals_);
    function upgradeEnabledForPath(uint256 toVersion_, uint256 fromVersion_) external view returns (bool allowed_);
    function createInstance(bytes calldata arguments_, bytes32 salt_) external returns (address instance_);
    function enableUpgradePath(uint256 fromVersion_, uint256 toVersion_, address migrator_) external;
    function disableUpgradePath(uint256 fromVersion_, uint256 toVersion_) external;
    function registerImplementation(uint256 version_, address implementationAddress_, address initializer_) external;
    function setDefaultVersion(uint256 version_) external;
    function upgradeInstance(uint256 toVersion_, bytes calldata arguments_) external;
    function getInstanceAddress(bytes calldata arguments_, bytes32 salt_) external view returns (address instanceAddress_);
    function implementationOf(uint256 version_) external view returns (address implementation_);
    function migratorForPath(uint256 oldVersion_, uint256 newVersion_) external view returns (address migrator_);
    function versionOf(address implementation_) external view returns (uint256 version_);
}
contract MapleLoan is IMapleLoan, MapleLoanInternals {
    modifier whenProtocolNotPaused() {
        require(!isProtocolPaused(), "ML:PROTOCOL_PAUSED");
        _;
    }
    function migrate(address migrator_, bytes calldata arguments_) external override {
        require(msg.sender == _factory(),        "ML:M:NOT_FACTORY");
        require(_migrate(migrator_, arguments_), "ML:M:FAILED");
    }
    function setImplementation(address newImplementation_) external override {
        require(msg.sender == _factory(),               "ML:SI:NOT_FACTORY");
        require(_setImplementation(newImplementation_), "ML:SI:FAILED");
    }
    function upgrade(uint256 toVersion_, bytes calldata arguments_) external override {
        require(msg.sender == _borrower, "ML:U:NOT_BORROWER");
        emit Upgraded(toVersion_, arguments_);
        IMapleProxyFactory(_factory()).upgradeInstance(toVersion_, arguments_);
    }
    function acceptBorrower() external override {
        require(msg.sender == _pendingBorrower, "ML:AB:NOT_PENDING_BORROWER");
        _pendingBorrower = address(0);
        emit BorrowerAccepted(_borrower = msg.sender);
    }
    function closeLoan(uint256 amount_) external override returns (uint256 principal_, uint256 interest_) {
        require(amount_ == uint256(0) || ERC20Helper.transferFrom(_fundsAsset, msg.sender, address(this), amount_), "ML:CL:TRANSFER_FROM_FAILED");
        ( principal_, interest_ ) = _closeLoan();
        emit LoanClosed(principal_, interest_);
    }
    function drawdownFunds(uint256 amount_, address destination_) external override whenProtocolNotPaused returns (uint256 collateralPosted_) {
        require(msg.sender == _borrower, "ML:DF:NOT_BORROWER");
        emit FundsDrawnDown(amount_, destination_);
        uint256 additionalCollateralRequired = getAdditionalCollateralRequiredFor(amount_);
        if (additionalCollateralRequired > uint256(0)) {
            uint256 unaccountedCollateral = _getUnaccountedAmount(_collateralAsset);
            collateralPosted_ = postCollateral(
                additionalCollateralRequired > unaccountedCollateral ? additionalCollateralRequired - unaccountedCollateral : uint256(0)
            );
        }
        _drawdownFunds(amount_, destination_);
    }
    function makePayment(uint256 amount_) external override returns (uint256 principal_, uint256 interest_) {
        require(amount_ == uint256(0) || ERC20Helper.transferFrom(_fundsAsset, msg.sender, address(this), amount_), "ML:MP:TRANSFER_FROM_FAILED");
        ( principal_, interest_ ) = _makePayment();
        emit PaymentMade(principal_, interest_);
    }
    function postCollateral(uint256 amount_) public override whenProtocolNotPaused returns (uint256 collateralPosted_) {
        require(
            amount_ == uint256(0) || ERC20Helper.transferFrom(_collateralAsset, msg.sender, address(this), amount_),
            "ML:PC:TRANSFER_FROM_FAILED"
        );
        emit CollateralPosted(collateralPosted_ = _postCollateral());
    }
    function proposeNewTerms(address refinancer_, bytes[] calldata calls_) external override whenProtocolNotPaused {
        require(msg.sender == _borrower, "ML:PNT:NOT_BORROWER");
        emit NewTermsProposed(_proposeNewTerms(refinancer_, calls_), refinancer_, calls_);
    }
    function removeCollateral(uint256 amount_, address destination_) external override whenProtocolNotPaused {
        require(msg.sender == _borrower, "ML:RC:NOT_BORROWER");
        emit CollateralRemoved(amount_, destination_);
        _removeCollateral(amount_, destination_);
    }
    function returnFunds(uint256 amount_) public override whenProtocolNotPaused returns (uint256 fundsReturned_) {
        require(amount_ == uint256(0) || ERC20Helper.transferFrom(_fundsAsset, msg.sender, address(this), amount_), "ML:RF:TRANSFER_FROM_FAILED");
        emit FundsReturned(fundsReturned_ = _returnFunds());
    }
    function setPendingBorrower(address pendingBorrower_) external override {
        require(msg.sender == _borrower, "ML:SPB:NOT_BORROWER");
        emit PendingBorrowerSet(_pendingBorrower = pendingBorrower_);
    }
    function acceptLender() external override {
        require(msg.sender == _pendingLender, "ML:AL:NOT_PENDING_LENDER");
        _pendingLender = address(0);
        emit LenderAccepted(_lender = msg.sender);
    }
    function acceptNewTerms(address refinancer_, bytes[] calldata calls_, uint256 amount_) external override whenProtocolNotPaused {
        require(msg.sender == _lender, "ML:ANT:NOT_LENDER");
        require(amount_ == uint256(0) || ERC20Helper.transferFrom(_fundsAsset, msg.sender, address(this), amount_), "ML:ACT:TRANSFER_FROM_FAILED");
        emit NewTermsAccepted(_acceptNewTerms(refinancer_, calls_), refinancer_, calls_);
        uint256 extra = _getUnaccountedAmount(_fundsAsset);
        if (extra > uint256(0)) {
            emit FundsRedirected(extra, _lender);
            require(ERC20Helper.transfer(_fundsAsset, _lender, extra), "ML:ANT:TRANSFER_FAILED");
        }
    }
    function claimFunds(uint256 amount_, address destination_) external override whenProtocolNotPaused {
        require(msg.sender == _lender, "ML:CF:NOT_LENDER");
        emit FundsClaimed(amount_, destination_);
        _claimFunds(amount_, destination_);
    }
    function fundLoan(address lender_, uint256 amount_) external override whenProtocolNotPaused returns (uint256 fundsLent_) {
        require(amount_ == uint256(0) || ERC20Helper.transferFrom(_fundsAsset, msg.sender, address(this), amount_), "ML:FL:TRANSFER_FROM_FAILED");
        if (_nextPaymentDueDate == uint256(0)) {
            emit Funded(lender_, fundsLent_ = _fundLoan(lender_), _nextPaymentDueDate);
        }
        uint256 extra = _getUnaccountedAmount(_fundsAsset);
        if (extra > uint256(0)) {
            emit FundsRedirected(extra, _lender);
            require(ERC20Helper.transfer(_fundsAsset, _lender, extra), "ML:FL:TRANSFER_FAILED");
        }
    }
    function repossess(address destination_) external override whenProtocolNotPaused returns (uint256 collateralRepossessed_, uint256 fundsRepossessed_) {
        require(msg.sender == _lender, "ML:R:NOT_LENDER");
        ( collateralRepossessed_, fundsRepossessed_ ) = _repossess(destination_);
        emit Repossessed(collateralRepossessed_, fundsRepossessed_, destination_);
    }
    function setPendingLender(address pendingLender_) external override {
        require(msg.sender == _lender, "ML:SPL:NOT_LENDER");
        emit PendingLenderSet(_pendingLender = pendingLender_);
    }
    function skim(address token_, address destination_) external override whenProtocolNotPaused returns (uint256 skimmed_) {
        require((msg.sender == _borrower) || (msg.sender == _lender),    "L:S:NO_AUTH");
        require((token_ != _fundsAsset) && (token_ != _collateralAsset), "L:S:INVALID_TOKEN");
        emit Skimmed(token_, skimmed_ = IERC20(token_).balanceOf(address(this)), destination_);
        require(ERC20Helper.transfer(token_, destination_, skimmed_), "L:S:TRANSFER_FAILED");
    }
    function getAdditionalCollateralRequiredFor(uint256 drawdown_) public view override returns (uint256 collateral_) {
        uint256 collateralNeeded = _getCollateralRequiredFor(_principal, _drawableFunds - drawdown_, _principalRequested, _collateralRequired);
        return collateralNeeded > _collateral ? collateralNeeded - _collateral : uint256(0);
    }
    function getEarlyPaymentBreakdown() external view override returns (uint256 principal_, uint256 interest_) {
        ( principal_, interest_ ) = _getEarlyPaymentBreakdown();
    }
    function getNextPaymentBreakdown() external view override returns (uint256 principal_, uint256 interest_) {
        ( principal_, interest_ ) = _getNextPaymentBreakdown();
    }
    function isProtocolPaused() public view override returns (bool paused_) {
        return IMapleGlobalsLike(IMapleProxyFactory(_factory()).mapleGlobals()).protocolPaused();
    }
    function borrower() external view override returns (address borrower_) {
        return _borrower;
    }
    function claimableFunds() external view override returns (uint256 claimableFunds_) {
        return _claimableFunds;
    }
    function collateral() external view override returns (uint256 collateral_) {
        return _collateral;
    }
    function collateralAsset() external view override returns (address collateralAsset_) {
        return _collateralAsset;
    }
    function collateralRequired() external view override returns (uint256 collateralRequired_) {
        return _collateralRequired;
    }
    function drawableFunds() external view override returns (uint256 drawableFunds_) {
        return _drawableFunds;
    }
    function earlyFeeRate() external view override returns (uint256 earlyFeeRate_) {
        return _earlyFeeRate;
    }
    function endingPrincipal() external view override returns (uint256 endingPrincipal_) {
        return _endingPrincipal;
    }
    function excessCollateral() external view override returns (uint256 excessCollateral_) {
        uint256 collateralNeeded = _getCollateralRequiredFor(_principal, _drawableFunds, _principalRequested, _collateralRequired);
        return _collateral > collateralNeeded ? _collateral - collateralNeeded : uint256(0);
    }
    function factory() external view override returns (address factory_) {
        return _factory();
    }
    function fundsAsset() external view override returns (address fundsAsset_) {
        return _fundsAsset;
    }
    function gracePeriod() external view override returns (uint256 gracePeriod_) {
        return _gracePeriod;
    }
    function implementation() external view override returns (address implementation_) {
        return _implementation();
    }
    function interestRate() external view override returns (uint256 interestRate_) {
        return _interestRate;
    }
    function lateFeeRate() external view override returns (uint256 lateFeeRate_) {
        return _lateFeeRate;
    }
    function lateInterestPremium() external view override returns (uint256 lateInterestPremium_) {
        return _lateInterestPremium;
    }
    function lender() external view override returns (address lender_) {
        return _lender;
    }
    function nextPaymentDueDate() external view override returns (uint256 nextPaymentDueDate_) {
        return _nextPaymentDueDate;
    }
    function paymentInterval() external view override returns (uint256 paymentInterval_) {
        return _paymentInterval;
    }
    function paymentsRemaining() external view override returns (uint256 paymentsRemaining_) {
        return _paymentsRemaining;
    }
    function pendingBorrower() external view override returns (address pendingBorrower_) {
        return _pendingBorrower;
    }
    function pendingLender() external view override returns (address pendingLender_) {
        return _pendingLender;
    }
    function principalRequested() external view override returns (uint256 principalRequested_) {
        return _principalRequested;
    }
    function principal() external view override returns (uint256 principal_) {
        return _principal;
    }
    function superFactory() external view override returns (address superFactory_) {
        return _factory();
    }
}