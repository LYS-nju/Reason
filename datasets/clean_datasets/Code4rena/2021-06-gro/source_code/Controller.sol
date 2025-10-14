pragma experimental ABIEncoderV2;
pragma solidity ^0.6.12;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IController {
    function stablecoins() external view returns (address[3] memory);
    function vaults() external view returns (address[3] memory);
    function underlyingVaults(uint256 i) external view returns (address vault);
    function curveVault() external view returns (address);
    function pnl() external view returns (address);
    function insurance() external view returns (address);
    function lifeGuard() external view returns (address);
    function buoy() external view returns (address);
    function reward() external view returns (address);
    function isValidBigFish(
        bool pwrd,
        bool deposit,
        uint256 amount
    ) external view returns (bool);
    function withdrawHandler() external view returns (address);
    function emergencyHandler() external view returns (address);
    function depositHandler() external view returns (address);
    function totalAssets() external view returns (uint256);
    function gTokenTotalAssets() external view returns (uint256);
    function eoaOnly(address sender) external;
    function getSkimPercent() external view returns (uint256);
    function gToken(bool _pwrd) external view returns (address);
    function emergencyState() external view returns (bool);
    function deadCoin() external view returns (uint256);
    function distributeStrategyGainLoss(uint256 gain, uint256 loss) external;
    function burnGToken(
        bool pwrd,
        bool all,
        address account,
        uint256 amount,
        uint256 bonus
    ) external;
    function mintGToken(
        bool pwrd,
        address account,
        uint256 amount
    ) external;
    function getUserAssets(bool pwrd, address account) external view returns (uint256 deductUsd);
    function referrals(address account) external view returns (address);
    function addReferral(address account, address referral) external;
    function getStrategiesTargetRatio() external view returns (uint256[] memory);
    function withdrawalFee(bool pwrd) external view returns (uint256);
    function validGTokenDecrease(uint256 amount) external view returns (bool);
}
interface IPausable {
    function paused() external view returns (bool);
}
contract Controllable is Ownable {
    address public controller;
    event ChangeController(address indexed oldController, address indexed newController);
    modifier whenNotPaused() {
        require(!_pausable().paused(), "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(_pausable().paused(), "Pausable: not paused");
        _;
    }
    function ctrlPaused() public view returns (bool) {
        return _pausable().paused();
    }
    function setController(address newController) external onlyOwner {
        require(newController != address(0), "setController: !0x");
        address oldController = controller;
        controller = newController;
        emit ChangeController(oldController, newController);
    }
    function _controller() internal view returns (IController) {
        require(controller != address(0), "Controller not set");
        return IController(controller);
    }
    function _pausable() internal view returns (IPausable) {
        require(controller != address(0), "Controller not set");
        return IPausable(controller);
    }
}
contract Constants {
    uint8 public constant N_COINS = 3;
    uint8 public constant DEFAULT_DECIMALS = 18; 
    uint256 public constant DEFAULT_DECIMALS_FACTOR = uint256(10)**DEFAULT_DECIMALS;
    uint8 public constant CHAINLINK_PRICE_DECIMALS = 8;
    uint256 public constant CHAINLINK_PRICE_DECIMAL_FACTOR = uint256(10)**CHAINLINK_PRICE_DECIMALS;
    uint8 public constant PERCENTAGE_DECIMALS = 4;
    uint256 public constant PERCENTAGE_DECIMAL_FACTOR = uint256(10)**PERCENTAGE_DECIMALS;
    uint256 public constant CURVE_RATIO_DECIMALS = 6;
    uint256 public constant CURVE_RATIO_DECIMALS_FACTOR = uint256(10)**CURVE_RATIO_DECIMALS;
}
interface IToken {
    function factor() external view returns (uint256);
    function factor(uint256 totalAssets) external view returns (uint256);
    function mint(
        address account,
        uint256 _factor,
        uint256 amount
    ) external;
    function burn(
        address account,
        uint256 _factor,
        uint256 amount
    ) external;
    function burnAll(address account) external;
    function totalAssets() external view returns (uint256);
    function getPricePerShare() external view returns (uint256);
    function getShareAssets(uint256 shares) external view returns (uint256);
    function getAssets(address account) external view returns (uint256);
}
interface IVault {
    function withdraw(uint256 amount) external;
    function withdraw(uint256 amount, address recipient) external;
    function withdrawByStrategyOrder(
        uint256 amount,
        address recipient,
        bool reversed
    ) external;
    function withdrawByStrategyIndex(
        uint256 amount,
        address recipient,
        uint256 strategyIndex
    ) external;
    function deposit(uint256 amount) external;
    function updateStrategyRatio(uint256[] calldata strategyRetios) external;
    function totalAssets() external view returns (uint256);
    function getStrategiesLength() external view returns (uint256);
    function strategyHarvestTrigger(uint256 index, uint256 callCost) external view returns (bool);
    function strategyHarvest(uint256 index) external returns (bool);
    function getStrategyAssets(uint256 index) external view returns (uint256);
    function token() external view returns (address);
    function vault() external view returns (address);
    function investTrigger() external view returns (bool);
    function invest() external;
}
contract FixedStablecoins is Constants {
    address public immutable DAI; 
    address public immutable USDC; 
    address public immutable USDT; 
    uint256 public immutable DAI_DECIMALS; 
    uint256 public immutable USDC_DECIMALS; 
    uint256 public immutable USDT_DECIMALS; 
    constructor(address[N_COINS] memory _tokens, uint256[N_COINS] memory _decimals) public {
        DAI = _tokens[0];
        USDC = _tokens[1];
        USDT = _tokens[2];
        DAI_DECIMALS = _decimals[0];
        USDC_DECIMALS = _decimals[1];
        USDT_DECIMALS = _decimals[2];
    }
    function underlyingTokens() internal view returns (address[N_COINS] memory tokens) {
        tokens[0] = DAI;
        tokens[1] = USDC;
        tokens[2] = USDT;
    }
    function getToken(uint256 index) internal view returns (address) {
        if (index == 0) {
            return DAI;
        } else if (index == 1) {
            return USDC;
        } else {
            return USDT;
        }
    }
    function decimals() internal view returns (uint256[N_COINS] memory _decimals) {
        _decimals[0] = DAI_DECIMALS;
        _decimals[1] = USDC_DECIMALS;
        _decimals[2] = USDT_DECIMALS;
    }
    function getDecimal(uint256 index) internal view returns (uint256) {
        if (index == 0) {
            return DAI_DECIMALS;
        } else if (index == 1) {
            return USDC_DECIMALS;
        } else {
            return USDT_DECIMALS;
        }
    }
}
contract FixedGTokens {
    IToken public immutable pwrd;
    IToken public immutable gvt;
    constructor(address _pwrd, address _gvt) public {
        pwrd = IToken(_pwrd);
        gvt = IToken(_gvt);
    }
    function gTokens(bool _pwrd) internal view returns (IToken) {
        if (_pwrd) {
            return pwrd;
        } else {
            return gvt;
        }
    }
}
contract FixedVaults is Constants {
    address public immutable DAI_VAULT;
    address public immutable USDC_VAULT;
    address public immutable USDT_VAULT;
    constructor(address[N_COINS] memory _vaults) public {
        DAI_VAULT = _vaults[0];
        USDC_VAULT = _vaults[1];
        USDT_VAULT = _vaults[2];
    }
    function getVault(uint256 index) internal view returns (address) {
        if (index == 0) {
            return DAI_VAULT;
        } else if (index == 1) {
            return USDC_VAULT;
        } else {
            return USDT_VAULT;
        }
    }
    function vaults() internal view returns (address[N_COINS] memory _vaults) {
        _vaults[0] = DAI_VAULT;
        _vaults[1] = USDC_VAULT;
        _vaults[2] = USDT_VAULT;
    }
}
contract Whitelist is Ownable {
    mapping(address => bool) public whitelist;
    event LogAddToWhitelist(address indexed user);
    event LogRemoveFromWhitelist(address indexed user);
    modifier onlyWhitelist() {
        require(whitelist[msg.sender], "only whitelist");
        _;
    }
    function addToWhitelist(address user) external onlyOwner {
        require(user != address(0), "WhiteList: 0x");
        whitelist[user] = true;
        emit LogAddToWhitelist(user);
    }
    function removeFromWhitelist(address user) external onlyOwner {
        require(user != address(0), "WhiteList: 0x");
        whitelist[user] = false;
        emit LogRemoveFromWhitelist(user);
    }
}
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor () internal {
        _paused = false;
    }
    function paused() public view returns (bool) {
        return _paused;
    }
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
interface ICurve3Pool {
    function coins(uint256 i) external view returns (address);
    function get_virtual_price() external view returns (uint256);
    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);
    function calc_token_amount(uint256[3] calldata inAmounts, bool deposit) external view returns (uint256);
    function balances(int128 i) external view returns (uint256);
}
interface ICurve3Deposit {
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;
    function add_liquidity(uint256[3] calldata uamounts, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 amount, uint256[3] calldata min_uamounts) external;
    function remove_liquidity_imbalance(uint256[3] calldata amounts, uint256 max_burn_amount) external;
    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;
    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
}
interface ICurveMetaPool {
    function coins(uint256 i) external view returns (address);
    function get_virtual_price() external view returns (uint256);
    function get_dy_underlying(
        int128 i,
        int128 j,
        uint256 dx
    ) external view returns (uint256);
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);
    function calc_token_amount(uint256[2] calldata inAmounts, bool deposit) external view returns (uint256);
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external;
    function add_liquidity(uint256[2] calldata uamounts, uint256 min_mint_amount) external;
    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;
}
interface ICurveZap {
    function add_liquidity(uint256[4] calldata uamounts, uint256 min_mint_amount) external;
    function remove_liquidity(uint256 amount, uint256[4] calldata min_uamounts) external;
    function remove_liquidity_imbalance(uint256[4] calldata amounts, uint256 max_burn_amount) external;
    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_uamount
    ) external;
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns (uint256);
    function calc_token_amount(uint256[4] calldata inAmounts, bool deposit) external view returns (uint256);
    function pool() external view returns (address);
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
interface IChainPrice {
    function getPriceFeed(uint256 i) external view returns (uint256 _price);
}
interface IBuoy {
    function safetyCheck() external view returns (bool);
    function updateRatios() external returns (bool);
    function updateRatiosWithTolerance(uint256 tolerance) external returns (bool);
    function lpToUsd(uint256 inAmount) external view returns (uint256);
    function usdToLp(uint256 inAmount) external view returns (uint256);
    function stableToUsd(uint256[3] calldata inAmount, bool deposit) external view returns (uint256);
    function stableToLp(uint256[3] calldata inAmount, bool deposit) external view returns (uint256);
    function singleStableFromLp(uint256 inAmount, int128 i) external view returns (uint256);
    function curvePool() external view returns (ICurve3Pool);
    function getVirtualPrice() external view returns (uint256);
    function singleStableFromUsd(uint256 inAmount, int128 i) external view returns (uint256);
    function singleStableToUsd(uint256 inAmount, uint256 i) external view returns (uint256);
}
interface IERC20Detailed {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
interface IInsurance {
    function calculateDepositDeltasOnAllVaults() external view returns (uint256[3] memory);
    function rebalanceTrigger() external view returns (bool sysNeedRebalance);
    function rebalance() external;
    function calcSkim() external view returns (uint256);
    function rebalanceForWithdraw(uint256 withdrawUsd, bool pwrd) external returns (bool);
    function getDelta(uint256 withdrawUsd) external view returns (uint256[3] memory delta);
    function getVaultDeltaForDeposit(uint256 amount)
        external
        view
        returns (
            uint256[3] memory,
            uint256[3] memory,
            uint256
        );
    function sortVaultsByDelta(bool bigFirst) external view returns (uint256[3] memory vaultIndexes);
    function getStrategiesTargetRatio(uint256 utilRatio) external view returns (uint256[] memory);
    function setUnderlyingTokenPercent(uint256 coinIndex, uint256 percent) external;
}
interface ILifeGuard {
    function assets(uint256 i) external view returns (uint256);
    function totalAssets() external view returns (uint256);
    function getAssets() external view returns (uint256[3] memory);
    function totalAssetsUsd() external view returns (uint256);
    function availableUsd() external view returns (uint256 dollar);
    function availableLP() external view returns (uint256);
    function depositStable(bool rebalance) external returns (uint256);
    function investToCurveVault() external;
    function distributeCurveVault(uint256 amount, uint256[3] memory delta) external returns (uint256[3] memory);
    function deposit() external returns (uint256 usdAmount);
    function withdrawSingleByLiquidity(
        uint256 i,
        uint256 minAmount,
        address recipient
    ) external returns (uint256 usdAmount, uint256 amount);
    function withdrawSingleByExchange(
        uint256 i,
        uint256 minAmount,
        address recipient
    ) external returns (uint256 usdAmount, uint256 amount);
    function invest(uint256 whaleDepositAmount, uint256[3] calldata delta) external returns (uint256 dollarAmount);
    function getBuoy() external view returns (address);
    function investSingle(
        uint256[3] calldata inAmounts,
        uint256 i,
        uint256 j
    ) external returns (uint256 dollarAmount);
    function investToCurveVaultTrigger() external view returns (bool _invest);
}
interface IPnL {
    function calcPnL() external view returns (uint256, uint256);
    function increaseGTokenLastAmount(bool pwrd, uint256 dollarAmount) external;
    function decreaseGTokenLastAmount(
        bool pwrd,
        uint256 dollarAmount,
        uint256 bonus
    ) external;
    function lastGvtAssets() external view returns (uint256);
    function lastPwrdAssets() external view returns (uint256);
    function utilisationRatio() external view returns (uint256);
    function emergencyPnL() external;
    function recover() external;
    function distributeStrategyGainLoss(
        uint256 gain,
        uint256 loss,
        address reward
    ) external;
    function distributePriceChange(uint256 currentTotalAssets) external;
}
contract Controller is Pausable, Ownable, Whitelist, FixedStablecoins, FixedGTokens, IController {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address public override curveVault; 
    bool public preventSmartContracts = false;
    address public override insurance; 
    address public override pnl; 
    address public override lifeGuard; 
    address public override buoy; 
    address public override depositHandler;
    address public override withdrawHandler;
    address public override emergencyHandler;
    uint256 public override deadCoin = 99;
    bool public override emergencyState;
    uint256 public utilisationRatioLimitGvt;
    uint256 public utilisationRatioLimitPwrd;
    uint256 public bigFishThreshold = 100; 
    uint256 public bigFishAbsoluteThreshold = 0; 
    address public override reward;
    mapping(address => bool) public safeAddresses; 
    mapping(uint256 => address) public override underlyingVaults; 
    mapping(address => uint256) public vaultIndexes;
    mapping(address => address) public override referrals;
    mapping(bool => uint256) public override withdrawalFee;
    event LogNewWithdrawHandler(address tokens);
    event LogNewDepositHandler(address tokens);
    event LogNewVault(uint256 index, address vault);
    event LogNewCurveVault(address curveVault);
    event LogNewLifeguard(address lifeguard);
    event LogNewInsurance(address insurance);
    event LogNewPnl(address pnl);
    event LogNewBigFishThreshold(uint256 percent, uint256 absolute);
    event LogFlashSwitchUpdated(bool status);
    event LogNewSafeAddress(address account);
    event LogNewRewardsContract(address reward);
    event LogNewUtilLimit(bool indexed pwrd, uint256 limit);
    event LogNewCurveToStableDistribution(uint256 amount, uint256[N_COINS] amounts, uint256[N_COINS] delta);
    event LogNewWithdrawalFee(address user, bool pwrd, uint256 newFee);
    constructor(
        address pwrd,
        address gvt,
        address[N_COINS] memory _tokens,
        uint256[N_COINS] memory _decimals
    ) public FixedStablecoins(_tokens, _decimals) FixedGTokens(pwrd, gvt) {}
    function pause() external onlyWhitelist {
        _pause();
    }
    function unpause() external onlyOwner {
        _unpause();
    }
    function setWithdrawHandler(address _withdrawHandler, address _emergencyHandler) external onlyOwner {
        require(_withdrawHandler != address(0), "setWithdrawHandler: 0x");
        withdrawHandler = _withdrawHandler;
        emergencyHandler = _emergencyHandler;
        emit LogNewWithdrawHandler(_withdrawHandler);
    }
    function setDepositHandler(address _depositHandler) external onlyOwner {
        require(_depositHandler != address(0), "setDepositHandler: 0x");
        depositHandler = _depositHandler;
        emit LogNewDepositHandler(_depositHandler);
    }
    function stablecoins() external view override returns (address[N_COINS] memory) {
        return underlyingTokens();
    }
    function getSkimPercent() external view override returns (uint256) {
        return IInsurance(insurance).calcSkim();
    }
    function vaults() external view override returns (address[N_COINS] memory) {
        address[N_COINS] memory result;
        for (uint256 i = 0; i < N_COINS; i++) {
            result[i] = underlyingVaults[i];
        }
        return result;
    }
    function setVault(uint256 index, address vault) external onlyOwner {
        require(vault != address(0), "setVault: 0x");
        require(index < N_COINS, "setVault: !index");
        underlyingVaults[index] = vault;
        vaultIndexes[vault] = index + 1;
        emit LogNewVault(index, vault);
    }
    function setCurveVault(address _curveVault) external onlyOwner {
        require(_curveVault != address(0), "setCurveVault: 0x");
        curveVault = _curveVault;
        vaultIndexes[_curveVault] = N_COINS + 1;
        emit LogNewCurveVault(_curveVault);
    }
    function setLifeGuard(address _lifeGuard) external onlyOwner {
        require(_lifeGuard != address(0), "setLifeGuard: 0x");
        lifeGuard = _lifeGuard;
        buoy = ILifeGuard(_lifeGuard).getBuoy();
        emit LogNewLifeguard(_lifeGuard);
    }
    function setInsurance(address _insurance) external onlyOwner {
        require(_insurance != address(0), "setInsurance: 0x");
        insurance = _insurance;
        emit LogNewInsurance(_insurance);
    }
    function setPnL(address _pnl) external onlyOwner {
        require(_pnl != address(0), "setPnl: 0x");
        pnl = _pnl;
        emit LogNewPnl(_pnl);
    }
    function addSafeAddress(address account) external onlyOwner {
        safeAddresses[account] = true;
        emit LogNewSafeAddress(account);
    }
    function switchEoaOnly(bool check) external onlyOwner {
        preventSmartContracts = check;
    }
    function setBigFishThreshold(uint256 _percent, uint256 _absolute) external onlyOwner {
        require(_percent > 0, "_whaleLimit is 0");
        bigFishThreshold = _percent;
        bigFishAbsoluteThreshold = _absolute;
        emit LogNewBigFishThreshold(_percent, _absolute);
    }
    function setReward(address _reward) external onlyOwner {
        require(_reward != address(0), "setReward: 0x");
        reward = _reward;
        emit LogNewRewardsContract(_reward);
    }
    function addReferral(address account, address referral) external override {
        require(msg.sender == depositHandler, "!depositHandler");
        if (account != address(0) && referral != address(0) && referrals[account] == address(0)) {
            referrals[account] = referral;
        }
    }
    function setWithdrawalFee(bool pwrd, uint256 newFee) external onlyOwner {
        withdrawalFee[pwrd] = newFee;
        emit LogNewWithdrawalFee(msg.sender, pwrd, newFee);
    }
    function totalAssets() external view override returns (uint256) {
        return emergencyState ? _totalAssetsEmergency() : _totalAssets();
    }
    function gTokenTotalAssets() public view override returns (uint256) {
        (uint256 gvtAssets, uint256 pwrdAssets) = IPnL(pnl).calcPnL();
        if (msg.sender == address(gvt)) {
            return gvtAssets;
        }
        if (msg.sender == address(pwrd)) {
            return pwrdAssets;
        }
        return 0;
    }
    function gToken(bool isPWRD) external view override returns (address) {
        return isPWRD ? address(pwrd) : address(gvt);
    }
    function isValidBigFish(
        bool pwrd,
        bool deposit,
        uint256 amount
    ) external view override returns (bool) {
        if (deposit && pwrd) {
            require(validGTokenIncrease(amount), "isBigFish: !validGTokenIncrease");
        } else if (!pwrd && !deposit) {
            require(validGTokenDecrease(amount), "isBigFish: !validGTokenDecrease");
        }
        (uint256 gvtAssets, uint256 pwrdAssets) = IPnL(pnl).calcPnL();
        uint256 assets = pwrdAssets.add(gvtAssets);
        if (amount < bigFishAbsoluteThreshold) {
            return false;
        } else if (amount > assets) {
            return true;
        } else {
            return amount > assets.mul(bigFishThreshold).div(PERCENTAGE_DECIMAL_FACTOR);
        }
    }
    function distributeCurveAssets(uint256 amount, uint256[N_COINS] memory delta) external onlyWhitelist {
        uint256[N_COINS] memory amounts = ILifeGuard(lifeGuard).distributeCurveVault(amount, delta);
        emit LogNewCurveToStableDistribution(amount, amounts, delta);
    }
    function eoaOnly(address sender) public override {
        if (preventSmartContracts && !safeAddresses[tx.origin]) {
            require(sender == tx.origin, "EOA only");
        }
    }
    function _totalAssets() private view returns (uint256) {
        require(IBuoy(buoy).safetyCheck(), "!buoy.safetyCheck");
        uint256[N_COINS] memory lgAssets = ILifeGuard(lifeGuard).getAssets();
        uint256[N_COINS] memory vaultAssets;
        for (uint256 i = 0; i < N_COINS; i++) {
            vaultAssets[i] = lgAssets[i].add(IVault(underlyingVaults[i]).totalAssets());
        }
        uint256 totalLp = IVault(curveVault).totalAssets();
        totalLp = totalLp.add(IBuoy(buoy).stableToLp(vaultAssets, true));
        uint256 vp = IBuoy(buoy).getVirtualPrice();
        return totalLp.mul(vp).div(DEFAULT_DECIMALS_FACTOR);
    }
    function _totalAssetsEmergency() private view returns (uint256) {
        IChainPrice chainPrice = IChainPrice(buoy);
        uint256 total;
        for (uint256 i = 0; i < N_COINS; i++) {
            if (i != deadCoin) {
                address tokenAddress = getToken(i);
                uint256 decimals = getDecimal(i);
                IERC20 token = IERC20(tokenAddress);
                uint256 price = chainPrice.getPriceFeed(i);
                uint256 assets = IVault(underlyingVaults[i]).totalAssets().add(token.balanceOf(lifeGuard));
                assets = assets.mul(price).div(CHAINLINK_PRICE_DECIMAL_FACTOR);
                assets = assets.mul(DEFAULT_DECIMALS_FACTOR).div(decimals);
                total = total.add(assets);
            }
        }
        return total;
    }
    function emergency(uint256 coin) external onlyWhitelist {
        require(coin < N_COINS, "invalid coin");
        if (!paused()) {
            _pause();
        }
        deadCoin = coin;
        emergencyState = true;
        uint256 percent;
        for (uint256 i; i < N_COINS; i++) {
            if (i == coin) {
                percent = 10000;
            } else {
                percent = 0;
            }
            IInsurance(insurance).setUnderlyingTokenPercent(i, percent);
        }
        IPnL(pnl).emergencyPnL();
    }
    function restart(uint256[] calldata allocations) external onlyOwner whenPaused {
        _unpause();
        deadCoin = 99;
        emergencyState = false;
        for (uint256 i; i < N_COINS; i++) {
            IInsurance(insurance).setUnderlyingTokenPercent(i, allocations[i]);
        }
        IPnL(pnl).recover();
    }
    function distributeStrategyGainLoss(uint256 gain, uint256 loss) external override {
        uint256 index = vaultIndexes[msg.sender];
        require(index > 0 || index <= N_COINS + 1, "!VaultAdaptor");
        IPnL ipnl = IPnL(pnl);
        IBuoy ibuoy = IBuoy(buoy);
        uint256 gainUsd;
        uint256 lossUsd;
        index = index - 1;
        if (index < N_COINS) {
            if (gain > 0) {
                gainUsd = ibuoy.singleStableToUsd(gain, index);
            } else if (loss > 0) {
                lossUsd = ibuoy.singleStableToUsd(loss, index);
            }
        } else {
            if (gain > 0) {
                gainUsd = ibuoy.lpToUsd(gain);
            } else if (loss > 0) {
                lossUsd = ibuoy.lpToUsd(loss);
            }
        }
        ipnl.distributeStrategyGainLoss(gainUsd, lossUsd, reward);
        if (ibuoy.updateRatios()) {
            ipnl.distributePriceChange(_totalAssets());
        }
    }
    function realizePriceChange(uint256 tolerance) external onlyOwner {
        IPnL ipnl = IPnL(pnl);
        IBuoy ibuoy = IBuoy(buoy);
        if (emergencyState) {
            ipnl.distributePriceChange(_totalAssetsEmergency());
        } else {
            if (ibuoy.updateRatiosWithTolerance(tolerance)) {
                ipnl.distributePriceChange(_totalAssets());
            }
        }
    }
    function burnGToken(
        bool pwrd,
        bool all,
        address account,
        uint256 amount,
        uint256 bonus
    ) external override {
        require(msg.sender == withdrawHandler || msg.sender == emergencyHandler, "burnGToken: !withdrawHandler");
        IToken gt = gTokens(pwrd);
        if (!all) {
            gt.burn(account, gt.factor(), amount);
        } else {
            gt.burnAll(account);
        }
        IPnL(pnl).decreaseGTokenLastAmount(pwrd, amount, bonus);
    }
    function mintGToken(
        bool pwrd,
        address account,
        uint256 amount
    ) external override {
        require(msg.sender == depositHandler, "burnGToken: !depositHandler");
        IToken gt = gTokens(pwrd);
        gt.mint(account, gt.factor(), amount);
        IPnL(pnl).increaseGTokenLastAmount(pwrd, amount);
    }
    function getUserAssets(bool pwrd, address account) external view override returns (uint256 deductUsd) {
        IToken gt = gTokens(pwrd);
        deductUsd = gt.getAssets(account);
        require(deductUsd > 0, "!minAmount");
    }
    function validGTokenIncrease(uint256 amount) private view returns (bool) {
        return
            gTokens(false).totalAssets().mul(utilisationRatioLimitPwrd).div(PERCENTAGE_DECIMAL_FACTOR) >=
            amount.add(gTokens(true).totalAssets());
    }
    function validGTokenDecrease(uint256 amount) public view override returns (bool) {
        return
            gTokens(false).totalAssets().sub(amount).mul(utilisationRatioLimitGvt).div(PERCENTAGE_DECIMAL_FACTOR) >=
            gTokens(true).totalAssets();
    }
    function setUtilisationRatioLimitPwrd(uint256 _utilisationRatioLimitPwrd) external onlyOwner {
        utilisationRatioLimitPwrd = _utilisationRatioLimitPwrd;
        emit LogNewUtilLimit(true, _utilisationRatioLimitPwrd);
    }
    function setUtilisationRatioLimitGvt(uint256 _utilisationRatioLimitGvt) external onlyOwner {
        utilisationRatioLimitGvt = _utilisationRatioLimitGvt;
        emit LogNewUtilLimit(false, _utilisationRatioLimitGvt);
    }
    function getStrategiesTargetRatio() external view override returns (uint256[] memory) {
        uint256 utilRatio = IPnL(pnl).utilisationRatio();
        return IInsurance(insurance).getStrategiesTargetRatio(utilRatio);
    }
}
interface IDepositHandler {
    function depositGvt(
        uint256[3] calldata inAmounts,
        uint256 minAmount,
        address _referral
    ) external;
    function depositPwrd(
        uint256[3] calldata inAmounts,
        uint256 minAmount,
        address _referral
    ) external;
}
contract DepositHandler is Controllable, FixedStablecoins, FixedVaults, IDepositHandler {
    IController public ctrl;
    ILifeGuard public lg;
    IBuoy public buoy;
    IInsurance public insurance;
    mapping(uint256 => bool) public feeToken; 
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    event LogNewFeeToken(address indexed token, uint256 index);
    event LogNewDependencies(address controller, address lifeguard, address buoy, address insurance);
    event LogNewDeposit(
        address indexed user,
        address indexed referral,
        bool pwrd,
        uint256 usdAmount,
        uint256[N_COINS] tokens
    );
    constructor(
        uint256 _feeToken,
        address[N_COINS] memory _vaults,
        address[N_COINS] memory _tokens,
        uint256[N_COINS] memory _decimals
    ) public FixedStablecoins(_tokens, _decimals) FixedVaults(_vaults) {
        feeToken[_feeToken] = true;
    }
    function setDependencies() external onlyOwner {
        ctrl = _controller();
        lg = ILifeGuard(ctrl.lifeGuard());
        buoy = IBuoy(lg.getBuoy());
        insurance = IInsurance(ctrl.insurance());
        emit LogNewDependencies(address(ctrl), address(lg), address(buoy), address(insurance));
    }
    function setFeeToken(uint256 index) external onlyOwner {
        address token = ctrl.stablecoins()[index];
        require(token != address(0), "setFeeToken: !invalid token");
        feeToken[index] = true;
        emit LogNewFeeToken(token, index);
    }
    function depositPwrd(
        uint256[N_COINS] memory inAmounts,
        uint256 minAmount,
        address _referral
    ) external override whenNotPaused {
        depositGToken(inAmounts, minAmount, _referral, true);
    }
    function depositGvt(
        uint256[N_COINS] memory inAmounts,
        uint256 minAmount,
        address _referral
    ) external override whenNotPaused {
        depositGToken(inAmounts, minAmount, _referral, false);
    }
    function depositGToken(
        uint256[N_COINS] memory inAmounts,
        uint256 minAmount,
        address _referral,
        bool pwrd
    ) private {
        ctrl.eoaOnly(msg.sender);
        require(minAmount > 0, "minAmount is 0");
        require(buoy.safetyCheck(), "!safetyCheck");
        ctrl.addReferral(msg.sender, _referral);
        uint256 roughUsd = roughUsd(inAmounts);
        uint256 dollarAmount = _deposit(pwrd, roughUsd, minAmount, inAmounts);
        ctrl.mintGToken(pwrd, msg.sender, dollarAmount);
        emit LogNewDeposit(msg.sender, ctrl.referrals(msg.sender), pwrd, dollarAmount, inAmounts);
    }
    function _deposit(
        bool pwrd,
        uint256 roughUsd,
        uint256 minAmount,
        uint256[N_COINS] memory inAmounts
    ) private returns (uint256 dollarAmount) {
        if (ctrl.isValidBigFish(pwrd, true, roughUsd)) {
            for (uint256 i = 0; i < N_COINS; i++) {
                if (inAmounts[i] > 0) {
                    IERC20 token = IERC20(getToken(i));
                    if (feeToken[i]) {
                        uint256 current = token.balanceOf(address(lg));
                        token.safeTransferFrom(msg.sender, address(lg), inAmounts[i]);
                        inAmounts[i] = token.balanceOf(address(lg)).sub(current);
                    } else {
                        token.safeTransferFrom(msg.sender, address(lg), inAmounts[i]);
                    }
                }
            }
            dollarAmount = _invest(inAmounts, roughUsd);
        } else {
            for (uint256 i = 0; i < N_COINS; i++) {
                if (inAmounts[i] > 0) {
                    IERC20 token = IERC20(getToken(i));
                    address _vault = getVault(i);
                    if (feeToken[i]) {
                        uint256 current = token.balanceOf(_vault);
                        token.safeTransferFrom(msg.sender, _vault, inAmounts[i]);
                        inAmounts[i] = token.balanceOf(_vault).sub(current);
                    } else {
                        token.safeTransferFrom(msg.sender, _vault, inAmounts[i]);
                    }
                }
            }
            dollarAmount = buoy.stableToUsd(inAmounts, true);
        }
        require(dollarAmount >= buoy.lpToUsd(minAmount), "!minAmount");
    }
    function _invest(uint256[N_COINS] memory _inAmounts, uint256 roughUsd) internal returns (uint256 dollarAmount) {
        (, uint256[N_COINS] memory vaultIndexes, uint256 _vaults) = insurance.getVaultDeltaForDeposit(roughUsd);
        if (_vaults < N_COINS) {
            dollarAmount = lg.investSingle(_inAmounts, vaultIndexes[0], vaultIndexes[1]);
        } else {
            uint256 outAmount = lg.deposit();
            uint256[N_COINS] memory delta = insurance.calculateDepositDeltasOnAllVaults();
            dollarAmount = lg.invest(outAmount, delta);
        }
    }
    function roughUsd(uint256[N_COINS] memory inAmounts) private view returns (uint256 usdAmount) {
        for (uint256 i; i < N_COINS; i++) {
            if (inAmounts[i] > 0) {
                usdAmount = usdAmount.add(inAmounts[i].mul(10**18).div(getDecimal(i)));
            }
        }
    }
}
struct SystemState {
    uint256 totalCurrentAssetsUsd;
    uint256 curveCurrentAssetsUsd;
    uint256 lifeguardCurrentAssetsUsd;
    uint256[3] vaultCurrentAssets;
    uint256[3] vaultCurrentAssetsUsd;
    uint256 rebalanceThreshold;
    uint256 utilisationRatio;
    uint256 targetBuffer;
    uint256[3] stablePercents;
    uint256 curvePercent;
}
struct ExposureState {
    uint256[3] stablecoinExposure;
    uint256[] protocolExposure;
    uint256 curveExposure;
    bool stablecoinExposed;
    bool protocolExposed;
}
struct AllocationState {
    uint256[] strategyTargetRatio;
    bool needProtocolWithdrawal;
    uint256 protocolExposedIndex;
    uint256[3] protocolWithdrawalUsd;
    StablecoinAllocationState stableState;
}
struct StablecoinAllocationState {
    uint256 swapInTotalAmountUsd;
    uint256[3] swapInAmounts;
    uint256[3] swapInAmountsUsd;
    uint256[3] swapOutPercents;
    uint256[3] vaultsTargetUsd;
    uint256 curveTargetUsd;
    uint256 curveTargetDeltaUsd;
}
interface IAllocation {
    function calcSystemTargetDelta(SystemState calldata sysState, ExposureState calldata expState)
        external
        view
        returns (AllocationState memory allState);
    function calcVaultTargetDelta(SystemState calldata sysState, bool onlySwapOut)
        external
        view
        returns (StablecoinAllocationState memory stableState);
    function calcStrategyPercent(uint256 utilisationRatio) external pure returns (uint256[] memory);
}
contract Allocation is Constants, Controllable, Whitelist, IAllocation {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public swapThreshold;
    uint256 public curvePercentThreshold;
    event LogNewSwapThreshold(uint256 threshold);
    event LogNewCurveThreshold(uint256 threshold);
    function setSwapThreshold(uint256 _swapThreshold) external onlyOwner {
        swapThreshold = _swapThreshold;
        emit LogNewSwapThreshold(_swapThreshold);
    }
    function setCurvePercentThreshold(uint256 _curvePercentThreshold) external onlyOwner {
        curvePercentThreshold = _curvePercentThreshold;
        emit LogNewCurveThreshold(_curvePercentThreshold);
    }
    function calcSystemTargetDelta(SystemState memory sysState, ExposureState memory expState)
        public
        view
        override
        returns (AllocationState memory allState)
    {
        allState.strategyTargetRatio = calcStrategyPercent(sysState.utilisationRatio);
        allState.stableState = _calcVaultTargetDelta(sysState, false, true);
        (uint256 protocolExposedDeltaUsd, uint256 protocolExposedIndex) = calcProtocolExposureDelta(
            expState.protocolExposure,
            sysState
        );
        allState.protocolExposedIndex = protocolExposedIndex;
        if (protocolExposedDeltaUsd > allState.stableState.swapInTotalAmountUsd) {
            allState.needProtocolWithdrawal = true;
            allState.protocolWithdrawalUsd = calcProtocolWithdraw(allState, protocolExposedIndex);
        }
    }
    function calcVaultTargetDelta(SystemState memory sysState, bool onlySwapOut)
        public
        view
        override
        returns (StablecoinAllocationState memory)
    {
        return _calcVaultTargetDelta(sysState, onlySwapOut, false);
    }
    function calcProtocolWithdraw(AllocationState memory allState, uint256 protocolExposedIndex)
        private
        view
        returns (uint256[N_COINS] memory protocolWithdrawalUsd)
    {
        address[N_COINS] memory vaults = _controller().vaults();
        uint256 strategyCurrentUsd;
        uint256 strategyTargetUsd;
        ILifeGuard lg = ILifeGuard(_controller().lifeGuard());
        IBuoy buoy = IBuoy(lg.getBuoy());
        for (uint256 i = 0; i < N_COINS; i++) {
            uint256 strategyAssets = IVault(vaults[i]).getStrategyAssets(protocolExposedIndex);
            if (strategyAssets > 0) {
                strategyCurrentUsd = buoy.singleStableToUsd(strategyAssets, i);
            }
            strategyTargetUsd = allState
            .stableState
            .vaultsTargetUsd[i]
            .mul(allState.strategyTargetRatio[protocolExposedIndex])
            .div(PERCENTAGE_DECIMAL_FACTOR);
            if (strategyCurrentUsd > strategyTargetUsd) {
                protocolWithdrawalUsd[i] = strategyCurrentUsd.sub(strategyTargetUsd);
            }
            if (protocolWithdrawalUsd[i] > 0 && protocolWithdrawalUsd[i] < allState.stableState.swapInAmountsUsd[i]) {
                protocolWithdrawalUsd[i] = allState.stableState.swapInAmountsUsd[i];
            }
        }
    }
    function _calcVaultTargetDelta(
        SystemState memory sysState,
        bool onlySwapOut,
        bool includeCurveVault
    ) private view returns (StablecoinAllocationState memory stableState) {
        ILifeGuard lg = ILifeGuard(_controller().lifeGuard());
        IBuoy buoy = IBuoy(lg.getBuoy());
        uint256 amountToRebalance;
        if (includeCurveVault && needCurveVault(sysState)) {
            stableState.curveTargetUsd = sysState.totalCurrentAssetsUsd.mul(sysState.curvePercent).div(
                PERCENTAGE_DECIMAL_FACTOR
            );
            amountToRebalance = sysState.totalCurrentAssetsUsd.sub(stableState.curveTargetUsd);
            uint256 curveCurrentAssetsUsd = sysState.lifeguardCurrentAssetsUsd.add(sysState.curveCurrentAssetsUsd);
            stableState.curveTargetDeltaUsd = curveCurrentAssetsUsd > stableState.curveTargetUsd
                ? curveCurrentAssetsUsd.sub(stableState.curveTargetUsd)
                : 0;
        } else {
            amountToRebalance = sysState
            .totalCurrentAssetsUsd
            .sub(sysState.curveCurrentAssetsUsd)
            .sub(sysState.lifeguardCurrentAssetsUsd)
            .add(lg.availableUsd());
        }
        uint256 swapOutTotalUsd = 0;
        for (uint256 i = 0; i < N_COINS; i++) {
            uint256 vaultTargetUsd = amountToRebalance.mul(sysState.stablePercents[i]).div(PERCENTAGE_DECIMAL_FACTOR);
            uint256 vaultTargetAssets;
            if (!onlySwapOut) {
                vaultTargetAssets = vaultTargetUsd == 0 ? 0 : buoy.singleStableFromUsd(vaultTargetUsd, int128(i));
                stableState.vaultsTargetUsd[i] = vaultTargetUsd;
            }
            if (sysState.vaultCurrentAssetsUsd[i] > vaultTargetUsd) {
                if (!onlySwapOut) {
                    stableState.swapInAmounts[i] = sysState.vaultCurrentAssets[i].sub(vaultTargetAssets);
                    stableState.swapInAmountsUsd[i] = sysState.vaultCurrentAssetsUsd[i].sub(vaultTargetUsd);
                    if (invalidDelta(swapThreshold, stableState.swapInAmountsUsd[i])) {
                        stableState.swapInAmounts[i] = 0;
                        stableState.swapInAmountsUsd[i] = 0;
                    } else {
                        stableState.swapInTotalAmountUsd = stableState.swapInTotalAmountUsd.add(
                            stableState.swapInAmountsUsd[i]
                        );
                    }
                }
            } else {
                stableState.swapOutPercents[i] = vaultTargetUsd.sub(sysState.vaultCurrentAssetsUsd[i]);
                if (invalidDelta(swapThreshold, stableState.swapOutPercents[i])) {
                    stableState.swapOutPercents[i] = 0;
                } else {
                    swapOutTotalUsd = swapOutTotalUsd.add(stableState.swapOutPercents[i]);
                }
            }
        }
        uint256 percent = PERCENTAGE_DECIMAL_FACTOR;
        for (uint256 i = 0; i < N_COINS - 1; i++) {
            if (stableState.swapOutPercents[i] > 0) {
                stableState.swapOutPercents[i] = stableState.swapOutPercents[i].mul(PERCENTAGE_DECIMAL_FACTOR).div(
                    swapOutTotalUsd
                );
                percent = percent.sub(stableState.swapOutPercents[i]);
            }
        }
        stableState.swapOutPercents[N_COINS - 1] = percent;
    }
    function calcStrategyPercent(uint256 utilisationRatio)
        public
        pure
        override
        returns (uint256[] memory targetPercent)
    {
        targetPercent = new uint256[](2);
        uint256 primaryTarget = PERCENTAGE_DECIMAL_FACTOR.mul(PERCENTAGE_DECIMAL_FACTOR).div(
            PERCENTAGE_DECIMAL_FACTOR.add(utilisationRatio)
        );
        targetPercent[0] = primaryTarget; 
        targetPercent[1] = PERCENTAGE_DECIMAL_FACTOR 
        .sub(targetPercent[0]);
    }
    function calcProtocolExposureDelta(uint256[] memory protocolExposure, SystemState memory sysState)
        private
        pure
        returns (uint256 protocolExposedDeltaUsd, uint256 protocolExposedIndex)
    {
        for (uint256 i = 0; i < protocolExposure.length; i++) {
            if (protocolExposedDeltaUsd == 0 && protocolExposure[i] > sysState.rebalanceThreshold) {
                uint256 target = sysState.rebalanceThreshold.sub(sysState.targetBuffer);
                protocolExposedDeltaUsd = protocolExposure[i].sub(target).mul(sysState.totalCurrentAssetsUsd).div(
                    PERCENTAGE_DECIMAL_FACTOR
                );
                protocolExposedIndex = i;
            }
        }
    }
    function invalidDelta(uint256 threshold, uint256 delta) private pure returns (bool) {
        return delta > 0 && threshold > 0 && delta < threshold.mul(DEFAULT_DECIMALS_FACTOR);
    }
    function needCurveVault(SystemState memory sysState) private view returns (bool) {
        uint256 currentPercent = sysState
        .curveCurrentAssetsUsd
        .add(sysState.lifeguardCurrentAssetsUsd)
        .mul(PERCENTAGE_DECIMAL_FACTOR)
        .div(sysState.totalCurrentAssetsUsd);
        return currentPercent > curvePercentThreshold;
    }
}
interface IExposure {
    function calcRiskExposure(SystemState calldata sysState) external view returns (ExposureState memory expState);
    function getExactRiskExposure(SystemState calldata sysState) external view returns (ExposureState memory expState);
    function getUnifiedAssets(address[3] calldata vaults)
        external
        view
        returns (uint256 unifiedTotalAssets, uint256[3] memory unifiedAssets);
    function sortVaultsByDelta(
        bool bigFirst,
        uint256 unifiedTotalAssets,
        uint256[3] calldata unifiedAssets,
        uint256[3] calldata targetPercents
    ) external pure returns (uint256[3] memory vaultIndexes);
    function calcRoughDelta(
        uint256[3] calldata targets,
        address[3] calldata vaults,
        uint256 withdrawUsd
    ) external view returns (uint256[3] memory);
}
contract Exposure is Constants, Controllable, Whitelist, IExposure {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 public protocolCount;
    uint256 public makerUSDCExposure;
    event LogNewProtocolCount(uint256 count);
    event LogNewMakerExposure(uint256 exposure);
    function setProtocolCount(uint256 _protocolCount) external onlyOwner {
        protocolCount = _protocolCount;
        emit LogNewProtocolCount(_protocolCount);
    }
    function setMakerUSDCExposure(uint256 _makerUSDCExposure) external onlyOwner {
        makerUSDCExposure = _makerUSDCExposure;
        emit LogNewMakerExposure(_makerUSDCExposure);
    }
    function getExactRiskExposure(SystemState calldata sysState)
        external
        view
        override
        returns (ExposureState memory expState)
    {
        expState = _calcRiskExposure(sysState, false);
        ILifeGuard lifeguard = ILifeGuard(_controller().lifeGuard());
        IBuoy buoy = IBuoy(_controller().buoy());
        for (uint256 i = 0; i < N_COINS; i++) {
            uint256 assets = lifeguard.assets(i);
            uint256 assetsUsd = buoy.singleStableToUsd(assets, i);
            expState.stablecoinExposure[i] = expState.stablecoinExposure[i].add(
                assetsUsd.mul(PERCENTAGE_DECIMAL_FACTOR).div(sysState.totalCurrentAssetsUsd)
            );
        }
    }
    function calcRiskExposure(SystemState calldata sysState)
        external
        view
        override
        returns (ExposureState memory expState)
    {
        expState = _calcRiskExposure(sysState, true);
        (expState.stablecoinExposed, expState.protocolExposed) = isExposed(
            sysState.rebalanceThreshold,
            expState.stablecoinExposure,
            expState.protocolExposure,
            expState.curveExposure
        );
    }
    function getUnifiedAssets(address[N_COINS] calldata vaults)
        public
        view
        override
        returns (uint256 unifiedTotalAssets, uint256[N_COINS] memory unifiedAssets)
    {
        for (uint256 i = 0; i < N_COINS; i++) {
            uint256 assets = IVault(vaults[i]).totalAssets();
            unifiedAssets[i] = assets.mul(DEFAULT_DECIMALS_FACTOR).div(
                uint256(10)**IERC20Detailed(IVault(vaults[i]).token()).decimals()
            );
            unifiedTotalAssets = unifiedTotalAssets.add(unifiedAssets[i]);
        }
    }
    function calcRoughDelta(
        uint256[N_COINS] calldata targets,
        address[N_COINS] calldata vaults,
        uint256 withdrawUsd
    ) external view override returns (uint256[N_COINS] memory delta) {
        (uint256 totalAssets, uint256[N_COINS] memory vaultTotalAssets) = getUnifiedAssets(vaults);
        require(totalAssets > withdrawUsd, "totalAssets < withdrawalUsd");
        totalAssets = totalAssets.sub(withdrawUsd);
        uint256 totalDelta;
        for (uint256 i; i < N_COINS; i++) {
            uint256 target = totalAssets.mul(targets[i]).div(PERCENTAGE_DECIMAL_FACTOR);
            if (vaultTotalAssets[i] > target) {
                delta[i] = vaultTotalAssets[i].sub(target);
                totalDelta = totalDelta.add(delta[i]);
            }
        }
        uint256 percent = PERCENTAGE_DECIMAL_FACTOR;
        for (uint256 i; i < N_COINS - 1; i++) {
            if (delta[i] > 0) {
                delta[i] = delta[i].mul(PERCENTAGE_DECIMAL_FACTOR).div(totalDelta);
                percent = percent.sub(delta[i]);
            }
        }
        delta[N_COINS - 1] = percent;
        return delta;
    }
    function sortVaultsByDelta(
        bool bigFirst,
        uint256 unifiedTotalAssets,
        uint256[N_COINS] calldata unifiedAssets,
        uint256[N_COINS] calldata targetPercents
    ) external pure override returns (uint256[N_COINS] memory vaultIndexes) {
        uint256 maxIndex;
        uint256 minIndex;
        int256 maxDelta;
        int256 minDelta;
        for (uint256 i = 0; i < N_COINS; i++) {
            int256 delta = int256(
                unifiedAssets[i] - unifiedTotalAssets.mul(targetPercents[i]).div(PERCENTAGE_DECIMAL_FACTOR)
            );
            if (delta > maxDelta) {
                maxDelta = delta;
                maxIndex = i;
            } else if (delta < minDelta) {
                minDelta = delta;
                minIndex = i;
            }
        }
        if (bigFirst) {
            vaultIndexes[0] = maxIndex;
            vaultIndexes[2] = minIndex;
        } else {
            vaultIndexes[0] = minIndex;
            vaultIndexes[2] = maxIndex;
        }
        vaultIndexes[1] = N_COINS - maxIndex - minIndex;
    }
    function calculatePercentOfSystem(
        address vault,
        uint256 index,
        uint256 vaultAssetsPercent,
        uint256 vaultAssets
    ) private view returns (uint256 percentOfSystem) {
        if (vaultAssets == 0) return 0;
        uint256 strategyAssetsPercent = IVault(vault).getStrategyAssets(index).mul(PERCENTAGE_DECIMAL_FACTOR).div(
            vaultAssets
        );
        percentOfSystem = vaultAssetsPercent.mul(strategyAssetsPercent).div(PERCENTAGE_DECIMAL_FACTOR);
    }
    function calculateStableCoinExposure(uint256[N_COINS] memory directlyExposure, uint256 curveExposure)
        private
        view
        returns (uint256[N_COINS] memory stableCoinExposure)
    {
        uint256 maker = directlyExposure[0].mul(makerUSDCExposure).div(PERCENTAGE_DECIMAL_FACTOR);
        for (uint256 i = 0; i < N_COINS; i++) {
            uint256 indirectExposure = curveExposure;
            if (i == 1) {
                indirectExposure = indirectExposure.add(maker);
            }
            stableCoinExposure[i] = directlyExposure[i].add(indirectExposure);
        }
    }
    function isExposed(
        uint256 rebalanceThreshold,
        uint256[N_COINS] memory stableCoinExposure,
        uint256[] memory protocolExposure,
        uint256 curveExposure
    ) private pure returns (bool stablecoinExposed, bool protocolExposed) {
        for (uint256 i = 0; i < N_COINS; i++) {
            if (stableCoinExposure[i] > rebalanceThreshold) {
                stablecoinExposed = true;
                break;
            }
        }
        for (uint256 i = 0; i < protocolExposure.length; i++) {
            if (protocolExposure[i] > rebalanceThreshold) {
                protocolExposed = true;
                break;
            }
        }
        if (!protocolExposed && curveExposure > rebalanceThreshold) protocolExposed = true;
        return (stablecoinExposed, protocolExposed);
    }
    function _calcRiskExposure(SystemState memory sysState, bool treatLifeguardAsCurve)
        private
        view
        returns (ExposureState memory expState)
    {
        address[N_COINS] memory vaults = _controller().vaults();
        uint256 pCount = protocolCount;
        expState.protocolExposure = new uint256[](pCount);
        if (sysState.totalCurrentAssetsUsd == 0) {
            return expState;
        }
        for (uint256 i = 0; i < N_COINS; i++) {
            uint256 vaultAssetsPercent = sysState.vaultCurrentAssetsUsd[i].mul(PERCENTAGE_DECIMAL_FACTOR).div(
                sysState.totalCurrentAssetsUsd
            );
            expState.stablecoinExposure[i] = vaultAssetsPercent;
            for (uint256 j = 0; j < pCount; j++) {
                uint256 percentOfSystem = calculatePercentOfSystem(
                    vaults[i],
                    j,
                    vaultAssetsPercent,
                    sysState.vaultCurrentAssets[i]
                );
                expState.protocolExposure[j] = expState.protocolExposure[j].add(percentOfSystem);
            }
        }
        if (treatLifeguardAsCurve) {
            expState.curveExposure = sysState.curveCurrentAssetsUsd.add(sysState.lifeguardCurrentAssetsUsd);
        } else {
            expState.curveExposure = sysState.curveCurrentAssetsUsd;
        }
        expState.curveExposure = expState.curveExposure.mul(PERCENTAGE_DECIMAL_FACTOR).div(
            sysState.totalCurrentAssetsUsd
        );
        expState.stablecoinExposure = calculateStableCoinExposure(expState.stablecoinExposure, expState.curveExposure);
    }
}
contract Insurance is Constants, Controllable, Whitelist, IInsurance {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IAllocation public allocation;
    IExposure public exposure;
    mapping(uint256 => uint256) public underlyingTokensPercents;
    uint256 public curveVaultPercent;
    uint256 public exposureBufferRebalance;
    uint256 public maxPercentForWithdraw;
    uint256 public maxPercentForDeposit;
    event LogNewAllocation(address allocation);
    event LogNewExposure(address exposure);
    event LogNewTargetAllocation(uint256 indexed index, uint256 percent);
    event LogNewCurveAllocation(uint256 percent);
    event LogNewExposureBuffer(uint256 buffer);
    event LogNewVaultMax(bool deposit, uint256 percent);
    modifier onlyValidIndex(uint256 index) {
        require(index >= 0 && index < N_COINS, "Invalid index value.");
        _;
    }
    function setAllocation(address _allocation) external onlyOwner {
        require(_allocation != address(0), "Zero address provided");
        allocation = IAllocation(_allocation);
        emit LogNewAllocation(_allocation);
    }
    function setExposure(address _exposure) external onlyOwner {
        require(_exposure != address(0), "Zero address provided");
        exposure = IExposure(_exposure);
        emit LogNewExposure(_exposure);
    }
    function setUnderlyingTokenPercent(uint256 coinIndex, uint256 percent) external override onlyValidIndex(coinIndex) {
        require(msg.sender == controller || msg.sender == owner(), "setUnderlyingTokenPercent: !authorized");
        underlyingTokensPercents[coinIndex] = percent;
        emit LogNewTargetAllocation(coinIndex, percent);
    }
    function setCurveVaultPercent(uint256 _curveVaultPercent) external onlyOwner {
        curveVaultPercent = _curveVaultPercent;
        emit LogNewCurveAllocation(_curveVaultPercent);
    }
    function setExposureBufferRebalance(uint256 rebalanceBuffer) external onlyOwner {
        exposureBufferRebalance = rebalanceBuffer;
        emit LogNewExposureBuffer(rebalanceBuffer);
    }
    function setWhaleThresholdWithdraw(uint256 _maxPercentForWithdraw) external onlyOwner {
        maxPercentForWithdraw = _maxPercentForWithdraw;
        emit LogNewVaultMax(false, _maxPercentForWithdraw);
    }
    function setWhaleThresholdDeposit(uint256 _maxPercentForDeposit) external onlyOwner {
        maxPercentForDeposit = _maxPercentForDeposit;
        emit LogNewVaultMax(true, _maxPercentForDeposit);
    }
    function calculateDepositDeltasOnAllVaults() public view override returns (uint256[N_COINS] memory) {
        return getStablePercents();
    }
    function getVaultDeltaForDeposit(uint256 amount)
        external
        view
        override
        returns (
            uint256[N_COINS] memory,
            uint256[N_COINS] memory,
            uint256
        )
    {
        uint256[N_COINS] memory investDelta;
        uint256[N_COINS] memory vaultIndexes;
        (uint256 totalAssets, uint256[N_COINS] memory vaultAssets) = exposure.getUnifiedAssets(_controller().vaults());
        if (amount < totalAssets.mul(maxPercentForDeposit).div(PERCENTAGE_DECIMAL_FACTOR)) {
            uint256[N_COINS] memory _vaultIndexes = exposure.sortVaultsByDelta(
                false,
                totalAssets,
                vaultAssets,
                getStablePercents()
            );
            investDelta[vaultIndexes[0]] = 10000;
            vaultIndexes[0] = _vaultIndexes[0];
            vaultIndexes[1] = _vaultIndexes[1];
            vaultIndexes[2] = _vaultIndexes[2];
            return (investDelta, vaultIndexes, 1);
        } else {
            return (investDelta, vaultIndexes, N_COINS);
        }
    }
    function sortVaultsByDelta(bool bigFirst) external view override returns (uint256[N_COINS] memory vaultIndexes) {
        (uint256 totalAssets, uint256[N_COINS] memory vaultAssets) = exposure.getUnifiedAssets(_controller().vaults());
        return exposure.sortVaultsByDelta(bigFirst, totalAssets, vaultAssets, getStablePercents());
    }
    function rebalanceTrigger() external view override returns (bool sysNeedRebalance) {
        SystemState memory sysState = prepareCalculation();
        sysState.utilisationRatio = IPnL(_controller().pnl()).utilisationRatio();
        sysState.rebalanceThreshold = PERCENTAGE_DECIMAL_FACTOR.sub(sysState.utilisationRatio.div(2)).sub(
            exposureBufferRebalance
        );
        ExposureState memory expState = exposure.calcRiskExposure(sysState);
        sysNeedRebalance = expState.stablecoinExposed || expState.protocolExposed;
    }
    function rebalance() external override onlyWhitelist {
        SystemState memory sysState = prepareCalculation();
        sysState.utilisationRatio = IPnL(_controller().pnl()).utilisationRatio();
        sysState.rebalanceThreshold = PERCENTAGE_DECIMAL_FACTOR.sub(sysState.utilisationRatio.div(2)).sub(
            exposureBufferRebalance
        );
        ExposureState memory expState = exposure.calcRiskExposure(sysState);
        if (!expState.stablecoinExposed && !expState.protocolExposed) return;
        sysState.targetBuffer = exposureBufferRebalance;
        AllocationState memory allState = allocation.calcSystemTargetDelta(sysState, expState);
        _rebalance(allState);
    }
    function rebalanceForWithdraw(uint256 withdrawUsd, bool pwrd) external override returns (bool) {
        require(msg.sender == _controller().withdrawHandler(), "rebalanceForWithdraw: !withdrawHandler");
        return withdraw(withdrawUsd, pwrd);
    }
    function calcSkim() external view override returns (uint256) {
        IPnL pnl = IPnL(_controller().pnl());
        (uint256 gvt, uint256 pwrd) = pnl.calcPnL();
        uint256 totalAssets = gvt.add(pwrd);
        uint256 curveAssets = IVault(_controller().curveVault()).totalAssets();
        if (totalAssets != 0 && curveAssets.mul(PERCENTAGE_DECIMAL_FACTOR).div(totalAssets) >= curveVaultPercent) {
            return 0;
        }
        return curveVaultPercent;
    }
    function getStrategiesTargetRatio(uint256 utilRatio) external view override returns (uint256[] memory) {
        return allocation.calcStrategyPercent(utilRatio);
    }
    function prepareCalculation() public view returns (SystemState memory systemState) {
        ILifeGuard lg = getLifeGuard();
        IBuoy buoy = IBuoy(lg.getBuoy());
        require(buoy.safetyCheck());
        IVault curve = IVault(_controller().curveVault());
        systemState.lifeguardCurrentAssetsUsd = lg.totalAssetsUsd();
        systemState.curveCurrentAssetsUsd = buoy.lpToUsd(curve.totalAssets());
        systemState.totalCurrentAssetsUsd = systemState.lifeguardCurrentAssetsUsd.add(
            systemState.curveCurrentAssetsUsd
        );
        systemState.curvePercent = curveVaultPercent;
        address[N_COINS] memory vaults = _controller().vaults();
        for (uint256 i = 0; i < N_COINS; i++) {
            IVault vault = IVault(vaults[i]);
            uint256 vaultAssets = vault.totalAssets();
            uint256 vaultAssetsUsd = buoy.singleStableToUsd(vaultAssets, i);
            systemState.totalCurrentAssetsUsd = systemState.totalCurrentAssetsUsd.add(vaultAssetsUsd);
            systemState.vaultCurrentAssets[i] = vaultAssets;
            systemState.vaultCurrentAssetsUsd[i] = vaultAssetsUsd;
        }
        systemState.stablePercents = getStablePercents();
    }
    function withdraw(uint256 amount, bool pwrd) private returns (bool curve) {
        address[N_COINS] memory vaults = _controller().vaults();
        (uint256 withdrawType, uint256[N_COINS] memory withdrawalAmounts) = calculateWithdrawalAmountsOnPartVaults(
            amount,
            vaults
        );
        if (withdrawType > 1) {
            if (withdrawType == 2)
                withdrawalAmounts = calculateWithdrawalAmountsOnAllVaults(amount, vaults);
            else {
                for (uint256 i; i < N_COINS; i++) {
                    withdrawalAmounts[i] = IVault(vaults[i]).totalAssets();
                }
            }
        }
        ILifeGuard lg = getLifeGuard();
        for (uint256 i = 0; i < N_COINS; i++) {
            if (withdrawalAmounts[i] > 0) {
                IVault(vaults[i]).withdrawByStrategyOrder(withdrawalAmounts[i], address(lg), pwrd);
            }
        }
        if (withdrawType == 3) {
            IBuoy buoy = IBuoy(lg.getBuoy());
            uint256[N_COINS] memory _withdrawalAmounts;
            _withdrawalAmounts[0] = withdrawalAmounts[0];
            _withdrawalAmounts[1] = withdrawalAmounts[1];
            _withdrawalAmounts[2] = withdrawalAmounts[2];
            uint256 leftUsd = amount.sub(buoy.stableToUsd(_withdrawalAmounts, false));
            IVault curveVault = IVault(_controller().curveVault());
            uint256 curveVaultUsd = buoy.lpToUsd(curveVault.totalAssets());
            require(curveVaultUsd > leftUsd, "no enough system assets");
            curveVault.withdraw(buoy.usdToLp(leftUsd), address(lg));
            curve = true;
        }
    }
    function calculateWithdrawalAmountsOnPartVaults(uint256 amount, address[N_COINS] memory vaults)
        private
        view
        returns (uint256 withdrawType, uint256[N_COINS] memory withdrawalAmounts)
    {
        uint256 maxWithdrawal;
        uint256 leftAmount = amount;
        uint256 vaultIndex;
        (uint256 totalAssets, uint256[N_COINS] memory vaultAssets) = exposure.getUnifiedAssets(vaults);
        if (amount > totalAssets) {
            withdrawType = 3;
        } else {
            withdrawType = 2;
            uint256[N_COINS] memory vaultIndexes = exposure.sortVaultsByDelta(
                true,
                totalAssets,
                vaultAssets,
                getStablePercents()
            );
            IBuoy buoy = IBuoy(getLifeGuard().getBuoy());
            for (uint256 i; i < N_COINS - 1; i++) {
                vaultIndex = vaultIndexes[i];
                maxWithdrawal = vaultAssets[vaultIndex].mul(maxPercentForWithdraw).div(PERCENTAGE_DECIMAL_FACTOR);
                if (leftAmount > maxWithdrawal) {
                    withdrawalAmounts[vaultIndex] = buoy.singleStableFromUsd(maxWithdrawal, int128(vaultIndex));
                    leftAmount = leftAmount.sub(maxWithdrawal);
                } else {
                    withdrawType = 1;
                    withdrawalAmounts[vaultIndex] = buoy.singleStableFromUsd(leftAmount, int128(vaultIndex));
                    break;
                }
            }
        }
    }
    function getDelta(uint256 withdrawUsd) external view override returns (uint256[N_COINS] memory delta) {
        address[N_COINS] memory vaults = _controller().vaults();
        delta = exposure.calcRoughDelta(getStablePercents(), vaults, withdrawUsd);
    }
    function calculateWithdrawalAmountsOnAllVaults(uint256 amount, address[N_COINS] memory vaults)
        private
        view
        returns (uint256[N_COINS] memory withdrawalAmounts)
    {
        bool simple = true;
        uint256[N_COINS] memory delta = exposure.calcRoughDelta(getStablePercents(), vaults, amount);
        for (uint256 i = 0; i < N_COINS; i++) {
            IVault vault = IVault(vaults[i]);
            withdrawalAmounts[i] = amount
            .mul(delta[i])
            .mul(uint256(10)**IERC20Detailed(vault.token()).decimals())
            .div(PERCENTAGE_DECIMAL_FACTOR)
            .div(DEFAULT_DECIMALS_FACTOR);
            if (withdrawalAmounts[i] > vault.totalAssets()) {
                simple = false;
                break;
            }
        }
        if (!simple) {
            (withdrawalAmounts, ) = calculateVaultSwapData(amount);
        }
    }
    function calculateVaultSwapData(uint256 withdrawAmount)
        private
        view
        returns (uint256[N_COINS] memory swapInAmounts, uint256[N_COINS] memory swapOutPercents)
    {
        SystemState memory state = prepareCalculation();
        require(withdrawAmount < state.totalCurrentAssetsUsd, "Withdrawal exceeds system assets");
        state.totalCurrentAssetsUsd = state.totalCurrentAssetsUsd.sub(withdrawAmount);
        StablecoinAllocationState memory stableState = allocation.calcVaultTargetDelta(state, false);
        swapInAmounts = stableState.swapInAmounts;
        swapOutPercents = stableState.swapOutPercents;
    }
    function getLifeGuard() private view returns (ILifeGuard) {
        return ILifeGuard(_controller().lifeGuard());
    }
    function _rebalance(AllocationState memory allState) private {
        address[N_COINS] memory vaults = _controller().vaults();
        ILifeGuard lg = getLifeGuard();
        IBuoy buoy = IBuoy(lg.getBuoy());
        if (allState.needProtocolWithdrawal) {
            for (uint256 i = 0; i < N_COINS; i++) {
                if (allState.protocolWithdrawalUsd[i] > 0) {
                    uint256 amount = buoy.singleStableFromUsd(allState.protocolWithdrawalUsd[i], int128(i));
                    IVault(vaults[i]).withdrawByStrategyIndex(
                        amount,
                        IVault(vaults[i]).vault(),
                        allState.protocolExposedIndex
                    );
                }
            }
        }
        bool hasWithdrawal = moveAssetsFromVaultsToLifeguard(
            vaults,
            allState.stableState.swapInAmounts,
            lg,
            allState.needProtocolWithdrawal ? 0 : allState.protocolExposedIndex,
            allState.strategyTargetRatio 
        );
        uint256 curveDeltaUsd = allState.stableState.curveTargetDeltaUsd;
        if (curveDeltaUsd > 0) {
            uint256 usdAmount = lg.totalAssetsUsd();
            lg.depositStable(true);
            if (usdAmount < curveDeltaUsd) {
                IVault(_controller().curveVault()).withdraw(buoy.usdToLp(curveDeltaUsd.sub(usdAmount)), address(lg));
            }
        }
        if (curveDeltaUsd == 0 && hasWithdrawal) lg.depositStable(false);
        for (uint256 i = 0; i < N_COINS; i++) {
            if (allState.stableState.swapOutPercents[i] > 0) {
                uint256[N_COINS] memory _swapOutPercents;
                _swapOutPercents[0] = allState.stableState.swapOutPercents[0];
                _swapOutPercents[1] = allState.stableState.swapOutPercents[1];
                _swapOutPercents[2] = allState.stableState.swapOutPercents[2];
                lg.invest(0, _swapOutPercents);
                break;
            }
        }
    }
    function moveAssetsFromVaultsToLifeguard(
        address[N_COINS] memory vaults,
        uint256[N_COINS] memory swapInAmounts,
        ILifeGuard lg,
        uint256 strategyIndex,
        uint256[] memory strategyTargetRatio
    ) private returns (bool) {
        bool moved = false;
        for (uint256 i = 0; i < N_COINS; i++) {
            IVault vault = IVault(vaults[i]);
            if (swapInAmounts[i] > 0) {
                moved = true;
                vault.withdrawByStrategyIndex(swapInAmounts[i], address(lg), strategyIndex);
            }
            vault.updateStrategyRatio(strategyTargetRatio);
        }
        return moved;
    }
    function getStablePercents() private view returns (uint256[N_COINS] memory stablePercents) {
        for (uint256 i = 0; i < N_COINS; i++) {
            stablePercents[i] = underlyingTokensPercents[i];
        }
    }
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
interface IWithdrawHandler {
    function withdrawByLPToken(
        bool pwrd,
        uint256 lpAmount,
        uint256[3] calldata minAmounts
    ) external;
    function withdrawByStablecoin(
        bool pwrd,
        uint256 index,
        uint256 lpAmount,
        uint256 minAmount
    ) external;
    function withdrawAllSingle(
        bool pwrd,
        uint256 index,
        uint256 minAmount
    ) external;
    function withdrawAllBalanced(bool pwrd, uint256[3] calldata minAmounts) external;
}
contract MockFlashLoanAttack {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address private lifeguard;
    address private controller;
    function setController(address _controller) external {
        controller = _controller;
    }
    function setLifeGuard(address _lifeguard) external {
        lifeguard = _lifeguard;
    }
    function withdraw(bool pwrd, uint256 lpAmount) public {
        IController c = IController(controller);
        uint256[3] memory minAmounts;
        IWithdrawHandler(c.withdrawHandler()).withdrawByLPToken(pwrd, lpAmount, minAmounts);
    }
}
contract MockFlashLoan {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    address private flNext;
    address private lifeguard;
    address private controller;
    constructor(address _flNext) public {
        flNext = _flNext;
    }
    function setController(address _controller) external {
        controller = _controller;
    }
    function setLifeGuard(address _lifeguard) external {
        lifeguard = _lifeguard;
    }
    function callNextChain(address gTokenAddress, uint256[3] calldata amounts) external {
        ILifeGuard lg = ILifeGuard(lifeguard);
        IBuoy buoy = IBuoy(lg.getBuoy());
        Controller c = Controller(controller);
        require(
            gTokenAddress == address(c.gvt()) || gTokenAddress == address(c.pwrd()),
            "invalid gTokenAddress"
        );
        address[3] memory tokens = c.stablecoins();
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).approve(c.depositHandler(), amounts[i]);
        }
        uint256 lp = buoy.stableToLp(amounts, true);
        uint256 lpWithSlippage = lp.sub(lp.div(1000));
        bool pwrd = gTokenAddress == address(c.pwrd());
        if (pwrd) {
            IDepositHandler(c.depositHandler()).depositPwrd(amounts, lpWithSlippage, address(0));
        } else {
            IDepositHandler(c.depositHandler()).depositGvt(amounts, lpWithSlippage, address(0));
        }
        IERC20(gTokenAddress).transfer(flNext, IERC20(gTokenAddress).balanceOf(address(this)));
        MockFlashLoanAttack(flNext).withdraw(pwrd, lpWithSlippage);
    }
    function withdrawDeposit(bool pwrd, uint256[3] calldata amounts) external {
        ILifeGuard lg = ILifeGuard(lifeguard);
        IBuoy buoy = IBuoy(lg.getBuoy());
        Controller c = Controller(controller);
        uint256 lp = buoy.stableToLp(amounts, false);
        uint256 lpWithSlippage = lp.add(lp.div(1000));
        uint256[3] memory minAmounts;
        IWithdrawHandler(c.withdrawHandler()).withdrawByLPToken(pwrd, lpWithSlippage, minAmounts);
        address[3] memory tokens = c.stablecoins();
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).approve(c.depositHandler(), amounts[i]);
        }
        lp = buoy.stableToLp(amounts, true);
        lpWithSlippage = lp.sub(lp.div(1000));
        if (pwrd) {
            IDepositHandler(c.depositHandler()).depositPwrd(amounts, lpWithSlippage, address(0));
        } else {
            IDepositHandler(c.depositHandler()).depositGvt(amounts, lpWithSlippage, address(0));
        }
    }
    function depositWithdraw(bool pwrd, uint256[3] calldata amounts) external {
        ILifeGuard lg = ILifeGuard(lifeguard);
        IBuoy buoy = IBuoy(lg.getBuoy());
        Controller c = Controller(controller);
        address[3] memory tokens = c.stablecoins();
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).approve(c.depositHandler(), amounts[i]);
        }
        uint256 lp = buoy.stableToLp(amounts, true);
        uint256 lpWithSlippage = lp.sub(lp.div(1000));
        if (pwrd) {
            IDepositHandler(c.depositHandler()).depositPwrd(amounts, lpWithSlippage, address(0));
        } else {
            IDepositHandler(c.depositHandler()).depositGvt(amounts, lpWithSlippage, address(0));
        }
        lp = buoy.stableToLp(amounts, false);
        lpWithSlippage = lp.add(lp.div(1000));
        uint256[3] memory minAmounts;
        IWithdrawHandler(c.withdrawHandler()).withdrawByLPToken(pwrd, lpWithSlippage, minAmounts);
    }
}
interface IChainlinkAggregator {
  function decimals() external view returns (uint8);
  function latestAnswer() external view returns (int256);
  function latestTimestamp() external view returns (uint256);
  function latestRound() external view returns (uint256);
  function getAnswer(uint256 roundId) external view returns (int256);
  function getTimestamp(uint256 roundId) external view returns (uint256);
  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 timestamp);
  event NewRound(uint256 indexed roundId, address indexed startedBy);
}
contract MockBuoy is IBuoy, IChainPrice, Whitelist, Constants {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address[] public stablecoins;
    ICurve3Pool public override curvePool;
    uint256 constant vp = 1005330723799997871;
    uint256[] public decimals = [18, 6, 6];
    uint256[] vpSingle = [996343755718242128, 994191500557422927, 993764724471177721];
    uint256[] chainPrices = [10001024, 100000300, 99998869];
    uint256[] public balanced = [30, 30, 40];
    function setStablecoins(address[] calldata _stablecoins) external {
        stablecoins = _stablecoins;
    }
    function lpToUsd(uint256 inAmount) external view override returns (uint256) {
        return _lpToUsd(inAmount);
    }
    function _lpToUsd(uint256 inAmount) private view returns (uint256) {
        return inAmount.mul(vp).div(DEFAULT_DECIMALS_FACTOR);
    }
    function usdToLp(uint256 inAmount) public view override returns (uint256) {
        return inAmount.mul(DEFAULT_DECIMALS_FACTOR).div(vp);
    }
    function stableToUsd(uint256[3] calldata inAmounts, bool _deposit) external view override returns (uint256) {
        return _stableToUsd(inAmounts, _deposit);
    }
    function _stableToUsd(uint256[3] memory inAmounts, bool _deposit) private view returns (uint256) {
        uint256 lp = _stableToLp(inAmounts, _deposit);
        return _lpToUsd(lp);
    }
    function stableToLp(uint256[3] calldata inAmounts, bool _deposit) external view override returns (uint256) {
        return _stableToLp(inAmounts, _deposit);
    }
    function _stableToLp(uint256[3] memory inAmounts, bool deposit) private view returns (uint256) {
        deposit;
        uint256 totalAmount;
        for (uint256 i = 0; i < vpSingle.length; i++) {
            totalAmount = totalAmount.add(inAmounts[i].mul(vpSingle[i]).div(10**decimals[i]));
        }
        return totalAmount;
    }
    function singleStableFromLp(uint256 inAmount, int128 i) external view override returns (uint256) {
        return _singleStableFromLp(inAmount, uint256(i));
    }
    function _singleStableFromLp(uint256 inAmount, uint256 i) private view returns (uint256) {
        return inAmount.mul(10**18).div(vpSingle[i]).div(10**(18 - decimals[i]));
    }
    function singleStableToUsd(uint256 inAmount, uint256 i) external view override returns (uint256) {
        uint256[3] memory inAmounts;
        inAmounts[i] = inAmount;
        return _stableToUsd(inAmounts, true);
    }
    function singleStableFromUsd(uint256 inAmount, int128 i) external view override returns (uint256) {
        return _singleStableFromLp(usdToLp(inAmount), uint256(i));
    }
    function getRatio(uint256 token0, uint256 token1) external view returns (uint256, uint256) {}
    function safetyCheck() external view override returns (bool) {
        return true;
    }
    function getVirtualPrice() external view override returns (uint256) {
        return vp;
    }
    function updateRatios() external override returns (bool) {}
    function updateRatiosWithTolerance(uint256 tolerance) external override returns (bool) {}
    function getPriceFeed(uint256 i) external view override returns (uint256 _price) {
        return chainPrices[i];
    }
}
abstract contract MockERC20 is ERC20, Ownable {
    function mint(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Account is empty.");
        require(amount > 0, "amount is less than zero.");
        _mint(account, amount);
    }
    function burn(address account, uint256 amount) external onlyOwner {
        require(account != address(0), "Account is empty.");
        require(amount > 0, "amount is less than zero.");
        _burn(account, amount);
    }
}
contract MockController is Constants, Pausable, Ownable, IController, IWithdrawHandler, IDepositHandler {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    uint256 pricePerShare = CHAINLINK_PRICE_DECIMAL_FACTOR;
    uint256 _gTokenTotalAssets;
    uint256 utilisationRatioLimit;
    address[3] underlyingTokens;
    uint256[3] delta;
    mapping(uint256 => address) public override underlyingVaults;
    address public override curveVault;
    uint256 public override deadCoin;
    bool public override emergencyState;
    mapping(address => bool) whiteListedPools;
    mapping(address => address) public override referrals;
    address public override insurance;
    address public override reward;
    address public override pnl;
    address public override lifeGuard;
    address public override buoy;
    address public gvt;
    address public pwrd;
    address public _pwrd;
    uint256 public override totalAssets;
    uint256 skimPercent;
    bool public whale;
    uint256[] public vaultOrder;
    event LogNewDeposit(address indexed user, uint256 usdAmount, uint256[3] tokens);
    event LogNewWithdrawal(address indexed user, uint256 usdAmount, uint256[3] tokenAmounts);
    event LogNewSingleCoinWithdrawal(address indexed user, uint256 usdAmount, uint256 token, uint256 lpTokens);
    function setUnderlyingTokens(address[3] calldata tokens) external onlyOwner {
        underlyingTokens = tokens;
    }
    function setDelta(uint256[3] calldata newDelta) external {
        delta = newDelta;
    }
    function setGvt(address _gvt) external {
        gvt = _gvt;
    }
    function setPwrd(address newPwrd) external {
        pwrd = newPwrd;
        _pwrd = newPwrd;
    }
    function setVaultOrder(uint256[] calldata newOrder) external {
        vaultOrder = newOrder;
    }
    function setVault(uint256 index, address vault) external {
        underlyingVaults[index] = vault;
    }
    function setCurveVault(address _curveVault) external onlyOwner {
        curveVault = _curveVault;
    }
    function stablecoins() external view override returns (address[3] memory) {
        return underlyingTokens;
    }
    function deposit(
        address gTokenAddress,
        uint256[3] calldata inAmounts,
        uint256 minAmount,
        address pool,
        address _referral
    ) external {
        require(minAmount > 0, "minAmount should be greater than 0.");
        ILifeGuard lg = ILifeGuard(pool);
        for (uint256 i = 0; i < N_COINS; i++) {
            address token = underlyingTokens[i];
            IERC20(token).safeTransferFrom(msg.sender, pool, inAmounts[i]);
        }
        uint256 dollarAmount;
        bool invest = false;
        dollarAmount = lg.deposit();
        if (invest) {
            dollarAmount = lg.invest(dollarAmount, delta);
        }
        _mintGToken(gTokenAddress, dollarAmount);
        emit LogNewDeposit(msg.sender, dollarAmount, inAmounts);
    }
    function depositGvt(
        uint256[3] calldata inAmounts,
        uint256 minAmount,
        address _referral
    ) external override {
        require(minAmount > 0, "minAmount should be greater than 0.");
        ILifeGuard lg = ILifeGuard(lifeGuard);
        for (uint256 i = 0; i < N_COINS; i++) {
            address token = underlyingTokens[i];
            IERC20(token).safeTransferFrom(msg.sender, lifeGuard, inAmounts[i]);
        }
        uint256 dollarAmount;
        bool invest = false;
        if (whale) {
            uint256 outAmount = lg.deposit();
            dollarAmount = lg.invest(outAmount, delta);
        } else {
            dollarAmount = lg.investSingle(inAmounts, vaultOrder[0], vaultOrder[1]);
        }
        _mintGToken(gvt, dollarAmount);
        emit LogNewDeposit(msg.sender, dollarAmount, inAmounts);
    }
    function depositPwrd(
        uint256[3] calldata inAmounts,
        uint256 minAmount,
        address _referral
    ) external override {
        require(minAmount > 0, "minAmount should be greater than 0.");
        ILifeGuard lg = ILifeGuard(lifeGuard);
        for (uint256 i = 0; i < N_COINS; i++) {
            address token = underlyingTokens[i];
            IERC20(token).safeTransferFrom(msg.sender, lifeGuard, inAmounts[i]);
        }
        uint256 dollarAmount;
        bool invest = false;
        if (whale) {
            uint256 outAmount = lg.deposit();
            dollarAmount = lg.invest(outAmount, delta);
        } else {
            dollarAmount = lg.investSingle(inAmounts, vaultOrder[0], vaultOrder[1]);
        }
        _mintGToken(pwrd, dollarAmount);
        emit LogNewDeposit(msg.sender, dollarAmount, inAmounts);
    }
    function withdrawAllSingle(
        address gTokenAddress,
        uint256 index,
        uint256 minAmount,
        address pool
    ) public {}
    function withdrawAllBalanced(
        address gTokenAddress,
        uint256[] calldata minAmounts,
        address pool
    ) public {}
    function withdrawalFee(bool pwrd_) external view override returns (uint256) {}
    function withdrawByLPToken(
        bool pwrd_,
        uint256 lpAmount,
        uint256[3] calldata minAmounts
    ) external override {
        _withdrawLp(pwrd_, lpAmount, minAmounts);
    }
    function _withdrawLp(
        bool pwrd_,
        uint256 lpAmount,
        uint256[3] memory minAmount
    ) internal {
        ILifeGuard lg = ILifeGuard(lifeGuard);
        IBuoy buoy = IBuoy(lg.getBuoy());
        uint256 dollarAmount;
        uint256[3] memory _amounts;
        if (whale) {
            for (uint256 i = 0; i < 3; i++) {
                uint256 lpPart = lpAmount.mul(delta[i]).div(10000);
                uint256 amount = buoy.singleStableFromLp(lpPart, int128(i));
                IVault vault = IVault(underlyingVaults[i]);
                vault.withdrawByStrategyOrder(amount, msg.sender, pwrd_);
                _amounts[i] = amount;
            }
        } else {
            uint256 i = vaultOrder[0];
            IVault vault = IVault(underlyingVaults[i]);
            uint256 amount = buoy.singleStableFromLp(lpAmount, int128(i));
            vault.withdrawByStrategyOrder(amount, msg.sender, pwrd_);
            _amounts[i] = amount;
        }
        dollarAmount = buoy.stableToUsd(_amounts, false);
        IToken dt;
        if (pwrd_) {
            dt = IToken(_pwrd);
        } else {
            dt = IToken(gvt);
        }
        dt.burn(msg.sender, dt.factor(), dollarAmount);
    }
    function withdrawByStablecoin(
        bool pwrd_,
        uint256 index,
        uint256 lpAmount,
        uint256 minAmount
    ) external override {
        _withdrawSingle(pwrd_, index, lpAmount, minAmount);
    }
    function withdrawAllSingle(
        bool pwrd_,
        uint256 index,
        uint256 minAmount
    ) external override {}
    function _withdrawSingle(
        bool pwrd_,
        uint256 index,
        uint256 lpAmount,
        uint256 minAmount
    ) internal {
        ILifeGuard lg = ILifeGuard(lifeGuard);
        IBuoy buoy = IBuoy(lg.getBuoy());
        uint256 dollarAmount;
        if (whale) {
            for (uint256 i = 0; i < 3; i++) {
                uint256 lpPart = lpAmount.mul(delta[i]).div(10000);
                uint256 amount = buoy.singleStableFromLp(lpPart, int128(i));
                IVault vault = IVault(underlyingVaults[i]);
                vault.withdrawByStrategyOrder(amount, lifeGuard, pwrd_);
                (dollarAmount, ) = lg.withdrawSingleByExchange(index, 1, msg.sender);
            }
        } else {
            IVault vault = IVault(underlyingVaults[vaultOrder[0]]);
            uint256 amount = buoy.singleStableFromLp(lpAmount, int128(vaultOrder[0]));
            vault.withdrawByStrategyOrder(amount, lifeGuard, pwrd_);
            (dollarAmount, ) = lg.withdrawSingleByExchange(index, 1, msg.sender);
        }
        IToken dt;
        if (pwrd_) {
            dt = IToken(_pwrd);
        } else {
            dt = IToken(gvt);
        }
        dt.burn(msg.sender, dt.factor(), dollarAmount);
    }
    function withdrawAllBalanced(bool pwrd_, uint256[3] calldata minAmounts) external override {}
    function addPool(address pool, address[] calldata tokens) external onlyOwner {
        tokens;
        whiteListedPools[pool] = true;
    }
    function _deposit(uint256 dollarAmount) private {
        _gTokenTotalAssets = _gTokenTotalAssets.add(dollarAmount);
    }
    function _withdraw(uint256 dollarAmount) private {
        _gTokenTotalAssets = _gTokenTotalAssets.sub(dollarAmount);
    }
    function _mintGToken(address gToken, uint256 amount) private {
        IToken dt = IToken(gToken);
        dt.mint(msg.sender, dt.factor(), amount);
        _deposit(amount);
    }
    function _burnGToken(
        address gToken,
        uint256 amount,
        uint256 bonus
    ) private {
        IToken dt = IToken(gToken);
        dt.burn(msg.sender, dt.factor(), amount);
        _withdraw(amount);
    }
    function gTokenTotalAssets() public view override returns (uint256) {
        return _gTokenTotalAssets;
    }
    function setGTokenTotalAssets(uint256 totalAssets) external {
        _gTokenTotalAssets = totalAssets;
    }
    function increaseGTokenTotalAssets(uint256 totalAssets) external {
        _gTokenTotalAssets = _gTokenTotalAssets.add(totalAssets);
    }
    function decreaseGTokenTotalAssets(uint256 totalAssets) external {
        _gTokenTotalAssets = _gTokenTotalAssets.sub(totalAssets);
    }
    function mintGTokens(address gToken, uint256 amount) external {
        _mintGToken(gToken, amount);
    }
    function burnGTokens(address gToken, uint256 amount) external {
        _burnGToken(gToken, amount, 0);
    }
    function vaults() external view override returns (address[N_COINS] memory) {
        uint256 length = underlyingTokens.length;
        address[N_COINS] memory result;
        for (uint256 i = 0; i < length; i++) {
            result[i] = underlyingVaults[i];
        }
        return result;
    }
    function setPnL(address _pnl) external {
        pnl = _pnl;
    }
    function setLifeGuard(address _lifeGuard) external {
        lifeGuard = _lifeGuard;
    }
    function setInsurance(address _insurance) external {
        insurance = _insurance;
    }
    function setUtilisationRatioLimitForDeposit(uint256 _utilisationRatioLimit) external {
        utilisationRatioLimit = _utilisationRatioLimit;
    }
    function increaseGTokenLastAmount(address gTokenAddress, uint256 dollarAmount) external {
        if (gTokenAddress == pwrd) {
            IPnL(pnl).increaseGTokenLastAmount(true, dollarAmount);
        } else {
            IPnL(pnl).increaseGTokenLastAmount(false, dollarAmount);
        }
    }
    function decreaseGTokenLastAmount(
        address gTokenAddress,
        uint256 dollarAmount,
        uint256 bonus
    ) external {
        if (gTokenAddress == pwrd) {
            IPnL(pnl).decreaseGTokenLastAmount(true, dollarAmount, bonus);
        } else {
            IPnL(pnl).decreaseGTokenLastAmount(false, dollarAmount, bonus);
        }
    }
    function setGVT(address token) external {
        gvt = token;
    }
    function setPWRD(address token) external {
        pwrd = token;
    }
    function setTotalAssets(uint256 _totalAssets) external {
        totalAssets = _totalAssets;
    }
    function eoaOnly(address sender) external override {
        sender;
    }
    function withdrawHandler() external view override returns (address) {
        return address(this);
    }
    function depositHandler() external view override returns (address) {
        return address(this);
    }
    function emergencyHandler() external view override returns (address) {
        return address(this);
    }
    function setWhale(bool _whale) external {
        whale = _whale;
    }
    function isValidBigFish(
        bool pwrd,
        bool deposit,
        uint256 amount
    ) external view override returns (bool) {
        return whale;
    }
    function gToken(bool isPWRD) external view override returns (address) {}
    function setSkimPercent(uint256 _percent) external {
        skimPercent = _percent;
    }
    function getSkimPercent() external view override returns (uint256) {
        return skimPercent;
    }
    function emergency(uint256 coin) external {}
    function restart(uint256[] calldata allocations) external {}
    function distributeStrategyGainLoss(uint256 gain, uint256 loss) external override {
        IPnL(pnl).distributeStrategyGainLoss(gain, loss, reward);
    }
    function distributePriceChange() external {
        IPnL(pnl).distributePriceChange(totalAssets);
    }
    function burnGToken(
        bool pwrd,
        bool all,
        address account,
        uint256 amount,
        uint256 bonus
    ) external override {
        IPnL(pnl).decreaseGTokenLastAmount(pwrd, amount, bonus);
        if (pwrd) {
            _burnGToken(_pwrd, amount, bonus);
        } else {
            _burnGToken(gvt, amount, bonus);
        }
    }
    function depositPool() external {
        ILifeGuard(lifeGuard).deposit();
    }
    function depositStablePool(bool rebalance) external {
        ILifeGuard(lifeGuard).depositStable(rebalance);
    }
    function investPool(uint256 amount, uint256[3] memory delta) external {
        ILifeGuard(lifeGuard).invest(amount, delta);
    }
    function mintGToken(
        bool pwrd,
        address account,
        uint256 amount
    ) external override {}
    function getUserAssets(bool pwrd, address account) external view override returns (uint256 deductUsd) {}
    function distributeCurveAssets(uint256 amount, uint256[N_COINS] memory delta) external {
        uint256[N_COINS] memory amounts = ILifeGuard(lifeGuard).distributeCurveVault(amount, delta);
    }
    function addReferral(address account, address referral) external override {}
    function getStrategiesTargetRatio() external view override returns (uint256[] memory result) {
        result = new uint256[](2);
        result[0] = 5000;
        result[1] = 5000;
    }
    function validGTokenDecrease(uint256 amount) external view override returns (bool) {}
}
contract MockLPToken is MockERC20 {
    constructor() public ERC20("LPT", "LPT") {
        _setupDecimals(18);
    }
}
contract MockCurveDeposit is ICurve3Deposit {
    using SafeERC20 for IERC20;
    address[] public coins;
    uint256 N_COINS = 3;
    uint256[] public PRECISION_MUL = [1, 1000000000000, 1000000000000];
    uint256[] public decimals = [18, 6, 6];
    uint256[] public rates = [1001835600000000000, 999482, 999069];
    uint256 constant vp = 1005530723799997871;
    uint256[] vpSingle = [996343755718242128, 994191500557422927, 993764724471177721];
    uint256[] desired_ratio = [250501710687927000, 386958750403203000, 362539538908870000];
    uint256[] poolratio = [20, 40, 40];
    uint256 Fee = 4000;
    MockLPToken PoolToken;
    constructor(address[] memory _tokens, address _PoolToken) public {
        coins = _tokens;
        PoolToken = MockLPToken(_PoolToken);
    }
    function setTokens(
        address[] calldata _tokens,
        uint256[] calldata _precisions,
        uint256[] calldata _rates
    ) external {
        coins = _tokens;
        N_COINS = _tokens.length;
        PRECISION_MUL = _precisions;
        rates = _rates;
    }
    function exchange(
        int128 i,
        int128 j,
        uint256 dx,
        uint256 min_dy
    ) external override {
        i;
        j;
        dx;
        min_dy;
    }
    function add_liquidity(uint256[3] calldata uamounts, uint256 min_mint_amount) external override {
        uint256 amount;
        for (uint256 i; i < N_COINS; i++) {
            IERC20 token = IERC20(coins[i]);
            token.safeTransferFrom(msg.sender, address(this), uamounts[i]);
            amount = ((uamounts[i] * (10**(18 - decimals[i]))) * vpSingle[i]) / (10**18);
        }
        PoolToken.mint(msg.sender, min_mint_amount);
    }
    function remove_liquidity(uint256 amount, uint256[3] calldata min_uamounts) external override {
        require(PoolToken.balanceOf(msg.sender) > amount, "remove_liquidity: !balance");
        PoolToken.burn(msg.sender, amount);
        for (uint256 i; i < N_COINS; i++) {
            IERC20 token = IERC20(coins[i]);
            token.transfer(msg.sender, min_uamounts[i]);
        }
    }
    function remove_liquidity_imbalance(uint256[3] calldata amounts, uint256 max_burn_amount) external override {
        require(PoolToken.balanceOf(msg.sender) > max_burn_amount, "remove_liquidity: !balance");
        PoolToken.burn(msg.sender, max_burn_amount);
        for (uint256 i; i < N_COINS; i++) {
            IERC20 token = IERC20(coins[i]);
            if (amounts[i] > 0) {
                token.safeTransfer(msg.sender, amounts[i]);
            }
        }
    }
    function remove_liquidity_one_coin(
        uint256 _token_amount,
        int128 i,
        uint256 min_amount
    ) external override {
        min_amount;
        require(PoolToken.balanceOf(msg.sender) > _token_amount, "remove_liquidity: !balance");
        uint256 outAmount = ((_token_amount * (10**18)) / vpSingle[uint256(i)]) / PRECISION_MUL[uint256(i)];
        PoolToken.burn(msg.sender, _token_amount);
        IERC20 token = IERC20(coins[uint256(i)]);
        token.safeTransfer(msg.sender, outAmount);
    }
    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view override returns (uint256) {
        uint256 x = rates[uint256(i)] * dx * PRECISION_MUL[uint256(i)];
        uint256 y = rates[uint256(j)] * PRECISION_MUL[uint256(j)];
        return x / y;
    }
    function calc_token_amount(uint256[3] calldata inAmounts, bool deposit) external view returns (uint256) {
        deposit;
        uint256 totalAmount;
        for (uint256 i = 0; i < vpSingle.length; i++) {
            totalAmount += (inAmounts[i] * vpSingle[i]) / (10**decimals[i]);
        }
        return totalAmount;
    }
}
contract MockCurvePool is ICurve3Pool {
    address[] public override coins;
    uint256 N_COINS = 3;
    uint256[] public PRECISION_MUL = [1, 1000000000000, 1000000000000];
    uint256[] public decimals = [18, 6, 6];
    uint256[] public rates = [1001835600000000000, 999482, 999069];
    uint256 constant vp = 1005330723799997871;
    uint256[] vpSingle = [996343755718242128, 994191500557422927, 993764724471177721];
    constructor(address[] memory _tokens) public {
        coins = _tokens;
    }
    function setTokens(
        address[] calldata _tokens,
        uint256[] calldata _precisions,
        uint256[] calldata _rates
    ) external {
        coins = _tokens;
        N_COINS = _tokens.length;
        PRECISION_MUL = _precisions;
        rates = _rates;
    }
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view override returns (uint256) {
        return (vpSingle[uint256(i)] * _token_amount) / ((uint256(10)**18) * PRECISION_MUL[uint256(i)]);
    }
    function calc_token_amount(uint256[3] calldata inAmounts, bool deposit) external view override returns (uint256) {
        deposit;
        uint256 totalAmount;
        for (uint256 i = 0; i < vpSingle.length; i++) {
            totalAmount += (inAmounts[i] * vpSingle[i]) / (10**decimals[i]);
        }
        return totalAmount;
    }
    function balances(int128 i) external view override returns (uint256) {
        i;
    }
    function get_dy(
        int128 i,
        int128 j,
        uint256 dx
    ) external view override returns (uint256) {
        dx;
        uint256 x = rates[uint256(i)] * PRECISION_MUL[uint256(i)] * (10**decimals[uint256(j)]);
        uint256 y = rates[uint256(j)] * PRECISION_MUL[uint256(j)];
        return x / y;
    }
    function get_virtual_price() external view override returns (uint256) {
        return vp;
    }
}
contract MockDAI is MockERC20 {
    constructor() public ERC20("DAI", "DAI") {
        _setupDecimals(18);
    }
}
abstract contract MockGToken is ERC20, Ownable, IToken {
    function mint(
        address account,
        uint256 factor,
        uint256 amount
    ) external override {
        factor;
        require(account != address(0), "Account is empty.");
        require(amount > 0, "amount is less than zero.");
        _mint(account, amount);
    }
    function burn(
        address account,
        uint256 factor,
        uint256 amount
    ) external override {
        factor;
        require(account != address(0), "Account is empty.");
        require(amount > 0, "amount is less than zero.");
        _burn(account, amount);
    }
    function factor() external view override returns (uint256) {}
    function factor(uint256 totalAssets) external view override returns (uint256) {
        totalAssets;
    }
    function burnAll(address account) external override {
        _burn(account, balanceOf(account));
    }
    function totalAssets() external view override returns (uint256) {
        return totalSupply();
    }
    function getPricePerShare() external view override returns (uint256) {}
    function getShareAssets(uint256 shares) external view override returns (uint256) {
        return shares;
    }
    function getAssets(address account) external view override returns (uint256) {
        return balanceOf(account);
    }
}
contract MockGvtToken is MockGToken, Constants {
    constructor() public ERC20("gvt", "gvt") {
        _setupDecimals(DEFAULT_DECIMALS);
    }
}
contract MockInsurance is IInsurance {
    address[] public underlyingVaults;
    address controller;
    uint256 public vaultDeltaIndex = 3;
    uint256[3] public vaultDeltaOrder = [1, 0, 2];
    mapping(uint256 => uint256) public underlyingTokensPercents;
    function calculateDepositDeltasOnAllVaults() external view override returns (uint256[3] memory deltas) {
        deltas[0] = 3333;
        deltas[1] = 3333;
        deltas[2] = 3333;
    }
    function rebalanceTrigger() external view override returns (bool sysNeedRebalance) {}
    function rebalance() external override {}
    function setController(address _controller) external {
        controller = _controller;
    }
    function setupTokens() external {
        underlyingTokensPercents[0] = 3000;
        underlyingTokensPercents[1] = 3000;
        underlyingTokensPercents[2] = 4000;
    }
    function rebalanceForWithdraw(uint256 withdrawUsd, bool pwrd) external override returns (bool) {}
    function setVaultDeltaIndex(uint256 _vaultDeltaIndex) external {
        require(_vaultDeltaIndex < 3, "invalid index");
        vaultDeltaIndex = _vaultDeltaIndex;
    }
    function getVaultDeltaForDeposit(uint256 amount)
        external
        view
        override
        returns (
            uint256[3] memory,
            uint256[3] memory,
            uint256
        )
    {
        amount;
        uint256[3] memory empty;
        if (vaultDeltaIndex == 3) {
            return (empty, vaultDeltaOrder, 3);
        } else {
            uint256[3] memory indexes;
            indexes[0] = vaultDeltaIndex;
            return (empty, indexes, 1);
        }
    }
    function calcSkim() external view override returns (uint256) {}
    function getStrategiesTargetRatio(uint256 utilRatio) external view override returns (uint256[] memory result) {
        result = new uint256[](2);
        result[0] = 5000;
        result[1] = 5000;
    }
    function getDelta(uint256 withdrawUsd) external view override returns (uint256[3] memory delta) {
        withdrawUsd;
        delta[0] = 3000;
        delta[1] = 3000;
        delta[2] = 4000;
    }
    function setUnderlyingTokenPercent(uint256 coinIndex, uint256 percent) external override {
        underlyingTokensPercents[coinIndex] = percent;
    }
    function sortVaultsByDelta(bool bigFirst) external view override returns (uint256[3] memory) {
        return vaultDeltaOrder;
    }
}
contract MockLifeGuard is Constants, Controllable, ILifeGuard {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address[] public stablecoins;
    address public buoy;
    uint256 constant vp = 1005330723799997871;
    uint256[] public decimals = [18, 6, 6];
    uint256[] vpSingle = [996343755718242128, 994191500557422927, 993764724471177721];
    uint256[] public balanced = [30, 30, 40];
    uint256[] public inAmounts;
    uint256 private _totalAssets;
    uint256 private _totalAssetsUsd;
    uint256 private _depositStableAmount;
    mapping(uint256 => uint256) public override assets;
    function setDepositStableAmount(uint256 depositStableAmount) external {
        _depositStableAmount = depositStableAmount;
    }
    function setStablecoins(address[] calldata _stablecoins) external {
        stablecoins = _stablecoins;
    }
    function setBuoy(address _buoy) external {
        buoy = _buoy;
    }
    function totalAssets() external view override returns (uint256) {
        return usdToLp(_totalAssetsUsd);
    }
    function _stableToUsd(uint256[] memory inAmounts, bool _deposit) private view returns (uint256) {
        uint256 lp = _stableToLp(inAmounts, _deposit);
        return _lpToUsd(lp);
    }
    function stableToLp(uint256[] calldata inAmounts, bool _deposit) external view returns (uint256) {
        return _stableToLp(inAmounts, _deposit);
    }
    function _stableToLp(uint256[] memory inAmounts, bool _deposit) private view returns (uint256) {
        uint256 totalAmount;
        for (uint256 i = 0; i < vpSingle.length; i++) {
            totalAmount = totalAmount.add(inAmounts[i].mul(vpSingle[i]).div(10**decimals[i]));
        }
        return totalAmount;
    }
    function singleStableFromLp(uint256 inAmount, uint256 i) external view returns (uint256) {
        return _singleStableFromLp(inAmount, i);
    }
    function _singleStableFromLp(uint256 inAmount, uint256 i) private view returns (uint256) {
        return inAmount.mul(10**decimals[i]).div(vpSingle[i]);
    }
    function underlyingCoins(uint256 index) external view returns (address coin) {
        return stablecoins[index];
    }
    function depositStable(bool curve) external override returns (uint256) {
        return _depositStableAmount;
    }
    function setInAmounts(uint256[] memory _inAmounts) external {
        inAmounts = _inAmounts;
    }
    function deposit() external override returns (uint256 usdAmount) {
        usdAmount = _stableToUsd(inAmounts, true);
        _totalAssetsUsd += usdAmount;
    }
    function withdraw(uint256 inAmount, address recipient)
        external
        returns (uint256 usdAmount, uint256[] memory amounts)
    {
        usdAmount = _lpToUsd(inAmount);
        if (_totalAssetsUsd > usdAmount) _totalAssetsUsd -= usdAmount;
        else _totalAssetsUsd = 0;
        amounts = new uint256[](3);
        address[N_COINS] memory vaults = _controller().vaults();
        for (uint256 i = 0; i < 3; i++) {
            uint256 lpAmount = inAmount.mul(balanced[i]).div(100);
            amounts[i] = _singleStableFromLp(lpAmount, i);
            IERC20 token = IERC20(IVault(vaults[i]).token());
            if (token.balanceOf(vaults[i]) > amounts[i]) token.transferFrom(vaults[i], recipient, amounts[i]);
        }
    }
    function withdrawSingleByLiquidity(
        uint256 i,
        uint256 minAmount,
        address recipient
    ) external override returns (uint256 usdAmount, uint256 amount) {
        usdAmount = _lpToUsd(inAmounts[0]);
        amount = _singleStableFromLp(inAmounts[0], i);
        address[N_COINS] memory vaults = _controller().vaults();
        IERC20 token = IERC20(IVault(vaults[i]).token());
        if (token.balanceOf(vaults[i]) > amount) token.transferFrom(vaults[i], recipient, amount);
    }
    function withdrawSingleByExchange(
        uint256 i,
        uint256 minAmount,
        address recipient
    ) external override returns (uint256 usdAmount, uint256 amount) {
        usdAmount = _lpToUsd(inAmounts[0]);
        amount = _singleStableFromLp(inAmounts[0], i);
        address[N_COINS] memory vaults = _controller().vaults();
        IERC20 token = IERC20(IVault(vaults[i]).token());
        if (token.balanceOf(vaults[i]) > amount) token.transferFrom(vaults[i], recipient, amount);
    }
    function invest(uint256 whaleDepositAmount, uint256[3] calldata delta) external override returns (uint256) {
        address[N_COINS] memory vaults = _controller().vaults();
        for (uint256 i; i < vaults.length; i++) {
            IERC20 token = IERC20(IVault(vaults[i]).token());
            token.transfer(vaults[i], token.balanceOf(address(this)));
        }
        _totalAssetsUsd -= whaleDepositAmount;
        return whaleDepositAmount;
    }
    function getEmergencyPrice(uint256 token) external view returns (uint256, uint256) {
        uint256 ratios = uint256(10)**decimals[token];
        uint256 decimals = uint256(10)**decimals[token];
        return (ratios, decimals);
    }
    function singleStableToUsd(uint256 inAmount, uint256 i) external view returns (uint256) {
        uint256[] memory inAmounts = new uint256[](stablecoins.length);
        inAmounts[i] = inAmount;
        return _stableToUsd(inAmounts, true);
    }
    function singleStableFromUsd(uint256 inAmount, uint256 i) public view returns (uint256) {
        return _singleStableFromLp(_lpToUsd(inAmount), i);
    }
    function _lpToUsd(uint256 inAmount) private pure returns (uint256) {
        return inAmount.mul(vp).div(DEFAULT_DECIMALS_FACTOR);
    }
    function usdToLp(uint256 inAmount) private view returns (uint256) {
        return inAmount.mul(DEFAULT_DECIMALS_FACTOR).div(vp);
    }
    function getBuoy() external view override returns (address) {
        return buoy;
    }
    address public exchanger;
    function setExchanger(address _exchanger) external {
        exchanger = _exchanger;
    }
    function investSingle(
        uint256[3] calldata inAmounts,
        uint256 i,
        uint256 j
    ) external override returns (uint256 dollarAmount) {
        dollarAmount = IBuoy(buoy).stableToUsd(inAmounts, true);
        for (uint256 k; k < 3; k++) {
            if (k == i || k == j) continue;
            uint256 inBalance = inAmounts[k];
            if (inBalance > 0) {
                _exchange(inBalance, k, i);
            }
        }
        if (inAmounts[i] > 0) {
            address vault = _controller().vaults()[i];
            IERC20 token = IERC20(IVault(vault).token());
            token.transfer(vault, token.balanceOf(address(this)));
        }
        if (inAmounts[j] > 0) {
            address vault = _controller().vaults()[j];
            IERC20 token = IERC20(IVault(vault).token());
            token.transfer(vault, token.balanceOf(address(this)));
        }
    }
    function _exchange(
        uint256 amount,
        uint256 src,
        uint256 dest
    ) private returns (uint256) {
        IERC20(stablecoins[src]).transfer(exchanger, amount);
        uint256 descAmount = amount.mul(10**decimals[dest]).div(10**decimals[src]);
        IERC20(stablecoins[dest]).transferFrom(exchanger, address(this), descAmount);
        return descAmount;
    }
    function availableLP() external view override returns (uint256) {}
    function availableUsd() external view override returns (uint256 dollar) {}
    function investToCurveVault() external override {}
    function distributeCurveVault(uint256 amount, uint256[3] memory delta)
        external
        override
        returns (uint256[3] memory)
    {}
    function totalAssetsUsd() external view override returns (uint256) {
        return _totalAssetsUsd;
    }
    function investToCurveVaultTrigger() external view override returns (bool) {}
    function getAssets() external view override returns (uint256[3] memory) {}
}
contract MockPnL is Constants, IPnL {
    using SafeMath for uint256;
    uint256 public override lastGvtAssets;
    uint256 public override lastPwrdAssets;
    uint256 public totalProfit;
    function calcPnL() external view override returns (uint256, uint256) {
        return (lastGvtAssets, lastPwrdAssets);
    }
    function setLastGvtAssets(uint256 _lastGvtAssets) public {
        lastGvtAssets = _lastGvtAssets;
    }
    function setLastPwrdAssets(uint256 _lastPwrdAssets) public {
        lastPwrdAssets = _lastPwrdAssets;
    }
    function setTotalProfit(uint256 _totalProfit) public {
        totalProfit = _totalProfit;
    }
    function increaseGTokenLastAmount(bool pwrd, uint256 dollarAmount) external override {}
    function decreaseGTokenLastAmount(
        bool pwrd,
        uint256 dollarAmount,
        uint256 bonus
    ) external override {}
    function utilisationRatio() external view override returns (uint256) {
        return lastGvtAssets != 0 ? lastPwrdAssets.mul(PERCENTAGE_DECIMAL_FACTOR).div(lastGvtAssets) : 0;
    }
    function emergencyPnL() external override {}
    function recover() external override {}
    function distributeStrategyGainLoss(
        uint256 gain,
        uint256 loss,
        address reward
    ) external override {}
    function distributePriceChange(uint256 currentTotalAssets) external override {}
}
contract MockPWRDToken is MockGToken, Constants {
    constructor() public ERC20("pwrd", "pwrd") {
        _setupDecimals(DEFAULT_DECIMALS);
    }
}
contract MockTUSD is MockERC20 {
        constructor() public ERC20("TUSD", "TUSD")  {
                        _setupDecimals(18);
        }
}
contract MockUSDC is MockERC20 {
    constructor() public ERC20("USDC", "USDC") {
        _setupDecimals(6);
    }
}
contract MockUSDT is MockERC20 {
    constructor() public ERC20("USDT", "USDT") {
        _setupDecimals(6);
    }
}
contract MockVaultAdaptor is IVault, Constants {
    using SafeMath for uint256;
    IERC20 public underlyingToken;
    uint256 public total = 0;
    uint256 public totalEstimated = 0;
    uint256 public amountAvailable;
    uint256 public countOfStrategies;
    address public override vault;
    address[] harvestQueue;
    uint256[] expectedDebtLimits;
    mapping(uint256 => uint256) strategyEstimatedAssets;
    address controller;
    uint256 amountToController;
    uint256 public gain;
    uint256 public loss;
    uint256 public startBlock;
    uint256 public swapInterestIncrement = 0;
    uint256 public strategiesLength;
    uint256 public investThreshold;
    uint256 public strategyRatioBuffer;
    constructor() public {}
    function setToken(address _token) external {}
    function setStrategiesLength(uint256 _strategiesLength) external {
        strategiesLength = _strategiesLength;
    }
    function setInvestThreshold(uint256 _investThreshold) external {
        investThreshold = _investThreshold;
    }
    function setStrategyRatioBuffer(uint256 _strategyRatioBuffer) external {
        strategyRatioBuffer = _strategyRatioBuffer;
    }
    function setUnderlyingToken(address _token) external {
        underlyingToken = IERC20(_token);
    }
    function setTotal(uint256 _total) external {
        total = _total;
    }
    function setController(address _controller) external {
        controller = _controller;
    }
    function setAmountToController(uint256 _amountToController) external {
        amountToController = _amountToController;
    }
    function setTotalEstimated(uint256 _totalEstimated) external {
        totalEstimated = _totalEstimated;
    }
    function setStrategyAssets(uint256 _index, uint256 _totalEstimated) external {
        strategyEstimatedAssets[_index] = _totalEstimated;
    }
    function setCountOfStrategies(uint32 _countOfStrategies) external {
        countOfStrategies = _countOfStrategies;
    }
    function setVault(address _vault) external {
        vault = _vault;
    }
    function setHarvestQueueAndLimits(address[] calldata _queue, uint256[] calldata _debtLimits) external {
        harvestQueue = _queue;
        expectedDebtLimits = _debtLimits;
    }
    function approve(address account, uint256 amount) external {
        underlyingToken.approve(account, amount);
    }
    function getHarvestQueueAndLimits() external view returns (address[] memory, uint256[] memory) {
        return (harvestQueue, expectedDebtLimits);
    }
    function strategyHarvest(uint256 _index) external override returns (bool) {}
    function strategyHarvestTrigger(uint256 _index, uint256 _callCost) external view override returns (bool) {}
    function deposit(uint256 _amount) external override {
        underlyingToken.transferFrom(msg.sender, address(this), _amount);
    }
    function withdraw(uint256 _amount) external override {
        underlyingToken.transfer(msg.sender, _amount);
    }
    function withdraw(uint256 _amount, address recipient) external override {
        recipient;
        underlyingToken.transfer(msg.sender, _amount);
    }
    function withdrawByStrategyOrder(
        uint256 _amount,
        address _recipient,
        bool pwrd
    ) external override {
        pwrd;
        underlyingToken.transfer(_recipient, _amount);
    }
    function depositAmountAvailable(uint256 _amount) external view returns (uint256) {
        _amount;
        return amountAvailable;
    }
    function setDepositAmountAvailable(uint256 _amountAvailable) external returns (uint256) {
        amountAvailable = _amountAvailable;
    }
    function addTotalAssets(uint256 addAsset) public {
        total += addAsset;
    }
    function startSwap(uint256 rate) external {
        startBlock = block.number;
        swapInterestIncrement = rate;
    }
    function getStartBlock() external view returns (uint256) {
        return startBlock;
    }
    function totalAssets() external view override returns (uint256) {
        uint256 interest = 0;
        if (startBlock != 0) {
            uint256 blockAdvancement = block.number.sub(startBlock);
            interest = blockAdvancement.mul(swapInterestIncrement);
        }
        return underlyingToken.balanceOf(address(this)).add(interest).add(total);
    }
    function updateStrategyRatio(uint256[] calldata debtratios) external override {}
    function getStrategiesLength() external view override returns (uint256) {
        return countOfStrategies;
    }
    function setGain(uint256 _gain) external {
        gain = _gain;
    }
    function setLoss(uint256 _loss) external {
        loss = _loss;
    }
    function getStrategyAssets(uint256 index) external view override returns (uint256) {
        return strategyEstimatedAssets[index];
    }
    function token() external view override returns (address) {
        return address(underlyingToken);
    }
    function withdrawByStrategyIndex(
        uint256 amount,
        address recipient,
        uint256 strategyIndex
    ) external override {}
    function investTrigger() external view override returns (bool) {}
    function invest() external override {}
    function withdrawToAdapter(uint256 amount) external {}
}
interface IYearnV2Strategy {
    function vault() external view returns (address);
    function setVault(address _vault) external;
    function keeper() external view returns (address);
    function setKeeper(address _keeper) external;
    function harvestTrigger(uint256 callCost) external view returns (bool);
    function harvest() external;
    function withdraw(uint256 _amount) external;
    function estimatedTotalAssets() external view returns (uint256);
}
struct StrategyParams {
    uint256 performanceFee;
    uint256 activation;
    uint256 debtRatio;
    uint256 minDebtPerHarvest;
    uint256 maxDebtPerHarvest;
    uint256 lastReport;
    uint256 totalDebt;
    uint256 totalGain;
    uint256 totalLoss;
}
interface IYearnV2Vault {
    function strategies(address _strategy) external view returns (StrategyParams memory);
    function totalAssets() external view returns (uint256);
    function pricePerShare() external view returns (uint256);
    function deposit(uint256 _amount, address _recipient) external;
    function withdraw(
        uint256 maxShares,
        address recipient,
        uint256 maxLoss
    )
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );
    function withdrawByStrategy(
        address[20] calldata _strategies,
        uint256 maxShares,
        address recipient,
        uint256 maxLoss
    ) external returns (uint256);
    function depositLimit() external view returns (uint256);
    function debtOutstanding(address strategy) external view returns (uint256);
    function totalDebt() external view returns (uint256);
    function updateStrategyDebtRatio(address strategy, uint256 ratio) external;
    function withdrawalQueue(uint256 index) external view returns (address);
    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external returns (uint256);
}
contract MockYearnV2Vault is ERC20, IYearnV2Vault {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IERC20 public token;
    uint256 public override depositLimit;
    uint256 public override totalDebt;
    uint256 public total;
    uint256 public airlock;
    mapping(address => uint256) public strategiesDebtLimit;
    mapping(address => uint256) public strategiesTotalDebt;
    mapping(address => uint256) public strategiesDebtRatio;
    address public depositRecipient;
    address public withdrawRecipient;
    address[] public override withdrawalQueue;
    uint256 public amount;
    uint256[] public debtRatios;
    constructor(address _token) public ERC20("Vault", "Vault") {
        _setupDecimals(18);
        token = IERC20(_token);
    }
    function approveStrategies(address[] calldata strategyArray) external {
        for (uint256 i = 0; i < strategyArray.length; i++) {
            token.approve(strategyArray[i], type(uint256).max);
        }
    }
    function setStrategies(address[] calldata _strategies) external {
        for (uint256 i = 0; i < _strategies.length; i++) {
            require(_strategies[i] != address(0), "Invalid strategy address.");
        }
        withdrawalQueue = _strategies;
    }
    function setStrategyDebtRatio(address strategy, uint256 debtRatio) external {
        strategiesDebtRatio[strategy] = debtRatio;
    }
    function getStrategiesDebtRatio() external view returns (uint256[] memory ratios) {
        ratios = new uint256[](withdrawalQueue.length);
        for (uint256 i = 0; i < withdrawalQueue.length; i++) {
            ratios[i] = strategiesDebtRatio[withdrawalQueue[i]];
        }
    }
    function strategies(address _strategy) external view override returns (StrategyParams memory result) {
        result.debtRatio = strategiesDebtRatio[_strategy];
    }
    function setTotalAssets(uint256 _total) external {
        total = _total;
    }
    function totalAssets() public view override returns (uint256) {
        uint256 val = token.balanceOf(address(this));
        for (uint256 i = 0; i < withdrawalQueue.length; i++) {
            val = val.add(token.balanceOf(withdrawalQueue[i]));
        }
        return val;
    }
    function setAirlock(uint256 _airlock) external {
        airlock = _airlock;
    }
    function setTotalDebt(uint256 _totalDebt) public {
        totalDebt = _totalDebt;
    }
    function deposit(uint256 _amount, address _recipient) external override {
        totalDebt = totalDebt.add(_amount);
        total = total.add(_amount);
        token.safeTransferFrom(msg.sender, address(this), _amount);
        depositRecipient = _recipient;
    }
    function withdrawByStrategy(
        address[20] calldata _strategies,
        uint256 maxShares,
        address recipient,
        uint256 maxLoss
    ) external override returns (uint256) {}
    function withdraw(
        uint256 maxShares,
        address _recipient,
        uint256 maxLoss
    )
        external
        override
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        maxLoss;
        uint256 _total = token.balanceOf(address(this));
        uint256 _amount = maxShares;
        if (_total < _amount) {
            for (uint256 i = 0; i < withdrawalQueue.length; i++) {
                address strategy = withdrawalQueue[i];
                uint256 stratDebt = strategiesDebtLimit[strategy];
                if (stratDebt > 0) {
                    strategiesDebtLimit[strategy] = 0;
                    IYearnV2Strategy(strategy).withdraw(stratDebt);
                    totalDebt = totalDebt.sub(stratDebt);
                }
            }
        }
        token.safeTransfer(_recipient, _amount);
        withdrawRecipient = _recipient;
    }
    function report(
        uint256 _gain,
        uint256 _loss,
        uint256 _debtPayment
    ) external override returns (uint256) {
        _gain;
        _loss;
        _debtPayment;
        address strategy = msg.sender;
        uint256 sBalance = token.balanceOf(strategy);
        if (sBalance > strategiesDebtLimit[strategy]) {
            uint256 outAmount = sBalance.sub(strategiesDebtLimit[strategy]);
            token.safeTransferFrom(strategy, address(this), outAmount);
        } else {
            uint256 inAmount = strategiesDebtLimit[strategy].sub(sBalance);
            token.safeTransfer(
                strategy,
                inAmount > token.balanceOf(address(this)) ? token.balanceOf(address(this)) : inAmount
            );
        }
    }
    function updateStrategyDebtRatio(address strategy, uint256 debtRatio) external override {
        strategiesDebtRatio[strategy] = debtRatio;
    }
    function debtOutstanding(address) external view override returns (uint256) {
        return 0;
    }
    function setStrategyTotalDebt(address _strategy, uint256 _totalDebt) external {
        strategiesTotalDebt[_strategy] = _totalDebt;
    }
    function pricePerShare() external view override returns (uint256) {
        if (this.totalAssets() == 0) {
            return uint256(10)**IERC20Detailed(address(token)).decimals();
        } else {
            return this.totalAssets().mul(IERC20Detailed(address(token)).decimals()).div(this.totalSupply());
        }
    }
    function getStrategyDebtLimit(address strategy) external view returns (uint256) {
        return strategiesDebtLimit[strategy];
    }
    function getStrategyTotalDebt(address strategy) external view returns (uint256) {
        return strategiesTotalDebt[strategy];
    }
}
contract MockYearnV2Strategy is ERC20, IYearnV2Strategy {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IERC20 public token;
    uint256 public harvestAmount;
    uint256 public estimatedAmount;
    bool public worthHarvest;
    address public override vault;
    address public override keeper;
    address public pool;
    constructor(address _token) public ERC20("Strategy", "Strategy") {
        _setupDecimals(18);
        token = IERC20(_token);
    }
    function withdraw(uint256 _amount) external override {
        token.transfer(vault, _amount);
    }
    function harvest() external override {
        uint256 gain = 0;
        uint256 loss = 0;
        uint256 delt = 0;
        IYearnV2Vault(vault).report(gain, loss, delt);
    }
    function setHarvestAmount(uint256 _amount) external {
        harvestAmount = _amount;
    }
    function setVault(address _vault) external override {
        vault = _vault;
        token.safeApprove(_vault, type(uint256).max);
    }
    function setKeeper(address _keeper) external override {
        keeper = _keeper;
    }
    function setPool(address _pool) external {
        pool = _pool;
    }
    function setWorthHarvest(bool _worthHarvest) external {
        worthHarvest = _worthHarvest;
    }
    function harvestTrigger(uint256 callCost) public view override returns (bool) {
        callCost;
        return worthHarvest;
    }
    function estimatedTotalAssets() public view override returns (uint256) {
        return token.balanceOf(address(this));
    }
    function setEstimatedAmount(uint256 _estimatedAmount) external {
        estimatedAmount = _estimatedAmount;
    }
}
contract PnL is Controllable, Constants, FixedGTokens, IPnL {
    using SafeMath for uint256;
    uint256 public override lastGvtAssets;
    uint256 public override lastPwrdAssets;
    bool public rebase = true;
    uint256 public performanceFee; 
    event LogRebaseSwitch(bool status);
    event LogNewPerfromanceFee(uint256 fee);
    event LogNewGtokenChange(bool pwrd, int256 change);
    event LogPnLExecution(
        uint256 deductedAssets,
        int256 totalPnL,
        int256 investPnL,
        int256 pricePnL,
        uint256 withdrawalBonus,
        uint256 performanceBonus,
        uint256 beforeGvtAssets,
        uint256 beforePwrdAssets,
        uint256 afterGvtAssets,
        uint256 afterPwrdAssets
    );
    constructor(
        address pwrd,
        address gvt,
        uint256 pwrdAssets,
        uint256 gvtAssets
    ) public FixedGTokens(pwrd, gvt) {
        lastPwrdAssets = pwrdAssets;
        lastGvtAssets = gvtAssets;
    }
    function setRebase(bool _rebase) external onlyOwner {
        rebase = _rebase;
        emit LogRebaseSwitch(_rebase);
    }
    function setPerformanceFee(uint256 _performanceFee) external onlyOwner {
        performanceFee = _performanceFee;
        emit LogNewPerfromanceFee(_performanceFee);
    }
    function increaseGTokenLastAmount(bool pwrd, uint256 dollarAmount) external override {
        require(msg.sender == controller, "increaseGTokenLastAmount: !controller");
        if (!pwrd) {
            lastGvtAssets = lastGvtAssets.add(dollarAmount);
        } else {
            lastPwrdAssets = lastPwrdAssets.add(dollarAmount);
        }
        emit LogNewGtokenChange(pwrd, int256(dollarAmount));
    }
    function decreaseGTokenLastAmount(
        bool pwrd,
        uint256 dollarAmount,
        uint256 bonus
    ) external override {
        require(msg.sender == controller, "decreaseGTokenLastAmount: !controller");
        uint256 lastGA = lastGvtAssets;
        uint256 lastPA = lastPwrdAssets;
        if (!pwrd) {
            lastGA = dollarAmount > lastGA ? 0 : lastGA.sub(dollarAmount);
        } else {
            lastPA = dollarAmount > lastPA ? 0 : lastPA.sub(dollarAmount);
        }
        if (bonus > 0) {
            uint256 preGABeforeBonus = lastGA;
            uint256 prePABeforeBonus = lastPA;
            uint256 preTABeforeBonus = preGABeforeBonus.add(prePABeforeBonus);
            if (rebase) {
                lastGA = preGABeforeBonus.add(bonus.mul(preGABeforeBonus).div(preTABeforeBonus));
                lastPA = prePABeforeBonus.add(bonus.mul(prePABeforeBonus).div(preTABeforeBonus));
            } else {
                lastGA = preGABeforeBonus.add(bonus);
            }
            emit LogPnLExecution(0, int256(bonus), 0, 0, bonus, 0, preGABeforeBonus, prePABeforeBonus, lastGA, lastPA);
        }
        lastGvtAssets = lastGA;
        lastPwrdAssets = lastPA;
        emit LogNewGtokenChange(pwrd, int256(-dollarAmount));
    }
    function calcPnL() external view override returns (uint256, uint256) {
        return (lastGvtAssets, lastPwrdAssets);
    }
    function utilisationRatio() external view override returns (uint256) {
        return lastGvtAssets != 0 ? lastPwrdAssets.mul(PERCENTAGE_DECIMAL_FACTOR).div(lastGvtAssets) : 0;
    }
    function emergencyPnL() external override {
        require(msg.sender == controller, "emergencyPnL: !controller");
        forceDistribute();
    }
    function recover() external override {
        require(msg.sender == controller, "recover: !controller");
        forceDistribute();
    }
    function handleInvestGain(
        uint256 gvtAssets,
        uint256 pwrdAssets,
        uint256 profit,
        address reward
    )
        private
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        uint256 performanceBonus;
        if (performanceFee > 0 && reward != address(0)) {
            performanceBonus = profit.mul(performanceFee).div(PERCENTAGE_DECIMAL_FACTOR);
            profit = profit.sub(performanceBonus);
        }
        if (rebase) {
            uint256 totalAssets = gvtAssets.add(pwrdAssets);
            uint256 gvtProfit = profit.mul(gvtAssets).div(totalAssets);
            uint256 pwrdProfit = profit.mul(pwrdAssets).div(totalAssets);
            uint256 factor = pwrdAssets.mul(10000).div(gvtAssets);
            if (factor > 10000) factor = 10000;
            if (factor < 8000) {
                factor = factor.mul(3).div(8).add(3000);
            } else {
                factor = factor.sub(8000).mul(2).add(6000);
            }
            uint256 portionFromPwrdProfit = pwrdProfit.mul(factor).div(10000);
            gvtAssets = gvtAssets.add(gvtProfit.add(portionFromPwrdProfit));
            pwrdAssets = pwrdAssets.add(pwrdProfit.sub(portionFromPwrdProfit));
        } else {
            gvtAssets = gvtAssets.add(profit);
        }
        return (gvtAssets, pwrdAssets, performanceBonus);
    }
    function handleLoss(
        uint256 gvtAssets,
        uint256 pwrdAssets,
        uint256 loss
    ) private pure returns (uint256, uint256) {
        uint256 maxGvtLoss = gvtAssets.sub(DEFAULT_DECIMALS_FACTOR);
        if (loss > maxGvtLoss) {
            gvtAssets = DEFAULT_DECIMALS_FACTOR;
            pwrdAssets = pwrdAssets.sub(loss.sub(maxGvtLoss));
        } else {
            gvtAssets = gvtAssets - loss;
        }
        return (gvtAssets, pwrdAssets);
    }
    function forceDistribute() private {
        uint256 total = _controller().totalAssets();
        if (total > lastPwrdAssets.add(DEFAULT_DECIMALS_FACTOR)) {
            lastGvtAssets = total - lastPwrdAssets;
        } else {
            lastGvtAssets = DEFAULT_DECIMALS_FACTOR;
            lastPwrdAssets = total.sub(DEFAULT_DECIMALS_FACTOR);
        }
    }
    function distributeStrategyGainLoss(
        uint256 gain,
        uint256 loss,
        address reward
    ) external override {
        require(msg.sender == controller, "!Controller");
        uint256 lastGA = lastGvtAssets;
        uint256 lastPA = lastPwrdAssets;
        uint256 performanceBonus;
        uint256 gvtAssets;
        uint256 pwrdAssets;
        int256 investPnL;
        if (gain > 0) {
            (gvtAssets, pwrdAssets, performanceBonus) = handleInvestGain(lastGA, lastPA, gain, reward);
            if (performanceBonus > 0) {
                gvt.mint(reward, gvt.factor(gvtAssets), performanceBonus);
                gvtAssets = gvtAssets.add(performanceBonus);
            }
            lastGvtAssets = gvtAssets;
            lastPwrdAssets = pwrdAssets;
            investPnL = int256(gain);
        } else if (loss > 0) {
            (lastGvtAssets, lastPwrdAssets) = handleLoss(lastGA, lastPA, loss);
            investPnL = -int256(loss);
        }
        emit LogPnLExecution(
            0,
            investPnL,
            investPnL,
            0,
            0,
            performanceBonus,
            lastGA,
            lastPA,
            lastGvtAssets,
            lastPwrdAssets
        );
    }
    function distributePriceChange(uint256 currentTotalAssets) external override {
        require(msg.sender == controller, "!Controller");
        uint256 gvtAssets = lastGvtAssets;
        uint256 pwrdAssets = lastPwrdAssets;
        uint256 totalAssets = gvtAssets.add(pwrdAssets);
        if (currentTotalAssets > totalAssets) {
            lastGvtAssets = gvtAssets.add(currentTotalAssets.sub(totalAssets));
        } else if (currentTotalAssets < totalAssets) {
            (lastGvtAssets, lastPwrdAssets) = handleLoss(gvtAssets, pwrdAssets, totalAssets.sub(currentTotalAssets));
        }
        int256 priceChange = int256(currentTotalAssets) - int256(totalAssets);
        emit LogPnLExecution(
            0,
            priceChange,
            0,
            priceChange,
            0,
            0,
            gvtAssets,
            pwrdAssets,
            lastGvtAssets,
            lastPwrdAssets
        );
    }
}
contract LifeGuard3Pool is ILifeGuard, Controllable, Whitelist, FixedStablecoins {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    ICurve3Deposit public immutable crv3pool; 
    IERC20 public immutable lpToken; 
    IBuoy public immutable buoy; 
    address public insurance;
    address public depositHandler;
    address public withdrawHandler;
    uint256 public investToCurveThreshold;
    mapping(uint256 => uint256) public override assets;
    event LogHealhCheckUpdate(bool status);
    event LogNewCurveThreshold(uint256 threshold);
    event LogNewEmergencyWithdrawal(uint256 indexed token1, uint256 indexed token2, uint256 ratio, uint256 decimals);
    event LogNewInvest(
        uint256 depositAmount,
        uint256[N_COINS] delta,
        uint256[N_COINS] amounts,
        uint256 dollarAmount,
        bool needSkim
    );
    event LogNewStableDeposit(uint256[N_COINS] inAmounts, uint256 lpToken, bool rebalance);
    constructor(
        address _crv3pool,
        address poolToken,
        address _buoy,
        address[N_COINS] memory _tokens,
        uint256[N_COINS] memory _decimals
    ) public FixedStablecoins(_tokens, _decimals) {
        crv3pool = ICurve3Deposit(_crv3pool);
        buoy = IBuoy(_buoy);
        lpToken = IERC20(poolToken);
        for (uint256 i = 0; i < N_COINS; i++) {
            IERC20(_tokens[i]).safeApprove(_crv3pool, type(uint256).max);
        }
    }
    function setDependencies() external onlyOwner {
        IController ctrl = _controller();
        if (withdrawHandler != address(0)) {
            for (uint256 i = 0; i < N_COINS; i++) {
                address coin = getToken(i);
                IERC20(coin).safeApprove(withdrawHandler, uint256(0));
            }
        }
        withdrawHandler = ctrl.withdrawHandler();
        for (uint256 i = 0; i < N_COINS; i++) {
            address coin = getToken(i);
            IERC20(coin).safeApprove(withdrawHandler, uint256(0));
            IERC20(coin).safeApprove(withdrawHandler, type(uint256).max);
        }
        depositHandler = ctrl.depositHandler();
        insurance = ctrl.insurance();
    }
    function getAssets() external view override returns (uint256[N_COINS] memory _assets) {
        for (uint256 i; i < N_COINS; i++) {
            _assets[i] = assets[i];
        }
    }
    function approveVaults(uint256 index) external onlyOwner {
        IVault vault;
        if (index < N_COINS) {
            vault = IVault(_controller().underlyingVaults(index));
        } else {
            vault = IVault(_controller().curveVault());
        }
        address coin = vault.token();
        IERC20(coin).safeApprove(address(vault), uint256(0));
        IERC20(coin).safeApprove(address(vault), type(uint256).max);
    }
    function setInvestToCurveThreshold(uint256 _investToCurveThreshold) external onlyOwner {
        investToCurveThreshold = _investToCurveThreshold;
        emit LogNewCurveThreshold(_investToCurveThreshold);
    }
    function investToCurveVault() external override onlyWhitelist {
        uint256[N_COINS] memory _inAmounts;
        for (uint256 i = 0; i < N_COINS; i++) {
            _inAmounts[i] = assets[i];
            assets[i] = 0;
        }
        crv3pool.add_liquidity(_inAmounts, 0);
        _investToVault(N_COINS, false);
    }
    function investToCurveVaultTrigger() external view override returns (bool invest) {
        uint256 totalAssetsLP = _totalAssets();
        return totalAssetsLP > investToCurveThreshold.mul(uint256(10)**IERC20Detailed(address(lpToken)).decimals());
    }
    function distributeCurveVault(uint256 amount, uint256[N_COINS] memory delta)
        external
        override
        returns (uint256[N_COINS] memory)
    {
        require(msg.sender == controller, "distributeCurveVault: !controller");
        IVault vault = IVault(_controller().curveVault());
        vault.withdraw(amount);
        _withdrawUnbalanced(amount, delta);
        uint256[N_COINS] memory amounts;
        for (uint256 i = 0; i < N_COINS; i++) {
            amounts[i] = _investToVault(i, false);
        }
        return amounts;
    }
    function depositStable(bool rebalance) external override returns (uint256) {
        require(msg.sender == withdrawHandler || msg.sender == insurance, "depositStable: !depositHandler");
        uint256[N_COINS] memory _inAmounts;
        uint256 countOfStableHasAssets = 0;
        for (uint256 i = 0; i < N_COINS; i++) {
            uint256 balance = IERC20(getToken(i)).balanceOf(address(this));
            if (balance != 0) {
                countOfStableHasAssets++;
            }
            if (!rebalance) {
                balance = balance.sub(assets[i]);
            } else {
                assets[i] = 0;
            }
            _inAmounts[i] = balance;
        }
        if (countOfStableHasAssets == 0) return 0;
        crv3pool.add_liquidity(_inAmounts, 0);
        uint256 lpAmount = lpToken.balanceOf(address(this));
        emit LogNewStableDeposit(_inAmounts, lpAmount, rebalance);
        return lpAmount;
    }
    function skim(uint256 amount, uint256 index) internal returns (uint256 balance) {
        uint256 skimPercent = _controller().getSkimPercent();
        uint256 skimmed = amount.mul(skimPercent).div(PERCENTAGE_DECIMAL_FACTOR);
        balance = amount.sub(skimmed);
        assets[index] = assets[index].add(skimmed);
    }
    function deposit() external override returns (uint256 newAssets) {
        require(msg.sender == depositHandler, "depositStable: !depositHandler");
        uint256[N_COINS] memory _inAmounts;
        for (uint256 i = 0; i < N_COINS; i++) {
            IERC20 coin = IERC20(getToken(i));
            _inAmounts[i] = coin.balanceOf(address(this)).sub(assets[i]);
        }
        uint256 previousAssets = lpToken.balanceOf(address(this));
        crv3pool.add_liquidity(_inAmounts, 0);
        newAssets = lpToken.balanceOf(address(this)).sub(previousAssets);
    }
    function withdrawSingleByLiquidity(
        uint256 i,
        uint256 minAmount,
        address recipient
    ) external override returns (uint256, uint256) {
        require(msg.sender == withdrawHandler, "withdrawSingleByLiquidity: !withdrawHandler");
        IERC20 coin = IERC20(getToken(i));
        crv3pool.remove_liquidity_one_coin(lpToken.balanceOf(address(this)), int128(i), 0);
        uint256 balance = coin.balanceOf(address(this)).sub(assets[i]);
        require(balance > minAmount, "withdrawSingle: !minAmount");
        coin.safeTransfer(recipient, balance);
        return (buoy.singleStableToUsd(balance, i), balance);
    }
    function withdrawSingleByExchange(
        uint256 i,
        uint256 minAmount,
        address recipient
    ) external override returns (uint256 usdAmount, uint256 balance) {
        require(msg.sender == withdrawHandler, "withdrawSingleByExchange: !withdrawHandler");
        IERC20 coin = IERC20(getToken(i));
        balance = coin.balanceOf(address(this)).sub(assets[i]);
        if (minAmount <= balance) {
            uint256[N_COINS] memory inAmounts;
            inAmounts[i] = balance;
            usdAmount = buoy.stableToUsd(inAmounts, false);
        } else {
            for (uint256 j; j < N_COINS; j++) {
                if (j == i) continue;
                IERC20 inCoin = IERC20(getToken(j));
                uint256 inBalance = inCoin.balanceOf(address(this)).sub(assets[j]);
                if (inBalance > 0) {
                    _exchange(inBalance, int128(j), int128(i));
                    if (coin.balanceOf(address(this)).sub(assets[i]) >= minAmount) {
                        break;
                    }
                }
            }
            balance = coin.balanceOf(address(this)).sub(assets[i]);
            uint256[N_COINS] memory inAmounts;
            inAmounts[i] = balance;
            usdAmount = buoy.stableToUsd(inAmounts, false);
        }
        require(balance >= minAmount);
        coin.safeTransfer(recipient, balance);
    }
    function getBuoy() external view override returns (address) {
        return address(buoy);
    }
    function invest(uint256 depositAmount, uint256[N_COINS] calldata delta)
        external
        override
        returns (uint256 dollarAmount)
    {
        require(msg.sender == insurance || msg.sender == depositHandler, "depositStable: !depositHandler");
        bool needSkim = true;
        if (depositAmount == 0) {
            depositAmount = lpToken.balanceOf(address(this));
            needSkim = false;
        }
        uint256[N_COINS] memory amounts;
        _withdrawUnbalanced(depositAmount, delta);
        for (uint256 i = 0; i < N_COINS; i++) {
            amounts[i] = _investToVault(i, needSkim);
        }
        dollarAmount = buoy.stableToUsd(amounts, true);
        emit LogNewInvest(depositAmount, delta, amounts, dollarAmount, needSkim);
    }
    function investSingle(
        uint256[N_COINS] calldata inAmounts,
        uint256 i,
        uint256 j
    ) external override returns (uint256 dollarAmount) {
        require(msg.sender == depositHandler, "!investSingle: !depositHandler");
        for (uint256 k; k < N_COINS; k++) {
            if (k == i || k == j) continue;
            uint256 inBalance = inAmounts[k];
            if (inBalance > 0) {
                _exchange(inBalance, int128(k), int128(i));
            }
        }
        uint256[N_COINS] memory amounts;
        uint256 k = N_COINS - (i + j);
        if (inAmounts[i] > 0 || inAmounts[k] > 0) {
            amounts[i] = _investToVault(i, true);
        }
        if (inAmounts[j] > 0) {
            amounts[j] = _investToVault(j, true);
        }
        dollarAmount = buoy.stableToUsd(amounts, true);
    }
    function totalAssets() external view override returns (uint256) {
        return _totalAssets();
    }
    function availableLP() external view override returns (uint256) {
        uint256[N_COINS] memory _assets;
        for (uint256 i; i < N_COINS; i++) {
            IERC20 coin = IERC20(getToken(i));
            _assets[i] = coin.balanceOf(address(this)).sub(assets[i]);
        }
        return buoy.stableToLp(_assets, true);
    }
    function totalAssetsUsd() external view override returns (uint256) {
        return buoy.lpToUsd(_totalAssets());
    }
    function availableUsd() external view override returns (uint256) {
        uint256 lpAmount = lpToken.balanceOf(address(this));
        uint256 skimPercent = _controller().getSkimPercent();
        lpAmount = lpAmount.sub(lpAmount.mul(skimPercent).div(PERCENTAGE_DECIMAL_FACTOR));
        return buoy.lpToUsd(lpAmount);
    }
    function _exchange(
        uint256 amount,
        int128 _in,
        int128 out
    ) private returns (uint256) {
        crv3pool.exchange(_in, out, amount, 0);
    }
    function _withdrawUnbalanced(uint256 inAmount, uint256[N_COINS] memory delta) private {
        uint256 leftAmount = inAmount;
        for (uint256 i; i < N_COINS - 1; i++) {
            if (delta[i] > 0) {
                uint256 amount = inAmount.mul(delta[i]).div(PERCENTAGE_DECIMAL_FACTOR);
                leftAmount = leftAmount.sub(amount);
                crv3pool.remove_liquidity_one_coin(amount, int128(i), 0);
            }
        }
        if (leftAmount > 0) {
            crv3pool.remove_liquidity_one_coin(leftAmount, int128(N_COINS - 1), 0);
        }
    }
    function _totalAssets() private view returns (uint256) {
        uint256[N_COINS] memory _assets;
        for (uint256 i; i < N_COINS; i++) {
            _assets[i] = assets[i];
        }
        return buoy.stableToLp(_assets, true);
    }
    function _investToVault(uint256 i, bool needSkim) private returns (uint256 balance) {
        IVault vault;
        IERC20 coin;
        if (i < N_COINS) {
            vault = IVault(_controller().underlyingVaults(i));
            coin = IERC20(getToken(i));
        } else {
            vault = IVault(_controller().curveVault());
            coin = lpToken;
        }
        balance = coin.balanceOf(address(this)).sub(assets[i]);
        if (balance > 0) {
            if (i == N_COINS) {
                IVault(vault).deposit(balance);
                IVault(vault).invest();
            } else {
                uint256 investBalance = needSkim ? skim(balance, i) : balance;
                IVault(vault).deposit(investBalance);
            }
        }
    }
}
contract Buoy3Pool is FixedStablecoins, Controllable, IBuoy, IChainPrice {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 TIME_LIMIT = 3000;
    uint256 public BASIS_POINTS = 20;
    uint256 constant CHAIN_FACTOR = 100;
    ICurve3Pool public immutable override curvePool;
    IERC20 public immutable lpToken;
    mapping(uint256 => uint256) lastRatio;
    address public immutable daiUsdAgg;
    address public immutable usdcUsdAgg;
    address public immutable usdtUsdAgg;
    mapping(address => mapping(address => uint256)) public tokenRatios;
    event LogNewBasisPointLimit(uint256 oldLimit, uint256 newLimit);
    constructor(
        address _crv3pool,
        address poolToken,
        address[N_COINS] memory _tokens,
        uint256[N_COINS] memory _decimals,
        address[N_COINS] memory aggregators
    ) public FixedStablecoins(_tokens, _decimals) {
        curvePool = ICurve3Pool(_crv3pool);
        lpToken = IERC20(poolToken);
        daiUsdAgg = aggregators[0];
        usdcUsdAgg = aggregators[1];
        usdtUsdAgg = aggregators[2];
    }
    function setBasisPointsLmit(uint256 newLimit) external onlyOwner {
        uint256 oldLimit = BASIS_POINTS;
        BASIS_POINTS = newLimit;
        emit LogNewBasisPointLimit(oldLimit, newLimit);
    }
    function safetyCheck() external view override returns (bool) {
        for (uint256 i = 1; i < N_COINS; i++) {
            uint256 _ratio = curvePool.get_dy(int128(0), int128(i), getDecimal(0));
            _ratio = abs(int256(_ratio - lastRatio[i]));
            if (_ratio.mul(PERCENTAGE_DECIMAL_FACTOR).div(CURVE_RATIO_DECIMALS_FACTOR) > BASIS_POINTS) {
                return false;
            }
        }
        return true;
    }
    function updateRatiosWithTolerance(uint256 tolerance) external override returns (bool) {
        require(msg.sender == controller || msg.sender == owner(), "updateRatiosWithTolerance: !authorized");
        return _updateRatios(tolerance);
    }
    function updateRatios() external override returns (bool) {
        require(msg.sender == controller || msg.sender == owner(), "updateRatios: !authorized");
        return _updateRatios(BASIS_POINTS);
    }
    function stableToUsd(uint256[N_COINS] calldata inAmounts, bool deposit) external view override returns (uint256) {
        return _stableToUsd(inAmounts, deposit);
    }
    function singleStableToUsd(uint256 inAmount, uint256 i) external view override returns (uint256) {
        uint256[N_COINS] memory inAmounts;
        inAmounts[i] = inAmount;
        return _stableToUsd(inAmounts, true);
    }
    function stableToLp(uint256[N_COINS] calldata tokenAmounts, bool deposit) external view override returns (uint256) {
        return _stableToLp(tokenAmounts, deposit);
    }
    function singleStableFromUsd(uint256 inAmount, int128 i) external view override returns (uint256) {
        return _singleStableFromLp(_usdToLp(inAmount), i);
    }
    function singleStableFromLp(uint256 inAmount, int128 i) external view override returns (uint256) {
        return _singleStableFromLp(inAmount, i);
    }
    function lpToUsd(uint256 inAmount) external view override returns (uint256) {
        return _lpToUsd(inAmount);
    }
    function usdToLp(uint256 inAmount) external view override returns (uint256) {
        return _usdToLp(inAmount);
    }
    function poolBalances(uint256 inAmount, uint256 totalBalance)
        internal
        view
        returns (uint256[N_COINS] memory balances)
    {
        uint256[N_COINS] memory _balances;
        for (uint256 i = 0; i < N_COINS; i++) {
            _balances[i] = (IERC20(getToken(i)).balanceOf(address(curvePool)).mul(inAmount)).div(totalBalance);
        }
        balances = _balances;
    }
    function getVirtualPrice() external view override returns (uint256) {
        return curvePool.get_virtual_price();
    }
    function _lpToUsd(uint256 inAmount) internal view returns (uint256) {
        return inAmount.mul(curvePool.get_virtual_price()).div(DEFAULT_DECIMALS_FACTOR);
    }
    function _stableToUsd(uint256[N_COINS] memory tokenAmounts, bool deposit) internal view returns (uint256) {
        require(tokenAmounts.length == N_COINS, "deposit: !length");
        uint256[N_COINS] memory _tokenAmounts;
        for (uint256 i = 0; i < N_COINS; i++) {
            _tokenAmounts[i] = tokenAmounts[i];
        }
        uint256 lpAmount = curvePool.calc_token_amount(_tokenAmounts, deposit);
        return _lpToUsd(lpAmount);
    }
    function _stableToLp(uint256[N_COINS] memory tokenAmounts, bool deposit) internal view returns (uint256) {
        require(tokenAmounts.length == N_COINS, "deposit: !length");
        uint256[N_COINS] memory _tokenAmounts;
        for (uint256 i = 0; i < N_COINS; i++) {
            _tokenAmounts[i] = tokenAmounts[i];
        }
        return curvePool.calc_token_amount(_tokenAmounts, deposit);
    }
    function _singleStableFromLp(uint256 inAmount, int128 i) internal view returns (uint256) {
        uint256 result = curvePool.calc_withdraw_one_coin(inAmount, i);
        return result;
    }
    function _usdToLp(uint256 inAmount) internal view returns (uint256) {
        return inAmount.mul(DEFAULT_DECIMALS_FACTOR).div(curvePool.get_virtual_price());
    }
    function getPriceFeed(uint256 i) external view override returns (uint256 _price) {
        _price = uint256(IChainlinkAggregator(getAggregator(i)).latestAnswer());
    }
    function getTokenRatios(uint256 i) private view returns (uint256[3] memory _ratios) {
        uint256[3] memory _prices;
        _prices[0] = uint256(IChainlinkAggregator(getAggregator(0)).latestAnswer());
        _prices[1] = uint256(IChainlinkAggregator(getAggregator(1)).latestAnswer());
        _prices[2] = uint256(IChainlinkAggregator(getAggregator(2)).latestAnswer());
        for (uint256 j = 0; j < 3; j++) {
            if (i == j) {
                _ratios[i] = CHAINLINK_PRICE_DECIMAL_FACTOR;
            } else {
                _ratios[j] = _prices[i].mul(CHAINLINK_PRICE_DECIMAL_FACTOR).div(_prices[j]);
            }
        }
        return _ratios;
    }
    function getAggregator(uint256 index) private view returns (address) {
        if (index == 0) {
            return daiUsdAgg;
        } else if (index == 1) {
            return usdcUsdAgg;
        } else {
            return usdtUsdAgg;
        }
    }
    function abs(int256 x) private pure returns (uint256) {
        return x >= 0 ? uint256(x) : uint256(-x);
    }
    function _updateRatios(uint256 tolerance) private returns (bool) {
        uint256[N_COINS] memory chainRatios = getTokenRatios(0);
        uint256[N_COINS] memory newRatios;
        for (uint256 i = 1; i < N_COINS; i++) {
            uint256 _ratio = curvePool.get_dy(int128(0), int128(i), getDecimal(0));
            uint256 check = abs(int256(_ratio) - int256(chainRatios[i].div(CHAIN_FACTOR)));
            if (check.mul(PERCENTAGE_DECIMAL_FACTOR).div(CURVE_RATIO_DECIMALS_FACTOR) > tolerance) {
                return false;
            } else {
                newRatios[i] = _ratio;
            }
        }
        for (uint256 i = 1; i < N_COINS; i++) {
            lastRatio[i] = newRatios[i];
        }
        return true;
    }
}
abstract contract GERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    constructor(
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
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
    function totalSupplyBase() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOfBase(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount, amount);
        return true;
    }
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance")
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero")
        );
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 transferAmount,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, transferAmount);
        _balances[sender] = _balances[sender].sub(transferAmount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(transferAmount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(
        address account,
        uint256 mintAmount,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, mintAmount);
        _totalSupply = _totalSupply.add(mintAmount);
        _balances[account] = _balances[account].add(mintAmount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(
        address account,
        uint256 burnAmount,
        uint256 amount
    ) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), burnAmount);
        _balances[account] = _balances[account].sub(burnAmount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(burnAmount);
        emit Transfer(account, address(0), amount);
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
    function _decreaseApproved(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = _allowances[owner][spender].sub(amount);
        emit Approval(owner, spender, _allowances[owner][spender]);
    }
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
abstract contract GToken is GERC20, Constants, Whitelist, IToken {
    uint256 public constant BASE = DEFAULT_DECIMALS_FACTOR;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IController public ctrl;
    constructor(string memory name, string memory symbol) public GERC20(name, symbol, DEFAULT_DECIMALS) {}
    function setController(address controller) external onlyOwner {
        ctrl = IController(controller);
    }
    function factor() public view override returns (uint256) {
        return factor(totalAssets());
    }
    function applyFactor(
        uint256 a,
        uint256 b,
        bool base
    ) internal pure returns (uint256 resultant) {
        uint256 _BASE = BASE;
        uint256 diff;
        if (base) {
            diff = a.mul(b) % _BASE;
            resultant = a.mul(b).div(_BASE);
        } else {
            diff = a.mul(_BASE) % b;
            resultant = a.mul(_BASE).div(b);
        }
        if (diff >= 5E17) {
            resultant = resultant.add(1);
        }
    }
    function factor(uint256 totalAssets) public view override returns (uint256) {
        if (totalSupplyBase() == 0) {
            return getInitialBase();
        }
        if (totalAssets > 0) {
            return totalSupplyBase().mul(BASE).div(totalAssets);
        }
        return 0;
    }
    function totalAssets() public view override returns (uint256) {
        return ctrl.gTokenTotalAssets();
    }
    function getInitialBase() internal pure virtual returns (uint256) {
        return BASE;
    }
}
contract NonRebasingGToken is GToken {
    uint256 public constant INIT_BASE = 3333333333333333;
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    event LogTransfer(address indexed sender, address indexed recipient, uint256 indexed amount, uint256 factor);
    constructor(string memory name, string memory symbol) public GToken(name, symbol) {}
    function totalSupply() public view override returns (uint256) {
        return totalSupplyBase();
    }
    function balanceOf(address account) public view override returns (uint256) {
        return balanceOfBase(account);
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        super._transfer(msg.sender, recipient, amount, amount);
        emit LogTransfer(msg.sender, recipient, amount, factor());
        return true;
    }
    function getPricePerShare() public view override returns (uint256) {
        uint256 f = factor();
        return f > 0 ? applyFactor(BASE, f, false) : 0;
    }
    function getShareAssets(uint256 shares) public view override returns (uint256) {
        return applyFactor(shares, getPricePerShare(), true);
    }
    function getAssets(address account) external view override returns (uint256) {
        return getShareAssets(balanceOf(account));
    }
    function getInitialBase() internal pure override returns (uint256) {
        return INIT_BASE;
    }
    function mint(
        address account,
        uint256 _factor,
        uint256 amount
    ) external override onlyWhitelist {
        require(account != address(0), "mint: 0x");
        require(amount > 0, "Amount is zero.");
        amount = applyFactor(amount, _factor, true);
        _mint(account, amount, amount);
    }
    function burn(
        address account,
        uint256 _factor,
        uint256 amount
    ) external override onlyWhitelist {
        require(account != address(0), "burn: 0x");
        require(amount > 0, "Amount is zero.");
        amount = applyFactor(amount, _factor, true);
        _burn(account, amount, amount);
    }
    function burnAll(address account) external override onlyWhitelist {
        require(account != address(0), "burnAll: 0x");
        uint256 amount = balanceOfBase(account);
        _burn(account, amount, amount);
    }
}
contract RebasingGToken is GToken {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    event LogTransfer(address indexed sender, address indexed recipient, uint256 indexed amount);
    constructor(string memory name, string memory symbol) public GToken(name, symbol) {}
    function totalSupply() public view override returns (uint256) {
        uint256 f = factor();
        return f > 0 ? applyFactor(totalSupplyBase(), f, false) : 0;
    }
    function balanceOf(address account) public view override returns (uint256) {
        uint256 f = factor();
        return f > 0 ? applyFactor(balanceOfBase(account), f, false) : 0;
    }
    function transfer(address recipient, uint256 amount) public override returns (bool) {
        uint256 transferAmount = applyFactor(amount, factor(), true);
        super._transfer(msg.sender, recipient, transferAmount, amount);
        emit LogTransfer(msg.sender, recipient, amount);
        return true;
    }
    function getPricePerShare() external view override returns (uint256) {
        return BASE;
    }
    function getShareAssets(uint256 shares) external view override returns (uint256) {
        return shares;
    }
    function getAssets(address account) external view override returns (uint256) {
        return balanceOf(account);
    }
    function mint(
        address account,
        uint256 _factor,
        uint256 amount
    ) external override onlyWhitelist {
        require(account != address(0), "mint: 0x");
        require(amount > 0, "Amount is zero.");
        uint256 mintAmount = applyFactor(amount, _factor, true);
        _mint(account, mintAmount, amount);
    }
    function burn(
        address account,
        uint256 _factor,
        uint256 amount
    ) external override onlyWhitelist {
        require(account != address(0), "burn: 0x");
        require(amount > 0, "Amount is zero.");
        uint256 burnAmount = applyFactor(amount, _factor, true);
        _burn(account, burnAmount, amount);
    }
    function burnAll(address account) external override onlyWhitelist {
        require(account != address(0), "burnAll: 0x");
        uint256 burnAmount = balanceOfBase(account);
        uint256 amount = applyFactor(burnAmount, factor(), false);
        _burn(account, burnAmount, amount);
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        super._decreaseApproved(sender, msg.sender, amount);
        uint256 transferAmount = applyFactor(amount, factor(), true);
        super._transfer(sender, recipient, transferAmount, amount);
        return true;
    }
}
abstract contract BaseVaultAdaptor is Controllable, Constants, Whitelist, IVault {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 constant MAX_STRATS = 20;
    address public immutable override token;
    uint256 public immutable decimals;
    address public immutable override vault;
    uint256 public strategiesLength;
    uint256 public investThreshold;
    uint256 public strategyRatioBuffer;
    uint256 public vaultReserve;
    event LogAdaptorToken(address token);
    event LogAdaptorVault(address vault);
    event LogAdaptorReserve(uint256 reserve);
    event LogAdaptorStrategies(uint256 length);
    event LogNewAdaptorInvestThreshold(uint256 threshold);
    event LogNewAdaptorStrategyBuffer(uint256 buffer);
    event LogNewDebtRatios(uint256[] strategyRetios);
    event LogMigrate(address parent, address child, uint256 amount);
    modifier onlyVault() {
        require(msg.sender == vault);
        _;
    }
    constructor(address _vault, address _token) public {
        vault = _vault;
        token = _token;
        decimals = IERC20Detailed(_token).decimals();
        IERC20(_token).safeApprove(address(_vault), 0);
        IERC20(_token).safeApprove(address(_vault), type(uint256).max);
    }
    function setVaultReserve(uint256 reserve) external onlyOwner {
        require(reserve <= PERCENTAGE_DECIMAL_FACTOR);
        vaultReserve = reserve;
        emit LogAdaptorReserve(reserve);
    }
    function setStrategiesLength(uint256 _strategiesLength) external onlyOwner {
        strategiesLength = _strategiesLength;
        emit LogAdaptorStrategies(_strategiesLength);
    }
    function setInvestThreshold(uint256 _investThreshold) external onlyOwner {
        investThreshold = _investThreshold;
        emit LogNewAdaptorInvestThreshold(_investThreshold);
    }
    function setStrategyRatioBuffer(uint256 _strategyRatioBuffer) external onlyOwner {
        strategyRatioBuffer = _strategyRatioBuffer;
        emit LogNewAdaptorStrategyBuffer(_strategyRatioBuffer);
    }
    function investTrigger() external view override returns (bool) {
        uint256 vaultHold = _totalAssets().mul(vaultReserve).div(PERCENTAGE_DECIMAL_FACTOR);
        uint256 _investThreshold = investThreshold.mul(uint256(10)**decimals);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance < _investThreshold) {
            return false;
        } else if (balance.sub(_investThreshold) > vaultHold) {
            return true;
        } else {
            return false;
        }
    }
    function invest() external override onlyWhitelist {
        uint256 vaultHold = _totalAssets().mul(vaultReserve).div(PERCENTAGE_DECIMAL_FACTOR);
        uint256 _investThreshold = investThreshold.mul(uint256(10)**decimals);
        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance <= vaultHold) return;
        if (balance.sub(vaultHold) > _investThreshold) {
            depositToUnderlyingVault(balance.sub(vaultHold));
        }
        if (strategiesLength > 1) {
            uint256[] memory targetRatios = _controller().getStrategiesTargetRatio();
            uint256[] memory currentRatios = getStrategiesDebtRatio();
            bool update;
            for (uint256 i; i < strategiesLength; i++) {
                if (currentRatios[i] < targetRatios[i] && targetRatios[i].sub(currentRatios[i]) > strategyRatioBuffer) {
                    update = true;
                    break;
                }
                if (currentRatios[i] > targetRatios[i] && currentRatios[i].sub(targetRatios[i]) > strategyRatioBuffer) {
                    update = true;
                    break;
                }
            }
            if (update) {
                updateStrategiesDebtRatio(targetRatios);
            }
        }
    }
    function totalAssets() external view override returns (uint256) {
        return _totalAssets();
    }
    function getStrategiesLength() external view override returns (uint256) {
        return strategiesLength;
    }
    function withdraw(uint256 amount) external override {
        require(msg.sender == _controller().lifeGuard(), "withdraw: !lifeguard");
        if (!_withdrawFromAdapter(amount, msg.sender)) {
            amount = _withdraw(calculateShare(amount), msg.sender);
        }
    }
    function withdraw(uint256 amount, address recipient) external override {
        require(msg.sender == _controller().insurance(), "withdraw: !insurance");
        if (!_withdrawFromAdapter(amount, recipient)) {
            amount = _withdraw(calculateShare(amount), recipient);
        }
    }
    function withdrawToAdapter(uint256 amount) external onlyOwner {
        amount = _withdraw(calculateShare(amount), address(this));
    }
    function withdrawByStrategyOrder(
        uint256 amount,
        address recipient,
        bool reversed
    ) external override {
        IController ctrl = _controller();
        require(
            msg.sender == ctrl.withdrawHandler() ||
                msg.sender == ctrl.insurance() ||
                msg.sender == ctrl.emergencyHandler(),
            "withdraw: !withdrawHandler/insurance"
        );
        if (!_withdrawFromAdapter(amount, recipient)) {
            amount = _withdrawByStrategyOrder(calculateShare(amount), recipient, reversed);
        }
    }
    function withdrawByStrategyIndex(
        uint256 amount,
        address recipient,
        uint256 strategyIndex
    ) external override {
        require(msg.sender == _controller().insurance(), "withdraw: !withdrawHandler/insurance");
        if (!_withdrawFromAdapter(amount, recipient)) {
            amount = _withdrawByStrategyIndex(calculateShare(amount), recipient, strategyIndex);
        }
    }
    function _withdrawFromAdapter(uint256 amount, address recipient) private returns (bool _success) {
        uint256 adapterAmount = IERC20(token).balanceOf(address(this));
        if (adapterAmount >= amount) {
            IERC20(token).safeTransfer(recipient, amount);
            return true;
        } else {
            return false;
        }
    }
    function getStrategyAssets(uint256 index) external view override returns (uint256 amount) {
        return getStrategyTotalAssets(index);
    }
    function deposit(uint256 amount) external override {
        require(msg.sender == _controller().lifeGuard(), "withdraw: !lifeguard");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
    }
    function updateStrategyRatio(uint256[] calldata strategyRatios) external override {
        require(
            msg.sender == _controller().insurance() || msg.sender == owner(),
            "!updateStrategyRatio: !owner/insurance"
        );
        updateStrategiesDebtRatio(strategyRatios);
        emit LogNewDebtRatios(strategyRatios);
    }
    function strategyHarvestTrigger(uint256 index, uint256 callCost) external view override returns (bool harvested) {
        require(index < strategiesLength, "invalid index");
        return _strategyHarvestTrigger(index, callCost);
    }
    function strategyHarvest(uint256 index) external override onlyWhitelist returns (bool harvested) {
        require(index < strategiesLength, "invalid index");
        uint256 beforeAssets = vaultTotalAssets();
        _strategyHarvest(index);
        uint256 afterAssets = vaultTotalAssets();
        if (afterAssets > beforeAssets) {
            _controller().distributeStrategyGainLoss(afterAssets.sub(beforeAssets), 0);
        } else if (afterAssets < beforeAssets) {
            _controller().distributeStrategyGainLoss(0, beforeAssets.sub(afterAssets));
        }
        harvested = true;
    }
    function migrate(address child) external onlyOwner {
        require(child != address(0), "migrate: child == 0x");
        IERC20 _token = IERC20(token);
        uint256 balance = _token.balanceOf(address(this));
        _token.safeTransfer(child, balance);
        emit LogMigrate(address(this), child, balance);
    }
    function _strategyHarvest(uint256 index) internal virtual;
    function updateStrategiesDebtRatio(uint256[] memory ratios) internal virtual;
    function getStrategiesDebtRatio() internal view virtual returns (uint256[] memory);
    function depositToUnderlyingVault(uint256 amount) internal virtual;
    function _withdraw(uint256 share, address recipient) internal virtual returns (uint256);
    function _withdrawByStrategyOrder(
        uint256 share,
        address recipient,
        bool reversed
    ) internal virtual returns (uint256);
    function _withdrawByStrategyIndex(
        uint256 share,
        address recipient,
        uint256 index
    ) internal virtual returns (uint256);
    function _strategyHarvestTrigger(uint256 index, uint256 callCost) internal view virtual returns (bool);
    function getStrategyEstimatedTotalAssets(uint256 index) internal view virtual returns (uint256);
    function getStrategyTotalAssets(uint256 index) internal view virtual returns (uint256);
    function vaultTotalAssets() internal view virtual returns (uint256);
    function _totalAssets() internal view returns (uint256) {
        uint256 total = IERC20(token).balanceOf(address(this)).add(vaultTotalAssets());
        return total;
    }
    function calculateShare(uint256 amount) private view returns (uint256 share) {
        uint256 sharePrice = _getVaultSharePrice();
        share = amount.mul(uint256(10)**decimals).div(sharePrice);
        uint256 balance = IERC20(vault).balanceOf(address(this));
        share = share < balance ? share : balance;
    }
    function totalEstimatedAssets() external view returns (uint256) {
        uint256 total = IERC20(token).balanceOf(address(this)).add(IERC20(token).balanceOf(address(vault)));
        for (uint256 i = 0; i < strategiesLength; i++) {
            total = total.add(getStrategyEstimatedTotalAssets(i));
        }
        return total;
    }
    function _getVaultSharePrice() internal view virtual returns (uint256);
}
contract VaultAdaptorYearnV2_032 is BaseVaultAdaptor {
    constructor(address _vault, address _token) public BaseVaultAdaptor(_vault, _token) {}
    function _withdrawByStrategyOrder(
        uint256 share,
        address recipient,
        bool pwrd
    ) internal override returns (uint256) {
        if (pwrd) {
            address[MAX_STRATS] memory _strategies;
            for (uint256 i = strategiesLength; i > 0; i--) {
                _strategies[i - 1] = IYearnV2Vault(vault).withdrawalQueue((strategiesLength - i));
            }
            return IYearnV2Vault(vault).withdrawByStrategy(_strategies, share, recipient, 1);
        } else {
            return _withdraw(share, recipient);
        }
    }
    function _withdrawByStrategyIndex(
        uint256 share,
        address recipient,
        uint256 index
    ) internal override returns (uint256) {
        if (index != 0) {
            address[MAX_STRATS] memory _strategies;
            uint256 strategyIndex = 0;
            _strategies[strategyIndex] = IYearnV2Vault(vault).withdrawalQueue(index);
            for (uint256 i = 0; i < strategiesLength; i++) {
                if (i == index) {
                    continue;
                }
                strategyIndex++;
                _strategies[strategyIndex] = IYearnV2Vault(vault).withdrawalQueue(i);
            }
            return IYearnV2Vault(vault).withdrawByStrategy(_strategies, share, recipient, 0);
        } else {
            return _withdraw(share, recipient);
        }
    }
    function depositToUnderlyingVault(uint256 _amount) internal override {
        if (_amount > 0) {
            IYearnV2Vault(vault).deposit(_amount, address(this));
        }
    }
    function _strategyHarvest(uint256 index) internal override {
        IYearnV2Vault yearnVault = IYearnV2Vault(vault);
        IYearnV2Strategy(yearnVault.withdrawalQueue(index)).harvest();
    }
    function resetStrategyDeltaRatio() private {
        IYearnV2Vault yearnVault = IYearnV2Vault(vault);
        for (uint256 i = 0; i < strategiesLength; i++) {
            yearnVault.updateStrategyDebtRatio(yearnVault.withdrawalQueue(i), 0);
        }
    }
    function updateStrategiesDebtRatio(uint256[] memory ratios) internal override {
        uint256 ratioTotal = 0;
        for (uint256 i = 0; i < ratios.length; i++) {
            ratioTotal = ratioTotal.add(ratios[i]);
        }
        require(ratioTotal <= 10**4, "The total of ratios is more than 10000");
        resetStrategyDeltaRatio();
        IYearnV2Vault yearnVault = IYearnV2Vault(vault);
        for (uint256 i = 0; i < ratios.length; i++) {
            yearnVault.updateStrategyDebtRatio(yearnVault.withdrawalQueue(i), ratios[i]);
        }
    }
    function getStrategiesDebtRatio() internal view override returns (uint256[] memory ratios) {
        ratios = new uint256[](strategiesLength);
        IYearnV2Vault yearnVault = IYearnV2Vault(vault);
        StrategyParams memory strategyParam;
        for (uint256 i; i < strategiesLength; i++) {
            strategyParam = yearnVault.strategies(yearnVault.withdrawalQueue(i));
            ratios[i] = strategyParam.debtRatio;
        }
    }
    function _strategyHarvestTrigger(uint256 index, uint256 callCost) internal view override returns (bool) {
        IYearnV2Vault yearnVault = IYearnV2Vault(vault);
        return IYearnV2Strategy(yearnVault.withdrawalQueue(index)).harvestTrigger(callCost);
    }
    function getStrategyEstimatedTotalAssets(uint256 index) internal view override returns (uint256) {
        IYearnV2Vault yearnVault = IYearnV2Vault(vault);
        return IYearnV2Strategy(yearnVault.withdrawalQueue(index)).estimatedTotalAssets();
    }
    function getStrategyTotalAssets(uint256 index) internal view override returns (uint256) {
        IYearnV2Vault yearnVault = IYearnV2Vault(vault);
        StrategyParams memory strategyParam = yearnVault.strategies(yearnVault.withdrawalQueue(index));
        return strategyParam.totalDebt;
    }
    function _withdraw(uint256 share, address recipient) internal override returns (uint256 withdrawalAmount) {
        (, , withdrawalAmount, ) = IYearnV2Vault(vault).withdraw(share, recipient, 1);
    }
    function vaultTotalAssets() internal view override returns (uint256) {
        return IYearnV2Vault(vault).totalAssets();
    }
    function _getVaultSharePrice() internal view override returns (uint256) {
        return IYearnV2Vault(vault).pricePerShare();
    }
}
interface IEmergencyHandler {
    function emergencyWithdrawal(
        address user,
        bool pwrd,
        uint256 inAmount,
        uint256 minAmounts
    ) external;
    function emergencyWithdrawAll(
        address user,
        bool pwrd,
        uint256 minAmounts
    ) external;
}
contract WithdrawHandler is Controllable, FixedStablecoins, FixedVaults, IWithdrawHandler {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IController public ctrl;
    ILifeGuard public lg;
    IBuoy public buoy;
    IInsurance public insurance;
    IEmergencyHandler public emergencyHandler;
    event LogNewDependencies(
        address controller,
        address lifeguard,
        address buoy,
        address insurance,
        address emergencyHandler
    );
    event LogNewWithdrawal(
        address indexed user,
        address indexed referral,
        bool pwrd,
        bool balanced,
        bool all,
        uint256 deductUsd,
        uint256 returnUsd,
        uint256 lpAmount,
        uint256[N_COINS] tokenAmounts
    );
    struct WithdrawParameter {
        address account;
        bool pwrd;
        bool balanced;
        bool all;
        uint256 index;
        uint256[N_COINS] minAmounts;
        uint256 lpAmount;
    }
    constructor(
        address[N_COINS] memory _vaults,
        address[N_COINS] memory _tokens,
        uint256[N_COINS] memory _decimals
    ) public FixedStablecoins(_tokens, _decimals) FixedVaults(_vaults) {}
    function setDependencies() external onlyOwner {
        ctrl = _controller();
        lg = ILifeGuard(ctrl.lifeGuard());
        buoy = IBuoy(lg.getBuoy());
        insurance = IInsurance(ctrl.insurance());
        emergencyHandler = IEmergencyHandler(ctrl.emergencyHandler());
        emit LogNewDependencies(
            address(ctrl),
            address(lg),
            address(buoy),
            address(insurance),
            address(emergencyHandler)
        );
    }
    function withdrawByLPToken(
        bool pwrd,
        uint256 lpAmount,
        uint256[N_COINS] calldata minAmounts
    ) external override {
        require(!ctrl.emergencyState(), "withdrawByLPToken: emergencyState");
        require(lpAmount > 0, "!minAmount");
        WithdrawParameter memory parameters = WithdrawParameter(
            msg.sender,
            pwrd,
            true,
            false,
            N_COINS,
            minAmounts,
            lpAmount
        );
        _withdraw(parameters);
    }
    function withdrawByStablecoin(
        bool pwrd,
        uint256 index,
        uint256 lpAmount,
        uint256 minAmount
    ) external override {
        if (ctrl.emergencyState()) {
            emergencyHandler.emergencyWithdrawal(msg.sender, pwrd, lpAmount, minAmount);
        } else {
            require(index < N_COINS, "!withdrawByStablecoin: invalid index");
            require(lpAmount > 0, "!minAmount");
            uint256[N_COINS] memory minAmounts;
            minAmounts[index] = minAmount;
            WithdrawParameter memory parameters = WithdrawParameter(
                msg.sender,
                pwrd,
                false,
                false,
                index,
                minAmounts,
                lpAmount
            );
            _withdraw(parameters);
        }
    }
    function withdrawAllSingle(
        bool pwrd,
        uint256 index,
        uint256 minAmount
    ) external override {
        if (ctrl.emergencyState()) {
            emergencyHandler.emergencyWithdrawAll(msg.sender, pwrd, minAmount);
        } else {
            _withdrawAllSingleFromAccount(msg.sender, pwrd, index, minAmount);
        }
    }
    function withdrawAllBalanced(bool pwrd, uint256[N_COINS] calldata minAmounts) external override {
        require(!ctrl.emergencyState(), "withdrawByLPToken: emergencyState");
        WithdrawParameter memory parameters = WithdrawParameter(msg.sender, pwrd, true, true, N_COINS, minAmounts, 0);
        _withdraw(parameters);
    }
    function getVaultDeltas(uint256 amount) external view returns (uint256[N_COINS] memory tokenAmounts) {
        uint256[N_COINS] memory delta = insurance.getDelta(buoy.lpToUsd(amount));
        for (uint256 i; i < N_COINS; i++) {
            uint256 withdraw = amount.mul(delta[i]).div(PERCENTAGE_DECIMAL_FACTOR);
            if (withdraw > 0) tokenAmounts[i] = buoy.singleStableFromLp(withdraw, int128(i));
        }
    }
    function withdrawalFee(bool pwrd) public view returns (uint256) {
        return _controller().withdrawalFee(pwrd);
    }
    function _withdrawAllSingleFromAccount(
        address account,
        bool pwrd,
        uint256 index,
        uint256 minAmount
    ) private {
        require(index < N_COINS, "!withdrawAllSingleFromAccount: invalid index");
        uint256[N_COINS] memory minAmounts;
        minAmounts[index] = minAmount;
        WithdrawParameter memory parameters = WithdrawParameter(account, pwrd, false, true, index, minAmounts, 0);
        _withdraw(parameters);
    }
    function _withdraw(WithdrawParameter memory parameters) private {
        ctrl.eoaOnly(msg.sender);
        require(buoy.safetyCheck(), "!safetyCheck");
        uint256 deductUsd;
        uint256 returnUsd;
        uint256 lpAmountFee;
        uint256[N_COINS] memory tokenAmounts;
        uint256 virtualPrice = buoy.getVirtualPrice();
        if (parameters.all) {
            deductUsd = ctrl.getUserAssets(parameters.pwrd, parameters.account);
            returnUsd = deductUsd.sub(deductUsd.mul(withdrawalFee(parameters.pwrd)).div(PERCENTAGE_DECIMAL_FACTOR));
            lpAmountFee = returnUsd.mul(DEFAULT_DECIMALS_FACTOR).div(virtualPrice);
        } else {
            uint256 userAssets = ctrl.getUserAssets(parameters.pwrd, parameters.account);
            uint256 lpAmount = parameters.lpAmount;
            uint256 fee = lpAmount.mul(withdrawalFee(parameters.pwrd)).div(PERCENTAGE_DECIMAL_FACTOR);
            lpAmountFee = lpAmount.sub(fee);
            returnUsd = lpAmountFee.mul(virtualPrice).div(DEFAULT_DECIMALS_FACTOR);
            deductUsd = lpAmount.mul(virtualPrice).div(DEFAULT_DECIMALS_FACTOR);
            require(deductUsd <= userAssets, "!withdraw: not enough balance");
        }
        uint256 hodlerBonus = deductUsd.sub(returnUsd);
        bool whale = ctrl.isValidBigFish(parameters.pwrd, false, returnUsd);
        if (parameters.balanced) {
            (returnUsd, tokenAmounts) = _withdrawBalanced(
                parameters.account,
                parameters.pwrd,
                lpAmountFee,
                parameters.minAmounts,
                returnUsd
            );
        } else {
            (returnUsd, tokenAmounts[parameters.index]) = _withdrawSingle(
                parameters.account,
                parameters.pwrd,
                lpAmountFee,
                parameters.minAmounts[parameters.index],
                parameters.index,
                returnUsd,
                whale
            );
        }
        ctrl.burnGToken(parameters.pwrd, parameters.all, parameters.account, deductUsd, hodlerBonus);
        emit LogNewWithdrawal(
            parameters.account,
            ctrl.referrals(parameters.account),
            parameters.pwrd,
            parameters.balanced,
            parameters.all,
            deductUsd,
            returnUsd,
            lpAmountFee,
            tokenAmounts
        );
    }
    function _withdrawSingle(
        address account,
        bool pwrd,
        uint256 lpAmount,
        uint256 minAmount,
        uint256 index,
        uint256 withdrawUsd,
        bool whale
    ) private returns (uint256 dollarAmount, uint256 tokenAmount) {
        dollarAmount = withdrawUsd;
        if (whale) {
            (dollarAmount, tokenAmount) = _prepareForWithdrawalSingle(account, pwrd, index, minAmount, withdrawUsd);
        } else {
            IVault adapter = IVault(getVault(index));
            tokenAmount = buoy.singleStableFromLp(lpAmount, int128(index));
            adapter.withdrawByStrategyOrder(tokenAmount, account, pwrd);
        }
        require(tokenAmount >= minAmount, "!withdrawSingle: !minAmount");
    }
    function _withdrawBalanced(
        address account,
        bool pwrd,
        uint256 lpAmount,
        uint256[N_COINS] memory minAmounts,
        uint256 withdrawUsd
    ) private returns (uint256 dollarAmount, uint256[N_COINS] memory tokenAmounts) {
        uint256 coins = N_COINS;
        uint256[N_COINS] memory delta = insurance.getDelta(withdrawUsd);
        address[N_COINS] memory _vaults = vaults();
        for (uint256 i; i < coins; i++) {
            uint256 withdraw = lpAmount.mul(delta[i]).div(PERCENTAGE_DECIMAL_FACTOR);
            if (withdraw > 0) {
                tokenAmounts[i] = buoy.singleStableFromLp(withdraw, int128(i));
                require(tokenAmounts[i] >= minAmounts[i], "!withdrawBalanced: !minAmount");
                IVault adapter = IVault(_vaults[i]);
                require(tokenAmounts[i] <= adapter.totalAssets(), "_withdrawBalanced: !adapterBalance");
                adapter.withdrawByStrategyOrder(tokenAmounts[i], account, pwrd);
            }
        }
        dollarAmount = buoy.stableToUsd(tokenAmounts, false);
    }
    function _prepareForWithdrawalSingle(
        address account,
        bool pwrd,
        uint256 index,
        uint256 minAmount,
        uint256 withdrawUsd
    ) private returns (uint256 dollarAmount, uint256 amount) {
        bool curve = insurance.rebalanceForWithdraw(withdrawUsd, pwrd);
        if (curve) {
            lg.depositStable(false);
            (dollarAmount, amount) = lg.withdrawSingleByLiquidity(index, minAmount, account);
        } else {
            (dollarAmount, amount) = lg.withdrawSingleByExchange(index, minAmount, account);
        }
        require(minAmount <= amount, "!prepareForWithdrawalSingle: !minAmount");
    }
}
interface IHarvest {
    function deposit(uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function getPricePerFullShare() external view returns (uint256);
    function transfer(address recipient, uint256 amount) external;
    function withdraw(uint256 numberOfShares) external;
    function withdrawAll() external;
    function approve(address spender, uint256 amount) external;
    function underlying() external view returns (address);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint256);
}
interface IStake {
    function balanceOf(address account) external view returns (uint256);
    function earned(address account) external view returns (uint256);
    function lpToken() external view returns (address);
    function stake(uint256 amount) external;
    function getReward() external;
    function withdraw(uint256 amount) external;
    function exit() external;
}
struct Struct1 {
    uint256[] aUIA;
    Struct2 bS2;
}
struct Struct2 {
    uint256 aUI;
    uint256[] bUIA;
    bool cB;
    address dA;
}
contract MockStruct4Test {
    address public owner;
    function setOwner(address _owner) external {
        owner = _owner;
    }
    function test1(Struct1 calldata s) external view returns (Struct1 memory result) {
        Struct1 memory s1;
        s1.aUIA = s.aUIA;
        s1.bS2.aUI = s.bS2.aUI;
        s1.bS2.bUIA = s.bS2.bUIA;
        s1.bS2.cB = s.bS2.cB;
        s1.bS2.dA = s.bS2.dA;
        return method1(s1);
    }
    function test2(Struct1 memory s) public view returns (Struct1 memory result) {
        return method1(s);
    }
    function method1(Struct1 memory s) private view returns (Struct1 memory r) {
        r.aUIA = new uint256[](s.aUIA.length);
        for (uint256 i = 0; i < s.aUIA.length; i++) {
            r.aUIA[i] = s.aUIA[i] + 1;
        }
        r.bS2.aUI = s.bS2.aUI * 2;
        r.bS2.bUIA = new uint256[](s.bS2.bUIA.length);
        for (uint256 i = 0; i < s.bS2.bUIA.length; i++) {
            r.bS2.bUIA[i] = s.bS2.bUIA[i] + 1;
        }
        r.bS2.cB = !s.bS2.cB;
        r.bS2.dA = owner;
    }
}