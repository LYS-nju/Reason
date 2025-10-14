pragma abicoder v2;
pragma solidity >=0.5.0;
interface IAlgebraFactory {
  event Owner(address indexed newOwner);
  event VaultAddress(address indexed newVaultAddress);
  event Pool(address indexed token0, address indexed token1, address pool);
  event FarmingAddress(address indexed newFarmingAddress);
  event FeeConfiguration(
    uint16 alpha1,
    uint16 alpha2,
    uint32 beta1,
    uint32 beta2,
    uint16 gamma1,
    uint16 gamma2,
    uint32 volumeBeta,
    uint16 volumeGamma,
    uint16 baseFee
  );
  function owner() external view returns (address);
  function poolDeployer() external view returns (address);
  function farmingAddress() external view returns (address);
  function vaultAddress() external view returns (address);
  function poolByPair(address tokenA, address tokenB) external view returns (address pool);
  function createPool(address tokenA, address tokenB) external returns (address pool);
  function setOwner(address _owner) external;
  function setFarmingAddress(address _farmingAddress) external;
  function setVaultAddress(address _vaultAddress) external;
  function setBaseFeeConfiguration(
    uint16 alpha1,
    uint16 alpha2,
    uint32 beta1,
    uint32 beta2,
    uint16 gamma1,
    uint16 gamma2,
    uint32 volumeBeta,
    uint16 volumeGamma,
    uint16 baseFee
  ) external;
}
pragma solidity =0.7.6;
library Constants {
  uint8 internal constant RESOLUTION = 96;
  uint256 internal constant Q96 = 0x1000000000000000000000000;
  uint256 internal constant Q128 = 0x100000000000000000000000000000000;
  uint16 internal constant BASE_FEE = 100;
  int24 internal constant TICK_SPACING = 60;
  uint128 internal constant MAX_LIQUIDITY_PER_TICK = 11505743598341114571880798222544994;
  uint32 internal constant MAX_LIQUIDITY_COOLDOWN = 1 days;
  uint8 internal constant MAX_COMMUNITY_FEE = 250;
  uint256 internal constant COMMUNITY_FEE_DENOMINATOR = 1000;
}
pragma solidity =0.7.6;
library AdaptiveFee {
  struct Configuration {
    uint16 alpha1; 
    uint16 alpha2; 
    uint32 beta1; 
    uint32 beta2; 
    uint16 gamma1; 
    uint16 gamma2; 
    uint32 volumeBeta; 
    uint16 volumeGamma; 
    uint16 baseFee; 
  }
  function getFee(
    uint88 volatility,
    uint256 volumePerLiquidity,
    Configuration memory config
  ) internal pure returns (uint16 fee) {
    uint256 sumOfSigmoids = sigmoid(volatility, config.gamma1, config.alpha1, config.beta1) +
      sigmoid(volatility, config.gamma2, config.alpha2, config.beta2);
    if (sumOfSigmoids > type(uint16).max) {
      sumOfSigmoids = type(uint16).max;
    }
    return uint16(config.baseFee + sigmoid(volumePerLiquidity, config.volumeGamma, uint16(sumOfSigmoids), config.volumeBeta)); 
  }
  function sigmoid(
    uint256 x,
    uint16 g,
    uint16 alpha,
    uint256 beta
  ) internal pure returns (uint256 res) {
    if (x > beta) {
      x = x - beta;
      if (x >= 6 * uint256(g)) return alpha; 
      uint256 g8 = uint256(g)**8; 
      uint256 ex = exp(x, g, g8); 
      res = (alpha * ex) / (g8 + ex); 
    } else {
      x = beta - x;
      if (x >= 6 * uint256(g)) return 0; 
      uint256 g8 = uint256(g)**8; 
      uint256 ex = g8 + exp(x, g, g8); 
      res = (alpha * g8) / ex; 
    }
  }
  function exp(
    uint256 x,
    uint16 g,
    uint256 gHighestDegree
  ) internal pure returns (uint256 res) {
    uint256 xLowestDegree = x;
    res = gHighestDegree; 
    gHighestDegree /= g; 
    res += xLowestDegree * gHighestDegree;
    gHighestDegree /= g; 
    xLowestDegree *= x; 
    res += (xLowestDegree * gHighestDegree) / 2;
    gHighestDegree /= g; 
    xLowestDegree *= x; 
    res += (xLowestDegree * gHighestDegree) / 6;
    gHighestDegree /= g; 
    xLowestDegree *= x; 
    res += (xLowestDegree * gHighestDegree) / 24;
    gHighestDegree /= g; 
    xLowestDegree *= x; 
    res += (xLowestDegree * gHighestDegree) / 120;
    gHighestDegree /= g; 
    xLowestDegree *= x; 
    res += (xLowestDegree * gHighestDegree) / 720;
    xLowestDegree *= x; 
    res += (xLowestDegree * g) / 5040 + (xLowestDegree * x) / (40320);
  }
}
pragma solidity >=0.5.0;
interface IDataStorageOperator {
  event FeeConfiguration(AdaptiveFee.Configuration feeConfig);
  function timepoints(uint256 index)
    external
    view
    returns (
      bool initialized,
      uint32 blockTimestamp,
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint88 volatilityCumulative,
      int24 averageTick,
      uint144 volumePerLiquidityCumulative
    );
  function initialize(uint32 time, int24 tick) external;
  function getSingleTimepoint(
    uint32 time,
    uint32 secondsAgo,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    returns (
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint112 volatilityCumulative,
      uint256 volumePerAvgLiquidity
    );
  function getTimepoints(
    uint32 time,
    uint32[] memory secondsAgos,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    );
  function getAverages(
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) external view returns (uint112 TWVolatilityAverage, uint256 TWVolumePerLiqAverage);
  function write(
    uint16 index,
    uint32 blockTimestamp,
    int24 tick,
    uint128 liquidity,
    uint128 volumePerLiquidity
  ) external returns (uint16 indexUpdated);
  function changeFeeConfiguration(AdaptiveFee.Configuration calldata feeConfig) external;
  function calculateVolumePerLiquidity(
    uint128 liquidity,
    int256 amount0,
    int256 amount1
  ) external pure returns (uint128 volumePerLiquidity);
  function window() external view returns (uint32 windowLength);
  function getFee(
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) external view returns (uint16 fee);
}
pragma solidity ^0.4.0 || ^0.5.0 || ^0.6.0 || ^0.7.0;
library FullMath {
  function mulDiv(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    uint256 prod0 = a * b; 
    uint256 prod1; 
    assembly {
      let mm := mulmod(a, b, not(0))
      prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }
    require(denominator > prod1);
    if (prod1 == 0) {
      assembly {
        result := div(prod0, denominator)
      }
      return result;
    }
    assembly {
      let remainder := mulmod(a, b, denominator)
      prod1 := sub(prod1, gt(remainder, prod0))
      prod0 := sub(prod0, remainder)
    }
    uint256 twos = -denominator & denominator;
    assembly {
      denominator := div(denominator, twos)
    }
    assembly {
      prod0 := div(prod0, twos)
    }
    assembly {
      twos := add(div(sub(0, twos), twos), 1)
    }
    prod0 |= prod1 * twos;
    uint256 inv = (3 * denominator) ^ 2;
    inv *= 2 - denominator * inv; 
    inv *= 2 - denominator * inv; 
    inv *= 2 - denominator * inv; 
    inv *= 2 - denominator * inv; 
    inv *= 2 - denominator * inv; 
    inv *= 2 - denominator * inv; 
    result = prod0 * inv;
    return result;
  }
  function mulDivRoundingUp(
    uint256 a,
    uint256 b,
    uint256 denominator
  ) internal pure returns (uint256 result) {
    if (a == 0 || ((result = a * b) / a == b)) {
      require(denominator > 0);
      assembly {
        result := add(div(result, denominator), gt(mod(result, denominator), 0))
      }
    } else {
      result = mulDiv(a, b, denominator);
      if (mulmod(a, b, denominator) > 0) {
        require(result < type(uint256).max);
        result++;
      }
    }
  }
  function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
    assembly {
      z := add(div(x, y), gt(mod(x, y), 0))
    }
  }
}
pragma solidity =0.7.6;
library DataStorage {
  uint32 public constant WINDOW = 1 days;
  uint256 private constant UINT16_MODULO = 65536;
  struct Timepoint {
    bool initialized; 
    uint32 blockTimestamp; 
    int56 tickCumulative; 
    uint160 secondsPerLiquidityCumulative; 
    uint88 volatilityCumulative; 
    int24 averageTick; 
    uint144 volumePerLiquidityCumulative; 
  }
  function _volatilityOnRange(
    int256 dt,
    int256 tick0,
    int256 tick1,
    int256 avgTick0,
    int256 avgTick1
  ) internal pure returns (uint256 volatility) {
    int256 K = (tick1 - tick0) - (avgTick1 - avgTick0); 
    int256 B = (tick0 - avgTick0) * dt; 
    int256 sumOfSquares = (dt * (dt + 1) * (2 * dt + 1)); 
    int256 sumOfSequence = (dt * (dt + 1)); 
    volatility = uint256((K**2 * sumOfSquares + 6 * B * K * sumOfSequence + 6 * dt * B**2) / (6 * dt**2));
  }
  function createNewTimepoint(
    Timepoint memory last,
    uint32 blockTimestamp,
    int24 tick,
    int24 prevTick,
    uint128 liquidity,
    int24 averageTick,
    uint128 volumePerLiquidity
  ) private pure returns (Timepoint memory) {
    uint32 delta = blockTimestamp - last.blockTimestamp;
    last.initialized = true;
    last.blockTimestamp = blockTimestamp;
    last.tickCumulative += int56(tick) * delta;
    last.secondsPerLiquidityCumulative += ((uint160(delta) << 128) / (liquidity > 0 ? liquidity : 1)); 
    last.volatilityCumulative += uint88(_volatilityOnRange(delta, prevTick, tick, last.averageTick, averageTick)); 
    last.averageTick = averageTick;
    last.volumePerLiquidityCumulative += volumePerLiquidity;
    return last;
  }
  function lteConsideringOverflow(
    uint32 a,
    uint32 b,
    uint32 currentTime
  ) private pure returns (bool res) {
    res = a > currentTime;
    if (res == b > currentTime) res = a <= b; 
  }
  function _getAverageTick(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    int24 tick,
    uint16 index,
    uint16 oldestIndex,
    uint32 lastTimestamp,
    int56 lastTickCumulative
  ) internal view returns (int256 avgTick) {
    uint32 oldestTimestamp = self[oldestIndex].blockTimestamp;
    int56 oldestTickCumulative = self[oldestIndex].tickCumulative;
    if (lteConsideringOverflow(oldestTimestamp, time - WINDOW, time)) {
      if (lteConsideringOverflow(lastTimestamp, time - WINDOW, time)) {
        index -= 1; 
        Timepoint storage startTimepoint = self[index];
        avgTick = startTimepoint.initialized
          ? (lastTickCumulative - startTimepoint.tickCumulative) / (lastTimestamp - startTimepoint.blockTimestamp)
          : tick;
      } else {
        Timepoint memory startOfWindow = getSingleTimepoint(self, time, WINDOW, tick, index, oldestIndex, 0);
        avgTick = (lastTickCumulative - startOfWindow.tickCumulative) / (lastTimestamp - time + WINDOW);
      }
    } else {
      avgTick = (lastTimestamp == oldestTimestamp) ? tick : (lastTickCumulative - oldestTickCumulative) / (lastTimestamp - oldestTimestamp);
    }
  }
  function binarySearch(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    uint32 target,
    uint16 lastIndex,
    uint16 oldestIndex
  ) private view returns (Timepoint storage beforeOrAt, Timepoint storage atOrAfter) {
    uint256 left = oldestIndex; 
    uint256 right = lastIndex >= oldestIndex ? lastIndex : lastIndex + UINT16_MODULO; 
    uint256 current = (left + right) >> 1; 
    do {
      beforeOrAt = self[uint16(current)]; 
      (bool initializedBefore, uint32 timestampBefore) = (beforeOrAt.initialized, beforeOrAt.blockTimestamp);
      if (initializedBefore) {
        if (lteConsideringOverflow(timestampBefore, target, time)) {
          atOrAfter = self[uint16(current + 1)]; 
          (bool initializedAfter, uint32 timestampAfter) = (atOrAfter.initialized, atOrAfter.blockTimestamp);
          if (initializedAfter) {
            if (lteConsideringOverflow(target, timestampAfter, time)) {
              return (beforeOrAt, atOrAfter); 
            }
            left = current + 1; 
          } else {
            return (beforeOrAt, beforeOrAt);
          }
        } else {
          right = current - 1; 
        }
      } else {
        left = current + 1;
      }
      current = (left + right) >> 1; 
    } while (true);
    atOrAfter = beforeOrAt; 
    assert(false);
  }
  function getSingleTimepoint(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    uint32 secondsAgo,
    int24 tick,
    uint16 index,
    uint16 oldestIndex,
    uint128 liquidity
  ) internal view returns (Timepoint memory targetTimepoint) {
    uint32 target = time - secondsAgo;
    if (secondsAgo == 0 || lteConsideringOverflow(self[index].blockTimestamp, target, time)) {
      Timepoint memory last = self[index];
      if (last.blockTimestamp == target) {
        return last;
      } else {
        int24 avgTick = int24(_getAverageTick(self, time, tick, index, oldestIndex, last.blockTimestamp, last.tickCumulative));
        int24 prevTick = tick;
        {
          if (index != oldestIndex) {
            Timepoint memory prevLast;
            Timepoint storage _prevLast = self[index - 1]; 
            prevLast.blockTimestamp = _prevLast.blockTimestamp;
            prevLast.tickCumulative = _prevLast.tickCumulative;
            prevTick = int24((last.tickCumulative - prevLast.tickCumulative) / (last.blockTimestamp - prevLast.blockTimestamp));
          }
        }
        return createNewTimepoint(last, target, tick, prevTick, liquidity, avgTick, 0);
      }
    }
    require(lteConsideringOverflow(self[oldestIndex].blockTimestamp, target, time), 'OLD');
    (Timepoint memory beforeOrAt, Timepoint memory atOrAfter) = binarySearch(self, time, target, index, oldestIndex);
    if (target == atOrAfter.blockTimestamp) {
      return atOrAfter; 
    }
    if (target != beforeOrAt.blockTimestamp) {
      uint32 timepointTimeDelta = atOrAfter.blockTimestamp - beforeOrAt.blockTimestamp;
      uint32 targetDelta = target - beforeOrAt.blockTimestamp;
      beforeOrAt.tickCumulative += ((atOrAfter.tickCumulative - beforeOrAt.tickCumulative) / timepointTimeDelta) * targetDelta;
      beforeOrAt.secondsPerLiquidityCumulative += uint160(
        (uint256(atOrAfter.secondsPerLiquidityCumulative - beforeOrAt.secondsPerLiquidityCumulative) * targetDelta) / timepointTimeDelta
      );
      beforeOrAt.volatilityCumulative += ((atOrAfter.volatilityCumulative - beforeOrAt.volatilityCumulative) / timepointTimeDelta) * targetDelta;
      beforeOrAt.volumePerLiquidityCumulative +=
        ((atOrAfter.volumePerLiquidityCumulative - beforeOrAt.volumePerLiquidityCumulative) / timepointTimeDelta) *
        targetDelta;
    }
    return beforeOrAt;
  }
  function getTimepoints(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    uint32[] memory secondsAgos,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    internal
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    )
  {
    tickCumulatives = new int56[](secondsAgos.length);
    secondsPerLiquidityCumulatives = new uint160[](secondsAgos.length);
    volatilityCumulatives = new uint112[](secondsAgos.length);
    volumePerAvgLiquiditys = new uint256[](secondsAgos.length);
    uint16 oldestIndex;
    uint16 nextIndex = index + 1; 
    if (self[nextIndex].initialized) {
      oldestIndex = nextIndex;
    }
    Timepoint memory current;
    for (uint256 i = 0; i < secondsAgos.length; i++) {
      current = getSingleTimepoint(self, time, secondsAgos[i], tick, index, oldestIndex, liquidity);
      (tickCumulatives[i], secondsPerLiquidityCumulatives[i], volatilityCumulatives[i], volumePerAvgLiquiditys[i]) = (
        current.tickCumulative,
        current.secondsPerLiquidityCumulative,
        current.volatilityCumulative,
        current.volumePerLiquidityCumulative
      );
    }
  }
  function getAverages(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) internal view returns (uint88 volatilityAverage, uint256 volumePerLiqAverage) {
    uint16 oldestIndex;
    Timepoint storage oldest = self[0];
    uint16 nextIndex = index + 1; 
    if (self[nextIndex].initialized) {
      oldest = self[nextIndex];
      oldestIndex = nextIndex;
    }
    Timepoint memory endOfWindow = getSingleTimepoint(self, time, 0, tick, index, oldestIndex, liquidity);
    uint32 oldestTimestamp = oldest.blockTimestamp;
    if (lteConsideringOverflow(oldestTimestamp, time - WINDOW, time)) {
      Timepoint memory startOfWindow = getSingleTimepoint(self, time, WINDOW, tick, index, oldestIndex, liquidity);
      return (
        (endOfWindow.volatilityCumulative - startOfWindow.volatilityCumulative) / WINDOW,
        uint256(endOfWindow.volumePerLiquidityCumulative - startOfWindow.volumePerLiquidityCumulative) >> 57
      );
    } else if (time != oldestTimestamp) {
      uint88 _oldestVolatilityCumulative = oldest.volatilityCumulative;
      uint144 _oldestVolumePerLiquidityCumulative = oldest.volumePerLiquidityCumulative;
      return (
        (endOfWindow.volatilityCumulative - _oldestVolatilityCumulative) / (time - oldestTimestamp),
        uint256(endOfWindow.volumePerLiquidityCumulative - _oldestVolumePerLiquidityCumulative) >> 57
      );
    }
  }
  function initialize(
    Timepoint[UINT16_MODULO] storage self,
    uint32 time,
    int24 tick
  ) internal {
    require(!self[0].initialized);
    self[0].initialized = true;
    self[0].blockTimestamp = time;
    self[0].averageTick = tick;
  }
  function write(
    Timepoint[UINT16_MODULO] storage self,
    uint16 index,
    uint32 blockTimestamp,
    int24 tick,
    uint128 liquidity,
    uint128 volumePerLiquidity
  ) internal returns (uint16 indexUpdated) {
    Timepoint storage _last = self[index];
    if (_last.blockTimestamp == blockTimestamp) {
      return index;
    }
    Timepoint memory last = _last;
    indexUpdated = index + 1;
    uint16 oldestIndex;
    if (self[indexUpdated].initialized) {
      oldestIndex = indexUpdated;
    }
    int24 avgTick = int24(_getAverageTick(self, blockTimestamp, tick, index, oldestIndex, last.blockTimestamp, last.tickCumulative));
    int24 prevTick = tick;
    if (index != oldestIndex) {
      Timepoint storage _prevLast = self[index - 1]; 
      uint32 _prevLastBlockTimestamp = _prevLast.blockTimestamp;
      int56 _prevLastTickCumulative = _prevLast.tickCumulative;
      prevTick = int24((last.tickCumulative - _prevLastTickCumulative) / (last.blockTimestamp - _prevLastBlockTimestamp));
    }
    self[indexUpdated] = createNewTimepoint(last, blockTimestamp, tick, prevTick, liquidity, avgTick, volumePerLiquidity);
  }
}
pragma solidity ^0.5.0 || ^0.6.0 || ^0.7.0 || ^0.8.0;
library Sqrt {
  function sqrtAbs(int256 _x) internal pure returns (uint256 result) {
    int256 mask = _x >> (256 - 1);
    uint256 x = uint256((_x ^ mask) - mask);
    if (x == 0) result = 0;
    else {
      uint256 xx = x;
      uint256 r = 1;
      if (xx >= 0x100000000000000000000000000000000) {
        xx >>= 128;
        r <<= 64;
      }
      if (xx >= 0x10000000000000000) {
        xx >>= 64;
        r <<= 32;
      }
      if (xx >= 0x100000000) {
        xx >>= 32;
        r <<= 16;
      }
      if (xx >= 0x10000) {
        xx >>= 16;
        r <<= 8;
      }
      if (xx >= 0x100) {
        xx >>= 8;
        r <<= 4;
      }
      if (xx >= 0x10) {
        xx >>= 4;
        r <<= 2;
      }
      if (xx >= 0x8) {
        r <<= 1;
      }
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1;
      r = (r + x / r) >> 1; 
      uint256 r1 = x / r;
      result = r < r1 ? r : r1;
    }
  }
}
pragma solidity =0.7.6;
contract DataStorageOperator is IDataStorageOperator {
  uint256 constant UINT16_MODULO = 65536;
  uint128 constant MAX_VOLUME_PER_LIQUIDITY = 100000 << 64; 
  using DataStorage for DataStorage.Timepoint[UINT16_MODULO];
  DataStorage.Timepoint[UINT16_MODULO] public override timepoints;
  AdaptiveFee.Configuration public feeConfig;
  address private immutable pool;
  address private immutable factory;
  modifier onlyPool() {
    require(msg.sender == pool, 'only pool can call this');
    _;
  }
  constructor(address _pool) {
    factory = msg.sender;
    pool = _pool;
  }
  function initialize(uint32 time, int24 tick) external override onlyPool {
    return timepoints.initialize(time, tick);
  }
  function changeFeeConfiguration(AdaptiveFee.Configuration calldata _feeConfig) external override {
    require(msg.sender == factory || msg.sender == IAlgebraFactory(factory).owner());
    require(uint256(_feeConfig.alpha1) + uint256(_feeConfig.alpha2) + uint256(_feeConfig.baseFee) <= type(uint16).max, 'Max fee exceeded');
    require(_feeConfig.gamma1 != 0 && _feeConfig.gamma2 != 0 && _feeConfig.volumeGamma != 0, 'Gammas must be > 0');
    feeConfig = _feeConfig;
    emit FeeConfiguration(_feeConfig);
  }
  function getSingleTimepoint(
    uint32 time,
    uint32 secondsAgo,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    override
    onlyPool
    returns (
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint112 volatilityCumulative,
      uint256 volumePerAvgLiquidity
    )
  {
    uint16 oldestIndex;
    uint16 nextIndex = index + 1; 
    if (timepoints[nextIndex].initialized) {
      oldestIndex = nextIndex;
    }
    DataStorage.Timepoint memory result = timepoints.getSingleTimepoint(time, secondsAgo, tick, index, oldestIndex, liquidity);
    (tickCumulative, secondsPerLiquidityCumulative, volatilityCumulative, volumePerAvgLiquidity) = (
      result.tickCumulative,
      result.secondsPerLiquidityCumulative,
      result.volatilityCumulative,
      result.volumePerLiquidityCumulative
    );
  }
  function getTimepoints(
    uint32 time,
    uint32[] memory secondsAgos,
    int24 tick,
    uint16 index,
    uint128 liquidity
  )
    external
    view
    override
    onlyPool
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    )
  {
    return timepoints.getTimepoints(time, secondsAgos, tick, index, liquidity);
  }
  function getAverages(
    uint32 time,
    int24 tick,
    uint16 index,
    uint128 liquidity
  ) external view override onlyPool returns (uint112 TWVolatilityAverage, uint256 TWVolumePerLiqAverage) {
    return timepoints.getAverages(time, tick, index, liquidity);
  }
  function write(
    uint16 index,
    uint32 blockTimestamp,
    int24 tick,
    uint128 liquidity,
    uint128 volumePerLiquidity
  ) external override onlyPool returns (uint16 indexUpdated) {
    return timepoints.write(index, blockTimestamp, tick, liquidity, volumePerLiquidity);
  }
  function calculateVolumePerLiquidity(
    uint128 liquidity,
    int256 amount0,
    int256 amount1
  ) external pure override returns (uint128 volumePerLiquidity) {
    uint256 volume = Sqrt.sqrtAbs(amount0) * Sqrt.sqrtAbs(amount1);
    uint256 volumeShifted;
    if (volume >= 2**192) volumeShifted = (type(uint256).max) / (liquidity > 0 ? liquidity : 1);
    else volumeShifted = (volume << 64) / (liquidity > 0 ? liquidity : 1);
    if (volumeShifted >= MAX_VOLUME_PER_LIQUIDITY) return MAX_VOLUME_PER_LIQUIDITY;
    else return uint128(volumeShifted);
  }
  function window() external pure override returns (uint32) {
    return DataStorage.WINDOW;
  }
  function getFee(
    uint32 _time,
    int24 _tick,
    uint16 _index,
    uint128 _liquidity
  ) external view override onlyPool returns (uint16 fee) {
    (uint88 volatilityAverage, uint256 volumePerLiqAverage) = timepoints.getAverages(_time, _tick, _index, _liquidity);
    return AdaptiveFee.getFee(volatilityAverage / 15, volumePerLiqAverage, feeConfig);
  }
}
pragma solidity >=0.5.0;
interface IAlgebraPoolDeployer {
  event Factory(address indexed factory);
  function parameters()
    external
    view
    returns (
      address dataStorage,
      address factory,
      address token0,
      address token1
    );
  function deploy(
    address dataStorage,
    address factory,
    address token0,
    address token1
  ) external returns (address pool);
  function setFactory(address factory) external;
}
pragma solidity =0.7.6;
contract AlgebraFactory is IAlgebraFactory {
  address public override owner;
  address public immutable override poolDeployer;
  address public override farmingAddress;
  address public override vaultAddress;
  AdaptiveFee.Configuration public baseFeeConfiguration =
    AdaptiveFee.Configuration(
      3000 - Constants.BASE_FEE, 
      15000 - 3000, 
      360, 
      60000, 
      59, 
      8500, 
      0, 
      10, 
      Constants.BASE_FEE 
    );
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  mapping(address => mapping(address => address)) public override poolByPair;
  constructor(address _poolDeployer, address _vaultAddress) {
    owner = msg.sender;
    emit Owner(msg.sender);
    poolDeployer = _poolDeployer;
    vaultAddress = _vaultAddress;
  }
  function createPool(address tokenA, address tokenB) external override returns (address pool) {
    require(tokenA != tokenB);
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0));
    require(poolByPair[token0][token1] == address(0));
    IDataStorageOperator dataStorage = new DataStorageOperator(computeAddress(token0, token1));
    dataStorage.changeFeeConfiguration(baseFeeConfiguration);
    pool = IAlgebraPoolDeployer(poolDeployer).deploy(address(dataStorage), address(this), token0, token1);
    poolByPair[token0][token1] = pool; 
    poolByPair[token1][token0] = pool;
    emit Pool(token0, token1, pool);
  }
  function setOwner(address _owner) external override onlyOwner {
    require(owner != _owner);
    emit Owner(_owner);
    owner = _owner;
  }
  function setFarmingAddress(address _farmingAddress) external override onlyOwner {
    require(farmingAddress != _farmingAddress);
    emit FarmingAddress(_farmingAddress);
    farmingAddress = _farmingAddress;
  }
  function setVaultAddress(address _vaultAddress) external override onlyOwner {
    require(vaultAddress != _vaultAddress);
    emit VaultAddress(_vaultAddress);
    vaultAddress = _vaultAddress;
  }
  function setBaseFeeConfiguration(
    uint16 alpha1,
    uint16 alpha2,
    uint32 beta1,
    uint32 beta2,
    uint16 gamma1,
    uint16 gamma2,
    uint32 volumeBeta,
    uint16 volumeGamma,
    uint16 baseFee
  ) external override onlyOwner {
    require(uint256(alpha1) + uint256(alpha2) + uint256(baseFee) <= type(uint16).max, 'Max fee exceeded');
    require(gamma1 != 0 && gamma2 != 0 && volumeGamma != 0, 'Gammas must be > 0');
    baseFeeConfiguration = AdaptiveFee.Configuration(alpha1, alpha2, beta1, beta2, gamma1, gamma2, volumeBeta, volumeGamma, baseFee);
    emit FeeConfiguration(alpha1, alpha2, beta1, beta2, gamma1, gamma2, volumeBeta, volumeGamma, baseFee);
  }
  bytes32 internal constant POOL_INIT_CODE_HASH = 0x6ec6c9c8091d160c0aa74b2b14ba9c1717e95093bd3ac085cee99a49aab294a4;
  function computeAddress(address token0, address token1) internal view returns (address pool) {
    pool = address(uint256(keccak256(abi.encodePacked(hex'ff', poolDeployer, keccak256(abi.encode(token0, token1)), POOL_INIT_CODE_HASH))));
  }
}
pragma solidity >=0.5.0;
interface IAlgebraPoolImmutables {
  function dataStorageOperator() external view returns (address);
  function factory() external view returns (address);
  function token0() external view returns (address);
  function token1() external view returns (address);
  function tickSpacing() external view returns (int24);
  function maxLiquidityPerTick() external view returns (uint128);
}
pragma solidity =0.7.6;
abstract contract PoolImmutables is IAlgebraPoolImmutables {
  address public immutable override dataStorageOperator;
  address public immutable override factory;
  address public immutable override token0;
  address public immutable override token1;
  function tickSpacing() external pure override returns (int24) {
    return Constants.TICK_SPACING;
  }
  function maxLiquidityPerTick() external pure override returns (uint128) {
    return Constants.MAX_LIQUIDITY_PER_TICK;
  }
  constructor(address deployer) {
    (dataStorageOperator, factory, token0, token1) = IAlgebraPoolDeployer(deployer).parameters();
  }
}
pragma solidity >=0.5.0;
interface IAlgebraPoolState {
  function globalState()
    external
    view
    returns (
      uint160 price,
      int24 tick,
      uint16 fee,
      uint16 timepointIndex,
      uint8 communityFeeToken0,
      uint8 communityFeeToken1,
      bool unlocked
    );
  function totalFeeGrowth0Token() external view returns (uint256);
  function totalFeeGrowth1Token() external view returns (uint256);
  function liquidity() external view returns (uint128);
  function ticks(int24 tick)
    external
    view
    returns (
      uint128 liquidityTotal,
      int128 liquidityDelta,
      uint256 outerFeeGrowth0Token,
      uint256 outerFeeGrowth1Token,
      int56 outerTickCumulative,
      uint160 outerSecondsPerLiquidity,
      uint32 outerSecondsSpent,
      bool initialized
    );
  function tickTable(int16 wordPosition) external view returns (uint256);
  function positions(bytes32 key)
    external
    view
    returns (
      uint128 liquidityAmount,
      uint32 lastLiquidityAddTimestamp,
      uint256 innerFeeGrowth0Token,
      uint256 innerFeeGrowth1Token,
      uint128 fees0,
      uint128 fees1
    );
  function timepoints(uint256 index)
    external
    view
    returns (
      bool initialized,
      uint32 blockTimestamp,
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint88 volatilityCumulative,
      int24 averageTick,
      uint144 volumePerLiquidityCumulative
    );
  function activeIncentive() external view returns (address virtualPool);
  function liquidityCooldown() external view returns (uint32 cooldownInSeconds);
}
pragma solidity >=0.5.0;
library LiquidityMath {
  function addDelta(uint128 x, int128 y) internal pure returns (uint128 z) {
    if (y < 0) {
      require((z = x - uint128(-y)) < x, 'LS');
    } else {
      require((z = x + uint128(y)) >= x, 'LA');
    }
  }
}
pragma solidity >=0.7.0;
library LowGasSafeMath {
  function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
    require((z = x + y) >= x);
  }
  function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
    require((z = x - y) <= x);
  }
  function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    require(x == 0 || (z = x * y) / x == y);
  }
  function add(int256 x, int256 y) internal pure returns (int256 z) {
    require((z = x + y) >= x == (y >= 0));
  }
  function sub(int256 x, int256 y) internal pure returns (int256 z) {
    require((z = x - y) <= x == (y >= 0));
  }
  function add128(uint128 x, uint128 y) internal pure returns (uint128 z) {
    require((z = x + y) >= x);
  }
}
pragma solidity >=0.5.0;
library SafeCast {
  function toUint160(uint256 y) internal pure returns (uint160 z) {
    require((z = uint160(y)) == y);
  }
  function toInt128(int256 y) internal pure returns (int128 z) {
    require((z = int128(y)) == y);
  }
  function toInt256(uint256 y) internal pure returns (int256 z) {
    require(y < 2**255);
    z = int256(y);
  }
}
pragma solidity =0.7.6;
library TickManager {
  using LowGasSafeMath for int256;
  using SafeCast for int256;
  struct Tick {
    uint128 liquidityTotal; 
    int128 liquidityDelta; 
    uint256 outerFeeGrowth0Token;
    uint256 outerFeeGrowth1Token;
    int56 outerTickCumulative; 
    uint160 outerSecondsPerLiquidity; 
    uint32 outerSecondsSpent; 
    bool initialized; 
  }
  function getInnerFeeGrowth(
    mapping(int24 => Tick) storage self,
    int24 bottomTick,
    int24 topTick,
    int24 currentTick,
    uint256 totalFeeGrowth0Token,
    uint256 totalFeeGrowth1Token
  ) internal view returns (uint256 innerFeeGrowth0Token, uint256 innerFeeGrowth1Token) {
    Tick storage lower = self[bottomTick];
    Tick storage upper = self[topTick];
    if (currentTick < topTick) {
      if (currentTick >= bottomTick) {
        innerFeeGrowth0Token = totalFeeGrowth0Token - lower.outerFeeGrowth0Token;
        innerFeeGrowth1Token = totalFeeGrowth1Token - lower.outerFeeGrowth1Token;
      } else {
        innerFeeGrowth0Token = lower.outerFeeGrowth0Token;
        innerFeeGrowth1Token = lower.outerFeeGrowth1Token;
      }
      innerFeeGrowth0Token -= upper.outerFeeGrowth0Token;
      innerFeeGrowth1Token -= upper.outerFeeGrowth1Token;
    } else {
      innerFeeGrowth0Token = upper.outerFeeGrowth0Token - lower.outerFeeGrowth0Token;
      innerFeeGrowth1Token = upper.outerFeeGrowth1Token - lower.outerFeeGrowth1Token;
    }
  }
  function update(
    mapping(int24 => Tick) storage self,
    int24 tick,
    int24 currentTick,
    int128 liquidityDelta,
    uint256 totalFeeGrowth0Token,
    uint256 totalFeeGrowth1Token,
    uint160 secondsPerLiquidityCumulative,
    int56 tickCumulative,
    uint32 time,
    bool upper
  ) internal returns (bool flipped) {
    Tick storage data = self[tick];
    int128 liquidityDeltaBefore = data.liquidityDelta;
    uint128 liquidityTotalBefore = data.liquidityTotal;
    uint128 liquidityTotalAfter = LiquidityMath.addDelta(liquidityTotalBefore, liquidityDelta);
    require(liquidityTotalAfter < Constants.MAX_LIQUIDITY_PER_TICK + 1, 'LO');
    data.liquidityDelta = upper
      ? int256(liquidityDeltaBefore).sub(liquidityDelta).toInt128()
      : int256(liquidityDeltaBefore).add(liquidityDelta).toInt128();
    data.liquidityTotal = liquidityTotalAfter;
    flipped = (liquidityTotalAfter == 0);
    if (liquidityTotalBefore == 0) {
      flipped = !flipped;
      if (tick <= currentTick) {
        data.outerFeeGrowth0Token = totalFeeGrowth0Token;
        data.outerFeeGrowth1Token = totalFeeGrowth1Token;
        data.outerSecondsPerLiquidity = secondsPerLiquidityCumulative;
        data.outerTickCumulative = tickCumulative;
        data.outerSecondsSpent = time;
      }
      data.initialized = true;
    }
  }
  function cross(
    mapping(int24 => Tick) storage self,
    int24 tick,
    uint256 totalFeeGrowth0Token,
    uint256 totalFeeGrowth1Token,
    uint160 secondsPerLiquidityCumulative,
    int56 tickCumulative,
    uint32 time
  ) internal returns (int128 liquidityDelta) {
    Tick storage data = self[tick];
    data.outerSecondsSpent = time - data.outerSecondsSpent;
    data.outerSecondsPerLiquidity = secondsPerLiquidityCumulative - data.outerSecondsPerLiquidity;
    data.outerTickCumulative = tickCumulative - data.outerTickCumulative;
    data.outerFeeGrowth1Token = totalFeeGrowth1Token - data.outerFeeGrowth1Token;
    data.outerFeeGrowth0Token = totalFeeGrowth0Token - data.outerFeeGrowth0Token;
    return data.liquidityDelta;
  }
}
pragma solidity =0.7.6;
abstract contract PoolState is IAlgebraPoolState {
  struct GlobalState {
    uint160 price; 
    int24 tick; 
    uint16 fee; 
    uint16 timepointIndex; 
    uint8 communityFeeToken0; 
    uint8 communityFeeToken1;
    bool unlocked; 
  }
  uint256 public override totalFeeGrowth0Token;
  uint256 public override totalFeeGrowth1Token;
  GlobalState public override globalState;
  uint128 public override liquidity;
  uint128 internal volumePerLiquidityInBlock;
  uint32 public override liquidityCooldown;
  address public override activeIncentive;
  mapping(int24 => TickManager.Tick) public override ticks;
  mapping(int16 => uint256) public override tickTable;
  modifier lock() {
    require(globalState.unlocked, 'LOK');
    globalState.unlocked = false;
    _;
    globalState.unlocked = true;
  }
  function _blockTimestamp() internal view virtual returns (uint32) {
    return uint32(block.timestamp); 
  }
}
pragma solidity >=0.5.0;
interface IAlgebraFlashCallback {
  function algebraFlashCallback(
    uint256 fee0,
    uint256 fee1,
    bytes calldata data
  ) external;
}
pragma solidity >=0.5.0;
interface IAlgebraMintCallback {
  function algebraMintCallback(
    uint256 amount0Owed,
    uint256 amount1Owed,
    bytes calldata data
  ) external;
}
pragma solidity >=0.5.0;
interface IAlgebraSwapCallback {
  function algebraSwapCallback(
    int256 amount0Delta,
    int256 amount1Delta,
    bytes calldata data
  ) external;
}
pragma solidity >=0.5.0;
interface IAlgebraPoolActions {
  function initialize(uint160 price) external;
  function mint(
    address sender,
    address recipient,
    int24 bottomTick,
    int24 topTick,
    uint128 amount,
    bytes calldata data
  )
    external
    returns (
      uint256 amount0,
      uint256 amount1,
      uint128 liquidityActual
    );
  function collect(
    address recipient,
    int24 bottomTick,
    int24 topTick,
    uint128 amount0Requested,
    uint128 amount1Requested
  ) external returns (uint128 amount0, uint128 amount1);
  function burn(
    int24 bottomTick,
    int24 topTick,
    uint128 amount
  ) external returns (uint256 amount0, uint256 amount1);
  function swap(
    address recipient,
    bool zeroToOne,
    int256 amountSpecified,
    uint160 limitSqrtPrice,
    bytes calldata data
  ) external returns (int256 amount0, int256 amount1);
  function swapSupportingFeeOnInputTokens(
    address sender,
    address recipient,
    bool zeroToOne,
    int256 amountSpecified,
    uint160 limitSqrtPrice,
    bytes calldata data
  ) external returns (int256 amount0, int256 amount1);
  function flash(
    address recipient,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external;
}
pragma solidity >=0.5.0;
interface IAlgebraPoolDerivedState {
  function getTimepoints(uint32[] calldata secondsAgos)
    external
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    );
  function getInnerCumulatives(int24 bottomTick, int24 topTick)
    external
    view
    returns (
      int56 innerTickCumulative,
      uint160 innerSecondsSpentPerLiquidity,
      uint32 innerSecondsSpent
    );
}
pragma solidity >=0.5.0;
interface IAlgebraPoolEvents {
  event Initialize(uint160 price, int24 tick);
  event Mint(
    address sender,
    address indexed owner,
    int24 indexed bottomTick,
    int24 indexed topTick,
    uint128 liquidityAmount,
    uint256 amount0,
    uint256 amount1
  );
  event Collect(address indexed owner, address recipient, int24 indexed bottomTick, int24 indexed topTick, uint128 amount0, uint128 amount1);
  event Burn(address indexed owner, int24 indexed bottomTick, int24 indexed topTick, uint128 liquidityAmount, uint256 amount0, uint256 amount1);
  event Swap(address indexed sender, address indexed recipient, int256 amount0, int256 amount1, uint160 price, uint128 liquidity, int24 tick);
  event Flash(address indexed sender, address indexed recipient, uint256 amount0, uint256 amount1, uint256 paid0, uint256 paid1);
  event CommunityFee(uint8 communityFee0New, uint8 communityFee1New);
  event Incentive(address indexed virtualPoolAddress);
  event Fee(uint16 fee);
  event LiquidityCooldown(uint32 liquidityCooldown);
}
pragma solidity >=0.5.0;
interface IAlgebraPoolPermissionedActions {
  function setCommunityFee(uint8 communityFee0, uint8 communityFee1) external;
  function setIncentive(address virtualPoolAddress) external;
  function setLiquidityCooldown(uint32 newLiquidityCooldown) external;
}
pragma solidity >=0.5.0;
interface IAlgebraPool is
  IAlgebraPoolImmutables,
  IAlgebraPoolState,
  IAlgebraPoolDerivedState,
  IAlgebraPoolActions,
  IAlgebraPoolPermissionedActions,
  IAlgebraPoolEvents
{
}
pragma solidity >=0.5.0;
interface IAlgebraVirtualPool {
  enum Status {
    NOT_EXIST,
    ACTIVE,
    NOT_STARTED
  }
  function cross(int24 nextTick, bool zeroToOne) external;
  function increaseCumulative(uint32 currentTimestamp) external returns (Status);
}
pragma solidity >=0.5.0;
interface IERC20Minimal {
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity =0.7.6;
library TokenDeltaMath {
  using LowGasSafeMath for uint256;
  using SafeCast for uint256;
  function getToken0Delta(
    uint160 priceLower,
    uint160 priceUpper,
    uint128 liquidity,
    bool roundUp
  ) internal pure returns (uint256 token0Delta) {
    uint256 priceDelta = priceUpper - priceLower;
    require(priceDelta < priceUpper); 
    uint256 liquidityShifted = uint256(liquidity) << Constants.RESOLUTION;
    token0Delta = roundUp
      ? FullMath.divRoundingUp(FullMath.mulDivRoundingUp(priceDelta, liquidityShifted, priceUpper), priceLower)
      : FullMath.mulDiv(priceDelta, liquidityShifted, priceUpper) / priceLower;
  }
  function getToken1Delta(
    uint160 priceLower,
    uint160 priceUpper,
    uint128 liquidity,
    bool roundUp
  ) internal pure returns (uint256 token1Delta) {
    require(priceUpper >= priceLower);
    uint256 priceDelta = priceUpper - priceLower;
    token1Delta = roundUp ? FullMath.mulDivRoundingUp(priceDelta, liquidity, Constants.Q96) : FullMath.mulDiv(priceDelta, liquidity, Constants.Q96);
  }
  function getToken0Delta(
    uint160 priceLower,
    uint160 priceUpper,
    int128 liquidity
  ) internal pure returns (int256 token0Delta) {
    token0Delta = liquidity >= 0
      ? getToken0Delta(priceLower, priceUpper, uint128(liquidity), true).toInt256()
      : -getToken0Delta(priceLower, priceUpper, uint128(-liquidity), false).toInt256();
  }
  function getToken1Delta(
    uint160 priceLower,
    uint160 priceUpper,
    int128 liquidity
  ) internal pure returns (int256 token1Delta) {
    token1Delta = liquidity >= 0
      ? getToken1Delta(priceLower, priceUpper, uint128(liquidity), true).toInt256()
      : -getToken1Delta(priceLower, priceUpper, uint128(-liquidity), false).toInt256();
  }
}
pragma solidity =0.7.6;
library PriceMovementMath {
  using LowGasSafeMath for uint256;
  using SafeCast for uint256;
  function getNewPriceAfterInput(
    uint160 price,
    uint128 liquidity,
    uint256 input,
    bool zeroToOne
  ) internal pure returns (uint160 resultPrice) {
    return getNewPrice(price, liquidity, input, zeroToOne, true);
  }
  function getNewPriceAfterOutput(
    uint160 price,
    uint128 liquidity,
    uint256 output,
    bool zeroToOne
  ) internal pure returns (uint160 resultPrice) {
    return getNewPrice(price, liquidity, output, zeroToOne, false);
  }
  function getNewPrice(
    uint160 price,
    uint128 liquidity,
    uint256 amount,
    bool zeroToOne,
    bool fromInput
  ) internal pure returns (uint160 resultPrice) {
    require(price > 0);
    require(liquidity > 0);
    if (zeroToOne == fromInput) {
      if (amount == 0) return price;
      uint256 liquidityShifted = uint256(liquidity) << Constants.RESOLUTION;
      if (fromInput) {
        uint256 product;
        if ((product = amount * price) / amount == price) {
          uint256 denominator = liquidityShifted + product;
          if (denominator >= liquidityShifted) return uint160(FullMath.mulDivRoundingUp(liquidityShifted, price, denominator)); 
        }
        return uint160(FullMath.divRoundingUp(liquidityShifted, (liquidityShifted / price).add(amount)));
      } else {
        uint256 product;
        require((product = amount * price) / amount == price); 
        require(liquidityShifted > product); 
        return FullMath.mulDivRoundingUp(liquidityShifted, price, liquidityShifted - product).toUint160();
      }
    } else {
      if (fromInput) {
        return
          uint256(price)
            .add(amount <= type(uint160).max ? (amount << Constants.RESOLUTION) / liquidity : FullMath.mulDiv(amount, Constants.Q96, liquidity))
            .toUint160();
      } else {
        uint256 quotient = amount <= type(uint160).max
          ? FullMath.divRoundingUp(amount << Constants.RESOLUTION, liquidity)
          : FullMath.mulDivRoundingUp(amount, Constants.Q96, liquidity);
        require(price > quotient);
        return uint160(price - quotient); 
      }
    }
  }
  function getTokenADelta01(
    uint160 to,
    uint160 from,
    uint128 liquidity
  ) internal pure returns (uint256) {
    return TokenDeltaMath.getToken0Delta(to, from, liquidity, true);
  }
  function getTokenADelta10(
    uint160 to,
    uint160 from,
    uint128 liquidity
  ) internal pure returns (uint256) {
    return TokenDeltaMath.getToken1Delta(from, to, liquidity, true);
  }
  function getTokenBDelta01(
    uint160 to,
    uint160 from,
    uint128 liquidity
  ) internal pure returns (uint256) {
    return TokenDeltaMath.getToken1Delta(to, from, liquidity, false);
  }
  function getTokenBDelta10(
    uint160 to,
    uint160 from,
    uint128 liquidity
  ) internal pure returns (uint256) {
    return TokenDeltaMath.getToken0Delta(from, to, liquidity, false);
  }
  function movePriceTowardsTarget(
    bool zeroToOne,
    uint160 currentPrice,
    uint160 targetPrice,
    uint128 liquidity,
    int256 amountAvailable,
    uint16 fee
  )
    internal
    pure
    returns (
      uint160 resultPrice,
      uint256 input,
      uint256 output,
      uint256 feeAmount
    )
  {
    function(uint160, uint160, uint128) pure returns (uint256) getAmountA = zeroToOne ? getTokenADelta01 : getTokenADelta10;
    if (amountAvailable >= 0) {
      uint256 amountAvailableAfterFee = FullMath.mulDiv(uint256(amountAvailable), 1e6 - fee, 1e6);
      input = getAmountA(targetPrice, currentPrice, liquidity);
      if (amountAvailableAfterFee >= input) {
        resultPrice = targetPrice;
        feeAmount = FullMath.mulDivRoundingUp(input, fee, 1e6 - fee);
      } else {
        resultPrice = getNewPriceAfterInput(currentPrice, liquidity, amountAvailableAfterFee, zeroToOne);
        if (targetPrice != resultPrice) {
          input = getAmountA(resultPrice, currentPrice, liquidity);
          feeAmount = uint256(amountAvailable) - input;
        } else {
          feeAmount = FullMath.mulDivRoundingUp(input, fee, 1e6 - fee);
        }
      }
      output = (zeroToOne ? getTokenBDelta01 : getTokenBDelta10)(resultPrice, currentPrice, liquidity);
    } else {
      function(uint160, uint160, uint128) pure returns (uint256) getAmountB = zeroToOne ? getTokenBDelta01 : getTokenBDelta10;
      output = getAmountB(targetPrice, currentPrice, liquidity);
      amountAvailable = -amountAvailable;
      if (uint256(amountAvailable) >= output) resultPrice = targetPrice;
      else {
        resultPrice = getNewPriceAfterOutput(currentPrice, liquidity, uint256(amountAvailable), zeroToOne);
        if (targetPrice != resultPrice) {
          output = getAmountB(resultPrice, currentPrice, liquidity);
        }
        if (output > uint256(amountAvailable)) {
          output = uint256(amountAvailable);
        }
      }
      input = getAmountA(resultPrice, currentPrice, liquidity);
      feeAmount = FullMath.mulDivRoundingUp(input, fee, 1e6 - fee);
    }
  }
}
pragma solidity >=0.5.0;
library TickMath {
  int24 internal constant MIN_TICK = -887272;
  int24 internal constant MAX_TICK = -MIN_TICK;
  uint160 internal constant MIN_SQRT_RATIO = 4295128739;
  uint160 internal constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;
  function getSqrtRatioAtTick(int24 tick) internal pure returns (uint160 price) {
    int24 mask = tick >> (24 - 1);
    uint256 absTick = uint256((tick ^ mask) - mask);
    require(absTick <= uint256(MAX_TICK), 'T');
    uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
    if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
    if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
    if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
    if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
    if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
    if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
    if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
    if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
    if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
    if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
    if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
    if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
    if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
    if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
    if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
    if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9) >> 128;
    if (absTick & 0x20000 != 0) ratio = (ratio * 0x5d6af8dedb81196699c329225ee604) >> 128;
    if (absTick & 0x40000 != 0) ratio = (ratio * 0x2216e584f5fa1ea926041bedfe98) >> 128;
    if (absTick & 0x80000 != 0) ratio = (ratio * 0x48a170391f7dc42444e8fa2) >> 128;
    if (tick > 0) ratio = type(uint256).max / ratio;
    price = uint160((ratio >> 32) + (ratio % (1 << 32) == 0 ? 0 : 1));
  }
  function getTickAtSqrtRatio(uint160 price) internal pure returns (int24 tick) {
    require(price >= MIN_SQRT_RATIO && price < MAX_SQRT_RATIO, 'R');
    uint256 ratio = uint256(price) << 32;
    uint256 r = ratio;
    uint256 msb = 0;
    assembly {
      let f := shl(7, gt(r, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(6, gt(r, 0xFFFFFFFFFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(5, gt(r, 0xFFFFFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(4, gt(r, 0xFFFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(3, gt(r, 0xFF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(2, gt(r, 0xF))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := shl(1, gt(r, 0x3))
      msb := or(msb, f)
      r := shr(f, r)
    }
    assembly {
      let f := gt(r, 0x1)
      msb := or(msb, f)
    }
    if (msb >= 128) r = ratio >> (msb - 127);
    else r = ratio << (127 - msb);
    int256 log_2 = (int256(msb) - 128) << 64;
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(63, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(62, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(61, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(60, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(59, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(58, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(57, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(56, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(55, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(54, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(53, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(52, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(51, f))
      r := shr(f, r)
    }
    assembly {
      r := shr(127, mul(r, r))
      let f := shr(128, r)
      log_2 := or(log_2, shl(50, f))
    }
    int256 log_sqrt10001 = log_2 * 255738958999603826347141; 
    int24 tickLow = int24((log_sqrt10001 - 3402992956809132418596140100660247210) >> 128);
    int24 tickHi = int24((log_sqrt10001 + 291339464771989622907027621153398088495) >> 128);
    tick = tickLow == tickHi ? tickLow : getSqrtRatioAtTick(tickHi) <= price ? tickHi : tickLow;
  }
}
pragma solidity =0.7.6;
library TickTable {
  function toggleTick(mapping(int16 => uint256) storage self, int24 tick) internal {
    require(tick % Constants.TICK_SPACING == 0, 'tick is not spaced'); 
    tick /= Constants.TICK_SPACING; 
    int16 rowNumber;
    uint8 bitNumber;
    assembly {
      bitNumber := and(tick, 0xFF)
      rowNumber := shr(8, tick)
    }
    self[rowNumber] ^= 1 << bitNumber;
  }
  function getSingleSignificantBit(uint256 word) internal pure returns (uint8 singleBitPos) {
    assembly {
      singleBitPos := iszero(and(word, 0x5555555555555555555555555555555555555555555555555555555555555555))
      singleBitPos := or(singleBitPos, shl(7, iszero(and(word, 0x00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))))
      singleBitPos := or(singleBitPos, shl(6, iszero(and(word, 0x0000000000000000FFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF))))
      singleBitPos := or(singleBitPos, shl(5, iszero(and(word, 0x00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF))))
      singleBitPos := or(singleBitPos, shl(4, iszero(and(word, 0x0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF))))
      singleBitPos := or(singleBitPos, shl(3, iszero(and(word, 0x00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF))))
      singleBitPos := or(singleBitPos, shl(2, iszero(and(word, 0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F))))
      singleBitPos := or(singleBitPos, shl(1, iszero(and(word, 0x3333333333333333333333333333333333333333333333333333333333333333))))
    }
  }
  function getMostSignificantBit(uint256 word) internal pure returns (uint8 mostBitPos) {
    assembly {
      word := or(word, shr(1, word))
      word := or(word, shr(2, word))
      word := or(word, shr(4, word))
      word := or(word, shr(8, word))
      word := or(word, shr(16, word))
      word := or(word, shr(32, word))
      word := or(word, shr(64, word))
      word := or(word, shr(128, word))
      word := sub(word, shr(1, word))
    }
    return (getSingleSignificantBit(word));
  }
  function nextTickInTheSameRow(
    mapping(int16 => uint256) storage self,
    int24 tick,
    bool lte
  ) internal view returns (int24 nextTick, bool initialized) {
    {
      int24 tickSpacing = Constants.TICK_SPACING;
      assembly {
        tick := sub(sdiv(tick, tickSpacing), and(slt(tick, 0), not(iszero(smod(tick, tickSpacing)))))
      }
    }
    if (lte) {
      int16 rowNumber;
      uint8 bitNumber;
      assembly {
        bitNumber := and(tick, 0xFF)
        rowNumber := shr(8, tick)
      }
      uint256 _row = self[rowNumber] << (255 - bitNumber); 
      if (_row != 0) {
        tick -= int24(255 - getMostSignificantBit(_row));
        return (uncompressAndBoundTick(tick), true);
      } else {
        tick -= int24(bitNumber);
        return (uncompressAndBoundTick(tick), false);
      }
    } else {
      tick += 1;
      int16 rowNumber;
      uint8 bitNumber;
      assembly {
        bitNumber := and(tick, 0xFF)
        rowNumber := shr(8, tick)
      }
      uint256 _row = self[rowNumber] >> (bitNumber);
      if (_row != 0) {
        tick += int24(getSingleSignificantBit(-_row & _row)); 
        return (uncompressAndBoundTick(tick), true);
      } else {
        tick += int24(255 - bitNumber);
        return (uncompressAndBoundTick(tick), false);
      }
    }
  }
  function uncompressAndBoundTick(int24 tick) private pure returns (int24 boundedTick) {
    boundedTick = tick * Constants.TICK_SPACING;
    if (boundedTick < TickMath.MIN_TICK) {
      boundedTick = TickMath.MIN_TICK;
    } else if (boundedTick > TickMath.MAX_TICK) {
      boundedTick = TickMath.MAX_TICK;
    }
  }
}
pragma solidity >=0.6.0;
library TransferHelper {
  function safeTransfer(
    address token,
    address to,
    uint256 value
  ) internal {
    (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20Minimal.transfer.selector, to, value));
    require(success && (data.length == 0 || abi.decode(data, (bool))), 'TF');
  }
}
pragma solidity =0.7.6;
contract AlgebraPool is PoolState, PoolImmutables, IAlgebraPool {
  using LowGasSafeMath for uint256;
  using LowGasSafeMath for int256;
  using LowGasSafeMath for uint128;
  using SafeCast for uint256;
  using SafeCast for int256;
  using TickTable for mapping(int16 => uint256);
  using TickManager for mapping(int24 => TickManager.Tick);
  struct Position {
    uint128 liquidity; 
    uint32 lastLiquidityAddTimestamp; 
    uint256 innerFeeGrowth0Token; 
    uint256 innerFeeGrowth1Token;
    uint128 fees0; 
    uint128 fees1; 
  }
  mapping(bytes32 => Position) public override positions;
  modifier onlyFactoryOwner() {
    require(msg.sender == IAlgebraFactory(factory).owner());
    _;
  }
  modifier onlyValidTicks(int24 bottomTick, int24 topTick) {
    require(topTick < TickMath.MAX_TICK + 1, 'TUM');
    require(topTick > bottomTick, 'TLU');
    require(bottomTick > TickMath.MIN_TICK - 1, 'TLM');
    _;
  }
  constructor() PoolImmutables(msg.sender) {
    globalState.fee = Constants.BASE_FEE;
  }
  function balanceToken0() private view returns (uint256) {
    return IERC20Minimal(token0).balanceOf(address(this));
  }
  function balanceToken1() private view returns (uint256) {
    return IERC20Minimal(token1).balanceOf(address(this));
  }
  function timepoints(uint256 index)
    external
    view
    override
    returns (
      bool initialized,
      uint32 blockTimestamp,
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint88 volatilityCumulative,
      int24 averageTick,
      uint144 volumePerLiquidityCumulative
    )
  {
    return IDataStorageOperator(dataStorageOperator).timepoints(index);
  }
  struct Cumulatives {
    int56 tickCumulative;
    uint160 outerSecondPerLiquidity;
    uint32 outerSecondsSpent;
  }
  function getInnerCumulatives(int24 bottomTick, int24 topTick)
    external
    view
    override
    onlyValidTicks(bottomTick, topTick)
    returns (
      int56 innerTickCumulative,
      uint160 innerSecondsSpentPerLiquidity,
      uint32 innerSecondsSpent
    )
  {
    Cumulatives memory lower;
    {
      TickManager.Tick storage _lower = ticks[bottomTick];
      (lower.tickCumulative, lower.outerSecondPerLiquidity, lower.outerSecondsSpent) = (
        _lower.outerTickCumulative,
        _lower.outerSecondsPerLiquidity,
        _lower.outerSecondsSpent
      );
      require(_lower.initialized);
    }
    Cumulatives memory upper;
    {
      TickManager.Tick storage _upper = ticks[topTick];
      (upper.tickCumulative, upper.outerSecondPerLiquidity, upper.outerSecondsSpent) = (
        _upper.outerTickCumulative,
        _upper.outerSecondsPerLiquidity,
        _upper.outerSecondsSpent
      );
      require(_upper.initialized);
    }
    (int24 currentTick, uint16 currentTimepointIndex) = (globalState.tick, globalState.timepointIndex);
    if (currentTick < bottomTick) {
      return (
        lower.tickCumulative - upper.tickCumulative,
        lower.outerSecondPerLiquidity - upper.outerSecondPerLiquidity,
        lower.outerSecondsSpent - upper.outerSecondsSpent
      );
    }
    if (currentTick < topTick) {
      uint32 globalTime = _blockTimestamp();
      (int56 globalTickCumulative, uint160 globalSecondsPerLiquidityCumulative, , ) = _getSingleTimepoint(
        globalTime,
        0,
        currentTick,
        currentTimepointIndex,
        liquidity
      );
      return (
        globalTickCumulative - lower.tickCumulative - upper.tickCumulative,
        globalSecondsPerLiquidityCumulative - lower.outerSecondPerLiquidity - upper.outerSecondPerLiquidity,
        globalTime - lower.outerSecondsSpent - upper.outerSecondsSpent
      );
    }
    return (
      upper.tickCumulative - lower.tickCumulative,
      upper.outerSecondPerLiquidity - lower.outerSecondPerLiquidity,
      upper.outerSecondsSpent - lower.outerSecondsSpent
    );
  }
  function getTimepoints(uint32[] calldata secondsAgos)
    external
    view
    override
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    )
  {
    return
      IDataStorageOperator(dataStorageOperator).getTimepoints(
        _blockTimestamp(),
        secondsAgos,
        globalState.tick,
        globalState.timepointIndex,
        liquidity
      );
  }
  function initialize(uint160 initialPrice) external override {
    require(globalState.price == 0, 'AI');
    int24 tick = TickMath.getTickAtSqrtRatio(initialPrice);
    uint32 timestamp = _blockTimestamp();
    IDataStorageOperator(dataStorageOperator).initialize(timestamp, tick);
    globalState.price = initialPrice;
    globalState.unlocked = true;
    globalState.tick = tick;
    emit Initialize(initialPrice, tick);
  }
  function _recalculatePosition(
    Position storage _position,
    int128 liquidityDelta,
    uint256 innerFeeGrowth0Token,
    uint256 innerFeeGrowth1Token
  ) internal {
    (uint128 currentLiquidity, uint32 lastLiquidityAddTimestamp) = (_position.liquidity, _position.lastLiquidityAddTimestamp);
    if (liquidityDelta == 0) {
      require(currentLiquidity > 0, 'NP'); 
    } else {
      if (liquidityDelta < 0) {
        uint32 _liquidityCooldown = liquidityCooldown;
        if (_liquidityCooldown > 0) {
          require((_blockTimestamp() - lastLiquidityAddTimestamp) >= _liquidityCooldown);
        }
      }
      uint128 liquidityNext = LiquidityMath.addDelta(currentLiquidity, liquidityDelta);
      (_position.liquidity, _position.lastLiquidityAddTimestamp) = (
        liquidityNext,
        liquidityNext > 0 ? (liquidityDelta > 0 ? _blockTimestamp() : lastLiquidityAddTimestamp) : 0
      );
    }
    uint256 _innerFeeGrowth0Token = _position.innerFeeGrowth0Token;
    uint256 _innerFeeGrowth1Token = _position.innerFeeGrowth1Token;
    uint128 fees0;
    if (innerFeeGrowth0Token != _innerFeeGrowth0Token) {
      _position.innerFeeGrowth0Token = innerFeeGrowth0Token;
      fees0 = uint128(FullMath.mulDiv(innerFeeGrowth0Token - _innerFeeGrowth0Token, currentLiquidity, Constants.Q128));
    }
    uint128 fees1;
    if (innerFeeGrowth1Token != _innerFeeGrowth1Token) {
      _position.innerFeeGrowth1Token = innerFeeGrowth1Token;
      fees1 = uint128(FullMath.mulDiv(innerFeeGrowth1Token - _innerFeeGrowth1Token, currentLiquidity, Constants.Q128));
    }
    if (fees0 | fees1 != 0) {
      _position.fees0 += fees0;
      _position.fees1 += fees1;
    }
  }
  struct UpdatePositionCache {
    uint160 price; 
    int24 tick; 
    uint16 timepointIndex; 
  }
  function _updatePositionTicksAndFees(
    address owner,
    int24 bottomTick,
    int24 topTick,
    int128 liquidityDelta
  )
    private
    returns (
      Position storage position,
      int256 amount0,
      int256 amount1
    )
  {
    UpdatePositionCache memory cache = UpdatePositionCache(globalState.price, globalState.tick, globalState.timepointIndex);
    position = getOrCreatePosition(owner, bottomTick, topTick);
    (uint256 _totalFeeGrowth0Token, uint256 _totalFeeGrowth1Token) = (totalFeeGrowth0Token, totalFeeGrowth1Token);
    bool toggledBottom;
    bool toggledTop;
    if (liquidityDelta != 0) {
      uint32 time = _blockTimestamp();
      (int56 tickCumulative, uint160 secondsPerLiquidityCumulative, , ) = _getSingleTimepoint(time, 0, cache.tick, cache.timepointIndex, liquidity);
      if (
        ticks.update(
          bottomTick,
          cache.tick,
          liquidityDelta,
          _totalFeeGrowth0Token,
          _totalFeeGrowth1Token,
          secondsPerLiquidityCumulative,
          tickCumulative,
          time,
          false 
        )
      ) {
        toggledBottom = true;
        tickTable.toggleTick(bottomTick);
      }
      if (
        ticks.update(
          topTick,
          cache.tick,
          liquidityDelta,
          _totalFeeGrowth0Token,
          _totalFeeGrowth1Token,
          secondsPerLiquidityCumulative,
          tickCumulative,
          time,
          true 
        )
      ) {
        toggledTop = true;
        tickTable.toggleTick(topTick);
      }
    }
    (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) = ticks.getInnerFeeGrowth(
      bottomTick,
      topTick,
      cache.tick,
      _totalFeeGrowth0Token,
      _totalFeeGrowth1Token
    );
    _recalculatePosition(position, liquidityDelta, feeGrowthInside0X128, feeGrowthInside1X128);
    if (liquidityDelta != 0) {
      if (liquidityDelta < 0) {
        if (toggledBottom) delete ticks[bottomTick];
        if (toggledTop) delete ticks[topTick];
      }
      int128 globalLiquidityDelta;
      (amount0, amount1, globalLiquidityDelta) = _getAmountsForLiquidity(bottomTick, topTick, liquidityDelta, cache.tick, cache.price);
      if (globalLiquidityDelta != 0) {
        uint128 liquidityBefore = liquidity;
        uint16 newTimepointIndex = _writeTimepoint(cache.timepointIndex, _blockTimestamp(), cache.tick, liquidityBefore, volumePerLiquidityInBlock);
        if (cache.timepointIndex != newTimepointIndex) {
          globalState.fee = _getNewFee(_blockTimestamp(), cache.tick, newTimepointIndex, liquidityBefore);
          globalState.timepointIndex = newTimepointIndex;
          volumePerLiquidityInBlock = 0;
        }
        liquidity = LiquidityMath.addDelta(liquidityBefore, liquidityDelta);
      }
    }
  }
  function _getAmountsForLiquidity(
    int24 bottomTick,
    int24 topTick,
    int128 liquidityDelta,
    int24 currentTick,
    uint160 currentPrice
  )
    private
    pure
    returns (
      int256 amount0,
      int256 amount1,
      int128 globalLiquidityDelta
    )
  {
    if (currentTick < bottomTick) {
      amount0 = TokenDeltaMath.getToken0Delta(TickMath.getSqrtRatioAtTick(bottomTick), TickMath.getSqrtRatioAtTick(topTick), liquidityDelta);
    } else if (currentTick < topTick) {
      amount0 = TokenDeltaMath.getToken0Delta(currentPrice, TickMath.getSqrtRatioAtTick(topTick), liquidityDelta);
      amount1 = TokenDeltaMath.getToken1Delta(TickMath.getSqrtRatioAtTick(bottomTick), currentPrice, liquidityDelta);
      globalLiquidityDelta = liquidityDelta;
    }
    else {
      amount1 = TokenDeltaMath.getToken1Delta(TickMath.getSqrtRatioAtTick(bottomTick), TickMath.getSqrtRatioAtTick(topTick), liquidityDelta);
    }
  }
  function getOrCreatePosition(
    address owner,
    int24 bottomTick,
    int24 topTick
  ) private view returns (Position storage) {
    bytes32 key;
    assembly {
      key := or(shl(24, or(shl(24, owner), and(bottomTick, 0xFFFFFF))), and(topTick, 0xFFFFFF))
    }
    return positions[key];
  }
  function mint(
    address sender,
    address recipient,
    int24 bottomTick,
    int24 topTick,
    uint128 liquidityDesired,
    bytes calldata data
  )
    external
    override
    lock
    onlyValidTicks(bottomTick, topTick)
    returns (
      uint256 amount0,
      uint256 amount1,
      uint128 liquidityActual
    )
  {
    require(liquidityDesired > 0, 'IL');
    {
      (int256 amount0Int, int256 amount1Int, ) = _getAmountsForLiquidity(
        bottomTick,
        topTick,
        int256(liquidityDesired).toInt128(),
        globalState.tick,
        globalState.price
      );
      amount0 = uint256(amount0Int);
      amount1 = uint256(amount1Int);
    }
    uint256 receivedAmount0;
    uint256 receivedAmount1;
    {
      if (amount0 > 0) receivedAmount0 = balanceToken0();
      if (amount1 > 0) receivedAmount1 = balanceToken1();
      IAlgebraMintCallback(msg.sender).algebraMintCallback(amount0, amount1, data);
      if (amount0 > 0) require((receivedAmount0 = balanceToken0() - receivedAmount0) > 0, 'IIAM');
      if (amount1 > 0) require((receivedAmount1 = balanceToken1() - receivedAmount1) > 0, 'IIAM');
    }
    liquidityActual = liquidityDesired;
    if (receivedAmount0 < amount0) {
      liquidityActual = uint128(FullMath.mulDiv(uint256(liquidityActual), receivedAmount0, amount0));
    }
    if (receivedAmount1 < amount1) {
      uint128 liquidityForRA1 = uint128(FullMath.mulDiv(uint256(liquidityActual), receivedAmount1, amount1));
      if (liquidityForRA1 < liquidityActual) {
        liquidityActual = liquidityForRA1;
      }
    }
    require(liquidityActual > 0, 'IIL2');
    {
      (, int256 amount0Int, int256 amount1Int) = _updatePositionTicksAndFees(recipient, bottomTick, topTick, int256(liquidityActual).toInt128());
      require((amount0 = uint256(amount0Int)) <= receivedAmount0, 'IIAM2');
      require((amount1 = uint256(amount1Int)) <= receivedAmount1, 'IIAM2');
    }
    if (receivedAmount0 > amount0) {
      TransferHelper.safeTransfer(token0, sender, receivedAmount0 - amount0);
    }
    if (receivedAmount1 > amount1) {
      TransferHelper.safeTransfer(token1, sender, receivedAmount1 - amount1);
    }
    emit Mint(msg.sender, recipient, bottomTick, topTick, liquidityActual, amount0, amount1);
  }
  function collect(
    address recipient,
    int24 bottomTick,
    int24 topTick,
    uint128 amount0Requested,
    uint128 amount1Requested
  ) external override lock returns (uint128 amount0, uint128 amount1) {
    Position storage position = getOrCreatePosition(msg.sender, bottomTick, topTick);
    (uint128 positionFees0, uint128 positionFees1) = (position.fees0, position.fees1);
    amount0 = amount0Requested > positionFees0 ? positionFees0 : amount0Requested;
    amount1 = amount1Requested > positionFees1 ? positionFees1 : amount1Requested;
    if (amount0 | amount1 != 0) {
      position.fees0 = positionFees0 - amount0;
      position.fees1 = positionFees1 - amount1;
      if (amount0 > 0) TransferHelper.safeTransfer(token0, recipient, amount0);
      if (amount1 > 0) TransferHelper.safeTransfer(token1, recipient, amount1);
    }
    emit Collect(msg.sender, recipient, bottomTick, topTick, amount0, amount1);
  }
  function burn(
    int24 bottomTick,
    int24 topTick,
    uint128 amount
  ) external override lock onlyValidTicks(bottomTick, topTick) returns (uint256 amount0, uint256 amount1) {
    (Position storage position, int256 amount0Int, int256 amount1Int) = _updatePositionTicksAndFees(
      msg.sender,
      bottomTick,
      topTick,
      -int256(amount).toInt128()
    );
    amount0 = uint256(-amount0Int);
    amount1 = uint256(-amount1Int);
    if (amount0 | amount1 != 0) {
      (position.fees0, position.fees1) = (position.fees0.add128(uint128(amount0)), position.fees1.add128(uint128(amount1)));
    }
    emit Burn(msg.sender, bottomTick, topTick, amount, amount0, amount1);
  }
  function _getNewFee(
    uint32 _time,
    int24 _tick,
    uint16 _index,
    uint128 _liquidity
  ) private returns (uint16 newFee) {
    newFee = IDataStorageOperator(dataStorageOperator).getFee(_time, _tick, _index, _liquidity);
    emit Fee(newFee);
  }
  function _payCommunityFee(address token, uint256 amount) private {
    address vault = IAlgebraFactory(factory).vaultAddress();
    TransferHelper.safeTransfer(token, vault, amount);
  }
  function _writeTimepoint(
    uint16 timepointIndex,
    uint32 blockTimestamp,
    int24 tick,
    uint128 liquidity,
    uint128 volumePerLiquidityInBlock
  ) private returns (uint16 newTimepointIndex) {
    return IDataStorageOperator(dataStorageOperator).write(timepointIndex, blockTimestamp, tick, liquidity, volumePerLiquidityInBlock);
  }
  function _getSingleTimepoint(
    uint32 blockTimestamp,
    uint32 secondsAgo,
    int24 startTick,
    uint16 timepointIndex,
    uint128 liquidityStart
  )
    private
    view
    returns (
      int56 tickCumulative,
      uint160 secondsPerLiquidityCumulative,
      uint112 volatilityCumulative,
      uint256 volumePerAvgLiquidity
    )
  {
    return IDataStorageOperator(dataStorageOperator).getSingleTimepoint(blockTimestamp, secondsAgo, startTick, timepointIndex, liquidityStart);
  }
  function _swapCallback(
    int256 amount0,
    int256 amount1,
    bytes calldata data
  ) private {
    IAlgebraSwapCallback(msg.sender).algebraSwapCallback(amount0, amount1, data);
  }
  function swap(
    address recipient,
    bool zeroToOne,
    int256 amountRequired,
    uint160 limitSqrtPrice,
    bytes calldata data
  ) external override returns (int256 amount0, int256 amount1) {
    uint160 currentPrice;
    int24 currentTick;
    uint128 currentLiquidity;
    uint256 communityFee;
    (amount0, amount1, currentPrice, currentTick, currentLiquidity, communityFee) = _calculateSwapAndLock(zeroToOne, amountRequired, limitSqrtPrice);
    if (zeroToOne) {
      if (amount1 < 0) TransferHelper.safeTransfer(token1, recipient, uint256(-amount1)); 
      uint256 balance0Before = balanceToken0();
      _swapCallback(amount0, amount1, data); 
      require(balance0Before.add(uint256(amount0)) <= balanceToken0(), 'IIA');
    } else {
      if (amount0 < 0) TransferHelper.safeTransfer(token0, recipient, uint256(-amount0)); 
      uint256 balance1Before = balanceToken1();
      _swapCallback(amount0, amount1, data); 
      require(balance1Before.add(uint256(amount1)) <= balanceToken1(), 'IIA');
    }
    if (communityFee > 0) {
      _payCommunityFee(zeroToOne ? token0 : token1, communityFee);
    }
    emit Swap(msg.sender, recipient, amount0, amount1, currentPrice, currentLiquidity, currentTick);
    globalState.unlocked = true; 
  }
  function swapSupportingFeeOnInputTokens(
    address sender,
    address recipient,
    bool zeroToOne,
    int256 amountRequired,
    uint160 limitSqrtPrice,
    bytes calldata data
  ) external override returns (int256 amount0, int256 amount1) {
    require(globalState.unlocked, 'LOK');
    globalState.unlocked = false;
    if (zeroToOne) {
      uint256 balance0Before = balanceToken0();
      _swapCallback(amountRequired, 0, data);
      require((amountRequired = int256(balanceToken0().sub(balance0Before))) > 0, 'IIA');
    } else {
      uint256 balance1Before = balanceToken1();
      _swapCallback(0, amountRequired, data);
      require((amountRequired = int256(balanceToken1().sub(balance1Before))) > 0, 'IIA');
    }
    globalState.unlocked = true;
    uint160 currentPrice;
    int24 currentTick;
    uint128 currentLiquidity;
    uint256 communityFee;
    (amount0, amount1, currentPrice, currentTick, currentLiquidity, communityFee) = _calculateSwapAndLock(zeroToOne, amountRequired, limitSqrtPrice);
    if (zeroToOne) {
      if (amount1 < 0) TransferHelper.safeTransfer(token1, recipient, uint256(-amount1));
      if (amount0 < amountRequired) TransferHelper.safeTransfer(token0, sender, uint256(amountRequired.sub(amount0)));
    } else {
      if (amount0 < 0) TransferHelper.safeTransfer(token0, recipient, uint256(-amount0));
      if (amount1 < amountRequired) TransferHelper.safeTransfer(token1, sender, uint256(amountRequired.sub(amount1)));
    }
    if (communityFee > 0) {
      _payCommunityFee(zeroToOne ? token0 : token1, communityFee);
    }
    emit Swap(msg.sender, recipient, amount0, amount1, currentPrice, currentLiquidity, currentTick);
    globalState.unlocked = true; 
  }
  struct SwapCalculationCache {
    uint256 communityFee; 
    uint128 volumePerLiquidityInBlock;
    int56 tickCumulative; 
    uint160 secondsPerLiquidityCumulative; 
    bool computedLatestTimepoint; 
    int256 amountRequiredInitial; 
    int256 amountCalculated; 
    uint256 totalFeeGrowth; 
    uint256 totalFeeGrowthB;
    IAlgebraVirtualPool.Status incentiveStatus; 
    bool exactInput; 
    uint16 fee; 
    int24 startTick; 
    uint16 timepointIndex; 
  }
  struct PriceMovementCache {
    uint160 stepSqrtPrice; 
    int24 nextTick; 
    bool initialized; 
    uint160 nextTickPrice; 
    uint256 input; 
    uint256 output; 
    uint256 feeAmount; 
  }
  function _calculateSwapAndLock(
    bool zeroToOne,
    int256 amountRequired,
    uint160 limitSqrtPrice
  )
    private
    returns (
      int256 amount0,
      int256 amount1,
      uint160 currentPrice,
      int24 currentTick,
      uint128 currentLiquidity,
      uint256 communityFeeAmount
    )
  {
    uint32 blockTimestamp;
    SwapCalculationCache memory cache;
    {
      currentPrice = globalState.price;
      currentTick = globalState.tick;
      cache.fee = globalState.fee;
      cache.timepointIndex = globalState.timepointIndex;
      uint256 _communityFeeToken0 = globalState.communityFeeToken0;
      uint256 _communityFeeToken1 = globalState.communityFeeToken1;
      bool unlocked = globalState.unlocked;
      globalState.unlocked = false; 
      require(unlocked, 'LOK');
      require(amountRequired != 0, 'AS');
      (cache.amountRequiredInitial, cache.exactInput) = (amountRequired, amountRequired > 0);
      (currentLiquidity, cache.volumePerLiquidityInBlock) = (liquidity, volumePerLiquidityInBlock);
      if (zeroToOne) {
        require(limitSqrtPrice < currentPrice && limitSqrtPrice > TickMath.MIN_SQRT_RATIO, 'SPL');
        cache.totalFeeGrowth = totalFeeGrowth0Token;
        cache.communityFee = _communityFeeToken0;
      } else {
        require(limitSqrtPrice > currentPrice && limitSqrtPrice < TickMath.MAX_SQRT_RATIO, 'SPL');
        cache.totalFeeGrowth = totalFeeGrowth1Token;
        cache.communityFee = _communityFeeToken1;
      }
      cache.startTick = currentTick;
      blockTimestamp = _blockTimestamp();
      if (activeIncentive != address(0)) {
        IAlgebraVirtualPool.Status _status = IAlgebraVirtualPool(activeIncentive).increaseCumulative(blockTimestamp);
        if (_status == IAlgebraVirtualPool.Status.NOT_EXIST) {
          activeIncentive = address(0);
        } else if (_status == IAlgebraVirtualPool.Status.ACTIVE) {
          cache.incentiveStatus = IAlgebraVirtualPool.Status.ACTIVE;
        } else if (_status == IAlgebraVirtualPool.Status.NOT_STARTED) {
          cache.incentiveStatus = IAlgebraVirtualPool.Status.NOT_STARTED;
        }
      }
      uint16 newTimepointIndex = _writeTimepoint(
        cache.timepointIndex,
        blockTimestamp,
        cache.startTick,
        currentLiquidity,
        cache.volumePerLiquidityInBlock
      );
      if (newTimepointIndex != cache.timepointIndex) {
        cache.timepointIndex = newTimepointIndex;
        cache.volumePerLiquidityInBlock = 0;
        cache.fee = _getNewFee(blockTimestamp, currentTick, newTimepointIndex, currentLiquidity);
      }
    }
    PriceMovementCache memory step;
    while (true) {
      step.stepSqrtPrice = currentPrice;
      (step.nextTick, step.initialized) = tickTable.nextTickInTheSameRow(currentTick, zeroToOne);
      step.nextTickPrice = TickMath.getSqrtRatioAtTick(step.nextTick);
      (currentPrice, step.input, step.output, step.feeAmount) = PriceMovementMath.movePriceTowardsTarget(
        zeroToOne,
        currentPrice,
        (zeroToOne == (step.nextTickPrice < limitSqrtPrice)) 
          ? limitSqrtPrice
          : step.nextTickPrice,
        currentLiquidity,
        amountRequired,
        cache.fee
      );
      if (cache.exactInput) {
        amountRequired -= (step.input + step.feeAmount).toInt256(); 
        cache.amountCalculated = cache.amountCalculated.sub(step.output.toInt256()); 
      } else {
        amountRequired += step.output.toInt256(); 
        cache.amountCalculated = cache.amountCalculated.add((step.input + step.feeAmount).toInt256()); 
      }
      if (cache.communityFee > 0) {
        uint256 delta = (step.feeAmount.mul(cache.communityFee)) / Constants.COMMUNITY_FEE_DENOMINATOR;
        step.feeAmount -= delta;
        communityFeeAmount += delta;
      }
      if (currentLiquidity > 0) cache.totalFeeGrowth += FullMath.mulDiv(step.feeAmount, Constants.Q128, currentLiquidity);
      if (currentPrice == step.nextTickPrice) {
        if (step.initialized) {
          if (!cache.computedLatestTimepoint) {
            (cache.tickCumulative, cache.secondsPerLiquidityCumulative, , ) = _getSingleTimepoint(
              blockTimestamp,
              0,
              cache.startTick,
              cache.timepointIndex,
              currentLiquidity 
            );
            cache.computedLatestTimepoint = true;
            cache.totalFeeGrowthB = zeroToOne ? totalFeeGrowth1Token : totalFeeGrowth0Token;
          }
          if (cache.incentiveStatus != IAlgebraVirtualPool.Status.NOT_EXIST) {
            IAlgebraVirtualPool(activeIncentive).cross(step.nextTick, zeroToOne);
          }
          int128 liquidityDelta;
          if (zeroToOne) {
            liquidityDelta = -ticks.cross(
              step.nextTick,
              cache.totalFeeGrowth, 
              cache.totalFeeGrowthB, 
              cache.secondsPerLiquidityCumulative,
              cache.tickCumulative,
              blockTimestamp
            );
          } else {
            liquidityDelta = ticks.cross(
              step.nextTick,
              cache.totalFeeGrowthB, 
              cache.totalFeeGrowth, 
              cache.secondsPerLiquidityCumulative,
              cache.tickCumulative,
              blockTimestamp
            );
          }
          currentLiquidity = LiquidityMath.addDelta(currentLiquidity, liquidityDelta);
        }
        currentTick = zeroToOne ? step.nextTick - 1 : step.nextTick;
      } else if (currentPrice != step.stepSqrtPrice) {
        currentTick = TickMath.getTickAtSqrtRatio(currentPrice);
        break; 
      }
      if (amountRequired == 0 || currentPrice == limitSqrtPrice) {
        break;
      }
    }
    (amount0, amount1) = zeroToOne == cache.exactInput 
      ? (cache.amountRequiredInitial - amountRequired, cache.amountCalculated) 
      : (cache.amountCalculated, cache.amountRequiredInitial - amountRequired);
    (globalState.price, globalState.tick, globalState.fee, globalState.timepointIndex) = (currentPrice, currentTick, cache.fee, cache.timepointIndex);
    (liquidity, volumePerLiquidityInBlock) = (
      currentLiquidity,
      cache.volumePerLiquidityInBlock + IDataStorageOperator(dataStorageOperator).calculateVolumePerLiquidity(currentLiquidity, amount0, amount1)
    );
    if (zeroToOne) {
      totalFeeGrowth0Token = cache.totalFeeGrowth;
    } else {
      totalFeeGrowth1Token = cache.totalFeeGrowth;
    }
  }
  function flash(
    address recipient,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external override lock {
    uint128 _liquidity = liquidity;
    require(_liquidity > 0, 'L');
    uint16 _fee = globalState.fee;
    uint256 fee0;
    uint256 balance0Before = balanceToken0();
    if (amount0 > 0) {
      fee0 = FullMath.mulDivRoundingUp(amount0, _fee, 1e6);
      TransferHelper.safeTransfer(token0, recipient, amount0);
    }
    uint256 fee1;
    uint256 balance1Before = balanceToken1();
    if (amount1 > 0) {
      fee1 = FullMath.mulDivRoundingUp(amount1, _fee, 1e6);
      TransferHelper.safeTransfer(token1, recipient, amount1);
    }
    IAlgebraFlashCallback(msg.sender).algebraFlashCallback(fee0, fee1, data);
    address vault = IAlgebraFactory(factory).vaultAddress();
    uint256 paid0 = balanceToken0();
    require(balance0Before.add(fee0) <= paid0, 'F0');
    paid0 -= balance0Before;
    if (paid0 > 0) {
      uint8 _communityFeeToken0 = globalState.communityFeeToken0;
      uint256 fees0;
      if (_communityFeeToken0 > 0) {
        fees0 = (paid0 * _communityFeeToken0) / Constants.COMMUNITY_FEE_DENOMINATOR;
        TransferHelper.safeTransfer(token0, vault, fees0);
      }
      totalFeeGrowth0Token += FullMath.mulDiv(paid0 - fees0, Constants.Q128, _liquidity);
    }
    uint256 paid1 = balanceToken1();
    require(balance1Before.add(fee1) <= paid1, 'F1');
    paid1 -= balance1Before;
    if (paid1 > 0) {
      uint8 _communityFeeToken1 = globalState.communityFeeToken1;
      uint256 fees1;
      if (_communityFeeToken1 > 0) {
        fees1 = (paid1 * _communityFeeToken1) / Constants.COMMUNITY_FEE_DENOMINATOR;
        TransferHelper.safeTransfer(token1, vault, fees1);
      }
      totalFeeGrowth1Token += FullMath.mulDiv(paid1 - fees1, Constants.Q128, _liquidity);
    }
    emit Flash(msg.sender, recipient, amount0, amount1, paid0, paid1);
  }
  function setCommunityFee(uint8 communityFee0, uint8 communityFee1) external override lock onlyFactoryOwner {
    require((communityFee0 <= Constants.MAX_COMMUNITY_FEE) && (communityFee1 <= Constants.MAX_COMMUNITY_FEE));
    (globalState.communityFeeToken0, globalState.communityFeeToken1) = (communityFee0, communityFee1);
    emit CommunityFee(communityFee0, communityFee1);
  }
  function setIncentive(address virtualPoolAddress) external override {
    require(msg.sender == IAlgebraFactory(factory).farmingAddress());
    activeIncentive = virtualPoolAddress;
    emit Incentive(virtualPoolAddress);
  }
  function setLiquidityCooldown(uint32 newLiquidityCooldown) external override onlyFactoryOwner {
    require(newLiquidityCooldown <= Constants.MAX_LIQUIDITY_COOLDOWN && liquidityCooldown != newLiquidityCooldown);
    liquidityCooldown = newLiquidityCooldown;
    emit LiquidityCooldown(newLiquidityCooldown);
  }
}
pragma solidity =0.7.6;
contract AlgebraPoolDeployer is IAlgebraPoolDeployer {
  struct Parameters {
    address dataStorage;
    address factory;
    address token0;
    address token1;
  }
  Parameters public override parameters;
  address private factory;
  address private owner;
  modifier onlyFactory() {
    require(msg.sender == factory);
    _;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  constructor() {
    owner = msg.sender;
  }
  function setFactory(address _factory) external override onlyOwner {
    require(_factory != address(0));
    require(factory == address(0));
    emit Factory(_factory);
    factory = _factory;
  }
  function deploy(
    address dataStorage,
    address _factory,
    address token0,
    address token1
  ) external override onlyFactory returns (address pool) {
    parameters = Parameters({dataStorage: dataStorage, factory: _factory, token0: token0, token1: token1});
    pool = address(new AlgebraPool{salt: keccak256(abi.encode(token0, token1))}());
  }
}
pragma solidity =0.7.6;
contract AdaptiveFeeEchidnaTest {
  function expInvariants(uint256 x, uint16 gamma) external pure {
    require(gamma != 0);
    if (x >= 6 * gamma) return;
    uint256 g8 = uint256(gamma)**8;
    uint256 exp = AdaptiveFee.exp(x, gamma, g8);
    assert(exp < 2**137);
  }
  function sigmoidInvariants(
    uint256 x,
    uint16 gamma,
    uint16 alpha,
    uint256 beta
  ) external pure {
    require(gamma != 0);
    uint256 res = AdaptiveFee.sigmoid(x, gamma, alpha, beta);
    assert(res <= type(uint16).max);
    assert(res <= alpha);
  }
  function getFeeInvariants(
    uint88 volatility,
    uint256 volumePerLiquidity,
    uint16 gamma1,
    uint16 gamma2,
    uint16 alpha1,
    uint16 alpha2,
    uint32 beta1,
    uint32 beta2,
    uint16 volumeGamma,
    uint32 volumeBeta,
    uint16 baseFee
  ) external pure returns (uint256 fee) {
    require(uint256(alpha1) + uint256(alpha2) + uint256(baseFee) <= type(uint16).max, 'Max fee exceeded');
    require(gamma1 != 0 && gamma2 != 0 && volumeGamma != 0, 'Gammas must be > 0');
    uint256 sigm1 = AdaptiveFee.sigmoid(volatility, gamma1, alpha1, beta1);
    uint256 sigm2 = AdaptiveFee.sigmoid(volatility, gamma2, alpha2, beta2);
    assert(sigm1 + sigm2 <= type(uint16).max);
    fee = baseFee + AdaptiveFee.sigmoid(volumePerLiquidity, volumeGamma, uint16(sigm1 + sigm2), volumeBeta);
    assert(fee <= type(uint16).max);
  }
}
pragma solidity =0.7.6;
contract AdaptiveFeeTest {
  AdaptiveFee.Configuration public feeConfig =
    AdaptiveFee.Configuration(
      3000 - Constants.BASE_FEE, 
      15000 - 3000, 
      360, 
      60000, 
      59, 
      8500, 
      0, 
      10, 
      Constants.BASE_FEE 
    );
  function getFee(uint88 volatility, uint256 volumePerLiquidity) external view returns (uint256 fee) {
    return AdaptiveFee.getFee(volatility, volumePerLiquidity, feeConfig);
  }
  function getGasCostOfGetFee(uint88 volatility, uint256 volumePerLiquidity) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    AdaptiveFee.getFee(volatility, volumePerLiquidity, feeConfig);
    return gasBefore - gasleft();
  }
}
pragma solidity =0.7.6;
contract AlgebraPoolSwapTest is IAlgebraSwapCallback {
  int256 private _amount0Delta;
  int256 private _amount1Delta;
  function getSwapResult(
    address pool,
    bool zeroToOne,
    int256 amountSpecified,
    uint160 limitSqrtPrice
  )
    external
    returns (
      int256 amount0Delta,
      int256 amount1Delta,
      uint160 nextSqrtRatio
    )
  {
    (amount0Delta, amount1Delta) = IAlgebraPool(pool).swap(address(0), zeroToOne, amountSpecified, limitSqrtPrice, abi.encode(msg.sender));
    (nextSqrtRatio, , , , , , ) = IAlgebraPool(pool).globalState();
  }
  function algebraSwapCallback(
    int256 amount0Delta,
    int256 amount1Delta,
    bytes calldata data
  ) external override {
    address sender = abi.decode(data, (address));
    if (amount0Delta > 0) {
      IERC20Minimal(IAlgebraPool(msg.sender).token0()).transferFrom(sender, msg.sender, uint256(amount0Delta));
    } else if (amount1Delta > 0) {
      IERC20Minimal(IAlgebraPool(msg.sender).token1()).transferFrom(sender, msg.sender, uint256(amount1Delta));
    }
  }
}
pragma solidity =0.7.6;
contract BitMathEchidnaTest {
  function mostSignificantBitInvariant(uint256 input) external pure {
    require(input > 0);
    uint8 msb = TickTable.getMostSignificantBit(input);
    assert(input >= (uint256(2)**msb));
    assert(msb == 255 || input < uint256(2)**(msb + 1));
  }
  function leastSignificantBitInvariant(uint256 input) external pure {
    require(input > 0);
    uint8 lsb = TickTable.getSingleSignificantBit(-input & input);
    assert(input & (uint256(2)**lsb) != 0);
    assert(input & (uint256(2)**lsb - 1) == 0);
  }
}
pragma solidity =0.7.6;
contract BitMathTest {
  function mostSignificantBit(uint256 x) external pure returns (uint8 r) {
    return TickTable.getMostSignificantBit(x);
  }
  function getGasCostOfMostSignificantBit(uint256 x) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TickTable.getMostSignificantBit(x);
    return gasBefore - gasleft();
  }
  function leastSignificantBit(uint256 x) external pure returns (uint8 r) {
    return TickTable.getSingleSignificantBit(-x & x);
  }
  function getGasCostOfLeastSignificantBit(uint256 x) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TickTable.getSingleSignificantBit(-x & x);
    return gasBefore - gasleft();
  }
}
pragma solidity =0.7.6;
contract DataStorageTest {
  uint256 private constant UINT16_MODULO = 65536;
  using DataStorage for DataStorage.Timepoint[UINT16_MODULO];
  DataStorage.Timepoint[UINT16_MODULO] public timepoints;
  uint32 public time;
  int24 public tick;
  uint128 public liquidity;
  uint16 public index;
  struct InitializeParams {
    uint32 time;
    int24 tick;
    uint128 liquidity;
  }
  function initialize(InitializeParams calldata params) external {
    time = params.time;
    tick = params.tick;
    liquidity = params.liquidity;
    timepoints.initialize(params.time, tick);
  }
  function advanceTime(uint32 by) public {
    time += by;
  }
  struct UpdateParams {
    uint32 advanceTimeBy;
    int24 tick;
    uint128 liquidity;
  }
  function update(UpdateParams calldata params) external {
    advanceTime(params.advanceTimeBy);
    index = timepoints.write(index, time, tick, liquidity, 0); 
    tick = params.tick;
    liquidity = params.liquidity;
  }
  function batchUpdate(UpdateParams[] calldata params) external {
    int24 _tick = tick;
    uint128 _liquidity = liquidity;
    uint16 _index = index;
    uint32 _time = time;
    for (uint256 i = 0; i < params.length; i++) {
      _time += params[i].advanceTimeBy;
      _index = timepoints.write(_index, _time, _tick, _liquidity, 0);
      _tick = params[i].tick;
      _liquidity = params[i].liquidity;
    }
    tick = _tick;
    liquidity = _liquidity;
    index = _index;
    time = _time;
  }
  function getTimepoints(uint32[] calldata secondsAgos)
    external
    view
    returns (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives,
      uint112[] memory volatilityCumulatives,
      uint256[] memory volumePerAvgLiquiditys
    )
  {
    return timepoints.getTimepoints(time, secondsAgos, tick, index, liquidity);
  }
  function getGasCostOfGetPoints(uint32[] calldata secondsAgos) external view returns (uint256) {
    (uint32 _time, int24 _tick, uint128 _liquidity, uint16 _index) = (time, tick, liquidity, index);
    uint256 gasBefore = gasleft();
    timepoints.getTimepoints(_time, secondsAgos, _tick, _index, _liquidity);
    return gasBefore - gasleft();
  }
  function volatilityOnRange(
    uint32 dt,
    int24 tick0,
    int24 tick1,
    int24 avgTick0,
    int24 avgTick1
  ) external pure returns (uint256) {
    return DataStorage._volatilityOnRange(dt, tick0, tick1, avgTick0, avgTick1);
  }
  function getAverageTick() external view returns (int256) {
    uint32 lastTimestamp = timepoints[index].blockTimestamp;
    int56 lastTickCumulative = timepoints[index].tickCumulative;
    uint16 oldestIndex;
    if (timepoints[index + 1].initialized) {
      oldestIndex = index + 1;
    }
    (uint32 _time, int24 _tick, uint16 _index) = (time, tick, index);
    return timepoints._getAverageTick(_time, _tick, _index, oldestIndex, lastTimestamp, lastTickCumulative);
  }
  function window() external pure returns (uint256) {
    return DataStorage.WINDOW;
  }
}
pragma solidity =0.7.6;
contract DataStorageEchidnaTest {
  DataStorageTest private dataStorage;
  bool private initialized;
  uint32 private timePassed;
  constructor() {
    dataStorage = new DataStorageTest();
  }
  function initialize(
    uint32 time,
    int24 tick,
    uint128 liquidity
  ) external {
    require(tick % 60 == 0);
    dataStorage.initialize(DataStorageTest.InitializeParams({time: time, tick: tick, liquidity: liquidity}));
    initialized = true;
  }
  function limitTimePassed(uint32 by) private {
    require(timePassed + by >= timePassed);
    timePassed += by;
  }
  function advanceTime(uint32 by) public {
    limitTimePassed(by);
    dataStorage.advanceTime(by);
  }
  function update(
    uint32 advanceTimeBy,
    int24 tick,
    uint128 liquidity
  ) external {
    require(initialized);
    limitTimePassed(advanceTimeBy);
    dataStorage.update(DataStorageTest.UpdateParams({advanceTimeBy: advanceTimeBy, tick: tick, liquidity: liquidity}));
  }
  function checkTimeWeightedResultAssertions(uint32 secondsAgo0, uint32 secondsAgo1) private view {
    require(secondsAgo0 != secondsAgo1);
    require(initialized);
    if (secondsAgo0 < secondsAgo1) (secondsAgo0, secondsAgo1) = (secondsAgo1, secondsAgo0);
    uint32 timeElapsed = secondsAgo0 - secondsAgo1;
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = secondsAgo0;
    secondsAgos[1] = secondsAgo1;
    (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulatives, , ) = dataStorage.getTimepoints(secondsAgos);
    int56 timeWeightedTick = (tickCumulatives[1] - tickCumulatives[0]) / timeElapsed;
    uint256 timeWeightedHarmonicMeanLiquidity = (uint256(timeElapsed) * type(uint160).max) /
      (uint256(secondsPerLiquidityCumulatives[1] - secondsPerLiquidityCumulatives[0]) << 32);
    assert(timeWeightedHarmonicMeanLiquidity <= type(uint128).max);
    assert(timeWeightedTick <= type(int24).max);
    assert(timeWeightedTick >= type(int24).min);
  }
  function echidna_indexAlwaysLtCardinality() external view returns (bool) {
    return dataStorage.index() < 65536 || !initialized;
  }
  function echidna_avgTickNotOverflows() external view returns (bool) {
    int256 res = dataStorage.getAverageTick();
    return (res <= type(int24).max && res >= type(int24).min);
  }
  function echidna_canAlwaysGetPoints0IfInitialized() external view returns (bool) {
    if (!initialized) {
      return true;
    }
    uint32[] memory arr = new uint32[](1);
    arr[0] = 0;
    (bool success, ) = address(dataStorage).staticcall(abi.encodeWithSelector(DataStorageTest.getTimepoints.selector, arr));
    return success;
  }
  function checkVolatilityOnRangeNotOverflowUint88(
    uint32 dt,
    int24 tick0,
    int24 tick1,
    int24 avgTick0,
    int24 avgTick1
  ) external view {
    uint256 res = dataStorage.volatilityOnRange(dt, tick0, tick1, avgTick0, avgTick1);
    assert(res <= type(uint88).max);
  }
  function checkTwoAdjacentTimepointsTickCumulativeModTimeElapsedAlways0(uint16 index) external view {
    require(index < 65536 && index != (dataStorage.index() + 1) % 65536);
    (bool initialized0, uint32 blockTimestamp0, int56 tickCumulative0, , , , ) = dataStorage.timepoints(index == 0 ? 65536 - 1 : index - 1);
    (bool initialized1, uint32 blockTimestamp1, int56 tickCumulative1, , , , ) = dataStorage.timepoints(index);
    require(initialized0);
    require(initialized1);
    uint32 timeElapsed = blockTimestamp1 - blockTimestamp0;
    assert(timeElapsed > 0);
    assert((tickCumulative1 - tickCumulative0) % timeElapsed == 0);
  }
  function checkTimeWeightedAveragesAlwaysFitsType(uint32 secondsAgo) external view {
    require(initialized);
    require(secondsAgo > 0);
    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = secondsAgo;
    secondsAgos[1] = 0;
    (
      int56[] memory tickCumulatives,
      uint160[] memory secondsPerLiquidityCumulatives, 
      ,
    ) = dataStorage.getTimepoints(secondsAgos);
    int56 numerator = tickCumulatives[1] - tickCumulatives[0];
    int56 timeWeightedTick = numerator / int56(secondsAgo);
    if (numerator < 0 && numerator % int56(secondsAgo) != 0) {
      timeWeightedTick--;
    }
    assert(timeWeightedTick <= type(int24).max && timeWeightedTick >= type(int24).min);
    uint256 timeWeightedHarmonicMeanLiquidity = (uint256(secondsAgo) * type(uint160).max) /
      (uint256(secondsPerLiquidityCumulatives[1] - secondsPerLiquidityCumulatives[0]) << 32);
    assert(timeWeightedHarmonicMeanLiquidity <= type(uint128).max);
  }
}
pragma solidity =0.7.6;
contract FullMathEchidnaTest {
  function checkMulDivRounding(
    uint256 x,
    uint256 y,
    uint256 d
  ) external pure {
    require(d > 0);
    uint256 ceiled = FullMath.mulDivRoundingUp(x, y, d);
    uint256 floored = FullMath.mulDiv(x, y, d);
    if (mulmod(x, y, d) > 0) {
      assert(ceiled - floored == 1);
    } else {
      assert(ceiled == floored);
    }
  }
  function checkMulDiv(
    uint256 x,
    uint256 y,
    uint256 d
  ) external pure {
    require(d > 0);
    uint256 z = FullMath.mulDiv(x, y, d);
    if (x == 0 || y == 0) {
      assert(z == 0);
      return;
    }
    uint256 x2 = FullMath.mulDiv(z, d, y);
    uint256 y2 = FullMath.mulDiv(z, d, x);
    assert(x2 <= x);
    assert(y2 <= y);
    assert(x - x2 < d);
    assert(y - y2 < d);
  }
  function checkMulDivRoundingUp(
    uint256 x,
    uint256 y,
    uint256 d
  ) external pure {
    require(d > 0);
    uint256 z = FullMath.mulDivRoundingUp(x, y, d);
    if (x == 0 || y == 0) {
      assert(z == 0);
      return;
    }
    uint256 x2 = FullMath.mulDiv(z, d, y);
    uint256 y2 = FullMath.mulDiv(z, d, x);
    assert(x2 >= x);
    assert(y2 >= y);
    assert(x2 - x < d);
    assert(y2 - y < d);
  }
}
pragma solidity =0.7.6;
contract FullMathTest {
  function mulDiv(
    uint256 x,
    uint256 y,
    uint256 z
  ) external pure returns (uint256) {
    return FullMath.mulDiv(x, y, z);
  }
  function mulDivRoundingUp(
    uint256 x,
    uint256 y,
    uint256 z
  ) external pure returns (uint256) {
    return FullMath.mulDivRoundingUp(x, y, z);
  }
}
pragma solidity >=0.5.0;
library LiquidityAmounts {
  function toUint128(uint256 x) private pure returns (uint128 y) {
    require((y = uint128(x)) == x);
  }
  function getLiquidityForAmount0(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    uint256 intermediate = FullMath.mulDiv(sqrtRatioAX96, sqrtRatioBX96, Constants.Q96);
    return toUint128(FullMath.mulDiv(amount0, intermediate, sqrtRatioBX96 - sqrtRatioAX96));
  }
  function getLiquidityForAmount1(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount1
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    return toUint128(FullMath.mulDiv(amount1, Constants.Q96, sqrtRatioBX96 - sqrtRatioAX96));
  }
  function getLiquidityForAmounts(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint256 amount0,
    uint256 amount1
  ) internal pure returns (uint128 liquidity) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    if (sqrtRatioX96 <= sqrtRatioAX96) {
      liquidity = getLiquidityForAmount0(sqrtRatioAX96, sqrtRatioBX96, amount0);
    } else if (sqrtRatioX96 < sqrtRatioBX96) {
      uint128 liquidity0 = getLiquidityForAmount0(sqrtRatioX96, sqrtRatioBX96, amount0);
      uint128 liquidity1 = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioX96, amount1);
      liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
    } else {
      liquidity = getLiquidityForAmount1(sqrtRatioAX96, sqrtRatioBX96, amount1);
    }
  }
  function getAmount0ForLiquidity(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint128 liquidity
  ) internal pure returns (uint256 amount0) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    return FullMath.mulDiv(uint256(liquidity) << Constants.RESOLUTION, sqrtRatioBX96 - sqrtRatioAX96, sqrtRatioBX96) / sqrtRatioAX96;
  }
  function getAmount1ForLiquidity(
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint128 liquidity
  ) internal pure returns (uint256 amount1) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    return FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, Constants.Q96);
  }
  function getAmountsForLiquidity(
    uint160 sqrtRatioX96,
    uint160 sqrtRatioAX96,
    uint160 sqrtRatioBX96,
    uint128 liquidity
  ) internal pure returns (uint256 amount0, uint256 amount1) {
    if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);
    if (sqrtRatioX96 <= sqrtRatioAX96) {
      amount0 = getAmount0ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
    } else if (sqrtRatioX96 < sqrtRatioBX96) {
      amount0 = getAmount0ForLiquidity(sqrtRatioX96, sqrtRatioBX96, liquidity);
      amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioX96, liquidity);
    } else {
      amount1 = getAmount1ForLiquidity(sqrtRatioAX96, sqrtRatioBX96, liquidity);
    }
  }
}
pragma solidity =0.7.6;
contract LiquidityMathTest {
  function addDelta(uint128 x, int128 y) external pure returns (uint128 z) {
    return LiquidityMath.addDelta(x, y);
  }
  function getGasCostOfAddDelta(uint128 x, int128 y) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    LiquidityMath.addDelta(x, y);
    return gasBefore - gasleft();
  }
}
pragma solidity =0.7.6;
contract LowGasSafeMathEchidnaTest {
  function checkAdd(uint256 x, uint256 y) external pure {
    uint256 z = LowGasSafeMath.add(x, y);
    assert(z == x + y);
    assert(z >= x && z >= y);
  }
  function checkSub(uint256 x, uint256 y) external pure {
    uint256 z = LowGasSafeMath.sub(x, y);
    assert(z == x - y);
    assert(z <= x);
  }
  function checkMul(uint256 x, uint256 y) external pure {
    uint256 z = LowGasSafeMath.mul(x, y);
    assert(z == x * y);
    assert(x == 0 || y == 0 || (z >= x && z >= y));
  }
  function checkAddi(int256 x, int256 y) external pure {
    int256 z = LowGasSafeMath.add(x, y);
    assert(z == x + y);
    assert(y < 0 ? z < x : z >= x);
  }
  function checkSubi(int256 x, int256 y) external pure {
    int256 z = LowGasSafeMath.sub(x, y);
    assert(z == x - y);
    assert(y < 0 ? z > x : z <= x);
  }
}
pragma solidity =0.7.6;
contract MockTimeAlgebraPool is AlgebraPool {
  uint256 public time = 1601906400;
  function setTotalFeeGrowth0Token(uint256 _totalFeeGrowth0Token) external {
    totalFeeGrowth0Token = _totalFeeGrowth0Token;
  }
  function setTotalFeeGrowth1Token(uint256 _totalFeeGrowth1Token) external {
    totalFeeGrowth1Token = _totalFeeGrowth1Token;
  }
  function advanceTime(uint256 by) external {
    time += by;
  }
  function _blockTimestamp() internal view override returns (uint32) {
    return uint32(time);
  }
  function checkBlockTimestamp() external view returns (bool) {
    require(super._blockTimestamp() == uint32(block.timestamp));
    return true;
  }
  function getAverages() external view returns (uint112 TWVolatilityAverage, uint256 TWVolumePerLiqAverage) {
    (TWVolatilityAverage, TWVolumePerLiqAverage) = IDataStorageOperator(dataStorageOperator).getAverages(
      _blockTimestamp(),
      globalState.fee,
      globalState.timepointIndex,
      liquidity
    );
  }
  function getPrevTick() external view returns (int24 tick, int24 currentTick) {
    if (globalState.timepointIndex > 2) {
      (, uint32 lastTsmp, int56 tickCum, , , , ) = IDataStorageOperator(dataStorageOperator).timepoints(globalState.timepointIndex);
      (, uint32 plastTsmp, int56 ptickCum, , , , ) = IDataStorageOperator(dataStorageOperator).timepoints(globalState.timepointIndex - 1);
      tick = int24((tickCum - ptickCum) / (lastTsmp - plastTsmp));
    }
    currentTick = globalState.tick;
  }
  function getFee() external view returns (uint16 fee) {
    return IDataStorageOperator(dataStorageOperator).getFee(_blockTimestamp(), globalState.tick, globalState.timepointIndex, liquidity);
  }
  function getKeyForPosition(
    address owner,
    int24 bottomTick,
    int24 topTick
  ) external pure returns (bytes32 key) {
    assembly {
      key := or(shl(24, or(shl(24, owner), and(bottomTick, 0xFFFFFF))), and(topTick, 0xFFFFFF))
    }
  }
}
pragma solidity =0.7.6;
contract MockTimeAlgebraPoolDeployer {
  struct Parameters {
    address dataStorage;
    address factory;
    address token0;
    address token1;
  }
  Parameters public parameters;
  event PoolDeployed(address pool);
  AdaptiveFee.Configuration baseFeeConfiguration =
    AdaptiveFee.Configuration(
      3000 - Constants.BASE_FEE, 
      15000 - 3000, 
      360, 
      60000, 
      59, 
      8500, 
      0, 
      10, 
      Constants.BASE_FEE 
    );
  function deployMock(
    address factory,
    address token0,
    address token1
  ) external returns (address pool) {
    bytes32 initCodeHash = keccak256(type(MockTimeAlgebraPool).creationCode);
    DataStorageOperator dataStorage = (new DataStorageOperator(computeAddress(initCodeHash, token0, token1)));
    dataStorage.changeFeeConfiguration(baseFeeConfiguration);
    parameters = Parameters({dataStorage: address(dataStorage), factory: factory, token0: token0, token1: token1});
    pool = address(new MockTimeAlgebraPool{salt: keccak256(abi.encode(token0, token1))}());
    emit PoolDeployed(pool);
  }
  function computeAddress(
    bytes32 initCodeHash,
    address token0,
    address token1
  ) internal view returns (address pool) {
    pool = address(uint256(keccak256(abi.encodePacked(hex'ff', address(this), keccak256(abi.encode(token0, token1)), initCodeHash))));
  }
}
pragma solidity =0.7.6;
contract MockTimeVirtualPool is IAlgebraVirtualPool {
  uint32 public timestamp;
  bool private isExist = true;
  bool private isStarted = true;
  int24 public currentTick;
  function setIsExist(bool _isExist) external {
    isExist = _isExist;
  }
  function setIsStarted(bool _isStarted) external {
    isStarted = _isStarted;
  }
  function increaseCumulative(uint32 currentTimestamp) external override returns (Status) {
    if (!isExist) return Status.NOT_EXIST;
    if (!isStarted) return Status.NOT_STARTED;
    timestamp = currentTimestamp;
    return Status.ACTIVE;
  }
  function cross(int24 nextTick, bool zeroToOne) external override {
    zeroToOne;
    require(isExist, 'Virtual pool not exist');
    currentTick = nextTick;
  }
}
pragma solidity =0.7.6;
contract PriceMovementMathEchidnaTest {
  function checkmovePriceTowardsTargetInvariants(
    uint160 sqrtPriceRaw,
    uint160 sqrtPriceTargetRaw,
    uint128 liquidity,
    int256 amountRemaining,
    uint16 feePips
  ) external pure {
    require(sqrtPriceRaw > 0);
    require(sqrtPriceTargetRaw > 0);
    require(feePips > 0);
    require(feePips < 1e6);
    (uint160 sqrtQ, uint256 amountIn, uint256 amountOut, uint256 feeAmount) = PriceMovementMath.movePriceTowardsTarget(
      sqrtPriceTargetRaw <= sqrtPriceRaw,
      sqrtPriceRaw,
      sqrtPriceTargetRaw,
      liquidity,
      amountRemaining,
      feePips
    );
    assert(amountIn <= type(uint256).max - feeAmount);
    if (amountRemaining < 0) {
      assert(amountOut <= uint256(-amountRemaining));
    } else {
      assert(amountIn + feeAmount <= uint256(amountRemaining));
    }
    if (sqrtPriceRaw == sqrtPriceTargetRaw) {
      assert(amountIn == 0);
      assert(amountOut == 0);
      assert(feeAmount == 0);
      assert(sqrtQ == sqrtPriceTargetRaw);
    }
    if (sqrtQ != sqrtPriceTargetRaw) {
      if (amountRemaining < 0) assert(amountOut == uint256(-amountRemaining));
      else assert(amountIn + feeAmount == uint256(amountRemaining));
    }
    if (sqrtPriceTargetRaw <= sqrtPriceRaw) {
      assert(sqrtQ <= sqrtPriceRaw);
      assert(sqrtQ >= sqrtPriceTargetRaw);
    } else {
      assert(sqrtQ >= sqrtPriceRaw);
      assert(sqrtQ <= sqrtPriceTargetRaw);
    }
  }
}
pragma solidity =0.7.6;
contract PriceMovementMathTest {
  function movePriceTowardsTarget(
    uint160 sqrtP,
    uint160 sqrtPTarget,
    uint128 liquidity,
    int256 amountRemaining,
    uint16 feePips
  )
    external
    pure
    returns (
      uint160 sqrtQ,
      uint256 amountIn,
      uint256 amountOut,
      uint256 feeAmount
    )
  {
    return PriceMovementMath.movePriceTowardsTarget(sqrtPTarget < sqrtP, sqrtP, sqrtPTarget, liquidity, amountRemaining, feePips);
  }
  function getGasCostOfmovePriceTowardsTarget(
    uint160 sqrtP,
    uint160 sqrtPTarget,
    uint128 liquidity,
    int256 amountRemaining,
    uint16 feePips
  ) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    PriceMovementMath.movePriceTowardsTarget(sqrtPTarget < sqrtP, sqrtP, sqrtPTarget, liquidity, amountRemaining, feePips);
    return gasBefore - gasleft();
  }
}
pragma solidity =0.7.6;
contract SafeMathTest {
  function add(uint256 x, uint256 y) external pure returns (uint256 z) {
    return LowGasSafeMath.add(x, y);
  }
  function sub(uint256 x, uint256 y) external pure returns (uint256 z) {
    return LowGasSafeMath.sub(x, y);
  }
  function mul(uint256 x, uint256 y) external pure returns (uint256 z) {
    return LowGasSafeMath.mul(x, y);
  }
  function addInt(int256 x, int256 y) external pure returns (int256 z) {
    return LowGasSafeMath.add(x, y);
  }
  function subInt(int256 x, int256 y) external pure returns (int256 z) {
    return LowGasSafeMath.sub(x, y);
  }
  function add128(uint128 x, uint128 y) external pure returns (uint128 z) {
    return LowGasSafeMath.add128(x, y);
  }
  function toUint160(uint256 y) external pure returns (uint160 z) {
    return SafeCast.toUint160(y);
  }
  function toInt128(int256 y) external pure returns (int128 z) {
    return SafeCast.toInt128(y);
  }
  function toInt256(uint256 y) external pure returns (int256 z) {
    return SafeCast.toInt256(y);
  }
}
pragma solidity =0.7.6;
contract SimulationTimeAlgebraPool is AlgebraPool {
  uint256 public time = 1601906400;
  function advanceTime(uint256 by) external {
    time += by;
  }
  function _blockTimestamp() internal view override returns (uint32) {
    return uint32(time);
  }
  function getAverages() external view returns (uint112 TWVolatilityAverage, uint256 TWVolumePerLiqAverage) {
    (TWVolatilityAverage, TWVolumePerLiqAverage) = IDataStorageOperator(dataStorageOperator).getAverages(
      _blockTimestamp(),
      globalState.fee,
      globalState.timepointIndex,
      liquidity
    );
  }
}
pragma solidity =0.7.6;
contract SimulationTimeFactory is IAlgebraFactory {
  address public override owner;
  address public immutable override poolDeployer;
  address public override farmingAddress;
  address public override vaultAddress;
  AdaptiveFee.Configuration public baseFeeConfiguration =
    AdaptiveFee.Configuration(
      3000 - Constants.BASE_FEE, 
      15000 - 3000, 
      360, 
      60000, 
      59, 
      8500, 
      0, 
      10, 
      Constants.BASE_FEE 
    );
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  mapping(address => mapping(address => address)) public override poolByPair;
  constructor(address _poolDeployer, address _vaultAddress) {
    owner = msg.sender;
    emit Owner(msg.sender);
    poolDeployer = _poolDeployer;
    vaultAddress = _vaultAddress;
  }
  function createPool(address tokenA, address tokenB) external override returns (address pool) {
    require(tokenA != tokenB);
    (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    require(token0 != address(0));
    require(poolByPair[token0][token1] == address(0));
    IDataStorageOperator dataStorage = new DataStorageOperator(computeAddress(token0, token1));
    dataStorage.changeFeeConfiguration(baseFeeConfiguration);
    pool = IAlgebraPoolDeployer(poolDeployer).deploy(address(dataStorage), address(this), token0, token1);
    poolByPair[token0][token1] = pool; 
    poolByPair[token1][token0] = pool;
    emit Pool(token0, token1, pool);
  }
  function setOwner(address _owner) external override onlyOwner {
    require(owner != _owner);
    emit Owner(_owner);
    owner = _owner;
  }
  function setFarmingAddress(address _farmingAddress) external override onlyOwner {
    require(farmingAddress != _farmingAddress);
    emit FarmingAddress(_farmingAddress);
    farmingAddress = _farmingAddress;
  }
  function setVaultAddress(address _vaultAddress) external override onlyOwner {
    require(vaultAddress != _vaultAddress);
    emit VaultAddress(_vaultAddress);
    vaultAddress = _vaultAddress;
  }
  function setBaseFeeConfiguration(
    uint16 alpha1,
    uint16 alpha2,
    uint32 beta1,
    uint32 beta2,
    uint16 gamma1,
    uint16 gamma2,
    uint32 volumeBeta,
    uint16 volumeGamma,
    uint16 baseFee
  ) external override onlyOwner {
    require(uint256(alpha1) + uint256(alpha2) + uint256(baseFee) <= type(uint16).max, 'Max fee exceeded');
    require(gamma1 != 0 && gamma2 != 0 && volumeGamma != 0, 'Gammas must be > 0');
    baseFeeConfiguration = AdaptiveFee.Configuration(alpha1, alpha2, beta1, beta2, gamma1, gamma2, volumeBeta, volumeGamma, baseFee);
    emit FeeConfiguration(alpha1, alpha2, beta1, beta2, gamma1, gamma2, volumeBeta, volumeGamma, baseFee);
  }
  bytes32 internal constant POOL_INIT_CODE_HASH = 0x900bf8d45a06958144a51da8749d15e2a339e87243bd50bc88d46815c9ec888d;
  function computeAddress(address token0, address token1) internal view returns (address pool) {
    pool = address(uint256(keccak256(abi.encodePacked(hex'ff', poolDeployer, keccak256(abi.encode(token0, token1)), POOL_INIT_CODE_HASH))));
  }
}
pragma solidity =0.7.6;
contract SimulationTimePoolDeployer is IAlgebraPoolDeployer {
  struct Parameters {
    address dataStorage;
    address factory;
    address token0;
    address token1;
  }
  Parameters public override parameters;
  address private factory;
  address private owner;
  modifier onlyFactory() {
    require(msg.sender == factory);
    _;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  constructor() {
    owner = msg.sender;
  }
  function setFactory(address _factory) external override onlyOwner {
    require(_factory != address(0));
    require(factory == address(0));
    emit Factory(_factory);
    factory = _factory;
  }
  function deploy(
    address dataStorage,
    address _factory,
    address token0,
    address token1
  ) external override onlyFactory returns (address pool) {
    parameters = Parameters({dataStorage: dataStorage, factory: _factory, token0: token0, token1: token1});
    pool = address(new SimulationTimeAlgebraPool{salt: keccak256(abi.encode(token0, token1))}());
  }
}
pragma solidity =0.7.6;
contract TestAlgebraCallee is IAlgebraMintCallback, IAlgebraSwapCallback, IAlgebraFlashCallback {
  using SafeCast for uint256;
  function swapExact0For1(
    address pool,
    uint256 amount0In,
    address recipient,
    uint160 limitSqrtPrice
  ) external {
    IAlgebraPool(pool).swap(recipient, true, amount0In.toInt256(), limitSqrtPrice, abi.encode(msg.sender));
  }
  function swapExact0For1SupportingFee(
    address pool,
    uint256 amount0In,
    address recipient,
    uint160 limitSqrtPrice
  ) external {
    IAlgebraPool(pool).swapSupportingFeeOnInputTokens(msg.sender, recipient, true, amount0In.toInt256(), limitSqrtPrice, abi.encode(msg.sender));
  }
  function swap0ForExact1(
    address pool,
    uint256 amount1Out,
    address recipient,
    uint160 limitSqrtPrice
  ) external {
    IAlgebraPool(pool).swap(recipient, true, -amount1Out.toInt256(), limitSqrtPrice, abi.encode(msg.sender));
  }
  function swapExact1For0(
    address pool,
    uint256 amount1In,
    address recipient,
    uint160 limitSqrtPrice
  ) external {
    IAlgebraPool(pool).swap(recipient, false, amount1In.toInt256(), limitSqrtPrice, abi.encode(msg.sender));
  }
  function swapExact1For0SupportingFee(
    address pool,
    uint256 amount1In,
    address recipient,
    uint160 limitSqrtPrice
  ) external {
    IAlgebraPool(pool).swapSupportingFeeOnInputTokens(msg.sender, recipient, false, amount1In.toInt256(), limitSqrtPrice, abi.encode(msg.sender));
  }
  function swap1ForExact0(
    address pool,
    uint256 amount0Out,
    address recipient,
    uint160 limitSqrtPrice
  ) external {
    IAlgebraPool(pool).swap(recipient, false, -amount0Out.toInt256(), limitSqrtPrice, abi.encode(msg.sender));
  }
  function swapToLowerSqrtPrice(
    address pool,
    uint160 price,
    address recipient
  ) external {
    IAlgebraPool(pool).swap(recipient, true, type(int256).max, price, abi.encode(msg.sender));
  }
  function swapToHigherSqrtPrice(
    address pool,
    uint160 price,
    address recipient
  ) external {
    IAlgebraPool(pool).swap(recipient, false, type(int256).max, price, abi.encode(msg.sender));
  }
  event SwapCallback(int256 amount0Delta, int256 amount1Delta);
  function algebraSwapCallback(
    int256 amount0Delta,
    int256 amount1Delta,
    bytes calldata data
  ) external override {
    address sender = abi.decode(data, (address));
    emit SwapCallback(amount0Delta, amount1Delta);
    if (amount0Delta > 0) {
      IERC20Minimal(IAlgebraPool(msg.sender).token0()).transferFrom(sender, msg.sender, uint256(amount0Delta));
    } else if (amount1Delta > 0) {
      IERC20Minimal(IAlgebraPool(msg.sender).token1()).transferFrom(sender, msg.sender, uint256(amount1Delta));
    } else {
      assert(amount0Delta == 0 && amount1Delta == 0);
    }
  }
  event MintResult(uint256 amount0Owed, uint256 amount1Owed, uint256 resultLiquidity);
  function mint(
    address pool,
    address recipient,
    int24 bottomTick,
    int24 topTick,
    uint128 amount
  )
    external
    returns (
      uint256 amount0Owed,
      uint256 amount1Owed,
      uint256 resultLiquidity
    )
  {
    (amount0Owed, amount1Owed, resultLiquidity) = IAlgebraPool(pool).mint(msg.sender, recipient, bottomTick, topTick, amount, abi.encode(msg.sender));
    emit MintResult(amount0Owed, amount1Owed, resultLiquidity);
  }
  event MintCallback(uint256 amount0Owed, uint256 amount1Owed);
  function algebraMintCallback(
    uint256 amount0Owed,
    uint256 amount1Owed,
    bytes calldata data
  ) external override {
    address sender = abi.decode(data, (address));
    if (amount0Owed > 0) IERC20Minimal(IAlgebraPool(msg.sender).token0()).transferFrom(sender, msg.sender, amount0Owed);
    if (amount1Owed > 0) IERC20Minimal(IAlgebraPool(msg.sender).token1()).transferFrom(sender, msg.sender, amount1Owed);
    emit MintCallback(amount0Owed, amount1Owed);
  }
  event FlashCallback(uint256 fee0, uint256 fee1);
  function flash(
    address pool,
    address recipient,
    uint256 amount0,
    uint256 amount1,
    uint256 pay0,
    uint256 pay1
  ) external {
    IAlgebraPool(pool).flash(recipient, amount0, amount1, abi.encode(msg.sender, pay0, pay1));
  }
  function algebraFlashCallback(
    uint256 fee0,
    uint256 fee1,
    bytes calldata data
  ) external override {
    emit FlashCallback(fee0, fee1);
    (address sender, uint256 pay0, uint256 pay1) = abi.decode(data, (address, uint256, uint256));
    if (pay0 > 0) IERC20Minimal(IAlgebraPool(msg.sender).token0()).transferFrom(sender, msg.sender, pay0);
    if (pay1 > 0) IERC20Minimal(IAlgebraPool(msg.sender).token1()).transferFrom(sender, msg.sender, pay1);
  }
}
pragma solidity =0.7.6;
contract TestAlgebraReentrantCallee is IAlgebraSwapCallback {
  string private constant expectedReason = 'LOK';
  function swapToReenter(address pool) external {
    IAlgebraPool(pool).swap(address(0), false, 1, TickMath.MAX_SQRT_RATIO - 1, new bytes(0));
  }
  function algebraSwapCallback(
    int256,
    int256,
    bytes calldata
  ) external override {
    try IAlgebraPool(msg.sender).swap(address(0), false, 1, 0, new bytes(0)) {} catch Error(string memory reason) {
      require(keccak256(abi.encode(reason)) == keccak256(abi.encode(expectedReason)));
    }
    try IAlgebraPool(msg.sender).swapSupportingFeeOnInputTokens(address(0), address(0), false, 1, 0, new bytes(0)) {} catch Error(
      string memory reason
    ) {
      require(keccak256(abi.encode(reason)) == keccak256(abi.encode(expectedReason)));
    }
    try IAlgebraPool(msg.sender).mint(address(0), address(0), 0, 0, 0, new bytes(0)) {} catch Error(string memory reason) {
      require(keccak256(abi.encode(reason)) == keccak256(abi.encode(expectedReason)));
    }
    try IAlgebraPool(msg.sender).collect(address(0), 0, 0, 0, 0) {} catch Error(string memory reason) {
      require(keccak256(abi.encode(reason)) == keccak256(abi.encode(expectedReason)));
    }
    try IAlgebraPool(msg.sender).burn(0, 0, 0) {} catch Error(string memory reason) {
      require(keccak256(abi.encode(reason)) == keccak256(abi.encode(expectedReason)));
    }
    try IAlgebraPool(msg.sender).flash(address(0), 0, 0, new bytes(0)) {} catch Error(string memory reason) {
      require(keccak256(abi.encode(reason)) == keccak256(abi.encode(expectedReason)));
    }
    require(false, 'Unable to reenter');
  }
}
pragma solidity =0.7.6;
contract TestAlgebraRouter is IAlgebraSwapCallback {
  using SafeCast for uint256;
  function swapForExact0Multi(
    address recipient,
    address poolInput,
    address poolOutput,
    uint256 amount0Out
  ) external {
    address[] memory pools = new address[](1);
    pools[0] = poolInput;
    IAlgebraPool(poolOutput).swap(recipient, false, -amount0Out.toInt256(), TickMath.MAX_SQRT_RATIO - 1, abi.encode(pools, msg.sender));
  }
  function swapForExact1Multi(
    address recipient,
    address poolInput,
    address poolOutput,
    uint256 amount1Out
  ) external {
    address[] memory pools = new address[](1);
    pools[0] = poolInput;
    IAlgebraPool(poolOutput).swap(recipient, true, -amount1Out.toInt256(), TickMath.MIN_SQRT_RATIO + 1, abi.encode(pools, msg.sender));
  }
  event SwapCallback(int256 amount0Delta, int256 amount1Delta);
  function algebraSwapCallback(
    int256 amount0Delta,
    int256 amount1Delta,
    bytes calldata data
  ) public override {
    emit SwapCallback(amount0Delta, amount1Delta);
    (address[] memory pools, address payer) = abi.decode(data, (address[], address));
    if (pools.length == 1) {
      address tokenToBePaid = amount0Delta > 0 ? IAlgebraPool(msg.sender).token0() : IAlgebraPool(msg.sender).token1();
      int256 amountToBePaid = amount0Delta > 0 ? amount0Delta : amount1Delta;
      bool zeroToOne = tokenToBePaid == IAlgebraPool(pools[0]).token1();
      IAlgebraPool(pools[0]).swap(
        msg.sender,
        zeroToOne,
        -amountToBePaid,
        zeroToOne ? TickMath.MIN_SQRT_RATIO + 1 : TickMath.MAX_SQRT_RATIO - 1,
        abi.encode(new address[](0), payer)
      );
    } else {
      if (amount0Delta > 0) {
        IERC20Minimal(IAlgebraPool(msg.sender).token0()).transferFrom(payer, msg.sender, uint256(amount0Delta));
      } else {
        IERC20Minimal(IAlgebraPool(msg.sender).token1()).transferFrom(payer, msg.sender, uint256(amount1Delta));
      }
    }
  }
}
pragma solidity =0.7.6;
contract TestAlgebraSwapPay is IAlgebraSwapCallback, IAlgebraMintCallback {
  function swap(
    address pool,
    address recipient,
    bool zeroToOne,
    uint160 price,
    int256 amountSpecified,
    uint256 pay0,
    uint256 pay1
  ) external {
    IAlgebraPool(pool).swap(recipient, zeroToOne, amountSpecified, price, abi.encode(msg.sender, pay0, pay1));
  }
  function swapSupportingFee(
    address pool,
    address recipient,
    bool zeroToOne,
    uint160 price,
    int256 amountSpecified,
    uint256 pay0,
    uint256 pay1
  ) external {
    IAlgebraPool(pool).swapSupportingFeeOnInputTokens(msg.sender, recipient, zeroToOne, amountSpecified, price, abi.encode(msg.sender, pay0, pay1));
  }
  function algebraSwapCallback(
    int256,
    int256,
    bytes calldata data
  ) external override {
    (address sender, uint256 pay0, uint256 pay1) = abi.decode(data, (address, uint256, uint256));
    if (pay0 > 0) {
      IERC20Minimal(IAlgebraPool(msg.sender).token0()).transferFrom(sender, msg.sender, uint256(pay0));
    } else if (pay1 > 0) {
      IERC20Minimal(IAlgebraPool(msg.sender).token1()).transferFrom(sender, msg.sender, uint256(pay1));
    }
  }
  function mint(
    address pool,
    address recipient,
    int24 bottomTick,
    int24 topTick,
    uint128 amount,
    uint256 pay0,
    uint256 pay1
  )
    external
    returns (
      uint256 amount0Owed,
      uint256 amount1Owed,
      uint256 resultLiquidity
    )
  {
    (amount0Owed, amount1Owed, resultLiquidity) = IAlgebraPool(pool).mint(
      msg.sender,
      recipient,
      bottomTick,
      topTick,
      amount,
      abi.encode(msg.sender, pay0, pay1)
    );
  }
  function algebraMintCallback(
    uint256 amount0Owed,
    uint256 amount1Owed,
    bytes calldata data
  ) external override {
    (address sender, uint256 pay0, uint256 pay1) = abi.decode(data, (address, uint256, uint256));
    if (amount0Owed > 0) IERC20Minimal(IAlgebraPool(msg.sender).token0()).transferFrom(sender, msg.sender, pay0);
    if (amount1Owed > 0) IERC20Minimal(IAlgebraPool(msg.sender).token1()).transferFrom(sender, msg.sender, pay1);
  }
}
pragma solidity =0.7.6;
contract TestERC20 is IERC20Minimal {
  mapping(address => uint256) public override balanceOf;
  mapping(address => mapping(address => uint256)) public override allowance;
  constructor(uint256 amountToMint) {
    mint(msg.sender, amountToMint);
  }
  function mint(address to, uint256 amount) public {
    uint256 balanceNext = balanceOf[to] + amount;
    require(balanceNext >= amount, 'overflow balance');
    balanceOf[to] = balanceNext;
  }
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    uint256 balanceBefore = balanceOf[msg.sender];
    require(balanceBefore >= amount, 'insufficient balance');
    balanceOf[msg.sender] = balanceBefore - amount;
    uint256 balanceRecipient = balanceOf[recipient];
    require(balanceRecipient + amount >= balanceRecipient, 'recipient balance overflow');
    if (!isDeflationary) {
      balanceOf[recipient] = balanceRecipient + amount;
    } else {
      balanceOf[recipient] = balanceRecipient + (amount - (amount * 5) / 100);
    }
    emit Transfer(msg.sender, recipient, amount);
    return true;
  }
  function approve(address spender, uint256 amount) external override returns (bool) {
    allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }
  bool isDeflationary = false;
  function setDefl() external {
    isDeflationary = true;
  }
  function transferFrom(
    address sender,
    address recipient,
    uint256 amount
  ) external override returns (bool) {
    uint256 allowanceBefore = allowance[sender][msg.sender];
    require(allowanceBefore >= amount, 'allowance insufficient');
    allowance[sender][msg.sender] = allowanceBefore - amount;
    uint256 balanceRecipient = balanceOf[recipient];
    require(balanceRecipient + amount >= balanceRecipient, 'overflow balance recipient');
    if (!isDeflationary) {
      balanceOf[recipient] = balanceRecipient + amount;
    } else {
      balanceOf[recipient] = balanceRecipient + (amount - (amount * 5) / 100);
    }
    uint256 balanceSender = balanceOf[sender];
    require(balanceSender >= amount, 'underflow balance sender');
    balanceOf[sender] = balanceSender - amount;
    emit Transfer(sender, recipient, amount);
    return true;
  }
}
pragma solidity =0.7.6;
contract TickMathEchidnaTest {
  function checkGetSqrtRatioAtTickInvariants(int24 tick) external pure {
    uint160 ratio = TickMath.getSqrtRatioAtTick(tick);
    assert(TickMath.getSqrtRatioAtTick(tick - 1) < ratio && ratio < TickMath.getSqrtRatioAtTick(tick + 1));
    assert(ratio >= TickMath.MIN_SQRT_RATIO);
    assert(ratio <= TickMath.MAX_SQRT_RATIO);
  }
  function checkGetTickAtSqrtRatioInvariants(uint160 ratio) external pure {
    int24 tick = TickMath.getTickAtSqrtRatio(ratio);
    assert(ratio >= TickMath.getSqrtRatioAtTick(tick) && ratio < TickMath.getSqrtRatioAtTick(tick + 1));
    assert(tick >= TickMath.MIN_TICK);
    assert(tick < TickMath.MAX_TICK);
  }
}
pragma solidity =0.7.6;
contract TickMathTest {
  function getSqrtRatioAtTick(int24 tick) external pure returns (uint160) {
    return TickMath.getSqrtRatioAtTick(tick);
  }
  function getGasCostOfGetSqrtRatioAtTick(int24 tick) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TickMath.getSqrtRatioAtTick(tick);
    return gasBefore - gasleft();
  }
  function getTickAtSqrtRatio(uint160 price) external pure returns (int24) {
    return TickMath.getTickAtSqrtRatio(price);
  }
  function getGasCostOfGetTickAtSqrtRatio(uint160 price) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TickMath.getTickAtSqrtRatio(price);
    return gasBefore - gasleft();
  }
  function MIN_SQRT_RATIO() external pure returns (uint160) {
    return TickMath.MIN_SQRT_RATIO;
  }
  function MAX_SQRT_RATIO() external pure returns (uint160) {
    return TickMath.MAX_SQRT_RATIO;
  }
}
pragma solidity =0.7.6;
contract TickOverflowSafetyEchidnaTest {
  using TickManager for mapping(int24 => TickManager.Tick);
  int24 private constant MIN_TICK = -16;
  int24 private constant MAX_TICK = 16;
  uint128 private constant MAX_LIQUIDITY = type(uint128).max / 32;
  mapping(int24 => TickManager.Tick) private ticks;
  int24 private tick = 0;
  int256 totalLiquidity = 0;
  uint256 private totalFeeGrowth0Token = type(uint256).max / 2;
  uint256 private totalFeeGrowth1Token = type(uint256).max / 2;
  uint256 private totalGrowth0 = 0;
  uint256 private totalGrowth1 = 0;
  function increaseTotalFeeGrowth0Token(uint256 amount) external {
    require(totalGrowth0 + amount > totalGrowth0); 
    totalFeeGrowth0Token += amount; 
    totalGrowth0 += amount;
  }
  function increaseTotalFeeGrowth1Token(uint256 amount) external {
    require(totalGrowth1 + amount > totalGrowth1); 
    totalFeeGrowth1Token += amount; 
    totalGrowth1 += amount;
  }
  function setPosition(
    int24 bottomTick,
    int24 topTick,
    int128 liquidityDelta
  ) external {
    require(bottomTick > MIN_TICK);
    require(topTick < MAX_TICK);
    require(bottomTick < topTick);
    bool flippedLower = ticks.update(
      bottomTick,
      tick,
      liquidityDelta,
      totalFeeGrowth0Token,
      totalFeeGrowth1Token,
      0,
      0,
      uint32(block.timestamp),
      false
    );
    bool flippedUpper = ticks.update(topTick, tick, liquidityDelta, totalFeeGrowth0Token, totalFeeGrowth1Token, 0, 0, uint32(block.timestamp), true);
    if (flippedLower) {
      if (liquidityDelta < 0) {
        assert(ticks[bottomTick].liquidityTotal == 0);
        delete ticks[bottomTick];
      } else assert(ticks[bottomTick].liquidityTotal > 0);
    }
    if (flippedUpper) {
      if (liquidityDelta < 0) {
        assert(ticks[topTick].liquidityTotal == 0);
        delete ticks[topTick];
      } else assert(ticks[topTick].liquidityTotal > 0);
    }
    totalLiquidity += liquidityDelta;
    assert(totalLiquidity >= 0);
    if (totalLiquidity == 0) {
      totalGrowth0 = 0;
      totalGrowth1 = 0;
    }
  }
  function moveToTick(int24 target) external {
    require(target > MIN_TICK);
    require(target < MAX_TICK);
    while (tick != target) {
      if (tick < target) {
        if (ticks[tick + 1].liquidityTotal > 0) ticks.cross(tick + 1, totalFeeGrowth0Token, totalFeeGrowth1Token, 0, 0, uint32(block.timestamp));
        tick++;
      } else {
        if (ticks[tick].liquidityTotal > 0) ticks.cross(tick, totalFeeGrowth0Token, totalFeeGrowth1Token, 0, 0, uint32(block.timestamp));
        tick--;
      }
    }
  }
}
pragma solidity =0.7.6;
contract TickTableEchidnaTest {
  using TickTable for mapping(int16 => uint256);
  mapping(int16 => uint256) private bitmap;
  function isInitialized(int24 tick) private view returns (bool) {
    (int24 next, bool initialized) = bitmap.nextTickInTheSameRow(tick, true);
    return next == tick ? initialized : false;
  }
  function toggleTick(int24 tick) external {
    tick = (tick / 60);
    tick = tick * 60;
    require(tick >= -887272);
    require(tick <= 887272);
    require(tick % 60 == 0);
    bool before = isInitialized(tick);
    bitmap.toggleTick(tick);
    assert(isInitialized(tick) == !before);
  }
  function checkNextInitializedTickWithinOneWordInvariants(int24 tick, bool lte) external view {
    tick = (tick / 60);
    tick = tick * 60;
    require(tick % 60 == 0);
    require(tick >= -887272);
    require(tick <= 887272);
    (int24 next, bool initialized) = bitmap.nextTickInTheSameRow(tick, lte);
    if (lte) {
      assert(next <= tick);
      assert(tick - next < 256 * 60);
      for (int24 i = tick; i > next; i -= 60) {
        assert(!isInitialized(i));
      }
      assert(isInitialized(next) == initialized);
    } else {
      require(tick < 887272);
      assert(next > tick);
      assert(next - tick <= 256 * 60);
      for (int24 i = tick + 60; i < next; i += 60) {
        assert(!isInitialized(i));
      }
      assert(isInitialized(next) == initialized);
    }
  }
}
pragma solidity =0.7.6;
contract TickTableTest {
  using TickTable for mapping(int16 => uint256);
  mapping(int16 => uint256) public bitmap;
  function toggleTick(int24 tick) external {
    bitmap.toggleTick(tick);
  }
  function getGasCostOfFlipTick(int24 tick) external returns (uint256) {
    uint256 gasBefore = gasleft();
    bitmap.toggleTick(tick);
    return gasBefore - gasleft();
  }
  function nextTickInTheSameRow(int24 tick, bool lte) external view returns (int24 next, bool initialized) {
    return bitmap.nextTickInTheSameRow(tick, lte);
  }
  function getGasCostOfNextTickInTheSameRow(int24 tick, bool lte) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    bitmap.nextTickInTheSameRow(tick, lte);
    return gasBefore - gasleft();
  }
  function isInitialized(int24 tick) external view returns (bool) {
    (int24 next, bool initialized) = bitmap.nextTickInTheSameRow(tick, true);
    return next == tick ? initialized : false;
  }
}
pragma solidity =0.7.6;
contract TickTest {
  using TickManager for mapping(int24 => TickManager.Tick);
  mapping(int24 => TickManager.Tick) public ticks;
  function setTick(int24 tick, TickManager.Tick memory data) external {
    ticks[tick] = data;
  }
  function getInnerFeeGrowth(
    int24 bottomTick,
    int24 topTick,
    int24 currentTick,
    uint256 totalFeeGrowth0Token,
    uint256 totalFeeGrowth1Token
  ) external view returns (uint256 innerFeeGrowth0Token, uint256 innerFeeGrowth1Token) {
    return ticks.getInnerFeeGrowth(bottomTick, topTick, currentTick, totalFeeGrowth0Token, totalFeeGrowth1Token);
  }
  function update(
    int24 tick,
    int24 currentTick,
    int128 liquidityDelta,
    uint256 totalFeeGrowth0Token,
    uint256 totalFeeGrowth1Token,
    uint160 secondsPerLiquidityCumulative,
    int56 tickCumulative,
    uint32 time,
    bool upper
  ) external returns (bool flipped) {
    return
      ticks.update(
        tick,
        currentTick,
        liquidityDelta,
        totalFeeGrowth0Token,
        totalFeeGrowth1Token,
        secondsPerLiquidityCumulative,
        tickCumulative,
        time,
        upper
      );
  }
  function clear(int24 tick) external {
    delete ticks[tick];
  }
  function cross(
    int24 tick,
    uint256 totalFeeGrowth0Token,
    uint256 totalFeeGrowth1Token,
    uint160 secondsPerLiquidityCumulative,
    int56 tickCumulative,
    uint32 time
  ) external returns (int128 liquidityDelta) {
    return ticks.cross(tick, totalFeeGrowth0Token, totalFeeGrowth1Token, secondsPerLiquidityCumulative, tickCumulative, time);
  }
}
pragma solidity =0.7.6;
contract TokenDeltaMathEchidnaTest {
  function mulDivRoundingUpInvariants(
    uint256 x,
    uint256 y,
    uint256 z
  ) external pure {
    require(z > 0);
    uint256 notRoundedUp = FullMath.mulDiv(x, y, z);
    uint256 roundedUp = FullMath.mulDivRoundingUp(x, y, z);
    assert(roundedUp >= notRoundedUp);
    assert(roundedUp - notRoundedUp < 2);
    if (roundedUp - notRoundedUp == 1) {
      assert(mulmod(x, y, z) > 0);
    } else {
      assert(mulmod(x, y, z) == 0);
    }
  }
  function getNextSqrtPriceFromInputInvariants(
    uint160 sqrtP,
    uint128 liquidity,
    uint256 amountIn,
    bool zeroToOne
  ) external pure {
    uint160 sqrtQ = PriceMovementMath.getNewPriceAfterInput(sqrtP, liquidity, amountIn, zeroToOne);
    if (zeroToOne) {
      assert(sqrtQ <= sqrtP);
      assert(amountIn >= TokenDeltaMath.getToken0Delta(sqrtQ, sqrtP, liquidity, true));
    } else {
      assert(sqrtQ >= sqrtP);
      assert(amountIn >= TokenDeltaMath.getToken1Delta(sqrtP, sqrtQ, liquidity, true));
    }
  }
  function getNextSqrtPriceFromOutputInvariants(
    uint160 sqrtP,
    uint128 liquidity,
    uint256 amountOut,
    bool zeroToOne
  ) external pure {
    uint160 sqrtQ = PriceMovementMath.getNewPriceAfterOutput(sqrtP, liquidity, amountOut, zeroToOne);
    if (zeroToOne) {
      assert(sqrtQ <= sqrtP);
      assert(amountOut <= TokenDeltaMath.getToken1Delta(sqrtQ, sqrtP, liquidity, false));
    } else {
      assert(sqrtQ > 0); 
      assert(sqrtQ >= sqrtP);
      assert(amountOut <= TokenDeltaMath.getToken0Delta(sqrtP, sqrtQ, liquidity, false));
    }
  }
  function getNextSqrtPriceFromAmount0RoundingUpInvariants(
    uint160 sqrtPX96,
    uint128 liquidity,
    uint256 amount,
    bool add
  ) external pure {
    require(sqrtPX96 > 0);
    require(liquidity > 0);
    uint160 sqrtQX96;
    if (add) {
      sqrtQX96 = PriceMovementMath.getNewPriceAfterInput(sqrtPX96, liquidity, amount, true);
    } else {
      sqrtQX96 = PriceMovementMath.getNewPriceAfterOutput(sqrtPX96, liquidity, amount, false);
    }
    if (add) {
      assert(sqrtQX96 <= sqrtPX96);
    } else {
      assert(sqrtQX96 >= sqrtPX96);
    }
    if (amount == 0) {
      assert(sqrtPX96 == sqrtQX96);
    }
  }
  function getNextSqrtPriceFromAmount1RoundingDownInvariants(
    uint160 sqrtPX96,
    uint128 liquidity,
    uint256 amount,
    bool add
  ) external pure {
    require(sqrtPX96 > 0);
    require(liquidity > 0);
    uint160 sqrtQX96;
    if (add) {
      sqrtQX96 = PriceMovementMath.getNewPriceAfterInput(sqrtPX96, liquidity, amount, false);
    } else {
      sqrtQX96 = PriceMovementMath.getNewPriceAfterOutput(sqrtPX96, liquidity, amount, true);
    }
    if (add) {
      assert(sqrtQX96 >= sqrtPX96);
    } else {
      assert(sqrtQX96 <= sqrtPX96);
    }
    if (amount == 0) {
      assert(sqrtPX96 == sqrtQX96);
    }
  }
  function getToken0DeltaInvariants(
    uint160 sqrtP,
    uint160 sqrtQ,
    uint128 liquidity
  ) external pure {
    require(sqrtP > 0 && sqrtQ > 0);
    if (sqrtP < sqrtQ) (sqrtP, sqrtQ) = (sqrtQ, sqrtP);
    uint256 amount0Down = TokenDeltaMath.getToken0Delta(sqrtQ, sqrtP, liquidity, false);
    uint256 amount0Up = TokenDeltaMath.getToken0Delta(sqrtQ, sqrtP, liquidity, true);
    assert(amount0Down <= amount0Up);
    assert(amount0Up - amount0Down < 2);
  }
  function getToken0DeltaEquivalency(
    uint160 sqrtP,
    uint160 sqrtQ,
    uint128 liquidity,
    bool roundUp
  ) external pure {
    require(sqrtP >= sqrtQ);
    require(sqrtP > 0 && sqrtQ > 0);
    require((sqrtP * sqrtQ) / sqrtP == sqrtQ);
    uint256 numerator1 = uint256(liquidity) << Constants.RESOLUTION;
    uint256 numerator2 = sqrtP - sqrtQ;
    uint256 denominator = uint256(sqrtP) * sqrtQ;
    uint256 safeResult = roundUp
      ? FullMath.mulDivRoundingUp(numerator1, numerator2, denominator)
      : FullMath.mulDiv(numerator1, numerator2, denominator);
    uint256 fullResult = TokenDeltaMath.getToken0Delta(sqrtQ, sqrtP, liquidity, roundUp);
    assert(safeResult == fullResult);
  }
  function getToken1DeltaInvariants(
    uint160 sqrtP,
    uint160 sqrtQ,
    uint128 liquidity
  ) external pure {
    require(sqrtP > 0 && sqrtQ > 0);
    if (sqrtP > sqrtQ) (sqrtP, sqrtQ) = (sqrtQ, sqrtP);
    uint256 amount1Down = TokenDeltaMath.getToken1Delta(sqrtP, sqrtQ, liquidity, false);
    uint256 amount1Up = TokenDeltaMath.getToken1Delta(sqrtP, sqrtQ, liquidity, true);
    assert(amount1Down <= amount1Up);
    assert(amount1Up - amount1Down < 2);
  }
  function getToken0DeltaSignedInvariants(
    uint160 sqrtP,
    uint160 sqrtQ,
    int128 liquidity
  ) external pure {
    require(sqrtP > 0 && sqrtQ > 0);
    int256 amount0 = TokenDeltaMath.getToken0Delta(sqrtQ, sqrtP, liquidity);
    if (liquidity < 0) assert(amount0 <= 0);
    if (liquidity > 0) {
      if (sqrtP == sqrtQ) assert(amount0 == 0);
      else assert(amount0 > 0);
    }
    if (liquidity == 0) assert(amount0 == 0);
  }
  function getToken1DeltaSignedInvariants(
    uint160 sqrtP,
    uint160 sqrtQ,
    int128 liquidity
  ) external pure {
    require(sqrtP > 0 && sqrtQ > 0);
    int256 amount1 = TokenDeltaMath.getToken1Delta(sqrtP, sqrtQ, liquidity);
    if (liquidity < 0) assert(amount1 <= 0);
    if (liquidity > 0) {
      if (sqrtP == sqrtQ) assert(amount1 == 0);
      else assert(amount1 > 0);
    }
    if (liquidity == 0) assert(amount1 == 0);
  }
  function getOutOfRangeMintInvariants(
    uint160 sqrtA,
    uint160 sqrtB,
    int128 liquidity
  ) external pure {
    require(sqrtA > 0 && sqrtB > 0);
    require(liquidity > 0);
    int256 amount0 = TokenDeltaMath.getToken0Delta(sqrtA, sqrtB, liquidity);
    int256 amount1 = TokenDeltaMath.getToken1Delta(sqrtA, sqrtB, liquidity);
    if (sqrtA == sqrtB) {
      assert(amount0 == 0);
      assert(amount1 == 0);
    } else {
      assert(amount0 > 0);
      assert(amount1 > 0);
    }
  }
  function getInRangeMintInvariants(
    uint160 sqrtLower,
    uint160 sqrtCurrent,
    uint160 sqrtUpper,
    int128 liquidity
  ) external pure {
    require(sqrtLower > 0);
    require(sqrtLower < sqrtUpper);
    require(sqrtLower <= sqrtCurrent && sqrtCurrent <= sqrtUpper);
    require(liquidity > 0);
    int256 amount0 = TokenDeltaMath.getToken0Delta(sqrtCurrent, sqrtUpper, liquidity);
    int256 amount1 = TokenDeltaMath.getToken1Delta(sqrtLower, sqrtCurrent, liquidity);
    assert(amount0 > 0 || amount1 > 0);
  }
}
pragma solidity =0.7.6;
contract TokenDeltaMathTest {
  function getNewPriceAfterInput(
    uint160 sqrtP,
    uint128 liquidity,
    uint256 amountIn,
    bool zeroToOne
  ) external pure returns (uint160 sqrtQ) {
    return PriceMovementMath.getNewPriceAfterInput(sqrtP, liquidity, amountIn, zeroToOne);
  }
  function getGasCostOfGetNewPriceAfterInput(
    uint160 sqrtP,
    uint128 liquidity,
    uint256 amountIn,
    bool zeroToOne
  ) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    PriceMovementMath.getNewPriceAfterInput(sqrtP, liquidity, amountIn, zeroToOne);
    return gasBefore - gasleft();
  }
  function getNewPriceAfterOutput(
    uint160 sqrtP,
    uint128 liquidity,
    uint256 amountOut,
    bool zeroToOne
  ) external pure returns (uint160 sqrtQ) {
    return PriceMovementMath.getNewPriceAfterOutput(sqrtP, liquidity, amountOut, zeroToOne);
  }
  function getGasCostOfGetNewPriceAfterOutput(
    uint160 sqrtP,
    uint128 liquidity,
    uint256 amountOut,
    bool zeroToOne
  ) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    PriceMovementMath.getNewPriceAfterOutput(sqrtP, liquidity, amountOut, zeroToOne);
    return gasBefore - gasleft();
  }
  function getToken0Delta(
    uint160 sqrtLower,
    uint160 sqrtUpper,
    uint128 liquidity,
    bool roundUp
  ) external pure returns (uint256 amount0) {
    return TokenDeltaMath.getToken0Delta(sqrtLower, sqrtUpper, liquidity, roundUp);
  }
  function getToken1Delta(
    uint160 sqrtLower,
    uint160 sqrtUpper,
    uint128 liquidity,
    bool roundUp
  ) external pure returns (uint256 amount1) {
    return TokenDeltaMath.getToken1Delta(sqrtLower, sqrtUpper, liquidity, roundUp);
  }
  function getGasCostOfGetToken0Delta(
    uint160 sqrtLower,
    uint160 sqrtUpper,
    uint128 liquidity,
    bool roundUp
  ) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TokenDeltaMath.getToken0Delta(sqrtLower, sqrtUpper, liquidity, roundUp);
    return gasBefore - gasleft();
  }
  function getGasCostOfGetToken1Delta(
    uint160 sqrtLower,
    uint160 sqrtUpper,
    uint128 liquidity,
    bool roundUp
  ) external view returns (uint256) {
    uint256 gasBefore = gasleft();
    TokenDeltaMath.getToken1Delta(sqrtLower, sqrtUpper, liquidity, roundUp);
    return gasBefore - gasleft();
  }
}
pragma solidity =0.7.6;
contract UnsafeMathEchidnaTest {
  function checkDivRoundingUp(uint256 x, uint256 d) external pure {
    require(d > 0);
    uint256 z = FullMath.divRoundingUp(x, d);
    uint256 diff = z - (x / d);
    if (x % d == 0) {
      assert(diff == 0);
    } else {
      assert(diff == 1);
    }
  }
}