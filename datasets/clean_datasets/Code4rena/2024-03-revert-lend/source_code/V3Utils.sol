pragma solidity ^0.8.24;
pragma abicoder v2;
interface IUniversalRouter {
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline) external payable;
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
interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
library SafeCast {
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
interface IEIP712 {
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
interface IUniswapV3SwapCallback {
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
interface IUniswapV3PoolActions {
    function initialize(uint160 sqrtPriceX96) external;
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}
interface IUniswapV3PoolDerivedState {
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}
interface IUniswapV3PoolErrors {
    error LOK();
    error TLU();
    error TLM();
    error TUM();
    error AI();
    error M0();
    error M1();
    error AS();
    error IIA();
    error L();
    error F0();
    error F1();
}
interface IUniswapV3PoolEvents {
    event Initialize(uint160 sqrtPriceX96, int24 tick);
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
interface IUniswapV3PoolImmutables {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
    function tickSpacing() external view returns (int24);
    function maxLiquidityPerTick() external view returns (uint128);
}
interface IUniswapV3PoolOwnerActions {
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}
interface IUniswapV3PoolState {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
    function feeGrowthGlobal0X128() external view returns (uint256);
    function feeGrowthGlobal1X128() external view returns (uint256);
    function protocolFees() external view returns (uint128 token0, uint128 token1);
    function liquidity() external view returns (uint128);
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );
    function tickBitmap(int16 wordPosition) external view returns (uint256);
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
library TickMath {
    error T();
    error R();
    int24 internal constant MIN_TICK = -887272;
    int24 internal constant MAX_TICK = -MIN_TICK;
    uint160 internal constant MIN_SQRT_RATIO = 4295128739;
    uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;
    function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        unchecked {
            uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
            if (absTick > uint256(int256(MAX_TICK))) revert T();
            uint256 ratio = absTick & 0x1 != 0
                ? 0xfffcb933bd6fad37aa2d162d1a594001
                : 0x100000000000000000000000000000000;
            if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
            if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
            if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
            if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
            if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
            if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
            if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
            if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
            if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
            if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
            if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
            if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
            if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
            if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
            if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
            if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
            if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
            if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
            if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;
            if (tick > 0) ratio = type(uint256).max / ratio;
            sqrtPriceX96 = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
        }
    }
    function getTickAtSqrtRatio(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        unchecked {
            if (!(sqrtPriceX96 >= MIN_SQRT_RATIO && sqrtPriceX96 < MAX_SQRT_RATIO)) revert R();
            uint256 ratio = uint256(sqrtPriceX96) << 32;
            uint256 r = ratio;
            uint256 msb = 0;
            assembly {
                let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(5, gt(r, 0xFFFFFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(4, gt(r, 0xFFFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(3, gt(r, 0xFF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(2, gt(r, 0xF))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := shl(1, gt(r, 0x3))
                msb := or(msb, f)
                r := shr(f, r)
            }
            assembly {
                let f := gt(r, 0x1)
                msb := or(msb, f)
            }
            if (msb >= 128) r = ratio >> (msb - 127);
            else r = ratio << (127 - msb);
            int256 log_2 = (int256(msb) - 128) << 64;
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(63, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(62, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(61, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(60, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(59, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(58, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(57, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(56, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(55, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(54, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(53, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(52, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(51, f))
                r := shr(f, r)
            }
            assembly {
                r := shr(127, mul(r, r))
                let f := shr(128, r)
                log_2 := or(log_2, shl(50, f))
            }
            int256 log_sqrt10001 = log_2 * 255738958999603826347141; 
            int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
            int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);
            tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= sqrtPriceX96 ? tickHi : tickLow;
        }
    }
}
interface IPeripheryImmutableState {
    function factory() external view returns (address);
    function WETH9() external view returns (address);
}
interface IPeripheryPayments {
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;
    function refundETH() external payable;
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}
interface IPoolInitializer {
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}
library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0xa598dd2fba360510c5a8f02f44423a4468e902df5857dbce3ca162a43a3a31ff;
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}
interface IErrors {
    error Unauthorized();
    error Reentrancy();
    error NotConfigured();
    error NotReady();
    error InvalidConfig();
    error TWAPCheckFailed();
    error WrongContract();
    error SwapFailed();
    error SlippageError();
    error MissingSwapData();
    error SwapAmountTooLarge();
    error LiquidityChanged();
    error ExceedsMaxReward();
    error InvalidPool();
    error ChainlinkPriceError();
    error PriceDifferenceExceeded();
    error CollateralFail();
    error MinLoanSize();
    error GlobalDebtLimit();
    error GlobalLendLimit();
    error DailyDebtIncreaseLimit();
    error DailyLendIncreaseLimit();
    error InsufficientLiquidity();
    error NotLiquidatable();
    error InterestNotUpdated();
    error RepayExceedsDebt();
    error TransformNotAllowed();
    error TransformFailed();
    error CollateralFactorExceedsMax();
    error CollateralValueLimit();
    error NoLiquidity();
    error DebtChanged();
    error SelfSend();
    error NotSupportedWhatToDo();
    error SameToken();
    error AmountError();
    error CollectError();
    error TransferError();
    error TooMuchEtherSent();
    error NoEtherToken();
    error EtherSendFailed();
    error NotWETH();
    error NotEnoughReward();
    error SameRange();
    error NotSupportedFeeTier();
}
interface IWETH9 is IERC20 {
    function deposit() external payable;
    function withdraw(uint256) external;
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
interface IAllowanceTransfer is IEIP712 {
    error AllowanceExpired(uint256 deadline);
    error InsufficientAllowance(uint256 amount);
    error ExcessiveInvalidation();
    event NonceInvalidation(
        address indexed owner, address indexed token, address indexed spender, uint48 newNonce, uint48 oldNonce
    );
    event Approval(
        address indexed owner, address indexed token, address indexed spender, uint160 amount, uint48 expiration
    );
    event Permit(
        address indexed owner,
        address indexed token,
        address indexed spender,
        uint160 amount,
        uint48 expiration,
        uint48 nonce
    );
    event Lockdown(address indexed owner, address token, address spender);
    struct PermitDetails {
        address token;
        uint160 amount;
        uint48 expiration;
        uint48 nonce;
    }
    struct PermitSingle {
        PermitDetails details;
        address spender;
        uint256 sigDeadline;
    }
    struct PermitBatch {
        PermitDetails[] details;
        address spender;
        uint256 sigDeadline;
    }
    struct PackedAllowance {
        uint160 amount;
        uint48 expiration;
        uint48 nonce;
    }
    struct TokenSpenderPair {
        address token;
        address spender;
    }
    struct AllowanceTransferDetails {
        address from;
        address to;
        uint160 amount;
        address token;
    }
    function allowance(address user, address token, address spender)
        external
        view
        returns (uint160 amount, uint48 expiration, uint48 nonce);
    function approve(address token, address spender, uint160 amount, uint48 expiration) external;
    function permit(address owner, PermitSingle memory permitSingle, bytes calldata signature) external;
    function permit(address owner, PermitBatch memory permitBatch, bytes calldata signature) external;
    function transferFrom(address from, address to, uint160 amount, address token) external;
    function transferFrom(AllowanceTransferDetails[] calldata transferDetails) external;
    function lockdown(TokenSpenderPair[] calldata approvals) external;
    function invalidateNonces(address token, address spender, uint48 newNonce) external;
}
interface ISignatureTransfer is IEIP712 {
    error InvalidAmount(uint256 maxAmount);
    error LengthMismatch();
    event UnorderedNonceInvalidation(address indexed owner, uint256 word, uint256 mask);
    struct TokenPermissions {
        address token;
        uint256 amount;
    }
    struct PermitTransferFrom {
        TokenPermissions permitted;
        uint256 nonce;
        uint256 deadline;
    }
    struct SignatureTransferDetails {
        address to;
        uint256 requestedAmount;
    }
    struct PermitBatchTransferFrom {
        TokenPermissions[] permitted;
        uint256 nonce;
        uint256 deadline;
    }
    function nonceBitmap(address, uint256) external view returns (uint256);
    function permitTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;
    function permitWitnessTransferFrom(
        PermitTransferFrom memory permit,
        SignatureTransferDetails calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;
    function permitTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes calldata signature
    ) external;
    function permitWitnessTransferFrom(
        PermitBatchTransferFrom memory permit,
        SignatureTransferDetails[] calldata transferDetails,
        address owner,
        bytes32 witness,
        string calldata witnessTypeString,
        bytes calldata signature
    ) external;
    function invalidateUnorderedNonces(uint256 wordPos, uint256 mask) external;
}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IERC721Permit is IERC721 {
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
interface IPermit2 is ISignatureTransfer, IAllowanceTransfer {
}
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolErrors,
    IUniswapV3PoolEvents
{
}
interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }
    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );
    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );
    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);
    function burn(uint256 tokenId) external payable;
}
abstract contract Swapper is IUniswapV3SwapCallback, IErrors {
    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);
    IWETH9 public immutable weth;
    address public immutable factory;
    INonfungiblePositionManager public immutable nonfungiblePositionManager;
    address public immutable zeroxRouter;
    address public immutable universalRouter;
    constructor(
        INonfungiblePositionManager _nonfungiblePositionManager,
        address _zeroxRouter,
        address _universalRouter
    ) {
        weth = IWETH9(_nonfungiblePositionManager.WETH9());
        factory = _nonfungiblePositionManager.factory();
        nonfungiblePositionManager = _nonfungiblePositionManager;
        zeroxRouter = _zeroxRouter;
        universalRouter = _universalRouter;
    }
    struct ZeroxRouterData {
        address allowanceTarget;
        bytes data;
    }
    struct UniversalRouterData {
        bytes commands;
        bytes[] inputs;
        uint256 deadline;
    }
    struct RouterSwapParams {
        IERC20 tokenIn;
        IERC20 tokenOut;
        uint256 amountIn;
        uint256 amountOutMin;
        bytes swapData;
    }
    function _routerSwap(RouterSwapParams memory params)
        internal
        returns (uint256 amountInDelta, uint256 amountOutDelta)
    {
        if (params.amountIn != 0 && params.swapData.length != 0 && address(params.tokenOut) != address(0)) {
            uint256 balanceInBefore = params.tokenIn.balanceOf(address(this));
            uint256 balanceOutBefore = params.tokenOut.balanceOf(address(this));
            (address router, bytes memory routerData) = abi.decode(params.swapData, (address, bytes));
            if (router == zeroxRouter) {
                ZeroxRouterData memory data = abi.decode(routerData, (ZeroxRouterData));
                SafeERC20.safeApprove(params.tokenIn, data.allowanceTarget, params.amountIn);
                (bool success,) = zeroxRouter.call(data.data);
                if (!success) {
                    revert SwapFailed();
                }
                SafeERC20.safeApprove(params.tokenIn, data.allowanceTarget, 0);
            } else if (router == universalRouter) {
                UniversalRouterData memory data = abi.decode(routerData, (UniversalRouterData));
                SafeERC20.safeTransfer(params.tokenIn, universalRouter, params.amountIn);
                IUniversalRouter(universalRouter).execute(data.commands, data.inputs, data.deadline);
            } else {
                revert WrongContract();
            }
            uint256 balanceInAfter = params.tokenIn.balanceOf(address(this));
            uint256 balanceOutAfter = params.tokenOut.balanceOf(address(this));
            amountInDelta = balanceInBefore - balanceInAfter;
            amountOutDelta = balanceOutAfter - balanceOutBefore;
            if (amountOutDelta < params.amountOutMin) {
                revert SlippageError();
            }
            emit Swap(address(params.tokenIn), address(params.tokenOut), amountInDelta, amountOutDelta);
        }
    }
    struct PoolSwapParams {
        IUniswapV3Pool pool;
        IERC20 token0;
        IERC20 token1;
        uint24 fee;
        bool swap0For1;
        uint256 amountIn;
        uint256 amountOutMin;
    }
    function _poolSwap(PoolSwapParams memory params) internal returns (uint256 amountInDelta, uint256 amountOutDelta) {
        if (params.amountIn > 0) {
            (int256 amount0Delta, int256 amount1Delta) = params.pool.swap(
                address(this),
                params.swap0For1,
                int256(params.amountIn),
                (params.swap0For1 ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1),
                abi.encode(
                    params.swap0For1 ? params.token0 : params.token1,
                    params.swap0For1 ? params.token1 : params.token0,
                    params.fee
                )
            );
            amountInDelta = params.swap0For1 ? uint256(amount0Delta) : uint256(amount1Delta);
            amountOutDelta = params.swap0For1 ? uint256(-amount1Delta) : uint256(-amount0Delta);
            if (amountOutDelta < params.amountOutMin) {
                revert SlippageError();
            }
        }
    }
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external override {
        require(amount0Delta > 0 || amount1Delta > 0); 
        (address tokenIn, address tokenOut, uint24 fee) = abi.decode(data, (address, address, uint24));
        if (address(_getPool(tokenIn, tokenOut, fee)) != msg.sender) {
            revert Unauthorized();
        }
        uint256 amountToPay = amount0Delta > 0 ? uint256(amount0Delta) : uint256(amount1Delta);
        SafeERC20.safeTransfer(IERC20(tokenIn), msg.sender, amountToPay);
    }
    function _getPool(address tokenA, address tokenB, uint24 fee) internal view returns (IUniswapV3Pool) {
        return IUniswapV3Pool(PoolAddress.computeAddress(address(factory), PoolAddress.getPoolKey(tokenA, tokenB, fee)));
    }
}
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
        ISignatureTransfer.PermitBatchTransferFrom memory permit,
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