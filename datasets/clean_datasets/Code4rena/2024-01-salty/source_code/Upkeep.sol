pragma solidity 0.8.22;
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface IDAOConfig
	{
	function changeBootstrappingRewards(bool increase) external; 
	function changePercentPolRewardsBurned(bool increase) external; 
	function changeBaseBallotQuorumPercent(bool increase) external; 
	function changeBallotDuration(bool increase) external; 
	function changeRequiredProposalPercentStake(bool increase) external; 
	function changeMaxPendingTokensForWhitelisting(bool increase) external; 
	function changeArbitrageProfitsPercentPOL(bool increase) external; 
	function changeUpkeepRewardPercent(bool increase) external; 
    function bootstrappingRewards() external view returns (uint256);
    function percentPolRewardsBurned() external view returns (uint256);
    function baseBallotQuorumPercentTimes1000() external view returns (uint256);
    function ballotMinimumDuration() external view returns (uint256);
    function requiredProposalPercentStakeTimes1000() external view returns (uint256);
    function maxPendingTokensForWhitelisting() external view returns (uint256);
    function arbitrageProfitsPercentPOL() external view returns (uint256);
    function upkeepRewardPercent() external view returns (uint256);
	}
interface IAccessManager
	{
	function excludedCountriesUpdated() external;
	function grantAccess(bytes calldata signature) external;
	function geoVersion() external view returns (uint256);
	function walletHasAccess(address wallet) external view returns (bool);
	}
interface IManagedWallet
	{
	function proposeWallets( address _proposedMainWallet, address _proposedConfirmationWallet ) external;
	function changeWallets() external;
	function mainWallet() external view returns (address wallet);
	function confirmationWallet() external view returns (address wallet);
	function proposedMainWallet() external view returns (address wallet);
	function proposedConfirmationWallet() external view returns (address wallet);
    function activeTimelock() external view returns (uint256);
	}
interface IUpkeep
	{
	function performUpkeep() external;
	function currentRewardsForCallingPerformUpkeep() external view returns (uint256);
	function lastUpkeepTimeEmissions() external view returns (uint256);
	function lastUpkeepTimeRewardsEmitters() external view returns (uint256);
	}
interface IAirdrop
	{
	function authorizeWallet( address wallet ) external;
	function allowClaiming() external;
	function claimAirdrop() external;
	function saltAmountForEachUser() external view returns (uint256);
	function claimingAllowed() external view returns (bool);
	function claimed(address wallet) external view returns (bool);
	function isAuthorized(address wallet) external view returns (bool);
	function numberAuthorized() external view returns (uint256);
	}
interface IBootstrapBallot
	{
	function vote( bool voteStartExchangeYes, bytes memory signature  ) external;
	function finalizeBallot() external;
	function completionTimestamp() external view returns (uint256);
	function hasVoted(address user) external view returns (bool);
	function ballotFinalized() external view returns (bool);
	function startExchangeYes() external view returns (uint256);
	function startExchangeNo() external view returns (uint256);
	}
interface IPoolStats
	{
	struct ArbitrageIndicies
		{
		uint64 index1;
		uint64 index2;
		uint64 index3;
		}
	function clearProfitsForPools() external;
	function updateArbitrageIndicies() external;
	function profitsForWhitelistedPools() external view returns (uint256[] memory _calculatedProfits);
	function arbitrageIndicies(bytes32 poolID) external view returns (ArbitrageIndicies memory);
	}
interface IPriceFeed
	{
	function getPriceBTC() external view returns (uint256);
	function getPriceETH() external view returns (uint256);
	}
interface IEmissions
	{
	function performUpkeep( uint256 timeSinceLastUpkeep ) external;
    }
interface IStableConfig
	{
	function changeRewardPercentForCallingLiquidation(bool increase) external; 
	function changeMaxRewardValueForCallingLiquidation(bool increase) external; 
	function changeMinimumCollateralValueForBorrowing(bool increase) external; 
	function changeInitialCollateralRatioPercent(bool increase) external; 
	function changeMinimumCollateralRatioPercent(bool increase) external; 
	function changePercentArbitrageProfitsForStablePOL(bool increase) external; 
    function rewardPercentForCallingLiquidation() external view returns (uint256);
    function maxRewardValueForCallingLiquidation() external view returns (uint256);
    function minimumCollateralValueForBorrowing() external view returns (uint256);
	function initialCollateralRatioPercent() external view returns (uint256);
	function minimumCollateralRatioPercent() external view returns (uint256);
	function percentArbitrageProfitsForStablePOL() external view returns (uint256);
	}
struct AddedReward
	{
	bytes32 poolID;							
	uint256 amountToAdd;				
	}
struct UserShareInfo
	{
	uint128 userShare;					
	uint128 virtualRewards;				
	uint256 cooldownExpiration;		
	}
interface IStakingRewards
	{
	function claimAllRewards( bytes32[] calldata poolIDs ) external returns (uint256 rewardsAmount);
	function addSALTRewards( AddedReward[] calldata addedRewards ) external;
	function totalShares(bytes32 poolID) external view returns (uint256);
	function totalSharesForPools( bytes32[] calldata poolIDs ) external view returns (uint256[] calldata shares);
	function totalRewardsForPools( bytes32[] calldata poolIDs ) external view returns (uint256[] calldata rewards);
	function userRewardForPool( address wallet, bytes32 poolID ) external view returns (uint256);
	function userShareForPool( address wallet, bytes32 poolID ) external view returns (uint256);
	function userVirtualRewardsForPool( address wallet, bytes32 poolID ) external view returns (uint256);
	function userRewardsForPools( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata rewards);
	function userShareForPools( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata shares);
	function userCooldowns( address wallet, bytes32[] calldata poolIDs ) external view returns (uint256[] calldata cooldowns);
	}
interface ISalt is IERC20
	{
	function burnTokensInContract() external;
	function totalBurned() external view returns (uint256);
	}
interface IInitialDistribution
	{
	function distributionApproved() external;
	function bootstrapBallot() external view returns (IBootstrapBallot);
	}
interface IPriceAggregator
	{
	function setInitialFeeds( IPriceFeed _priceFeed1, IPriceFeed _priceFeed2, IPriceFeed _priceFeed3 ) external;
	function setPriceFeed( uint256 priceFeedNum, IPriceFeed newPriceFeed ) external; 
	function changeMaximumPriceFeedPercentDifferenceTimes1000(bool increase) external; 
	function changePriceFeedModificationCooldown(bool increase) external; 
	function maximumPriceFeedPercentDifferenceTimes1000() external view returns (uint256);
	function priceFeedModificationCooldown() external view returns (uint256);
	function priceFeed1() external view returns (IPriceFeed);
	function priceFeed2() external view returns (IPriceFeed);
	function priceFeed3() external view returns (IPriceFeed);
	function getPriceBTC() external view returns (uint256);
	function getPriceETH() external view returns (uint256);
	}
interface IRewardsEmitter
	{
	function addSALTRewards( AddedReward[] calldata addedRewards ) external;
	function performUpkeep( uint256 timeSinceLastUpkeep ) external;
	function pendingRewardsForPools( bytes32[] calldata pools ) external view returns (uint256[] calldata);
	}
interface ISaltRewards
	{
	function sendInitialSaltRewards( uint256 liquidityBootstrapAmount, bytes32[] calldata poolIDs ) external;
    function performUpkeep( bytes32[] calldata poolIDs, uint256[] calldata profitsForPools ) external;
    function stakingRewardsEmitter() external view returns (IRewardsEmitter);
    function liquidityRewardsEmitter() external view returns (IRewardsEmitter);
    }
interface ILiquidity is IStakingRewards
	{
	function depositLiquidityAndIncreaseShare( IERC20 tokenA, IERC20 tokenB, uint256 maxAmountA, uint256 maxAmountB, uint256 minLiquidityReceived, uint256 deadline, bool useZapping ) external returns (uint256 addedAmountA, uint256 addedAmountB, uint256 addedLiquidity);
	function withdrawLiquidityAndClaim( IERC20 tokenA, IERC20 tokenB, uint256 liquidityToWithdraw, uint256 minReclaimedA, uint256 minReclaimedB, uint256 deadline ) external returns (uint256 reclaimedA, uint256 reclaimedB);
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
contract VestingWallet is Context {
    event EtherReleased(uint256 amount);
    event ERC20Released(address indexed token, uint256 amount);
    uint256 private _released;
    mapping(address => uint256) private _erc20Released;
    address private immutable _beneficiary;
    uint64 private immutable _start;
    uint64 private immutable _duration;
    constructor(address beneficiaryAddress, uint64 startTimestamp, uint64 durationSeconds) payable {
        require(beneficiaryAddress != address(0), "VestingWallet: beneficiary is zero address");
        _beneficiary = beneficiaryAddress;
        _start = startTimestamp;
        _duration = durationSeconds;
    }
    receive() external payable virtual {}
    function beneficiary() public view virtual returns (address) {
        return _beneficiary;
    }
    function start() public view virtual returns (uint256) {
        return _start;
    }
    function duration() public view virtual returns (uint256) {
        return _duration;
    }
    function released() public view virtual returns (uint256) {
        return _released;
    }
    function released(address token) public view virtual returns (uint256) {
        return _erc20Released[token];
    }
    function releasable() public view virtual returns (uint256) {
        return vestedAmount(uint64(block.timestamp)) - released();
    }
    function releasable(address token) public view virtual returns (uint256) {
        return vestedAmount(token, uint64(block.timestamp)) - released(token);
    }
    function release() public virtual {
        uint256 amount = releasable();
        _released += amount;
        emit EtherReleased(amount);
        Address.sendValue(payable(beneficiary()), amount);
    }
    function release(address token) public virtual {
        uint256 amount = releasable(token);
        _erc20Released[token] += amount;
        emit ERC20Released(token, amount);
        SafeERC20.safeTransfer(IERC20(token), beneficiary(), amount);
    }
    function vestedAmount(uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(address(this).balance + released(), timestamp);
    }
    function vestedAmount(address token, uint64 timestamp) public view virtual returns (uint256) {
        return _vestingSchedule(IERC20(token).balanceOf(address(this)) + released(token), timestamp);
    }
    function _vestingSchedule(uint256 totalAllocation, uint64 timestamp) internal view virtual returns (uint256) {
        if (timestamp < start()) {
            return 0;
        } else if (timestamp > start() + duration()) {
            return totalAllocation;
        } else {
            return (totalAllocation * (timestamp - start())) / duration();
        }
    }
}
interface IDAO
	{
	function finalizeBallot( uint256 ballotID ) external;
	function withdrawArbitrageProfits( IERC20 weth ) external returns (uint256 withdrawnAmount);
	function formPOL( IERC20 tokenA, IERC20 tokenB, uint256 amountA, uint256 amountB ) external;
	function processRewardsFromPOL() external;
	function withdrawPOL( IERC20 tokenA, IERC20 tokenB, uint256 percentToLiquidate ) external;
	function pools() external view returns (IPools);
	function websiteURL() external view returns (string memory);
	function countryIsExcluded( string calldata country ) external view returns (bool);
	}
interface IExchangeConfig
	{
	function setContracts( IDAO _dao, IUpkeep _upkeep, IInitialDistribution _initialDistribution, IAirdrop _airdrop, VestingWallet _teamVestingWallet, VestingWallet _daoVestingWallet ) external; 
	function setAccessManager( IAccessManager _accessManager ) external; 
	function salt() external view returns (ISalt);
	function wbtc() external view returns (IERC20);
	function weth() external view returns (IERC20);
	function dai() external view returns (IERC20);
	function usds() external view returns (IUSDS);
	function managedTeamWallet() external view returns (IManagedWallet);
	function daoVestingWallet() external view returns (VestingWallet);
    function teamVestingWallet() external view returns (VestingWallet);
    function initialDistribution() external view returns (IInitialDistribution);
	function accessManager() external view returns (IAccessManager);
	function dao() external view returns (IDAO);
	function upkeep() external view returns (IUpkeep);
	function airdrop() external view returns (IAirdrop);
	function walletHasAccess( address wallet ) external view returns (bool);
	}
interface IPools is IPoolStats
	{
	function startExchangeApproved() external;
	function setContracts( IDAO _dao, ICollateralAndLiquidity _collateralAndLiquidity ) external; 
	function addLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 maxAmountA, uint256 maxAmountB, uint256 minLiquidityReceived, uint256 totalLiquidity ) external returns (uint256 addedAmountA, uint256 addedAmountB, uint256 addedLiquidity);
	function removeLiquidity( IERC20 tokenA, IERC20 tokenB, uint256 liquidityToRemove, uint256 minReclaimedA, uint256 minReclaimedB, uint256 totalLiquidity ) external returns (uint256 reclaimedA, uint256 reclaimedB);
	function deposit( IERC20 token, uint256 amount ) external;
	function withdraw( IERC20 token, uint256 amount ) external;
	function swap( IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function depositSwapWithdraw(IERC20 swapTokenIn, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function depositDoubleSwapWithdraw( IERC20 swapTokenIn, IERC20 swapTokenMiddle, IERC20 swapTokenOut, uint256 swapAmountIn, uint256 minAmountOut, uint256 deadline ) external returns (uint256 swapAmountOut);
	function exchangeIsLive() external view returns (bool);
	function getPoolReserves(IERC20 tokenA, IERC20 tokenB) external view returns (uint256 reserveA, uint256 reserveB);
	function depositedUserBalance(address user, IERC20 token) external view returns (uint256);
	}
interface ICollateralAndLiquidity is ILiquidity
	{
	function depositCollateralAndIncreaseShare( uint256 maxAmountWBTC, uint256 maxAmountWETH, uint256 minLiquidityReceived, uint256 deadline, bool useZapping ) external returns (uint256 addedAmountWBTC, uint256 addedAmountWETH, uint256 addedLiquidity);
	function withdrawCollateralAndClaim( uint256 collateralToWithdraw, uint256 minReclaimedWBTC, uint256 minReclaimedWETH, uint256 deadline ) external returns (uint256 reclaimedWBTC, uint256 reclaimedWETH);
	function borrowUSDS( uint256 amountBorrowed ) external;
	function repayUSDS( uint256 amountRepaid ) external;
	function liquidateUser( address wallet ) external;
	function liquidizer() external view returns (ILiquidizer);
	function usdsBorrowedByUsers( address wallet ) external view returns (uint256);
	function maxWithdrawableCollateral( address wallet ) external view returns (uint256);
	function maxBorrowableUSDS( address wallet ) external view returns (uint256);
	function numberOfUsersWithBorrowedUSDS() external view returns (uint256);
	function canUserBeLiquidated( address wallet ) external view returns (bool);
	function findLiquidatableUsers( uint256 startIndex, uint256 endIndex ) external view returns (address[] calldata);
	function findLiquidatableUsers() external view returns (address[] calldata);
	function underlyingTokenValueInUSD( uint256 amountBTC, uint256 amountETH ) external view returns (uint256);
	function totalCollateralValueInUSD() external view returns (uint256);
	function userCollateralValueInUSD( address wallet ) external view returns (uint256);
	}
interface ILiquidizer
	{
	function setContracts(ICollateralAndLiquidity _collateralAndLiquidity, IPools _pools, IDAO _dao) external; 
	function incrementBurnableUSDS( uint256 usdsToBurn ) external;
	function performUpkeep() external;
	function usdsThatShouldBeBurned() external view returns (uint256 _usdsThatShouldBeBurned);
	}
interface IUSDS is IERC20
	{
	function setCollateralAndLiquidity( ICollateralAndLiquidity _collateralAndLiquidity ) external; 
	function mintTo( address wallet, uint256 amount ) external;
	function burnTokensInContract() external;
	}
interface IPoolsConfig
	{
	function whitelistPool(  IPools pools, IERC20 tokenA, IERC20 tokenB ) external; 
	function unwhitelistPool( IPools pools, IERC20 tokenA, IERC20 tokenB ) external; 
	function changeMaximumWhitelistedPools(bool increase) external; 
	function changeMaximumInternalSwapPercentTimes1000(bool increase) external; 
    function maximumWhitelistedPools() external view returns (uint256);
    function maximumInternalSwapPercentTimes1000() external view returns (uint256);
	function numberOfWhitelistedPools() external view returns (uint256);
	function isWhitelisted( bytes32 poolID ) external view returns (bool);
	function whitelistedPools() external view returns (bytes32[] calldata);
	function underlyingTokenPair( bytes32 poolID ) external view returns (IERC20 tokenA, IERC20 tokenB);
	function tokenHasBeenWhitelisted( IERC20 token, IERC20 wbtc, IERC20 weth ) external view returns (bool);
	}
contract Upkeep is IUpkeep, ReentrancyGuard
    {
	using SafeERC20 for ISalt;
	using SafeERC20 for IUSDS;
	using SafeERC20 for IERC20;
    event UpkeepError(string description, bytes error);
	IPools immutable public pools;
	IExchangeConfig  immutable public exchangeConfig;
	IPoolsConfig immutable public poolsConfig;
	IDAOConfig immutable public daoConfig;
	IStableConfig immutable public stableConfig;
	IPriceAggregator immutable public priceAggregator;
	ISaltRewards immutable public saltRewards;
	ICollateralAndLiquidity immutable public collateralAndLiquidity;
	IEmissions immutable public emissions;
	IDAO immutable public dao;
	IERC20  immutable public weth;
	ISalt  immutable public salt;
	IUSDS  immutable public usds;
	IERC20  immutable public dai;
	uint256 public lastUpkeepTimeEmissions;
	uint256 public lastUpkeepTimeRewardsEmitters;
    constructor( IPools _pools, IExchangeConfig _exchangeConfig, IPoolsConfig _poolsConfig, IDAOConfig _daoConfig, IStableConfig _stableConfig, IPriceAggregator _priceAggregator, ISaltRewards _saltRewards, ICollateralAndLiquidity _collateralAndLiquidity, IEmissions _emissions, IDAO _dao )
		{
		pools = _pools;
		exchangeConfig = _exchangeConfig;
		poolsConfig = _poolsConfig;
		daoConfig = _daoConfig;
		stableConfig = _stableConfig;
		priceAggregator = _priceAggregator;
		saltRewards = _saltRewards;
		collateralAndLiquidity = _collateralAndLiquidity;
		emissions = _emissions;
		dao = _dao;
		weth = _exchangeConfig.weth();
		salt = _exchangeConfig.salt();
		usds = _exchangeConfig.usds();
		dai = _exchangeConfig.dai();
		lastUpkeepTimeEmissions = block.timestamp;
		lastUpkeepTimeRewardsEmitters = block.timestamp;
		weth.approve( address(pools), type(uint256).max );
		}
	modifier onlySameContract()
		{
    	require(msg.sender == address(this), "Only callable from within the same contract");
    	_;
		}
	function step1() public onlySameContract
		{
		collateralAndLiquidity.liquidizer().performUpkeep();
		}
	function step2(address receiver) public onlySameContract
		{
		uint256 withdrawnAmount = exchangeConfig.dao().withdrawArbitrageProfits(weth);
		if ( withdrawnAmount == 0 )
			return;
		uint256 rewardAmount = withdrawnAmount * daoConfig.upkeepRewardPercent() / 100;
		weth.safeTransfer(receiver, rewardAmount);
		}
	function _formPOL( IERC20 tokenA, IERC20 tokenB, uint256 amountWETH) internal
		{
		uint256 wethAmountPerToken = amountWETH >> 1;
		uint256 amountA = pools.depositSwapWithdraw( weth, tokenA, wethAmountPerToken, 0, block.timestamp );
		uint256 amountB = pools.depositSwapWithdraw( weth, tokenB, wethAmountPerToken, 0, block.timestamp );
		tokenA.safeTransfer( address(dao), amountA );
		tokenB.safeTransfer( address(dao), amountB );
		dao.formPOL(tokenA, tokenB, amountA, amountB);
		}
	function step3() public onlySameContract
		{
		uint256 wethBalance = weth.balanceOf( address(this) );
		if ( wethBalance == 0 )
			return;
		uint256 amountOfWETH = wethBalance * stableConfig.percentArbitrageProfitsForStablePOL() / 100;
		_formPOL(usds, dai, amountOfWETH);
		}
	function step4() public onlySameContract
		{
		uint256 wethBalance = weth.balanceOf( address(this) );
		if ( wethBalance == 0 )
			return;
		uint256 amountOfWETH = wethBalance * daoConfig.arbitrageProfitsPercentPOL() / 100;
		_formPOL(salt, usds, amountOfWETH);
		}
	function step5() public onlySameContract
		{
		uint256 wethBalance = weth.balanceOf( address(this) );
		if ( wethBalance == 0 )
			return;
		uint256 amountSALT = pools.depositSwapWithdraw( weth, salt, wethBalance, 0, block.timestamp );
		salt.safeTransfer(address(saltRewards), amountSALT);
		}
	function step6() public onlySameContract
		{
		uint256 timeSinceLastUpkeep = block.timestamp - lastUpkeepTimeEmissions;
		emissions.performUpkeep(timeSinceLastUpkeep);
		lastUpkeepTimeEmissions = block.timestamp;
		}
	function step7() public onlySameContract
		{
		uint256[] memory profitsForPools = pools.profitsForWhitelistedPools();
		bytes32[] memory poolIDs = poolsConfig.whitelistedPools();
		saltRewards.performUpkeep(poolIDs, profitsForPools );
		pools.clearProfitsForPools();
		}
	function step8() public onlySameContract
		{
		uint256 timeSinceLastUpkeep = block.timestamp - lastUpkeepTimeRewardsEmitters;
		saltRewards.stakingRewardsEmitter().performUpkeep(timeSinceLastUpkeep);
		saltRewards.liquidityRewardsEmitter().performUpkeep(timeSinceLastUpkeep);
		lastUpkeepTimeRewardsEmitters = block.timestamp;
		}
	function step9() public onlySameContract
		{
		dao.processRewardsFromPOL();
		}
	function step10() public onlySameContract
		{
		VestingWallet(payable(exchangeConfig.daoVestingWallet())).release(address(salt));
		}
	function step11() public onlySameContract
		{
		uint256 releaseableAmount = VestingWallet(payable(exchangeConfig.teamVestingWallet())).releasable(address(salt));
		VestingWallet(payable(exchangeConfig.teamVestingWallet())).release(address(salt));
		salt.safeTransfer( exchangeConfig.managedTeamWallet().mainWallet(), releaseableAmount );
		}
	function performUpkeep() public nonReentrant
		{
 		try this.step1() {}
		catch (bytes memory error) { emit UpkeepError("Step 1", error); }
 		try this.step2(msg.sender) {}
		catch (bytes memory error) { emit UpkeepError("Step 2", error); }
 		try this.step3() {}
		catch (bytes memory error) { emit UpkeepError("Step 3", error); }
 		try this.step4() {}
		catch (bytes memory error) { emit UpkeepError("Step 4", error); }
 		try this.step5() {}
		catch (bytes memory error) { emit UpkeepError("Step 5", error); }
 		try this.step6() {}
		catch (bytes memory error) { emit UpkeepError("Step 6", error); }
 		try this.step7() {}
		catch (bytes memory error) { emit UpkeepError("Step 7", error); }
 		try this.step8() {}
		catch (bytes memory error) { emit UpkeepError("Step 8", error); }
 		try this.step9() {}
		catch (bytes memory error) { emit UpkeepError("Step 9", error); }
 		try this.step10() {}
		catch (bytes memory error) { emit UpkeepError("Step 10", error); }
 		try this.step11() {}
		catch (bytes memory error) { emit UpkeepError("Step 11", error); }
		}
	function currentRewardsForCallingPerformUpkeep() public view returns (uint256)
		{
		uint256 daoWETH = pools.depositedUserBalance( address(dao), weth );
		return daoWETH * daoConfig.upkeepRewardPercent() / 100;
		}
	}