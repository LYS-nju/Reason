pragma solidity 0.8.20;
import "./IPSwapAggregator.sol";
interface IPendleRouter {
  struct ApproxParams {
    uint256 guessMin;
    uint256 guessMax;
    uint256 guessOffchain; 
    uint256 maxIteration; 
    uint256 eps; 
  }
  struct TokenInput {
    address tokenIn;
    uint256 netTokenIn;
    address tokenMintSy;
    address bulk;
    address pendleSwap;
    SwapData swapData;
  }
  struct TokenOutput {
    address tokenOut;
    uint256 minTokenOut;
    address tokenRedeemSy;
    address bulk;
    address pendleSwap;
    SwapData swapData;
  }
  function addLiquiditySingleToken(
    address receiver,
    address market,
    uint256 minLpOut,
    ApproxParams calldata guessPtReceivedFromSy,
    TokenInput calldata input
  ) external payable returns (uint256 netLpOut, uint256 netSyFee);
  function removeLiquiditySingleToken(
    address receiver,
    address market,
    uint256 netLpToRemove,
    TokenOutput calldata output
  ) external returns (uint256 netTokenOut, uint256 netSyFee);
}