pragma solidity ^0.8.16;
interface IAccessControlUpgradeable {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}
library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized < type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }
    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}
interface IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }
    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}
library MathUpgradeable {
    enum Rounding {
        Down, 
        Up, 
        Zero 
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
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
        uint256 result = 1 << (log2(a) >> 1);
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
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
        }
    }
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
    }
    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }
    mapping(bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(account),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}
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
contract StaderConfig is IStaderConfig, Initializable, AccessControlUpgradeable {
    bytes32 public constant ETH_PER_NODE = keccak256('ETH_PER_NODE');
    bytes32 public constant PRE_DEPOSIT_SIZE = keccak256('PRE_DEPOSIT_SIZE');
    bytes32 public constant FULL_DEPOSIT_SIZE = keccak256('FULL_DEPOSIT_SIZE');
    bytes32 public constant DECIMALS = keccak256('DECIMALS');
    bytes32 public constant TOTAL_FEE = keccak256('TOTAL_FEE');
    bytes32 public constant OPERATOR_MAX_NAME_LENGTH = keccak256('OPERATOR_MAX_NAME_LENGTH');
    bytes32 public constant SOCIALIZING_POOL_CYCLE_DURATION = keccak256('SOCIALIZING_POOL_CYCLE_DURATION');
    bytes32 public constant SOCIALIZING_POOL_OPT_IN_COOLING_PERIOD =
        keccak256('SOCIALIZING_POOL_OPT_IN_COOLING_PERIOD');
    bytes32 public constant REWARD_THRESHOLD = keccak256('REWARD_THRESHOLD');
    bytes32 public constant MIN_DEPOSIT_AMOUNT = keccak256('MIN_DEPOSIT_AMOUNT');
    bytes32 public constant MAX_DEPOSIT_AMOUNT = keccak256('MAX_DEPOSIT_AMOUNT');
    bytes32 public constant MIN_WITHDRAW_AMOUNT = keccak256('MIN_WITHDRAW_AMOUNT');
    bytes32 public constant MAX_WITHDRAW_AMOUNT = keccak256('MAX_WITHDRAW_AMOUNT');
    bytes32 public constant MIN_BLOCK_DELAY_TO_FINALIZE_WITHDRAW_REQUEST =
        keccak256('MIN_BLOCK_DELAY_TO_FINALIZE_WITHDRAW_REQUEST');
    bytes32 public constant WITHDRAWN_KEYS_BATCH_SIZE = keccak256('WITHDRAWN_KEYS_BATCH_SIZE');
    bytes32 public constant ADMIN = keccak256('ADMIN');
    bytes32 public constant STADER_TREASURY = keccak256('STADER_TREASURY');
    bytes32 public constant override POOL_UTILS = keccak256('POOL_UTILS');
    bytes32 public constant override POOL_SELECTOR = keccak256('POOL_SELECTOR');
    bytes32 public constant override SD_COLLATERAL = keccak256('SD_COLLATERAL');
    bytes32 public constant override OPERATOR_REWARD_COLLECTOR = keccak256('OPERATOR_REWARD_COLLECTOR');
    bytes32 public constant override VAULT_FACTORY = keccak256('VAULT_FACTORY');
    bytes32 public constant override STADER_ORACLE = keccak256('STADER_ORACLE');
    bytes32 public constant override AUCTION_CONTRACT = keccak256('AuctionContract');
    bytes32 public constant override PENALTY_CONTRACT = keccak256('PENALTY_CONTRACT');
    bytes32 public constant override PERMISSIONED_POOL = keccak256('PERMISSIONED_POOL');
    bytes32 public constant override STAKE_POOL_MANAGER = keccak256('STAKE_POOL_MANAGER');
    bytes32 public constant override ETH_DEPOSIT_CONTRACT = keccak256('ETH_DEPOSIT_CONTRACT');
    bytes32 public constant override PERMISSIONLESS_POOL = keccak256('PERMISSIONLESS_POOL');
    bytes32 public constant override USER_WITHDRAW_MANAGER = keccak256('USER_WITHDRAW_MANAGER');
    bytes32 public constant override STADER_INSURANCE_FUND = keccak256('STADER_INSURANCE_FUND');
    bytes32 public constant override PERMISSIONED_NODE_REGISTRY = keccak256('PERMISSIONED_NODE_REGISTRY');
    bytes32 public constant override PERMISSIONLESS_NODE_REGISTRY = keccak256('PERMISSIONLESS_NODE_REGISTRY');
    bytes32 public constant override PERMISSIONED_SOCIALIZING_POOL = keccak256('PERMISSIONED_SOCIALIZING_POOL');
    bytes32 public constant override PERMISSIONLESS_SOCIALIZING_POOL = keccak256('PERMISSIONLESS_SOCIALIZING_POOL');
    bytes32 public constant override NODE_EL_REWARD_VAULT_IMPLEMENTATION =
        keccak256('NODE_EL_REWARD_VAULT_IMPLEMENTATION');
    bytes32 public constant override VALIDATOR_WITHDRAWAL_VAULT_IMPLEMENTATION =
        keccak256('VALIDATOR_WITHDRAWAL_VAULT_IMPLEMENTATION');
    bytes32 public constant override ETH_BALANCE_POR_FEED = keccak256('ETH_BALANCE_POR_FEED');
    bytes32 public constant override ETHX_SUPPLY_POR_FEED = keccak256('ETHX_SUPPLY_POR_FEED');
    bytes32 public constant override MANAGER = keccak256('MANAGER');
    bytes32 public constant override OPERATOR = keccak256('OPERATOR');
    bytes32 public constant SD = keccak256('SD');
    bytes32 public constant ETHx = keccak256('ETHx');
    mapping(bytes32 => uint256) private constantsMap;
    mapping(bytes32 => uint256) private variablesMap;
    mapping(bytes32 => address) private accountsMap;
    mapping(bytes32 => address) private contractsMap;
    mapping(bytes32 => address) private tokensMap;
    constructor() {
        _disableInitializers();
    }
    function initialize(address _admin, address _ethDepositContract) external initializer {
        UtilLib.checkNonZeroAddress(_admin);
        UtilLib.checkNonZeroAddress(_ethDepositContract);
        __AccessControl_init();
        setConstant(ETH_PER_NODE, 32 ether);
        setConstant(PRE_DEPOSIT_SIZE, 1 ether);
        setConstant(FULL_DEPOSIT_SIZE, 31 ether);
        setConstant(TOTAL_FEE, 10000);
        setConstant(DECIMALS, 10**18);
        setConstant(OPERATOR_MAX_NAME_LENGTH, 255);
        setVariable(MIN_DEPOSIT_AMOUNT, 10**14);
        setVariable(MAX_DEPOSIT_AMOUNT, 10000 ether);
        setVariable(MIN_WITHDRAW_AMOUNT, 10**14);
        setVariable(MAX_WITHDRAW_AMOUNT, 10000 ether);
        setVariable(WITHDRAWN_KEYS_BATCH_SIZE, 50);
        setVariable(MIN_BLOCK_DELAY_TO_FINALIZE_WITHDRAW_REQUEST, 600);
        setContract(ETH_DEPOSIT_CONTRACT, _ethDepositContract);
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }
    function updateSocializingPoolCycleDuration(uint256 _socializingPoolCycleDuration) external onlyRole(MANAGER) {
        setVariable(SOCIALIZING_POOL_CYCLE_DURATION, _socializingPoolCycleDuration);
    }
    function updateSocializingPoolOptInCoolingPeriod(uint256 _SocializePoolOptInCoolingPeriod)
        external
        onlyRole(MANAGER)
    {
        setVariable(SOCIALIZING_POOL_OPT_IN_COOLING_PERIOD, _SocializePoolOptInCoolingPeriod);
    }
    function updateRewardsThreshold(uint256 _rewardsThreshold) external onlyRole(MANAGER) {
        setVariable(REWARD_THRESHOLD, _rewardsThreshold);
    }
    function updateMinDepositAmount(uint256 _minDepositAmount) external onlyRole(MANAGER) {
        setVariable(MIN_DEPOSIT_AMOUNT, _minDepositAmount);
        verifyDepositAndWithdrawLimits();
    }
    function updateMaxDepositAmount(uint256 _maxDepositAmount) external onlyRole(MANAGER) {
        setVariable(MAX_DEPOSIT_AMOUNT, _maxDepositAmount);
        verifyDepositAndWithdrawLimits();
    }
    function updateMinWithdrawAmount(uint256 _minWithdrawAmount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setVariable(MIN_WITHDRAW_AMOUNT, _minWithdrawAmount);
        verifyDepositAndWithdrawLimits();
    }
    function updateMaxWithdrawAmount(uint256 _maxWithdrawAmount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setVariable(MAX_WITHDRAW_AMOUNT, _maxWithdrawAmount);
        verifyDepositAndWithdrawLimits();
    }
    function updateMinBlockDelayToFinalizeWithdrawRequest(uint256 _minBlockDelay)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        setVariable(MIN_BLOCK_DELAY_TO_FINALIZE_WITHDRAW_REQUEST, _minBlockDelay);
    }
    function updateWithdrawnKeysBatchSize(uint256 _withdrawnKeysBatchSize) external onlyRole(OPERATOR) {
        setVariable(WITHDRAWN_KEYS_BATCH_SIZE, _withdrawnKeysBatchSize);
    }
    function updateAdmin(address _admin) external onlyRole(DEFAULT_ADMIN_ROLE) {
        address oldAdmin = accountsMap[ADMIN];
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        setAccount(ADMIN, _admin);
        _revokeRole(DEFAULT_ADMIN_ROLE, oldAdmin);
    }
    function updateStaderTreasury(address _staderTreasury) external onlyRole(MANAGER) {
        setAccount(STADER_TREASURY, _staderTreasury);
    }
    function updatePoolUtils(address _poolUtils) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(POOL_UTILS, _poolUtils);
    }
    function updatePoolSelector(address _poolSelector) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(POOL_SELECTOR, _poolSelector);
    }
    function updateSDCollateral(address _sdCollateral) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(SD_COLLATERAL, _sdCollateral);
    }
    function updateOperatorRewardsCollector(address _operatorRewardsCollector) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(OPERATOR_REWARD_COLLECTOR, _operatorRewardsCollector);
    }
    function updateVaultFactory(address _vaultFactory) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(VAULT_FACTORY, _vaultFactory);
    }
    function updateAuctionContract(address _auctionContract) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(AUCTION_CONTRACT, _auctionContract);
    }
    function updateStaderOracle(address _staderOracle) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(STADER_ORACLE, _staderOracle);
    }
    function updatePenaltyContract(address _penaltyContract) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(PENALTY_CONTRACT, _penaltyContract);
    }
    function updatePermissionedPool(address _permissionedPool) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(PERMISSIONED_POOL, _permissionedPool);
    }
    function updateStakePoolManager(address _stakePoolManager) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(STAKE_POOL_MANAGER, _stakePoolManager);
    }
    function updatePermissionlessPool(address _permissionlessPool) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(PERMISSIONLESS_POOL, _permissionlessPool);
    }
    function updateUserWithdrawManager(address _userWithdrawManager) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(USER_WITHDRAW_MANAGER, _userWithdrawManager);
    }
    function updateStaderInsuranceFund(address _staderInsuranceFund) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(STADER_INSURANCE_FUND, _staderInsuranceFund);
    }
    function updatePermissionedNodeRegistry(address _permissionedNodeRegistry) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(PERMISSIONED_NODE_REGISTRY, _permissionedNodeRegistry);
    }
    function updatePermissionlessNodeRegistry(address _permissionlessNodeRegistry)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        setContract(PERMISSIONLESS_NODE_REGISTRY, _permissionlessNodeRegistry);
    }
    function updatePermissionedSocializingPool(address _permissionedSocializePool)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        setContract(PERMISSIONED_SOCIALIZING_POOL, _permissionedSocializePool);
    }
    function updatePermissionlessSocializingPool(address _permissionlessSocializePool)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        setContract(PERMISSIONLESS_SOCIALIZING_POOL, _permissionlessSocializePool);
    }
    function updateNodeELRewardImplementation(address _nodeELRewardVaultImpl) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(NODE_EL_REWARD_VAULT_IMPLEMENTATION, _nodeELRewardVaultImpl);
    }
    function updateValidatorWithdrawalVaultImplementation(address _validatorWithdrawalVaultImpl)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        setContract(VALIDATOR_WITHDRAWAL_VAULT_IMPLEMENTATION, _validatorWithdrawalVaultImpl);
    }
    function updateETHBalancePORFeedProxy(address _ethBalanceProxy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(ETH_BALANCE_POR_FEED, _ethBalanceProxy);
    }
    function updateETHXSupplyPORFeedProxy(address _ethXSupplyProxy) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setContract(ETHX_SUPPLY_POR_FEED, _ethXSupplyProxy);
    }
    function updateStaderToken(address _staderToken) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setToken(SD, _staderToken);
    }
    function updateETHxToken(address _ethX) external onlyRole(DEFAULT_ADMIN_ROLE) {
        setToken(ETHx, _ethX);
    }
    function getStakedEthPerNode() external view override returns (uint256) {
        return constantsMap[ETH_PER_NODE];
    }
    function getPreDepositSize() external view override returns (uint256) {
        return constantsMap[PRE_DEPOSIT_SIZE];
    }
    function getFullDepositSize() external view override returns (uint256) {
        return constantsMap[FULL_DEPOSIT_SIZE];
    }
    function getDecimals() external view override returns (uint256) {
        return constantsMap[DECIMALS];
    }
    function getTotalFee() external view override returns (uint256) {
        return constantsMap[TOTAL_FEE];
    }
    function getOperatorMaxNameLength() external view override returns (uint256) {
        return constantsMap[OPERATOR_MAX_NAME_LENGTH];
    }
    function getSocializingPoolCycleDuration() external view override returns (uint256) {
        return variablesMap[SOCIALIZING_POOL_CYCLE_DURATION];
    }
    function getSocializingPoolOptInCoolingPeriod() external view override returns (uint256) {
        return variablesMap[SOCIALIZING_POOL_OPT_IN_COOLING_PERIOD];
    }
    function getRewardsThreshold() external view override returns (uint256) {
        return variablesMap[REWARD_THRESHOLD];
    }
    function getMinDepositAmount() external view override returns (uint256) {
        return variablesMap[MIN_DEPOSIT_AMOUNT];
    }
    function getMaxDepositAmount() external view override returns (uint256) {
        return variablesMap[MAX_DEPOSIT_AMOUNT];
    }
    function getMinWithdrawAmount() external view override returns (uint256) {
        return variablesMap[MIN_WITHDRAW_AMOUNT];
    }
    function getMaxWithdrawAmount() external view override returns (uint256) {
        return variablesMap[MAX_WITHDRAW_AMOUNT];
    }
    function getMinBlockDelayToFinalizeWithdrawRequest() external view override returns (uint256) {
        return variablesMap[MIN_BLOCK_DELAY_TO_FINALIZE_WITHDRAW_REQUEST];
    }
    function getWithdrawnKeyBatchSize() external view override returns (uint256) {
        return variablesMap[WITHDRAWN_KEYS_BATCH_SIZE];
    }
    function getAdmin() external view returns (address) {
        return accountsMap[ADMIN];
    }
    function getStaderTreasury() external view override returns (address) {
        return accountsMap[STADER_TREASURY];
    }
    function getPoolUtils() external view override returns (address) {
        return contractsMap[POOL_UTILS];
    }
    function getPoolSelector() external view override returns (address) {
        return contractsMap[POOL_SELECTOR];
    }
    function getSDCollateral() external view override returns (address) {
        return contractsMap[SD_COLLATERAL];
    }
    function getOperatorRewardsCollector() external view override returns (address) {
        return contractsMap[OPERATOR_REWARD_COLLECTOR];
    }
    function getVaultFactory() external view override returns (address) {
        return contractsMap[VAULT_FACTORY];
    }
    function getStaderOracle() external view override returns (address) {
        return contractsMap[STADER_ORACLE];
    }
    function getAuctionContract() external view override returns (address) {
        return contractsMap[AUCTION_CONTRACT];
    }
    function getPenaltyContract() external view override returns (address) {
        return contractsMap[PENALTY_CONTRACT];
    }
    function getPermissionedPool() external view override returns (address) {
        return contractsMap[PERMISSIONED_POOL];
    }
    function getStakePoolManager() external view override returns (address) {
        return contractsMap[STAKE_POOL_MANAGER];
    }
    function getETHDepositContract() external view override returns (address) {
        return contractsMap[ETH_DEPOSIT_CONTRACT];
    }
    function getPermissionlessPool() external view override returns (address) {
        return contractsMap[PERMISSIONLESS_POOL];
    }
    function getUserWithdrawManager() external view override returns (address) {
        return contractsMap[USER_WITHDRAW_MANAGER];
    }
    function getStaderInsuranceFund() external view override returns (address) {
        return contractsMap[STADER_INSURANCE_FUND];
    }
    function getPermissionedNodeRegistry() external view override returns (address) {
        return contractsMap[PERMISSIONED_NODE_REGISTRY];
    }
    function getPermissionlessNodeRegistry() external view override returns (address) {
        return contractsMap[PERMISSIONLESS_NODE_REGISTRY];
    }
    function getPermissionedSocializingPool() external view override returns (address) {
        return contractsMap[PERMISSIONED_SOCIALIZING_POOL];
    }
    function getPermissionlessSocializingPool() external view override returns (address) {
        return contractsMap[PERMISSIONLESS_SOCIALIZING_POOL];
    }
    function getNodeELRewardVaultImplementation() external view override returns (address) {
        return contractsMap[NODE_EL_REWARD_VAULT_IMPLEMENTATION];
    }
    function getValidatorWithdrawalVaultImplementation() external view override returns (address) {
        return contractsMap[VALIDATOR_WITHDRAWAL_VAULT_IMPLEMENTATION];
    }
    function getETHBalancePORFeedProxy() external view override returns (address) {
        return contractsMap[ETH_BALANCE_POR_FEED];
    }
    function getETHXSupplyPORFeedProxy() external view override returns (address) {
        return contractsMap[ETHX_SUPPLY_POR_FEED];
    }
    function getStaderToken() external view override returns (address) {
        return tokensMap[SD];
    }
    function getETHxToken() external view returns (address) {
        return tokensMap[ETHx];
    }
    function setConstant(bytes32 key, uint256 val) internal {
        constantsMap[key] = val;
        emit SetConstant(key, val);
    }
    function setVariable(bytes32 key, uint256 val) internal {
        variablesMap[key] = val;
        emit SetConstant(key, val);
    }
    function setAccount(bytes32 key, address val) internal {
        UtilLib.checkNonZeroAddress(val);
        accountsMap[key] = val;
        emit SetAccount(key, val);
    }
    function setContract(bytes32 key, address val) internal {
        UtilLib.checkNonZeroAddress(val);
        contractsMap[key] = val;
        emit SetContract(key, val);
    }
    function setToken(bytes32 key, address val) internal {
        UtilLib.checkNonZeroAddress(val);
        tokensMap[key] = val;
        emit SetToken(key, val);
    }
    function onlyStaderContract(address _addr, bytes32 _contractName) external view returns (bool) {
        return (_addr == contractsMap[_contractName]);
    }
    function onlyManagerRole(address account) public view override returns (bool) {
        return hasRole(MANAGER, account);
    }
    function onlyOperatorRole(address account) public view override returns (bool) {
        return hasRole(OPERATOR, account);
    }
    function verifyDepositAndWithdrawLimits() internal view {
        if (
            !(variablesMap[MIN_DEPOSIT_AMOUNT] != 0 &&
                variablesMap[MIN_WITHDRAW_AMOUNT] != 0 &&
                variablesMap[MIN_DEPOSIT_AMOUNT] <= variablesMap[MAX_DEPOSIT_AMOUNT] &&
                variablesMap[MIN_WITHDRAW_AMOUNT] <= variablesMap[MAX_WITHDRAW_AMOUNT] &&
                variablesMap[MIN_WITHDRAW_AMOUNT] <= variablesMap[MIN_DEPOSIT_AMOUNT] &&
                variablesMap[MAX_WITHDRAW_AMOUNT] >= variablesMap[MAX_DEPOSIT_AMOUNT])
        ) {
            revert InvalidLimits();
        }
    }
}