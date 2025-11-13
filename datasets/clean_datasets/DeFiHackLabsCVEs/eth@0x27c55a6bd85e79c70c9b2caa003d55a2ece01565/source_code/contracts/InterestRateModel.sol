pragma solidity ^0.8.10;
abstract contract InterestRateModel {
    bool public constant isInterestRateModel = true;
    function getBorrowRate(uint iur, uint cRatePerBlock) virtual external view returns (uint);
    function getSupplyRate(uint iur, uint cRatePerBlock) virtual external view returns (uint);
}