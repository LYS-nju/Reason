pragma solidity 0.6.6;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}
contract Initializable {
  bool private initialized;
  bool private initializing;
  modifier initializer() {
    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");
    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }
    _;
    if (isTopLevelCall) {
      initializing = false;
    }
  }
  function isConstructor() private view returns (bool) {
    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }
  uint256[50] private ______gap;
}
interface IDAO {
  function epoch() external view returns (uint256);
  function epochLength() external view returns (uint256);
  function genesisTime() external view returns (uint256);
  function getEpochStartTime(uint256 _epoch) external view returns (uint256);
  function getLockedMalt(address account) external view returns (uint256);
  function epochsPerYear() external view returns (uint256);
}
interface IMiningService {
  function withdrawAccountRewards(uint256 amount) external;
  function balanceOfRewards(address account) external view returns (uint256);
  function earned(address account) external view returns (uint256);
  function onBond(address account, uint256 amount) external;
  function onUnbond(address account, uint256 amount) external;
  function withdrawRewardsForAccount(address account, uint256 amount) external;
}
interface IDexHandler {
  function buyMalt() external returns (uint256 purchased);
  function sellMalt() external returns (uint256 rewards);
  function addLiquidity() external returns (
    uint256 maltUsed,
    uint256 rewardUsed,
    uint256 liquidityCreated
  );
  function removeLiquidity() external returns (uint256 amountMalt, uint256 amountReward);
  function calculateMintingTradeSize(uint256 priceTarget) external view returns (uint256);
  function calculateBurningTradeSize(uint256 priceTarget) external view returns (uint256);
  function reserves() external view returns (uint256 maltSupply, uint256 rewardSupply);
  function maltMarketPrice() external view returns (uint256 price, uint256 decimals);
  function getOptimalLiquidity(address tokenA, address tokenB, uint256 liquidityB)
    external view returns (uint256 liquidityA);
}
interface IMaltDataLab {
  function priceTarget() external view returns (uint256);
  function smoothedReserveRatio() external view returns (uint256);
  function smoothedMaltPrice() external view returns (uint256);
  function smoothedMaltInPool() external view returns (uint256);
  function reserveRatioAverage(uint256 _lookback) external view returns (uint256);
  function maltPriceAverage(uint256 _lookback) external view returns (uint256);
  function maltInPoolAverage(uint256 _lookback) external view returns (uint256);
  function realValueOfLPToken(uint256 amount) external view returns (uint256);
  function trackReserveRatio() external;
  function trackPool() external;
}
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping (bytes32 => uint256) _indexes;
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
            bytes32 lastvalue = set._values[lastIndex];
            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; 
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
        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
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
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(value)));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(value)));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(value)));
    }
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint256(_at(set._inner, index)));
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
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
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
abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;
    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }
    mapping (bytes32 => RoleData) private _roles;
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }
    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }
    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }
    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }
    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");
        _grantRole(role, account);
    }
    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");
        _revokeRole(role, account);
    }
    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");
        _revokeRole(role, account);
    }
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }
    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }
    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract Permissions is AccessControl {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;
  bytes32 public constant TIMELOCK_ROLE = keccak256("TIMELOCK_ROLE");
  bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
  bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
  bytes32 public constant MONETARY_BURNER_ROLE = keccak256("MONETARY_BURNER_ROLE");
  bytes32 public constant MONETARY_MINTER_ROLE = keccak256("MONETARY_MINTER_ROLE");
  bytes32 public constant STABILIZER_NODE_ROLE = keccak256("STABILIZER_NODE_ROLE");
  bytes32 public constant LIQUIDITY_MINE_ROLE = keccak256("LIQUIDITY_MINE_ROLE");
  bytes32 public constant AUCTION_ROLE = keccak256("AUCTION_ROLE");
  bytes32 public constant REWARD_THROTTLE_ROLE = keccak256("REWARD_THROTTLE_ROLE");
  address internal globalAdmin;
  mapping(address => uint256) public lastBlock; 
  function _adminSetup(address _timelock) internal {
    _roleSetup(TIMELOCK_ROLE, _timelock);
    _roleSetup(ADMIN_ROLE, _timelock);
    _roleSetup(GOVERNOR_ROLE, _timelock);
    _roleSetup(MONETARY_BURNER_ROLE, _timelock);
    _roleSetup(MONETARY_MINTER_ROLE, _timelock);
    _roleSetup(STABILIZER_NODE_ROLE, _timelock);
    _roleSetup(LIQUIDITY_MINE_ROLE, _timelock);
    _roleSetup(AUCTION_ROLE, _timelock);
    _roleSetup(REWARD_THROTTLE_ROLE, _timelock);
    globalAdmin = _timelock;
  }
  function assignRole(bytes32 role, address _assignee)
    external
    onlyRole(TIMELOCK_ROLE, "Only timelock can assign roles")
  {
    _setupRole(role, _assignee);
  }
  function removeRole(bytes32 role, address _entity)
    external
    onlyRole(TIMELOCK_ROLE, "Only timelock can revoke roles")
  {
    revokeRole(role, _entity);
  }
  function reassignGlobalAdmin(address _admin)
    external
    onlyRole(TIMELOCK_ROLE, "Only timelock can assign roles")
  {
    _swapRole(_admin, globalAdmin, TIMELOCK_ROLE);
    _swapRole(_admin, globalAdmin, ADMIN_ROLE);
    _swapRole(_admin, globalAdmin, GOVERNOR_ROLE);
    _swapRole(_admin, globalAdmin, MONETARY_BURNER_ROLE);
    _swapRole(_admin, globalAdmin, MONETARY_MINTER_ROLE);
    _swapRole(_admin, globalAdmin, STABILIZER_NODE_ROLE);
    _swapRole(_admin, globalAdmin, LIQUIDITY_MINE_ROLE);
    _swapRole(_admin, globalAdmin, AUCTION_ROLE);
    _swapRole(_admin, globalAdmin, REWARD_THROTTLE_ROLE);
    globalAdmin = _admin;
  }
  function emergencyWithdrawGAS(address payable destination)
    external 
    onlyRole(TIMELOCK_ROLE, "Only timelock can assign roles")
  {
    destination.call{value: address(this).balance}('');
  }
  function emergencyWithdraw(address _token, address destination)
    external 
    onlyRole(TIMELOCK_ROLE, "Must have timelock role")
  {
    ERC20 token = ERC20(_token);
    token.safeTransfer(destination, token.balanceOf(address(this)));
  }
  function partialWithdrawGAS(address payable destination, uint256 amount)
    external 
    onlyRole(TIMELOCK_ROLE, "Must have timelock role")
  {
    destination.call{value: amount}('');
  }
  function partialWithdraw(address _token, address destination, uint256 amount)
    external 
    onlyRole(TIMELOCK_ROLE, "Only timelock can assign roles")
  {
    ERC20 token = ERC20(_token);
    token.safeTransfer(destination, amount);
  }
  function _swapRole(address newAccount, address oldAccount, bytes32 role) internal {
    revokeRole(role, oldAccount);
    _setupRole(role, newAccount);
  }
  function _roleSetup(bytes32 role, address account) internal {
    _setupRole(role, account);
    _setRoleAdmin(role, ADMIN_ROLE);
  }
  function _onlyRole(bytes32 role, string memory reason) internal view {
    require(
      hasRole(
        role,
        _msgSender()
      ),
      reason
    );
  }
  function _notSameBlock() internal {
    require(
      block.number > lastBlock[_msgSender()],
      "Can't carry out actions in the same block"
    );
    lastBlock[_msgSender()] = block.number;
  }
  modifier onlyRole(bytes32 role, string memory reason) {
    _onlyRole(role, reason);
    _;
  }
  modifier notSameBlock() {
    _notSameBlock();
    _;
  }
}
struct UserState {
  uint256 bonded;
  uint256 bondedEpoch;
}
struct EpochState {
  uint256 lastTotalBonded;
  uint256 lastUpdateTime;
  uint256 cumulativeTotalBonded;
}
contract Bonding is Initializable, Permissions {
  ERC20 public malt;
  ERC20 public rewardToken;
  ERC20 public stakeToken;
  IDAO public dao;
  IMiningService public miningService;
  IDexHandler public dexHandler;
  IMaltDataLab public maltDataLab;
  uint256 internal _globalBonded;
  uint256 internal _currentEpoch;
  address internal offering;
  mapping(address => UserState) internal userState;
  mapping(uint256 => EpochState) internal epochState;
  event Bond(address indexed account, uint256 value);
  event Unbond(address indexed account, uint256 value);
  event UnbondAndBreak(address indexed account, uint256 amountLPToken, uint256 amountMalt, uint256 amountReward);
  function initialize(
    address _timelock,
    address initialAdmin,
    address _malt,
    address _rewardToken,
    address _stakeToken,
    address _dao,
    address _miningService,
    address _offering,
    address _dexHandler,
    address _maltDataLab
  ) external initializer {
    _adminSetup(_timelock);
    _setupRole(ADMIN_ROLE, initialAdmin);
    dao = IDAO(_dao);
    offering = _offering;
    stakeToken = ERC20(_stakeToken);
    miningService = IMiningService(_miningService);
    dexHandler = IDexHandler(_dexHandler);
    malt = ERC20(_malt);
    rewardToken = ERC20(_rewardToken);
    maltDataLab = IMaltDataLab(_maltDataLab);
  }
  function bond(uint256 amount) external {
    bondToAccount(msg.sender, amount);
  }
  function bondToAccount(address account, uint256 amount)
    public
  {
    if (msg.sender != offering) {
      _notSameBlock();
    }
    require(amount > 0, "Cannot bond 0");
    miningService.onBond(account, amount);
    _bond(account, amount);
  }
  function unbond(uint256 amount)
    external
  {
    require(amount > 0, "Cannot unbond 0");
    uint256 bondedBalance = balanceOfBonded(msg.sender);
    require(bondedBalance > 0, "< bonded balance");
    require(amount <= bondedBalance, "< bonded balance");
    if (amount.add(1e16) > bondedBalance) {
      amount = bondedBalance;
    }
    miningService.onUnbond(msg.sender, amount);
    _unbond(amount);
  }
  function unbondAndBreak(uint256 amount)
    external
  {
    require(amount > 0, "Cannot unbond 0");
    uint256 bondedBalance = balanceOfBonded(msg.sender);
    require(bondedBalance > 0, "< bonded balance");
    require(amount <= bondedBalance, "< bonded balance");
    if (amount.add(1e16) > bondedBalance) {
      amount = bondedBalance;
    }
    miningService.onUnbond(msg.sender, amount);
    _unbondAndBreak(amount);
  }
  function averageBondedValue(uint256 epoch) public view returns (uint256) {
    EpochState storage state = epochState[epoch];
    uint256 epochLength = dao.epochLength();
    uint256 timeElapsed = epochLength;
    uint256 epochStartTime = dao.getEpochStartTime(epoch);
    uint256 diff;
    uint256 lastUpdateTime = state.lastUpdateTime;
    uint256 lastTotalBonded = state.lastTotalBonded;
    if (lastUpdateTime == 0) {
      lastUpdateTime = epochStartTime;
    }
    if (lastTotalBonded == 0) {
      lastTotalBonded = _globalBonded;
    }
    if (block.timestamp < epochStartTime) {
      return 0;
    }
    if (epochStartTime + epochLength <= lastUpdateTime) {
      return maltDataLab.realValueOfLPToken((state.cumulativeTotalBonded) / epochLength);
    }
    if (epochStartTime + epochLength < block.timestamp) {
      diff = (epochStartTime + epochLength) - lastUpdateTime;
    } else {
      diff = block.timestamp - lastUpdateTime;
      timeElapsed = block.timestamp - epochStartTime;
    }
    if (timeElapsed == 0) {
      return maltDataLab.realValueOfLPToken(lastTotalBonded);
    }
    uint256 endValue = state.cumulativeTotalBonded + (lastTotalBonded.mul(diff));
    return maltDataLab.realValueOfLPToken((endValue) / timeElapsed);
  }
  function totalBonded() public view returns (uint256) {
    return _globalBonded;
  }
  function balanceOfBonded(address account) public view returns (uint256) {
    return userState[account].bonded;
  }
  function bondedEpoch(address account) public view returns (uint256) {
    return userState[account].bondedEpoch;
  }
  function epochData(uint256 epoch) public view returns(uint256, uint256, uint256) {
    return (epochState[epoch].lastTotalBonded, epochState[epoch].lastUpdateTime, epochState[epoch].cumulativeTotalBonded);
  }
  function _balanceCheck() internal view {
    require(stakeToken.balanceOf(address(this)) >= totalBonded(), "Balance inconsistency");
  }
  function _bond(address account, uint256 amount) internal {
    stakeToken.safeTransferFrom(msg.sender, address(this), amount);
    _addToBonded(account, amount);
    _balanceCheck();
    emit Bond(account, amount);
  }
  function _unbond(uint256 amountLPToken) internal notSameBlock {
    _removeFromBonded(msg.sender, amountLPToken, "LP: Insufficient bonded balance");
    stakeToken.safeTransfer(msg.sender, amountLPToken);
    _balanceCheck();
    emit Unbond(msg.sender, amountLPToken);
  }
  function _unbondAndBreak(uint256 amountLPToken) internal notSameBlock {
    _removeFromBonded(msg.sender, amountLPToken, "LP: Insufficient bonded balance");
    stakeToken.safeTransfer(address(dexHandler), amountLPToken);
    (uint256 amountMalt, uint256 amountReward) = dexHandler.removeLiquidity();
    malt.safeTransfer(msg.sender, amountMalt);
    rewardToken.safeTransfer(msg.sender, amountReward);
    _balanceCheck();
    emit UnbondAndBreak(msg.sender, amountLPToken, amountMalt, amountReward);
  }
  function _addToBonded(address account, uint256 amount) internal {
    userState[account].bonded = userState[account].bonded.add(amount);
    _updateEpochState(_globalBonded.add(amount));
    if (userState[account].bondedEpoch == 0) {
      userState[account].bondedEpoch = dao.epoch();
    }
  }
  function _removeFromBonded(address account, uint256 amount, string memory reason) internal {
    userState[account].bonded = userState[account].bonded.sub(amount, reason);
    _updateEpochState(_globalBonded.sub(amount, reason));
  }
  function _updateEpochState(uint256 newTotalBonded) internal {
    EpochState storage state = epochState[_currentEpoch];
    uint256 epoch = dao.epoch();
    uint256 epochStartTime = dao.getEpochStartTime(_currentEpoch);
    uint256 lastUpdateTime = state.lastUpdateTime;
    uint256 lengthOfEpoch = dao.epochLength();
    uint256 epochEndTime = epochStartTime + lengthOfEpoch;
    if (lastUpdateTime == 0) {
      lastUpdateTime = epochStartTime;
    }
    if (lastUpdateTime > epochEndTime) {
      lastUpdateTime = epochEndTime;
    }
    if (epoch == _currentEpoch) {
      uint256 finalTime = block.timestamp;
      if (block.timestamp > epochEndTime) {
        finalTime = epochEndTime;
      } 
      uint256 diff = finalTime - lastUpdateTime;
      if (diff > 0) {
        state.cumulativeTotalBonded = state.cumulativeTotalBonded + (state.lastTotalBonded.mul(diff));
        state.lastUpdateTime = finalTime;
        state.lastTotalBonded = newTotalBonded;
      }
    } else {
      uint256 diff = epochEndTime - lastUpdateTime;
      state.cumulativeTotalBonded = state.cumulativeTotalBonded + (state.lastTotalBonded.mul(diff));
      state.lastUpdateTime = epochEndTime;
      state.lastTotalBonded = _globalBonded;
      for (uint256 i = _currentEpoch + 1; i <= epoch; i += 1) {
        state = epochState[i];
        epochStartTime = dao.getEpochStartTime(i);
        epochEndTime = epochStartTime + lengthOfEpoch;
        state.lastTotalBonded = _globalBonded;
        if (epochEndTime < block.timestamp) {
          diff = lengthOfEpoch;
          state.lastUpdateTime = epochEndTime;
        } else {
          diff = block.timestamp - epochStartTime;
          state.lastUpdateTime = block.timestamp;
        }
        state.cumulativeTotalBonded = state.lastTotalBonded.mul(diff);
      }
      state.lastTotalBonded = newTotalBonded;
      _currentEpoch = epoch;
    } 
    _globalBonded = newTotalBonded;
  }
  function setMiningService(address _miningService)
    public
    onlyRole(ADMIN_ROLE, "Must have admin privs")
  {
    require(_miningService != address(0), "Cannot set 0 address");
    miningService = IMiningService(_miningService);
  }
  function setDAO(address _dao)
    public
    onlyRole(ADMIN_ROLE, "Must have admin privs")
  {
    require(_dao != address(0), "Cannot set 0 address");
    dao = IDAO(_dao);
  }
  function setDexHandler(address _dexHandler)
    public
    onlyRole(ADMIN_ROLE, "Must have admin privs")
  {
    require(_dexHandler != address(0), "Cannot set 0 address");
    dexHandler = IDexHandler(_dexHandler);
  }
  function setCurrentEpoch(uint256 _epoch)
    public
    onlyRole(ADMIN_ROLE, "Must have admin privs")
  {
    _currentEpoch = _epoch;
  }
}