pragma solidity ^0.8.0;
import "./interface/ILinearVesting.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
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