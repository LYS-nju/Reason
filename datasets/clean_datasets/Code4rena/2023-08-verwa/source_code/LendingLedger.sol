pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
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
}
pragma solidity ^0.8.16;
contract VotingEscrow is ReentrancyGuard {
    event Deposit(address indexed provider, uint256 value, uint256 locktime, LockAction indexed action, uint256 ts);
    event Withdraw(address indexed provider, uint256 value, LockAction indexed action, uint256 ts);
    event Unlock();
    string public name;
    string public symbol;
    uint256 public decimals = 18;
    uint256 public constant WEEK = 7 days;
    uint256 public constant LOCKTIME = 1825 days;
    uint256 public constant MULTIPLIER = 10**18;
    uint256 public globalEpoch;
    Point[1000000000000000000] public pointHistory; 
    mapping(address => Point[1000000000]) public userPointHistory;
    mapping(address => uint256) public userPointEpoch;
    mapping(uint256 => int128) public slopeChanges;
    mapping(address => LockedBalance) public locked;
    struct Point {
        int128 bias;
        int128 slope;
        uint256 ts;
        uint256 blk;
    }
    struct LockedBalance {
        int128 amount;
        uint256 end;
        int128 delegated;
        address delegatee;
    }
    enum LockAction {
        CREATE,
        INCREASE_AMOUNT,
        INCREASE_AMOUNT_AND_DELEGATION,
        INCREASE_TIME,
        WITHDRAW,
        QUIT,
        DELEGATE,
        UNDELEGATE
    }
    constructor(string memory _name, string memory _symbol) {
        pointHistory[0] = Point({bias: int128(0), slope: int128(0), ts: block.timestamp, blk: block.number});
        name = _name;
        symbol = _symbol;
    }
    function lockEnd(address _addr) external view returns (uint256) {
        return locked[_addr].end;
    }
    function getLastUserPoint(address _addr)
        external
        view
        returns (
            int128 bias,
            int128 slope,
            uint256 ts
        )
    {
        uint256 uepoch = userPointEpoch[_addr];
        if (uepoch == 0) {
            return (0, 0, 0);
        }
        Point memory point = userPointHistory[_addr][uepoch];
        return (point.bias, point.slope, point.ts);
    }
    function _checkpoint(
        address _addr,
        LockedBalance memory _oldLocked,
        LockedBalance memory _newLocked
    ) internal {
        Point memory userOldPoint;
        Point memory userNewPoint;
        int128 oldSlopeDelta = 0;
        int128 newSlopeDelta = 0;
        uint256 epoch = globalEpoch;
        if (_addr != address(0)) {
            if (_oldLocked.end > block.timestamp && _oldLocked.delegated > 0) {
                userOldPoint.slope = _oldLocked.delegated / int128(int256(LOCKTIME));
                userOldPoint.bias = userOldPoint.slope * int128(int256(_oldLocked.end - block.timestamp));
            }
            if (_newLocked.end > block.timestamp && _newLocked.delegated > 0) {
                userNewPoint.slope = _newLocked.delegated / int128(int256(LOCKTIME));
                userNewPoint.bias = userNewPoint.slope * int128(int256(_newLocked.end - block.timestamp));
            }
            uint256 uEpoch = userPointEpoch[_addr];
            if (uEpoch == 0) {
                userPointHistory[_addr][uEpoch + 1] = userOldPoint;
            }
            userPointEpoch[_addr] = uEpoch + 1;
            userNewPoint.ts = block.timestamp;
            userNewPoint.blk = block.number;
            userPointHistory[_addr][uEpoch + 1] = userNewPoint;
            oldSlopeDelta = slopeChanges[_oldLocked.end];
            if (_newLocked.end != 0) {
                if (_newLocked.end == _oldLocked.end) {
                    newSlopeDelta = oldSlopeDelta;
                } else {
                    newSlopeDelta = slopeChanges[_newLocked.end];
                }
            }
        }
        Point memory lastPoint = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number});
        if (epoch > 0) {
            lastPoint = pointHistory[epoch];
        }
        uint256 lastCheckpoint = lastPoint.ts;
        Point memory initialLastPoint = Point({bias: 0, slope: 0, ts: lastPoint.ts, blk: lastPoint.blk});
        uint256 blockSlope = 0; 
        if (block.timestamp > lastPoint.ts) {
            blockSlope = (MULTIPLIER * (block.number - lastPoint.blk)) / (block.timestamp - lastPoint.ts);
        }
        uint256 iterativeTime = _floorToWeek(lastCheckpoint);
        for (uint256 i = 0; i < 255; i++) {
            iterativeTime = iterativeTime + WEEK;
            int128 dSlope = 0;
            if (iterativeTime > block.timestamp) {
                iterativeTime = block.timestamp;
            } else {
                dSlope = slopeChanges[iterativeTime];
            }
            int128 biasDelta = lastPoint.slope * int128(int256((iterativeTime - lastCheckpoint)));
            lastPoint.bias = lastPoint.bias - biasDelta;
            lastPoint.slope = lastPoint.slope + dSlope;
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
            if (lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }
            lastCheckpoint = iterativeTime;
            lastPoint.ts = iterativeTime;
            lastPoint.blk = initialLastPoint.blk + (blockSlope * (iterativeTime - initialLastPoint.ts)) / MULTIPLIER;
            epoch = epoch + 1;
            if (iterativeTime == block.timestamp) {
                lastPoint.blk = block.number;
                break;
            } else {
                pointHistory[epoch] = lastPoint;
            }
        }
        globalEpoch = epoch;
        if (_addr != address(0)) {
            lastPoint.slope = lastPoint.slope + userNewPoint.slope - userOldPoint.slope;
            lastPoint.bias = lastPoint.bias + userNewPoint.bias - userOldPoint.bias;
            if (lastPoint.slope < 0) {
                lastPoint.slope = 0;
            }
            if (lastPoint.bias < 0) {
                lastPoint.bias = 0;
            }
        }
        pointHistory[epoch] = lastPoint;
        if (_addr != address(0)) {
            if (_oldLocked.end > block.timestamp) {
                oldSlopeDelta = oldSlopeDelta + userOldPoint.slope;
                if (_newLocked.end == _oldLocked.end) {
                    oldSlopeDelta = oldSlopeDelta - userNewPoint.slope; 
                }
                slopeChanges[_oldLocked.end] = oldSlopeDelta;
            }
            if (_newLocked.end > block.timestamp) {
                if (_newLocked.end > _oldLocked.end) {
                    newSlopeDelta = newSlopeDelta - userNewPoint.slope; 
                    slopeChanges[_newLocked.end] = newSlopeDelta;
                }
            }
        }
    }
    function checkpoint() external {
        LockedBalance memory empty;
        _checkpoint(address(0), empty, empty);
    }
    function createLock(uint256 _value) external payable nonReentrant {
        uint256 unlock_time = _floorToWeek(block.timestamp + LOCKTIME); 
        LockedBalance memory locked_ = locked[msg.sender];
        require(_value > 0, "Only non zero amount");
        require(msg.value == _value, "Invalid value");
        require(locked_.amount == 0, "Lock exists");
        locked_.amount += int128(int256(_value));
        locked_.end = unlock_time;
        locked_.delegated += int128(int256(_value));
        locked_.delegatee = msg.sender;
        locked[msg.sender] = locked_;
        _checkpoint(msg.sender, LockedBalance(0, 0, 0, address(0)), locked_);
        emit Deposit(msg.sender, _value, unlock_time, LockAction.CREATE, block.timestamp);
    }
    function increaseAmount(uint256 _value) external payable nonReentrant {
        LockedBalance memory locked_ = locked[msg.sender];
        require(_value > 0, "Only non zero amount");
        require(msg.value == _value, "Invalid value");
        require(locked_.amount > 0, "No lock");
        require(locked_.end > block.timestamp, "Lock expired");
        address delegatee = locked_.delegatee;
        uint256 unlockTime = locked_.end;
        LockAction action = LockAction.INCREASE_AMOUNT;
        LockedBalance memory newLocked = _copyLock(locked_);
        newLocked.amount += int128(int256(_value));
        newLocked.end = _floorToWeek(block.timestamp + LOCKTIME);
        if (delegatee == msg.sender) {
            action = LockAction.INCREASE_AMOUNT_AND_DELEGATION;
            newLocked.delegated += int128(int256(_value));
            locked[msg.sender] = newLocked;
            _checkpoint(msg.sender, locked_, newLocked);
        } else {
            locked[msg.sender] = newLocked;
            _checkpoint(msg.sender, locked_, newLocked);
            locked_ = locked[delegatee];
            require(locked_.amount > 0, "Delegatee has no lock");
            require(locked_.end > block.timestamp, "Delegatee lock expired");
            newLocked = _copyLock(locked_);
            newLocked.delegated += int128(int256(_value));
            locked[delegatee] = newLocked;
            _checkpoint(delegatee, locked_, newLocked);
            emit Deposit(delegatee, _value, newLocked.end, LockAction.DELEGATE, block.timestamp);
        }
        emit Deposit(msg.sender, _value, unlockTime, action, block.timestamp);
    }
    function withdraw() external nonReentrant {
        LockedBalance memory locked_ = locked[msg.sender];
        require(locked_.amount > 0, "No lock");
        require(locked_.end <= block.timestamp, "Lock not expired");
        require(locked_.delegatee == msg.sender, "Lock delegated");
        uint256 amountToSend = uint256(uint128(locked_.amount));
        LockedBalance memory newLocked = _copyLock(locked_);
        newLocked.amount = 0;
        newLocked.end = 0;
        newLocked.delegated -= int128(int256(amountToSend));
        newLocked.delegatee = address(0);
        locked[msg.sender] = newLocked;
        newLocked.delegated = 0;
        _checkpoint(msg.sender, locked_, newLocked);
        (bool success, ) = msg.sender.call{value: amountToSend}("");
        require(success, "Failed to send CANTO");
        emit Withdraw(msg.sender, amountToSend, LockAction.WITHDRAW, block.timestamp);
    }
    function delegate(address _addr) external nonReentrant {
        LockedBalance memory locked_ = locked[msg.sender];
        require(locked_.amount > 0, "No lock");
        require(locked_.delegatee != _addr, "Already delegated");
        int128 value = locked_.amount;
        address delegatee = locked_.delegatee;
        LockedBalance memory fromLocked;
        LockedBalance memory toLocked;
        locked_.delegatee = _addr;
        if (delegatee == msg.sender) {
            fromLocked = locked_;
            toLocked = locked[_addr];
        } else if (_addr == msg.sender) {
            fromLocked = locked[delegatee];
            toLocked = locked_;
        } else {
            fromLocked = locked[delegatee];
            toLocked = locked[_addr];
            locked[msg.sender] = locked_;
        }
        require(toLocked.amount > 0, "Delegatee has no lock");
        require(toLocked.end > block.timestamp, "Delegatee lock expired");
        require(toLocked.end >= fromLocked.end, "Only delegate to longer lock");
        _delegate(delegatee, fromLocked, value, LockAction.UNDELEGATE);
        _delegate(_addr, toLocked, value, LockAction.DELEGATE);
    }
    function _delegate(
        address addr,
        LockedBalance memory _locked,
        int128 value,
        LockAction action
    ) internal {
        LockedBalance memory newLocked = _copyLock(_locked);
        if (action == LockAction.DELEGATE) {
            newLocked.delegated += value;
            emit Deposit(addr, uint256(int256(value)), newLocked.end, action, block.timestamp);
        } else {
            newLocked.delegated -= value;
            emit Withdraw(addr, uint256(int256(value)), action, block.timestamp);
        }
        locked[addr] = newLocked;
        if (newLocked.amount > 0) {
            _checkpoint(addr, _locked, newLocked);
        }
    }
    function _copyLock(LockedBalance memory _locked) internal pure returns (LockedBalance memory) {
        return
            LockedBalance({
                amount: _locked.amount,
                end: _locked.end,
                delegatee: _locked.delegatee,
                delegated: _locked.delegated
            });
    }
    function _floorToWeek(uint256 _t) internal pure returns (uint256) {
        return (_t / WEEK) * WEEK;
    }
    function _findBlockEpoch(uint256 _block, uint256 _maxEpoch) internal view returns (uint256) {
        uint256 min = 0;
        uint256 max = _maxEpoch;
        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) break;
            uint256 mid = (min + max + 1) / 2;
            if (pointHistory[mid].blk <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }
    function _findUserBlockEpoch(address _addr, uint256 _block) internal view returns (uint256) {
        uint256 min = 0;
        uint256 max = userPointEpoch[_addr];
        for (uint256 i = 0; i < 128; i++) {
            if (min >= max) {
                break;
            }
            uint256 mid = (min + max + 1) / 2;
            if (userPointHistory[_addr][mid].blk <= _block) {
                min = mid;
            } else {
                max = mid - 1;
            }
        }
        return min;
    }
    function balanceOf(address _owner) public view returns (uint256) {
        uint256 epoch = userPointEpoch[_owner];
        if (epoch == 0) {
            return 0;
        }
        Point memory lastPoint = userPointHistory[_owner][epoch];
        lastPoint.bias = lastPoint.bias - (lastPoint.slope * int128(int256(block.timestamp - lastPoint.ts)));
        if (lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
        return uint256(uint128(lastPoint.bias));
    }
    function balanceOfAt(address _owner, uint256 _blockNumber) public view returns (uint256) {
        require(_blockNumber <= block.number, "Only past block number");
        uint256 userEpoch = _findUserBlockEpoch(_owner, _blockNumber);
        if (userEpoch == 0) {
            return 0;
        }
        Point memory upoint = userPointHistory[_owner][userEpoch];
        uint256 maxEpoch = globalEpoch;
        uint256 epoch = _findBlockEpoch(_blockNumber, maxEpoch);
        Point memory point0 = pointHistory[epoch];
        uint256 dBlock = 0;
        uint256 dTime = 0;
        if (epoch < maxEpoch) {
            Point memory point1 = pointHistory[epoch + 1];
            dBlock = point1.blk - point0.blk;
            dTime = point1.ts - point0.ts;
        } else {
            dBlock = block.number - point0.blk;
            dTime = block.timestamp - point0.ts;
        }
        uint256 blockTime = point0.ts;
        if (dBlock != 0) {
            blockTime = blockTime + ((dTime * (_blockNumber - point0.blk)) / dBlock);
        }
        upoint.bias = upoint.bias - (upoint.slope * int128(int256(blockTime - upoint.ts)));
        if (upoint.bias >= 0) {
            return uint256(uint128(upoint.bias));
        } else {
            return 0;
        }
    }
    function _supplyAt(Point memory _point, uint256 _t) internal view returns (uint256) {
        Point memory lastPoint = _point;
        uint256 iterativeTime = _floorToWeek(lastPoint.ts);
        for (uint256 i = 0; i < 255; i++) {
            iterativeTime = iterativeTime + WEEK;
            int128 dSlope = 0;
            if (iterativeTime > _t) {
                iterativeTime = _t;
            }
            else {
                dSlope = slopeChanges[iterativeTime];
            }
            lastPoint.bias = lastPoint.bias - (lastPoint.slope * int128(int256(iterativeTime - lastPoint.ts)));
            if (iterativeTime == _t) {
                break;
            }
            lastPoint.slope = lastPoint.slope + dSlope;
            lastPoint.ts = iterativeTime;
        }
        if (lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
        return uint256(uint128(lastPoint.bias));
    }
    function totalSupply() public view returns (uint256) {
        uint256 epoch_ = globalEpoch;
        Point memory lastPoint = pointHistory[epoch_];
        return _supplyAt(lastPoint, block.timestamp);
    }
    function totalSupplyAt(uint256 _blockNumber) public view returns (uint256) {
        require(_blockNumber <= block.number, "Only past block number");
        uint256 epoch = globalEpoch;
        uint256 targetEpoch = _findBlockEpoch(_blockNumber, epoch);
        Point memory point = pointHistory[targetEpoch];
        if (point.blk > _blockNumber) {
            return 0;
        }
        uint256 dTime = 0;
        if (targetEpoch < epoch) {
            Point memory pointNext = pointHistory[targetEpoch + 1];
            if (point.blk != pointNext.blk) {
                dTime = ((_blockNumber - point.blk) * (pointNext.ts - point.ts)) / (pointNext.blk - point.blk);
            }
        } else if (point.blk != block.number) {
            dTime = ((_blockNumber - point.blk) * (block.timestamp - point.ts)) / (block.number - point.blk);
        }
        return _supplyAt(point, point.ts + dTime);
    }
}
pragma solidity ^0.8.16;
contract GaugeController {
    uint256 public constant WEEK = 7 days;
    uint256 public constant MULTIPLIER = 10**18;
    event NewGauge(address indexed gauge_address);
    event GaugeRemoved(address indexed gauge_address);
    VotingEscrow public votingEscrow;
    address public governance;
    mapping(address => bool) public isValidGauge;
    mapping(address => mapping(address => VotedSlope)) public vote_user_slopes;
    mapping(address => uint256) public vote_user_power;
    mapping(address => mapping(address => uint256)) public last_user_vote;
    mapping(address => mapping(uint256 => Point)) public points_weight;
    mapping(address => mapping(uint256 => uint256)) public changes_weight;
    mapping(address => uint256) time_weight;
    mapping(uint256 => Point) points_sum;
    mapping(uint256 => uint256) changes_sum;
    uint256 public time_sum;
    struct Point {
        uint256 bias;
        uint256 slope;
    }
    struct VotedSlope {
        uint256 slope;
        uint256 power;
        uint256 end;
    }
    modifier onlyGovernance() {
        require(msg.sender == governance);
        _;
    }
    constructor(address _votingEscrow, address _governance) {
        votingEscrow = VotingEscrow(_votingEscrow);
        governance = _governance; 
        uint256 last_epoch = (block.timestamp / WEEK) * WEEK;
        time_sum = last_epoch;
    }
    function _get_sum() internal returns (uint256) {
        uint256 t = time_sum;
        Point memory pt = points_sum[t];
        for (uint256 i; i < 500; ++i) {
            if (t > block.timestamp) break;
            t += WEEK;
            uint256 d_bias = pt.slope * WEEK;
            if (pt.bias > d_bias) {
                pt.bias -= d_bias;
                uint256 d_slope = changes_sum[t];
                pt.slope -= d_slope;
            } else {
                pt.bias = 0;
                pt.slope = 0;
            }
            points_sum[t] = pt;
            if (t > block.timestamp) time_sum = t;
        }
        return pt.bias;
    }
    function _get_weight(address _gauge_addr) private returns (uint256) {
        uint256 t = time_weight[_gauge_addr];
        if (t > 0) {
            Point memory pt = points_weight[_gauge_addr][t];
            for (uint256 i; i < 500; ++i) {
                if (t > block.timestamp) break;
                t += WEEK;
                uint256 d_bias = pt.slope * WEEK;
                if (pt.bias > d_bias) {
                    pt.bias -= d_bias;
                    uint256 d_slope = changes_weight[_gauge_addr][t];
                    pt.slope -= d_slope;
                } else {
                    pt.bias = 0;
                    pt.slope = 0;
                }
                points_weight[_gauge_addr][t] = pt;
                if (t > block.timestamp) time_weight[_gauge_addr] = t;
            }
            return pt.bias;
        } else {
            return 0;
        }
    }
    function add_gauge(address _gauge) external onlyGovernance {
        require(!isValidGauge[_gauge], "Gauge already exists");
        isValidGauge[_gauge] = true;
        emit NewGauge(_gauge);
    }
    function remove_gauge(address _gauge) external onlyGovernance {
        require(isValidGauge[_gauge], "Invalid gauge address");
        isValidGauge[_gauge] = false;
        _change_gauge_weight(_gauge, 0);
        emit GaugeRemoved(_gauge);
    }
    function checkpoint() external {
        _get_sum();
    }
    function checkpoint_gauge(address _gauge) external {
        _get_weight(_gauge);
        _get_sum();
    }
    function _gauge_relative_weight(address _gauge, uint256 _time) private view returns (uint256) {
        uint256 t = (_time / WEEK) * WEEK;
        uint256 total_weight = points_sum[t].bias;
        if (total_weight > 0) {
            uint256 gauge_weight = points_weight[_gauge][t].bias;
            return (MULTIPLIER * gauge_weight) / total_weight;
        } else {
            return 0;
        }
    }
    function gauge_relative_weight(address _gauge, uint256 _time) external view returns (uint256) {
        return _gauge_relative_weight(_gauge, _time);
    }
    function gauge_relative_weight_write(address _gauge, uint256 _time) external returns (uint256) {
        _get_weight(_gauge);
        _get_sum();
        return _gauge_relative_weight(_gauge, _time);
    }
    function _change_gauge_weight(address _gauge, uint256 _weight) internal {
        uint256 old_gauge_weight = _get_weight(_gauge);
        uint256 old_sum = _get_sum();
        uint256 next_time = ((block.timestamp + WEEK) / WEEK) * WEEK;
        points_weight[_gauge][next_time].bias = _weight;
        time_weight[_gauge] = next_time;
        uint256 new_sum = old_sum + _weight - old_gauge_weight;
        points_sum[next_time].bias = new_sum;
        time_sum = next_time;
    }
    function change_gauge_weight(address _gauge, uint256 _weight) public onlyGovernance {
        _change_gauge_weight(_gauge, _weight);
    }
    function vote_for_gauge_weights(address _gauge_addr, uint256 _user_weight) external {
        require(_user_weight >= 0 && _user_weight <= 10_000, "Invalid user weight");
        require(isValidGauge[_gauge_addr], "Invalid gauge address");
        VotingEscrow ve = votingEscrow;
        (
            ,
            int128 slope_, 
        ) = ve.getLastUserPoint(msg.sender);
        require(slope_ >= 0, "Invalid slope");
        uint256 slope = uint256(uint128(slope_));
        uint256 lock_end = ve.lockEnd(msg.sender);
        uint256 next_time = ((block.timestamp + WEEK) / WEEK) * WEEK;
        require(lock_end > next_time, "Lock expires too soon");
        VotedSlope memory old_slope = vote_user_slopes[msg.sender][_gauge_addr];
        uint256 old_dt = 0;
        if (old_slope.end > next_time) old_dt = old_slope.end - next_time;
        uint256 old_bias = old_slope.slope * old_dt;
        VotedSlope memory new_slope = VotedSlope({
            slope: (slope * _user_weight) / 10_000,
            end: lock_end,
            power: _user_weight
        });
        uint256 new_dt = lock_end - next_time;
        uint256 new_bias = new_slope.slope * new_dt;
        uint256 power_used = vote_user_power[msg.sender];
        power_used = power_used + new_slope.power - old_slope.power;
        require(power_used >= 0 && power_used <= 10_000, "Used too much power");
        vote_user_power[msg.sender] = power_used;
        uint256 old_weight_bias = _get_weight(_gauge_addr);
        uint256 old_weight_slope = points_weight[_gauge_addr][next_time].slope;
        uint256 old_sum_bias = _get_sum();
        uint256 old_sum_slope = points_sum[next_time].slope;
        points_weight[_gauge_addr][next_time].bias = Math.max(old_weight_bias + new_bias, old_bias) - old_bias;
        points_sum[next_time].bias = Math.max(old_sum_bias + new_bias, old_bias) - old_bias;
        if (old_slope.end > next_time) {
            points_weight[_gauge_addr][next_time].slope =
                Math.max(old_weight_slope + new_slope.slope, old_slope.slope) -
                old_slope.slope;
            points_sum[next_time].slope = Math.max(old_sum_slope + new_slope.slope, old_slope.slope) - old_slope.slope;
        } else {
            points_weight[_gauge_addr][next_time].slope += new_slope.slope;
            points_sum[next_time].slope += new_slope.slope;
        }
        if (old_slope.end > block.timestamp) {
            changes_weight[_gauge_addr][old_slope.end] -= old_slope.slope;
            changes_sum[old_slope.end] -= old_slope.slope;
        }
        changes_weight[_gauge_addr][new_slope.end] += new_slope.slope;
        changes_sum[new_slope.end] += new_slope.slope;
        _get_sum();
        vote_user_slopes[msg.sender][_gauge_addr] = new_slope;
        last_user_vote[msg.sender][_gauge_addr] = block.timestamp;
    }
    function get_gauge_weight(address _gauge) external view returns (uint256) {
        return points_weight[_gauge][time_weight[_gauge]].bias;
    }
    function get_total_weight() external view returns (uint256) {
        return points_sum[time_sum].bias;
    }
}
pragma solidity ^0.8.16;
contract LendingLedger {
    uint256 public constant WEEK = 7 days;
    address public governance;
    GaugeController public gaugeController;
    mapping(address => bool) public lendingMarketWhitelist;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public lendingMarketBalances; 
    mapping(address => mapping(address => uint256)) public lendingMarketBalancesEpoch; 
    mapping(address => mapping(uint256 => uint256)) public lendingMarketTotalBalance; 
    mapping(address => uint256) public lendingMarketTotalBalanceEpoch; 
    mapping(address => mapping(address => uint256)) public userClaimedEpoch; 
    struct RewardInformation {
        bool set;
        uint248 amount;
    }
    mapping(uint256 => RewardInformation) public rewardInformation;
    modifier is_valid_epoch(uint256 _timestamp) {
        require(_timestamp % WEEK == 0 || _timestamp == type(uint256).max, "Invalid timestamp");
        _;
    }
    modifier onlyGovernance() {
        require(msg.sender == governance);
        _;
    }
    constructor(address _gaugeController, address _governance) {
        gaugeController = GaugeController(_gaugeController);
        governance = _governance; 
    }
    function _checkpoint_lender(
        address _market,
        address _lender,
        uint256 _forwardTimestampLimit
    ) private {
        uint256 currEpoch = (block.timestamp / WEEK) * WEEK;
        uint256 lastUserUpdateEpoch = lendingMarketBalancesEpoch[_market][_lender];
        uint256 updateUntilEpoch = Math.min(currEpoch, _forwardTimestampLimit);
        if (lastUserUpdateEpoch == 0) {
            userClaimedEpoch[_market][_lender] = currEpoch;
            lendingMarketBalancesEpoch[_market][_lender] = currEpoch;
        } else if (lastUserUpdateEpoch < currEpoch) {
            uint256 lastUserBalance = lendingMarketBalances[_market][_lender][lastUserUpdateEpoch];
            for (uint256 i = lastUserUpdateEpoch; i <= updateUntilEpoch; i += WEEK) {
                lendingMarketBalances[_market][_lender][i] = lastUserBalance;
            }
            if (updateUntilEpoch > lastUserUpdateEpoch) {
                lendingMarketBalancesEpoch[_market][_lender] = updateUntilEpoch;
            }
        }
    }
    function _checkpoint_market(address _market, uint256 _forwardTimestampLimit) private {
        uint256 currEpoch = (block.timestamp / WEEK) * WEEK;
        uint256 lastMarketUpdateEpoch = lendingMarketTotalBalanceEpoch[_market];
        uint256 updateUntilEpoch = Math.min(currEpoch, _forwardTimestampLimit);
        if (lastMarketUpdateEpoch == 0) {
            lendingMarketTotalBalanceEpoch[_market] = currEpoch;
        } else if (lastMarketUpdateEpoch < currEpoch) {
            uint256 lastMarketBalance = lendingMarketTotalBalance[_market][lastMarketUpdateEpoch];
            for (uint256 i = lastMarketUpdateEpoch; i <= updateUntilEpoch; i += WEEK) {
                lendingMarketTotalBalance[_market][i] = lastMarketBalance;
            }
            if (updateUntilEpoch > lastMarketUpdateEpoch) {
                lendingMarketTotalBalanceEpoch[_market] = updateUntilEpoch;
            }
        }
    }
    function checkpoint_market(address _market, uint256 _forwardTimestampLimit)
        external
        is_valid_epoch(_forwardTimestampLimit)
    {
        require(lendingMarketTotalBalanceEpoch[_market] > 0, "No deposits for this market");
        _checkpoint_market(_market, _forwardTimestampLimit);
    }
    function checkpoint_lender(
        address _market,
        address _lender,
        uint256 _forwardTimestampLimit
    ) external is_valid_epoch(_forwardTimestampLimit) {
        require(lendingMarketBalancesEpoch[_market][_lender] > 0, "No deposits for this lender in this market");
        _checkpoint_lender(_market, _lender, _forwardTimestampLimit);
    }
    function sync_ledger(address _lender, int256 _delta) external {
        address lendingMarket = msg.sender;
        require(lendingMarketWhitelist[lendingMarket], "Market not whitelisted");
        _checkpoint_lender(lendingMarket, _lender, type(uint256).max);
        uint256 currEpoch = (block.timestamp / WEEK) * WEEK;
        int256 updatedLenderBalance = int256(lendingMarketBalances[lendingMarket][_lender][currEpoch]) + _delta;
        require(updatedLenderBalance >= 0, "Lender balance underflow"); 
        lendingMarketBalances[lendingMarket][_lender][currEpoch] = uint256(updatedLenderBalance);
        _checkpoint_market(lendingMarket, type(uint256).max);
        int256 updatedMarketBalance = int256(lendingMarketTotalBalance[lendingMarket][currEpoch]) + _delta;
        require(updatedMarketBalance >= 0, "Market balance underflow"); 
        lendingMarketTotalBalance[lendingMarket][currEpoch] = uint256(updatedMarketBalance);
    }
    function claim(
        address _market,
        uint256 _claimFromTimestamp,
        uint256 _claimUpToTimestamp
    ) external is_valid_epoch(_claimFromTimestamp) is_valid_epoch(_claimUpToTimestamp) {
        address lender = msg.sender;
        uint256 userLastClaimed = userClaimedEpoch[_market][lender];
        require(userLastClaimed > 0, "No deposits for this user");
        _checkpoint_lender(_market, lender, _claimUpToTimestamp);
        _checkpoint_market(_market, _claimUpToTimestamp);
        uint256 currEpoch = (block.timestamp / WEEK) * WEEK;
        uint256 claimStart = Math.max(userLastClaimed, _claimFromTimestamp);
        uint256 claimEnd = Math.min(currEpoch - WEEK, _claimUpToTimestamp);
        uint256 cantoToSend;
        if (claimEnd >= claimStart) {
            for (uint256 i = claimStart; i <= claimEnd; i += WEEK) {
                uint256 userBalance = lendingMarketBalances[_market][lender][i];
                uint256 marketBalance = lendingMarketTotalBalance[_market][i];
                RewardInformation memory ri = rewardInformation[i];
                require(ri.set, "Reward not set yet"); 
                uint256 marketWeight = gaugeController.gauge_relative_weight_write(_market, i); 
                cantoToSend += (marketWeight * userBalance * ri.amount) / (1e18 * marketBalance); 
            }
            userClaimedEpoch[_market][lender] = claimEnd + WEEK;
        }
        if (cantoToSend > 0) {
            (bool success, ) = msg.sender.call{value: cantoToSend}("");
            require(success, "Failed to send CANTO");
        }
    }
    function setRewards(
        uint256 _fromEpoch,
        uint256 _toEpoch,
        uint248 _amountPerEpoch
    ) external is_valid_epoch(_fromEpoch) is_valid_epoch(_toEpoch) onlyGovernance {
        for (uint256 i = _fromEpoch; i <= _toEpoch; i += WEEK) {
            RewardInformation storage ri = rewardInformation[i];
            require(!ri.set, "Rewards already set");
            ri.set = true;
            ri.amount = _amountPerEpoch;
        }
    }
    function whiteListLendingMarket(address _market, bool _isWhiteListed) external onlyGovernance {
        require(lendingMarketWhitelist[_market] != _isWhiteListed, "No change");
        lendingMarketWhitelist[_market] = _isWhiteListed;
    }
    receive() external payable {}
}