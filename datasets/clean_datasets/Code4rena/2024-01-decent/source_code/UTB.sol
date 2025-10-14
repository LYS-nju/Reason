pragma solidity ^0.8.20;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract Owned {
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    address public owner;
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }
    constructor(address _owner) {
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
struct SwapInstructions {
    uint8 swapperId;
    bytes swapPayload;
}
struct FeeStructure {
    uint bridgeFee;
    address feeToken;
    uint feeAmount;
}
struct SwapAndExecuteInstructions {
    SwapInstructions swapInstructions;
    address target;
    address paymentOperator;
    address payable refund;
    bytes payload;
}
struct BridgeInstructions {
    SwapInstructions preBridge;
    SwapInstructions postBridge;
    uint8 bridgeId;
    uint256 dstChainId;
    address target;
    address paymentOperator;
    address payable refund;
    bytes payload;
    bytes additionalArgs;
}
interface IUTBExecutor {
    function execute(
        address target,
        address paymentOperator,
        bytes memory payload,
        address token,
        uint256 amount,
        address refund
    ) external payable;
    function execute(
        address target,
        address paymentOperator,
        bytes memory payload,
        address token,
        uint256 amount,
        address refund,
        uint256 extraNative
    ) external;
}
library SwapDirection {
    uint8 constant EXACT_IN = 0;
    uint8 constant EXACT_OUT = 1;
}
struct SwapParams {
    uint256 amountIn;
    uint256 amountOut;
    address tokenIn;
    address tokenOut;
    uint8 direction;
    bytes path;
}
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}
interface IBridgeAdapter {
    function getId() external returns (uint8);
    function getBridgeToken(
        bytes calldata additionalArgs
    ) external returns (address);
    function getBridgedAmount(
        uint256 amt2Bridge,
        address preBridgeToken,
        address postBridgeToken
    ) external returns (uint256);
    function bridge(
        uint256 amt2Bridge,
        SwapInstructions memory postBridge,
        uint256 dstChainId,
        address target,
        address paymentOperator,
        bytes memory payload,
        bytes calldata additionalArgs,
        address payable refund
    ) external payable returns (bytes memory);
}
interface IUTBFeeCollector {
    function collectFees(
      FeeStructure memory fees,
      bytes memory packedInfo,
      bytes memory signature
    ) external payable;
    function redeemFees(address token, uint256 amount) external;
    function setSigner(address _signer) external;
    function setUtb(address _utb) external;
}
interface ISwapper {
    function getId() external returns (uint8);
    function swap(
        bytes memory swapPayload
    ) external returns (address tokenOut, uint256 amountOut);
    function updateSwapParams(
        SwapParams memory newSwapParams,
        bytes memory payload
    ) external returns (bytes memory);
}
contract UTB is Owned {
    constructor() Owned(msg.sender) {}
    IUTBExecutor executor;
    IUTBFeeCollector feeCollector;
    IWETH wrapped;
    mapping(uint8 => address) public swappers;
    mapping(uint8 => address) public bridgeAdapters;
    function setExecutor(address _executor) public onlyOwner {
        executor = IUTBExecutor(_executor);
    }
    function setWrapped(address payable _wrapped) public onlyOwner {
        wrapped = IWETH(_wrapped);
    }
    function setFeeCollector(address payable _feeCollector) public onlyOwner {
        feeCollector = IUTBFeeCollector(_feeCollector);
    }
    function performSwap(
        SwapInstructions memory swapInstructions
    ) private returns (address tokenOut, uint256 amountOut) {
        return performSwap(swapInstructions, true);
    }
    function performSwap(
        SwapInstructions memory swapInstructions,
        bool retrieveTokenIn
    ) private returns (address tokenOut, uint256 amountOut) {
        ISwapper swapper = ISwapper(swappers[swapInstructions.swapperId]);
        SwapParams memory swapParams = abi.decode(
            swapInstructions.swapPayload,
            (SwapParams)
        );
        if (swapParams.tokenIn == address(0)) {
            require(msg.value >= swapParams.amountIn, "not enough native");
            wrapped.deposit{value: swapParams.amountIn}();
            swapParams.tokenIn = address(wrapped);
            swapInstructions.swapPayload = swapper.updateSwapParams(
                swapParams,
                swapInstructions.swapPayload
            );
        } else if (retrieveTokenIn) {
            IERC20(swapParams.tokenIn).transferFrom(
                msg.sender,
                address(this),
                swapParams.amountIn
            );
        }
        IERC20(swapParams.tokenIn).approve(
            address(swapper),
            swapParams.amountIn
        );
        (tokenOut, amountOut) = swapper.swap(swapInstructions.swapPayload);
        if (tokenOut == address(0)) {
            wrapped.withdraw(amountOut);
        }
    }
    function swapAndExecute(
        SwapAndExecuteInstructions calldata instructions,
        FeeStructure calldata fees,
        bytes calldata signature
    )
        public
        payable
        retrieveAndCollectFees(fees, abi.encode(instructions, fees), signature)
    {
        _swapAndExecute(
            instructions.swapInstructions,
            instructions.target,
            instructions.paymentOperator,
            instructions.payload,
            instructions.refund
        );
    }
    function _swapAndExecute(
        SwapInstructions memory swapInstructions,
        address target,
        address paymentOperator,
        bytes memory payload,
        address payable refund
    ) private {
        (address tokenOut, uint256 amountOut) = performSwap(swapInstructions);
        if (tokenOut == address(0)) {
            executor.execute{value: amountOut}(
                target,
                paymentOperator,
                payload,
                tokenOut,
                amountOut,
                refund
            );
        } else {
            IERC20(tokenOut).approve(address(executor), amountOut);
            executor.execute(
                target,
                paymentOperator,
                payload,
                tokenOut,
                amountOut,
                refund
            );
        }
    }
    function swapAndModifyPostBridge(
        BridgeInstructions memory instructions
    )
        private
        returns (
            uint256 amount2Bridge,
            BridgeInstructions memory updatedInstructions
        )
    {
        (address tokenOut, uint256 amountOut) = performSwap(
            instructions.preBridge
        );
        SwapParams memory newPostSwapParams = abi.decode(
            instructions.postBridge.swapPayload,
            (SwapParams)
        );
        newPostSwapParams.amountIn = IBridgeAdapter(
            bridgeAdapters[instructions.bridgeId]
        ).getBridgedAmount(amountOut, tokenOut, newPostSwapParams.tokenIn);
        updatedInstructions = instructions;
        updatedInstructions.postBridge.swapPayload = ISwapper(swappers[
            instructions.postBridge.swapperId
        ]).updateSwapParams(
            newPostSwapParams,
            instructions.postBridge.swapPayload
        );
        amount2Bridge = amountOut;
    }
    function approveAndCheckIfNative(
        BridgeInstructions memory instructions,
        uint256 amt2Bridge
    ) private returns (bool) {
        IBridgeAdapter bridgeAdapter = IBridgeAdapter(bridgeAdapters[instructions.bridgeId]);
        address bridgeToken = bridgeAdapter.getBridgeToken(
            instructions.additionalArgs
        );
        if (bridgeToken != address(0)) {
            IERC20(bridgeToken).approve(address(bridgeAdapter), amt2Bridge);
            return false;
        }
        return true;
    }
    modifier retrieveAndCollectFees(
        FeeStructure calldata fees,
        bytes memory packedInfo,
        bytes calldata signature
    ) {
        if (address(feeCollector) != address(0)) {
            uint value = 0;
            if (fees.feeToken != address(0)) {
                IERC20(fees.feeToken).transferFrom(
                    msg.sender,
                    address(this),
                    fees.feeAmount
                );
                IERC20(fees.feeToken).approve(
                    address(feeCollector),
                    fees.feeAmount
                );
            } else {
                value = fees.feeAmount;
            }
            feeCollector.collectFees{value: value}(fees, packedInfo, signature);
        }
        _;
    }
    function bridgeAndExecute(
        BridgeInstructions calldata instructions,
        FeeStructure calldata fees,
        bytes calldata signature
    )
        public
        payable
        retrieveAndCollectFees(fees, abi.encode(instructions, fees), signature)
        returns (bytes memory)
    {
        (
            uint256 amt2Bridge,
            BridgeInstructions memory updatedInstructions
        ) = swapAndModifyPostBridge(instructions);
        return callBridge(amt2Bridge, fees.bridgeFee, updatedInstructions);
    }
    function callBridge(
        uint256 amt2Bridge,
        uint bridgeFee,
        BridgeInstructions memory instructions
    ) private returns (bytes memory) {
        bool native = approveAndCheckIfNative(instructions, amt2Bridge);
        return
            IBridgeAdapter(bridgeAdapters[instructions.bridgeId]).bridge{
                value: bridgeFee + (native ? amt2Bridge : 0)
            }(
                amt2Bridge,
                instructions.postBridge,
                instructions.dstChainId,
                instructions.target,
                instructions.paymentOperator,
                instructions.payload,
                instructions.additionalArgs,
                instructions.refund
            );
    }
    function receiveFromBridge(
        SwapInstructions memory postBridge,
        address target,
        address paymentOperator,
        bytes memory payload,
        address payable refund
    ) public {
        _swapAndExecute(postBridge, target, paymentOperator, payload, refund);
    }
    function registerSwapper(address swapper) public onlyOwner {
        ISwapper s = ISwapper(swapper);
        swappers[s.getId()] = swapper;
    }
    function registerBridge(address bridge) public onlyOwner {
        IBridgeAdapter b = IBridgeAdapter(bridge);
        bridgeAdapters[b.getId()] = bridge;
    }
    receive() external payable {}
    fallback() external payable {}
}