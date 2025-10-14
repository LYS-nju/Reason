pragma solidity ^0.8.9;
import { ICurveFi } from "./vendor/interfaces/ICurveFi.sol";
import { IRegistry } from "./vendor/interfaces/IRegistry.sol";
import { IAddressProvider } from "./vendor/interfaces/IAddressProvider.sol";
import { IERC20 } from "./vendor/interfaces/IERC20.sol";
import { SafeERC20 } from "./vendor/interfaces/SafeERC20.sol";
import "hardhat/console.sol";
import "./CurveContractInterface.sol";
contract CurveSwap is CurveContractInterface{
    using SafeERC20 for IERC20;
    address public TriPool;
    address public ADDRESSPROVIDER;
    address public USDC_ADDRESS;
    address public USDT_ADDRESS;
    function setAddressesCurve(address TriPool_, address ADDRESSPROVIDER_, address USDC_ADDRESS_, address USDT_ADDRESS_) internal {
        TriPool = TriPool_;
        ADDRESSPROVIDER = ADDRESSPROVIDER_;
        USDC_ADDRESS = USDC_ADDRESS_;
        USDT_ADDRESS = USDT_ADDRESS_;
    }
    function QueryAddressProvider(uint id) internal view returns (address) {
        return IAddressProvider(ADDRESSPROVIDER).get_address(id);
    }
    function PerformExchange(address _from, address _to, uint _amount, uint _expected, address _receiver) internal returns (uint256) {
        address Registry = QueryAddressProvider(2);
        uint receToken = IRegistry(Registry).exchange(TriPool, _from, _to, _amount, _expected, _receiver);
        return receToken;
    }
    function changeUSDT2USDC(uint _amount, uint _expected, address _receiver) virtual internal returns (uint256) {
        address Registry = QueryAddressProvider(2);
        approveToken(USDT_ADDRESS, Registry, _amount);
        uint receToken = IRegistry(Registry).exchange(TriPool, USDT_ADDRESS, USDC_ADDRESS, _amount, _expected, _receiver);
        return receToken;
    }
    function changeUSDC2USDT(uint _amount, uint _expected, address _receiver) internal returns (uint256) {
        address Registry = QueryAddressProvider(2);
        approveToken(USDC_ADDRESS, Registry, _amount);
        uint receToken = IRegistry(Registry).exchange(TriPool, USDC_ADDRESS, USDT_ADDRESS, _amount, _expected, _receiver);
        return receToken;
    }
    function approveToken(address token, address spender, uint _amount) public returns (bool) {
        IERC20(token).safeApprove(spender, _amount);
        return true;
    }
}