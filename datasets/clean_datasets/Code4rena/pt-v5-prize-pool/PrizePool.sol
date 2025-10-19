pragma solidity 0.8.17;
import "forge-std/console2.sol";
import { IERC20 } from "openzeppelin/token/ERC20/IERC20.sol";
import { SafeERC20 } from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { E, SD59x18, sd, toSD59x18, fromSD59x18 } from "prb-math/SD59x18.sol";
import { UD60x18, ud, toUD60x18, fromUD60x18, intoSD59x18 } from "prb-math/UD60x18.sol";
import { UD2x18, intoUD60x18 } from "prb-math/UD2x18.sol";
import { SD1x18, unwrap, UNIT } from "prb-math/SD1x18.sol";
import { UD34x4, fromUD60x18 as fromUD60x18toUD34x4, intoUD60x18 as fromUD34x4toUD60x18, toUD34x4 } from "./libraries/UD34x4.sol";
import { TwabController } from "v5-twab-controller/TwabController.sol";
import { DrawAccumulatorLib, Observation } from "./libraries/DrawAccumulatorLib.sol";
import { TieredLiquidityDistributor, Tier } from "./abstract/TieredLiquidityDistributor.sol";
import { TierCalculationLib } from "./libraries/TierCalculationLib.sol";
error DrawManagerAlreadySet();
error AlreadyClaimedPrize(
  address vault,
  address winner,
  uint8 tier,
  uint32 prizeIndex,
  address recipient
);
error InsufficientRewardsError(uint256 requested, uint256 available);
error DidNotWin(address vault, address winner, uint8 tier, uint32 prizeIndex);
error FeeTooLarge(uint256 fee, uint256 maxFee);
error SmoothingGTEOne(int64 smoothing);
error ContributionGTDeltaBalance(uint256 amount, uint256 available);
error InsufficientReserve(uint104 amount, uint104 reserve);
error RandomNumberIsZero();
error DrawNotFinished(uint64 drawEndsAt, uint64 errorTimestamp);
error InvalidPrizeIndex(uint32 invalidPrizeIndex, uint32 prizeCount, uint8 tier);
error NoClosedDraw();
error InvalidTier(uint8 tier, uint8 numberOfTiers);
error CallerNotDrawManager(address caller, address drawManager);
struct ConstructorParams {
  IERC20 prizeToken;
  TwabController twabController;
  address drawManager;
  uint32 drawPeriodSeconds;
  uint64 firstDrawStartsAt;
  uint8 numberOfTiers;
  uint8 tierShares;
  uint8 canaryShares;
  uint8 reserveShares;
  UD2x18 claimExpansionThreshold;
  SD1x18 smoothing;
}
contract PrizePool is TieredLiquidityDistributor {
  using SafeERC20 for IERC20;
  event ClaimedPrize(
    address indexed vault,
    address indexed winner,
    address indexed recipient,
    uint16 drawId,
    uint8 tier,
    uint32 prizeIndex,
    uint152 payout,
    uint96 fee,
    address feeRecipient
  );
  event DrawClosed(
    uint16 indexed drawId,
    uint256 winningRandomNumber,
    uint8 numTiers,
    uint8 nextNumTiers,
    uint104 reserve,
    UD34x4 prizeTokensPerShare,
    uint64 drawStartedAt
  );
  event WithdrawReserve(address indexed to, uint256 amount);
  event IncreaseReserve(address user, uint256 amount);
  event ContributePrizeTokens(address indexed vault, uint16 indexed drawId, uint256 amount);
  event WithdrawClaimRewards(address indexed to, uint256 amount, uint256 available);
  event IncreaseClaimRewards(address indexed to, uint256 amount);
  event DrawManagerSet(address indexed drawManager);
  mapping(address => DrawAccumulatorLib.Accumulator) internal vaultAccumulator;
  mapping(address => mapping(address => mapping(uint16 => mapping(uint8 => mapping(uint32 => bool)))))
    internal claimedPrizes;
  mapping(address => uint256) internal claimerRewards;
  SD1x18 public immutable smoothing;
  IERC20 public immutable prizeToken;
  TwabController public immutable twabController;
  address public drawManager;
  uint32 public immutable drawPeriodSeconds;
  UD2x18 public immutable claimExpansionThreshold;
  DrawAccumulatorLib.Accumulator internal totalAccumulator;
  uint256 internal _totalWithdrawn;
  uint256 internal _winningRandomNumber;
  uint32 public claimCount;
  uint32 public canaryClaimCount;
  uint8 public largestTierClaimed;
  uint64 internal _lastClosedDrawStartedAt;
  uint64 internal _lastClosedDrawAwardedAt;
  constructor(
    ConstructorParams memory params
  )
    TieredLiquidityDistributor(
      params.numberOfTiers,
      params.tierShares,
      params.canaryShares,
      params.reserveShares
    )
  {
    if (unwrap(params.smoothing) >= unwrap(UNIT)) {
      revert SmoothingGTEOne(unwrap(params.smoothing));
    }
    prizeToken = params.prizeToken;
    twabController = params.twabController;
    smoothing = params.smoothing;
    claimExpansionThreshold = params.claimExpansionThreshold;
    drawPeriodSeconds = params.drawPeriodSeconds;
    _lastClosedDrawStartedAt = params.firstDrawStartsAt;
    drawManager = params.drawManager;
    if (params.drawManager != address(0)) {
      emit DrawManagerSet(params.drawManager);
    }
  }
  modifier onlyDrawManager() {
    if (msg.sender != drawManager) {
      revert CallerNotDrawManager(msg.sender, drawManager);
    }
    _;
  }
  function setDrawManager(address _drawManager) external {
    if (drawManager != address(0)) {
      revert DrawManagerAlreadySet();
    }
    drawManager = _drawManager;
    emit DrawManagerSet(_drawManager);
  }
  function contributePrizeTokens(address _prizeVault, uint256 _amount) external returns (uint256) {
    uint256 _deltaBalance = prizeToken.balanceOf(address(this)) - _accountedBalance();
    if (_deltaBalance < _amount) {
      revert ContributionGTDeltaBalance(_amount, _deltaBalance);
    }
    DrawAccumulatorLib.add(
      vaultAccumulator[_prizeVault],
      _amount,
      lastClosedDrawId + 1,
      smoothing.intoSD59x18()
    );
    DrawAccumulatorLib.add(
      totalAccumulator,
      _amount,
      lastClosedDrawId + 1,
      smoothing.intoSD59x18()
    );
    emit ContributePrizeTokens(_prizeVault, lastClosedDrawId + 1, _amount);
    return _deltaBalance;
  }
  function withdrawReserve(address _to, uint104 _amount) external onlyDrawManager {
    if (_amount > _reserve) {
      revert InsufficientReserve(_amount, _reserve);
    }
    _reserve -= _amount;
    _transfer(_to, _amount);
    emit WithdrawReserve(_to, _amount);
  }
  function closeDraw(uint256 winningRandomNumber_) external onlyDrawManager returns (uint16) {
    if (winningRandomNumber_ == 0) {
      revert RandomNumberIsZero();
    }
    if (block.timestamp < _openDrawEndsAt()) {
      revert DrawNotFinished(_openDrawEndsAt(), uint64(block.timestamp));
    }
    uint8 _numTiers = numberOfTiers;
    uint8 _nextNumberOfTiers = _numTiers;
    if (lastClosedDrawId != 0) {
      _nextNumberOfTiers = _computeNextNumberOfTiers(_numTiers);
    }
    uint64 openDrawStartedAt_ = _openDrawStartedAt();
    _nextDraw(_nextNumberOfTiers, uint96(_contributionsForDraw(lastClosedDrawId + 1)));
    _winningRandomNumber = winningRandomNumber_;
    claimCount = 0;
    canaryClaimCount = 0;
    largestTierClaimed = 0;
    _lastClosedDrawStartedAt = openDrawStartedAt_;
    _lastClosedDrawAwardedAt = uint64(block.timestamp);
    emit DrawClosed(
      lastClosedDrawId,
      winningRandomNumber_,
      _numTiers,
      _nextNumberOfTiers,
      _reserve,
      prizeTokenPerShare,
      _lastClosedDrawStartedAt
    );
    return lastClosedDrawId;
  }
  function claimPrize(
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex,
    address _prizeRecipient,
    uint96 _fee,
    address _feeRecipient
  ) external returns (uint256) {
    Tier memory tierLiquidity = _getTier(_tier, numberOfTiers);
    if (_fee > tierLiquidity.prizeSize) {
      revert FeeTooLarge(_fee, tierLiquidity.prizeSize);
    }
    (SD59x18 _vaultPortion, SD59x18 _tierOdds, uint16 _drawDuration) = _computeVaultTierDetails(
      msg.sender,
      _tier,
      numberOfTiers,
      lastClosedDrawId
    );
    if (
      !_isWinner(msg.sender, _winner, _tier, _prizeIndex, _vaultPortion, _tierOdds, _drawDuration)
    ) {
      revert DidNotWin(msg.sender, _winner, _tier, _prizeIndex);
    }
    if (claimedPrizes[msg.sender][_winner][lastClosedDrawId][_tier][_prizeIndex]) {
      revert AlreadyClaimedPrize(msg.sender, _winner, _tier, _prizeIndex, _prizeRecipient);
    }
    claimedPrizes[msg.sender][_winner][lastClosedDrawId][_tier][_prizeIndex] = true;
    if (_isCanaryTier(_tier, numberOfTiers)) {
      canaryClaimCount++;
    } else {
      claimCount++;
    }
    if (largestTierClaimed < _tier) {
      largestTierClaimed = _tier;
    }
    _consumeLiquidity(tierLiquidity, _tier, tierLiquidity.prizeSize);
    if (_fee != 0) {
      emit IncreaseClaimRewards(_feeRecipient, _fee);
      claimerRewards[_feeRecipient] += _fee;
    }
    uint256 amount = tierLiquidity.prizeSize - _fee;
    emit ClaimedPrize(
      msg.sender,
      _winner,
      _prizeRecipient,
      lastClosedDrawId,
      _tier,
      _prizeIndex,
      uint152(amount),
      _fee,
      _feeRecipient
    );
    _transfer(_prizeRecipient, amount);
    return tierLiquidity.prizeSize;
  }
  function withdrawClaimRewards(address _to, uint256 _amount) external {
    uint256 _available = claimerRewards[msg.sender];
    if (_amount > _available) {
      revert InsufficientRewardsError(_amount, _available);
    }
    claimerRewards[msg.sender] -= _amount;
    _transfer(_to, _amount);
    emit WithdrawClaimRewards(_to, _amount, _available);
  }
  function increaseReserve(uint104 _amount) external {
    _reserve += _amount;
    prizeToken.safeTransferFrom(msg.sender, address(this), _amount);
    emit IncreaseReserve(msg.sender, _amount);
  }
  function getWinningRandomNumber() external view returns (uint256) {
    return _winningRandomNumber;
  }
  function getLastClosedDrawId() external view returns (uint256) {
    return lastClosedDrawId;
  }
  function getTotalContributedBetween(
    uint16 _startDrawIdInclusive,
    uint16 _endDrawIdInclusive
  ) external view returns (uint256) {
    return
      DrawAccumulatorLib.getDisbursedBetween(
        totalAccumulator,
        _startDrawIdInclusive,
        _endDrawIdInclusive,
        smoothing.intoSD59x18()
      );
  }
  function getContributedBetween(
    address _vault,
    uint16 _startDrawIdInclusive,
    uint16 _endDrawIdInclusive
  ) external view returns (uint256) {
    return
      DrawAccumulatorLib.getDisbursedBetween(
        vaultAccumulator[_vault],
        _startDrawIdInclusive,
        _endDrawIdInclusive,
        smoothing.intoSD59x18()
      );
  }
  function getTierAccrualDurationInDraws(uint8 _tier) external view returns (uint16) {
    return
      uint16(TierCalculationLib.estimatePrizeFrequencyInDraws(_tierOdds(_tier, numberOfTiers)));
  }
  function totalWithdrawn() external view returns (uint256) {
    return _totalWithdrawn;
  }
  function accountedBalance() external view returns (uint256) {
    return _accountedBalance();
  }
  function lastClosedDrawStartedAt() external view returns (uint64) {
    return lastClosedDrawId != 0 ? _lastClosedDrawStartedAt : 0;
  }
  function lastClosedDrawEndedAt() external view returns (uint64) {
    return lastClosedDrawId != 0 ? _lastClosedDrawStartedAt + drawPeriodSeconds : 0;
  }
  function lastClosedDrawAwardedAt() external view returns (uint64) {
    return lastClosedDrawId != 0 ? _lastClosedDrawAwardedAt : 0;
  }
  function hasOpenDrawFinished() external view returns (bool) {
    return block.timestamp >= _openDrawEndsAt();
  }
  function openDrawStartedAt() external view returns (uint64) {
    return _openDrawStartedAt();
  }
  function openDrawEndsAt() external view returns (uint64) {
    return _openDrawEndsAt();
  }
  function reserveForOpenDraw() external view returns (uint256) {
    uint8 _numTiers = numberOfTiers;
    uint8 _nextNumberOfTiers = _numTiers;
    if (lastClosedDrawId != 0) {
      _nextNumberOfTiers = _computeNextNumberOfTiers(_numTiers);
    }
    (, uint104 newReserve, ) = _computeNewDistributions(
      _numTiers,
      _nextNumberOfTiers,
      uint96(_contributionsForDraw(lastClosedDrawId + 1))
    );
    return newReserve;
  }
  function getTotalContributionsForClosedDraw() external view returns (uint256) {
    return _contributionsForDraw(lastClosedDrawId);
  }
  function wasClaimed(
    address _vault,
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex
  ) external view returns (bool) {
    return claimedPrizes[_vault][_winner][lastClosedDrawId][_tier][_prizeIndex];
  }
  function balanceOfClaimRewards(address _claimer) external view returns (uint256) {
    return claimerRewards[_claimer];
  }
  function isWinner(
    address _vault,
    address _user,
    uint8 _tier,
    uint32 _prizeIndex
  ) external view returns (bool) {
    (SD59x18 vaultPortion, SD59x18 tierOdds, uint16 drawDuration) = _computeVaultTierDetails(
      _vault,
      _tier,
      numberOfTiers,
      lastClosedDrawId
    );
    return _isWinner(_vault, _user, _tier, _prizeIndex, vaultPortion, tierOdds, drawDuration);
  }
  function calculateTierTwabTimestamps(
    uint8 _tier
  ) external view returns (uint64 startTimestamp, uint64 endTimestamp) {
    uint8 _numberOfTiers = numberOfTiers;
    _checkValidTier(_tier, _numberOfTiers);
    endTimestamp = _lastClosedDrawStartedAt + drawPeriodSeconds;
    SD59x18 tierOdds = _tierOdds(_tier, _numberOfTiers);
    uint256 durationInSeconds = TierCalculationLib.estimatePrizeFrequencyInDraws(tierOdds) * drawPeriodSeconds;
    startTimestamp = uint64(
      endTimestamp -
        durationInSeconds
    );
  }
  function getVaultUserBalanceAndTotalSupplyTwab(
    address _vault,
    address _user,
    uint256 _drawDuration
  ) external view returns (uint256, uint256) {
    return _getVaultUserBalanceAndTotalSupplyTwab(_vault, _user, _drawDuration);
  }
  function getVaultPortion(
    address _vault,
    uint16 _startDrawId,
    uint16 _endDrawId
  ) external view returns (SD59x18) {
    return _getVaultPortion(_vault, _startDrawId, _endDrawId, smoothing.intoSD59x18());
  }
  function nextNumberOfTiers() external view returns (uint8) {
    return _computeNextNumberOfTiers(numberOfTiers);
  }
  function _accountedBalance() internal view returns (uint256) {
    Observation memory obs = DrawAccumulatorLib.newestObservation(totalAccumulator);
    return (obs.available + obs.disbursed) - _totalWithdrawn;
  }
  function _openDrawStartedAt() internal view returns (uint64) {
    return _openDrawEndsAt() - drawPeriodSeconds;
  }
  function _checkValidTier(uint8 _tier, uint8 _numTiers) internal pure {
    if (_tier >= _numTiers) {
      revert InvalidTier(_tier, _numTiers);
    }
  }
  function _openDrawEndsAt() internal view returns (uint64) {
    uint64 _nextExpectedEndTime = _lastClosedDrawStartedAt +
      (lastClosedDrawId == 0 ? 1 : 2) *
      drawPeriodSeconds;
    if (block.timestamp > _nextExpectedEndTime) {
      _nextExpectedEndTime +=
        drawPeriodSeconds *
        (uint64((block.timestamp - _nextExpectedEndTime) / drawPeriodSeconds));
    }
    return _nextExpectedEndTime;
  }
  function _computeNextNumberOfTiers(uint8 _numTiers) internal view returns (uint8) {
    UD2x18 _claimExpansionThreshold = claimExpansionThreshold;
    uint8 _nextNumberOfTiers = largestTierClaimed + 2; 
    _nextNumberOfTiers = _nextNumberOfTiers > MINIMUM_NUMBER_OF_TIERS
      ? _nextNumberOfTiers
      : MINIMUM_NUMBER_OF_TIERS;
    if (_nextNumberOfTiers >= MAXIMUM_NUMBER_OF_TIERS) {
      return MAXIMUM_NUMBER_OF_TIERS;
    }
    if (
      _nextNumberOfTiers >= _numTiers &&
      canaryClaimCount >=
      fromUD60x18(
        intoUD60x18(_claimExpansionThreshold).mul(_canaryPrizeCountFractional(_numTiers).floor())
      ) &&
      claimCount >=
      fromUD60x18(
        intoUD60x18(_claimExpansionThreshold).mul(toUD60x18(_estimatedPrizeCount(_numTiers)))
      )
    ) {
      _nextNumberOfTiers = _numTiers + 1;
    }
    return _nextNumberOfTiers;
  }
  function _contributionsForDraw(uint16 _drawId) internal view returns (uint256) {
    return
      DrawAccumulatorLib.getDisbursedBetween(
        totalAccumulator,
        _drawId,
        _drawId,
        smoothing.intoSD59x18()
      );
  }
  function _transfer(address _to, uint256 _amount) internal {
    _totalWithdrawn += _amount;
    prizeToken.safeTransfer(_to, _amount);
  }
  function _isWinner(
    address _vault,
    address _user,
    uint8 _tier,
    uint32 _prizeIndex,
    SD59x18 _vaultPortion,
    SD59x18 _tierOdds,
    uint16 _drawDuration
  ) internal view returns (bool) {
    uint8 _numberOfTiers = numberOfTiers;
    uint32 tierPrizeCount = _getTierPrizeCount(_tier, _numberOfTiers);
    if (_prizeIndex >= tierPrizeCount) {
      revert InvalidPrizeIndex(_prizeIndex, tierPrizeCount, _tier);
    }
    uint256 userSpecificRandomNumber = TierCalculationLib.calculatePseudoRandomNumber(
      _user,
      _tier,
      _prizeIndex,
      _winningRandomNumber
    );
    (uint256 _userTwab, uint256 _vaultTwabTotalSupply) = _getVaultUserBalanceAndTotalSupplyTwab(
      _vault,
      _user,
      _drawDuration
    );
    return
      TierCalculationLib.isWinner(
        userSpecificRandomNumber,
        uint128(_userTwab),
        uint128(_vaultTwabTotalSupply),
        _vaultPortion,
        _tierOdds
      );
  }
  function _computeVaultTierDetails(
    address _vault,
    uint8 _tier,
    uint8 _numberOfTiers,
    uint16 _lastClosedDrawId
  ) internal view returns (SD59x18 vaultPortion, SD59x18 tierOdds, uint16 drawDuration) {
    if (_lastClosedDrawId == 0) {
      revert NoClosedDraw();
    }
    _checkValidTier(_tier, _numberOfTiers);
    tierOdds = _tierOdds(_tier, numberOfTiers);
    drawDuration = uint16(TierCalculationLib.estimatePrizeFrequencyInDraws(tierOdds));
    vaultPortion = _getVaultPortion(
      _vault,
      uint16(drawDuration > _lastClosedDrawId ? 0 : _lastClosedDrawId - drawDuration + 1),
      _lastClosedDrawId + 1,
      smoothing.intoSD59x18()
    );
  }
  function _getVaultUserBalanceAndTotalSupplyTwab(
    address _vault,
    address _user,
    uint256 _drawDuration
  ) internal view returns (uint256 twab, uint256 twabTotalSupply) {
    uint32 _endTimestamp = uint32(_lastClosedDrawStartedAt + drawPeriodSeconds);
    uint32 _startTimestamp = uint32(_endTimestamp - _drawDuration * drawPeriodSeconds);
    twab = twabController.getTwabBetween(_vault, _user, _startTimestamp, _endTimestamp);
    twabTotalSupply = twabController.getTotalSupplyTwabBetween(
      _vault,
      _startTimestamp,
      _endTimestamp
    );
  }
  function _getVaultPortion(
    address _vault,
    uint16 _startDrawId,
    uint16 _endDrawId,
    SD59x18 _smoothing
  ) internal view returns (SD59x18) {
    uint256 totalContributed = DrawAccumulatorLib.getDisbursedBetween(
      totalAccumulator,
      _startDrawId,
      _endDrawId,
      _smoothing
    );
    if (totalContributed != 0) {
      return
        sd(
          int256(
            DrawAccumulatorLib.getDisbursedBetween(
              vaultAccumulator[_vault],
              _startDrawId,
              _endDrawId,
              _smoothing
            )
          )
        ).div(sd(int256(totalContributed)));
    } else {
      return sd(0);
    }
  }
}