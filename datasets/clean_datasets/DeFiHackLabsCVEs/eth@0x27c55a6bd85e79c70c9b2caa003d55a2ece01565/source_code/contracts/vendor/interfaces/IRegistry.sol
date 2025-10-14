pragma solidity ^0.8.9;
interface IRegistry {
    function get_decimals(address pool) external view returns (uint[8] memory);
    function exchange(address _pool, address _from, address _to, uint _amound, uint _expected, address _receiver) external returns (uint);
    function get_exchange_amount(address _pool, address _from, address _to, uint _amount) external view returns (uint);
}