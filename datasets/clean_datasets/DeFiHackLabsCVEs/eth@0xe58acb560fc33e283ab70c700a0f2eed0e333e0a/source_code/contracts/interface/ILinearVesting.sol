pragma solidity ^0.8.0;
enum ExchangeMode {
    normalExchange,
    repeatExchange,
    normalUnstake,
    repeatUnstake
}
enum SwitchType {
    normalReleaseSwitch,
    repeatReleaseSwitch,
    normalUnstakeReleaseSwitch,
    repeatUnstakeReleaseSwitch
}
struct VestingSchedule {
    uint256 start;
    address beneficiary;
    uint256 amount;
    uint256 released;
}
struct Info {
    uint256 periods;
    uint256 interval;
}
interface ILinearVesting {
    function addLinearVesting(address beneficiary, uint256 amount) external;
    function addLinearVesting(
        bytes32 txHash,
        address beneficiary,
        uint256 amount,
        ExchangeMode mode
    ) external;
    function release(uint256 index) external;
    function getReleasableAmount(uint256 index) external view returns (uint256);
}