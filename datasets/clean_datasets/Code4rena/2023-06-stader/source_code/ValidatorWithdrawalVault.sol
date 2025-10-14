pragma solidity ^0.8.16;
interface IOperatorRewardsCollector {
    event UpdatedStaderConfig(address indexed staderConfig);
    event Claimed(address indexed receiver, uint256 amount);
    event DepositedFor(address indexed sender, address indexed receiver, uint256 amount);
    function depositFor(address _receiver) external payable;
    function claim() external;
}
interface IPenalty {
    error ValidatorSettled();
    event UpdatedAdditionalPenaltyAmount(bytes pubkey, uint256 amount);
    event UpdatedMEVTheftPenaltyPerStrike(uint256 mevTheftPenalty);
    event UpdatedPenaltyOracleAddress(address penaltyOracleAddress);
    event UpdatedMissedAttestationPenaltyPerStrike(uint256 missedAttestationPenalty);
    event UpdatedValidatorExitPenaltyThreshold(uint256 totalPenaltyThreshold);
    event ForceExitValidator(bytes pubkey);
    event UpdatedStaderConfig(address staderConfig);
    event ValidatorMarkedAsSettled(bytes pubkey);
    function ratedOracleAddress() external view returns (address);
    function mevTheftPenaltyPerStrike() external view returns (uint256);
    function missedAttestationPenaltyPerStrike() external view returns (uint256);
    function validatorExitPenaltyThreshold() external view returns (uint256);
    function additionalPenaltyAmount(bytes32 _pubkeyRoot) external view returns (uint256);
    function totalPenaltyAmount(bytes calldata _pubkey) external view returns (uint256);
    function updateRatedOracleAddress(address _penaltyOracleAddress) external;
    function updateStaderConfig(address _staderConfig) external;
    function updateMEVTheftPenaltyPerStrike(uint256 _mevTheftPenaltyPerStrike) external;
    function updateMissedAttestationPenaltyPerStrike(uint256 _missedAttestationPenaltyPerStrike) external;
    function updateValidatorExitPenaltyThreshold(uint256 _validatorExitPenaltyThreshold) external;
    function setAdditionalPenaltyAmount(bytes calldata _pubkey, uint256 _amount) external;
    function getAdditionalPenaltyAmount(bytes calldata _pubkey) external view returns (uint256);
    function updateTotalPenaltyAmount(bytes[] calldata _pubkey) external;
    function calculateMEVTheftPenalty(bytes32 _pubkeyRoot) external returns (uint256);
    function calculateMissedAttestationPenalty(bytes32 _pubkeyRoot) external returns (uint256);
    function markValidatorSettled(uint8 _poolId, uint256 _validatorId) external;
}
interface IStaderConfig {
    error InvalidLimits();
    error InvalidMinDepositValue();
    error InvalidMaxDepositValue();
    error InvalidMinWithdrawValue();
    error InvalidMaxWithdrawValue();
    event SetConstant(bytes32 key, uint256 amount);
    event SetVariable(bytes32 key, uint256 amount);
    event SetAccount(bytes32 key, address newAddress);
    event SetContract(bytes32 key, address newAddress);
    event SetToken(bytes32 key, address newAddress);
    function POOL_UTILS() external view returns (bytes32);
    function POOL_SELECTOR() external view returns (bytes32);
    function SD_COLLATERAL() external view returns (bytes32);
    function OPERATOR_REWARD_COLLECTOR() external view returns (bytes32);
    function VAULT_FACTORY() external view returns (bytes32);
    function STADER_ORACLE() external view returns (bytes32);
    function AUCTION_CONTRACT() external view returns (bytes32);
    function PENALTY_CONTRACT() external view returns (bytes32);
    function PERMISSIONED_POOL() external view returns (bytes32);
    function STAKE_POOL_MANAGER() external view returns (bytes32);
    function ETH_DEPOSIT_CONTRACT() external view returns (bytes32);
    function PERMISSIONLESS_POOL() external view returns (bytes32);
    function USER_WITHDRAW_MANAGER() external view returns (bytes32);
    function STADER_INSURANCE_FUND() external view returns (bytes32);
    function PERMISSIONED_NODE_REGISTRY() external view returns (bytes32);
    function PERMISSIONLESS_NODE_REGISTRY() external view returns (bytes32);
    function PERMISSIONED_SOCIALIZING_POOL() external view returns (bytes32);
    function PERMISSIONLESS_SOCIALIZING_POOL() external view returns (bytes32);
    function NODE_EL_REWARD_VAULT_IMPLEMENTATION() external view returns (bytes32);
    function VALIDATOR_WITHDRAWAL_VAULT_IMPLEMENTATION() external view returns (bytes32);
    function ETH_BALANCE_POR_FEED() external view returns (bytes32);
    function ETHX_SUPPLY_POR_FEED() external view returns (bytes32);
    function MANAGER() external view returns (bytes32);
    function OPERATOR() external view returns (bytes32);
    function getStakedEthPerNode() external view returns (uint256);
    function getPreDepositSize() external view returns (uint256);
    function getFullDepositSize() external view returns (uint256);
    function getDecimals() external view returns (uint256);
    function getTotalFee() external view returns (uint256);
    function getOperatorMaxNameLength() external view returns (uint256);
    function getSocializingPoolCycleDuration() external view returns (uint256);
    function getSocializingPoolOptInCoolingPeriod() external view returns (uint256);
    function getRewardsThreshold() external view returns (uint256);
    function getMinDepositAmount() external view returns (uint256);
    function getMaxDepositAmount() external view returns (uint256);
    function getMinWithdrawAmount() external view returns (uint256);
    function getMaxWithdrawAmount() external view returns (uint256);
    function getMinBlockDelayToFinalizeWithdrawRequest() external view returns (uint256);
    function getWithdrawnKeyBatchSize() external view returns (uint256);
    function getAdmin() external view returns (address);
    function getStaderTreasury() external view returns (address);
    function getPoolUtils() external view returns (address);
    function getPoolSelector() external view returns (address);
    function getSDCollateral() external view returns (address);
    function getOperatorRewardsCollector() external view returns (address);
    function getVaultFactory() external view returns (address);
    function getStaderOracle() external view returns (address);
    function getAuctionContract() external view returns (address);
    function getPenaltyContract() external view returns (address);
    function getPermissionedPool() external view returns (address);
    function getStakePoolManager() external view returns (address);
    function getETHDepositContract() external view returns (address);
    function getPermissionlessPool() external view returns (address);
    function getUserWithdrawManager() external view returns (address);
    function getStaderInsuranceFund() external view returns (address);
    function getPermissionedNodeRegistry() external view returns (address);
    function getPermissionlessNodeRegistry() external view returns (address);
    function getPermissionedSocializingPool() external view returns (address);
    function getPermissionlessSocializingPool() external view returns (address);
    function getNodeELRewardVaultImplementation() external view returns (address);
    function getValidatorWithdrawalVaultImplementation() external view returns (address);
    function getETHBalancePORFeedProxy() external view returns (address);
    function getETHXSupplyPORFeedProxy() external view returns (address);
    function getStaderToken() external view returns (address);
    function getETHxToken() external view returns (address);
    function onlyStaderContract(address _addr, bytes32 _contractName) external view returns (bool);
    function onlyManagerRole(address account) external view returns (bool);
    function onlyOperatorRole(address account) external view returns (bool);
}
interface IStaderStakePoolManager {
    error InvalidDepositAmount();
    error UnsupportedOperation();
    error InsufficientBalance();
    error TransferFailed();
    error PoolIdDoesNotExit();
    error CooldownNotComplete();
    error UnsupportedOperationInSafeMode();
    event UpdatedStaderConfig(address staderConfig);
    event Deposited(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event ExecutionLayerRewardsReceived(uint256 amount);
    event AuctionedEthReceived(uint256 amount);
    event ReceivedExcessEthFromPool(uint8 indexed poolId);
    event TransferredETHToUserWithdrawManager(uint256 amount);
    event ETHTransferredToPool(uint256 indexed poolId, address poolAddress, uint256 validatorCount);
    event WithdrawVaultUserShareReceived(uint256 amount);
    event UpdatedExcessETHDepositCoolDown(uint256 excessETHDepositCoolDown);
    function deposit(address _receiver) external payable returns (uint256);
    function previewDeposit(uint256 _assets) external view returns (uint256);
    function previewWithdraw(uint256 _shares) external view returns (uint256);
    function getExchangeRate() external view returns (uint256);
    function totalAssets() external view returns (uint256);
    function convertToShares(uint256 _assets) external view returns (uint256);
    function convertToAssets(uint256 _shares) external view returns (uint256);
    function maxDeposit() external view returns (uint256);
    function minDeposit() external view returns (uint256);
    function receiveExecutionLayerRewards() external payable;
    function receiveWithdrawVaultUserShare() external payable;
    function receiveEthFromAuction() external payable;
    function receiveExcessEthFromPool(uint8 _poolId) external payable;
    function transferETHToUserWithdrawManager(uint256 _amount) external;
    function validatorBatchDeposit(uint8 _poolId) external;
    function depositETHOverTargetWeight() external;
    function isVaultHealthy() external view returns (bool);
}
enum ValidatorStatus {
    INITIALIZED,
    INVALID_SIGNATURE,
    FRONT_RUN,
    PRE_DEPOSIT,
    DEPOSITED,
    WITHDRAWN
}
library Math {
    enum Rounding {
        Down, 
        Up, 
        Zero 
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0; 
            uint256 prod1; 
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            require(denominator > prod1);
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            result = prod0 * inverse;
            return result;
        }
    }
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = 1;
        uint256 x = a;
        if (x >> 128 > 0) {
            x >>= 128;
            result <<= 64;
        }
        if (x >> 64 > 0) {
            x >>= 64;
            result <<= 32;
        }
        if (x >> 32 > 0) {
            x >>= 32;
            result <<= 16;
        }
        if (x >> 16 > 0) {
            x >>= 16;
            result <<= 8;
        }
        if (x >> 8 > 0) {
            x >>= 8;
            result <<= 4;
        }
        if (x >> 4 > 0) {
            x >>= 4;
            result <<= 2;
        }
        if (x >> 2 > 0) {
            result <<= 1;
        }
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        uint256 result = sqrt(a);
        if (rounding == Rounding.Up && result * result < a) {
            result += 1;
        }
        return result;
    }
}
struct Validator {
    ValidatorStatus status; 
    bytes pubkey; 
    bytes preDepositSignature; 
    bytes depositSignature; 
    address withdrawVaultAddress; 
    uint256 operatorId; 
    uint256 depositBlock; 
    uint256 withdrawnBlock; 
}
struct Operator {
    bool active; 
    bool optedForSocializingPool; 
    string operatorName; 
    address payable operatorRewardAddress; 
    address operatorAddress; 
}
interface INodeRegistry {
    error DuplicatePoolIDOrPoolNotAdded();
    error OperatorAlreadyOnBoardedInProtocol();
    error maxKeyLimitReached();
    error OperatorNotOnBoarded();
    error InvalidKeyCount();
    error InvalidStartAndEndIndex();
    error OperatorIsDeactivate();
    error MisMatchingInputKeysSize();
    error PageNumberIsZero();
    error UNEXPECTED_STATUS();
    error PubkeyAlreadyExist();
    error NotEnoughSDCollateral();
    error TooManyVerifiedKeysReported();
    error TooManyWithdrawnKeysReported();
    event AddedValidatorKey(address indexed nodeOperator, bytes pubkey, uint256 validatorId);
    event ValidatorMarkedAsFrontRunned(bytes pubkey, uint256 validatorId);
    event ValidatorWithdrawn(bytes pubkey, uint256 validatorId);
    event ValidatorStatusMarkedAsInvalidSignature(bytes pubkey, uint256 validatorId);
    event UpdatedValidatorDepositBlock(uint256 validatorId, uint256 depositBlock);
    event UpdatedMaxNonTerminalKeyPerOperator(uint64 maxNonTerminalKeyPerOperator);
    event UpdatedInputKeyCountLimit(uint256 batchKeyDepositLimit);
    event UpdatedStaderConfig(address staderConfig);
    event UpdatedOperatorDetails(address indexed nodeOperator, string operatorName, address rewardAddress);
    event IncreasedTotalActiveValidatorCount(uint256 totalActiveValidatorCount);
    event UpdatedVerifiedKeyBatchSize(uint256 verifiedKeysBatchSize);
    event UpdatedWithdrawnKeyBatchSize(uint256 withdrawnKeysBatchSize);
    event DecreasedTotalActiveValidatorCount(uint256 totalActiveValidatorCount);
    function withdrawnValidators(bytes[] calldata _pubkeys) external;
    function markValidatorReadyToDeposit(
        bytes[] calldata _readyToDepositPubkey,
        bytes[] calldata _frontRunPubkey,
        bytes[] calldata _invalidSignaturePubkey
    ) external;
    function validatorRegistry(uint256)
        external
        view
        returns (
            ValidatorStatus status,
            bytes calldata pubkey,
            bytes calldata preDepositSignature,
            bytes calldata depositSignature,
            address withdrawVaultAddress,
            uint256 operatorId,
            uint256 depositTime,
            uint256 withdrawnTime
        );
    function operatorStructById(uint256)
        external
        view
        returns (
            bool active,
            bool optedForSocializingPool,
            string calldata operatorName,
            address payable operatorRewardAddress,
            address operatorAddress
        );
    function getSocializingPoolStateChangeBlock(uint256 _operatorId) external view returns (uint256);
    function getAllActiveValidators(uint256 _pageNumber, uint256 _pageSize) external view returns (Validator[] memory);
    function getValidatorsByOperator(
        address _operator,
        uint256 _pageNumber,
        uint256 _pageSize
    ) external view returns (Validator[] memory);
    function getOperatorTotalNonTerminalKeys(
        address _nodeOperator,
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (uint64);
    function getTotalQueuedValidatorCount() external view returns (uint256);
    function getTotalActiveValidatorCount() external view returns (uint256);
    function getCollateralETH() external view returns (uint256);
    function getOperatorTotalKeys(uint256 _operatorId) external view returns (uint256 totalKeys);
    function operatorIDByAddress(address) external view returns (uint256);
    function getOperatorRewardAddress(uint256 _operatorId) external view returns (address payable);
    function isExistingPubkey(bytes calldata _pubkey) external view returns (bool);
    function isExistingOperator(address _operAddr) external view returns (bool);
    function POOL_ID() external view returns (uint8);
    function inputKeyCountLimit() external view returns (uint16);
    function nextOperatorId() external view returns (uint256);
    function nextValidatorId() external view returns (uint256);
    function maxNonTerminalKeyPerOperator() external view returns (uint64);
    function verifiedKeyBatchSize() external view returns (uint256);
    function totalActiveValidatorCount() external view returns (uint256);
    function validatorIdByPubkey(bytes calldata _pubkey) external view returns (uint256);
    function validatorIdsByOperatorId(uint256, uint256) external view returns (uint256);
}
interface IValidatorWithdrawalVault {
    error InvalidRewardAmount();
    error NotEnoughRewardToDistribute();
    error CallerNotNodeRegistryContract();
    event ETHReceived(address indexed sender, uint256 amount);
    event DistributeRewardFailed(uint256 rewardAmount, uint256 rewardThreshold);
    event DistributedRewards(uint256 userShare, uint256 operatorShare, uint256 protocolShare);
    event SettledFunds(uint256 userShare, uint256 operatorShare, uint256 protocolShare);
    event UpdatedStaderConfig(address _staderConfig);
    function distributeRewards() external;
    function settleFunds() external;
    function calculateValidatorWithdrawalShare()
        external
        view
        returns (
            uint256 _userShare,
            uint256 _operatorShare,
            uint256 _protocolShare
        );
}
interface IVaultProxy {
    error CallerNotOwner();
    error AlreadyInitialized();
    event UpdatedOwner(address owner);
    event UpdatedStaderConfig(address staderConfig);
    function vaultSettleStatus() external view returns (bool);
    function isValidatorWithdrawalVault() external view returns (bool);
    function isInitialized() external view returns (bool);
    function poolId() external view returns (uint8);
    function id() external view returns (uint256);
    function owner() external view returns (address);
    function staderConfig() external view returns (IStaderConfig);
    function updateOwner(address _owner) external;
    function updateStaderConfig(address _staderConfig) external;
}
interface ISDCollateral {
    struct PoolThresholdInfo {
        uint256 minThreshold;
        uint256 maxThreshold;
        uint256 withdrawThreshold;
        string units;
    }
    struct WithdrawRequestInfo {
        uint256 lastWithdrawReqTimestamp;
        uint256 totalSDWithdrawReqAmount;
    }
    error InsufficientSDToWithdraw(uint256 operatorSDCollateral);
    error InvalidPoolId();
    error InvalidPoolLimit();
    error SDTransferFailed();
    error NoStateChange();
    event UpdatedStaderConfig(address indexed staderConfig);
    event SDDeposited(address indexed operator, uint256 sdAmount);
    event SDWithdrawn(address indexed operator, uint256 sdAmount);
    event SDSlashed(address indexed operator, address indexed auction, uint256 sdSlashed);
    event UpdatedPoolThreshold(uint8 poolId, uint256 minThreshold, uint256 withdrawThreshold);
    event UpdatedPoolIdForOperator(uint8 poolId, address operator);
    function depositSDAsCollateral(uint256 _sdAmount) external;
    function withdraw(uint256 _requestedSD) external;
    function slashValidatorSD(uint256 _validatorId, uint8 _poolId) external;
    function maxApproveSD() external;
    function updateStaderConfig(address _staderConfig) external;
    function updatePoolThreshold(
        uint8 _poolId,
        uint256 _minThreshold,
        uint256 _maxThreshold,
        uint256 _withdrawThreshold,
        string memory _units
    ) external;
    function staderConfig() external view returns (IStaderConfig);
    function operatorSDBalance(address) external view returns (uint256);
    function getOperatorWithdrawThreshold(address _operator) external view returns (uint256 operatorWithdrawThreshold);
    function hasEnoughSDCollateral(
        address _operator,
        uint8 _poolId,
        uint256 _numValidators
    ) external view returns (bool);
    function getMinimumSDToBond(uint8 _poolId, uint256 _numValidator) external view returns (uint256 _minSDToBond);
    function getRemainingSDToBond(
        address _operator,
        uint8 _poolId,
        uint256 _numValidator
    ) external view returns (uint256);
    function getRewardEligibleSD(address _operator) external view returns (uint256 _rewardEligibleSD);
    function convertSDToETH(uint256 _sdAmount) external view returns (uint256);
    function convertETHToSD(uint256 _ethAmount) external view returns (uint256);
}
interface IPoolUtils {
    error EmptyNameString();
    error PoolIdNotPresent();
    error PubkeyDoesNotExit();
    error PubkeyAlreadyExist();
    error NameCrossedMaxLength();
    error InvalidLengthOfPubkey();
    error OperatorIsNotOnboarded();
    error InvalidLengthOfSignature();
    error ExistingOrMismatchingPoolId();
    event PoolAdded(uint8 indexed poolId, address poolAddress);
    event PoolAddressUpdated(uint8 indexed poolId, address poolAddress);
    event DeactivatedPool(uint8 indexed poolId, address poolAddress);
    event UpdatedStaderConfig(address staderConfig);
    event ExitValidator(bytes pubkey);
    function poolAddressById(uint8) external view returns (address poolAddress);
    function poolIdArray(uint256) external view returns (uint8);
    function getPoolIdArray() external view returns (uint8[] memory);
    function addNewPool(uint8 _poolId, address _poolAddress) external;
    function updatePoolAddress(uint8 _poolId, address _poolAddress) external;
    function processValidatorExitList(bytes[] calldata _pubkeys) external;
    function getOperatorTotalNonTerminalKeys(
        uint8 _poolId,
        address _nodeOperator,
        uint256 _startIndex,
        uint256 _endIndex
    ) external view returns (uint256);
    function getSocializingPoolAddress(uint8 _poolId) external view returns (address);
    function getProtocolFee(uint8 _poolId) external view returns (uint256); 
    function getOperatorFee(uint8 _poolId) external view returns (uint256); 
    function getTotalActiveValidatorCount() external view returns (uint256); 
    function getActiveValidatorCountByPool(uint8 _poolId) external view returns (uint256); 
    function getQueuedValidatorCountByPool(uint8 _poolId) external view returns (uint256); 
    function getCollateralETH(uint8 _poolId) external view returns (uint256);
    function getNodeRegistry(uint8 _poolId) external view returns (address);
    function isExistingPubkey(bytes calldata _pubkey) external view returns (bool);
    function isExistingOperator(address _operAddr) external view returns (bool);
    function isExistingPoolId(uint8 _poolId) external view returns (bool);
    function getOperatorPoolId(address _operAddr) external view returns (uint8);
    function getValidatorPoolId(bytes calldata _pubkey) external view returns (uint8);
    function onlyValidName(string calldata _name) external;
    function onlyValidKeys(
        bytes calldata _pubkey,
        bytes calldata _preDepositSignature,
        bytes calldata _depositSignature
    ) external;
    function calculateRewardShare(uint8 _poolId, uint256 _totalRewards)
        external
        view
        returns (
            uint256 userShare,
            uint256 operatorShare,
            uint256 protocolShare
        );
}
library UtilLib {
    error ZeroAddress();
    error InvalidPubkeyLength();
    error CallerNotManager();
    error CallerNotOperator();
    error CallerNotStaderContract();
    error CallerNotWithdrawVault();
    error TransferFailed();
    uint64 private constant VALIDATOR_PUBKEY_LENGTH = 48;
    function checkNonZeroAddress(address _address) internal pure {
        if (_address == address(0)) revert ZeroAddress();
    }
    function onlyManagerRole(address _addr, IStaderConfig _staderConfig) internal view {
        if (!_staderConfig.onlyManagerRole(_addr)) {
            revert CallerNotManager();
        }
    }
    function onlyOperatorRole(address _addr, IStaderConfig _staderConfig) internal view {
        if (!_staderConfig.onlyOperatorRole(_addr)) {
            revert CallerNotOperator();
        }
    }
    function onlyStaderContract(
        address _addr,
        IStaderConfig _staderConfig,
        bytes32 _contractName
    ) internal view {
        if (!_staderConfig.onlyStaderContract(_addr, _contractName)) {
            revert CallerNotStaderContract();
        }
    }
    function getPubkeyForValidSender(
        uint8 _poolId,
        uint256 _validatorId,
        address _addr,
        IStaderConfig _staderConfig
    ) internal view returns (bytes memory) {
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(_poolId);
        (, bytes memory pubkey, , , address withdrawVaultAddress, , , ) = INodeRegistry(nodeRegistry).validatorRegistry(
            _validatorId
        );
        if (_addr != withdrawVaultAddress) {
            revert CallerNotWithdrawVault();
        }
        return pubkey;
    }
    function getOperatorForValidSender(
        uint8 _poolId,
        uint256 _validatorId,
        address _addr,
        IStaderConfig _staderConfig
    ) internal view returns (address) {
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(_poolId);
        (, , , , address withdrawVaultAddress, uint256 operatorId, , ) = INodeRegistry(nodeRegistry).validatorRegistry(
            _validatorId
        );
        if (_addr != withdrawVaultAddress) {
            revert CallerNotWithdrawVault();
        }
        (, , , , address operator) = INodeRegistry(nodeRegistry).operatorStructById(operatorId);
        return operator;
    }
    function onlyValidatorWithdrawVault(
        uint8 _poolId,
        uint256 _validatorId,
        address _addr,
        IStaderConfig _staderConfig
    ) internal view {
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(_poolId);
        (, , , , address withdrawVaultAddress, , , ) = INodeRegistry(nodeRegistry).validatorRegistry(_validatorId);
        if (_addr != withdrawVaultAddress) {
            revert CallerNotWithdrawVault();
        }
    }
    function getOperatorAddressByValidatorId(
        uint8 _poolId,
        uint256 _validatorId,
        IStaderConfig _staderConfig
    ) internal view returns (address) {
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(_poolId);
        (, , , , , uint256 operatorId, , ) = INodeRegistry(nodeRegistry).validatorRegistry(_validatorId);
        (, , , , address operatorAddress) = INodeRegistry(nodeRegistry).operatorStructById(operatorId);
        return operatorAddress;
    }
    function getOperatorAddressByOperatorId(
        uint8 _poolId,
        uint256 _operatorId,
        IStaderConfig _staderConfig
    ) internal view returns (address) {
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(_poolId);
        (, , , , address operatorAddress) = INodeRegistry(nodeRegistry).operatorStructById(_operatorId);
        return operatorAddress;
    }
    function getOperatorRewardAddress(address _operator, IStaderConfig _staderConfig)
        internal
        view
        returns (address payable)
    {
        uint8 poolId = IPoolUtils(_staderConfig.getPoolUtils()).getOperatorPoolId(_operator);
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(poolId);
        uint256 operatorId = INodeRegistry(nodeRegistry).operatorIDByAddress(_operator);
        return INodeRegistry(nodeRegistry).getOperatorRewardAddress(operatorId);
    }
    function getPubkeyRoot(bytes calldata _pubkey) internal pure returns (bytes32) {
        if (_pubkey.length != VALIDATOR_PUBKEY_LENGTH) {
            revert InvalidPubkeyLength();
        }
        return sha256(abi.encodePacked(_pubkey, bytes16(0)));
    }
    function getValidatorSettleStatus(bytes calldata _pubkey, IStaderConfig _staderConfig)
        internal
        view
        returns (bool)
    {
        uint8 poolId = IPoolUtils(_staderConfig.getPoolUtils()).getValidatorPoolId(_pubkey);
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(poolId);
        uint256 validatorId = INodeRegistry(nodeRegistry).validatorIdByPubkey(_pubkey);
        (, , , , address withdrawVaultAddress, , , ) = INodeRegistry(nodeRegistry).validatorRegistry(validatorId);
        return IVaultProxy(withdrawVaultAddress).vaultSettleStatus();
    }
    function computeExchangeRate(
        uint256 totalETHBalance,
        uint256 totalETHXSupply,
        IStaderConfig _staderConfig
    ) internal view returns (uint256) {
        uint256 DECIMALS = _staderConfig.getDecimals();
        uint256 newExchangeRate = (totalETHBalance == 0 || totalETHXSupply == 0)
            ? DECIMALS
            : (totalETHBalance * DECIMALS) / totalETHXSupply;
        return newExchangeRate;
    }
    function sendValue(address _receiver, uint256 _amount) internal {
        (bool success, ) = payable(_receiver).call{value: _amount}('');
        if (!success) {
            revert TransferFailed();
        }
    }
}
contract VaultProxy is IVaultProxy {
    bool public override vaultSettleStatus;
    bool public override isValidatorWithdrawalVault;
    bool public override isInitialized;
    uint8 public override poolId;
    uint256 public override id; 
    address public override owner;
    IStaderConfig public override staderConfig;
    constructor() {}
    function initialise(
        bool _isValidatorWithdrawalVault,
        uint8 _poolId,
        uint256 _id,
        address _staderConfig
    ) external {
        if (isInitialized) {
            revert AlreadyInitialized();
        }
        UtilLib.checkNonZeroAddress(_staderConfig);
        isValidatorWithdrawalVault = _isValidatorWithdrawalVault;
        isInitialized = true;
        poolId = _poolId;
        id = _id;
        staderConfig = IStaderConfig(_staderConfig);
        owner = staderConfig.getAdmin();
    }
    fallback(bytes calldata _input) external payable returns (bytes memory) {
        address vaultImplementation = isValidatorWithdrawalVault
            ? staderConfig.getValidatorWithdrawalVaultImplementation()
            : staderConfig.getNodeELRewardVaultImplementation();
        (bool success, bytes memory data) = vaultImplementation.delegatecall(_input);
        if (!success) {
            revert(string(data));
        }
        return data;
    }
    function updateStaderConfig(address _staderConfig) external override onlyOwner {
        UtilLib.checkNonZeroAddress(_staderConfig);
        staderConfig = IStaderConfig(_staderConfig);
        emit UpdatedStaderConfig(_staderConfig);
    }
    function updateOwner(address _owner) external override onlyOwner {
        UtilLib.checkNonZeroAddress(_owner);
        owner = _owner;
        emit UpdatedOwner(owner);
    }
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert CallerNotOwner();
        }
        _;
    }
}
contract ValidatorWithdrawalVault is IValidatorWithdrawalVault {
    bool internal vaultSettleStatus;
    using Math for uint256;
    constructor() {}
    receive() external payable {
        emit ETHReceived(msg.sender, msg.value);
    }
    function distributeRewards() external override {
        uint8 poolId = VaultProxy(payable(address(this))).poolId();
        uint256 validatorId = VaultProxy(payable(address(this))).id();
        IStaderConfig staderConfig = VaultProxy(payable(address(this))).staderConfig();
        uint256 totalRewards = address(this).balance;
        if (!staderConfig.onlyOperatorRole(msg.sender) && totalRewards > staderConfig.getRewardsThreshold()) {
            emit DistributeRewardFailed(totalRewards, staderConfig.getRewardsThreshold());
            revert InvalidRewardAmount();
        }
        if (totalRewards == 0) {
            revert NotEnoughRewardToDistribute();
        }
        (uint256 userShare, uint256 operatorShare, uint256 protocolShare) = IPoolUtils(staderConfig.getPoolUtils())
            .calculateRewardShare(poolId, totalRewards);
        IStaderStakePoolManager(staderConfig.getStakePoolManager()).receiveWithdrawVaultUserShare{value: userShare}();
        UtilLib.sendValue(payable(staderConfig.getStaderTreasury()), protocolShare);
        IOperatorRewardsCollector(staderConfig.getOperatorRewardsCollector()).depositFor{value: operatorShare}(
            getOperatorAddress(poolId, validatorId, staderConfig)
        );
        emit DistributedRewards(userShare, operatorShare, protocolShare);
    }
    function settleFunds() external override {
        uint8 poolId = VaultProxy(payable(address(this))).poolId();
        uint256 validatorId = VaultProxy(payable(address(this))).id();
        IStaderConfig staderConfig = VaultProxy(payable(address(this))).staderConfig();
        address nodeRegistry = IPoolUtils(staderConfig.getPoolUtils()).getNodeRegistry(poolId);
        if (msg.sender != nodeRegistry) {
            revert CallerNotNodeRegistryContract();
        }
        (uint256 userSharePrelim, uint256 operatorShare, uint256 protocolShare) = calculateValidatorWithdrawalShare();
        uint256 penaltyAmount = getUpdatedPenaltyAmount(poolId, validatorId, staderConfig);
        if (operatorShare < penaltyAmount) {
            ISDCollateral(staderConfig.getSDCollateral()).slashValidatorSD(validatorId, poolId);
            penaltyAmount = operatorShare;
        }
        uint256 userShare = userSharePrelim + penaltyAmount;
        operatorShare = operatorShare - penaltyAmount;
        vaultSettleStatus = true;
        IPenalty(staderConfig.getPenaltyContract()).markValidatorSettled(poolId, validatorId);
        IStaderStakePoolManager(staderConfig.getStakePoolManager()).receiveWithdrawVaultUserShare{value: userShare}();
        UtilLib.sendValue(payable(staderConfig.getStaderTreasury()), protocolShare);
        IOperatorRewardsCollector(staderConfig.getOperatorRewardsCollector()).depositFor{value: operatorShare}(
            getOperatorAddress(poolId, validatorId, staderConfig)
        );
        emit SettledFunds(userShare, operatorShare, protocolShare);
    }
    function calculateValidatorWithdrawalShare()
        public
        view
        returns (
            uint256 _userShare,
            uint256 _operatorShare,
            uint256 _protocolShare
        )
    {
        uint8 poolId = VaultProxy(payable(address(this))).poolId();
        IStaderConfig staderConfig = VaultProxy(payable(address(this))).staderConfig();
        uint256 TOTAL_STAKED_ETH = staderConfig.getStakedEthPerNode();
        uint256 collateralETH = getCollateralETH(poolId, staderConfig); 
        uint256 usersETH = TOTAL_STAKED_ETH - collateralETH;
        uint256 contractBalance = address(this).balance;
        uint256 totalRewards;
        if (contractBalance <= usersETH) {
            _userShare = contractBalance;
            return (_userShare, _operatorShare, _protocolShare);
        } else if (contractBalance <= TOTAL_STAKED_ETH) {
            _userShare = usersETH;
            _operatorShare = contractBalance - _userShare;
            return (_userShare, _operatorShare, _protocolShare);
        } else {
            totalRewards = contractBalance - TOTAL_STAKED_ETH;
            _operatorShare = collateralETH;
            _userShare = usersETH;
        }
        if (totalRewards > 0) {
            (uint256 userReward, uint256 operatorReward, uint256 protocolReward) = IPoolUtils(
                staderConfig.getPoolUtils()
            ).calculateRewardShare(poolId, totalRewards);
            _userShare += userReward;
            _operatorShare += operatorReward;
            _protocolShare += protocolReward;
        }
    }
    function getCollateralETH(uint8 _poolId, IStaderConfig _staderConfig) internal view returns (uint256) {
        return IPoolUtils(_staderConfig.getPoolUtils()).getCollateralETH(_poolId);
    }
    function getOperatorAddress(
        uint8 _poolId,
        uint256 _validatorId,
        IStaderConfig _staderConfig
    ) internal view returns (address) {
        return UtilLib.getOperatorAddressByValidatorId(_poolId, _validatorId, _staderConfig);
    }
    function getUpdatedPenaltyAmount(
        uint8 _poolId,
        uint256 _validatorId,
        IStaderConfig _staderConfig
    ) internal returns (uint256) {
        address nodeRegistry = IPoolUtils(_staderConfig.getPoolUtils()).getNodeRegistry(_poolId);
        (, bytes memory pubkey, , , , , , ) = INodeRegistry(nodeRegistry).validatorRegistry(_validatorId);
        bytes[] memory pubkeyArray = new bytes[](1);
        pubkeyArray[0] = pubkey;
        IPenalty(_staderConfig.getPenaltyContract()).updateTotalPenaltyAmount(pubkeyArray);
        return IPenalty(_staderConfig.getPenaltyContract()).totalPenaltyAmount(pubkey);
    }
}