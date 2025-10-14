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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
interface IERC1967Upgradeable {
    event Upgraded(address indexed implementation);
    event AdminChanged(address previousAdmin, address newAdmin);
    event BeaconUpgraded(address indexed beacon);
}
interface IERC5267Upgradeable {
    event EIP712DomainChanged();
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
interface IERC1822ProxiableUpgradeable {
    function proxiableUUID() external view returns (bytes32);
}
interface IBeaconUpgradeable {
    function implementation() external view returns (address);
}
interface IERC20Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
interface IERC20PermitUpgradeable {
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
library AddressUpgradeable {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
library CountersUpgradeable {
    struct Counter {
        uint256 _value; 
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
library StorageSlotUpgradeable {
    struct AddressSlot {
        address value;
    }
    struct BooleanSlot {
        bool value;
    }
    struct Bytes32Slot {
        bytes32 value;
    }
    struct Uint256Slot {
        uint256 value;
    }
    struct StringSlot {
        string value;
    }
    struct BytesSlot {
        bytes value;
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
}
library MathUpgradeable {
    enum Rounding {
        Down, 
        Up, 
        Zero 
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0; 
            uint256 prod1; 
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            require(denominator > prod1, "Math: mulDiv overflow");
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            result = prod0 * inverse;
            return result;
        }
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = 1 << (log2(a) >> 1);
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
library SignedMathUpgradeable {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }
    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            return uint256(n >= 0 ? n : -n);
        }
    }
}
interface IWellFunction {
    error InvalidJArgument();
    function calcReserve(
        uint256[] memory reserves,
        uint256 j,
        uint256 lpTokenSupply,
        bytes calldata data
    ) external view returns (uint256 reserve);
    function calcLpTokenSupply(
        uint256[] memory reserves,
        bytes calldata data
    ) external view returns (uint256 lpTokenSupply);
    function calcLPTokenUnderlying(
        uint256 lpTokenAmount,
        uint256[] memory reserves,
        uint256 lpTokenSupply,
        bytes calldata data
    ) external view returns (uint256[] memory underlyingAmounts);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
}
interface IPump {
    function update(uint256[] calldata reserves, bytes calldata data) external;
}
library LibBytes {
    uint256 constant MAX_UINT128 = 340_282_366_920_938_463_463_374_607_431_768_211_455; 
    function storeUint128(bytes32 slot, uint256[] memory reserves) internal {
        if (reserves.length == 2) {
            require(reserves[0] <= MAX_UINT128, "ByteStorage: too large");
            require(reserves[1] <= MAX_UINT128, "ByteStorage: too large");
            assembly {
                sstore(slot, add(mload(add(reserves, 32)), shl(128, mload(add(reserves, 64)))))
            }
        } else {
            uint256 maxI = reserves.length / 2; 
            uint256 iByte; 
            for (uint256 i; i < maxI; ++i) {
                require(reserves[2 * i] <= MAX_UINT128, "ByteStorage: too large");
                require(reserves[2 * i + 1] <= MAX_UINT128, "ByteStorage: too large");
                iByte = i * 64;
                assembly {
                    sstore(
                        add(slot, i),
                        add(mload(add(reserves, add(iByte, 32))), shl(128, mload(add(reserves, add(iByte, 64)))))
                    )
                }
            }
            if (reserves.length & 1 == 1) {
                require(reserves[reserves.length - 1] <= MAX_UINT128, "ByteStorage: too large");
                iByte = maxI * 64;
                assembly {
                    sstore(
                        add(slot, maxI),
                        add(mload(add(reserves, add(iByte, 32))), shr(128, shl(128, sload(add(slot, maxI)))))
                    )
                }
            }
        }
    }
    function readUint128(bytes32 slot, uint256 n) internal view returns (uint256[] memory reserves) {
        reserves = new uint256[](n);
        if (n == 2) {
            assembly {
                mstore(add(reserves, 32), shr(128, shl(128, sload(slot))))
                mstore(add(reserves, 64), shr(128, sload(slot)))
            }
            return reserves;
        }
        uint256 iByte;
        for (uint256 i = 1; i <= n; ++i) {
            iByte = (i - 1) / 2;
            if (i & 1 == 1) {
                assembly {
                    mstore(
                        add(reserves, mul(i, 32)),
                        shr(128, shl(128, sload(add(slot, iByte))))
                    )
                }
            } else {
                assembly {
                    mstore(add(reserves, mul(i, 32)), shr(128, sload(add(slot, iByte))))
                }
            }
        }
    }
}
contract Clone {
    uint256 internal constant ONE_WORD = 0x20;
    function _getArgAddress(uint256 argOffset)
        internal
        pure
        returns (address arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }
    function _getArgUint256(uint256 argOffset)
        internal
        pure
        returns (uint256 arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }
    function _getArgUint256Array(uint256 argOffset, uint256 arrLen)
        internal
        pure
      returns (uint256[] memory arr)
    {
        uint256 offset = _getImmutableArgsOffset() + argOffset;
        arr = new uint256[](arrLen);
        assembly {
            calldatacopy(
                add(arr, ONE_WORD),
                offset,
                shl(5, arrLen)
            )
        }
    }
    function _getArgUint64(uint256 argOffset)
        internal
        pure
        returns (uint64 arg)
    {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xc0, calldataload(add(offset, argOffset)))
        }
    }
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        assembly {
            offset := sub(
                calldatasize(),
                shr(0xf0, calldataload(sub(calldatasize(), 2)))
            )
        }
    }
}
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
struct Call {
    address target; 
    bytes data; 
}
interface IWell {
    event Swap(IERC20 fromToken, IERC20 toToken, uint256 amountIn, uint256 amountOut, address recipient);
    event AddLiquidity(uint256[] tokenAmountsIn, uint256 lpAmountOut, address recipient);
    event RemoveLiquidity(uint256 lpAmountIn, uint256[] tokenAmountsOut, address recipient);
    event RemoveLiquidityOneToken(uint256 lpAmountIn, IERC20 tokenOut, uint256 tokenAmountOut, address recipient);
    event Shift(uint256[] reserves, IERC20 toToken, uint256 amountOut, address recipient);
    event Sync(uint256[] reserves, uint256 lpAmountOut, address recipient);
    function tokens() external view returns (IERC20[] memory);
    function wellFunction() external view returns (Call memory);
    function pumps() external view returns (Call[] memory);
    function wellData() external view returns (bytes memory);
    function aquifer() external view returns (address);
    function well()
        external
        view
        returns (
            IERC20[] memory _tokens,
            Call memory _wellFunction,
            Call[] memory _pumps,
            bytes memory _wellData,
            address _aquifer
        );
    function swapFrom(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 amountOut);
    function swapFromFeeOnTransfer(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 amountOut);
    function getSwapOut(IERC20 fromToken, IERC20 toToken, uint256 amountIn) external view returns (uint256 amountOut);
    function swapTo(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 maxAmountIn,
        uint256 amountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 amountIn);
    function getSwapIn(IERC20 fromToken, IERC20 toToken, uint256 amountOut) external view returns (uint256 amountIn);
    function shift(IERC20 tokenOut, uint256 minAmountOut, address recipient) external returns (uint256 amountOut);
    function getShiftOut(IERC20 tokenOut) external returns (uint256 amountOut);
    function addLiquidity(
        uint256[] memory tokenAmountsIn,
        uint256 minLpAmountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 lpAmountOut);
    function addLiquidityFeeOnTransfer(
        uint256[] memory tokenAmountsIn,
        uint256 minLpAmountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 lpAmountOut);
    function getAddLiquidityOut(uint256[] memory tokenAmountsIn) external view returns (uint256 lpAmountOut);
    function removeLiquidity(
        uint256 lpAmountIn,
        uint256[] calldata minTokenAmountsOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256[] memory tokenAmountsOut);
    function getRemoveLiquidityOut(uint256 lpAmountIn) external view returns (uint256[] memory tokenAmountsOut);
    function removeLiquidityOneToken(
        uint256 lpAmountIn,
        IERC20 tokenOut,
        uint256 minTokenAmountOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 tokenAmountOut);
    function getRemoveLiquidityOneTokenOut(
        uint256 lpAmountIn,
        IERC20 tokenOut
    ) external view returns (uint256 tokenAmountOut);
    function removeLiquidityImbalanced(
        uint256 maxLpAmountIn,
        uint256[] calldata tokenAmountsOut,
        address recipient,
        uint256 deadline
    ) external returns (uint256 lpAmountIn);
    function getRemoveLiquidityImbalancedIn(uint256[] calldata tokenAmountsOut)
        external
        view
        returns (uint256 lpAmountIn);
    function sync(address recipient, uint256 minLpAmountOut) external returns (uint256 lpAmountOut);
    function getSyncOut() external view returns (uint256 lpAmountOut);
    function skim(address recipient) external returns (uint256[] memory skimAmounts);
    function getReserves() external view returns (uint256[] memory reserves);
    function isInitialized() external view returns (bool);
}
interface IWellErrors {
    error SlippageOut(uint256 amountOut, uint256 minAmountOut);
    error SlippageIn(uint256 amountIn, uint256 maxAmountIn);
    error InvalidTokens();
    error InvalidReserves();
    error DuplicateTokens(IERC20 token);
    error Expired();
}
abstract contract ReentrancyGuardUpgradeable is Initializable {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }
    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
    uint256[49] private __gap;
}
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }
    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
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
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }
    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}
library ECDSAUpgradeable {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV 
    }
    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; 
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }
        return (signer, RecoverError.NoError);
    }
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC20_init_unchained(name_, symbol_);
    }
    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    uint256[45] private __gap;
}
interface IAquifer {
    error InitFailed(string reason);
    error InvalidConfig();
    error WellNotInitialized();
    error InvalidSalt();
    event BoreWell(
        address well, address implementation, IERC20[] tokens, Call wellFunction, Call[] pumps, bytes wellData
    );
    function boreWell(
        address implementation,
        bytes calldata immutableData,
        bytes calldata initFunctionCall,
        bytes32 salt
    ) external returns (address wellAddress);
    function wellImplementation(address well) external view returns (address implementation);
}
contract ClonePlus is Clone {
    function _getArgIERC20Array(uint256 argOffset, uint256 arrLen) internal pure returns (IERC20[] memory arr) {
        uint256 offset = _getImmutableArgsOffset() + argOffset;
        arr = new IERC20[](arrLen);
        assembly {
            calldatacopy(add(arr, ONE_WORD), offset, shl(5, arrLen))
        }
    }
    function _getArgBytes(uint256 argOffset, uint256 bytesLen) internal pure returns (bytes memory data) {
        if (bytesLen == 0) return data;
        uint256 offset = _getImmutableArgsOffset() + argOffset;
        data = new bytes(bytesLen);
        assembly {
            calldatacopy(add(data, ONE_WORD), offset, bytesLen)
        }
    }
}
abstract contract ERC1967UpgradeUpgradeable is Initializable, IERC1967Upgradeable {
    function __ERC1967Upgrade_init() internal onlyInitializing {
    }
    function __ERC1967Upgrade_init_unchained() internal onlyInitializing {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }
    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }
    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }
    function _upgradeToAndCall(address newImplementation, bytes memory data, bool forceCall) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(newImplementation, data);
        }
    }
    function _upgradeToAndCallUUPS(address newImplementation, bytes memory data, bool forceCall) internal {
        if (StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT).value) {
            _setImplementation(newImplementation);
        } else {
            try IERC1822ProxiableUpgradeable(newImplementation).proxiableUUID() returns (bytes32 slot) {
                require(slot == _IMPLEMENTATION_SLOT, "ERC1967Upgrade: unsupported proxiableUUID");
            } catch {
                revert("ERC1967Upgrade: new implementation is not UUPS");
            }
            _upgradeToAndCall(newImplementation, data, forceCall);
        }
    }
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;
    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }
    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }
    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;
    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }
    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }
    function _upgradeBeaconToAndCall(address newBeacon, bytes memory data, bool forceCall) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            AddressUpgradeable.functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }
    uint256[50] private __gap;
}
abstract contract UUPSUpgradeable is Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal onlyInitializing {
    }
    function __UUPSUpgradeable_init_unchained() internal onlyInitializing {
    }
    address private immutable __self = address(this);
    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }
    modifier notDelegated() {
        require(address(this) == __self, "UUPSUpgradeable: must not be called through delegatecall");
        _;
    }
    function proxiableUUID() external view virtual override notDelegated returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
    function upgradeTo(address newImplementation) public virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}
abstract contract EIP712Upgradeable is Initializable, IERC5267Upgradeable {
    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private _hashedName;
    bytes32 private _hashedVersion;
    string private _name;
    string private _version;
    function __EIP712_init(string memory name, string memory version) internal onlyInitializing {
        __EIP712_init_unchained(name, version);
    }
    function __EIP712_init_unchained(string memory name, string memory version) internal onlyInitializing {
        _name = name;
        _version = version;
        _hashedName = 0;
        _hashedVersion = 0;
    }
    function _domainSeparatorV4() internal view returns (bytes32) {
        return _buildDomainSeparator();
    }
    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _EIP712NameHash(), _EIP712VersionHash(), block.chainid, address(this)));
    }
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSAUpgradeable.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        require(_hashedName == 0 && _hashedVersion == 0, "EIP712: Uninitialized");
        return (
            hex"0f", 
            _EIP712Name(),
            _EIP712Version(),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }
    function _EIP712Name() internal virtual view returns (string memory) {
        return _name;
    }
    function _EIP712Version() internal virtual view returns (string memory) {
        return _version;
    }
    function _EIP712NameHash() internal view returns (bytes32) {
        string memory name = _EIP712Name();
        if (bytes(name).length > 0) {
            return keccak256(bytes(name));
        } else {
            bytes32 hashedName = _hashedName;
            if (hashedName != 0) {
                return hashedName;
            } else {
                return keccak256("");
            }
        }
    }
    function _EIP712VersionHash() internal view returns (bytes32) {
        string memory version = _EIP712Version();
        if (bytes(version).length > 0) {
            return keccak256(bytes(version));
        } else {
            bytes32 hashedVersion = _hashedVersion;
            if (hashedVersion != 0) {
                return hashedVersion;
            } else {
                return keccak256("");
            }
        }
    }
    uint256[48] private __gap;
}
abstract contract ERC20PermitUpgradeable is Initializable, ERC20Upgradeable, IERC20PermitUpgradeable, EIP712Upgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;
    mapping(address => CountersUpgradeable.Counter) private _nonces;
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;
    function __ERC20Permit_init(string memory name) internal onlyInitializing {
        __EIP712_init_unchained(name, "1");
    }
    function __ERC20Permit_init_unchained(string memory) internal onlyInitializing {}
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSAUpgradeable.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");
        _approve(owner, spender, value);
    }
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        CountersUpgradeable.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
    uint256[49] private __gap;
}
contract Well is ERC20PermitUpgradeable, IWell, IWellErrors, ReentrancyGuardUpgradeable, ClonePlus {
    using SafeERC20 for IERC20;
    uint256 private constant PACKED_ADDRESS = 20;
    uint256 private constant ONE_WORD_PLUS_PACKED_ADDRESS = 52; 
    bytes32 private constant RESERVES_STORAGE_SLOT = 0x4bba01c388049b5ebd30398b65e8ad45b632802c5faf4964e58085ea8ab03715; 
    constructor() {
        _disableInitializers();
    }
    function init(string memory _name, string memory _symbol) external virtual initializer {
        __ERC20Permit_init(_name);
        __ERC20_init(_name, _symbol);
        __ReentrancyGuard_init();
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        for (uint256 i; i < tokensLength - 1; ++i) {
            for (uint256 j = i + 1; j < tokensLength; ++j) {
                if (_tokens[i] == _tokens[j]) {
                    revert DuplicateTokens(_tokens[i]);
                }
            }
        }
    }
    function isInitialized() external view returns (bool) {
        return _getInitializedVersion() > 0;
    }
    uint256 private constant LOC_AQUIFER_ADDR = 0;
    uint256 private constant LOC_TOKENS_COUNT = 20; 
    uint256 private constant LOC_WELL_FUNCTION_ADDR = 52; 
    uint256 private constant LOC_WELL_FUNCTION_DATA_LENGTH = 72; 
    uint256 private constant LOC_PUMPS_COUNT = 104; 
    uint256 private constant LOC_VARIABLE = 136; 
    function tokens() public pure returns (IERC20[] memory _tokens) {
        _tokens = _getArgIERC20Array(LOC_VARIABLE, numberOfTokens());
    }
    function wellFunction() public pure returns (Call memory _wellFunction) {
        _wellFunction.target = wellFunctionAddress();
        _wellFunction.data = _getArgBytes(LOC_VARIABLE + numberOfTokens() * ONE_WORD, wellFunctionDataLength());
    }
    function pumps() public pure returns (Call[] memory _pumps) {
        uint256 _numberOfPumps = numberOfPumps();
        if (_numberOfPumps == 0) return _pumps;
        _pumps = new Call[](_numberOfPumps);
        uint256 dataLoc = LOC_VARIABLE + numberOfTokens() * ONE_WORD + wellFunctionDataLength();
        uint256 pumpDataLength;
        for (uint256 i; i < _pumps.length; ++i) {
            _pumps[i].target = _getArgAddress(dataLoc);
            dataLoc += PACKED_ADDRESS;
            pumpDataLength = _getArgUint256(dataLoc);
            dataLoc += ONE_WORD;
            _pumps[i].data = _getArgBytes(dataLoc, pumpDataLength);
            dataLoc += pumpDataLength;
        }
    }
    function wellData() public pure returns (bytes memory) {}
    function aquifer() public pure override returns (address) {
        return _getArgAddress(LOC_AQUIFER_ADDR);
    }
    function well()
        external
        pure
        returns (
            IERC20[] memory _tokens,
            Call memory _wellFunction,
            Call[] memory _pumps,
            bytes memory _wellData,
            address _aquifer
        )
    {
        _tokens = tokens();
        _wellFunction = wellFunction();
        _pumps = pumps();
        _wellData = wellData();
        _aquifer = aquifer();
    }
    function numberOfTokens() public pure returns (uint256) {
        return _getArgUint256(LOC_TOKENS_COUNT);
    }
    function wellFunctionAddress() public pure returns (address) {
        return _getArgAddress(LOC_WELL_FUNCTION_ADDR);
    }
    function wellFunctionDataLength() public pure returns (uint256) {
        return _getArgUint256(LOC_WELL_FUNCTION_DATA_LENGTH);
    }
    function numberOfPumps() public pure returns (uint256) {
        return _getArgUint256(LOC_PUMPS_COUNT);
    }
    function firstPump() public pure returns (Call memory _pump) {
        uint256 dataLoc = LOC_VARIABLE + numberOfTokens() * ONE_WORD + wellFunctionDataLength();
        _pump.target = _getArgAddress(dataLoc);
        _pump.data = _getArgBytes(dataLoc + ONE_WORD_PLUS_PACKED_ADDRESS, _getArgUint256(dataLoc + PACKED_ADDRESS));
    }
    function swapFrom(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256 amountOut) {
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        amountOut = _swapFrom(fromToken, toToken, amountIn, minAmountOut, recipient);
    }
    function swapFromFeeOnTransfer(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256 amountOut) {
        amountIn = _safeTransferFromFeeOnTransfer(fromToken, msg.sender, amountIn);
        amountOut = _swapFrom(fromToken, toToken, amountIn, minAmountOut, recipient);
    }
    function _swapFrom(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountIn,
        uint256 minAmountOut,
        address recipient
    ) internal returns (uint256 amountOut) {
        IERC20[] memory _tokens = tokens();
        (uint256 i, uint256 j) = _getIJ(_tokens, fromToken, toToken);
        uint256[] memory reserves = _updatePumps(_tokens.length);
        reserves[i] += amountIn;
        uint256 reserveJBefore = reserves[j];
        reserves[j] = _calcReserve(wellFunction(), reserves, j, totalSupply());
        amountOut = reserveJBefore - reserves[j];
        if (amountOut < minAmountOut) {
            revert SlippageOut(amountOut, minAmountOut);
        }
        toToken.safeTransfer(recipient, amountOut);
        emit Swap(fromToken, toToken, amountIn, amountOut, recipient);
        _setReserves(_tokens, reserves);
    }
    function getSwapOut(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountIn
    ) external view readOnlyNonReentrant returns (uint256 amountOut) {
        IERC20[] memory _tokens = tokens();
        (uint256 i, uint256 j) = _getIJ(_tokens, fromToken, toToken);
        uint256[] memory reserves = _getReserves(_tokens.length);
        reserves[i] += amountIn;
        amountOut = reserves[j] - _calcReserve(wellFunction(), reserves, j, totalSupply());
    }
    function swapTo(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 maxAmountIn,
        uint256 amountOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256 amountIn) {
        IERC20[] memory _tokens = tokens();
        (uint256 i, uint256 j) = _getIJ(_tokens, fromToken, toToken);
        uint256[] memory reserves = _updatePumps(_tokens.length);
        reserves[j] -= amountOut;
        uint256 reserveIBefore = reserves[i];
        reserves[i] = _calcReserve(wellFunction(), reserves, i, totalSupply());
        amountIn = reserves[i] - reserveIBefore;
        if (amountIn > maxAmountIn) {
            revert SlippageIn(amountIn, maxAmountIn);
        }
        _swapTo(fromToken, toToken, amountIn, amountOut, recipient);
        _setReserves(_tokens, reserves);
    }
    function _swapTo(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountIn,
        uint256 amountOut,
        address recipient
    ) internal {
        fromToken.safeTransferFrom(msg.sender, address(this), amountIn);
        toToken.safeTransfer(recipient, amountOut);
        emit Swap(fromToken, toToken, amountIn, amountOut, recipient);
    }
    function getSwapIn(
        IERC20 fromToken,
        IERC20 toToken,
        uint256 amountOut
    ) external view readOnlyNonReentrant returns (uint256 amountIn) {
        IERC20[] memory _tokens = tokens();
        (uint256 i, uint256 j) = _getIJ(_tokens, fromToken, toToken);
        uint256[] memory reserves = _getReserves(_tokens.length);
        reserves[j] -= amountOut;
        amountIn = _calcReserve(wellFunction(), reserves, i, totalSupply()) - reserves[i];
    }
    function shift(
        IERC20 tokenOut,
        uint256 minAmountOut,
        address recipient
    ) external nonReentrant returns (uint256 amountOut) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        _updatePumps(tokensLength);
        uint256[] memory reserves = new uint256[](tokensLength);
        for (uint256 i; i < tokensLength; ++i) {
            reserves[i] = _tokens[i].balanceOf(address(this));
        }
        uint256 j = _getJ(_tokens, tokenOut);
        amountOut = reserves[j] - _calcReserve(wellFunction(), reserves, j, totalSupply());
        if (amountOut >= minAmountOut) {
            tokenOut.safeTransfer(recipient, amountOut);
            reserves[j] -= amountOut;
            _setReserves(_tokens, reserves);
            emit Shift(reserves, tokenOut, amountOut, recipient);
        } else {
            revert SlippageOut(amountOut, minAmountOut);
        }
    }
    function getShiftOut(IERC20 tokenOut) external view readOnlyNonReentrant returns (uint256 amountOut) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = new uint256[](tokensLength);
        for (uint256 i; i < tokensLength; ++i) {
            reserves[i] = _tokens[i].balanceOf(address(this));
        }
        uint256 j = _getJ(_tokens, tokenOut);
        amountOut = reserves[j] - _calcReserve(wellFunction(), reserves, j, totalSupply());
    }
    function addLiquidity(
        uint256[] memory tokenAmountsIn,
        uint256 minLpAmountOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256 lpAmountOut) {
        lpAmountOut = _addLiquidity(tokenAmountsIn, minLpAmountOut, recipient, false);
    }
    function addLiquidityFeeOnTransfer(
        uint256[] memory tokenAmountsIn,
        uint256 minLpAmountOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256 lpAmountOut) {
        lpAmountOut = _addLiquidity(tokenAmountsIn, minLpAmountOut, recipient, true);
    }
    function _addLiquidity(
        uint256[] memory tokenAmountsIn,
        uint256 minLpAmountOut,
        address recipient,
        bool feeOnTransfer
    ) internal returns (uint256 lpAmountOut) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = _updatePumps(tokensLength);
        uint256 _tokenAmountIn;
        if (feeOnTransfer) {
            for (uint256 i; i < tokensLength; ++i) {
                _tokenAmountIn = tokenAmountsIn[i];
                if (_tokenAmountIn == 0) continue;
                _tokenAmountIn = _safeTransferFromFeeOnTransfer(_tokens[i], msg.sender, _tokenAmountIn);
                reserves[i] += _tokenAmountIn;
                tokenAmountsIn[i] = _tokenAmountIn;
            }
        } else {
            for (uint256 i; i < tokensLength; ++i) {
                _tokenAmountIn = tokenAmountsIn[i];
                if (_tokenAmountIn == 0) continue;
                _tokens[i].safeTransferFrom(msg.sender, address(this), _tokenAmountIn);
                reserves[i] += _tokenAmountIn;
            }
        }
        lpAmountOut = _calcLpTokenSupply(wellFunction(), reserves) - totalSupply();
        if (lpAmountOut < minLpAmountOut) {
            revert SlippageOut(lpAmountOut, minLpAmountOut);
        }
        _mint(recipient, lpAmountOut);
        _setReserves(_tokens, reserves);
        emit AddLiquidity(tokenAmountsIn, lpAmountOut, recipient);
    }
    function getAddLiquidityOut(uint256[] memory tokenAmountsIn)
        external
        view
        readOnlyNonReentrant
        returns (uint256 lpAmountOut)
    {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = _getReserves(tokensLength);
        for (uint256 i; i < tokensLength; ++i) {
            reserves[i] += tokenAmountsIn[i];
        }
        lpAmountOut = _calcLpTokenSupply(wellFunction(), reserves) - totalSupply();
    }
    function removeLiquidity(
        uint256 lpAmountIn,
        uint256[] calldata minTokenAmountsOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256[] memory tokenAmountsOut) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = _updatePumps(tokensLength);
        tokenAmountsOut = _calcLPTokenUnderlying(wellFunction(), lpAmountIn, reserves, totalSupply());
        _burn(msg.sender, lpAmountIn);
        uint256 _tokenAmountOut;
        for (uint256 i; i < tokensLength; ++i) {
            _tokenAmountOut = tokenAmountsOut[i];
            if (_tokenAmountOut < minTokenAmountsOut[i]) {
                revert SlippageOut(_tokenAmountOut, minTokenAmountsOut[i]);
            }
            _tokens[i].safeTransfer(recipient, _tokenAmountOut);
            reserves[i] -= _tokenAmountOut;
        }
        _setReserves(_tokens, reserves);
        emit RemoveLiquidity(lpAmountIn, tokenAmountsOut, recipient);
    }
    function getRemoveLiquidityOut(uint256 lpAmountIn)
        external
        view
        readOnlyNonReentrant
        returns (uint256[] memory tokenAmountsOut)
    {
        IERC20[] memory _tokens = tokens();
        uint256[] memory reserves = _getReserves(_tokens.length);
        uint256 lpTokenSupply = totalSupply();
        tokenAmountsOut = _calcLPTokenUnderlying(wellFunction(), lpAmountIn, reserves, lpTokenSupply);
    }
    function removeLiquidityOneToken(
        uint256 lpAmountIn,
        IERC20 tokenOut,
        uint256 minTokenAmountOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256 tokenAmountOut) {
        IERC20[] memory _tokens = tokens();
        uint256[] memory reserves = _updatePumps(_tokens.length);
        uint256 j = _getJ(_tokens, tokenOut);
        tokenAmountOut = _getRemoveLiquidityOneTokenOut(lpAmountIn, j, reserves);
        if (tokenAmountOut < minTokenAmountOut) {
            revert SlippageOut(tokenAmountOut, minTokenAmountOut);
        }
        _burn(msg.sender, lpAmountIn);
        tokenOut.safeTransfer(recipient, tokenAmountOut);
        reserves[j] -= tokenAmountOut;
        _setReserves(_tokens, reserves);
        emit RemoveLiquidityOneToken(lpAmountIn, tokenOut, tokenAmountOut, recipient);
    }
    function getRemoveLiquidityOneTokenOut(
        uint256 lpAmountIn,
        IERC20 tokenOut
    ) external view readOnlyNonReentrant returns (uint256 tokenAmountOut) {
        IERC20[] memory _tokens = tokens();
        uint256[] memory reserves = _getReserves(_tokens.length);
        tokenAmountOut = _getRemoveLiquidityOneTokenOut(lpAmountIn, _getJ(_tokens, tokenOut), reserves);
    }
    function _getRemoveLiquidityOneTokenOut(
        uint256 lpAmountIn,
        uint256 j,
        uint256[] memory reserves
    ) private view returns (uint256 tokenAmountOut) {
        uint256 newReserveJ = _calcReserve(wellFunction(), reserves, j, totalSupply() - lpAmountIn);
        tokenAmountOut = reserves[j] - newReserveJ;
    }
    function removeLiquidityImbalanced(
        uint256 maxLpAmountIn,
        uint256[] calldata tokenAmountsOut,
        address recipient,
        uint256 deadline
    ) external nonReentrant expire(deadline) returns (uint256 lpAmountIn) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = _updatePumps(tokensLength);
        uint256 _tokenAmountOut;
        for (uint256 i; i < tokensLength; ++i) {
            _tokenAmountOut = tokenAmountsOut[i];
            _tokens[i].safeTransfer(recipient, _tokenAmountOut);
            reserves[i] -= _tokenAmountOut;
        }
        lpAmountIn = totalSupply() - _calcLpTokenSupply(wellFunction(), reserves);
        if (lpAmountIn > maxLpAmountIn) {
            revert SlippageIn(lpAmountIn, maxLpAmountIn);
        }
        _burn(msg.sender, lpAmountIn);
        _setReserves(_tokens, reserves);
        emit RemoveLiquidity(lpAmountIn, tokenAmountsOut, recipient);
    }
    function getRemoveLiquidityImbalancedIn(uint256[] calldata tokenAmountsOut)
        external
        view
        readOnlyNonReentrant
        returns (uint256 lpAmountIn)
    {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = _getReserves(tokensLength);
        for (uint256 i; i < tokensLength; ++i) {
            reserves[i] -= tokenAmountsOut[i];
        }
        lpAmountIn = totalSupply() - _calcLpTokenSupply(wellFunction(), reserves);
    }
    function sync(address recipient, uint256 minLpAmountOut) external nonReentrant returns (uint256 lpAmountOut) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        _updatePumps(tokensLength);
        uint256[] memory reserves = new uint256[](tokensLength);
        for (uint256 i; i < tokensLength; ++i) {
            reserves[i] = _tokens[i].balanceOf(address(this));
        }
        uint256 newTokenSupply = _calcLpTokenSupply(wellFunction(), reserves);
        uint256 oldTokenSupply = totalSupply();
        if (newTokenSupply > oldTokenSupply) {
            lpAmountOut = newTokenSupply - oldTokenSupply;
            _mint(recipient, lpAmountOut);
        }
        if (lpAmountOut < minLpAmountOut) {
            revert SlippageOut(lpAmountOut, minLpAmountOut);
        }
        _setReserves(_tokens, reserves);
        emit Sync(reserves, lpAmountOut, recipient);
    }
    function getSyncOut() external view readOnlyNonReentrant returns (uint256 lpAmountOut) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = new uint256[](tokensLength);
        for (uint256 i; i < tokensLength; ++i) {
            reserves[i] = _tokens[i].balanceOf(address(this));
        }
        uint256 newTokenSupply = _calcLpTokenSupply(wellFunction(), reserves);
        uint256 oldTokenSupply = totalSupply();
        if (newTokenSupply > oldTokenSupply) {
            lpAmountOut = newTokenSupply - oldTokenSupply;
        }
    }
    function skim(address recipient) external nonReentrant returns (uint256[] memory skimAmounts) {
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        uint256[] memory reserves = _getReserves(tokensLength);
        skimAmounts = new uint256[](tokensLength);
        for (uint256 i; i < tokensLength; ++i) {
            skimAmounts[i] = _tokens[i].balanceOf(address(this)) - reserves[i];
            if (skimAmounts[i] > 0) {
                _tokens[i].safeTransfer(recipient, skimAmounts[i]);
            }
        }
    }
    function getReserves() external view readOnlyNonReentrant returns (uint256[] memory reserves) {
        reserves = _getReserves(numberOfTokens());
    }
    function _getReserves(uint256 _numberOfTokens) internal view returns (uint256[] memory reserves) {
        reserves = LibBytes.readUint128(RESERVES_STORAGE_SLOT, _numberOfTokens);
    }
    function _setReserves(IERC20[] memory _tokens, uint256[] memory reserves) internal {
        for (uint256 i; i < reserves.length; ++i) {
            if (reserves[i] > _tokens[i].balanceOf(address(this))) {
                revert InvalidReserves();
            }
        }
        LibBytes.storeUint128(RESERVES_STORAGE_SLOT, reserves);
    }
    function _updatePumps(uint256 _numberOfTokens) internal returns (uint256[] memory reserves) {
        reserves = _getReserves(_numberOfTokens);
        uint256 _numberOfPumps = numberOfPumps();
        if (_numberOfPumps == 0) {
            return reserves;
        }
        if (_numberOfPumps == 1) {
            Call memory _pump = firstPump();
            try IPump(_pump.target).update(reserves, _pump.data) {}
            catch {
            }
        } else {
            Call[] memory _pumps = pumps();
            for (uint256 i; i < _pumps.length; ++i) {
                try IPump(_pumps[i].target).update(reserves, _pumps[i].data) {}
                catch {
                }
            }
        }
    }
    function _calcLpTokenSupply(
        Call memory _wellFunction,
        uint256[] memory reserves
    ) internal view returns (uint256 lpTokenSupply) {
        lpTokenSupply = IWellFunction(_wellFunction.target).calcLpTokenSupply(reserves, _wellFunction.data);
    }
    function _calcReserve(
        Call memory _wellFunction,
        uint256[] memory reserves,
        uint256 j,
        uint256 lpTokenSupply
    ) internal view returns (uint256 reserve) {
        reserve = IWellFunction(_wellFunction.target).calcReserve(reserves, j, lpTokenSupply, _wellFunction.data);
    }
    function _calcLPTokenUnderlying(
        Call memory _wellFunction,
        uint256 lpTokenAmount,
        uint256[] memory reserves,
        uint256 lpTokenSupply
    ) internal view returns (uint256[] memory tokenAmounts) {
        tokenAmounts = IWellFunction(_wellFunction.target).calcLPTokenUnderlying(
            lpTokenAmount, reserves, lpTokenSupply, _wellFunction.data
        );
    }
    function _getIJ(
        IERC20[] memory _tokens,
        IERC20 iToken,
        IERC20 jToken
    ) internal pure returns (uint256 i, uint256 j) {
        bool foundOne;
        for (uint256 k; k < _tokens.length; ++k) {
            if (iToken == _tokens[k]) {
                i = k;
                if (foundOne) return (i, j);
                foundOne = true;
            } else if (jToken == _tokens[k]) {
                j = k;
                if (foundOne) return (i, j);
                foundOne = true;
            }
        }
        revert InvalidTokens();
    }
    function _getJ(IERC20[] memory _tokens, IERC20 jToken) internal pure returns (uint256 j) {
        for (j; j < _tokens.length; ++j) {
            if (jToken == _tokens[j]) {
                return j;
            }
        }
        revert InvalidTokens();
    }
    function _safeTransferFromFeeOnTransfer(
        IERC20 token,
        address from,
        uint256 amount
    ) internal returns (uint256 amountTransferred) {
        uint256 balanceBefore = token.balanceOf(address(this));
        token.safeTransferFrom(from, address(this), amount);
        amountTransferred = token.balanceOf(address(this)) - balanceBefore;
    }
    modifier expire(uint256 deadline) {
        if (block.timestamp > deadline) {
            revert Expired();
        }
        _;
    }
    modifier readOnlyNonReentrant() {
        require(!_reentrancyGuardEntered(), "ReentrancyGuard: reentrant call");
        _;
    }
}
contract WellUpgradeable is Well, UUPSUpgradeable, OwnableUpgradeable {
    address private immutable ___self = address(this);
    modifier notDelegatedOrIsMinimalProxy() {
        if (address(this) != ___self) {
            address aquifer = aquifer();
            address wellImplmentation = IAquifer(aquifer).wellImplementation(address(this));
            require(wellImplmentation == ___self, "Function must be called by a Well bored by an aquifer");
        } else {
            revert("UUPSUpgradeable: must not be called through delegatecall");
        }
        _;
    }
    function init(string memory _name, string memory _symbol) external override reinitializer(2) {
        __ERC20Permit_init(_name);
        __ERC20_init(_name, _symbol);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __Ownable_init();
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        for (uint256 i; i < tokensLength - 1; ++i) {
            for (uint256 j = i + 1; j < tokensLength; ++j) {
                if (_tokens[i] == _tokens[j]) {
                    revert DuplicateTokens(_tokens[i]);
                }
            }
        }
    }
    function initNoWellToken() external initializer {}
    function _authorizeUpgrade(address newImplmentation) internal view override {
        require(address(this) != ___self, "Function must be called through delegatecall");
        address aquifer = aquifer();
        address activeProxy = IAquifer(aquifer).wellImplementation(_getImplementation());
        require(activeProxy == ___self, "Function must be called through active proxy bored by an aquifer");
        require(
            IAquifer(aquifer).wellImplementation(newImplmentation) != address(0),
            "New implementation must be a well implmentation"
        );
        require(
            UUPSUpgradeable(newImplmentation).proxiableUUID() == _IMPLEMENTATION_SLOT,
            "New implementation must be a valid ERC-1967 implmentation"
        );
    }
    function upgradeTo(address newImplementation) public override {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable override {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function proxiableUUID() external view override notDelegatedOrIsMinimalProxy returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
    function getVersion() external pure virtual returns (uint256) {
        return 1;
    }
    function getInitializerVersion() external view returns (uint256) {
        return _getInitializedVersion();
    }
}