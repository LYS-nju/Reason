pragma solidity ^0.8.10;
abstract contract TensorpricerInterface {
    bool public constant isTensorpricer = true;
    function mintAllowed(address levToken, address minter) virtual external returns (uint);
    function redeemAllowed(address levToken, address redeemer, uint redeemTokens) virtual external returns (uint);
    function transferAllowed(address levToken, address src, address dst, uint transferTokens) virtual external returns (uint);
    function getFx(string memory fxname) virtual external view returns (uint);
    function _setMintPausedLev(address levToken, bool state) virtual public returns (bool);
    function _setRedeemPausedLev(address levToken, bool state) virtual public returns (bool);
}