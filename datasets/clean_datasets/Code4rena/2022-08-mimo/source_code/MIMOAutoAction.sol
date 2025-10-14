pragma solidity 0.8.10;
pragma experimental ABIEncoderV2;
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
library CustomErrors {
  error CANNOT_SET_TO_ADDRESS_ZERO();
  error INITIATOR_NOT_AUTHORIZED(address actual, address expected);
  error CALLER_NOT_LENDING_POOL(address actual, address expected);
  error CANNOT_REPAY_FLASHLOAN();
  error INVALID_AGGREGATOR();
  error AGGREGATOR_CALL_FAILED();
  error EXECUTION_NOT_AUTHORIZED(address owner, address caller, address target, bytes4 selector);
  error EXECUTION_REVERTED();
  error NOT_OWNER(address owner, address caller);
  error OWNER_CHANGED(address originalOwner, address newOwner);
  error TARGET_INVALID(address target);
  error CALLER_NOT_VAULT_OWNER(address callerProxy, address vaultOwner);
  error CALLER_NOT_PROTOCOL_MANAGER();
  error MANAGER_NOT_LISTED();
  error VAULT_NOT_UNDER_MANAGEMENT();
  error CALLER_NOT_SELECTED_MANAGER();
  error PROXY_ALREADY_EXISTS(address owner);
  error MAX_OPERATIONS_REACHED();
  error MINT_AMOUNT_GREATER_THAN_VAULT_DEBT();
  error VAULT_VALUE_CHANGE_TOO_HIGH();
  error FINAL_VAULT_RATIO_TOO_LOW(uint256 minRatio, uint256 actualRatio);
  error VAULT_NOT_AUTOMATED();
  error VAULT_TRIGGER_RATIO_NOT_REACHED(uint256 actual, uint256 expected);
  error TARGETS_LENGTH_DIFFERENT_THAN_DATA_LENGTH(uint256 targetsLength, uint256 dataLength);
  error LOW_LEVEL_CALL_FAILED();
  error REBALANCE_AMOUNT_CANNOT_BE_ZERO();
  error VARIABLE_FEE_TOO_HIGH(uint256 maxVarFee, uint256 actualVarFee);
}
library WadRayMath {
  uint256 internal constant WAD = 1e18;
  uint256 internal constant HALF_WAD = 0.5e18;
  uint256 internal constant RAY = 1e27;
  uint256 internal constant HALF_RAY = 0.5e27;
  uint256 internal constant WAD_RAY_RATIO = 1e9;
  function wadMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_WAD), b))))) {
        revert(0, 0)
      }
      c := div(add(mul(a, b), HALF_WAD), WAD)
    }
  }
  function wadDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if or(iszero(b), iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), WAD))))) {
        revert(0, 0)
      }
      c := div(add(mul(a, WAD), div(b, 2)), b)
    }
  }
  function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))) {
        revert(0, 0)
      }
      c := div(add(mul(a, b), HALF_RAY), RAY)
    }
  }
  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if or(iszero(b), iszero(iszero(gt(a, div(sub(not(0), div(b, 2)), RAY))))) {
        revert(0, 0)
      }
      c := div(add(mul(a, RAY), div(b, 2)), b)
    }
  }
  function rayToWad(uint256 a) internal pure returns (uint256 b) {
    assembly {
      b := div(a, WAD_RAY_RATIO)
      let remainder := mod(a, WAD_RAY_RATIO)
      if iszero(lt(remainder, div(WAD_RAY_RATIO, 2))) {
        b := add(b, 1)
      }
    }
  }
  function wadToRay(uint256 a) internal pure returns (uint256 b) {
    assembly {
      b := mul(a, WAD_RAY_RATIO)
      if iszero(eq(div(b, WAD_RAY_RATIO), a)) {
        revert(0, 0)
      }
    }
  }
}
interface IMIMOProxy {
  event Execute(address indexed target, bytes data, bytes response);
  event TransferOwnership(address indexed oldOwner, address indexed newOwner);
  function initialize() external;
  function getPermission(
    address envoy,
    address target,
    bytes4 selector
  ) external view returns (bool);
  function owner() external view returns (address);
  function minGasReserve() external view returns (uint256);
  function execute(address target, bytes calldata data) external payable returns (bytes memory response);
  function setPermission(
    address envoy,
    address target,
    bytes4 selector,
    bool permission
  ) external;
  function transferOwnership(address newOwner) external;
  function multicall(address[] calldata targets, bytes[] calldata data) external returns (bytes[] memory);
}
interface IMIMOProxyFactory {
  event DeployProxy(address indexed deployer, address indexed owner, address proxy);
  function isProxy(address proxy) external view returns (bool result);
  function VERSION() external view returns (uint256);
  function deploy() external returns (IMIMOProxy proxy);
  function deployFor(address owner) external returns (IMIMOProxy proxy);
}
interface IAccessController {
  event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);
  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
  function grantRole(bytes32 role, address account) external;
  function revokeRole(bytes32 role, address account) external;
  function renounceRole(bytes32 role, address account) external;
  function MANAGER_ROLE() external view returns (bytes32);
  function MINTER_ROLE() external view returns (bytes32);
  function hasRole(bytes32 role, address account) external view returns (bool);
  function getRoleMemberCount(bytes32 role) external view returns (uint256);
  function getRoleMember(bytes32 role, uint256 index) external view returns (address);
  function getRoleAdmin(bytes32 role) external view returns (bytes32);
}
interface IConfigProvider {
  struct CollateralConfig {
    address collateralType;
    uint256 debtLimit;
    uint256 liquidationRatio;
    uint256 minCollateralRatio;
    uint256 borrowRate;
    uint256 originationFee;
    uint256 liquidationBonus;
    uint256 liquidationFee;
  }
  event CollateralUpdated(
    address indexed collateralType,
    uint256 debtLimit,
    uint256 liquidationRatio,
    uint256 minCollateralRatio,
    uint256 borrowRate,
    uint256 originationFee,
    uint256 liquidationBonus,
    uint256 liquidationFee
  );
  event CollateralRemoved(address indexed collateralType);
  function setCollateralConfig(
    address _collateralType,
    uint256 _debtLimit,
    uint256 _liquidationRatio,
    uint256 _minCollateralRatio,
    uint256 _borrowRate,
    uint256 _originationFee,
    uint256 _liquidationBonus,
    uint256 _liquidationFee
  ) external;
  function removeCollateral(address _collateralType) external;
  function setCollateralDebtLimit(address _collateralType, uint256 _debtLimit) external;
  function setCollateralLiquidationRatio(address _collateralType, uint256 _liquidationRatio) external;
  function setCollateralMinCollateralRatio(address _collateralType, uint256 _minCollateralRatio) external;
  function setCollateralBorrowRate(address _collateralType, uint256 _borrowRate) external;
  function setCollateralOriginationFee(address _collateralType, uint256 _originationFee) external;
  function setCollateralLiquidationBonus(address _collateralType, uint256 _liquidationBonus) external;
  function setCollateralLiquidationFee(address _collateralType, uint256 _liquidationFee) external;
  function setMinVotingPeriod(uint256 _minVotingPeriod) external;
  function setMaxVotingPeriod(uint256 _maxVotingPeriod) external;
  function setVotingQuorum(uint256 _votingQuorum) external;
  function setProposalThreshold(uint256 _proposalThreshold) external;
  function a() external view returns (IAddressProvider);
  function collateralConfigs(uint256 _id) external view returns (CollateralConfig memory);
  function collateralIds(address _collateralType) external view returns (uint256);
  function numCollateralConfigs() external view returns (uint256);
  function minVotingPeriod() external view returns (uint256);
  function maxVotingPeriod() external view returns (uint256);
  function votingQuorum() external view returns (uint256);
  function proposalThreshold() external view returns (uint256);
  function collateralDebtLimit(address _collateralType) external view returns (uint256);
  function collateralLiquidationRatio(address _collateralType) external view returns (uint256);
  function collateralMinCollateralRatio(address _collateralType) external view returns (uint256);
  function collateralBorrowRate(address _collateralType) external view returns (uint256);
  function collateralOriginationFee(address _collateralType) external view returns (uint256);
  function collateralLiquidationBonus(address _collateralType) external view returns (uint256);
  function collateralLiquidationFee(address _collateralType) external view returns (uint256);
}
interface ISTABLEX is IERC20 {
    function mint(address account, uint256 amount) external;
    function burn(address account, uint256 amount) external;
    function a() external view returns (IAddressProvider);
}
interface IPriceFeed {
  event OracleUpdated(address indexed asset, address oracle, address sender);
  event EurOracleUpdated(address oracle, address sender);
  function setAssetOracle(address _asset, address _oracle) external;
  function setEurOracle(address _oracle) external;
  function a() external view returns (IAddressProvider);
  function assetOracles(address _asset) external view returns (AggregatorV3Interface);
  function eurOracle() external view returns (AggregatorV3Interface);
  function getAssetPrice(address _asset) external view returns (uint256);
  function convertFrom(address _asset, uint256 _amount) external view returns (uint256);
  function convertTo(address _asset, uint256 _amount) external view returns (uint256);
}
interface IRatesManager {
  function a() external view returns (IAddressProvider);
  function annualizedBorrowRate(uint256 _currentBorrowRate) external pure returns (uint256);
  function calculateDebt(uint256 _baseDebt, uint256 _cumulativeRate) external pure returns (uint256);
  function calculateBaseDebt(uint256 _debt, uint256 _cumulativeRate) external pure returns (uint256);
  function calculateCumulativeRate(
    uint256 _borrowRate,
    uint256 _cumulativeRate,
    uint256 _timeElapsed
  ) external view returns (uint256);
}
interface ILiquidationManager {
  function a() external view returns (IAddressProvider);
  function calculateHealthFactor(
    uint256 _collateralValue,
    uint256 _vaultDebt,
    uint256 _minRatio
  ) external view returns (uint256 healthFactor);
  function liquidationBonus(address _collateralType, uint256 _amount) external view returns (uint256 bonus);
  function applyLiquidationDiscount(address _collateralType, uint256 _amount)
    external
    view
    returns (uint256 discountedAmount);
  function isHealthy(
    uint256 _collateralValue,
    uint256 _vaultDebt,
    uint256 _minRatio
  ) external view returns (bool);
}
interface IWETH is IERC20 {
  function deposit() external payable;
  function transfer(address to, uint256 value) external returns (bool);
  function withdraw(uint256 wad) external;
  function approve(address guy, uint256 wad) external returns (bool);
}
interface IGovernorAlpha {
  enum ProposalState { Active, Canceled, Defeated, Succeeded, Queued, Expired, Executed }
  struct Proposal {
    uint256 id;
    address proposer;
    uint256 eta;
    address[] targets;
    uint256[] values;
    string[] signatures;
    bytes[] calldatas;
    uint256 startTime;
    uint256 endTime;
    uint256 forVotes;
    uint256 againstVotes;
    bool canceled;
    bool executed;
    mapping(address => Receipt) receipts;
  }
  struct Receipt {
    bool hasVoted;
    bool support;
    uint256 votes;
  }
  event ProposalCreated(
    uint256 id,
    address proposer,
    address[] targets,
    uint256[] values,
    string[] signatures,
    bytes[] calldatas,
    uint256 startTime,
    uint256 endTime,
    string description
  );
  event VoteCast(address voter, uint256 proposalId, bool support, uint256 votes);
  event ProposalCanceled(uint256 id);
  event ProposalQueued(uint256 id, uint256 eta);
  event ProposalExecuted(uint256 id);
  function propose(
    address[] memory targets,
    uint256[] memory values,
    string[] memory signatures,
    bytes[] memory calldatas,
    string memory description,
    uint256 endTime
  ) external returns (uint256);
  function queue(uint256 proposalId) external;
  function execute(uint256 proposalId) external payable;
  function cancel(uint256 proposalId) external;
  function castVote(uint256 proposalId, bool support) external;
  function getActions(uint256 proposalId)
    external
    view
    returns (
      address[] memory targets,
      uint256[] memory values,
      string[] memory signatures,
      bytes[] memory calldatas
    );
  function getReceipt(uint256 proposalId, address voter) external view returns (Receipt memory);
  function state(uint256 proposalId) external view returns (ProposalState);
  function quorumVotes() external view returns (uint256);
  function proposalThreshold() external view returns (uint256);
}
interface ITimelock {
  event NewAdmin(address indexed newAdmin);
  event NewPendingAdmin(address indexed newPendingAdmin);
  event NewDelay(uint256 indexed newDelay);
  event CancelTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );
  event ExecuteTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );
  event QueueTransaction(
    bytes32 indexed txHash,
    address indexed target,
    uint256 value,
    string signature,
    bytes data,
    uint256 eta
  );
  function acceptAdmin() external;
  function queueTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external returns (bytes32);
  function cancelTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external;
  function executeTransaction(
    address target,
    uint256 value,
    string calldata signature,
    bytes calldata data,
    uint256 eta
  ) external payable returns (bytes memory);
  function delay() external view returns (uint256);
  function GRACE_PERIOD() external view returns (uint256);
  function queuedTransactions(bytes32 hash) external view returns (bool);
}
interface IGenericMiner {
  struct UserInfo {
    uint256 stake;
    uint256 accAmountPerShare; 
  }
  event StakeIncreased(address indexed user, uint256 stake);
  event StakeDecreased(address indexed user, uint256 stake);
  function releaseMIMO(address _user) external;
  function a() external view returns (IGovernanceAddressProvider);
  function stake(address _user) external view returns (uint256);
  function pendingMIMO(address _user) external view returns (uint256);
  function totalStake() external view returns (uint256);
  function userInfo(address _user) external view returns (UserInfo memory);
}
interface IVotingEscrow {
  enum LockAction {
    CREATE_LOCK,
    INCREASE_LOCK_AMOUNT,
    INCREASE_LOCK_TIME
  }
  struct LockedBalance {
    uint256 amount;
    uint256 end;
  }
  event Deposit(address indexed provider, uint256 value, uint256 locktime, LockAction indexed action, uint256 ts);
  event Withdraw(address indexed provider, uint256 value, uint256 ts);
  event Expired();
  function createLock(uint256 _value, uint256 _unlockTime) external;
  function increaseLockAmount(uint256 _value) external;
  function increaseLockLength(uint256 _unlockTime) external;
  function withdraw() external;
  function expireContract() external;
  function setMiner(IGenericMiner _miner) external;
  function setMinimumLockTime(uint256 _minimumLockTime) external;
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint256);
  function balanceOf(address _owner) external view returns (uint256);
  function balanceOfAt(address _owner, uint256 _blockTime) external view returns (uint256);
  function stakingToken() external view returns (IERC20);
}
interface IMIMO is IERC20 {
  function burn(address account, uint256 amount) external;
  function mint(address account, uint256 amount) external;
}
interface IGovernanceAddressProvider {
  function setParallelAddressProvider(IAddressProvider _parallel) external;
  function setMIMO(IMIMO _mimo) external;
  function setDebtNotifier(IDebtNotifier _debtNotifier) external;
  function setGovernorAlpha(IGovernorAlpha _governorAlpha) external;
  function setTimelock(ITimelock _timelock) external;
  function setVotingEscrow(IVotingEscrow _votingEscrow) external;
  function controller() external view returns (IAccessController);
  function parallel() external view returns (IAddressProvider);
  function mimo() external view returns (IMIMO);
  function debtNotifier() external view returns (IDebtNotifier);
  function governorAlpha() external view returns (IGovernorAlpha);
  function timelock() external view returns (ITimelock);
  function votingEscrow() external view returns (IVotingEscrow);
}
interface ISupplyMiner {
  function baseDebtChanged(address user, uint256 newBaseDebt) external;
}
interface IDebtNotifier {
    function debtChanged(uint256 _vaultId) external;
    function setCollateralSupplyMiner(
        address collateral,
        ISupplyMiner supplyMiner
    ) external;
    function a() external view returns (IGovernanceAddressProvider);
    function collateralSupplyMinerMapping(address collateral)
        external
        view
        returns (ISupplyMiner);
}
interface IConfigProviderV1 {
  struct CollateralConfig {
    address collateralType;
    uint256 debtLimit;
    uint256 minCollateralRatio;
    uint256 borrowRate;
    uint256 originationFee;
  }
  event CollateralUpdated(
    address indexed collateralType,
    uint256 debtLimit,
    uint256 minCollateralRatio,
    uint256 borrowRate,
    uint256 originationFee
  );
  event CollateralRemoved(address indexed collateralType);
  function setCollateralConfig(
    address _collateralType,
    uint256 _debtLimit,
    uint256 _minCollateralRatio,
    uint256 _borrowRate,
    uint256 _originationFee
  ) external;
  function removeCollateral(address _collateralType) external;
  function setCollateralDebtLimit(address _collateralType, uint256 _debtLimit) external;
  function setCollateralMinCollateralRatio(address _collateralType, uint256 _minCollateralRatio) external;
  function setCollateralBorrowRate(address _collateralType, uint256 _borrowRate) external;
  function setCollateralOriginationFee(address _collateralType, uint256 _originationFee) external;
  function setLiquidationBonus(uint256 _bonus) external;
  function a() external view returns (IAddressProviderV1);
  function collateralConfigs(uint256 _id) external view returns (CollateralConfig memory);
  function collateralIds(address _collateralType) external view returns (uint256);
  function numCollateralConfigs() external view returns (uint256);
  function liquidationBonus() external view returns (uint256);
  function collateralDebtLimit(address _collateralType) external view returns (uint256);
  function collateralMinCollateralRatio(address _collateralType) external view returns (uint256);
  function collateralBorrowRate(address _collateralType) external view returns (uint256);
  function collateralOriginationFee(address _collateralType) external view returns (uint256);
}
interface ILiquidationManagerV1 {
  function a() external view returns (IAddressProviderV1);
  function calculateHealthFactor(
    address _collateralType,
    uint256 _collateralValue,
    uint256 _vaultDebt
  ) external view returns (uint256 healthFactor);
  function liquidationBonus(uint256 _amount) external view returns (uint256 bonus);
  function applyLiquidationDiscount(uint256 _amount) external view returns (uint256 discountedAmount);
  function isHealthy(
    address _collateralType,
    uint256 _collateralValue,
    uint256 _vaultDebt
  ) external view returns (bool);
}
interface IAddressProviderV1 {
  function setAccessController(IAccessController _controller) external;
  function setConfigProvider(IConfigProviderV1 _config) external;
  function setVaultsCore(IVaultsCoreV1 _core) external;
  function setStableX(ISTABLEX _stablex) external;
  function setRatesManager(IRatesManager _ratesManager) external;
  function setPriceFeed(IPriceFeed _priceFeed) external;
  function setLiquidationManager(ILiquidationManagerV1 _liquidationManager) external;
  function setVaultsDataProvider(IVaultsDataProvider _vaultsData) external;
  function setFeeDistributor(IFeeDistributor _feeDistributor) external;
  function controller() external view returns (IAccessController);
  function config() external view returns (IConfigProviderV1);
  function core() external view returns (IVaultsCoreV1);
  function stablex() external view returns (ISTABLEX);
  function ratesManager() external view returns (IRatesManager);
  function priceFeed() external view returns (IPriceFeed);
  function liquidationManager() external view returns (ILiquidationManagerV1);
  function vaultsData() external view returns (IVaultsDataProvider);
  function feeDistributor() external view returns (IFeeDistributor);
}
interface IVaultsCoreV1 {
  event Opened(uint256 indexed vaultId, address indexed collateralType, address indexed owner);
  event Deposited(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Withdrawn(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Borrowed(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Repaid(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Liquidated(
    uint256 indexed vaultId,
    uint256 debtRepaid,
    uint256 collateralLiquidated,
    address indexed owner,
    address indexed sender
  );
  event CumulativeRateUpdated(address indexed collateralType, uint256 elapsedTime, uint256 newCumulativeRate); 
  event InsurancePaid(uint256 indexed vaultId, uint256 insuranceAmount, address indexed sender);
  function deposit(address _collateralType, uint256 _amount) external;
  function withdraw(uint256 _vaultId, uint256 _amount) external;
  function withdrawAll(uint256 _vaultId) external;
  function borrow(uint256 _vaultId, uint256 _amount) external;
  function repayAll(uint256 _vaultId) external;
  function repay(uint256 _vaultId, uint256 _amount) external;
  function liquidate(uint256 _vaultId) external;
  function initializeRates(address _collateralType) external;
  function refresh() external;
  function refreshCollateral(address collateralType) external;
  function upgrade(address _newVaultsCore) external;
  function a() external view returns (IAddressProviderV1);
  function availableIncome() external view returns (uint256);
  function cumulativeRates(address _collateralType) external view returns (uint256);
  function lastRefresh(address _collateralType) external view returns (uint256);
}
interface IVaultsCoreState {
  event CumulativeRateUpdated(address indexed collateralType, uint256 elapsedTime, uint256 newCumulativeRate); 
  function initializeRates(address _collateralType) external;
  function refresh() external;
  function refreshCollateral(address collateralType) external;
  function syncState(IVaultsCoreState _stateAddress) external;
  function syncStateFromV1(IVaultsCoreV1 _core) external;
  function a() external view returns (IAddressProvider);
  function availableIncome() external view returns (uint256);
  function cumulativeRates(address _collateralType) external view returns (uint256);
  function lastRefresh(address _collateralType) external view returns (uint256);
  function synced() external view returns (bool);
}
interface IVaultsCore {
  event Opened(uint256 indexed vaultId, address indexed collateralType, address indexed owner);
  event Deposited(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Withdrawn(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Borrowed(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Repaid(uint256 indexed vaultId, uint256 amount, address indexed sender);
  event Liquidated(
    uint256 indexed vaultId,
    uint256 debtRepaid,
    uint256 collateralLiquidated,
    address indexed owner,
    address indexed sender
  );
  event InsurancePaid(uint256 indexed vaultId, uint256 insuranceAmount, address indexed sender);
  function deposit(address _collateralType, uint256 _amount) external;
  function depositETH() external payable;
  function depositByVaultId(uint256 _vaultId, uint256 _amount) external;
  function depositETHByVaultId(uint256 _vaultId) external payable;
  function depositAndBorrow(
    address _collateralType,
    uint256 _depositAmount,
    uint256 _borrowAmount
  ) external;
  function depositETHAndBorrow(uint256 _borrowAmount) external payable;
  function withdraw(uint256 _vaultId, uint256 _amount) external;
  function withdrawETH(uint256 _vaultId, uint256 _amount) external;
  function borrow(uint256 _vaultId, uint256 _amount) external;
  function repayAll(uint256 _vaultId) external;
  function repay(uint256 _vaultId, uint256 _amount) external;
  function liquidate(uint256 _vaultId) external;
  function liquidatePartial(uint256 _vaultId, uint256 _amount) external;
  function upgrade(address payable _newVaultsCore) external;
  function acceptUpgrade(address payable _oldVaultsCore) external;
  function setDebtNotifier(IDebtNotifier _debtNotifier) external;
  function a() external view returns (IAddressProvider);
  function WETH() external view returns (IWETH);
  function debtNotifier() external view returns (IDebtNotifier);
  function state() external view returns (IVaultsCoreState);
  function cumulativeRates(address _collateralType) external view returns (uint256);
}
interface IFeeDistributor {
  event PayeeAdded(address indexed account, uint256 shares);
  event FeeReleased(uint256 income, uint256 releasedAt);
  function release() external;
  function changePayees(address[] memory _payees, uint256[] memory _shares) external;
  function a() external view returns (IAddressProvider);
  function lastReleasedAt() external view returns (uint256);
  function getPayees() external view returns (address[] memory);
  function totalShares() external view returns (uint256);
  function shares(address payee) external view returns (uint256);
}
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
interface IVaultsDataProvider {
  struct Vault {
    address collateralType;
    address owner;
    uint256 collateralBalance;
    uint256 baseDebt;
    uint256 createdAt;
  }
  function createVault(address _collateralType, address _owner) external returns (uint256);
  function setCollateralBalance(uint256 _id, uint256 _balance) external;
  function setBaseDebt(uint256 _id, uint256 _newBaseDebt) external;
  function a() external view returns (IAddressProvider);
  function baseDebt(address _collateralType) external view returns (uint256);
  function vaultCount() external view returns (uint256);
  function vaults(uint256 _id) external view returns (Vault memory);
  function vaultOwner(uint256 _id) external view returns (address);
  function vaultCollateralType(uint256 _id) external view returns (address);
  function vaultCollateralBalance(uint256 _id) external view returns (uint256);
  function vaultBaseDebt(uint256 _id) external view returns (uint256);
  function vaultId(address _collateralType, address _owner) external view returns (uint256);
  function vaultExists(uint256 _id) external view returns (bool);
  function vaultDebt(uint256 _vaultId) external view returns (uint256);
  function debt() external view returns (uint256);
  function collateralDebt(address _collateralType) external view returns (uint256);
}
interface IAddressProvider {
  function setAccessController(IAccessController _controller) external;
  function setConfigProvider(IConfigProvider _config) external;
  function setVaultsCore(IVaultsCore _core) external;
  function setStableX(ISTABLEX _stablex) external;
  function setRatesManager(IRatesManager _ratesManager) external;
  function setPriceFeed(IPriceFeed _priceFeed) external;
  function setLiquidationManager(ILiquidationManager _liquidationManager) external;
  function setVaultsDataProvider(IVaultsDataProvider _vaultsData) external;
  function setFeeDistributor(IFeeDistributor _feeDistributor) external;
  function controller() external view returns (IAccessController);
  function config() external view returns (IConfigProvider);
  function core() external view returns (IVaultsCore);
  function stablex() external view returns (ISTABLEX);
  function ratesManager() external view returns (IRatesManager);
  function priceFeed() external view returns (IPriceFeed);
  function liquidationManager() external view returns (ILiquidationManager);
  function vaultsData() external view returns (IVaultsDataProvider);
  function feeDistributor() external view returns (IFeeDistributor);
}
interface IMIMOProxyRegistry {
  function factory() external view returns (IMIMOProxyFactory proxyFactory);
  function getCurrentProxy(address owner) external view returns (IMIMOProxy proxy);
  function deploy() external returns (IMIMOProxy proxy);
  function deployFor(address owner) external returns (IMIMOProxy proxy);
}
interface IMIMOAutoAction {
  struct AutomatedVault {
    bool isAutomated;
    address toCollateral;
    uint256 allowedVariation;
    uint256 targetRatio;
    uint256 triggerRatio;
    uint256 mcrBuffer;
    uint256 fixedFee;
    uint256 varFee;
  }
  struct VaultState {
    address collateralType;
    uint256 collateralValue;
    uint256 vaultDebt;
  }
  event AutomationSet(uint256 vaultId, AutomatedVault autoVault);
  function setAutomation(uint256 vaultId, AutomatedVault calldata autoParams) external;
  function a() external view returns (IAddressProvider);
  function proxyRegistry() external view returns (IMIMOProxyRegistry);
  function getAutomatedVault(uint256 vaultId) external view returns (AutomatedVault memory);
  function getOperationTracker(uint256 vaultId) external view returns (uint256);
}
contract MIMOAutoAction is IMIMOAutoAction {
  using WadRayMath for uint256;
  IAddressProvider public immutable a;
  IMIMOProxyRegistry public immutable proxyRegistry;
  mapping(uint256 => AutomatedVault) internal _automatedVaults;
  mapping(uint256 => uint256) internal _operationTracker;
  constructor(IAddressProvider _a, IMIMOProxyRegistry _proxyRegistry) {
    if (address(_a) == address(0) || address(_proxyRegistry) == address(0)) {
      revert CustomErrors.CANNOT_SET_TO_ADDRESS_ZERO();
    }
    a = _a;
    proxyRegistry = _proxyRegistry;
  }
  function setAutomation(uint256 vaultId, AutomatedVault calldata autoParams) external override {
    address vaultOwner = a.vaultsData().vaultOwner(vaultId);
    address mimoProxy = address(proxyRegistry.getCurrentProxy(msg.sender));
    if (mimoProxy != vaultOwner && vaultOwner != msg.sender) {
      revert CustomErrors.CALLER_NOT_VAULT_OWNER(mimoProxy, vaultOwner);
    }
    uint256 toVaultMcr = a.config().collateralMinCollateralRatio(autoParams.toCollateral);
    uint256 maxVarFee = (autoParams.targetRatio.wadDiv(toVaultMcr + autoParams.mcrBuffer) + WadRayMath.WAD).wadDiv(
      autoParams.targetRatio
    );
    if (autoParams.varFee >= maxVarFee) {
      revert CustomErrors.VARIABLE_FEE_TOO_HIGH(maxVarFee, autoParams.varFee);
    }
    _automatedVaults[vaultId] = autoParams;
    emit AutomationSet(vaultId, autoParams);
  }
  function getAutomatedVault(uint256 vaultId) external view override returns (AutomatedVault memory) {
    return _automatedVaults[vaultId];
  }
  function getOperationTracker(uint256 vaultId) external view override returns (uint256) {
    return _operationTracker[vaultId];
  }
  function _getVaultStats(uint256 vaultId) internal view returns (uint256 vaultRatio, VaultState memory vaultState) {
    IAddressProvider _a = a;
    IVaultsDataProvider vaultsData = _a.vaultsData();
    IPriceFeed priceFeed = _a.priceFeed();
    uint256 collateralBalance = vaultsData.vaultCollateralBalance(vaultId);
    address collateralType = vaultsData.vaultCollateralType(vaultId);
    uint256 collateralValue = priceFeed.convertFrom(collateralType, collateralBalance);
    uint256 vaultDebt = vaultsData.vaultDebt(vaultId);
    vaultRatio = vaultDebt == 0 ? type(uint256).max : collateralValue.wadDiv(vaultDebt);
    vaultState = VaultState({ collateralType: collateralType, collateralValue: collateralValue, vaultDebt: vaultDebt });
  }
  function _isVaultVariationAllowed(
    AutomatedVault memory autoVault,
    uint256 rebalanceValue,
    uint256 swapResultValue
  ) internal pure returns (bool) {
    if (swapResultValue >= rebalanceValue) {
      return true;
    }
    uint256 vaultVariation = (rebalanceValue - swapResultValue).wadDiv(rebalanceValue);
    if (vaultVariation > autoVault.allowedVariation) {
      return false;
    }
    return true;
  }
}