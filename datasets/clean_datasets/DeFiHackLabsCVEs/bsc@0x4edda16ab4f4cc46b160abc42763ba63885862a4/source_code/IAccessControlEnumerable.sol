pragma solidity ^0.8.20;
import {IAccessControl} from "IAccessControl.sol";
interface IAccessControlEnumerable is IAccessControl {
    function getRoleMember(bytes32 role, uint256 index) external view returns (address);
    function getRoleMemberCount(bytes32 role) external view returns (uint256);
}