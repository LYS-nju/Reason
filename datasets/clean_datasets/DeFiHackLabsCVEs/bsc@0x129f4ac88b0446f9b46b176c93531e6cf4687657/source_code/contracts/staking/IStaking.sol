pragma solidity =0.8.19;
interface IStaking {
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 pendingRewards;
        uint256 lastStakedAt;
        uint256 lastUnstakedAt;
    }
    function getUserInfo(address account) external view returns (UserInfo memory);
    function pendingRewards(address account) external view returns (uint256);
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function claim() external;
}