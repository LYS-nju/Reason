pragma solidity 0.8.20 ;
library LibBit {
    function fls(uint256 x) internal pure returns (uint256 r) {
        assembly {
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, x)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := or(r, byte(shr(r, x), hex"00000101020202020303030303030303"))
        }
    }
    function clz(uint256 x) internal pure returns (uint256 r) {
        assembly {
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            r := or(r, shl(2, lt(0xf, shr(r, x))))
            r := add(iszero(x), xor(255,
                or(r, byte(shr(r, x), hex"00000101020202020303030303030303"))))
        }
    }
    function ffs(uint256 x) internal pure returns (uint256 r) {
        assembly {
            let b := and(x, add(not(x), 1))
            r := or(shl(8, iszero(x)), shl(7, lt(0xffffffffffffffffffffffffffffffff, b)))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, b))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, b))))
            r := or(r, byte(and(div(0xd76453e0, shr(r, b)), 0x1f),
                0x001f0d1e100c1d070f090b19131c1706010e11080a1a141802121b1503160405))
        }
    }
    function popCount(uint256 x) internal pure returns (uint256 c) {
        assembly {
            let max := not(0)
            let isMax := eq(x, max)
            x := sub(x, and(shr(1, x), div(max, 3)))
            x := add(and(x, div(max, 5)), and(shr(2, x), div(max, 5)))
            x := and(add(x, shr(4, x)), div(max, 17))
            c := or(shl(8, isMax), shr(248, mul(x, div(max, 255))))
        }
    }
    function isPo2(uint256 x) internal pure returns (bool result) {
        assembly {
            result := iszero(add(and(x, sub(x, 1)), iszero(x)))
        }
    }
    function reverseBits(uint256 x) internal pure returns (uint256 r) {
        assembly {
            let m := not(0)
            r := x
            for { let s := 128 } 1 {} {
                m := xor(m, shl(s, m))
                r := or(and(shr(s, r), m), and(shl(s, r), not(m)))
                s := shr(1, s)
                if iszero(s) { break }
            }
        }
    }
    function reverseBytes(uint256 x) internal pure returns (uint256 r) {
        assembly {
            let m := not(0)
            r := x
            for { let s := 128 } 1 {} {
                m := xor(m, shl(s, m))
                r := or(and(shr(s, r), m), and(shl(s, r), not(m)))
                s := shr(1, s)
                if eq(s, 4) { break }
            }
        }
    }
    function rawAnd(bool x, bool y) internal pure returns (bool z) {
        assembly {
            z := and(x, y)
        }
    }
    function and(bool x, bool y) internal pure returns (bool z) {
        assembly {
            z := and(iszero(iszero(x)), iszero(iszero(y)))
        }
    }
    function rawOr(bool x, bool y) internal pure returns (bool z) {
        assembly {
            z := or(x, y)
        }
    }
    function or(bool x, bool y) internal pure returns (bool z) {
        assembly {
            z := or(iszero(iszero(x)), iszero(iszero(y)))
        }
    }
    function rawToUint(bool b) internal pure returns (uint256 z) {
        assembly {
            z := b
        }
    }
    function toUint(bool b) internal pure returns (uint256 z) {
        assembly {
            z := iszero(iszero(b))
        }
    }
}
library SafeTransferLib {
    error ETHTransferFailed();
    error TransferFromFailed();
    error TransferFailed();
    error ApproveFailed();
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;
    function safeTransferETH(address to, uint256 amount) internal {
        assembly {
            if iszero(call(gas(), to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) 
                revert(0x1c, 0x04)
            }
        }
    }
    function safeTransferAllETH(address to) internal {
        assembly {
            if iszero(call(gas(), to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, 0xb12d13eb) 
                revert(0x1c, 0x04)
            }
        }
    }
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) 
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } 
            }
        }
    }
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } 
            }
        }
    }
    function forceSafeTransferETH(address to, uint256 amount) internal {
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb) 
                revert(0x1c, 0x04)
            }
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) { revert(codesize(), codesize()) } 
            }
        }
    }
    function forceSafeTransferAllETH(address to) internal {
        assembly {
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(selfbalance(), 0x0b, 0x16)) { revert(codesize(), codesize()) } 
            }
        }
    }
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        assembly {
            success := call(gasStipend, to, amount, codesize(), 0x00, codesize(), 0x00)
        }
    }
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        assembly {
            success := call(gasStipend, to, selfbalance(), codesize(), 0x00, codesize(), 0x00)
        }
    }
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        assembly {
            let m := mload(0x40) 
            mstore(0x60, amount) 
            mstore(0x40, to) 
            mstore(0x2c, shl(96, from)) 
            mstore(0x0c, 0x23b872dd000000000000000000000000) 
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())), 
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) 
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) 
            mstore(0x40, m) 
        }
    }
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        assembly {
            let m := mload(0x40) 
            mstore(0x40, to) 
            mstore(0x2c, shl(96, from)) 
            mstore(0x0c, 0x70a08231000000000000000000000000) 
            if iszero(
                and( 
                    gt(returndatasize(), 0x1f), 
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) 
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd) 
            amount := mload(0x60) 
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())), 
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424) 
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) 
            mstore(0x40, m) 
        }
    }
    function safeTransfer(address token, address to, uint256 amount) internal {
        assembly {
            mstore(0x14, to) 
            mstore(0x34, amount) 
            mstore(0x00, 0xa9059cbb000000000000000000000000) 
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())), 
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) 
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) 
        }
    }
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        assembly {
            mstore(0x00, 0x70a08231) 
            mstore(0x20, address()) 
            if iszero(
                and( 
                    gt(returndatasize(), 0x1f), 
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) 
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) 
            amount := mload(0x34) 
            mstore(0x00, 0xa9059cbb000000000000000000000000) 
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())), 
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) 
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) 
        }
    }
    function safeApprove(address token, address to, uint256 amount) internal {
        assembly {
            mstore(0x14, to) 
            mstore(0x34, amount) 
            mstore(0x00, 0x095ea7b3000000000000000000000000) 
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())), 
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73) 
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0) 
        }
    }
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
        assembly {
            mstore(0x14, to) 
            mstore(0x34, amount) 
            mstore(0x00, 0x095ea7b3000000000000000000000000) 
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())), 
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x34, 0) 
                mstore(0x00, 0x095ea7b3000000000000000000000000) 
                pop(call(gas(), token, 0, 0x10, 0x44, 0x00, 0x00)) 
                mstore(0x34, amount) 
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), 
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) 
                    revert(0x1c, 0x04)
                }
            }
            mstore(0x34, 0) 
        }
    }
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        assembly {
            mstore(0x14, account) 
            mstore(0x00, 0x70a08231000000000000000000000000) 
            amount :=
                mul(
                    mload(0x20),
                    and( 
                        gt(returndatasize(), 0x1f), 
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }
}
contract ReentrancyGuard {
  error NoReentrantCalls();
  uint256 private _reentrancyGuard;
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;
  modifier nonReentrant() {
    _setReentrancyGuard();
    _;
    _clearReentrancyGuard();
  }
  modifier nonReentrantView() {
    _assertNonReentrant();
    _;
  }
  constructor() {
    _reentrancyGuard = _NOT_ENTERED;
  }
  function _setReentrancyGuard() internal {
    _assertNonReentrant();
    unchecked {
      _reentrancyGuard = _ENTERED;
    }
  }
  function _clearReentrancyGuard() internal {
    _reentrancyGuard = _NOT_ENTERED;
  }
  function _assertNonReentrant() internal view {
    if (_reentrancyGuard != _NOT_ENTERED) {
      revert NoReentrantCalls();
    }
  }
}
interface IERC20 {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
  function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}
interface IWildcatMarketControllerEventsAndErrors {
  error DelinquencyGracePeriodOutOfBounds();
  error ReserveRatioBipsOutOfBounds();
  error DelinquencyFeeBipsOutOfBounds();
  error WithdrawalBatchDurationOutOfBounds();
  error AnnualInterestBipsOutOfBounds();
  error CallerNotBorrower();
  error CallerNotBorrowerOrControllerFactory();
  error NotRegisteredBorrower();
  error EmptyString();
  error NotControlledMarket();
  error MarketAlreadyDeployed();
  error ExcessReserveRatioStillActive();
  error AprChangeNotPending();
  event LenderAuthorized(address);
  event LenderDeauthorized(address);
  event MarketDeployed(address indexed market);
}
interface IWildcatSanctionsSentinel {
  event NewSanctionsEscrow(
    address indexed borrower,
    address indexed account,
    address indexed asset
  );
  event SanctionOverride(address indexed borrower, address indexed account);
  event SanctionOverrideRemoved(address indexed borrower, address indexed account);
  error NotRegisteredMarket();
  struct TmpEscrowParams {
    address borrower;
    address account;
    address asset;
  }
  function WildcatSanctionsEscrowInitcodeHash() external pure returns (bytes32);
  function chainalysisSanctionsList() external view returns (address);
  function archController() external view returns (address);
  function tmpEscrowParams()
    external
    view
    returns (address borrower, address account, address asset);
  function isSanctioned(address borrower, address account) external view returns (bool);
  function sanctionOverrides(address borrower, address account) external view returns (bool);
  function overrideSanction(address account) external;
  function removeSanctionOverride(address account) external;
  function getEscrowAddress(
    address account,
    address borrower,
    address asset
  ) external view returns (address escrowContract);
  function createEscrow(
    address account,
    address borrower,
    address asset
  ) external returns (address escrowContract);
}
library BoolUtils {
  function and(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := and(a, b)
    }
  }
  function or(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := or(a, b)
    }
  }
  function xor(bool a, bool b) internal pure returns (bool c) {
    assembly {
      c := xor(a, b)
    }
  }
}
uint256 constant Panic_CompilerPanic = 0x00;
uint256 constant Panic_AssertFalse = 0x01;
uint256 constant Panic_Arithmetic = 0x11;
uint256 constant Panic_DivideByZero = 0x12;
uint256 constant Panic_InvalidEnumValue = 0x21;
uint256 constant Panic_InvalidStorageByteArray = 0x22;
uint256 constant Panic_EmptyArrayPop = 0x31;
uint256 constant Panic_ArrayOutOfBounds = 0x32;
uint256 constant Panic_MemoryTooLarge = 0x41;
uint256 constant Panic_UninitializedFunctionPointer = 0x51;
uint256 constant Panic_ErrorSelector = 0x4e487b71;
uint256 constant Panic_ErrorCodePointer = 0x20;
uint256 constant Panic_ErrorLength = 0x24;
uint256 constant Error_SelectorPointer = 0x1c;
function revertWithSelector_0(bytes4 errorSelector) pure {
  assembly {
    mstore(0, errorSelector)
    revert(0, 4)
  }
}
function revertWithSelector_1(uint256 errorSelector) pure {
  assembly {
    mstore(0, errorSelector)
    revert(Error_SelectorPointer, 4)
  }
}
function revertWithSelectorAndArgument_0(bytes4 errorSelector, uint256 argument) pure {
  assembly {
    mstore(0, errorSelector)
    mstore(4, argument)
    revert(0, 0x24)
  }
}
function revertWithSelectorAndArgument_1(uint256 errorSelector, uint256 argument) pure {
  assembly {
    mstore(0, errorSelector)
    mstore(0x20, argument)
    revert(Error_SelectorPointer, 0x24)
  }
}
struct FIFOQueue {
  uint128 startIndex;
  uint128 nextIndex;
  mapping(uint256 => uint32) data;
}
using FIFOQueueLib for FIFOQueue global;
library FIFOQueueLib {
  error FIFOQueueOutOfBounds();
  function empty(FIFOQueue storage arr) internal view returns (bool) {
    return arr.nextIndex == arr.startIndex;
  }
  function first(FIFOQueue storage arr) internal view returns (uint32) {
    if (arr.startIndex == arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    return arr.data[arr.startIndex];
  }
  function at(FIFOQueue storage arr, uint256 index) internal view returns (uint32) {
    index += arr.startIndex;
    if (index >= arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    return arr.data[index];
  }
  function length(FIFOQueue storage arr) internal view returns (uint128) {
    return arr.nextIndex - arr.startIndex;
  }
  function values(FIFOQueue storage arr) internal view returns (uint32[] memory _values) {
    uint256 startIndex = arr.startIndex;
    uint256 nextIndex = arr.nextIndex;
    uint256 len = nextIndex - startIndex;
    _values = new uint32[](len);
    for (uint256 i = 0; i < len; i++) {
      _values[i] = arr.data[startIndex + i];
    }
    return _values;
  }
  function push(FIFOQueue storage arr, uint32 value) internal {
    uint128 nextIndex = arr.nextIndex;
    arr.data[nextIndex] = value;
    arr.nextIndex = nextIndex + 1;
  }
  function shift(FIFOQueue storage arr) internal {
    uint128 startIndex = arr.startIndex;
    if (startIndex == arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    delete arr.data[startIndex];
    arr.startIndex = startIndex + 1;
  }
  function shiftN(FIFOQueue storage arr, uint128 n) internal {
    uint128 startIndex = arr.startIndex;
    if (startIndex + n > arr.nextIndex) {
      revert FIFOQueueOutOfBounds();
    }
    for (uint256 i = 0; i < n; i++) {
      delete arr.data[startIndex + i];
    }
    arr.startIndex = startIndex + n;
  }
}
interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}
uint256 constant BIP = 1e4;
uint256 constant HALF_BIP = 0.5e4;
uint256 constant RAY = 1e27;
uint256 constant HALF_RAY = 0.5e27;
uint256 constant BIP_RAY_RATIO = 1e23;
uint256 constant SECONDS_IN_365_DAYS = 365 days;
library MathUtils {
  error MulDivFailed();
  using MathUtils for uint256;
  function calculateLinearInterestFromBips(
    uint256 rateBip,
    uint256 timeDelta
  ) internal pure returns (uint256 result) {
    uint256 rate = rateBip.bipToRay();
    uint256 accumulatedInterestRay = rate * timeDelta;
    unchecked {
      return accumulatedInterestRay / SECONDS_IN_365_DAYS;
    }
  }
  function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = ternary(a < b, a, b);
  }
  function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = ternary(a < b, b, a);
  }
  function satSub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      c := mul(gt(a, b), sub(a, b))
    }
  }
  function ternary(
    bool condition,
    uint256 valueIfTrue,
    uint256 valueIfFalse
  ) internal pure returns (uint256 c) {
    assembly {
      c := add(valueIfFalse, mul(condition, sub(valueIfTrue, valueIfFalse)))
    }
  }
  function bipMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_BIP), b))))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
      c := div(add(mul(a, b), HALF_BIP), BIP)
    }
  }
  function bipDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if or(iszero(b), gt(a, div(sub(not(0), div(b, 2)), BIP))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
      c := div(add(mul(a, BIP), div(b, 2)), b)
    }
  }
  function bipToRay(uint256 a) internal pure returns (uint256 b) {
    assembly {
      b := mul(a, BIP_RAY_RATIO)
      if iszero(eq(div(b, BIP_RAY_RATIO), a)) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
    }
  }
  function rayMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if iszero(or(iszero(b), iszero(gt(a, div(sub(not(0), HALF_RAY), b))))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
      c := div(add(mul(a, b), HALF_RAY), RAY)
    }
  }
  function rayDiv(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assembly {
      if or(iszero(b), gt(a, div(sub(not(0), div(b, 2)), RAY))) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
      c := div(add(mul(a, RAY), div(b, 2)), b)
    }
  }
  function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
    assembly {
      if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
        mstore(0x00, 0xad251c27)
        revert(0x1c, 0x04)
      }
      z := div(mul(x, y), d)
    }
  }
  function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
    assembly {
      if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
        mstore(0x00, 0xad251c27)
        revert(0x1c, 0x04)
      }
      z := add(iszero(iszero(mod(mul(x, y), d))), div(mul(x, y), d))
    }
  }
}
library SafeCastLib {
  function _assertNonOverflow(bool didNotOverflow) private pure {
    assembly {
      if iszero(didNotOverflow) {
        mstore(0, Panic_ErrorSelector)
        mstore(Panic_ErrorCodePointer, Panic_Arithmetic)
        revert(Error_SelectorPointer, Panic_ErrorLength)
      }
    }
  }
  function toUint8(uint256 x) internal pure returns (uint8 y) {
    _assertNonOverflow(x == (y = uint8(x)));
  }
  function toUint16(uint256 x) internal pure returns (uint16 y) {
    _assertNonOverflow(x == (y = uint16(x)));
  }
  function toUint24(uint256 x) internal pure returns (uint24 y) {
    _assertNonOverflow(x == (y = uint24(x)));
  }
  function toUint32(uint256 x) internal pure returns (uint32 y) {
    _assertNonOverflow(x == (y = uint32(x)));
  }
  function toUint40(uint256 x) internal pure returns (uint40 y) {
    _assertNonOverflow(x == (y = uint40(x)));
  }
  function toUint48(uint256 x) internal pure returns (uint48 y) {
    _assertNonOverflow(x == (y = uint48(x)));
  }
  function toUint56(uint256 x) internal pure returns (uint56 y) {
    _assertNonOverflow(x == (y = uint56(x)));
  }
  function toUint64(uint256 x) internal pure returns (uint64 y) {
    _assertNonOverflow(x == (y = uint64(x)));
  }
  function toUint72(uint256 x) internal pure returns (uint72 y) {
    _assertNonOverflow(x == (y = uint72(x)));
  }
  function toUint80(uint256 x) internal pure returns (uint80 y) {
    _assertNonOverflow(x == (y = uint80(x)));
  }
  function toUint88(uint256 x) internal pure returns (uint88 y) {
    _assertNonOverflow(x == (y = uint88(x)));
  }
  function toUint96(uint256 x) internal pure returns (uint96 y) {
    _assertNonOverflow(x == (y = uint96(x)));
  }
  function toUint104(uint256 x) internal pure returns (uint104 y) {
    _assertNonOverflow(x == (y = uint104(x)));
  }
  function toUint112(uint256 x) internal pure returns (uint112 y) {
    _assertNonOverflow(x == (y = uint112(x)));
  }
  function toUint120(uint256 x) internal pure returns (uint120 y) {
    _assertNonOverflow(x == (y = uint120(x)));
  }
  function toUint128(uint256 x) internal pure returns (uint128 y) {
    _assertNonOverflow(x == (y = uint128(x)));
  }
  function toUint136(uint256 x) internal pure returns (uint136 y) {
    _assertNonOverflow(x == (y = uint136(x)));
  }
  function toUint144(uint256 x) internal pure returns (uint144 y) {
    _assertNonOverflow(x == (y = uint144(x)));
  }
  function toUint152(uint256 x) internal pure returns (uint152 y) {
    _assertNonOverflow(x == (y = uint152(x)));
  }
  function toUint160(uint256 x) internal pure returns (uint160 y) {
    _assertNonOverflow(x == (y = uint160(x)));
  }
  function toUint168(uint256 x) internal pure returns (uint168 y) {
    _assertNonOverflow(x == (y = uint168(x)));
  }
  function toUint176(uint256 x) internal pure returns (uint176 y) {
    _assertNonOverflow(x == (y = uint176(x)));
  }
  function toUint184(uint256 x) internal pure returns (uint184 y) {
    _assertNonOverflow(x == (y = uint184(x)));
  }
  function toUint192(uint256 x) internal pure returns (uint192 y) {
    _assertNonOverflow(x == (y = uint192(x)));
  }
  function toUint200(uint256 x) internal pure returns (uint200 y) {
    _assertNonOverflow(x == (y = uint200(x)));
  }
  function toUint208(uint256 x) internal pure returns (uint208 y) {
    _assertNonOverflow(x == (y = uint208(x)));
  }
  function toUint216(uint256 x) internal pure returns (uint216 y) {
    _assertNonOverflow(x == (y = uint216(x)));
  }
  function toUint224(uint256 x) internal pure returns (uint224 y) {
    _assertNonOverflow(x == (y = uint224(x)));
  }
  function toUint232(uint256 x) internal pure returns (uint232 y) {
    _assertNonOverflow(x == (y = uint232(x)));
  }
  function toUint240(uint256 x) internal pure returns (uint240 y) {
    _assertNonOverflow(x == (y = uint240(x)));
  }
  function toUint248(uint256 x) internal pure returns (uint248 y) {
    _assertNonOverflow(x == (y = uint248(x)));
  }
}
using LibBit for uint256;
uint256 constant InvalidReturnDataString_selector = (
  0x4cb9c00000000000000000000000000000000000000000000000000000000000
);
uint256 constant SixtyThreeBytes = 0x3f;
uint256 constant ThirtyOneBytes = 0x1f;
uint256 constant OnlyFullWordMask = 0xffffffe0;
error InvalidReturnDataString();
error InvalidCompactString();
function bytes32ToString(bytes32 value) pure returns (string memory str) {
  uint256 size;
  unchecked {
    uint256 sizeInBits = 255 - uint256(value).ffs();
    size = (sizeInBits + 7) / 8;
  }
  assembly {
    str := mload(0x40)
    mstore(0x40, add(str, 0x40))
    mstore(str, size)
    mstore(add(str, 0x20), value)
  }
}
function queryStringOrBytes32AsString(
  address target,
  uint256 rightPaddedFunctionSelector,
  uint256 rightPaddedGenericErrorSelector
) view returns (string memory str) {
  bool isBytes32;
  assembly {
    mstore(0, rightPaddedFunctionSelector)
    let status := staticcall(gas(), target, 0, 0x04, 0, 0)
    isBytes32 := eq(returndatasize(), 0x20)
    if or(iszero(status), iszero(or(isBytes32, eq(returndatasize(), 0x60)))) {
      if iszero(status) {
        if returndatasize() {
          returndatacopy(0, 0, returndatasize())
          revert(0, returndatasize())
        }
        mstore(0, rightPaddedGenericErrorSelector)
        revert(0, 0x04)
      }
      mstore(0, InvalidReturnDataString_selector)
      revert(0, 0x04)
    }
  }
  if (isBytes32) {
    uint256 value;
    assembly {
      returndatacopy(0x00, 0x00, 0x20)
      value := mload(0)
    }
    uint256 size;
    unchecked {
      uint256 sizeInBits = 255 - value.ffs();
      size = (sizeInBits + 7) / 8;
    }
    assembly {
      str := mload(0x40)
      mstore(0x40, add(str, 0x40))
      mstore(str, size)
      mstore(add(str, 0x20), value)
    }
  } else {
    assembly {
      str := mload(0x40)
      let allocSize := and(sub(returndatasize(), 1), OnlyFullWordMask)
      mstore(0x40, add(str, allocSize))
      returndatacopy(str, 0x20, sub(returndatasize(), 0x20))
    }
  }
}
function queryName(address target) view returns (string memory) {
  return
    queryStringOrBytes32AsString(target, NameFunction_selector, UnknownNameQueryError_selector);
}
function querySymbol(address target) view returns (string memory) {
  return
    queryStringOrBytes32AsString(target, SymbolFunction_selector, UnknownSymbolQueryError_selector);
}
uint256 constant UnknownNameQueryError_selector = (
  0xed3df7ad00000000000000000000000000000000000000000000000000000000
);
uint256 constant UnknownSymbolQueryError_selector = (
  0x89ff815700000000000000000000000000000000000000000000000000000000
);
uint256 constant NameFunction_selector = (
  0x06fdde0300000000000000000000000000000000000000000000000000000000
);
uint256 constant SymbolFunction_selector = (
  0x95d89b4100000000000000000000000000000000000000000000000000000000
);
enum AuthRole {
  Null,
  Blocked,
  WithdrawOnly,
  DepositAndWithdraw
}
struct MarketParameters {
  address asset;
  string namePrefix;
  string symbolPrefix;
  address borrower;
  address controller;
  address feeRecipient;
  address sentinel;
  uint128 maxTotalSupply;
  uint16 protocolFeeBips;
  uint16 annualInterestBips;
  uint16 delinquencyFeeBips;
  uint32 withdrawalBatchDuration;
  uint16 reserveRatioBips;
  uint32 delinquencyGracePeriod;
}
struct MarketControllerParameters {
  address archController;
  address borrower;
  address sentinel;
  address marketInitCodeStorage;
  uint256 marketInitCodeHash;
  uint32 minimumDelinquencyGracePeriod;
  uint32 maximumDelinquencyGracePeriod;
  uint16 minimumReserveRatioBips;
  uint16 maximumReserveRatioBips;
  uint16 minimumDelinquencyFeeBips;
  uint16 maximumDelinquencyFeeBips;
  uint32 minimumWithdrawalBatchDuration;
  uint32 maximumWithdrawalBatchDuration;
  uint16 minimumAnnualInterestBips;
  uint16 maximumAnnualInterestBips;
}
struct ProtocolFeeConfiguration {
  address feeRecipient;
  address originationFeeAsset;
  uint80 originationFeeAmount;
  uint16 protocolFeeBips;
}
struct MarketParameterConstraints {
  uint32 minimumDelinquencyGracePeriod;
  uint32 maximumDelinquencyGracePeriod;
  uint16 minimumReserveRatioBips;
  uint16 maximumReserveRatioBips;
  uint16 minimumDelinquencyFeeBips;
  uint16 maximumDelinquencyFeeBips;
  uint32 minimumWithdrawalBatchDuration;
  uint32 maximumWithdrawalBatchDuration;
  uint16 minimumAnnualInterestBips;
  uint16 maximumAnnualInterestBips;
}
using SafeCastLib for uint256;
using MathUtils for uint256;
library FeeMath {
  function calculateLinearInterestFromBips(
    uint256 rateBip,
    uint256 timeDelta
  ) internal pure returns (uint256 result) {
    uint256 rate = rateBip.bipToRay();
    uint256 accumulatedInterestRay = rate * timeDelta;
    unchecked {
      return accumulatedInterestRay / SECONDS_IN_365_DAYS;
    }
  }
  function calculateBaseInterest(
    MarketState memory state,
    uint256 timestamp
  ) internal pure returns (uint256 baseInterestRay) {
    baseInterestRay = MathUtils.calculateLinearInterestFromBips(
      state.annualInterestBips,
      timestamp - state.lastInterestAccruedTimestamp
    );
  }
  function applyProtocolFee(
    MarketState memory state,
    uint256 baseInterestRay,
    uint256 protocolFeeBips
  ) internal pure returns (uint256 protocolFee) {
    uint256 protocolFeeRay = protocolFeeBips.bipMul(baseInterestRay);
    protocolFee = uint256(state.scaledTotalSupply).rayMul(
      uint256(state.scaleFactor).rayMul(protocolFeeRay)
    );
    state.accruedProtocolFees = (state.accruedProtocolFees + protocolFee).toUint128();
  }
  function updateDelinquency(
    MarketState memory state,
    uint256 timestamp,
    uint256 delinquencyFeeBips,
    uint256 delinquencyGracePeriod
  ) internal pure returns (uint256 delinquencyFeeRay) {
    uint256 timeWithPenalty = updateTimeDelinquentAndGetPenaltyTime(
      state,
      delinquencyGracePeriod,
      timestamp - state.lastInterestAccruedTimestamp
    );
    if (timeWithPenalty > 0) {
      delinquencyFeeRay = calculateLinearInterestFromBips(delinquencyFeeBips, timeWithPenalty);
    }
  }
  function updateTimeDelinquentAndGetPenaltyTime(
    MarketState memory state,
    uint256 delinquencyGracePeriod,
    uint256 timeDelta
  ) internal pure returns (uint256 ) {
    uint256 previousTimeDelinquent = state.timeDelinquent;
    if (state.isDelinquent) {
      state.timeDelinquent = (previousTimeDelinquent + timeDelta).toUint32();
      uint256 secondsRemainingWithoutPenalty = delinquencyGracePeriod.satSub(
        previousTimeDelinquent
      );
      return timeDelta.satSub(secondsRemainingWithoutPenalty);
    }
    state.timeDelinquent = previousTimeDelinquent.satSub(timeDelta).toUint32();
    uint256 secondsRemainingWithPenalty = previousTimeDelinquent.satSub(delinquencyGracePeriod);
    return MathUtils.min(secondsRemainingWithPenalty, timeDelta);
  }
  function updateScaleFactorAndFees(
    MarketState memory state,
    uint256 protocolFeeBips,
    uint256 delinquencyFeeBips,
    uint256 delinquencyGracePeriod,
    uint256 timestamp
  )
    internal
    pure
    returns (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee)
  {
    baseInterestRay = state.calculateBaseInterest(timestamp);
    if (protocolFeeBips > 0) {
      protocolFee = state.applyProtocolFee(baseInterestRay, protocolFeeBips);
    }
    if (delinquencyFeeBips > 0) {
      delinquencyFeeRay = state.updateDelinquency(
        timestamp,
        delinquencyFeeBips,
        delinquencyGracePeriod
      );
    }
    uint256 prevScaleFactor = state.scaleFactor;
    uint256 scaleFactorDelta = prevScaleFactor.rayMul(baseInterestRay + delinquencyFeeRay);
    state.scaleFactor = (prevScaleFactor + scaleFactorDelta).toUint112();
    state.lastInterestAccruedTimestamp = uint32(timestamp);
  }
}
using MarketStateLib for MarketState global;
using MarketStateLib for Account global;
using FeeMath for MarketState global;
struct MarketState {
  bool isClosed;
  uint128 maxTotalSupply;
  uint128 accruedProtocolFees;
  uint128 normalizedUnclaimedWithdrawals;
  uint104 scaledTotalSupply;
  uint104 scaledPendingWithdrawals;
  uint32 pendingWithdrawalExpiry;
  bool isDelinquent;
  uint32 timeDelinquent;
  uint16 annualInterestBips;
  uint16 reserveRatioBips;
  uint112 scaleFactor;
  uint32 lastInterestAccruedTimestamp;
}
struct Account {
  AuthRole approval;
  uint104 scaledBalance;
}
library MarketStateLib {
  using MathUtils for uint256;
  using SafeCastLib for uint256;
  function totalSupply(MarketState memory state) internal pure returns (uint256) {
    return state.normalizeAmount(state.scaledTotalSupply);
  }
  function maximumDeposit(MarketState memory state) internal pure returns (uint256) {
    return uint256(state.maxTotalSupply).satSub(state.totalSupply());
  }
  function normalizeAmount(
    MarketState memory state,
    uint256 amount
  ) internal pure returns (uint256) {
    return amount.rayMul(state.scaleFactor);
  }
  function scaleAmount(MarketState memory state, uint256 amount) internal pure returns (uint256) {
    return amount.rayDiv(state.scaleFactor);
  }
  function liquidityRequired(
    MarketState memory state
  ) internal pure returns (uint256 _liquidityRequired) {
    uint256 scaledWithdrawals = state.scaledPendingWithdrawals;
    uint256 scaledRequiredReserves = (state.scaledTotalSupply - scaledWithdrawals).bipMul(
      state.reserveRatioBips
    ) + scaledWithdrawals;
    return
      state.normalizeAmount(scaledRequiredReserves) +
      state.accruedProtocolFees +
      state.normalizedUnclaimedWithdrawals;
  }
  function withdrawableProtocolFees(
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint128) {
    uint256 totalAvailableAssets = totalAssets - state.normalizedUnclaimedWithdrawals;
    return uint128(MathUtils.min(totalAvailableAssets, state.accruedProtocolFees));
  }
  function borrowableAssets(
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint256) {
    return totalAssets.satSub(state.liquidityRequired());
  }
  function hasPendingExpiredBatch(MarketState memory state) internal view returns (bool result) {
    uint256 expiry = state.pendingWithdrawalExpiry;
    assembly {
      result := gt(timestamp(), sub(expiry, 1))
    }
  }
  function totalDebts(MarketState memory state) internal pure returns (uint256) {
    return
      state.normalizeAmount(state.scaledTotalSupply) +
      state.normalizedUnclaimedWithdrawals +
      state.accruedProtocolFees;
  }
}
interface IMarketEventsAndErrors {
  error MaxSupplyExceeded();
  error NotApprovedBorrower();
  error NotApprovedLender();
  error NotController();
  error BadLaunchCode();
  error NewMaxSupplyTooLow();
  error ReserveRatioBipsTooHigh();
  error InterestRateTooHigh();
  error InterestFeeTooHigh();
  error PenaltyFeeTooHigh();
  error AccountBlacklisted();
  error AccountNotBlocked();
  error NotReversedOrStunning();
  error UnknownNameQueryError();
  error UnknownSymbolQueryError();
  error BorrowAmountTooHigh();
  error FeeSetWithoutRecipient();
  error InsufficientReservesForFeeWithdrawal();
  error WithdrawalBatchNotExpired();
  error NullMintAmount();
  error NullBurnAmount();
  error NullFeeAmount();
  error NullTransferAmount();
  error NullWithdrawalAmount();
  error DepositToClosedMarket();
  error BorrowFromClosedMarket();
  error CloseMarketWithUnpaidWithdrawals();
  error InsufficientReservesForNewLiquidityRatio();
  error InsufficientReservesForOldLiquidityRatio();
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event MaxTotalSupplyUpdated(uint256 assets);
  event AnnualInterestBipsUpdated(uint256 annualInterestBipsUpdated);
  event ReserveRatioBipsUpdated(uint256 reserveRatioBipsUpdated);
  event SanctionedAccountAssetsSentToEscrow(address account, address escrow, uint256 amount);
  event Deposit(address indexed account, uint256 assetAmount, uint256 scaledAmount);
  event Borrow(uint256 assetAmount);
  event MarketClosed(uint256 timestamp);
  event FeesCollected(uint256 assets);
  event StateUpdated(uint256 scaleFactor, bool isDelinquent);
  event ScaleFactorUpdated(
    uint256 scaleFactor,
    uint256 baseInterestRay,
    uint256 delinquencyFeeRay,
    uint256 protocolFee
  );
  event AuthorizationStatusUpdated(address indexed account, AuthRole role);
  event WithdrawalBatchExpired(
    uint256 expiry,
    uint256 scaledTotalAmount,
    uint256 scaledAmountBurned,
    uint256 normalizedAmountPaid
  );
  event WithdrawalBatchCreated(uint256 expiry);
  event WithdrawalBatchClosed(uint256 expiry);
  event WithdrawalBatchPayment(
    uint256 expiry,
    uint256 scaledAmountBurned,
    uint256 normalizedAmountPaid
  );
  event WithdrawalQueued(uint256 expiry, address account, uint256 scaledAmount);
  event WithdrawalExecuted(uint256 expiry, address account, uint256 normalizedAmount);
  event Withdrawal(address indexed account, uint256 assetAmount, uint256 scaledAmount);
  event SanctionedAccountWithdrawalSentToEscrow(
    address account,
    address escrow,
    uint32 expiry,
    uint256 amount
  );
}
interface IWildcatMarketController is IWildcatMarketControllerEventsAndErrors {
  function controllerFactory() external view returns (address);
  function marketFactory() external view returns (address);
  function archController() external view returns (address);
  function borrower() external view returns (address);
  function getProtocolFeeConfiguration()
    external
    view
    returns (
      address feeRecipient,
      uint16 protocolFeeBips,
      address originationFeeAsset,
      uint256 originationFeeAmount
    );
  function getParameterConstraints()
    external
    view
    returns (MarketParameterConstraints memory constraints);
  function getAuthorizedLenders() external view returns (address[] memory);
  function getAuthorizedLenders(
    uint256 start,
    uint256 end
  ) external view returns (address[] memory);
  function getAuthorizedLendersCount() external view returns (uint256);
  function isAuthorizedLender(address lender) external view returns (bool);
  function authorizeLenders(address[] memory lenders) external;
  function deauthorizeLenders(address[] memory lenders) external;
  function updateLenderAuthorization(address lender, address[] memory markets) external;
  function setAnnualInterestBips(address market, uint16 annualInterestBips) external;
  function resetReserveRatio(address market) external;
  function temporaryExcessReserveRatio(
    address
  ) external view returns (uint128 reserveRatioBips, uint128 expiry);
  function deployMarket(
    address asset,
    string memory namePrefix,
    string memory symbolPrefix,
    uint128 maxTotalSupply,
    uint16 annualInterestBips,
    uint16 delinquencyFeeBips,
    uint32 withdrawalBatchDuration,
    uint16 reserveRatioBips,
    uint32 delinquencyGracePeriod
  ) external returns (address);
  function getMarketParameters() external view returns (MarketParameters memory);
}
using MathUtils for uint256;
using SafeCastLib for uint256;
using WithdrawalLib for WithdrawalBatch global;
using WithdrawalLib for WithdrawalData global;
struct WithdrawalBatch {
  uint104 scaledTotalAmount;
  uint104 scaledAmountBurned;
  uint128 normalizedAmountPaid;
}
struct AccountWithdrawalStatus {
  uint104 scaledAmount;
  uint128 normalizedAmountWithdrawn;
}
struct WithdrawalData {
  FIFOQueue unpaidBatches;
  mapping(uint32 => WithdrawalBatch) batches;
  mapping(uint256 => mapping(address => AccountWithdrawalStatus)) accountStatuses;
}
library WithdrawalLib {
  function scaledOwedAmount(WithdrawalBatch memory batch) internal pure returns (uint104) {
    return batch.scaledTotalAmount - batch.scaledAmountBurned;
  }
  function availableLiquidityForPendingBatch(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint256 totalAssets
  ) internal pure returns (uint256) {
    uint256 priorScaledAmountPending = (state.scaledPendingWithdrawals - batch.scaledOwedAmount());
    uint256 unavailableAssets = state.normalizedUnclaimedWithdrawals +
      state.normalizeAmount(priorScaledAmountPending) +
      state.accruedProtocolFees;
    return totalAssets.satSub(unavailableAssets);
  }
}
contract WildcatMarketBase is ReentrancyGuard, IMarketEventsAndErrors {
  using WithdrawalLib for MarketState;
  using SafeCastLib for uint256;
  using MathUtils for uint256;
  using BoolUtils for bool;
  string public constant version = '1.0';
  address public immutable sentinel;
  address public immutable borrower;
  address public immutable feeRecipient;
  uint256 public immutable protocolFeeBips;
  uint256 public immutable delinquencyFeeBips;
  uint256 public immutable delinquencyGracePeriod;
  address public immutable controller;
  address public immutable asset;
  uint256 public immutable withdrawalBatchDuration;
  uint8 public immutable decimals;
  string public name;
  string public symbol;
  MarketState internal _state;
  mapping(address => Account) internal _accounts;
  WithdrawalData internal _withdrawalData;
  constructor() {
    MarketParameters memory parameters = IWildcatMarketController(msg.sender).getMarketParameters();
    if ((parameters.protocolFeeBips > 0).and(parameters.feeRecipient == address(0))) {
      revert FeeSetWithoutRecipient();
    }
    if (parameters.annualInterestBips > BIP) {
      revert InterestRateTooHigh();
    }
    if (parameters.reserveRatioBips > BIP) {
      revert ReserveRatioBipsTooHigh();
    }
    if (parameters.protocolFeeBips > BIP) {
      revert InterestFeeTooHigh();
    }
    if (parameters.delinquencyFeeBips > BIP) {
      revert PenaltyFeeTooHigh();
    }
    asset = parameters.asset;
    name = string.concat(parameters.namePrefix, queryName(parameters.asset));
    symbol = string.concat(parameters.symbolPrefix, querySymbol(parameters.asset));
    decimals = IERC20Metadata(parameters.asset).decimals();
    _state = MarketState({
      isClosed: false,
      maxTotalSupply: parameters.maxTotalSupply,
      accruedProtocolFees: 0,
      normalizedUnclaimedWithdrawals: 0,
      scaledTotalSupply: 0,
      scaledPendingWithdrawals: 0,
      pendingWithdrawalExpiry: 0,
      isDelinquent: false,
      timeDelinquent: 0,
      annualInterestBips: parameters.annualInterestBips,
      reserveRatioBips: parameters.reserveRatioBips,
      scaleFactor: uint112(RAY),
      lastInterestAccruedTimestamp: uint32(block.timestamp)
    });
    sentinel = parameters.sentinel;
    borrower = parameters.borrower;
    controller = parameters.controller;
    feeRecipient = parameters.feeRecipient;
    protocolFeeBips = parameters.protocolFeeBips;
    delinquencyFeeBips = parameters.delinquencyFeeBips;
    delinquencyGracePeriod = parameters.delinquencyGracePeriod;
    withdrawalBatchDuration = parameters.withdrawalBatchDuration;
  }
  modifier onlyBorrower() {
    if (msg.sender != borrower) revert NotApprovedBorrower();
    _;
  }
  modifier onlyController() {
    if (msg.sender != controller) revert NotController();
    _;
  }
  function _getAccount(address accountAddress) internal view returns (Account memory account) {
    account = _accounts[accountAddress];
    if (account.approval == AuthRole.Blocked) {
      revert AccountBlacklisted();
    }
  }
  function _blockAccount(MarketState memory state, address accountAddress) internal {
    Account memory account = _accounts[accountAddress];
    if (account.approval != AuthRole.Blocked) {
      uint104 scaledBalance = account.scaledBalance;
      account.approval = AuthRole.Blocked;
      emit AuthorizationStatusUpdated(accountAddress, AuthRole.Blocked);
      if (scaledBalance > 0) {
        account.scaledBalance = 0;
        address escrow = IWildcatSanctionsSentinel(sentinel).createEscrow(
          accountAddress,
          borrower,
          address(this)
        );
        emit Transfer(accountAddress, escrow, state.normalizeAmount(scaledBalance));
        _accounts[escrow].scaledBalance += scaledBalance;
        emit SanctionedAccountAssetsSentToEscrow(
          accountAddress,
          escrow,
          state.normalizeAmount(scaledBalance)
        );
      }
      _accounts[accountAddress] = account;
    }
  }
  function _getAccountWithRole(
    address accountAddress,
    AuthRole requiredRole
  ) internal returns (Account memory account) {
    account = _getAccount(accountAddress);
    if (account.approval == AuthRole.Null) {
      if (IWildcatMarketController(controller).isAuthorizedLender(accountAddress)) {
        account.approval = AuthRole.DepositAndWithdraw;
        emit AuthorizationStatusUpdated(accountAddress, AuthRole.DepositAndWithdraw);
      }
    }
    if (uint256(account.approval) < uint256(requiredRole)) {
      revert NotApprovedLender();
    }
  }
  function coverageLiquidity() external view nonReentrantView returns (uint256) {
    return currentState().liquidityRequired();
  }
  function scaleFactor() external view nonReentrantView returns (uint256) {
    return currentState().scaleFactor;
  }
  function totalAssets() public view returns (uint256) {
    return IERC20(asset).balanceOf(address(this));
  }
  function borrowableAssets() external view nonReentrantView returns (uint256) {
    return currentState().borrowableAssets(totalAssets());
  }
  function accruedProtocolFees() external view nonReentrantView returns (uint256) {
    return currentState().accruedProtocolFees;
  }
  function previousState() external view returns (MarketState memory) {
    return _state;
  }
  function currentState() public view nonReentrantView returns (MarketState memory state) {
    (state, , ) = _calculateCurrentState();
  }
  function scaledTotalSupply() external view nonReentrantView returns (uint256) {
    return currentState().scaledTotalSupply;
  }
  function scaledBalanceOf(address account) external view nonReentrantView returns (uint256) {
    return _accounts[account].scaledBalance;
  }
  function getAccountRole(address account) external view nonReentrantView returns (AuthRole) {
    return _accounts[account].approval;
  }
  function withdrawableProtocolFees() external view returns (uint128) {
    return currentState().withdrawableProtocolFees(totalAssets());
  }
  function effectiveBorrowerAPR() external view returns (uint256) {
    MarketState memory state = currentState();
    uint256 apr = MathUtils.bipToRay(state.annualInterestBips).bipMul(BIP + protocolFeeBips);
    if (state.timeDelinquent > delinquencyGracePeriod) {
      apr += MathUtils.bipToRay(delinquencyFeeBips);
    }
    return apr;
  }
  function effectiveLenderAPR() external view returns (uint256) {
    MarketState memory state = currentState();
    uint256 apr = state.annualInterestBips;
    if (state.timeDelinquent > delinquencyGracePeriod) {
      apr += delinquencyFeeBips;
    }
    return MathUtils.bipToRay(apr);
  }
  function _getUpdatedState() internal returns (MarketState memory state) {
    state = _state;
    if (state.hasPendingExpiredBatch()) {
      uint256 expiry = state.pendingWithdrawalExpiry;
      if (expiry != state.lastInterestAccruedTimestamp) {
        (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee) = state
          .updateScaleFactorAndFees(
            protocolFeeBips,
            delinquencyFeeBips,
            delinquencyGracePeriod,
            expiry
          );
        emit ScaleFactorUpdated(state.scaleFactor, baseInterestRay, delinquencyFeeRay, protocolFee);
      }
      _processExpiredWithdrawalBatch(state);
    }
    if (block.timestamp != state.lastInterestAccruedTimestamp) {
      (uint256 baseInterestRay, uint256 delinquencyFeeRay, uint256 protocolFee) = state
        .updateScaleFactorAndFees(
          protocolFeeBips,
          delinquencyFeeBips,
          delinquencyGracePeriod,
          block.timestamp
        );
      emit ScaleFactorUpdated(state.scaleFactor, baseInterestRay, delinquencyFeeRay, protocolFee);
    }
  }
  function _calculateCurrentState()
    internal
    view
    returns (
      MarketState memory state,
      uint32 expiredBatchExpiry,
      WithdrawalBatch memory expiredBatch
    )
  {
    state = _state;
    if (state.hasPendingExpiredBatch()) {
      expiredBatchExpiry = state.pendingWithdrawalExpiry;
      if (expiredBatchExpiry != state.lastInterestAccruedTimestamp) {
        state.updateScaleFactorAndFees(
          protocolFeeBips,
          delinquencyFeeBips,
          delinquencyGracePeriod,
          expiredBatchExpiry
        );
      }
      expiredBatch = _withdrawalData.batches[expiredBatchExpiry];
      uint256 availableLiquidity = expiredBatch.availableLiquidityForPendingBatch(
        state,
        totalAssets()
      );
      if (availableLiquidity > 0) {
        _applyWithdrawalBatchPaymentView(expiredBatch, state, availableLiquidity);
      }
      state.pendingWithdrawalExpiry = 0;
    }
    if (state.lastInterestAccruedTimestamp != block.timestamp) {
      state.updateScaleFactorAndFees(
        protocolFeeBips,
        delinquencyFeeBips,
        delinquencyGracePeriod,
        block.timestamp
      );
    }
  }
  function _writeState(MarketState memory state) internal {
    bool isDelinquent = state.liquidityRequired() > totalAssets();
    state.isDelinquent = isDelinquent;
    _state = state;
    emit StateUpdated(state.scaleFactor, isDelinquent);
  }
  function _processExpiredWithdrawalBatch(MarketState memory state) internal {
    uint32 expiry = state.pendingWithdrawalExpiry;
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
    uint256 availableLiquidity = batch.availableLiquidityForPendingBatch(state, totalAssets());
    if (availableLiquidity > 0) {
      _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
    }
    emit WithdrawalBatchExpired(
      expiry,
      batch.scaledTotalAmount,
      batch.scaledAmountBurned,
      batch.normalizedAmountPaid
    );
    if (batch.scaledAmountBurned < batch.scaledTotalAmount) {
      _withdrawalData.unpaidBatches.push(expiry);
    } else {
      emit WithdrawalBatchClosed(expiry);
    }
    state.pendingWithdrawalExpiry = 0;
    _withdrawalData.batches[expiry] = batch;
  }
  function _applyWithdrawalBatchPayment(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint32 expiry,
    uint256 availableLiquidity
  ) internal {
    uint104 scaledAvailableLiquidity = state.scaleAmount(availableLiquidity).toUint104();
    uint104 scaledAmountOwed = batch.scaledTotalAmount - batch.scaledAmountBurned;
    if (scaledAmountOwed == 0) {
      return;
    }
    uint104 scaledAmountBurned = uint104(MathUtils.min(scaledAvailableLiquidity, scaledAmountOwed));
    uint128 normalizedAmountPaid = state.normalizeAmount(scaledAmountBurned).toUint128();
    batch.scaledAmountBurned += scaledAmountBurned;
    batch.normalizedAmountPaid += normalizedAmountPaid;
    state.scaledPendingWithdrawals -= scaledAmountBurned;
    state.normalizedUnclaimedWithdrawals += normalizedAmountPaid;
    state.scaledTotalSupply -= scaledAmountBurned;
    emit Transfer(address(this), address(0), normalizedAmountPaid);
    emit WithdrawalBatchPayment(expiry, scaledAmountBurned, normalizedAmountPaid);
  }
  function _applyWithdrawalBatchPaymentView(
    WithdrawalBatch memory batch,
    MarketState memory state,
    uint256 availableLiquidity
  ) internal pure {
    uint104 scaledAvailableLiquidity = state.scaleAmount(availableLiquidity).toUint104();
    uint104 scaledAmountOwed = batch.scaledTotalAmount - batch.scaledAmountBurned;
    if (scaledAmountOwed == 0) {
      return;
    }
    uint104 scaledAmountBurned = uint104(MathUtils.min(scaledAvailableLiquidity, scaledAmountOwed));
    uint128 normalizedAmountPaid = state.normalizeAmount(scaledAmountBurned).toUint128();
    batch.scaledAmountBurned += scaledAmountBurned;
    batch.normalizedAmountPaid += normalizedAmountPaid;
    state.scaledPendingWithdrawals -= scaledAmountBurned;
    state.normalizedUnclaimedWithdrawals += normalizedAmountPaid;
    state.scaledTotalSupply -= scaledAmountBurned;
  }
}
contract WildcatMarketConfig is WildcatMarketBase {
  using SafeCastLib for uint256;
  using BoolUtils for bool;
  function maximumDeposit() external view returns (uint256) {
    MarketState memory state = currentState();
    return state.maximumDeposit();
  }
  function maxTotalSupply() external view returns (uint256) {
    return _state.maxTotalSupply;
  }
  function annualInterestBips() external view returns (uint256) {
    return _state.annualInterestBips;
  }
  function reserveRatioBips() external view returns (uint256) {
    return _state.reserveRatioBips;
  }
  function nukeFromOrbit(address accountAddress) external nonReentrant {
    if (!IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      revert BadLaunchCode();
    }
    MarketState memory state = _getUpdatedState();
    _blockAccount(state, accountAddress);
    _writeState(state);
  }
  function stunningReversal(address accountAddress) external nonReentrant {
    Account memory account = _accounts[accountAddress];
    if (account.approval != AuthRole.Blocked) {
      revert AccountNotBlocked();
    }
    if (IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      revert NotReversedOrStunning();
    }
    account.approval = AuthRole.Null;
    emit AuthorizationStatusUpdated(accountAddress, account.approval);
    _accounts[accountAddress] = account;
  }
  function updateAccountAuthorization(
    address _account,
    bool _isAuthorized
  ) external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    Account memory account = _getAccount(_account);
    if (_isAuthorized) {
      account.approval = AuthRole.DepositAndWithdraw;
    } else {
      account.approval = AuthRole.WithdrawOnly;
    }
    _accounts[_account] = account;
    _writeState(state);
    emit AuthorizationStatusUpdated(_account, account.approval);
  }
  function setMaxTotalSupply(uint256 _maxTotalSupply) external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (_maxTotalSupply < state.totalSupply()) {
      revert NewMaxSupplyTooLow();
    }
    state.maxTotalSupply = _maxTotalSupply.toUint128();
    _writeState(state);
    emit MaxTotalSupplyUpdated(_maxTotalSupply);
  }
  function setAnnualInterestBips(uint16 _annualInterestBips) public onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (_annualInterestBips > BIP) {
      revert InterestRateTooHigh();
    }
    state.annualInterestBips = _annualInterestBips;
    _writeState(state);
    emit AnnualInterestBipsUpdated(_annualInterestBips);
  }
  function setReserveRatioBips(uint16 _reserveRatioBips) public onlyController nonReentrant {
    if (_reserveRatioBips > BIP) {
      revert ReserveRatioBipsTooHigh();
    }
    MarketState memory state = _getUpdatedState();
    uint256 initialReserveRatioBips = state.reserveRatioBips;
    if (_reserveRatioBips < initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert InsufficientReservesForOldLiquidityRatio();
      }
    }
    state.reserveRatioBips = _reserveRatioBips;
    if (_reserveRatioBips > initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert InsufficientReservesForNewLiquidityRatio();
      }
    }
    _writeState(state);
    emit ReserveRatioBipsUpdated(_reserveRatioBips);
  }
}
contract WildcatMarketToken is WildcatMarketBase {
  using SafeCastLib for uint256;
  mapping(address => mapping(address => uint256)) public allowance;
  function balanceOf(address account) public view virtual nonReentrantView returns (uint256) {
    (MarketState memory state, , ) = _calculateCurrentState();
    return state.normalizeAmount(_accounts[account].scaledBalance);
  }
  function totalSupply() external view virtual nonReentrantView returns (uint256) {
    (MarketState memory state, , ) = _calculateCurrentState();
    return state.totalSupply();
  }
  function approve(address spender, uint256 amount) external virtual nonReentrant returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }
  function transfer(address to, uint256 amount) external virtual nonReentrant returns (bool) {
    _transfer(msg.sender, to, amount);
    return true;
  }
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external virtual nonReentrant returns (bool) {
    uint256 allowed = allowance[from][msg.sender];
    if (allowed != type(uint256).max) {
      uint256 newAllowance = allowed - amount;
      _approve(from, msg.sender, newAllowance);
    }
    _transfer(from, to, amount);
    return true;
  }
  function _approve(address approver, address spender, uint256 amount) internal virtual {
    allowance[approver][spender] = amount;
    emit Approval(approver, spender, amount);
  }
  function _transfer(address from, address to, uint256 amount) internal virtual {
    MarketState memory state = _getUpdatedState();
    uint104 scaledAmount = state.scaleAmount(amount).toUint104();
    if (scaledAmount == 0) {
      revert NullTransferAmount();
    }
    Account memory fromAccount = _getAccount(from);
    fromAccount.scaledBalance -= scaledAmount;
    _accounts[from] = fromAccount;
    Account memory toAccount = _getAccount(to);
    toAccount.scaledBalance += scaledAmount;
    _accounts[to] = toAccount;
    _writeState(state);
    emit Transfer(from, to, amount);
  }
}
contract WildcatMarketWithdrawals is WildcatMarketBase {
  using SafeTransferLib for address;
  using MathUtils for uint256;
  using SafeCastLib for uint256;
  using BoolUtils for bool;
  function getUnpaidBatchExpiries() external view nonReentrantView returns (uint32[] memory) {
    return _withdrawalData.unpaidBatches.values();
  }
  function getWithdrawalBatch(
    uint32 expiry
  ) external view nonReentrantView returns (WithdrawalBatch memory) {
    (, uint32 expiredBatchExpiry, WithdrawalBatch memory expiredBatch) = _calculateCurrentState();
    if ((expiry == expiredBatchExpiry).and(expiry > 0)) {
      return expiredBatch;
    }
    return _withdrawalData.batches[expiry];
  }
  function getAccountWithdrawalStatus(
    address accountAddress,
    uint32 expiry
  ) external view nonReentrantView returns (AccountWithdrawalStatus memory) {
    return _withdrawalData.accountStatuses[expiry][accountAddress];
  }
  function getAvailableWithdrawalAmount(
    address accountAddress,
    uint32 expiry
  ) external view nonReentrantView returns (uint256) {
    if (expiry > block.timestamp) {
      revert WithdrawalBatchNotExpired();
    }
    (, uint32 expiredBatchExpiry, WithdrawalBatch memory expiredBatch) = _calculateCurrentState();
    WithdrawalBatch memory batch;
    if (expiry == expiredBatchExpiry) {
      batch = expiredBatch;
    } else {
      batch = _withdrawalData.batches[expiry];
    }
    AccountWithdrawalStatus memory status = _withdrawalData.accountStatuses[expiry][accountAddress];
    uint256 previousTotalWithdrawn = status.normalizedAmountWithdrawn;
    uint256 newTotalWithdrawn = uint256(batch.normalizedAmountPaid).mulDiv(
      status.scaledAmount,
      batch.scaledTotalAmount
    );
    return newTotalWithdrawn - previousTotalWithdrawn;
  }
  function queueWithdrawal(uint256 amount) external nonReentrant {
    MarketState memory state = _getUpdatedState();
    Account memory account = _getAccountWithRole(msg.sender, AuthRole.WithdrawOnly);
    uint104 scaledAmount = state.scaleAmount(amount).toUint104();
    if (scaledAmount == 0) {
      revert NullBurnAmount();
    }
    account.scaledBalance -= scaledAmount;
    _accounts[msg.sender] = account;
    emit Transfer(msg.sender, address(this), amount);
    if (state.pendingWithdrawalExpiry == 0) {
      state.pendingWithdrawalExpiry = uint32(block.timestamp + withdrawalBatchDuration);
      emit WithdrawalBatchCreated(state.pendingWithdrawalExpiry);
    }
    uint32 expiry = state.pendingWithdrawalExpiry;
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
    _withdrawalData.accountStatuses[expiry][msg.sender].scaledAmount += scaledAmount;
    batch.scaledTotalAmount += scaledAmount;
    state.scaledPendingWithdrawals += scaledAmount;
    emit WithdrawalQueued(expiry, msg.sender, scaledAmount);
    uint256 availableLiquidity = batch.availableLiquidityForPendingBatch(state, totalAssets());
    if (availableLiquidity > 0) {
      _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
    }
    _withdrawalData.batches[expiry] = batch;
    _writeState(state);
  }
  function executeWithdrawal(
    address accountAddress,
    uint32 expiry
  ) external nonReentrant returns (uint256) {
    if (expiry > block.timestamp) {
      revert WithdrawalBatchNotExpired();
    }
    MarketState memory state = _getUpdatedState();
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
    AccountWithdrawalStatus storage status = _withdrawalData.accountStatuses[expiry][
      accountAddress
    ];
    uint128 newTotalWithdrawn = uint128(
      MathUtils.mulDiv(batch.normalizedAmountPaid, status.scaledAmount, batch.scaledTotalAmount)
    );
    uint128 normalizedAmountWithdrawn = newTotalWithdrawn - status.normalizedAmountWithdrawn;
    status.normalizedAmountWithdrawn = newTotalWithdrawn;
    state.normalizedUnclaimedWithdrawals -= normalizedAmountWithdrawn;
    if (normalizedAmountWithdrawn == 0) {
      revert NullWithdrawalAmount();
    }
    if (IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      _blockAccount(state, accountAddress);
      address escrow = IWildcatSanctionsSentinel(sentinel).createEscrow(
        accountAddress,
        borrower,
        address(asset)
      );
      asset.safeTransfer(escrow, normalizedAmountWithdrawn);
      emit SanctionedAccountWithdrawalSentToEscrow(
        accountAddress,
        escrow,
        expiry,
        normalizedAmountWithdrawn
      );
    } else {
      asset.safeTransfer(accountAddress, normalizedAmountWithdrawn);
    }
    emit WithdrawalExecuted(expiry, accountAddress, normalizedAmountWithdrawn);
    _writeState(state);
    return normalizedAmountWithdrawn;
  }
  function processUnpaidWithdrawalBatch() external nonReentrant {
    MarketState memory state = _getUpdatedState();
    uint32 expiry = _withdrawalData.unpaidBatches.first();
    WithdrawalBatch memory batch = _withdrawalData.batches[expiry];
    uint256 availableLiquidity = totalAssets() -
      (state.normalizedUnclaimedWithdrawals + state.accruedProtocolFees);
    _applyWithdrawalBatchPayment(batch, state, expiry, availableLiquidity);
    if (batch.scaledTotalAmount == batch.scaledAmountBurned) {
      _withdrawalData.unpaidBatches.shift();
      emit WithdrawalBatchClosed(expiry);
    }
    _withdrawalData.batches[expiry] = batch;
    _writeState(state);
  }
}
contract WildcatMarket is
  WildcatMarketBase,
  WildcatMarketConfig,
  WildcatMarketToken,
  WildcatMarketWithdrawals
{
  using MathUtils for uint256;
  using SafeCastLib for uint256;
  using SafeTransferLib for address;
  function updateState() external nonReentrant {
    MarketState memory state = _getUpdatedState();
    _writeState(state);
  }
  function depositUpTo(
    uint256 amount
  ) public virtual nonReentrant returns (uint256 ) {
    MarketState memory state = _getUpdatedState();
    if (state.isClosed) {
      revert DepositToClosedMarket();
    }
    amount = MathUtils.min(amount, state.maximumDeposit());
    uint104 scaledAmount = state.scaleAmount(amount).toUint104();
    if (scaledAmount == 0) revert NullMintAmount();
    asset.safeTransferFrom(msg.sender, address(this), amount);
    Account memory account = _getAccountWithRole(msg.sender, AuthRole.DepositAndWithdraw);
    account.scaledBalance += scaledAmount;
    _accounts[msg.sender] = account;
    emit Transfer(address(0), msg.sender, amount);
    emit Deposit(msg.sender, amount, scaledAmount);
    state.scaledTotalSupply += scaledAmount;
    _writeState(state);
    return amount;
  }
  function deposit(uint256 amount) external virtual {
    uint256 actualAmount = depositUpTo(amount);
    if (amount != actualAmount) {
      revert MaxSupplyExceeded();
    }
  }
  function collectFees() external nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (state.accruedProtocolFees == 0) {
      revert NullFeeAmount();
    }
    uint128 withdrawableFees = state.withdrawableProtocolFees(totalAssets());
    if (withdrawableFees == 0) {
      revert InsufficientReservesForFeeWithdrawal();
    }
    state.accruedProtocolFees -= withdrawableFees;
    _writeState(state);
    asset.safeTransfer(feeRecipient, withdrawableFees);
    emit FeesCollected(withdrawableFees);
  }
  function borrow(uint256 amount) external onlyBorrower nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (state.isClosed) {
      revert BorrowFromClosedMarket();
    }
    uint256 borrowable = state.borrowableAssets(totalAssets());
    if (amount > borrowable) {
      revert BorrowAmountTooHigh();
    }
    _writeState(state);
    asset.safeTransfer(msg.sender, amount);
    emit Borrow(amount);
  }
  function closeMarket() external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    state.annualInterestBips = 0;
    state.isClosed = true;
    state.reserveRatioBips = 0;
    if (_withdrawalData.unpaidBatches.length() > 0) {
      revert CloseMarketWithUnpaidWithdrawals();
    }
    uint256 currentlyHeld = totalAssets();
    uint256 totalDebts = state.totalDebts();
    if (currentlyHeld < totalDebts) {
      asset.safeTransferFrom(borrower, address(this), totalDebts - currentlyHeld);
    } else if (currentlyHeld > totalDebts) {
      asset.safeTransfer(borrower, currentlyHeld - totalDebts);
    }
    _writeState(state);
    emit MarketClosed(block.timestamp);
  }
}