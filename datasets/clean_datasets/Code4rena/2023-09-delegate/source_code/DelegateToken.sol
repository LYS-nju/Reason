pragma solidity ^0.8.21;
interface IDelegateRegistry {
    enum DelegationType {
        NONE,
        ALL,
        CONTRACT,
        ERC721,
        ERC20,
        ERC1155
    }
    struct Delegation {
        DelegationType type_;
        address to;
        address from;
        bytes32 rights;
        address contract_;
        uint256 tokenId;
        uint256 amount;
    }
    event DelegateAll(address indexed from, address indexed to, bytes32 rights, bool enable);
    event DelegateContract(address indexed from, address indexed to, address indexed contract_, bytes32 rights, bool enable);
    event DelegateERC721(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, bool enable);
    event DelegateERC20(address indexed from, address indexed to, address indexed contract_, bytes32 rights, uint256 amount);
    event DelegateERC1155(address indexed from, address indexed to, address indexed contract_, uint256 tokenId, bytes32 rights, uint256 amount);
    error MulticallFailed();
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
    function delegateAll(address to, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);
    function delegateContract(address to, address contract_, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);
    function delegateERC721(address to, address contract_, uint256 tokenId, bytes32 rights, bool enable) external payable returns (bytes32 delegationHash);
    function delegateERC20(address to, address contract_, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);
    function delegateERC1155(address to, address contract_, uint256 tokenId, bytes32 rights, uint256 amount) external payable returns (bytes32 delegationHash);
    function checkDelegateForAll(address to, address from, bytes32 rights) external view returns (bool);
    function checkDelegateForContract(address to, address from, address contract_, bytes32 rights) external view returns (bool);
    function checkDelegateForERC721(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (bool);
    function checkDelegateForERC20(address to, address from, address contract_, bytes32 rights) external view returns (uint256);
    function checkDelegateForERC1155(address to, address from, address contract_, uint256 tokenId, bytes32 rights) external view returns (uint256);
    function getIncomingDelegations(address to) external view returns (Delegation[] memory delegations);
    function getOutgoingDelegations(address from) external view returns (Delegation[] memory delegations);
    function getIncomingDelegationHashes(address to) external view returns (bytes32[] memory delegationHashes);
    function getOutgoingDelegationHashes(address from) external view returns (bytes32[] memory delegationHashes);
    function getDelegationsFromHashes(bytes32[] calldata delegationHashes) external view returns (Delegation[] memory delegations);
    function readSlot(bytes32 location) external view returns (bytes32);
    function readSlots(bytes32[] calldata locations) external view returns (bytes32[] memory);
}
library RegistryStorage {
    address internal constant DELEGATION_EMPTY = address(0);
    address internal constant DELEGATION_REVOKED = address(1);
    uint256 internal constant POSITIONS_FIRST_PACKED = 0; 
    uint256 internal constant POSITIONS_SECOND_PACKED = 1; 
    uint256 internal constant POSITIONS_RIGHTS = 2;
    uint256 internal constant POSITIONS_TOKEN_ID = 3;
    uint256 internal constant POSITIONS_AMOUNT = 4;
    uint256 internal constant CLEAN_ADDRESS = 0x00ffffffffffffffffffffffffffffffffffffffff;
    uint256 internal constant CLEAN_FIRST8_BYTES_ADDRESS = 0xffffffffffffffff << 96;
    uint256 internal constant CLEAN_PACKED8_BYTES_ADDRESS = 0xffffffffffffffff << 160;
    function packAddresses(address from, address to, address contract_) internal pure returns (bytes32 firstPacked, bytes32 secondPacked) {
        assembly {
            firstPacked := or(shl(64, and(contract_, CLEAN_FIRST8_BYTES_ADDRESS)), and(from, CLEAN_ADDRESS))
            secondPacked := or(shl(160, contract_), and(to, CLEAN_ADDRESS))
        }
    }
    function unpackAddresses(bytes32 firstPacked, bytes32 secondPacked) internal pure returns (address from, address to, address contract_) {
        assembly {
            from := and(firstPacked, CLEAN_ADDRESS)
            to := and(secondPacked, CLEAN_ADDRESS)
            contract_ := or(shr(64, and(firstPacked, CLEAN_PACKED8_BYTES_ADDRESS)), shr(160, secondPacked))
        }
    }
    function unpackAddress(bytes32 packedSlot) internal pure returns (address unpacked) {
        assembly {
            unpacked := and(packedSlot, CLEAN_ADDRESS)
        }
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
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
            require(denominator > prod1, "Math: mulDiv overflow");
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
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
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
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
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
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
library SignedMath {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }
    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            return uint256(n >= 0 ? n : -n);
        }
    }
}
library RegistryHashes {
    uint256 internal constant EXTRACT_LAST_BYTE = 0xff;
    uint256 internal constant ALL_TYPE = 1;
    uint256 internal constant CONTRACT_TYPE = 2;
    uint256 internal constant ERC721_TYPE = 3;
    uint256 internal constant ERC20_TYPE = 4;
    uint256 internal constant ERC1155_TYPE = 5;
    uint256 internal constant DELEGATION_SLOT = 0;
    function decodeType(bytes32 inputHash) internal pure returns (IDelegateRegistry.DelegationType decodedType) {
        assembly {
            decodedType := and(inputHash, EXTRACT_LAST_BYTE)
        }
    }
    function location(bytes32 inputHash) internal pure returns (bytes32 computedLocation) {
        assembly ("memory-safe") {
            mstore(0, inputHash)
            mstore(32, DELEGATION_SLOT)
            computedLocation := keccak256(0, 64) 
        }
    }
    function allHash(address from, bytes32 rights, address to) internal pure returns (bytes32 hash) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            hash := or(shl(8, keccak256(ptr, 72)), ALL_TYPE) 
        }
    }
    function allLocation(address from, bytes32 rights, address to) internal pure returns (bytes32 computedLocation) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            mstore(0, or(shl(8, keccak256(ptr, 72)), ALL_TYPE)) 
            mstore(32, DELEGATION_SLOT)
            computedLocation := keccak256(0, 64) 
        }
    }
    function contractHash(address from, bytes32 rights, address to, address contract_) internal pure returns (bytes32 hash) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            hash := or(shl(8, keccak256(ptr, 92)), CONTRACT_TYPE) 
        }
    }
    function contractLocation(address from, bytes32 rights, address to, address contract_) internal pure returns (bytes32 computedLocation) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            mstore(0, or(shl(8, keccak256(ptr, 92)), CONTRACT_TYPE)) 
            mstore(32, DELEGATION_SLOT)
            computedLocation := keccak256(0, 64) 
        }
    }
    function erc721Hash(address from, bytes32 rights, address to, uint256 tokenId, address contract_) internal pure returns (bytes32 hash) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 92), tokenId)
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            hash := or(shl(8, keccak256(ptr, 124)), ERC721_TYPE) 
        }
    }
    function erc721Location(address from, bytes32 rights, address to, uint256 tokenId, address contract_) internal pure returns (bytes32 computedLocation) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 92), tokenId)
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            mstore(0, or(shl(8, keccak256(ptr, 124)), ERC721_TYPE)) 
            mstore(32, DELEGATION_SLOT)
            computedLocation := keccak256(0, 64) 
        }
    }
    function erc20Hash(address from, bytes32 rights, address to, address contract_) internal pure returns (bytes32 hash) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            hash := or(shl(8, keccak256(ptr, 92)), ERC20_TYPE) 
        }
    }
    function erc20Location(address from, bytes32 rights, address to, address contract_) internal pure returns (bytes32 computedLocation) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            mstore(0, or(shl(8, keccak256(ptr, 92)), ERC20_TYPE)) 
            mstore(32, DELEGATION_SLOT)
            computedLocation := keccak256(0, 64) 
        }
    }
    function erc1155Hash(address from, bytes32 rights, address to, uint256 tokenId, address contract_) internal pure returns (bytes32 hash) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 92), tokenId)
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            hash := or(shl(8, keccak256(ptr, 124)), ERC1155_TYPE) 
        }
    }
    function erc1155Location(address from, bytes32 rights, address to, uint256 tokenId, address contract_) internal pure returns (bytes32 computedLocation) {
        assembly ("memory-safe") {
            let ptr := mload(64) 
            mstore(add(ptr, 92), tokenId)
            mstore(add(ptr, 60), contract_)
            mstore(add(ptr, 40), to)
            mstore(add(ptr, 20), from)
            mstore(ptr, rights)
            mstore(0, or(shl(8, keccak256(ptr, 124)), ERC1155_TYPE)) 
            mstore(32, DELEGATION_SLOT)
            computedLocation := keccak256(0, 64) 
        }
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC2981 is IERC165 {
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view returns (address receiver, uint256 royaltyAmount);
}
interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(
        address[] calldata accounts,
        uint256[] calldata ids
    ) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
abstract contract Ownable2Step is Ownable {
    address private _pendingOwner;
    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    function pendingOwner() public view virtual returns (address) {
        return _pendingOwner;
    }
    function transferOwnership(address newOwner) public virtual override onlyOwner {
        _pendingOwner = newOwner;
        emit OwnershipTransferStarted(owner(), newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual override {
        delete _pendingOwner;
        super._transferOwnership(newOwner);
    }
    function acceptOwnership() public virtual {
        address sender = _msgSender();
        require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
        _transferOwnership(sender);
    }
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
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
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
abstract contract ERC2981 is IERC2981, ERC165 {
    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }
    RoyaltyInfo private _defaultRoyaltyInfo;
    mapping(uint256 => RoyaltyInfo) private _tokenRoyaltyInfo;
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }
    function royaltyInfo(uint256 tokenId, uint256 salePrice) public view virtual override returns (address, uint256) {
        RoyaltyInfo memory royalty = _tokenRoyaltyInfo[tokenId];
        if (royalty.receiver == address(0)) {
            royalty = _defaultRoyaltyInfo;
        }
        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / _feeDenominator();
        return (royalty.receiver, royaltyAmount);
    }
    function _feeDenominator() internal pure virtual returns (uint96) {
        return 10000;
    }
    function _setDefaultRoyalty(address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: invalid receiver");
        _defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
    }
    function _deleteDefaultRoyalty() internal virtual {
        delete _defaultRoyaltyInfo;
    }
    function _setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) internal virtual {
        require(feeNumerator <= _feeDenominator(), "ERC2981: royalty fee will exceed salePrice");
        require(receiver != address(0), "ERC2981: Invalid parameters");
        _tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
    }
    function _resetTokenRoyalty(uint256 tokenId) internal virtual {
        delete _tokenRoyaltyInfo[tokenId];
    }
}
interface IDelegateFlashloan {
    error InvalidFlashloan();
    function onFlashloan(address initiator, DelegateTokenStructs.FlashInfo calldata flashInfo) external payable returns (bytes32);
}
library DelegateTokenStructs {
    struct Uint256 {
        uint256 flag;
    }
    struct DelegateTokenParameters {
        address delegateRegistry;
        address principalToken;
        address marketMetadata;
    }
    struct DelegateInfo {
        address principalHolder;
        IDelegateRegistry.DelegationType tokenType;
        address delegateHolder;
        uint256 amount;
        address tokenContract;
        uint256 tokenId;
        bytes32 rights;
        uint256 expiry;
    }
    struct FlashInfo {
        address receiver; 
        address delegateHolder; 
        IDelegateRegistry.DelegationType tokenType; 
        address tokenContract; 
        uint256 tokenId; 
        uint256 amount; 
        bytes data; 
    }
}
library DelegateTokenErrors {
    error DelegateRegistryZero();
    error PrincipalTokenZero();
    error DelegateTokenHolderZero();
    error MarketMetadataZero();
    error ToIsZero();
    error NotERC721Receiver();
    error InvalidERC721TransferOperator();
    error ERC1155PullNotRequested(address operator);
    error BatchERC1155TransferUnsupported();
    error InsufficientAllowanceOrInvalidToken();
    error CallerNotOwnerOrInvalidToken();
    error NotOperator(address caller, address account);
    error NotApproved(address caller, uint256 delegateTokenId);
    error FromNotDelegateTokenHolder();
    error HashMismatch();
    error NotMinted(uint256 delegateTokenId);
    error AlreadyExisted(uint256 delegateTokenId);
    error WithdrawNotAvailable(uint256 delegateTokenId, uint256 expiry, uint256 timestamp);
    error ExpiryInPast();
    error ExpiryTooLarge();
    error ExpiryTooSmall();
    error WrongAmountForType(IDelegateRegistry.DelegationType tokenType, uint256 wrongAmount);
    error WrongTokenIdForType(IDelegateRegistry.DelegationType tokenType, uint256 wrongTokenId);
    error InvalidTokenType(IDelegateRegistry.DelegationType tokenType);
    error ERC721FlashUnavailable();
    error ERC20FlashAmountUnavailable();
    error ERC1155FlashAmountUnavailable();
    error BurnNotAuthorized();
    error MintNotAuthorized();
    error CallerNotPrincipalToken();
    error BurnAuthorized();
    error MintAuthorized();
    error ERC1155Pulled();
    error ERC1155NotPulled();
}
library DelegateTokenHelpers {
    function revertOnCallingInvalidFlashloan(DelegateTokenStructs.FlashInfo calldata info) internal {
        if (IDelegateFlashloan(info.receiver).onFlashloan{value: msg.value}(msg.sender, info) == IDelegateFlashloan.onFlashloan.selector) return;
        revert IDelegateFlashloan.InvalidFlashloan();
    }
    function revertOnInvalidERC721ReceiverCallback(address from, address to, uint256 delegateTokenId, bytes calldata data) internal {
        if (to.code.length == 0 || IERC721Receiver(to).onERC721Received(msg.sender, from, delegateTokenId, data) == IERC721Receiver.onERC721Received.selector) return;
        revert DelegateTokenErrors.NotERC721Receiver();
    }
    function revertOnInvalidERC721ReceiverCallback(address from, address to, uint256 delegateTokenId) internal {
        if (to.code.length == 0 || IERC721Receiver(to).onERC721Received(msg.sender, from, delegateTokenId, "") == IERC721Receiver.onERC721Received.selector) return;
        revert DelegateTokenErrors.NotERC721Receiver();
    }
    function revertOldExpiry(uint256 expiry) internal view {
        if (expiry > block.timestamp) return;
        revert DelegateTokenErrors.ExpiryInPast();
    }
    function delegateIdNoRevert(address caller, uint256 salt) internal pure returns (uint256) {
        return uint256(keccak256(abi.encode(caller, salt)));
    }
}
library DelegateTokenRegistryHelpers {
    function loadTokenHolder(address delegateRegistry, bytes32 registryHash) internal view returns (address delegateTokenHolder) {
        unchecked {
            return RegistryStorage.unpackAddress(
                IDelegateRegistry(delegateRegistry).readSlot(bytes32(uint256(RegistryHashes.location(registryHash)) + RegistryStorage.POSITIONS_SECOND_PACKED))
            );
        }
    }
    function loadContract(address delegateRegistry, bytes32 registryHash) internal view returns (address underlyingContract) {
        unchecked {
            uint256 registryLocation = uint256(RegistryHashes.location(registryHash));
            (,, underlyingContract) = RegistryStorage.unpackAddresses(
                IDelegateRegistry(delegateRegistry).readSlot(bytes32(registryLocation + RegistryStorage.POSITIONS_FIRST_PACKED)),
                IDelegateRegistry(delegateRegistry).readSlot(bytes32(registryLocation + RegistryStorage.POSITIONS_SECOND_PACKED))
            );
        }
    }
    function loadTokenHolderAndContract(address delegateRegistry, bytes32 registryHash) internal view returns (address delegateTokenHolder, address underlyingContract) {
        unchecked {
            uint256 registryLocation = uint256(RegistryHashes.location(registryHash));
            (, delegateTokenHolder, underlyingContract) = RegistryStorage.unpackAddresses(
                IDelegateRegistry(delegateRegistry).readSlot(bytes32(registryLocation + RegistryStorage.POSITIONS_FIRST_PACKED)),
                IDelegateRegistry(delegateRegistry).readSlot(bytes32(registryLocation + RegistryStorage.POSITIONS_SECOND_PACKED))
            );
        }
    }
    function loadFrom(address delegateRegistry, bytes32 registryHash) internal view returns (address) {
        unchecked {
            return RegistryStorage.unpackAddress(
                IDelegateRegistry(delegateRegistry).readSlot(bytes32(uint256(RegistryHashes.location(registryHash)) + RegistryStorage.POSITIONS_FIRST_PACKED))
            );
        }
    }
    function loadAmount(address delegateRegistry, bytes32 registryHash) internal view returns (uint256) {
        unchecked {
            return uint256(IDelegateRegistry(delegateRegistry).readSlot(bytes32(uint256(RegistryHashes.location(registryHash)) + RegistryStorage.POSITIONS_AMOUNT)));
        }
    }
    function loadRights(address delegateRegistry, bytes32 registryHash) internal view returns (bytes32) {
        unchecked {
            return IDelegateRegistry(delegateRegistry).readSlot(bytes32(uint256(RegistryHashes.location(registryHash)) + RegistryStorage.POSITIONS_RIGHTS));
        }
    }
    function loadTokenId(address delegateRegistry, bytes32 registryHash) internal view returns (uint256) {
        unchecked {
            return uint256(IDelegateRegistry(delegateRegistry).readSlot(bytes32(uint256(RegistryHashes.location(registryHash)) + RegistryStorage.POSITIONS_TOKEN_ID)));
        }
    }
    function calculateDecreasedAmount(address delegateRegistry, bytes32 registryHash, uint256 decreaseAmount) internal view returns (uint256) {
        unchecked {
            return
                uint256(IDelegateRegistry(delegateRegistry).readSlot(bytes32(uint256(RegistryHashes.location(registryHash)) + RegistryStorage.POSITIONS_AMOUNT))) - decreaseAmount;
        }
    }
    function calculateIncreasedAmount(address delegateRegistry, bytes32 registryHash, uint256 increaseAmount) internal view returns (uint256) {
        unchecked {
            return
                uint256(IDelegateRegistry(delegateRegistry).readSlot(bytes32(uint256(RegistryHashes.location(registryHash)) + RegistryStorage.POSITIONS_AMOUNT))) + increaseAmount;
        }
    }
    function revertERC721FlashUnavailable(address delegateRegistry, DelegateTokenStructs.FlashInfo calldata info) internal view {
        if (
            loadFrom(delegateRegistry, RegistryHashes.erc721Hash(address(this), "", info.delegateHolder, info.tokenId, info.tokenContract)) == address(this)
                || loadFrom(delegateRegistry, RegistryHashes.erc721Hash(address(this), "flashloan", info.delegateHolder, info.tokenId, info.tokenContract)) == address(this)
        ) return;
        revert DelegateTokenErrors.ERC721FlashUnavailable();
    }
    function revertERC20FlashAmountUnavailable(address delegateRegistry, DelegateTokenStructs.FlashInfo calldata info) internal view {
        uint256 availableAmount = 0;
        unchecked {
            availableAmount = loadAmount(delegateRegistry, RegistryHashes.erc20Hash(address(this), "flashloan", info.delegateHolder, info.tokenContract))
                + loadAmount(delegateRegistry, RegistryHashes.erc20Hash(address(this), "", info.delegateHolder, info.tokenContract));
        } 
        if (info.amount > availableAmount) revert DelegateTokenErrors.ERC20FlashAmountUnavailable();
    }
    function revertERC1155FlashAmountUnavailable(address delegateRegistry, DelegateTokenStructs.FlashInfo calldata info) internal view {
        uint256 availableAmount = 0;
        unchecked {
            availableAmount = loadAmount(delegateRegistry, RegistryHashes.erc1155Hash(address(this), "flashloan", info.delegateHolder, info.tokenId, info.tokenContract))
                + loadAmount(delegateRegistry, RegistryHashes.erc1155Hash(address(this), "", info.delegateHolder, info.tokenId, info.tokenContract));
        } 
        if (info.amount > availableAmount) {
            revert DelegateTokenErrors.ERC1155FlashAmountUnavailable();
        }
    }
    function transferERC721(
        address delegateRegistry,
        bytes32 registryHash,
        address from,
        bytes32 newRegistryHash,
        address to,
        bytes32 underlyingRights,
        address underlyingContract,
        uint256 underlyingTokenId
    ) internal {
        if (
            IDelegateRegistry(delegateRegistry).delegateERC721(from, underlyingContract, underlyingTokenId, underlyingRights, false) == registryHash
                && IDelegateRegistry(delegateRegistry).delegateERC721(to, underlyingContract, underlyingTokenId, underlyingRights, true) == newRegistryHash
        ) return;
        revert DelegateTokenErrors.HashMismatch();
    }
    function transferERC20(
        address delegateRegistry,
        bytes32 registryHash,
        address from,
        bytes32 newRegistryHash,
        address to,
        uint256 underlyingAmount,
        bytes32 underlyingRights,
        address underlyingContract
    ) internal {
        if (
            IDelegateRegistry(delegateRegistry).delegateERC20(
                from, underlyingContract, underlyingRights, calculateDecreasedAmount(delegateRegistry, registryHash, underlyingAmount)
            ) == bytes32(registryHash)
                && IDelegateRegistry(delegateRegistry).delegateERC20(
                    to, underlyingContract, underlyingRights, calculateIncreasedAmount(delegateRegistry, newRegistryHash, underlyingAmount)
                ) == newRegistryHash
        ) return;
        revert DelegateTokenErrors.HashMismatch();
    }
    function transferERC1155(
        address delegateRegistry,
        bytes32 registryHash,
        address from,
        bytes32 newRegistryHash,
        address to,
        uint256 underlyingAmount,
        bytes32 underlyingRights,
        address underlyingContract,
        uint256 underlyingTokenId
    ) internal {
        uint256 amount = calculateDecreasedAmount(delegateRegistry, registryHash, underlyingAmount);
        if (IDelegateRegistry(delegateRegistry).delegateERC1155(from, underlyingContract, underlyingTokenId, underlyingRights, amount) != registryHash) {
            revert DelegateTokenErrors.HashMismatch();
        }
        amount = calculateIncreasedAmount(delegateRegistry, newRegistryHash, underlyingAmount);
        if (IDelegateRegistry(delegateRegistry).delegateERC1155(to, underlyingContract, underlyingTokenId, underlyingRights, amount) != newRegistryHash) {
            revert DelegateTokenErrors.HashMismatch();
        }
    }
    function delegateERC721(address delegateRegistry, bytes32 newRegistryHash, DelegateTokenStructs.DelegateInfo calldata delegateInfo) internal {
        if (
            IDelegateRegistry(delegateRegistry).delegateERC721(delegateInfo.delegateHolder, delegateInfo.tokenContract, delegateInfo.tokenId, delegateInfo.rights, true)
                == newRegistryHash
        ) return;
        revert DelegateTokenErrors.HashMismatch();
    }
    function incrementERC20(address delegateRegistry, bytes32 newRegistryHash, DelegateTokenStructs.DelegateInfo calldata delegateInfo) internal {
        if (
            IDelegateRegistry(delegateRegistry).delegateERC20(
                delegateInfo.delegateHolder, delegateInfo.tokenContract, delegateInfo.rights, calculateIncreasedAmount(delegateRegistry, newRegistryHash, delegateInfo.amount)
            ) == newRegistryHash
        ) return;
        revert DelegateTokenErrors.HashMismatch();
    }
    function incrementERC1155(address delegateRegistry, bytes32 newRegistryHash, DelegateTokenStructs.DelegateInfo calldata delegateInfo) internal {
        if (
            IDelegateRegistry(delegateRegistry).delegateERC1155(
                delegateInfo.delegateHolder,
                delegateInfo.tokenContract,
                delegateInfo.tokenId,
                delegateInfo.rights,
                calculateIncreasedAmount(delegateRegistry, newRegistryHash, delegateInfo.amount)
            ) == newRegistryHash
        ) return;
        revert DelegateTokenErrors.HashMismatch();
    }
    function revokeERC721(
        address delegateRegistry,
        bytes32 registryHash,
        address delegateTokenHolder,
        address underlyingContract,
        uint256 underlyingTokenId,
        bytes32 underlyingRights
    ) internal {
        if (IDelegateRegistry(delegateRegistry).delegateERC721(delegateTokenHolder, underlyingContract, underlyingTokenId, underlyingRights, false) == registryHash) {
            return;
        }
        revert DelegateTokenErrors.HashMismatch();
    }
    function decrementERC20(
        address delegateRegistry,
        bytes32 registryHash,
        address delegateTokenHolder,
        address underlyingContract,
        uint256 underlyingAmount,
        bytes32 underlyingRights
    ) internal {
        if (
            IDelegateRegistry(delegateRegistry).delegateERC20(
                delegateTokenHolder, underlyingContract, underlyingRights, calculateDecreasedAmount(delegateRegistry, registryHash, underlyingAmount)
            ) == registryHash
        ) return;
        revert DelegateTokenErrors.HashMismatch();
    }
    function decrementERC1155(
        address delegateRegistry,
        bytes32 registryHash,
        address delegateTokenHolder,
        address underlyingContract,
        uint256 underlyingTokenId,
        uint256 underlyingAmount,
        bytes32 underlyingRights
    ) internal {
        if (
            IDelegateRegistry(delegateRegistry).delegateERC1155(
                delegateTokenHolder, underlyingContract, underlyingTokenId, underlyingRights, calculateDecreasedAmount(delegateRegistry, registryHash, underlyingAmount)
            ) == registryHash
        ) return;
        revert DelegateTokenErrors.HashMismatch();
    }
}
interface IDelegateToken is IERC721Metadata, IERC721Receiver, IERC1155Receiver, IERC2981 {
    event ExpiryExtended(uint256 indexed delegateTokenId, uint256 previousExpiry, uint256 newExpiry);
    function delegateRegistry() external view returns (address);
    function principalToken() external view returns (address);
    function baseURI() external view returns (string memory);
    function isApprovedOrOwner(address spender, uint256 delegateTokenId) external view returns (bool);
    function getDelegateInfo(uint256 delegateTokenId) external view returns (DelegateTokenStructs.DelegateInfo memory delegateInfo);
    function getDelegateId(address creator, uint256 salt) external view returns (uint256 delegateId);
    function contractURI() external view returns (string memory);
    function create(DelegateTokenStructs.DelegateInfo calldata delegateInfo, uint256 salt) external returns (uint256 delegateTokenId);
    function extend(uint256 delegateTokenId, uint256 newExpiry) external;
    function rescind(uint256 delegateTokenId) external;
    function withdraw(uint256 delegateTokenId) external;
    function flashloan(DelegateTokenStructs.FlashInfo calldata info) external payable;
    function burnAuthorizedCallback() external;
    function mintAuthorizedCallback() external;
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
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
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
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
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
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
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
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
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
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
}
library DelegateTokenTransferHelpers {
    uint256 internal constant ERC1155_NOT_PULLED = 5;
    uint256 internal constant ERC1155_PULLED = 6;
    function checkAndPullByType(DelegateTokenStructs.Uint256 storage erc1155Pulled, DelegateTokenStructs.DelegateInfo calldata delegateInfo) internal {
        if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC721) {
            checkERC721BeforePull(delegateInfo.amount, delegateInfo.tokenContract, delegateInfo.tokenId);
            pullERC721AfterCheck(delegateInfo.tokenContract, delegateInfo.tokenId);
        } else if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC20) {
            checkERC20BeforePull(delegateInfo.amount, delegateInfo.tokenContract, delegateInfo.tokenId);
            pullERC20AfterCheck(delegateInfo.tokenContract, delegateInfo.amount);
        } else if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC1155) {
            checkERC1155BeforePull(erc1155Pulled, delegateInfo.amount);
            pullERC1155AfterCheck(erc1155Pulled, delegateInfo.amount, delegateInfo.tokenContract, delegateInfo.tokenId);
        } else {
            revert DelegateTokenErrors.InvalidTokenType(delegateInfo.tokenType);
        }
    }
    function checkERC721BeforePull(uint256 underlyingAmount, address underlyingContract, uint256 underlyingTokenId) internal view {
        if (underlyingAmount != 0) {
            revert DelegateTokenErrors.WrongAmountForType(IDelegateRegistry.DelegationType.ERC721, underlyingAmount);
        }
        if (IERC721(underlyingContract).ownerOf(underlyingTokenId) != msg.sender) {
            revert DelegateTokenErrors.CallerNotOwnerOrInvalidToken();
        }
    }
    function pullERC721AfterCheck(address underlyingContract, uint256 underlyingTokenId) internal {
        IERC721(underlyingContract).transferFrom(msg.sender, address(this), underlyingTokenId);
    }
    function checkERC20BeforePull(uint256 underlyingAmount, address underlyingContract, uint256 underlyingTokenId) internal view {
        if (underlyingTokenId != 0) {
            revert DelegateTokenErrors.WrongTokenIdForType(IDelegateRegistry.DelegationType.ERC20, underlyingTokenId);
        }
        if (underlyingAmount == 0) {
            revert DelegateTokenErrors.WrongAmountForType(IDelegateRegistry.DelegationType.ERC20, underlyingAmount);
        }
        if (IERC20(underlyingContract).allowance(msg.sender, address(this)) < underlyingAmount) {
            revert DelegateTokenErrors.InsufficientAllowanceOrInvalidToken();
        }
    }
    function pullERC20AfterCheck(address underlyingContract, uint256 pullAmount) internal {
        SafeERC20.safeTransferFrom(IERC20(underlyingContract), msg.sender, address(this), pullAmount);
    }
    function checkERC1155BeforePull(DelegateTokenStructs.Uint256 storage erc1155Pulled, uint256 pullAmount) internal {
        if (pullAmount == 0) revert DelegateTokenErrors.WrongAmountForType(IDelegateRegistry.DelegationType.ERC1155, pullAmount);
        if (erc1155Pulled.flag == ERC1155_NOT_PULLED) {
            erc1155Pulled.flag = ERC1155_PULLED;
        } else {
            revert DelegateTokenErrors.ERC1155Pulled();
        }
    }
    function pullERC1155AfterCheck(DelegateTokenStructs.Uint256 storage erc1155Pulled, uint256 pullAmount, address underlyingContract, uint256 underlyingTokenId) internal {
        IERC1155(underlyingContract).safeTransferFrom(msg.sender, address(this), underlyingTokenId, pullAmount, "");
        if (erc1155Pulled.flag == ERC1155_PULLED) {
            revert DelegateTokenErrors.ERC1155NotPulled();
        }
    }
    function checkERC1155Pulled(DelegateTokenStructs.Uint256 storage erc1155Pulled, address operator) internal returns (bool) {
        if (erc1155Pulled.flag == ERC1155_PULLED && address(this) == operator) {
            erc1155Pulled.flag = ERC1155_NOT_PULLED;
            return true;
        }
        return false;
    }
    function revertInvalidERC1155PullCheck(DelegateTokenStructs.Uint256 storage erc1155PullAuthorization, address operator) internal {
        if (!checkERC1155Pulled(erc1155PullAuthorization, operator)) revert DelegateTokenErrors.ERC1155PullNotRequested(operator);
    }
}
contract MarketMetadata is Ownable2Step, ERC2981 {
    string public delegateTokenBaseURI;
    constructor(address initialOwner, string memory initialDelegateTokenBaseURI) {
        delegateTokenBaseURI = initialDelegateTokenBaseURI;
        _transferOwnership(initialOwner);
    }
    function setDelegateTokenBaseURI(string calldata uri) external onlyOwner {
        delegateTokenBaseURI = uri;
    }
    function setDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }
    function deleteDefaultRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }
    function delegateTokenContractURI() external view returns (string memory) {
        return string.concat(delegateTokenBaseURI, "contract");
    }
    function delegateTokenURI(address tokenContract, uint256 delegateTokenId, uint256 expiry, address principalOwner) external view returns (string memory) {
        string memory idstr = Strings.toString(delegateTokenId);
        string memory pownerstr = principalOwner == address(0) ? "N/A" : Strings.toHexString(principalOwner);
        string memory status = principalOwner == address(0) || expiry <= block.timestamp ? "Expired" : "Active";
        string memory firstPartOfMetadataString = string.concat(
            '{"name":"Delegate Token #"',
            idstr,
            '","description":"DelegateMarket lets you escrow your token for a chosen timeperiod and receive a token representing the associated delegation rights. This collection represents the tokenized delegation rights.","attributes":[{"trait_type":"Collection Address","value":"',
            Strings.toHexString(tokenContract),
            '"},{"trait_type":"Token ID","value":"',
            idstr,
            '"},{"trait_type":"Expires At","display_type":"date","value":',
            Strings.toString(expiry)
        );
        string memory secondPartOfMetadataString = string.concat(
            '},{"trait_type":"Principal Owner Address","value":"',
            pownerstr,
            '"},{"trait_type":"Delegate Status","value":"',
            status,
            '"}]',
            ',"image":"',
            delegateTokenBaseURI,
            "rights/",
            idstr,
            '"}'
        );
        string memory metadataString = string.concat(firstPartOfMetadataString, secondPartOfMetadataString);
        return string.concat("data:application/json;base64,", Base64.encode(bytes(metadataString)));
    }
    function principalTokenURI(address delegateToken, uint256 id) external view returns (string memory) {
        IDelegateToken dt = IDelegateToken(delegateToken);
        DelegateTokenStructs.DelegateInfo memory delegateInfo = dt.getDelegateInfo(id);
        string memory idstr = Strings.toString(delegateInfo.tokenId);
        string memory imageUrl = string.concat(delegateTokenBaseURI, "principal/", idstr);
        address rightsOwner = address(0);
        try dt.ownerOf(id) returns (address retrievedOwner) {
            rightsOwner = retrievedOwner;
        } catch {}
        string memory rightsOwnerStr = rightsOwner == address(0) ? "N/A" : Strings.toHexString(rightsOwner);
        string memory status = rightsOwner == address(0) || delegateInfo.expiry <= block.timestamp ? "Unlocked" : "Locked";
        string memory firstPartOfMetadataString = string.concat(
            '{"name":"',
            string.concat(dt.name(), " #", idstr),
            '","description":"DelegateMarket lets you escrow your token for a chosen timeperiod and receive a token representing its delegation rights. This collection represents the principal i.e. the future right to claim the underlying token once the associated delegate token expires.","attributes":[{"trait_type":"Collection Address","value":"',
            Strings.toHexString(delegateInfo.tokenContract),
            '"},{"trait_type":"Token ID","value":"',
            idstr,
            '"},{"trait_type":"Unlocks At","display_type":"date","value":',
            Strings.toString(delegateInfo.expiry)
        );
        string memory secondPartOfMetadataString = string.concat(
            '},{"trait_type":"Delegate Owner Address","value":"', rightsOwnerStr, '"},{"trait_type":"Principal Status","value":"', status, '"}],"image":"', imageUrl, '"}'
        );
        string memory metadataString = string.concat(firstPartOfMetadataString, secondPartOfMetadataString);
        return string.concat("data:application/json;base64,", Base64.encode(bytes(metadataString)));
    }
}
contract PrincipalToken is ERC721("PrincipalToken", "PT") {
    address public immutable delegateToken;
    address public immutable marketMetadata;
    error DelegateTokenZero();
    error MarketMetadataZero();
    error CallerNotDelegateToken();
    error NotApproved(address spender, uint256 id);
    constructor(address setDelegateToken, address setMarketMetadata) {
        if (setDelegateToken == address(0)) revert DelegateTokenZero();
        delegateToken = setDelegateToken;
        if (setMarketMetadata == address(0)) revert MarketMetadataZero();
        marketMetadata = setMarketMetadata;
    }
    function _checkDelegateTokenCaller() internal view {
        if (msg.sender == delegateToken) return;
        revert CallerNotDelegateToken();
    }
    function mint(address to, uint256 id) external {
        _checkDelegateTokenCaller();
        _mint(to, id);
        IDelegateToken(delegateToken).mintAuthorizedCallback();
    }
    function burn(address spender, uint256 id) external {
        _checkDelegateTokenCaller();
        if (_isApprovedOrOwner(spender, id)) {
            _burn(id);
            IDelegateToken(delegateToken).burnAuthorizedCallback();
            return;
        }
        revert NotApproved(spender, id);
    }
    function isApprovedOrOwner(address account, uint256 id) external view returns (bool) {
        return _isApprovedOrOwner(account, id);
    }
    function tokenURI(uint256 id) public view override returns (string memory) {
        _requireMinted(id);
        return MarketMetadata(marketMetadata).principalTokenURI(delegateToken, id);
    }
}
library DelegateTokenStorageHelpers {
    uint256 internal constant MAX_EXPIRY = type(uint96).max;
    uint256 internal constant ID_AVAILABLE = 0;
    uint256 internal constant ID_USED = 1;
    uint256 internal constant REGISTRY_HASH_POSITION = 0;
    uint256 internal constant PACKED_INFO_POSITION = 1; 
    uint256 internal constant UNDERLYING_AMOUNT_POSITION = 2; 
    uint256 internal constant MINT_NOT_AUTHORIZED = 1;
    uint256 internal constant MINT_AUTHORIZED = 2;
    uint256 internal constant BURN_NOT_AUTHORIZED = 3;
    uint256 internal constant BURN_AUTHORIZED = 4;
    function writeApproved(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId, address approved) internal {
        uint96 expiry = uint96(delegateTokenInfo[delegateTokenId][PACKED_INFO_POSITION]);
        delegateTokenInfo[delegateTokenId][PACKED_INFO_POSITION] = (uint256(uint160(approved)) << 96) | expiry;
    }
    function writeExpiry(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId, uint256 expiry) internal {
        if (expiry > MAX_EXPIRY) revert DelegateTokenErrors.ExpiryTooLarge();
        address approved = address(uint160(delegateTokenInfo[delegateTokenId][PACKED_INFO_POSITION] >> 96));
        delegateTokenInfo[delegateTokenId][PACKED_INFO_POSITION] = (uint256(uint160(approved)) << 96) | expiry;
    }
    function writeRegistryHash(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId, bytes32 registryHash) internal {
        delegateTokenInfo[delegateTokenId][REGISTRY_HASH_POSITION] = uint256(registryHash);
    }
    function writeUnderlyingAmount(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId, uint256 underlyingAmount) internal {
        delegateTokenInfo[delegateTokenId][UNDERLYING_AMOUNT_POSITION] = underlyingAmount;
    }
    function incrementBalance(mapping(address delegateTokenHolder => uint256 balance) storage balances, address delegateTokenHolder) internal {
        unchecked {
            ++balances[delegateTokenHolder];
        } 
    }
    function decrementBalance(mapping(address delegateTokenHolder => uint256 balance) storage balances, address delegateTokenHolder) internal {
        unchecked {
            --balances[delegateTokenHolder];
        } 
    }
    function burnPrincipal(address principalToken, DelegateTokenStructs.Uint256 storage principalBurnAuthorization, uint256 delegateTokenId) internal {
        if (principalBurnAuthorization.flag == BURN_NOT_AUTHORIZED) {
            principalBurnAuthorization.flag = BURN_AUTHORIZED;
            PrincipalToken(principalToken).burn(msg.sender, delegateTokenId);
            principalBurnAuthorization.flag = BURN_NOT_AUTHORIZED;
            return;
        }
        revert DelegateTokenErrors.BurnAuthorized();
    }
    function mintPrincipal(address principalToken, DelegateTokenStructs.Uint256 storage principalMintAuthorization, address principalRecipient, uint256 delegateTokenId) internal {
        if (principalMintAuthorization.flag == MINT_NOT_AUTHORIZED) {
            principalMintAuthorization.flag = MINT_AUTHORIZED;
            PrincipalToken(principalToken).mint(principalRecipient, delegateTokenId);
            principalMintAuthorization.flag = MINT_NOT_AUTHORIZED;
            return;
        }
        revert DelegateTokenErrors.MintAuthorized();
    }
    function checkBurnAuthorized(address principalToken, DelegateTokenStructs.Uint256 storage principalBurnAuthorization) internal view {
        principalIsCaller(principalToken);
        if (principalBurnAuthorization.flag == BURN_AUTHORIZED) return;
        revert DelegateTokenErrors.BurnNotAuthorized();
    }
    function checkMintAuthorized(address principalToken, DelegateTokenStructs.Uint256 storage principalMintAuthorization) internal view {
        principalIsCaller(principalToken);
        if (principalMintAuthorization.flag == MINT_AUTHORIZED) return;
        revert DelegateTokenErrors.MintNotAuthorized();
    }
    function principalIsCaller(address principalToken) internal view {
        if (msg.sender == principalToken) return;
        revert DelegateTokenErrors.CallerNotPrincipalToken();
    }
    function revertAlreadyExisted(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId) internal view {
        if (delegateTokenInfo[delegateTokenId][REGISTRY_HASH_POSITION] == ID_AVAILABLE) return;
        revert DelegateTokenErrors.AlreadyExisted(delegateTokenId);
    }
    function revertNotOperator(mapping(address account => mapping(address operator => bool enabled)) storage accountOperator, address account) internal view {
        if (msg.sender == account || accountOperator[account][msg.sender]) return;
        revert DelegateTokenErrors.NotOperator(msg.sender, account);
    }
    function readApproved(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId) internal view returns (address) {
        return address(uint160(delegateTokenInfo[delegateTokenId][PACKED_INFO_POSITION] >> 96));
    }
    function readExpiry(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId) internal view returns (uint256) {
        return uint96(delegateTokenInfo[delegateTokenId][PACKED_INFO_POSITION]);
    }
    function readRegistryHash(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId) internal view returns (bytes32) {
        return bytes32(delegateTokenInfo[delegateTokenId][REGISTRY_HASH_POSITION]);
    }
    function readUnderlyingAmount(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId) internal view returns (uint256) {
        return delegateTokenInfo[delegateTokenId][UNDERLYING_AMOUNT_POSITION];
    }
    function revertNotApprovedOrOperator(
        mapping(address account => mapping(address operator => bool enabled)) storage accountOperator,
        mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo,
        address account,
        uint256 delegateTokenId
    ) internal view {
        if (msg.sender == account || accountOperator[account][msg.sender] || msg.sender == readApproved(delegateTokenInfo, delegateTokenId)) return;
        revert DelegateTokenErrors.NotApproved(msg.sender, delegateTokenId);
    }
    function revertInvalidWithdrawalConditions(
        mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo,
        mapping(address account => mapping(address operator => bool enabled)) storage accountOperator,
        uint256 delegateTokenId,
        address delegateTokenHolder
    ) internal view {
        if (block.timestamp < readExpiry(delegateTokenInfo, delegateTokenId)) {
            if (delegateTokenHolder == msg.sender || msg.sender == readApproved(delegateTokenInfo, delegateTokenId) || accountOperator[delegateTokenHolder][msg.sender]) {
                return;
            }
            revert DelegateTokenErrors.WithdrawNotAvailable(delegateTokenId, readExpiry(delegateTokenInfo, delegateTokenId), block.timestamp);
        }
    }
    function revertNotMinted(mapping(uint256 delegateTokenId => uint256[3] info) storage delegateTokenInfo, uint256 delegateTokenId) internal view {
        uint256 registryHash = delegateTokenInfo[delegateTokenId][REGISTRY_HASH_POSITION];
        if (registryHash == ID_AVAILABLE || registryHash == ID_USED) {
            revert DelegateTokenErrors.NotMinted(delegateTokenId);
        }
    }
    function revertNotMinted(bytes32 registryHash, uint256 delegateTokenId) internal pure {
        if (uint256(registryHash) == ID_AVAILABLE || uint256(registryHash) == ID_USED) {
            revert DelegateTokenErrors.NotMinted(delegateTokenId);
        }
    }
}
contract DelegateToken is ReentrancyGuard, IDelegateToken {
    address public immutable override delegateRegistry;
    address public immutable override principalToken;
    address public immutable marketMetadata;
    mapping(uint256 delegateTokenId => uint256[3] info) internal delegateTokenInfo;
    mapping(address delegateTokenHolder => uint256 balance) internal balances;
    mapping(address account => mapping(address operator => bool enabled)) internal accountOperator;
    DelegateTokenStructs.Uint256 internal principalMintAuthorization = DelegateTokenStructs.Uint256(DelegateTokenStorageHelpers.MINT_NOT_AUTHORIZED);
    DelegateTokenStructs.Uint256 internal principalBurnAuthorization = DelegateTokenStructs.Uint256(DelegateTokenStorageHelpers.BURN_NOT_AUTHORIZED);
    DelegateTokenStructs.Uint256 internal erc1155PullAuthorization = DelegateTokenStructs.Uint256(DelegateTokenTransferHelpers.ERC1155_NOT_PULLED);
    constructor(DelegateTokenStructs.DelegateTokenParameters memory parameters) {
        if (parameters.delegateRegistry == address(0)) revert DelegateTokenErrors.DelegateRegistryZero();
        if (parameters.principalToken == address(0)) revert DelegateTokenErrors.PrincipalTokenZero();
        if (parameters.marketMetadata == address(0)) revert DelegateTokenErrors.MarketMetadataZero();
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
        revert DelegateTokenErrors.BatchERC1155TransferUnsupported();
    }
    function onERC721Received(address operator, address, uint256, bytes calldata) external view returns (bytes4) {
        if (address(this) == operator) return IERC721Receiver.onERC721Received.selector;
        revert DelegateTokenErrors.InvalidERC721TransferOperator();
    }
    function onERC1155Received(address operator, address, uint256, uint256, bytes calldata) external returns (bytes4) {
        DelegateTokenTransferHelpers.revertInvalidERC1155PullCheck(erc1155PullAuthorization, operator);
        return IERC1155Receiver.onERC1155Received.selector;
    }
    function balanceOf(address delegateTokenHolder) external view returns (uint256) {
        if (delegateTokenHolder == address(0)) revert DelegateTokenErrors.DelegateTokenHolderZero();
        return balances[delegateTokenHolder];
    }
    function ownerOf(uint256 delegateTokenId) external view returns (address delegateTokenHolder) {
        delegateTokenHolder = DelegateTokenRegistryHelpers.loadTokenHolder(delegateRegistry, DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId));
        if (delegateTokenHolder == address(0)) revert DelegateTokenErrors.DelegateTokenHolderZero();
    }
    function getApproved(uint256 delegateTokenId) external view returns (address) {
        DelegateTokenStorageHelpers.revertNotMinted(delegateTokenInfo, delegateTokenId);
        return DelegateTokenStorageHelpers.readApproved(delegateTokenInfo, delegateTokenId);
    }
    function isApprovedForAll(address account, address operator) external view returns (bool) {
        return accountOperator[account][operator];
    }
    function safeTransferFrom(address from, address to, uint256 delegateTokenId, bytes calldata data) external {
        transferFrom(from, to, delegateTokenId);
        DelegateTokenHelpers.revertOnInvalidERC721ReceiverCallback(from, to, delegateTokenId, data);
    }
    function safeTransferFrom(address from, address to, uint256 delegateTokenId) external {
        transferFrom(from, to, delegateTokenId);
        DelegateTokenHelpers.revertOnInvalidERC721ReceiverCallback(from, to, delegateTokenId);
    }
    function approve(address spender, uint256 delegateTokenId) external {
        bytes32 registryHash = DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        DelegateTokenStorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        address delegateTokenHolder = DelegateTokenRegistryHelpers.loadTokenHolder(delegateRegistry, registryHash);
        DelegateTokenStorageHelpers.revertNotOperator(accountOperator, delegateTokenHolder);
        DelegateTokenStorageHelpers.writeApproved(delegateTokenInfo, delegateTokenId, spender);
        emit Approval(delegateTokenHolder, spender, delegateTokenId);
    }
    function setApprovalForAll(address operator, bool approved) external {
        accountOperator[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    function transferFrom(address from, address to, uint256 delegateTokenId) public {
        if (to == address(0)) revert DelegateTokenErrors.ToIsZero();
        bytes32 registryHash = DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        DelegateTokenStorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        (address delegateTokenHolder, address underlyingContract) = DelegateTokenRegistryHelpers.loadTokenHolderAndContract(delegateRegistry, registryHash);
        if (from != delegateTokenHolder) revert DelegateTokenErrors.FromNotDelegateTokenHolder();
        DelegateTokenStorageHelpers.revertNotApprovedOrOperator(accountOperator, delegateTokenInfo, from, delegateTokenId);
        DelegateTokenStorageHelpers.incrementBalance(balances, to);
        DelegateTokenStorageHelpers.decrementBalance(balances, from);
        DelegateTokenStorageHelpers.writeApproved(delegateTokenInfo, delegateTokenId, address(0));
        emit Transfer(from, to, delegateTokenId);
        IDelegateRegistry.DelegationType underlyingType = RegistryHashes.decodeType(registryHash);
        bytes32 underlyingRights = DelegateTokenRegistryHelpers.loadRights(delegateRegistry, registryHash);
        bytes32 newRegistryHash = 0;
        if (underlyingType == IDelegateRegistry.DelegationType.ERC721) {
            uint256 underlyingTokenId = DelegateTokenRegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            newRegistryHash = RegistryHashes.erc721Hash(address(this), underlyingRights, to, underlyingTokenId, underlyingContract);
            DelegateTokenStorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            DelegateTokenRegistryHelpers.transferERC721(delegateRegistry, registryHash, from, newRegistryHash, to, underlyingRights, underlyingContract, underlyingTokenId);
        } else if (underlyingType == IDelegateRegistry.DelegationType.ERC20) {
            newRegistryHash = RegistryHashes.erc20Hash(address(this), underlyingRights, to, underlyingContract);
            DelegateTokenStorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            DelegateTokenRegistryHelpers.transferERC20(
                delegateRegistry,
                registryHash,
                from,
                newRegistryHash,
                to,
                DelegateTokenStorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId),
                underlyingRights,
                underlyingContract
            );
        } else if (underlyingType == IDelegateRegistry.DelegationType.ERC1155) {
            uint256 underlyingTokenId = DelegateTokenRegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            newRegistryHash = RegistryHashes.erc1155Hash(address(this), underlyingRights, to, underlyingTokenId, underlyingContract);
            DelegateTokenStorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            DelegateTokenRegistryHelpers.transferERC1155(
                delegateRegistry,
                registryHash,
                from,
                newRegistryHash,
                to,
                DelegateTokenStorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId),
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
        bytes32 registryHash = DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        DelegateTokenStorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        return MarketMetadata(marketMetadata).delegateTokenURI(
            DelegateTokenRegistryHelpers.loadContract(delegateRegistry, registryHash),
            DelegateTokenRegistryHelpers.loadTokenId(delegateRegistry, registryHash),
            DelegateTokenStorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId),
            IERC721(principalToken).ownerOf(delegateTokenId)
        );
    }
    function isApprovedOrOwner(address spender, uint256 delegateTokenId) external view returns (bool) {
        bytes32 registryHash = DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        DelegateTokenStorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        address delegateTokenHolder = DelegateTokenRegistryHelpers.loadTokenHolder(delegateRegistry, registryHash);
        return spender == delegateTokenHolder || accountOperator[delegateTokenHolder][spender] || DelegateTokenStorageHelpers.readApproved(delegateTokenInfo, delegateTokenId) == spender;
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
    function getDelegateInfo(uint256 delegateTokenId) external view returns (DelegateTokenStructs.DelegateInfo memory delegateInfo) {
        bytes32 registryHash = DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        DelegateTokenStorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        delegateInfo.tokenType = RegistryHashes.decodeType(registryHash);
        (delegateInfo.delegateHolder, delegateInfo.tokenContract) = DelegateTokenRegistryHelpers.loadTokenHolderAndContract(delegateRegistry, registryHash);
        delegateInfo.rights = DelegateTokenRegistryHelpers.loadRights(delegateRegistry, registryHash);
        delegateInfo.principalHolder = IERC721(principalToken).ownerOf(delegateTokenId);
        delegateInfo.expiry = DelegateTokenStorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId);
        if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC20) delegateInfo.tokenId = 0;
        else delegateInfo.tokenId = DelegateTokenRegistryHelpers.loadTokenId(delegateRegistry, registryHash);
        if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC721) delegateInfo.amount = 0;
        else delegateInfo.amount = DelegateTokenStorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId);
    }
    function getDelegateId(address caller, uint256 salt) external view returns (uint256 delegateTokenId) {
        delegateTokenId = DelegateTokenHelpers.delegateIdNoRevert(caller, salt);
        DelegateTokenStorageHelpers.revertAlreadyExisted(delegateTokenInfo, delegateTokenId);
    }
    function burnAuthorizedCallback() external view {
        DelegateTokenStorageHelpers.checkBurnAuthorized(principalToken, principalBurnAuthorization);
    }
    function mintAuthorizedCallback() external view {
        DelegateTokenStorageHelpers.checkMintAuthorized(principalToken, principalMintAuthorization);
    }
    function create(DelegateTokenStructs.DelegateInfo calldata delegateInfo, uint256 salt) external nonReentrant returns (uint256 delegateTokenId) {
        DelegateTokenTransferHelpers.checkAndPullByType(erc1155PullAuthorization, delegateInfo);
        DelegateTokenHelpers.revertOldExpiry(delegateInfo.expiry);
        if (delegateInfo.delegateHolder == address(0)) revert DelegateTokenErrors.ToIsZero();
        delegateTokenId = DelegateTokenHelpers.delegateIdNoRevert(msg.sender, salt);
        DelegateTokenStorageHelpers.revertAlreadyExisted(delegateTokenInfo, delegateTokenId);
        DelegateTokenStorageHelpers.incrementBalance(balances, delegateInfo.delegateHolder);
        DelegateTokenStorageHelpers.writeExpiry(delegateTokenInfo, delegateTokenId, delegateInfo.expiry);
        emit Transfer(address(0), delegateInfo.delegateHolder, delegateTokenId);
        bytes32 newRegistryHash = 0;
        if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC721) {
            newRegistryHash = RegistryHashes.erc721Hash(address(this), delegateInfo.rights, delegateInfo.delegateHolder, delegateInfo.tokenId, delegateInfo.tokenContract);
            DelegateTokenStorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            DelegateTokenRegistryHelpers.delegateERC721(delegateRegistry, newRegistryHash, delegateInfo);
        } else if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC20) {
            DelegateTokenStorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, delegateInfo.amount);
            newRegistryHash = RegistryHashes.erc20Hash(address(this), delegateInfo.rights, delegateInfo.delegateHolder, delegateInfo.tokenContract);
            DelegateTokenStorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            DelegateTokenRegistryHelpers.incrementERC20(delegateRegistry, newRegistryHash, delegateInfo);
        } else if (delegateInfo.tokenType == IDelegateRegistry.DelegationType.ERC1155) {
            DelegateTokenStorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, delegateInfo.amount);
            newRegistryHash = RegistryHashes.erc1155Hash(address(this), delegateInfo.rights, delegateInfo.delegateHolder, delegateInfo.tokenId, delegateInfo.tokenContract);
            DelegateTokenStorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, newRegistryHash);
            DelegateTokenRegistryHelpers.incrementERC1155(delegateRegistry, newRegistryHash, delegateInfo);
        }
        DelegateTokenStorageHelpers.mintPrincipal(principalToken, principalMintAuthorization, delegateInfo.principalHolder, delegateTokenId);
    }
    function extend(uint256 delegateTokenId, uint256 newExpiry) external {
        DelegateTokenStorageHelpers.revertNotMinted(delegateTokenInfo, delegateTokenId);
        DelegateTokenHelpers.revertOldExpiry(newExpiry);
        uint256 previousExpiry = DelegateTokenStorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId);
        if (newExpiry <= previousExpiry) revert DelegateTokenErrors.ExpiryTooSmall();
        if (PrincipalToken(principalToken).isApprovedOrOwner(msg.sender, delegateTokenId)) {
            DelegateTokenStorageHelpers.writeExpiry(delegateTokenInfo, delegateTokenId, newExpiry);
            emit ExpiryExtended(delegateTokenId, previousExpiry, newExpiry);
            return;
        }
        revert DelegateTokenErrors.NotApproved(msg.sender, delegateTokenId);
    }
    function rescind(uint256 delegateTokenId) external {
        if (DelegateTokenStorageHelpers.readExpiry(delegateTokenInfo, delegateTokenId) < block.timestamp) {
            DelegateTokenStorageHelpers.writeApproved(delegateTokenInfo, delegateTokenId, msg.sender);
        }
        transferFrom(
            DelegateTokenRegistryHelpers.loadTokenHolder(delegateRegistry, DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId)),
            IERC721(principalToken).ownerOf(delegateTokenId),
            delegateTokenId
        );
    }
    function withdraw(uint256 delegateTokenId) external nonReentrant {
        bytes32 registryHash = DelegateTokenStorageHelpers.readRegistryHash(delegateTokenInfo, delegateTokenId);
        DelegateTokenStorageHelpers.writeRegistryHash(delegateTokenInfo, delegateTokenId, bytes32(DelegateTokenStorageHelpers.ID_USED));
        DelegateTokenStorageHelpers.revertNotMinted(registryHash, delegateTokenId);
        (address delegateTokenHolder, address underlyingContract) = DelegateTokenRegistryHelpers.loadTokenHolderAndContract(delegateRegistry, registryHash);
        DelegateTokenStorageHelpers.revertInvalidWithdrawalConditions(delegateTokenInfo, accountOperator, delegateTokenId, delegateTokenHolder);
        DelegateTokenStorageHelpers.decrementBalance(balances, delegateTokenHolder);
        delete delegateTokenInfo[delegateTokenId][DelegateTokenStorageHelpers.PACKED_INFO_POSITION]; 
        emit Transfer(delegateTokenHolder, address(0), delegateTokenId);
        IDelegateRegistry.DelegationType delegationType = RegistryHashes.decodeType(registryHash);
        bytes32 underlyingRights = DelegateTokenRegistryHelpers.loadRights(delegateRegistry, registryHash);
        if (delegationType == IDelegateRegistry.DelegationType.ERC721) {
            uint256 erc721UnderlyingTokenId = DelegateTokenRegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            DelegateTokenRegistryHelpers.revokeERC721(delegateRegistry, registryHash, delegateTokenHolder, underlyingContract, erc721UnderlyingTokenId, underlyingRights);
            DelegateTokenStorageHelpers.burnPrincipal(principalToken, principalBurnAuthorization, delegateTokenId);
            IERC721(underlyingContract).transferFrom(address(this), msg.sender, erc721UnderlyingTokenId);
        } else if (delegationType == IDelegateRegistry.DelegationType.ERC20) {
            uint256 erc20UnderlyingAmount = DelegateTokenStorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId);
            DelegateTokenStorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, 0); 
            DelegateTokenRegistryHelpers.decrementERC20(delegateRegistry, registryHash, delegateTokenHolder, underlyingContract, erc20UnderlyingAmount, underlyingRights);
            DelegateTokenStorageHelpers.burnPrincipal(principalToken, principalBurnAuthorization, delegateTokenId);
            SafeERC20.safeTransfer(IERC20(underlyingContract), msg.sender, erc20UnderlyingAmount);
        } else if (delegationType == IDelegateRegistry.DelegationType.ERC1155) {
            uint256 erc1155UnderlyingAmount = DelegateTokenStorageHelpers.readUnderlyingAmount(delegateTokenInfo, delegateTokenId);
            DelegateTokenStorageHelpers.writeUnderlyingAmount(delegateTokenInfo, delegateTokenId, 0); 
            uint256 erc11551UnderlyingTokenId = DelegateTokenRegistryHelpers.loadTokenId(delegateRegistry, registryHash);
            DelegateTokenRegistryHelpers.decrementERC1155(
                delegateRegistry, registryHash, delegateTokenHolder, underlyingContract, erc11551UnderlyingTokenId, erc1155UnderlyingAmount, underlyingRights
            );
            DelegateTokenStorageHelpers.burnPrincipal(principalToken, principalBurnAuthorization, delegateTokenId);
            IERC1155(underlyingContract).safeTransferFrom(address(this), msg.sender, erc11551UnderlyingTokenId, erc1155UnderlyingAmount, "");
        }
    }
    function flashloan(DelegateTokenStructs.FlashInfo calldata info) external payable nonReentrant {
        DelegateTokenStorageHelpers.revertNotOperator(accountOperator, info.delegateHolder);
        if (info.tokenType == IDelegateRegistry.DelegationType.ERC721) {
            DelegateTokenRegistryHelpers.revertERC721FlashUnavailable(delegateRegistry, info);
            IERC721(info.tokenContract).transferFrom(address(this), info.receiver, info.tokenId);
            DelegateTokenHelpers.revertOnCallingInvalidFlashloan(info);
            DelegateTokenTransferHelpers.checkERC721BeforePull(info.amount, info.tokenContract, info.tokenId);
            DelegateTokenTransferHelpers.pullERC721AfterCheck(info.tokenContract, info.tokenId);
        } else if (info.tokenType == IDelegateRegistry.DelegationType.ERC20) {
            DelegateTokenRegistryHelpers.revertERC20FlashAmountUnavailable(delegateRegistry, info);
            SafeERC20.safeTransfer(IERC20(info.tokenContract), info.receiver, info.amount);
            DelegateTokenHelpers.revertOnCallingInvalidFlashloan(info);
            DelegateTokenTransferHelpers.checkERC20BeforePull(info.amount, info.tokenContract, info.tokenId);
            DelegateTokenTransferHelpers.pullERC20AfterCheck(info.tokenContract, info.amount);
        } else if (info.tokenType == IDelegateRegistry.DelegationType.ERC1155) {
            DelegateTokenRegistryHelpers.revertERC1155FlashAmountUnavailable(delegateRegistry, info);
            DelegateTokenTransferHelpers.checkERC1155BeforePull(erc1155PullAuthorization, info.amount);
            IERC1155(info.tokenContract).safeTransferFrom(address(this), info.receiver, info.tokenId, info.amount, "");
            DelegateTokenHelpers.revertOnCallingInvalidFlashloan(info);
            DelegateTokenTransferHelpers.pullERC1155AfterCheck(erc1155PullAuthorization, info.amount, info.tokenContract, info.tokenId);
        }
    }
}