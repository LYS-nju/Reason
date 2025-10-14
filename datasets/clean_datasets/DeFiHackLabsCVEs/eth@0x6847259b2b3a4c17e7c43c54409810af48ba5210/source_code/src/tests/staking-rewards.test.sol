pragma solidity ^0.6.7;
import "../lib/safe-math.sol";
import "../staking-rewards.sol";
import "./lib/test.sol";
import "./lib/mock-erc20.sol";
import "./lib/hevm.sol";
contract StakngRewardsTest is DSTest {
    using SafeMath for uint256;
    MockERC20 stakingToken;
    MockERC20 rewardsToken;
    StakingRewards stakingRewards;
    address owner;
    Hevm hevm = Hevm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);
    function setUp() public {
        owner = address(this);
        stakingToken = new MockERC20("staking", "STAKE");
        rewardsToken = new MockERC20("rewards", "RWD");
        stakingRewards = new StakingRewards(
            owner,
            address(rewardsToken),
            address(stakingToken)
        );
    }
    function test_staking() public {
        uint256 stakeAmount = 100 ether;
        uint256 rewardAmount = 100 ether;
        stakingToken.mint(owner, stakeAmount);
        rewardsToken.mint(owner, rewardAmount);
        stakingToken.approve(address(stakingRewards), stakeAmount);
        stakingRewards.stake(stakeAmount);
        uint256 _before = stakingRewards.earned(owner);
        assertEq(_before, 0);
        hevm.warp(block.timestamp + 1 days);
        uint256 _after = stakingRewards.earned(owner);
        assertEq(_after, _before);
        rewardsToken.transfer(address(stakingRewards), rewardAmount);
        stakingRewards.notifyRewardAmount(rewardAmount);
        uint256 _rateBefore = stakingRewards.getRewardForDuration();
        assertTrue(_rateBefore > 0);
        _before = stakingRewards.earned(owner);
        hevm.warp(block.timestamp + 1 days);
        _after = stakingRewards.earned(owner);
        assertTrue(_after > _before);
        assertTrue(_after > 0);
        rewardsToken.mint(owner, rewardAmount);
        rewardsToken.transfer(address(stakingRewards), rewardAmount);
        stakingRewards.notifyRewardAmount(rewardAmount);
        uint256 _rateAfter = stakingRewards.getRewardForDuration();
        assertTrue(_rateAfter > _rateBefore);
        hevm.warp(stakingRewards.periodFinish() + 1 days);
        stakingRewards.getReward();
        _before = stakingRewards.earned(owner);
        hevm.warp(block.timestamp + 1 days);
        _after = stakingRewards.earned(owner);
        assertEq(_before, 0);
        assertEq(_after, 0);
    }
}