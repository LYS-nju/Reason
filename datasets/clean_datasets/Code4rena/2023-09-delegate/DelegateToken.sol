pragma solidity ^0.8.21;
import {IDelegateToken, IERC721Metadata, IERC721Receiver, IERC1155Receiver} from "./interfaces/IDelegateToken.sol";
import {MarketMetadata} from "src/MarketMetadata.sol";
import {PrincipalToken} from "src/PrincipalToken.sol";
import {ReentrancyGuard} from "openzeppelin/security/ReentrancyGuard.sol";
import {IDelegateRegistry, DelegateTokenErrors as Errors, DelegateTokenStructs as Structs, DelegateTokenHelpers as Helpers} from "src/libraries/DelegateTokenLib.sol";
import {DelegateTokenStorageHelpers as StorageHelpers} from "src/libraries/DelegateTokenStorageHelpers.sol";
import {DelegateTokenRegistryHelpers as RegistryHelpers, RegistryHashes} from "src/libraries/DelegateTokenRegistryHelpers.sol";
import {DelegateTokenTransferHelpers as TransferHelpers, SafeERC20, IERC721, IERC20, IERC1155} from "src/libraries/DelegateTokenTransferHelpers.sol";
contract DelegateToken is ReentrancyGuard, IDelegateToken {
    address public immutable override delegateRegistry;
    address public immutable override principalToken;
    address public immutable marketMetadata;
    mapping(uint256 delegateTokenId => uint256[3] info) internal delegateTokenInfo;
    mapping(address delegateTokenHolder => uint256 balance) internal balances;
    mapping(address account => mapping(address operator => bool enabled)) internal accountOperator;
    Structs.Uint256 internal principalMintAuthorization = Structs.Uint256(StorageHelpers.MINT_NOT_AUTHORIZED);
    Structs.Uint256 internal principalBurnAuthorization = Structs.Uint256(StorageHelpers.BURN_NOT_AUTHORIZED);
    Structs.Uint256 internal erc1155PullAuthorization = Structs.Uint256(TransferHelpers.ERC1155_NOT_PULLED);
    constructor(Structs.DelegateTokenParameters memory parameters) {
        if (parameters.delegateRegistry == address(0)) revert Errors.DelegateRegistryZero();
        if (parameters.principalToken == address(0)) revert Errors.PrincipalTokenZero();
        if (parameters.marketMetadata == address(0)) revert Errors.MarketMetadataZero();
        delegateRegistry = parameters.delegateRegistry;
        principalToken = parameters.principalToken;
        marketMetadata = parameters.marketMetadata;
    }
    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == 0x2a55205a 
            || interfaceId == 0x01ffc9a7 
            || interfaceId == 0x80ac58cd 
            || interfaceId == 0x5b5e139f 
            || interfaceId == 0x4e2312e0; 
    }
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external pure returns (bytes4) {
        revert Errors.BatchERC1155TransferUnsupported();
    }
    function onERC721Received(address operator, address, uint256, bytes calldata) external view returns (bytes4) {
        if (address(this) == operator) return IERC721Receiver.onERC721Received.selector;
        revert Errors.InvalidERC721TransferOperator();
    }
    function onERC1155Received(address operator, address, uint256, uint256, bytes calldata) external returns (bytes4) {
        TransferHelpers.revertInvalidERC1155PullCheck(erc1155PullAuthorization, operator);
        return IERC1155Receiver.onERC1155Received.selector;
    }
    function balanceOf(address delegateTokenHolder) external view returns (uint256) {
        if (delegateTokenHolder == address(0)) revert Errors.DelegateTokenHolderZero();
        return balances[delegateTokenHolder];
    }
    function ownerOf(uint256 delegateTokenId) external view returns (address delegateTokenHolder) {
        delegateTokenHolder = RegistryHelpers.loadTokenHolder(delegateRegistry, StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId));
        if (delegateTokenHolder == address(0)) revert Errors.DelegateTokenHolderZero();
    }
    function getApproved(uint256 delegateTokenId) external view returns (address) {
        StorageHelpers.revertNotMinted(delegateTokenInfo, delegateTokenId);
        return StorageHelpers.readApproved(delegateTokenInfo, delegateTokenId);
    }
    function isApprovedForAll(address account, address operator) external view returns (bool) {
        return accountOperator[account][operator];
    }
    function safeTransferFrom(address from, address to, uint256 delegateTokenId, bytes calldata data) external {
        transferFrom(from, to, delegateTokenId);
        Helpers.revertOnInvalidERC721ReceiverCallback(from, to, delegateTokenId, data);
    }
    function safeTransferFrom(address from, address to, uint256 delegateTokenId) external {
        transferFrom(from, to, delegateTokenId);
        Helpers.revertOnInvalidERC721ReceiverCallback(from, to, delegateTokenId);
    }
    function approve(address spender, uint256 delegateTokenId) external {
        bytes32 registryHash = StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        StorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        address delegateTokenHolder = RegistryHelpers.loadTokenHolder(delegateRegistry, registryHash);
        StorageHelpers.revertNotOperator(accountOperator, delegateTokenHolder);
        StorageHelpers.writeApproved(delegateTokenInfo, delegateTokenId, spender);
        emit Approval(delegateTokenHolder, spender, delegateTokenId);
    }
    function setApprovalForAll(address operator, bool approved) external {
        accountOperator[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    function transferFrom(address from, address to, uint256 delegateTokenId) public {
        if (to == address(0)) revert Errors.ToIsZero();
        bytes32 registryHash = StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        StorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        (address delegateTokenHolder, address underlyingContract) = RegistryHelpers.loadTokenHolderAndContract(delegateRegistry, registryHash);
        if (from != delegateTokenHolder) revert Errors.FromNotDelegateTokenHolder();
        StorageHelpers.revertNotApprovedOrOperator(accountOperator, delegateTokenInfo, from, delegateTokenId);
        StorageHelpers.incrementBalance(balances, to);
        StorageHelpers.decrementBalance(balances, from);
        StorageHelpers.writeApproved(delegateTokenInfo, delegateTokenId, address(0));
        emit Transfer(from, to, delegateTokenId);
        IDelegateRegistry.DelegationType underlyingType = RegistryHashes.decodeType(registryHash);
        bytes32 underlyingRights = RegistryHelpers.loadRights(delegateRegistry, registryHash);
        bytes32 newRegistryHash = 0;
        if (underlyingType == IDelegateRegistry.DelegationType.ERC721) {
            uint256 underlyingTokenId = RegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            newRegistryHash = RegistryHashes.erc721Hash(address(this), underlyingRights, to, underlyingTokenId, underlyingContract);
            StorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            RegistryHelpers.transferERC721(delegateRegistry, registryHash, from, newRegistryHash, to, underlyingRights, underlyingContract, underlyingTokenId);
        } else if (underlyingType == IDelegateRegistry.DelegationType.ERC20) {
            newRegistryHash = RegistryHashes.erc20Hash(address(this), underlyingRights, to, underlyingContract);
            StorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            RegistryHelpers.transferERC20(
                delegateRegistry,
                registryHash,
                from,
                newRegistryHash,
                to,
                StorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId),
                underlyingRights,
                underlyingContract
            );
        } else if (underlyingType == IDelegateRegistry.DelegationType.ERC1155) {
            uint256 underlyingTokenId = RegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            newRegistryHash = RegistryHashes.erc1155Hash(address(this), underlyingRights, to, underlyingTokenId, underlyingContract);
            StorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            RegistryHelpers.transferERC1155(
                delegateRegistry,
                registryHash,
                from,
                newRegistryHash,
                to,
                StorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId),
                underlyingRights,
                underlyingContract,
                underlyingTokenId
            );
        }
    }
    function name() external pure returns (string memory) {
        return "Delegate Token";
    }
    function symbol() external pure returns (string memory) {
        return "DT";
    }
    function tokenURI(uint256 delegateTokenId) external view returns (string memory) {
        bytes32 registryHash = StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        StorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        return MarketMetadata(marketMetadata).delegateTokenURI(
            RegistryHelpers.loadContract(delegateRegistry, registryHash),
            RegistryHelpers.loadTokenId(delegateRegistry, registryHash),
            StorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId),
            IERC721(principalToken).ownerOf(delegateTokenId)
        );
    }
    function isApprovedOrOwner(address spender, uint256 delegateTokenId) external view returns (bool) {
        bytes32 registryHash = StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        StorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        address delegateTokenHolder = RegistryHelpers.loadTokenHolder(delegateRegistry, registryHash);
        return spender == delegateTokenHolder || accountOperator[delegateTokenHolder][spender] || StorageHelpers.readApproved(delegateTokenInfo, delegateTokenId) == spender;
    }
    function baseURI() external view returns (string memory) {
        return MarketMetadata(marketMetadata).delegateTokenBaseURI();
    }
    function contractURI() external view returns (string memory) {
        return MarketMetadata(marketMetadata).delegateTokenContractURI();
    }
    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        (receiver, royaltyAmount) = MarketMetadata(marketMetadata).royaltyInfo(tokenId, salePrice);
    }
    function getDelegateInfo(uint256 delegateTokenId) external view returns (Structs.DelegateInfo memory delegateInfo) {
        bytes32 registryHash = StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        StorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        delegateInfo.tokenType = RegistryHashes.decodeType(registryHash);
        (delegateInfo.delegateHolder, delegateInfo.tokenContract) = RegistryHelpers.loadTokenHolderAndContract(delegateRegistry, registryHash);
        delegateInfo.rights = RegistryHelpers.loadRights(delegateRegistry, registryHash);
        delegateInfo.principalHolder = IERC721(principalToken).ownerOf(delegateTokenId);
        delegateInfo.expiry = StorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId);
        if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC20) delegateInfo.tokenId = 0;
        else delegateInfo.tokenId = RegistryHelpers.loadTokenId(delegateRegistry, registryHash);
        if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC721) delegateInfo.amount = 0;
        else delegateInfo.amount = StorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId);
    }
    function getDelegateId(address caller, uint256 salt) external view returns (uint256 delegateTokenId) {
        delegateTokenId = Helpers.delegateIdNoRevert(caller, salt);
        StorageHelpers.revertAlreadyExisted(delegateTokenInfo, delegateTokenId);
    }
    function burnAuthorizedCallback() external view {
        StorageHelpers.checkBurnAuthorized(principalToken, principalBurnAuthorization);
    }
    function mintAuthorizedCallback() external view {
        StorageHelpers.checkMintAuthorized(principalToken, principalMintAuthorization);
    }
    function create(Structs.DelegateInfo calldata delegateInfo, uint256 salt) external nonReentrant returns (uint256 delegateTokenId) {
        TransferHelpers.checkAndPullByType(erc1155PullAuthorization, delegateInfo);
        Helpers.revertOldExpiry(delegateInfo.expiry);
        if (delegateInfo.delegateHolder == address(0)) revert Errors.ToIsZero();
        delegateTokenId = Helpers.delegateIdNoRevert(msg.sender, salt);
        StorageHelpers.revertAlreadyExisted(delegateTokenInfo, delegateTokenId);
        StorageHelpers.incrementBalance(balances, delegateInfo.delegateHolder);
        StorageHelpers.writeExpiry(delegateTokenInfo, delegateTokenId, delegateInfo.expiry);
        emit Transfer(address(0), delegateInfo.delegateHolder, delegateTokenId);
        bytes32 newRegistryHash = 0;
        if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC721) {
            newRegistryHash = RegistryHashes.erc721Hash(address(this), delegateInfo.rights, delegateInfo.delegateHolder, delegateInfo.tokenId, delegateInfo.tokenContract);
            StorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            RegistryHelpers.delegateERC721(delegateRegistry, newRegistryHash, delegateInfo);
        } else if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC20) {
            StorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, delegateInfo.amount);
            newRegistryHash = RegistryHashes.erc20Hash(address(this), delegateInfo.rights, delegateInfo.delegateHolder, delegateInfo.tokenContract);
            StorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            RegistryHelpers.incrementERC20(delegateRegistry, newRegistryHash, delegateInfo);
        } else if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC1155) {
            StorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, delegateInfo.amount);
            newRegistryHash = RegistryHashes.erc1155Hash(address(this), delegateInfo.rights, delegateInfo.delegateHolder, delegateInfo.tokenId, delegateInfo.tokenContract);
            StorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            RegistryHelpers.incrementERC1155(delegateRegistry, newRegistryHash, delegateInfo);
        }
        StorageHelpers.mintPrincipal(principalToken, principalMintAuthorization, delegateInfo.principalHolder, delegateTokenId);
    }
    function extend(uint256 delegateTokenId, uint256 newExpiry) external {
        StorageHelpers.revertNotMinted(delegateTokenInfo, delegateTokenId);
        Helpers.revertOldExpiry(newExpiry);
        uint256 previousExpiry = StorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId);
        if (newExpiry <= previousExpiry) revert Errors.ExpiryTooSmall();
        if (PrincipalToken(principalToken).isApprovedOrOwner(msg.sender, delegateTokenId)) {
            StorageHelpers.writeExpiry(delegateTokenInfo, delegateTokenId, newExpiry);
            emit ExpiryExtended(delegateTokenId, previousExpiry, newExpiry);
            return;
        }
        revert Errors.NotApproved(msg.sender, delegateTokenId);
    }
    function rescind(uint256 delegateTokenId) external {
        if (StorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId) < block.timestamp) {
            StorageHelpers.writeApproved(delegateTokenInfo, delegateTokenId, msg.sender);
        }
        transferFrom(
            RegistryHelpers.loadTokenHolder(delegateRegistry, StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId)),
            IERC721(principalToken).ownerOf(delegateTokenId),
            delegateTokenId
        );
    }
    function withdraw(uint256 delegateTokenId) external nonReentrant {
        bytes32 registryHash = StorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        StorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, bytes32(StorageHelpers.ID_USED));
        StorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        (address delegateTokenHolder, address underlyingContract) = RegistryHelpers.loadTokenHolderAndContract(delegateRegistry, registryHash);
        StorageHelpers.revertInvalidWithdrawalConditions(delegateTokenInfo, accountOperator, delegateTokenId, delegateTokenHolder);
        StorageHelpers.decrementBalance(balances, delegateTokenHolder);
        delete delegateTokenInfo[delegateTokenId][StorageHelpers.PACKED_INFO_POSITION]; 
        emit Transfer(delegateTokenHolder, address(0), delegateTokenId);
        IDelegateRegistry.DelegationType delegationType = RegistryHashes.decodeType(registryHash);
        bytes32 underlyingRights = RegistryHelpers.loadRights(delegateRegistry, registryHash);
        if (delegationType == IDelegateRegistry.DelegationType.ERC721) {
            uint256 erc721UnderlyingTokenId = RegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            RegistryHelpers.revokeERC721(delegateRegistry, registryHash, delegateTokenHolder, underlyingContract, erc721UnderlyingTokenId, underlyingRights);
            StorageHelpers.burnPrincipal(principalToken, principalBurnAuthorization, delegateTokenId);
            IERC721(underlyingContract).transferFrom(address(this), msg.sender, erc721UnderlyingTokenId);
        } else if (delegationType == IDelegateRegistry.DelegationType.ERC20) {
            uint256 erc20UnderlyingAmount = StorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId);
            StorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, 0); 
            RegistryHelpers.decrementERC20(delegateRegistry, registryHash, delegateTokenHolder, underlyingContract, erc20UnderlyingAmount, underlyingRights);
            StorageHelpers.burnPrincipal(principalToken, principalBurnAuthorization, delegateTokenId);
            SafeERC20.safeTransfer(IERC20(underlyingContract), msg.sender, erc20UnderlyingAmount);
        } else if (delegationType == IDelegateRegistry.DelegationType.ERC1155) {
            uint256 erc1155UnderlyingAmount = StorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId);
            StorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, 0); 
            uint256 erc11551UnderlyingTokenId = RegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            RegistryHelpers.decrementERC1155(
                delegateRegistry, registryHash, delegateTokenHolder, underlyingContract, erc11551UnderlyingTokenId, erc1155UnderlyingAmount, underlyingRights
            );
            StorageHelpers.burnPrincipal(principalToken, principalBurnAuthorization, delegateTokenId);
            IERC1155(underlyingContract).safeTransferFrom(address(this), msg.sender, erc11551UnderlyingTokenId, erc1155UnderlyingAmount, "");
        }
    }
    function flashloan(Structs.FlashInfo calldata info) external payable nonReentrant {
        StorageHelpers.revertNotOperator(accountOperator, info.delegateHolder);
        if (info.tokenType == IDelegateRegistry.DelegationType.ERC721) {
            RegistryHelpers.revertERC721FlashUnavailable(delegateRegistry, info);
            IERC721(info.tokenContract).transferFrom(address(this), info.receiver, info.tokenId);
            Helpers.revertOnCallingInvalidFlashloan(info);
            TransferHelpers.checkERC721BeforePull(info.amount, info.tokenContract, info.tokenId);
            TransferHelpers.pullERC721AfterCheck(info.tokenContract, info.tokenId);
        } else if (info.tokenType == IDelegateRegistry.DelegationType.ERC20) {
            RegistryHelpers.revertERC20FlashAmountUnavailable(delegateRegistry, info);
            SafeERC20.safeTransfer(IERC20(info.tokenContract), info.receiver, info.amount);
            Helpers.revertOnCallingInvalidFlashloan(info);
            TransferHelpers.checkERC20BeforePull(info.amount, info.tokenContract, info.tokenId);
            TransferHelpers.pullERC20AfterCheck(info.tokenContract, info.amount);
        } else if (info.tokenType == IDelegateRegistry.DelegationType.ERC1155) {
            RegistryHelpers.revertERC1155FlashAmountUnavailable(delegateRegistry, info);
            TransferHelpers.checkERC1155BeforePull(erc1155PullAuthorization, info.amount);
            IERC1155(info.tokenContract).safeTransferFrom(address(this), info.receiver, info.tokenId, info.amount, "");
            Helpers.revertOnCallingInvalidFlashloan(info);
            TransferHelpers.pullERC1155AfterCheck(erc1155PullAuthorization, info.amount, info.tokenContract, info.tokenId);
        }
    }
}