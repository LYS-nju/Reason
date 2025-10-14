pragma solidity ^0.8.4;
interface IPancakeLibrary {
    function sortTokens(address tokenA, address tokenB) external pure returns (address token0, address token1);
    function pairFor(address factory, address tokenA, address tokenB) external view returns (address pair);
    function getReserves(address factory, address tokenA, address tokenB) external pure returns (uint reserveA, uint reserveB);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external view returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(address factory, uint amountIn, address[] memory path) external view returns (uint[] memory amounts);
    function getAmountsIn(address factory, uint amountOut, address[] memory path) external pure returns (uint[] memory amounts);
}