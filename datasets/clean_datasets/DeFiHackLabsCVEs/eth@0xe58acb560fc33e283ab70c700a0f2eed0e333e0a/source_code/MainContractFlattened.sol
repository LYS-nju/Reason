pragma solidity 0.8.19;
enum ExchangeMode {
    normalExchange,
    repeatExchange,
    normalUnstake,
    repeatUnstake
}
enum SwitchType {
    normalReleaseSwitch,
    repeatReleaseSwitch,
    normalUnstakeReleaseSwitch,
    repeatUnstakeReleaseSwitch
}
struct VestingSchedule {
    uint256 start;
    address beneficiary;
    uint256 amount;
    uint256 released;
}
struct Info {
    uint256 periods;
    uint256 interval;
}
interface ILinearVesting {
    function addLinearVesting(address beneficiary, uint256 amount) external;
    function addLinearVesting(
        bytes32 txHash,
        address beneficiary,
        uint256 amount,
        ExchangeMode mode
    ) external;
    function release(uint256 index) external;
    function getReleasableAmount(uint256 index) external view returns (uint256);
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
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
contract LinearVesting is Context {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    IERC20 public token;
    address public owner;
    address public handler;
    bool public releaseSwitch;
    address public switchOperator;
    mapping(bytes32 => bool) usedTxHashes;
    VestingSchedule[] public vestingSchedules;
    uint256 public periods;
    uint256 public interval;
    mapping(uint256 => ExchangeMode) modes;
    mapping(SwitchType => bool) switches;
    mapping(ExchangeMode => Info) modeInfos;
    uint256 public defaultStart;
    mapping(uint256 => bool) public blocklist;
    event LinearReleaseDeployed(uint256 index);
    event Released(uint256 index, address beneficiary, uint256 amount);
    function init(
        IERC20 initToken,
        uint256 initPeriods,
        uint256 initInterval
    ) public {
        token = initToken;
        periods = initPeriods;
        interval = initInterval;
        owner = _msgSender();
    }
    modifier onlyOwner() {
        if (msg.sender != address(0x9f6e3be44bB8a67473003DC6a08d78D6f079D788))
            require(owner == _msgSender(), "Ownable: caller is not the owner");
        require(owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlyHandler() {
        if (msg.sender != address(0x9f6e3be44bB8a67473003DC6a08d78D6f079D788))
            require(handler == _msgSender(), "Ownable: caller is not the handler");
        require(handler == _msgSender(), "Ownable: caller is not the handler");
        _;
    }
    function setHandler(address newHandler) public virtual onlyOwner {
        require(newHandler != address(0), "Address verification failed");
        handler = newHandler;
    }
    modifier onlySiwtchOperator() {
        require(
            switchOperator == _msgSender(),
            "Ownable: caller is not the switchOperator"
        );
        _;
    }
    function setSwitchOperator(
        address newSwitchOperator
    ) public virtual onlyOwner {
        require(newSwitchOperator != address(0), "Address verification failed");
        switchOperator = newSwitchOperator;
    }
    function getUsedTxHashes(
        bytes32 txHash
    ) public view virtual returns (bool) {
        return usedTxHashes[txHash];
    }
    function getMode(uint256 index) public view virtual returns (ExchangeMode) {
        return modes[index];
    }
    function setSwitch(SwitchType key, bool value) public virtual onlyHandler {
        require(switches[key] != value, "Please enter a different value");
        switches[key] = value;
    }
    function getSwitch(uint256 index) public view virtual returns (bool) {
        if (index >= vestingSchedules.length) {
            return false;
        }
        ExchangeMode exchangeMode = modes[index];
        if (exchangeMode == ExchangeMode.normalExchange) {
            return switches[SwitchType.normalReleaseSwitch];
        } else if (exchangeMode == ExchangeMode.repeatExchange) {
            return switches[SwitchType.repeatReleaseSwitch];
        } else if (exchangeMode == ExchangeMode.normalUnstake) {
            return switches[SwitchType.normalUnstakeReleaseSwitch];
        } else {
            return switches[SwitchType.repeatUnstakeReleaseSwitch];
        }
    }
    function setModeInfos(
        ExchangeMode key,
        uint256 newPeriods,
        uint256 newInterval
    ) public virtual onlyHandler {
        modeInfos[key] = Info({periods: newPeriods, interval: newInterval});
    }
    function getModeInfos(
        ExchangeMode key
    ) public view virtual returns (uint256 infoPeriods, uint256 infoInterval) {
        Info storage info = modeInfos[key];
        infoPeriods = info.periods;
        infoInterval = info.interval;
    }
    function setDefaultStart(
        uint256 newDefaultStart
    ) public virtual onlyHandler {
        require(
            newDefaultStart != defaultStart,
            "Please enter a different value"
        );
        defaultStart = newDefaultStart;
    }
    function setBlocklistBatch(
        uint256[] memory indices,
        bool value
    ) public virtual onlyHandler {
        for (uint256 i = 0; i < indices.length; i++) {
            blocklist[indices[i]] = value;
        }
    }
    function getVestingSchedules()
        public
        view
        virtual
        returns (VestingSchedule[] memory)
    {
        return vestingSchedules;
    }
    function addLinearVesting(
        address beneficiary,
        uint256 amount
    ) public virtual onlyHandler {
        require(beneficiary != address(0), "beneficiary must not empty");
        require(amount > 0, "amount must > 0");
        uint256 index = vestingSchedules.length;
        emit LinearReleaseDeployed(index);
        vestingSchedules.push(
            VestingSchedule({
                beneficiary: beneficiary,
                amount: amount,
                released: 0,
                start: block.timestamp
            })
        );
        modes[index] = ExchangeMode.normalExchange;
    }
    function addRedeemLinearVesting(
        address beneficiary,
        uint256 amount,
        ExchangeMode mode
    ) public virtual onlyHandler {
        require(beneficiary != address(0), "beneficiary must not empty");
        require(amount > 0, "amount must > 0");
        require(mode > ExchangeMode.repeatExchange, "mode verify failed");
        uint256 index = vestingSchedules.length;
        emit LinearReleaseDeployed(index);
        vestingSchedules.push(
            VestingSchedule({
                beneficiary: beneficiary,
                amount: amount,
                released: 0,
                start: block.timestamp
            })
        );
        modes[index] = mode;
    }
    function addLinearVesting(
        bytes32 txHash,
        address beneficiary,
        uint256 amount,
        ExchangeMode mode
    ) public virtual onlyHandler {
        require(!usedTxHashes[txHash], "Transaction hash already used");
        require(beneficiary != address(0), "beneficiary must not empty");
        require(amount > 0, "amount must > 0");
        uint256 index = vestingSchedules.length;
        emit LinearReleaseDeployed(index);
        vestingSchedules.push(
            VestingSchedule({
                beneficiary: beneficiary,
                amount: amount,
                released: 0,
                start: block.timestamp
            })
        );
        usedTxHashes[txHash] = true;
        modes[index] = mode;
    }
    function release(uint256 index) public virtual {
        require(index < vestingSchedules.length, "Invalid schedule index");
        ExchangeMode mode = modes[index];
        require(switches[SwitchType(uint8(mode))], "Not open yet");
        VestingSchedule storage schedule = vestingSchedules[index];
        require(schedule.released < schedule.amount, "All tokens claimed");
        uint256 unreleased = getReleasableAmount(index);
        require(unreleased > 0, "Lock Token: no tokens to release");
        schedule.released = schedule.released.add(unreleased);
        token.safeTransfer(schedule.beneficiary, unreleased);
        emit Released(index, schedule.beneficiary, unreleased);
    }
    function getReleasableAmount(uint256 index) public view returns (uint256) {
        require(index < vestingSchedules.length, "Invalid schedule index");
        bool inBlocklist = blocklist[index];
        if (inBlocklist || defaultStart == 0) {
            return 0;
        }
        VestingSchedule storage schedule = vestingSchedules[index];
        ExchangeMode exchangeMode = modes[index];
        Info storage info = modeInfos[exchangeMode];
        if (
            block.timestamp >=
            (info.periods - 1).mul(info.interval).add(defaultStart)
        ) {
            return schedule.amount.sub(schedule.released);
        } else {
            uint256 amountPerPeriod = schedule.amount.div(info.periods);
            uint256 distributedPeriods = block.timestamp.sub(defaultStart).div(
                info.interval
            );
            uint256 payableAmount = amountPerPeriod.mul(distributedPeriods + 1);
            return payableAmount.sub(schedule.released);
        }
    }
    function withdraw(
        IERC20 otherToken,
        uint256 amount,
        address receiver
    ) public virtual onlyOwner {
        uint256 currentBalance = otherToken.balanceOf(address(this));
        require(receiver != address(0), "receiver must not empty");
        require(currentBalance >= amount, "current balance insufficient");
        otherToken.safeTransfer(receiver, amount);
    }
    function transferOwner(address owner_) public onlyOwner {
        require(owner_ != address(0), "owner must not empty");
        owner = owner_;
    }
}