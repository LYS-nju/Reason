pragma solidity ^0.8.9;
import "./IStrategy.sol";
interface IDelegationTerms {
    function payForService(IERC20 token, uint256 amount) external payable;
    function onDelegationWithdrawn(
        address delegator,
        IStrategy[] memory stakerStrategyList,
        uint256[] memory stakerShares
    ) external returns(bytes memory);
    function onDelegationReceived(
        address delegator,
        IStrategy[] memory stakerStrategyList,
        uint256[] memory stakerShares
    ) external returns(bytes memory);
}