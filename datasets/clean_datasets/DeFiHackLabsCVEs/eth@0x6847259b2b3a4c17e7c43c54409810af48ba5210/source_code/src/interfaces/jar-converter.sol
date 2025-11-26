pragma solidity ^0.6.2;
interface IJarConverter {
    function convert(
        address _refundExcess, 
        uint256 _amount, 
        bytes calldata _data
    ) external returns (uint256);
}