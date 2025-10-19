pragma solidity ^0.8.19;
import '../common/library/InitErrors.sol';
import {UnderACM} from '../common/UnderACM.sol';
import {BaseMappingIdHook} from './BaseMappingIdHook.sol';
import {
    OrderType,
    OrderStatus,
    SwapType,
    Order,
    MarginPos,
    SwapInfo,
    IMarginTradingHook
} from '../interfaces/hook/IMarginTradingHook.sol';
import {IWNative} from '../interfaces/common/IWNative.sol';
import {IInitCore} from '../interfaces/core/IInitCore.sol';
import {ICallbackReceiver} from '../interfaces/receiver/ICallbackReceiver.sol';
import {IMulticall} from '../interfaces/common/IMulticall.sol';
import {ILendingPool} from '../interfaces/lending_pool/ILendingPool.sol';
import {IPosManager} from '../interfaces/core/IPosManager.sol';
import {IInitOracle} from '../interfaces/oracle/IInitOracle.sol';
import {IBaseSwapHelper} from '../interfaces/helper/swap_helper/IBaseSwapHelper.sol';
import {IERC20} from '@openzeppelin-contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin-contracts/token/ERC20/utils/SafeERC20.sol';
import {Math} from '@openzeppelin-contracts/utils/math/Math.sol';
contract MarginTradingHook is BaseMappingIdHook, UnderACM, IMarginTradingHook, ICallbackReceiver {
    using SafeERC20 for IERC20;
    using Math for uint;
    uint private constant ONE_E18 = 1e18;
    uint private constant ONE_E36 = 1e36;
    bytes32 private constant GOVERNOR = keccak256('governor');
    address public immutable WNATIVE;
    address public swapHelper;
    mapping(address => mapping(address => address)) private __quoteAssets;
    mapping(uint => Order) private __orders;
    mapping(uint => MarginPos) private __marginPositions;
    mapping(uint => uint[]) private __posOrderIds;
    uint public lastOrderId;
    modifier onlyGovernor() {
        ACM.checkRole(GOVERNOR, msg.sender);
        _;
    }
    constructor(address _core, address _posManager, address _wNative, address _acm)
        BaseMappingIdHook(_core, _posManager)
        UnderACM(_acm)
    {
        WNATIVE = _wNative;
    }
    function initialize(address _swapHelper) external initializer {
        swapHelper = _swapHelper;
    }
    modifier depositNative() {
        if (msg.value != 0) IWNative(WNATIVE).deposit{value: msg.value}();
        _;
    }
    modifier refundNative() {
        _;
        uint wNativeBal = IERC20(WNATIVE).balanceOf(address(this));
        if (wNativeBal != 0) IWNative(WNATIVE).withdraw(wNativeBal);
        uint nativeBal = address(this).balance;
        if (nativeBal != 0) {
            (bool success,) = payable(msg.sender).call{value: nativeBal}('');
            _require(success, Errors.CALL_FAILED);
        }
    }
    function openPos(
        uint16 _mode,
        address _viewer,
        address _tokenIn,
        uint _amtIn,
        address _borrPool,
        uint _borrAmt,
        address _collPool,
        bytes calldata _data,
        uint _minHealth_e18
    ) external payable depositNative refundNative returns (uint posId, uint initPosId, uint health_e18) {
        initPosId = IInitCore(CORE).createPos(_mode, _viewer);
        address borrToken = ILendingPool(_borrPool).underlyingToken();
        {
            (address baseToken, address quoteToken) = getBaseAssetAndQuoteAsset(
                ILendingPool(_collPool).underlyingToken(), ILendingPool(_borrPool).underlyingToken()
            );
            bool isLongBaseAsset = baseToken != borrToken;
            __marginPositions[initPosId] = MarginPos(_collPool, _borrPool, baseToken, quoteToken, isLongBaseAsset);
        }
        posId = ++lastPosIds[msg.sender];
        initPosIds[msg.sender][posId] = initPosId;
        health_e18 = _increasePosInternal(
            IncreasePosInternalParam({
                initPosId: initPosId,
                tokenIn: _tokenIn,
                amtIn: _amtIn,
                borrPool: _borrPool,
                borrAmt: _borrAmt,
                collPool: _collPool,
                data: _data,
                minHealth_e18: _minHealth_e18
            })
        );
    }
    function increasePos(
        uint _posId,
        address _tokenIn,
        uint _amtIn,
        uint _borrAmt,
        bytes calldata _data,
        uint _minHealth_e18
    ) external payable depositNative refundNative returns (uint health_e18) {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        health_e18 = _increasePosInternal(
            IncreasePosInternalParam({
                initPosId: initPosId,
                tokenIn: _tokenIn,
                amtIn: _amtIn,
                borrPool: marginPos.borrPool,
                borrAmt: _borrAmt,
                collPool: marginPos.collPool,
                data: _data,
                minHealth_e18: _minHealth_e18
            })
        );
    }
    function _increasePosInternal(IncreasePosInternalParam memory _param) internal returns (uint health_e18) {
        _transmitTokenIn(_param.tokenIn, _param.amtIn);
        bytes[] memory multicallData = new bytes[](4);
        multicallData[0] = abi.encodeWithSelector(
            IInitCore(CORE).borrow.selector, _param.borrPool, _param.borrAmt, _param.initPosId, address(this)
        );
        address collToken = ILendingPool(_param.collPool).underlyingToken();
        address borrToken = ILendingPool(_param.borrPool).underlyingToken();
        _require(_param.tokenIn == collToken || _param.tokenIn == borrToken, Errors.INVALID_INPUT);
        {
            SwapInfo memory swapInfo =
                SwapInfo(_param.initPosId, SwapType.OpenExactIn, borrToken, collToken, 0, _param.data);
            multicallData[1] =
                abi.encodeWithSelector(IInitCore(CORE).callback.selector, address(this), 0, abi.encode(swapInfo));
        }
        multicallData[2] = abi.encodeWithSelector(IInitCore(CORE).mintTo.selector, _param.collPool, POS_MANAGER);
        multicallData[3] =
            abi.encodeWithSelector(IInitCore(CORE).collateralize.selector, _param.initPosId, _param.collPool);
        IMulticall(CORE).multicall(multicallData);
        health_e18 = _validateHealth(_param.initPosId, _param.minHealth_e18);
        emit IncreasePos(_param.initPosId, _param.tokenIn, borrToken, _param.amtIn, _param.borrAmt);
    }
    function addCollateral(uint _posId, uint _amtIn)
        external
        payable
        depositNative
        refundNative
        returns (uint health_e18)
    {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        _transmitTokenIn(collToken, _amtIn);
        IERC20(collToken).safeTransfer(marginPos.collPool, _amtIn);
        IInitCore(CORE).mintTo(marginPos.collPool, POS_MANAGER);
        IInitCore(CORE).collateralize(initPosId, marginPos.collPool);
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(initPosId);
    }
    function removeCollateral(uint _posId, uint _shares, bool _returnNative)
        external
        refundNative
        returns (uint health_e18)
    {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        IInitCore(CORE).decollateralize(initPosId, marginPos.collPool, _shares, marginPos.collPool);
        IInitCore(CORE).burnTo(marginPos.collPool, address(this));
        uint balance = IERC20(collToken).balanceOf(address(this));
        _transmitTokenOut(collToken, balance, _returnNative);
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(initPosId);
    }
    function repayDebt(uint _posId, uint _repayShares)
        external
        payable
        depositNative
        refundNative
        returns (uint repayAmt, uint health_e18)
    {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos storage marginPos = __marginPositions[initPosId];
        address borrPool = marginPos.borrPool;
        uint debtShares = IPosManager(POS_MANAGER).getPosDebtShares(initPosId, borrPool);
        if (_repayShares > debtShares) _repayShares = debtShares;
        address borrToken = ILendingPool(borrPool).underlyingToken();
        uint amtToRepay = ILendingPool(borrPool).debtShareToAmtCurrent(_repayShares);
        _transmitTokenIn(borrToken, amtToRepay);
        _ensureApprove(borrToken, amtToRepay);
        repayAmt = IInitCore(CORE).repay(borrPool, _repayShares, initPosId);
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(initPosId);
    }
    function reducePos(
        uint _posId,
        uint _collAmt,
        uint _repayShares,
        address _tokenOut,
        uint _minAmtOut,
        bool _returnNative,
        bytes calldata _data,
        uint _minHealth_e18
    ) external refundNative returns (uint amtOut, uint health_e18) {
        uint initPosId = initPosIds[msg.sender][_posId];
        (amtOut, health_e18) = _reducePosInternal(
            ReducePosInternalParam({
                initPosId: initPosId,
                collAmt: _collAmt,
                repayShares: _repayShares,
                tokenOut: _tokenOut,
                minAmtOut: _minAmtOut,
                returnNative: _returnNative,
                data: _data,
                minHealth_e18: _minHealth_e18
            })
        );
    }
    function _reducePosInternal(ReducePosInternalParam memory _param) internal returns (uint amtOut, uint health_e18) {
        MarginPos memory marginPos = __marginPositions[_param.initPosId];
        _require(
            _param.collAmt <= IPosManager(POS_MANAGER).getCollAmt(_param.initPosId, marginPos.collPool),
            Errors.INPUT_TOO_HIGH
        );
        _require(
            _param.repayShares <= IPosManager(POS_MANAGER).getPosDebtShares(_param.initPosId, marginPos.borrPool),
            Errors.INPUT_TOO_HIGH
        );
        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        address borrToken = ILendingPool(marginPos.borrPool).underlyingToken();
        _require(_param.tokenOut == collToken || _param.tokenOut == borrToken, Errors.INVALID_INPUT);
        uint repayAmt = ILendingPool(marginPos.borrPool).debtShareToAmtCurrent(_param.repayShares);
        _ensureApprove(borrToken, repayAmt);
        bytes[] memory multicallData = new bytes[](4);
        multicallData[0] = abi.encodeWithSelector(
            IInitCore(CORE).decollateralize.selector,
            _param.initPosId,
            marginPos.collPool,
            _param.collAmt,
            marginPos.collPool
        );
        multicallData[1] = abi.encodeWithSelector(IInitCore(CORE).burnTo.selector, marginPos.collPool, address(this));
        {
            SwapType swapType = _param.tokenOut == borrToken ? SwapType.CloseExactIn : SwapType.CloseExactOut;
            SwapInfo memory swapInfo = SwapInfo(_param.initPosId, swapType, collToken, borrToken, repayAmt, _param.data);
            multicallData[2] =
                abi.encodeWithSelector(IInitCore(CORE).callback.selector, address(this), 0, abi.encode(swapInfo));
        }
        multicallData[3] = abi.encodeWithSelector(
            IInitCore(CORE).repay.selector, marginPos.borrPool, _param.repayShares, _param.initPosId
        );
        IMulticall(CORE).multicall(multicallData);
        amtOut = IERC20(_param.tokenOut).balanceOf(address(this));
        _require(amtOut >= _param.minAmtOut, Errors.SLIPPAGE_CONTROL);
        _transmitTokenOut(_param.tokenOut, amtOut, _param.returnNative);
        health_e18 = _validateHealth(_param.initPosId, _param.minHealth_e18);
        emit ReducePos(_param.initPosId, _param.tokenOut, amtOut, _param.collAmt, repayAmt);
    }
    function addStopLossOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId) {
        orderId = _createOrder(_posId, _triggerPrice_e36, _tokenOut, _limitPrice_e36, _collAmt, OrderType.StopLoss);
    }
    function addTakeProfitOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId) {
        orderId = _createOrder(_posId, _triggerPrice_e36, _tokenOut, _limitPrice_e36, _collAmt, OrderType.TakeProfit);
    }
    function cancelOrder(uint _posId, uint _orderId) external {
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        Order storage order = __orders[_orderId];
        _require(order.initPosId == initPosId, Errors.INVALID_INPUT);
        _require(order.status == OrderStatus.Active, Errors.INVALID_INPUT);
        order.status = OrderStatus.Cancelled;
        emit CancelOrder(initPosId, _orderId);
    }
    function fillOrder(uint _orderId) external {
        Order memory order = __orders[_orderId];
        _require(order.status == OrderStatus.Active, Errors.INVALID_INPUT);
        MarginPos memory marginPos = __marginPositions[order.initPosId];
        address collToken = ILendingPool(marginPos.collPool).underlyingToken();
        address borrToken = ILendingPool(marginPos.borrPool).underlyingToken();
        if (IPosManager(POS_MANAGER).getCollAmt(order.initPosId, marginPos.collPool) == 0) {
            order.status = OrderStatus.Cancelled;
            emit CancelOrder(order.initPosId, _orderId);
            return;
        }
        _validateTriggerPrice(order, marginPos);
        (uint amtOut, uint repayShares, uint repayAmt) = _calculateFillOrderInfo(order, marginPos, collToken);
        IERC20(borrToken).safeTransferFrom(msg.sender, address(this), repayAmt);
        IERC20(order.tokenOut).safeTransferFrom(msg.sender, order.recipient, amtOut);
        _ensureApprove(borrToken, repayAmt);
        IInitCore(CORE).repay(marginPos.borrPool, repayShares, order.initPosId);
        IInitCore(CORE).decollateralize(order.initPosId, marginPos.collPool, order.collAmt, msg.sender);
        __orders[_orderId].status = OrderStatus.Filled;
        emit FillOrder(order.initPosId, _orderId, order.tokenOut, amtOut);
    }
    function coreCallback(address _sender, bytes calldata _data) external payable returns (bytes memory result) {
        _require(msg.sender == CORE, Errors.NOT_INIT_CORE);
        _require(_sender == address(this), Errors.NOT_AUTHORIZED);
        SwapInfo memory swapInfo = abi.decode(_data, (SwapInfo));
        MarginPos memory marginPos = __marginPositions[swapInfo.initPosId];
        uint amtIn = IERC20(swapInfo.tokenIn).balanceOf(address(this));
        IERC20(swapInfo.tokenIn).safeTransfer(swapHelper, amtIn); 
        IBaseSwapHelper(swapHelper).swap(swapInfo);
        uint amtOut = IERC20(swapInfo.tokenOut).balanceOf(address(this));
        if (swapInfo.swapType == SwapType.OpenExactIn) {
            IERC20(swapInfo.tokenOut).safeTransfer(marginPos.collPool, amtOut);
            emit SwapToIncreasePos(swapInfo.initPosId, swapInfo.tokenIn, swapInfo.tokenOut, amtIn, amtOut);
        } else {
            uint amtSwapped = amtIn;
            if (swapInfo.swapType == SwapType.CloseExactOut) {
                _require(IERC20(swapInfo.tokenOut).balanceOf(address(this)) == swapInfo.amtOut, Errors.SLIPPAGE_CONTROL);
                amtSwapped -= IERC20(swapInfo.tokenIn).balanceOf(address(this));
            }
            emit SwapToReducePos(swapInfo.initPosId, swapInfo.tokenIn, swapInfo.tokenOut, amtSwapped, amtOut);
        }
        result = abi.encode(amtOut);
    }
    function setQuoteAsset(address _tokenA, address _tokenB, address _quoteAsset) external onlyGovernor {
        _require(_tokenA != address(0) && _tokenB != address(0), Errors.ZERO_VALUE);
        _require(_quoteAsset == _tokenA || _quoteAsset == _tokenB, Errors.INVALID_INPUT);
        _require(_tokenA != _tokenB, Errors.NOT_SORTED_OR_DUPLICATED_INPUT);
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        __quoteAssets[token0][token1] = _quoteAsset;
    }
    function getBaseAssetAndQuoteAsset(address _tokenA, address _tokenB)
        public
        view
        returns (address baseAsset, address quoteAsset)
    {
        (address token0, address token1) = _tokenA < _tokenB ? (_tokenA, _tokenB) : (_tokenB, _tokenA);
        quoteAsset = __quoteAssets[token0][token1];
        _require(quoteAsset != address(0), Errors.ZERO_VALUE);
        baseAsset = quoteAsset == token0 ? token1 : token0;
    }
    function getOrder(uint _orderId) external view returns (Order memory) {
        return __orders[_orderId];
    }
    function getMarginPos(uint _initPosId) external view returns (MarginPos memory) {
        return __marginPositions[_initPosId];
    }
    function getPosOrdersLength(uint _initPosId) external view returns (uint) {
        return __posOrderIds[_initPosId].length;
    }
    function _createOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt,
        OrderType _orderType
    ) internal returns (uint orderId) {
        orderId = ++lastOrderId;
        _require(_collAmt != 0, Errors.ZERO_VALUE);
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos memory marginPos = __marginPositions[initPosId];
        _require(_tokenOut == marginPos.baseAsset || _tokenOut == marginPos.quoteAsset, Errors.INVALID_INPUT);
        uint collAmt = IPosManager(POS_MANAGER).getCollAmt(initPosId, marginPos.collPool);
        _require(_collAmt <= collAmt, Errors.INPUT_TOO_HIGH); 
        __orders[orderId] = (
            Order({
                initPosId: initPosId,
                triggerPrice_e36: _triggerPrice_e36,
                limitPrice_e36: _limitPrice_e36,
                collAmt: _collAmt,
                tokenOut: _tokenOut,
                orderType: _orderType,
                status: OrderStatus.Active,
                recipient: msg.sender
            })
        );
        __posOrderIds[initPosId].push(orderId);
        emit CreateOrder(initPosId, orderId, _tokenOut, _triggerPrice_e36, _limitPrice_e36, _collAmt, _orderType);
    }
    function updateOrder(
        uint _posId,
        uint _orderId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external {
        _require(_collAmt != 0, Errors.ZERO_VALUE);
        Order storage order = __orders[_orderId];
        _require(order.status == OrderStatus.Active, Errors.INVALID_INPUT);
        uint initPosId = initPosIds[msg.sender][_posId];
        _require(initPosId != 0, Errors.POSITION_NOT_FOUND);
        MarginPos memory marginPos = __marginPositions[initPosId];
        uint collAmt = IPosManager(POS_MANAGER).getCollAmt(initPosId, marginPos.collPool);
        _require(_collAmt <= collAmt, Errors.INPUT_TOO_HIGH);
        order.triggerPrice_e36 = _triggerPrice_e36;
        order.limitPrice_e36 = _limitPrice_e36;
        order.collAmt = _collAmt;
        order.tokenOut = _tokenOut;
        emit UpdateOrder(initPosId, _orderId, _tokenOut, _triggerPrice_e36, _limitPrice_e36, _collAmt);
    }
    function _calculateFillOrderInfo(Order memory _order, MarginPos memory _marginPos, address _collToken)
        internal
        returns (uint amtOut, uint repayShares, uint repayAmt)
    {
        (repayShares, repayAmt) = _calculateRepaySize(_order, _marginPos);
        uint collTokenAmt = ILendingPool(_marginPos.collPool).toAmtCurrent(_order.collAmt);
        if (_collToken == _order.tokenOut) {
            if (_marginPos.isLongBaseAsset) {
                amtOut = collTokenAmt - repayAmt * ONE_E36 / _order.limitPrice_e36;
            } else {
                amtOut = collTokenAmt - (repayAmt * _order.limitPrice_e36 / ONE_E36);
            }
        } else {
            if (_marginPos.isLongBaseAsset) {
                amtOut = (collTokenAmt * _order.limitPrice_e36).ceilDiv(ONE_E36) - repayAmt;
            } else {
                amtOut = (collTokenAmt * ONE_E36).ceilDiv(_order.limitPrice_e36) - repayAmt;
            }
        }
    }
    function _validateTriggerPrice(Order memory _order, MarginPos memory _marginPos) internal view {
        address oracle = IInitCore(CORE).oracle();
        uint markPrice_e36 = IInitOracle(oracle).getPrice_e36(_marginPos.baseAsset).mulDiv(
            ONE_E36, IInitOracle(oracle).getPrice_e36(_marginPos.quoteAsset)
        );
        (_order.orderType == OrderType.TakeProfit) == _marginPos.isLongBaseAsset
            ? _require(markPrice_e36 >= _order.triggerPrice_e36, Errors.INVALID_INPUT)
            : _require(markPrice_e36 <= _order.triggerPrice_e36, Errors.INVALID_INPUT);
    }
    function _calculateRepaySize(Order memory _order, MarginPos memory _marginPos)
        internal
        returns (uint repayAmt, uint repayShares)
    {
        uint totalCollAmt = IPosManager(POS_MANAGER).getCollAmt(_order.initPosId, _marginPos.collPool);
        if (_order.collAmt > totalCollAmt) _order.collAmt = totalCollAmt;
        uint totalDebtShares = IPosManager(POS_MANAGER).getPosDebtShares(_order.initPosId, _marginPos.borrPool);
        repayShares = totalDebtShares * _order.collAmt / totalCollAmt;
        repayAmt = ILendingPool(_marginPos.borrPool).debtShareToAmtCurrent(repayShares);
    }
    function _transmitTokenIn(address _tokenIn, uint _amt) internal {
        uint amtToTransfer = _amt;
        if (msg.value != 0) {
            _require(_tokenIn == WNATIVE, Errors.NOT_WNATIVE);
            amtToTransfer = _amt > msg.value ? amtToTransfer - msg.value : 0;
        }
        if (amtToTransfer != 0) IERC20(_tokenIn).safeTransferFrom(msg.sender, address(this), amtToTransfer);
    }
    function _transmitTokenOut(address _tokenOut, uint _amt, bool _returnNative) internal {
        if (_tokenOut != WNATIVE || !_returnNative) IERC20(_tokenOut).safeTransfer(msg.sender, _amt);
    }
    function _validateHealth(uint _initPosId, uint _minHealth_e18) internal returns (uint health_e18) {
        health_e18 = IInitCore(CORE).getPosHealthCurrent_e18(_initPosId);
        _require(health_e18 >= _minHealth_e18, Errors.SLIPPAGE_CONTROL);
    }
    function getPosOrderIds(uint _initPosId) external view returns (uint[] memory) {
        return __posOrderIds[_initPosId];
    }
}