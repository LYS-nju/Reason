pragma solidity 0.8.16;
enum ValidatorStatus {
    INITIALIZED,
    INVALID_SIGNATURE,
    FRONT_RUN,
    PRE_DEPOSIT,
    DEPOSITED,
    WITHDRAWN
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