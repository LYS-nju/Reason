pragma solidity ^0.8.19;
interface IERC721Burnable {
    function burn(uint256 tokenId) external;
}
interface IERC721MetaTx {
    function nonces(address signer) external view returns (uint256);
    function getDomainSeparator() external view returns (bytes32);
}
interface ILensHubEventHooks {
    function emitUnfollowedEvent(uint256 unfollowerProfileId, uint256 idOfProfileUnfollowed) external;
}
interface ILensImplGetters {
    function getFollowNFTImpl() external view returns (address);
    function getCollectNFTImpl() external view returns (address);
}
library Types {
    struct TokenData {
        address owner;
        uint96 mintTimestamp;
    }
    struct FollowData {
        uint160 followerProfileId;
        uint48 originalFollowTimestamp;
        uint48 followTimestamp;
        uint256 profileIdAllowedToRecover;
    }
    enum ProtocolState {
        Unpaused,
        PublishingPaused,
        Paused
    }
    enum PublicationType {
        Nonexistent,
        Post,
        Comment,
        Mirror,
        Quote
    }
    struct EIP712Signature {
        address signer;
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 deadline;
    }
    struct Profile {
        uint256 pubCount; 
        address followModule; 
        address followNFT; 
        string __DEPRECATED__handle; 
        string imageURI; 
        string __DEPRECATED__followNFTURI; 
        string metadataURI; 
    }
    struct Publication {
        uint256 pointedProfileId;
        uint256 pointedPubId;
        string contentURI;
        address referenceModule;
        address __DEPRECATED__collectModule; 
        address __DEPRECATED__collectNFT; 
        PublicationType pubType;
        uint256 rootProfileId;
        uint256 rootPubId;
        uint256 enabledActionModulesBitmap; 
    }
    struct CreateProfileParams {
        address to;
        string imageURI;
        address followModule;
        bytes followModuleInitData;
    }
    struct PostParams {
        uint256 profileId;
        string contentURI;
        address[] actionModules;
        bytes[] actionModulesInitDatas;
        address referenceModule;
        bytes referenceModuleInitData;
    }
    struct CommentParams {
        uint256 profileId;
        string contentURI;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        bytes referenceModuleData;
        address[] actionModules;
        bytes[] actionModulesInitDatas;
        address referenceModule;
        bytes referenceModuleInitData;
    }
    struct QuoteParams {
        uint256 profileId;
        string contentURI;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        bytes referenceModuleData;
        address[] actionModules;
        bytes[] actionModulesInitDatas;
        address referenceModule;
        bytes referenceModuleInitData;
    }
    struct ReferencePubParams {
        uint256 profileId;
        string contentURI;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        bytes referenceModuleData;
        address[] actionModules;
        bytes[] actionModulesInitDatas;
        address referenceModule;
        bytes referenceModuleInitData;
    }
    struct MirrorParams {
        uint256 profileId;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        bytes referenceModuleData;
    }
    struct CollectParams {
        uint256 publicationCollectedProfileId;
        uint256 publicationCollectedId;
        uint256 collectorProfileId;
        uint256 referrerProfileId;
        uint256 referrerPubId;
        bytes collectModuleData;
    }
    struct PublicationActionParams {
        uint256 publicationActedProfileId;
        uint256 publicationActedId;
        uint256 actorProfileId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        address actionModuleAddress;
        bytes actionModuleData;
    }
    struct ProcessActionParams {
        uint256 publicationActedProfileId;
        uint256 publicationActedId;
        uint256 actorProfileId;
        address actorProfileOwner;
        address transactionExecutor;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        Types.PublicationType[] referrerPubTypes;
        bytes actionModuleData;
    }
    struct ProcessCollectParams {
        uint256 publicationCollectedProfileId;
        uint256 publicationCollectedId;
        uint256 collectorProfileId;
        address collectorProfileOwner;
        address transactionExecutor;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        Types.PublicationType[] referrerPubTypes;
        bytes data;
    }
    struct ProcessCommentParams {
        uint256 profileId;
        address transactionExecutor;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        Types.PublicationType[] referrerPubTypes;
        bytes data;
    }
    struct ProcessQuoteParams {
        uint256 profileId;
        address transactionExecutor;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        Types.PublicationType[] referrerPubTypes;
        bytes data;
    }
    struct ProcessMirrorParams {
        uint256 profileId;
        address transactionExecutor;
        uint256 pointedProfileId;
        uint256 pointedPubId;
        uint256[] referrerProfileIds;
        uint256[] referrerPubIds;
        Types.PublicationType[] referrerPubTypes;
        bytes data;
    }
    struct DelegatedExecutorsConfig {
        mapping(uint256 => mapping(address => bool)) isApproved; 
        uint64 configNumber;
        uint64 prevConfigNumber;
        uint64 maxConfigNumberSet;
    }
    struct ActionModuleWhitelistData {
        uint248 id;
        bool isWhitelisted;
    }
}
library TokenURIMainFontLib {
    function getFontName() internal pure returns (string memory) {
        return 'Ginto Nord';
    }
    function getFontBase64Encoded() external pure returns (string memory) {
        return
            '@font-face{font-family:"Ginto Nord";src:url(data:application/font-woff;charset=utf-8;base64,d09GRgABAAAAACKUAA4AAAAAQAwAARmaAAAAAAAAAAAAAAAAAAAAAAAAAABPUy8yAAABRAAAAFUAAABgXW6BgGNtYXAAAAGcAAAAjAAAAXLpzuMfY3Z0IAAAAigAAABeAAAAihVLIuhmcGdtAAACiAAABvIAAA4VnjYU0Gdhc3AAAAl8AAAACAAAAAgAAAAQZ2x5ZgAACYQAABMkAAAkgGzo2S1oZWFkAAAcqAAAADYAAAA2GfI/q2hoZWEAABzgAAAAHgAAACQDvQO5aG10eAAAHQAAAACnAAAArHm+BYRsb2NhAAAdqAAAAFgAAABYvpjHhm1heHAAAB4AAAAAIAAAACAB2w7DbmFtZQAAHiAAAAOvAAAHs7kildFwb3N0AAAh0AAAABQAAAAg/7gAXXByZXAAACHkAAAArgAAAMuEpHX+eJxjYGG6wrSHgZWBg6mLKYKBgcEbQjPGMRgxxjMwMHEzsDAzMbExsQDl2AUYEMDRydmFQQEIq5jF/usxnGD+yaiiwMAwGSTH5Ak0kwEoxw0AJjsLwwAAAHicY2BgYGaAYBkGRgYQyAHyGMF8FoYAIC0AhCB5BQZlBj0GSwYHhniGqv
    }
}
library TokenURISecondaryFontLib {
    function getFontName() internal pure returns (string memory) {
        return 'Ginto';
    }
    function getFontBase64Encoded() external pure returns (string memory) {
        return
            '@font-face{font-family:"Ginto";src:url(data:application/font-woff;charset=utf-8;base64,d09GRgABAAAAACbYAA4AAAAARJAAARmaAAAAAAAAAAAAAAAAAAAAAAAAAABPUy8yAAABRAAAAFcAAABgXA+As2NtYXAAAAGcAAAAqAAAAXJsSC7NY3Z0IAAAAkQAAABeAAAAihGhH9lmcGdtAAACpAAABvIAAA4VnjYU0Gdhc3AAAAmYAAAACAAAAAgAAAAQZ2x5ZgAACaAAABbOAAAoaGc4A+poZWFkAAAgcAAAADYAAAA2GT4/RGhoZWEAACCoAAAAHAAAACQD0AL4aG10eAAAIMQAAADxAAABFJpSDp9sb2NhAAAhuAAAAIwAAACMXylpLm1heHAAACJEAAAAIAAAACAB2w7DbmFtZQAAImQAAAOvAAAHs7kildFwb3N0AAAmFAAAABQAAAAg/7gAd3ByZXAAACYoAAAArgAAAMuEpHX+eJxjYGGyYZzAwMrAwdTFFMHAwOANoRnjGIwYdRgYmLgZWJiZmNiYWIBy7AIMCODo5OzC4MCgwFDFLPZfj+EE809GFQUGhskgOcYvTHuAlAIDNwDbtAuVAHicY2BgYGaAYBkGRgYQyAHyGMF8FoYAIC0AhCB5BQZlBj0GS4YohniGqv
    }
}
contract ImmutableOwnable {
    address public immutable OWNER;
    address public immutable LENS_HUB;
    error OnlyOwner();
    error OnlyOwnerOrHub();
    modifier onlyOwner() {
        if (msg.sender != OWNER) {
            revert OnlyOwner();
        }
        _;
    }
    modifier onlyOwnerOrHub() {
        if (msg.sender != OWNER && msg.sender != LENS_HUB) {
            revert OnlyOwnerOrHub();
        }
        _;
    }
    constructor(address owner, address lensHub) {
        OWNER = owner;
        LENS_HUB = lensHub;
    }
}
library RegistryErrors {
    error NotHandleOwner();
    error NotTokenOwner();
    error NotHandleNorTokenOwner();
    error OnlyLensHub();
    error NotLinked();
    error DoesNotExist();
}
library HandlesErrors {
    error HandleLengthInvalid();
    error HandleContainsInvalidCharacters();
    error HandleFirstCharInvalid();
    error NotOwnerNorWhitelisted();
    error NotOwner();
    error NotHub();
    error DoesNotExist();
    error NotEOA();
    error DisablingAlreadyTriggered();
    error GuardianEnabled();
    error AlreadyEnabled();
}
library RegistryTypes {
    struct Token {
        uint256 id; 
        address collection; 
    }
    struct Handle {
        uint256 id; 
        address collection; 
    }
}
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        if (returndata.length > 0) {
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}
library Base64 {
    string internal constant _TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";
        string memory table = _TABLE;
        string memory result = new string(4 * ((data.length + 2) / 3));
        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for {
                let dataPtr := data
                let endPtr := add(data, mload(data))
            } lt(dataPtr, endPtr) {
            } {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)
                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1) 
                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1) 
                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1) 
                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1) 
            }
            switch mod(mload(data), 3)
            case 1 {
                mstore8(sub(resultPtr, 1), 0x3d)
                mstore8(sub(resultPtr, 2), 0x3d)
            }
            case 2 {
                mstore8(sub(resultPtr, 1), 0x3d)
            }
        }
        return result;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 result) {
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
            require(denominator > prod1);
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
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 denominator,
        Rounding rounding
    ) internal pure returns (uint256) {
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
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10**result < value ? 1 : 0);
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
            return result + (rounding == Rounding.Up && 1 << (result * 8) < value ? 1 : 0);
        }
    }
}
interface IERC721Timestamped {
    function mintTimestampOf(uint256 tokenId) external view returns (uint256);
    function tokenDataOf(uint256 tokenId) external view returns (Types.TokenData memory);
    function exists(uint256 tokenId) external view returns (bool);
    function totalSupply() external view returns (uint256);
}
interface ILensGovernable {
    function setGovernance(address newGovernance) external;
    function setEmergencyAdmin(address newEmergencyAdmin) external;
    function setState(Types.ProtocolState newState) external;
    function whitelistProfileCreator(address profileCreator, bool whitelist) external;
    function whitelistFollowModule(address followModule, bool whitelist) external;
    function whitelistReferenceModule(address referenceModule, bool whitelist) external;
    function whitelistActionModule(address actionModule, bool whitelist) external;
    function getGovernance() external view returns (address);
    function getState() external view returns (Types.ProtocolState);
    function isProfileCreatorWhitelisted(address profileCreator) external view returns (bool);
    function isFollowModuleWhitelisted(address followModule) external view returns (bool);
    function isReferenceModuleWhitelisted(address referenceModule) external view returns (bool);
    function getActionModuleWhitelistData(address actionModule)
        external
        view
        returns (Types.ActionModuleWhitelistData memory);
}
interface ILensProtocol {
    function createProfile(Types.CreateProfileParams calldata createProfileParams) external returns (uint256);
    function setProfileMetadataURI(uint256 profileId, string calldata metadataURI) external;
    function setProfileMetadataURIWithSig(
        uint256 profileId,
        string calldata metadataURI,
        Types.EIP712Signature calldata signature
    ) external;
    function setFollowModule(
        uint256 profileId,
        address followModule,
        bytes calldata followModuleInitData
    ) external;
    function setFollowModuleWithSig(
        uint256 profileId,
        address followModule,
        bytes calldata followModuleInitData,
        Types.EIP712Signature calldata signature
    ) external;
    function changeDelegatedExecutorsConfig(
        uint256 delegatorProfileId,
        address[] calldata delegatedExecutors,
        bool[] calldata approvals,
        uint64 configNumber,
        bool switchToGivenConfig
    ) external;
    function changeDelegatedExecutorsConfig(
        uint256 delegatorProfileId,
        address[] calldata delegatedExecutors,
        bool[] calldata approvals
    ) external;
    function changeDelegatedExecutorsConfigWithSig(
        uint256 delegatorProfileId,
        address[] calldata delegatedExecutors,
        bool[] calldata approvals,
        uint64 configNumber,
        bool switchToGivenConfig,
        Types.EIP712Signature calldata signature
    ) external;
    function setProfileImageURI(uint256 profileId, string calldata imageURI) external;
    function setProfileImageURIWithSig(
        uint256 profileId,
        string calldata imageURI,
        Types.EIP712Signature calldata signature
    ) external;
    function post(Types.PostParams calldata postParams) external returns (uint256);
    function postWithSig(Types.PostParams calldata postParams, Types.EIP712Signature calldata signature)
        external
        returns (uint256);
    function comment(Types.CommentParams calldata commentParams) external returns (uint256);
    function commentWithSig(Types.CommentParams calldata commentParams, Types.EIP712Signature calldata signature)
        external
        returns (uint256);
    function mirror(Types.MirrorParams calldata mirrorParams) external returns (uint256);
    function mirrorWithSig(Types.MirrorParams calldata mirrorParams, Types.EIP712Signature calldata signature)
        external
        returns (uint256);
    function quote(Types.QuoteParams calldata quoteParams) external returns (uint256);
    function quoteWithSig(Types.QuoteParams calldata quoteParams, Types.EIP712Signature calldata signature)
        external
        returns (uint256);
    function follow(
        uint256 followerProfileId,
        uint256[] calldata idsOfProfilesToFollow,
        uint256[] calldata followTokenIds,
        bytes[] calldata datas
    ) external returns (uint256[] memory);
    function followWithSig(
        uint256 followerProfileId,
        uint256[] calldata idsOfProfilesToFollow,
        uint256[] calldata followTokenIds,
        bytes[] calldata datas,
        Types.EIP712Signature calldata signature
    ) external returns (uint256[] memory);
    function unfollow(uint256 unfollowerProfileId, uint256[] calldata idsOfProfilesToUnfollow) external;
    function unfollowWithSig(
        uint256 unfollowerProfileId,
        uint256[] calldata idsOfProfilesToUnfollow,
        Types.EIP712Signature calldata signature
    ) external;
    function setBlockStatus(
        uint256 byProfileId,
        uint256[] calldata idsOfProfilesToSetBlockStatus,
        bool[] calldata blockStatus
    ) external;
    function setBlockStatusWithSig(
        uint256 byProfileId,
        uint256[] calldata idsOfProfilesToSetBlockStatus,
        bool[] calldata blockStatus,
        Types.EIP712Signature calldata signature
    ) external;
    function collect(Types.CollectParams calldata collectParams) external returns (uint256);
    function collectWithSig(Types.CollectParams calldata collectParams, Types.EIP712Signature calldata signature)
        external
        returns (uint256);
    function act(Types.PublicationActionParams calldata publicationActionParams) external returns (bytes memory);
    function actWithSig(
        Types.PublicationActionParams calldata publicationActionParams,
        Types.EIP712Signature calldata signature
    ) external returns (bytes memory);
    function isFollowing(uint256 followerProfileId, uint256 followedProfileId) external view returns (bool);
    function isDelegatedExecutorApproved(
        uint256 delegatorProfileId,
        address delegatedExecutor,
        uint64 configNumber
    ) external view returns (bool);
    function isDelegatedExecutorApproved(uint256 delegatorProfileId, address delegatedExecutor)
        external
        view
        returns (bool);
    function getDelegatedExecutorsConfigNumber(uint256 delegatorProfileId) external view returns (uint64);
    function getDelegatedExecutorsPrevConfigNumber(uint256 delegatorProfileId) external view returns (uint64);
    function getDelegatedExecutorsMaxConfigNumberSet(uint256 delegatorProfileId) external view returns (uint64);
    function isBlocked(uint256 profileId, uint256 byProfileId) external view returns (bool);
    function getActionModuleById(uint256 id) external view returns (address);
    function getContentURI(uint256 profileId, uint256 pubId) external view returns (string memory);
    function getProfile(uint256 profileId) external view returns (Types.Profile memory);
    function getPublication(uint256 profileId, uint256 pubId) external view returns (Types.Publication memory);
    function getPublicationType(uint256 profileId, uint256 pubId) external view returns (Types.PublicationType);
}
library HandlesEvents {
    event HandleMinted(string handle, string namespace, uint256 handleId, address to, uint256 timestamp);
    event TokenGuardianStateChanged(
        address indexed wallet,
        bool indexed enabled,
        uint256 tokenGuardianDisablingTimestamp,
        uint256 timestamp
    );
}
library RegistryEvents {
    event HandleLinked(RegistryTypes.Handle handle, RegistryTypes.Token token, uint256 timestamp);
    event HandleUnlinked(RegistryTypes.Handle handle, RegistryTypes.Token token, uint256 timestamp);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool _approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
interface ILensHandles is IERC721 {
    function mintHandle(address to, string calldata localName) external returns (uint256);
    function burn(uint256 tokenId) external;
    function getNamespace() external pure returns (string memory);
    function getNamespaceHash() external pure returns (bytes32);
    function exists(uint256 tokenId) external view returns (bool);
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
library HandleTokenURILib {
    using Strings for uint256;
    function getTokenURI(uint256 tokenId, string memory localName) external pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    'data:application/json;base64,',
                    Base64.encode(
                        abi.encodePacked(
                            '{"name":"@',
                            localName,
                            '","description":"Lens Protocol - @',
                            localName,
                            '","image":"data:image/svg+xml;base64,',
                            _getSVGImageBase64Encoded(localName),
                            '","attributes":[{"display_type": "number", "trait_type":"ID","value":"',
                            tokenId.toString(),
                            '"},{"trait_type":"NAMESPACE","value":".lens"},{"trait_type":"LENGTH","value":"',
                            bytes(localName).length.toString(),
                            '"}]}'
                        )
                    )
                )
            );
    }
    function _getSVGImageBase64Encoded(string memory localName) private pure returns (string memory) {
        return
            Base64.encode(
                abi.encodePacked(
                    '<svg width="724" height="724" viewBox="0 0 724 724" fill="none" xmlns="http:
                    TokenURIMainFontLib.getFontBase64Encoded(),
                    '</style></defs><defs><style>',
                    TokenURISecondaryFontLib.getFontBase64Encoded(),
                    '</style></defs><g clip-path="url(#clip0_2578_6956)"><rect width="724" height="724" fill="#DBCCF3"/><ellipse cx="362" cy="362" rx="322" ry="212" fill="#FFEBB8"/><text opacity="0.7" fill="#5A4E4C" text-anchor="middle" font-family="',
                    TokenURISecondaryFontLib.getFontName(),
                    '" font-size="26" letter-spacing="-0.2px"><tspan x="50%" y="469.016">Lens Handle</tspan></text><text fill="#5A4E4C" text-anchor="middle" font-family="',
                    TokenURIMainFontLib.getFontName(),
                    '" font-size="',
                    _localNameLengthToFontSize(bytes(localName).length).toString(),
                    '" letter-spacing="-2px"><tspan x="50%" y="430.562">@',
                    localName,
                    '</tspan></text><path d="M395.81 268.567C395.125 269.262 394.48 269.964 393.821 270.66C393.821 269.698 393.879 268.71 393.879 267.761C393.879 266.812 393.879 265.765 393.834 264.777C392.711 223.741 331.286 223.741 330.162 264.777C330.137 265.765 330.124 266.76 330.124 267.761C330.124 268.742 330.156 269.711 330.182 270.66C329.536 269.964 328.891 269.262 328.193 268.567C327.496 267.871 326.773 267.163 326.063 266.487C296.422 238.269 253.017 282.035 281.037 311.813C281.717 312.532 282.408 313.247 283.109 313.958C316.921 348 361.998 348 361.998 348C361.998 348 407.082 348 440.894 313.958C441.6 313.252 442.291 312.537 442.966 311.813C470.987 282.003 427.555 238.269 397.94 266.487C397.224 267.163 396.494 267.858 395.81 268.567Z" fill="#5A4E4C" fill-opacity="0.2"/><path d="M388.109 299.431C387.081 299.431 386.082 299.508 385.117 299.654C387.515 300.895 389.155 303.41 389.155 306.312C389.155 310.444 385.828 313.793 381.724 313.793C377.62 313.793 374.293 310.444 374.293 306.312C374.293 306.075 374.304 305.841 374.325 305.61C372.492 307.896 371.445 310.629 371.445 313.477H366.242C366.242 302.505 376.402 294.228 388.109 294.228C399.816 294.228 409.976 302.505 409.976 313.477H404.773C404.773 306.066 397.681 299.431 388.109 299.431ZM322.177 305.383C320.117 307.754 318.929 310.658 318.929 313.694H313.726C313.726 302.715 323.887 294.445 335.593 294.445C347.3 294.445 357.46 302.715 357.46 313.694H352.257C352.257 306.277 345.167 299.648 335.593 299.648C334.775 299.648 333.975 299.696 333.196 299.79C335.457 301.073 336.983 303.513 336.983 306.312C336.983 310.444 333.656 313.793 329.552 313.793C325.448 313.793 322.121 310.444 322.121 306.312C322.121 305.997 322.14 305.687 322.177 305.383ZM371.792 322.293C370.159 325.282 366.472 327.601 361.976 327.601C357.468 327.601 353.793 325.307 352.164 322.301L347.589 324.779C350.222 329.638 355.765 332.804 361.976 332.804C368.196 332.804 373.73 329.598 376.358 324.787L371.792 322.293Z" fill="#5A4E4C"/></g><defs><clipPath id="clip0_2578_6956"><rect width="724" height="724"/></clipPath></defs></svg>'
                )
            );
    }
    function _localNameLengthToFontSize(uint256 localNameLength) internal pure returns (uint256) {
        return (664301 * localNameLength * localNameLength + 790000000 - 41066900 * localNameLength) / 10000000;
    }
}
interface ILensERC721 is IERC721, IERC721Timestamped, IERC721Burnable, IERC721MetaTx, IERC721Metadata {}
interface ILensProfiles is ILensERC721 {
    function DANGER__disableTokenGuardian() external;
    function enableTokenGuardian() external;
    function getTokenGuardianDisablingTimestamp(address wallet) external view returns (uint256);
}
contract ERC721 is Context, ERC165, IERC721, IERC721Metadata {
    using Address for address;
    using Strings for uint256;
    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId, 1);
        require(!_exists(tokenId), "ERC721: token already minted");
        unchecked {
            _balances[to] += 1;
        }
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId, 1);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId, 1);
        owner = ERC721.ownerOf(tokenId);
        delete _tokenApprovals[tokenId];
        unchecked {
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId, 1);
        require(ERC721.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        delete _tokenApprovals[tokenId];
        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId, 1);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721.ownerOf(tokenId), to, tokenId);
    }
    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256, 
        uint256 batchSize
    ) internal virtual {
        if (batchSize > 1) {
            if (from != address(0)) {
                _balances[from] -= batchSize;
            }
            if (to != address(0)) {
                _balances[to] += batchSize;
            }
        }
    }
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual {}
}
interface ILensHub is ILensProfiles, ILensProtocol, ILensGovernable, ILensHubEventHooks, ILensImplGetters {}
contract LensHandles is ERC721, ImmutableOwnable, ILensHandles {
    using Address for address;
    uint256 internal constant MAX_HANDLE_LENGTH = 31;
    string internal constant NAMESPACE = 'lens';
    uint256 internal immutable NAMESPACE_LENGTH = bytes(NAMESPACE).length;
    uint256 internal constant SEPARATOR_LENGTH = 1; 
    bytes32 internal constant NAMESPACE_HASH = keccak256(bytes(NAMESPACE));
    uint256 internal immutable TOKEN_GUARDIAN_COOLDOWN;
    mapping(address => uint256) internal _tokenGuardianDisablingTimestamp;
    mapping(uint256 tokenId => string localName) internal _localNames;
    modifier onlyOwnerOrWhitelistedProfileCreator() {
        if (
            msg.sender != OWNER && !ILensHub(LENS_HUB).isProfileCreatorWhitelisted(msg.sender)
        ) {
            revert HandlesErrors.NotOwnerNorWhitelisted();
        }
        _;
    }
    modifier onlyEOA() {
        if (msg.sender.isContract()) {
            revert HandlesErrors.NotEOA();
        }
        _;
    }
    modifier onlyHub() {
        if (msg.sender != LENS_HUB) {
            revert HandlesErrors.NotHub();
        }
        _;
    }
    constructor(
        address owner,
        address lensHub,
        uint256 tokenGuardianCooldown
    ) ERC721('', '') ImmutableOwnable(owner, lensHub) {
        TOKEN_GUARDIAN_COOLDOWN = tokenGuardianCooldown;
    }
    function name() public pure override returns (string memory) {
        return string.concat(symbol(), ' Handles');
    }
    function symbol() public pure override returns (string memory) {
        return string.concat('.', NAMESPACE);
    }
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);
        return HandleTokenURILib.getTokenURI(tokenId, _localNames[tokenId]);
    }
    function mintHandle(address to, string calldata localName)
        external
        onlyOwnerOrWhitelistedProfileCreator
        returns (uint256)
    {
        _validateLocalName(localName);
        return _mintHandle(to, localName);
    }
    function migrateHandle(address to, string calldata localName) external onlyHub returns (uint256) {
        _validateLocalNameMigration(localName);
        return _mintHandle(to, localName);
    }
    function burn(uint256 tokenId) external {
        if (msg.sender != ownerOf(tokenId)) {
            revert HandlesErrors.NotOwner();
        }
        _burn(tokenId);
        delete _localNames[tokenId];
    }
    function DANGER__disableTokenGuardian() external onlyEOA {
        if (_tokenGuardianDisablingTimestamp[msg.sender] != 0) {
            revert HandlesErrors.DisablingAlreadyTriggered();
        }
        _tokenGuardianDisablingTimestamp[msg.sender] = block.timestamp + TOKEN_GUARDIAN_COOLDOWN;
        emit HandlesEvents.TokenGuardianStateChanged({
            wallet: msg.sender,
            enabled: false,
            tokenGuardianDisablingTimestamp: block.timestamp + TOKEN_GUARDIAN_COOLDOWN,
            timestamp: block.timestamp
        });
    }
    function enableTokenGuardian() external onlyEOA {
        if (_tokenGuardianDisablingTimestamp[msg.sender] == 0) {
            revert HandlesErrors.AlreadyEnabled();
        }
        _tokenGuardianDisablingTimestamp[msg.sender] = 0;
        emit HandlesEvents.TokenGuardianStateChanged({
            wallet: msg.sender,
            enabled: true,
            tokenGuardianDisablingTimestamp: 0,
            timestamp: block.timestamp
        });
    }
    function approve(address to, uint256 tokenId) public override(IERC721, ERC721) {
        if (to != address(0) && _hasTokenGuardianEnabled(msg.sender)) {
            revert HandlesErrors.GuardianEnabled();
        }
        super.approve(to, tokenId);
    }
    function setApprovalForAll(address operator, bool approved) public override(IERC721, ERC721) {
        if (approved && _hasTokenGuardianEnabled(msg.sender)) {
            revert HandlesErrors.GuardianEnabled();
        }
        super.setApprovalForAll(operator, approved);
    }
    function exists(uint256 tokenId) external view returns (bool) {
        return _exists(tokenId);
    }
    function getNamespace() external pure returns (string memory) {
        return NAMESPACE;
    }
    function getNamespaceHash() external pure returns (bytes32) {
        return NAMESPACE_HASH;
    }
    function getLocalName(uint256 tokenId) public view returns (string memory) {
        string memory localName = _localNames[tokenId];
        if (bytes(localName).length == 0) {
            revert HandlesErrors.DoesNotExist();
        }
        return _localNames[tokenId];
    }
    function getHandle(uint256 tokenId) public view returns (string memory) {
        string memory localName = getLocalName(tokenId);
        return string.concat(localName, '.', NAMESPACE);
    }
    function getTokenId(string memory localName) public pure returns (uint256) {
        return uint256(keccak256(bytes(localName)));
    }
    function getTokenGuardianDisablingTimestamp(address wallet) external view returns (uint256) {
        return _tokenGuardianDisablingTimestamp[wallet];
    }
    function _mintHandle(address to, string calldata localName) internal returns (uint256) {
        uint256 tokenId = getTokenId(localName);
        _mint(to, tokenId);
        _localNames[tokenId] = localName;
        emit HandlesEvents.HandleMinted(localName, NAMESPACE, tokenId, to, block.timestamp);
        return tokenId;
    }
    function _validateLocalNameMigration(string memory localName) internal view {
        bytes memory localNameAsBytes = bytes(localName);
        uint256 localNameLength = localNameAsBytes.length;
        if (localNameLength == 0 || localNameLength + SEPARATOR_LENGTH + NAMESPACE_LENGTH > MAX_HANDLE_LENGTH) {
            revert HandlesErrors.HandleLengthInvalid();
        }
        bytes1 firstByte = localNameAsBytes[0];
        if (firstByte == '-' || firstByte == '_') {
            revert HandlesErrors.HandleFirstCharInvalid();
        }
        uint256 i;
        while (i < localNameLength) {
            if (!_isAlphaNumeric(localNameAsBytes[i]) && localNameAsBytes[i] != '-' && localNameAsBytes[i] != '_') {
                revert HandlesErrors.HandleContainsInvalidCharacters();
            }
            unchecked {
                ++i;
            }
        }
    }
    function _validateLocalName(string memory localName) internal view {
        bytes memory localNameAsBytes = bytes(localName);
        uint256 localNameLength = localNameAsBytes.length;
        if (localNameLength == 0 || localNameLength + SEPARATOR_LENGTH + NAMESPACE_LENGTH > MAX_HANDLE_LENGTH) {
            revert HandlesErrors.HandleLengthInvalid();
        }
        if (localNameAsBytes[0] == '_') {
            revert HandlesErrors.HandleFirstCharInvalid();
        }
        uint256 i;
        while (i < localNameLength) {
            if (!_isAlphaNumeric(localNameAsBytes[i]) && localNameAsBytes[i] != '_') {
                revert HandlesErrors.HandleContainsInvalidCharacters();
            }
            unchecked {
                ++i;
            }
        }
    }
    function _isAlphaNumeric(bytes1 char) internal pure returns (bool) {
        return (char >= '0' && char <= '9') || (char >= 'a' && char <= 'z');
    }
    function _hasTokenGuardianEnabled(address wallet) internal view returns (bool) {
        return
            !wallet.isContract() &&
            (_tokenGuardianDisablingTimestamp[wallet] == 0 ||
                block.timestamp < _tokenGuardianDisablingTimestamp[wallet]);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 ,
        uint256 batchSize
    ) internal override {
        if (from != address(0) && _hasTokenGuardianEnabled(from)) {
            revert HandlesErrors.GuardianEnabled();
        }
        super._beforeTokenTransfer(from, to, 0, batchSize);
    }
}