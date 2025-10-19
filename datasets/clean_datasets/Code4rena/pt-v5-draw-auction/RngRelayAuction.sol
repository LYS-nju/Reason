pragma solidity ^0.8.19;
import { UD2x18 } from "prb-math/UD2x18.sol";
import { convert } from "prb-math/UD60x18.sol";
import { PrizePool } from "pt-v5-prize-pool/PrizePool.sol";
import { RewardLib } from "./libraries/RewardLib.sol";
import { IRngAuctionRelayListener } from "./interfaces/IRngAuctionRelayListener.sol";
import { IAuction, AuctionResult } from "./interfaces/IAuction.sol";
import { RngAuction } from "./RngAuction.sol";
error AuctionDurationZero();
error AuctionTargetTimeZero();
error AuctionTargetTimeExceedsDuration(uint64 auctionDuration, uint64 auctionTargetTime);
error RngRelayerZeroAddress();
error SequenceAlreadyCompleted();
error AuctionExpired();
error PrizePoolZeroAddress();
contract RngRelayAuction is IRngAuctionRelayListener, IAuction {
  event AuctionRewardDistributed(
    uint32 indexed sequenceId,
    address indexed recipient,
    uint32 index,
    uint256 reward
  );
  event RngSequenceCompleted(
    uint32 indexed sequenceId,
    uint32 indexed drawId,
    address indexed rewardRecipient,
    uint64 auctionElapsedSeconds,
    UD2x18 rewardFraction
  );
  PrizePool public immutable prizePool;
  address public immutable rngAuctionRelayer;
  uint32 internal _lastSequenceId;
  uint64 internal _auctionDurationSeconds;
  UD2x18 internal _auctionTargetTimeFraction;
  AuctionResult internal _auctionResults;
  constructor(
    PrizePool prizePool_,
    address _rngAuctionRelayer,
    uint64 auctionDurationSeconds_,
    uint64 auctionTargetTime_
  ) {
    if (address(prizePool_) == address(0)) revert PrizePoolZeroAddress();
    prizePool = prizePool_;
    if (address(_rngAuctionRelayer) == address(0)) revert RngRelayerZeroAddress();
    if (auctionDurationSeconds_ == 0) revert AuctionDurationZero();
    if (auctionTargetTime_ == 0) revert AuctionTargetTimeZero();
    if (auctionTargetTime_ > auctionDurationSeconds_) {
      revert AuctionTargetTimeExceedsDuration(auctionDurationSeconds_, auctionTargetTime_);
    }
    rngAuctionRelayer = _rngAuctionRelayer;
    _auctionDurationSeconds = auctionDurationSeconds_;
    _auctionTargetTimeFraction = UD2x18.wrap(
      uint64(convert(auctionTargetTime_).div(convert(_auctionDurationSeconds)).unwrap())
    );
  }
  function rngComplete(
    uint256 _randomNumber,
    uint256 _rngCompletedAt,
    address _rewardRecipient,
    uint32 _sequenceId,
    AuctionResult calldata _rngAuctionResult
  ) external returns (bytes32) {
    if (_sequenceHasCompleted(_sequenceId)) revert SequenceAlreadyCompleted();
    uint64 _auctionElapsedSeconds = uint64(block.timestamp < _rngCompletedAt ? 0 : block.timestamp - _rngCompletedAt);
    if (_auctionElapsedSeconds > (_auctionDurationSeconds-1)) revert AuctionExpired();
    UD2x18 rewardFraction = _fractionalReward(_auctionElapsedSeconds);
    _auctionResults.rewardFraction = rewardFraction;
    _auctionResults.recipient = _rewardRecipient;
    _lastSequenceId = _sequenceId;
    AuctionResult[] memory auctionResults = new AuctionResult[](2);
    auctionResults[0] = _rngAuctionResult;
    auctionResults[1] = AuctionResult({
      rewardFraction: rewardFraction,
      recipient: _rewardRecipient
    });
    uint32 drawId = prizePool.closeDraw(_randomNumber);
    uint256 futureReserve = prizePool.reserve() + prizePool.reserveForOpenDraw();
    uint256[] memory _rewards = RewardLib.rewards(auctionResults, futureReserve);
    emit RngSequenceCompleted(
      _sequenceId,
      drawId,
      _rewardRecipient,
      _auctionElapsedSeconds,
      rewardFraction
    );
    for (uint8 i = 0; i < _rewards.length; i++) {
      uint104 _reward = uint104(_rewards[i]);
      if (_reward > 0) {
        prizePool.withdrawReserve(auctionResults[i].recipient, _reward);
        emit AuctionRewardDistributed(_sequenceId, auctionResults[i].recipient, i, _reward);
      }
    }
    return bytes32(uint(drawId));
  }
  function computeRewards(AuctionResult[] calldata __auctionResults) external returns (uint256[] memory) {
    uint256 totalReserve = prizePool.reserve() + prizePool.reserveForOpenDraw();
    return _computeRewards(__auctionResults, totalReserve);
  }
  function computeRewardsWithTotal(AuctionResult[] calldata __auctionResults, uint256 _totalReserve) external returns (uint256[] memory) {
    return _computeRewards(__auctionResults, _totalReserve);
  }
  function isSequenceCompleted(uint32 _sequenceId) external view returns (bool) {
    return _sequenceHasCompleted(_sequenceId);
  }
  function auctionDuration() external view returns (uint64) {
    return _auctionDurationSeconds;
  }
  function computeRewardFraction(uint64 _auctionElapsedTime) external view returns (UD2x18) {
    return _fractionalReward(_auctionElapsedTime);
  }
  function lastSequenceId() external view returns (uint32) {
    return _lastSequenceId;
  }
  function getLastAuctionResult()
    external
    view
    returns (AuctionResult memory)
  {
    return _auctionResults;
  }
  function _computeRewards(AuctionResult[] calldata __auctionResults, uint256 _totalReserve) internal returns (uint256[] memory) {
    return RewardLib.rewards(__auctionResults, _totalReserve);
  }
  function _sequenceHasCompleted(uint32 _sequenceId) internal view returns (bool) {
    return _lastSequenceId >= _sequenceId;
  }
  function _fractionalReward(uint64 _elapsedSeconds) internal view returns (UD2x18) {
    return
      RewardLib.fractionalReward(
        _elapsedSeconds,
        _auctionDurationSeconds,
        _auctionTargetTimeFraction,
        _auctionResults.rewardFraction
      );
  }
}