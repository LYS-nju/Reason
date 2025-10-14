pragma solidity ^0.8.9;
import "./IDelegationTerms.sol";
interface IDelegationManager {
    function registerAsOperator(IDelegationTerms dt) external;
    function delegateTo(address operator) external;
    function delegateToBySignature(address staker, address operator, uint256 expiry, bytes memory signature) external;
    function undelegate(address staker) external;
    function delegatedTo(address staker) external view returns (address);
    function delegationTerms(address operator) external view returns (IDelegationTerms);
    function operatorShares(address operator, IStrategy strategy) external view returns (uint256);
    function increaseDelegatedShares(address staker, IStrategy strategy, uint256 shares) external;
    function decreaseDelegatedShares(
        address staker,
        IStrategy[] calldata strategies,
        uint256[] calldata shares
    ) external;
    function isDelegated(address staker) external view returns (bool);
    function isNotDelegated(address staker) external view returns (bool);
    function isOperator(address operator) external view returns (bool);
}