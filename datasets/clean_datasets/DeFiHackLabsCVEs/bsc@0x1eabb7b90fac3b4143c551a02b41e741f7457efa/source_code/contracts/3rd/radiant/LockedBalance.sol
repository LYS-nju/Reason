pragma solidity 0.8.20;
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