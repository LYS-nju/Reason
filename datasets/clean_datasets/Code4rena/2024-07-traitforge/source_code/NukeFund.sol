pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
pragma solidity ^0.8.0;
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
pragma solidity ^0.8.0;
interface IERC4906 is IERC165, IERC721 {
    event MetadataUpdate(uint256 _tokenId);
    event BatchMetadataUpdate(uint256 _fromTokenId, uint256 _toTokenId);
}
pragma solidity ^0.8.0;
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor() {
        _paused = false;
    }
    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }
    modifier whenPaused() {
        _requirePaused();
        _;
    }
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }
    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
pragma solidity ^0.8.0;
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
pragma solidity ^0.8.0;
abstract contract ERC20Pausable is ERC20, Pausable {
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        require(!paused(), "ERC20Pausable: token transfer while paused");
    }
}
pragma solidity ^0.8.0;
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
pragma solidity ^0.8.0;
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
pragma solidity ^0.8.1;
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
pragma solidity ^0.8.0;
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.0;
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
pragma solidity ^0.8.0;
abstract contract ERC721Enumerable is ERC721, IERC721Enumerable {
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC721) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId || super.supportsInterface(interfaceId);
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721.balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
    }
    function tokenByIndex(uint256 index) public view virtual override returns (uint256) {
        require(index < ERC721Enumerable.totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
        if (batchSize > 1) {
            revert("ERC721Enumerable: consecutive transfers not supported");
        }
        uint256 tokenId = firstTokenId;
        if (from == address(0)) {
            _addTokenToAllTokensEnumeration(tokenId);
        } else if (from != to) {
            _removeTokenFromOwnerEnumeration(from, tokenId);
        }
        if (to == address(0)) {
            _removeTokenFromAllTokensEnumeration(tokenId);
        } else if (to != from) {
            _addTokenToOwnerEnumeration(to, tokenId);
        }
    }
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        uint256 length = ERC721.balanceOf(to);
        _ownedTokens[to][length] = tokenId;
        _ownedTokensIndex[tokenId] = length;
    }
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = ERC721.balanceOf(from) - 1;
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId; 
            _ownedTokensIndex[lastTokenId] = tokenIndex; 
        }
        delete _ownedTokensIndex[tokenId];
        delete _ownedTokens[from][lastTokenIndex];
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length - 1;
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId; 
        _allTokensIndex[lastTokenId] = tokenIndex; 
        delete _allTokensIndex[tokenId];
        _allTokens.pop();
    }
}
pragma solidity ^0.8.0;
abstract contract ERC721URIStorage is IERC4906, ERC721 {
    using Strings for uint256;
    mapping(uint256 => string) private _tokenURIs;
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, IERC165) returns (bool) {
        return interfaceId == bytes4(0x49064906) || super.supportsInterface(interfaceId);
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return super.tokenURI(tokenId);
    }
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
        emit MetadataUpdate(tokenId);
    }
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
pragma solidity ^0.8.0;
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
pragma solidity ^0.8.20;
interface IAirdrop {
  function setTraitToken(address _traitToken) external;
  function startAirdrop(uint256 amount) external;
  function airdropStarted() external view returns (bool);
  function allowDaoFund() external;
  function daoFundAllowed() external view returns (bool);
  function addUserAmount(address user, uint256 amount) external;
  function subUserAmount(address user, uint256 amount) external;
  function claim() external;
}
pragma solidity ^0.8.20;
contract Airdrop is IAirdrop, Ownable, ReentrancyGuard, Pausable {
  bool private started;
  bool private daoAllowed;
  IERC20 public traitToken;
  uint256 public totalTokenAmount;
  uint256 public totalValue;
  mapping(address => uint256) public userInfo;
  function setTraitToken(address _traitToken) external onlyOwner {
    traitToken = IERC20(_traitToken);
  }
  function startAirdrop(
    uint256 amount
  ) external whenNotPaused nonReentrant onlyOwner {
    require(!started, 'Already started');
    require(amount > 0, 'Invalid amount');
    traitToken.transferFrom(tx.origin, address(this), amount);
    started = true;
    totalTokenAmount = amount;
  }
  function airdropStarted() external view returns (bool) {
    return started;
  }
  function allowDaoFund() external onlyOwner {
    require(started, 'Not started');
    require(!daoAllowed, 'Already allowed');
    daoAllowed = true;
  }
  function daoFundAllowed() external view returns (bool) {
    return daoAllowed;
  }
  function addUserAmount(
    address user,
    uint256 amount
  ) external whenNotPaused nonReentrant onlyOwner {
    require(!started, 'Already started');
    userInfo[user] += amount;
    totalValue += amount;
  }
  function subUserAmount(
    address user,
    uint256 amount
  ) external whenNotPaused nonReentrant onlyOwner {
    require(!started, 'Already started');
    require(userInfo[user] >= amount, 'Invalid amount');
    userInfo[user] -= amount;
    totalValue -= amount;
  }
  function claim() external whenNotPaused nonReentrant {
    require(started, 'Not started');
    require(userInfo[msg.sender] > 0, 'Not eligible');
    uint256 amount = (totalTokenAmount * userInfo[msg.sender]) / totalValue;
    traitToken.transfer(msg.sender, amount);
    userInfo[msg.sender] = 0;
  }
}
pragma solidity ^0.8.20;
interface IUniswapV2Router01 {
  function factory() external pure returns (address);
  function WETH() external pure returns (address);
  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB, uint256 liquidity);
  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    returns (uint256 amountToken, uint256 amountETH, uint256 liquidity);
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountA, uint256 amountB);
  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountToken, uint256 amountETH);
  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountA, uint256 amountB);
  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountToken, uint256 amountETH);
  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);
  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external returns (uint256[] memory amounts);
  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable returns (uint256[] memory amounts);
  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) external pure returns (uint256 amountB);
  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountOut);
  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) external pure returns (uint256 amountIn);
  function getAmountsOut(
    uint256 amountIn,
    address[] calldata path
  ) external view returns (uint256[] memory amounts);
  function getAmountsIn(
    uint256 amountOut,
    address[] calldata path
  ) external view returns (uint256[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
  function removeLiquidityETHSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) external returns (uint256 amountETH);
  function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external returns (uint256 amountETH);
  function swapExactTokensForTokensSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
  function swapExactETHForTokensSupportingFeeOnTransferTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable;
  function swapExactTokensForETHSupportingFeeOnTransferTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external;
}
pragma solidity ^0.8.20;
interface ITrait is IERC20 {
  function burn(uint256 amount) external returns (bool);
}
pragma solidity ^0.8.20;
contract DAOFund {
  ITrait public token;
  IUniswapV2Router01 public uniswapV2Router;
  constructor(address _token, address _router) {
    token = ITrait(_token);
    uniswapV2Router = IUniswapV2Router02(_router);
  }
  receive() external payable {
    require(msg.value > 0, 'No ETH sent');
    address[] memory path = new address[](2);
    path[0] = uniswapV2Router.WETH();
    path[1] = address(token);
    uniswapV2Router.swapExactETHForTokens{ value: msg.value }(
      0,
      path,
      address(this),
      block.timestamp
    );
    require(
      token.burn(token.balanceOf(address(this))) == true,
      'Token burn failed'
    );
  }
}
pragma solidity ^0.8.20;
interface IDevFund {
  struct DevInfo {
    uint256 weight;
    uint256 rewardDebt;
    uint256 pendingRewards;
  }
  event AddDev(address indexed dev, uint256 weight);
  event UpdateDev(address indexed dev, uint256 weight);
  event RemoveDev(address indexed dev);
  event Claim(address indexed dev, uint256 amount);
  event FundReceived(address indexed from, uint256 amount); 
  receive() external payable;
  function addDev(address user, uint256 weight) external;
  function removeDev(address user) external;
  function claim() external;
  function pendingRewards(address user) external view returns (uint256);
}
pragma solidity ^0.8.20;
contract DevFund is IDevFund, Ownable, ReentrancyGuard, Pausable {
  uint256 public totalDevWeight;
  uint256 public totalRewardDebt;
  mapping(address => DevInfo) public devInfo;
  receive() external payable {
    if (totalDevWeight > 0) {
      uint256 amountPerWeight = msg.value / totalDevWeight;
      uint256 remaining = msg.value - (amountPerWeight * totalDevWeight);
      totalRewardDebt += amountPerWeight;
      if (remaining > 0) {
        (bool success, ) = payable(owner()).call{ value: remaining }('');
        require(success, 'Failed to send Ether to owner');
      }
    } else {
      (bool success, ) = payable(owner()).call{ value: msg.value }('');
      require(success, 'Failed to send Ether to owner');
    }
    emit FundReceived(msg.sender, msg.value);
  }
  function addDev(address user, uint256 weight) external onlyOwner {
    DevInfo storage info = devInfo[user];
    require(weight > 0, 'Invalid weight');
    require(info.weight == 0, 'Already registered');
    info.rewardDebt = totalRewardDebt;
    info.weight = weight;
    totalDevWeight += weight;
    emit AddDev(user, weight);
  }
  function updateDev(address user, uint256 weight) external onlyOwner {
    DevInfo storage info = devInfo[user];
    require(weight > 0, 'Invalid weight');
    require(info.weight > 0, 'Not dev address');
    totalDevWeight = totalDevWeight - info.weight + weight;
    info.pendingRewards += (totalRewardDebt - info.rewardDebt) * info.weight;
    info.rewardDebt = totalRewardDebt;
    info.weight = weight;
    emit UpdateDev(user, weight);
  }
  function removeDev(address user) external onlyOwner {
    DevInfo storage info = devInfo[user];
    require(info.weight > 0, 'Not dev address');
    totalDevWeight -= info.weight;
    info.pendingRewards += (totalRewardDebt - info.rewardDebt) * info.weight;
    info.rewardDebt = totalRewardDebt;
    info.weight = 0;
    emit RemoveDev(user);
  }
  function claim() external whenNotPaused nonReentrant {
    DevInfo storage info = devInfo[msg.sender];
    uint256 pending = info.pendingRewards +
      (totalRewardDebt - info.rewardDebt) *
      info.weight;
    if (pending > 0) {
      uint256 claimedAmount = safeRewardTransfer(msg.sender, pending);
      info.pendingRewards = pending - claimedAmount;
      emit Claim(msg.sender, claimedAmount);
    }
    info.rewardDebt = totalRewardDebt;
  }
  function pendingRewards(address user) external view returns (uint256) {
    DevInfo storage info = devInfo[user];
    return
      info.pendingRewards + (totalRewardDebt - info.rewardDebt) * info.weight;
  }
  function safeRewardTransfer(
    address to,
    uint256 amount
  ) internal returns (uint256) {
    uint256 _rewardBalance = payable(address(this)).balance;
    if (amount > _rewardBalance) amount = _rewardBalance;
    (bool success, ) = payable(to).call{ value: amount }('');
    require(success, 'Failed to send Reward');
    return amount;
  }
}
pragma solidity ^0.8.20;
interface IEntityForging {
  struct Listing {
    address account;
    uint256 tokenId;
    bool isListed;
    uint256 fee;
  }
  event ListedForForging(uint256 tokenId, uint256 fee);
  event EntityForged(
    uint256 indexed newTokenid,
    uint256 indexed parent1Id,
    uint256 indexed parent2Id,
    uint256 newEntropy,
    uint256 forgingFee
  );
  event CancelledListingForForging(uint256 tokenId);
  function setNukeFundAddress(address payable _nukeFundAddress) external;
  function setTaxCut(uint256 _taxCut) external;
  function setOneYearInDays(uint256 value) external;
  function setMinimumListingFee(uint256 _fee) external;
  function listForForging(uint256 tokenId, uint256 fee) external;
  function forgeWithListed(
    uint256 forgerTokenId,
    uint256 mergerTokenId
  ) external payable returns (uint256);
  function cancelListingForForging(uint256 tokenId) external;
  function fetchListings() external view returns (Listing[] memory);
  function getListedTokenIds(uint tokenId_) external view returns (uint);
  function getListings(uint id) external view returns (Listing memory);
}
pragma solidity ^0.8.20;
interface ITraitForgeNft is IERC721Enumerable {
  event Minted(
    address indexed minter,
    uint256 indexed itemId,
    uint256 indexed generation,
    uint256 entropyValue,
    uint256 mintPrice
  );
  event NewEntityMinted(
    address indexed owner,
    uint256 indexed tokenId,
    uint256 indexed generation,
    uint256 entropy
  );
  event GenerationIncremented(uint256 newGeneration);
  event FundsDistributedToNukeFund(address indexed to, uint256 amount);
  event NukeFundContractUpdated(address nukeFundAddress);
  function setNukeFundContract(address payable _nukeFundAddress) external;
  function setEntityForgingContract(address _entityForgingAddress) external;
  function setEntropyGenerator(address _entropyGeneratorAddress) external;
  function setAirdropContract(address _airdrop) external;
  function setStartPrice(uint256 _startPrice) external;
  function setPriceIncrement(uint256 _priceIncrement) external;
  function setPriceIncrementByGen(uint256 _priceIncrementByGen) external;
  function startAirdrop(uint256 amount) external;
  function isApprovedOrOwner(
    address spender,
    uint256 tokenId
  ) external view returns (bool);
  function burn(uint256 tokenId) external;
  function forge(
    address newOwner,
    uint256 parent1Id,
    uint256 parent2Id,
    string memory baseTokenURI
  ) external returns (uint256);
  function mintToken(bytes32[] calldata proof) external payable;
  function mintWithBudget(bytes32[] calldata proof) external payable;
  function calculateMintPrice() external view returns (uint256);
  function getTokenEntropy(uint256 tokenId) external view returns (uint256);
  function getTokenGeneration(uint256 tokenId) external view returns (uint256);
  function getEntropiesForTokens(
    uint256 forgerTokenId,
    uint256 mergerTokenId
  ) external view returns (uint256 forgerEntropy, uint256 mergerEntropy);
  function getTokenLastTransferredTimestamp(
    uint256 tokenId
  ) external view returns (uint256);
  function getTokenCreationTimestamp(
    uint256 tokenId
  ) external view returns (uint256);
  function isForger(uint256 tokenId) external view returns (bool);
}
pragma solidity ^0.8.20;
contract EntityForging is IEntityForging, ReentrancyGuard, Ownable, Pausable {
  ITraitForgeNft public nftContract;
  address payable public nukeFundAddress;
  uint256 public taxCut = 10;
  uint256 public oneYearInDays = 365 days;
  uint256 public listingCount = 0;
  uint256 public minimumListFee = 0.01 ether;
  mapping(uint256 => uint256) public listedTokenIds;
  mapping(uint256 => Listing) public listings;
  mapping(uint256 => uint8) public forgingCounts; 
  mapping(uint256 => uint256) private lastForgeResetTimestamp;
  constructor(address _traitForgeNft) {
    nftContract = ITraitForgeNft(_traitForgeNft);
  }
  function setNukeFundAddress(
    address payable _nukeFundAddress
  ) external onlyOwner {
    nukeFundAddress = _nukeFundAddress;
  }
  function setTaxCut(uint256 _taxCut) external onlyOwner {
    taxCut = _taxCut;
  }
  function setOneYearInDays(uint256 value) external onlyOwner {
    oneYearInDays = value;
  }
  function setMinimumListingFee(uint256 _fee) external onlyOwner {
    minimumListFee = _fee;
  }
  function fetchListings() external view returns (Listing[] memory _listings) {
    _listings = new Listing[](listingCount + 1);
    for (uint256 i = 1; i <= listingCount; ++i) {
      _listings[i] = listings[i];
    }
  }
  function getListedTokenIds(
    uint tokenId_
  ) external view override returns (uint) {
    return listedTokenIds[tokenId_];
  }
  function getListings(
    uint id
  ) external view override returns (Listing memory) {
    return listings[id];
  }
  function listForForging(
    uint256 tokenId,
    uint256 fee
  ) public whenNotPaused nonReentrant {
    Listing memory _listingInfo = listings[listedTokenIds[tokenId]];
    require(!_listingInfo.isListed, 'Token is already listed for forging');
    require(
      nftContract.ownerOf(tokenId) == msg.sender,
      'Caller must own the token'
    );
    require(
      fee >= minimumListFee,
      'Fee should be higher than minimum listing fee'
    );
    _resetForgingCountIfNeeded(tokenId);
    uint256 entropy = nftContract.getTokenEntropy(tokenId); 
    uint8 forgePotential = uint8((entropy / 10) % 10); 
    require(
      forgePotential > 0 && forgingCounts[tokenId] <= forgePotential,
      'Entity has reached its forging limit'
    );
    bool isForger = (entropy % 3) == 0; 
    require(isForger, 'Only forgers can list for forging');
    ++listingCount;
    listings[listingCount] = Listing(msg.sender, tokenId, true, fee);
    listedTokenIds[tokenId] = listingCount;
    emit ListedForForging(tokenId, fee);
  }
  function forgeWithListed(
    uint256 forgerTokenId,
    uint256 mergerTokenId
  ) external payable whenNotPaused nonReentrant returns (uint256) {
    Listing memory _forgerListingInfo = listings[listedTokenIds[forgerTokenId]];
    require(
      _forgerListingInfo.isListed,
      "Forger's entity not listed for forging"
    );
    require(
      nftContract.ownerOf(mergerTokenId) == msg.sender,
      'Caller must own the merger token'
    );
    require(
      nftContract.ownerOf(forgerTokenId) != msg.sender,
      'Caller should be different from forger token owner'
    );
    require(
      nftContract.getTokenGeneration(mergerTokenId) ==
        nftContract.getTokenGeneration(forgerTokenId),
      'Invalid token generation'
    );
    uint256 forgingFee = _forgerListingInfo.fee;
    require(msg.value >= forgingFee, 'Insufficient fee for forging');
    _resetForgingCountIfNeeded(forgerTokenId); 
    _resetForgingCountIfNeeded(mergerTokenId); 
    forgingCounts[forgerTokenId]++;
    uint256 mergerEntropy = nftContract.getTokenEntropy(mergerTokenId);
    require(mergerEntropy % 3 != 0, 'Not merger');
    uint8 mergerForgePotential = uint8((mergerEntropy / 10) % 10); 
    forgingCounts[mergerTokenId]++;
    require(
      mergerForgePotential > 0 &&
        forgingCounts[mergerTokenId] <= mergerForgePotential,
      'forgePotential insufficient'
    );
    uint256 devFee = forgingFee / taxCut;
    uint256 forgerShare = forgingFee - devFee;
    address payable forgerOwner = payable(nftContract.ownerOf(forgerTokenId));
    uint256 newTokenId = nftContract.forge(
      msg.sender,
      forgerTokenId,
      mergerTokenId,
      ''
    );
    (bool success, ) = nukeFundAddress.call{ value: devFee }('');
    require(success, 'Failed to send to NukeFund');
    (bool success_forge, ) = forgerOwner.call{ value: forgerShare }('');
    require(success_forge, 'Failed to send to Forge Owner');
    _cancelListingForForging(forgerTokenId);
    uint256 newEntropy = nftContract.getTokenEntropy(newTokenId);
    emit EntityForged(
      newTokenId,
      forgerTokenId,
      mergerTokenId,
      newEntropy,
      forgingFee
    );
    return newTokenId;
  }
  function cancelListingForForging(
    uint256 tokenId
  ) external whenNotPaused nonReentrant {
    require(
      nftContract.ownerOf(tokenId) == msg.sender ||
        msg.sender == address(nftContract),
      'Caller must own the token'
    );
    require(
      listings[listedTokenIds[tokenId]].isListed,
      'Token not listed for forging'
    );
    _cancelListingForForging(tokenId);
  }
  function _cancelListingForForging(uint256 tokenId) internal {
    delete listings[listedTokenIds[tokenId]];
    emit CancelledListingForForging(tokenId); 
  }
  function _resetForgingCountIfNeeded(uint256 tokenId) private {
    uint256 oneYear = oneYearInDays;
    if (lastForgeResetTimestamp[tokenId] == 0) {
      lastForgeResetTimestamp[tokenId] = block.timestamp;
    } else if (block.timestamp >= lastForgeResetTimestamp[tokenId] + oneYear) {
      forgingCounts[tokenId] = 0; 
      lastForgeResetTimestamp[tokenId] = block.timestamp;
    }
  }
}
pragma solidity ^0.8.20;
interface IEntityTrading {
  struct Listing {
    address seller; 
    uint256 tokenId; 
    uint256 price; 
    bool isActive; 
  }
  event NFTListed(
    uint256 indexed tokenId,
    address indexed seller,
    uint256 price
  );
  event NFTSold(
    uint256 indexed tokenId,
    address indexed seller,
    address indexed buyer,
    uint256 price,
    uint256 nukeFundContribution
  );
  event ListingCanceled(uint256 indexed tokenId, address indexed seller);
  event NukeFundContribution(address indexed from, uint256 amount);
  function setNukeFundAddress(address payable _nukeFundAddress) external;
  function setTaxCut(uint256 _taxCut) external;
  function listNFTForSale(uint256 tokenId, uint256 price) external;
  function buyNFT(uint256 tokenId) external payable;
  function cancelListing(uint256 tokenId) external;
}
pragma solidity ^0.8.20;
contract EntityTrading is IEntityTrading, ReentrancyGuard, Ownable, Pausable {
  ITraitForgeNft public nftContract;
  address payable public nukeFundAddress;
  uint256 public taxCut = 10;
  uint256 public listingCount = 0;
  mapping(uint256 => uint256) public listedTokenIds;
  mapping(uint256 => Listing) public listings;
  constructor(address _traitForgeNft) {
    nftContract = ITraitForgeNft(_traitForgeNft);
  }
  function setNukeFundAddress(
    address payable _nukeFundAddress
  ) external onlyOwner {
    nukeFundAddress = _nukeFundAddress;
  }
  function setTaxCut(uint256 _taxCut) external onlyOwner {
    taxCut = _taxCut;
  }
  function listNFTForSale(
    uint256 tokenId,
    uint256 price
  ) public whenNotPaused nonReentrant {
    require(price > 0, 'Price must be greater than zero');
    require(
      nftContract.ownerOf(tokenId) == msg.sender,
      'Sender must be the NFT owner.'
    );
    require(
      nftContract.getApproved(tokenId) == address(this) ||
        nftContract.isApprovedForAll(msg.sender, address(this)),
      'Contract must be approved to transfer the NFT.'
    );
    nftContract.transferFrom(msg.sender, address(this), tokenId); 
    ++listingCount;
    listings[listingCount] = Listing(msg.sender, tokenId, price, true);
    listedTokenIds[tokenId] = listingCount;
    emit NFTListed(tokenId, msg.sender, price);
  }
  function buyNFT(uint256 tokenId) external payable whenNotPaused nonReentrant {
    Listing memory listing = listings[listedTokenIds[tokenId]];
    require(
      msg.value == listing.price,
      'ETH sent does not match the listing price'
    );
    require(listing.seller != address(0), 'NFT is not listed for sale.');
    uint256 nukeFundContribution = msg.value / taxCut;
    uint256 sellerProceeds = msg.value - nukeFundContribution;
    transferToNukeFund(nukeFundContribution); 
    (bool success, ) = payable(listing.seller).call{ value: sellerProceeds }(
      ''
    );
    require(success, 'Failed to send to seller');
    nftContract.transferFrom(address(this), msg.sender, tokenId); 
    delete listings[listedTokenIds[tokenId]]; 
    emit NFTSold(
      tokenId,
      listing.seller,
      msg.sender,
      msg.value,
      nukeFundContribution
    ); 
  }
  function cancelListing(uint256 tokenId) public whenNotPaused nonReentrant {
    Listing storage listing = listings[listedTokenIds[tokenId]];
    require(
      listing.seller == msg.sender,
      'Only the seller can canel the listing.'
    );
    require(listing.isActive, 'Listing is not active.');
    nftContract.transferFrom(address(this), msg.sender, tokenId); 
    delete listings[listedTokenIds[tokenId]]; 
    emit ListingCanceled(tokenId, msg.sender);
  }
  function transferToNukeFund(uint256 amount) private {
    require(nukeFundAddress != address(0), 'NukeFund address not set');
    (bool success, ) = nukeFundAddress.call{ value: amount }('');
    require(success, 'Failed to send Ether to NukeFund');
    emit NukeFundContribution(address(this), amount);
  }
}
pragma solidity ^0.8.20;
interface IEntropyGenerator {
  event AllowedCallerUpdated(address allowedCaller);
  event EntropyRetrieved(uint256 indexed entropy);
  function setAllowedCaller(address _allowedCaller) external;
  function getAllowedCaller() external view returns (address);
  function writeEntropyBatch1() external;
  function writeEntropyBatch2() external;
  function writeEntropyBatch3() external;
  function getNextEntropy() external returns (uint256);
  function getPublicEntropy(
    uint256 slotIndex,
    uint256 numberIndex
  ) external view returns (uint256);
  function getLastInitializedIndex() external view returns (uint256);
  function initializeAlphaIndices() external;
  function deriveTokenParameters(
    uint256 slotIndex,
    uint256 numberIndex
  )
    external
    view
    returns (
      uint256 nukeFactor,
      uint256 forgePotential,
      uint256 performanceFactor,
      bool isForger
    );
}
pragma solidity ^0.8.20;
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
pragma solidity ^0.8.20;
interface INukeFund {
  event FundBalanceUpdated(uint256 newBalance);
  event FundReceived(address indexed from, uint256 amount);
  event Nuked(
    address indexed owner,
    uint256 indexed tokenId,
    uint256 nukeAmount
  );
  event DevShareDistributed(uint256 devShare);
  event TraitForgeNftAddressUpdated(address indexed newAddress);
  event AirdropAddressUpdated(address indexed newAddress);
  event DevAddressUpdated(address indexed newAddress);
  event DaoAddressUpdated(address indexed newAddress);
  receive() external payable;
  function setTaxCut(uint256 _taxCut) external;
  function setMinimumDaysHeld(uint256 value) external;
  function setDefaultNukeFactorIncrease(uint256 value) external;
  function setMaxAllowedClaimDivisor(uint256 value) external;
  function setNukeFactorMaxParam(uint256 value) external;
  function setTraitForgeNftContract(address _traitForgeNft) external;
  function setAirdropContract(address _airdrop) external;
  function setDevAddress(address payable account) external;
  function setDaoAddress(address payable account) external;
  function getFundBalance() external view returns (uint256);
  function calculateAge(uint256 tokenId) external view returns (uint256);
  function calculateNukeFactor(uint256 tokenId) external view returns (uint256);
  function nuke(uint256 tokenId) external;
  function canTokenBeNuked(uint256 tokenId) external view returns (bool);
}
pragma solidity ^0.8.20;
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
pragma solidity ^0.8.20;
contract TestERC721 is ERC721 {
  uint256 private _tokenIds;
  constructor() ERC721('TraitForgeNft', 'TFGNFT') {}
  function mintToken(address to) external {
    _mint(to, _tokenIds);
    _tokenIds++;
  }
}
pragma solidity ^0.8.20;
contract Trait is ITrait, ERC20Pausable {
  uint8 private _decimals;
  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimal,
    uint256 _totalSupply
  ) ERC20(_name, _symbol) {
    _decimals = _decimal;
    _mint(msg.sender, _totalSupply);
  }
  function decimals() public view virtual override returns (uint8) {
    return _decimals;
  }
  function burn(uint256 amount) external returns (bool) {
    _burn(msg.sender, amount);
    return true;
  }
}
pragma solidity ^0.8.0;
library MerkleProof {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }
        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }
        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
pragma solidity ^0.8.20;
contract TraitForgeNft is
  ITraitForgeNft,
  ERC721Enumerable,
  ReentrancyGuard,
  Ownable,
  Pausable
{
  uint256 public maxTokensPerGen = 10000;
  uint256 public startPrice = 0.005 ether;
  uint256 public priceIncrement = 0.0000245 ether;
  uint256 public priceIncrementByGen = 0.000005 ether;
  IEntityForging public entityForgingContract;
  IEntropyGenerator public entropyGenerator;
  IAirdrop public airdropContract;
  address public nukeFundAddress;
  uint256 public currentGeneration = 1;
  uint256 public maxGeneration = 10;
  bytes32 public rootHash;
  uint256 public whitelistEndTime;
  mapping(uint256 => uint256) public tokenCreationTimestamps;
  mapping(uint256 => uint256) public lastTokenTransferredTimestamp;
  mapping(uint256 => uint256) public tokenEntropy;
  mapping(uint256 => uint256) public generationMintCounts;
  mapping(uint256 => uint256) public tokenGenerations;
  mapping(uint256 => address) public initialOwners;
  uint256 private _tokenIds;
  modifier onlyWhitelisted(bytes32[] calldata proof, bytes32 leaf) {
    if (block.timestamp <= whitelistEndTime) {
      require(
        MerkleProof.verify(proof, rootHash, leaf),
        'Not whitelisted user'
      );
    }
    _;
  }
  constructor() ERC721('TraitForgeNft', 'TFGNFT') {
    whitelistEndTime = block.timestamp + 24 hours;
  }
  function setNukeFundContract(
    address payable _nukeFundAddress
  ) external onlyOwner {
    nukeFundAddress = _nukeFundAddress;
    emit NukeFundContractUpdated(_nukeFundAddress); 
  }
  function setEntityForgingContract(
    address entityForgingAddress_
  ) external onlyOwner {
    require(entityForgingAddress_ != address(0), 'Invalid address');
    entityForgingContract = IEntityForging(entityForgingAddress_);
  }
  function setEntropyGenerator(
    address entropyGeneratorAddress_
  ) external onlyOwner {
    require(entropyGeneratorAddress_ != address(0), 'Invalid address');
    entropyGenerator = IEntropyGenerator(entropyGeneratorAddress_);
  }
  function setAirdropContract(address airdrop_) external onlyOwner {
    require(airdrop_ != address(0), 'Invalid address');
    airdropContract = IAirdrop(airdrop_);
  }
  function startAirdrop(uint256 amount) external whenNotPaused onlyOwner {
    airdropContract.startAirdrop(amount);
  }
  function setStartPrice(uint256 _startPrice) external onlyOwner {
    startPrice = _startPrice;
  }
  function setPriceIncrement(uint256 _priceIncrement) external onlyOwner {
    priceIncrement = _priceIncrement;
  }
  function setPriceIncrementByGen(
    uint256 _priceIncrementByGen
  ) external onlyOwner {
    priceIncrementByGen = _priceIncrementByGen;
  }
  function setMaxGeneration(uint maxGeneration_) external onlyOwner {
    require(
      maxGeneration_ >= currentGeneration,
      "can't below than current generation"
    );
    maxGeneration = maxGeneration_;
  }
  function setRootHash(bytes32 rootHash_) external onlyOwner {
    rootHash = rootHash_;
  }
  function setWhitelistEndTime(uint256 endTime_) external onlyOwner {
    whitelistEndTime = endTime_;
  }
  function getGeneration() public view returns (uint256) {
    return currentGeneration;
  }
  function isApprovedOrOwner(
    address spender,
    uint256 tokenId
  ) public view returns (bool) {
    return _isApprovedOrOwner(spender, tokenId);
  }
  function burn(uint256 tokenId) external whenNotPaused nonReentrant {
    require(
      isApprovedOrOwner(msg.sender, tokenId),
      'ERC721: caller is not token owner or approved'
    );
    if (!airdropContract.airdropStarted()) {
      uint256 entropy = getTokenEntropy(tokenId);
      airdropContract.subUserAmount(initialOwners[tokenId], entropy);
    }
    _burn(tokenId);
  }
  function forge(
    address newOwner,
    uint256 parent1Id,
    uint256 parent2Id,
    string memory
  ) external whenNotPaused nonReentrant returns (uint256) {
    require(
      msg.sender == address(entityForgingContract),
      'unauthorized caller'
    );
    uint256 newGeneration = getTokenGeneration(parent1Id) + 1;
    require(newGeneration <= maxGeneration, "can't be over max generation");
    (uint256 forgerEntropy, uint256 mergerEntropy) = getEntropiesForTokens(
      parent1Id,
      parent2Id
    );
    uint256 newEntropy = (forgerEntropy + mergerEntropy) / 2;
    uint256 newTokenId = _mintNewEntity(newOwner, newEntropy, newGeneration);
    return newTokenId;
  }
  function mintToken(
    bytes32[] calldata proof
  )
    public
    payable
    whenNotPaused
    nonReentrant
    onlyWhitelisted(proof, keccak256(abi.encodePacked(msg.sender)))
  {
    uint256 mintPrice = calculateMintPrice();
    require(msg.value >= mintPrice, 'Insufficient ETH send for minting.');
    _mintInternal(msg.sender, mintPrice);
    uint256 excessPayment = msg.value - mintPrice;
    if (excessPayment > 0) {
      (bool refundSuccess, ) = msg.sender.call{ value: excessPayment }('');
      require(refundSuccess, 'Refund of excess payment failed.');
    }
  }
  function mintWithBudget(
    bytes32[] calldata proof
  )
    public
    payable
    whenNotPaused
    nonReentrant
    onlyWhitelisted(proof, keccak256(abi.encodePacked(msg.sender)))
  {
    uint256 mintPrice = calculateMintPrice();
    uint256 amountMinted = 0;
    uint256 budgetLeft = msg.value;
    while (budgetLeft >= mintPrice && _tokenIds < maxTokensPerGen) {
      _mintInternal(msg.sender, mintPrice);
      amountMinted++;
      budgetLeft -= mintPrice;
      mintPrice = calculateMintPrice();
    }
    if (budgetLeft > 0) {
      (bool refundSuccess, ) = msg.sender.call{ value: budgetLeft }('');
      require(refundSuccess, 'Refund failed.');
    }
  }
  function calculateMintPrice() public view returns (uint256) {
    uint256 currentGenMintCount = generationMintCounts[currentGeneration];
    uint256 priceIncrease = priceIncrement * currentGenMintCount;
    uint256 price = startPrice + priceIncrease;
    return price;
  }
  function getTokenEntropy(uint256 tokenId) public view returns (uint256) {
    require(
      ownerOf(tokenId) != address(0),
      'ERC721: query for nonexistent token'
    );
    return tokenEntropy[tokenId];
  }
  function getTokenGeneration(uint256 tokenId) public view returns (uint256) {
    return tokenGenerations[tokenId];
  }
  function getEntropiesForTokens(
    uint256 forgerTokenId,
    uint256 mergerTokenId
  ) public view returns (uint256 forgerEntropy, uint256 mergerEntropy) {
    forgerEntropy = getTokenEntropy(forgerTokenId);
    mergerEntropy = getTokenEntropy(mergerTokenId);
  }
  function getTokenLastTransferredTimestamp(
    uint256 tokenId
  ) public view returns (uint256) {
    require(
      ownerOf(tokenId) != address(0),
      'ERC721: query for nonexistent token'
    );
    return lastTokenTransferredTimestamp[tokenId];
  }
  function getTokenCreationTimestamp(
    uint256 tokenId
  ) public view returns (uint256) {
    require(
      ownerOf(tokenId) != address(0),
      'ERC721: query for nonexistent token'
    );
    return tokenCreationTimestamps[tokenId];
  }
  function isForger(uint256 tokenId) public view returns (bool) {
    uint256 entropy = tokenEntropy[tokenId];
    uint256 roleIndicator = entropy % 3;
    return roleIndicator == 0;
  }
  function _mintInternal(address to, uint256 mintPrice) internal {
    if (generationMintCounts[currentGeneration] >= maxTokensPerGen) {
      _incrementGeneration();
    }
    _tokenIds++;
    uint256 newItemId = _tokenIds;
    _mint(to, newItemId);
    uint256 entropyValue = entropyGenerator.getNextEntropy();
    tokenCreationTimestamps[newItemId] = block.timestamp;
    tokenEntropy[newItemId] = entropyValue;
    tokenGenerations[newItemId] = currentGeneration;
    generationMintCounts[currentGeneration]++;
    initialOwners[newItemId] = to;
    if (!airdropContract.airdropStarted()) {
      airdropContract.addUserAmount(to, entropyValue);
    }
    emit Minted(
      msg.sender,
      newItemId,
      currentGeneration,
      entropyValue,
      mintPrice
    );
    _distributeFunds(mintPrice);
  }
  function _mintNewEntity(
    address newOwner,
    uint256 entropy,
    uint256 gen
  ) private returns (uint256) {
    require(
      generationMintCounts[gen] < maxTokensPerGen,
      'Exceeds maxTokensPerGen'
    );
    _tokenIds++;
    uint256 newTokenId = _tokenIds;
    _mint(newOwner, newTokenId);
    tokenCreationTimestamps[newTokenId] = block.timestamp;
    tokenEntropy[newTokenId] = entropy;
    tokenGenerations[newTokenId] = gen;
    generationMintCounts[gen]++;
    initialOwners[newTokenId] = newOwner;
    if (
      generationMintCounts[gen] >= maxTokensPerGen && gen == currentGeneration
    ) {
      _incrementGeneration();
    }
    if (!airdropContract.airdropStarted()) {
      airdropContract.addUserAmount(newOwner, entropy);
    }
    emit NewEntityMinted(newOwner, newTokenId, gen, entropy);
    return newTokenId;
  }
  function _incrementGeneration() private {
    require(
      generationMintCounts[currentGeneration] >= maxTokensPerGen,
      'Generation limit not yet reached'
    );
    currentGeneration++;
    generationMintCounts[currentGeneration] = 0;
    priceIncrement = priceIncrement + priceIncrementByGen;
    entropyGenerator.initializeAlphaIndices();
    emit GenerationIncremented(currentGeneration);
  }
  function _distributeFunds(uint256 totalAmount) private {
    require(address(this).balance >= totalAmount, 'Insufficient balance');
    (bool success, ) = nukeFundAddress.call{ value: totalAmount }('');
    require(success, 'ETH send failed');
    emit FundsDistributedToNukeFund(nukeFundAddress, totalAmount);
  }
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 firstTokenId,
    uint256 batchSize
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    uint listedId = entityForgingContract.getListedTokenIds(firstTokenId);
    if (from != to) {
      lastTokenTransferredTimestamp[firstTokenId] = block.timestamp;
    }
    if (listedId > 0) {
      IEntityForging.Listing memory listing = entityForgingContract.getListings(
        listedId
      );
      if (
        listing.tokenId == firstTokenId &&
        listing.account == from &&
        listing.isListed
      ) {
        entityForgingContract.cancelListingForForging(firstTokenId);
      }
    }
    require(!paused(), 'ERC721Pausable: token transfer while paused');
  }
}
pragma solidity ^0.8.20;
interface IDAOFund {
  struct UserInfo {
    uint256 amount;
    uint256 rewardDebt;
    uint256 pendingRewards;
  }
  event Deposit(address indexed account, uint256 amount);
  event Withdraw(address indexed account, uint256 amount);
  event Claim(address indexed account, uint256 amount);
  event FundReceived(address indexed from, uint256 amount); 
  receive() external payable;
  function deposit(uint256 amount) external;
  function withdraw(uint256 amount) external;
  function claim() external;
  function pendingRewards(address account) external view returns (uint256);
}