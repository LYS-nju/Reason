pragma solidity ^0.8.19;
function _require(bool _condition, uint32 _errorCode) pure {
    if (!_condition) revert(string(abi.encodePacked(_errorCode)));
}
library Errors {
    uint32 internal constant ZERO_VALUE = 0x23313030; 
    uint32 internal constant NOT_INIT_CORE = 0x23313031; 
    uint32 internal constant SLIPPAGE_CONTROL = 0x23313032; 
    uint32 internal constant CALL_FAILED = 0x23313033; 
    uint32 internal constant NOT_OWNER = 0x23313034; 
    uint32 internal constant NOT_WNATIVE = 0x23313035; 
    uint32 internal constant ALREADY_SET = 0x23313036; 
    uint32 internal constant NOT_WHITELISTED = 0x23313037; 
    uint32 internal constant ARRAY_LENGTH_MISMATCHED = 0x23323030; 
    uint32 internal constant INPUT_TOO_LOW = 0x23323031; 
    uint32 internal constant INPUT_TOO_HIGH = 0x23323032; 
    uint32 internal constant INVALID_INPUT = 0x23323033; 
    uint32 internal constant INVALID_TOKEN_IN = 0x23323034; 
    uint32 internal constant INVALID_TOKEN_OUT = 0x23323035; 
    uint32 internal constant NOT_SORTED_OR_DUPLICATED_INPUT = 0x23323036; 
    uint32 internal constant POSITION_NOT_HEALTHY = 0x23333030; 
    uint32 internal constant POSITION_NOT_FOUND = 0x23333031; 
    uint32 internal constant LOCKED_MULTICALL = 0x23333032; 
    uint32 internal constant POSITION_HEALTHY = 0x23333033; 
    uint32 internal constant INVALID_HEALTH_AFTER_LIQUIDATION = 0x23333034; 
    uint32 internal constant FLASH_PAUSED = 0x23333035; 
    uint32 internal constant INVALID_FLASHLOAN = 0x23333036; 
    uint32 internal constant NOT_AUTHORIZED = 0x23333037; 
    uint32 internal constant INVALID_CALLBACK_ADDRESS = 0x23333038; 
    uint32 internal constant MINT_PAUSED = 0x23343030; 
    uint32 internal constant REDEEM_PAUSED = 0x23343031; 
    uint32 internal constant BORROW_PAUSED = 0x23343032; 
    uint32 internal constant REPAY_PAUSED = 0x23343033; 
    uint32 internal constant NOT_ENOUGH_CASH = 0x23343034; 
    uint32 internal constant INVALID_AMOUNT_TO_REPAY = 0x23343035; 
    uint32 internal constant SUPPLY_CAP_REACHED = 0x23343036; 
    uint32 internal constant BORROW_CAP_REACHED = 0x23343037; 
    uint32 internal constant INVALID_MODE = 0x23353030; 
    uint32 internal constant TOKEN_NOT_WHITELISTED = 0x23353031; 
    uint32 internal constant INVALID_FACTOR = 0x23353032; 
    uint32 internal constant COLLATERALIZE_PAUSED = 0x23363030; 
    uint32 internal constant DECOLLATERALIZE_PAUSED = 0x23363031; 
    uint32 internal constant MAX_COLLATERAL_COUNT_REACHED = 0x23363032; 
    uint32 internal constant NOT_CONTAIN = 0x23363033; 
    uint32 internal constant ALREADY_COLLATERALIZED = 0x23363034; 
    uint32 internal constant NO_VALID_SOURCE = 0x23373030; 
    uint32 internal constant TOO_MUCH_DEVIATION = 0x23373031; 
    uint32 internal constant MAX_PRICE_DEVIATION_TOO_LOW = 0x23373032; 
    uint32 internal constant NO_PRICE_ID = 0x23373033; 
    uint32 internal constant PYTH_CONFIG_NOT_SET = 0x23373034; 
    uint32 internal constant DATAFEED_ID_NOT_SET = 0x23373035; 
    uint32 internal constant MAX_STALETIME_NOT_SET = 0x23373036; 
    uint32 internal constant MAX_STALETIME_EXCEEDED = 0x23373037; 
    uint32 internal constant PRIMARY_SOURCE_NOT_SET = 0x23373038; 
    uint32 internal constant DEBT_CEILING_EXCEEDED = 0x23383030; 
    uint32 internal constant INCORRECT_PAIR = 0x23393030; 
    uint32 internal constant UNIMPLEMENTED = 0x23393939; 
}
interface IAccessControlManager {
    function checkRole(bytes32 _role, address _user) external;
}
interface IMulticall {
    function multicall(bytes[] calldata _data) external payable returns (bytes[] memory results);
}
enum OrderType {
    StopLoss,
    TakeProfit
}
enum OrderStatus {
    Cancelled,
    Active,
    Filled
}
enum SwapType {
    OpenExactIn,
    CloseExactIn,
    CloseExactOut
}
struct Order {
    uint initPosId; 
    uint triggerPrice_e36; 
    uint limitPrice_e36; 
    uint collAmt; 
    address tokenOut; 
    OrderType orderType; 
    OrderStatus status; 
    address recipient; 
}
struct MarginPos {
    address collPool; 
    address borrPool; 
    address baseAsset; 
    address quoteAsset; 
    bool isLongBaseAsset; 
}
struct SwapInfo {
    uint initPosId; 
    SwapType swapType; 
    address tokenIn; 
    address tokenOut; 
    uint amtOut; 
    bytes data; 
}
interface IMarginTradingHook {
    event SwapToIncreasePos(
        uint indexed initPosId, address indexed tokenIn, address indexed tokenOut, uint amtIn, uint amtOut
    );
    event SwapToReducePos(
        uint indexed initPosId, address indexed tokenIn, address indexed tokenOut, uint amtIn, uint amtOut
    );
    event IncreasePos(
        uint indexed initPosId, address indexed tokenIn, address indexed borrToken, uint amtIn, uint borrowAmt
    );
    event ReducePos(uint indexed initPosId, address indexed tokenOut, uint amtOut, uint size, uint repayAmt);
    event CreateOrder(
        uint indexed initPosId,
        uint indexed orderId,
        address tokenOut,
        uint triggerPrice_e36,
        uint limitPrice_e36,
        uint size,
        OrderType orderType
    );
    event UpdateOrder(
        uint indexed initPosId,
        uint indexed orderId,
        address tokenOut,
        uint triggerPrice_e36,
        uint limitPrice_e36,
        uint size
    );
    event CancelOrder(uint indexed initPosId, uint indexed orderId);
    event FillOrder(uint indexed initPosId, uint indexed orderId, address tokenOut, uint amtOut);
    struct IncreasePosInternalParam {
        uint initPosId; 
        address tokenIn; 
        uint amtIn; 
        address borrPool; 
        uint borrAmt; 
        address collPool; 
        bytes data; 
        uint minHealth_e18; 
    }
    struct ReducePosInternalParam {
        uint initPosId; 
        uint collAmt; 
        uint repayShares; 
        address tokenOut; 
        uint minAmtOut; 
        bool returnNative; 
        bytes data; 
        uint minHealth_e18; 
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
    ) external payable returns (uint posId, uint initPosId, uint health_e18);
    function increasePos(
        uint _posId,
        address _tokenIn,
        uint _amtIn,
        uint _borrAmt,
        bytes calldata _data,
        uint _minHealth_e18
    ) external payable returns (uint health_e18);
    function addCollateral(uint _posId, uint _amtIn) external payable returns (uint health_e18);
    function removeCollateral(uint _posId, uint _shares, bool _returnNative) external returns (uint health_e18);
    function repayDebt(uint _posId, uint _repayShares) external payable returns (uint repayAmt, uint health_e18);
    function reducePos(
        uint _posId,
        uint _collAmt,
        uint _repayShares,
        address _tokenOut,
        uint _minAmtOut,
        bool _returnNative,
        bytes calldata _data,
        uint _minHealth_e18
    ) external returns (uint amtOut, uint health_e18);
    function addStopLossOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId);
    function addTakeProfitOrder(
        uint _posId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external returns (uint orderId);
    function updateOrder(
        uint _posId,
        uint _orderId,
        uint _triggerPrice_e36,
        address _tokenOut,
        uint _limitPrice_e36,
        uint _collAmt
    ) external;
    function cancelOrder(uint _posId, uint _orderId) external;
    function fillOrder(uint _orderId) external;
    function setQuoteAsset(address _tokenA, address _tokenB, address _quoteAsset) external;
    function getBaseAssetAndQuoteAsset(address _tokenA, address _tokenB)
        external
        view
        returns (address baseAsset, address quoteAsset);
    function getOrder(uint _orderId) external view returns (Order memory);
    function getMarginPos(uint _initPosId) external view returns (MarginPos memory);
    function getPosOrdersLength(uint _initPosId) external view returns (uint);
    function lastOrderId() external view returns (uint);
    function getPosOrderIds(uint _initPosId) external view returns (uint[] memory);
}
interface ILendingPool {
    event SetIrm(address _irm);
    event SetReserveFactor_e18(uint _reserveFactor_e18);
    event SetTreasury(address _treasury);
    function core() external view returns (address core);
    function irm() external view returns (address model);
    function reserveFactor_e18() external view returns (uint factor_e18);
    function underlyingToken() external view returns (address token);
    function totalAssets() external view returns (uint amt);
    function totalDebt() external view returns (uint debt);
    function totalDebtShares() external view returns (uint shares);
    function debtAmtToShareStored(uint _amt) external view returns (uint shares);
    function debtAmtToShareCurrent(uint _amt) external returns (uint shares);
    function debtShareToAmtStored(uint _shares) external view returns (uint amt);
    function debtShareToAmtCurrent(uint _shares) external returns (uint amt);
    function getSupplyRate_e18() external view returns (uint supplyRate_e18);
    function getBorrowRate_e18() external view returns (uint borrowRate_e18);
    function cash() external view returns (uint amt);
    function lastAccruedTime() external view returns (uint lastAccruedTime);
    function treasury() external view returns (address treasury);
    function mint(address _receiver) external returns (uint mintShares);
    function burn(address _receiver) external returns (uint amt);
    function borrow(address _receiver, uint _amt) external returns (uint debtShares);
    function repay(uint _shares) external returns (uint amt);
    function accrueInterest() external;
    function toShares(uint _amt) external view returns (uint shares);
    function toAmt(uint _shares) external view returns (uint amt);
    function toSharesCurrent(uint _amt) external returns (uint shares);
    function toAmtCurrent(uint _shares) external returns (uint amt);
    function setIrm(address _irm) external;
    function setReserveFactor_e18(uint _reserveFactor_e18) external;
    function setTreasury(address _treasury) external;
}
interface IBaseOracle {
    function getPrice_e36(address _token) external view returns (uint price_e36);
}
interface ICallbackReceiver {
    function coreCallback(address _sender, bytes calldata _data) external payable returns (bytes memory result);
}
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
library Math {
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
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastValue;
                set._indexes[lastValue] = valueIndex; 
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }
    struct Bytes32Set {
        Set _inner;
    }
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;
        assembly {
            result := store
        }
        return result;
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;
        assembly {
            result := store
        }
        return result;
    }
    struct UintSet {
        Set _inner;
    }
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {
            result := store
        }
        return result;
    }
}
interface IERC721ReceiverUpgradeable {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
abstract contract UnderACM {
    IAccessControlManager public immutable ACM; 
    constructor(address _acm) {
        ACM = IAccessControlManager(_acm);
    }
}
interface IWNative is IERC20 {
    function deposit() external payable;
    function withdraw(uint amount) external;
}
struct TokenFactors {
    uint128 collFactor_e18; 
    uint128 borrFactor_e18; 
}
struct ModeConfig {
    EnumerableSet.AddressSet collTokens; 
    EnumerableSet.AddressSet borrTokens; 
    uint64 maxHealthAfterLiq_e18; 
    mapping(address => TokenFactors) factors; 
    ModeStatus status; 
    uint8 maxCollWLpCount; 
}
struct PoolConfig {
    uint128 supplyCap; 
    uint128 borrowCap; 
    bool canMint; 
    bool canBurn; 
    bool canBorrow; 
    bool canRepay; 
    bool canFlash; 
}
struct ModeStatus {
    bool canCollateralize; 
    bool canDecollateralize; 
    bool canBorrow; 
    bool canRepay; 
}
interface IConfig {
    event SetPoolConfig(address indexed pool, PoolConfig config);
    event SetCollFactors_e18(uint16 indexed mode, address[] tokens, uint128[] _factors);
    event SetBorrFactors_e18(uint16 indexed mode, address[] tokens, uint128[] factors);
    event SetMaxHealthAfterLiq_e18(uint16 indexed mode, uint64 maxHealthAfterLiq_e18);
    event SetWhitelistedWLps(address[] wLps, bool status);
    event SetModeStatus(uint16 mode, ModeStatus status);
    event SetMaxCollWLpCount(uint16 indexed mode, uint8 maxCollWLpCount);
    function whitelistedWLps(address _wlp) external view returns (bool);
    function getModeConfig(uint16 _mode)
        external
        view
        returns (
            address[] memory collTokens,
            address[] memory borrTokens,
            uint maxHealthAfterLiq_e18,
            uint8 maxCollWLpCount
        );
    function getPoolConfig(address _pool) external view returns (PoolConfig memory poolConfig);
    function isAllowedForBorrow(uint16 _mode, address _pool) external view returns (bool);
    function isAllowedForCollateral(uint16 _mode, address _pool) external view returns (bool);
    function getTokenFactors(uint16 _mode, address _pool) external view returns (TokenFactors memory tokenFactors);
    function getMaxHealthAfterLiq_e18(uint16 _mode) external view returns (uint maxHealthAfterLiq_e18);
    function getModeStatus(uint16 _mode) external view returns (ModeStatus memory modeStatus);
    function setPoolConfig(address _pool, PoolConfig calldata _config) external;
    function setCollFactors_e18(uint16 _mode, address[] calldata _pools, uint128[] calldata _factors) external;
    function setBorrFactors_e18(uint16 _mode, address[] calldata _pools, uint128[] calldata _factors) external;
    function setModeStatus(uint16 _mode, ModeStatus calldata _status) external;
    function setWhitelistedWLps(address[] calldata _wLps, bool _status) external;
    function setMaxHealthAfterLiq_e18(uint16 _mode, uint64 _maxHealthAfterLiq_e18) external;
    function setMaxCollWLpCount(uint16 _mode, uint8 _maxCollWLpCount) external;
    function getModeMaxCollWLpCount(uint16 _mode) external view returns (uint8);
}
interface IPosManager {
    event SetMaxCollCount(uint maxCollCount);
    struct PosInfo {
        address viewer; 
        uint16 mode; 
    }
    struct PosBorrExtraInfo {
        uint128 totalInterest; 
        uint128 lastDebtAmt; 
    }
    struct PosCollInfo {
        EnumerableSet.AddressSet collTokens; 
        mapping(address => uint) collAmts; 
        EnumerableSet.AddressSet wLps; 
        mapping(address => EnumerableSet.UintSet) ids; 
        uint8 collCount; 
        uint8 wLpCount; 
    }
    struct PosBorrInfo {
        EnumerableSet.AddressSet pools; 
        mapping(address => uint) debtShares; 
        mapping(address => PosBorrExtraInfo) borrExtraInfos; 
    }
    function nextNonces(address _owner) external view returns (uint nextNonce);
    function core() external view returns (address core);
    function pendingRewards(uint _posId, address _rewardToken) external view returns (uint amt);
    function isCollateralized(address _wLp, uint _tokenId) external view returns (bool);
    function getPosBorrInfo(uint _posId) external view returns (address[] memory pools, uint[] memory debtShares);
    function getPosBorrExtraInfo(uint _posId, address _pool)
        external
        view
        returns (uint totalInterest, uint lastDebtAmt);
    function getPosCollInfo(uint _posId)
        external
        view
        returns (
            address[] memory pools,
            uint[] memory amts,
            address[] memory wLps,
            uint[][] memory ids,
            uint[][] memory wLpAmts
        );
    function getCollAmt(uint _posId, address _pool) external view returns (uint amt);
    function getCollWLpAmt(uint _posId, address _wLp, uint _tokenId) external view returns (uint amt);
    function getPosCollCount(uint _posId) external view returns (uint8 collCount);
    function getPosCollWLpCount(uint _posId) external view returns (uint8 wLpCount);
    function getPosInfo(uint _posId) external view returns (address viewerAddress, uint16 mode);
    function getPosMode(uint _posId) external view returns (uint16 mode);
    function getPosDebtShares(uint _posId, address _pool) external view returns (uint debtShares);
    function getViewerPosIdsAt(address _viewer, uint _index) external view returns (uint posId);
    function getViewerPosIdsLength(address _viewer) external view returns (uint length);
    function updatePosDebtShares(uint _posId, address _pool, int _debtShares) external;
    function updatePosMode(uint _posId, uint16 _mode) external;
    function addCollateral(uint _posId, address _pool) external returns (uint amtIn);
    function addCollateralWLp(uint _posId, address _wLp, uint _tokenId) external returns (uint amtIn);
    function removeCollateralTo(uint _posId, address _pool, uint _shares, address _receiver)
        external
        returns (uint amtOut);
    function removeCollateralWLpTo(uint _posId, address _wLp, uint _tokenId, uint _amt, address _receiver)
        external
        returns (uint amtOut);
    function createPos(address _owner, uint16 _mode, address _viewer) external returns (uint posId);
    function harvestTo(uint _posId, address _wlp, uint _tokenId, address _to)
        external
        returns (address[] memory tokens, uint[] memory amts);
    function claimPendingRewards(uint _posId, address[] calldata _tokens, address _to)
        external
        returns (uint[] memory amts);
    function isAuthorized(address _account, uint _posId) external view returns (bool);
    function setMaxCollCount(uint8 _maxCollCount) external;
    function setPosViewer(uint _posId, address _viewer) external;
}
interface IBaseSwapHelper {
    function swap(SwapInfo calldata _swapInfo) external;
}
interface IInitOracle is IBaseOracle {
    event SetPrimarySource(address indexed token, address oracle);
    event SetSecondarySource(address indexed token, address oracle);
    event SetMaxPriceDeviation_e18(address indexed token, uint maxPriceDeviation_e18);
    function primarySources(address _token) external view returns (address primarySource);
    function secondarySources(address _token) external view returns (address secondarySource);
    function maxPriceDeviations_e18(address _token) external view returns (uint maxPriceDeviation_e18);
    function getPrices_e36(address[] calldata _tokens) external view returns (uint[] memory prices_e36);
    function setPrimarySources(address[] calldata _tokens, address[] calldata _sources) external;
    function setSecondarySources(address[] calldata _tokens, address[] calldata _sources) external;
    function setMaxPriceDeviations_e18(address[] calldata _tokens, uint[] calldata _maxPriceDeviations_e18) external;
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
interface IInitCore {
    event SetConfig(address indexed newConfig);
    event SetOracle(address indexed newOracle);
    event SetIncentiveCalculator(address indexed newIncentiveCalculator);
    event SetRiskManager(address indexed newRiskManager);
    event Borrow(address indexed pool, uint indexed posId, address indexed to, uint borrowAmt, uint shares);
    event Repay(address indexed pool, uint indexed posId, address indexed repayer, uint shares, uint amtToRepay);
    event CreatePosition(address indexed owner, uint indexed posId, uint16 mode, address viewer);
    event SetPositionMode(uint indexed posId, uint16 mode);
    event Collateralize(uint indexed posId, address indexed pool, uint amt);
    event Decollateralize(uint indexed posId, address indexed pool, address indexed to, uint amt);
    event CollateralizeWLp(uint indexed posId, address indexed wLp, uint indexed tokenId, uint amt);
    event DecollateralizeWLp(uint indexed posId, address indexed wLp, uint indexed tokenId, address to, uint amt);
    event Liquidate(uint indexed posId, address indexed liquidator, address poolOut, uint shares);
    event LiquidateWLp(uint indexed posId, address indexed liquidator, address wLpOut, uint tokenId, uint amt);
    struct LiquidateLocalVars {
        IConfig config;
        uint16 mode;
        uint health_e18;
        uint liqIncentive_e18;
        address collToken;
        address repayToken;
        uint repayAmt;
        uint repayAmtWithLiqIncentive;
    }
    function POS_MANAGER() external view returns (address);
    function config() external view returns (address);
    function oracle() external view returns (address);
    function riskManager() external view returns (address);
    function liqIncentiveCalculator() external view returns (address);
    function mintTo(address _pool, address _to) external returns (uint shares);
    function burnTo(address _pool, address _to) external returns (uint amt);
    function borrow(address _pool, uint _amt, uint _posId, address _to) external returns (uint shares);
    function repay(address _pool, uint _shares, uint _posId) external returns (uint amt);
    function createPos(uint16 _mode, address _viewer) external returns (uint posId);
    function setPosMode(uint _posId, uint16 _mode) external;
    function collateralize(uint _posId, address _pool) external;
    function decollateralize(uint _posId, address _pool, uint _shares, address _to) external;
    function collateralizeWLp(uint _posId, address _wLp, uint _tokenId) external;
    function decollateralizeWLp(uint _posId, address _wLp, uint _tokenId, uint _amt, address _to) external;
    function liquidate(uint _posId, address _poolToRepay, uint _repayShares, address _tokenOut, uint _minShares)
        external
        returns (uint amt);
    function liquidateWLp(
        uint _posId,
        address _poolToRepay,
        uint _repayShares,
        address _wLp,
        uint _tokenId,
        uint _minLpOut
    ) external returns (uint amt);
    function flash(address[] calldata _pools, uint[] calldata _amts, bytes calldata _data) external;
    function callback(address _to, uint _value, bytes calldata _data) external payable returns (bytes memory result);
    function getCollateralCreditCurrent_e36(uint _posId) external returns (uint credit);
    function getBorrowCreditCurrent_e36(uint _posId) external returns (uint credit);
    function getPosHealthCurrent_e18(uint _posId) external returns (uint health);
    function setConfig(address _config) external;
    function setOracle(address _oracle) external;
    function setLiqIncentiveCalculator(address _liqIncentiveCalculator) external;
    function setRiskManager(address _riskManager) external;
    function transferToken(address _token, address _to, uint _amt) external;
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
contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {
    function __ERC721Holder_init() internal onlyInitializing {
    }
    function __ERC721Holder_init_unchained() internal onlyInitializing {
    }
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}
abstract contract BaseMappingIdHook is ERC721HolderUpgradeable {
    using SafeERC20 for IERC20;
    address public immutable CORE;
    address public immutable POS_MANAGER;
    mapping(address => uint) public lastPosIds;
    mapping(address => mapping(uint => uint)) public initPosIds;
    constructor(address _core, address _posManager) {
        CORE = _core;
        POS_MANAGER = _posManager;
    }
    function _ensureApprove(address _token, uint _amt) internal {
        if (IERC20(_token).allowance(address(this), CORE) < _amt) {
            IERC20(_token).safeApprove(CORE, type(uint).max);
        }
    }
}
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