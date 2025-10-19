pragma solidity ^0.8.15;
import {Types} from 'contracts/libraries/constants/Types.sol';
import {ERC2981CollectionRoyalties} from 'contracts/base/ERC2981CollectionRoyalties.sol';
import {Errors} from 'contracts/libraries/constants/Errors.sol';
import {HubRestricted} from 'contracts/base/HubRestricted.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import {IERC721Timestamped} from 'contracts/interfaces/IERC721Timestamped.sol';
import {IFollowNFT} from 'contracts/interfaces/IFollowNFT.sol';
import {ILensHub} from 'contracts/interfaces/ILensHub.sol';
import {LensBaseERC721} from 'contracts/base/LensBaseERC721.sol';
import {Strings} from '@openzeppelin/contracts/utils/Strings.sol';
import {StorageLib} from 'contracts/libraries/StorageLib.sol';
import {FollowTokenURILib} from 'contracts/libraries/token-uris/FollowTokenURILib.sol';
contract FollowNFT is HubRestricted, LensBaseERC721, ERC2981CollectionRoyalties, IFollowNFT {
    using Strings for uint256;
    string constant FOLLOW_NFT_NAME_SUFFIX = '-Follower';
    string constant FOLLOW_NFT_SYMBOL_SUFFIX = '-Fl';
    uint256[5] ___DEPRECATED_SLOTS; 
    uint256 internal _followedProfileId;
    uint128 internal _lastFollowTokenId;
    uint128 internal _followerCount;
    bool private _initialized;
    mapping(uint256 => Types.FollowData) internal _followDataByFollowTokenId;
    mapping(uint256 => uint256) internal _followTokenIdByFollowerProfileId;
    mapping(uint256 => uint256) internal _followApprovalByFollowTokenId;
    uint256 internal _royaltiesInBasisPoints;
    event FollowApproval(uint256 indexed followerProfileId, uint256 indexed followTokenId);
    constructor(address hub) HubRestricted(hub) {
        _initialized = true;
    }
    function initialize(uint256 profileId) external override {
        if (_initialized) {
            revert Errors.Initialized();
        }
        _initialized = true;
        _followedProfileId = profileId;
        _setRoyalty(1000); 
    }
    function follow(
        uint256 followerProfileId,
        address transactionExecutor,
        uint256 followTokenId
    ) external override onlyHub returns (uint256) {
        if (_followTokenIdByFollowerProfileId[followerProfileId] != 0) {
            revert AlreadyFollowing();
        }
        if (followTokenId == 0) {
            return _followMintingNewToken(followerProfileId);
        }
        address followTokenOwner = _unsafeOwnerOf(followTokenId);
        if (followTokenOwner != address(0)) {
            return
                _followWithWrappedToken({
                    followerProfileId: followerProfileId,
                    transactionExecutor: transactionExecutor,
                    followTokenId: followTokenId,
                    followTokenOwner: followTokenOwner
                });
        }
        uint256 currentFollowerProfileId = _followDataByFollowTokenId[followTokenId].followerProfileId;
        if (currentFollowerProfileId != 0) {
            return
                _followWithUnwrappedTokenFromBurnedProfile({
                    followerProfileId: followerProfileId,
                    followTokenId: followTokenId,
                    currentFollowerProfileId: currentFollowerProfileId
                });
        }
        return _followByRecoveringToken({followerProfileId: followerProfileId, followTokenId: followTokenId});
    }
    function unfollow(uint256 unfollowerProfileId, address transactionExecutor) external override onlyHub {
        uint256 followTokenId = _followTokenIdByFollowerProfileId[unfollowerProfileId];
        if (followTokenId == 0) {
            revert NotFollowing();
        }
        address followTokenOwner = _unsafeOwnerOf(followTokenId);
        if (followTokenOwner == address(0)) {
            _unfollow({unfollower: unfollowerProfileId, followTokenId: followTokenId});
            _followDataByFollowTokenId[followTokenId].profileIdAllowedToRecover = unfollowerProfileId;
        } else {
            address unfollowerProfileOwner = IERC721(HUB).ownerOf(unfollowerProfileId);
            if (
                (followTokenOwner != unfollowerProfileOwner) &&
                (followTokenOwner != transactionExecutor) &&
                !isApprovedForAll(followTokenOwner, transactionExecutor) &&
                !isApprovedForAll(followTokenOwner, unfollowerProfileOwner)
            ) {
                revert DoesNotHavePermissions();
            }
            _unfollow({unfollower: unfollowerProfileId, followTokenId: followTokenId});
        }
    }
    function removeFollower(uint256 followTokenId) external override {
        address followTokenOwner = ownerOf(followTokenId);
        if (followTokenOwner == msg.sender || isApprovedForAll(followTokenOwner, msg.sender)) {
            _unfollowIfHasFollower(followTokenId);
        } else {
            revert DoesNotHavePermissions();
        }
    }
    function approveFollow(uint256 followerProfileId, uint256 followTokenId) external override {
        if (!IERC721Timestamped(HUB).exists(followerProfileId)) {
            revert Errors.TokenDoesNotExist();
        }
        address followTokenOwner = _unsafeOwnerOf(followTokenId);
        if (followTokenOwner == address(0)) {
            revert OnlyWrappedFollowTokens();
        }
        if (followTokenOwner != msg.sender && !isApprovedForAll(followTokenOwner, msg.sender)) {
            revert DoesNotHavePermissions();
        }
        _approveFollow(followerProfileId, followTokenId);
    }
    function wrap(uint256 followTokenId, address wrappedTokenReceiver) external override {
        if (wrappedTokenReceiver == address(0)) {
            revert Errors.InvalidParameter();
        }
        _wrap(followTokenId, wrappedTokenReceiver);
    }
    function wrap(uint256 followTokenId) external override {
        _wrap(followTokenId, address(0));
    }
    function _wrap(uint256 followTokenId, address wrappedTokenReceiver) internal {
        if (_isFollowTokenWrapped(followTokenId)) {
            revert AlreadyWrapped();
        }
        uint256 followerProfileId = _followDataByFollowTokenId[followTokenId].followerProfileId;
        if (followerProfileId == 0) {
            followerProfileId = _followDataByFollowTokenId[followTokenId].profileIdAllowedToRecover;
            if (followerProfileId == 0) {
                revert FollowTokenDoesNotExist();
            }
            delete _followDataByFollowTokenId[followTokenId].profileIdAllowedToRecover;
        }
        address followerProfileOwner = IERC721(HUB).ownerOf(followerProfileId);
        if (msg.sender != followerProfileOwner) {
            revert DoesNotHavePermissions();
        }
        _mint(wrappedTokenReceiver == address(0) ? followerProfileOwner : wrappedTokenReceiver, followTokenId);
    }
    function unwrap(uint256 followTokenId) external override {
        if (_followDataByFollowTokenId[followTokenId].followerProfileId == 0) {
            revert NotFollowing();
        }
        super.burn(followTokenId);
    }
    function processBlock(uint256 followerProfileId) external override onlyHub returns (bool) {
        bool hasUnfollowed;
        uint256 followTokenId = _followTokenIdByFollowerProfileId[followerProfileId];
        if (followTokenId != 0) {
            if (!_isFollowTokenWrapped(followTokenId)) {
                _mint(IERC721(HUB).ownerOf(followerProfileId), followTokenId);
            }
            _unfollow(followerProfileId, followTokenId);
            hasUnfollowed = true;
        }
        return hasUnfollowed;
    }
    function getFollowerProfileId(uint256 followTokenId) external view override returns (uint256) {
        return _followDataByFollowTokenId[followTokenId].followerProfileId;
    }
    function isFollowing(uint256 followerProfileId) external view override returns (bool) {
        return _followTokenIdByFollowerProfileId[followerProfileId] != 0;
    }
    function getFollowTokenId(uint256 followerProfileId) external view override returns (uint256) {
        return _followTokenIdByFollowerProfileId[followerProfileId];
    }
    function getOriginalFollowTimestamp(uint256 followTokenId) external view override returns (uint256) {
        return _followDataByFollowTokenId[followTokenId].originalFollowTimestamp;
    }
    function getFollowTimestamp(uint256 followTokenId) external view override returns (uint256) {
        return _followDataByFollowTokenId[followTokenId].followTimestamp;
    }
    function getProfileIdAllowedToRecover(uint256 followTokenId) external view override returns (uint256) {
        return _followDataByFollowTokenId[followTokenId].profileIdAllowedToRecover;
    }
    function getFollowData(uint256 followTokenId) external view override returns (Types.FollowData memory) {
        return _followDataByFollowTokenId[followTokenId];
    }
    function getFollowApproved(uint256 followTokenId) external view override returns (uint256) {
        return _followApprovalByFollowTokenId[followTokenId];
    }
    function getFollowerCount() external view override returns (uint256) {
        return _followerCount;
    }
    function burn(uint256 followTokenId) public override {
        _unfollowIfHasFollower(followTokenId);
        super.burn(followTokenId);
    }
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(LensBaseERC721, ERC2981CollectionRoyalties)
        returns (bool)
    {
        return
            LensBaseERC721.supportsInterface(interfaceId) || ERC2981CollectionRoyalties.supportsInterface(interfaceId);
    }
    function name() public view override returns (string memory) {
        return string(abi.encodePacked(_followedProfileId.toString(), FOLLOW_NFT_NAME_SUFFIX));
    }
    function symbol() public view override returns (string memory) {
        return string(abi.encodePacked(_followedProfileId.toString(), FOLLOW_NFT_SYMBOL_SUFFIX));
    }
    function tokenURI(uint256 followTokenId) public view override returns (string memory) {
        if (!_exists(followTokenId)) {
            revert Errors.TokenDoesNotExist();
        }
        return
            FollowTokenURILib.getTokenURI(
                followTokenId,
                _followedProfileId,
                _followDataByFollowTokenId[followTokenId].originalFollowTimestamp
            );
    }
    function _followMintingNewToken(uint256 followerProfileId) internal returns (uint256) {
        uint256 followTokenIdAssigned;
        unchecked {
            followTokenIdAssigned = ++_lastFollowTokenId;
            _followerCount++;
        }
        _baseFollow({
            followerProfileId: followerProfileId,
            followTokenId: followTokenIdAssigned,
            isOriginalFollow: true
        });
        return followTokenIdAssigned;
    }
    function _followWithWrappedToken(
        uint256 followerProfileId,
        address transactionExecutor,
        uint256 followTokenId,
        address followTokenOwner
    ) internal returns (uint256) {
        bool isFollowApproved = _followApprovalByFollowTokenId[followTokenId] == followerProfileId;
        address followerProfileOwner = IERC721(HUB).ownerOf(followerProfileId);
        if (
            !isFollowApproved &&
            followTokenOwner != followerProfileOwner &&
            followTokenOwner != transactionExecutor &&
            !isApprovedForAll(followTokenOwner, transactionExecutor) &&
            !isApprovedForAll(followTokenOwner, followerProfileOwner)
        ) {
            revert DoesNotHavePermissions();
        }
        if (isFollowApproved) {
            _approveFollow(0, followTokenId);
        }
        _replaceFollower({
            currentFollowerProfileId: _followDataByFollowTokenId[followTokenId].followerProfileId,
            newFollowerProfileId: followerProfileId,
            followTokenId: followTokenId
        });
        return followTokenId;
    }
    function _followWithUnwrappedTokenFromBurnedProfile(
        uint256 followerProfileId,
        uint256 followTokenId,
        uint256 currentFollowerProfileId
    ) internal returns (uint256) {
        if (IERC721Timestamped(HUB).exists(currentFollowerProfileId)) {
            revert DoesNotHavePermissions();
        }
        _replaceFollower({
            currentFollowerProfileId: currentFollowerProfileId,
            newFollowerProfileId: followerProfileId,
            followTokenId: followTokenId
        });
        return followTokenId;
    }
    function _followByRecoveringToken(uint256 followerProfileId, uint256 followTokenId) internal returns (uint256) {
        if (_followDataByFollowTokenId[followTokenId].profileIdAllowedToRecover != followerProfileId) {
            revert FollowTokenDoesNotExist();
        }
        unchecked {
            _followerCount++;
        }
        _baseFollow({followerProfileId: followerProfileId, followTokenId: followTokenId, isOriginalFollow: false});
        return followTokenId;
    }
    function _replaceFollower(
        uint256 currentFollowerProfileId,
        uint256 newFollowerProfileId,
        uint256 followTokenId
    ) internal {
        if (currentFollowerProfileId != 0) {
            delete _followTokenIdByFollowerProfileId[currentFollowerProfileId];
            ILensHub(HUB).emitUnfollowedEvent(currentFollowerProfileId, _followedProfileId);
        } else {
            unchecked {
                _followerCount++;
            }
        }
        _baseFollow({followerProfileId: newFollowerProfileId, followTokenId: followTokenId, isOriginalFollow: false});
    }
    function _baseFollow(
        uint256 followerProfileId,
        uint256 followTokenId,
        bool isOriginalFollow
    ) internal {
        _followTokenIdByFollowerProfileId[followerProfileId] = followTokenId;
        _followDataByFollowTokenId[followTokenId].followerProfileId = uint160(followerProfileId);
        _followDataByFollowTokenId[followTokenId].followTimestamp = uint48(block.timestamp);
        delete _followDataByFollowTokenId[followTokenId].profileIdAllowedToRecover;
        if (isOriginalFollow) {
            _followDataByFollowTokenId[followTokenId].originalFollowTimestamp = uint48(block.timestamp);
        } else {
            if (_followDataByFollowTokenId[followTokenId].originalFollowTimestamp == 0) {
                uint48 mintTimestamp = uint48(StorageLib.getTokenData(followTokenId).mintTimestamp);
                _followDataByFollowTokenId[followTokenId].originalFollowTimestamp = mintTimestamp;
            }
        }
    }
    function _unfollowIfHasFollower(uint256 followTokenId) internal {
        uint256 followerProfileId = _followDataByFollowTokenId[followTokenId].followerProfileId;
        if (followerProfileId != 0) {
            _unfollow(followerProfileId, followTokenId);
            ILensHub(HUB).emitUnfollowedEvent(followerProfileId, _followedProfileId);
        }
    }
    function _unfollow(uint256 unfollower, uint256 followTokenId) internal {
        unchecked {
            _followerCount--;
        }
        delete _followTokenIdByFollowerProfileId[unfollower];
        delete _followDataByFollowTokenId[followTokenId].followerProfileId;
        delete _followDataByFollowTokenId[followTokenId].followTimestamp;
        delete _followDataByFollowTokenId[followTokenId].profileIdAllowedToRecover;
    }
    function _approveFollow(uint256 approvedProfileId, uint256 followTokenId) internal {
        _followApprovalByFollowTokenId[followTokenId] = approvedProfileId;
        emit FollowApproval(approvedProfileId, followTokenId);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 followTokenId
    ) internal override {
        if (from != address(0)) {
            _approveFollow(0, followTokenId);
        }
        super._beforeTokenTransfer(from, to, followTokenId);
    }
    function _getReceiver(
        uint256 
    ) internal view override returns (address) {
        return IERC721(HUB).ownerOf(_followedProfileId);
    }
    function _beforeRoyaltiesSet(
        uint256 
    ) internal view override {
        if (IERC721(HUB).ownerOf(_followedProfileId) != msg.sender) {
            revert Errors.NotProfileOwner();
        }
    }
    function _isFollowTokenWrapped(uint256 followTokenId) internal view returns (bool) {
        return _exists(followTokenId);
    }
    function _getRoyaltiesInBasisPointsSlot() internal pure override returns (uint256) {
        uint256 slot;
        assembly {
            slot := _royaltiesInBasisPoints.slot
        }
        return slot;
    }
    function tryMigrate(
        uint256 followerProfileId,
        address followerProfileOwner,
        uint256 idOfProfileFollowed,
        uint256 followTokenId
    ) external onlyHub returns (uint48) {
        if (_followDataByFollowTokenId[followTokenId].originalFollowTimestamp != 0) {
            return 0; 
        }
        if (_followedProfileId != idOfProfileFollowed) {
            revert Errors.InvalidParameter();
        }
        if (!_exists(followTokenId)) {
            return 0; 
        }
        address followTokenOwner = ownerOf(followTokenId);
        if (followerProfileOwner != followTokenOwner) {
            return 0; 
        }
        unchecked {
            ++_followerCount;
        }
        _followTokenIdByFollowerProfileId[followerProfileId] = followTokenId;
        uint48 mintTimestamp = uint48(StorageLib.getTokenData(followTokenId).mintTimestamp);
        _followDataByFollowTokenId[followTokenId].followerProfileId = uint160(followerProfileId);
        _followDataByFollowTokenId[followTokenId].originalFollowTimestamp = mintTimestamp;
        _followDataByFollowTokenId[followTokenId].followTimestamp = mintTimestamp;
        super._burn(followTokenId);
        return mintTimestamp;
    }
}