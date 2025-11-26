pragma solidity 0.8.23;
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 value => uint256) _positions;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 position = set._positions[value];
        if (position != 0) {
            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;
            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[valueIndex] = lastValue;
                set._positions[lastValue] = position;
            }
            set._values.pop();
            delete set._positions[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
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
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;
        assembly {
            result := store
        }
        return result;
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
abstract contract Utils {
    function absSlippage(uint256 start, uint256 end, uint256 unit) internal pure returns (uint256) {
        uint256 diff = start > end ? start - end : end - start;
        return (diff * unit) / start;
    }
}
interface IAccessControl {
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error AccessControlBadConfirmation();
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) external view returns (bool);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address callerConfirmation) external;
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
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }
    mapping(bytes32 role => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }
    function hasRole(bytes32 role, address account) public view virtual returns (bool) {
        return _roles[role].hasRole[account];
    }
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }
    function getRoleAdmin(bytes32 role) public view virtual returns (bytes32) {
        return _roles[role].adminRole;
    }
    function grantRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) public virtual onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }
    function renounceRole(bytes32 role, address callerConfirmation) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }
        _revokeRole(role, callerConfirmation);
    }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }
    function _grantRole(bytes32 role, address account) internal virtual returns (bool) {
        if (!hasRole(role, account)) {
            _roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
    function _revokeRole(bytes32 role, address account) internal virtual returns (bool) {
        if (hasRole(role, account)) {
            _roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }
}
abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;
    mapping(bytes32 role => EnumerableSet.AddressSet) private _roleMembers;
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }
    function getRoleMember(bytes32 role, uint256 index) public view virtual returns (address) {
        return _roleMembers[role].at(index);
    }
    function getRoleMemberCount(bytes32 role) public view virtual returns (uint256) {
        return _roleMembers[role].length();
    }
    function _grantRole(bytes32 role, address account) internal virtual override returns (bool) {
        bool granted = super._grantRole(role, account);
        if (granted) {
            _roleMembers[role].add(account);
        }
        return granted;
    }
    function _revokeRole(bytes32 role, address account) internal virtual override returns (bool) {
        bool revoked = super._revokeRole(role, account);
        if (revoked) {
            _roleMembers[role].remove(account);
        }
        return revoked;
    }
}
abstract contract DefaultAccess is AccessControlEnumerable {
    bytes32 public constant MASTER = keccak256('MASTER');
    bytes32 public constant OPERATOR = keccak256('OPERATOR');
    function _initDefaultAccess(address admin_) internal {
        _grantRole(MASTER, admin_);
        _setRoleAdmin(MASTER, MASTER);
        _grantRole(OPERATOR, admin_);
        _setRoleAdmin(OPERATOR, MASTER);
    }
}
interface IDiscountPolicy {
    function computeDiscountTokensToSpend(uint256 undiscountedFeeInUsd)
    external view returns (uint256 discountTokensToSpend, uint256 discountMultiplier);
    function discountToken() external view returns (address);
    function discountTokenRate() external view returns (uint256);
    function discountRate() external view returns (uint256);
    function decimals() external view returns (uint8);
    event DiscountTokenRateUpdated(uint256 indexed newDiscountRate);
    event DiscountRateUpdated(uint256 indexed newDiscountRate);
}
interface IOracleConnector {
    function getPriceInUsd(address token) external view returns (int256, uint8, uint256);
    function getSupportedTokens() external view returns (address[] memory);
    function isTokenSupported(address token) external view returns (bool);
}
abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status;
    error ReentrancyGuardReentrantCall();
    constructor() {
        _status = NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}
interface IERC721Errors {
    error ERC721InvalidOwner(address owner);
    error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721InvalidSender(address sender);
    error ERC721InvalidReceiver(address receiver);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);
}
interface IERC1155Errors {
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155MissingApprovalForAll(address operator, address owner);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
        emit Transfer(from, to, value);
    }
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
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
interface IUniswapRouterV3 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
    function WETH9() external view returns (address);
}
interface IPancakeRouterV3 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
    function WETH9() external view returns (address);
}
contract SpotVault is Utils, DefaultAccess, ReentrancyGuard, ERC20 {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for ERC20;
    using Address for address;
    using Address for address payable;
    enum SlippageType{ SWAP, AUM, NAV }
    enum FeeType { DEPOSIT, REDEEM, ROTATION }
    struct TxParams {
        uint nav;
        uint nominalFinalAum;
        uint aum;
        address[] assets;
        uint256[] prices;
        uint256[] usdValues;
        address feeRecipient;
        address feeAsset;
        uint256 totalSupply;
    }
    struct RotationParams {
        uint256 startAum;
        uint256 srcTokenSize;
        uint256 dstTokenSize;
        bool srcTokenLessThanBefore;
        address nativeToken;
    }
    uint256 public maxAssets;
    mapping (SlippageType => uint256) public slippageTolerances;
    IOracleConnector public oracle;
    address payable public feeRecipient;
    mapping (FeeType => uint256) public feePercentages;
    address public feeAsset;
    bool public useUniswap;
    IDiscountPolicy public discountPolicy;
    mapping (uint256 => uint256) public feeRecord;
    mapping (address => uint24) public directPoolSwapFee;
    uint256 public immutable FEE_INTERVAL;
    uint256 constant MAX_FEE_PERCENTAGE = 10 * UNIT / 100;
    address public immutable ONE_INCH_AGG_ROUTER;
    address public immutable DIRECT_SWAP_ROUTER;
    address public immutable NATIVE_TOKEN;
    uint256 constant SLIPPAGE_LOWER_BOUND = 5 * UNIT / 1000; 
    uint256 constant SLIPPAGE_UPPER_BOUND = UNIT / 5; 
    bytes32 public constant ROTATOR = keccak256('ROTATOR');
    bytes32 public constant ORACLE_MGR = keccak256('ORACLE_MGR');
    uint256 public constant UNIT = 10 ** 18;
    EnumerableSet.AddressSet private portfolio;
    EnumerableSet.AddressSet private depositableAssets;
    event DepositableAssetUpdated(address indexed token, bool indexed added);
    event DiscountPolicyUpdated(address discountPolicy);
    event FeeCollected(address indexed feeCollectionToken, uint256 feeAmount);
    event FeeDetailsUpdated(uint256 depositFeePercentage, uint256 redeemFeePercentage, uint256 rotationFeePercentage,
        address feeRecipient, address feeAsset);
    event MaxAssetsUpdated(uint256 newMaxAssets);
    event OracleUpdated(address newAddress);
    event RotationFeeCollected(uint256 indexed weekNumber, uint256 usdValue);
    event SlippageToleranceUpdated(SlippageType indexed slippageType, uint256 tolerance);
    event Transaction(bool indexed isDeposit, address indexed user, address indexed txAsset, uint256 txAmount, uint256 shares);
    modifier reimburseGas() {
        uint256 initialGas = gasleft();
        _;
        payable(msg.sender).sendValue((initialGas - gasleft()) * tx.gasprice);
    }
    constructor(
        string memory name, string memory symbol, address nativeToken,
        address oneinchRouter, address directSwapRouter, uint256 feeInterval,
        address initFeeAsset
    )
    ERC20(name, symbol)
    {
        require(nativeToken != address(0), "z1");
        require(oneinchRouter != address(0), "z2");
        require(directSwapRouter != address(0), "z3");
        require(initFeeAsset != address(0), "z4");
        NATIVE_TOKEN = nativeToken;
        ONE_INCH_AGG_ROUTER = oneinchRouter; 
        DIRECT_SWAP_ROUTER = directSwapRouter;
        _initDefaultAccess(msg.sender);
        _setRoleAdmin(ROTATOR, MASTER);
        _grantRole(ROTATOR, msg.sender);
        _setRoleAdmin(ORACLE_MGR, MASTER);
        _grantRole(ORACLE_MGR, msg.sender);
        FEE_INTERVAL = feeInterval;
        feeRecipient = payable(msg.sender);
        feeAsset = initFeeAsset;
        emit FeeDetailsUpdated(0, 0, 0, msg.sender, initFeeAsset);
    }
    receive() external payable {
        require((msg.sender == ONE_INCH_AGG_ROUTER) || (msg.sender == DIRECT_SWAP_ROUTER), "n1");
    }
    function rotationSwaps(
        address[] calldata srcTokens,
        address[] calldata dstTokens,
        bytes[] calldata dataList,
        uint256[] calldata nativeAmounts
    ) external reimburseGas onlyRole(ROTATOR) nonReentrant
    {
        require(srcTokens.length == dstTokens.length, "l");
        require(srcTokens.length == dataList.length, "l");
        require(nativeAmounts.length == dataList.length, "l");
        RotationParams memory rp;
        rp.startAum = _getAum();
        rp.nativeToken = NATIVE_TOKEN;
        {
            for (uint256 i = 0; i < dataList.length; i++) {
                rp.dstTokenSize = dstTokens[i] == rp.nativeToken ? address(this).balance : ERC20(dstTokens[i]).balanceOf(address(this));
                if (srcTokens[i] != rp.nativeToken) {
                    rp.srcTokenSize = ERC20(srcTokens[i]).balanceOf(address(this));
                    ONE_INCH_AGG_ROUTER.functionCall(dataList[i]);
                    rp.srcTokenLessThanBefore = ERC20(srcTokens[i]).balanceOf(address(this)) < rp.srcTokenSize;
                } else {
                    rp.srcTokenSize = address(this).balance;
                    ONE_INCH_AGG_ROUTER.functionCallWithValue(dataList[i], nativeAmounts[i]);
                    rp.srcTokenLessThanBefore = address(this).balance < rp.srcTokenSize;
                }
                require(rp.srcTokenLessThanBefore, "b2");
                require(
                    (dstTokens[i] == rp.nativeToken ? address(this).balance : ERC20(dstTokens[i]).balanceOf(address(this))) > rp.dstTokenSize,
                    "b3"
                );
                _updatePortfolio(ERC20(srcTokens[i]));
                _updatePortfolio(ERC20(dstTokens[i]));
            }
        }
        require(portfolio.length() <= maxAssets, "m2");
        require(absSlippage(rp.startAum, _getAum(), UNIT) <= slippageTolerances[SlippageType.AUM], "s2");
    }
    function collectFee() external reimburseGas onlyRole(OPERATOR)
    {
        uint256 weekNumber = block.timestamp / FEE_INTERVAL;
        require(feeRecord[weekNumber] == 0, "wf");
        uint256 feeValueInUsd = feePercentages[FeeType.ROTATION] * _getAum() / UNIT;
        (int256 price, uint8 priceDecimals, uint256 timestamp) = oracle.getPriceInUsd(feeAsset);
        ERC20 token = ERC20(feeAsset);
        uint256 tokenSize = feeValueInUsd * (10 ** (priceDecimals + token.decimals())) / uint256(price) / UNIT;
        feeRecord[weekNumber] = feeValueInUsd;
        token.safeTransfer(feeRecipient, tokenSize);
        emit RotationFeeCollected(weekNumber, feeValueInUsd);
    }
    function approveAsset(ERC20 token, address spender, uint256 amount) external reimburseGas onlyRole(OPERATOR)
    {
        require((spender == ONE_INCH_AGG_ROUTER) || (spender == DIRECT_SWAP_ROUTER), "a1");
        token.approve(spender, amount);
    }
    function updateDiscountPolicy(address newDiscountPolicy) external onlyRole(OPERATOR) {
        require(newDiscountPolicy.code.length > 0, "dp");
        discountPolicy = IDiscountPolicy(newDiscountPolicy);
        emit DiscountPolicyUpdated(newDiscountPolicy);
    }
    function updateFeeDetails(
        uint256 newDepositFeePercentage,
        uint256 newRedeemFeePercentage,
        uint256 newRotationFeePercentage,
        address payable newFeeRecipient,
        address newFeeAsset,
        bool useUniswapFlag
    )
    external onlyRole(OPERATOR)
    {
        require(
             (newDepositFeePercentage <= MAX_FEE_PERCENTAGE) &&
                (newRedeemFeePercentage <= MAX_FEE_PERCENTAGE) &&
                (newRotationFeePercentage <= MAX_FEE_PERCENTAGE),
            "mf"
        );
        require(newFeeRecipient != address(0), "z4");
        require(newFeeAsset.code.length > 0, "fa");
        feePercentages[FeeType.DEPOSIT] = newDepositFeePercentage;
        feePercentages[FeeType.REDEEM] = newRedeemFeePercentage;
        feePercentages[FeeType.ROTATION] = newRotationFeePercentage;
        feeRecipient = newFeeRecipient;
        feeAsset = newFeeAsset;
        useUniswap = useUniswapFlag;
        emit FeeDetailsUpdated(
            newDepositFeePercentage, newRedeemFeePercentage, newRotationFeePercentage,
            newFeeRecipient, newFeeAsset);
    }
    function updateMaxAssets(uint256 newMaxAssets) external onlyRole(OPERATOR) {
        require(newMaxAssets >= 2, "m1");
        maxAssets = newMaxAssets;
        emit MaxAssetsUpdated(newMaxAssets);
    }
    function updateSlippageTolerance(SlippageType slippageType, uint256 tolerance) external onlyRole(OPERATOR) {
        require(tolerance >= SLIPPAGE_LOWER_BOUND, "sl");
        require(tolerance <= SLIPPAGE_UPPER_BOUND, "su");
        emit SlippageToleranceUpdated(slippageType, tolerance);
        slippageTolerances[slippageType] = tolerance;
    }
    function addDepositableAsset(address token, uint24 fee) external onlyRole(OPERATOR) {
        require(oracle.isTokenSupported(token), "st");
        depositableAssets.add(token);
        directPoolSwapFee[token] = fee;
        if (token != NATIVE_TOKEN) {
            ERC20(token).approve(DIRECT_SWAP_ROUTER, type(uint256).max);
        }
        emit DepositableAssetUpdated(token, true);
    }
    function removeDepositableAsset(address token) external onlyRole(OPERATOR) {
        require(depositableAssets.contains(token), "da");
        depositableAssets.remove(token);
        directPoolSwapFee[token] = 0;
        if (token != NATIVE_TOKEN) {
            ERC20(token).approve(DIRECT_SWAP_ROUTER, 0);
        }
        emit DepositableAssetUpdated(token, false);
    }
    function updateOracle(address newOracle) external onlyRole(ORACLE_MGR)
    {
        require(newOracle.code.length > 0, "oc");
        oracle = IOracleConnector(newOracle);
        emit OracleUpdated(newOracle);
    }
    function redeem(
        uint256 sharesToRedeem,
        address receivingAsset,
        uint256 minTokensToReceive,
        bytes[] calldata dataList,
        bool useDiscount
    )
    external nonReentrant
    returns (uint256 tokensToReturn)
    {
        require(depositableAssets.contains(receivingAsset), "da");
        TxParams memory dp;
        (dp.aum, dp.assets, dp.prices, dp.usdValues) = _getAllocations(0);
        dp.nav = getNav();
        dp.nominalFinalAum = dp.aum - (dp.nav * sharesToRedeem / UNIT);
        require(dataList.length == dp.assets.length, "l");
        dp.totalSupply = totalSupply();
        uint256 rcvTokenAccumulator =
        (receivingAsset == NATIVE_TOKEN ? address(this).balance : ERC20(receivingAsset).balanceOf(address(this)))
         * sharesToRedeem / dp.totalSupply;
        for (uint256 i = 0; i < dp.assets.length; i++) {
            if (dp.assets[i] == receivingAsset) {
                continue;
            }
            uint256 rcvTokenSize = receivingAsset == NATIVE_TOKEN ? address(this).balance :
                ERC20(receivingAsset).balanceOf(address(this));
            if (dp.assets[i] != NATIVE_TOKEN) {
                ONE_INCH_AGG_ROUTER.functionCall(dataList[i]);
            } else {
                uint256 sizeToSwap = address(this).balance * sharesToRedeem / dp.totalSupply;
                ONE_INCH_AGG_ROUTER.functionCallWithValue(dataList[i], sizeToSwap);
            }
            rcvTokenAccumulator += receivingAsset == NATIVE_TOKEN ? address(this).balance - rcvTokenSize :
                ERC20(receivingAsset).balanceOf(address(this)) - rcvTokenSize;
        }
        _burn(msg.sender, sharesToRedeem);
        uint256 feePortion = rcvTokenAccumulator * feePercentages[FeeType.REDEEM] / UNIT;
        dp.feeRecipient = feeRecipient;
        if (useDiscount) {
            (uint256 discountTokensToSpend, uint256 discountMultiplier) = discountPolicy.computeDiscountTokensToSpend(_getUsdValue(receivingAsset, feePortion));
            ERC20(discountPolicy.discountToken()).safeTransferFrom(msg.sender, dp.feeRecipient, discountTokensToSpend);
            feePortion = feePortion * discountMultiplier / (10 ** discountPolicy.decimals());
            emit FeeCollected(discountPolicy.discountToken(), discountTokensToSpend);
        }
        tokensToReturn = rcvTokenAccumulator - feePortion;
        require((tokensToReturn) >= minTokensToReceive, "s4");
        if (receivingAsset == NATIVE_TOKEN) {
            payable(msg.sender).sendValue(tokensToReturn);
        } else {
            ERC20(receivingAsset).safeTransfer(msg.sender, tokensToReturn);
        }
        if (feePortion > 0) {
            uint256 feeTokenAmount;
            dp.feeAsset = feeAsset;
            if (receivingAsset == dp.feeAsset) {
                feeTokenAmount = feePortion;
            }
            else {
                feeTokenAmount = _directSwapForFee(
                    feePortion,
                    0, 
                    receivingAsset,
                    dp.feeAsset
                );
            }
            ERC20(dp.feeAsset).safeTransfer(dp.feeRecipient, feeTokenAmount);
            emit FeeCollected(dp.feeAsset, feeTokenAmount);
        }
        require(absSlippage(dp.nav, getNav(), UNIT) <= slippageTolerances[SlippageType.NAV], "s3");
        _postSwapHandler(receivingAsset, dp);
        emit Transaction(false, msg.sender, receivingAsset, tokensToReturn, sharesToRedeem);
    }
    function deposit(
        ERC20 token,
        uint256 amountIn,
        uint256 minSharesToReceive,
        bytes[] calldata dataList,
        bytes calldata feeSwapData,
        bool useDiscount
    )
    external nonReentrant
    returns (uint256 sharesToMint)
    {
        require(address(token) != NATIVE_TOKEN, "n2");
        uint256 feeAmount = amountIn * feePercentages[FeeType.DEPOSIT] / UNIT;
        if (useDiscount) {
            (uint256 discountTokensToSpend, uint256 discountMultiplier) = discountPolicy.computeDiscountTokensToSpend(_getUsdValue(address(token), feeAmount));
            ERC20(discountPolicy.discountToken()).safeTransferFrom(msg.sender, feeRecipient, discountTokensToSpend);
            feeAmount = feeAmount * discountMultiplier / (10 ** discountPolicy.decimals());
            emit FeeCollected(discountPolicy.discountToken(), discountTokensToSpend);
        }
        uint256 effectiveAmount = amountIn - feeAmount;
        TxParams memory dp = _preSwapHandler(token, minSharesToReceive);
        dp.nominalFinalAum = dp.aum + _getUsdValue(address(token), effectiveAmount);
        require(dp.assets.length == dataList.length, "l");
        token.safeTransferFrom(msg.sender, address(this), amountIn);
        if (feeAmount > 0) {
            uint256 feeTokenDeltaBal;
            ERC20 feeToken = ERC20(feeAsset);
            if (feeToken != token) {
                uint256 feeTokenBeforeBal = feeToken.balanceOf(address(this));
                ONE_INCH_AGG_ROUTER.functionCall(feeSwapData);
                feeTokenDeltaBal = feeToken.balanceOf(address(this)) - feeTokenBeforeBal;
            } else {
                feeTokenDeltaBal = feeAmount;
            }
            feeToken.safeTransfer(feeRecipient, feeTokenDeltaBal);
            emit FeeCollected(address(feeToken), feeTokenDeltaBal);
        }
        for (uint256 i = 0; i < dp.assets.length; i++) {
            if (dp.assets[i] == address(token)) {
                continue;
            }
            ONE_INCH_AGG_ROUTER.functionCall(dataList[i]);
        }
        if (dp.nav != 0) {
            uint256 endAum = _postSwapHandler(address(token), dp);
            sharesToMint = (endAum * UNIT / dp.nav) - totalSupply();
            require(sharesToMint >= minSharesToReceive, "s4");
            _mint(msg.sender, sharesToMint);
            require(absSlippage(dp.nav, getNav(), UNIT) <= slippageTolerances[SlippageType.NAV], "s3");
        } else { 
            _updatePortfolio(token);
            sharesToMint = _getAum();
            _mint(msg.sender, sharesToMint);
        }
        emit Transaction(true, msg.sender, address(token), amountIn, sharesToMint);
    }
    function depositNative(
        uint256 minSharesToReceive,
        bytes[] calldata dataList,
        uint256[] calldata nativeAmounts,
        bytes calldata feeSwapData,
        bool useDiscount
    )
    payable external nonReentrant
    returns (uint256 sharesToMint)
    {
        require(depositableAssets.contains(NATIVE_TOKEN), "da");
        uint256 feeAmount = msg.value * feePercentages[FeeType.DEPOSIT] / UNIT;
        if (useDiscount) {
            (uint256 discountTokensToSpend, uint256 discountMultipler) = discountPolicy.computeDiscountTokensToSpend(_getUsdValue(NATIVE_TOKEN, feeAmount));
            ERC20(discountPolicy.discountToken()).safeTransferFrom(msg.sender, feeRecipient, discountTokensToSpend);
            feeAmount = feeAmount * discountMultipler / (10 ** discountPolicy.decimals());
            emit FeeCollected(discountPolicy.discountToken(), discountTokensToSpend);
        }
        uint256 amount = msg.value - feeAmount;
        if (feeAmount > 0) {
            ERC20 feeToken = ERC20(feeAsset);
            uint256 feeTokenBeforeBal = feeToken.balanceOf(address(this));
            ONE_INCH_AGG_ROUTER.functionCallWithValue(feeSwapData, feeAmount);
            uint256 feeTokenDeltaBal = feeToken.balanceOf(address(this)) - feeTokenBeforeBal;
            feeToken.safeTransfer(feeRecipient, feeTokenDeltaBal);
            emit FeeCollected(address(feeToken), feeTokenDeltaBal);
        }
        TxParams memory dp;
        dp.totalSupply = totalSupply();
        (dp.aum, dp.assets, dp.prices, dp.usdValues) = _getAllocations(amount);
        if (dp.aum == 0) {
            dp.nav = 0;
        } else {
            dp.nav = dp.aum * UNIT / dp.totalSupply;
        }
        dp.nominalFinalAum = dp.aum + _getUsdValue(NATIVE_TOKEN, amount);
        require(dp.assets.length == dataList.length, "l");
        for (uint256 i = 0; i < dp.assets.length; i++) {
            if (dp.assets[i] == NATIVE_TOKEN) {
                continue;
            }
            ONE_INCH_AGG_ROUTER.functionCallWithValue(dataList[i], nativeAmounts[i]);
        }
        if (dp.nav != 0) {
            uint256 endAum = _postSwapHandler(NATIVE_TOKEN, dp);
            sharesToMint = (endAum * UNIT / dp.nav) - dp.totalSupply;
            require(sharesToMint >= minSharesToReceive, "s4");
            _mint(msg.sender, sharesToMint);
            require(absSlippage(dp.nav, getNav(), UNIT) <= slippageTolerances[SlippageType.NAV], "s3");
        } else { 
            _updatePortfolio(ERC20(NATIVE_TOKEN));
            sharesToMint = _getAum();
            _mint(msg.sender, sharesToMint);
        }
        emit Transaction(true, msg.sender, NATIVE_TOKEN, msg.value, sharesToMint);
    }
    function _directSwapForFee(
        uint256 amountIn,
        uint256 amountOutMin,
        address srcToken,
        address dstToken
    ) private returns (uint256 actualAmountOut){
        if (useUniswap) {
            IUniswapRouterV3.ExactInputSingleParams memory data;
            data.amountIn = amountIn;
            data.amountOutMinimum = amountOutMin;
            data.tokenIn = srcToken == NATIVE_TOKEN ? IUniswapRouterV3(DIRECT_SWAP_ROUTER).WETH9() : srcToken;
            data.tokenOut = dstToken;
            data.recipient = address(this);
            data.sqrtPriceLimitX96 = 0;
            data.fee = directPoolSwapFee[srcToken];
            data.deadline = block.timestamp + 60;
            actualAmountOut = srcToken == NATIVE_TOKEN ?
                IUniswapRouterV3(DIRECT_SWAP_ROUTER).exactInputSingle{value: amountIn}(data) :
                IUniswapRouterV3(DIRECT_SWAP_ROUTER).exactInputSingle(data);
        } else {
            IPancakeRouterV3.ExactInputSingleParams memory data;
            data.amountIn = amountIn;
            data.amountOutMinimum = amountOutMin;
            data.tokenIn = srcToken == NATIVE_TOKEN ? IPancakeRouterV3(DIRECT_SWAP_ROUTER).WETH9() : srcToken;
            data.tokenOut = dstToken;
            data.recipient = address(this);
            data.sqrtPriceLimitX96 = 0;
            data.fee = directPoolSwapFee[srcToken];
            actualAmountOut = srcToken == NATIVE_TOKEN ?
                IPancakeRouterV3(DIRECT_SWAP_ROUTER).exactInputSingle{value: amountIn}(data) :
                IPancakeRouterV3(DIRECT_SWAP_ROUTER).exactInputSingle(data);
        }
    }
    function _preSwapHandler(
        ERC20 token,
        uint256 minSharesToReceive
    ) private returns (TxParams memory dp) {
        require(depositableAssets.contains(address(token)), "da");
        (dp.aum, dp.assets, dp.prices, dp.usdValues) = _getAllocations(0);
        dp.nav = dp.aum == 0 ? 0 : getNav();
        return dp;
    }
    function _postSwapHandler(address token, TxParams memory dp)
    private returns (uint256 endAum) {
        if (!portfolio.contains(token)) {
                require(
                (token == NATIVE_TOKEN ? address(this).balance: ERC20(token).balanceOf(address(this))) == 0, "b1");
            }
        uint256[] memory newUsdValues;
        (endAum, newUsdValues) = _getAllocationsWithPrices(dp.assets, dp.prices);
        require(absSlippage(dp.nominalFinalAum, endAum, UNIT) <= slippageTolerances[SlippageType.AUM], "s2");
        for (uint256 i = 0; i < dp.assets.length; i++) {
            uint256 initialAlloc = dp.usdValues[i] * UNIT / dp.aum;
            uint256 newAlloc = newUsdValues[i] * UNIT / endAum;
            require(absSlippage(initialAlloc, newAlloc, UNIT) <= slippageTolerances[SlippageType.SWAP], "s1");
        }
    }
    function _updatePortfolio(ERC20 token) private {
        uint256 balance = address(token) == NATIVE_TOKEN ? address(this).balance : token.balanceOf(address(this));
        if (balance > 0) {
            require(oracle.isTokenSupported(address(token)), "st");
            portfolio.add(address(token));
        } else {
            require(address(token) != NATIVE_TOKEN, "p1");
            require(address(token) != feeAsset, "p2");
            portfolio.remove(address(token));
        }
    }
    function getAllocations()
    external view
    returns (uint256 aumInUsd, address[] memory assets, uint256[] memory prices, uint256[] memory usdValues)
    {
        return _getAllocations(0);
    }
    function getDepositableAssets()
    external view
    returns (address[] memory)
    {
        return depositableAssets.values();
    }
    function getNav() public view returns (uint256 nav) {
        return _getAum() * UNIT / totalSupply();
    }
    function _getAllocations(uint256 nativeIn) private view
    returns (uint256 aumInUsd, address[] memory assets, uint256[] memory prices, uint256[] memory usdValues)
    {
        uint256 len = portfolio.length();
        aumInUsd = 0;
        assets = new address[](len);
        usdValues = new uint256[](len);
        prices = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            address token = portfolio.at(i);
            uint256 size = address(token) == NATIVE_TOKEN ? address(this).balance - nativeIn : ERC20(token).balanceOf(address(this));
            uint256 priceUnit18 = _getPriceUnit18(token);
            uint256 usdValue = _getUsdValueUnit18(token, size, priceUnit18);
            aumInUsd += usdValue;
            assets[i] = token;
            usdValues[i] = usdValue;
            prices[i] = priceUnit18;
        }
    }
    function _getAllocationsWithPrices(address[] memory tokens, uint256[] memory prices) private view
    returns (uint256 aumInUsd, uint256[] memory usdValues)
    {
        uint256 len = tokens.length;
        aumInUsd = 0;
        usdValues = new uint256[](len);
        for (uint256 i = 0; i < len; i++) {
            address token = tokens[i];
            uint256 size = address(token) == NATIVE_TOKEN ? address(this).balance : ERC20(token).balanceOf(address(this));
            uint256 usdValue = _getUsdValueUnit18(token, size, prices[i]);
            aumInUsd += usdValue;
            usdValues[i] = usdValue;
        }
    }
    function _getAum() private view returns (uint256 aum) {
        (aum, , ,) = _getAllocations(0);
    }
    function _getPriceUnit18(address token) private view returns (uint256 priceUnit18) {
        (int256 price, uint8 priceDecimals, ) = oracle.getPriceInUsd(token);
        priceUnit18 = uint256(price) * (10 ** (18 - priceDecimals));  
    }
    function _getUsdValue(address token, uint256 size) private view returns (uint256 usdValue) {
        uint256 unit = token == NATIVE_TOKEN ? 1e18 : 10 ** ERC20(token).decimals();
        (int256 price, uint8 priceDecimals, uint256 timestamp) = oracle.getPriceInUsd(token);
        usdValue = uint256(price) * size * UNIT / unit / (10 ** priceDecimals);
    }
    function _getUsdValueUnit18(address token, uint256 size, uint256 priceUnit18) private view returns (uint256 usdValueUnit18) {
        uint8 _decimals = token == NATIVE_TOKEN ? 18 : ERC20(token).decimals();
        usdValueUnit18 = priceUnit18 * size / (10 ** _decimals);
    }
}