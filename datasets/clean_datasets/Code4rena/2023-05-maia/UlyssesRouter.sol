pragma solidity ^0.8.0;
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {UlyssesPool} from "./UlyssesPool.sol";
import {IUlyssesRouter, UlyssesFactory} from "./interfaces/IUlyssesRouter.sol";
contract UlyssesRouter is IUlyssesRouter {
    using SafeTransferLib for address;
    mapping(uint256 => UlyssesPool) private pools;
    UlyssesFactory public ulyssesFactory;
    constructor(UlyssesFactory _ulyssesFactory) {
        ulyssesFactory = _ulyssesFactory;
    }
    function getUlyssesLP(uint256 id) private returns (UlyssesPool ulysses) {
        ulysses = pools[id];
        if (address(ulysses) == address(0)) {
            ulysses = ulyssesFactory.pools(id);
            if (address(ulysses) == address(0)) revert UnrecognizedUlyssesLP();
            pools[id] = ulysses;
            address(ulysses.asset()).safeApprove(address(ulysses), type(uint256).max);
        }
    }
    function addLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256) {
        UlyssesPool ulysses = getUlyssesLP(poolId);
        amount = ulysses.deposit(amount, msg.sender);
        if (amount < minOutput) revert OutputTooLow();
        return amount;
    }
    function removeLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256) {
        UlyssesPool ulysses = getUlyssesLP(poolId);
        amount = ulysses.redeem(amount, msg.sender, msg.sender);
        if (amount < minOutput) revert OutputTooLow();
        return amount;
    }
    function swap(uint256 amount, uint256 minOutput, Route[] calldata routes) external returns (uint256) {
        address(getUlyssesLP(routes[0].from).asset()).safeTransferFrom(msg.sender, address(this), amount);
        uint256 length = routes.length;
        for (uint256 i = 0; i < length;) {
            amount = getUlyssesLP(routes[i].from).swapIn(amount, routes[i].to);
            unchecked {
                ++i;
            }
        }
        if (amount < minOutput) revert OutputTooLow();
        unchecked {
            --length;
        }
        address(getUlyssesLP(routes[length].to).asset()).safeTransfer(msg.sender, amount);
        return amount;
    }
}