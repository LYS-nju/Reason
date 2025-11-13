pragma solidity 0.8.19;
interface IERC20Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
interface IERC20PermitUpgradeable {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;
    function safeTransfer(IERC20Upgradeable token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20Upgradeable token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20Upgradeable token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20Upgradeable token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function safePermit(
        IERC20PermitUpgradeable token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20Upgradeable token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && AddressUpgradeable.isContract(address(token));
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
        if (_initialized != type(uint8).max) {
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
interface IStaking {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
        uint256 lastStakedAt;
        uint256 lastUnstakedAt;
    }
    function getUserInfo(address account) external view returns (UserInfo memory);
    function pendingRewards(address account) external view returns (uint256);
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function claim() external;
}
interface IStakingLockable is IStaking {
    function setLockPeriod(uint256 _lockPeriod) external;
    function setLevelManager(address _address) external;
    function getLockPeriod() external view returns (uint256);
    function lock(address account, uint256 saleStart) external;
    function getUnlocksAt(address account) external view returns (uint256);
    function isLocked(address account) external view returns (bool);
    function getLockedAmount(address account) external view returns (uint256);
}
interface ILevelManager {
    struct Tier {
        string id;
        uint256 multiplier; 
        uint256 lockingPeriod; 
        uint256 minAmount; 
        bool random;
        uint8 odds; 
        bool vip; 
        bool aag; 
        address pool; 
        uint256 amount; 
    }
    struct Pool {
        address addr;
        bool enabled;
        bool isVip; 
        bool isAAG; 
        uint256 minAAGLevelMultiplier;
        uint256 multiplierLotteryBoost;
        uint256 multiplierGuaranteedBoost;
        uint256 multiplierAAGBoost;
        uint256 multiplierSAAGBoost;
    }
    function getAlwaysRegister()
    external
    view
    returns (
        address[] memory,
        string[] memory,
        uint256[] memory
    );
    function getUserUnlockTime(address account) external view returns (uint256);
    function getTierById(string calldata id)
    external
    view
    returns (Tier memory);
    function getUserTier(address account) external view returns (Tier memory);
    function getIsUserAAG(address account) external view returns (bool);
    function getTierIds() external view returns (string[] memory);
    function lock(address account, address pool, uint256 startTime) external;
}
interface IMigrationPool {
    function migrateFromStaking(
        address account,
        address pool,
        uint256 amount,
        uint256 depositLockStart,
        uint256 lockPeriod,
        uint256 unclaimedReward
    ) external;
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
contract StandaloneTreasury is Ownable {
    function allowPoolClaiming(
        IERC20 rewardToken,
        address stakingPool,
        uint256 amount
    ) external onlyOwner {
        if (amount == 0) {
            amount = 100000000000000 ether;
        }
        rewardToken.approve(stakingPool, amount);
    }
    function withdrawToken(address token) external onlyOwner {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }
    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}
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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
            require(denominator > prod1, "Math: mulDiv overflow");
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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
library SignedMathUpgradeable {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }
    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            return uint256(n >= 0 ? n : -n);
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
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
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
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
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
abstract contract AdminableUpgradeable is Initializable, OwnableUpgradeable, AccessControlUpgradeable {
    function __Adminable_init() public virtual initializer {
        OwnableUpgradeable.__Ownable_init();
        AccessControlUpgradeable.__AccessControl_init();
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
    modifier onlyOwnerOrAdmin() {
        require(
            owner() == _msgSender() ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Adminable: caller is not the owner or admin"
        );
        _;
    }
}
contract LaunchpadLockableStaking is Initializable, AdminableUpgradeable, IStakingLockable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    ILevelManager public levelManager;
    StandaloneTreasury public treasury;
    struct PoolInfo {
        IERC20Upgradeable stakingToken;
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
    }
    struct Fees {
        address collectorAddress;
        uint256 depositFee;
        uint256 withdrawFee;
        uint256 collectedDepositFees;
        uint256 collectedWithdrawFees;
    }
    bool public halted;
    PoolInfo public liquidityMining;
    IERC20Upgradeable public rewardToken;
    uint256 public rewardPerBlock;
    uint256 private divider;
    mapping(address => UserInfo) public userInfo;
    Fees public fees;
    bool public allowEarlyWithdrawal;
    uint256 public stakersCount;
    uint256 public lockPeriod;
    uint256 public fixedApr;
    mapping(address => uint256) public depositLockStart;
    bool public alwaysLockOnRegister;
    address[] public higherPools;
    uint8 public extendLockDaysOnRegister;
    IStaking public secondaryStaking;
    mapping(address => uint256) public lastClaimedAt;
    bool public waitForRewardMaturity;
    uint256 public rewardMaturityDuration;
    struct ClaimFees {
        address collectorAddress;
        uint256 fee;
        uint256 collectedFees;
    }
    ClaimFees public claimFees;
    address private migrationPool;
    mapping(address => bool) public isMigrated; 
    event Deposit(address indexed user, uint256 amount, uint256 feeAmount);
    event Withdraw(address indexed user, uint256 amount, uint256 feeAmount, bool locked);
    event UppedLockPool(address indexed user, uint256 amount, address targetPool);
    event Claim(address indexed user, uint256 amount, uint256 feeAmount);
    event StakedPending(address indexed user, uint256 amount);
    event Halted(bool status);
    event FeesUpdated(uint256 depositFee, uint256 withdrawFee, uint256 claimFee);
    event EarlyWithdrawalUpdated(bool allowEarlyWithdrawal);
    event RewardPerBlockUpdated(uint256 rewardPerBlock);
    event Locked(address indexed user, uint256 amount, uint256 lockPeriod, uint256 rewardPerBlock);
    modifier onlyLevelManager() {
        require(msg.sender == address(levelManager), 'Only LevelManager can lock');
        _;
    }
    modifier notMigrated() {
        require(!isMigrated[msg.sender], 'Migrated');
        _;
    }
    function initialize(
        address _levelManager,
        address _treasury,
        address _feeAddress,
        uint256 _depositFee,
        uint256 _withdrawFee,
        uint256 _lockPeriod,
        uint256 _fixedApr
    ) public initializer {
        AdminableUpgradeable.__Adminable_init();
        levelManager = ILevelManager(_levelManager);
        setTreasury(_treasury);
        setFees(_feeAddress, _depositFee, _withdrawFee, _feeAddress, 0);
        divider = 1e12;
        allowEarlyWithdrawal = false;
        lockPeriod = _lockPeriod;
        fixedApr = _fixedApr;
        waitForRewardMaturity = true;
    }
    function isLocked(address account) public view override returns (bool) {
        return block.timestamp < depositLockStart[account] + lockPeriod;
    }
    function getLockPeriod() external view override returns (uint256) {
        return lockPeriod;
    }
    function getUnlocksAt(address account) external view override returns (uint256) {
        return depositLockStart[account] + lockPeriod;
    }
    function getLockedAmount(address account) external view override returns (uint256) {
        return userInfo[account].amount;
    }
    function getUserInfo(address account) external view override returns (UserInfo memory) {
        return userInfo[account];
    }
    function getRewardPerBlock(address account) public view returns (uint256) {
        if (fixedApr == 0) {
            return 0;
        }
        if (userInfo[account].amount == 0 || !isLocked(account)) {
            return 0;
        }
        return getRewardPerSecond(account) * 3;
    }
    function getRewardPerSecond(address account) public view returns (uint256) {
        return (userInfo[account].amount * fixedApr) / 100 / 100 / (365 * 24 * 3600);
    }
    function setLevelManager(address _address) external override onlyOwner {
        levelManager = ILevelManager(_address);
    }
    function setTreasury(address _address) public onlyOwner {
        treasury = StandaloneTreasury(_address);
    }
    function setFixedApr(uint256 _apr) public onlyOwner {
        fixedApr = _apr;
        rewardPerBlock = 0;
    }
    function setLockPeriod(uint256 _lockPeriod) external override onlyOwner {
        lockPeriod = _lockPeriod;
    }
    function setSecondaryStaking(address _address) external onlyOwner {
        secondaryStaking = IStaking(_address);
    }
    function setFees(
        address _feeAddress,
        uint256 _depositFee,
        uint256 _withdrawFee,
        address _claimFeeAddress,
        uint256 _claimFee
    ) public onlyOwner {
        require(_feeAddress != address(0), 'Fees collector address is not specified');
        require(_depositFee < 700, 'Max deposit fee: 70%');
        require(_withdrawFee < 700, 'Max withdraw fee: 70%');
        require(_claimFee < 700, 'Max claim fee: 70%');
        fees.collectorAddress = _feeAddress;
        fees.depositFee = _depositFee;
        fees.withdrawFee = _withdrawFee;
        claimFees.collectorAddress = _claimFeeAddress;
        claimFees.fee = _claimFee;
        emit FeesUpdated(_depositFee, _withdrawFee, _claimFee);
    }
    function setWithdrawFee(uint256 _withdrawFee) external onlyOwner {
        require(_withdrawFee < 700, 'Max withdraw fee: 70%');
        fees.withdrawFee = _withdrawFee;
        emit FeesUpdated(fees.depositFee, fees.withdrawFee, claimFees.fee);
    }
    function setAllowEarlyWithdrawal(bool status) public onlyOwner {
        allowEarlyWithdrawal = status;
        emit EarlyWithdrawalUpdated(status);
    }
    function setWaitForMaturity(bool enabled, uint256 duration) public onlyOwner {
        waitForRewardMaturity = enabled;
        rewardMaturityDuration = duration;
    }
    function halt(bool status) external onlyOwnerOrAdmin {
        halted = status;
        emit Halted(status);
    }
    function setRewardPerBlock(uint256 _rewardPerBlock) external onlyOwnerOrAdmin {
        rewardPerBlock = _rewardPerBlock;
        fixedApr = 0;
        emit RewardPerBlockUpdated(rewardPerBlock);
    }
    function setAlwaysLockOnRegister(bool status) external onlyOwnerOrAdmin {
        alwaysLockOnRegister = status;
    }
    function deposit(uint256 amount) external override notMigrated {
        require(!halted, 'Deposits are paused');
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        uint256 fee;
        if (address(secondaryStaking) != address(0)) {
            secondaryStaking.deposit(amount);
        }
        if (!isLocked(account)) {
            depositLockStart[account] = block.timestamp;
            lastClaimedAt[account] = block.timestamp;
            user.rewardDebt = 0;
            emit Locked(account, amount, lockPeriod, 0);
        }
        updateUserPending(account);
        if (amount > 0) {
            liquidityMining.stakingToken.safeTransferFrom(address(account), address(this), amount);
            (amount, fee) = takeFee(amount, fees.depositFee, fees.collectorAddress);
            fees.collectedDepositFees += fee;
            stakersCount += user.amount == 0 ? 1 : 0;
            user.amount += amount;
            user.lastStakedAt = block.timestamp;
        }
        updateUserDebt(account);
        emit Deposit(account, amount, fee);
    }
    function withdraw(uint256 amount) external override notMigrated {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        bool tokensLocked = isLocked(account);
        uint256 fee;
        require(allowEarlyWithdrawal || !tokensLocked, 'Account is locked');
        require(user.amount >= amount, 'Withdrawing more than you have!');
        if (address(secondaryStaking) != address(0)) {
            try secondaryStaking.withdraw(amount) {} catch {}
        }
        updateUserPending(account);
        if (amount > 0) {
            user.amount -= amount;
            user.lastUnstakedAt = block.timestamp;
            stakersCount -= user.amount == 0 && stakersCount > 0 ? 1 : 0;
            if (allowEarlyWithdrawal && tokensLocked) {
                (amount, fee) = takeFee(amount, fees.withdrawFee, fees.collectorAddress);
                fees.collectedWithdrawFees += fee;
            }
            liquidityMining.stakingToken.safeTransfer(address(account), amount);
        }
        updateUserDebt(account);
        emit Withdraw(account, amount, fee, tokensLocked);
    }
    function claim() external override notMigrated {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        require(isRewardMatured(account), 'Rewards are not matured yet');
        updateUserPending(account);
        if (user.pendingRewards > 0) {
            uint256 fee;
            if (claimFees.fee > 0) {
                fee = (user.pendingRewards * claimFees.fee) / 1000;
                user.pendingRewards -= fee;
                claimFees.collectedFees += fee;
                safeRewardTransfer(claimFees.collectorAddress, fee);
            }
            uint256 claimedAmount = safeRewardTransfer(account, user.pendingRewards);
            user.pendingRewards -= claimedAmount;
            lastClaimedAt[account] = rewardMaturityDuration > 0 ? block.timestamp : depositLockStart[account];
            emit Claim(account, claimedAmount, fee);
        }
        updateUserDebt(account);
    }
    function stakePendingRewards() external notMigrated {
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        updateUserPending(account);
        uint256 amount = user.pendingRewards;
        user.pendingRewards = 0;
        user.amount += amount;
        if (!isLocked(account)) {
            depositLockStart[account] = block.timestamp;
            user.rewardDebt = 0;
            emit Locked(account, amount, lockPeriod, 0);
        }
        updateUserDebt(account);
        if (address(secondaryStaking) != address(0)) {
            secondaryStaking.deposit(amount);
        }
        emit StakedPending(account, amount);
    }
    function isRewardMatured(address account) internal returns (bool) {
        uint256 matureAt = lastClaimedAt[account] + (rewardMaturityDuration > 0 ? rewardMaturityDuration : lockPeriod);
        return !waitForRewardMaturity || block.timestamp > matureAt;
    }
    function takeFee(
        uint256 amount,
        uint256 feePercent,
        address feesAddress
    ) internal returns (uint256, uint256) {
        if (feePercent == 0) {
            return (amount, 0);
        }
        uint256 feeAmount = (amount * feePercent) / 1000;
        liquidityMining.stakingToken.safeTransfer(feesAddress, feeAmount);
        return (amount - feeAmount, feeAmount);
    }
    function updateUserPending(address account) internal {
        UserInfo storage user = userInfo[account];
        if (user.amount == 0) {
            return;
        }
        uint256 totalPending = user.pendingRewards + getFixedAprPendingReward(account);
        if (totalPending < user.rewardDebt) {
            user.pendingRewards = 0;
        } else {
            user.pendingRewards = totalPending - user.rewardDebt;
        }
    }
    function getFixedAprPendingReward(address account) public view returns (uint256) {
        if (depositLockStart[account] == 0 || depositLockStart[account] == block.timestamp) {
            return 0;
        }
        uint256 passedTime = block.timestamp >= depositLockStart[account] + lockPeriod
            ? lockPeriod
            : block.timestamp - depositLockStart[account];
        return passedTime * getRewardPerSecond(account);
    }
    function updateUserDebt(address account) internal {
        UserInfo storage user = userInfo[account];
        user.rewardDebt = getFixedAprPendingReward(account);
    }
    function setPoolInfo(IERC20Upgradeable _rewardToken, IERC20Upgradeable _stakingToken) external onlyOwner {
        require(
            address(rewardToken) == address(0) && address(liquidityMining.stakingToken) == address(0),
            'Token is already set'
        );
        rewardToken = _rewardToken;
        liquidityMining = PoolInfo({stakingToken: _stakingToken, lastRewardBlock: 0, accRewardPerShare: 0});
    }
    function safeRewardTransfer(address to, uint256 amount) internal returns (uint256) {
        uint256 balance = rewardToken.balanceOf(address(treasury));
        require(amount > 0, 'Reward amount must be more than zero');
        require(balance > 0, 'Not enough reward tokens for transfer');
        if (amount > balance) {
            rewardToken.safeTransferFrom(address(treasury), to, balance);
            return balance;
        }
        rewardToken.safeTransferFrom(address(treasury), to, amount);
        return amount;
    }
    function pendingRewards(address _user) external view override returns (uint256) {
        UserInfo storage user = userInfo[_user];
        return user.pendingRewards + getFixedAprPendingReward(_user) - user.rewardDebt;
    }
    function withdrawToken(address token, uint256 amount) external onlyOwnerOrAdmin {
        IERC20Upgradeable(token).transfer(msg.sender, amount);
    }
    function lock(address account, uint256 saleStart) external override onlyLevelManager {
        bool isUserLocked = isLocked(account);
        if (userInfo[account].amount == 0 || (isUserLocked && !alwaysLockOnRegister)) {
            return;
        }
        if (!isUserLocked || alwaysLockOnRegister) {
            updateDepositLockStart(account, block.timestamp);
            lastClaimedAt[account] = block.timestamp;
        }
        emit Locked(account, userInfo[account].amount, lockPeriod, 0);
    }
    function upPool(address targetPool) external notMigrated {
        require(targetPool != address(0) && targetPool != address(this), 'Must specify target pool');
        require(higherPools.length > 0, 'Must have higherPools configured');
        bool poolAllowed = false;
        for (uint256 i = 0; i < higherPools.length; i++) {
            if (higherPools[i] == targetPool) {
                poolAllowed = true;
            }
        }
        require(poolAllowed, 'Pool not allowed');
        address account = msg.sender;
        UserInfo storage user = userInfo[account];
        require(user.amount > 0, 'No tokens locked');
        updateUserPending(account);
        liquidityMining.stakingToken.approve(targetPool, user.amount);
        LaunchpadLockableStaking(targetPool).receiveUpPool(account, user.amount);
        emit UppedLockPool(account, user.amount, targetPool);
        user.amount = 0;
        depositLockStart[account] = 0;
        updateUserDebt(account);
        lastClaimedAt[account] = 0;
    }
    function receiveUpPool(address account, uint256 amount) external {
        require(account != address(0), 'Must specify valid account');
        require(amount > 0, 'Must specify non-zero amount');
        UserInfo storage user = userInfo[account];
        uint256 newLockStartTime;
        if (isLocked(account)) {
            newLockStartTime = depositLockStart[account];
        } else {
            newLockStartTime = LaunchpadLockableStaking(msg.sender).isLocked(account)
                ? LaunchpadLockableStaking(msg.sender).depositLockStart(account)
                : block.timestamp;
        }
        updateDepositLockStart(account, newLockStartTime);
        emit Locked(account, amount, lockPeriod, 0);
        liquidityMining.stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        stakersCount += user.lastStakedAt > 0 ? 0 : 1;
        user.amount += amount;
        user.lastStakedAt = block.timestamp;
        lastClaimedAt[account] = block.timestamp;
        emit Deposit(account, amount, 0);
        if (address(secondaryStaking) != address(0)) {
            secondaryStaking.deposit(amount);
        }
    }
    function updateDepositLockStartAdmin(address account, uint256 lockStart) external onlyOwnerOrAdmin {
        updateDepositLockStart(account, lockStart);
    }
    function updateDepositLockStart(address account, uint256 lockStart) internal {
        updateUserPending(account);
        depositLockStart[account] = lockStart;
        updateUserDebt(account);
    }
    function setHigherPools(address[] calldata pools) external onlyOwnerOrAdmin {
        higherPools = pools;
    }
    function batchSyncLockStatus(address[] calldata addresses) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (!isLocked(addr)) {
                updateUserPending(addr);
            }
        }
    }
    function batchFixateRewardsBefore(address[] calldata addresses) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (userInfo[addr].amount > 0) {
                updateUserPending(addr);
                updateUserDebt(addr);
            }
        }
    }
    function batchFixateDebtAfter(address[] calldata addresses) external onlyOwnerOrAdmin {
        for (uint256 i = 0; i < addresses.length; i++) {
            address addr = addresses[i];
            if (userInfo[addr].amount > 0) {
                updateUserDebt(addr);
            }
        }
    }
    function unlock(address account) external onlyOwnerOrAdmin {
        updateDepositLockStart(account, 0);
    }
    function transferAccountBalance(address oldAccount, address newAccount) external onlyOwner {
        depositLockStart[newAccount] = depositLockStart[oldAccount];
        depositLockStart[oldAccount] = 0;
        userInfo[newAccount].amount += userInfo[oldAccount].amount;
        userInfo[oldAccount].amount = 0;
        userInfo[newAccount].pendingRewards += userInfo[oldAccount].pendingRewards;
        userInfo[oldAccount].pendingRewards = 0;
        updateUserDebt(newAccount);
        userInfo[oldAccount].rewardDebt = 0;
    }
    function setMigrationPool(address pool) external onlyOwnerOrAdmin {
        require(pool != address(0), 'Must specify valid migration pool');
        migrationPool = pool;
    }
    function migrateTokens() external notMigrated {
        liquidityMining.stakingToken.approve(migrationPool, userInfo[msg.sender].amount);
        IMigrationPool(migrationPool).migrateFromStaking(
            msg.sender,
            address(this),
            userInfo[msg.sender].amount,
            depositLockStart[msg.sender],
            lockPeriod,
            userInfo[msg.sender].pendingRewards
        );
        isMigrated[msg.sender] = true;
    }
}