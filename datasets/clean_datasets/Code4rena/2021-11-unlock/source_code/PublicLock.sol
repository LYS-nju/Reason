pragma solidity ^0.8.4;
interface IPublicLock
{
  function initialize(
    address _lockCreator,
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName
  ) external;
  function DEFAULT_ADMIN_ROLE() external pure returns (bytes32);
  function KEY_GRANTER_ROLE() external pure returns (bytes32);
  function LOCK_MANAGER_ROLE() external pure returns (bytes32);
  function publicLockVersion() external pure returns (uint16);
  function disableLock() external;
  function withdraw(
    address _tokenAddress,
    uint _amount
  ) external;
  function approveBeneficiary(
    address _spender,
    uint _amount
  ) external
    returns (bool);
  function updateKeyPricing( uint _keyPrice, address _tokenAddress ) external;
  function updateBeneficiary( address _beneficiary ) external;
  function getHasValidKey(
    address _user
  ) external view returns (bool);
  function getTokenIdFor(
    address _account
  ) external view returns (uint);
  function keyExpirationTimestampFor(
    address _keyOwner
  ) external view returns (uint timestamp);
  function numberOfOwners() external view returns (uint);
  function updateLockName(
    string calldata _lockName
  ) external;
  function updateLockSymbol(
    string calldata _lockSymbol
  ) external;
  function symbol()
    external view
    returns(string memory);
  function setBaseTokenURI(
    string calldata _baseTokenURI
  ) external;
  function tokenURI(
    uint256 _tokenId
  ) external view returns(string memory);
  function setEventHooks(
    address _onKeyPurchaseHook,
    address _onKeyCancelHook
  ) external;
  function grantKeys(
    address[] calldata _recipients,
    uint[] calldata _expirationTimestamps,
    address[] calldata _keyManagers
  ) external;
  function purchase(
    uint256 _value,
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external payable;
  function purchasePriceFor(
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external view
    returns (uint);
  function updateTransferFee(
    uint _transferFeeBasisPoints
  ) external;
  function getTransferFee(
    address _keyOwner,
    uint _time
  ) external view returns (uint);
  function expireAndRefundFor(
    address _keyOwner,
    uint amount
  ) external;
  function cancelAndRefund(uint _tokenId) external;
  function updateRefundPenalty(
    uint _freeTrialLength,
    uint _refundPenaltyBasisPoints
  ) external;
  function getCancelAndRefundValueFor(
    address _keyOwner
  ) external view returns (uint refund);
  function addKeyGranter(address account) external;
  function addLockManager(address account) external;
  function isKeyGranter(address account) external view returns (bool);
  function isLockManager(address account) external view returns (bool);
  function onKeyPurchaseHook() external view returns(address);
  function onKeyCancelHook() external view returns(address);
  function revokeKeyGranter(address _granter) external;
  function renounceLockManager() external;
  function beneficiary() external view returns (address );
  function expirationDuration() external view returns (uint256 );
  function freeTrialLength() external view returns (uint256 );
  function isAlive() external view returns (bool );
  function keyPrice() external view returns (uint256 );
  function maxNumberOfKeys() external view returns (uint256 );
  function owners(uint256 ) external view returns (address );
  function refundPenaltyBasisPoints() external view returns (uint256 );
  function tokenAddress() external view returns (address );
  function transferFeeBasisPoints() external view returns (uint256 );
  function unlockProtocol() external view returns (address );
  function keyManagerOf(uint) external view returns (address );
  function shareKey(
    address _to,
    uint _tokenId,
    uint _timeShared
  ) external;
  function setKeyManagerOf(
    uint _tokenId,
    address _keyManager
  ) external;
  function name() external view returns (string memory _name);
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address _owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 _tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address _owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address _owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function getRoleAdmin(bytes32 role) external view returns (bytes32);
    function grantRole(bytes32 role, address account) external;
    function revokeRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
    function hasRole(bytes32 role, address account) external view returns (bool);
    function transfer(
      address _to,
      uint _value
    ) external
      returns (bool success);
}
abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}
interface IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }
    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}
abstract contract ERC165StorageUpgradeable is Initializable, ERC165Upgradeable {
    function __ERC165Storage_init() internal initializer {
        __ERC165_init_unchained();
        __ERC165Storage_init_unchained();
    }
    function __ERC165Storage_init_unchained() internal initializer {
    }
    mapping(bytes4 => bool) private _supportedInterfaces;
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return super.supportsInterface(interfaceId) || _supportedInterfaces[interfaceId];
    }
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}
interface IERC20Upgradeable {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract MixinFunds
{
  using AddressUpgradeable for address payable;
  using SafeERC20Upgradeable for IERC20Upgradeable;
  address public tokenAddress;
  function _initializeMixinFunds(
    address _tokenAddress
  ) internal
  {
    tokenAddress = _tokenAddress;
    require(
      _tokenAddress == address(0) || IERC20Upgradeable(_tokenAddress).totalSupply() > 0,
      'INVALID_TOKEN'
    );
  }
  function _transfer(
    address _tokenAddress,
    address payable _to,
    uint _amount
  ) internal
  {
    if(_amount > 0) {
      if(_tokenAddress == address(0)) {
        _to.sendValue(_amount);
      } else {
        IERC20Upgradeable token = IERC20Upgradeable(_tokenAddress);
        token.safeTransfer(_to, _amount);
      }
    }
  }
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
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }
    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}
library StringsUpgradeable {
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
abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }
    function __AccessControl_init_unchained() internal initializer {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }
    mapping(bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }
    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }
    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }
    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
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
    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }
    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}
contract MixinRoles is AccessControlUpgradeable {
  bytes32 public constant LOCK_MANAGER_ROLE = keccak256("LOCK_MANAGER");
  bytes32 public constant KEY_GRANTER_ROLE = keccak256("KEY_GRANTER");
  event LockManagerAdded(address indexed account);
  event LockManagerRemoved(address indexed account);
  event KeyGranterAdded(address indexed account);
  event KeyGranterRemoved(address indexed account);
  function _initializeMixinRoles(address sender) internal {
    _setRoleAdmin(LOCK_MANAGER_ROLE, LOCK_MANAGER_ROLE);
    _setRoleAdmin(KEY_GRANTER_ROLE, LOCK_MANAGER_ROLE);
    if (!isLockManager(sender)) {
      _setupRole(LOCK_MANAGER_ROLE, sender);  
    }
    if (!isKeyGranter(sender)) {
      _setupRole(KEY_GRANTER_ROLE, sender);
    }
  }
  modifier onlyLockManager() {
    require( hasRole(LOCK_MANAGER_ROLE, msg.sender), 'MixinRoles: caller does not have the LockManager role');
    _;
  }
  modifier onlyKeyGranterOrManager() {
    require(isKeyGranter(msg.sender) || isLockManager(msg.sender), 'MixinRoles: caller does not have the KeyGranter or LockManager role');
    _;
  }
  function isLockManager(address account) public view returns (bool) {
    return hasRole(LOCK_MANAGER_ROLE, account);
  }
  function addLockManager(address account) public onlyLockManager {
    grantRole(LOCK_MANAGER_ROLE, account);
    emit LockManagerAdded(account);
  }
  function renounceLockManager() public {
    renounceRole(LOCK_MANAGER_ROLE, msg.sender);
    emit LockManagerRemoved(msg.sender);
  }
  function isKeyGranter(address account) public view returns (bool) {
    return hasRole(KEY_GRANTER_ROLE, account);
  }
  function addKeyGranter(address account) public onlyLockManager {
    grantRole(KEY_GRANTER_ROLE, account);
    emit KeyGranterAdded(account);
  }
  function revokeKeyGranter(address _granter) public onlyLockManager {
    revokeRole(KEY_GRANTER_ROLE, _granter);
    emit KeyGranterRemoved(_granter);
  }
}
contract MixinDisable is
  MixinRoles,
  MixinFunds
{
  bool public isAlive;
  event Disable();
  function _initializeMixinDisable(
  ) internal
  {
    isAlive = true;
  }
  modifier onlyIfAlive() {
    require(isAlive, 'LOCK_DEPRECATED');
    _;
  }
  function disableLock()
    external
    onlyLockManager
    onlyIfAlive
  {
    emit Disable();
    isAlive = false;
  }
}
interface IUnlock
{
  function initialize(address _unlockOwner) external;
  function initializeProxyAdmin() external;
  function proxyAdminAddress() external view;
  function createLock(
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName,
    bytes12 _salt
  ) external returns(address);
  function upgradeLock(
    address payable lockAddress, 
    uint16 version
  ) external returns(address);
  function recordKeyPurchase(
    uint _value,
    address _referrer 
  )
    external;
  function recordConsumedDiscount(
    uint _discount,
    uint _tokens 
  )
    external;
  function computeAvailableDiscountFor(
    address _purchaser, 
    uint _keyPrice 
  )
    external
    view
    returns(uint discount, uint tokens);
  function globalBaseTokenURI()
    external
    view
    returns(string memory);
  function getGlobalBaseTokenURI()
    external
    view
    returns (string memory);
  function globalTokenSymbol()
    external
    view
    returns(string memory);
  function chainId()
    external
    view
    returns(uint);
  function getGlobalTokenSymbol()
    external
    view
    returns (string memory);
  function configUnlock(
    address _udt,
    address _weth,
    uint _estimatedGasForPurchase,
    string calldata _symbol,
    string calldata _URI,
    uint _chainId
  )
    external;
  function addLockTemplate(address impl, uint16 version) external;
  function publicLockImpls(uint16 _version) external view;
  function publicLockVersions(address _impl) external view;
  function publicLockLatestVersion() external view;
  function setLockTemplate(
    address payable _publicLockAddress
  ) external;
  function resetTrackedValue(
    uint _grossNetworkProduct,
    uint _totalDiscountGranted
  ) external;
  function grossNetworkProduct() external view returns(uint);
  function totalDiscountGranted() external view returns(uint);
  function locks(address) external view returns(bool deployed, uint totalSales, uint yieldedDiscountTokens);
  function publicLockAddress() external view returns(address);
  function uniswapOracles(address) external view returns(address);
  function weth() external view returns(address);
  function udt() external view returns(address);
  function estimatedGasForPurchase() external view returns(uint);
  function unlockVersion() external pure returns(uint16);
  function setOracle(
    address _tokenAddress,
    address _oracleAddress
  ) external;
  function __initializeOwnable(address sender) external;
  function isOwner() external view returns(bool);
  function owner() external view returns(address);
  function renounceOwnership() external;
  function transferOwnership(address newOwner) external;
}
interface ILockKeyCancelHook
{
  function onKeyCancel(
    address operator,
    address to,
    uint256 refund
  ) external;
}
interface ILockKeyPurchaseHook
{
  function keyPurchasePrice(
    address from,
    address recipient,
    address referrer,
    bytes calldata data
  ) external view
    returns (uint minKeyPrice);
  function onKeyPurchase(
    address from,
    address recipient,
    address referrer,
    bytes calldata data,
    uint minKeyPrice,
    uint pricePaid
  ) external;
}
contract MixinLockCore is
  MixinRoles,
  MixinFunds,
  MixinDisable
{
  using AddressUpgradeable for address;
  event Withdrawal(
    address indexed sender,
    address indexed tokenAddress,
    address indexed beneficiary,
    uint amount
  );
  event PricingChanged(
    uint oldKeyPrice,
    uint keyPrice,
    address oldTokenAddress,
    address tokenAddress
  );
  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
  IUnlock public unlockProtocol;
  uint public expirationDuration;
  uint public keyPrice;
  uint public maxNumberOfKeys;
  uint internal _totalSupply;
  address payable public beneficiary;
  uint internal constant BASIS_POINTS_DEN = 10000;
  ILockKeyPurchaseHook public onKeyPurchaseHook;
  ILockKeyCancelHook public onKeyCancelHook;
  modifier notSoldOut() {
    require(maxNumberOfKeys > _totalSupply, 'LOCK_SOLD_OUT');
    _;
  }
  modifier onlyLockManagerOrBeneficiary()
  {
    require(
      isLockManager(msg.sender) || msg.sender == beneficiary,
      'ONLY_LOCK_MANAGER_OR_BENEFICIARY'
    );
    _;
  }
  function _initializeMixinLockCore(
    address payable _beneficiary,
    uint _expirationDuration,
    uint _keyPrice,
    uint _maxNumberOfKeys
  ) internal
  {
    require(_expirationDuration <= 100 * 365 * 24 * 60 * 60, 'MAX_EXPIRATION_100_YEARS');
    unlockProtocol = IUnlock(msg.sender); 
    beneficiary = _beneficiary;
    expirationDuration = _expirationDuration;
    keyPrice = _keyPrice;
    maxNumberOfKeys = _maxNumberOfKeys;
  }
  function publicLockVersion(
  ) public pure
    returns (uint16)
  {
    return 9;
  }
  function withdraw(
    address _tokenAddress,
    uint _amount
  ) external
    onlyLockManagerOrBeneficiary
  {
    uint balance;
    if(_tokenAddress == address(0)) {
      balance = address(this).balance;
    } else {
      balance = IERC20Upgradeable(_tokenAddress).balanceOf(address(this));
    }
    uint amount;
    if(_amount == 0 || _amount > balance)
    {
      require(balance > 0, 'NOT_ENOUGH_FUNDS');
      amount = balance;
    }
    else
    {
      amount = _amount;
    }
    emit Withdrawal(msg.sender, _tokenAddress, beneficiary, amount);
    _transfer(_tokenAddress, beneficiary, amount);
  }
  function updateKeyPricing(
    uint _keyPrice,
    address _tokenAddress
  )
    external
    onlyLockManager
    onlyIfAlive
  {
    uint oldKeyPrice = keyPrice;
    address oldTokenAddress = tokenAddress;
    require(
      _tokenAddress == address(0) || IERC20Upgradeable(_tokenAddress).totalSupply() > 0,
      'INVALID_TOKEN'
    );
    keyPrice = _keyPrice;
    tokenAddress = _tokenAddress;
    emit PricingChanged(oldKeyPrice, keyPrice, oldTokenAddress, tokenAddress);
  }
  function updateBeneficiary(
    address payable _beneficiary
  ) external
  {
    require(msg.sender == beneficiary || isLockManager(msg.sender), 'ONLY_BENEFICIARY_OR_LOCKMANAGER');
    require(_beneficiary != address(0), 'INVALID_ADDRESS');
    beneficiary = _beneficiary;
  }
  function setEventHooks(
    address _onKeyPurchaseHook,
    address _onKeyCancelHook
  ) external
    onlyLockManager()
  {
    require(_onKeyPurchaseHook == address(0) || _onKeyPurchaseHook.isContract(), 'INVALID_ON_KEY_SOLD_HOOK');
    require(_onKeyCancelHook == address(0) || _onKeyCancelHook.isContract(), 'INVALID_ON_KEY_CANCEL_HOOK');
    onKeyPurchaseHook = ILockKeyPurchaseHook(_onKeyPurchaseHook);
    onKeyCancelHook = ILockKeyCancelHook(_onKeyCancelHook);
  }
  function totalSupply()
    public
    view returns(uint256)
  {
    return _totalSupply;
  }
  function approveBeneficiary(
    address _spender,
    uint _amount
  ) public
    onlyLockManagerOrBeneficiary
    returns (bool)
  {
    return IERC20Upgradeable(tokenAddress).approve(_spender, _amount);
  }
}
contract MixinKeys is
  MixinLockCore
{
  struct Key {
    uint tokenId;
    uint expirationTimestamp;
  }
  event ExpireKey(uint indexed tokenId);
  event ExpirationChanged(
    uint indexed _tokenId,
    uint _amount,
    bool _timeAdded
  );
  event KeyManagerChanged(uint indexed _tokenId, address indexed _newManager);
  mapping (address => Key) internal keyByOwner;
  mapping (uint => address) internal _ownerOf;
  address[] public owners;
  mapping (uint => address) public keyManagerOf;
  mapping (uint => address) private approved;
  mapping (address => mapping (address => bool)) private managerToOperatorApproved;
  modifier onlyKeyManagerOrApproved(
    uint _tokenId
  )
  {
    require(
      _isKeyManager(_tokenId, msg.sender) ||
      _isApproved(_tokenId, msg.sender) ||
      isApprovedForAll(_ownerOf[_tokenId], msg.sender),
      'ONLY_KEY_MANAGER_OR_APPROVED'
    );
    _;
  }
  modifier ownsOrHasOwnedKey(
    address _keyOwner
  ) {
    require(
      keyByOwner[_keyOwner].expirationTimestamp > 0, 'HAS_NEVER_OWNED_KEY'
    );
    _;
  }
  modifier hasValidKey(
    address _user
  ) {
    require(
      getHasValidKey(_user), 'KEY_NOT_VALID'
    );
    _;
  }
  modifier isKey(
    uint _tokenId
  ) {
    require(
      _ownerOf[_tokenId] != address(0), 'NO_SUCH_KEY'
    );
    _;
  }
  modifier onlyKeyOwner(
    uint _tokenId
  ) {
    require(
      ownerOf(_tokenId) == msg.sender, 'ONLY_KEY_OWNER'
    );
    _;
  }
  function balanceOf(
    address _keyOwner
  )
    public
    view
    returns (uint)
  {
    require(_keyOwner != address(0), 'INVALID_ADDRESS');
    return getHasValidKey(_keyOwner) ? 1 : 0;
  }
  function getHasValidKey(
    address _keyOwner
  )
    public
    view
    returns (bool)
  {
    return keyByOwner[_keyOwner].expirationTimestamp > block.timestamp;
  }
  function getTokenIdFor(
    address _account
  ) public view
    returns (uint)
  {
    return keyByOwner[_account].tokenId;
  }
  function keyExpirationTimestampFor(
    address _keyOwner
  ) public view
    returns (uint)
  {
    return keyByOwner[_keyOwner].expirationTimestamp;
  }
  function numberOfOwners()
    public
    view
    returns (uint)
  {
    return owners.length;
  }
  function ownerOf(
    uint _tokenId
  ) public view
    returns(address)
  {
    return _ownerOf[_tokenId];
  }
  function setKeyManagerOf(
    uint _tokenId,
    address _keyManager
  ) public
    isKey(_tokenId)
  {
    require(
      _isKeyManager(_tokenId, msg.sender) ||
      isLockManager(msg.sender),
      'UNAUTHORIZED_KEY_MANAGER_UPDATE'
    );
    _setKeyManagerOf(_tokenId, _keyManager);
  }
  function _setKeyManagerOf(
    uint _tokenId,
    address _keyManager
  ) internal
  {
    if(keyManagerOf[_tokenId] != _keyManager) {
      keyManagerOf[_tokenId] = _keyManager;
      _clearApproval(_tokenId);
      emit KeyManagerChanged(_tokenId, address(0));
    }
  }
  function approve(
    address _approved,
    uint _tokenId
  )
    public
    onlyIfAlive
    onlyKeyManagerOrApproved(_tokenId)
  {
    require(msg.sender != _approved, 'APPROVE_SELF');
    approved[_tokenId] = _approved;
    emit Approval(_ownerOf[_tokenId], _approved, _tokenId);
  }
  function getApproved(
    uint _tokenId
  ) public view
    isKey(_tokenId)
    returns (address)
  {
    address approvedRecipient = approved[_tokenId];
    return approvedRecipient;
  }
  function isApprovedForAll(
    address _owner,
    address _operator
  ) public view
    returns (bool)
  {
    uint tokenId = keyByOwner[_owner].tokenId;
    address keyManager = keyManagerOf[tokenId];
    if(keyManager == address(0)) {
      return managerToOperatorApproved[_owner][_operator];
    } else {
      return managerToOperatorApproved[keyManager][_operator];
    }
  }
  function _isKeyManager(
    uint _tokenId,
    address _keyManager
  ) internal view
    returns (bool)
  {
    if(keyManagerOf[_tokenId] == _keyManager ||
      (keyManagerOf[_tokenId] == address(0) && ownerOf(_tokenId) == _keyManager)) {
      return true;
    } else {
      return false;
    }
  }
  function _assignNewTokenId(
    Key storage _key
  ) internal
  {
    if (_key.tokenId == 0) {
      _totalSupply++;
      _key.tokenId = _totalSupply;
    }
  }
  function _recordOwner(
    address _keyOwner,
    uint _tokenId
  ) internal
  {
    if (ownerOf(_tokenId) != _keyOwner) {
      owners.push(_keyOwner);
      _ownerOf[_tokenId] = _keyOwner;
    }
  }
  function _timeMachine(
    uint _tokenId,
    uint256 _deltaT,
    bool _addTime
  ) internal
  {
    address tokenOwner = ownerOf(_tokenId);
    require(tokenOwner != address(0), 'NON_EXISTENT_KEY');
    Key storage key = keyByOwner[tokenOwner];
    uint formerTimestamp = key.expirationTimestamp;
    bool validKey = getHasValidKey(tokenOwner);
    if(_addTime) {
      if(validKey) {
        key.expirationTimestamp = formerTimestamp + _deltaT;
      } else {
        key.expirationTimestamp = block.timestamp + _deltaT;
      }
    } else {
      key.expirationTimestamp = formerTimestamp - _deltaT;
    }
    emit ExpirationChanged(_tokenId, _deltaT, _addTime);
  }
  function setApprovalForAll(
    address _to,
    bool _approved
  ) public
    onlyIfAlive
  {
    require(_to != msg.sender, 'APPROVE_SELF');
    managerToOperatorApproved[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }
  function _isApproved(
    uint _tokenId,
    address _user
  ) internal view
    returns (bool)
  {
    return approved[_tokenId] == _user;
  }
  function _clearApproval(
    uint256 _tokenId
  ) internal
  {
    if (approved[_tokenId] != address(0)) {
      approved[_tokenId] = address(0);
    }
  }
}
contract MixinERC721Enumerable is
  ERC165StorageUpgradeable,
  MixinLockCore, 
  MixinKeys
{
  function _initializeMixinERC721Enumerable() internal
  {
    _registerInterface(0x780e9d63);
  }
  function tokenByIndex(
    uint256 _index
  ) public view
    returns (uint256)
  {
    require(_index < _totalSupply, 'OUT_OF_RANGE');
    return _index;
  }
  function tokenOfOwnerByIndex(
    address _keyOwner,
    uint256 _index
  ) public view
    returns (uint256)
  {
    require(_index == 0, 'ONLY_ONE_KEY_PER_OWNER');
    return getTokenIdFor(_keyOwner);
  }
  function supportsInterface(bytes4 interfaceId) 
    public 
    view 
    virtual 
    override(
      AccessControlUpgradeable,
      ERC165StorageUpgradeable
    ) 
    returns (bool) 
    {
    return super.supportsInterface(interfaceId);
  }
}
contract MixinGrantKeys is
  MixinRoles,
  MixinKeys
{
  function grantKeys(
    address[] calldata _recipients,
    uint[] calldata _expirationTimestamps,
    address[] calldata _keyManagers
  ) external
    onlyKeyGranterOrManager
  {
    for(uint i = 0; i < _recipients.length; i++) {
      address recipient = _recipients[i];
      uint expirationTimestamp = _expirationTimestamps[i];
      address keyManager = _keyManagers[i];
      require(recipient != address(0), 'INVALID_ADDRESS');
      Key storage toKey = keyByOwner[recipient];
      require(expirationTimestamp > toKey.expirationTimestamp, 'ALREADY_OWNS_KEY');
      uint idTo = toKey.tokenId;
      if(idTo == 0) {
        _assignNewTokenId(toKey);
        idTo = toKey.tokenId;
        _recordOwner(recipient, idTo);
      }
      _setKeyManagerOf(idTo, keyManager);
      emit KeyManagerChanged(idTo, keyManager);
      toKey.expirationTimestamp = expirationTimestamp;
      emit Transfer(
        address(0), 
        recipient,
        idTo
      );
    }
  }
}
library UnlockUtils {
  function strConcat(
    string memory _a,
    string memory _b,
    string memory _c,
    string memory _d
  ) internal pure
    returns (string memory _concatenatedString)
  {
    return string(abi.encodePacked(_a, _b, _c, _d));
  }
  function uint2Str(
    uint _i
  ) internal pure
    returns (string memory _uintAsString)
  {
    uint c = _i;
    if (_i == 0) {
      return '0';
    }
    uint j = _i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len;
    while (c != 0) {
        k = k-1;
        uint8 temp = (48 + uint8(c - c / 10 * 10));
        bytes1 b1 = bytes1(temp);
        bstr[k] = b1;
        c /= 10;
    }
    return string(bstr);
  }
  function address2Str(
    address _addr
  ) internal pure
    returns(string memory)
  {
    bytes32 value = bytes32(uint256(uint160(_addr)));
    bytes memory alphabet = '0123456789abcdef';
    bytes memory str = new bytes(42);
    str[0] = '0';
    str[1] = 'x';
    for (uint i = 0; i < 20; i++) {
      str[2+i*2] = alphabet[uint8(value[i + 12] >> 4)];
      str[3+i*2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    return string(str);
  }
}
contract MixinLockMetadata is
  ERC165StorageUpgradeable,
  MixinRoles,
  MixinLockCore,
  MixinKeys
{
  using UnlockUtils for uint;
  using UnlockUtils for address;
  using UnlockUtils for string;
  string public name;
  string private lockSymbol;
  string private baseTokenURI;
  event NewLockSymbol(
    string symbol
  );
  function _initializeMixinLockMetadata(
    string calldata _lockName
  ) internal
  {
    ERC165StorageUpgradeable.__ERC165Storage_init();
    name = _lockName;
    _registerInterface(0x5b5e139f);
  }
  function updateLockName(
    string calldata _lockName
  ) external
    onlyLockManager
  {
    name = _lockName;
  }
  function updateLockSymbol(
    string calldata _lockSymbol
  ) external
    onlyLockManager
  {
    lockSymbol = _lockSymbol;
    emit NewLockSymbol(_lockSymbol);
  }
  function symbol()
    external view
    returns(string memory)
  {
    if(bytes(lockSymbol).length == 0) {
      return unlockProtocol.globalTokenSymbol();
    } else {
      return lockSymbol;
    }
  }
  function setBaseTokenURI(
    string calldata _baseTokenURI
  ) external
    onlyLockManager
  {
    baseTokenURI = _baseTokenURI;
  }
  function tokenURI(
    uint256 _tokenId
  ) external
    view
    returns(string memory)
  {
    string memory URI;
    string memory tokenId;
    string memory lockAddress = address(this).address2Str();
    string memory seperator;
    if(_tokenId != 0) {
      tokenId = _tokenId.uint2Str();
    } else {
      tokenId = '';
    }
    if(bytes(baseTokenURI).length == 0) {
      URI = unlockProtocol.globalBaseTokenURI();
      seperator = '/';
    } else {
      URI = baseTokenURI;
      seperator = '';
      lockAddress = '';
    }
    return URI.strConcat(
        lockAddress,
        seperator,
        tokenId
      );
  }
  function supportsInterface(bytes4 interfaceId) 
    public 
    view 
    virtual 
    override(
      AccessControlUpgradeable,
      ERC165StorageUpgradeable
    ) 
    returns (bool) 
    {
    return super.supportsInterface(interfaceId);
  }
}
contract MixinPurchase is
  MixinFunds,
  MixinDisable,
  MixinLockCore,
  MixinKeys
{
  event RenewKeyPurchase(address indexed owner, uint newExpiration);
  function purchase(
    uint256 _value,
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external payable
    onlyIfAlive
    notSoldOut
  {
    require(_recipient != address(0), 'INVALID_ADDRESS');
    Key storage toKey = keyByOwner[_recipient];
    uint idTo = toKey.tokenId;
    uint newTimeStamp;
    if (idTo == 0) {
      _assignNewTokenId(toKey);
      idTo = toKey.tokenId;
      _recordOwner(_recipient, idTo);
      newTimeStamp = block.timestamp + expirationDuration;
      toKey.expirationTimestamp = newTimeStamp;
      emit Transfer(
        address(0), 
        _recipient,
        idTo
      );
    } else if (toKey.expirationTimestamp > block.timestamp) {
      newTimeStamp = toKey.expirationTimestamp + expirationDuration;
      toKey.expirationTimestamp = newTimeStamp;
      emit RenewKeyPurchase(_recipient, newTimeStamp);
    } else {
      newTimeStamp = block.timestamp + expirationDuration;
      toKey.expirationTimestamp = newTimeStamp;
      _setKeyManagerOf(idTo, address(0));
      emit RenewKeyPurchase(_recipient, newTimeStamp);
    }
    (uint inMemoryKeyPrice, uint discount, uint tokens) = _purchasePriceFor(_recipient, _referrer, _data);
    if (discount > 0)
    {
      unlockProtocol.recordConsumedDiscount(discount, tokens);
    }
    unlockProtocol.recordKeyPurchase(inMemoryKeyPrice, _referrer);
    uint pricePaid;
    if(tokenAddress != address(0))
    {
      pricePaid = _value;
      IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
      token.transferFrom(msg.sender, address(this), pricePaid);
    }
    else
    {
      pricePaid = msg.value;
    }
    require(pricePaid >= inMemoryKeyPrice, 'INSUFFICIENT_VALUE');
    if(address(onKeyPurchaseHook) != address(0))
    {
      onKeyPurchaseHook.onKeyPurchase(msg.sender, _recipient, _referrer, _data, inMemoryKeyPrice, pricePaid);
    }
  }
  function purchasePriceFor(
    address _recipient,
    address _referrer,
    bytes calldata _data
  ) external view
    returns (uint minKeyPrice)
  {
    (minKeyPrice, , ) = _purchasePriceFor(_recipient, _referrer, _data);
  }
  function _purchasePriceFor(
    address _recipient,
    address _referrer,
    bytes memory _data
  ) internal view
    returns (uint minKeyPrice, uint unlockDiscount, uint unlockTokens)
  {
    if(address(onKeyPurchaseHook) != address(0))
    {
      minKeyPrice = onKeyPurchaseHook.keyPurchasePrice(msg.sender, _recipient, _referrer, _data);
    }
    else
    {
      minKeyPrice = keyPrice;
    }
    if(minKeyPrice > 0)
    {
      (unlockDiscount, unlockTokens) = unlockProtocol.computeAvailableDiscountFor(_recipient, minKeyPrice);
      require(unlockDiscount <= minKeyPrice, 'INVALID_DISCOUNT_FROM_UNLOCK');
      minKeyPrice -= unlockDiscount;
    }
  }
}
contract MixinRefunds is
  MixinRoles,
  MixinFunds,
  MixinLockCore,
  MixinKeys
{
  uint public refundPenaltyBasisPoints;
  uint public freeTrialLength;
  event CancelKey(
    uint indexed tokenId,
    address indexed owner,
    address indexed sendTo,
    uint refund
  );
  event RefundPenaltyChanged(
    uint freeTrialLength,
    uint refundPenaltyBasisPoints
  );
  function _initializeMixinRefunds() internal
  {
    refundPenaltyBasisPoints = 1000;
  }
  function expireAndRefundFor(
    address payable _keyOwner,
    uint amount
  ) external
    onlyLockManager
    hasValidKey(_keyOwner)
  {
    _cancelAndRefund(_keyOwner, amount);
  }
  function cancelAndRefund(uint _tokenId)
    external
    onlyKeyManagerOrApproved(_tokenId)
  {
    address payable keyOwner = payable(ownerOf(_tokenId));
    uint refund = _getCancelAndRefundValue(keyOwner);
    _cancelAndRefund(keyOwner, refund);
  }
  function updateRefundPenalty(
    uint _freeTrialLength,
    uint _refundPenaltyBasisPoints
  ) external
    onlyLockManager
  {
    emit RefundPenaltyChanged(
      _freeTrialLength,
      _refundPenaltyBasisPoints
    );
    freeTrialLength = _freeTrialLength;
    refundPenaltyBasisPoints = _refundPenaltyBasisPoints;
  }
  function getCancelAndRefundValueFor(
    address _keyOwner
  )
    external view
    returns (uint refund)
  {
    return _getCancelAndRefundValue(_keyOwner);
  }
  function _cancelAndRefund(
    address payable _keyOwner,
    uint refund
  ) internal
  {
    Key storage key = keyByOwner[_keyOwner];
    emit CancelKey(key.tokenId, _keyOwner, msg.sender, refund);
    key.expirationTimestamp = block.timestamp;
    if (refund > 0) {
      _transfer(tokenAddress, _keyOwner, refund);
    }
    if(address(onKeyCancelHook) != address(0))
    {
      onKeyCancelHook.onKeyCancel(msg.sender, _keyOwner, refund);
    }
  }
  function _getCancelAndRefundValue(
    address _keyOwner
  )
    private view
    hasValidKey(_keyOwner)
    returns (uint refund)
  {
    Key storage key = keyByOwner[_keyOwner];
    uint timeRemaining = key.expirationTimestamp - block.timestamp;
    if(timeRemaining + freeTrialLength >= expirationDuration) {
      refund = keyPrice;
    } else {
      refund = keyPrice * timeRemaining / expirationDuration;
    }
    if(freeTrialLength == 0 || timeRemaining + freeTrialLength < expirationDuration)
    {
      uint penalty = keyPrice * refundPenaltyBasisPoints / BASIS_POINTS_DEN;
      if (refund > penalty) {
        refund -= penalty;
      } else {
        refund = 0;
      }
    }
  }
}
interface IERC721ReceiverUpgradeable {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
contract MixinTransfer is
  MixinRoles,
  MixinFunds,
  MixinLockCore,
  MixinKeys
{
  using AddressUpgradeable for address;
  event TransferFeeChanged(
    uint transferFeeBasisPoints
  );
  bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
  uint public transferFeeBasisPoints;
  function shareKey(
    address _to,
    uint _tokenId,
    uint _timeShared
  ) public
    onlyIfAlive
    onlyKeyManagerOrApproved(_tokenId)
  {
    require(transferFeeBasisPoints < BASIS_POINTS_DEN, 'KEY_TRANSFERS_DISABLED');
    require(_to != address(0), 'INVALID_ADDRESS');
    address keyOwner = _ownerOf[_tokenId];
    require(getHasValidKey(keyOwner), 'KEY_NOT_VALID');
    Key storage fromKey = keyByOwner[keyOwner];
    Key storage toKey = keyByOwner[_to];
    uint idTo = toKey.tokenId;
    uint time;
    uint timeRemaining = fromKey.expirationTimestamp - block.timestamp;
    uint fee = getTransferFee(keyOwner, _timeShared);
    uint timePlusFee = _timeShared + fee;
    if(timePlusFee < timeRemaining) {
      time = _timeShared;
      _timeMachine(_tokenId, timePlusFee, false);
    } else {
      fee = getTransferFee(keyOwner, timeRemaining);
      time = timeRemaining - fee;
      fromKey.expirationTimestamp = block.timestamp; 
      emit ExpireKey(_tokenId);
    }
    if (idTo == 0) {
      _assignNewTokenId(toKey);
      idTo = toKey.tokenId;
      _recordOwner(_to, idTo);
      emit Transfer(
        address(0), 
        _to,
        idTo
      );
    } else if (toKey.expirationTimestamp <= block.timestamp) {
      _setKeyManagerOf(idTo, address(0));
    }
    _timeMachine(idTo, time, true);
    emit Transfer(
      keyOwner,
      _to,
      idTo
    );
    require(_checkOnERC721Received(keyOwner, _to, _tokenId, ''), 'NON_COMPLIANT_ERC721_RECEIVER');
  }
  function transferFrom(
    address _from,
    address _recipient,
    uint _tokenId
  )
    public
    onlyIfAlive
    hasValidKey(_from)
    onlyKeyManagerOrApproved(_tokenId)
  {
    require(ownerOf(_tokenId) == _from, 'TRANSFER_FROM: NOT_KEY_OWNER');
    require(transferFeeBasisPoints < BASIS_POINTS_DEN, 'KEY_TRANSFERS_DISABLED');
    require(_recipient != address(0), 'INVALID_ADDRESS');
    uint fee = getTransferFee(_from, 0);
    Key storage fromKey = keyByOwner[_from];
    Key storage toKey = keyByOwner[_recipient];
    uint previousExpiration = toKey.expirationTimestamp;
    _timeMachine(_tokenId, fee, false);
    if (toKey.tokenId == 0) {
      toKey.tokenId = _tokenId;
      _recordOwner(_recipient, _tokenId);
      _clearApproval(_tokenId);
    }
    if (previousExpiration <= block.timestamp) {
      toKey.expirationTimestamp = fromKey.expirationTimestamp;
      toKey.tokenId = _tokenId;
      _setKeyManagerOf(_tokenId, address(0));
      _recordOwner(_recipient, _tokenId);
    } else {
      toKey.expirationTimestamp = fromKey.expirationTimestamp + previousExpiration - block.timestamp;
    }
    fromKey.expirationTimestamp = block.timestamp;
    fromKey.tokenId = 0;
    emit Transfer(
      _from,
      _recipient,
      _tokenId
    );
  }
  function transfer(
    address _to,
    uint _value
  ) public
    returns (bool success)
  {
    uint maxTimeToSend = _value * expirationDuration;
    Key storage fromKey = keyByOwner[msg.sender];
    uint timeRemaining = fromKey.expirationTimestamp - block.timestamp;
    if(maxTimeToSend < timeRemaining)
    {
      shareKey(_to, fromKey.tokenId, maxTimeToSend);
    }
    else
    {
      transferFrom(msg.sender, _to, fromKey.tokenId);
    }
    return true;
  }
  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId
  )
    public
  {
    safeTransferFrom(_from, _to, _tokenId, '');
  }
  function safeTransferFrom(
    address _from,
    address _to,
    uint _tokenId,
    bytes memory _data
  )
    public
  {
    transferFrom(_from, _to, _tokenId);
    require(_checkOnERC721Received(_from, _to, _tokenId, _data), 'NON_COMPLIANT_ERC721_RECEIVER');
  }
  function updateTransferFee(
    uint _transferFeeBasisPoints
  )
    external
    onlyLockManager
  {
    emit TransferFeeChanged(
      _transferFeeBasisPoints
    );
    transferFeeBasisPoints = _transferFeeBasisPoints;
  }
  function getTransferFee(
    address _keyOwner,
    uint _time
  )
    public view
    returns (uint)
  {
    if(! getHasValidKey(_keyOwner)) {
      return 0;
    } else {
      Key storage key = keyByOwner[_keyOwner];
      uint timeToTransfer;
      uint fee;
      if(_time == 0) {
        timeToTransfer = key.expirationTimestamp - block.timestamp;
      } else {
        timeToTransfer = _time;
      }
      fee = timeToTransfer * transferFeeBasisPoints / BASIS_POINTS_DEN;
      return fee;
    }
  }
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  )
    internal
    returns (bool)
  {
    if (!to.isContract()) {
      return true;
    }
    bytes4 retval = IERC721ReceiverUpgradeable(to).onERC721Received(
      msg.sender, from, tokenId, _data);
    return (retval == _ERC721_RECEIVED);
  }
}
contract PublicLock is
  Initializable,
  ERC165StorageUpgradeable,
  MixinRoles,
  MixinFunds,
  MixinDisable,
  MixinLockCore,
  MixinKeys,
  MixinLockMetadata,
  MixinERC721Enumerable,
  MixinGrantKeys,
  MixinPurchase,
  MixinTransfer,
  MixinRefunds
{
  function initialize(
    address payable _lockCreator,
    uint _expirationDuration,
    address _tokenAddress,
    uint _keyPrice,
    uint _maxNumberOfKeys,
    string calldata _lockName
  ) public
    initializer()
  {
    MixinFunds._initializeMixinFunds(_tokenAddress);
    MixinDisable._initializeMixinDisable();
    MixinLockCore._initializeMixinLockCore(_lockCreator, _expirationDuration, _keyPrice, _maxNumberOfKeys);
    MixinLockMetadata._initializeMixinLockMetadata(_lockName);
    MixinERC721Enumerable._initializeMixinERC721Enumerable();
    MixinRefunds._initializeMixinRefunds();
    MixinRoles._initializeMixinRoles(_lockCreator);
    _registerInterface(0x80ac58cd);
  }
  receive() external payable {}
  fallback() external payable {}
  function supportsInterface(bytes4 interfaceId) 
    public 
    view 
    virtual 
    override(
      MixinERC721Enumerable,
      MixinLockMetadata,
      AccessControlUpgradeable, 
      ERC165StorageUpgradeable
    ) 
    returns (bool) 
    {
    return super.supportsInterface(interfaceId);
  }
}