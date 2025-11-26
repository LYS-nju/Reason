pragma solidity ^0.8.9;
interface ISlasher {
    struct MiddlewareTimes {
        uint32 stalestUpdateBlock;
        uint32 latestServeUntilBlock;
    }
    struct MiddlewareDetails {
        uint32 contractCanSlashOperatorUntilBlock;
        uint32 latestUpdateBlock;
    }
    function optIntoSlashing(address contractAddress) external;
    function freezeOperator(address toBeFrozen) external;
    function resetFrozenStatus(address[] calldata frozenAddresses) external;
    function recordFirstStakeUpdate(address operator, uint32 serveUntilBlock) external;
    function recordStakeUpdate(address operator, uint32 updateBlock, uint32 serveUntilBlock, uint256 insertAfter) external;
    function recordLastStakeUpdateAndRevokeSlashingAbility(address operator, uint32 serveUntilBlock) external;
    function isFrozen(address staker) external view returns (bool);
    function canSlash(address toBeSlashed, address slashingContract) external view returns (bool);
    function contractCanSlashOperatorUntilBlock(address operator, address serviceContract) external view returns (uint32);
    function latestUpdateBlock(address operator, address serviceContract) external view returns (uint32);
    function getCorrectValueForInsertAfter(address operator, uint32 updateBlock) external view returns (uint256);
    function canWithdraw(address operator, uint32 withdrawalStartBlock, uint256 middlewareTimesIndex) external view returns(bool);
    function operatorToMiddlewareTimes(address operator, uint256 arrayIndex) external view returns (MiddlewareTimes memory);
    function middlewareTimesLength(address operator) external view returns (uint256);
    function getMiddlewareTimesIndexBlock(address operator, uint32 index) external view returns(uint32);
    function getMiddlewareTimesIndexServeUntilBlock(address operator, uint32 index) external view returns(uint32);
    function operatorWhitelistedContractsLinkedListSize(address operator) external view returns (uint256);
    function operatorWhitelistedContractsLinkedListEntry(address operator, address node) external view returns (bool, uint256, uint256);
}