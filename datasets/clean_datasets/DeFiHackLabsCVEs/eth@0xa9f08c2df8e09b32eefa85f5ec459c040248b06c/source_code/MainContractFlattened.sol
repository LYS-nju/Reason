pragma solidity 0.8.18;
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
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
interface IERC20Permit {
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
library Address {
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
library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function safePermit(
        IERC20Permit token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
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
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }
    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }
    modifier whenPaused() {
        _requirePaused();
        _;
    }
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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
interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns (bytes32);
}
interface IBeaconUpgradeable {
    function implementation() external view returns (address);
}
interface IERC1967Upgradeable {
    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);
    event BeaconUpgraded(address indexed beacon);
}
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }
    struct BooleanSlot {
        bool value;
    }
    struct Bytes32Slot {
        bytes32 value;
    }
    struct Uint256Slot {
        uint256 value;
    }
    struct StringSlot {
        string value;
    }
    struct BytesSlot {
        bytes value;
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
}
abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }
    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(newImplementation, data);
        }
    }
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }
    uint256[50] private __gap;
}
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }
    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
library Utils {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    function payMe(address payer, uint256 amount, address token) internal returns (bool) {
        return payTo(payer, address(this), amount, token);
    }
    function payTo(address allower, address receiver, uint256 amount, address token) internal returns (bool) {
        return IERC20(token).transferFrom(allower, receiver, amount);
    }
    function payDirect(address to, uint256 amount, address token) internal returns (bool) {
        IERC20(token).safeTransfer(to, amount);
        return true;
    }
}
interface IRestakedETH is IERC20 {
    function stakedTokenAddress() external view returns (address);
    function scaledBalanceOf(address who) external view returns (uint256);
    function scaledBalanceToBalance(uint256 scaledBalance) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function burn(address from, uint256 amount) external;
    function rebase(uint256 epoch, bool isRebasePositive, uint256 supplyDelta) external returns (uint256);
}
interface IDelegator {
    function getStakedTokenAddressAtWithdrawalsIndex(
        uint256 _index
    ) external returns (address);
    function restake(
        address _stakedTokenAddress,
        address _eigenLayerStrategyManagerAddress,
        address _eigenLayerStrategyAddress
    ) external returns (uint256);
    function queueWithdrawal(
        address _stakedTokenAddress,
        address _eigenLayerStrategyManagerAddress,
        address _eigenLayerStrategyAddress
    ) external returns (uint96);
    function canWithdraw(
        uint96 _withdrawalIndex,
        uint256 _middlewareTimesIndex,
        address _eigenLayerStrategyManagerAddress
    ) external view returns (bool);
    function completeQueuedWithdrawal(
        uint96 _withdrawalIndex,
        uint256 _middlewareTimesIndex,
        address _eigenLayerStrategyManagerAddress,
        address _eigenLayerStrategyAddress
    ) external;
    function pull(address token) external returns (uint256 balance);
    function getAssetBalances(
        address _eigenLayerStrategyManagerAddress
    ) external view returns (address[] memory, uint256[] memory);
    function getAssetBalance(
        address _token,
        address _eigenLayerStrategyAddress
    ) external view returns (uint256);
}
interface IStrategy {
    function deposit(IERC20 token, uint256 amount) external returns (uint256);
    function withdraw(address depositor, IERC20 token, uint256 amountShares) external;
    function sharesToUnderlying(uint256 amountShares) external returns (uint256);
    function underlyingToShares(uint256 amountUnderlying) external returns (uint256);
    function userUnderlying(address user) external returns (uint256);
    function sharesToUnderlyingView(uint256 amountShares) external view returns (uint256);
    function underlyingToSharesView(uint256 amountUnderlying) external view returns (uint256);
    function userUnderlyingView(address user) external view returns (uint256);
    function underlyingToken() external view returns (IERC20);
    function totalShares() external view returns (uint256);
    function explanation() external view returns (string memory);
    function shares(address user) external view returns (uint256);
}
interface ISlasher {
    struct MiddlewareTimes {
        uint32 stalestUpdateBlock;
        uint32 latestServeUntilBlock;
    }
    struct MiddlewareDetails {
        uint32 contractCanSlashOperatorUntilBlock;
        uint32 latestUpdateBlock;
    }
    function optIntoSlashing(address contractAddress) external;
    function freezeOperator(address toBeFrozen) external;
    function resetFrozenStatus(address[] calldata frozenAddresses) external;
    function recordFirstStakeUpdate(address operator, uint32 serveUntilBlock) external;
    function recordStakeUpdate(address operator, uint32 updateBlock, uint32 serveUntilBlock, uint256 insertAfter) external;
    function recordLastStakeUpdateAndRevokeSlashingAbility(address operator, uint32 serveUntilBlock) external;
    function isFrozen(address staker) external view returns (bool);
    function canSlash(address toBeSlashed, address slashingContract) external view returns (bool);
    function contractCanSlashOperatorUntilBlock(address operator, address serviceContract) external view returns (uint32);
    function latestUpdateBlock(address operator, address serviceContract) external view returns (uint32);
    function getCorrectValueForInsertAfter(address operator, uint32 updateBlock) external view returns (uint256);
    function canWithdraw(address operator, uint32 withdrawalStartBlock, uint256 middlewareTimesIndex) external view returns(bool);
    function operatorToMiddlewareTimes(address operator, uint256 arrayIndex) external view returns (MiddlewareTimes memory);
    function middlewareTimesLength(address operator) external view returns (uint256);
    function getMiddlewareTimesIndexBlock(address operator, uint32 index) external view returns(uint32);
    function getMiddlewareTimesIndexServeUntilBlock(address operator, uint32 index) external view returns(uint32);
    function operatorWhitelistedContractsLinkedListSize(address operator) external view returns (uint256);
    function operatorWhitelistedContractsLinkedListEntry(address operator, address node) external view returns (bool, uint256, uint256);
}
interface IDelegationTerms {
    function payForService(IERC20 token, uint256 amount) external payable;
    function onDelegationWithdrawn(
        address delegator,
        IStrategy[] memory stakerStrategyList,
        uint256[] memory stakerShares
    ) external returns(bytes memory);
    function onDelegationReceived(
        address delegator,
        IStrategy[] memory stakerStrategyList,
        uint256[] memory stakerShares
    ) external returns(bytes memory);
}
interface IDelegationManager {
    function registerAsOperator(IDelegationTerms dt) external;
    function delegateTo(address operator) external;
    function delegateToBySignature(address staker, address operator, uint256 expiry, bytes memory signature) external;
    function undelegate(address staker) external;
    function delegatedTo(address staker) external view returns (address);
    function delegationTerms(address operator) external view returns (IDelegationTerms);
    function operatorShares(address operator, IStrategy strategy) external view returns (uint256);
    function increaseDelegatedShares(address staker, IStrategy strategy, uint256 shares) external;
    function decreaseDelegatedShares(
        address staker,
        IStrategy[] calldata strategies,
        uint256[] calldata shares
    ) external;
    function isDelegated(address staker) external view returns (bool);
    function isNotDelegated(address staker) external view returns (bool);
    function isOperator(address operator) external view returns (bool);
}
interface IStrategyManager {
    struct WithdrawerAndNonce {
        address withdrawer;
        uint96 nonce;
    }
    struct QueuedWithdrawal {
        IStrategy[] strategies;
        uint256[] shares;
        address depositor;
        WithdrawerAndNonce withdrawerAndNonce;
        uint32 withdrawalStartBlock;
        address delegatedAddress;
    }
    function depositIntoStrategy(IStrategy strategy, IERC20 token, uint256 amount)
        external
        returns (uint256 shares);
    function depositBeaconChainETH(address staker, uint256 amount) external;
    function recordOvercommittedBeaconChainETH(address overcommittedPodOwner, uint256 beaconChainETHStrategyIndex, uint256 amount)
        external;
    function depositIntoStrategyWithSignature(
        IStrategy strategy,
        IERC20 token,
        uint256 amount,
        address staker,
        uint256 expiry,
        bytes memory signature
    )
        external
        returns (uint256 shares);
    function stakerStrategyShares(address user, IStrategy strategy) external view returns (uint256 shares);
    function getDeposits(address depositor) external view returns (IStrategy[] memory, uint256[] memory);
    function stakerStrategyListLength(address staker) external view returns (uint256);
    function stakerStrategyList(address, uint256) external view returns (address);
    function queueWithdrawal(
        uint256[] calldata strategyIndexes,
        IStrategy[] calldata strategies,
        uint256[] calldata shares,
        address withdrawer,
        bool undelegateIfPossible
    )
        external returns(bytes32);
    function completeQueuedWithdrawal(
        QueuedWithdrawal calldata queuedWithdrawal,
        IERC20[] calldata tokens,
        uint256 middlewareTimesIndex,
        bool receiveAsTokens
    )
        external;
    function completeQueuedWithdrawals(
        QueuedWithdrawal[] calldata queuedWithdrawals,
        IERC20[][] calldata tokens,
        uint256[] calldata middlewareTimesIndexes,
        bool[] calldata receiveAsTokens
    )
        external;
    function slashShares(
        address slashedAddress,
        address recipient,
        IStrategy[] calldata strategies,
        IERC20[] calldata tokens,
        uint256[] calldata strategyIndexes,
        uint256[] calldata shareAmounts
    )
        external;
    function slashQueuedWithdrawal(address recipient, QueuedWithdrawal calldata queuedWithdrawal, IERC20[] calldata tokens, uint256[] calldata indicesToSkip)
        external;
    function calculateWithdrawalRoot(
        QueuedWithdrawal memory queuedWithdrawal
    )
        external
        pure
        returns (bytes32);
    function addStrategiesToDepositWhitelist(IStrategy[] calldata strategiesToWhitelist) external;
    function removeStrategiesFromDepositWhitelist(IStrategy[] calldata strategiesToRemoveFromWhitelist) external;
    function delegation() external view returns (IDelegationManager);
    function slasher() external view returns (ISlasher);
    function beaconChainETHStrategy() external view returns (IStrategy);
    function withdrawalDelayBlocks() external view returns (uint256);
}
contract AstridProtocol is Initializable, UUPSUpgradeable, PausableUpgradeable, AccessControlUpgradeable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant REBASER_ROLE = keccak256("REBASER_ROLE");
    struct StakedTokenMapping {
        bool whitelisted;
        address restakedTokenAddress;
        address eigenLayerStrategyAddress;
    }
    mapping(address => StakedTokenMapping) public stakedTokens;
    address public eigenLayerStrategyManagerAddress;
    struct ReStakeInfo {
        address staker;
        address stakedTokenAddress;
        uint256 amount;
        uint256 stakedAt;
        uint256 shares;
    }
    struct WithdrawalInfo {
        address withdrawer;
        address restakedTokenAddress;
        uint256 amount;
        uint256 shares;
        bool pending;
        uint32 withdrawalStartBlock;
        uint256 withdrawInitiatedAt;
        uint256 withdrawCompletedAt;
        uint256 nonce;
        bytes32 withdrawalRoot;
    }
    mapping(address => ReStakeInfo[]) public restakes;
    mapping(address => WithdrawalInfo[]) public withdrawals;
    uint96 public withdrawalsNonce;
    struct DepositInfo {
        address staker;
        address stakedTokenAddress;
        uint256 amount;
        uint256 stakedAt;
    }
    enum WithdrawalStatus{ REQUESTED, PROCESSED, CLAIMED }
    struct WithdrawalRequest {
        address withdrawer;
        address restakedTokenAddress;
        uint256 amount;
        uint256 requestedRestakedTokenShares;
        uint256 claimableStakedTokenAmount;
        WithdrawalStatus status;
        uint32 withdrawalStartBlock;
        uint256 withdrawRequestedAt;
        uint256 withdrawProcessedAt;
        uint256 withdrawClaimedAt;
        uint256 withdrawalRequestsIndex;
        uint256 withdrawalRequestsByUserIndex;
    }
    struct ReBaseInfo {
        uint256 restakedTokenTotalSupply;
        uint256 stakedTokenBackedSupply;
        uint32 currentBlock;
        uint256 currentTimestamp;
    }
    IDelegator[] public delegators;
    mapping(address => DepositInfo[]) public deposits;
    mapping(address => uint256) public totalWithdrawalRequests; 
    WithdrawalRequest[] public withdrawalRequests;
    uint256 public withdrawalProcessingCurrentIndex;
    mapping(address => WithdrawalRequest[]) public withdrawalRequestsByUser;
    mapping(address => uint256) public totalClaimableWithdrawals; 
    bool public processWithdrawalsOnWithdraw;
    event EigenLayerStrategyManagerAddressSet(address oldAddress, address newAddress);
    event StakedTokenMappingSet(address stakedTokenAddress, bool whitelisted, address restakedTokenAddress, address eigenLayerStrategyAddress);
    event ProcessWithdrawalsOnWithdrawSet(bool value);
    event DelegatorAdded(address indexed delegator);
    event DelegatorRestaked(address indexed delegator, address stakedTokenAddress, uint256 amount, uint256 shares);
    event DelegatorWithdrawalQueued(address indexed delegator, address stakedTokenAddress, uint96 nonce);
    event DelegatorWithdrawalCompleted(address indexed delegator, uint96 withdrawalIndex);
    event DelegatorPulled(address indexed delegator, address token, uint256 balance);
    event DelegatorETHPulled(address indexed delegator, uint256 balance);
    event DepositPerformed(address indexed from, address stakedTokenAddress, uint256 amount);
    event WithdrawalRequested(address indexed to, address restakedTokenAddress, uint256 amount, uint256 shares);
    event WithdrawalProcessed(uint256 withdrawalRequestsIndex);
    event WithdrawalClaimed(address indexed to, uint256 withdrawalRequestsIndex);
    event RebasePerformed(address indexed restakedTokenAddress, uint256 currentTimestamp, uint256 totalSupply, bool isRebasePositive, uint256 supplyDelta);
    constructor() {
        _disableInitializers();
    }
    function initialize(address _governanceAddr, address _eigenLayerStrategyManagerAddr) initializer public {
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, _governanceAddr);
        _grantRole(PAUSER_ROLE, _governanceAddr);
        _grantRole(UPGRADER_ROLE, _governanceAddr);
        _grantRole(REBASER_ROLE, _governanceAddr);
        eigenLayerStrategyManagerAddress = _eigenLayerStrategyManagerAddr;
    }
    function setEigenLayerStrategyManagerAddress(
        address _eigenLayerStrategyManagerAddr
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        emit EigenLayerStrategyManagerAddressSet(eigenLayerStrategyManagerAddress, _eigenLayerStrategyManagerAddr);
        eigenLayerStrategyManagerAddress = _eigenLayerStrategyManagerAddr;
    }
    function setStakedTokenMapping(
        address _stakedTokenAddr,
        bool _whitelisted,
        address _restakedTokenAddr,
        address _eigenLayerStrategyAddr
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        stakedTokens[_stakedTokenAddr] = StakedTokenMapping({
            whitelisted: _whitelisted,
            restakedTokenAddress: _restakedTokenAddr,
            eigenLayerStrategyAddress: _eigenLayerStrategyAddr
        });
        emit StakedTokenMappingSet(_stakedTokenAddr, _whitelisted, _restakedTokenAddr, _eigenLayerStrategyAddr);
    }
    function setProcessWithdrawalsOnWithdraw(
        bool _value
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        processWithdrawalsOnWithdraw = _value;
        emit ProcessWithdrawalsOnWithdrawSet(_value);
    }
    function pause() public onlyRole(PAUSER_ROLE) {
        _pause();
    }
    function unpause() public onlyRole(PAUSER_ROLE) {
        _unpause();
    }
    function _authorizeUpgrade(address newImplementation) internal onlyRole(UPGRADER_ROLE) override {
    }
    function addDelegators(
        IDelegator[] calldata _delegatorContracts
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        for (uint256 i; i < _delegatorContracts.length; i++) {
            delegators.push(_delegatorContracts[i]);
            emit DelegatorAdded(address(_delegatorContracts[i]));
        }
    }
    function delegatorsLength() public view returns (uint256) {
        return delegators.length;
    }
    function restakeDelegator(
        uint16 _delegatorIndex,
        address _stakedTokenAddress,
        uint256 _amount
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256) {
        require(
            IERC20(_stakedTokenAddress).balanceOf(address(this)) >=
            totalClaimableWithdrawals[_stakedTokenAddress] + _amount,
            "AstridProtocol: Insufficient staked token available balance"
        );
        address delegator = address(delegators[_delegatorIndex]);
        bool sent = Utils.payDirect(delegator, _amount, _stakedTokenAddress);
        require(sent, "AstridProtocol: Failed to send staked token");
        uint256 shares = IDelegator(delegator).restake(
            _stakedTokenAddress,
            eigenLayerStrategyManagerAddress,
            stakedTokens[_stakedTokenAddress].eigenLayerStrategyAddress
        );
        emit DelegatorRestaked(delegator, _stakedTokenAddress, _amount, shares);
        return shares;
    }
    function queueWithdrawalDelegator(
        uint16 _delegatorIndex,
        address _stakedTokenAddress
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) returns (uint96) {
        uint96 nonce = delegators[_delegatorIndex].queueWithdrawal(
            _stakedTokenAddress,
            eigenLayerStrategyManagerAddress,
            stakedTokens[_stakedTokenAddress].eigenLayerStrategyAddress
        );
        emit DelegatorWithdrawalQueued(address(delegators[_delegatorIndex]), _stakedTokenAddress, nonce);
        return nonce;
    }
    function completeQueuedWithdrawalDelegator(
        uint16 _delegatorIndex,
        uint96 _withdrawalIndex,
        uint256 _middlewareTimesIndex
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {
        IDelegator delegator = delegators[_delegatorIndex];
        address _stakedTokenAddress = delegator.getStakedTokenAddressAtWithdrawalsIndex(_withdrawalIndex);
        delegator.completeQueuedWithdrawal(
            _withdrawalIndex,
            _middlewareTimesIndex,
            eigenLayerStrategyManagerAddress,
            stakedTokens[_stakedTokenAddress].eigenLayerStrategyAddress
        );
        emit DelegatorWithdrawalCompleted(address(delegator), _withdrawalIndex);
    }
    function pullDelegator(
        uint16 _delegatorIndex,
        address _token
    ) public whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) returns (uint256 balance) {
        balance = delegators[_delegatorIndex].pull(_token);
        emit DelegatorPulled(address(delegators[_delegatorIndex]), _token, balance);
    }
    function rebaseInfo(address _stakedTokenAddress) public view returns (ReBaseInfo memory) {
        StakedTokenMapping memory stakedTokenMapping = stakedTokens[_stakedTokenAddress];
        uint256 _stakedTokenBackedSupply;
        for (uint256 i; i < delegators.length; i++) {
            _stakedTokenBackedSupply += delegators[i].getAssetBalance(_stakedTokenAddress, stakedTokenMapping.eigenLayerStrategyAddress);
        }
        _stakedTokenBackedSupply += IERC20(_stakedTokenAddress).balanceOf(address(this));
        _stakedTokenBackedSupply -= totalClaimableWithdrawals[_stakedTokenAddress];
        ReBaseInfo memory info = ReBaseInfo({
            restakedTokenTotalSupply: IRestakedETH(stakedTokenMapping.restakedTokenAddress).totalSupply(),
            stakedTokenBackedSupply: _stakedTokenBackedSupply,
            currentBlock: uint32(block.number),
            currentTimestamp: block.timestamp
        });
        return info;
    }
    function rebase(address _stakedTokenAddress) public whenNotPaused onlyRole(REBASER_ROLE) returns (uint256 _totalSupply) {
        ReBaseInfo memory info = rebaseInfo(_stakedTokenAddress);
        require(info.restakedTokenTotalSupply != info.stakedTokenBackedSupply, "AstridProtocol: restakedTokenTotalSupply = stakedTokenBackedSupply");
        address _restakedTokenAddress = stakedTokens[_stakedTokenAddress].restakedTokenAddress;
        uint256 _supplyDelta;
        bool _isRebasePositive;
        if (info.restakedTokenTotalSupply < info.stakedTokenBackedSupply) {
            _supplyDelta = info.stakedTokenBackedSupply - info.restakedTokenTotalSupply;
            _isRebasePositive = true;
        } else {
            _supplyDelta = info.restakedTokenTotalSupply - info.stakedTokenBackedSupply;
            _isRebasePositive = false;
        }
        _totalSupply = IRestakedETH(_restakedTokenAddress).rebase(info.currentTimestamp, _isRebasePositive, _supplyDelta);
        emit RebasePerformed(_restakedTokenAddress, info.currentTimestamp, _totalSupply, _isRebasePositive, _supplyDelta);
    }
    function depositsLength(address staker) public view returns (uint256) {
        return deposits[staker].length;
    }
    function withdrawalRequestsLength() public view returns (uint256) {
        return withdrawalRequests.length;
    }
    function withdrawalRequestsByUserLength(address withdrawer) public view returns (uint256) {
        return withdrawalRequestsByUser[withdrawer].length;
    }
    function deposit(address _stakedTokenAddress, uint256 amount) public nonReentrant whenNotPaused {
        StakedTokenMapping memory stakedTokenMapping = stakedTokens[_stakedTokenAddress];
        require(stakedTokenMapping.whitelisted, "AstridProtocol: Staked token not whitelisted");
        require(IERC20(_stakedTokenAddress).balanceOf(msg.sender) >= amount, "AstridProtocol: Insufficient balance of staked token");
        require(IERC20(_stakedTokenAddress).allowance(msg.sender, address(this)) >= amount, "AstridProtocol: Insufficient allowance of staked token");
        bool amountSent = Utils.payMe(msg.sender, amount, _stakedTokenAddress);
        require(amountSent, "AstridProtocol: Failed to send staked token");
        IRestakedETH(stakedTokenMapping.restakedTokenAddress).mint(msg.sender, amount);
        deposits[msg.sender].push(DepositInfo({
            staker: msg.sender,
            stakedTokenAddress: _stakedTokenAddress,
            amount: amount,
            stakedAt: block.timestamp
        }));
        emit DepositPerformed(msg.sender, _stakedTokenAddress, amount);
    }
    function withdraw(address _restakedTokenAddress, uint256 amount) public nonReentrant whenNotPaused {
        address _stakedTokenAddress = IRestakedETH(_restakedTokenAddress).stakedTokenAddress();
        StakedTokenMapping memory stakedTokenMapping = stakedTokens[_stakedTokenAddress];
        require(stakedTokenMapping.whitelisted, "AstridProtocol: Staked token not whitelisted");
        require(IERC20(_restakedTokenAddress).balanceOf(msg.sender) >= amount, "AstridProtocol: Insufficient balance of restaked token");
        require(IERC20(_restakedTokenAddress).allowance(msg.sender, address(this)) >= amount, "AstridProtocol: Insufficient allowance of restaked token");
        uint256 sharesBefore = IRestakedETH(_restakedTokenAddress).scaledBalanceOf(address(this));
        bool amountSent = Utils.payMe(msg.sender, amount, _restakedTokenAddress);
        require(amountSent, "AstridProtocol: Failed to send restaked token");
        uint256 sharesAfter = IRestakedETH(_restakedTokenAddress).scaledBalanceOf(address(this));
        uint256 shares = sharesAfter.sub(sharesBefore); 
        WithdrawalRequest memory request = WithdrawalRequest({
            withdrawer: msg.sender,
            restakedTokenAddress: _restakedTokenAddress,
            amount: amount,
            requestedRestakedTokenShares: shares,
            claimableStakedTokenAmount: 0, 
            status: WithdrawalStatus.REQUESTED,
            withdrawalStartBlock: uint32(block.number),
            withdrawRequestedAt: block.timestamp,
            withdrawProcessedAt: 0,
            withdrawClaimedAt: 0,
            withdrawalRequestsIndex: withdrawalRequests.length,
            withdrawalRequestsByUserIndex: withdrawalRequestsByUser[msg.sender].length
        });
        totalWithdrawalRequests[_restakedTokenAddress] += shares;
        withdrawalRequests.push(request);
        withdrawalRequestsByUser[msg.sender].push(request);
        emit WithdrawalRequested(msg.sender, _restakedTokenAddress, amount, shares);
        if (processWithdrawalsOnWithdraw) {
            _processWithdrawals();
        }
    }
    function processWithdrawals() public nonReentrant whenNotPaused {
        _processWithdrawals();
    }
    function _processWithdrawals() internal whenNotPaused {
        uint256 _withdrawalRequestsLength = withdrawalRequests.length;
        while(withdrawalProcessingCurrentIndex < _withdrawalRequestsLength) {
            WithdrawalRequest memory request = withdrawalRequests[withdrawalProcessingCurrentIndex];
            require(request.status == WithdrawalStatus.REQUESTED, "AstridProtocol: Withdrawal status mismatch");
            address _restakedTokenAddress = request.restakedTokenAddress;
            address _stakedTokenAddress = IRestakedETH(_restakedTokenAddress).stakedTokenAddress();
            uint256 requestedAmount = IRestakedETH(_restakedTokenAddress).scaledBalanceToBalance(request.requestedRestakedTokenShares);
            if (requestedAmount > IERC20(_stakedTokenAddress).balanceOf(address(this)) - totalClaimableWithdrawals[_stakedTokenAddress]) {
                break;
            }
            totalWithdrawalRequests[_restakedTokenAddress] -= request.requestedRestakedTokenShares;
            IRestakedETH(_restakedTokenAddress).burn(address(this), requestedAmount);
            totalClaimableWithdrawals[_stakedTokenAddress] += requestedAmount;
            withdrawalRequests[withdrawalProcessingCurrentIndex].claimableStakedTokenAmount = requestedAmount;
            withdrawalRequests[withdrawalProcessingCurrentIndex].status = WithdrawalStatus.PROCESSED;
            withdrawalRequests[withdrawalProcessingCurrentIndex].withdrawProcessedAt = block.timestamp;
            uint256 withdrawerIndex = request.withdrawalRequestsByUserIndex;
            withdrawalRequestsByUser[request.withdrawer][withdrawerIndex].claimableStakedTokenAmount = requestedAmount;
            withdrawalRequestsByUser[request.withdrawer][withdrawerIndex].status = WithdrawalStatus.PROCESSED;
            withdrawalRequestsByUser[request.withdrawer][withdrawerIndex].withdrawProcessedAt = block.timestamp;
            emit WithdrawalProcessed(withdrawalProcessingCurrentIndex);
            withdrawalProcessingCurrentIndex += 1;
        }
    }
    function claim(uint256 withdrawerIndex) public nonReentrant whenNotPaused {
        WithdrawalRequest memory request = withdrawalRequestsByUser[msg.sender][withdrawerIndex];
        require(request.status == WithdrawalStatus.PROCESSED, "AstridProtocol: Withdrawal status mismatch");
        require(request.withdrawer == msg.sender, "AstridProtocol: Invalid withdrawer");
        address _stakedTokenAddress = IRestakedETH(request.restakedTokenAddress).stakedTokenAddress();
        withdrawalRequests[request.withdrawalRequestsIndex].status = WithdrawalStatus.CLAIMED;
        withdrawalRequests[request.withdrawalRequestsIndex].withdrawClaimedAt = block.timestamp;
        withdrawalRequestsByUser[msg.sender][withdrawerIndex].status = WithdrawalStatus.CLAIMED;
        withdrawalRequestsByUser[msg.sender][withdrawerIndex].withdrawClaimedAt = block.timestamp;
        totalClaimableWithdrawals[_stakedTokenAddress] -= request.claimableStakedTokenAmount;
        bool sent = Utils.payDirect(msg.sender, request.claimableStakedTokenAmount, _stakedTokenAddress);
        require(sent, "AstridProtocol: Failed to send staked token");
        emit WithdrawalClaimed(msg.sender, request.withdrawalRequestsIndex);
    }
    function restakesLength(address staker) public view returns (uint256) {
        return restakes[staker].length + deposits[staker].length;
    }
    function withdrawalsLength(address withdrawer) public view returns (uint256) {
        return withdrawals[withdrawer].length;
    }
    event WithdrawCompleted(address indexed to, uint96 withdrawalIndex);
    function completeQueuedWithdrawal(uint96 withdrawalIndex, uint256 middlewareTimesIndex) public nonReentrant whenNotPaused {
        WithdrawalInfo memory withdrawalInfo = withdrawals[msg.sender][withdrawalIndex];
        require(withdrawalInfo.withdrawCompletedAt == 0, "AstridProtocol: Withdrawal already completed");
        require(withdrawalInfo.withdrawer == msg.sender, "AstridProtocol: Invalid withdrawer");
        address _stakedTokenAddress = IRestakedETH(withdrawalInfo.restakedTokenAddress).stakedTokenAddress();
        IStrategy[] memory strategiesArr = new IStrategy[](1);
        strategiesArr[0] = IStrategy(stakedTokens[_stakedTokenAddress].eigenLayerStrategyAddress);
        uint256[] memory sharesArr = new uint256[](1);
        sharesArr[0] = withdrawalInfo.shares;
        address operator = IDelegationManager(IStrategyManager(eigenLayerStrategyManagerAddress).delegation()).delegatedTo(address(this));
        IStrategyManager.QueuedWithdrawal memory queuedWithdrawal = IStrategyManager.QueuedWithdrawal({
            strategies: strategiesArr,
            shares: sharesArr,
            depositor: address(this),
            withdrawerAndNonce: IStrategyManager.WithdrawerAndNonce({
                withdrawer: address(this),
                nonce: uint96(withdrawalInfo.nonce)
            }),
            withdrawalStartBlock: withdrawalInfo.withdrawalStartBlock,
            delegatedAddress: operator
        });
        IERC20[] memory tokens = new IERC20[](1);
        tokens[0] = IERC20(_stakedTokenAddress);
        uint256 balanceBefore = IERC20(_stakedTokenAddress).balanceOf(address(this));
        IStrategyManager(eigenLayerStrategyManagerAddress).completeQueuedWithdrawal(
            queuedWithdrawal,
            tokens,
            middlewareTimesIndex,
            true
        );
        uint256 balanceAfter = IERC20(_stakedTokenAddress).balanceOf(address(this));
        withdrawals[msg.sender][withdrawalIndex].pending = false;
        withdrawals[msg.sender][withdrawalIndex].withdrawCompletedAt = block.timestamp;
        bool sent = Utils.payDirect(msg.sender, balanceAfter.sub(balanceBefore), _stakedTokenAddress);
        require(sent, "AstridProtocol: Failed to send staked token");
        emit WithdrawCompleted(msg.sender, withdrawalIndex);
    }
}