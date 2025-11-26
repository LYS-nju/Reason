pragma solidity =0.8.19;
interface ILevelManager {
    struct Tier {
        string id;
        uint256 multiplier; 
        uint256 lockingPeriod; 
        uint256 minAmount; 
        bool random;
        uint8 odds; 
        bool vip; 
        bool aag; 
        address pool; 
        uint256 amount; 
    }
    struct Pool {
        address addr;
        bool enabled;
        bool isVip; 
        bool isAAG; 
        uint256 minAAGLevelMultiplier;
        uint256 multiplierLotteryBoost;
        uint256 multiplierGuaranteedBoost;
        uint256 multiplierAAGBoost;
        uint256 multiplierSAAGBoost;
    }
    function getAlwaysRegister()
    external
    view
    returns (
        address[] memory,
        string[] memory,
        uint256[] memory
    );
    function getUserUnlockTime(address account) external view returns (uint256);
    function getTierById(string calldata id)
    external
    view
    returns (Tier memory);
    function getUserTier(address account) external view returns (Tier memory);
    function getIsUserAAG(address account) external view returns (bool);
    function getTierIds() external view returns (string[] memory);
    function lock(address account, address pool, uint256 startTime) external;
}