pragma solidity 0.8.12;
interface IERC20Upgradeable {
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
        return functionCall(target, data, "Address: low-level call failed");
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
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}
library SafeERC20Upgradeable {
    using AddressUpgradeable for address;
    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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
    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 wad) external;
    function transfer(address dst, uint256 wad) external;
    function balanceOf(address dst) external view returns (uint256);
    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);
}
interface IGymMLM {
    function isOnGymMLM(address) external view returns (bool);
    function addGymMLM(address, uint256) external;
    function distributeRewards(
        uint256,
        address,
        address,
        uint32
    ) external;
    function updateInvestment(address _user, uint256 _newInvestment) external;
    function investment(address _user) external view returns (uint256);
    function getPendingRewards(address, uint32) external view returns (uint256);
}
interface IPancakeRouter01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
}
interface IPancakeRouter02 is IPancakeRouter01 {
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
interface IERC20Burnable is IERC20Upgradeable {
    function burn(uint256 _amount) external;
    function burnFrom(address _account, uint256 _amount) external;
}
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }
    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
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
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }
    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}
interface IPancakePair {
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
    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
library DateTime {
    uint256 constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint256 constant SECONDS_PER_HOUR = 60 * 60;
    uint256 constant SECONDS_PER_MINUTE = 60;
    int256 constant OFFSET19700101 = 2440588;
    uint256 constant DOW_MON = 1;
    uint256 constant DOW_TUE = 2;
    uint256 constant DOW_WED = 3;
    uint256 constant DOW_THU = 4;
    uint256 constant DOW_FRI = 5;
    uint256 constant DOW_SAT = 6;
    uint256 constant DOW_SUN = 7;
    function _daysFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 _days) {
        require(year >= 1970);
        int256 _year = int256(year);
        int256 _month = int256(month);
        int256 _day = int256(day);
        int256 __days =
            _day -
                32075 +
                (1461 * (_year + 4800 + (_month - 14) / 12)) /
                4 +
                (367 * (_month - 2 - ((_month - 14) / 12) * 12)) /
                12 -
                (3 * ((_year + 4900 + (_month - 14) / 12) / 100)) /
                4 -
                OFFSET19700101;
        _days = uint256(__days);
    }
    function _daysToDate(uint256 _days)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        int256 __days = int256(_days);
        int256 L = __days + 68569 + OFFSET19700101;
        int256 N = (4 * L) / 146097;
        L = L - (146097 * N + 3) / 4;
        int256 _year = (4000 * (L + 1)) / 1461001;
        L = L - (1461 * _year) / 4 + 31;
        int256 _month = (80 * L) / 2447;
        int256 _day = L - (2447 * _month) / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;
        year = uint256(_year);
        month = uint256(_month);
        day = uint256(_day);
    }
    function timestampFromDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (uint256 timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (uint256 timestamp) {
        timestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            hour *
            SECONDS_PER_HOUR +
            minute *
            SECONDS_PER_MINUTE +
            second;
    }
    function timestampToDate(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint256 timestamp)
        internal
        pure
        returns (
            uint256 year,
            uint256 month,
            uint256 day,
            uint256 hour,
            uint256 minute,
            uint256 second
        )
    {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }
    function isValidDate(
        uint256 year,
        uint256 month,
        uint256 day
    ) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint256 daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 hour,
        uint256 minute,
        uint256 second
    ) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint256 timestamp)
        internal
        pure
        returns (bool leapYear)
    {
        (uint256 year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint256 year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint256 timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint256 timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint256 timestamp)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        (uint256 year, uint256 month, ) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint256 year, uint256 month)
        internal
        pure
        returns (uint256 daysInMonth)
    {
        if (
            month == 1 ||
            month == 3 ||
            month == 5 ||
            month == 7 ||
            month == 8 ||
            month == 10 ||
            month == 12
        ) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    function getDayOfWeek(uint256 timestamp)
        internal
        pure
        returns (uint256 dayOfWeek)
    {
        uint256 _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = ((_days + 3) % 7) + 1;
    }
    function getYear(uint256 timestamp) internal pure returns (uint256 year) {
        (year, , ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint256 timestamp) internal pure returns (uint256 month) {
        (, month, ) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint256 timestamp) internal pure returns (uint256 day) {
        (, , day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint256 timestamp) internal pure returns (uint256 hour) {
        uint256 secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint256 timestamp)
        internal
        pure
        returns (uint256 minute)
    {
        uint256 secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint256 timestamp)
        internal
        pure
        returns (uint256 second)
    {
        second = timestamp % SECONDS_PER_MINUTE;
    }
    function addYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = ((month - 1) % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp >= timestamp);
    }
    function addDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }
    function subYears(uint256 timestamp, uint256 _years)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint256 timestamp, uint256 _months)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        (uint256 year, uint256 month, uint256 day) =
            _daysToDate(timestamp / SECONDS_PER_DAY);
        uint256 yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = (yearMonth % 12) + 1;
        uint256 daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp =
            _daysFromDate(year, month, day) *
            SECONDS_PER_DAY +
            (timestamp % SECONDS_PER_DAY);
        require(newTimestamp <= timestamp);
    }
    function subDays(uint256 timestamp, uint256 _days)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint256 timestamp, uint256 _hours)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint256 timestamp, uint256 _minutes)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint256 timestamp, uint256 _seconds)
        internal
        pure
        returns (uint256 newTimestamp)
    {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }
    function diffYears(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _years)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, , ) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, , ) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _months)
    {
        require(fromTimestamp <= toTimestamp);
        (uint256 fromYear, uint256 fromMonth, ) =
            _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint256 toYear, uint256 toMonth, ) =
            _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _days)
    {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _hours)
    {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _minutes)
    {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint256 fromTimestamp, uint256 toTimestamp)
        internal
        pure
        returns (uint256 _seconds)
    {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}
contract GymSinglePool is ReentrancyGuardUpgradeable, OwnableUpgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    struct UserInfo {
        uint256 totalDepositTokens;
        uint256 totalDepositDollarValue;
        uint256 level;
        uint256 depositId;
        uint256 totalClaimt;
    }
    struct UserDeposits {
        uint256 depositTokens;
        uint256 depositDollarValue;
        uint256 stakePeriod;
        uint256 depositTimestamp;
        uint256 withdrawalTimestamp;
        uint256 rewardsGained;
        uint256 rewardsClaimt;
        uint256 rewardDebt;
        bool is_finished;
    }
    struct PoolInfo {
        uint256 lastRewardBlock;
        uint256 accRewardPerShare;
        uint256 rewardPerBlock;
    }
    uint256 public startBlock;
    uint256 public withdrawFee;
    address public relationship;
    address public treasuryAddress;
    PoolInfo public poolInfo;
    mapping(address => UserInfo) public userInfo;
    mapping (address=>UserDeposits[]) public user_deposits;
    uint256 private lastChangeBlock;
    address public tokenAddress;
    address public pancakeRouterAddress;
    address[] public wbnbAndUSDTTokenArray;
    address[] public GymWBNBPair;
    uint256[16] public levels;
    uint256[6] public months;
    uint256 public totalGymnetLocked;
    uint256 public totalClaimtInPool;
    uint256 public RELATIONSHIP_REWARD;
    uint256 public poolRewardsAmount;
    address public holderRewardContractAddress;
    address public runnerScriptAddress;
    uint256 public totalBurntInSinglePool;
    bool public isPoolActive;
    bool public isInMigrationToVTwo;
    uint256 public totalGymnetUnlocked;
    uint256 public unlockedTimestampQualification;
    address public vaultContractAddress;
    address public farmingContractAddress;
    event Initialized(address indexed executor, uint256 at);
    event Deposit(address indexed user, uint256 amount,uint indexed period);
    event Withdraw(address indexed user, uint256 amount,uint indexed period);
    event RewardPaid(address indexed token, address indexed user, uint256 amount);
    event ClaimUserReward(address indexed user, uint256 amount);
    modifier onlyRunnerScript() {
        require(msg.sender == runnerScriptAddress || msg.sender == owner(), "Only Runner Script");
        _;
    }
    modifier onlyBank() {
        require(msg.sender == vaultContractAddress, "GymFarming:: Only bank");
        _;
    }
    receive() external payable {}
    fallback() external payable {}
    function initialize(
        uint256 _startBlock,
        address _gym,
        address _mlm,
        uint256 _gymRewardRate,
        address _pancakeRouterAddress,
        address[] memory _wbnbAndUSDTTokenArray,
        address[] memory _GymWBNBPair
    ) external initializer {
        require(block.number < _startBlock, "SinglePool: Start block must have a bigger value");
        startBlock = _startBlock; 
        relationship = _mlm;  
        tokenAddress = _gym; 
        pancakeRouterAddress = _pancakeRouterAddress; 
        wbnbAndUSDTTokenArray = _wbnbAndUSDTTokenArray; 
        GymWBNBPair = _GymWBNBPair; 
        runnerScriptAddress = msg.sender;
        isPoolActive = false;
        isInMigrationToVTwo = false;
        RELATIONSHIP_REWARD = 39; 
        levels = [0, 0, 200, 200, 2000, 4000, 10000, 20000, 40000, 45000, 50000, 60000, 65000, 70000, 75000, 80000]; 
        months = [3, 6, 12, 18, 24, 30]; 
        poolInfo = PoolInfo({
                lastRewardBlock: _startBlock,
                rewardPerBlock: _gymRewardRate,
                accRewardPerShare: 0
            });
        lastChangeBlock = _startBlock;
        __Ownable_init();
        __ReentrancyGuard_init();
        emit Initialized(msg.sender, block.number);
    }
    function setPoolInfo(uint256 lastRewardBlock,uint256 accRewardPerShare, uint256 rewardPerBlock) external onlyOwner {
        poolInfo = PoolInfo({
                lastRewardBlock: lastRewardBlock,
                accRewardPerShare: accRewardPerShare,
                rewardPerBlock: rewardPerBlock
            });
    }
    function updateStartBlock(uint256 _startBlock) external onlyOwner {
        startBlock = _startBlock;
    }
    function setMLMAddress(address _relationship) external onlyOwner {
        relationship = _relationship;
    }
    function setTokenAddress(address _tokenAddress) external onlyOwner {
        tokenAddress = _tokenAddress;
    }
    function setVaultContractAddress(address _vaultContractAddress) external onlyOwner {
        vaultContractAddress = _vaultContractAddress;
    }
    function setFarmingContractAddress(address _farmingContractAddress) external onlyOwner {
        farmingContractAddress = _farmingContractAddress;
    }
    function setRelationshipReward(uint256 _amount) external onlyOwner {
        RELATIONSHIP_REWARD = _amount;
    }
    function setOnlyRunnerScript(address _onlyRunnerScript) external onlyOwner {
        runnerScriptAddress = _onlyRunnerScript;
    }
    function setGymWBNBPair(address[] memory  _GymWBNBPair) external onlyOwner {
        GymWBNBPair = _GymWBNBPair;
    }
    function setPancakeRouterAddress(address _pancakeRouterAddress) external onlyOwner {
        pancakeRouterAddress = _pancakeRouterAddress;
    }
    function setIsPoolActive(bool _isPoolActive) external onlyOwner {
        isPoolActive = _isPoolActive;
    }
    function setIsInMigrationToVTwo(bool _isInMigrationToVTwo) external onlyOwner {
        isInMigrationToVTwo = _isInMigrationToVTwo;
    }
    function setHolderRewardContractAddress(address _holderRewardContractAddress) external onlyOwner {
        holderRewardContractAddress = _holderRewardContractAddress;
    }
    function setWbnbAndUSDTTokenArray(address[] memory _wbnbAndUSDTTokenArray) external onlyOwner {
        wbnbAndUSDTTokenArray = _wbnbAndUSDTTokenArray;
    }
    function setUnlockedTimestampQualification(uint256 _unlockedTimestampQualification) external onlyOwner {
        unlockedTimestampQualification = _unlockedTimestampQualification;
    }
    function setLevels(uint256[16] calldata _levels) external onlyOwner {
        levels = _levels;
    }
    function setTreasuryAddress(address _treasuryAddress) external nonReentrant onlyOwner {
        treasuryAddress = _treasuryAddress;
    }
    function deposit(
        uint256 _depositAmount,
        uint8 _periodId,
        uint256 _referrerId,
        bool isUnlocked
    ) external  {
        require(isPoolActive,'Contract is not running yet');
        IGymMLM(relationship).addGymMLM(msg.sender, _referrerId);
        _deposit(_depositAmount,_periodId,isUnlocked);
    }
    function depositFromOtherContract(
        uint256 _depositAmount,
        uint8 _periodId,
        bool isUnlocked,
        address _from
    ) external  {
        require(isPoolActive,'Contract is not running yet');
        _autoDeposit(_depositAmount,_periodId,isUnlocked,_from);
    }
    function getUserLevelInSinglePool(address _user) external view returns (uint32) {
        uint256 _totalDepositDollarValue = userInfo[_user].totalDepositDollarValue;
        uint32 level = 0;
        for (uint32 i = 0; i<levels.length ; i++) {
            if(_totalDepositDollarValue >= levels[i]) {
                level=i;
            }
        }
        return level;
    }
    function _deposit(
        uint256 _depositAmount,
        uint8 _periodId,
        bool _isUnlocked
    ) private {
        UserInfo storage user = userInfo[msg.sender];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;
        updatePool();
        uint256 period = months[_periodId];
        uint256 lockTimesamp = DateTime.addMonths(block.timestamp,months[_periodId]);
        uint256 burnTokensAmount = 0;
        if(!_isUnlocked) {
            burnTokensAmount = (_depositAmount * 4) / 100;
            totalBurntInSinglePool += burnTokensAmount;
            IERC20Burnable(tokenAddress).burnFrom(msg.sender,burnTokensAmount);
        }
        uint256 amountToDeposit = _depositAmount - burnTokensAmount;
        token.safeTransferFrom(msg.sender, address(this), amountToDeposit);
        uint256 UsdValueOfGym = ((amountToDeposit * getPrice())/1e18) / 1e18;
        user.totalDepositTokens += amountToDeposit;
        user.totalDepositDollarValue += UsdValueOfGym;
        totalGymnetLocked += amountToDeposit;
        if(_isUnlocked) {
            totalGymnetUnlocked += amountToDeposit;
            period = 0; 
            lockTimesamp = DateTime.addSeconds(block.timestamp,months[_periodId]);
        }
        uint256 rewardDebt = (amountToDeposit * (pool.accRewardPerShare)) / (1e18);
        UserDeposits memory depositDetails = UserDeposits(
            {
                depositTokens: amountToDeposit, 
                depositDollarValue: UsdValueOfGym,
                stakePeriod: period,
                depositTimestamp: block.timestamp,
                withdrawalTimestamp: lockTimesamp,
                rewardsGained: 0,
                is_finished: false,
                rewardsClaimt: 0,
                rewardDebt: rewardDebt
            }
        );
        user_deposits[msg.sender].push(depositDetails);
        user.depositId = user_deposits[msg.sender].length;
       for (uint i = 0; i<levels.length ; i++) {
            if(user.totalDepositDollarValue >= levels[i]) {
                user.level=i;
            }
        }
        emit Deposit(msg.sender, _depositAmount,_periodId);
    }
    function _autoDeposit(
        uint256 _depositAmount,
        uint8 _periodId,
        bool _isUnlocked,
        address _from
    ) private {
        UserInfo storage user = userInfo[_from];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;
        token.approve(address(this), _depositAmount);
        updatePool();
        uint256 period = months[_periodId];
        uint256 lockTimesamp = DateTime.addMonths(block.timestamp,months[_periodId]);
        uint256 burnTokensAmount = 0;
        uint256 amountToDeposit = _depositAmount - burnTokensAmount;
        uint256 UsdValueOfGym = ((amountToDeposit * getPrice())/1e18) / 1e18;
        user.totalDepositTokens += amountToDeposit;
        user.totalDepositDollarValue += UsdValueOfGym;
        totalGymnetLocked += amountToDeposit;
        if(_isUnlocked) {
            totalGymnetUnlocked += amountToDeposit;
            period = 0; 
            lockTimesamp = DateTime.addSeconds(block.timestamp,months[_periodId]);
        }
        uint256 rewardDebt = (amountToDeposit * (pool.accRewardPerShare)) / (1e18);
        UserDeposits memory depositDetails = UserDeposits(
            {
                depositTokens: amountToDeposit, 
                depositDollarValue: UsdValueOfGym,
                stakePeriod: period,
                depositTimestamp: block.timestamp,
                withdrawalTimestamp: lockTimesamp,
                rewardsGained: 0,
                is_finished: false,
                rewardsClaimt: 0,
                rewardDebt: rewardDebt
            }
        );
        user_deposits[_from].push(depositDetails);
        user.depositId = user_deposits[_from].length;
        emit Deposit(_from, amountToDeposit,_periodId);
    }
    function getPrice () public view returns (uint) {
        uint256[] memory gymPriceInUSD = IPancakeRouter02(pancakeRouterAddress).getAmountsOut(1000000000000000000,GymWBNBPair);
        uint256[] memory BNBPriceInUSD = IPancakeRouter02(pancakeRouterAddress).getAmountsOut(1, wbnbAndUSDTTokenArray);
        return gymPriceInUSD[1] * BNBPriceInUSD[1];
    }
    function withdraw(
        uint256 _depositId
    ) external  {
        require(_depositId >= 0, "Value is not specified");
        updatePool();
        _withdraw(_depositId);
    }
    function _withdraw(
            uint256 _depositId
        ) private {
            UserInfo storage user = userInfo[msg.sender];
            IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
            PoolInfo storage pool = poolInfo;
            UserDeposits storage depositDetails = user_deposits[msg.sender][_depositId];
            if(!isInMigrationToVTwo) {
                require(block.timestamp > depositDetails.withdrawalTimestamp,"Locking Period isn't over yet.");
            }
            require(!depositDetails.is_finished,"You already withdrawn your deposit.");
            _claim(_depositId,1);
            depositDetails.rewardDebt = (depositDetails.depositTokens * (pool.accRewardPerShare)) / (1e18);
            user.totalDepositTokens -=  depositDetails.depositTokens;
            user.totalDepositDollarValue -=  depositDetails.depositDollarValue;
            totalGymnetLocked -= depositDetails.depositTokens;
            if(depositDetails.stakePeriod == 0) {
                totalGymnetUnlocked -= depositDetails.depositTokens;
            }
            token.safeTransferFrom(address(this),msg.sender, depositDetails.depositTokens);
            for (uint i = 0; i<levels.length ; i++) {
                if(user.totalDepositDollarValue >= levels[i]) {
                    user.level=i;
                }
            }
            depositDetails.is_finished = true;
            emit Withdraw(msg.sender,  depositDetails.depositTokens,depositDetails.stakePeriod);
        }
    function claim(
        uint256 _depositId
    ) external  {
        require(_depositId >= 0, "Value is not specified");
        updatePool();
        refreshMyLevel(msg.sender);
        _claim(_depositId,0);
    }
    function _claim(
            uint256 _depositId,
            uint256 fromWithdraw
        ) private {
            UserInfo storage user = userInfo[msg.sender];
            IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
            UserDeposits storage depositDetails = user_deposits[msg.sender][_depositId];
            PoolInfo storage pool = poolInfo;
            uint256 pending = pendingReward(_depositId,msg.sender);
            if(fromWithdraw == 0) {
                require(pending > 0 ,"No rewards to claim.");
            }
            if (pending > 0) {
                uint256 distributeRewardTokenAmt = (pending * RELATIONSHIP_REWARD) / 100;
                token.safeTransfer(relationship, distributeRewardTokenAmt);
                IGymMLM(relationship).distributeRewards(pending, address(tokenAddress), msg.sender, 3);
                uint256 calculateDistrubutionReward = (pending * 6) / 100;
                poolRewardsAmount += calculateDistrubutionReward; 
                uint256 calcUserRewards = (pending-distributeRewardTokenAmt-calculateDistrubutionReward);
                safeRewardTransfer(tokenAddress, msg.sender, calcUserRewards);
                user.totalClaimt += calcUserRewards;
                totalClaimtInPool += pending;
                depositDetails.rewardsClaimt += pending;
                depositDetails.rewardDebt = (depositDetails.depositTokens * (pool.accRewardPerShare)) / (1e18);
                emit ClaimUserReward(msg.sender,  calcUserRewards);
                 depositDetails.rewardsGained = 0;
            }
        }
    function transferPoolRewards() public onlyRunnerScript {
            require(address(holderRewardContractAddress) != address(0x0),"Holder Reward Address::SET_ZERO_ADDRESS");
            IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
            token.safeTransfer(holderRewardContractAddress, poolRewardsAmount);
            poolRewardsAmount = 0;
        }  
    function safeRewardTransfer(
        address _rewardToken,
        address _to,
        uint256 _amount
    ) internal {
        uint256 _bal = IERC20Upgradeable(_rewardToken).balanceOf(address(this));
        if (_amount > _bal) {
            require(IERC20Upgradeable(_rewardToken).transfer(_to, _bal), "GymSinglePool:: Transfer failed");
        } else {
            require(IERC20Upgradeable(_rewardToken).transfer(_to, _amount), "GymSinglePool:: Transfer failed");
        }
    }
    function getUserInfo(address _user) external view returns (UserInfo memory) {
        return userInfo[_user];
    }
    function pendingReward(uint256 _depositId, address _user) public view returns (uint256) {
        UserDeposits storage depositDetails = user_deposits[_user][_depositId];
        UserInfo storage user = userInfo[_user];
        PoolInfo storage pool = poolInfo;
        if(depositDetails.is_finished == true || depositDetails.stakePeriod == 0){
            return 0;
        }
        uint256 _accRewardPerShare = pool.accRewardPerShare;
        uint256 sharesTotal = totalGymnetLocked-totalGymnetUnlocked;
        if (block.number > pool.lastRewardBlock && sharesTotal != 0) {
            uint256 _multiplier = block.number - pool.lastRewardBlock;
            uint256 _reward = (_multiplier * pool.rewardPerBlock);
             _accRewardPerShare = _accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        }
        return (depositDetails.depositTokens * _accRewardPerShare) / (1e18) - (depositDetails.rewardDebt);
    }
    function updatePool() public {
        PoolInfo storage pool = poolInfo;
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 sharesTotal = totalGymnetLocked-totalGymnetUnlocked;
        if (sharesTotal == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = block.number - pool.lastRewardBlock;
        if (multiplier <= 0) {
            return;
        }
        uint256 _rewardPerBlock = pool.rewardPerBlock;
        uint256 _reward = (multiplier * _rewardPerBlock);
        pool.accRewardPerShare = pool.accRewardPerShare + ((_reward * 1e18) / sharesTotal);
        pool.lastRewardBlock = block.number;
    }
    function _claimAll(bool reinvest,uint8 reinvestPeriodId) private {
        UserInfo storage user = userInfo[msg.sender];
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        PoolInfo storage pool = poolInfo;
         updatePool();
         uint256 distributeRewardTokenAmtTotal = 0;
         uint256 calcUserRewardsTotal = 0;
         uint256 totalDistribute = 0;
        for (uint256 i = 0; i<user.depositId ; i++) {
            UserDeposits storage depositDetails = user_deposits[msg.sender][i];
            uint256 pending = pendingReward(i,msg.sender);
            totalDistribute += pending;
            if (pending > 0) {
                uint256 distributeRewardTokenAmt = (pending * RELATIONSHIP_REWARD) / 100;
                 distributeRewardTokenAmtTotal += distributeRewardTokenAmt;
                uint256 calculateDistrubutionReward = (pending * 6) / 100;
                poolRewardsAmount += calculateDistrubutionReward; 
                uint256 calcUserRewards = (pending-distributeRewardTokenAmt-calculateDistrubutionReward);
                calcUserRewardsTotal += calcUserRewards;
                user.totalClaimt += calcUserRewards;
                totalClaimtInPool += pending;
                depositDetails.rewardsClaimt += pending;
                depositDetails.rewardDebt = (depositDetails.depositTokens * (pool.accRewardPerShare)) / (1e18);
                emit ClaimUserReward(msg.sender,  calcUserRewards);
                 depositDetails.rewardsGained = 0;
            }
        }
        token.safeTransfer(relationship, distributeRewardTokenAmtTotal);
        IGymMLM(relationship).distributeRewards(totalDistribute, address(tokenAddress), msg.sender, 3);
        safeRewardTransfer(tokenAddress, msg.sender, calcUserRewardsTotal);
        if(reinvest == true) {
          _deposit(calcUserRewardsTotal,reinvestPeriodId,false);
        }
    }
    function claimAll() public {
         refreshMyLevel(msg.sender);
        _claimAll(false,0);
    }
    function claimAndReinvest(bool reinvest,uint8 periodId) public {
        require(isPoolActive,'Contract is not running yet');
        _claimAll(reinvest,periodId);
    }
    function refreshMyLevel(address _user) public {
        UserInfo storage user = userInfo[_user];
        for (uint i = 0; i<levels.length ; i++) {
            if(user.totalDepositDollarValue >= levels[i]) {
                user.level=i;
            }
        }
    }
    function totalLockedTokens(address _user) public view returns (uint256) {
        UserInfo storage user = userInfo[_user];
        uint256 totalDepositLocked = 0;
        for (uint256 i = 0; i<user.depositId ; i++) {
            UserDeposits storage depositDetails = user_deposits[_user][i];
            if(depositDetails.stakePeriod != 0 && !depositDetails.is_finished) {
                totalDepositLocked += depositDetails.depositTokens;
            } 
        }
        return totalDepositLocked;
    }
    function switchToUnlocked(uint256 _depositId) public {
        UserInfo storage user = userInfo[msg.sender];
        UserDeposits storage depositDetails = user_deposits[msg.sender][_depositId];
        require(depositDetails.depositTimestamp <= unlockedTimestampQualification,'Function is only for Users that deposited before Unlocked Staking Upgrade');
        _claim(_depositId,1);
        uint256 lockTimesamp = DateTime.addSeconds(block.timestamp,1);
        depositDetails.stakePeriod = 0;
        depositDetails.withdrawalTimestamp = lockTimesamp;
        totalGymnetUnlocked += depositDetails.depositTokens;
    }
}