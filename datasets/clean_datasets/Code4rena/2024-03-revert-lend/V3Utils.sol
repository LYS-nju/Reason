pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeCast.sol";
import "permit2/interfaces/IPermit2.sol";
import "../utils/Swapper.sol";
contract V3Utils is Swapper, IERC721Receiver {
    using SafeCast for uint256;
    IPermit2 public immutable permit2;
    event CompoundFees(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event ChangeRange(uint256 indexed tokenId, uint256 newTokenId);
    event WithdrawAndCollectAndSwap(uint256 indexed tokenId, address token, uint256 amount);
    event SwapAndMint(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event SwapAndIncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    constructor(
        INonfungiblePositionManager _nonfungiblePositionManager,
        address _zeroxRouter,
        address _universalRouter,
        address _permit2
    ) Swapper(_nonfungiblePositionManager, _zeroxRouter, _universalRouter) {
        permit2 = IPermit2(_permit2);
    }
    enum WhatToDo {
        CHANGE_RANGE,
        WITHDRAW_AND_COLLECT_AND_SWAP,
        COMPOUND_FEES
    }
    struct Instructions {
        WhatToDo whatToDo;
        address targetToken;
        uint256 amountRemoveMin0;
        uint256 amountRemoveMin1;
        uint256 amountIn0;
        uint256 amountOut0Min;
        bytes swapData0; 
        uint256 amountIn1;
        uint256 amountOut1Min;
        bytes swapData1; 
        uint128 feeAmount0;
        uint128 feeAmount1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 amountAddMin0;
        uint256 amountAddMin1;
        uint256 deadline;
        address recipient;
        address recipientNFT;
        bool unwrap;
        bytes returnData;
        bytes swapAndMintReturnData;
    }
    function executeWithPermit(uint256 tokenId, Instructions memory instructions, uint8 v, bytes32 r, bytes32 s)
        public
        returns (uint256 newTokenId)
    {
        if (nonfungiblePositionManager.ownerOf(tokenId) != msg.sender) {
            revert Unauthorized();
        }
        nonfungiblePositionManager.permit(address(this), tokenId, instructions.deadline, v, r, s);
        return execute(tokenId, instructions);
    }
    function execute(uint256 tokenId, Instructions memory instructions) public returns (uint256 newTokenId) {
        (,, address token0, address token1,,,, uint128 liquidity,,,,) = nonfungiblePositionManager.positions(tokenId);
        uint256 amount0;
        uint256 amount1;
        if (instructions.liquidity != 0) {
            (amount0, amount1) = _decreaseLiquidity(
                tokenId,
                instructions.liquidity,
                instructions.deadline,
                instructions.amountRemoveMin0,
                instructions.amountRemoveMin1
            );
        }
        (amount0, amount1) = _collectFees(
            tokenId,
            IERC20(token0),
            IERC20(token1),
            instructions.feeAmount0 == type(uint128).max
                ? type(uint128).max
                : (amount0 + instructions.feeAmount0).toUint128(),
            instructions.feeAmount1 == type(uint128).max
                ? type(uint128).max
                : (amount1 + instructions.feeAmount1).toUint128()
        );
        if (amount0 < instructions.amountIn0 || amount1 < instructions.amountIn1) {
            revert AmountError();
        }
        if (instructions.whatToDo == WhatToDo.COMPOUND_FEES) {
            if (instructions.targetToken == token0) {
                (liquidity, amount0, amount1) = _swapAndIncrease(
                    SwapAndIncreaseLiquidityParams(
                        tokenId,
                        amount0,
                        amount1,
                        instructions.recipient,
                        instructions.deadline,
                        IERC20(token1),
                        instructions.amountIn1,
                        instructions.amountOut1Min,
                        instructions.swapData1,
                        0,
                        0,
                        "",
                        instructions.amountAddMin0,
                        instructions.amountAddMin1,
                        ""
                    ),
                    IERC20(token0),
                    IERC20(token1),
                    instructions.unwrap
                );
            } else if (instructions.targetToken == token1) {
                (liquidity, amount0, amount1) = _swapAndIncrease(
                    SwapAndIncreaseLiquidityParams(
                        tokenId,
                        amount0,
                        amount1,
                        instructions.recipient,
                        instructions.deadline,
                        IERC20(token0),
                        0,
                        0,
                        "",
                        instructions.amountIn0,
                        instructions.amountOut0Min,
                        instructions.swapData0,
                        instructions.amountAddMin0,
                        instructions.amountAddMin1,
                        ""
                    ),
                    IERC20(token0),
                    IERC20(token1),
                    instructions.unwrap
                );
            } else {
                (liquidity, amount0, amount1) = _swapAndIncrease(
                    SwapAndIncreaseLiquidityParams(
                        tokenId,
                        amount0,
                        amount1,
                        instructions.recipient,
                        instructions.deadline,
                        IERC20(address(0)),
                        0,
                        0,
                        "",
                        0,
                        0,
                        "",
                        instructions.amountAddMin0,
                        instructions.amountAddMin1,
                        ""
                    ),
                    IERC20(token0),
                    IERC20(token1),
                    instructions.unwrap
                );
            }
            emit CompoundFees(tokenId, liquidity, amount0, amount1);
        } else if (instructions.whatToDo == WhatToDo.CHANGE_RANGE) {
            if (instructions.targetToken == token0) {
                (newTokenId,,,) = _swapAndMint(
                    SwapAndMintParams(
                        IERC20(token0),
                        IERC20(token1),
                        instructions.fee,
                        instructions.tickLower,
                        instructions.tickUpper,
                        amount0,
                        amount1,
                        instructions.recipient,
                        instructions.recipientNFT,
                        instructions.deadline,
                        IERC20(token1),
                        instructions.amountIn1,
                        instructions.amountOut1Min,
                        instructions.swapData1,
                        0,
                        0,
                        "",
                        instructions.amountAddMin0,
                        instructions.amountAddMin1,
                        instructions.swapAndMintReturnData,
                        ""
                    ),
                    instructions.unwrap
                );
            } else if (instructions.targetToken == token1) {
                (newTokenId,,,) = _swapAndMint(
                    SwapAndMintParams(
                        IERC20(token0),
                        IERC20(token1),
                        instructions.fee,
                        instructions.tickLower,
                        instructions.tickUpper,
                        amount0,
                        amount1,
                        instructions.recipient,
                        instructions.recipientNFT,
                        instructions.deadline,
                        IERC20(token0),
                        0,
                        0,
                        "",
                        instructions.amountIn0,
                        instructions.amountOut0Min,
                        instructions.swapData0,
                        instructions.amountAddMin0,
                        instructions.amountAddMin1,
                        instructions.swapAndMintReturnData,
                        ""
                    ),
                    instructions.unwrap
                );
            } else {
                (newTokenId,,,) = _swapAndMint(
                    SwapAndMintParams(
                        IERC20(token0),
                        IERC20(token1),
                        instructions.fee,
                        instructions.tickLower,
                        instructions.tickUpper,
                        amount0,
                        amount1,
                        instructions.recipient,
                        instructions.recipientNFT,
                        instructions.deadline,
                        IERC20(address(0)),
                        0,
                        0,
                        "",
                        0,
                        0,
                        "",
                        instructions.amountAddMin0,
                        instructions.amountAddMin1,
                        instructions.swapAndMintReturnData,
                        ""
                    ),
                    instructions.unwrap
                );
            }
            emit ChangeRange(tokenId, newTokenId);
        } else if (instructions.whatToDo == WhatToDo.WITHDRAW_AND_COLLECT_AND_SWAP) {
            uint256 targetAmount;
            if (token0 != instructions.targetToken) {
                (uint256 amountInDelta, uint256 amountOutDelta) = _routerSwap(
                    Swapper.RouterSwapParams(
                        IERC20(token0),
                        IERC20(instructions.targetToken),
                        amount0,
                        instructions.amountOut0Min,
                        instructions.swapData0
                    )
                );
                if (amountInDelta < amount0) {
                    _transferToken(instructions.recipient, IERC20(token0), amount0 - amountInDelta, instructions.unwrap);
                }
                targetAmount += amountOutDelta;
            } else {
                targetAmount += amount0;
            }
            if (token1 != instructions.targetToken) {
                (uint256 amountInDelta, uint256 amountOutDelta) = _routerSwap(
                    Swapper.RouterSwapParams(
                        IERC20(token1),
                        IERC20(instructions.targetToken),
                        amount1,
                        instructions.amountOut1Min,
                        instructions.swapData1
                    )
                );
                if (amountInDelta < amount1) {
                    _transferToken(instructions.recipient, IERC20(token1), amount1 - amountInDelta, instructions.unwrap);
                }
                targetAmount += amountOutDelta;
            } else {
                targetAmount += amount1;
            }
            if (targetAmount != 0 && instructions.targetToken != address(0)) {
                _transferToken(
                    instructions.recipient, IERC20(instructions.targetToken), targetAmount, instructions.unwrap
                );
            }
            emit WithdrawAndCollectAndSwap(tokenId, instructions.targetToken, targetAmount);
        } else {
            revert NotSupportedWhatToDo();
        }
    }
    function onERC721Received(address, address from, uint256 tokenId, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        if (msg.sender != address(nonfungiblePositionManager)) {
            revert WrongContract();
        }
        if (from == address(this)) {
            revert SelfSend();
        }
        Instructions memory instructions = abi.decode(data, (Instructions));
        execute(tokenId, instructions);
        nonfungiblePositionManager.safeTransferFrom(address(this), from, tokenId, instructions.returnData);
        return IERC721Receiver.onERC721Received.selector;
    }
    struct SwapParams {
        IERC20 tokenIn;
        IERC20 tokenOut;
        uint256 amountIn;
        uint256 minAmountOut;
        address recipient; 
        bytes swapData;
        bool unwrap; 
        bytes permitData; 
    }
    function swap(SwapParams calldata params) external payable returns (uint256 amountOut) {
        if (params.tokenIn == params.tokenOut) {
            revert SameToken();
        }
        if (params.permitData.length > 0) {
            (ISignatureTransfer.PermitBatchTransferFrom memory pbtf, bytes memory signature) =
                abi.decode(params.permitData, (ISignatureTransfer.PermitBatchTransferFrom, bytes));
            _prepareAddPermit2(
                params.tokenIn, IERC20(address(0)), IERC20(address(0)), params.amountIn, 0, 0, pbtf, signature
            );
        } else {
            _prepareAddApproved(params.tokenIn, IERC20(address(0)), IERC20(address(0)), params.amountIn, 0, 0);
        }
        uint256 amountInDelta;
        (amountInDelta, amountOut) = _routerSwap(
            Swapper.RouterSwapParams(
                params.tokenIn, params.tokenOut, params.amountIn, params.minAmountOut, params.swapData
            )
        );
        if (amountOut != 0) {
            _transferToken(params.recipient, params.tokenOut, amountOut, params.unwrap);
        }
        uint256 leftOver = params.amountIn - amountInDelta;
        if (leftOver != 0) {
            _transferToken(params.recipient, params.tokenIn, leftOver, params.unwrap);
        }
    }
    struct SwapAndMintParams {
        IERC20 token0;
        IERC20 token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0;
        uint256 amount1;
        address recipient; 
        address recipientNFT; 
        uint256 deadline;
        IERC20 swapSourceToken;
        uint256 amountIn0;
        uint256 amountOut0Min;
        bytes swapData0;
        uint256 amountIn1;
        uint256 amountOut1Min;
        bytes swapData1;
        uint256 amountAddMin0;
        uint256 amountAddMin1;
        bytes returnData;
        bytes permitData;
    }
    function swapAndMint(SwapAndMintParams calldata params)
        external
        payable
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        if (params.token0 == params.token1) {
            revert SameToken();
        }
        if (params.permitData.length > 0) {
            (ISignatureTransfer.PermitBatchTransferFrom memory pbtf, bytes memory signature) =
                abi.decode(params.permitData, (ISignatureTransfer.PermitBatchTransferFrom, bytes));
            _prepareAddPermit2(
                params.token0,
                params.token1,
                params.swapSourceToken,
                params.amount0,
                params.amount1,
                params.amountIn0 + params.amountIn1,
                pbtf,
                signature
            );
        } else {
            _prepareAddApproved(
                params.token0,
                params.token1,
                params.swapSourceToken,
                params.amount0,
                params.amount1,
                params.amountIn0 + params.amountIn1
            );
        }
        (tokenId, liquidity, amount0, amount1) = _swapAndMint(params, msg.value != 0);
    }
    struct SwapAndIncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0;
        uint256 amount1;
        address recipient; 
        uint256 deadline;
        IERC20 swapSourceToken;
        uint256 amountIn0;
        uint256 amountOut0Min;
        bytes swapData0;
        uint256 amountIn1;
        uint256 amountOut1Min;
        bytes swapData1;
        uint256 amountAddMin0;
        uint256 amountAddMin1;
        bytes permitData;
    }
    function swapAndIncreaseLiquidity(SwapAndIncreaseLiquidityParams calldata params)
        external
        payable
        returns (uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        (,, address token0, address token1,,,,,,,,) = nonfungiblePositionManager.positions(params.tokenId);
        if (params.permitData.length > 0) {
            (ISignatureTransfer.PermitBatchTransferFrom memory pbtf, bytes memory signature) =
                abi.decode(params.permitData, (ISignatureTransfer.PermitBatchTransferFrom, bytes));
            _prepareAddPermit2(
                IERC20(token0),
                IERC20(token1),
                params.swapSourceToken,
                params.amount0,
                params.amount1,
                params.amountIn0 + params.amountIn1,
                pbtf,
                signature
            );
        } else {
            _prepareAddApproved(
                IERC20(token0),
                IERC20(token1),
                params.swapSourceToken,
                params.amount0,
                params.amount1,
                params.amountIn0 + params.amountIn1
            );
        }
        (liquidity, amount0, amount1) = _swapAndIncrease(params, IERC20(token0), IERC20(token1), msg.value != 0);
    }
    function _prepareAddApproved(
        IERC20 token0,
        IERC20 token1,
        IERC20 otherToken,
        uint256 amount0,
        uint256 amount1,
        uint256 amountOther
    ) internal {
        (uint256 needed0, uint256 needed1, uint256 neededOther) =
            _prepareAdd(token0, token1, otherToken, amount0, amount1, amountOther);
        if (needed0 > 0) {
            SafeERC20.safeTransferFrom(token0, msg.sender, address(this), needed0);
        }
        if (needed1 > 0) {
            SafeERC20.safeTransferFrom(token1, msg.sender, address(this), needed1);
        }
        if (neededOther > 0) {
            SafeERC20.safeTransferFrom(otherToken, msg.sender, address(this), neededOther);
        }
    }
    struct PrepareAddPermit2State {
        uint256 needed0;
        uint256 needed1;
        uint256 neededOther;
        uint256 i;
        uint256 balanceBefore0;
        uint256 balanceBefore1;
        uint256 balanceBeforeOther;
    }
    function _prepareAddPermit2(
        IERC20 token0,
        IERC20 token1,
        IERC20 otherToken,
        uint256 amount0,
        uint256 amount1,
        uint256 amountOther,
        IPermit2.PermitBatchTransferFrom memory permit,
        bytes memory signature
    ) internal {
        PrepareAddPermit2State memory state;
        (state.needed0, state.needed1, state.neededOther) =
            _prepareAdd(token0, token1, otherToken, amount0, amount1, amountOther);
        ISignatureTransfer.SignatureTransferDetails[] memory transferDetails =
            new ISignatureTransfer.SignatureTransferDetails[](permit.permitted.length);
        if (state.needed0 > 0) {
            state.balanceBefore0 = token0.balanceOf(address(this));
            transferDetails[state.i++] = ISignatureTransfer.SignatureTransferDetails(address(this), state.needed0);
        }
        if (state.needed1 > 0) {
            state.balanceBefore1 = token1.balanceOf(address(this));
            transferDetails[state.i++] = ISignatureTransfer.SignatureTransferDetails(address(this), state.needed1);
        }
        if (state.neededOther > 0) {
            state.balanceBeforeOther = otherToken.balanceOf(address(this));
            transferDetails[state.i++] = ISignatureTransfer.SignatureTransferDetails(address(this), state.neededOther);
        }
        permit2.permitTransferFrom(permit, transferDetails, msg.sender, signature);
        if (state.needed0 > 0) {
            if (token0.balanceOf(address(this)) - state.balanceBefore0 != state.needed0) {
                revert TransferError(); 
            }
        }
        if (state.needed1 > 0) {
            if (token1.balanceOf(address(this)) - state.balanceBefore1 != state.needed1) {
                revert TransferError(); 
            }
        }
        if (state.neededOther > 0) {
            if (otherToken.balanceOf(address(this)) - state.balanceBeforeOther != state.neededOther) {
                revert TransferError(); 
            }
        }
    }
    function _prepareAdd(
        IERC20 token0,
        IERC20 token1,
        IERC20 otherToken,
        uint256 amount0,
        uint256 amount1,
        uint256 amountOther
    ) internal returns (uint256 needed0, uint256 needed1, uint256 neededOther) {
        uint256 amountAdded0;
        uint256 amountAdded1;
        uint256 amountAddedOther;
        if (msg.value != 0) {
            weth.deposit{value: msg.value}();
            if (address(weth) == address(token0)) {
                amountAdded0 = msg.value;
                if (amountAdded0 > amount0) {
                    revert TooMuchEtherSent();
                }
            } else if (address(weth) == address(token1)) {
                amountAdded1 = msg.value;
                if (amountAdded1 > amount1) {
                    revert TooMuchEtherSent();
                }
            } else if (address(weth) == address(otherToken)) {
                amountAddedOther = msg.value;
                if (amountAddedOther > amountOther) {
                    revert TooMuchEtherSent();
                }
            } else {
                revert NoEtherToken();
            }
        }
        if (amount0 > amountAdded0) {
            needed0 = amount0 - amountAdded0;
        }
        if (amount1 > amountAdded1) {
            needed1 = amount1 - amountAdded1;
        }
        if (
            amountOther > amountAddedOther && address(otherToken) != address(0) && token0 != otherToken
                && token1 != otherToken
        ) {
            neededOther = amountOther - amountAddedOther;
        }
    }
    function _swapAndMint(SwapAndMintParams memory params, bool unwrap)
        internal
        returns (uint256 tokenId, uint128 liquidity, uint256 added0, uint256 added1)
    {
        (uint256 total0, uint256 total1) = _swapAndPrepareAmounts(params, unwrap);
        INonfungiblePositionManager.MintParams memory mintParams = INonfungiblePositionManager.MintParams(
            address(params.token0),
            address(params.token1),
            params.fee,
            params.tickLower,
            params.tickUpper,
            total0,
            total1,
            params.amountAddMin0,
            params.amountAddMin1,
            address(this), 
            params.deadline
        );
        (tokenId, liquidity, added0, added1) = nonfungiblePositionManager.mint(mintParams);
        nonfungiblePositionManager.safeTransferFrom(address(this), params.recipientNFT, tokenId, params.returnData);
        emit SwapAndMint(tokenId, liquidity, added0, added1);
        _returnLeftoverTokens(params.recipient, params.token0, params.token1, total0, total1, added0, added1, unwrap);
    }
    function _swapAndIncrease(SwapAndIncreaseLiquidityParams memory params, IERC20 token0, IERC20 token1, bool unwrap)
        internal
        returns (uint128 liquidity, uint256 added0, uint256 added1)
    {
        (uint256 total0, uint256 total1) = _swapAndPrepareAmounts(
            SwapAndMintParams(
                token0,
                token1,
                0,
                0,
                0,
                params.amount0,
                params.amount1,
                params.recipient,
                params.recipient,
                params.deadline,
                params.swapSourceToken,
                params.amountIn0,
                params.amountOut0Min,
                params.swapData0,
                params.amountIn1,
                params.amountOut1Min,
                params.swapData1,
                params.amountAddMin0,
                params.amountAddMin1,
                "",
                params.permitData
            ),
            unwrap
        );
        INonfungiblePositionManager.IncreaseLiquidityParams memory increaseLiquidityParams = INonfungiblePositionManager
            .IncreaseLiquidityParams(
            params.tokenId, total0, total1, params.amountAddMin0, params.amountAddMin1, params.deadline
        );
        (liquidity, added0, added1) = nonfungiblePositionManager.increaseLiquidity(increaseLiquidityParams);
        emit SwapAndIncreaseLiquidity(params.tokenId, liquidity, added0, added1);
        _returnLeftoverTokens(params.recipient, token0, token1, total0, total1, added0, added1, unwrap);
    }
    function _swapAndPrepareAmounts(SwapAndMintParams memory params, bool unwrap)
        internal
        returns (uint256 total0, uint256 total1)
    {
        if (params.swapSourceToken == params.token0) {
            if (params.amount0 < params.amountIn1) {
                revert AmountError();
            }
            (uint256 amountInDelta, uint256 amountOutDelta) = _routerSwap(
                Swapper.RouterSwapParams(
                    params.token0, params.token1, params.amountIn1, params.amountOut1Min, params.swapData1
                )
            );
            total0 = params.amount0 - amountInDelta;
            total1 = params.amount1 + amountOutDelta;
        } else if (params.swapSourceToken == params.token1) {
            if (params.amount1 < params.amountIn0) {
                revert AmountError();
            }
            (uint256 amountInDelta, uint256 amountOutDelta) = _routerSwap(
                Swapper.RouterSwapParams(
                    params.token1, params.token0, params.amountIn0, params.amountOut0Min, params.swapData0
                )
            );
            total1 = params.amount1 - amountInDelta;
            total0 = params.amount0 + amountOutDelta;
        } else if (address(params.swapSourceToken) != address(0)) {
            (uint256 amountInDelta0, uint256 amountOutDelta0) = _routerSwap(
                Swapper.RouterSwapParams(
                    params.swapSourceToken, params.token0, params.amountIn0, params.amountOut0Min, params.swapData0
                )
            );
            (uint256 amountInDelta1, uint256 amountOutDelta1) = _routerSwap(
                Swapper.RouterSwapParams(
                    params.swapSourceToken, params.token1, params.amountIn1, params.amountOut1Min, params.swapData1
                )
            );
            total0 = params.amount0 + amountOutDelta0;
            total1 = params.amount1 + amountOutDelta1;
            uint256 leftOver = params.amountIn0 + params.amountIn1 - amountInDelta0 - amountInDelta1;
            if (leftOver != 0) {
                _transferToken(params.recipient, params.swapSourceToken, leftOver, unwrap);
            }
        } else {
            total0 = params.amount0;
            total1 = params.amount1;
        }
        if (total0 != 0) {
            SafeERC20.safeApprove(params.token0, address(nonfungiblePositionManager), 0);
            SafeERC20.safeApprove(params.token0, address(nonfungiblePositionManager), total0);
        }
        if (total1 != 0) {
            SafeERC20.safeApprove(params.token1, address(nonfungiblePositionManager), 0);
            SafeERC20.safeApprove(params.token1, address(nonfungiblePositionManager), total1);
        }
    }
    function _returnLeftoverTokens(
        address to,
        IERC20 token0,
        IERC20 token1,
        uint256 total0,
        uint256 total1,
        uint256 added0,
        uint256 added1,
        bool unwrap
    ) internal {
        uint256 left0 = total0 - added0;
        uint256 left1 = total1 - added1;
        if (left0 != 0) {
            _transferToken(to, token0, left0, unwrap);
        }
        if (left1 != 0) {
            _transferToken(to, token1, left1, unwrap);
        }
    }
    function _transferToken(address to, IERC20 token, uint256 amount, bool unwrap) internal {
        if (address(weth) == address(token) && unwrap) {
            weth.withdraw(amount);
            (bool sent,) = to.call{value: amount}("");
            if (!sent) {
                revert EtherSendFailed();
            }
        } else {
            SafeERC20.safeTransfer(token, to, amount);
        }
    }
    function _decreaseLiquidity(
        uint256 tokenId,
        uint128 liquidity,
        uint256 deadline,
        uint256 token0Min,
        uint256 token1Min
    ) internal returns (uint256 amount0, uint256 amount1) {
        if (liquidity != 0) {
            (amount0, amount1) = nonfungiblePositionManager.decreaseLiquidity(
                INonfungiblePositionManager.DecreaseLiquidityParams(tokenId, liquidity, token0Min, token1Min, deadline)
            );
        }
    }
    function _collectFees(uint256 tokenId, IERC20 token0, IERC20 token1, uint128 collectAmount0, uint128 collectAmount1)
        internal
        returns (uint256 amount0, uint256 amount1)
    {
        uint256 balanceBefore0 = token0.balanceOf(address(this));
        uint256 balanceBefore1 = token1.balanceOf(address(this));
        (amount0, amount1) = nonfungiblePositionManager.collect(
            INonfungiblePositionManager.CollectParams(tokenId, address(this), collectAmount0, collectAmount1)
        );
        uint256 balanceAfter0 = token0.balanceOf(address(this));
        uint256 balanceAfter1 = token1.balanceOf(address(this));
        if (balanceAfter0 - balanceBefore0 != amount0) {
            revert CollectError();
        }
        if (balanceAfter1 - balanceBefore1 != amount1) {
            revert CollectError();
        }
    }
    receive() external payable {
        if (msg.sender != address(weth)) {
            revert NotWETH();
        }
    }
}