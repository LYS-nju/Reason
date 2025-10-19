pragma solidity ^0.8.20;
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import './INukeFund.sol';
import '../TraitForgeNft/ITraitForgeNft.sol';
import '../Airdrop/IAirdrop.sol';
contract NukeFund is INukeFund, ReentrancyGuard, Ownable, Pausable {
  uint256 public constant MAX_DENOMINATOR = 100000;
  uint256 private fund;
  ITraitForgeNft public nftContract;
  IAirdrop public airdropContract;
  address payable public devAddress;
  address payable public daoAddress;
  uint256 public taxCut = 10;
  uint256 public defaultNukeFactorIncrease = 250;
  uint256 public maxAllowedClaimDivisor = 2;
  uint256 public nukeFactorMaxParam = MAX_DENOMINATOR / 2;
  uint256 public minimumDaysHeld = 3 days;
  uint256 public ageMultiplier;
  constructor(
    address _traitForgeNft,
    address _airdrop,
    address payable _devAddress,
    address payable _daoAddress
  ) {
    nftContract = ITraitForgeNft(_traitForgeNft);
    airdropContract = IAirdrop(_airdrop);
    devAddress = _devAddress; 
    daoAddress = _daoAddress;
  }
  receive() external payable {
    uint256 devShare = msg.value / taxCut; 
    uint256 remainingFund = msg.value - devShare; 
    fund += remainingFund; 
    if (!airdropContract.airdropStarted()) {
      (bool success, ) = devAddress.call{ value: devShare }('');
      require(success, 'ETH send failed');
      emit DevShareDistributed(devShare);
    } else if (!airdropContract.daoFundAllowed()) {
      (bool success, ) = payable(owner()).call{ value: devShare }('');
      require(success, 'ETH send failed');
    } else {
      (bool success, ) = daoAddress.call{ value: devShare }('');
      require(success, 'ETH send failed');
      emit DevShareDistributed(devShare);
    }
    emit FundReceived(msg.sender, msg.value); 
    emit FundBalanceUpdated(fund); 
  }
  function setTaxCut(uint256 _taxCut) external onlyOwner {
    taxCut = _taxCut;
  }
  function setMinimumDaysHeld(uint256 value) external onlyOwner {
    minimumDaysHeld = value;
  }
  function setDefaultNukeFactorIncrease(uint256 value) external onlyOwner {
    defaultNukeFactorIncrease = value;
  }
  function setMaxAllowedClaimDivisor(uint256 value) external onlyOwner {
    maxAllowedClaimDivisor = value;
  }
  function setNukeFactorMaxParam(uint256 value) external onlyOwner {
    nukeFactorMaxParam = value;
  }
  function setTraitForgeNftContract(address _traitForgeNft) external onlyOwner {
    nftContract = ITraitForgeNft(_traitForgeNft);
    emit TraitForgeNftAddressUpdated(_traitForgeNft); 
  }
  function setAirdropContract(address _airdrop) external onlyOwner {
    airdropContract = IAirdrop(_airdrop);
    emit AirdropAddressUpdated(_airdrop); 
  }
  function setDevAddress(address payable account) external onlyOwner {
    devAddress = account;
    emit DevAddressUpdated(account);
  }
  function setDaoAddress(address payable account) external onlyOwner {
    daoAddress = account;
    emit DaoAddressUpdated(account);
  }
  function getFundBalance() public view returns (uint256) {
    return fund;
  }
  function setAgeMultplier(uint256 _ageMultiplier) external onlyOwner {
    ageMultiplier = _ageMultiplier;
  }
  function getAgeMultiplier() public view returns (uint256) {
    return ageMultiplier;
  }
  function calculateAge(uint256 tokenId) public view returns (uint256) {
    require(nftContract.ownerOf(tokenId) != address(0), 'Token does not exist');
    uint256 daysOld = (block.timestamp -
      nftContract.getTokenCreationTimestamp(tokenId)) /
      60 /
      60 /
      24;
    uint256 perfomanceFactor = nftContract.getTokenEntropy(tokenId) % 10;
    uint256 age = (daysOld *
      perfomanceFactor *
      MAX_DENOMINATOR *
      ageMultiplier) / 365; 
    return age;
  }
  function calculateNukeFactor(uint256 tokenId) public view returns (uint256) {
    require(
      nftContract.ownerOf(tokenId) != address(0),
      'ERC721: operator query for nonexistent token'
    );
    uint256 entropy = nftContract.getTokenEntropy(tokenId);
    uint256 adjustedAge = calculateAge(tokenId);
    uint256 initialNukeFactor = entropy / 40; 
    uint256 finalNukeFactor = ((adjustedAge * defaultNukeFactorIncrease) /
      MAX_DENOMINATOR) + initialNukeFactor;
    return finalNukeFactor;
  }
  function nuke(uint256 tokenId) public whenNotPaused nonReentrant {
    require(
      nftContract.isApprovedOrOwner(msg.sender, tokenId),
      'ERC721: caller is not token owner or approved'
    );
    require(
      nftContract.getApproved(tokenId) == address(this) ||
        nftContract.isApprovedForAll(msg.sender, address(this)),
      'Contract must be approved to transfer the NFT.'
    );
    require(canTokenBeNuked(tokenId), 'Token is not mature yet');
    uint256 finalNukeFactor = calculateNukeFactor(tokenId); 
    uint256 potentialClaimAmount = (fund * finalNukeFactor) / MAX_DENOMINATOR; 
    uint256 maxAllowedClaimAmount = fund / maxAllowedClaimDivisor; 
    uint256 claimAmount = finalNukeFactor > nukeFactorMaxParam
      ? maxAllowedClaimAmount
      : potentialClaimAmount;
    fund -= claimAmount; 
    nftContract.burn(tokenId); 
    (bool success, ) = payable(msg.sender).call{ value: claimAmount }('');
    require(success, 'Failed to send Ether');
    emit Nuked(msg.sender, tokenId, claimAmount); 
    emit FundBalanceUpdated(fund); 
  }
  function canTokenBeNuked(uint256 tokenId) public view returns (bool) {
    require(
      nftContract.ownerOf(tokenId) != address(0),
      'ERC721: operator query for nonexistent token'
    );
    uint256 tokenAgeInSeconds = block.timestamp -
      nftContract.getTokenLastTransferredTimestamp(tokenId);
    return tokenAgeInSeconds >= minimumDaysHeld;
  }
}