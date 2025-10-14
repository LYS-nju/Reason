pragma solidity 0.8.17;
import "./IERC20.sol";
contract LeetSwapV2Fees {
    address internal immutable pair; 
    address internal immutable token0; 
    address internal immutable token1; 
    error InvalidToken();
    error TransferFailed();
    error Unauthorized();
    constructor(address _token0, address _token1) {
        pair = msg.sender;
        token0 = _token0;
        token1 = _token1;
    }
    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        if (token.code.length == 0) revert InvalidToken();
        bool success = IERC20(token).transfer(to, value);
        if (!success) revert TransferFailed();
    }
    function claimFeesFor(
        address recipient,
        uint256 amount0,
        uint256 amount1
    ) external {
        if (msg.sender != pair) revert Unauthorized();
        if (amount0 > 0) _safeTransfer(token0, recipient, amount0);
        if (amount1 > 0) _safeTransfer(token1, recipient, amount1);
    }
}