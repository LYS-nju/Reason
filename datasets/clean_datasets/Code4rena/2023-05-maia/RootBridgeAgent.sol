pragma solidity ^0.8.0;
import {Ownable} from "solady/auth/Ownable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {SafeCastLib} from "solady/utils/SafeCastLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {WETH9} from "./interfaces/IWETH9.sol";
import {IUniswapV3Pool} from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import {AnycallFlags} from "./lib/AnycallFlags.sol";
import {IAnycallProxy} from "./interfaces/IAnycallProxy.sol";
import {IAnycallConfig} from "./interfaces/IAnycallConfig.sol";
import {IAnycallExecutor} from "./interfaces/IAnycallExecutor.sol";
import {IApp, IRootBridgeAgent} from "./interfaces/IRootBridgeAgent.sol";
import {IBranchBridgeAgent} from "./interfaces/IBranchBridgeAgent.sol";
import {IERC20hTokenRoot} from "./interfaces/IERC20hTokenRoot.sol";
import {IRootPort as IPort} from "./interfaces/IRootPort.sol";
import {IRootRouter as IRouter} from "./interfaces/IRootRouter.sol";
import {VirtualAccount} from "./VirtualAccount.sol";
import {
    IRootBridgeAgent,
    DepositParams,
    DepositMultipleParams,
    Settlement,
    SettlementStatus,
    SettlementParams,
    SettlementMultipleParams,
    UserFeeInfo,
    SwapCallbackData
} from "./interfaces/IRootBridgeAgent.sol";
import {DeployRootBridgeAgentExecutor, RootBridgeAgentExecutor} from "./RootBridgeAgentExecutor.sol";
library CheckParamsLib {
    function checkParams(address _localPortAddress, DepositParams memory _dParams, uint24 _fromChain)
        internal
        view
        returns (bool)
    {
        if (
            (_dParams.amount < _dParams.deposit) 
                || (_dParams.amount > 0 && !IPort(_localPortAddress).isLocalToken(_dParams.hToken, _fromChain)) 
                || (_dParams.deposit > 0 && !IPort(_localPortAddress).isUnderlyingToken(_dParams.token, _fromChain)) 
        ) {
            return false;
        }
        return true;
    }
}
library DeployRootBridgeAgent {
    function deploy(
        WETH9 _wrappedNativeToken,
        uint24 _localChainId,
        address _daoAddress,
        address _localAnyCallAddress,
        address _localAnyCallExecutorAddress,
        address _localPortAddress,
        address _localRouterAddress
    ) external returns (RootBridgeAgent) {
        return new RootBridgeAgent(
            _wrappedNativeToken,
            _localChainId,
            _daoAddress,
            _localAnyCallAddress,
            _localAnyCallExecutorAddress,
            _localPortAddress,
            _localRouterAddress
        );
    }
}
contract RootBridgeAgent is IRootBridgeAgent {
    using SafeTransferLib for address;
    using SafeCastLib for uint256;
    uint8 internal constant PARAMS_START = 1;
    uint8 internal constant PARAMS_START_SIGNED = 21;
    uint8 internal constant PARAMS_ADDRESS_SIZE = 20;
    uint8 internal constant PARAMS_GAS_IN = 32;
    uint8 internal constant PARAMS_GAS_OUT = 16;
    uint8 internal constant PARAMS_TKN_START = 5;
    uint8 internal constant PARAMS_AMT_OFFSET = 64;
    uint8 internal constant PARAMS_DEPOSIT_OFFSET = 96;
    uint24 public immutable localChainId;
    WETH9 public immutable wrappedNativeToken;
    address public immutable factoryAddress;
    address public immutable daoAddress;
    address public immutable localRouterAddress;
    address public immutable localPortAddress;
    address public immutable localAnyCallAddress;
    address public immutable localAnyCallExecutorAddress;
    address public immutable bridgeAgentExecutorAddress;
    mapping(uint256 => address) public getBranchBridgeAgent;
    mapping(uint256 => bool) public isBranchBridgeAgentAllowed;
    uint32 public settlementNonce;
    mapping(uint32 => Settlement) public getSettlement;
    mapping(uint256 => mapping(uint32 => bool)) public executionHistory;
    uint256 internal constant MIN_FALLBACK_RESERVE = 155_000; 
    uint256 internal constant MIN_EXECUTION_OVERHEAD = 155_000; 
    uint256 public initialGas;
    UserFeeInfo public userFeeInfo;
    uint256 public accumulatedFees;
    constructor(
        WETH9 _wrappedNativeToken,
        uint24 _localChainId,
        address _daoAddress,
        address _localAnyCallAddress,
        address _localAnyCallExecutorAddress,
        address _localPortAddress,
        address _localRouterAddress
    ) {
        require(address(_wrappedNativeToken) != address(0), "Wrapped native token cannot be zero address");
        require(_daoAddress != address(0), "DAO cannot be zero address");
        require(_localAnyCallAddress != address(0), "Anycall Address cannot be zero address");
        require(_localAnyCallExecutorAddress != address(0), "Anycall Executor Address cannot be zero address");
        require(_localPortAddress != address(0), "Port Address cannot be zero address");
        require(_localRouterAddress != address(0), "Router Address cannot be zero address");
        wrappedNativeToken = _wrappedNativeToken;
        factoryAddress = msg.sender;
        daoAddress = _daoAddress;
        localChainId = _localChainId;
        localAnyCallAddress = _localAnyCallAddress;
        localPortAddress = _localPortAddress;
        localRouterAddress = _localRouterAddress;
        bridgeAgentExecutorAddress = DeployRootBridgeAgentExecutor.deploy(address(this));
        localAnyCallExecutorAddress = _localAnyCallExecutorAddress;
        settlementNonce = 1;
        accumulatedFees = 1; 
    }
    function getSettlementEntry(uint32 _settlementNonce) external view returns (Settlement memory) {
        return getSettlement[_settlementNonce];
    }
    function retrySettlement(uint32 _settlementNonce, uint128 _remoteExecutionGas) external payable {
        if (initialGas == 0) {
            userFeeInfo.depositedGas = uint128(msg.value);
            userFeeInfo.gasToBridgeOut = _remoteExecutionGas;
        }
        _retrySettlement(_settlementNonce);
    }
    function redeemSettlement(uint32 _depositNonce) external lock {
        address depositOwner = getSettlement[_depositNonce].owner;
        if (getSettlement[_depositNonce].status != SettlementStatus.Failed || depositOwner == address(0)) {
            revert SettlementRedeemUnavailable();
        } else if (
            msg.sender != depositOwner && msg.sender != address(IPort(localPortAddress).getUserAccount(depositOwner))
        ) {
            revert NotSettlementOwner();
        }
        _redeemSettlement(_depositNonce);
    }
    function callOut(address _recipient, bytes memory _data, uint24 _toChain) external payable lock requiresRouter {
        bytes memory data =
            abi.encodePacked(bytes1(0x00), _recipient, settlementNonce++, _data, _manageGasOut(_toChain));
        _performCall(data, _toChain);
    }
    function callOutAndBridge(
        address _owner,
        address _recipient,
        bytes memory _data,
        address _globalAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) external payable lock requiresRouter {
        address localAddress = IPort(localPortAddress).getLocalTokenFromGlobal(_globalAddress, _toChain);
        address underlyingAddress = IPort(localPortAddress).getUnderlyingTokenFromLocal(localAddress, _toChain);
        if (localAddress == address(0) || (underlyingAddress == address(0) && _deposit > 0)) {
            revert InvalidInputParams();
        }
        bytes memory data = abi.encodePacked(
            bytes1(0x01),
            _recipient,
            settlementNonce,
            localAddress,
            underlyingAddress,
            _amount,
            _deposit,
            _data,
            _manageGasOut(_toChain)
        );
        _updateStateOnBridgeOut(
            msg.sender, _globalAddress, localAddress, underlyingAddress, _amount, _deposit, _toChain
        );
        _createSettlement(_owner, _recipient, localAddress, underlyingAddress, _amount, _deposit, data, _toChain);
        _performCall(data, _toChain);
    }
    function callOutAndBridgeMultiple(
        address _owner,
        address _recipient,
        bytes memory _data,
        address[] memory _globalAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        uint24 _toChain
    ) external payable lock requiresRouter {
        address[] memory hTokens = new address[](_globalAddresses.length);
        address[] memory tokens = new address[](_globalAddresses.length);
        for (uint256 i = 0; i < _globalAddresses.length;) {
            hTokens[i] = IPort(localPortAddress).getLocalTokenFromGlobal(_globalAddresses[i], _toChain);
            tokens[i] = IPort(localPortAddress).getUnderlyingTokenFromLocal(hTokens[i], _toChain);
            if (hTokens[i] == address(0) || (tokens[i] == address(0) && _deposits[i] > 0)) revert InvalidInputParams();
            _updateStateOnBridgeOut(
                msg.sender, _globalAddresses[i], hTokens[i], tokens[i], _amounts[i], _deposits[i], _toChain
            );
            unchecked {
                ++i;
            }
        }
        bytes memory data = abi.encodePacked(
            bytes1(0x02),
            _recipient,
            uint8(hTokens.length),
            settlementNonce,
            hTokens,
            tokens,
            _amounts,
            _deposits,
            _data,
            _manageGasOut(_toChain)
        );
        _createMultipleSettlement(_owner, _recipient, hTokens, tokens, _amounts, _deposits, data, _toChain);
        _performCall(data, _toChain);
    }
    function bridgeIn(address _recipient, DepositParams memory _dParams, uint24 _fromChain)
        public
        requiresAgentExecutor
    {
        if (!CheckParamsLib.checkParams(localPortAddress, _dParams, _fromChain)) {
            revert InvalidInputParams();
        }
        address globalAddress = IPort(localPortAddress).getGlobalTokenFromLocal(_dParams.hToken, _fromChain);
        if (globalAddress == address(0)) revert InvalidInputParams();
        IPort(localPortAddress).bridgeToRoot(_recipient, globalAddress, _dParams.amount, _dParams.deposit, _fromChain);
    }
    function bridgeInMultiple(address _recipient, DepositMultipleParams memory _dParams, uint24 _fromChain)
        external
        requiresAgentExecutor
    {
        for (uint256 i = 0; i < _dParams.hTokens.length;) {
            bridgeIn(
                _recipient,
                DepositParams({
                    hToken: _dParams.hTokens[i],
                    token: _dParams.tokens[i],
                    amount: _dParams.amounts[i],
                    deposit: _dParams.deposits[i],
                    toChain: _dParams.toChain,
                    depositNonce: 0
                }),
                _fromChain
            );
            unchecked {
                ++i;
            }
        }
    }
    function _updateStateOnBridgeOut(
        address _sender,
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) internal {
        if (_amount - _deposit > 0) {
            if (_localAddress == address(0)) revert UnrecognizedLocalAddress();
            _globalAddress.safeTransferFrom(_sender, localPortAddress, _amount - _deposit);
        }
        if (_deposit > 0) {
            if (_underlyingAddress == address(0)) revert UnrecognizedUnderlyingAddress();
            if (IERC20hTokenRoot(_globalAddress).getTokenBalance(_toChain) < _deposit) {
                revert InsufficientBalanceForSettlement();
            }
            IPort(localPortAddress).burn(_sender, _globalAddress, _deposit, _toChain);
        }
    }
    function _createSettlement(
        address _owner,
        address _recipient,
        address _hToken,
        address _token,
        uint256 _amount,
        uint256 _deposit,
        bytes memory _callData,
        uint24 _toChain
    ) internal {
        address[] memory hTokens = new address[](1);
        hTokens[0] = _hToken;
        address[] memory tokens = new address[](1);
        tokens[0] = _token;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;
        uint256[] memory deposits = new uint256[](1);
        deposits[0] = _deposit;
        _createMultipleSettlement(_owner, _recipient, hTokens, tokens, amounts, deposits, _callData, _toChain);
    }
    function _createMultipleSettlement(
        address _owner,
        address _recipient,
        address[] memory _hTokens,
        address[] memory _tokens,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        bytes memory _callData,
        uint24 _toChain
    ) internal {
        getSettlement[_getAndIncrementSettlementNonce()] = Settlement({
            owner: _owner,
            recipient: _recipient,
            hTokens: _hTokens,
            tokens: _tokens,
            amounts: _amounts,
            deposits: _deposits,
            callData: _callData,
            toChain: _toChain,
            status: SettlementStatus.Success,
            gasToBridgeOut: userFeeInfo.gasToBridgeOut
        });
    }
    function _retrySettlement(uint32 _settlementNonce) internal returns (bool) {
        Settlement memory settlement = getSettlement[_settlementNonce];
        if (settlement.owner == address(0)) return false;
        bytes memory newGas = abi.encodePacked(_manageGasOut(settlement.toChain));
        for (uint256 i = 0; i < newGas.length;) {
            settlement.callData[settlement.callData.length - 16 + i] = newGas[i];
            unchecked {
                ++i;
            }
        }
        Settlement storage settlementReference = getSettlement[_settlementNonce];
        settlementReference.gasToBridgeOut = userFeeInfo.gasToBridgeOut;
        settlementReference.callData = settlement.callData;
        settlementReference.status = SettlementStatus.Success;
        _performCall(settlement.callData, settlement.toChain);
        return true;
    }
    function _redeemSettlement(uint32 _settlementNonce) internal {
        Settlement storage settlement = getSettlement[_settlementNonce];
        for (uint256 i = 0; i < settlement.hTokens.length;) {
            if (settlement.hTokens[i] != address(0)) {
                IPort(localPortAddress).bridgeToRoot(
                    msg.sender,
                    IPort(localPortAddress).getGlobalTokenFromLocal(settlement.hTokens[i], settlement.toChain),
                    settlement.amounts[i],
                    settlement.deposits[i],
                    settlement.toChain
                );
            }
            unchecked {
                ++i;
            }
        }
        delete getSettlement[_settlementNonce];
    }
    function _reopenSettlemment(uint32 _settlementNonce) internal {
        getSettlement[_settlementNonce].status = SettlementStatus.Failed;
    }
    function _getAndIncrementSettlementNonce() internal returns (uint32) {
        return settlementNonce++;
    }
    uint24 private constant GLOBAL_DIVISIONER = 1e6; 
    mapping(address => bool) private approvedGasPool;
    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata _data) external {
        if (!approvedGasPool[msg.sender]) revert CallerIsNotPool();
        if (amount0 == 0 && amount1 == 0) revert AmountsAreZero();
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        address(data.tokenIn).safeTransfer(msg.sender, uint256(amount0 > 0 ? amount0 : amount1));
    }
    function _gasSwapIn(uint256 _amount, uint24 _fromChain) internal returns (uint256) {
        (bool zeroForOneOnInflow, uint24 priceImpactPercentage, address gasTokenGlobalAddress, address poolAddress) =
            IPort(localPortAddress).getGasPoolInfo(_fromChain);
        if (gasTokenGlobalAddress == address(0) || poolAddress == address(0)) revert InvalidGasPool();
        IPort(localPortAddress).bridgeToRoot(address(this), gasTokenGlobalAddress, _amount, _amount, _fromChain);
        if (!approvedGasPool[poolAddress]) approvedGasPool[poolAddress] = true;
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(poolAddress).slot0();
        uint160 exactSqrtPriceImpact = (sqrtPriceX96 * (priceImpactPercentage / 2)) / GLOBAL_DIVISIONER;
        uint160 sqrtPriceLimitX96 =
            zeroForOneOnInflow ? sqrtPriceX96 - exactSqrtPriceImpact : sqrtPriceX96 + exactSqrtPriceImpact;
        try IUniswapV3Pool(poolAddress).swap(
            address(this),
            zeroForOneOnInflow,
            int256(_amount),
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({tokenIn: gasTokenGlobalAddress}))
        ) returns (int256 amount0, int256 amount1) {
            return uint256(zeroForOneOnInflow ? amount1 : amount0);
        } catch (bytes memory) {
            _forceRevert();
            return 0;
        }
    }
    function _gasSwapOut(uint256 _amount, uint24 _toChain) internal returns (uint256, address) {
        (bool zeroForOneOnInflow, uint24 priceImpactPercentage, address gasTokenGlobalAddress, address poolAddress) =
            IPort(localPortAddress).getGasPoolInfo(_toChain);
        if (gasTokenGlobalAddress == address(0) || poolAddress == address(0)) revert InvalidGasPool();
        if (!approvedGasPool[poolAddress]) approvedGasPool[poolAddress] = true;
        uint160 sqrtPriceLimitX96;
        {
            (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(poolAddress).slot0();
            uint160 exactSqrtPriceImpact = (sqrtPriceX96 * (priceImpactPercentage / 2)) / GLOBAL_DIVISIONER;
            sqrtPriceLimitX96 =
                zeroForOneOnInflow ? sqrtPriceX96 + exactSqrtPriceImpact : sqrtPriceX96 - exactSqrtPriceImpact;
        }
        (int256 amount0, int256 amount1) = IUniswapV3Pool(poolAddress).swap(
            address(this),
            !zeroForOneOnInflow,
            int256(_amount),
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({tokenIn: address(wrappedNativeToken)}))
        );
        return (uint256(!zeroForOneOnInflow ? amount1 : amount0), gasTokenGlobalAddress);
    }
    function _manageGasOut(uint24 _toChain) internal returns (uint128) {
        uint256 amountOut;
        address gasToken;
        uint256 _initialGas = initialGas;
        if (_toChain == localChainId) {
            if (_initialGas > 0) {
                address(wrappedNativeToken).safeTransfer(getBranchBridgeAgent[localChainId], userFeeInfo.gasToBridgeOut);
            }
            return uint128(userFeeInfo.gasToBridgeOut);
        }
        if (_initialGas > 0) {
            if (userFeeInfo.gasToBridgeOut <= MIN_FALLBACK_RESERVE * tx.gasprice) revert InsufficientGasForFees();
            (amountOut, gasToken) = _gasSwapOut(userFeeInfo.gasToBridgeOut, _toChain);
        } else {
            if (msg.value <= MIN_FALLBACK_RESERVE * tx.gasprice) revert InsufficientGasForFees();
            wrappedNativeToken.deposit{value: msg.value}();
            (amountOut, gasToken) = _gasSwapOut(msg.value, _toChain);
        }
        IPort(localPortAddress).burn(address(this), gasToken, amountOut, _toChain);
        return amountOut.toUint128();
    }
    function _performCall(bytes memory _calldata, uint256 _toChain) internal {
        address callee = getBranchBridgeAgent[_toChain];
        if (callee == address(0)) revert UnrecognizedBridgeAgent();
        if (_toChain != localChainId) {
            IAnycallProxy(localAnyCallAddress).anyCall(
                callee, _calldata, _toChain, AnycallFlags.FLAG_ALLOW_FALLBACK_DST, ""
            );
        } else {
            IBranchBridgeAgent(callee).anyExecute(_calldata);
        }
    }
    function _payExecutionGas(uint128 _depositedGas, uint128 _gasToBridgeOut, uint256 _initialGas, uint24 _fromChain)
        internal
    {
        delete(initialGas);
        delete(userFeeInfo);
        if (_fromChain == localChainId) return;
        uint256 availableGas = _depositedGas - _gasToBridgeOut;
        uint256 minExecCost = tx.gasprice * (MIN_EXECUTION_OVERHEAD + _initialGas - gasleft());
        if (minExecCost > availableGas) {
            _forceRevert();
            return;
        }
        _replenishGas(minExecCost);
        accumulatedFees += availableGas - minExecCost;
    }
    function _payFallbackGas(uint32 _settlementNonce, uint256 _initialGas) internal virtual {
        uint256 gasLeft = gasleft();
        uint256 minExecCost = tx.gasprice * (MIN_FALLBACK_RESERVE + _initialGas - gasLeft);
        if (minExecCost > getSettlement[_settlementNonce].gasToBridgeOut) {
            _forceRevert();
            return;
        }
        getSettlement[_settlementNonce].gasToBridgeOut -= minExecCost.toUint128();
    }
    function _replenishGas(uint256 _executionGasSpent) internal {
        wrappedNativeToken.withdraw(_executionGasSpent);
        IAnycallConfig(IAnycallProxy(localAnyCallAddress).config()).deposit{value: _executionGasSpent}(address(this));
    }
    function _getContext() internal view returns (address from, uint256 fromChainId) {
        (from, fromChainId,) = IAnycallExecutor(localAnyCallExecutorAddress).context();
    }
    function anyExecute(bytes calldata data)
        external
        virtual
        requiresExecutor
        returns (bool success, bytes memory result)
    {
        uint256 _initialGas = gasleft();
        uint24 fromChainId;
        UserFeeInfo memory _userFeeInfo;
        if (localAnyCallExecutorAddress == msg.sender) {
            initialGas = _initialGas;
            (, uint256 _fromChainId) = _getContext();
            fromChainId = _fromChainId.toUint24();
            _userFeeInfo.depositedGas = _gasSwapIn(
                uint256(uint128(bytes16(data[data.length - PARAMS_GAS_IN:data.length - PARAMS_GAS_OUT]))), fromChainId
            ).toUint128();
            _userFeeInfo.gasToBridgeOut = uint128(bytes16(data[data.length - PARAMS_GAS_OUT:data.length]));
        } else {
            fromChainId = localChainId;
            _userFeeInfo.depositedGas = uint128(bytes16(data[data.length - 32:data.length - 16]));
            _userFeeInfo.gasToBridgeOut = _userFeeInfo.depositedGas;
        }
        if (_userFeeInfo.depositedGas < _userFeeInfo.gasToBridgeOut) {
            _forceRevert();
            return (true, "Not enough gas to bridge out");
        }
        userFeeInfo = _userFeeInfo;
        bytes1 flag = data[0];
        if (flag == 0x00) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSystemRequest(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                (success, result) = (false, reason);
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x01) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeNoDeposit(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                (success, result) = (true, reason);
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x02) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeWithDeposit(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x03) {
            uint32 nonce = uint32(bytes4(data[2:6]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeWithDepositMultiple(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x04) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            VirtualAccount userAccount = IPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );
            IPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedNoDeposit(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                (success, result) = (true, reason);
            }
            IPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x05) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            VirtualAccount userAccount = IPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );
            IPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedWithDeposit(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            IPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x06) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            VirtualAccount userAccount = IPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );
            IPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedWithDepositMultiple(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            IPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x07) {
            uint32 nonce = uint32(bytes4(data[1:5]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeRetrySettlement(uint32(bytes4(data[5:9])))
            returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x08) {
            uint32 nonce = uint32(bytes4(data[1:5]));
            if (!executionHistory[fromChainId][uint32(bytes4(data[1:5]))]) {
                executionHistory[fromChainId][nonce] = true;
                (success, result) = (false, "");
            } else {
                _forceRevert();
                return (true, "already executed tx");
            }
        } else {
            if (initialGas > 0) {
                _payExecutionGas(userFeeInfo.depositedGas, userFeeInfo.gasToBridgeOut, _initialGas, fromChainId);
            }
            return (false, "unknown selector");
        }
        emit LogCallin(flag, data, fromChainId);
        if (initialGas > 0) {
            _payExecutionGas(userFeeInfo.depositedGas, userFeeInfo.gasToBridgeOut, _initialGas, fromChainId);
        }
    }
    function anyFallback(bytes calldata data)
        external
        virtual
        requiresExecutor
        returns (bool success, bytes memory result)
    {
        uint256 _initialGas = gasleft();
        (, uint256 _fromChainId) = _getContext();
        uint24 fromChainId = _fromChainId.toUint24();
        bytes1 flag = data[0];
        uint32 _settlementNonce;
        if (flag == 0x00) {
            _settlementNonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            _reopenSettlemment(_settlementNonce);
        } else if (flag == 0x01) {
            _settlementNonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            _reopenSettlemment(_settlementNonce);
        } else if (flag == 0x02) {
            _settlementNonce = uint32(bytes4(data[22:26]));
            _reopenSettlemment(_settlementNonce);
        }
        emit LogCalloutFail(flag, data, fromChainId);
        _payFallbackGas(_settlementNonce, _initialGas);
        return (true, "");
    }
    function depositGasAnycallConfig() external payable {
        _replenishGas(msg.value);
    }
    function forceRevert() external requiresLocalBranchBridgeAgent {
        _forceRevert();
    }
    function _forceRevert() internal {
        if (initialGas == 0) revert GasErrorOrRepeatedTx();
        IAnycallConfig anycallConfig = IAnycallConfig(IAnycallProxy(localAnyCallAddress).config());
        uint256 executionBudget = anycallConfig.executionBudget(address(this));
        if (executionBudget > 0) try anycallConfig.withdraw(executionBudget) {} catch {}
    }
    function approveBranchBridgeAgent(uint256 _branchChainId) external requiresManager {
        if (getBranchBridgeAgent[_branchChainId] != address(0)) revert AlreadyAddedBridgeAgent();
        isBranchBridgeAgentAllowed[_branchChainId] = true;
    }
    function syncBranchBridgeAgent(address _newBranchBridgeAgent, uint24 _branchChainId) external requiresPort {
        getBranchBridgeAgent[_branchChainId] = _newBranchBridgeAgent;
    }
    function sweep() external {
        if (msg.sender != daoAddress) revert NotDao();
        uint256 _accumulatedFees = accumulatedFees - 1;
        accumulatedFees = 1;
        SafeTransferLib.safeTransferETH(daoAddress, _accumulatedFees);
    }
    uint256 internal _unlocked = 1;
    modifier lock() {
        require(_unlocked == 1);
        _unlocked = 2;
        _;
        _unlocked = 1;
    }
    modifier requiresExecutor() {
        _requiresExecutor();
        _;
    }
    function _requiresExecutor() internal view {
        if (msg.sender == getBranchBridgeAgent[localChainId]) return;
        if (msg.sender != localAnyCallExecutorAddress) revert AnycallUnauthorizedCaller();
        (address from, uint256 fromChainId,) = IAnycallExecutor(localAnyCallExecutorAddress).context();
        if (getBranchBridgeAgent[fromChainId] != from) revert AnycallUnauthorizedCaller();
    }
    modifier requiresRouter() {
        _requiresRouter();
        _;
    }
    function _requiresRouter() internal view {
        if (msg.sender != localRouterAddress) revert UnrecognizedCallerNotRouter();
    }
    modifier requiresAgentExecutor() {
        if (msg.sender != bridgeAgentExecutorAddress) revert UnrecognizedExecutor();
        _;
    }
    modifier requiresLocalBranchBridgeAgent() {
        if (msg.sender != getBranchBridgeAgent[localChainId]) {
            revert UnrecognizedExecutor();
        }
        _;
    }
    modifier requiresPort() {
        if (msg.sender != localPortAddress) revert UnrecognizedPort();
        _;
    }
    modifier requiresManager() {
        if (msg.sender != IPort(localPortAddress).getBridgeAgentManager(address(this))) {
            revert UnrecognizedBridgeAgentManager();
        }
        _;
    }
    fallback() external payable {}
}