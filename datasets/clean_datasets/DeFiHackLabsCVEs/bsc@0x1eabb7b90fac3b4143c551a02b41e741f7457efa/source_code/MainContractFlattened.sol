pragma solidity 0.8.20;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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
    error AddressInsufficientBalance(address account);
    error AddressEmptyCode(address target);
    error FailedInnerCall();
    function sendValue(address payable recipient, uint256 amount) internal {
        if (address(this).balance < amount) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, ) = recipient.call{value: amount}("");
        if (!success) {
            revert FailedInnerCall();
        }
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        if (address(this).balance < value) {
            revert AddressInsufficientBalance(address(this));
        }
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata
    ) internal view returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            if (returndata.length == 0 && target.code.length == 0) {
                revert AddressEmptyCode(target);
            }
            return returndata;
        }
    }
    function verifyCallResult(bool success, bytes memory returndata) internal pure returns (bytes memory) {
        if (!success) {
            _revert(returndata);
        } else {
            return returndata;
        }
    }
    function _revert(bytes memory returndata) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert FailedInnerCall();
        }
    }
}
library SafeERC20 {
    using Address for address;
    error SafeERC20FailedOperation(address token);
    error SafeERC20FailedDecreaseAllowance(address spender, uint256 currentAllowance, uint256 requestedDecrease);
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transfer, (to, value)));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeCall(token.transferFrom, (from, to, value)));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        forceApprove(token, spender, oldAllowance + value);
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 requestedDecrease) internal {
        unchecked {
            uint256 currentAllowance = token.allowance(address(this), spender);
            if (currentAllowance < requestedDecrease) {
                revert SafeERC20FailedDecreaseAllowance(spender, currentAllowance, requestedDecrease);
            }
            forceApprove(token, spender, currentAllowance - requestedDecrease);
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeCall(token.approve, (spender, value));
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeCall(token.approve, (spender, 0)));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data);
        if (returndata.length != 0 && !abi.decode(returndata, (bool))) {
            revert SafeERC20FailedOperation(address(token));
        }
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return success && (returndata.length == 0 || abi.decode(returndata, (bool))) && address(token).code.length > 0;
    }
}
library Math {
    error MathOverflowedMulDiv();
    enum Rounding {
        Floor, 
        Ceil, 
        Trunc, 
        Expand 
    }
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
        if (b == 0) {
            return a / b;
        }
        return a == 0 ? 0 : (a - 1) / b + 1;
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0 = x * y; 
            uint256 prod1; 
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            if (denominator <= prod1) {
                revert MathOverflowedMulDiv();
            }
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (0 - denominator);
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
        if (unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0) {
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
            return result + (unsignedRoundsUp(rounding) && result * result < a ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 1 << result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 10 ** result < value ? 1 : 0);
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
            return result + (unsignedRoundsUp(rounding) && 1 << (result << 3) < value ? 1 : 0);
        }
    }
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
interface IApolloX {
  function mintAlp(
    address tokenIn,
    uint256 amount,
    uint256 minAlp,
    bool stake
  ) external;
  function unStake(uint256 _amount) external;
  function burnAlp(
    address tokenOut,
    uint256 alpAmount,
    uint256 minOut,
    address receiver
  ) external;
  function stakeOf(address account) external view returns (uint256);
  function pendingApx(address _account) external view returns (uint256);
  function claimAllReward() external;
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
interface IERC20Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }
    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    uint256[45] private __gap;
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
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;
    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
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
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
interface IERC4626Upgradeable is IERC20Upgradeable, IERC20MetadataUpgradeable {
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    function asset() external view returns (address assetTokenAddress);
    function totalAssets() external view returns (uint256 totalManagedAssets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);
    function previewDeposit(uint256 assets) external view returns (uint256 shares);
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function maxMint(address receiver) external view returns (uint256 maxShares);
    function previewMint(uint256 shares) external view returns (uint256 assets);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) external returns (uint256 shares);
    function maxRedeem(address owner) external view returns (uint256 maxShares);
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) external returns (uint256 assets);
}
library MathUpgradeable {
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
abstract contract ERC4626Upgradeable is Initializable, ERC20Upgradeable, IERC4626Upgradeable {
    using MathUpgradeable for uint256;
    IERC20MetadataUpgradeable private _asset;
    function __ERC4626_init(IERC20MetadataUpgradeable asset_) internal onlyInitializing {
        __ERC4626_init_unchained(asset_);
    }
    function __ERC4626_init_unchained(IERC20MetadataUpgradeable asset_) internal onlyInitializing {
        _asset = asset_;
    }
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }
    function totalAssets() public view virtual override returns (uint256) {
        return _asset.balanceOf(address(this));
    }
    function convertToShares(uint256 assets) public view virtual override returns (uint256 shares) {
        return _convertToShares(assets, MathUpgradeable.Rounding.Down);
    }
    function convertToAssets(uint256 shares) public view virtual override returns (uint256 assets) {
        return _convertToAssets(shares, MathUpgradeable.Rounding.Down);
    }
    function maxDeposit(address) public view virtual override returns (uint256) {
        return _isVaultCollateralized() ? type(uint256).max : 0;
    }
    function maxMint(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }
    function maxWithdraw(address owner) public view virtual override returns (uint256) {
        return _convertToAssets(balanceOf(owner), MathUpgradeable.Rounding.Down);
    }
    function maxRedeem(address owner) public view virtual override returns (uint256) {
        return balanceOf(owner);
    }
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, MathUpgradeable.Rounding.Down);
    }
    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, MathUpgradeable.Rounding.Up);
    }
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, MathUpgradeable.Rounding.Up);
    }
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, MathUpgradeable.Rounding.Down);
    }
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256) {
        require(assets <= maxDeposit(receiver), "ERC4626: deposit more than max");
        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        return shares;
    }
    function mint(uint256 shares, address receiver) public virtual override returns (uint256) {
        require(shares <= maxMint(receiver), "ERC4626: mint more than max");
        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        return assets;
    }
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual override returns (uint256) {
        require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");
        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return shares;
    }
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual override returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");
        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return assets;
    }
    function _convertToShares(uint256 assets, MathUpgradeable.Rounding rounding) internal view virtual returns (uint256 shares) {
        uint256 supply = totalSupply();
        return
            (assets == 0 || supply == 0)
                ? assets.mulDiv(10**decimals(), 10**_asset.decimals(), rounding)
                : assets.mulDiv(supply, totalAssets(), rounding);
    }
    function _convertToAssets(uint256 shares, MathUpgradeable.Rounding rounding) internal view virtual returns (uint256 assets) {
        uint256 supply = totalSupply();
        return
            (supply == 0)
                ? shares.mulDiv(10**_asset.decimals(), 10**decimals(), rounding)
                : shares.mulDiv(totalAssets(), supply, rounding);
    }
    function _deposit(
        address caller,
        address receiver,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        SafeERC20Upgradeable.safeTransferFrom(_asset, caller, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(caller, receiver, assets, shares);
    }
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }
        _burn(owner, shares);
        SafeERC20Upgradeable.safeTransfer(_asset, receiver, assets);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }
    function _isVaultCollateralized() private view returns (bool) {
        return totalAssets() > 0 || totalSupply() == 0;
    }
    uint256[49] private __gap;
}
interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns (bytes32);
}
interface IBeaconUpgradeable {
    function implementation() external view returns (address);
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
}
abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }
    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    event Upgraded(address indexed implementation);
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
    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }
    function _upgradeToAndCallUUPS(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
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
    event AdminChanged(address previousAdmin, address newAdmin);
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
    event BeaconUpgraded(address indexed beacon);
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
    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }
    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
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
    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}
abstract contract ReentrancyGuardUpgradeable is Initializable {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }
    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}
pragma abicoder v2;
struct LockedBalance {
  uint256 amount;
  uint256 unlockTime;
  uint256 multiplier;
  uint256 duration;
}
struct EarnedBalance {
  uint256 amount;
  uint256 unlockTime;
  uint256 penalty;
}
struct Reward {
  uint256 periodFinish;
  uint256 rewardPerSecond;
  uint256 lastUpdateTime;
  uint256 rewardPerTokenStored;
  uint256 balance;
}
struct Balances {
  uint256 total; 
  uint256 unlocked; 
  uint256 locked; 
  uint256 lockedWithMultiplier; 
  uint256 earned; 
}
interface IFeeDistribution {
  struct RewardData {
    address token;
    uint256 amount;
  }
  function addReward(address rewardsToken) external;
  function lockedBalances(
    address user
  )
    external
    view
    returns (uint256, uint256, uint256, uint256, LockedBalance[] memory);
}
struct ApolloXDepositData {
  address tokenIn;
  uint256 minALP;
}
struct DepositData {
  uint256 amount;
  address receiver;
  address tokenIn;
  address tokenInAfterSwap;
  bytes aggregatorData;
  ApolloXDepositData apolloXDepositData;
}
struct ApolloXRedeemData {
  address alpTokenOut;
  uint256 minOut;
  address tokenOut;
  bytes aggregatorData;
}
struct RedeemData {
  uint256 amount;
  address receiver;
  ApolloXRedeemData apolloXRedeemData;
}
abstract contract AbstractVaultV2 is
  Initializable,
  UUPSUpgradeable,
  ERC4626Upgradeable,
  OwnableUpgradeable,
  PausableUpgradeable,
  ReentrancyGuardUpgradeable
{
  using SafeERC20 for IERC20;
  error ERC4626ExceededMaxRedeem(address owner, uint256 shares, uint256 max);
  address public oneInchAggregatorAddress;
  constructor() {
    _disableInitializers();
  }
  function _initialize(
    IERC20MetadataUpgradeable asset_,
    string memory name_,
    string memory symbol_
  ) public onlyInitializing {
    ERC4626Upgradeable.__ERC4626_init(asset_);
    ERC20Upgradeable.__ERC20_init(name_, symbol_);
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    UUPSUpgradeable.__UUPSUpgradeable_init();
    PausableUpgradeable.__Pausable_init();
  }
  function _authorizeUpgrade(address) internal override onlyOwner {}
  function updateOneInchAggregatorAddress(
    address oneInchAggregatorAddress_
  ) external onlyOwner {
    require(oneInchAggregatorAddress_ != address(0), "Address cannot be zero");
    oneInchAggregatorAddress = oneInchAggregatorAddress_;
  }
  function totalLockedAssets() public view virtual returns (uint256);
  function totalStakedButWithoutLockedAssets()
    public
    view
    virtual
    returns (uint256);
  function totalUnstakedAssets() public view virtual returns (uint256);
  function totalAssets() public view override returns (uint256) {
    return
      totalLockedAssets() +
      totalStakedButWithoutLockedAssets() +
      totalUnstakedAssets();
  }
  function getClaimableRewards()
    public
    view
    virtual
    returns (IFeeDistribution.RewardData[] memory claimableRewards);
  function deposit(
    uint256 amount,
    DepositData calldata depositData
  ) public virtual nonReentrant whenNotPaused returns (uint256) {
    _prepareForDeposit(amount, depositData.tokenInAfterSwap);
    uint256 shares = _zapIn(amount, depositData);
    return _mintShares(shares, amount);
  }
  function _prepareForDeposit(
    uint256 amount,
    address tokenIn
  ) internal virtual {
    require(amount <= maxDeposit(msg.sender), "ERC4626: deposit more than max");
    SafeERC20.safeTransferFrom(
      IERC20(tokenIn),
      msg.sender,
      address(this),
      amount
    );
  }
  function _zapIn(
    uint256 amount,
    DepositData calldata depositData
  ) internal virtual returns (uint256) {
    revert("_zapIn not implemented");
  }
  function _mintShares(
    uint256 shares,
    uint256 amount
  ) internal virtual returns (uint256) {
    _mint(msg.sender, shares);
    emit Deposit(_msgSender(), msg.sender, amount, shares);
    return shares;
  }
  function redeem(
    uint256 shares,
    RedeemData calldata redeemData
  )
    public
    nonReentrant
    whenNotPaused
    returns (uint256, address, address, bytes calldata)
  {
    uint256 maxShares = maxRedeem(msg.sender);
    if (shares > maxShares) {
      revert ERC4626ExceededMaxRedeem(msg.sender, shares, maxShares);
    }
    _burn(msg.sender, shares);
    return _redeemFrom3rdPartyProtocol(shares, redeemData);
  }
  function claim() public virtual nonReentrant {
    revert("Not implemented");
  }
  function claimRewardsFromVaultToPortfolioVault(
    IFeeDistribution.RewardData[] memory claimableRewards
  ) public virtual {
    for (uint256 i = 0; i < claimableRewards.length; i++) {
      SafeERC20.safeTransfer(
        IERC20(claimableRewards[i].token),
        msg.sender,
        claimableRewards[i].amount
      );
    }
  }
  function _redeemFrom3rdPartyProtocol(
    uint256 shares,
    RedeemData calldata redeemData
  ) internal virtual returns (uint256, address, address, bytes calldata) {
    revert("not implemented");
  }
  function rescueFunds(
    address tokenAddress,
    uint256 amount
  ) external onlyOwner {
    require(tokenAddress != address(0), "Invalid token address");
    SafeERC20.safeTransfer(IERC20(tokenAddress), owner(), amount);
  }
  function rescueETH(uint256 amount) external onlyOwner {
    payable(owner()).transfer(amount);
  }
  function rescueFundsWithHexData(
    address payable destination,
    uint256 amount,
    bytes memory hexData
  ) external onlyOwner {
    require(destination != address(0), "Invalid destination address");
    require(address(this).balance >= amount, "Insufficient balance");
    (bool success, ) = destination.call(hexData);
    require(success, "Fund transfer failed");
  }
}
contract ApolloXBscVault is AbstractVaultV2 {
  using SafeERC20 for IERC20;
  IApolloX public apolloX;
  IERC20 public ALP;
  IERC20 public constant APX =
    IERC20(0x78F5d389F5CDCcFc41594aBaB4B0Ed02F31398b3);
  uint256 public ratioAfterPerformanceFee;
  uint256 public denominator;
  function initialize(
    IERC20MetadataUpgradeable asset_,
    string memory name_,
    string memory symbol_,
    uint256 ratioAfterPerformanceFee_,
    uint256 denominator_
  ) public initializer {
    AbstractVaultV2._initialize(asset_, name_, symbol_);
    apolloX = IApolloX(0x1b6F2d3844C6ae7D56ceb3C3643b9060ba28FEb0);
    ALP = IERC20(0x4E47057f45adF24ba41375a175dA0357cB3480E5);
    ratioAfterPerformanceFee = ratioAfterPerformanceFee_;
    denominator = denominator_;
  }
  function updateApolloXAddr(address newAddr) public onlyOwner {
    require(newAddr != address(0), "Address cannot be zero");
    apolloX = IApolloX(newAddr);
  }
  function updateAlpAddr(address newAddr) public onlyOwner {
    require(newAddr != address(0), "Address cannot be zero");
    ALP = IERC20(newAddr);
  }
  function updatePerformanceFeeMetaData(
    uint256 ratioAfterPerformanceFee_,
    uint256 denominator_
  ) public onlyOwner {
    require(denominator_ != 0, "denominator cannot be zero");
    require(
      ratioAfterPerformanceFee_ <= denominator_,
      "ratioAfterPerformanceFee_ cannot be greater than denominator_"
    );
    ratioAfterPerformanceFee = ratioAfterPerformanceFee_;
    denominator = denominator_;
  }
  function totalLockedAssets() public pure override returns (uint256) {
    return 0;
  }
  function totalStakedButWithoutLockedAssets()
    public
    view
    override
    returns (uint256)
  {
    return apolloX.stakeOf(address(this));
  }
  function totalUnstakedAssets() public view override returns (uint256) {
    return IERC20(asset()).balanceOf(address(this));
  }
  function claim() public override nonReentrant whenNotPaused {
    IFeeDistribution.RewardData[]
      memory claimableRewards = getClaimableRewards();
    if (claimableRewards.length != 0) {
      apolloX.claimAllReward();
      super.claimRewardsFromVaultToPortfolioVault(claimableRewards);
    }
  }
  function getClaimableRewards()
    public
    view
    override
    returns (IFeeDistribution.RewardData[] memory rewards)
  {
    uint256 portfolioSharesInThisVault = balanceOf(msg.sender);
    uint256 totalVaultShares = totalSupply();
    if (portfolioSharesInThisVault == 0 || totalVaultShares == 0) {
      return new IFeeDistribution.RewardData[](0);
    }
    rewards = new IFeeDistribution.RewardData[](1);
    uint256 claimableRewardsBelongsToThisPortfolio = Math.mulDiv(
      apolloX.pendingApx(address(this)),
      portfolioSharesInThisVault,
      totalVaultShares
    );
    rewards[0] = IFeeDistribution.RewardData({
      token: address(APX),
      amount: _calClaimableAmountAfterPerformanceFee(
        claimableRewardsBelongsToThisPortfolio
      )
    });
    return rewards;
  }
  function getPerformanceFeeRateMetaData()
    public
    view
    returns (uint256, uint256)
  {
    return (ratioAfterPerformanceFee, denominator);
  }
  function _zapIn(
    uint256 amount,
    DepositData calldata depositData
  ) internal override returns (uint256) {
    IERC20 tokenInERC20 = IERC20(depositData.apolloXDepositData.tokenIn);
    SafeERC20.forceApprove(tokenInERC20, address(apolloX), amount);
    SafeERC20.forceApprove(ALP, address(apolloX), amount);
    uint256 originalStakeOf = apolloX.stakeOf(address(this));
    apolloX.mintAlp(
      address(tokenInERC20),
      amount,
      depositData.apolloXDepositData.minALP,
      true
    );
    uint256 currentStakeOf = apolloX.stakeOf(address(this));
    uint256 mintedALPAmount = currentStakeOf - originalStakeOf;
    return mintedALPAmount;
  }
  function _calClaimableAmountAfterPerformanceFee(
    uint256 claimableRewardsBelongsToThisPortfolio
  ) internal view returns (uint256) {
    (
      uint256 ratioAfterPerformanceFee,
      uint256 denominator
    ) = getPerformanceFeeRateMetaData();
    return
      Math.mulDiv(
        claimableRewardsBelongsToThisPortfolio,
        ratioAfterPerformanceFee,
        denominator
      );
  }
  function _redeemFrom3rdPartyProtocol(
    uint256 shares,
    RedeemData calldata redeemData
  ) internal override returns (uint256, address, address, bytes calldata) {
    apolloX.unStake(shares);
    SafeERC20.forceApprove(ALP, address(apolloX), shares);
    uint256 originalTokenOutBalance = IERC20(
      redeemData.apolloXRedeemData.alpTokenOut
    ).balanceOf(address(this));
    apolloX.burnAlp(
      redeemData.apolloXRedeemData.alpTokenOut,
      shares,
      redeemData.apolloXRedeemData.minOut,
      address(this)
    );
    uint256 currentTokenOutBalance = IERC20(
      redeemData.apolloXRedeemData.alpTokenOut
    ).balanceOf(address(this));
    uint256 redeemAmount = currentTokenOutBalance - originalTokenOutBalance;
    SafeERC20.safeTransfer(
      IERC20(redeemData.apolloXRedeemData.alpTokenOut),
      msg.sender,
      redeemAmount
    );
    return (
      redeemAmount,
      redeemData.apolloXRedeemData.alpTokenOut,
      redeemData.apolloXRedeemData.tokenOut,
      redeemData.apolloXRedeemData.aggregatorData
    );
  }
}
struct SwapData {
  SwapType swapType;
  address extRouter;
  bytes extCalldata;
  bool needScale;
}
enum SwapType {
  NONE,
  KYBERSWAP,
  ONE_INCH,
  ETH_WETH
}
interface IPSwapAggregator {
  function swap(
    address tokenIn,
    uint256 amountIn,
    SwapData calldata swapData
  ) external payable;
}
interface IPendleRouter {
  struct ApproxParams {
    uint256 guessMin;
    uint256 guessMax;
    uint256 guessOffchain; 
    uint256 maxIteration; 
    uint256 eps; 
  }
  struct TokenInput {
    address tokenIn;
    uint256 netTokenIn;
    address tokenMintSy;
    address bulk;
    address pendleSwap;
    SwapData swapData;
  }
  struct TokenOutput {
    address tokenOut;
    uint256 minTokenOut;
    address tokenRedeemSy;
    address bulk;
    address pendleSwap;
    SwapData swapData;
  }
  function addLiquiditySingleToken(
    address receiver,
    address market,
    uint256 minLpOut,
    ApproxParams calldata guessPtReceivedFromSy,
    TokenInput calldata input
  ) external payable returns (uint256 netLpOut, uint256 netSyFee);
  function removeLiquiditySingleToken(
    address receiver,
    address market,
    uint256 netLpToRemove,
    TokenOutput calldata output
  ) external returns (uint256 netTokenOut, uint256 netSyFee);
}
abstract contract BasePortfolioV2 is
  Initializable,
  UUPSUpgradeable,
  ERC20Upgradeable,
  OwnableUpgradeable,
  PausableUpgradeable,
  ReentrancyGuardUpgradeable
{
  using SafeERC20 for IERC20;
  event ClaimError(string errorMessage);
  struct PortfolioAllocationOfSingleCategory {
    string protocol;
    uint256 percentage;
  }
  struct ClaimableRewardOfAProtocol {
    string protocol;
    IFeeDistribution.RewardData[] claimableRewards;
  }
  struct SharesOfVault {
    string vaultName;
    uint256 assets;
  }
  struct ClaimData {
    address receiver;
    VaultClaimData apolloXClaimData;
  }
  struct VaultClaimData {
    address tokenOut;
    bytes aggregatorData;
  }
  uint256 public balanceOfProtocolFee;
  mapping(string => uint256) public portfolioAllocation;
  AbstractVaultV2[] internal vaults;
  mapping(address => mapping(string => mapping(address => uint256)))
    public userRewardsOfInvestedProtocols;
  mapping(address => mapping(string => mapping(address => uint256)))
    public userRewardPerTokenPaidPointerMapping;
  mapping(address => mapping(address => uint256))
    public pointersOfThisPortfolioForRecordingDistributedRewards;
  mapping(string => mapping(address => uint256)) public rewardPerShareZappedIn;
  uint256 public constant UNIT_OF_SHARES = 1e10;
  address public oneInchAggregatorAddress;
  constructor() {
    _disableInitializers();
  }
  function _initialize(
    string memory name_,
    string memory symbol_
  ) public onlyInitializing {
    ERC20Upgradeable.__ERC20_init(name_, symbol_);
    OwnableUpgradeable.__Ownable_init();
    ReentrancyGuardUpgradeable.__ReentrancyGuard_init();
    UUPSUpgradeable.__UUPSUpgradeable_init();
    PausableUpgradeable.__Pausable_init();
  }
  function _authorizeUpgrade(address) internal override onlyOwner {}
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);
    ClaimData memory claimData = ClaimData({
      receiver: msg.sender,
      apolloXClaimData: VaultClaimData({
        tokenOut: address(0),
        aggregatorData: new bytes(0)
      })
    });
    if (to != msg.sender && from != address(0) && to != address(0)) {
      claim(claimData, false);
      _initReceiverRewardPointer(to);
    }
  }
  function updateOneInchAggregatorAddress(
    address oneInchAggregatorAddress_
  ) external onlyOwner {
    require(oneInchAggregatorAddress_ != address(0), "Address cannot be zero");
    oneInchAggregatorAddress = oneInchAggregatorAddress_;
  }
  function getVaults() external view returns (AbstractVaultV2[] memory) {
    return vaults;
  }
  modifier updateRewards() {
    ClaimableRewardOfAProtocol[]
      memory totalClaimableRewards = getClaimableRewards(
        payable(address(this))
      );
    for (
      uint256 vaultIdx = 0;
      vaultIdx < totalClaimableRewards.length;
      vaultIdx++
    ) {
      for (
        uint256 rewardIdxOfThisVault = 0;
        rewardIdxOfThisVault <
        totalClaimableRewards[vaultIdx].claimableRewards.length;
        rewardIdxOfThisVault++
      ) {
        address addressOfReward = totalClaimableRewards[vaultIdx]
          .claimableRewards[rewardIdxOfThisVault]
          .token;
        uint256 oneOfTheUnclaimedRewardsAmountBelongsToThisPortfolio = totalClaimableRewards[
            vaultIdx
          ].claimableRewards[rewardIdxOfThisVault].amount -
            pointersOfThisPortfolioForRecordingDistributedRewards[
              address(vaults[vaultIdx])
            ][addressOfReward];
        pointersOfThisPortfolioForRecordingDistributedRewards[
          address(vaults[vaultIdx])
        ][addressOfReward] = totalClaimableRewards[vaultIdx]
          .claimableRewards[rewardIdxOfThisVault]
          .amount;
        _updateUserSpecificReward(
          totalClaimableRewards[vaultIdx].protocol,
          addressOfReward,
          oneOfTheUnclaimedRewardsAmountBelongsToThisPortfolio
        );
      }
    }
    _;
  }
  function setVaultAllocations(
    PortfolioAllocationOfSingleCategory[] calldata portfolioAllocation_
  ) external onlyOwner {
    for (uint256 i = 0; i < portfolioAllocation_.length; i++) {
      portfolioAllocation[
        portfolioAllocation_[i].protocol
      ] = portfolioAllocation_[i].percentage;
    }
  }
  function updateMappings(
    string calldata mappingName,
    address userAddress,
    string calldata vaultName,
    address rewardTokenAddress,
    uint256 amount
  ) external onlyOwner {
    bytes32 mappingNameInBytes = keccak256(bytes(mappingName));
    if (
      mappingNameInBytes == keccak256(bytes("userRewardsOfInvestedProtocols"))
    ) {
      userRewardsOfInvestedProtocols[userAddress][vaultName][
        rewardTokenAddress
      ] = amount;
    } else if (
      mappingNameInBytes ==
      keccak256(bytes("userRewardPerTokenPaidPointerMapping"))
    ) {
      userRewardPerTokenPaidPointerMapping[userAddress][vaultName][
        rewardTokenAddress
      ] = amount;
    } else {
      revert("Invalid mapping name");
    }
  }
  function getPortfolioAllocation()
    public
    view
    returns (string[] memory, uint256[] memory)
  {
    string[] memory nameOfVaults = new string[](vaults.length);
    uint256[] memory percentages = new uint256[](vaults.length);
    for (uint256 i = 0; i < vaults.length; i++) {
      string memory nameOfThisVault = vaults[i].name();
      nameOfVaults[i] = nameOfThisVault;
      percentages[i] = portfolioAllocation[nameOfThisVault];
    }
    return (nameOfVaults, percentages);
  }
  function totalAssets() public view returns (SharesOfVault[] memory) {
    SharesOfVault[] memory shareOfVaults = new SharesOfVault[](vaults.length);
    for (uint256 i = 0; i < vaults.length; i++) {
      shareOfVaults[i].vaultName = vaults[i].name();
      shareOfVaults[i].assets = vaults[i].totalAssets();
    }
    return shareOfVaults;
  }
  function deposit(
    DepositData calldata depositData
  ) public updateRewards whenNotPaused nonReentrant {
    require(depositData.amount > 0, "amount must > 0");
    (
      address addressOfTokenForDiversification,
      uint256 amountOfTokenForDiversification
    ) = _getToken(depositData);
    uint256 portfolioSharesToBeMinted = _diversify(
      depositData,
      addressOfTokenForDiversification,
      amountOfTokenForDiversification
    );
    _mintShares(depositData, portfolioSharesToBeMinted);
  }
  function redeem(
    RedeemData calldata redeemData
  ) public updateRewards whenNotPaused nonReentrant {
    require(redeemData.amount <= totalSupply(), "Shares exceed total supply");
    for (uint256 i = 0; i < vaults.length; i++) {
      uint256 vaultShares = Math.mulDiv(
        vaults[i].balanceOf(address(this)),
        redeemData.amount,
        totalSupply()
      );
      if (vaultShares > 0) {
        (
          uint256 redeemAmount,
          address tokenOutFromRedeem,
          address desiredTokenOut,
          bytes memory aggregatorData
        ) = vaults[i].redeem(vaultShares, redeemData);
        _returnRedeemInDesiredTokenToUser(
          redeemData.receiver,
          redeemAmount,
          tokenOutFromRedeem,
          desiredTokenOut,
          aggregatorData
        );
      }
    }
    _burn(msg.sender, redeemData.amount);
  }
  function claim(
    ClaimData memory claimData,
    bool useDump
  ) public whenNotPaused updateRewards {
    ClaimableRewardOfAProtocol[]
      memory totalClaimableRewards = getClaimableRewards(payable(msg.sender));
    uint256 userShares = balanceOf(msg.sender);
    if (userShares == 0) {
      return;
    }
    for (
      uint256 vaultIdx = 0;
      vaultIdx < totalClaimableRewards.length;
      vaultIdx++
    ) {
      string memory protocolNameOfThisVault = totalClaimableRewards[vaultIdx]
        .protocol;
      bytes32 bytesOfvaultName = keccak256(bytes(protocolNameOfThisVault));
      VaultClaimData memory valutClaimData;
      if (bytesOfvaultName == keccak256(bytes("ApolloX-ALP"))) {
        valutClaimData = claimData.apolloXClaimData;
      } else {
        revert(
          string(abi.encodePacked("Unknow Vault:", protocolNameOfThisVault))
        );
      }
      _claimAllTheRewardsInThisVault(
        vaultIdx,
        totalClaimableRewards,
        protocolNameOfThisVault,
        valutClaimData,
        useDump,
        claimData.receiver
      );
    }
  }
  function getClaimableRewards(
    address payable owner
  ) public view returns (ClaimableRewardOfAProtocol[] memory) {
    ClaimableRewardOfAProtocol[]
      memory totalClaimableRewards = new ClaimableRewardOfAProtocol[](
        vaults.length
      );
    for (uint256 vaultIdx = 0; vaultIdx < vaults.length; vaultIdx++) {
      string memory protocolNameOfThisVault = vaults[vaultIdx].name();
      IFeeDistribution.RewardData[] memory claimableRewardsOfThisVault = vaults[
        vaultIdx
      ].getClaimableRewards();
      IFeeDistribution.RewardData[]
        memory claimableRewardsOfThisVaultArr = new IFeeDistribution.RewardData[](
          claimableRewardsOfThisVault.length
        );
      for (
        uint256 rewardIdx = 0;
        rewardIdx < claimableRewardsOfThisVault.length;
        rewardIdx++
      ) {
        address addressOfReward = claimableRewardsOfThisVault[rewardIdx].token;
        claimableRewardsOfThisVaultArr[rewardIdx] = IFeeDistribution
          .RewardData({
            token: addressOfReward,
            amount: _getRewardAmount(
              owner,
              claimableRewardsOfThisVault[rewardIdx].amount,
              protocolNameOfThisVault,
              addressOfReward
            )
          });
      }
      totalClaimableRewards[vaultIdx] = ClaimableRewardOfAProtocol({
        protocol: protocolNameOfThisVault,
        claimableRewards: claimableRewardsOfThisVaultArr
      });
    }
    return totalClaimableRewards;
  }
  function _initReceiverRewardPointer(address to) internal {
    ClaimableRewardOfAProtocol[]
      memory totalClaimableRewards = getClaimableRewards(
        payable(address(this))
      );
    for (
      uint256 vaultIdx = 0;
      vaultIdx < totalClaimableRewards.length;
      vaultIdx++
    ) {
      for (
        uint256 rewardIdxOfThisVault = 0;
        rewardIdxOfThisVault <
        totalClaimableRewards[vaultIdx].claimableRewards.length;
        rewardIdxOfThisVault++
      ) {
        address addressOfReward = totalClaimableRewards[vaultIdx]
          .claimableRewards[rewardIdxOfThisVault]
          .token;
        string memory protocolNameOfThisVault = totalClaimableRewards[vaultIdx]
          .protocol;
        userRewardPerTokenPaidPointerMapping[to][protocolNameOfThisVault][
          addressOfReward
        ] = rewardPerShareZappedIn[protocolNameOfThisVault][addressOfReward];
      }
    }
  }
  function _getToken(
    DepositData calldata depositData
  ) internal returns (address, uint256) {
    SafeERC20.safeTransferFrom(
      IERC20(depositData.tokenIn),
      msg.sender,
      address(this),
      depositData.amount
    );
    if (depositData.aggregatorData.length > 0) {
      return (
        depositData.tokenInAfterSwap,
        _swap(IERC20(depositData.tokenIn), depositData.aggregatorData)
      );
    }
    return (depositData.tokenIn, depositData.amount);
  }
  function _diversify(
    DepositData calldata depositData,
    address addressOfTokenForDiversification,
    uint256 amountOfTokenForDiversification
  ) internal returns (uint256) {
    uint256 portfolioSharesToBeMinted = 0;
    for (uint256 idx = 0; idx < vaults.length; idx++) {
      string memory nameOfThisVault = vaults[idx].name();
      uint256 zapInAmountForThisVault = Math.mulDiv(
        amountOfTokenForDiversification,
        portfolioAllocation[nameOfThisVault],
        100
      );
      if (zapInAmountForThisVault == 0) {
        continue;
      }
      SafeERC20.forceApprove(
        IERC20(addressOfTokenForDiversification),
        address(vaults[idx]),
        zapInAmountForThisVault
      );
      portfolioSharesToBeMinted = vaults[idx].deposit(
        zapInAmountForThisVault,
        depositData
      );
      require(portfolioSharesToBeMinted > 0, "Zap-In failed");
    }
    return portfolioSharesToBeMinted;
  }
  function _mintShares(
    DepositData calldata depositData,
    uint256 portfolioSharesToBeMinted
  ) internal {
    (bool succ, uint256 shares) = Math.tryDiv(
      portfolioSharesToBeMinted,
      UNIT_OF_SHARES
    );
    require(succ, "Division failed");
    require(shares > 0, "Shares must > 0");
    _mint(depositData.receiver, shares);
  }
  function _returnRedeemInDesiredTokenToUser(
    address receiver,
    uint256 redeemAmount,
    address tokenOutFromRedeem,
    address desiredTokenOut,
    bytes memory aggregatorData
  ) internal {
    if (aggregatorData.length > 0) {
      uint256 swappedAmount = _swap(IERC20(tokenOutFromRedeem), aggregatorData);
      SafeERC20.safeTransfer(IERC20(desiredTokenOut), receiver, swappedAmount);
    } else {
      SafeERC20.safeTransfer(
        IERC20(tokenOutFromRedeem),
        receiver,
        redeemAmount
      );
    }
  }
  function _claimAllTheRewardsInThisVault(
    uint256 vaultIdx,
    ClaimableRewardOfAProtocol[] memory totalClaimableRewards,
    string memory protocolNameOfThisVault,
    VaultClaimData memory valutClaimData,
    bool useDump,
    address receiver
  ) internal nonReentrant {
    try vaults[vaultIdx].claim() {
      for (
        uint256 rewardIdxOfThisVault = 0;
        rewardIdxOfThisVault <
        totalClaimableRewards[vaultIdx].claimableRewards.length;
        rewardIdxOfThisVault++
      ) {
        address addressOfReward = totalClaimableRewards[vaultIdx]
          .claimableRewards[rewardIdxOfThisVault]
          .token;
        _returnRewardsInPreferredToken(
          addressOfReward,
          valutClaimData,
          protocolNameOfThisVault,
          useDump,
          receiver
        );
        _resetUserRewardsOfInvestedProtocols(
          address(vaults[vaultIdx]),
          protocolNameOfThisVault,
          addressOfReward
        );
      }
    } catch Error(string memory _errorMessage) {
      emit ClaimError(_errorMessage);
    }
  }
  function _returnRewardsInPreferredToken(
    address addressOfReward,
    VaultClaimData memory valutClaimData,
    string memory protocolNameOfThisVault,
    bool useDump,
    address receiver
  ) internal {
    IERC20 rewardToken = IERC20(addressOfReward);
    if (useDump == false) {
      SafeERC20.safeTransfer(
        rewardToken,
        receiver,
        userRewardsOfInvestedProtocols[msg.sender][protocolNameOfThisVault][
          addressOfReward
        ]
      );
    } else {
      uint256 swappedAmount = _swap(rewardToken, valutClaimData.aggregatorData);
      SafeERC20.safeTransfer(
        IERC20(valutClaimData.tokenOut),
        receiver,
        swappedAmount
      );
    }
  }
  function _swap(
    IERC20 tokenForSwap,
    bytes memory aggregatorData
  ) public returns (uint256) {
    SafeERC20.forceApprove(
      tokenForSwap,
      oneInchAggregatorAddress,
      tokenForSwap.balanceOf(address(this))
    );
    (bool succ, bytes memory data) = address(oneInchAggregatorAddress).call(
      aggregatorData
    );
    require(
      succ,
      "Aggregator failed to swap, please update your block_number when running hardhat test"
    );
    return abi.decode(data, (uint256));
  }
  function _resetUserRewardsOfInvestedProtocols(
    address vaultAddress,
    string memory protocolNameOfThisVault,
    address addressOfReward
  ) internal {
    pointersOfThisPortfolioForRecordingDistributedRewards[vaultAddress][
      addressOfReward
    ] = 0;
    userRewardsOfInvestedProtocols[msg.sender][protocolNameOfThisVault][
      addressOfReward
    ] = 0;
  }
  function rescueFunds(
    address tokenAddress,
    uint256 amount
  ) external onlyOwner {
    require(tokenAddress != address(0), "Invalid token address");
    SafeERC20.safeTransfer(IERC20(tokenAddress), owner(), amount);
  }
  function rescueETH(uint256 amount) external onlyOwner {
    payable(owner()).transfer(amount);
  }
  function rescueFundsWithHexData(
    address payable destination,
    uint256 amount,
    bytes memory hexData
  ) external onlyOwner {
    require(destination != address(0), "Invalid destination address");
    require(address(this).balance >= amount, "Insufficient balance");
    (bool success, ) = destination.call{value: amount}(hexData);
    require(success, "Fund transfer failed");
  }
  function _getRewardAmount(
    address payable owner,
    uint256 claimableRewardsAmountOfThisVault,
    string memory protocolNameOfThisVault,
    address addressOfReward
  ) internal view returns (uint256) {
    uint256 rewardAmount;
    if (owner == address(this)) {
      rewardAmount = claimableRewardsAmountOfThisVault;
    } else {
      rewardAmount =
        balanceOf(owner) *
        (rewardPerShareZappedIn[protocolNameOfThisVault][addressOfReward] +
          _calculateRewardPerShareDuringThisPeriod(
            claimableRewardsAmountOfThisVault
          ) -
          userRewardPerTokenPaidPointerMapping[owner][protocolNameOfThisVault][
            addressOfReward
          ]) +
        userRewardsOfInvestedProtocols[owner][protocolNameOfThisVault][
          addressOfReward
        ];
    }
    return rewardAmount;
  }
  function _updateUserSpecificReward(
    string memory protocolNameOfThisVault,
    address addressOfReward,
    uint256 oneOfTheUnclaimedRewardsAmountBelongsToThisPortfolio
  ) internal {
    if (msg.sender != address(0)) {
      rewardPerShareZappedIn[protocolNameOfThisVault][
        addressOfReward
      ] += _calculateRewardPerShareDuringThisPeriod(
        oneOfTheUnclaimedRewardsAmountBelongsToThisPortfolio
      );
      userRewardsOfInvestedProtocols[msg.sender][protocolNameOfThisVault][
        addressOfReward
      ] += _calcualteUserEarnedBeforeThisUpdateAction(
        protocolNameOfThisVault,
        addressOfReward
      );
      userRewardPerTokenPaidPointerMapping[msg.sender][protocolNameOfThisVault][
        addressOfReward
      ] = rewardPerShareZappedIn[protocolNameOfThisVault][addressOfReward];
    }
  }
  function _calcualteUserEarnedBeforeThisUpdateAction(
    string memory protocolNameOfThisVault,
    address addressOfReward
  ) internal view returns (uint256) {
    return
      (rewardPerShareZappedIn[protocolNameOfThisVault][addressOfReward] -
        userRewardPerTokenPaidPointerMapping[msg.sender][
          protocolNameOfThisVault
        ][addressOfReward]) * balanceOf(msg.sender);
  }
  function _calculateRewardPerShareDuringThisPeriod(
    uint256 oneOfTheUnclaimedRewardsAmountBelongsToThisPortfolio
  ) internal view returns (uint256) {
    if (totalSupply() == 0) {
      return 0;
    }
    (bool succ, uint256 rewardPerShare) = Math.tryDiv(
      oneOfTheUnclaimedRewardsAmountBelongsToThisPortfolio,
      totalSupply()
    );
    require(succ, "Division failed");
    return rewardPerShare;
  }
  receive() external payable {}
}
contract StableCoinVault is BasePortfolioV2 {
  using SafeERC20 for IERC20;
  function initialize(
    string memory name_,
    string memory symbol_,
    address apolloXBscVaultAddr
  ) public initializer {
    BasePortfolioV2._initialize(name_, symbol_);
    require(
      apolloXBscVaultAddr != address(0),
      "apolloXBscVaultAddr cannot be zero"
    );
    vaults = [AbstractVaultV2(ApolloXBscVault(apolloXBscVaultAddr))];
  }
}