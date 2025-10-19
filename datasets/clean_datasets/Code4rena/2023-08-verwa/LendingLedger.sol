pragma solidity ^0.8.16;
import {VotingEscrow} from "./VotingEscrow.sol";
import {GaugeController} from "./GaugeController.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
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