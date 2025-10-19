pragma solidity ^0.8.15;
import '@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol';
import '@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol';
import '@openzeppelin/contracts-upgradeable/interfaces/IERC2981Upgradeable.sol';
import '@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol';
import './ReceiptRenderer.sol';
import './interfaces/IQuestFactory.sol';
import './interfaces/IQuest.sol';
contract RabbitHoleReceipt is
    Initializable,
    ERC721Upgradeable,
    ERC721EnumerableUpgradeable,
    ERC721URIStorageUpgradeable,
    OwnableUpgradeable,
    IERC2981Upgradeable
{
    event RoyaltyFeeSet(uint256 indexed royaltyFee);
    event MinterAddressSet(address indexed minterAddress);
    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter private _tokenIds;
    mapping(uint => string) public questIdForTokenId;
    address public royaltyRecipient;
    address public minterAddress;
    uint public royaltyFee;
    mapping(uint => uint) public timestampForTokenId;
    ReceiptRenderer public ReceiptRendererContract;
    IQuestFactory public QuestFactoryContract;
    constructor() {
        _disableInitializers();
    }
    function initialize(
        address receiptRenderer_,
        address royaltyRecipient_,
        address minterAddress_,
        uint royaltyFee_
    ) public initializer {
        __ERC721_init('RabbitHoleReceipt', 'RHR');
        __ERC721URIStorage_init();
        __Ownable_init();
        royaltyRecipient = royaltyRecipient_;
        minterAddress = minterAddress_;
        royaltyFee = royaltyFee_;
        ReceiptRendererContract = ReceiptRenderer(receiptRenderer_);
    }
    modifier onlyMinter() {
        msg.sender == minterAddress;
        _;
    }
    function setReceiptRenderer(address receiptRenderer_) public onlyOwner {
        ReceiptRendererContract = ReceiptRenderer(receiptRenderer_);
    }
    function setRoyaltyRecipient(address royaltyRecipient_) public onlyOwner {
        royaltyRecipient = royaltyRecipient_;
    }
    function setQuestFactory(address questFactory_) public onlyOwner {
        QuestFactoryContract = IQuestFactory(questFactory_);
    }
    function setMinterAddress(address minterAddress_) public onlyOwner {
        minterAddress = minterAddress_;
        emit MinterAddressSet(minterAddress_);
    }
    function setRoyaltyFee(uint256 royaltyFee_) public onlyOwner {
        royaltyFee = royaltyFee_;
        emit RoyaltyFeeSet(royaltyFee_);
    }
    function mint(address to_, string memory questId_) public onlyMinter {
        _tokenIds.increment();
        uint newTokenID = _tokenIds.current();
        questIdForTokenId[newTokenID] = questId_;
        timestampForTokenId[newTokenID] = block.timestamp;
        _safeMint(to_, newTokenID);
    }
    function getOwnedTokenIdsOfQuest(
        string memory questId_,
        address claimingAddress_
    ) public view returns (uint[] memory) {
        uint msgSenderBalance = balanceOf(claimingAddress_);
        uint[] memory tokenIdsForQuest = new uint[](msgSenderBalance);
        uint foundTokens = 0;
        for (uint i = 0; i < msgSenderBalance; i++) {
            uint tokenId = tokenOfOwnerByIndex(claimingAddress_, i);
            if (keccak256(bytes(questIdForTokenId[tokenId])) == keccak256(bytes(questId_))) {
                tokenIdsForQuest[i] = tokenId;
                foundTokens++;
            }
        }
        uint[] memory filteredTokens = new uint[](foundTokens);
        uint filterTokensIndexTracker = 0;
        for (uint i = 0; i < msgSenderBalance; i++) {
            if (tokenIdsForQuest[i] > 0) {
                filteredTokens[filterTokensIndexTracker] = tokenIdsForQuest[i];
                filterTokensIndexTracker++;
            }
        }
        return filteredTokens;
    }
    function _burn(uint256 tokenId_) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId_);
    }
    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_,
        uint256 batchSize_
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._beforeTokenTransfer(from_, to_, tokenId_, batchSize_);
    }
    function tokenURI(
        uint tokenId_
    ) public view virtual override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        require(_exists(tokenId_), 'ERC721URIStorage: URI query for nonexistent token');
        require(QuestFactoryContract != IQuestFactory(address(0)), 'QuestFactory not set');
        string memory questId = questIdForTokenId[tokenId_];
        (address questAddress, uint totalParticipants, ) = QuestFactoryContract.questInfo(questId);
        IQuest questContract = IQuest(questAddress);
        bool claimed = questContract.isClaimed(tokenId_);
        uint rewardAmount = questContract.getRewardAmount();
        address rewardAddress = questContract.getRewardToken();
        return ReceiptRendererContract.generateTokenURI(tokenId_, questId, totalParticipants, claimed, rewardAmount, rewardAddress);
    }
    function royaltyInfo(
        uint256 tokenId_,
        uint256 salePrice_
    ) external view override returns (address receiver, uint256 royaltyAmount) {
        require(_exists(tokenId_), 'Nonexistent token');
        uint256 royaltyPayment = (salePrice_ * royaltyFee) / 10_000;
        return (royaltyRecipient, royaltyPayment);
    }
    function supportsInterface(
        bytes4 interfaceId_
    ) public view virtual override(ERC721Upgradeable, ERC721EnumerableUpgradeable, IERC165Upgradeable) returns (bool) {
        return interfaceId_ == type(IERC2981Upgradeable).interfaceId || super.supportsInterface(interfaceId_);
    }
}