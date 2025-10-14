pragma solidity ^0.8.24;
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
error PRBMath_MulDiv_Overflow(uint256 x, uint256 y, uint256 denominator);
error PRBMath_MulDiv18_Overflow(uint256 x, uint256 y);
error PRBMath_MulDivSigned_InputTooSmall();
error PRBMath_MulDivSigned_Overflow(int256 x, int256 y);
uint128 constant MAX_UINT128 = type(uint128).max;
uint40 constant MAX_UINT40 = type(uint40).max;
uint256 constant UNIT_0 = 1e18;
uint256 constant UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;
uint256 constant UNIT_LPOTD = 262144;
function exp2_0(uint256 x) pure returns (uint256 result) {
    unchecked {
        result = 0x800000000000000000000000000000000000000000000000;
        if (x & 0xFF00000000000000 > 0) {
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
        }
        if (x & 0xFF000000000000 > 0) {
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
        }
        if (x & 0xFF0000000000 > 0) {
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
        }
        if (x & 0xFF00000000 > 0) {
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
        }
        if (x & 0xFF000000 > 0) {
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
        }
        if (x & 0xFF0000 > 0) {
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
        }
        if (x & 0xFF00 > 0) {
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
        }
        if (x & 0xFF > 0) {
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
        }
        result *= UNIT_0;
        result >>= (191 - (x >> 64));
    }
}
function msb(uint256 x) pure returns (uint256 result) {
    assembly ("memory-safe") {
        let factor := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(5, gt(x, 0xFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(4, gt(x, 0xFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(3, gt(x, 0xFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(2, gt(x, 0xF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(1, gt(x, 0x3))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := gt(x, 0x1)
        result := or(result, factor)
    }
}
function mulDiv(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 result) {
    uint256 prod0; 
    uint256 prod1; 
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }
    if (prod1 == 0) {
        unchecked {
            return prod0 / denominator;
        }
    }
    if (prod1 >= denominator) {
        revert PRBMath_MulDiv_Overflow(x, y, denominator);
    }
    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, denominator)
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
    }
    unchecked {
        uint256 lpotdod = denominator & (~denominator + 1);
        uint256 flippedLpotdod;
        assembly ("memory-safe") {
            denominator := div(denominator, lpotdod)
            prod0 := div(prod0, lpotdod)
            flippedLpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
        }
        prod0 |= prod1 * flippedLpotdod;
        uint256 inverse = (3 * denominator) ^ 2;
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        result = prod0 * inverse;
    }
}
function mulDiv18(uint256 x, uint256 y) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }
    if (prod1 == 0) {
        unchecked {
            return prod0 / UNIT_0;
        }
    }
    if (prod1 >= UNIT_0) {
        revert PRBMath_MulDiv18_Overflow(x, y);
    }
    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, UNIT_0)
        result :=
            mul(
                or(
                    div(sub(prod0, remainder), UNIT_LPOTD),
                    mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
                ),
                UNIT_INVERSE
            )
    }
}
function mulDivSigned(int256 x, int256 y, int256 denominator) pure returns (int256 result) {
    if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
        revert PRBMath_MulDivSigned_InputTooSmall();
    }
    uint256 xAbs;
    uint256 yAbs;
    uint256 dAbs;
    unchecked {
        xAbs = x < 0 ? uint256(-x) : uint256(x);
        yAbs = y < 0 ? uint256(-y) : uint256(y);
        dAbs = denominator < 0 ? uint256(-denominator) : uint256(denominator);
    }
    uint256 resultAbs = mulDiv(xAbs, yAbs, dAbs);
    if (resultAbs > uint256(type(int256).max)) {
        revert PRBMath_MulDivSigned_Overflow(x, y);
    }
    uint256 sx;
    uint256 sy;
    uint256 sd;
    assembly ("memory-safe") {
        sx := sgt(x, sub(0, 1))
        sy := sgt(y, sub(0, 1))
        sd := sgt(denominator, sub(0, 1))
    }
    unchecked {
        result = sx ^ sy ^ sd == 0 ? -int256(resultAbs) : int256(resultAbs);
    }
}
function sqrt_0(uint256 x) pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 2 ** 128) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 2 ** 64) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 2 ** 32) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 2 ** 16) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 2 ** 8) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 2 ** 4) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 2 ** 2) {
        result <<= 1;
    }
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        uint256 roundedResult = x / result;
        if (result >= roundedResult) {
            result = roundedResult;
        }
    }
}
library RingBufferLib {
    function wrap(uint256 _index, uint256 _cardinality) internal pure returns (uint256) {
        return _index % _cardinality;
    }
    function offset(
        uint256 _index,
        uint256 _amount,
        uint256 _count
    ) internal pure returns (uint256) {
        return wrap(_index + _count - _amount, _count);
    }
    function newestIndex(uint256 _nextIndex, uint256 _count)
        internal
        pure
        returns (uint256)
    {
        if (_count == 0) {
            return 0;
        }
        return wrap(_nextIndex + _count - 1, _count);
    }
    function oldestIndex(uint256 _nextIndex, uint256 _count, uint256 _cardinality)
        internal
        pure
        returns (uint256)
    {
        if (_count < _cardinality) {
            return 0;
        } else {
            return wrap(_nextIndex + _cardinality, _cardinality);
        }
    }
    function nextIndex(uint256 _index, uint256 _cardinality)
        internal
        pure
        returns (uint256)
    {
        return wrap(_index + 1, _cardinality);
    }
    function prevIndex(uint256 _index, uint256 _cardinality)
    internal
    pure
    returns (uint256) 
    {
        return _index == 0 ? _cardinality - 1 : _index - 1;
    }
}
error UpperBoundGtZero();
library UniformRandomNumber {
  function uniform(uint256 _entropy, uint256 _upperBound) internal pure returns (uint256) {
    if(_upperBound == 0) {
        revert UpperBoundGtZero();
    }
    uint256 min = (type(uint256).max-_upperBound+1) % _upperBound;
    uint256 random = _entropy;
    while (true) {
      if (random >= min) {
        break;
      }
      random = uint256(keccak256(abi.encodePacked(random)));
    }
    return random % _upperBound;
  }
}
uint16 constant MAX_CARDINALITY = 17520; 
library ObservationLib {
  struct Observation {
    uint128 cumulativeBalance;
    uint96 balance;
    uint32 timestamp;
  }
  function binarySearch(
    Observation[MAX_CARDINALITY] storage _observations,
    uint24 _newestObservationIndex,
    uint24 _oldestObservationIndex,
    uint32 _target,
    uint16 _cardinality
  )
    internal
    view
    returns (
      Observation memory beforeOrAt,
      uint16 beforeOrAtIndex,
      Observation memory afterOrAt,
      uint16 afterOrAtIndex
    )
  {
    uint256 leftSide = _oldestObservationIndex;
    uint256 rightSide = _newestObservationIndex < leftSide
      ? leftSide + _cardinality - 1
      : _newestObservationIndex;
    uint256 currentIndex;
    while (true) {
      currentIndex = (leftSide + rightSide) / 2;
      beforeOrAtIndex = uint16(RingBufferLib.wrap(currentIndex, _cardinality));
      beforeOrAt = _observations[beforeOrAtIndex];
      uint32 beforeOrAtTimestamp = beforeOrAt.timestamp;
      afterOrAtIndex = uint16(RingBufferLib.nextIndex(currentIndex, _cardinality));
      afterOrAt = _observations[afterOrAtIndex];
      bool targetAfterOrAt = beforeOrAtTimestamp <= _target;
      if (targetAfterOrAt && _target <= afterOrAt.timestamp) {
        break;
      }
      if (!targetAfterOrAt) {
        rightSide = currentIndex - 1;
      } else {
        leftSide = currentIndex + 1;
      }
    }
  }
}
type PeriodOffsetRelativeTimestamp is uint32;
error BalanceLTAmount(uint96 balance, uint96 amount, string message);
error DelegateBalanceLTAmount(uint96 delegateBalance, uint96 delegateAmount, string message);
error TimestampNotFinalized(uint256 timestamp, uint256 currentOverwritePeriodStartedAt);
error InvalidTimeRange(uint256 start, uint256 end);
error InsufficientHistory(
  PeriodOffsetRelativeTimestamp requestedTimestamp,
  PeriodOffsetRelativeTimestamp oldestTimestamp
);
library TwabLib {
  struct AccountDetails {
    uint96 balance;
    uint96 delegateBalance;
    uint16 nextObservationIndex;
    uint16 cardinality;
  }
  struct Account {
    AccountDetails details;
    ObservationLib.Observation[17520] observations;
  }
  function increaseBalances(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    Account storage _account,
    uint96 _amount,
    uint96 _delegateAmount
  )
    internal
    returns (
      ObservationLib.Observation memory observation,
      bool isNew,
      bool isObservationRecorded,
      AccountDetails memory accountDetails
    )
  {
    accountDetails = _account.details;
    isObservationRecorded =
      _delegateAmount != uint96(0) &&
      block.timestamp <= lastObservationAt(PERIOD_LENGTH, PERIOD_OFFSET);
    accountDetails.balance += _amount;
    accountDetails.delegateBalance += _delegateAmount;
    if (isObservationRecorded) {
      (observation, isNew, accountDetails) = _recordObservation(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        accountDetails,
        _account
      );
    }
    _account.details = accountDetails;
  }
  function decreaseBalances(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    Account storage _account,
    uint96 _amount,
    uint96 _delegateAmount,
    string memory _revertMessage
  )
    internal
    returns (
      ObservationLib.Observation memory observation,
      bool isNew,
      bool isObservationRecorded,
      AccountDetails memory accountDetails
    )
  {
    accountDetails = _account.details;
    if (accountDetails.balance < _amount) {
      revert BalanceLTAmount(accountDetails.balance, _amount, _revertMessage);
    }
    if (accountDetails.delegateBalance < _delegateAmount) {
      revert DelegateBalanceLTAmount(
        accountDetails.delegateBalance,
        _delegateAmount,
        _revertMessage
      );
    }
    isObservationRecorded =
      _delegateAmount != uint96(0) &&
      block.timestamp <= lastObservationAt(PERIOD_LENGTH, PERIOD_OFFSET);
    unchecked {
      accountDetails.balance -= _amount;
      accountDetails.delegateBalance -= _delegateAmount;
    }
    if (isObservationRecorded) {
      (observation, isNew, accountDetails) = _recordObservation(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        accountDetails,
        _account
      );
    }
    _account.details = accountDetails;
  }
  function getOldestObservation(
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails
  ) internal view returns (uint16 index, ObservationLib.Observation memory observation) {
    if (_accountDetails.cardinality < MAX_CARDINALITY) {
      index = 0;
      observation = _observations[0];
    } else {
      index = _accountDetails.nextObservationIndex;
      observation = _observations[index];
    }
  }
  function getNewestObservation(
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails
  ) internal view returns (uint16 index, ObservationLib.Observation memory observation) {
    index = uint16(
      RingBufferLib.newestIndex(_accountDetails.nextObservationIndex, MAX_CARDINALITY)
    );
    observation = _observations[index];
  }
  function getBalanceAt(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint256 _targetTime
  ) internal view requireFinalized(PERIOD_LENGTH, PERIOD_OFFSET, _targetTime) returns (uint256) {
    if (_targetTime < PERIOD_OFFSET) {
      return 0;
    }
    if (isShutdownAt(_targetTime, PERIOD_LENGTH, PERIOD_OFFSET)) {
      return 0;
    }
    ObservationLib.Observation memory prevOrAtObservation = _getPreviousOrAtObservation(
      _observations,
      _accountDetails,
      PeriodOffsetRelativeTimestamp.wrap(uint32(_targetTime - PERIOD_OFFSET))
    );
    return prevOrAtObservation.balance;
  }
  function isShutdownAt(
    uint256 timestamp,
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET
  ) internal pure returns (bool) {
    return timestamp > lastObservationAt(PERIOD_LENGTH, PERIOD_OFFSET);
  }
  function lastObservationAt(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET
  ) internal pure returns (uint256) {
    return uint256(PERIOD_OFFSET) + (type(uint32).max / PERIOD_LENGTH) * PERIOD_LENGTH;
  }
  function getTwabBetween(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint256 _startTime,
    uint256 _endTime
  ) internal view requireFinalized(PERIOD_LENGTH, PERIOD_OFFSET, _endTime) returns (uint256) {
    if (_endTime < _startTime) {
      revert InvalidTimeRange(_startTime, _endTime);
    }
    if (isShutdownAt(_endTime, PERIOD_LENGTH, PERIOD_OFFSET)) {
      return 0;
    }
    uint256 offsetStartTime = _startTime - PERIOD_OFFSET;
    uint256 offsetEndTime = _endTime - PERIOD_OFFSET;
    ObservationLib.Observation memory endObservation = _getPreviousOrAtObservation(
      _observations,
      _accountDetails,
      PeriodOffsetRelativeTimestamp.wrap(uint32(offsetEndTime))
    );
    if (offsetStartTime == offsetEndTime) {
      return endObservation.balance;
    }
    ObservationLib.Observation memory startObservation = _getPreviousOrAtObservation(
      _observations,
      _accountDetails,
      PeriodOffsetRelativeTimestamp.wrap(uint32(offsetStartTime))
    );
    if (startObservation.timestamp != offsetStartTime) {
      startObservation = _calculateTemporaryObservation(
        startObservation,
        PeriodOffsetRelativeTimestamp.wrap(uint32(offsetStartTime))
      );
    }
    if (endObservation.timestamp != offsetEndTime) {
      endObservation = _calculateTemporaryObservation(
        endObservation,
        PeriodOffsetRelativeTimestamp.wrap(uint32(offsetEndTime))
      );
    }
    return
      (endObservation.cumulativeBalance - startObservation.cumulativeBalance) /
      (offsetEndTime - offsetStartTime);
  }
  function _recordObservation(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    AccountDetails memory _accountDetails,
    Account storage _account
  )
    internal
    returns (
      ObservationLib.Observation memory observation,
      bool isNew,
      AccountDetails memory newAccountDetails
    )
  {
    PeriodOffsetRelativeTimestamp currentTime = PeriodOffsetRelativeTimestamp.wrap(
      uint32(block.timestamp - PERIOD_OFFSET)
    );
    uint16 nextIndex;
    ObservationLib.Observation memory newestObservation;
    (nextIndex, newestObservation, isNew) = _getNextObservationIndex(
      PERIOD_LENGTH,
      PERIOD_OFFSET,
      _account.observations,
      _accountDetails
    );
    if (isNew) {
      _accountDetails.nextObservationIndex = uint16(
        RingBufferLib.nextIndex(uint256(nextIndex), MAX_CARDINALITY)
      );
      _accountDetails.cardinality = _accountDetails.cardinality < MAX_CARDINALITY
        ? _accountDetails.cardinality + 1
        : MAX_CARDINALITY;
    }
    observation = ObservationLib.Observation({
      cumulativeBalance: _extrapolateFromBalance(newestObservation, currentTime),
      balance: _accountDetails.delegateBalance,
      timestamp: PeriodOffsetRelativeTimestamp.unwrap(currentTime)
    });
    _account.observations[nextIndex] = observation;
    newAccountDetails = _accountDetails;
  }
  function _calculateTemporaryObservation(
    ObservationLib.Observation memory _observation,
    PeriodOffsetRelativeTimestamp _time
  ) private pure returns (ObservationLib.Observation memory) {
    return
      ObservationLib.Observation({
        cumulativeBalance: _extrapolateFromBalance(_observation, _time),
        balance: _observation.balance,
        timestamp: PeriodOffsetRelativeTimestamp.unwrap(_time)
      });
  }
  function _getNextObservationIndex(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails
  )
    private
    view
    returns (uint16 index, ObservationLib.Observation memory newestObservation, bool isNew)
  {
    uint16 newestIndex;
    (newestIndex, newestObservation) = getNewestObservation(_observations, _accountDetails);
    uint256 currentPeriod = getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, block.timestamp);
    uint256 newestObservationPeriod = getTimestampPeriod(
      PERIOD_LENGTH,
      PERIOD_OFFSET,
      PERIOD_OFFSET + uint256(newestObservation.timestamp)
    );
    if (_accountDetails.cardinality == 0 || currentPeriod > newestObservationPeriod) {
      return (_accountDetails.nextObservationIndex, newestObservation, true);
    }
    return (newestIndex, newestObservation, false);
  }
  function _currentOverwritePeriodStartedAt(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET
  ) private view returns (uint256) {
    uint256 period = getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, block.timestamp);
    return getPeriodStartTime(PERIOD_LENGTH, PERIOD_OFFSET, period);
  }
  function _extrapolateFromBalance(
    ObservationLib.Observation memory _observation,
    PeriodOffsetRelativeTimestamp _offsetTimestamp
  ) private pure returns (uint128) {
    unchecked {
      return
        uint128(
          uint256(_observation.cumulativeBalance) +
            uint256(_observation.balance) *
            (PeriodOffsetRelativeTimestamp.unwrap(_offsetTimestamp) - _observation.timestamp)
        );
    }
  }
  function currentOverwritePeriodStartedAt(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET
  ) internal view returns (uint256) {
    return _currentOverwritePeriodStartedAt(PERIOD_LENGTH, PERIOD_OFFSET);
  }
  function getTimestampPeriod(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint256 _timestamp
  ) internal pure returns (uint256) {
    if (_timestamp <= PERIOD_OFFSET) {
      return 0;
    }
    return (_timestamp - PERIOD_OFFSET) / uint256(PERIOD_LENGTH);
  }
  function getPeriodStartTime(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint256 _period
  ) internal pure returns (uint256) {
    return _period * PERIOD_LENGTH + PERIOD_OFFSET;
  }
  function getPeriodEndTime(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint256 _period
  ) internal pure returns (uint256) {
    return (_period + 1) * PERIOD_LENGTH + PERIOD_OFFSET;
  }
  function getPreviousOrAtObservation(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint256 _targetTime
  ) internal view returns (ObservationLib.Observation memory prevOrAtObservation) {
    if (_targetTime < PERIOD_OFFSET) {
      return ObservationLib.Observation({ cumulativeBalance: 0, balance: 0, timestamp: 0 });
    }
    uint256 offsetTargetTime = _targetTime - PERIOD_OFFSET;
    if (offsetTargetTime > type(uint32).max) {
      return
        ObservationLib.Observation({
          cumulativeBalance: 0,
          balance: 0,
          timestamp: type(uint32).max
        });
    }
    prevOrAtObservation = _getPreviousOrAtObservation(
      _observations,
      _accountDetails,
      PeriodOffsetRelativeTimestamp.wrap(uint32(offsetTargetTime))
    );
  }
  function _getPreviousOrAtObservation(
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    PeriodOffsetRelativeTimestamp _offsetTargetTime
  ) private view returns (ObservationLib.Observation memory prevOrAtObservation) {
    if (_accountDetails.cardinality == 0) {
      return ObservationLib.Observation({ cumulativeBalance: 0, balance: 0, timestamp: 0 });
    }
    uint16 oldestTwabIndex;
    (oldestTwabIndex, prevOrAtObservation) = getOldestObservation(_observations, _accountDetails);
    if (PeriodOffsetRelativeTimestamp.unwrap(_offsetTargetTime) < prevOrAtObservation.timestamp) {
      if (_accountDetails.cardinality < MAX_CARDINALITY) {
        return
          ObservationLib.Observation({
            cumulativeBalance: 0,
            balance: 0,
            timestamp: PeriodOffsetRelativeTimestamp.unwrap(_offsetTargetTime)
          });
      } else {
        revert InsufficientHistory(
          _offsetTargetTime,
          PeriodOffsetRelativeTimestamp.wrap(prevOrAtObservation.timestamp)
        );
      }
    }
    if (_accountDetails.cardinality == 1) {
      return prevOrAtObservation;
    }
    (
      uint16 newestTwabIndex,
      ObservationLib.Observation memory afterOrAtObservation
    ) = getNewestObservation(_observations, _accountDetails);
    if (PeriodOffsetRelativeTimestamp.unwrap(_offsetTargetTime) >= afterOrAtObservation.timestamp) {
      return afterOrAtObservation;
    }
    if (_accountDetails.cardinality == 2) {
      return prevOrAtObservation;
    }
    (prevOrAtObservation, oldestTwabIndex, afterOrAtObservation, newestTwabIndex) = ObservationLib
      .binarySearch(
        _observations,
        newestTwabIndex,
        oldestTwabIndex,
        PeriodOffsetRelativeTimestamp.unwrap(_offsetTargetTime),
        _accountDetails.cardinality
      );
    if (afterOrAtObservation.timestamp == PeriodOffsetRelativeTimestamp.unwrap(_offsetTargetTime)) {
      return afterOrAtObservation;
    }
    return prevOrAtObservation;
  }
  function hasFinalized(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint256 _time
  ) internal view returns (bool) {
    return _hasFinalized(PERIOD_LENGTH, PERIOD_OFFSET, _time);
  }
  function _hasFinalized(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint256 _time
  ) private view returns (bool) {
    return _time <= _currentOverwritePeriodStartedAt(PERIOD_LENGTH, PERIOD_OFFSET);
  }
  modifier requireFinalized(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint256 _timestamp
  ) {
    uint256 overwritePeriodStartTime = _currentOverwritePeriodStartedAt(
      PERIOD_LENGTH,
      PERIOD_OFFSET
    );
    if (_timestamp > overwritePeriodStartTime) {
      revert TimestampNotFinalized(_timestamp, overwritePeriodStartTime);
    }
    _;
  }
}
uint16 constant MAX_OBSERVATION_CARDINALITY = 366;
error AddToDrawZero();
error DrawAwarded(uint24 drawId, uint24 newestDrawId);
error InvalidDrawRange(uint24 startDrawId, uint24 endDrawId);
struct Observation {
  uint96 available;
  uint160 disbursed;
}
struct RingBufferInfo {
  uint16 nextIndex;
  uint16 cardinality;
}
library DrawAccumulatorLib {
  struct Accumulator {
    RingBufferInfo ringBufferInfo; 
    uint24[366] drawRingBuffer; 
    mapping(uint256 drawId => Observation observation) observations;
  }
  function add(
    Accumulator storage accumulator,
    uint256 _amount,
    uint24 _drawId
  ) internal returns (bool) {
    if (_drawId == 0) {
      revert AddToDrawZero();
    }
    RingBufferInfo memory ringBufferInfo = accumulator.ringBufferInfo;
    uint24 newestDrawId_ = accumulator.drawRingBuffer[
      RingBufferLib.newestIndex(ringBufferInfo.nextIndex, MAX_OBSERVATION_CARDINALITY)
    ];
    if (_drawId < newestDrawId_) {
      revert DrawAwarded(_drawId, newestDrawId_);
    }
    mapping(uint256 drawId => Observation observation) storage accumulatorObservations = accumulator
      .observations;
    Observation memory newestObservation_ = accumulatorObservations[newestDrawId_];
    if (_drawId != newestDrawId_) {
      uint16 cardinality = ringBufferInfo.cardinality;
      if (ringBufferInfo.cardinality < MAX_OBSERVATION_CARDINALITY) {
        cardinality += 1;
      } else {
        delete accumulatorObservations[accumulator.drawRingBuffer[ringBufferInfo.nextIndex]];
      }
      accumulator.drawRingBuffer[ringBufferInfo.nextIndex] = _drawId;
      accumulatorObservations[_drawId] = Observation({
        available: SafeCast.toUint96(_amount),
        disbursed: SafeCast.toUint160(
          newestObservation_.disbursed +
            newestObservation_.available
        )
      });
      accumulator.ringBufferInfo = RingBufferInfo({
        nextIndex: uint16(RingBufferLib.nextIndex(ringBufferInfo.nextIndex, MAX_OBSERVATION_CARDINALITY)),
        cardinality: cardinality
      });
      return true;
    } else {
      accumulatorObservations[newestDrawId_] = Observation({
        available: SafeCast.toUint96(newestObservation_.available + _amount),
        disbursed: newestObservation_.disbursed
      });
      return false;
    }
  }
  function newestDrawId(Accumulator storage accumulator) internal view returns (uint256) {
    return
      accumulator.drawRingBuffer[
        RingBufferLib.newestIndex(accumulator.ringBufferInfo.nextIndex, MAX_OBSERVATION_CARDINALITY)
      ];
  }
  function newestObservation(Accumulator storage accumulator) internal view returns (Observation memory) {
    return accumulator.observations[
      newestDrawId(accumulator)
    ];
  }
  function getDisbursedBetween(
    Accumulator storage _accumulator,
    uint24 _startDrawId,
    uint24 _endDrawId
  ) internal view returns (uint256) {
    if (_startDrawId > _endDrawId) {
      revert InvalidDrawRange(_startDrawId, _endDrawId);
    }
    RingBufferInfo memory ringBufferInfo = _accumulator.ringBufferInfo;
    if (ringBufferInfo.cardinality == 0) {
      return 0;
    }
    uint16 oldestIndex = uint16(
      RingBufferLib.oldestIndex(
        ringBufferInfo.nextIndex,
        ringBufferInfo.cardinality,
        MAX_OBSERVATION_CARDINALITY
      )
    );
    uint16 newestIndex = uint16(
      RingBufferLib.newestIndex(ringBufferInfo.nextIndex, ringBufferInfo.cardinality)
    );
    uint24 oldestDrawId = _accumulator.drawRingBuffer[oldestIndex];
    uint24 _newestDrawId = _accumulator.drawRingBuffer[newestIndex];
    if (_endDrawId < oldestDrawId || _startDrawId > _newestDrawId) {
      return 0;
    }
    Observation memory atOrAfterStart;
    if (_startDrawId <= oldestDrawId || ringBufferInfo.cardinality == 1) {
      atOrAfterStart = _accumulator.observations[oldestDrawId];
    } else {
      atOrAfterStart = _accumulator.observations[_startDrawId];
      if (atOrAfterStart.available == 0 && atOrAfterStart.disbursed == 0) {
        (, , , uint24 afterOrAtDrawId) = binarySearch(
          _accumulator.drawRingBuffer,
          oldestIndex,
          newestIndex,
          ringBufferInfo.cardinality,
          _startDrawId
        );
        atOrAfterStart = _accumulator.observations[afterOrAtDrawId];
      }
    }
    Observation memory atOrBeforeEnd;
    if (_endDrawId >= _newestDrawId || ringBufferInfo.cardinality == 1) {
      atOrBeforeEnd = _accumulator.observations[_newestDrawId];
    } else {
      atOrBeforeEnd = _accumulator.observations[_endDrawId];
      if (atOrBeforeEnd.available == 0 && atOrBeforeEnd.disbursed == 0) {
        (, uint24 beforeOrAtDrawId, , ) = binarySearch(
          _accumulator.drawRingBuffer,
          oldestIndex,
          newestIndex,
          ringBufferInfo.cardinality,
          _endDrawId
        );
        atOrBeforeEnd = _accumulator.observations[beforeOrAtDrawId];
      }
    }
    return atOrBeforeEnd.available + atOrBeforeEnd.disbursed - atOrAfterStart.disbursed;
  }
  function binarySearch(
    uint24[366] storage _drawRingBuffer,
    uint16 _oldestIndex,
    uint16 _newestIndex,
    uint16 _cardinality,
    uint24 _targetDrawId
  )
    internal
    view
    returns (
      uint16 beforeOrAtIndex,
      uint24 beforeOrAtDrawId,
      uint16 afterOrAtIndex,
      uint24 afterOrAtDrawId
    )
  {
    uint16 leftSide = _oldestIndex;
    uint16 rightSide = _newestIndex < leftSide ? leftSide + _cardinality - 1 : _newestIndex;
    uint16 currentIndex;
    while (true) {
      currentIndex = (leftSide + rightSide) / 2;
      beforeOrAtIndex = uint16(RingBufferLib.wrap(currentIndex, _cardinality));
      beforeOrAtDrawId = _drawRingBuffer[beforeOrAtIndex];
      afterOrAtIndex = uint16(RingBufferLib.nextIndex(currentIndex, _cardinality));
      afterOrAtDrawId = _drawRingBuffer[afterOrAtIndex];
      bool targetAtOrAfter = beforeOrAtDrawId <= _targetDrawId;
      if (targetAtOrAfter && _targetDrawId <= afterOrAtDrawId) {
        break;
      }
      if (!targetAtOrAfter) {
        rightSide = currentIndex - 1;
      } else {
        leftSide = currentIndex + 1;
      }
    }
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
error SameDelegateAlreadySet(address delegate);
error CannotTransferToSponsorshipAddress();
error PeriodLengthTooShort();
error PeriodOffsetInFuture(uint32 periodOffset);
error TransferToZeroAddress();
uint32 constant MINIMUM_PERIOD_LENGTH = 1 hours;
address constant SPONSORSHIP_ADDRESS = address(1);
contract TwabController {
  using SafeCast for uint256;
  uint32 public immutable PERIOD_LENGTH;
  uint32 public immutable PERIOD_OFFSET;
  mapping(address => mapping(address => TwabLib.Account)) internal userObservations;
  mapping(address => TwabLib.Account) internal totalSupplyObservations;
  mapping(address => mapping(address => address)) internal delegates;
  event IncreasedBalance(
    address indexed vault,
    address indexed user,
    uint96 amount,
    uint96 delegateAmount
  );
  event DecreasedBalance(
    address indexed vault,
    address indexed user,
    uint96 amount,
    uint96 delegateAmount
  );
  event ObservationRecorded(
    address indexed vault,
    address indexed user,
    uint96 balance,
    uint96 delegateBalance,
    bool isNew,
    ObservationLib.Observation observation
  );
  event Delegated(address indexed vault, address indexed delegator, address indexed delegate);
  event IncreasedTotalSupply(address indexed vault, uint96 amount, uint96 delegateAmount);
  event DecreasedTotalSupply(address indexed vault, uint96 amount, uint96 delegateAmount);
  event TotalSupplyObservationRecorded(
    address indexed vault,
    uint96 balance,
    uint96 delegateBalance,
    bool isNew,
    ObservationLib.Observation observation
  );
  constructor(uint32 _periodLength, uint32 _periodOffset) {
    if (_periodLength < MINIMUM_PERIOD_LENGTH) {
      revert PeriodLengthTooShort();
    }
    if (_periodOffset > block.timestamp) {
      revert PeriodOffsetInFuture(_periodOffset);
    }
    PERIOD_LENGTH = _periodLength;
    PERIOD_OFFSET = _periodOffset;
  }
  function isShutdownAt(uint256 timestamp) external view returns (bool) {
    return TwabLib.isShutdownAt(timestamp, PERIOD_LENGTH, PERIOD_OFFSET);
  }
  function lastObservationAt() external view returns (uint256) {
    return TwabLib.lastObservationAt(PERIOD_LENGTH, PERIOD_OFFSET);
  }
  function getAccount(address vault, address user) external view returns (TwabLib.Account memory) {
    return userObservations[vault][user];
  }
  function getTotalSupplyAccount(address vault) external view returns (TwabLib.Account memory) {
    return totalSupplyObservations[vault];
  }
  function balanceOf(address vault, address user) external view returns (uint256) {
    return userObservations[vault][user].details.balance;
  }
  function totalSupply(address vault) external view returns (uint256) {
    return totalSupplyObservations[vault].details.balance;
  }
  function totalSupplyDelegateBalance(address vault) external view returns (uint256) {
    return totalSupplyObservations[vault].details.delegateBalance;
  }
  function delegateOf(address vault, address user) external view returns (address) {
    return _delegateOf(vault, user);
  }
  function delegateBalanceOf(address vault, address user) external view returns (uint256) {
    return userObservations[vault][user].details.delegateBalance;
  }
  function getBalanceAt(
    address vault,
    address user,
    uint256 periodEndOnOrAfterTime
  ) external view returns (uint256) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return
      TwabLib.getBalanceAt(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account.observations,
        _account.details,
        _periodEndOnOrAfter(periodEndOnOrAfterTime)
      );
  }
  function getTotalSupplyAt(
    address vault,
    uint256 periodEndOnOrAfterTime
  ) external view returns (uint256) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return
      TwabLib.getBalanceAt(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account.observations,
        _account.details,
        _periodEndOnOrAfter(periodEndOnOrAfterTime)
      );
  }
  function getTwabBetween(
    address vault,
    address user,
    uint256 startTime,
    uint256 endTime
  ) external view returns (uint256) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return
      TwabLib.getTwabBetween(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account.observations,
        _account.details,
        _periodEndOnOrAfter(startTime),
        _periodEndOnOrAfter(endTime)
      );
  }
  function getTotalSupplyTwabBetween(
    address vault,
    uint256 startTime,
    uint256 endTime
  ) external view returns (uint256) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return
      TwabLib.getTwabBetween(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account.observations,
        _account.details,
        _periodEndOnOrAfter(startTime),
        _periodEndOnOrAfter(endTime)
      );
  }
  function periodEndOnOrAfter(uint256 _timestamp) external view returns (uint256) {
    return _periodEndOnOrAfter(_timestamp);
  }
  function _periodEndOnOrAfter(uint256 _timestamp) internal view returns (uint256) {
    if (_timestamp < PERIOD_OFFSET) {
      return PERIOD_OFFSET;
    }
    if ((_timestamp - PERIOD_OFFSET) % PERIOD_LENGTH == 0) {
      return _timestamp;
    }
    uint256 period = TwabLib.getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, _timestamp);
    return TwabLib.getPeriodEndTime(PERIOD_LENGTH, PERIOD_OFFSET, period);
  }
  function getNewestObservation(
    address vault,
    address user
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return TwabLib.getNewestObservation(_account.observations, _account.details);
  }
  function getOldestObservation(
    address vault,
    address user
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return TwabLib.getOldestObservation(_account.observations, _account.details);
  }
  function getNewestTotalSupplyObservation(
    address vault
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return TwabLib.getNewestObservation(_account.observations, _account.details);
  }
  function getOldestTotalSupplyObservation(
    address vault
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return TwabLib.getOldestObservation(_account.observations, _account.details);
  }
  function getTimestampPeriod(uint256 time) external view returns (uint256) {
    return TwabLib.getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, time);
  }
  function hasFinalized(uint256 time) external view returns (bool) {
    return TwabLib.hasFinalized(PERIOD_LENGTH, PERIOD_OFFSET, time);
  }
  function currentOverwritePeriodStartedAt() external view returns (uint256) {
    return TwabLib.currentOverwritePeriodStartedAt(PERIOD_LENGTH, PERIOD_OFFSET);
  }
  function mint(address _to, uint96 _amount) external {
    if (_to == address(0)) {
      revert TransferToZeroAddress();
    }
    _transferBalance(msg.sender, address(0), _to, _amount);
  }
  function burn(address _from, uint96 _amount) external {
    _transferBalance(msg.sender, _from, address(0), _amount);
  }
  function transfer(address _from, address _to, uint96 _amount) external {
    if (_to == address(0)) {
      revert TransferToZeroAddress();
    }
    _transferBalance(msg.sender, _from, _to, _amount);
  }
  function delegate(address _vault, address _to) external {
    _delegate(_vault, msg.sender, _to);
  }
  function sponsor(address _from) external {
    _delegate(msg.sender, _from, SPONSORSHIP_ADDRESS);
  }
  function _transferBalance(address _vault, address _from, address _to, uint96 _amount) internal {
    if (_to == SPONSORSHIP_ADDRESS) {
      revert CannotTransferToSponsorshipAddress();
    }
    if (_from == _to) {
      return;
    }
    address _fromDelegate = _delegateOf(_vault, _from);
    address _toDelegate = _delegateOf(_vault, _to);
    if (_from != address(0)) {
      bool _isFromDelegate = _fromDelegate == _from;
      _decreaseBalances(_vault, _from, _amount, _isFromDelegate ? _amount : 0);
      if (!_isFromDelegate && _fromDelegate != SPONSORSHIP_ADDRESS) {
        _decreaseBalances(_vault, _fromDelegate, 0, _amount);
      }
      if (
        _to == address(0) ||
        (_toDelegate == SPONSORSHIP_ADDRESS && _fromDelegate != SPONSORSHIP_ADDRESS)
      ) {
        _decreaseTotalSupplyBalances(
          _vault,
          _to == address(0) ? _amount : 0,
          (_to == address(0) && _fromDelegate != SPONSORSHIP_ADDRESS) ||
            (_toDelegate == SPONSORSHIP_ADDRESS && _fromDelegate != SPONSORSHIP_ADDRESS)
            ? _amount
            : 0
        );
      }
    }
    if (_to != address(0)) {
      bool _isToDelegate = _toDelegate == _to;
      _increaseBalances(_vault, _to, _amount, _isToDelegate ? _amount : 0);
      if (!_isToDelegate && _toDelegate != SPONSORSHIP_ADDRESS) {
        _increaseBalances(_vault, _toDelegate, 0, _amount);
      }
      if (
        _from == address(0) ||
        (_fromDelegate == SPONSORSHIP_ADDRESS && _toDelegate != SPONSORSHIP_ADDRESS)
      ) {
        _increaseTotalSupplyBalances(
          _vault,
          _from == address(0) ? _amount : 0,
          (_from == address(0) && _toDelegate != SPONSORSHIP_ADDRESS) ||
            (_fromDelegate == SPONSORSHIP_ADDRESS && _toDelegate != SPONSORSHIP_ADDRESS)
            ? _amount
            : 0
        );
      }
    }
  }
  function _delegateOf(address _vault, address _user) internal view returns (address) {
    address _userDelegate;
    if (_user != address(0)) {
      _userDelegate = delegates[_vault][_user];
      if (_userDelegate == address(0)) {
        _userDelegate = _user;
      }
    }
    return _userDelegate;
  }
  function _transferDelegateBalance(
    address _vault,
    address _fromDelegate,
    address _toDelegate,
    uint96 _amount
  ) internal {
    if (_fromDelegate != address(0) && _fromDelegate != SPONSORSHIP_ADDRESS) {
      _decreaseBalances(_vault, _fromDelegate, 0, _amount);
      if (_toDelegate == address(0) || _toDelegate == SPONSORSHIP_ADDRESS) {
        _decreaseTotalSupplyBalances(_vault, 0, _amount);
      }
    }
    if (_toDelegate != address(0) && _toDelegate != SPONSORSHIP_ADDRESS) {
      _increaseBalances(_vault, _toDelegate, 0, _amount);
      if (_fromDelegate == address(0) || _fromDelegate == SPONSORSHIP_ADDRESS) {
        _increaseTotalSupplyBalances(_vault, 0, _amount);
      }
    }
  }
  function _delegate(address _vault, address _from, address _to) internal {
    address _currentDelegate = _delegateOf(_vault, _from);
    address to = _to == address(0) ? SPONSORSHIP_ADDRESS : _to;
    if (to == _currentDelegate) {
      revert SameDelegateAlreadySet(to);
    }
    delegates[_vault][_from] = to;
    _transferDelegateBalance(
      _vault,
      _currentDelegate,
      _to,
      SafeCast.toUint96(userObservations[_vault][_from].details.balance)
    );
    emit Delegated(_vault, _from, to);
  }
  function _increaseBalances(
    address _vault,
    address _user,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = userObservations[_vault][_user];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded,
      TwabLib.AccountDetails memory accountDetails
    ) = TwabLib.increaseBalances(PERIOD_LENGTH, PERIOD_OFFSET, _account, _amount, _delegateAmount);
    if (_amount != 0 || _delegateAmount != 0) {
      emit IncreasedBalance(_vault, _user, _amount, _delegateAmount);
    }
    if (_isObservationRecorded) {
      emit ObservationRecorded(
        _vault,
        _user,
        accountDetails.balance,
        accountDetails.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
  function _decreaseBalances(
    address _vault,
    address _user,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = userObservations[_vault][_user];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded,
      TwabLib.AccountDetails memory accountDetails
    ) = TwabLib.decreaseBalances(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account,
        _amount,
        _delegateAmount,
        "TC/observation-burn-lt-delegate-balance"
      );
    if (_amount != 0 || _delegateAmount != 0) {
      emit DecreasedBalance(_vault, _user, _amount, _delegateAmount);
    }
    if (_isObservationRecorded) {
      emit ObservationRecorded(
        _vault,
        _user,
        accountDetails.balance,
        accountDetails.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
  function _decreaseTotalSupplyBalances(
    address _vault,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = totalSupplyObservations[_vault];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded,
      TwabLib.AccountDetails memory accountDetails
    ) = TwabLib.decreaseBalances(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account,
        _amount,
        _delegateAmount,
        "TC/burn-amount-exceeds-total-supply-balance"
      );
    if (_amount != 0 || _delegateAmount != 0) {
      emit DecreasedTotalSupply(_vault, _amount, _delegateAmount);
    }
    if (_isObservationRecorded) {
      emit TotalSupplyObservationRecorded(
        _vault,
        accountDetails.balance,
        accountDetails.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
  function _increaseTotalSupplyBalances(
    address _vault,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = totalSupplyObservations[_vault];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded,
      TwabLib.AccountDetails memory accountDetails
    ) = TwabLib.increaseBalances(PERIOD_LENGTH, PERIOD_OFFSET, _account, _amount, _delegateAmount);
    if (_amount != 0 || _delegateAmount != 0) {
      emit IncreasedTotalSupply(_vault, _amount, _delegateAmount);
    }
    if (_isObservationRecorded) {
      emit TotalSupplyObservationRecorded(
        _vault,
        accountDetails.balance,
        accountDetails.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
}
function intoSD59x18_0(SD1x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD1x18.unwrap(x)));
}
function intoUD2x18_0(SD1x18 x) pure returns (UD2x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUD2x18_Underflow(x);
    }
    result = UD2x18.wrap(uint64(xInt));
}
function intoUD60x18_0(SD1x18 x) pure returns (UD60x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint64(xInt));
}
function intoUint256_0(SD1x18 x) pure returns (uint256 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUint256_Underflow(x);
    }
    result = uint256(uint64(xInt));
}
function intoUint128_0(SD1x18 x) pure returns (uint128 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUint128_Underflow(x);
    }
    result = uint128(uint64(xInt));
}
function intoUint40_0(SD1x18 x) pure returns (uint40 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUint40_Underflow(x);
    }
    if (xInt > int64(uint64(MAX_UINT40))) {
        revert PRBMath_SD1x18_ToUint40_Overflow(x);
    }
    result = uint40(uint64(xInt));
}
function sd1x18(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
function unwrap_0(SD1x18 x) pure returns (int64 result) {
    result = SD1x18.unwrap(x);
}
function wrap_0(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
SD1x18 constant E_0 = SD1x18.wrap(2_718281828459045235);
int64 constant uMAX_SD1x18 = 9_223372036854775807;
SD1x18 constant MAX_SD1x18 = SD1x18.wrap(uMAX_SD1x18);
int64 constant uMIN_SD1x18 = -9_223372036854775808;
SD1x18 constant MIN_SD1x18 = SD1x18.wrap(uMIN_SD1x18);
SD1x18 constant PI_0 = SD1x18.wrap(3_141592653589793238);
SD1x18 constant UNIT_1 = SD1x18.wrap(1e18);
int64 constant uUNIT_0 = 1e18;
error PRBMath_SD1x18_ToUD2x18_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUD60x18_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUint128_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUint256_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUint40_Overflow(SD1x18 x);
error PRBMath_SD1x18_ToUint40_Underflow(SD1x18 x);
type SD1x18 is int64;
using {
    intoSD59x18_0,
    intoUD2x18_0,
    intoUD60x18_0,
    intoUint256_0,
    intoUint128_0,
    intoUint40_0,
    unwrap_0
} for SD1x18 global;
function intoInt256(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}
function intoSD1x18_0(SD59x18 x) pure returns (SD1x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD1x18) {
        revert PRBMath_SD59x18_IntoSD1x18_Underflow(x);
    }
    if (xInt > uMAX_SD1x18) {
        revert PRBMath_SD59x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xInt));
}
function intoUD2x18_1(SD59x18 x) pure returns (UD2x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUD2x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD2x18))) {
        revert PRBMath_SD59x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(uint256(xInt)));
}
function intoUD60x18_1(SD59x18 x) pure returns (UD60x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint256(xInt));
}
function intoUint256_1(SD59x18 x) pure returns (uint256 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUint256_Underflow(x);
    }
    result = uint256(xInt);
}
function intoUint128_1(SD59x18 x) pure returns (uint128 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUint128_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT128))) {
        revert PRBMath_SD59x18_IntoUint128_Overflow(x);
    }
    result = uint128(uint256(xInt));
}
function intoUint40_1(SD59x18 x) pure returns (uint40 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUint40_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT40))) {
        revert PRBMath_SD59x18_IntoUint40_Overflow(x);
    }
    result = uint40(uint256(xInt));
}
function sd(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
function sd59x18(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
function unwrap_1(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}
function wrap_1(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
SD59x18 constant E_1 = SD59x18.wrap(2_718281828459045235);
int256 constant uEXP_MAX_INPUT_0 = 133_084258667509499440;
SD59x18 constant EXP_MAX_INPUT_0 = SD59x18.wrap(uEXP_MAX_INPUT_0);
int256 constant uEXP_MIN_THRESHOLD = -41_446531673892822322;
SD59x18 constant EXP_MIN_THRESHOLD = SD59x18.wrap(uEXP_MIN_THRESHOLD);
int256 constant uEXP2_MAX_INPUT_0 = 192e18 - 1;
SD59x18 constant EXP2_MAX_INPUT_0 = SD59x18.wrap(uEXP2_MAX_INPUT_0);
int256 constant uEXP2_MIN_THRESHOLD = -59_794705707972522261;
SD59x18 constant EXP2_MIN_THRESHOLD = SD59x18.wrap(uEXP2_MIN_THRESHOLD);
int256 constant uHALF_UNIT_0 = 0.5e18;
SD59x18 constant HALF_UNIT_0 = SD59x18.wrap(uHALF_UNIT_0);
int256 constant uLOG2_10_0 = 3_321928094887362347;
SD59x18 constant LOG2_10_0 = SD59x18.wrap(uLOG2_10_0);
int256 constant uLOG2_E_0 = 1_442695040888963407;
SD59x18 constant LOG2_E_0 = SD59x18.wrap(uLOG2_E_0);
int256 constant uMAX_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_792003956564819967;
SD59x18 constant MAX_SD59x18 = SD59x18.wrap(uMAX_SD59x18);
int256 constant uMAX_WHOLE_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MAX_WHOLE_SD59x18 = SD59x18.wrap(uMAX_WHOLE_SD59x18);
int256 constant uMIN_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_792003956564819968;
SD59x18 constant MIN_SD59x18 = SD59x18.wrap(uMIN_SD59x18);
int256 constant uMIN_WHOLE_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MIN_WHOLE_SD59x18 = SD59x18.wrap(uMIN_WHOLE_SD59x18);
SD59x18 constant PI_1 = SD59x18.wrap(3_141592653589793238);
int256 constant uUNIT_1 = 1e18;
SD59x18 constant UNIT_2 = SD59x18.wrap(1e18);
int256 constant uUNIT_SQUARED_0 = 1e36;
SD59x18 constant UNIT_SQUARED_0 = SD59x18.wrap(uUNIT_SQUARED_0);
SD59x18 constant ZERO_0 = SD59x18.wrap(0);
error PRBMath_SD59x18_Abs_MinSD59x18();
error PRBMath_SD59x18_Ceil_Overflow(SD59x18 x);
error PRBMath_SD59x18_Convert_Overflow(int256 x);
error PRBMath_SD59x18_Convert_Underflow(int256 x);
error PRBMath_SD59x18_Div_InputTooSmall();
error PRBMath_SD59x18_Div_Overflow(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_Exp_InputTooBig(SD59x18 x);
error PRBMath_SD59x18_Exp2_InputTooBig(SD59x18 x);
error PRBMath_SD59x18_Floor_Underflow(SD59x18 x);
error PRBMath_SD59x18_Gm_NegativeProduct(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_Gm_Overflow(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_IntoSD1x18_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoSD1x18_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUD2x18_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoUD2x18_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUD60x18_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint128_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint128_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint256_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint40_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint40_Underflow(SD59x18 x);
error PRBMath_SD59x18_Log_InputTooSmall(SD59x18 x);
error PRBMath_SD59x18_Mul_InputTooSmall();
error PRBMath_SD59x18_Mul_Overflow(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_Powu_Overflow(SD59x18 x, uint256 y);
error PRBMath_SD59x18_Sqrt_NegativeInput(SD59x18 x);
error PRBMath_SD59x18_Sqrt_Overflow(SD59x18 x);
function add_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap_1(x.unwrap_1() + y.unwrap_1());
}
function and_0(SD59x18 x, int256 bits) pure returns (SD59x18 result) {
    return wrap_1(x.unwrap_1() & bits);
}
function and2_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap_1(x.unwrap_1() & y.unwrap_1());
}
function eq_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap_1() == y.unwrap_1();
}
function gt_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap_1() > y.unwrap_1();
}
function gte_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap_1() >= y.unwrap_1();
}
function isZero_0(SD59x18 x) pure returns (bool result) {
    result = x.unwrap_1() == 0;
}
function lshift_0(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap_1(x.unwrap_1() << bits);
}
function lt_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap_1() < y.unwrap_1();
}
function lte_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap_1() <= y.unwrap_1();
}
function mod_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(x.unwrap_1() % y.unwrap_1());
}
function neq_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = x.unwrap_1() != y.unwrap_1();
}
function not_0(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1(~x.unwrap_1());
}
function or_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(x.unwrap_1() | y.unwrap_1());
}
function rshift_0(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap_1(x.unwrap_1() >> bits);
}
function sub_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(x.unwrap_1() - y.unwrap_1());
}
function unary(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1(-x.unwrap_1());
}
function uncheckedAdd_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap_1(x.unwrap_1() + y.unwrap_1());
    }
}
function uncheckedSub_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap_1(x.unwrap_1() - y.unwrap_1());
    }
}
function uncheckedUnary(SD59x18 x) pure returns (SD59x18 result) {
    unchecked {
        result = wrap_1(-x.unwrap_1());
    }
}
function xor_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(x.unwrap_1() ^ y.unwrap_1());
}
function abs(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt == uMIN_SD59x18) {
        revert PRBMath_SD59x18_Abs_MinSD59x18();
    }
    result = xInt < 0 ? wrap_1(-xInt) : x;
}
function avg_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    int256 yInt = y.unwrap_1();
    unchecked {
        int256 sum = (xInt >> 1) + (yInt >> 1);
        if (sum < 0) {
            assembly ("memory-safe") {
                result := add(sum, and(or(xInt, yInt), 1))
            }
        } else {
            result = wrap_1(sum + (xInt & yInt & 1));
        }
    }
}
function ceil_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt > uMAX_WHOLE_SD59x18) {
        revert PRBMath_SD59x18_Ceil_Overflow(x);
    }
    int256 remainder = xInt % uUNIT_1;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            int256 resultInt = xInt - remainder;
            if (xInt > 0) {
                resultInt += uUNIT_1;
            }
            result = wrap_1(resultInt);
        }
    }
}
function div_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    int256 yInt = y.unwrap_1();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert PRBMath_SD59x18_Div_InputTooSmall();
    }
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }
    uint256 resultAbs = mulDiv(xAbs, uint256(uUNIT_1), yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert PRBMath_SD59x18_Div_Overflow(x, y);
    }
    bool sameSign = (xInt ^ yInt) > -1;
    unchecked {
        result = wrap_1(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}
function exp_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt < uEXP_MIN_THRESHOLD) {
        return ZERO_0;
    }
    if (xInt > uEXP_MAX_INPUT_0) {
        revert PRBMath_SD59x18_Exp_InputTooBig(x);
    }
    unchecked {
        int256 doubleUnitProduct = xInt * uLOG2_E_0;
        result = exp2_1(wrap_1(doubleUnitProduct / uUNIT_1));
    }
}
function exp2_1(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt < 0) {
        if (xInt < uEXP2_MIN_THRESHOLD) {
            return ZERO_0;
        }
        unchecked {
            result = wrap_1(uUNIT_SQUARED_0 / exp2_1(wrap_1(-xInt)).unwrap_1());
        }
    } else {
        if (xInt > uEXP2_MAX_INPUT_0) {
            revert PRBMath_SD59x18_Exp2_InputTooBig(x);
        }
        unchecked {
            uint256 x_192x64 = uint256((xInt << 64) / uUNIT_1);
            result = wrap_1(int256(exp2_0(x_192x64)));
        }
    }
}
function floor_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt < uMIN_WHOLE_SD59x18) {
        revert PRBMath_SD59x18_Floor_Underflow(x);
    }
    int256 remainder = xInt % uUNIT_1;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            int256 resultInt = xInt - remainder;
            if (xInt < 0) {
                resultInt -= uUNIT_1;
            }
            result = wrap_1(resultInt);
        }
    }
}
function frac_0(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1(x.unwrap_1() % uUNIT_1);
}
function gm_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    int256 yInt = y.unwrap_1();
    if (xInt == 0 || yInt == 0) {
        return ZERO_0;
    }
    unchecked {
        int256 xyInt = xInt * yInt;
        if (xyInt / xInt != yInt) {
            revert PRBMath_SD59x18_Gm_Overflow(x, y);
        }
        if (xyInt < 0) {
            revert PRBMath_SD59x18_Gm_NegativeProduct(x, y);
        }
        uint256 resultUint = sqrt_0(uint256(xyInt));
        result = wrap_1(int256(resultUint));
    }
}
function inv_0(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1(uUNIT_SQUARED_0 / x.unwrap_1());
}
function ln_0(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1(log2_0(x).unwrap_1() * uUNIT_1 / uLOG2_E_0);
}
function log10_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt < 0) {
        revert PRBMath_SD59x18_Log_InputTooSmall(x);
    }
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT_1, sub(0, 18)) }
        case 10 { result := mul(uUNIT_1, sub(1, 18)) }
        case 100 { result := mul(uUNIT_1, sub(2, 18)) }
        case 1000 { result := mul(uUNIT_1, sub(3, 18)) }
        case 10000 { result := mul(uUNIT_1, sub(4, 18)) }
        case 100000 { result := mul(uUNIT_1, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT_1, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT_1, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT_1, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT_1, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT_1, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT_1, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT_1, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT_1, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT_1, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT_1, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT_1, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT_1, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT_1 }
        case 100000000000000000000 { result := mul(uUNIT_1, 2) }
        case 1000000000000000000000 { result := mul(uUNIT_1, 3) }
        case 10000000000000000000000 { result := mul(uUNIT_1, 4) }
        case 100000000000000000000000 { result := mul(uUNIT_1, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT_1, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT_1, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT_1, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT_1, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT_1, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT_1, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT_1, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT_1, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT_1, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT_1, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT_1, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT_1, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT_1, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT_1, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT_1, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT_1, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT_1, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT_1, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 58) }
        default { result := uMAX_SD59x18 }
    }
    if (result.unwrap_1() == uMAX_SD59x18) {
        unchecked {
            result = wrap_1(log2_0(x).unwrap_1() * uUNIT_1 / uLOG2_10_0);
        }
    }
}
function log2_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt <= 0) {
        revert PRBMath_SD59x18_Log_InputTooSmall(x);
    }
    unchecked {
        int256 sign;
        if (xInt >= uUNIT_1) {
            sign = 1;
        } else {
            sign = -1;
            xInt = uUNIT_SQUARED_0 / xInt;
        }
        uint256 n = msb(uint256(xInt / uUNIT_1));
        int256 resultInt = int256(n) * uUNIT_1;
        int256 y = xInt >> n;
        if (y == uUNIT_1) {
            return wrap_1(resultInt * sign);
        }
        int256 DOUBLE_UNIT = 2e18;
        for (int256 delta = uHALF_UNIT_0; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT_1;
            if (y >= DOUBLE_UNIT) {
                resultInt = resultInt + delta;
                y >>= 1;
            }
        }
        resultInt *= sign;
        result = wrap_1(resultInt);
    }
}
function mul_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    int256 yInt = y.unwrap_1();
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert PRBMath_SD59x18_Mul_InputTooSmall();
    }
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }
    uint256 resultAbs = mulDiv18(xAbs, yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert PRBMath_SD59x18_Mul_Overflow(x, y);
    }
    bool sameSign = (xInt ^ yInt) > -1;
    unchecked {
        result = wrap_1(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}
function pow_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    int256 yInt = y.unwrap_1();
    if (xInt == 0) {
        return yInt == 0 ? UNIT_2 : ZERO_0;
    }
    else if (xInt == uUNIT_1) {
        return UNIT_2;
    }
    if (yInt == 0) {
        return UNIT_2;
    }
    else if (yInt == uUNIT_1) {
        return x;
    }
    result = exp2_1(mul_0(log2_0(x), y));
}
function powu_0(SD59x18 x, uint256 y) pure returns (SD59x18 result) {
    uint256 xAbs = uint256(abs(x).unwrap_1());
    uint256 resultAbs = y & 1 > 0 ? xAbs : uint256(uUNIT_1);
    uint256 yAux = y;
    for (yAux >>= 1; yAux > 0; yAux >>= 1) {
        xAbs = mulDiv18(xAbs, xAbs);
        if (yAux & 1 > 0) {
            resultAbs = mulDiv18(resultAbs, xAbs);
        }
    }
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert PRBMath_SD59x18_Powu_Overflow(x, y);
    }
    unchecked {
        int256 resultInt = int256(resultAbs);
        bool isNegative = x.unwrap_1() < 0 && y & 1 == 1;
        if (isNegative) {
            resultInt = -resultInt;
        }
        result = wrap_1(resultInt);
    }
}
function sqrt_1(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = x.unwrap_1();
    if (xInt < 0) {
        revert PRBMath_SD59x18_Sqrt_NegativeInput(x);
    }
    if (xInt > uMAX_SD59x18 / uUNIT_1) {
        revert PRBMath_SD59x18_Sqrt_Overflow(x);
    }
    unchecked {
        uint256 resultUint = sqrt_0(uint256(xInt * uUNIT_1));
        result = wrap_1(int256(resultUint));
    }
}
type SD59x18 is int256;
using {
    intoInt256,
    intoSD1x18_0,
    intoUD2x18_1,
    intoUD60x18_1,
    intoUint256_1,
    intoUint128_1,
    intoUint40_1,
    unwrap_1
} for SD59x18 global;
using {
    abs,
    avg_0,
    ceil_0,
    div_0,
    exp_0,
    exp2_1,
    floor_0,
    frac_0,
    gm_0,
    inv_0,
    log10_0,
    log2_0,
    ln_0,
    mul_0,
    pow_0,
    powu_0,
    sqrt_1
} for SD59x18 global;
using {
    add_0,
    and_0,
    eq_0,
    gt_0,
    gte_0,
    isZero_0,
    lshift_0,
    lt_0,
    lte_0,
    mod_0,
    neq_0,
    not_0,
    or_0,
    rshift_0,
    sub_0,
    uncheckedAdd_0,
    uncheckedSub_0,
    uncheckedUnary,
    xor_0
} for SD59x18 global;
using {
    add_0 as +,
    and2_0 as &,
    div_0 as /,
    eq_0 as ==,
    gt_0 as >,
    gte_0 as >=,
    lt_0 as <,
    lte_0 as <=,
    mod_0 as %,
    mul_0 as *,
    neq_0 as !=,
    not_0 as ~,
    or_0 as |,
    sub_0 as -,
    unary as -,
    xor_0 as ^
} for SD59x18 global;
function intoSD1x18_1(UD2x18 x) pure returns (SD1x18 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(uMAX_SD1x18)) {
        revert PRBMath_UD2x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xUint));
}
function intoSD59x18_1(UD2x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD2x18.unwrap(x))));
}
function intoUD60x18_2(UD2x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD2x18.unwrap(x));
}
function intoUint128_2(UD2x18 x) pure returns (uint128 result) {
    result = uint128(UD2x18.unwrap(x));
}
function intoUint256_2(UD2x18 x) pure returns (uint256 result) {
    result = uint256(UD2x18.unwrap(x));
}
function intoUint40_2(UD2x18 x) pure returns (uint40 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(MAX_UINT40)) {
        revert PRBMath_UD2x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}
function ud2x18(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
function unwrap_2(UD2x18 x) pure returns (uint64 result) {
    result = UD2x18.unwrap(x);
}
function wrap_2(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
UD2x18 constant E_2 = UD2x18.wrap(2_718281828459045235);
uint64 constant uMAX_UD2x18 = 18_446744073709551615;
UD2x18 constant MAX_UD2x18 = UD2x18.wrap(uMAX_UD2x18);
UD2x18 constant PI_2 = UD2x18.wrap(3_141592653589793238);
UD2x18 constant UNIT_3 = UD2x18.wrap(1e18);
uint64 constant uUNIT_2 = 1e18;
error PRBMath_UD2x18_IntoSD1x18_Overflow(UD2x18 x);
error PRBMath_UD2x18_IntoUint40_Overflow(UD2x18 x);
type UD2x18 is uint64;
using {
    intoSD1x18_1,
    intoSD59x18_1,
    intoUD60x18_2,
    intoUint256_2,
    intoUint128_2,
    intoUint40_2,
    unwrap_2
} for UD2x18 global;
function intoSD1x18_2(UD60x18 x) pure returns (SD1x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD1x18))) {
        revert PRBMath_UD60x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(uint64(xUint)));
}
function intoUD2x18_2(UD60x18 x) pure returns (UD2x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD2x18) {
        revert PRBMath_UD60x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(xUint));
}
function intoSD59x18_2(UD60x18 x) pure returns (SD59x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(uMAX_SD59x18)) {
        revert PRBMath_UD60x18_IntoSD59x18_Overflow(x);
    }
    result = SD59x18.wrap(int256(xUint));
}
function intoUint256_3(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}
function intoUint128_3(UD60x18 x) pure returns (uint128 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT128) {
        revert PRBMath_UD60x18_IntoUint128_Overflow(x);
    }
    result = uint128(xUint);
}
function intoUint40_3(UD60x18 x) pure returns (uint40 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT40) {
        revert PRBMath_UD60x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}
function ud(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
function ud60x18(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
function unwrap_3(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}
function wrap_3(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
UD60x18 constant E_3 = UD60x18.wrap(2_718281828459045235);
uint256 constant uEXP_MAX_INPUT_1 = 133_084258667509499440;
UD60x18 constant EXP_MAX_INPUT_1 = UD60x18.wrap(uEXP_MAX_INPUT_1);
uint256 constant uEXP2_MAX_INPUT_1 = 192e18 - 1;
UD60x18 constant EXP2_MAX_INPUT_1 = UD60x18.wrap(uEXP2_MAX_INPUT_1);
uint256 constant uHALF_UNIT_1 = 0.5e18;
UD60x18 constant HALF_UNIT_1 = UD60x18.wrap(uHALF_UNIT_1);
uint256 constant uLOG2_10_1 = 3_321928094887362347;
UD60x18 constant LOG2_10_1 = UD60x18.wrap(uLOG2_10_1);
uint256 constant uLOG2_E_1 = 1_442695040888963407;
UD60x18 constant LOG2_E_1 = UD60x18.wrap(uLOG2_E_1);
uint256 constant uMAX_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_584007913129639935;
UD60x18 constant MAX_UD60x18 = UD60x18.wrap(uMAX_UD60x18);
uint256 constant uMAX_WHOLE_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_000000000000000000;
UD60x18 constant MAX_WHOLE_UD60x18 = UD60x18.wrap(uMAX_WHOLE_UD60x18);
UD60x18 constant PI_3 = UD60x18.wrap(3_141592653589793238);
uint256 constant uUNIT_3 = 1e18;
UD60x18 constant UNIT_4 = UD60x18.wrap(uUNIT_3);
uint256 constant uUNIT_SQUARED_1 = 1e36;
UD60x18 constant UNIT_SQUARED_1 = UD60x18.wrap(uUNIT_SQUARED_1);
UD60x18 constant ZERO_1 = UD60x18.wrap(0);
error PRBMath_UD60x18_Ceil_Overflow(UD60x18 x);
error PRBMath_UD60x18_Convert_Overflow(uint256 x);
error PRBMath_UD60x18_Exp_InputTooBig(UD60x18 x);
error PRBMath_UD60x18_Exp2_InputTooBig(UD60x18 x);
error PRBMath_UD60x18_Gm_Overflow(UD60x18 x, UD60x18 y);
error PRBMath_UD60x18_IntoSD1x18_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoSD59x18_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoUD2x18_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoUint128_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoUint40_Overflow(UD60x18 x);
error PRBMath_UD60x18_Log_InputTooSmall(UD60x18 x);
error PRBMath_UD60x18_Sqrt_Overflow(UD60x18 x);
function add_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() + y.unwrap_3());
}
function and_1(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() & bits);
}
function and2_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() & y.unwrap_3());
}
function eq_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap_3() == y.unwrap_3();
}
function gt_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap_3() > y.unwrap_3();
}
function gte_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap_3() >= y.unwrap_3();
}
function isZero_1(UD60x18 x) pure returns (bool result) {
    result = x.unwrap_3() == 0;
}
function lshift_1(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() << bits);
}
function lt_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap_3() < y.unwrap_3();
}
function lte_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap_3() <= y.unwrap_3();
}
function mod_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() % y.unwrap_3());
}
function neq_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = x.unwrap_3() != y.unwrap_3();
}
function not_1(UD60x18 x) pure returns (UD60x18 result) {
    result = wrap_3(~x.unwrap_3());
}
function or_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() | y.unwrap_3());
}
function rshift_1(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() >> bits);
}
function sub_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() - y.unwrap_3());
}
function uncheckedAdd_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3(x.unwrap_3() + y.unwrap_3());
    }
}
function uncheckedSub_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3(x.unwrap_3() - y.unwrap_3());
    }
}
function xor_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(x.unwrap_3() ^ y.unwrap_3());
}
function avg_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    uint256 yUint = y.unwrap_3();
    unchecked {
        result = wrap_3((xUint & yUint) + ((xUint ^ yUint) >> 1));
    }
}
function ceil_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    if (xUint > uMAX_WHOLE_UD60x18) {
        revert PRBMath_UD60x18_Ceil_Overflow(x);
    }
    assembly ("memory-safe") {
        let remainder := mod(x, uUNIT_3)
        let delta := sub(uUNIT_3, remainder)
        result := add(x, mul(delta, gt(remainder, 0)))
    }
}
function div_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(mulDiv(x.unwrap_3(), uUNIT_3, y.unwrap_3()));
}
function exp_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    if (xUint > uEXP_MAX_INPUT_1) {
        revert PRBMath_UD60x18_Exp_InputTooBig(x);
    }
    unchecked {
        uint256 doubleUnitProduct = xUint * uLOG2_E_1;
        result = exp2_2(wrap_3(doubleUnitProduct / uUNIT_3));
    }
}
function exp2_2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    if (xUint > uEXP2_MAX_INPUT_1) {
        revert PRBMath_UD60x18_Exp2_InputTooBig(x);
    }
    uint256 x_192x64 = (xUint << 64) / uUNIT_3;
    result = wrap_3(exp2_0(x_192x64));
}
function floor_1(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        let remainder := mod(x, uUNIT_3)
        result := sub(x, mul(remainder, gt(remainder, 0)))
    }
}
function frac_1(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        result := mod(x, uUNIT_3)
    }
}
function gm_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    uint256 yUint = y.unwrap_3();
    if (xUint == 0 || yUint == 0) {
        return ZERO_1;
    }
    unchecked {
        uint256 xyUint = xUint * yUint;
        if (xyUint / xUint != yUint) {
            revert PRBMath_UD60x18_Gm_Overflow(x, y);
        }
        result = wrap_3(sqrt_0(xyUint));
    }
}
function inv_1(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3(uUNIT_SQUARED_1 / x.unwrap_3());
    }
}
function ln_1(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3(log2_1(x).unwrap_3() * uUNIT_3 / uLOG2_E_1);
    }
}
function log10_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    if (xUint < uUNIT_3) {
        revert PRBMath_UD60x18_Log_InputTooSmall(x);
    }
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT_3, sub(0, 18)) }
        case 10 { result := mul(uUNIT_3, sub(1, 18)) }
        case 100 { result := mul(uUNIT_3, sub(2, 18)) }
        case 1000 { result := mul(uUNIT_3, sub(3, 18)) }
        case 10000 { result := mul(uUNIT_3, sub(4, 18)) }
        case 100000 { result := mul(uUNIT_3, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT_3, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT_3, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT_3, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT_3, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT_3, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT_3, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT_3, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT_3, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT_3, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT_3, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT_3, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT_3, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT_3 }
        case 100000000000000000000 { result := mul(uUNIT_3, 2) }
        case 1000000000000000000000 { result := mul(uUNIT_3, 3) }
        case 10000000000000000000000 { result := mul(uUNIT_3, 4) }
        case 100000000000000000000000 { result := mul(uUNIT_3, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT_3, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT_3, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT_3, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT_3, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT_3, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT_3, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT_3, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT_3, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT_3, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT_3, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT_3, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT_3, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT_3, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT_3, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT_3, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT_3, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT_3, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT_3, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 58) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 59) }
        default { result := uMAX_UD60x18 }
    }
    if (result.unwrap_3() == uMAX_UD60x18) {
        unchecked {
            result = wrap_3(log2_1(x).unwrap_3() * uUNIT_3 / uLOG2_10_1);
        }
    }
}
function log2_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    if (xUint < uUNIT_3) {
        revert PRBMath_UD60x18_Log_InputTooSmall(x);
    }
    unchecked {
        uint256 n = msb(xUint / uUNIT_3);
        uint256 resultUint = n * uUNIT_3;
        uint256 y = xUint >> n;
        if (y == uUNIT_3) {
            return wrap_3(resultUint);
        }
        uint256 DOUBLE_UNIT = 2e18;
        for (uint256 delta = uHALF_UNIT_1; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT_3;
            if (y >= DOUBLE_UNIT) {
                resultUint += delta;
                y >>= 1;
            }
        }
        result = wrap_3(resultUint);
    }
}
function mul_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(mulDiv18(x.unwrap_3(), y.unwrap_3()));
}
function pow_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    uint256 yUint = y.unwrap_3();
    if (xUint == 0) {
        return yUint == 0 ? UNIT_4 : ZERO_1;
    }
    else if (xUint == uUNIT_3) {
        return UNIT_4;
    }
    if (yUint == 0) {
        return UNIT_4;
    }
    else if (yUint == uUNIT_3) {
        return x;
    }
    if (xUint > uUNIT_3) {
        result = exp2_2(mul_1(log2_1(x), y));
    }
    else {
        UD60x18 i = wrap_3(uUNIT_SQUARED_1 / xUint);
        UD60x18 w = exp2_2(mul_1(log2_1(i), y));
        result = wrap_3(uUNIT_SQUARED_1 / w.unwrap_3());
    }
}
function powu_1(UD60x18 x, uint256 y) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    uint256 resultUint = y & 1 > 0 ? xUint : uUNIT_3;
    for (y >>= 1; y > 0; y >>= 1) {
        xUint = mulDiv18(xUint, xUint);
        if (y & 1 > 0) {
            resultUint = mulDiv18(resultUint, xUint);
        }
    }
    result = wrap_3(resultUint);
}
function sqrt_2(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = x.unwrap_3();
    unchecked {
        if (xUint > uMAX_UD60x18 / uUNIT_3) {
            revert PRBMath_UD60x18_Sqrt_Overflow(x);
        }
        result = wrap_3(sqrt_0(xUint * uUNIT_3));
    }
}
type UD60x18 is uint256;
using {
    intoSD1x18_2,
    intoUD2x18_2,
    intoSD59x18_2,
    intoUint128_3,
    intoUint256_3,
    intoUint40_3,
    unwrap_3
} for UD60x18 global;
using {
    avg_1,
    ceil_1,
    div_1,
    exp_1,
    exp2_2,
    floor_1,
    frac_1,
    gm_1,
    inv_1,
    ln_1,
    log10_1,
    log2_1,
    mul_1,
    pow_1,
    powu_1,
    sqrt_2
} for UD60x18 global;
using {
    add_1,
    and_1,
    eq_1,
    gt_1,
    gte_1,
    isZero_1,
    lshift_1,
    lt_1,
    lte_1,
    mod_1,
    neq_1,
    not_1,
    or_1,
    rshift_1,
    sub_1,
    uncheckedAdd_1,
    uncheckedSub_1,
    xor_1
} for UD60x18 global;
using {
    add_1 as +,
    and2_1 as &,
    div_1 as /,
    eq_1 as ==,
    gt_1 as >,
    gte_1 as >=,
    lt_1 as <,
    lte_1 as <=,
    or_1 as |,
    mod_1 as %,
    mul_1 as *,
    neq_1 as !=,
    not_1 as ~,
    sub_1 as -,
    xor_1 as ^
} for UD60x18 global;
function convert_0(int256 x) pure returns (SD59x18 result) {
    if (x < uMIN_SD59x18 / uUNIT_1) {
        revert PRBMath_SD59x18_Convert_Underflow(x);
    }
    if (x > uMAX_SD59x18 / uUNIT_1) {
        revert PRBMath_SD59x18_Convert_Overflow(x);
    }
    unchecked {
        result = SD59x18.wrap(x * uUNIT_1);
    }
}
function convert_1(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x) / uUNIT_1;
}
function convert_2(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x) / uUNIT_3;
}
function convert_3(uint256 x) pure returns (UD60x18 result) {
    if (x > uMAX_UD60x18 / uUNIT_3) {
        revert PRBMath_UD60x18_Convert_Overflow(x);
    }
    unchecked {
        result = UD60x18.wrap(x * uUNIT_3);
    }
}
library TierCalculationLib {
  function getTierOdds(
    uint8 _tier,
    uint8 _numberOfTiers,
    uint24 _grandPrizePeriod
  ) internal pure returns (SD59x18) {
    int8 oneMinusNumTiers = 1 - int8(_numberOfTiers);
    return
      sd(1).div_0(sd(int24(_grandPrizePeriod))).pow_0(
        sd(int8(_tier) + oneMinusNumTiers).div_0(sd(oneMinusNumTiers)).sqrt_1()
      );
  }
  function estimatePrizeFrequencyInDraws(SD59x18 _tierOdds, uint24 _grandPrizePeriod) internal pure returns (uint24) {
    uint256 _prizeFrequencyInDraws = uint256(convert_1(sd(1e18).div_0(_tierOdds).ceil_0()));
    return _prizeFrequencyInDraws > _grandPrizePeriod ? _grandPrizePeriod : uint24(_prizeFrequencyInDraws);
  }
  function prizeCount(uint8 _tier) internal pure returns (uint256) {
    return 4 ** _tier;
  }
  function isWinner(
    uint256 _userSpecificRandomNumber,
    uint256 _userTwab,
    uint256 _vaultTwabTotalSupply,
    SD59x18 _vaultContributionFraction,
    SD59x18 _tierOdds
  ) internal pure returns (bool) {
    if (_vaultTwabTotalSupply == 0) {
      return false;
    }
    return
      UniformRandomNumber.uniform(_userSpecificRandomNumber, _vaultTwabTotalSupply) <
      calculateWinningZone(_userTwab, _vaultContributionFraction, _tierOdds);
  }
  function calculatePseudoRandomNumber(
    uint24 _drawId,
    address _vault,
    address _user,
    uint8 _tier,
    uint32 _prizeIndex,
    uint256 _winningRandomNumber
  ) internal pure returns (uint256) {
    return
      uint256(
        keccak256(abi.encode(_drawId, _vault, _user, _tier, _prizeIndex, _winningRandomNumber))
      );
  }
  function calculateWinningZone(
    uint256 _userTwab,
    SD59x18 _vaultContributionFraction,
    SD59x18 _tierOdds
  ) internal pure returns (uint256) {
    return
      uint256(convert_1(convert_0(int256(_userTwab)).mul_0(_tierOdds).mul_0(_vaultContributionFraction)));
  }
  function tierPrizeCountPerDraw(uint8 _tier, SD59x18 _odds) internal pure returns (uint32) {
    return uint32(uint256(unwrap_1(sd(int256(prizeCount(_tier))).mul_0(_odds))));
  }
  function isValidTier(uint8 _tier, uint8 _numberOfTiers) internal pure returns (bool) {
    return _tier < _numberOfTiers;
  }
}
struct Tier {
  uint24 drawId;
  uint104 prizeSize;
  uint128 prizeTokenPerShare;
}
error NumberOfTiersLessThanMinimum(uint8 numTiers);
error NumberOfTiersGreaterThanMaximum(uint8 numTiers);
error TierLiquidityUtilizationRateGreaterThanOne();
error TierLiquidityUtilizationRateCannotBeZero();
error InsufficientLiquidity(uint104 requestedLiquidity);
uint8 constant MINIMUM_NUMBER_OF_TIERS = 4;
uint8 constant MAXIMUM_NUMBER_OF_TIERS = 11;
uint8 constant NUMBER_OF_CANARY_TIERS = 2;
contract TieredLiquidityDistributor {
  event ReserveConsumed(uint256 amount);
  SD59x18 internal immutable TIER_ODDS_0;
  SD59x18 internal immutable TIER_ODDS_EVERY_DRAW;
  SD59x18 internal immutable TIER_ODDS_1_5;
  SD59x18 internal immutable TIER_ODDS_1_6;
  SD59x18 internal immutable TIER_ODDS_2_6;
  SD59x18 internal immutable TIER_ODDS_1_7;
  SD59x18 internal immutable TIER_ODDS_2_7;
  SD59x18 internal immutable TIER_ODDS_3_7;
  SD59x18 internal immutable TIER_ODDS_1_8;
  SD59x18 internal immutable TIER_ODDS_2_8;
  SD59x18 internal immutable TIER_ODDS_3_8;
  SD59x18 internal immutable TIER_ODDS_4_8;
  SD59x18 internal immutable TIER_ODDS_1_9;
  SD59x18 internal immutable TIER_ODDS_2_9;
  SD59x18 internal immutable TIER_ODDS_3_9;
  SD59x18 internal immutable TIER_ODDS_4_9;
  SD59x18 internal immutable TIER_ODDS_5_9;
  SD59x18 internal immutable TIER_ODDS_1_10;
  SD59x18 internal immutable TIER_ODDS_2_10;
  SD59x18 internal immutable TIER_ODDS_3_10;
  SD59x18 internal immutable TIER_ODDS_4_10;
  SD59x18 internal immutable TIER_ODDS_5_10;
  SD59x18 internal immutable TIER_ODDS_6_10;
  SD59x18 internal immutable TIER_ODDS_1_11;
  SD59x18 internal immutable TIER_ODDS_2_11;
  SD59x18 internal immutable TIER_ODDS_3_11;
  SD59x18 internal immutable TIER_ODDS_4_11;
  SD59x18 internal immutable TIER_ODDS_5_11;
  SD59x18 internal immutable TIER_ODDS_6_11;
  SD59x18 internal immutable TIER_ODDS_7_11;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_4_TIERS;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_5_TIERS;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_6_TIERS;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_7_TIERS;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_8_TIERS;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_9_TIERS;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_10_TIERS;
  uint32 internal immutable ESTIMATED_PRIZES_PER_DRAW_FOR_11_TIERS;
  mapping(uint8 tierId => Tier tierData) internal _tiers;
  uint24 public immutable grandPrizePeriodDraws;
  uint8 public immutable tierShares;
  uint8 public immutable canaryShares;
  uint8 public immutable reserveShares;
  UD60x18 public immutable tierLiquidityUtilizationRate;
  uint128 public prizeTokenPerShare;
  uint8 public numberOfTiers;
  uint24 internal _lastAwardedDrawId;
  uint48 public lastAwardedDrawAwardedAt;
  uint96 internal _reserve;
  constructor(
    uint256 _tierLiquidityUtilizationRate,
    uint8 _numberOfTiers,
    uint8 _tierShares,
    uint8 _canaryShares,
    uint8 _reserveShares,
    uint24 _grandPrizePeriodDraws
  ) {
    if (_numberOfTiers < MINIMUM_NUMBER_OF_TIERS) {
      revert NumberOfTiersLessThanMinimum(_numberOfTiers);
    }
    if (_numberOfTiers > MAXIMUM_NUMBER_OF_TIERS) {
      revert NumberOfTiersGreaterThanMaximum(_numberOfTiers);
    }
    if (_tierLiquidityUtilizationRate > 1e18) {
      revert TierLiquidityUtilizationRateGreaterThanOne();
    }
    if (_tierLiquidityUtilizationRate == 0) {
      revert TierLiquidityUtilizationRateCannotBeZero();
    }
    tierLiquidityUtilizationRate = UD60x18.wrap(_tierLiquidityUtilizationRate);
    numberOfTiers = _numberOfTiers;
    tierShares = _tierShares;
    canaryShares = _canaryShares;
    reserveShares = _reserveShares;
    grandPrizePeriodDraws = _grandPrizePeriodDraws;
    TIER_ODDS_0 = sd(1).div_0(sd(int24(_grandPrizePeriodDraws)));
    TIER_ODDS_EVERY_DRAW = SD59x18.wrap(1000000000000000000);
    TIER_ODDS_1_5 = TierCalculationLib.getTierOdds(1, 3, _grandPrizePeriodDraws);
    TIER_ODDS_1_6 = TierCalculationLib.getTierOdds(1, 4, _grandPrizePeriodDraws);
    TIER_ODDS_2_6 = TierCalculationLib.getTierOdds(2, 4, _grandPrizePeriodDraws);
    TIER_ODDS_1_7 = TierCalculationLib.getTierOdds(1, 5, _grandPrizePeriodDraws);
    TIER_ODDS_2_7 = TierCalculationLib.getTierOdds(2, 5, _grandPrizePeriodDraws);
    TIER_ODDS_3_7 = TierCalculationLib.getTierOdds(3, 5, _grandPrizePeriodDraws);
    TIER_ODDS_1_8 = TierCalculationLib.getTierOdds(1, 6, _grandPrizePeriodDraws);
    TIER_ODDS_2_8 = TierCalculationLib.getTierOdds(2, 6, _grandPrizePeriodDraws);
    TIER_ODDS_3_8 = TierCalculationLib.getTierOdds(3, 6, _grandPrizePeriodDraws);
    TIER_ODDS_4_8 = TierCalculationLib.getTierOdds(4, 6, _grandPrizePeriodDraws);
    TIER_ODDS_1_9 = TierCalculationLib.getTierOdds(1, 7, _grandPrizePeriodDraws);
    TIER_ODDS_2_9 = TierCalculationLib.getTierOdds(2, 7, _grandPrizePeriodDraws);
    TIER_ODDS_3_9 = TierCalculationLib.getTierOdds(3, 7, _grandPrizePeriodDraws);
    TIER_ODDS_4_9 = TierCalculationLib.getTierOdds(4, 7, _grandPrizePeriodDraws);
    TIER_ODDS_5_9 = TierCalculationLib.getTierOdds(5, 7, _grandPrizePeriodDraws);
    TIER_ODDS_1_10 = TierCalculationLib.getTierOdds(1, 8, _grandPrizePeriodDraws);
    TIER_ODDS_2_10 = TierCalculationLib.getTierOdds(2, 8, _grandPrizePeriodDraws);
    TIER_ODDS_3_10 = TierCalculationLib.getTierOdds(3, 8, _grandPrizePeriodDraws);
    TIER_ODDS_4_10 = TierCalculationLib.getTierOdds(4, 8, _grandPrizePeriodDraws);
    TIER_ODDS_5_10 = TierCalculationLib.getTierOdds(5, 8, _grandPrizePeriodDraws);
    TIER_ODDS_6_10 = TierCalculationLib.getTierOdds(6, 8, _grandPrizePeriodDraws);
    TIER_ODDS_1_11 = TierCalculationLib.getTierOdds(1, 9, _grandPrizePeriodDraws);
    TIER_ODDS_2_11 = TierCalculationLib.getTierOdds(2, 9, _grandPrizePeriodDraws);
    TIER_ODDS_3_11 = TierCalculationLib.getTierOdds(3, 9, _grandPrizePeriodDraws);
    TIER_ODDS_4_11 = TierCalculationLib.getTierOdds(4, 9, _grandPrizePeriodDraws);
    TIER_ODDS_5_11 = TierCalculationLib.getTierOdds(5, 9, _grandPrizePeriodDraws);
    TIER_ODDS_6_11 = TierCalculationLib.getTierOdds(6, 9, _grandPrizePeriodDraws);
    TIER_ODDS_7_11 = TierCalculationLib.getTierOdds(7, 9, _grandPrizePeriodDraws);
    ESTIMATED_PRIZES_PER_DRAW_FOR_4_TIERS = _sumTierPrizeCounts(4);
    ESTIMATED_PRIZES_PER_DRAW_FOR_5_TIERS = _sumTierPrizeCounts(5);
    ESTIMATED_PRIZES_PER_DRAW_FOR_6_TIERS = _sumTierPrizeCounts(6);
    ESTIMATED_PRIZES_PER_DRAW_FOR_7_TIERS = _sumTierPrizeCounts(7);
    ESTIMATED_PRIZES_PER_DRAW_FOR_8_TIERS = _sumTierPrizeCounts(8);
    ESTIMATED_PRIZES_PER_DRAW_FOR_9_TIERS = _sumTierPrizeCounts(9);
    ESTIMATED_PRIZES_PER_DRAW_FOR_10_TIERS = _sumTierPrizeCounts(10);
    ESTIMATED_PRIZES_PER_DRAW_FOR_11_TIERS = _sumTierPrizeCounts(11);
  }
  function _awardDraw(
    uint24 _awardingDraw,
    uint8 _nextNumberOfTiers,
    uint256 _prizeTokenLiquidity
  ) internal {
    if (_nextNumberOfTiers < MINIMUM_NUMBER_OF_TIERS) {
      revert NumberOfTiersLessThanMinimum(_nextNumberOfTiers);
    }
    uint8 numTiers = numberOfTiers;
    uint128 _prizeTokenPerShare = prizeTokenPerShare;
    (uint96 deltaReserve, uint128 newPrizeTokenPerShare) = _computeNewDistributions(
      numTiers,
      _nextNumberOfTiers,
      _prizeTokenPerShare,
      _prizeTokenLiquidity
    );
    uint8 start = _computeReclamationStart(numTiers, _nextNumberOfTiers);
    uint8 end = _nextNumberOfTiers;
    for (uint8 i = start; i < end; i++) {
      _tiers[i] = Tier({
        drawId: _awardingDraw,
        prizeTokenPerShare: _prizeTokenPerShare,
        prizeSize: _computePrizeSize(
          i,
          _nextNumberOfTiers,
          _prizeTokenPerShare,
          newPrizeTokenPerShare
        )
      });
    }
    prizeTokenPerShare = newPrizeTokenPerShare;
    numberOfTiers = _nextNumberOfTiers;
    _lastAwardedDrawId = _awardingDraw;
    lastAwardedDrawAwardedAt = uint48(block.timestamp);
    _reserve += deltaReserve;
  }
  function _computeNewDistributions(
    uint8 _numberOfTiers,
    uint8 _nextNumberOfTiers,
    uint128 _currentPrizeTokenPerShare,
    uint256 _prizeTokenLiquidity
  ) internal view returns (uint96 deltaReserve, uint128 newPrizeTokenPerShare) {
    uint256 reclaimedLiquidity;
    {
      uint8 start = _computeReclamationStart(_numberOfTiers, _nextNumberOfTiers);
      uint8 end = _numberOfTiers;
      for (uint8 i = start; i < end; i++) {
        reclaimedLiquidity = reclaimedLiquidity + (
          _getTierRemainingLiquidity(
            _tiers[i].prizeTokenPerShare,
            _currentPrizeTokenPerShare,
            _numShares(i, _numberOfTiers)
          )
        );
      }
    }
    uint256 totalNewLiquidity = _prizeTokenLiquidity + reclaimedLiquidity;
    uint256 nextTotalShares = computeTotalShares(_nextNumberOfTiers);
    uint256 deltaPrizeTokensPerShare = totalNewLiquidity / nextTotalShares;
    newPrizeTokenPerShare = SafeCast.toUint128(_currentPrizeTokenPerShare + deltaPrizeTokensPerShare);
    deltaReserve = SafeCast.toUint96(
      deltaPrizeTokensPerShare *
        reserveShares +
        totalNewLiquidity -
        deltaPrizeTokensPerShare *
        nextTotalShares
    );
  }
  function getTierPrizeSize(uint8 _tier) external view returns (uint104) {
    uint8 _numTiers = numberOfTiers;
    return
      !TierCalculationLib.isValidTier(_tier, _numTiers) ? 0 : _getTier(_tier, _numTiers).prizeSize;
  }
  function getTierPrizeCount(uint8 _tier) external pure returns (uint32) {
    return uint32(TierCalculationLib.prizeCount(_tier));
  }
  function _getTier(uint8 _tier, uint8 _numberOfTiers) internal view returns (Tier memory) {
    Tier memory tier = _tiers[_tier];
    uint24 lastAwardedDrawId_ = _lastAwardedDrawId;
    if (tier.drawId != lastAwardedDrawId_) {
      tier.drawId = lastAwardedDrawId_;
      tier.prizeSize = _computePrizeSize(
        _tier,
        _numberOfTiers,
        tier.prizeTokenPerShare,
        prizeTokenPerShare
      );
    }
    return tier;
  }
  function getTotalShares() external view returns (uint256) {
    return computeTotalShares(numberOfTiers);
  }
  function computeTotalShares(uint8 _numberOfTiers) public view returns (uint256) {
    return uint256(_numberOfTiers-2) * uint256(tierShares) + uint256(reserveShares) + uint256(canaryShares) * 2;
  }
  function _computeReclamationStart(uint8 _numberOfTiers, uint8 _nextNumberOfTiers) internal pure returns (uint8) {
    return (_nextNumberOfTiers > _numberOfTiers ? _numberOfTiers : _nextNumberOfTiers) - NUMBER_OF_CANARY_TIERS;
  }
  function _consumeLiquidity(Tier memory _tierStruct, uint8 _tier, uint104 _liquidity) internal {
    uint8 _tierShares = _numShares(_tier, numberOfTiers);
    uint104 remainingLiquidity = SafeCast.toUint104(
      _getTierRemainingLiquidity(
        _tierStruct.prizeTokenPerShare,
        prizeTokenPerShare,
        _tierShares
      )
    );
    if (_liquidity > remainingLiquidity) {
      uint96 excess = SafeCast.toUint96(_liquidity - remainingLiquidity);
      if (excess > _reserve) {
        revert InsufficientLiquidity(_liquidity);
      }
      unchecked {
        _reserve -= excess;
      }
      emit ReserveConsumed(excess);
      _tierStruct.prizeTokenPerShare = prizeTokenPerShare;
    } else {
      uint8 _remainder = uint8(_liquidity % _tierShares);
      uint8 _roundUpConsumption = _remainder == 0 ? 0 : _tierShares - _remainder;
      if (_roundUpConsumption > 0) {
        _reserve += _roundUpConsumption;
      }
      _tierStruct.prizeTokenPerShare += SafeCast.toUint104(uint256(_liquidity) + _roundUpConsumption) / _tierShares;
    }
    _tiers[_tier] = _tierStruct;
  }
  function _computePrizeSize(
    uint8 _tier,
    uint8 _numberOfTiers,
    uint128 _tierPrizeTokenPerShare,
    uint128 _prizeTokenPerShare
  ) internal view returns (uint104) {
    uint256 prizeCount = TierCalculationLib.prizeCount(_tier);
    uint256 remainingTierLiquidity = _getTierRemainingLiquidity(
      _tierPrizeTokenPerShare,
      _prizeTokenPerShare,
      _numShares(_tier, _numberOfTiers)
    );
    uint256 prizeSize = convert_2(
      convert_3(remainingTierLiquidity).mul_1(tierLiquidityUtilizationRate).div_1(convert_3(prizeCount))
    );
    return prizeSize > type(uint104).max ? type(uint104).max : uint104(prizeSize);
  }
  function isCanaryTier(uint8 _tier) public view returns (bool) {
    return _tier >= numberOfTiers - NUMBER_OF_CANARY_TIERS;
  }
  function _numShares(uint8 _tier, uint8 _numberOfTiers) internal view returns (uint8) {
    uint8 result = _tier > _numberOfTiers - 3 ? canaryShares : tierShares;
    return result;
  }
  function getTierRemainingLiquidity(uint8 _tier) public view returns (uint256) {
    uint8 _numTiers = numberOfTiers;
    if (TierCalculationLib.isValidTier(_tier, _numTiers)) {
      return _getTierRemainingLiquidity(
        _getTier(_tier, _numTiers).prizeTokenPerShare,
        prizeTokenPerShare,
        _numShares(_tier, _numTiers)
      );
    } else {
      return 0;
    }
  }
  function _getTierRemainingLiquidity(
    uint128 _tierPrizeTokenPerShare,
    uint128 _prizeTokenPerShare,
    uint8 _tierShares
  ) internal pure returns (uint256) {
    uint256 result =
      _tierPrizeTokenPerShare >= _prizeTokenPerShare
        ? 0
        : uint256(_prizeTokenPerShare - _tierPrizeTokenPerShare) * _tierShares;
    return result;
  }
  function estimatedPrizeCount() external view returns (uint32) {
    return estimatedPrizeCount(numberOfTiers);
  }
  function estimatedPrizeCountWithBothCanaries() external view returns (uint32) {
    return estimatedPrizeCountWithBothCanaries(numberOfTiers);
  }
  function reserve() external view returns (uint96) {
    return _reserve;
  }
  function estimatedPrizeCount(
    uint8 numTiers
  ) public view returns (uint32) {
    if (numTiers == 4) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_4_TIERS;
    } else if (numTiers == 5) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_5_TIERS;
    } else if (numTiers == 6) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_6_TIERS;
    } else if (numTiers == 7) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_7_TIERS;
    } else if (numTiers == 8) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_8_TIERS;
    } else if (numTiers == 9) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_9_TIERS;
    } else if (numTiers == 10) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_10_TIERS;
    } else if (numTiers == 11) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_11_TIERS;
    }
    return 0;
  }
  function estimatedPrizeCountWithBothCanaries(
    uint8 numTiers
  ) public view returns (uint32) {
    if (numTiers >= MINIMUM_NUMBER_OF_TIERS && numTiers <= MAXIMUM_NUMBER_OF_TIERS) {
      return estimatedPrizeCount(numTiers) + uint32(TierCalculationLib.prizeCount(numTiers - 1));
    } else {
      return 0;
    }
  }
  function _estimateNumberOfTiersUsingPrizeCountPerDraw(
    uint32 _prizeCount
  ) internal view returns (uint8) {
    uint32 _adjustedPrizeCount = _prizeCount * 2;
    if (_adjustedPrizeCount < ESTIMATED_PRIZES_PER_DRAW_FOR_5_TIERS) {
      return 4;
    } else if (_adjustedPrizeCount < ESTIMATED_PRIZES_PER_DRAW_FOR_6_TIERS) {
      return 5;
    } else if (_adjustedPrizeCount < ESTIMATED_PRIZES_PER_DRAW_FOR_7_TIERS) {
      return 6;
    } else if (_adjustedPrizeCount < ESTIMATED_PRIZES_PER_DRAW_FOR_8_TIERS) {
      return 7;
    } else if (_adjustedPrizeCount < ESTIMATED_PRIZES_PER_DRAW_FOR_9_TIERS) {
      return 8;
    } else if (_adjustedPrizeCount < ESTIMATED_PRIZES_PER_DRAW_FOR_10_TIERS) {
      return 9;
    } else if (_adjustedPrizeCount < ESTIMATED_PRIZES_PER_DRAW_FOR_11_TIERS) {
      return 10;
    } else {
      return 11;
    }
  }
  function _sumTierPrizeCounts(uint8 _numTiers) internal view returns (uint32) {
    uint32 prizeCount;
    uint8 i = 0;
    do {
      prizeCount += TierCalculationLib.tierPrizeCountPerDraw(i, getTierOdds(i, _numTiers));
      i++;
    } while (i < _numTiers - 1);
    return prizeCount;
  }
  function getTierOdds(uint8 _tier, uint8 _numTiers) public view returns (SD59x18) {
    if (_tier == 0) return TIER_ODDS_0;
    if (_numTiers == 3) {
      if (_tier <= 2) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 4) {
      if (_tier <= 3) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 5) {
      if (_tier == 1) return TIER_ODDS_1_5;
      else if (_tier <= 4) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 6) {
      if (_tier == 1) return TIER_ODDS_1_6;
      else if (_tier == 2) return TIER_ODDS_2_6;
      else if (_tier <= 5) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 7) {
      if (_tier == 1) return TIER_ODDS_1_7;
      else if (_tier == 2) return TIER_ODDS_2_7;
      else if (_tier == 3) return TIER_ODDS_3_7;
      else if (_tier <= 6) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 8) {
      if (_tier == 1) return TIER_ODDS_1_8;
      else if (_tier == 2) return TIER_ODDS_2_8;
      else if (_tier == 3) return TIER_ODDS_3_8;
      else if (_tier == 4) return TIER_ODDS_4_8;
      else if (_tier <= 7) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 9) {
      if (_tier == 1) return TIER_ODDS_1_9;
      else if (_tier == 2) return TIER_ODDS_2_9;
      else if (_tier == 3) return TIER_ODDS_3_9;
      else if (_tier == 4) return TIER_ODDS_4_9;
      else if (_tier == 5) return TIER_ODDS_5_9;
      else if (_tier <= 8) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 10) {
      if (_tier == 1) return TIER_ODDS_1_10;
      else if (_tier == 2) return TIER_ODDS_2_10;
      else if (_tier == 3) return TIER_ODDS_3_10;
      else if (_tier == 4) return TIER_ODDS_4_10;
      else if (_tier == 5) return TIER_ODDS_5_10;
      else if (_tier == 6) return TIER_ODDS_6_10;
      else if (_tier <= 9) return TIER_ODDS_EVERY_DRAW;
    } else if (_numTiers == 11) {
      if (_tier == 1) return TIER_ODDS_1_11;
      else if (_tier == 2) return TIER_ODDS_2_11;
      else if (_tier == 3) return TIER_ODDS_3_11;
      else if (_tier == 4) return TIER_ODDS_4_11;
      else if (_tier == 5) return TIER_ODDS_5_11;
      else if (_tier == 6) return TIER_ODDS_6_11;
      else if (_tier == 7) return TIER_ODDS_7_11;
      else if (_tier <= 10) return TIER_ODDS_EVERY_DRAW;
    }
    return sd(0);
  }
}
uint24 constant MINIMUM_DRAW_TIMEOUT = 2;
error FirstDrawOpensInPast();
error IncompatibleTwabPeriodLength();
error IncompatibleTwabPeriodOffset();
error DrawManagerIsZeroAddress();
error CreatorIsZeroAddress();
error NotDeployer();
error RangeSizeZero();
error PrizePoolShutdown();
error PrizePoolNotShutdown();
error InsufficientRewardsError(uint256 requested, uint256 available);
error DidNotWin(address vault, address winner, uint8 tier, uint32 prizeIndex);
error AlreadyClaimed(address vault, address winner, uint8 tier, uint32 prizeIndex);
error RewardTooLarge(uint256 reward, uint256 maxReward);
error ContributionGTDeltaBalance(uint256 amount, uint256 available);
error InsufficientReserve(uint104 amount, uint104 reserve);
error RandomNumberIsZero();
error AwardingDrawNotClosed(uint48 drawClosesAt);
error InvalidPrizeIndex(uint32 invalidPrizeIndex, uint32 prizeCount, uint8 tier);
error NoDrawsAwarded();
error DrawTimeoutLtMinimum(uint24 drawTimeout, uint24 minimumDrawTimeout);
error DrawTimeoutGTGrandPrizePeriodDraws();
error InvalidTier(uint8 tier, uint8 numberOfTiers);
error CallerNotDrawManager(address caller, address drawManager);
error PrizeIsZero();
error RewardRecipientZeroAddress();
error ClaimPeriodExpired();
error OnlyCreator();
error DrawManagerAlreadySet();
error GrandPrizePeriodDrawsTooLarge(uint24 grandPrizePeriodDraws, uint24 maxGrandPrizePeriodDraws);
struct ConstructorParams {
  IERC20 prizeToken;
  TwabController twabController;
  address creator;
  uint256 tierLiquidityUtilizationRate;
  uint48 drawPeriodSeconds;
  uint48 firstDrawOpensAt;
  uint24 grandPrizePeriodDraws;
  uint8 numberOfTiers;
  uint8 tierShares;
  uint8 canaryShares;
  uint8 reserveShares;
  uint24 drawTimeout;
}
contract PrizePool is TieredLiquidityDistributor {
  using SafeERC20 for IERC20;
  using DrawAccumulatorLib for DrawAccumulatorLib.Accumulator;
  event ClaimedPrize(
    address indexed vault,
    address indexed winner,
    address indexed recipient,
    uint24 drawId,
    uint8 tier,
    uint32 prizeIndex,
    uint152 payout,
    uint96 claimReward,
    address claimRewardRecipient
  );
  event DrawAwarded(
    uint24 indexed drawId,
    uint256 winningRandomNumber,
    uint8 lastNumTiers,
    uint8 numTiers,
    uint104 reserve,
    uint128 prizeTokensPerShare,
    uint48 drawOpenedAt
  );
  event AllocateRewardFromReserve(address indexed to, uint256 amount);
  event ContributedReserve(address indexed user, uint256 amount);
  event ContributePrizeTokens(address indexed vault, uint24 indexed drawId, uint256 amount);
  event SetDrawManager(address indexed drawManager);
  event WithdrawRewards(
    address indexed account,
    address indexed to,
    uint256 amount,
    uint256 available
  );
  event IncreaseClaimRewards(address indexed to, uint256 amount);
  mapping(address vault => DrawAccumulatorLib.Accumulator accumulator) internal _vaultAccumulator;
  mapping(address vault => mapping(address account => mapping(uint24 drawId => mapping(uint8 tier => mapping(uint32 prizeIndex => bool claimed)))))
    internal _claimedPrizes;
  mapping(address recipient => uint256 rewards) internal _rewards;
  address public constant DONATOR = 0x000000000000000000000000000000000000F2EE;
  IERC20 public immutable prizeToken;
  TwabController public immutable twabController;
  uint48 public immutable drawPeriodSeconds;
  uint48 public immutable firstDrawOpensAt;
  uint24 public immutable drawTimeout;
  address immutable creator;
  DrawAccumulatorLib.Accumulator internal _totalAccumulator;
  uint256 internal _winningRandomNumber;
  address public drawManager;
  uint96 internal _directlyContributedReserve;
  uint24 public claimCount;
  uint128 internal _totalWithdrawn;
  uint104 internal _totalRewardsToBeClaimed;
  Observation shutdownObservation;
  uint256 shutdownBalance;
  mapping(address vault => mapping(address account => Observation lastWithdrawalTotalContributedObservation)) internal _withdrawalObservations;
  mapping(address vault => mapping(address account => UD60x18 shutdownPortion)) internal _shutdownPortions;
  constructor(
    ConstructorParams memory params
  )
    TieredLiquidityDistributor(
      params.tierLiquidityUtilizationRate,
      params.numberOfTiers,
      params.tierShares,
      params.canaryShares,
      params.reserveShares,
      params.grandPrizePeriodDraws
    )
  {
    if (params.drawTimeout < MINIMUM_DRAW_TIMEOUT) {
      revert DrawTimeoutLtMinimum(params.drawTimeout, MINIMUM_DRAW_TIMEOUT);
    }
    if (params.drawTimeout > params.grandPrizePeriodDraws) {
      revert DrawTimeoutGTGrandPrizePeriodDraws();
    }
    if (params.firstDrawOpensAt < block.timestamp) {
      revert FirstDrawOpensInPast();
    }
    if (params.grandPrizePeriodDraws >= MAX_OBSERVATION_CARDINALITY) {
      revert GrandPrizePeriodDrawsTooLarge(params.grandPrizePeriodDraws, MAX_OBSERVATION_CARDINALITY - 1);
    }
    uint48 twabPeriodOffset = params.twabController.PERIOD_OFFSET();
    uint48 twabPeriodLength = params.twabController.PERIOD_LENGTH();
    if (
      params.drawPeriodSeconds < twabPeriodLength ||
      params.drawPeriodSeconds % twabPeriodLength != 0
    ) {
      revert IncompatibleTwabPeriodLength();
    }
    if ((params.firstDrawOpensAt - twabPeriodOffset) % twabPeriodLength != 0) {
      revert IncompatibleTwabPeriodOffset();
    }
    if (params.creator == address(0)) {
      revert CreatorIsZeroAddress();
    }
    creator = params.creator;
    drawTimeout = params.drawTimeout;
    prizeToken = params.prizeToken;
    twabController = params.twabController;
    drawPeriodSeconds = params.drawPeriodSeconds;
    firstDrawOpensAt = params.firstDrawOpensAt;
  }
  modifier onlyDrawManager() {
    if (msg.sender != drawManager) {
      revert CallerNotDrawManager(msg.sender, drawManager);
    }
    _;
  }
  function setDrawManager(address _drawManager) external {
    if (msg.sender != creator) {
      revert OnlyCreator();
    }
    if (drawManager != address(0)) {
      revert DrawManagerAlreadySet();
    }
    drawManager = _drawManager;
    emit SetDrawManager(_drawManager);
  }
  function contributePrizeTokens(address _prizeVault, uint256 _amount) public returns (uint256) {
    uint256 _deltaBalance = prizeToken.balanceOf(address(this)) - accountedBalance();
    if (_deltaBalance < _amount) {
      revert ContributionGTDeltaBalance(_amount, _deltaBalance);
    }
    uint24 openDrawId_ = getOpenDrawId();
    _vaultAccumulator[_prizeVault].add(_amount, openDrawId_);
    _totalAccumulator.add(_amount, openDrawId_);
    emit ContributePrizeTokens(_prizeVault, openDrawId_, _amount);
    return _deltaBalance;
  }
  function donatePrizeTokens(uint256 _amount) external {
    prizeToken.safeTransferFrom(msg.sender, address(this), _amount);
    contributePrizeTokens(DONATOR, _amount);
  }
  function allocateRewardFromReserve(address _to, uint96 _amount) external onlyDrawManager notShutdown {
    if (_to == address(0)) {
      revert RewardRecipientZeroAddress();
    }
    if (_amount > _reserve) {
      revert InsufficientReserve(_amount, _reserve);
    }
    unchecked {
      _reserve -= _amount;
    }
    _rewards[_to] += _amount;
    _totalRewardsToBeClaimed = SafeCast.toUint104(_totalRewardsToBeClaimed + _amount);
    emit AllocateRewardFromReserve(_to, _amount);
  }
  function awardDraw(uint256 winningRandomNumber_) external onlyDrawManager notShutdown returns (uint24) {
    if (winningRandomNumber_ == 0) {
      revert RandomNumberIsZero();
    }
    uint24 awardingDrawId = getDrawIdToAward();
    uint48 awardingDrawOpenedAt = drawOpensAt(awardingDrawId);
    uint48 awardingDrawClosedAt = awardingDrawOpenedAt + drawPeriodSeconds;
    if (block.timestamp < awardingDrawClosedAt) {
      revert AwardingDrawNotClosed(awardingDrawClosedAt);
    }
    uint24 lastAwardedDrawId_ = _lastAwardedDrawId;
    uint32 _claimCount = claimCount;
    uint8 _numTiers = numberOfTiers;
    uint8 _nextNumberOfTiers = _numTiers;
    _nextNumberOfTiers = computeNextNumberOfTiers(_claimCount);
    _awardDraw(
      awardingDrawId,
      _nextNumberOfTiers,
      getTotalContributedBetween(lastAwardedDrawId_ + 1, awardingDrawId)
    );
    _winningRandomNumber = winningRandomNumber_;
    if (_claimCount != 0) {
      claimCount = 0;
    }
    emit DrawAwarded(
      awardingDrawId,
      winningRandomNumber_,
      _numTiers,
      _nextNumberOfTiers,
      _reserve,
      prizeTokenPerShare,
      awardingDrawOpenedAt
    );
    return awardingDrawId;
  }
  function claimPrize(
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex,
    address _prizeRecipient,
    uint96 _claimReward,
    address _claimRewardRecipient
  ) external returns (uint256) {
    uint24 lastAwardedDrawId_ = _lastAwardedDrawId;
    if (isDrawFinalized(lastAwardedDrawId_)) {
      revert ClaimPeriodExpired();
    }
    if (_claimRewardRecipient == address(0) && _claimReward > 0) {
      revert RewardRecipientZeroAddress();
    }
    uint8 _numTiers = numberOfTiers;
    Tier memory tierLiquidity = _getTier(_tier, _numTiers);
    if (_claimReward > tierLiquidity.prizeSize) {
      revert RewardTooLarge(_claimReward, tierLiquidity.prizeSize);
    }
    if (tierLiquidity.prizeSize == 0) {
      revert PrizeIsZero();
    }
    if (!isWinner(msg.sender, _winner, _tier, _prizeIndex)) {
      revert DidNotWin(msg.sender, _winner, _tier, _prizeIndex);
    }
    if (_claimedPrizes[msg.sender][_winner][lastAwardedDrawId_][_tier][_prizeIndex]) {
      revert AlreadyClaimed(msg.sender, _winner, _tier, _prizeIndex);
    }
    _claimedPrizes[msg.sender][_winner][lastAwardedDrawId_][_tier][_prizeIndex] = true;
    _consumeLiquidity(tierLiquidity, _tier, tierLiquidity.prizeSize);
    uint256 amount;
    if (_claimReward != 0) {
      emit IncreaseClaimRewards(_claimRewardRecipient, _claimReward);
      _rewards[_claimRewardRecipient] += _claimReward;
      unchecked {
        amount = tierLiquidity.prizeSize - _claimReward;
      }
    } else {
      amount = tierLiquidity.prizeSize;
    }
    claimCount++;
    _totalWithdrawn = SafeCast.toUint128(_totalWithdrawn + amount);
    _totalRewardsToBeClaimed = SafeCast.toUint104(_totalRewardsToBeClaimed + _claimReward);
    emit ClaimedPrize(
      msg.sender,
      _winner,
      _prizeRecipient,
      lastAwardedDrawId_,
      _tier,
      _prizeIndex,
      uint152(amount),
      _claimReward,
      _claimRewardRecipient
    );
    if (amount > 0) {
      prizeToken.safeTransfer(_prizeRecipient, amount);
    }
    return tierLiquidity.prizeSize;
  }
  function withdrawRewards(address _to, uint256 _amount) external {
    uint256 _available = _rewards[msg.sender];
    if (_amount > _available) {
      revert InsufficientRewardsError(_amount, _available);
    }
    unchecked {
      _rewards[msg.sender] = _available - _amount;
    }
    _totalWithdrawn = SafeCast.toUint128(_totalWithdrawn + _amount);
    _totalRewardsToBeClaimed = SafeCast.toUint104(_totalRewardsToBeClaimed - _amount);
    if (_to != address(this)) {
      prizeToken.safeTransfer(_to, _amount);
    }
    emit WithdrawRewards(msg.sender, _to, _amount, _available);
  }
  function contributeReserve(uint96 _amount) external notShutdown {
    _reserve += _amount;
    _directlyContributedReserve += _amount;
    prizeToken.safeTransferFrom(msg.sender, address(this), _amount);
    emit ContributedReserve(msg.sender, _amount);
  }
  function getWinningRandomNumber() external view returns (uint256) {
    return _winningRandomNumber;
  }
  function getLastAwardedDrawId() external view returns (uint24) {
    return _lastAwardedDrawId;
  }
  function getContributedBetween(
    address _vault,
    uint24 _startDrawIdInclusive,
    uint24 _endDrawIdInclusive
  ) external view returns (uint256) {
    return
      _vaultAccumulator[_vault].getDisbursedBetween(
        _startDrawIdInclusive,
        _endDrawIdInclusive
      );
  }
  function getDonatedBetween(
    uint24 _startDrawIdInclusive,
    uint24 _endDrawIdInclusive
  ) external view returns (uint256) {
    return
      _vaultAccumulator[DONATOR].getDisbursedBetween(
        _startDrawIdInclusive,
        _endDrawIdInclusive
      );
  }
  function getTotalAccumulatorNewestObservation() external view returns (Observation memory) {
    return _totalAccumulator.newestObservation();
  }
  function getVaultAccumulatorNewestObservation(address _vault) external view returns (Observation memory) {
    return _vaultAccumulator[_vault].newestObservation();
  }
  function getTierAccrualDurationInDraws(uint8 _tier) external view returns (uint24) {
    return
      TierCalculationLib.estimatePrizeFrequencyInDraws(getTierOdds(_tier, numberOfTiers), grandPrizePeriodDraws);
  }
  function totalWithdrawn() external view returns (uint256) {
    return _totalWithdrawn;
  }
  function pendingReserveContributions() external view returns (uint256) {
    uint8 _numTiers = numberOfTiers;
    uint24 lastAwardedDrawId_ = _lastAwardedDrawId;
    (uint104 newReserve, ) = _computeNewDistributions(
      _numTiers,
      lastAwardedDrawId_ == 0 ? _numTiers : computeNextNumberOfTiers(claimCount),
      prizeTokenPerShare,
      getTotalContributedBetween(lastAwardedDrawId_ + 1, getDrawIdToAward())
    );
    return newReserve;
  }
  function wasClaimed(
    address _vault,
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex
  ) external view returns (bool) {
    return _claimedPrizes[_vault][_winner][_lastAwardedDrawId][_tier][_prizeIndex];
  }
  function wasClaimed(
    address _vault,
    address _winner,
    uint24 _drawId,
    uint8 _tier,
    uint32 _prizeIndex
  ) external view returns (bool) {
    return _claimedPrizes[_vault][_winner][_drawId][_tier][_prizeIndex];
  }
  function rewardBalance(address _recipient) external view returns (uint256) {
    return _rewards[_recipient];
  }
  function estimateNextNumberOfTiers() external view returns (uint8) {
    return computeNextNumberOfTiers(claimCount);
  }
  function accountedBalance() public view returns (uint256) {
    return _accountedBalance(_totalAccumulator.newestObservation());
  }
  function getShutdownInfo() public returns (uint256 balance, Observation memory observation) {
    if (!isShutdown()) {
      return (balance, observation);
    }
    if (shutdownObservation.disbursed + shutdownObservation.available == 0) {
      observation = _totalAccumulator.newestObservation();
      shutdownObservation = observation;
      balance = _accountedBalance(observation) - _totalRewardsToBeClaimed;
      shutdownBalance = balance;
    } else {
      observation = shutdownObservation;
      balance = shutdownBalance;
    }
  }
  function getOpenDrawId() public view returns (uint24) {
    uint24 shutdownDrawId = getShutdownDrawId();
    uint24 openDrawId = getDrawId(block.timestamp);
    return openDrawId > shutdownDrawId ? shutdownDrawId : openDrawId;
  }
  function getDrawId(uint256 _timestamp) public view returns (uint24) {
    uint48 _firstDrawOpensAt = firstDrawOpensAt;
    return
      (_timestamp < _firstDrawOpensAt)
        ? 1
        : (uint24((_timestamp - _firstDrawOpensAt) / drawPeriodSeconds) + 1);
  }
  function getDrawIdToAward() public view returns (uint24) {
    uint24 openDrawId_ = getOpenDrawId();
    return (openDrawId_ - _lastAwardedDrawId) > 1 ? openDrawId_ - 1 : openDrawId_;
  }
  function drawOpensAt(uint24 drawId) public view returns (uint48) {
    return firstDrawOpensAt + (drawId - 1) * drawPeriodSeconds;
  }
  function drawClosesAt(uint24 drawId) public view returns (uint48) {
    return firstDrawOpensAt + drawId * drawPeriodSeconds;
  }
  function isDrawFinalized(uint24 drawId) public view returns (bool) {
    return block.timestamp >= drawClosesAt(drawId + 1);
  }
  function computeNextNumberOfTiers(uint32 _claimCount) public view returns (uint8) {
    if (_lastAwardedDrawId != 0) {
      uint8 nextNumberOfTiers = _estimateNumberOfTiersUsingPrizeCountPerDraw(_claimCount);
      uint8 _numTiers = numberOfTiers;
      if (nextNumberOfTiers > _numTiers) {
        nextNumberOfTiers = _numTiers + 1;
      } else if (nextNumberOfTiers < _numTiers) {
        nextNumberOfTiers = _numTiers - 1;
      }
      return nextNumberOfTiers;
    } else {
      return numberOfTiers;
    }
  }
  function computeShutdownPortion(address _vault, address _account) public view returns (UD60x18) {
    uint24 drawIdPriorToShutdown = getShutdownDrawId() - 1;
    uint24 startDrawIdInclusive = computeRangeStartDrawIdInclusive(drawIdPriorToShutdown, grandPrizePeriodDraws);
    (uint256 vaultContrib, uint256 totalContrib) = _getVaultShares(
      _vault,
      startDrawIdInclusive,
      drawIdPriorToShutdown
    );
    (uint256 _userTwab, uint256 _vaultTwabTotalSupply) = getVaultUserBalanceAndTotalSupplyTwab(
      _vault,
      _account,
      startDrawIdInclusive,
      drawIdPriorToShutdown
    );
    if (_vaultTwabTotalSupply == 0 || totalContrib == 0) {
      return UD60x18.wrap(0);
    }
    return convert_3(vaultContrib)
      .div_1(convert_3(totalContrib))
      .mul_1(convert_3(_userTwab))
      .div_1(convert_3(_vaultTwabTotalSupply));
  }
  function shutdownBalanceOf(address _vault, address _account) public returns (uint256) {
    if (!isShutdown()) {
      return 0;
    }
    Observation memory withdrawalObservation = _withdrawalObservations[_vault][_account];
    UD60x18 shutdownPortion;
    uint256 balance;
    if ((withdrawalObservation.available + withdrawalObservation.disbursed) == 0) {
      (balance, withdrawalObservation) = getShutdownInfo();
      shutdownPortion = computeShutdownPortion(_vault, _account);
      _shutdownPortions[_vault][_account] = shutdownPortion;
    } else {
      shutdownPortion = _shutdownPortions[_vault][_account];
    }
    if (shutdownPortion.unwrap_3() == 0) {
      return 0;
    }
    Observation memory newestObs = _totalAccumulator.newestObservation();
    balance += (newestObs.available + newestObs.disbursed) - (withdrawalObservation.available + withdrawalObservation.disbursed);
    return convert_2(convert_3(balance).mul_1(shutdownPortion));
  }
  function withdrawShutdownBalance(address _vault, address _recipient) external returns (uint256) {
    if (!isShutdown()) {
      revert PrizePoolNotShutdown();
    }
    uint256 balance = shutdownBalanceOf(_vault, msg.sender);
    _withdrawalObservations[_vault][msg.sender] = _totalAccumulator.newestObservation();
    if (balance > 0) {
      prizeToken.safeTransfer(_recipient, balance);
      _totalWithdrawn += uint128(balance);
    }
    return balance;
  }
  function getShutdownDrawId() public view returns (uint24) {
    return getDrawId(shutdownAt());
  }
  function shutdownAt() public view returns (uint256) {
    uint256 twabShutdownAt = drawOpensAt(getDrawId(twabController.lastObservationAt()));
    uint256 drawTimeoutAt_ = drawTimeoutAt();
    return drawTimeoutAt_ < twabShutdownAt ? drawTimeoutAt_ : twabShutdownAt;
  }
  function isShutdown() public view returns (bool) {
    return block.timestamp >= shutdownAt();
  }
  function drawTimeoutAt() public view returns (uint256) { 
    return drawClosesAt(_lastAwardedDrawId + drawTimeout);
  }
  function getTotalContributedBetween(
    uint24 _startDrawIdInclusive,
    uint24 _endDrawIdInclusive
  ) public view returns (uint256) {
    return
      _totalAccumulator.getDisbursedBetween(
        _startDrawIdInclusive,
        _endDrawIdInclusive
      );
  }
  function isWinner(
    address _vault,
    address _user,
    uint8 _tier,
    uint32 _prizeIndex
  ) public view returns (bool) {
    uint24 lastAwardedDrawId_ = _lastAwardedDrawId;
    if (lastAwardedDrawId_ == 0) {
      revert NoDrawsAwarded();
    }
    if (_tier >= numberOfTiers) {
      revert InvalidTier(_tier, numberOfTiers);
    }
    SD59x18 tierOdds = getTierOdds(_tier, numberOfTiers);
    uint24 startDrawIdInclusive = computeRangeStartDrawIdInclusive(lastAwardedDrawId_, TierCalculationLib.estimatePrizeFrequencyInDraws(tierOdds, grandPrizePeriodDraws));
    uint32 tierPrizeCount = uint32(TierCalculationLib.prizeCount(_tier));
    if (_prizeIndex >= tierPrizeCount) {
      revert InvalidPrizeIndex(_prizeIndex, tierPrizeCount, _tier);
    }
    uint256 userSpecificRandomNumber = TierCalculationLib.calculatePseudoRandomNumber(
      lastAwardedDrawId_,
      _vault,
      _user,
      _tier,
      _prizeIndex,
      _winningRandomNumber
    );
    SD59x18 vaultPortion = getVaultPortion(
      _vault,
      startDrawIdInclusive,
      lastAwardedDrawId_
    );
    (uint256 _userTwab, uint256 _vaultTwabTotalSupply) = getVaultUserBalanceAndTotalSupplyTwab(
      _vault,
      _user,
      startDrawIdInclusive,
      lastAwardedDrawId_
    );
    return
      TierCalculationLib.isWinner(
        userSpecificRandomNumber,
        _userTwab,
        _vaultTwabTotalSupply,
        vaultPortion,
        tierOdds
      );
  }
  function computeRangeStartDrawIdInclusive(uint24 _endDrawIdInclusive, uint24 _rangeSize) public pure returns (uint24) {
    if (_rangeSize != 0) {
      return _rangeSize > _endDrawIdInclusive ? 1 : _endDrawIdInclusive - _rangeSize + 1;
    } else {
      revert RangeSizeZero();
    }
  }
  function getVaultUserBalanceAndTotalSupplyTwab(
    address _vault,
    address _user,
    uint24 _startDrawIdInclusive,
    uint24 _endDrawIdInclusive
  ) public view returns (uint256 twab, uint256 twabTotalSupply) {
    uint48 _startTimestamp = drawOpensAt(_startDrawIdInclusive);
    uint48 _endTimestamp = drawClosesAt(_endDrawIdInclusive);
    twab = twabController.getTwabBetween(_vault, _user, _startTimestamp, _endTimestamp);
    twabTotalSupply = twabController.getTotalSupplyTwabBetween(
      _vault,
      _startTimestamp,
      _endTimestamp
    );
  }
  function getVaultPortion(
    address _vault,
    uint24 _startDrawIdInclusive,
    uint24 _endDrawIdInclusive
  ) public view returns (SD59x18) {
    if (_vault == DONATOR) {
      return sd(0);
    }
    (uint256 vaultContributed, uint256 totalContributed) = _getVaultShares(_vault, _startDrawIdInclusive, _endDrawIdInclusive);
    if (totalContributed == 0) {
      return sd(0);
    }
    return sd(
      SafeCast.toInt256(
        vaultContributed
      )
    ).div_0(sd(SafeCast.toInt256(totalContributed)));
  }
  function _getVaultShares(
    address _vault,
    uint24 _startDrawIdInclusive,
    uint24 _endDrawIdInclusive
  ) internal view returns (uint256 shares, uint256 totalSupply) {
    uint256 totalContributed = _totalAccumulator.getDisbursedBetween(
      _startDrawIdInclusive,
      _endDrawIdInclusive
    );
    uint256 totalDonated = _vaultAccumulator[DONATOR].getDisbursedBetween(_startDrawIdInclusive, _endDrawIdInclusive);
    totalSupply = totalContributed - totalDonated;
    shares = _vaultAccumulator[_vault].getDisbursedBetween(
      _startDrawIdInclusive,
      _endDrawIdInclusive
    );
  }
  function _accountedBalance(Observation memory _observation) internal view returns (uint256) {
    return (_observation.available + _observation.disbursed) + uint256(_directlyContributedReserve) - uint256(_totalWithdrawn);
  }
  modifier notShutdown() {
    if (isShutdown()) {
      revert PrizePoolShutdown();
    }
    _;
  }
}