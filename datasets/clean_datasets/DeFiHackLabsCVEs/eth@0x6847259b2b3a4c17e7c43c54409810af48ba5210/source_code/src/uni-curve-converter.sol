pragma solidity ^0.6.7;
import "./lib/safe-math.sol";
import "./lib/erc20.sol";
import "./interfaces/uniswapv2.sol";
import "./interfaces/curve.sol";
contract UniCurveConverter {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    UniswapRouterV2 public router = UniswapRouterV2(
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
    );
    address public constant dai = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant usdc = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant susd = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address public constant scrv = 0xC25a3A3b969415c80451098fa907EC722572917F;
    address public constant weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    ICurveFi_4 public curve = ICurveFi_4(
        0xA5407eAE9Ba41422680e2e00537571bcC53efBfD
    );
    function convert(address _lp, uint256 _amount) public {
        IERC20(_lp).safeTransferFrom(msg.sender, address(this), _amount);
        IUniswapV2Pair fromPair = IUniswapV2Pair(_lp);
        if (!(fromPair.token0() == weth || fromPair.token1() == weth)) {
            revert("!eth-from");
        }
        IERC20(_lp).safeApprove(address(router), 0);
        IERC20(_lp).safeApprove(address(router), _amount);
        router.removeLiquidity(
            fromPair.token0(),
            fromPair.token1(),
            _amount,
            0,
            0,
            address(this),
            now + 60
        );
        (address premiumStablecoin, ) = getMostPremium();
        address[] memory path = new address[](2);
        path[0] = weth;
        path[1] = premiumStablecoin;
        IERC20(weth).safeApprove(address(router), 0);
        IERC20(weth).safeApprove(address(router), uint256(-1));
        router.swapExactTokensForTokens(
            IERC20(weth).balanceOf(address(this)),
            0,
            path,
            address(this),
            now + 60
        );
        address _from = fromPair.token0() != weth
            ? fromPair.token0()
            : fromPair.token1();
        if (_from != dai && _from != usdc && _from != usdt && _from != susd) {
            path = new address[](3);
            path[0] = _from;
            path[1] = weth;
            path[2] = premiumStablecoin;
            IERC20(_from).safeApprove(address(router), 0);
            IERC20(_from).safeApprove(address(router), uint256(-1));
            router.swapExactTokensForTokens(
                IERC20(_from).balanceOf(address(this)),
                0,
                path,
                address(this),
                now + 60
            );
        }
        IERC20(dai).safeApprove(address(curve), 0);
        IERC20(dai).safeApprove(address(curve), uint256(-1));
        IERC20(usdc).safeApprove(address(curve), 0);
        IERC20(usdc).safeApprove(address(curve), uint256(-1));
        IERC20(usdt).safeApprove(address(curve), 0);
        IERC20(usdt).safeApprove(address(curve), uint256(-1));
        IERC20(susd).safeApprove(address(curve), 0);
        IERC20(susd).safeApprove(address(curve), uint256(-1));
        curve.add_liquidity(
            [
                IERC20(dai).balanceOf(address(this)),
                IERC20(usdc).balanceOf(address(this)),
                IERC20(usdt).balanceOf(address(this)),
                IERC20(susd).balanceOf(address(this))
            ],
            0
        );
        IERC20(scrv).transfer(
            msg.sender,
            IERC20(scrv).balanceOf(address(this))
        );
    }
    function getMostPremium() public view returns (address, uint256) {
        uint256[] memory balances = new uint256[](4);
        balances[0] = ICurveFi_4(curve).balances(0); 
        balances[1] = ICurveFi_4(curve).balances(1).mul(10**12); 
        balances[2] = ICurveFi_4(curve).balances(2).mul(10**12); 
        balances[3] = ICurveFi_4(curve).balances(3); 
        if (
            balances[0] < balances[1] &&
            balances[0] < balances[2] &&
            balances[0] < balances[3]
        ) {
            return (dai, 0);
        }
        if (
            balances[1] < balances[0] &&
            balances[1] < balances[2] &&
            balances[1] < balances[3]
        ) {
            return (usdc, 1);
        }
        if (
            balances[2] < balances[0] &&
            balances[2] < balances[1] &&
            balances[2] < balances[3]
        ) {
            return (usdt, 2);
        }
        if (
            balances[3] < balances[0] &&
            balances[3] < balances[1] &&
            balances[3] < balances[2]
        ) {
            return (susd, 3);
        }
        return (dai, 0);
    }
}