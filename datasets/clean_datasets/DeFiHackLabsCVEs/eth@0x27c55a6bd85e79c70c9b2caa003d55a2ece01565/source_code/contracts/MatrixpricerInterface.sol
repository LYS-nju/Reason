pragma solidity ^0.8.10;
abstract contract MatrixpricerInterface {
    bool public constant isMatrixpricer = true;
    function mintAllowed(address depToken, address minter) virtual external returns (uint);
    function redeemAllowed(address depToken, address redeemer, uint redeemTokens) virtual external returns (uint);
    function borrowAllowed(address depToken, address borrower) virtual external returns (uint);
    function repayBorrowAllowed(
        address depToken,
        address borrower) virtual external returns (uint);
    function transferAllowed(address depToken, address src, address dst, uint transferTokens) virtual external returns (uint);
}