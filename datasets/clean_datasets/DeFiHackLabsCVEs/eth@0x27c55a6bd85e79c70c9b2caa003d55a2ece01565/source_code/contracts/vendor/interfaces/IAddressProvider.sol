pragma solidity ^0.8.9;
interface IAddressProvider {
    function get_registry() external view;
    function get_address(uint id) external view returns (address);
}