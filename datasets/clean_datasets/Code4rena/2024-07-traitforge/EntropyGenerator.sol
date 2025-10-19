pragma solidity ^0.8.20;
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import './IEntropyGenerator.sol';
contract EntropyGenerator is IEntropyGenerator, Ownable, Pausable {
  uint256[770] private entropySlots; 
  uint256 private lastInitializedIndex = 0; 
  uint256 private currentSlotIndex = 0;
  uint256 private currentNumberIndex = 0;
  uint256 private batchSize1 = 256;
  uint256 private batchSize2 = 512;
  uint256 private maxSlotIndex = 770;
  uint256 private maxNumberIndex = 13;
  uint256 public slotIndexSelectionPoint;
  uint256 public numberIndexSelectionPoint;
  address private allowedCaller;
  modifier onlyAllowedCaller() {
    require(msg.sender == allowedCaller, 'Caller is not allowed');
    _;
  }
  constructor(address _traitForgetNft) {
    allowedCaller = _traitForgetNft;
    initializeAlphaIndices();
  }
  function setAllowedCaller(address _allowedCaller) external onlyOwner {
    allowedCaller = _allowedCaller;
    emit AllowedCallerUpdated(_allowedCaller); 
  }
  function getAllowedCaller() external view returns (address) {
    return allowedCaller;
  }
  function writeEntropyBatch1() public {
    require(lastInitializedIndex < batchSize1, 'Batch 1 already initialized.');
    uint256 endIndex = lastInitializedIndex + batchSize1; 
    unchecked {
      for (uint256 i = lastInitializedIndex; i < endIndex; i++) {
        uint256 pseudoRandomValue = uint256(
          keccak256(abi.encodePacked(block.number, i))
        ) % uint256(10) ** 78; 
        require(pseudoRandomValue != 999999, 'Invalid value, retry.');
        entropySlots[i] = pseudoRandomValue; 
      }
    }
    lastInitializedIndex = endIndex;
  }
  function writeEntropyBatch2() public {
    require(
      lastInitializedIndex >= batchSize1 && lastInitializedIndex < batchSize2,
      'Batch 2 not ready or already initialized.'
    );
    uint256 endIndex = lastInitializedIndex + batchSize1;
    unchecked {
      for (uint256 i = lastInitializedIndex; i < endIndex; i++) {
        uint256 pseudoRandomValue = uint256(
          keccak256(abi.encodePacked(block.number, i))
        ) % uint256(10) ** 78;
        require(pseudoRandomValue != 999999, 'Invalid value, retry.');
        entropySlots[i] = pseudoRandomValue;
      }
    }
    lastInitializedIndex = endIndex;
  }
  function writeEntropyBatch3() public {
    require(
      lastInitializedIndex >= batchSize2 && lastInitializedIndex < maxSlotIndex,
      'Batch 3 not ready or already completed.'
    );
    unchecked {
      for (uint256 i = lastInitializedIndex; i < maxSlotIndex; i++) {
        uint256 pseudoRandomValue = uint256(
          keccak256(abi.encodePacked(block.number, i))
        ) % uint256(10) ** 78;
        entropySlots[i] = pseudoRandomValue;
      }
    }
    lastInitializedIndex = maxSlotIndex;
  }
  function getNextEntropy() public onlyAllowedCaller returns (uint256) {
    require(currentSlotIndex <= maxSlotIndex, 'Max slot index reached.');
    uint256 entropy = getEntropy(currentSlotIndex, currentNumberIndex);
    if (currentNumberIndex >= maxNumberIndex - 1) {
      currentNumberIndex = 0;
      if (currentSlotIndex >= maxSlotIndex - 1) {
        currentSlotIndex = 0;
      } else {
        currentSlotIndex++;
      }
    } else {
      currentNumberIndex++;
    }
    emit EntropyRetrieved(entropy);
    return entropy;
  }
  function getPublicEntropy(
    uint256 slotIndex,
    uint256 numberIndex
  ) public view returns (uint256) {
    return getEntropy(slotIndex, numberIndex);
  }
  function getLastInitializedIndex() public view returns (uint256) {
    return lastInitializedIndex;
  }
  function deriveTokenParameters(
    uint256 slotIndex,
    uint256 numberIndex
  )
    public
    view
    returns (
      uint256 nukeFactor,
      uint256 forgePotential,
      uint256 performanceFactor,
      bool isForger
    )
  {
    uint256 entropy = getEntropy(slotIndex, numberIndex);
    nukeFactor = entropy / 4000000;
    forgePotential = getFirstDigit(entropy);
    performanceFactor = entropy % 10;
    uint256 role = entropy % 3;
    isForger = role == 0;
    return (nukeFactor, forgePotential, performanceFactor, isForger); 
  }
  function getEntropy(
    uint256 slotIndex,
    uint256 numberIndex
  ) private view returns (uint256) {
    require(slotIndex <= maxSlotIndex, 'Slot index out of bounds.');
    if (
      slotIndex == slotIndexSelectionPoint &&
      numberIndex == numberIndexSelectionPoint
    ) {
      return 999999;
    }
    uint256 position = numberIndex * 6; 
    require(position <= 72, 'Position calculation error');
    uint256 slotValue = entropySlots[slotIndex]; 
    uint256 entropy = (slotValue / (10 ** (72 - position))) % 1000000; 
    uint256 paddedEntropy = entropy * (10 ** (6 - numberOfDigits(entropy)));
    return paddedEntropy; 
  }
  function numberOfDigits(uint256 number) private pure returns (uint256) {
    uint256 digits = 0;
    while (number != 0) {
      number /= 10;
      digits++;
    }
    return digits;
  }
  function getFirstDigit(uint256 number) private pure returns (uint256) {
    while (number >= 10) {
      number /= 10;
    }
    return number;
  }
  function initializeAlphaIndices() public whenNotPaused onlyOwner {
    uint256 hashValue = uint256(
      keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))
    );
    uint256 slotIndexSelection = (hashValue % 258) + 512;
    uint256 numberIndexSelection = hashValue % 13;
    slotIndexSelectionPoint = slotIndexSelection;
    numberIndexSelectionPoint = numberIndexSelection;
  }
}