pragma solidity 0.8.11;
interface IStrategy {
    function withdraw(uint256 _amount) external returns (uint256 loss);
    function harvest() external returns (uint256 callerFee);
    function balanceOf() external view returns (uint256);
    function vault() external view returns (address);
    function want() external view returns (address);
}
interface IERC4626 {
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
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function maxRedeem(address owner) external view returns (uint256 maxShares);
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);
}
interface IAccessControl {
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}
interface IAccessControlEnumerable is IAccessControl {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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
}
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; 
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }
    struct Bytes32Set {
        Set _inner;
    }
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;
        assembly {
            result := store
        }
        return result;
    }
    struct UintSet {
        Set _inner;
    }
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {
            result := store
        }
        return result;
    }
}
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }
    function getRoleMember(bytes32 role, uint256 index) public view virtual override returns (address) {
        return _roleMembers[role].at(index);
    }
    function getRoleMemberCount(bytes32 role) public view virtual override returns (uint256) {
        return _roleMembers[role].length();
    }
    function _grantRole(bytes32 role, address account) internal virtual override {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }
    function _revokeRole(bytes32 role, address account) internal virtual override {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
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
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
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
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
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
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
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
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20 token,
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
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library Math {
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
        return a / b + (a % b == 0 ? 0 : 1);
    }
}
library FixedPointMathLib {
    uint256 internal constant WAD = 1e18; 
    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); 
    }
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); 
    }
    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); 
    }
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); 
    }
    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            z := mul(x, y)
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }
            z := div(z, denominator)
        }
    }
    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            z := mul(x, y)
            if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                revert(0, 0)
            }
            z := mul(iszero(iszero(z)), add(div(sub(z, 1), denominator), 1))
        }
    }
    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := scalar
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := scalar
                }
                default {
                    z := x
                }
                let half := shr(1, scalar)
                for {
                    n := shr(1, n)
                } n {
                    n := shr(1, n)
                } {
                    if shr(128, x) {
                        revert(0, 0)
                    }
                    let xx := mul(x, x)
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }
                    x := div(xxRound, scalar)
                    if mod(n, 2) {
                        let zx := mul(z, x)
                        if iszero(eq(div(zx, x), z)) {
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            z := 1
            let y := x
            if iszero(lt(y, 0x100000000000000000000000000000000)) {
                y := shr(128, y) 
                z := shl(64, z) 
            }
            if iszero(lt(y, 0x10000000000000000)) {
                y := shr(64, y) 
                z := shl(32, z) 
            }
            if iszero(lt(y, 0x100000000)) {
                y := shr(32, y) 
                z := shl(16, z) 
            }
            if iszero(lt(y, 0x10000)) {
                y := shr(16, y) 
                z := shl(8, z) 
            }
            if iszero(lt(y, 0x100)) {
                y := shr(8, y) 
                z := shl(4, z) 
            }
            if iszero(lt(y, 0x10)) {
                y := shr(4, y) 
                z := shl(2, z) 
            }
            if iszero(lt(y, 0x8)) {
                z := shl(1, z)
            }
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            let zRoundDown := div(x, z)
            if lt(zRoundDown, z) {
                z := zRoundDown
            }
        }
    }
}
contract ReaperVaultV2 is IERC4626, ERC20, ReentrancyGuard, AccessControlEnumerable {
    using SafeERC20 for IERC20Metadata;
    using FixedPointMathLib for uint256;
    struct StrategyParams {
        uint256 activation; 
        uint256 allocBPS; 
        uint256 allocated; 
        uint256 gains; 
        uint256 losses; 
        uint256 lastReport; 
    }
    mapping(address => StrategyParams) public strategies;  
    address[] public withdrawalQueue; 
    uint256 public constant DEGRADATION_COEFFICIENT = 10 ** 18; 
    uint256 public constant PERCENT_DIVISOR = 10_000; 
    uint256 public tvlCap; 
    uint256 public totalAllocBPS; 
    uint256 public totalAllocated; 
    uint256 public lastReport; 
    uint256 public constructionTime; 
    bool public emergencyShutdown; 
    address public immutable asset; 
    uint256 public withdrawMaxLoss = 1; 
    uint256 public lockedProfitDegradation; 
    uint256 public  lockedProfit; 
    bytes32 public constant STRATEGIST = keccak256("STRATEGIST");
    bytes32 public constant GUARDIAN = keccak256("GUARDIAN");
    bytes32 public constant ADMIN = keccak256("ADMIN");
    bytes32[] private cascadingAccess;
    event TvlCapUpdated(uint256 newTvlCap);
    event LockedProfitDegradationUpdated(uint256 degradation);
    event StrategyReported(
        address indexed strategy,
        int256 roi,
        uint256 repayment,
        uint256 gains,
        uint256 losses,
        uint256 allocated,
        uint256 allocBPS 
    );
    event StrategyAdded(address indexed strategy, uint256 allocBPS);
    event StrategyAllocBPSUpdated(address indexed strategy, uint256 allocBPS);
    event StrategyRevoked(address indexed strategy);
    event UpdateWithdrawalQueue(address[] withdrawalQueue);
    event WithdrawMaxLossUpdated(uint256 withdrawMaxLoss);
    event EmergencyShutdown(bool active);
    event InCaseTokensGetStuckCalled(address token, uint256 amount);
    constructor(
        address _asset,
        string memory _name,
        string memory _symbol,
        uint256 _tvlCap,
        address[] memory _strategists,
        address[] memory _multisigRoles
    ) ERC20(string(_name), string(_symbol)) {
        asset = _asset;
        constructionTime = block.timestamp;
        lastReport = block.timestamp;
        tvlCap = _tvlCap;
        lockedProfitDegradation = DEGRADATION_COEFFICIENT * 46 / 10 ** 6; 
        for (uint256 i = 0; i < _strategists.length; i = _uncheckedInc(i)) {
            _grantRole(STRATEGIST, _strategists[i]);
        }
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, _multisigRoles[0]);
        _grantRole(ADMIN, _multisigRoles[1]);
        _grantRole(GUARDIAN, _multisigRoles[2]);
        cascadingAccess = [DEFAULT_ADMIN_ROLE, ADMIN, GUARDIAN, STRATEGIST];
    }
    function totalAssets() public view returns (uint256) {
        return IERC20Metadata(asset).balanceOf(address(this)) + totalAllocated;
    }
    function _freeFunds() internal view returns (uint256) {
        return totalAssets() - _calculateLockedProfit();
    }
    function _calculateLockedProfit() internal view returns (uint256) {
        uint256 lockedFundsRatio = (block.timestamp - lastReport) * lockedProfitDegradation;
        if(lockedFundsRatio < DEGRADATION_COEFFICIENT) {
            return lockedProfit - (
                lockedFundsRatio
                * lockedProfit
                / DEGRADATION_COEFFICIENT
            );
        } else {
            return 0;
        }
    }
    function convertToShares(uint256 assets) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        uint256 freeFunds = _freeFunds();
        if (freeFunds == 0 || _totalSupply == 0) return assets;
        return assets.mulDivDown(_totalSupply, freeFunds);
    }
    function convertToAssets(uint256 shares) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) return shares; 
        return shares.mulDivDown(_freeFunds(), _totalSupply);
    }
    function maxDeposit(address receiver) public view returns (uint256) {
        uint256 _totalAssets = totalAssets();
        if (_totalAssets > tvlCap) {
            return 0;
        }
        return tvlCap - _totalAssets;
    }
    function previewDeposit(uint256 assets) public view returns (uint256) {
        return convertToShares(assets);
    }
    function depositAll() external {
        deposit(IERC20Metadata(asset).balanceOf(msg.sender), msg.sender);
    }
    function deposit(uint256 assets, address receiver) public nonReentrant returns (uint256 shares) {
        require(!emergencyShutdown, "Cannot deposit during emergency shutdown");
        require(assets != 0, "please provide amount");
        uint256 _pool = totalAssets();
        require(_pool + assets <= tvlCap, "vault is full!");
        shares = previewDeposit(assets);
        IERC20Metadata(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    function maxMint(address receiver) public view virtual returns (uint256) {
        return convertToShares(maxDeposit(address(0)));
    }
    function previewMint(uint256 shares) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        if (_totalSupply == 0) return shares; 
        return shares.mulDivUp(_freeFunds(), _totalSupply);
    }
    function mint(uint256 shares, address receiver) external nonReentrant returns (uint256) {
        require(!emergencyShutdown, "Cannot mint during emergency shutdown");
        require(shares != 0, "please provide amount");
        uint256 assets = previewMint(shares);
        uint256 _pool = totalAssets();
        require(_pool + assets <= tvlCap, "vault is full!");
        if (_freeFunds() == 0) assets = shares;
        IERC20Metadata(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        return assets;
    }
    function maxWithdraw(address owner) external view returns (uint256) {
        return convertToAssets(balanceOf(owner));
    }
    function previewWithdraw(uint256 assets) public view returns (uint256) {
        uint256 _totalSupply = totalSupply();
        if (totalSupply() == 0) return 0;
        uint256 freeFunds = _freeFunds();
        if (freeFunds == 0) return assets;
        return assets.mulDivUp(_totalSupply, freeFunds);
    }
    function withdraw(uint256 assets, address receiver, address owner) external nonReentrant returns (uint256 shares) {
        require(assets != 0, "please provide amount");
        shares = previewWithdraw(assets);
        _withdraw(assets, shares, receiver, owner);
        return shares;
    }
    function _withdraw(uint256 assets, uint256 shares, address receiver, address owner) internal returns (uint256) {
        _burn(owner, shares);
        if (assets > IERC20Metadata(asset).balanceOf(address(this))) {
            uint256 totalLoss = 0;
            uint256 queueLength = withdrawalQueue.length;
            uint256 vaultBalance = 0;
            for (uint256 i = 0; i < queueLength; i = _uncheckedInc(i)) {
                vaultBalance = IERC20Metadata(asset).balanceOf(address(this));
                if (assets <= vaultBalance) {
                    break;
                }
                address stratAddr = withdrawalQueue[i];
                uint256 strategyBal = strategies[stratAddr].allocated;
                if (strategyBal == 0) {
                    continue;
                }
                uint256 remaining = assets - vaultBalance;
                uint256 loss = IStrategy(stratAddr).withdraw(Math.min(remaining, strategyBal));
                uint256 actualWithdrawn = IERC20Metadata(asset).balanceOf(address(this)) - vaultBalance;
                if (loss != 0) {
                    assets -= loss;
                    totalLoss += loss;
                    _reportLoss(stratAddr, loss);
                }
                strategies[stratAddr].allocated -= actualWithdrawn;
                totalAllocated -= actualWithdrawn;
            }
            vaultBalance = IERC20Metadata(asset).balanceOf(address(this));
            if (assets > vaultBalance) {
                assets = vaultBalance;
            }
            require(totalLoss <= ((assets + totalLoss) * withdrawMaxLoss) / PERCENT_DIVISOR, "Cannot exceed the maximum allowed withdraw slippage");
        }
        IERC20Metadata(asset).safeTransfer(receiver, assets);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        return assets;
    }
    function maxRedeem(address owner) external view returns (uint256) {
        return balanceOf(owner);
    }
    function previewRedeem(uint256 shares) public view returns (uint256) {
        return convertToAssets(shares);
    }
    function getPricePerFullShare() external view returns (uint256) {
        return convertToAssets(10 ** decimals());
    }
    function redeemAll() external {
        redeem(balanceOf(msg.sender), msg.sender, msg.sender);
    }
    function redeem(uint256 shares, address receiver, address owner) public nonReentrant returns (uint256 assets) {
        require(shares != 0, "please provide amount");
        assets = previewRedeem(shares);
        return _withdraw(assets, shares, receiver, owner);
    }
    function addStrategy(address strategy, uint256 allocBPS) external {
        _atLeastRole(DEFAULT_ADMIN_ROLE);
        require(!emergencyShutdown, "Cannot add a strategy during emergency shutdown");
        require(strategy != address(0), "Cannot add the zero address");
        require(strategies[strategy].activation == 0, "Strategy must not be added already");
        require(address(this) == IStrategy(strategy).vault(), "The strategy must use this vault");
        require(asset == IStrategy(strategy).want(), "The strategy must use the same want");
        require(allocBPS + totalAllocBPS <= PERCENT_DIVISOR, "Total allocation points are over 100%");
        strategies[strategy] = StrategyParams({
            activation: block.timestamp,
            allocBPS: allocBPS,
            allocated: 0,
            gains: 0,
            losses: 0,
            lastReport: block.timestamp
        });
        totalAllocBPS += allocBPS;
        withdrawalQueue.push(strategy);
        emit StrategyAdded(strategy, allocBPS);
    }
    function updateStrategyAllocBPS(address strategy, uint256 allocBPS) external {
        _atLeastRole(STRATEGIST);
        require(strategies[strategy].activation != 0, "Strategy must be active");
        totalAllocBPS -= strategies[strategy].allocBPS;
        strategies[strategy].allocBPS = allocBPS;
        totalAllocBPS += allocBPS;
        require(totalAllocBPS <= PERCENT_DIVISOR, "Total allocation points are over 100%");
        emit StrategyAllocBPSUpdated(strategy, allocBPS);
    }
    function revokeStrategy(address strategy) external {
        if (!(msg.sender == strategy)) {
            _atLeastRole(GUARDIAN);
        }
        if (strategies[strategy].allocBPS == 0) {
            return;
        }
        totalAllocBPS -= strategies[strategy].allocBPS;
        strategies[strategy].allocBPS = 0;
        emit StrategyRevoked(strategy);
    }
    function availableCapital() public view returns (int256) {
        address stratAddr = msg.sender;
        if (totalAllocBPS == 0 || emergencyShutdown) {
            return -int256(strategies[stratAddr].allocated);
        }
        uint256 stratMaxAllocation = (strategies[stratAddr].allocBPS * totalAssets()) / PERCENT_DIVISOR;
        uint256 stratCurrentAllocation = strategies[stratAddr].allocated;
        if (stratCurrentAllocation > stratMaxAllocation) {
            return -int256(stratCurrentAllocation - stratMaxAllocation);
        } else if (stratCurrentAllocation < stratMaxAllocation) {
            uint256 vaultMaxAllocation = (totalAllocBPS * totalAssets()) / PERCENT_DIVISOR;
            uint256 vaultCurrentAllocation = totalAllocated;
            if (vaultCurrentAllocation >= vaultMaxAllocation) {
                return 0;
            }
            uint256 available = stratMaxAllocation - stratCurrentAllocation;
            available = Math.min(available, vaultMaxAllocation - vaultCurrentAllocation);
            available = Math.min(available, IERC20Metadata(asset).balanceOf(address(this)));
            return int256(available);
        } else {
            return 0;
        }
    }
    function setWithdrawalQueue(address[] calldata _withdrawalQueue) external {
        _atLeastRole(STRATEGIST);
        uint256 queueLength = _withdrawalQueue.length;
        require(queueLength != 0, "Cannot set an empty withdrawal queue");
        delete withdrawalQueue;
        for (uint256 i = 0; i < queueLength; i = _uncheckedInc(i)) {
            address strategy = _withdrawalQueue[i];
            StrategyParams storage params = strategies[strategy];
            require(params.activation != 0, "Can only use active strategies in the withdrawal queue");
            withdrawalQueue.push(strategy);
        }
        emit UpdateWithdrawalQueue(withdrawalQueue);
    }
    function _reportLoss(address strategy, uint256 loss) internal {
        StrategyParams storage stratParams = strategies[strategy];
        uint256 allocation = stratParams.allocated;
        require(loss <= allocation, "Strategy cannot loose more than what was allocated to it");
        if (totalAllocBPS != 0) {
            uint256 bpsChange = Math.min((loss * totalAllocBPS) / totalAllocated, stratParams.allocBPS);
            if (bpsChange != 0) {
                stratParams.allocBPS -= bpsChange;
                totalAllocBPS -= bpsChange;
            }
        }
        stratParams.losses += loss;
        stratParams.allocated -= loss;
        totalAllocated -= loss;
    }
    function report(int256 roi, uint256 repayment) external returns (uint256) {
        address stratAddr = msg.sender;
        StrategyParams storage strategy = strategies[stratAddr];
        require(strategy.activation != 0, "Only active strategies can report");
        uint256 loss = 0;
        uint256 gain = 0;
        if (roi < 0) {
            loss = uint256(-roi);
            _reportLoss(stratAddr, loss);
        } else {
            gain = uint256(roi);
            strategy.gains += uint256(roi);
        }
        int256 available = availableCapital();
        uint256 debt = 0;
        uint256 credit = 0;
        if (available < 0) {
            debt = uint256(-available);
            repayment = Math.min(debt, repayment);
            if (repayment != 0) {
                strategy.allocated -= repayment;
                totalAllocated -= repayment;
                debt -= repayment;
            }
        } else {
            credit = uint256(available);
            strategy.allocated += credit;
            totalAllocated += credit;
        }
        uint256 freeWantInStrat = repayment;
        if (roi > 0) {
            freeWantInStrat += uint256(roi);
        }
        if (credit > freeWantInStrat) {
            IERC20Metadata(asset).safeTransfer(stratAddr, credit - freeWantInStrat);
        } else if (credit < freeWantInStrat) {
            IERC20Metadata(asset).safeTransferFrom(stratAddr, address(this), freeWantInStrat - credit);
        }
        uint256 lockedProfitBeforeLoss = _calculateLockedProfit() + gain;
        if (lockedProfitBeforeLoss > loss) {
            lockedProfit = lockedProfitBeforeLoss - loss;
        } else {
            lockedProfit = 0;
        }
        strategy.lastReport = block.timestamp;
        lastReport = block.timestamp;
        emit StrategyReported(
            stratAddr,
            roi,
            repayment,
            strategy.gains,
            strategy.losses,
            strategy.allocated,
            strategy.allocBPS 
        );
        if (strategy.allocBPS == 0 || emergencyShutdown) {
            return IStrategy(stratAddr).balanceOf();
        }
        return debt;
    }
    function updateWithdrawMaxLoss(uint256 _withdrawMaxLoss) external {
        _atLeastRole(STRATEGIST);
        require(_withdrawMaxLoss <= PERCENT_DIVISOR, "withdrawMaxLoss cannot be greater than 100%");
        withdrawMaxLoss = _withdrawMaxLoss;
        emit WithdrawMaxLossUpdated(withdrawMaxLoss);
    }
    function updateTvlCap(uint256 newTvlCap) public {
        _atLeastRole(ADMIN);
        tvlCap = newTvlCap;
        emit TvlCapUpdated(tvlCap);
    }
    function removeTvlCap() external {
        _atLeastRole(ADMIN);
        updateTvlCap(type(uint256).max);
    }
    function setEmergencyShutdown(bool active) external {
        if (active == true) {
            _atLeastRole(GUARDIAN);
        } else {
            _atLeastRole(ADMIN);
        }
        emergencyShutdown = active;
        emit EmergencyShutdown(emergencyShutdown);
    }
    function inCaseTokensGetStuck(address token) external {
        _atLeastRole(STRATEGIST);
        require(token != asset, "!asset");
        uint256 amount = IERC20Metadata(token).balanceOf(address(this));
        IERC20Metadata(token).safeTransfer(msg.sender, amount);
        emit InCaseTokensGetStuckCalled(token, amount);
    }
    function decimals() public view override returns (uint8) {
        return IERC20Metadata(asset).decimals();
    }
    function setLockedProfitDegradation(uint256 degradation) external {
        _atLeastRole(STRATEGIST);
        require(degradation <= DEGRADATION_COEFFICIENT, "Degradation cannot be more than 100%");
        lockedProfitDegradation = degradation;
        emit LockedProfitDegradationUpdated(degradation);
    }
    function _atLeastRole(bytes32 role) internal view {
        uint256 numRoles = cascadingAccess.length;
        uint256 specifiedRoleIndex;
        for (uint256 i = 0; i < numRoles; i = _uncheckedInc(i)) {
            if (role == cascadingAccess[i]) {
                specifiedRoleIndex = i;
                break;
            } else if (i == numRoles - 1) {
                revert();
            }
        }
        for (uint256 i = 0; i <= specifiedRoleIndex; i = _uncheckedInc(i)) {
            if (hasRole(cascadingAccess[i], msg.sender)) {
                break;
            } else if (i == specifiedRoleIndex) {
                revert();
            }
        }
    }
    function _uncheckedInc(uint256 i) internal pure returns (uint256) {
        unchecked {
            return i + 1;
        }
    }
}