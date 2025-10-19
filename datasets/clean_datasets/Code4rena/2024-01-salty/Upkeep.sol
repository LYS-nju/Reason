pragma solidity =0.8.22;
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "openzeppelin-contracts/contracts/security/ReentrancyGuard.sol";
import "openzeppelin-contracts/contracts/finance/VestingWallet.sol";
import "./price_feed/interfaces/IPriceAggregator.sol";
import "./stable/interfaces/IStableConfig.sol";
import "./rewards/interfaces/IEmissions.sol";
import "./pools/interfaces/IPoolsConfig.sol";
import "./interfaces/IExchangeConfig.sol";
import "./dao/interfaces/IDAOConfig.sol";
import "./pools/interfaces/IPools.sol";
import "./dao/interfaces/IDAO.sol";
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