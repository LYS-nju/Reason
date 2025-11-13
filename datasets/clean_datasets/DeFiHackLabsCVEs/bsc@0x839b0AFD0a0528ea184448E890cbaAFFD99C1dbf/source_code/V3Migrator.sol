pragma solidity 0.8.16;
interface IBiswapFactoryV3 {
    event NewPool(
        address indexed tokenX,
        address indexed tokenY,
        uint16 indexed fee,
        uint24 pointDelta,
        address pool
    );
    event NewFeeEnabled(uint16 fee, uint24 pointDelta);
    event FeeDeltaChanged(uint16 fee, uint16 oldDelta, uint16 newDelta);
    event NewDiscountSetter(address newDiscountSetter);
    event NewFarmsContract(address newFarmsContract);
    event NewFarmsRatio(address pool, uint ratio);
    event SetDiscounts(DiscountStr[] discounts);
    struct DiscountStr {
        address user;
        address pool;
        uint16 discount;
    }
    struct Addresses {
        address swapX2YModule;
        address  swapY2XModule;
        address  liquidityModule;
        address  limitOrderModule;
        address  flashModule;
    }
    function addresses() external returns(
        address swapX2YModule,
        address swapY2XModule,
        address liquidityModule,
        address limitOrderModule,
        address flashModule
    );
    function setDiscount(DiscountStr[] calldata discounts) external;
    function setFarmsRatio(address _pool, uint256 ratio) external;
    function defaultFeeChargePercent() external returns (uint24);
    function enableFeeAmount(uint16 fee, uint24 pointDelta) external;
    function newPool(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint
    ) external returns (address);
    function chargeReceiver() external view returns(address);
    function pool(
        address tokenX,
        address tokenY,
        uint16 fee
    ) external view returns(address);
    function farmsRatio(address _pool) external view returns(uint256 farmRatio);
    function farmsContract() external view returns(address);
    function fee2pointDelta(uint16 fee) external view returns (int24 pointDelta);
    function fee2DeltaFee(uint16 fee) external view returns (uint16 deltaFee);
    function modifyChargeReceiver(address _chargeReceiver) external;
    function modifyDefaultFeeChargePercent(uint24 _defaultFeeChargePercent) external;
    function getFeeRange(uint16 fee) external view returns(uint16 lowFee, uint16 highFee);
    function setFeeDelta(uint16 fee, uint16 delta) external;
    function setDiscountSetter(address newDiscountSetter) external;
    function setFarmsContract(address newFarmsContract) external;
    function feeDiscount(address user, address _pool) external returns(uint16 discount);
    function deployPoolParams() external view returns(
        address tokenX,
        address tokenY,
        uint16 fee,
        int24 currentPoint,
        int24 pointDelta,
        uint24 feeChargePercent
    );
    function checkFeeInRange(uint16 fee, uint16 initFee) external view returns(bool);
    function INIT_CODE_HASH() external pure returns(bytes32);
}
interface IBiswapPair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);
    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;
    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);
    function swapFee() external view returns (uint32);
    function devFee() external view returns (uint32);
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
    function setSwapFee(uint32) external;
    function setDevFee(uint32) external;
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
interface ILiquidityManager is IERC721Enumerable {
    event AddLiquidity(
        uint256 indexed nftId,
        address pool,
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );
    event DecLiquidity(
        uint256 indexed nftId,
        address pool,
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );
    event SetBonusPoolManager(address _bonusPoolManager);
    event HookError(address receiver,  bytes returnData);
    struct MintParam {
        address miner;
        address tokenX;
        address tokenY;
        uint16 fee;
        int24 pl;
        int24 pr;
        uint128 xLim;
        uint128 yLim;
        uint128 amountXMin;
        uint128 amountYMin;
        uint256 deadline;
    }
    struct AddLiquidityParam {
        uint256 lid;
        uint128 xLim;
        uint128 yLim;
        uint128 amountXMin;
        uint128 amountYMin;
        uint256 deadline;
    }
    struct PoolMeta {
        address tokenX;
        uint16 fee;
        address tokenY;
        address pool;
    }
    struct Liquidity {
        int24 leftPt;
        int24 rightPt;
        uint16 feeVote;
        uint128 liquidity;
        uint256 lastFeeScaleX_128;
        uint256 lastFeeScaleY_128;
        uint256 lastFPScale_128;
        uint256 remainTokenX;
        uint256 remainTokenY;
        uint256 fpOwed;
        uint128 poolId;
    }
    struct MintCallbackData {
        address tokenX;
        address tokenY;
        uint16 fee;
        address payer;
    }
    function mint(MintParam calldata mintParam) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );
    function mintWithFeeVote(MintParam calldata mintParam, uint16 feeVote) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );
    function burn(uint256 lid) external returns (bool success);
    function addLiquidity(
        AddLiquidityParam calldata addLiquidityParam
    ) external payable returns (
        uint128 liquidityDelta,
        uint256 amountX,
        uint256 amountY
    );
    function decLiquidity(
        uint256 lid,
        uint128 liquidDelta,
        uint256 amountXMin,
        uint256 amountYMin,
        uint256 deadline
    ) external returns (
        uint256 amountX,
        uint256 amountY
    );
    function changeFeeVote(uint256 lid, uint16 newFeeVote) external;
    function liquidities(uint256 lid) external view returns(
        int24 leftPt,
        int24 rightPt,
        uint16 feeVote,
        uint128 liquidity,
        uint256 lastFeeScaleX_128,
        uint256 lastFeeScaleY_128,
        uint256 lastFPScale_128,
        uint256 remainTokenX,
        uint256 remainTokenY,
        uint256 fpOwed,
        uint128 poolId
    );
    function poolMetas(uint128 poolId) external view returns(
        address tokenX,
        uint16 fee,
        address tokenY,
        address pool
    );
    function collect(
        address recipient,
        uint256 lid,
        uint128 amountXLim,
        uint128 amountYLim
    ) external payable returns (
        uint256 amountX,
        uint256 amountY
    );
    function updateFpOwed(uint256 lid) external;
    function setBonusPoolManager(address _bonusPoolManager) external;
}
interface IV3Migrator {
    struct MigrateParams {
        address pair; 
        uint256 liquidityToMigrate; 
        address token0;
        address token1;
        uint16 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 amount0Min; 
        uint128 amount1Min; 
        address recipient;
        uint256 deadline;
        bool refundAsETH;
    }
    function migrate(MigrateParams calldata params) external returns(uint refund0, uint refund1);
    function mint(ILiquidityManager.MintParam calldata mintParam) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    );
}
interface IWETH9 is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
}
abstract contract Base {
    address public immutable factory;
    address public immutable WETH9;
    bytes32  public immutable INIT_CODE_HASH;
    modifier checkDeadline(uint256 deadline) {
        require(block.timestamp <= deadline, 'Out of time');
        _;
    }
    receive() external payable {}
    constructor(address _factory, address _WETH9) {
        factory = _factory;
        WETH9 = _WETH9;
        INIT_CODE_HASH = IBiswapFactoryV3(_factory).INIT_CODE_HASH();
    }
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            (bool success, bytes memory result) = address(this).delegatecall(data[i]);
            if (!success) {
                if (result.length < 68) revert();
                assembly {
                    result := add(result, 0x04)
                }
                revert(abi.decode(result, (string)));
            }
            results[i] = result;
        }
    }
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
        token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }
    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
    function unwrapWETH9(uint256 minAmount, address recipient) external payable {
        uint256 all = IWETH9(WETH9).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');
        if (all > 0) {
            IWETH9(WETH9).withdraw(all);
            safeTransferETH(recipient, all);
        }
    }
    function sweepToken(
        address token,
        uint256 minAmount,
        address recipient
    ) external payable {
        uint256 all = IERC20(token).balanceOf(address(this));
        require(all >= minAmount, 'WETH9 Not Enough');
        if (all > 0) {
            safeTransfer(token, recipient, all);
        }
    }
    function refundETH() external payable {
        if (address(this).balance > 0) safeTransferETH(msg.sender, address(this).balance);
    }
    function pay(
        address token,
        address payer,
        address recipient,
        uint256 value
    ) internal {
        if (token == WETH9 && address(this).balance >= value) {
            IWETH9(WETH9).deposit{value: value}(); 
            IWETH9(WETH9).transfer(recipient, value);
        } else if (payer == address(this)) {
            safeTransfer(token, recipient, value);
        } else {
            safeTransferFrom(token, payer, recipient, value);
        }
    }
    function pool(address tokenX, address tokenY, uint16 fee) public view returns(address) {
        (address token0, address token1) = tokenX < tokenY ? (tokenX, tokenY) : (tokenY, tokenX);
        return address(uint160(uint(keccak256(abi.encodePacked(
            hex'ff',
            factory,
            keccak256(abi.encode(token0, token1, fee)),
            INIT_CODE_HASH
        )))));
    }
    function createPool(address tokenX, address tokenY, uint16 fee, int24 initialPoint) external payable returns (address) {
        return IBiswapFactoryV3(factory).newPool(tokenX, tokenY, fee, initialPoint);
    }
    function verify(address tokenX, address tokenY, uint16 fee) internal view {
        require (msg.sender == pool(tokenX, tokenY, fee), "sp");
    }
}
contract V3Migrator is Base, IV3Migrator {
    address public immutable liquidityManager;
    int24 fullRangeLength = 800000;
    event Migrate(
        MigrateParams params,
        uint amountRemoved0,
        uint amountRemoved1,
        uint amountAdded0,
        uint amountAdded1
    );
    constructor(
        address _factory,
        address _WETH9,
        address _liquidityManager
    ) Base(_factory, _WETH9) {
        liquidityManager = _liquidityManager;
    }
    function mint(ILiquidityManager.MintParam calldata mintParam) external payable returns(
        uint256 lid,
        uint128 liquidity,
        uint256 amountX,
        uint256 amountY
    ){
        return ILiquidityManager(liquidityManager).mint(mintParam);
    }
    function migrate(MigrateParams calldata params) external override returns(uint refund0, uint refund1){
        IBiswapPair(params.pair).transferFrom(params.recipient, params.pair, params.liquidityToMigrate);
        (uint256 amount0V2, uint256 amount1V2) = IBiswapPair(params.pair).burn(address(this));
        uint128 amount0V2ToMigrate = uint128(amount0V2);
        uint128 amount1V2ToMigrate = uint128(amount1V2);
        safeApprove(params.token0, liquidityManager, amount0V2ToMigrate);
        safeApprove(params.token1, liquidityManager, amount1V2ToMigrate);
        (, , uint256 amount0V3, uint256 amount1V3) = ILiquidityManager(liquidityManager).mint(
            ILiquidityManager.MintParam({
                miner: params.recipient,
                tokenX: params.token0,
                tokenY: params.token1,
                fee: params.fee,
                pl: params.tickLower,
                pr: params.tickUpper,
                xLim: amount0V2ToMigrate,
                yLim: amount1V2ToMigrate,
                amountXMin: params.amount0Min,
                amountYMin: params.amount1Min,
                deadline: params.deadline
            })
        );
        if (amount0V3 < amount0V2) {
            if (amount0V3 < amount0V2ToMigrate) {
                safeApprove(params.token0, liquidityManager, 0);
            }
            refund0 = amount0V2 - amount0V3;
            if (params.refundAsETH && params.token0 == WETH9) {
                IWETH9(WETH9).withdraw(refund0);
                safeTransferETH(params.recipient, refund0);
            } else {
                safeTransfer(params.token0, params.recipient, refund0);
            }
        }
        if (amount1V3 < amount1V2) {
            if (amount1V3 < amount1V2ToMigrate) {
                safeApprove(params.token1, liquidityManager, 0);
            }
            refund1 = amount1V2 - amount1V3;
            if (params.refundAsETH && params.token1 == WETH9) {
                IWETH9(WETH9).withdraw(refund1);
                safeTransferETH(params.recipient, refund1);
            } else {
                safeTransfer(params.token1, params.recipient, refund1);
            }
        }
        emit Migrate(
            params,
            amount0V2,
            amount1V2,
            amount0V3,
            amount1V3
        );
    }
    function stretchToPD(int24 point, int24 pd) private pure returns(int24 stretchedPoint){
        if (point < -pd) return ((point / pd) * pd) + pd;
        if (point > pd) return ((point / pd) * pd);
        return 0;
    }
    function getFullRangeTicks(int24 cp, int24 pd) public view returns(int24 pl, int24 pr){
        cp = (cp / pd) * pd;
        int24 minPoint = -800000;
        int24 maxPoint = 800000;
        if (cp >= fullRangeLength/2)  return (stretchToPD(maxPoint - fullRangeLength, pd), stretchToPD(maxPoint, pd));
        if (cp <= -fullRangeLength/2) return (stretchToPD(minPoint, pd),  stretchToPD(minPoint + fullRangeLength, pd));
        return (stretchToPD(cp - fullRangeLength/2, pd), stretchToPD(cp + fullRangeLength/2, pd));
    }
    function getPoolState(address _tokenX, address _tokenY, uint16 _fee) public view returns(
        int24 currentPoint,
        int24 leftTick,
        int24 rightTick
    ){
        address poolAddress = pool(_tokenX, _tokenY, _fee);
        (bool success, bytes memory d_state) = poolAddress.staticcall(abi.encodeWithSelector(0xc19d93fb)); 
        if (!success) revert('pool not created yet!');
        (, bytes memory d_pointDelta) = poolAddress.staticcall(abi.encodeWithSelector(0x58c51ce6)); 
        (,currentPoint,,,,,,,,) = abi.decode(d_state, (uint160,int24,uint16,uint16,uint16,bool,uint240,uint16,uint128,uint128));
        (int24 pointDelta) = abi.decode(d_pointDelta, (int24));
        (leftTick, rightTick) = getFullRangeTicks(currentPoint, pointDelta);
        return (currentPoint, leftTick, rightTick);
    }
}