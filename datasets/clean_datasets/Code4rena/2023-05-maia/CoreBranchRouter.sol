pragma solidity ^0.8.0;
import {Ownable} from "solady/auth/Ownable.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IBranchPort as IPort} from "./interfaces/IBranchPort.sol";
import {IBranchBridgeAgent as IBridgeAgent} from "./interfaces/IBranchBridgeAgent.sol";
import {IBranchBridgeAgentFactory as IBridgeAgentFactory} from "./interfaces/IBranchBridgeAgentFactory.sol";
import {IBranchRouter} from "./interfaces/IBranchRouter.sol";
import {ICoreBranchRouter} from "./interfaces/ICoreBranchRouter.sol";
import {IERC20hTokenBranchFactory as ITokenFactory} from "./interfaces/IERC20hTokenBranchFactory.sol";
import {BaseBranchRouter} from "./BaseBranchRouter.sol";
import {ERC20hTokenBranch as ERC20hToken} from "./token/ERC20hTokenBranch.sol";
contract CoreBranchRouter is BaseBranchRouter {
    address public hTokenFactoryAddress;
    address public localPortAddress;
    constructor(address _hTokenFactoryAddress, address _localPortAddress) BaseBranchRouter() {
        localPortAddress = _localPortAddress;
        hTokenFactoryAddress = _hTokenFactoryAddress;
    }
    function addGlobalToken(
        address _globalAddress,
        uint24 _toChain,
        uint128 _remoteExecutionGas,
        uint128 _rootExecutionGas
    ) external payable {
        bytes memory data = abi.encode(msg.sender, _globalAddress, _toChain, _rootExecutionGas);
        bytes memory packedData = abi.encodePacked(bytes1(0x01), data);
        IBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(
            msg.sender, packedData, 0, _remoteExecutionGas
        );
    }
    function addLocalToken(address _underlyingAddress) external payable virtual {
        string memory name = ERC20(_underlyingAddress).name();
        string memory symbol = ERC20(_underlyingAddress).symbol();
        ERC20hToken newToken = ITokenFactory(hTokenFactoryAddress).createToken(name, symbol);
        bytes memory data = abi.encode(_underlyingAddress, newToken, name, symbol);
        bytes memory packedData = abi.encodePacked(bytes1(0x02), data);
        IBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(msg.sender, packedData, 0, 0);
    }
    function _receiveAddGlobalToken(
        address _globalAddress,
        string memory _name,
        string memory _symbol,
        uint128 _rootExecutionGas
    ) internal {
        ERC20hToken newToken = ITokenFactory(hTokenFactoryAddress).createToken(_name, _symbol);
        bytes memory data = abi.encode(_globalAddress, newToken);
        bytes memory packedData = abi.encodePacked(bytes1(0x03), data);
        IBridgeAgent(localBridgeAgentAddress).performSystemCallOut(address(this), packedData, _rootExecutionGas, 0);
    }
    function _receiveAddBridgeAgent(
        address _newBranchRouter,
        address _branchBridgeAgentFactory,
        address _rootBridgeAgent,
        address _rootBridgeAgentFactory,
        uint128 _remoteExecutionGas
    ) internal virtual {
        if (!IPort(localPortAddress).isBridgeAgentFactory(_branchBridgeAgentFactory)) {
            revert UnrecognizedBridgeAgentFactory();
        }
        address newBridgeAgent = IBridgeAgentFactory(_branchBridgeAgentFactory).createBridgeAgent(
            _newBranchRouter, _rootBridgeAgent, _rootBridgeAgentFactory
        );
        if (!IPort(localPortAddress).isBridgeAgent(newBridgeAgent)) {
            revert UnrecognizedBridgeAgent();
        }
        bytes memory data = abi.encode(newBridgeAgent, _rootBridgeAgent);
        bytes memory packedData = abi.encodePacked(bytes1(0x04), data);
        IBridgeAgent(localBridgeAgentAddress).performSystemCallOut(address(this), packedData, _remoteExecutionGas, 0);
    }
    function _toggleBranchBridgeAgentFactory(address _newBridgeAgentFactoryAddress) internal {
        if (!IPort(localPortAddress).isBridgeAgentFactory(_newBridgeAgentFactoryAddress)) {
            IPort(localPortAddress).addBridgeAgentFactory(_newBridgeAgentFactoryAddress);
        } else {
            IPort(localPortAddress).toggleBridgeAgentFactory(_newBridgeAgentFactoryAddress);
        }
    }
    function _removeBranchBridgeAgent(address _branchBridgeAgent) internal {
        if (!IPort(localPortAddress).isBridgeAgent(_branchBridgeAgent)) revert UnrecognizedBridgeAgent();
        IPort(localPortAddress).toggleBridgeAgent(_branchBridgeAgent);
    }
    function _manageStrategyToken(address _underlyingToken, uint256 _minimumReservesRatio) internal {
        if (!IPort(localPortAddress).isStrategyToken(_underlyingToken)) {
            IPort(localPortAddress).addStrategyToken(_underlyingToken, _minimumReservesRatio);
        } else {
            IPort(localPortAddress).toggleStrategyToken(_underlyingToken);
        }
    }
    function _managePortStrategy(
        address _portStrategy,
        address _underlyingToken,
        uint256 _dailyManagementLimit,
        bool _isUpdateDailyLimit
    ) internal {
        if (!IPort(localPortAddress).isPortStrategy(_portStrategy, _underlyingToken)) {
            IPort(localPortAddress).addPortStrategy(_portStrategy, _underlyingToken, _dailyManagementLimit);
        } else if (_isUpdateDailyLimit) {
            IPort(localPortAddress).updatePortStrategy(_portStrategy, _underlyingToken, _dailyManagementLimit);
        } else {
            IPort(localPortAddress).togglePortStrategy(_portStrategy, _underlyingToken);
        }
    }
    function anyExecuteNoSettlement(bytes calldata _data)
        external
        virtual
        override
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        if (_data[0] == 0x01) {
            (address globalAddress, string memory name, string memory symbol, uint128 gasToBridgeOut) =
                abi.decode(_data[1:], (address, string, string, uint128));
            _receiveAddGlobalToken(globalAddress, name, symbol, gasToBridgeOut);
        } else if (_data[0] == 0x02) {
            (
                address newBranchRouter,
                address branchBridgeAgentFactory,
                address rootBridgeAgent,
                address rootBridgeAgentFactory,
                uint128 remoteExecutionGas
            ) = abi.decode(_data[1:], (address, address, address, address, uint128));
            _receiveAddBridgeAgent(
                newBranchRouter, branchBridgeAgentFactory, rootBridgeAgent, rootBridgeAgentFactory, remoteExecutionGas
            );
        } else if (_data[0] == 0x03) {
            (address bridgeAgentFactoryAddress) = abi.decode(_data[1:], (address));
            _toggleBranchBridgeAgentFactory(bridgeAgentFactoryAddress);
        } else if (_data[0] == 0x04) {
            (address branchBridgeAgent) = abi.decode(_data[1:], (address));
            _removeBranchBridgeAgent(branchBridgeAgent);
        } else if (_data[0] == 0x05) {
            (address underlyingToken, uint256 minimumReservesRatio) = abi.decode(_data[1:], (address, uint256));
            _manageStrategyToken(underlyingToken, minimumReservesRatio);
        } else if (_data[0] == 0x06) {
            (address portStrategy, address underlyingToken, uint256 dailyManagementLimit, bool isUpdateDailyLimit) =
                abi.decode(_data[1:], (address, address, uint256, bool));
            _managePortStrategy(portStrategy, underlyingToken, dailyManagementLimit, isUpdateDailyLimit);
        } else {
            return (false, "unknown selector");
        }
        return (true, "");
    }
    fallback() external payable {}
    error UnrecognizedBridgeAgent();
    error UnrecognizedBridgeAgentFactory();
}