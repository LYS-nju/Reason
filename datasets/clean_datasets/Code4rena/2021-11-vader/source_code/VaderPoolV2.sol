pragma experimental ABIEncoderV2;
pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
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
interface IVotes {
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
    function getVotes(address account) external view returns (uint256);
    function getPastVotes(address account, uint256 timepoint) external view returns (uint256);
    function getPastTotalSupply(uint256 timepoint) external view returns (uint256);
    function delegates(address account) external view returns (address);
    function delegate(address delegatee) external;
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external;
}
pragma solidity ^0.8.0;
interface IERC6372 {
    function clock() external view returns (uint48);
    function CLOCK_MODE() external view returns (string memory);
}
pragma solidity ^0.8.0;
interface IERC5805 is IERC6372, IVotes {}
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
pragma solidity ^0.8.0;
library Counters {
    struct Counter {
        uint256 _value; 
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
    function reset(Counter storage counter) internal {
        counter._value = 0;
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
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV 
    }
    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; 
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }
        return (signer, RecoverError.NoError);
    }
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
pragma solidity ^0.8.0;
interface IERC5267 {
    event EIP712DomainChanged();
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
pragma solidity ^0.8.0;
library StorageSlot {
    struct AddressSlot {
        address value;
    }
    struct BooleanSlot {
        bool value;
    }
    struct Bytes32Slot {
        bytes32 value;
    }
    struct Uint256Slot {
        uint256 value;
    }
    struct StringSlot {
        string value;
    }
    struct BytesSlot {
        bytes value;
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
}
pragma solidity ^0.8.8;
type ShortString is bytes32;
library ShortStrings {
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;
    error StringTooLong(string str);
    error InvalidShortString();
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        string memory str = new string(32);
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
pragma solidity ^0.8.8;
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;
    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;
    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;
    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));
        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }
    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", 
            _name.toStringWithFallback(_nameFallback),
            _version.toStringWithFallback(_versionFallback),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }
}
pragma solidity ^0.8.0;
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;
    mapping(address => Counters.Counter) private _nonces;
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;
    constructor(string memory name) EIP712(name, "1") {}
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");
        _approve(owner, spender, value);
    }
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}
pragma solidity ^0.8.0;
library SafeCast {
    function toUint248(uint256 value) internal pure returns (uint248) {
        require(value <= type(uint248).max, "SafeCast: value doesn't fit in 248 bits");
        return uint248(value);
    }
    function toUint240(uint256 value) internal pure returns (uint240) {
        require(value <= type(uint240).max, "SafeCast: value doesn't fit in 240 bits");
        return uint240(value);
    }
    function toUint232(uint256 value) internal pure returns (uint232) {
        require(value <= type(uint232).max, "SafeCast: value doesn't fit in 232 bits");
        return uint232(value);
    }
    function toUint224(uint256 value) internal pure returns (uint224) {
        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }
    function toUint216(uint256 value) internal pure returns (uint216) {
        require(value <= type(uint216).max, "SafeCast: value doesn't fit in 216 bits");
        return uint216(value);
    }
    function toUint208(uint256 value) internal pure returns (uint208) {
        require(value <= type(uint208).max, "SafeCast: value doesn't fit in 208 bits");
        return uint208(value);
    }
    function toUint200(uint256 value) internal pure returns (uint200) {
        require(value <= type(uint200).max, "SafeCast: value doesn't fit in 200 bits");
        return uint200(value);
    }
    function toUint192(uint256 value) internal pure returns (uint192) {
        require(value <= type(uint192).max, "SafeCast: value doesn't fit in 192 bits");
        return uint192(value);
    }
    function toUint184(uint256 value) internal pure returns (uint184) {
        require(value <= type(uint184).max, "SafeCast: value doesn't fit in 184 bits");
        return uint184(value);
    }
    function toUint176(uint256 value) internal pure returns (uint176) {
        require(value <= type(uint176).max, "SafeCast: value doesn't fit in 176 bits");
        return uint176(value);
    }
    function toUint168(uint256 value) internal pure returns (uint168) {
        require(value <= type(uint168).max, "SafeCast: value doesn't fit in 168 bits");
        return uint168(value);
    }
    function toUint160(uint256 value) internal pure returns (uint160) {
        require(value <= type(uint160).max, "SafeCast: value doesn't fit in 160 bits");
        return uint160(value);
    }
    function toUint152(uint256 value) internal pure returns (uint152) {
        require(value <= type(uint152).max, "SafeCast: value doesn't fit in 152 bits");
        return uint152(value);
    }
    function toUint144(uint256 value) internal pure returns (uint144) {
        require(value <= type(uint144).max, "SafeCast: value doesn't fit in 144 bits");
        return uint144(value);
    }
    function toUint136(uint256 value) internal pure returns (uint136) {
        require(value <= type(uint136).max, "SafeCast: value doesn't fit in 136 bits");
        return uint136(value);
    }
    function toUint128(uint256 value) internal pure returns (uint128) {
        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }
    function toUint120(uint256 value) internal pure returns (uint120) {
        require(value <= type(uint120).max, "SafeCast: value doesn't fit in 120 bits");
        return uint120(value);
    }
    function toUint112(uint256 value) internal pure returns (uint112) {
        require(value <= type(uint112).max, "SafeCast: value doesn't fit in 112 bits");
        return uint112(value);
    }
    function toUint104(uint256 value) internal pure returns (uint104) {
        require(value <= type(uint104).max, "SafeCast: value doesn't fit in 104 bits");
        return uint104(value);
    }
    function toUint96(uint256 value) internal pure returns (uint96) {
        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }
    function toUint88(uint256 value) internal pure returns (uint88) {
        require(value <= type(uint88).max, "SafeCast: value doesn't fit in 88 bits");
        return uint88(value);
    }
    function toUint80(uint256 value) internal pure returns (uint80) {
        require(value <= type(uint80).max, "SafeCast: value doesn't fit in 80 bits");
        return uint80(value);
    }
    function toUint72(uint256 value) internal pure returns (uint72) {
        require(value <= type(uint72).max, "SafeCast: value doesn't fit in 72 bits");
        return uint72(value);
    }
    function toUint64(uint256 value) internal pure returns (uint64) {
        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }
    function toUint56(uint256 value) internal pure returns (uint56) {
        require(value <= type(uint56).max, "SafeCast: value doesn't fit in 56 bits");
        return uint56(value);
    }
    function toUint48(uint256 value) internal pure returns (uint48) {
        require(value <= type(uint48).max, "SafeCast: value doesn't fit in 48 bits");
        return uint48(value);
    }
    function toUint40(uint256 value) internal pure returns (uint40) {
        require(value <= type(uint40).max, "SafeCast: value doesn't fit in 40 bits");
        return uint40(value);
    }
    function toUint32(uint256 value) internal pure returns (uint32) {
        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }
    function toUint24(uint256 value) internal pure returns (uint24) {
        require(value <= type(uint24).max, "SafeCast: value doesn't fit in 24 bits");
        return uint24(value);
    }
    function toUint16(uint256 value) internal pure returns (uint16) {
        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }
    function toUint8(uint256 value) internal pure returns (uint8) {
        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }
    function toUint256(int256 value) internal pure returns (uint256) {
        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 248 bits");
    }
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 240 bits");
    }
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 232 bits");
    }
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 224 bits");
    }
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 216 bits");
    }
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 208 bits");
    }
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 200 bits");
    }
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 192 bits");
    }
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 184 bits");
    }
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 176 bits");
    }
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 168 bits");
    }
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 160 bits");
    }
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 152 bits");
    }
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 144 bits");
    }
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 136 bits");
    }
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 128 bits");
    }
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 120 bits");
    }
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 112 bits");
    }
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 104 bits");
    }
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 96 bits");
    }
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 88 bits");
    }
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 80 bits");
    }
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 72 bits");
    }
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 64 bits");
    }
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 56 bits");
    }
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 48 bits");
    }
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 40 bits");
    }
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 32 bits");
    }
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 24 bits");
    }
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 16 bits");
    }
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        require(downcasted == value, "SafeCast: value doesn't fit in 8 bits");
    }
    function toInt256(uint256 value) internal pure returns (int256) {
        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}
pragma solidity ^0.8.0;
abstract contract ERC20Votes is ERC20Permit, IERC5805 {
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }
    bytes32 private constant _DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    mapping(address => address) private _delegates;
    mapping(address => Checkpoint[]) private _checkpoints;
    Checkpoint[] private _totalSupplyCheckpoints;
    function clock() public view virtual override returns (uint48) {
        return SafeCast.toUint48(block.number);
    }
    function CLOCK_MODE() public view virtual override returns (string memory) {
        require(clock() == block.number, "ERC20Votes: broken clock mode");
        return "mode=blocknumber&from=default";
    }
    function checkpoints(address account, uint32 pos) public view virtual returns (Checkpoint memory) {
        return _checkpoints[account][pos];
    }
    function numCheckpoints(address account) public view virtual returns (uint32) {
        return SafeCast.toUint32(_checkpoints[account].length);
    }
    function delegates(address account) public view virtual override returns (address) {
        return _delegates[account];
    }
    function getVotes(address account) public view virtual override returns (uint256) {
        uint256 pos = _checkpoints[account].length;
        unchecked {
            return pos == 0 ? 0 : _checkpoints[account][pos - 1].votes;
        }
    }
    function getPastVotes(address account, uint256 timepoint) public view virtual override returns (uint256) {
        require(timepoint < clock(), "ERC20Votes: future lookup");
        return _checkpointsLookup(_checkpoints[account], timepoint);
    }
    function getPastTotalSupply(uint256 timepoint) public view virtual override returns (uint256) {
        require(timepoint < clock(), "ERC20Votes: future lookup");
        return _checkpointsLookup(_totalSupplyCheckpoints, timepoint);
    }
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 timepoint) private view returns (uint256) {
        uint256 length = ckpts.length;
        uint256 low = 0;
        uint256 high = length;
        if (length > 5) {
            uint256 mid = length - Math.sqrt(length);
            if (_unsafeAccess(ckpts, mid).fromBlock > timepoint) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        while (low < high) {
            uint256 mid = Math.average(low, high);
            if (_unsafeAccess(ckpts, mid).fromBlock > timepoint) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        unchecked {
            return high == 0 ? 0 : _unsafeAccess(ckpts, high - 1).votes;
        }
    }
    function delegate(address delegatee) public virtual override {
        _delegate(_msgSender(), delegatee);
    }
    function delegateBySig(
        address delegatee,
        uint256 nonce,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= expiry, "ERC20Votes: signature expired");
        address signer = ECDSA.recover(
            _hashTypedDataV4(keccak256(abi.encode(_DELEGATION_TYPEHASH, delegatee, nonce, expiry))),
            v,
            r,
            s
        );
        require(nonce == _useNonce(signer), "ERC20Votes: invalid nonce");
        _delegate(signer, delegatee);
    }
    function _maxSupply() internal view virtual returns (uint224) {
        return type(uint224).max;
    }
    function _mint(address account, uint256 amount) internal virtual override {
        super._mint(account, amount);
        require(totalSupply() <= _maxSupply(), "ERC20Votes: total supply risks overflowing votes");
        _writeCheckpoint(_totalSupplyCheckpoints, _add, amount);
    }
    function _burn(address account, uint256 amount) internal virtual override {
        super._burn(account, amount);
        _writeCheckpoint(_totalSupplyCheckpoints, _subtract, amount);
    }
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        super._afterTokenTransfer(from, to, amount);
        _moveVotingPower(delegates(from), delegates(to), amount);
    }
    function _delegate(address delegator, address delegatee) internal virtual {
        address currentDelegate = delegates(delegator);
        uint256 delegatorBalance = balanceOf(delegator);
        _delegates[delegator] = delegatee;
        emit DelegateChanged(delegator, currentDelegate, delegatee);
        _moveVotingPower(currentDelegate, delegatee, delegatorBalance);
    }
    function _moveVotingPower(address src, address dst, uint256 amount) private {
        if (src != dst && amount > 0) {
            if (src != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[src], _subtract, amount);
                emit DelegateVotesChanged(src, oldWeight, newWeight);
            }
            if (dst != address(0)) {
                (uint256 oldWeight, uint256 newWeight) = _writeCheckpoint(_checkpoints[dst], _add, amount);
                emit DelegateVotesChanged(dst, oldWeight, newWeight);
            }
        }
    }
    function _writeCheckpoint(
        Checkpoint[] storage ckpts,
        function(uint256, uint256) view returns (uint256) op,
        uint256 delta
    ) private returns (uint256 oldWeight, uint256 newWeight) {
        uint256 pos = ckpts.length;
        unchecked {
            Checkpoint memory oldCkpt = pos == 0 ? Checkpoint(0, 0) : _unsafeAccess(ckpts, pos - 1);
            oldWeight = oldCkpt.votes;
            newWeight = op(oldWeight, delta);
            if (pos > 0 && oldCkpt.fromBlock == clock()) {
                _unsafeAccess(ckpts, pos - 1).votes = SafeCast.toUint224(newWeight);
            } else {
                ckpts.push(Checkpoint({fromBlock: SafeCast.toUint32(clock()), votes: SafeCast.toUint224(newWeight)}));
            }
        }
    }
    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }
    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
    function _unsafeAccess(Checkpoint[] storage ckpts, uint256 pos) private pure returns (Checkpoint storage result) {
        assembly {
            mstore(0, ckpts.slot)
            result.slot := add(keccak256(0, 0x20), pos)
        }
    }
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
pragma solidity ^0.8.0;
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
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
pragma solidity ^0.8.0;
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
pragma solidity =0.8.9;
library VaderMath {
    uint256 public constant ONE = 1 ether;
    function calculateLiquidityUnits(
        uint256 vaderDeposited,
        uint256 vaderBalance,
        uint256 assetDeposited,
        uint256 assetBalance,
        uint256 totalPoolUnits
    ) public pure returns (uint256) {
        uint256 slip = calculateSlipAdjustment(
            vaderDeposited,
            vaderBalance,
            assetDeposited,
            assetBalance
        );
        uint256 poolUnitFactor = (vaderBalance * assetDeposited) +
            (vaderDeposited * assetBalance);
        uint256 denominator = ONE * 2 * vaderBalance * assetBalance;
        return ((totalPoolUnits * poolUnitFactor) / denominator) * slip;
    }
    function calculateSlipAdjustment(
        uint256 vaderDeposited,
        uint256 vaderBalance,
        uint256 assetDeposited,
        uint256 assetBalance
    ) public pure returns (uint256) {
        uint256 vaderAsset = vaderBalance * assetDeposited;
        uint256 assetVader = assetBalance * vaderDeposited;
        uint256 denominator = (vaderDeposited + vaderBalance) *
            (assetDeposited + assetBalance);
        return ONE - (delta(vaderAsset, assetVader) / denominator);
    }
    function calculateLoss(
        uint256 originalVader,
        uint256 originalAsset,
        uint256 releasedVader,
        uint256 releasedAsset
    ) public pure returns (uint256 loss) {
        uint256 originalValue = ((originalAsset * releasedVader) /
            releasedAsset) + originalVader;
        uint256 releasedValue = ((releasedAsset * releasedVader) /
            releasedAsset) + releasedVader;
        if (originalValue > releasedValue) loss = originalValue - releasedValue;
    }
    function calculateSwap(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256 amountOut) {
        uint256 numerator = amountIn * reserveIn * reserveOut;
        uint256 denominator = pow(amountIn + reserveIn);
        amountOut = numerator / denominator;
    }
    function calculateSwapReverse(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256 amountIn) {
        uint256 XY = reserveIn * reserveOut;
        uint256 y2 = amountOut * 2;
        uint256 y4 = y2 * 2;
        require(
            y4 < reserveOut,
            "VaderMath::calculateSwapReverse: Desired Output Exceeds Maximum Output Possible (1/4 of Liquidity Pool)"
        );
        uint256 numeratorA = root(XY) * root(reserveIn * (reserveOut - y4));
        uint256 numeratorB = y2 * reserveIn;
        uint256 numeratorC = XY;
        uint256 numerator = numeratorC - numeratorA - numeratorB;
        uint256 denominator = y2;
        amountIn = numerator / denominator;
    }
    function delta(uint256 a, uint256 b) public pure returns (uint256) {
        return a > b ? a - b : b - a;
    }
    function pow(uint256 a) public pure returns (uint256) {
        return a * a;
    }
    function root(uint256 a) public pure returns (uint256 c) {
        if (a > 3) {
            c = a;
            uint256 x = a / 2 + 1;
            while (x < c) {
                c = x;
                x = (a / x + x) / 2;
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}
pragma solidity =0.8.9;
interface IAggregator {
    function latestAnswer() external view returns (int256);
}
pragma solidity =0.8.9;
abstract contract ProtocolConstants {
    address internal constant _ZERO_ADDRESS = address(0);
    uint256 internal constant _ONE_YEAR = 365 days;
    uint256 internal constant _MAX_BASIS_POINTS = 100_00;
    uint256 internal constant _INITIAL_VADER_SUPPLY = 2_500_000_000 * 1 ether;
    uint256 internal constant _VETH_ALLOCATION = 1_000_000_000 * 1 ether;
    uint256 internal constant _TEAM_ALLOCATION = 250_000_000 * 1 ether;
    uint256 internal constant _ECOSYSTEM_GROWTH = 250_000_000 * 1 ether;
    uint256 internal constant _EMISSION_ERA = 24 hours;
    uint256 internal constant _INITIAL_EMISSION_CURVE = 5;
    uint256 internal constant _MAX_FEE_BASIS_POINTS = 1_00;
    uint256 internal constant _VESTING_DURATION = 2 * _ONE_YEAR;
    uint256 internal constant _VADER_VETHER_CONVERSION_RATE = 1000;
    address internal constant _BURN =
        0xdeaDDeADDEaDdeaDdEAddEADDEAdDeadDEADDEaD;
    uint256 internal constant _MIN_SWAPS_EXECUTED = 10;
    uint256 internal constant _DEFAULT_SWAPS_EXECUTED = 50_00;
    uint256 internal constant _QUEUE_SIZE = 100;
    address internal constant _FAST_GAS_ORACLE =
        0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C;
    uint256 internal constant _GRANT_DELAY = 30 days;
    uint256 internal constant _MAX_GRANT_BASIS_POINTS = 10_00;
}
pragma solidity =0.8.9;
contract GasThrottle is ProtocolConstants {
    modifier validateGas() {
        _;
    }
}
pragma solidity =0.8.9;
library UQ112x112 {
    uint224 constant Q112 = 2**112;
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; 
    }
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}
pragma solidity =0.8.9;
interface IBasePoolV2 {
    struct Position {
        IERC20 foreignAsset;
        uint256 creation;
        uint256 liquidity;
        uint256 originalNative;
        uint256 originalForeign;
    }
    struct PairInfo {
        uint256 totalSupply;
        uint112 reserveNative;
        uint112 reserveForeign;
        uint32 blockTimestampLast;
        PriceCumulative priceCumulative;
    }
    struct PriceCumulative {
        uint256 nativeLast;
        uint256 foreignLast;
    }
    function getReserves(
        IERC20 foreignAsset
    ) external view returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
    function nativeAsset() external view returns (IERC20);
    function supported(IERC20 token) external view returns (bool);
    function positionForeignAsset(uint256 id) external view returns (IERC20);
    function pairSupply(IERC20 foreignAsset) external view returns (uint256);
    function doubleSwap(
        IERC20 foreignAssetA,
        IERC20 foreignAssetB,
        uint256 foreignAmountIn,
        address to
    ) external returns (uint256);
    function swap(
        IERC20 foreignAsset,
        uint256 nativeAmountIn,
        uint256 foreignAmountIn,
        address to
    ) external returns (uint256);
    function mint(
        IERC20 foreignAsset,
        uint256 nativeDeposit,
        uint256 foreignDeposit,
        address from,
        address to
    ) external returns (uint256 liquidity);
    event Mint(
        address indexed sender,
        address indexed to,
        uint256 amount0,
        uint256 amount1
    ); 
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        IERC20 foreignAsset,
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(IERC20 foreignAsset, uint256 reserve0, uint256 reserve1); 
    event PositionOpened(
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 liquidity
    );
    event PositionClosed(
        address indexed sender,
        uint256 id,
        uint256 liquidity,
        uint256 loss
    );
}
pragma solidity =0.8.9;
contract BasePoolV2 is
    IBasePoolV2,
    ProtocolConstants,
    GasThrottle,
    ERC721,
    ReentrancyGuard
{
    using SafeERC20 for IERC20;
    using UQ112x112 for uint224;
    IERC20 public immutable override nativeAsset;
    mapping(IERC20 => bool) public override supported;
    mapping(IERC20 => PairInfo) public pairInfo;
    mapping(uint256 => Position) public positions;
    uint256 public positionId;
    address public router;
    constructor(IERC20 _nativeAsset) ERC721("Vader LP", "VLP") {
        require(
            _nativeAsset != IERC20(_ZERO_ADDRESS),
            "BasePoolV2::constructor: Incorrect Arguments"
        );
        nativeAsset = IERC20(_nativeAsset);
    }
    function getReserves(IERC20 foreignAsset)
        public
        view
        returns (
            uint112 reserveNative,
            uint112 reserveForeign,
            uint32 blockTimestampLast
        )
    {
        PairInfo storage pair = pairInfo[foreignAsset];
        (reserveNative, reserveForeign, blockTimestampLast) = (
            pair.reserveNative,
            pair.reserveForeign,
            pair.blockTimestampLast
        );
    }
    function positionForeignAsset(uint256 id)
        external
        view
        override
        returns (IERC20)
    {
        return positions[id].foreignAsset;
    }
    function pairSupply(IERC20 foreignAsset)
        external
        view
        override
        returns (uint256)
    {
        return pairInfo[foreignAsset].totalSupply;
    }
    function mint(
        IERC20 foreignAsset,
        uint256 nativeDeposit,
        uint256 foreignDeposit,
        address from,
        address to
    )
        external
        override
        nonReentrant
        onlyRouter
        supportedToken(foreignAsset)
        returns (uint256 liquidity)
    {
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(
            foreignAsset
        ); 
        nativeAsset.safeTransferFrom(from, address(this), nativeDeposit);
        foreignAsset.safeTransferFrom(from, address(this), foreignDeposit);
        PairInfo storage pair = pairInfo[foreignAsset];
        uint256 totalLiquidityUnits = pair.totalSupply;
        if (totalLiquidityUnits == 0) liquidity = nativeDeposit;
        else
            liquidity = VaderMath.calculateLiquidityUnits(
                nativeDeposit,
                reserveNative,
                foreignDeposit,
                reserveForeign,
                totalLiquidityUnits
            );
        require(
            liquidity > 0,
            "BasePoolV2::mint: Insufficient Liquidity Provided"
        );
        uint256 id = positionId++;
        pair.totalSupply = totalLiquidityUnits + liquidity;
        _mint(to, id);
        positions[id] = Position(
            foreignAsset,
            block.timestamp,
            liquidity,
            nativeDeposit,
            foreignDeposit
        );
        _update(
            foreignAsset,
            reserveNative + nativeDeposit,
            reserveForeign + foreignDeposit,
            reserveNative,
            reserveForeign
        );
        emit Mint(from, to, nativeDeposit, foreignDeposit);
        emit PositionOpened(from, to, id, liquidity);
    }
    function _burn(uint256 id, address to)
        internal
        nonReentrant
        returns (uint256 amountNative, uint256 amountForeign)
    {
        require(
            ownerOf(id) == address(this),
            "BasePoolV2::burn: Incorrect Ownership"
        );
        IERC20 foreignAsset = positions[id].foreignAsset;
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(
            foreignAsset
        ); 
        uint256 liquidity = positions[id].liquidity;
        PairInfo storage pair = pairInfo[foreignAsset];
        uint256 _totalSupply = pair.totalSupply;
        amountNative = (liquidity * reserveNative) / _totalSupply;
        amountForeign = (liquidity * reserveForeign) / _totalSupply;
        require(
            amountNative > 0 && amountForeign > 0,
            "BasePoolV2::burn: Insufficient Liquidity Burned"
        );
        pair.totalSupply = _totalSupply - liquidity;
        _burn(id);
        nativeAsset.safeTransfer(to, amountNative);
        foreignAsset.safeTransfer(to, amountForeign);
        _update(
            foreignAsset,
            reserveNative - amountNative,
            reserveForeign - amountForeign,
            reserveNative,
            reserveForeign
        );
        emit Burn(msg.sender, amountNative, amountForeign, to);
    }
    function doubleSwap(
        IERC20 foreignAssetA,
        IERC20 foreignAssetB,
        uint256 foreignAmountIn,
        address to
    )
        external
        override
        onlyRouter
        supportedToken(foreignAssetA)
        supportedToken(foreignAssetB)
        nonReentrant
        validateGas
        returns (uint256 foreignAmountOut)
    {
        (uint112 nativeReserve, uint112 foreignReserve, ) = getReserves(
            foreignAssetA
        ); 
        require(
            foreignReserve + foreignAmountIn <=
                foreignAssetA.balanceOf(address(this)),
            "BasePoolV2::doubleSwap: Insufficient Tokens Provided"
        );
        uint256 nativeAmountOut = VaderMath.calculateSwap(
            foreignAmountIn,
            foreignReserve,
            nativeReserve
        );
        require(
            nativeAmountOut > 0 && nativeAmountOut <= nativeReserve,
            "BasePoolV2::doubleSwap: Swap Impossible"
        );
        _update(
            foreignAssetA,
            nativeReserve - nativeAmountOut,
            foreignReserve + foreignAmountIn,
            nativeReserve,
            foreignReserve
        );
        emit Swap(
            foreignAssetA,
            msg.sender,
            0,
            foreignAmountIn,
            nativeAmountOut,
            0,
            address(this)
        );
        (nativeReserve, foreignReserve, ) = getReserves(foreignAssetB); 
        foreignAmountOut = VaderMath.calculateSwap(
            nativeAmountOut,
            nativeReserve,
            foreignReserve
        );
        require(
            foreignAmountOut > 0 && foreignAmountOut <= foreignReserve,
            "BasePoolV2::doubleSwap: Swap Impossible"
        );
        _update(
            foreignAssetB,
            nativeReserve + nativeAmountOut,
            foreignReserve - foreignAmountOut,
            nativeReserve,
            foreignReserve
        );
        emit Swap(
            foreignAssetB,
            msg.sender,
            nativeAmountOut,
            0,
            0,
            foreignAmountOut,
            to
        );
        foreignAssetB.safeTransfer(to, foreignAmountOut);
    }
    function swap(
        IERC20 foreignAsset,
        uint256 nativeAmountIn,
        uint256 foreignAmountIn,
        address to
    )
        external
        override
        onlyRouter
        supportedToken(foreignAsset)
        nonReentrant
        validateGas
        returns (uint256)
    {
        require(
            (nativeAmountIn > 0 && foreignAmountIn == 0) ||
                (nativeAmountIn == 0 && foreignAmountIn > 0),
            "BasePoolV2::swap: Only One-Sided Swaps Supported"
        );
        (uint112 nativeReserve, uint112 foreignReserve, ) = getReserves(
            foreignAsset
        ); 
        uint256 nativeAmountOut;
        uint256 foreignAmountOut;
        {
            IERC20 _nativeAsset = nativeAsset;
            require(
                to != address(_nativeAsset) && to != address(foreignAsset),
                "BasePoolV2::swap: Invalid Receiver"
            );
            if (foreignAmountIn > 0) {
                nativeAmountOut = VaderMath.calculateSwap(
                    foreignAmountIn,
                    foreignReserve,
                    nativeReserve
                );
                require(
                    nativeAmountOut > 0 && nativeAmountOut <= nativeReserve,
                    "BasePoolV2::swap: Swap Impossible"
                );
                _nativeAsset.safeTransfer(to, nativeAmountOut); 
            } else {
                foreignAmountOut = VaderMath.calculateSwap(
                    nativeAmountIn,
                    nativeReserve,
                    foreignReserve
                );
                require(
                    foreignAmountOut > 0 && foreignAmountOut <= foreignReserve,
                    "BasePoolV2::swap: Swap Impossible"
                );
                foreignAsset.safeTransfer(to, foreignAmountOut); 
            }
        }
        _update(
            foreignAsset,
            nativeReserve - nativeAmountOut + nativeAmountIn,
            foreignReserve - foreignAmountOut + foreignAmountIn,
            nativeReserve,
            foreignReserve
        );
        emit Swap(
            foreignAsset,
            msg.sender,
            nativeAmountIn,
            foreignAmountIn,
            nativeAmountOut,
            foreignAmountOut,
            to
        );
        return nativeAmountOut > 0 ? nativeAmountOut : foreignAmountOut;
    }
    function rescue(IERC20 foreignAsset) external {
        uint256 foreignBalance = foreignAsset.balanceOf(address(this));
        uint256 reserveForeign = pairInfo[foreignAsset].reserveForeign;
        uint256 unaccounted = foreignBalance - reserveForeign;
        foreignAsset.safeTransfer(msg.sender, unaccounted);
    }
    function _update(
        IERC20 foreignAsset,
        uint256 balanceNative,
        uint256 balanceForeign,
        uint112 reserveNative,
        uint112 reserveForeign
    ) internal {
        require(
            balanceNative <= type(uint112).max &&
                balanceForeign <= type(uint112).max,
            "BasePoolV2::_update: Balance Overflow"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        PairInfo storage pair = pairInfo[foreignAsset];
        unchecked {
            uint32 timeElapsed = blockTimestamp - pair.blockTimestampLast; 
            if (timeElapsed > 0 && reserveNative != 0 && reserveForeign != 0) {
                pair.priceCumulative.nativeLast +=
                    uint256(
                        UQ112x112.encode(reserveForeign).uqdiv(reserveNative)
                    ) *
                    timeElapsed;
                pair.priceCumulative.foreignLast +=
                    uint256(
                        UQ112x112.encode(reserveNative).uqdiv(reserveForeign)
                    ) *
                    timeElapsed;
            }
        }
        pair.reserveNative = uint112(balanceNative);
        pair.reserveForeign = uint112(balanceForeign);
        pair.blockTimestampLast = blockTimestamp;
        emit Sync(foreignAsset, balanceNative, balanceForeign);
    }
    function _supportedToken(IERC20 token) private view {
        require(
            supported[token],
            "BasePoolV2::_supportedToken: Unsupported Token"
        );
    }
    function _onlyRouter() private view {
        require(
            msg.sender == router,
            "BasePoolV2::_onlyRouter: Only Router is allowed to call"
        );
    }
    modifier onlyRouter() {
        _onlyRouter();
        _;
    }
    modifier supportedToken(IERC20 token) {
        _supportedToken(token);
        _;
    }
}
pragma solidity =0.8.9;
interface IVaderPoolV2 is IBasePoolV2, IERC721 {
    function cumulativePrices(
        IERC20 foreignAsset
    ) external view returns (
        uint256 price0CumulativeLast,
        uint256 price1CumulativeLast,
        uint32 blockTimestampLast
    );
    function mintSynth(
        IERC20 foreignAsset,
        uint256 nativeDeposit,
        address from,
        address to
    ) external returns (uint256 amountSynth);
    function burnSynth(
        IERC20 foreignAsset,
        uint256 synthAmount,
        address to
    ) external returns (uint256 amountNative);
    function mintFungible(
        IERC20 foreignAsset,
        uint256 nativeDeposit,
        uint256 foreignDeposit,
        address from,
        address to
    ) external returns (uint256 liquidity);
    function burnFungible(
        IERC20 foreignAsset,
        uint256 liquidity,
        address to
    ) external returns (uint256 amountNative, uint256 amountForeign);
    function burn(uint256 id, address to)
        external
        returns (
            uint256 amountNative,
            uint256 amountForeign,
            uint256 coveredLoss
        );
    function toggleQueue() external;
    function setTokenSupport(IERC20 foreignAsset, bool support) external;
    function setFungibleTokenSupport(IERC20 foreignAsset) external;
    event QueueActive(bool activated);
}
pragma solidity =0.8.9;
interface ISynth is IERC20 {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
}
pragma solidity =0.8.9;
interface IERC20Extended is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
}
pragma solidity =0.8.9;
interface ISynthFactory {
    function synths(IERC20 token) external view returns (ISynth);
    function createSynth(IERC20Extended token) external returns (ISynth);
}
pragma solidity =0.8.9;
interface ILPWrapper {
    function tokens(IERC20 foreignAsset) external view returns (IERC20Extended);
    function createWrapper(IERC20 foreignAsset) external;
}
pragma solidity =0.8.9;
contract VaderPoolV2 is IVaderPoolV2, BasePoolV2, Ownable {
    using SafeERC20 for IERC20;
    ILPWrapper public wrapper;
    ISynthFactory public synthFactory;
    bool public queueActive;
    constructor(bool _queueActive, IERC20 _nativeAsset)
        BasePoolV2(_nativeAsset)
    {
        queueActive = _queueActive;
    }
    function cumulativePrices(IERC20 foreignAsset)
        public
        view
        returns (
            uint256 price0CumulativeLast,
            uint256 price1CumulativeLast,
            uint32 blockTimestampLast
        )
    {
        PriceCumulative memory priceCumulative = pairInfo[foreignAsset]
            .priceCumulative;
        price0CumulativeLast = priceCumulative.nativeLast;
        price1CumulativeLast = priceCumulative.foreignLast;
        blockTimestampLast = pairInfo[foreignAsset].blockTimestampLast;
    }
    function initialize(
        ILPWrapper _wrapper,
        ISynthFactory _synthFactory,
        address _router
    ) external onlyOwner {
        require(
            wrapper == ILPWrapper(_ZERO_ADDRESS),
            "VaderPoolV2::initialize: Already initialized"
        );
        require(
            _wrapper != ILPWrapper(_ZERO_ADDRESS),
            "VaderPoolV2::initialize: Incorrect Wrapper Specified"
        );
        require(
            _synthFactory != ISynthFactory(_ZERO_ADDRESS),
            "VaderPoolV2::initialize: Incorrect SynthFactory Specified"
        );
        require(
            _router != _ZERO_ADDRESS,
            "VaderPoolV2::initialize: Incorrect Router Specified"
        );
        wrapper = _wrapper;
        synthFactory = _synthFactory;
        router = _router;
    }
    function mintSynth(
        IERC20 foreignAsset,
        uint256 nativeDeposit,
        address from,
        address to
    )
        external
        override
        nonReentrant
        supportedToken(foreignAsset)
        returns (uint256 amountSynth)
    {
        nativeAsset.safeTransferFrom(from, address(this), nativeDeposit);
        ISynth synth = synthFactory.synths(foreignAsset);
        if (synth == ISynth(_ZERO_ADDRESS))
            synth = synthFactory.createSynth(
                IERC20Extended(address(foreignAsset))
            );
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(
            foreignAsset
        ); 
        amountSynth = VaderMath.calculateSwap(
            nativeDeposit,
            reserveNative,
            reserveForeign
        );
        _update(
            foreignAsset,
            reserveNative + nativeDeposit,
            reserveForeign,
            reserveNative,
            reserveForeign
        );
        synth.mint(to, amountSynth);
    }
    function burnSynth(
        IERC20 foreignAsset,
        uint256 synthAmount,
        address to
    ) external override nonReentrant returns (uint256 amountNative) {
        ISynth synth = synthFactory.synths(foreignAsset);
        require(
            synth != ISynth(_ZERO_ADDRESS),
            "VaderPoolV2::burnSynth: Inexistent Synth"
        );
        require(
            synthAmount > 0,
            "VaderPoolV2::burnSynth: Insufficient Synth Amount"
        );
        IERC20(synth).safeTransferFrom(msg.sender, address(this), synthAmount);
        synth.burn(synthAmount);
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(
            foreignAsset
        ); 
        amountNative = VaderMath.calculateSwap(
            synthAmount,
            reserveForeign,
            reserveNative
        );
        _update(
            foreignAsset,
            reserveNative - amountNative,
            reserveForeign,
            reserveNative,
            reserveForeign
        );
        nativeAsset.safeTransfer(to, amountNative);
    }
    function burn(uint256 id, address to)
        external
        override
        onlyRouter
        returns (
            uint256 amountNative,
            uint256 amountForeign,
            uint256 coveredLoss
        )
    {
        (amountNative, amountForeign) = _burn(id, to);
        Position storage position = positions[id];
        uint256 creation = position.creation;
        uint256 originalNative = position.originalNative;
        uint256 originalForeign = position.originalForeign;
        delete positions[id];
        uint256 loss = VaderMath.calculateLoss(
            originalNative,
            originalForeign,
            amountNative,
            amountForeign
        );
        coveredLoss =
            (loss * _min(block.timestamp - creation, _ONE_YEAR)) /
            _ONE_YEAR;
    }
    function mintFungible(
        IERC20 foreignAsset,
        uint256 nativeDeposit,
        uint256 foreignDeposit,
        address from,
        address to
    ) external override nonReentrant returns (uint256 liquidity) {
        IERC20Extended lp = wrapper.tokens(foreignAsset);
        require(
            lp != IERC20Extended(_ZERO_ADDRESS),
            "VaderPoolV2::mintFungible: Unsupported Token"
        );
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(
            foreignAsset
        ); 
        nativeAsset.safeTransferFrom(from, address(this), nativeDeposit);
        foreignAsset.safeTransferFrom(from, address(this), foreignDeposit);
        PairInfo storage pair = pairInfo[foreignAsset];
        uint256 totalLiquidityUnits = pair.totalSupply;
        if (totalLiquidityUnits == 0) liquidity = nativeDeposit;
        else
            liquidity = VaderMath.calculateLiquidityUnits(
                nativeDeposit,
                reserveNative,
                foreignDeposit,
                reserveForeign,
                totalLiquidityUnits
            );
        require(
            liquidity > 0,
            "VaderPoolV2::mintFungible: Insufficient Liquidity Provided"
        );
        pair.totalSupply = totalLiquidityUnits + liquidity;
        _update(
            foreignAsset,
            reserveNative + nativeDeposit,
            reserveForeign + foreignDeposit,
            reserveNative,
            reserveForeign
        );
        lp.mint(to, liquidity);
        emit Mint(from, to, nativeDeposit, foreignDeposit);
    }
    function burnFungible(
        IERC20 foreignAsset,
        uint256 liquidity,
        address to
    )
        external
        override
        nonReentrant
        returns (uint256 amountNative, uint256 amountForeign)
    {
        IERC20Extended lp = wrapper.tokens(foreignAsset);
        require(
            lp != IERC20Extended(_ZERO_ADDRESS),
            "VaderPoolV2::burnFungible: Unsupported Token"
        );
        IERC20(lp).safeTransferFrom(msg.sender, address(this), liquidity);
        lp.burn(liquidity);
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(
            foreignAsset
        ); 
        PairInfo storage pair = pairInfo[foreignAsset];
        uint256 _totalSupply = pair.totalSupply;
        amountNative = (liquidity * reserveNative) / _totalSupply;
        amountForeign = (liquidity * reserveForeign) / _totalSupply;
        require(
            amountNative > 0 && amountForeign > 0,
            "VaderPoolV2::burnFungible: Insufficient Liquidity Burned"
        );
        pair.totalSupply = _totalSupply - liquidity;
        nativeAsset.safeTransfer(to, amountNative);
        foreignAsset.safeTransfer(to, amountForeign);
        _update(
            foreignAsset,
            reserveNative - amountNative,
            reserveForeign - amountForeign,
            reserveNative,
            reserveForeign
        );
        emit Burn(msg.sender, amountNative, amountForeign, to);
    }
    function toggleQueue() external override onlyOwner {
        bool _queueActive = !queueActive;
        queueActive = _queueActive;
        emit QueueActive(_queueActive);
    }
    function setTokenSupport(IERC20 foreignAsset, bool support)
        external
        override
        onlyOwner
    {
        require(
            supported[foreignAsset] != support,
            "VaderPoolV2::supportToken: Already At Desired State"
        );
        supported[foreignAsset] = support;
    }
    function setFungibleTokenSupport(IERC20 foreignAsset)
        external
        override
        onlyOwner
    {
        wrapper.createWrapper(foreignAsset);
    }
    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}
pragma solidity =0.8.9;
interface IVaderRouterV2 {
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256, 
        uint256, 
        address to,
        uint256 deadline
    ) external returns (uint256 liquidity);
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        address to,
        uint256 deadline
    ) external returns (uint256 liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 id,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);
}
pragma solidity =0.8.9;
interface IVaderReserve {
    function reimburseImpermanentLoss(address recipient, uint256 amount)
        external;
    function grant(address recipient, uint256 amount) external;
    function reserve() external view returns (uint256);
    event GrantDistributed(address recipient, uint256 amount);
    event LossCovered(address recipient, uint256 amount, uint256 actualAmount);
}
pragma solidity =0.8.9;
contract VaderRouterV2 is IVaderRouterV2, ProtocolConstants, Ownable {
    using SafeERC20 for IERC20;
    IVaderPoolV2 public immutable pool;
    IERC20 public immutable nativeAsset;
    IVaderReserve public reserve;
    constructor(IVaderPoolV2 _pool) {
        require(
            _pool != IVaderPoolV2(_ZERO_ADDRESS),
            "VaderRouterV2::constructor: Incorrect Arguments"
        );
        pool = _pool;
        nativeAsset = pool.nativeAsset();
    }
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256, 
        uint256, 
        address to,
        uint256 deadline
    ) external override returns (uint256 liquidity) {
        return
            addLiquidity(
                tokenA,
                tokenB,
                amountADesired,
                amountBDesired,
                to,
                deadline
            );
    }
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        address to,
        uint256 deadline
    ) public override ensure(deadline) returns (uint256 liquidity) {
        IERC20 foreignAsset;
        uint256 nativeDeposit;
        uint256 foreignDeposit;
        if (tokenA == nativeAsset) {
            require(
                pool.supported(tokenB),
                "VaderRouterV2::addLiquidity: Unsupported Assets Specified"
            );
            foreignAsset = tokenB;
            foreignDeposit = amountBDesired;
            nativeDeposit = amountADesired;
        } else {
            require(
                tokenB == nativeAsset && pool.supported(tokenA),
                "VaderRouterV2::addLiquidity: Unsupported Assets Specified"
            );
            foreignAsset = tokenA;
            foreignDeposit = amountADesired;
            nativeDeposit = amountBDesired;
        }
        liquidity = pool.mint(
            foreignAsset,
            nativeDeposit,
            foreignDeposit,
            msg.sender,
            to
        );
    }
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 id,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        IERC20 _foreignAsset = pool.positionForeignAsset(id);
        IERC20 _nativeAsset = nativeAsset;
        bool isNativeA = _nativeAsset == IERC20(tokenA);
        if (isNativeA) {
            require(
                IERC20(tokenB) == _foreignAsset,
                "VaderRouterV2::removeLiquidity: Incorrect Addresses Specified"
            );
        } else {
            require(
                IERC20(tokenA) == _foreignAsset &&
                    IERC20(tokenB) == _nativeAsset,
                "VaderRouterV2::removeLiquidity: Incorrect Addresses Specified"
            );
        }
        pool.transferFrom(msg.sender, address(pool), id);
        (
            uint256 amountNative,
            uint256 amountForeign,
            uint256 coveredLoss
        ) = pool.burn(id, to);
        (amountA, amountB) = isNativeA
            ? (amountNative, amountForeign)
            : (amountForeign, amountNative);
        require(
            amountA >= amountAMin,
            "VaderRouterV2: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "VaderRouterV2: INSUFFICIENT_B_AMOUNT"
        );
        reserve.reimburseImpermanentLoss(msg.sender, coveredLoss);
    }
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        IERC20[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _swap(amountIn, path, to);
        require(
            amountOut >= amountOutMin,
            "VaderRouterV2::swapExactTokensForTokens: Insufficient Trade Output"
        );
    }
    function initialize(IVaderReserve _reserve) external onlyOwner {
        require(
            _reserve != IVaderReserve(_ZERO_ADDRESS),
            "VaderRouterV2::initialize: Incorrect Reserve Specified"
        );
        reserve = _reserve;
        renounceOwnership();
    }
    function _swap(
        uint256 amountIn,
        IERC20[] calldata path,
        address to
    ) private returns (uint256 amountOut) {
        if (path.length == 3) {
            require(
                path[0] != path[1] &&
                    path[1] == pool.nativeAsset() &&
                    path[2] != path[1],
                "VaderRouterV2::_swap: Incorrect Path"
            );
            path[0].safeTransferFrom(msg.sender, address(pool), amountIn);
            return pool.doubleSwap(path[0], path[2], amountIn, to);
        } else {
            require(
                path.length == 2,
                "VaderRouterV2::_swap: Incorrect Path Length"
            );
            IERC20 _nativeAsset = nativeAsset;
            require(path[0] != path[1], "VaderRouterV2::_swap: Incorrect Path");
            path[0].safeTransferFrom(msg.sender, address(pool), amountIn);
            if (path[0] == _nativeAsset) {
                return pool.swap(path[1], amountIn, 0, to);
            } else {
                require(
                    path[1] == _nativeAsset,
                    "VaderRouterV2::_swap: Incorrect Path"
                );
                return pool.swap(path[0], 0, amountIn, to);
            }
        }
    }
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "VaderRouterV2::ensure: Expired");
        _;
    }
}
pragma solidity =0.8.9;
contract Synth is ISynth, ProtocolConstants, ERC20, Ownable {
    constructor(IERC20Extended token)
        ERC20(_calculateName(token), _calculateSymbol(token))
    {}
    function _calculateName(IERC20Extended token)
        internal
        view
        returns (string memory)
    {
        return _combine(token.name(), " - vSynth");
    }
    function _calculateSymbol(IERC20Extended token)
        internal
        view
        returns (string memory)
    {
        return _combine(token.symbol(), ".v");
    }
    function _combine(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(a, b));
    }
    function mint(address to, uint256 amount) external override onlyOwner {
        _mint(to, amount);
    }
    function burn(uint256 amount) external override onlyOwner {
        _burn(msg.sender, amount);
    }
}
pragma solidity =0.8.9;
contract SynthFactory is ISynthFactory, ProtocolConstants, Ownable {
    mapping(IERC20 => ISynth) public override synths;
    constructor(address _pool) {
        require(
            _pool != _ZERO_ADDRESS,
            "SynthFactory::constructor: Misconfiguration"
        );
        transferOwnership(_pool);
    }
    function createSynth(IERC20Extended token)
        external
        override
        onlyOwner
        returns (ISynth)
    {
        require(
            synths[IERC20(token)] == ISynth(_ZERO_ADDRESS),
            "SynthFactory::createSynth: Already Created"
        );
        Synth synth = new Synth(token);
        synth.transferOwnership(owner());
        synths[IERC20(token)] = synth;
        return synth;
    }
}
pragma solidity =0.8.9;
interface ILPToken {
    function mint(address to, uint256 amount) external;
    function burn(uint256 amount) external;
}
pragma solidity =0.8.9;
contract LPToken is ILPToken, ProtocolConstants, ERC20, Ownable {
    IERC20Extended public immutable foreignAsset;
    IVaderPoolV2 public immutable pool;
    constructor(IERC20Extended _foreignAsset, IVaderPoolV2 _pool)
        ERC20(_calculateName(_foreignAsset), _calculateSymbol(_foreignAsset))
    {
        foreignAsset = _foreignAsset;
        pool = _pool;
        transferOwnership(address(_pool));
    }
    function totalSupply() public view override returns (uint256) {
        return pool.pairSupply(foreignAsset);
    }
    function balanceOf(address user) public view override returns (uint256) {
        if (user == address(pool)) return totalSupply() - ERC20.totalSupply();
        else return ERC20.balanceOf(user);
    }
    function _calculateName(IERC20Extended token)
        internal
        view
        returns (string memory)
    {
        return _combine(token.name(), " - USDV LP");
    }
    function _calculateSymbol(IERC20Extended token)
        internal
        view
        returns (string memory)
    {
        return _combine("V(", token.symbol(), "|USDV)");
    }
    function _combine(string memory a, string memory b)
        internal
        pure
        returns (string memory)
    {
        return _combine(a, b, "");
    }
    function _combine(
        string memory a,
        string memory b,
        string memory c
    ) internal pure returns (string memory) {
        return string(abi.encodePacked(a, b, c));
    }
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }
    function burn(uint256 amount) external onlyOwner {
        _burn(msg.sender, amount);
    }
}
pragma solidity =0.8.9;
contract LPWrapper is ILPWrapper, ProtocolConstants, Ownable {
    mapping(IERC20 => IERC20Extended) public override tokens;
    constructor(address pool) {
        require(
            pool != _ZERO_ADDRESS,
            "LPWrapper::constructor: Misconfiguration"
        );
        transferOwnership(pool);
    }
    function createWrapper(IERC20 foreignAsset) external override onlyOwner {
        require(
            tokens[foreignAsset] == IERC20Extended(_ZERO_ADDRESS),
            "LPWrapper::createWrapper: Already Created"
        );
        tokens[foreignAsset] = IERC20Extended(
            address(
                new LPToken(
                    IERC20Extended(address(foreignAsset)),
                    IVaderPoolV2(owner())
                )
            )
        );
    }
}
pragma solidity =0.8.9;
interface IBasePool {
    struct Position {
        uint256 creation;
        uint256 liquidity;
        uint256 originalNative;
        uint256 originalForeign;
    }
    function swap(
        uint256 nativeAmountIn,
        uint256 foreignAmountIn,
        address to
    ) external returns (uint256);
    function swap(
        uint256 nativeAmountIn,
        uint256 foreignAmountIn,
        address to,
        bytes calldata
    ) external returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function getReserves() external view returns (
            uint112 reserveNative,
            uint112 reserveForeign,
            uint32 blockTimestampLast
        );
    event Mint(
        address indexed sender,
        address indexed to,
        uint256 amount0,
        uint256 amount1
    ); 
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint256 reserve0, uint256 reserve1); 
    event PositionOpened(address indexed sender, uint256 id, uint256 liquidity);
    event PositionClosed(
        address indexed sender,
        uint256 id,
        uint256 liquidity,
        uint256 loss
    );
}
pragma solidity =0.8.9;
contract BasePool is IBasePool, GasThrottle, ERC721, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;
    using UQ112x112 for uint224;
    IERC20 public immutable nativeAsset;
    IERC20 public immutable foreignAsset;
    uint256 public priceNativeCumulativeLast;
    uint256 public priceForeignCumulativeLast;
    mapping(uint256 => Position) public positions;
    uint256 public positionId;
    uint256 public totalSupply;
    string private _name;
    uint112 private _reserveNative; 
    uint112 private _reserveForeign; 
    uint32 private _blockTimestampLast; 
    constructor(IERC20Extended _nativeAsset, IERC20Extended _foreignAsset)
        ERC721("Vader LP", "VLP")
    {
        nativeAsset = IERC20(_nativeAsset);
        foreignAsset = IERC20(_foreignAsset);
        string memory calculatedName = string(
            abi.encodePacked("Vader USDV /", _foreignAsset.symbol(), " LP")
        );
        _name = calculatedName;
    }
    function getReserves()
        public
        view
        returns (
            uint112 reserveNative,
            uint112 reserveForeign,
            uint32 blockTimestampLast
        )
    {
        reserveNative = _reserveNative;
        reserveForeign = _reserveForeign;
        blockTimestampLast = _blockTimestampLast;
    }
    function name() public view override returns (string memory) {
        return _name;
    }
    function mint(address to)
        external
        override
        nonReentrant
        returns (uint256 liquidity)
    {
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(); 
        uint256 balanceNative = nativeAsset.balanceOf(address(this));
        uint256 balanceForeign = foreignAsset.balanceOf(address(this));
        uint256 nativeDeposit = balanceNative - reserveNative;
        uint256 foreignDeposit = balanceForeign - reserveForeign;
        uint256 totalLiquidityUnits = totalSupply;
        if (totalLiquidityUnits == 0)
            liquidity = nativeDeposit; 
        else
            liquidity = VaderMath.calculateLiquidityUnits(
                nativeDeposit,
                reserveNative,
                foreignDeposit,
                reserveForeign,
                totalLiquidityUnits
            );
        require(
            liquidity > 0,
            "BasePool::mint: Insufficient Liquidity Provided"
        );
        uint256 id = positionId++;
        totalSupply += liquidity;
        _mint(to, id);
        positions[id] = Position(
            block.timestamp,
            liquidity,
            nativeDeposit,
            foreignDeposit
        );
        _update(balanceNative, balanceForeign, reserveNative, reserveForeign);
        emit Mint(msg.sender, to, nativeDeposit, foreignDeposit);
        emit PositionOpened(msg.sender, id, liquidity);
    }
    function _burn(uint256 id, address to)
        internal
        nonReentrant
        returns (uint256 amountNative, uint256 amountForeign)
    {
        require(
            ownerOf(id) == address(this),
            "BasePool::burn: Incorrect Ownership"
        );
        (uint112 reserveNative, uint112 reserveForeign, ) = getReserves(); 
        IERC20 _nativeAsset = nativeAsset; 
        IERC20 _foreignAsset = foreignAsset; 
        uint256 nativeBalance = IERC20(_nativeAsset).balanceOf(address(this));
        uint256 foreignBalance = IERC20(_foreignAsset).balanceOf(address(this));
        uint256 liquidity = positions[id].liquidity;
        uint256 _totalSupply = totalSupply; 
        amountNative = (liquidity * nativeBalance) / _totalSupply; 
        amountForeign = (liquidity * foreignBalance) / _totalSupply; 
        require(
            amountNative > 0 && amountForeign > 0,
            "BasePool::burn: Insufficient Liquidity Burned"
        );
        totalSupply -= liquidity;
        _burn(id);
        _nativeAsset.safeTransfer(to, amountNative);
        _foreignAsset.safeTransfer(to, amountForeign);
        nativeBalance = _nativeAsset.balanceOf(address(this));
        foreignBalance = _foreignAsset.balanceOf(address(this));
        _update(nativeBalance, foreignBalance, reserveNative, reserveForeign);
        emit Burn(msg.sender, amountNative, amountForeign, to);
    }
    function swap(
        uint256 nativeAmountIn,
        uint256 foreignAmountIn,
        address to,
        bytes calldata
    ) external override returns (uint256) {
        return swap(nativeAmountIn, foreignAmountIn, to);
    }
    function swap(
        uint256 nativeAmountIn,
        uint256 foreignAmountIn,
        address to
    ) public override nonReentrant validateGas returns (uint256) {
        require(
            (nativeAmountIn > 0 && foreignAmountIn == 0) ||
                (nativeAmountIn == 0 && foreignAmountIn > 0),
            "BasePool::swap: Only One-Sided Swaps Supported"
        );
        (uint112 nativeReserve, uint112 foreignReserve, ) = getReserves(); 
        uint256 nativeBalance;
        uint256 foreignBalance;
        uint256 nativeAmountOut;
        uint256 foreignAmountOut;
        {
            IERC20 _nativeAsset = nativeAsset;
            IERC20 _foreignAsset = foreignAsset;
            nativeBalance = _nativeAsset.balanceOf(address(this));
            foreignBalance = _foreignAsset.balanceOf(address(this));
            require(
                to != address(_nativeAsset) && to != address(_foreignAsset),
                "BasePool::swap: Invalid Receiver"
            );
            if (foreignAmountIn > 0) {
                require(
                    foreignAmountIn <= foreignBalance - foreignReserve,
                    "BasePool::swap: Insufficient Tokens Provided"
                );
                require(
                    foreignAmountIn <= foreignReserve,
                    "BasePool::swap: Unfavourable Trade"
                );
                nativeAmountOut = VaderMath.calculateSwap(
                    foreignAmountIn,
                    foreignReserve,
                    nativeReserve
                );
                require(
                    nativeAmountOut > 0 && nativeAmountOut <= nativeReserve,
                    "BasePool::swap: Swap Impossible"
                );
                _nativeAsset.safeTransfer(to, nativeAmountOut); 
            } else {
                require(
                    nativeAmountIn <= nativeBalance - nativeReserve,
                    "BasePool::swap: Insufficient Tokens Provided"
                );
                require(
                    nativeAmountIn <= nativeReserve,
                    "BasePool::swap: Unfavourable Trade"
                );
                foreignAmountOut = VaderMath.calculateSwap(
                    nativeAmountIn,
                    nativeReserve,
                    foreignReserve
                );
                require(
                    foreignAmountOut > 0 && foreignAmountOut <= foreignReserve,
                    "BasePool::swap: Swap Impossible"
                );
                _foreignAsset.safeTransfer(to, foreignAmountOut); 
            }
            nativeBalance = _nativeAsset.balanceOf(address(this));
            foreignBalance = _foreignAsset.balanceOf(address(this));
        }
        _update(nativeBalance, foreignBalance, nativeReserve, foreignReserve);
        emit Swap(
            msg.sender,
            nativeAmountIn,
            foreignAmountIn,
            nativeAmountOut,
            foreignAmountOut,
            to
        );
        return nativeAmountOut > 0 ? nativeAmountOut : foreignAmountOut;
    }
    function _update(
        uint256 balanceNative,
        uint256 balanceForeign,
        uint112 reserveNative,
        uint112 reserveForeign
    ) internal {
        require(
            balanceNative <= type(uint112).max &&
                balanceForeign <= type(uint112).max,
            "BasePool::_update: Balance Overflow"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        unchecked {
            uint32 timeElapsed = blockTimestamp - _blockTimestampLast; 
            if (timeElapsed > 0 && reserveNative != 0 && reserveForeign != 0) {
                priceNativeCumulativeLast +=
                    uint256(
                        UQ112x112.encode(reserveForeign).uqdiv(reserveNative)
                    ) *
                    timeElapsed;
                priceForeignCumulativeLast +=
                    uint256(
                        UQ112x112.encode(reserveNative).uqdiv(reserveForeign)
                    ) *
                    timeElapsed;
            }
        }
        _reserveNative = uint112(balanceNative);
        _reserveForeign = uint112(balanceForeign);
        _blockTimestampLast = blockTimestamp;
        emit Sync(balanceNative, balanceForeign);
    }
}
pragma solidity =0.8.9;
interface IVaderPool is IBasePool, IERC721 {
    function burn(uint256 id, address to)
        external
        returns (
            uint256 amountNative,
            uint256 amountForeign,
            uint256 coveredLoss
        );
    function toggleQueue() external;
    event QueueActive(bool activated);
}
pragma solidity =0.8.9;
contract VaderPool is IVaderPool, BasePool {
    bool public queueActive;
    constructor(
        bool _queueActive,
        IERC20Extended _nativeAsset,
        IERC20Extended _foreignAsset
    ) BasePool(_nativeAsset, _foreignAsset) {
        queueActive = _queueActive;
    }
    function burn(uint256 id, address to)
        external
        override
        returns (
            uint256 amountNative,
            uint256 amountForeign,
            uint256 coveredLoss
        )
    {
        (amountNative, amountForeign) = _burn(id, to);
        Position storage position = positions[id];
        uint256 creation = position.creation;
        uint256 originalNative = position.originalNative;
        uint256 originalForeign = position.originalForeign;
        delete positions[id];
        uint256 loss = VaderMath.calculateLoss(
            originalNative,
            originalForeign,
            amountNative,
            amountForeign
        );
        coveredLoss =
            (loss * _min(block.timestamp - creation, _ONE_YEAR)) /
            _ONE_YEAR;
    }
    function toggleQueue() external override onlyOwner {
        bool _queueActive = !queueActive;
        queueActive = _queueActive;
        emit QueueActive(_queueActive);
    }
    function _onlyDAO() private view {
        require(
            owner() == _msgSender(),
            "BasePool::_onlyDAO: Insufficient Privileges"
        );
    }
    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    modifier onlyDAO() {
        _onlyDAO();
        _;
    }
}
pragma solidity =0.8.9;
interface IVaderPoolFactory {
    function createPool(address tokenA, address tokenB)
        external
        returns (IVaderPool);
    function getPool(address tokenA, address tokenB)
        external
        view
        returns (IVaderPool);
    function nativeAsset() external view returns (address);
    event PoolCreated(
        address token0,
        address token1,
        IVaderPool pool,
        uint256 index
    );
}
pragma solidity =0.8.9;
contract VaderPoolFactory is IVaderPoolFactory, ProtocolConstants, Ownable {
    bool public queueActive;
    address public override nativeAsset;
    mapping(address => mapping(address => IVaderPool)) public override getPool;
    IVaderPool[] public allPools;
    function createPool(address tokenA, address tokenB)
        external
        override
        returns (IVaderPool pool)
    {
        (address token0, address token1) = tokenA == nativeAsset
            ? (tokenA, tokenB)
            : tokenB == nativeAsset
            ? (tokenB, tokenA)
            : (_ZERO_ADDRESS, _ZERO_ADDRESS);
        require(
            token0 != token1,
            "VaderPoolFactory::createPool: Identical Tokens"
        );
        require(
            token1 != _ZERO_ADDRESS,
            "VaderPoolFactory::createPool: Inexistent Token"
        );
        require(
            getPool[token0][token1] == IVaderPool(_ZERO_ADDRESS),
            "VaderPoolFactory::createPool: Pair Exists"
        ); 
        pool = new VaderPool(
            queueActive,
            IERC20Extended(token0),
            IERC20Extended(token1)
        );
        getPool[token0][token1] = pool;
        getPool[token1][token0] = pool; 
        allPools.push(pool);
        emit PoolCreated(token0, token1, pool, allPools.length);
    }
    function initialize(address _nativeAsset, address _dao) external onlyOwner {
        require(
            _nativeAsset != _ZERO_ADDRESS && _dao != _ZERO_ADDRESS,
            "VaderPoolFactory::initialize: Incorrect Arguments"
        );
        nativeAsset = _nativeAsset;
        transferOwnership(_dao);
    }
    function toggleQueue(address token0, address token1) external onlyDAO {
        getPool[token0][token1].toggleQueue();
    }
    function _onlyDAO() private view {
        require(
            nativeAsset != _ZERO_ADDRESS && owner() == _msgSender(),
            "BasePool::_onlyDAO: Insufficient Privileges"
        );
    }
    modifier onlyDAO() {
        _onlyDAO();
        _;
    }
}
pragma solidity =0.8.9;
interface ISwapQueue {
    struct Node {
        uint256 value;
        uint256 previous;
        uint256 next;
    }
    struct Queue {
        mapping(uint256 => Node) linkedList;
        uint256 start;
        uint256 end;
        uint256 size;
    }
}
pragma solidity =0.8.9;
contract SwapQueue is ISwapQueue, ProtocolConstants {
    using Address for address payable;
    mapping(uint256 => Queue) public queue;
    function executeQueue() external {
        uint256 reimbursement = _executeQueue();
        payable(msg.sender).sendValue(reimbursement);
    }
    function _insertQueue(uint256 value) internal returns (bool) {}
    function _executeQueue() internal returns (uint256) {}
}
pragma solidity =0.8.9;
interface IVaderRouter {
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256, 
        uint256, 
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 id,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256 amountOut);
}
pragma solidity =0.8.9;
contract VaderRouter is IVaderRouter, ProtocolConstants, Ownable {
    using SafeERC20 for IERC20;
    IVaderPoolFactory public immutable factory;
    IVaderReserve public reserve;
    constructor(IVaderPoolFactory _factory) {
        require(
            _factory != IVaderPoolFactory(_ZERO_ADDRESS),
            "VaderRouter::constructor: Incorrect Arguments"
        );
        factory = _factory;
    }
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256, 
        uint256, 
        address to,
        uint256 deadline
    )
        external
        override
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        return
            addLiquidity(
                tokenA,
                tokenB,
                amountADesired,
                amountBDesired,
                to,
                deadline
            );
    }
    function addLiquidity(
        IERC20 tokenA,
        IERC20 tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        address to,
        uint256 deadline
    )
        public
        override
        ensure(deadline)
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        IVaderPool pool;
        (pool, amountA, amountB) = _addLiquidity(
            address(tokenA),
            address(tokenB),
            amountADesired,
            amountBDesired
        );
        tokenA.safeTransferFrom(msg.sender, address(pool), amountA);
        tokenB.safeTransferFrom(msg.sender, address(pool), amountB);
        liquidity = pool.mint(to);
    }
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 id,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        public
        override
        ensure(deadline)
        returns (uint256 amountA, uint256 amountB)
    {
        IVaderPool pool = factory.getPool(tokenA, tokenB);
        pool.transferFrom(msg.sender, address(pool), id);
        (
            uint256 amountNative,
            uint256 amountForeign,
            uint256 coveredLoss
        ) = pool.burn(id, to);
        (amountA, amountB) = tokenA == factory.nativeAsset()
            ? (amountNative, amountForeign)
            : (amountForeign, amountNative);
        require(
            amountA >= amountAMin,
            "UniswapV2Router: INSUFFICIENT_A_AMOUNT"
        );
        require(
            amountB >= amountBMin,
            "UniswapV2Router: INSUFFICIENT_B_AMOUNT"
        );
        reserve.reimburseImpermanentLoss(msg.sender, coveredLoss);
    }
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual override ensure(deadline) returns (uint256 amountOut) {
        amountOut = _swap(amountIn, path, to);
        require(
            amountOut >= amountOutMin,
            "VaderRouter::swapExactTokensForTokens: Insufficient Trade Output"
        );
    }
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external virtual ensure(deadline) returns (uint256 amountIn) {
        amountIn = calculateInGivenOut(amountOut, path);
        require(
            amountInMax >= amountIn,
            "VaderRouter::swapTokensForExactTokens: Large Trade Input"
        );
        _swap(amountIn, path, to);
    }
    function initialize(IVaderReserve _reserve) external onlyOwner {
        require(
            _reserve != IVaderReserve(_ZERO_ADDRESS),
            "VaderRouter::initialize: Incorrect Reserve Specified"
        );
        reserve = _reserve;
        renounceOwnership();
    }
    function _swap(
        uint256 amountIn,
        address[] calldata path,
        address to
    ) private returns (uint256 amountOut) {
        if (path.length == 3) {
            require(
                path[0] != path[1] &&
                    path[1] == factory.nativeAsset() &&
                    path[2] != path[1],
                "VaderRouter::_swap: Incorrect Path"
            );
            IVaderPool pool0 = factory.getPool(path[0], path[1]);
            IVaderPool pool1 = factory.getPool(path[1], path[2]);
            IERC20(path[0]).safeTransferFrom(
                msg.sender,
                address(pool0),
                amountIn
            );
            return pool1.swap(0, pool0.swap(amountIn, 0, address(pool1)), to);
        } else {
            require(
                path.length == 2,
                "VaderRouter::_swap: Incorrect Path Length"
            );
            address nativeAsset = factory.nativeAsset();
            require(path[0] != path[1], "VaderRouter::_swap: Incorrect Path");
            IVaderPool pool = factory.getPool(path[0], path[1]);
            IERC20(path[0]).safeTransferFrom(
                msg.sender,
                address(pool),
                amountIn
            );
            if (path[0] == nativeAsset) {
                return pool.swap(amountIn, 0, to);
            } else {
                require(
                    path[1] == nativeAsset,
                    "VaderRouter::_swap: Incorrect Path"
                );
                return pool.swap(0, amountIn, to);
            }
        }
    }
    function _addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    )
        private
        returns (
            IVaderPool pool,
            uint256 amountA,
            uint256 amountB
        )
    {
        pool = factory.getPool(tokenA, tokenB);
        if (pool == IVaderPool(_ZERO_ADDRESS)) {
            pool = factory.createPool(tokenA, tokenB);
        }
        (amountA, amountB) = (amountADesired, amountBDesired);
    }
    function calculateInGivenOut(uint256 amountOut, address[] calldata path)
        public
        view
        returns (uint256 amountIn)
    {
        if (path.length == 2) {
            address nativeAsset = factory.nativeAsset();
            IVaderPool pool = factory.getPool(path[0], path[1]);
            (uint256 nativeReserve, uint256 foreignReserve, ) = pool
                .getReserves();
            if (path[0] == nativeAsset) {
                return
                    VaderMath.calculateSwapReverse(
                        amountOut,
                        nativeReserve,
                        foreignReserve
                    );
            } else {
                return
                    VaderMath.calculateSwapReverse(
                        amountOut,
                        foreignReserve,
                        nativeReserve
                    );
            }
        } else {
            IVaderPool pool0 = factory.getPool(path[0], path[1]);
            IVaderPool pool1 = factory.getPool(path[1], path[2]);
            (uint256 nativeReserve0, uint256 foreignReserve0, ) = pool0
                .getReserves();
            (uint256 nativeReserve1, uint256 foreignReserve1, ) = pool1
                .getReserves();
            return
                VaderMath.calculateSwapReverse(
                    VaderMath.calculateSwapReverse(
                        amountOut,
                        nativeReserve1,
                        foreignReserve1
                    ),
                    foreignReserve0,
                    nativeReserve0
                );
        }
    }
    function calculateOutGivenIn(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256 amountOut)
    {
        if (path.length == 2) {
            address nativeAsset = factory.nativeAsset();
            IVaderPool pool = factory.getPool(path[0], path[1]);
            (uint256 nativeReserve, uint256 foreignReserve, ) = pool
                .getReserves();
            if (path[0] == nativeAsset) {
                return
                    VaderMath.calculateSwap(
                        amountIn,
                        nativeReserve,
                        foreignReserve
                    );
            } else {
                return
                    VaderMath.calculateSwap(
                        amountIn,
                        foreignReserve,
                        nativeReserve
                    );
            }
        } else {
            IVaderPool pool0 = factory.getPool(path[0], path[1]);
            IVaderPool pool1 = factory.getPool(path[1], path[2]);
            (uint256 nativeReserve0, uint256 foreignReserve0, ) = pool0
                .getReserves();
            (uint256 nativeReserve1, uint256 foreignReserve1, ) = pool1
                .getReserves();
            return
                VaderMath.calculateSwap(
                    VaderMath.calculateSwap(
                        amountIn,
                        nativeReserve1,
                        foreignReserve1
                    ),
                    foreignReserve0,
                    nativeReserve0
                );
        }
    }
    modifier ensure(uint256 deadline) {
        require(deadline >= block.timestamp, "VaderRouter::ensure: Expired");
        _;
    }
}
pragma solidity =0.8.9;
interface IUniswapV2ERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}
pragma solidity =0.8.9;
interface IUniswapV2Pair is IUniswapV2ERC20 {
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
pragma solidity =0.8.9;
library Babylonian {
    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
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
        return (r < r1 ? r : r1);
    }
}
pragma solidity =0.8.9;
library BitMath {
    function mostSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0, "BitMath::mostSignificantBit: zero");
        if (x >= 0x100000000000000000000000000000000) {
            x >>= 128;
            r += 128;
        }
        if (x >= 0x10000000000000000) {
            x >>= 64;
            r += 64;
        }
        if (x >= 0x100000000) {
            x >>= 32;
            r += 32;
        }
        if (x >= 0x10000) {
            x >>= 16;
            r += 16;
        }
        if (x >= 0x100) {
            x >>= 8;
            r += 8;
        }
        if (x >= 0x10) {
            x >>= 4;
            r += 4;
        }
        if (x >= 0x4) {
            x >>= 2;
            r += 2;
        }
        if (x >= 0x2) r += 1;
    }
    function leastSignificantBit(uint256 x) internal pure returns (uint8 r) {
        require(x > 0, "BitMath::leastSignificantBit: zero");
        r = 255;
        if (x & type(uint128).max > 0) {
            r -= 128;
        } else {
            x >>= 128;
        }
        if (x & type(uint64).max > 0) {
            r -= 64;
        } else {
            x >>= 64;
        }
        if (x & type(uint32).max > 0) {
            r -= 32;
        } else {
            x >>= 32;
        }
        if (x & type(uint16).max > 0) {
            r -= 16;
        } else {
            x >>= 16;
        }
        if (x & type(uint8).max > 0) {
            r -= 8;
        } else {
            x >>= 8;
        }
        if (x & 0xf > 0) {
            r -= 4;
        } else {
            x >>= 4;
        }
        if (x & 0x3 > 0) {
            r -= 2;
        } else {
            x >>= 2;
        }
        if (x & 0x1 > 0) r -= 1;
    }
}
pragma solidity =0.8.9;
library FullMath {
    function fullMul(uint256 x, uint256 y)
        internal
        pure
        returns (uint256 l, uint256 h)
    {
        uint256 mm = mulmod(x, y, type(uint256).max);
        l = x * y;
        h = mm - l;
        if (mm < l) h -= 1;
    }
    function fullDiv(
        uint256 l,
        uint256 h,
        uint256 d
    ) private pure returns (uint256) {
        uint256 pow2 = d & uint256(-int256(d));
        d /= pow2;
        l /= pow2;
        l += h * (uint256(-int256(pow2)) / pow2 + 1);
        uint256 r = 1;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        r *= 2 - d * r;
        return l * r;
    }
    function mulDiv(
        uint256 x,
        uint256 y,
        uint256 d
    ) internal pure returns (uint256) {
        (uint256 l, uint256 h) = fullMul(x, y);
        uint256 mm = mulmod(x, y, d);
        if (mm > l) h -= 1;
        l -= mm;
        if (h == 0) return l / d;
        require(h < d, "FullMath: FULLDIV_OVERFLOW");
        return fullDiv(l, h, d);
    }
}
pragma solidity =0.8.9;
library FixedPoint {
    struct uq112x112 {
        uint224 _x;
    }
    struct uq144x112 {
        uint256 _x;
    }
    uint8 public constant RESOLUTION = 112;
    uint256 public constant Q112 = 0x10000000000000000000000000000; 
    uint256 private constant Q224 =
        0x100000000000000000000000000000000000000000000000000000000; 
    uint256 private constant LOWER_MASK = 0xffffffffffffffffffffffffffff; 
    function encode(uint112 x) internal pure returns (uq112x112 memory) {
        return uq112x112(uint224(x) << RESOLUTION);
    }
    function encode144(uint144 x) internal pure returns (uq144x112 memory) {
        return uq144x112(uint256(x) << RESOLUTION);
    }
    function decode(uq112x112 memory self) internal pure returns (uint112) {
        return uint112(self._x >> RESOLUTION);
    }
    function decode144(uq144x112 memory self) internal pure returns (uint144) {
        return uint144(self._x >> RESOLUTION);
    }
    function mul(uq112x112 memory self, uint256 y)
        internal
        pure
        returns (uq144x112 memory)
    {
        uint256 z = 0;
        require(
            y == 0 || (z = self._x * y) / y == self._x,
            "FixedPoint::mul: overflow"
        );
        return uq144x112(z);
    }
    function muli(uq112x112 memory self, int256 y)
        internal
        pure
        returns (int256)
    {
        uint256 z = FullMath.mulDiv(self._x, uint256(y < 0 ? -y : y), Q112);
        require(z < 2**255, "FixedPoint::muli: overflow");
        return y < 0 ? -int256(z) : int256(z);
    }
    function muluq(uq112x112 memory self, uq112x112 memory other)
        internal
        pure
        returns (uq112x112 memory)
    {
        if (self._x == 0 || other._x == 0) {
            return uq112x112(0);
        }
        uint112 upper_self = uint112(self._x >> RESOLUTION); 
        uint112 lower_self = uint112(self._x & LOWER_MASK); 
        uint112 upper_other = uint112(other._x >> RESOLUTION); 
        uint112 lower_other = uint112(other._x & LOWER_MASK); 
        uint224 upper = uint224(upper_self) * upper_other; 
        uint224 lower = uint224(lower_self) * lower_other; 
        uint224 uppers_lowero = uint224(upper_self) * lower_other; 
        uint224 uppero_lowers = uint224(upper_other) * lower_self; 
        require(
            upper <= type(uint112).max,
            "FixedPoint::muluq: upper overflow"
        );
        uint256 sum = uint256(upper << RESOLUTION) +
            uppers_lowero +
            uppero_lowers +
            (lower >> RESOLUTION);
        require(sum <= type(uint224).max, "FixedPoint::muluq: sum overflow");
        return uq112x112(uint224(sum));
    }
    function divuq(uq112x112 memory self, uq112x112 memory other)
        internal
        pure
        returns (uq112x112 memory)
    {
        require(other._x > 0, "FixedPoint::divuq: division by zero");
        if (self._x == other._x) {
            return uq112x112(uint224(Q112));
        }
        if (self._x <= type(uint144).max) {
            uint256 value = (uint256(self._x) << RESOLUTION) / other._x;
            require(value <= type(uint224).max, "FixedPoint::divuq: overflow");
            return uq112x112(uint224(value));
        }
        uint256 result = FullMath.mulDiv(Q112, self._x, other._x);
        require(result <= type(uint224).max, "FixedPoint::divuq: overflow");
        return uq112x112(uint224(result));
    }
    function fraction(uint256 numerator, uint256 denominator)
        internal
        pure
        returns (uq112x112 memory)
    {
        require(denominator > 0, "FixedPoint::fraction: division by zero");
        if (numerator == 0) return FixedPoint.uq112x112(0);
        if (numerator <= type(uint144).max) {
            uint256 result = (numerator << RESOLUTION) / denominator;
            require(
                result <= type(uint224).max,
                "FixedPoint::fraction: overflow"
            );
            return uq112x112(uint224(result));
        } else {
            uint256 result = FullMath.mulDiv(numerator, Q112, denominator);
            require(
                result <= type(uint224).max,
                "FixedPoint::fraction: overflow"
            );
            return uq112x112(uint224(result));
        }
    }
    function reciprocal(uq112x112 memory self)
        internal
        pure
        returns (uq112x112 memory)
    {
        require(self._x != 0, "FixedPoint::reciprocal: reciprocal of zero");
        require(self._x != 1, "FixedPoint::reciprocal: overflow");
        return uq112x112(uint224(Q224 / self._x));
    }
    function sqrt(uq112x112 memory self)
        internal
        pure
        returns (uq112x112 memory)
    {
        if (self._x <= type(uint144).max) {
            return uq112x112(uint224(Babylonian.sqrt(uint256(self._x) << 112)));
        }
        uint8 safeShiftBits = 255 - BitMath.mostSignificantBit(self._x);
        safeShiftBits -= safeShiftBits % 2;
        return
            uq112x112(
                uint224(
                    Babylonian.sqrt(uint256(self._x) << safeShiftBits) <<
                        ((112 - safeShiftBits) / 2)
                )
            );
    }
}
pragma solidity ^0.8.0;
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
pragma solidity =0.8.9;
library UniswapV2Library {
    using SafeMath for uint256;
    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }
    function pairFor(
        address factory,
        address tokenA,
        address tokenB
    ) internal pure returns (address pair) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        unchecked {
            pair = address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                hex"ff",
                                factory,
                                keccak256(abi.encodePacked(token0, token1)),
                                hex"96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f" 
                            )
                        )
                    )
                )
            );
        }
    }
    function getReserves(
        address factory,
        address tokenA,
        address tokenB
    ) internal view returns (uint256 reserveA, uint256 reserveB) {
        (address token0, ) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(
            pairFor(factory, tokenA, tokenB)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) internal pure returns (uint256 amountB) {
        require(amountA > 0, "UniswapV2Library: INSUFFICIENT_AMOUNT");
        require(
            reserveA > 0 && reserveB > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        amountB = amountA.mul(reserveB) / reserveA;
    }
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountOut) {
        require(amountIn > 0, "UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 amountInWithFee = amountIn.mul(997);
        uint256 numerator = amountInWithFee.mul(reserveOut);
        uint256 denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) internal pure returns (uint256 amountIn) {
        require(amountOut > 0, "UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT");
        require(
            reserveIn > 0 && reserveOut > 0,
            "UniswapV2Library: INSUFFICIENT_LIQUIDITY"
        );
        uint256 numerator = reserveIn.mul(amountOut).mul(1000);
        uint256 denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }
    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[0] = amountIn;
        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }
    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) internal view returns (uint256[] memory amounts) {
        require(path.length >= 2, "UniswapV2Library: INVALID_PATH");
        amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserveIn, uint256 reserveOut) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}
pragma solidity =0.8.9;
library UniswapV2OracleLibrary {
    using FixedPoint for *;
    function currentBlockTimestamp() internal view returns (uint32) {
        return uint32(block.timestamp % 2**32);
    }
    function currentCumulativePrices(address pair)
        internal
        view
        returns (
            uint256 price0Cumulative,
            uint256 price1Cumulative,
            uint32 blockTimestamp
        )
    {
        blockTimestamp = currentBlockTimestamp();
        price0Cumulative = IUniswapV2Pair(pair).price0CumulativeLast();
        price1Cumulative = IUniswapV2Pair(pair).price1CumulativeLast();
        (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        ) = IUniswapV2Pair(pair).getReserves();
        if (blockTimestampLast != blockTimestamp) {
            uint32 timeElapsed = blockTimestamp - blockTimestampLast;
            price0Cumulative +=
                uint256(FixedPoint.fraction(reserve1, reserve0)._x) *
                timeElapsed;
            price1Cumulative +=
                uint256(FixedPoint.fraction(reserve0, reserve1)._x) *
                timeElapsed;
        }
    }
}
pragma solidity =0.8.9;
contract UniswapV2ERC20 is IUniswapV2ERC20 {
    string public constant name = "Uniswap V2";
    string public constant symbol = "UNI-V2";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint256) public nonces;
    constructor() {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }
    function _mint(address to, uint256 value) internal {
        totalSupply = totalSupply + value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(address(0), to, value);
    }
    function _burn(address from, uint256 value) internal {
        balanceOf[from] = balanceOf[from] - value;
        totalSupply = totalSupply - value;
        emit Transfer(from, address(0), value);
    }
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function _transfer(
        address from,
        address to,
        uint256 value
    ) private {
        balanceOf[from] = balanceOf[from] - value;
        balanceOf[to] = balanceOf[to] + value;
        emit Transfer(from, to, value);
    }
    function approve(address spender, uint256 value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transfer(address to, uint256 value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] = allowance[from][msg.sender] - value;
        }
        _transfer(from, to, value);
        return true;
    }
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "UniswapV2: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "UniswapV2: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}
pragma solidity =0.8.9;
interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}
pragma solidity >=0.8.9;
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
pragma solidity =0.8.9;
library Math1 {
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}
pragma solidity =0.8.9;
contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using UQ112x112 for uint224;
    uint256 public constant MINIMUM_LIQUIDITY = 10**3;
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));
    address public factory;
    address public token0;
    address public token1;
    uint112 private reserve0; 
    uint112 private reserve1; 
    uint32 private blockTimestampLast; 
    uint256 public price0CumulativeLast;
    uint256 public price1CumulativeLast;
    uint256 public kLast; 
    uint256 private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "UniswapV2: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }
    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }
    function _safeTransfer(
        address token,
        address to,
        uint256 value
    ) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "UniswapV2: TRANSFER_FAILED"
        );
    }
    constructor() {
        factory = msg.sender;
    }
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN"); 
        token0 = _token0;
        token1 = _token1;
    }
    function _update(
        uint256 balance0,
        uint256 balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        require(
            balance0 <= type(uint112).max && balance1 <= type(uint112).max,
            "UniswapV2: OVERFLOW"
        );
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; 
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            price0CumulativeLast +=
                uint256(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed;
            price1CumulativeLast +=
                uint256(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed;
        }
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }
    function _mintFee(uint112 _reserve0, uint112 _reserve1)
        private
        returns (bool feeOn)
    {
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint256 _kLast = kLast; 
        if (feeOn) {
            if (_kLast != 0) {
                uint256 rootK = Math.sqrt(uint256(_reserve0) * _reserve1);
                uint256 rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    uint256 numerator = totalSupply * (rootK - rootKLast);
                    uint256 denominator = (rootK * 5) + rootKLast;
                    uint256 liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }
    function mint(address to) external lock returns (uint256 liquidity) {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); 
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        uint256 amount0 = balance0 - _reserve0;
        uint256 amount1 = balance1 - _reserve1;
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; 
        if (_totalSupply == 0) {
            liquidity = Math.sqrt(amount0 * amount1) - MINIMUM_LIQUIDITY;
            _mint(address(0), MINIMUM_LIQUIDITY); 
        } else {
            liquidity = Math.min(
                (amount0 * (_totalSupply)) / _reserve0,
                (amount1 * (_totalSupply)) / _reserve1
            );
        }
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * reserve1; 
        emit Mint(msg.sender, amount0, amount1);
    }
    function burn(address to)
        external
        lock
        returns (uint256 amount0, uint256 amount1)
    {
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); 
        address _token0 = token0; 
        address _token1 = token1; 
        uint256 balance0 = IERC20(_token0).balanceOf(address(this));
        uint256 balance1 = IERC20(_token1).balanceOf(address(this));
        uint256 liquidity = balanceOf[address(this)];
        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint256 _totalSupply = totalSupply; 
        amount0 = (liquidity * balance0) / _totalSupply; 
        amount1 = (liquidity * balance1) / _totalSupply; 
        require(
            amount0 > 0 && amount1 > 0,
            "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED"
        );
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));
        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint256(reserve0) * reserve1; 
        emit Burn(msg.sender, amount0, amount1, to);
    }
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external lock {
        require(
            amount0Out > 0 || amount1Out > 0,
            "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT"
        );
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); 
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "UniswapV2: INSUFFICIENT_LIQUIDITY"
        );
        uint256 balance0;
        uint256 balance1;
        {
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO");
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); 
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); 
            if (data.length > 0)
                IUniswapV2Callee(to).uniswapV2Call(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    data
                );
            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }
        uint256 amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        uint256 amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;
        require(
            amount0In > 0 || amount1In > 0,
            "UniswapV2: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            uint256 balance0Adjusted = (balance0 * 1000) - (amount0In * 3);
            uint256 balance1Adjusted = (balance1 * 1000) - (amount1In * 3);
            require(
                balance0Adjusted * balance1Adjusted >=
                    uint256(_reserve0) * _reserve1 * 1000**2,
                "UniswapV2: K"
            );
        }
        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }
    function skim(address to) external lock {
        address _token0 = token0; 
        address _token1 = token1; 
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)) - reserve0
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)) - reserve1
        );
    }
    function sync() external lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}
pragma solidity =0.8.9;
interface ITimelock {
    function delay() external view returns (uint256);
    function GRACE_PERIOD() external pure returns (uint256);
    function acceptAdmin() external;
    function queuedTransactions(bytes32 hash) external view returns (bool);
    function queueTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external returns (bytes32);
    function cancelTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external;
    function executeTransaction(
        address target,
        uint256 value,
        string calldata signature,
        bytes calldata data,
        uint256 eta
    ) external payable returns (bytes memory);
}
pragma solidity 0.8.9;
interface IXVader is IERC20 {
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);
}
pragma solidity =0.8.9;
contract GovernorAlpha {
    string public constant name = "Vader Governor Alpha";
    ITimelock public timelock;
    address public guardian;
    uint256 public proposalCount;
    IXVader public immutable xVader;
    address public feeReceiver;
    uint256 public feeAmount;
    address public council;
    struct Proposal {
        uint256 id;
        bool canceled;
        bool executed;
        address proposer;
        uint256 eta;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        uint256 startBlock;
        uint256 endBlock;
        uint224 forVotes;
        uint224 againstVotes;
        VetoStatus vetoStatus;
        mapping(address => Receipt) receipts;
    }
    struct Receipt {
        bool hasVoted;
        bool support;
        uint224 votes;
    }
    struct VetoStatus {
        bool hasBeenVetoed;
        bool support;
    }
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }
    mapping(uint256 => Proposal) public proposals;
    mapping(address => uint256) public latestProposalIds;
    bytes32 public constant DOMAIN_TYPEHASH =
        keccak256(
            "EIP712Domain(string name,uint256 chainId,address verifyingContract)"
        );
    bytes32 public constant BALLOT_TYPEHASH =
        keccak256("Ballot(uint256 proposalId,bool support)");
    event ProposalCreated(
        uint256 id,
        address proposer,
        address[] targets,
        uint256[] values,
        string[] signatures,
        bytes[] calldatas,
        uint256 startBlock,
        uint256 endBlock,
        string description
    );
    event VoteCast(
        address voter,
        uint256 proposalId,
        bool support,
        uint256 votes
    );
    event ProposalCanceled(uint256 id);
    event ProposalQueued(uint256 id, uint256 eta);
    event ProposalExecuted(uint256 id);
    event FeeReceiverChanged(address oldFeeReceiver, address newFeeReceiver);
    event FeeAmountChanged(uint256 oldFeeAmount, uint256 newFeeAmount);
    event ProposalVetoed(uint256 proposalId, bool support);
    event CouncilChanged(address oldCouncil, address newCouncil);
    constructor(
        address guardian_,
        address xVader_,
        address feeReceiver_,
        uint256 feeAmount_,
        address council_
    ) {
        require(
            xVader_ != address(0),
            "GovernorAlpha::constructor: xVader address is zero"
        );
        require(
            guardian_ != address(0) &&
                feeReceiver_ != address(0) &&
                council_ != address(0),
            "GovernorAlpha::constructor: guardian, feeReceiver or council cannot be zero"
        );
        guardian = guardian_;
        xVader = IXVader(xVader_);
        feeReceiver = feeReceiver_;
        feeAmount = feeAmount_;
        council = council_;
        emit FeeReceiverChanged(address(0), feeReceiver_);
        emit FeeAmountChanged(0, feeAmount_);
    }
    function quorumVotes(uint256 blockNumber) public view returns (uint256) {
        return (xVader.getPastTotalSupply(blockNumber) * 4) / 100; 
    }
    function proposalMaxOperations() public pure returns (uint256) {
        return 10; 
    }
    function votingDelay() public pure returns (uint256) {
        return 1; 
    }
    function votingPeriod() public pure virtual returns (uint256) {
        return 17280; 
    }
    function getActions(uint256 proposalId)
        public
        view
        returns (
            address[] memory targets,
            uint256[] memory values,
            string[] memory signatures,
            bytes[] memory calldatas
        )
    {
        Proposal storage p = proposals[proposalId];
        return (p.targets, p.values, p.signatures, p.calldatas);
    }
    function getReceipt(uint256 proposalId, address voter)
        public
        view
        returns (Receipt memory)
    {
        return proposals[proposalId].receipts[voter];
    }
    function state(uint256 proposalId) public view returns (ProposalState) {
        require(
            proposalCount >= proposalId && proposalId > 0,
            "GovernorAlpha::state: invalid proposal id"
        );
        Proposal storage proposal = proposals[proposalId];
        if (proposal.canceled) return ProposalState.Canceled;
        if (proposal.vetoStatus.hasBeenVetoed) {
            uint256 _eta = proposal.eta;
            if (proposal.vetoStatus.support && _eta == 0)
                return ProposalState.Succeeded;
            if (_eta == 0) return ProposalState.Defeated;
        } else {
            if (block.number <= proposal.startBlock)
                return ProposalState.Pending;
            if (block.number <= proposal.endBlock) return ProposalState.Active;
            if (
                proposal.forVotes <= proposal.againstVotes ||
                proposal.forVotes < quorumVotes(proposal.startBlock)
            ) return ProposalState.Defeated;
            if (proposal.eta == 0) return ProposalState.Succeeded;
        }
        if (proposal.executed) return ProposalState.Executed;
        if (block.timestamp >= proposal.eta + timelock.GRACE_PERIOD())
            return ProposalState.Expired;
        return ProposalState.Queued;
    }
    function setTimelock(address _timelock) external onlyGuardian {
        require(
            _timelock != address(0),
            "GovernorAlpha::initTimelock: _timelock cannot be zero address"
        );
        timelock = ITimelock(_timelock);
    }
    function propose(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public returns (uint256 proposalId) {
        require(
            targets.length == values.length &&
                targets.length == signatures.length &&
                targets.length == calldatas.length,
            "GovernorAlpha::propose: proposal function information arity mismatch"
        );
        require(
            targets.length != 0,
            "GovernorAlpha::propose: must provide actions"
        );
        require(
            targets.length <= proposalMaxOperations(),
            "GovernorAlpha::propose: too many actions"
        );
        xVader.transferFrom(msg.sender, feeReceiver, feeAmount);
        uint256 latestProposalId = latestProposalIds[msg.sender];
        if (latestProposalId != 0) {
            ProposalState proposersLatestProposalState = state(
                latestProposalId
            );
            require(
                proposersLatestProposalState != ProposalState.Active,
                "GovernorAlpha::propose: one live proposal per proposer, found an already active proposal"
            );
            require(
                proposersLatestProposalState != ProposalState.Pending,
                "GovernorAlpha::propose: one live proposal per proposer, found an already pending proposal"
            );
        }
        uint256 startBlock = block.number + votingDelay();
        uint256 endBlock = startBlock + votingPeriod();
        proposalId = ++proposalCount;
        Proposal storage newProposal = proposals[proposalId];
        newProposal.id = proposalId;
        newProposal.proposer = msg.sender;
        newProposal.targets = targets;
        newProposal.values = values;
        newProposal.signatures = signatures;
        newProposal.calldatas = calldatas;
        newProposal.startBlock = startBlock;
        newProposal.endBlock = endBlock;
        latestProposalIds[msg.sender] = proposalId;
        emit ProposalCreated(
            proposalId,
            msg.sender,
            targets,
            values,
            signatures,
            calldatas,
            startBlock,
            endBlock,
            description
        );
    }
    function queue(uint256 proposalId) public {
        require(
            state(proposalId) == ProposalState.Succeeded,
            "GovernorAlpha::queue: proposal can only be queued if it is succeeded"
        );
        Proposal storage proposal = proposals[proposalId];
        uint256 eta = block.timestamp + timelock.delay();
        uint256 length = proposal.targets.length;
        for (uint256 i = 0; i < length; i++) {
            _queueOrRevert(
                proposal.targets[i],
                proposal.values[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                eta
            );
        }
        proposal.eta = eta;
        emit ProposalQueued(proposalId, eta);
    }
    function execute(uint256 proposalId) public payable {
        require(
            state(proposalId) == ProposalState.Queued,
            "GovernorAlpha::execute: proposal can only be executed if it is queued"
        );
        Proposal storage proposal = proposals[proposalId];
        proposal.executed = true;
        uint256 length = proposal.targets.length;
        for (uint256 i = 0; i < length; i++) {
            timelock.executeTransaction{value: proposal.values[i]}(
                proposal.targets[i],
                proposal.values[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                proposal.eta
            );
        }
        emit ProposalExecuted(proposalId);
    }
    function castVote(uint256 proposalId, bool support) public {
        return _castVote(msg.sender, proposalId, support);
    }
    function castVoteBySig(
        uint256 proposalId,
        bool support,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        bytes32 domainSeparator = keccak256(
            abi.encode(
                DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                getChainId(),
                address(this)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(BALLOT_TYPEHASH, proposalId, support)
        );
        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", domainSeparator, structHash)
        );
        address signatory = ecrecover(digest, v, r, s);
        require(
            signatory != address(0),
            "GovernorAlpha::castVoteBySig: invalid signature"
        );
        return _castVote(signatory, proposalId, support);
    }
    function changeFeeReceiver(address feeReceiver_) external onlyGuardian {
        emit FeeReceiverChanged(feeReceiver, feeReceiver_);
        feeReceiver = feeReceiver_;
    }
    function changeFeeAmount(uint256 feeAmount_) external onlyGuardian {
        emit FeeAmountChanged(feeAmount, feeAmount_);
        feeAmount = feeAmount_;
    }
    function veto(uint256 proposalId, bool support) external onlyCouncil {
        ProposalState _state = state(proposalId);
        require(
            _state == ProposalState.Active || _state == ProposalState.Pending,
            "GovernorAlpha::veto: Proposal can only be vetoed when active"
        );
        Proposal storage proposal = proposals[proposalId];
        address[] memory _targets = proposal.targets;
        for (uint256 i = 0; i < _targets.length; i++) {
            if (_targets[i] == address(this)) {
                revert(
                    "GovernorAlpha::veto: council cannot veto on proposal having action with address(this) as target"
                );
            }
        }
        VetoStatus storage _vetoStatus = proposal.vetoStatus;
        _vetoStatus.hasBeenVetoed = true;
        _vetoStatus.support = support;
        if (support) {
            queue(proposalId);
        }
        emit ProposalVetoed(proposalId, support);
    }
    function changeCouncil(address council_) external onlyTimelock {
        emit CouncilChanged(council, council_);
        council = council_;
    }
    function cancel(uint256 proposalId) public onlyGuardian {
        ProposalState _state = state(proposalId);
        require(
            _state != ProposalState.Executed,
            "GovernorAlpha::cancel: cannot cancel executed proposal"
        );
        Proposal storage proposal = proposals[proposalId];
        proposal.canceled = true;
        uint256 length = proposal.targets.length;
        for (uint256 i = 0; i < length; i++) {
            timelock.cancelTransaction(
                proposal.targets[i],
                proposal.values[i],
                proposal.signatures[i],
                proposal.calldatas[i],
                proposal.eta
            );
        }
        emit ProposalCanceled(proposalId);
    }
    function __acceptAdmin() public onlyGuardian {
        timelock.acceptAdmin();
    }
    function __abdicate() public onlyGuardian {
        guardian = address(0);
    }
    function __queueSetTimelockPendingAdmin(
        address newPendingAdmin,
        uint256 eta
    ) public onlyGuardian {
        timelock.queueTransaction(
            address(timelock),
            0,
            "setPendingAdmin(address)",
            abi.encode(newPendingAdmin),
            eta
        );
    }
    function __executeSetTimelockPendingAdmin(
        address newPendingAdmin,
        uint256 eta
    ) public onlyGuardian {
        timelock.executeTransaction(
            address(timelock),
            0,
            "setPendingAdmin(address)",
            abi.encode(newPendingAdmin),
            eta
        );
    }
    function _queueOrRevert(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) internal {
        require(
            !timelock.queuedTransactions(
                keccak256(abi.encode(target, value, signature, data, eta))
            ),
            "GovernorAlpha::_queueOrRevert: proposal action already queued at eta"
        );
        timelock.queueTransaction(target, value, signature, data, eta);
    }
    function _castVote(
        address voter,
        uint256 proposalId,
        bool support
    ) internal {
        require(
            state(proposalId) == ProposalState.Active,
            "GovernorAlpha::_castVote: voting is closed"
        );
        Proposal storage proposal = proposals[proposalId];
        Receipt storage receipt = proposal.receipts[voter];
        require(
            !receipt.hasVoted,
            "GovernorAlpha::_castVote: voter already voted"
        );
        uint224 votes = uint224(xVader.getPastVotes(voter, proposal.startBlock));
        if (support) {
            proposal.forVotes = proposal.forVotes + votes;
        } else {
            proposal.againstVotes = proposal.againstVotes + votes;
        }
        receipt.hasVoted = true;
        receipt.support = support;
        receipt.votes = votes;
        emit VoteCast(voter, proposalId, support, votes);
    }
    function getChainId() internal view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
    function _onlyGuardian() private view {
        require(
            msg.sender == guardian,
            "GovernorAlpha::_onlyGuardian: only guardian can call"
        );
    }
    function _onlyTimelock() private view {
        require(
            msg.sender == address(timelock),
            "GovernorAlpha::_onlyTimelock: only timelock can call"
        );
    }
    function _onlyCouncil() private view {
        require(
            msg.sender == council,
            "GovernorAlpha::_onlyCouncil: only council can call"
        );
    }
    modifier onlyGuardian() {
        _onlyGuardian();
        _;
    }
    modifier onlyTimelock() {
        _onlyTimelock();
        _;
    }
    modifier onlyCouncil() {
        _onlyCouncil();
        _;
    }
}
pragma solidity =0.8.9;
contract Timelock is ITimelock {
    address public admin;
    address public pendingAdmin;
    uint256 public override delay;
    mapping(bytes32 => bool) public override queuedTransactions;
    event NewAdmin(address indexed newAdmin);
    event NewPendingAdmin(address indexed newPendingAdmin);
    event NewDelay(uint256 indexed newDelay);
    event CancelTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );
    event ExecuteTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );
    event QueueTransaction(
        bytes32 indexed txHash,
        address indexed target,
        uint256 value,
        string signature,
        bytes data,
        uint256 eta
    );
    receive() external payable {}
    constructor(address admin_, uint256 delay_) {
        require(
            delay_ >= MINIMUM_DELAY(),
            "Timelock::constructor: Delay must exceed minimum delay."
        );
        require(
            delay_ <= MAXIMUM_DELAY(),
            "Timelock::constructor: Delay must not exceed maximum delay."
        );
        require(
            admin_ != address(0),
            "Timelock::constructor: Admin cannot be zero"
        );
        admin = admin_;
        delay = delay_;
    }
    function GRACE_PERIOD() public pure virtual override returns (uint256) {
        return 14 days;
    }
    function MINIMUM_DELAY() public pure virtual returns (uint256) {
        return 2 days;
    }
    function MAXIMUM_DELAY() public pure virtual returns (uint256) {
        return 30 days;
    }
    function setDelay(uint256 delay_) public {
        require(
            msg.sender == address(this),
            "Timelock::setDelay: Call must come from Timelock."
        );
        require(
            delay_ >= MINIMUM_DELAY(),
            "Timelock::setDelay: Delay must exceed minimum delay."
        );
        require(
            delay_ <= MAXIMUM_DELAY(),
            "Timelock::setDelay: Delay must not exceed maximum delay."
        );
        delay = delay_;
        emit NewDelay(delay);
    }
    function acceptAdmin() public override {
        require(
            msg.sender == pendingAdmin,
            "Timelock::acceptAdmin: Call must come from pendingAdmin."
        );
        admin = msg.sender;
        pendingAdmin = address(0);
        emit NewAdmin(admin);
    }
    function setPendingAdmin(address pendingAdmin_) public {
        require(
            msg.sender == address(this),
            "Timelock::setPendingAdmin: Call must come from Timelock."
        );
        pendingAdmin = pendingAdmin_;
        emit NewPendingAdmin(pendingAdmin);
    }
    function queueTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public override returns (bytes32 txHash) {
        require(
            msg.sender == admin,
            "Timelock::queueTransaction: Call must come from admin."
        );
        require(
            eta >= getBlockTimestamp() + delay,
            "Timelock::queueTransaction: Estimated execution block must satisfy delay."
        );
        txHash = keccak256(abi.encode(target, value, signature, data, eta));
        queuedTransactions[txHash] = true;
        emit QueueTransaction(txHash, target, value, signature, data, eta);
    }
    function cancelTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public override {
        require(
            msg.sender == admin,
            "Timelock::cancelTransaction: Call must come from admin."
        );
        bytes32 txHash = keccak256(
            abi.encode(target, value, signature, data, eta)
        );
        queuedTransactions[txHash] = false;
        emit CancelTransaction(txHash, target, value, signature, data, eta);
    }
    function executeTransaction(
        address target,
        uint256 value,
        string memory signature,
        bytes memory data,
        uint256 eta
    ) public payable override returns (bytes memory) {
        require(
            msg.sender == admin,
            "Timelock::executeTransaction: Call must come from admin."
        );
        bytes32 txHash = keccak256(
            abi.encode(target, value, signature, data, eta)
        );
        require(
            queuedTransactions[txHash],
            "Timelock::executeTransaction: Transaction hasn't been queued."
        );
        require(
            getBlockTimestamp() >= eta,
            "Timelock::executeTransaction: Transaction hasn't surpassed time lock."
        );
        require(
            getBlockTimestamp() <= eta + GRACE_PERIOD(),
            "Timelock::executeTransaction: Transaction is stale."
        );
        queuedTransactions[txHash] = false;
        bytes memory callData;
        if (bytes(signature).length == 0) {
            callData = data;
        } else {
            callData = abi.encodePacked(
                bytes4(keccak256(bytes(signature))),
                data
            );
        }
        (bool success, bytes memory returnData) = target.call{value: value}(
            callData
        );
        require(
            success,
            "Timelock::executeTransaction: Transaction execution reverted."
        );
        emit ExecuteTransaction(txHash, target, value, signature, data, eta);
        return returnData;
    }
    function getBlockTimestamp() internal view returns (uint256) {
        return block.timestamp;
    }
}
pragma solidity =0.8.9;
interface IVaderPoolFactoryV2 {
    function createPool(address tokenA, address tokenB)
        external
        returns (IVaderPoolV2);
    function getPool(address tokenA, address tokenB)
        external
        returns (IVaderPoolV2);
    function nativeAsset() external view returns (address);
    event PoolCreated(
        address token0,
        address token1,
        IVaderPoolV2 pool,
        uint256 totalPools
    );
}
pragma solidity =0.8.9;
contract MockAggregatorV3 {
    IERC20 public token;
    uint80 private _storedRoundId;
    constructor(IERC20 _token) {
        token = _token;
    }
    function decimals() external pure returns (uint8) {
        return 8;
    }
    function version() external pure returns (uint256) {
        return 3;
    }
    function getRoundData(uint80 _roundId)
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        roundId = _roundId;
        answer = 1e8;
        startedAt = block.timestamp;
        updatedAt = block.timestamp;
        answeredInRound = roundId;
    }
    function latestRoundData()
        external
        view
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        roundId = _storedRoundId + 1;
        answer = 1e8;
        startedAt = block.timestamp;
        updatedAt = block.timestamp;
        answeredInRound = roundId;
    }
}
pragma solidity =0.8.9;
contract MockConstants is ProtocolConstants {
    uint256 public constant INITIAL_VADER_SUPPLY = _INITIAL_VADER_SUPPLY;
    uint256 public constant VETH_ALLOCATION = _VETH_ALLOCATION;
    uint256 public constant VADER_VETHER_CONVERSION_RATE =
        _VADER_VETHER_CONVERSION_RATE;
    uint256 public constant TEAM_ALLOCATION = _TEAM_ALLOCATION;
    uint256 public constant ECOSYSTEM_GROWTH = _ECOSYSTEM_GROWTH;
    uint256 public constant EMISSION_ERA = _EMISSION_ERA;
    uint256 public constant ONE_YEAR = _ONE_YEAR;
    uint256 public constant INITIAL_EMISSION_CURVE = _INITIAL_EMISSION_CURVE;
    uint256 public constant VESTING_DURATION = _VESTING_DURATION;
    uint256 public constant MAX_BASIS_POINTS = _MAX_BASIS_POINTS;
    uint256 public constant MAX_FEE_BASIS_POINTS = _MAX_FEE_BASIS_POINTS;
    address public constant BURN = _BURN;
}
pragma solidity =0.8.9;
contract MockGovernorAlpha is GovernorAlpha {
    constructor(
        address guardian_,
        address xVader_,
        address feeReceiver_,
        uint256 feeAmount_,
        address council_
    )
        GovernorAlpha(
            guardian_,
            xVader_,
            feeReceiver_,
            feeAmount_,
            council_
        )
    {}
    function votingPeriod() public pure override returns (uint256) {
        return 50;
    }
    function CHAINID() public view returns (uint256 chainId) {
        assembly {
            chainId := chainid()
        }
    }
}
pragma solidity =0.8.9;
contract MockTarget {
    bool public state;
    ITimelock public timelock;
    constructor(address _timelock) {
        timelock = ITimelock(_timelock);
    }
    function setStateToTrue() external onlyTimelock {
        state = true;
    }
    function changeState(bool _state) external onlyTimelock {
        state = _state;
    }
    modifier onlyTimelock() {
        require(msg.sender == address(timelock), "only timelock can call");
        _;
    }
}
pragma solidity =0.8.9;
contract MockTimelock is Timelock {
    constructor(address admin_, uint256 delay_) Timelock(admin_, delay_) {}
    function GRACE_PERIOD() public pure override returns (uint256) {
        return 1 days;
    }
    function MINIMUM_DELAY() public pure override returns (uint256) {
        return 5 minutes;
    }
    function MAXIMUM_DELAY() public pure override returns (uint256) {
        return 15 minutes;
    }
}
pragma solidity =0.8.9;
contract MockToken is ERC20 {
    uint8 internal immutable _decimals;
    constructor(
        string memory _symbol,
        string memory _name,
        uint8 __decimals
    ) ERC20(_symbol, _name) {
        _decimals = __decimals;
    }
    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
    function decimals() public view override returns (uint8) {
        return _decimals;
    }
}
pragma solidity =0.8.9;
contract MockUniswapV2Factory is IUniswapV2Factory {
    address public feeTo;
    address public feeToSetter;
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;
    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }
    function allPairsLength() external view returns (uint256) {
        return allPairs.length;
    }
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair)
    {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        require(
            getPair[token0][token1] == address(0),
            "UniswapV2: PAIR_EXISTS"
        ); 
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; 
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeTo = _feeTo;
    }
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}
pragma solidity =0.8.9;
contract MockUniswapV2Library {
    function pairFor(
        address _factory,
        address _token0,
        address _token1
    ) external pure returns (address) {
        return UniswapV2Library.pairFor(_factory, _token0, _token1);
    }
}
pragma solidity 0.8.9;
contract XVader is ProtocolConstants, ERC20Votes, ReentrancyGuard {
    IERC20 public immutable vader;
    constructor(IERC20 _vader)
        ERC20Permit("XVader")
        ERC20("XVader", "xVADER")
    {
        require(
            _vader != IERC20(_ZERO_ADDRESS),
            "XVader::constructor: _vader cannot be a zero address"
        );
        vader = _vader;
    }
    function enter(uint256 _amount) external nonReentrant {
        uint256 totalVader = vader.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        uint256 xVADERToMint = totalShares == 0 || totalVader == 0
            ? _amount
            : (_amount * totalShares) / totalVader;
        _mint(msg.sender, xVADERToMint);
        vader.transferFrom(msg.sender, address(this), _amount);
    }
    function leave(uint256 _shares) external nonReentrant {
        uint vaderAmount = (_shares * vader.balanceOf(address(this))) / totalSupply();
        _burn(msg.sender, _shares);
        vader.transfer(msg.sender, vaderAmount);
    }
}
pragma solidity =0.8.9;
contract MockXVader is XVader {
    constructor(IERC20 _vader) XVader(_vader) {}
    function mint(address to, uint256 amount) external {
        ERC20Votes._mint(to, amount);
    }
    function burn(address from, uint256 amount) external {
        ERC20Votes._burn(from, amount);
    }
}
pragma solidity =0.8.9;
contract VaderReserve is IVaderReserve, ProtocolConstants, Ownable {
    using SafeERC20 for IERC20;
    IERC20 public immutable vader;
    address public router;
    uint256 public lastGrant;
    constructor(
        IERC20 _vader
    ) {
        require(
            _vader != IERC20(_ZERO_ADDRESS),
            "VaderReserve::constructor: Incorrect Arguments"
        );
        vader = _vader;
    }
    function reserve() public view override returns (uint256) {
        return vader.balanceOf(address(this));
    }
    function grant(address recipient, uint256 amount)
        external
        override
        onlyOwner
        throttle
    {
        amount = _min(
            (reserve() * _MAX_GRANT_BASIS_POINTS) / _MAX_BASIS_POINTS,
            amount
        );
        vader.safeTransfer(recipient, amount);
        emit GrantDistributed(recipient, amount);
    }
    function initialize(address _router, address _dao) external onlyOwner {
         require(
            _router != _ZERO_ADDRESS &&
                _dao != _ZERO_ADDRESS,
            "VaderReserve::initialize: Incorrect Arguments"
        );
        router = _router;
        transferOwnership(_dao);
    }
    function reimburseImpermanentLoss(address recipient, uint256 amount)
        external
        override
    {
        require(
            msg.sender == router,
            "VaderReserve::reimburseImpermanentLoss: Insufficient Priviledges"
        );
        uint256 actualAmount = _min(reserve(), amount);
        vader.safeTransfer(recipient, actualAmount);
        emit LossCovered(recipient, amount, actualAmount);
    }
    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
    modifier throttle() {
        require(
            lastGrant + _GRANT_DELAY <= block.timestamp,
            "VaderReserve::throttle: Grant Too Fast"
        );
        lastGrant = block.timestamp;
        _;
    }
}
pragma solidity 0.8.9;
contract Owned {
    address public owner;
    address public nominatedOwner;
    constructor(address _owner) {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }
    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }
    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }
    modifier onlyOwner {
        _onlyOwner();
        _;
    }
    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }
    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}
pragma solidity 0.8.9;
abstract contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;
    constructor() {
        require(owner != address(0), "Owner must be set");
    }
    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }
        paused = _paused;
        if (_paused) {
            lastPauseTime = block.timestamp;
        }
        emit PauseChanged(_paused);
    }
    event PauseChanged(bool isPaused);
    modifier notPaused() {
        require(!paused, "paused");
        _;
    }
}
pragma solidity 0.8.9;
abstract contract RewardsDistributionRecipient is Owned {
    address public rewardsDistribution;
    function notifyRewardAmount(uint reward) external virtual;
    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "not reward distribution");
        _;
    }
    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}
pragma solidity 0.8.9;
interface IStakingRewards {
    function balanceOf(address account) external view returns (uint);
    function earned(address account) external view returns (uint);
    function getRewardForDuration() external view returns (uint);
    function lastTimeRewardApplicable() external view returns (uint);
    function rewardPerToken() external view returns (uint);
    function totalSupply() external view returns (uint);
    function exit() external;
    function getReward() external;
    function stake(uint amount) external;
    function withdraw(uint amount) external;
}
pragma solidity 0.8.9;
contract StakingRewards is
    IStakingRewards,
    RewardsDistributionRecipient,
    ReentrancyGuard,
    Pausable
{
    using SafeERC20 for IERC20;
    IERC20 public immutable rewardsToken;
    IERC20 public immutable stakingToken;
    uint public periodFinish;
    uint public rewardRate;
    uint public rewardsDuration = 7 days;
    uint public lastUpdateTime;
    uint public rewardPerTokenStored;
    mapping(address => uint) public userRewardPerTokenPaid;
    mapping(address => uint) public rewards;
    uint private _totalSupply;
    mapping(address => uint) private _balances;
    constructor(
        address _owner,
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken
    ) Owned(_owner) {
        require(_rewardsDistribution != address(0), "reward dist = zero address");
        require(_rewardsToken != address(0), "reward token = zero address");
        require(_stakingToken != address(0), "staking token = zero address");
        rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        rewardsDistribution = _rewardsDistribution;
    }
    function totalSupply() external view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) external view returns (uint) {
        return _balances[account];
    }
    function lastTimeRewardApplicable() public view returns (uint) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }
    function rewardPerToken() public view returns (uint) {
        if (_totalSupply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored +
            ((lastTimeRewardApplicable() - lastUpdateTime) * rewardRate * 1e18) /
            _totalSupply;
    }
    function earned(address account) public view returns (uint) {
        return
            _balances[account] *
            ((rewardPerToken() - userRewardPerTokenPaid[account]) / 1e18) +
            rewards[account];
    }
    function getRewardForDuration() external view returns (uint) {
        return rewardRate * rewardsDuration;
    }
    function stake(uint amount)
        external
        nonReentrant
        notPaused
        updateReward(msg.sender)
    {
        require(amount > 0, "Cannot stake 0");
        _totalSupply += amount;
        _balances[msg.sender] += amount;
        stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }
    function withdraw(uint amount) public nonReentrant updateReward(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply -= amount;
        _balances[msg.sender] -= amount;
        stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    function getReward() public nonReentrant updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
    function exit() external {
        withdraw(_balances[msg.sender]);
        getReward();
    }
    function notifyRewardAmount(uint reward)
        external
        override
        onlyRewardsDistribution
        updateReward(address(0))
    {
        if (block.timestamp >= periodFinish) {
            rewardRate = reward / rewardsDuration;
        } else {
            uint remaining = periodFinish - block.timestamp;
            uint leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }
        uint balance = rewardsToken.balanceOf(address(this));
        require(rewardRate <= balance / rewardsDuration, "Provided reward too high");
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }
    function recoverERC20(address tokenAddress, uint tokenAmount) external onlyOwner {
        require(
            tokenAddress != address(stakingToken),
            "Cannot withdraw the staking token"
        );
        IERC20(tokenAddress).safeTransfer(msg.sender, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }
    function setRewardsDuration(uint _rewardsDuration) external onlyOwner {
        require(
            block.timestamp > periodFinish,
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(_rewardsDuration);
    }
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    event RewardAdded(uint reward);
    event Staked(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RewardPaid(address indexed user, uint reward);
    event RewardsDurationUpdated(uint newDuration);
    event Recovered(address token, uint amount);
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
pragma solidity =0.8.9;
interface IConverter {
    function convert(bytes32[] calldata proof, uint256 amount)
        external
        returns (uint256 vaderReceived);
    event Conversion(
        address indexed user,
        uint256 vetherAmount,
        uint256 vaderAmount
    );
}
pragma solidity =0.8.9;
interface ILinearVesting {
    struct Vester {
        uint192 amount;
        uint64 lastClaim;
        uint128 start;
        uint128 end;
    }
    function getClaim() external view returns (uint256 vestedAmount);
    function claim() external returns (uint256 vestedAmount);
    function claimConverted() external returns (uint256 vestedAmount);
    function begin() external;
    function vestFor(address user, uint256 amount) external;
    event VestingInitialized(uint256 duration);
    event Vested(address indexed from, uint256 amount);
}
pragma solidity =0.8.9;
contract Converter is IConverter, ProtocolConstants {
    using SafeERC20 for IERC20;
    using MerkleProof for bytes32[];
    IERC20 public immutable vether;
    IERC20 public immutable vader;
    ILinearVesting public immutable vesting;
    bytes32 public immutable root;
    mapping(bytes32 => bool) public claimed;
    constructor(
        IERC20 _vether,
        IERC20 _vader,
        ILinearVesting _vesting,
        bytes32 _root
    ) {
        require(
            _vether != IERC20(_ZERO_ADDRESS) &&
                _vader != IERC20(_ZERO_ADDRESS) &&
                _vesting != ILinearVesting(_ZERO_ADDRESS),
            "Converter::constructor: Misconfiguration"
        );
        vether = _vether;
        vader = _vader;
        _vader.approve(address(_vesting), type(uint256).max);
        vesting = _vesting;
        root = _root;
    }
    function convert(bytes32[] calldata proof, uint256 amount)
        external
        override
        returns (uint256 vaderReceived)
    {
        require(
            amount != 0,
            "Converter::convert: Non-Zero Conversion Amount Required"
        );
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, amount));
        require(
            !claimed[leaf] && proof.verify(root, leaf),
            "Converter::convert: Incorrect Proof Provided"
        );
        claimed[leaf] = true;
        vaderReceived = amount * _VADER_VETHER_CONVERSION_RATE;
        emit Conversion(msg.sender, amount, vaderReceived);
        vether.safeTransferFrom(msg.sender, _BURN, amount);
        uint256 half = vaderReceived / 2;
        vader.safeTransfer(msg.sender, half);
        vesting.vestFor(msg.sender, half);
    }
}
pragma solidity =0.8.9;
interface IUSDV {
    function distributeEmission() external;
}
pragma solidity =0.8.9;
contract USDV is IUSDV, ProtocolConstants, ERC20, Ownable {
    IERC20 public immutable vader;
    IVaderReserve public immutable reserve;
    constructor(IERC20 _vader, IVaderReserve _reserve)
        ERC20("Vader USD", "USDV")
    {
        require(
            _reserve != IVaderReserve(_ZERO_ADDRESS),
            "USDV::constructor: Incorrect Arguments"
        );
        vader = _vader;
        reserve = _reserve;
    }
    function distributeEmission() external override {
        uint256 balance = vader.balanceOf(address(this));
        vader.transfer(address(reserve), balance);
    }
}
pragma solidity =0.8.9;
interface IVader {
    function createEmission(address user, uint256 amount) external;
    function calculateFee() external view returns (uint256 basisPoints);
    function getCurrentEraEmission() external view returns (uint256);
    function getEraEmission(uint256 currentSupply)
        external
        view
        returns (uint256);
    event Emission(address to, uint256 amount);
    event EmissionChanged(uint256 previous, uint256 next);
    event MaxSupplyChanged(uint256 previous, uint256 next);
    event GrantClaimed(address indexed beneficiary, uint256 amount);
    event ProtocolInitialized(
        address converter,
        address vest,
        address usdv,
        address dao
    );
}
pragma solidity =0.8.9;
contract Vader is IVader, ProtocolConstants, ERC20, Ownable {
    IConverter public converter;
    ILinearVesting public vest;
    IUSDV public usdv;
    uint256 public emissionCurve = _INITIAL_EMISSION_CURVE;
    uint256 public lastEmission = block.timestamp;
    uint256 public maxSupply = _INITIAL_VADER_SUPPLY;
    mapping(address => bool) public untaxed;
    constructor() ERC20("Vader", "VADER") {
        _mint(address(this), _ECOSYSTEM_GROWTH);
    }
    function calculateFee() public view override returns (uint256 basisPoints) {
        basisPoints = (_MAX_FEE_BASIS_POINTS * totalSupply()) / maxSupply;
    }
    function getCurrentEraEmission() external view override returns (uint256) {
        return getEraEmission(totalSupply());
    }
    function getEraEmission(uint256 currentSupply)
        public
        view
        override
        returns (uint256)
    {
        return
            ((maxSupply - currentSupply) / emissionCurve) /
            (_ONE_YEAR / _EMISSION_ERA);
    }
    function createEmission(address user, uint256 amount)
        external
        override
        onlyOwner
    {
        _mint(user, amount);
        emit Emission(user, amount);
    }
    function setComponents(
        IConverter _converter,
        ILinearVesting _vest,
        IUSDV _usdv,
        address dao
    ) external onlyOwner {
        require(
            _converter != IConverter(_ZERO_ADDRESS) &&
                _vest != ILinearVesting(_ZERO_ADDRESS) &&
                _usdv != IUSDV(_ZERO_ADDRESS) &&
                dao != _ZERO_ADDRESS,
            "Vader::setComponents: Incorrect Arguments"
        );
        require(
            converter == IConverter(_ZERO_ADDRESS),
            "Vader::setComponents: Already Set"
        );
        converter = _converter;
        vest = _vest;
        usdv = _usdv;
        untaxed[address(_converter)] = true;
        untaxed[address(_vest)] = true;
        untaxed[address(_usdv)] = true;
        _mint(address(_converter), _VETH_ALLOCATION);
        _mint(address(_vest), _TEAM_ALLOCATION);
        _vest.begin();
        transferOwnership(dao);
        emit ProtocolInitialized(
            address(_converter),
            address(_vest),
            address(_usdv),
            dao
        );
    }
    function claimGrant(address beneficiary, uint256 amount) external onlyDAO {
        require(amount != 0, "Vader::claimGrant: Non-Zero Amount Required");
        emit GrantClaimed(beneficiary, amount);
        ERC20._transfer(address(this), beneficiary, amount);
    }
    function adjustMaxSupply(uint256 _maxSupply) external onlyDAO {
        require(
            _maxSupply >= totalSupply(),
            "Vader::adjustMaxSupply: Max supply cannot subcede current supply"
        );
        emit MaxSupplyChanged(maxSupply, _maxSupply);
        maxSupply = _maxSupply;
    }
    function _beforeTokenTransfer(
        address from,
        address,
        uint256 amount
    ) internal view override {
        if (from == address(0))
            require(
                totalSupply() + amount <= maxSupply,
                "Vader::_beforeTokenTransfer: Mint exceeds cap"
            );
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        if (untaxed[msg.sender])
            return ERC20._transfer(sender, recipient, amount);
        uint256 fee = calculateFee();
        uint256 tax = (amount * fee) / _MAX_BASIS_POINTS;
        amount -= tax;
        _burn(sender, tax);
        ERC20._transfer(sender, recipient, amount);
    }
    function _onlyDAO() private view {
        require(
            converter != IConverter(_ZERO_ADDRESS),
            "Vader::_onlyDAO: DAO not set yet"
        );
        require(
            owner() == _msgSender(),
            "Vader::_onlyDAO: Insufficient Privileges"
        );
    }
    modifier onlyDAO() {
        _onlyDAO();
        _;
    }
}
pragma solidity =0.8.9;
contract LinearVesting is ILinearVesting, ProtocolConstants, Ownable {
    using SafeERC20 for IERC20;
    IERC20 public immutable vader;
    uint256 public start;
    uint256 public end;
    mapping(address => Vester) public vest;
    constructor(
        IERC20 _vader,
        address[] memory vesters,
        uint192[] memory amounts
    ) {
        require(
            _vader != IERC20(_ZERO_ADDRESS) && vesters.length == amounts.length,
            "LinearVesting::constructor: Misconfiguration"
        );
        vader = _vader;
        uint256 total;
        for (uint256 i = 0; i < vesters.length; i++) {
            require(
                amounts[i] != 0,
                "LinearVesting::constructor: Incorrect Amount Specified"
            );
            vest[vesters[i]].amount = amounts[i];
            total = total + amounts[i];
        }
        require(
            total == _TEAM_ALLOCATION,
            "LinearVesting::constructor: Invalid Vest Amounts Specified"
        );
        transferOwnership(address(_vader));
    }
    function getClaim()
        external
        view
        override
        hasStarted
        returns (uint256 vestedAmount)
    {
        Vester memory vester = vest[msg.sender];
        return _getClaim(vester.amount, vester.lastClaim);
    }
    function claim()
        external
        override
        hasStarted
        returns (uint256 vestedAmount)
    {
        Vester memory vester = vest[msg.sender];
        require(
            vester.start == 0,
            "LinearVesting::claim: Incorrect Vesting Type"
        );
        vestedAmount = _getClaim(vester.amount, vester.lastClaim);
        require(vestedAmount != 0, "LinearVesting::claim: Nothing to claim");
        vester.amount -= uint192(vestedAmount);
        vester.lastClaim = uint64(block.timestamp);
        vest[msg.sender] = vester;
        emit Vested(msg.sender, vestedAmount);
        vader.safeTransfer(msg.sender, vestedAmount);
    }
    function claimConverted() external override returns (uint256 vestedAmount) {
        Vester memory vester = vest[msg.sender];
        require(
            vester.start != 0,
            "LinearVesting::claim: Incorrect Vesting Type"
        );
        require(
            vester.start < block.timestamp,
            "LinearVesting::claim: Not Started Yet"
        );
        vestedAmount = _getClaim(
            vester.amount,
            vester.lastClaim,
            vester.start,
            vester.end
        );
        require(vestedAmount != 0, "LinearVesting::claim: Nothing to claim");
        vester.amount -= uint192(vestedAmount);
        vester.lastClaim = uint64(block.timestamp);
        vest[msg.sender] = vester;
        emit Vested(msg.sender, vestedAmount);
        vader.safeTransfer(msg.sender, vestedAmount);
    }
    function begin() external override onlyOwner {
        start = block.timestamp;
        end = block.timestamp + _VESTING_DURATION;
        emit VestingInitialized(_VESTING_DURATION);
        renounceOwnership();
    }
    function vestFor(address user, uint256 amount) external override {
        require(
            vest[user].amount == 0,
            "LinearVesting::selfVest: Already a vester"
        );
        vest[user] = Vester(
            uint192(amount),
            0,
            uint128(block.timestamp),
            uint128(block.timestamp + 365 days)
        );
        vader.safeTransferFrom(msg.sender, address(this), amount);
    }
    function _getClaim(uint256 amount, uint256 lastClaim)
        private
        view
        returns (uint256)
    {
        uint256 _end = end;
        if (block.timestamp >= _end) return amount;
        if (lastClaim == 0) lastClaim = start;
        return (amount * (block.timestamp - lastClaim)) / (_end - lastClaim);
    }
    function _getClaim(
        uint256 amount,
        uint256 lastClaim,
        uint256 _start,
        uint256 _end
    ) private view returns (uint256) {
        if (block.timestamp >= _end) return amount;
        if (lastClaim == 0) lastClaim = _start;
        return (amount * (block.timestamp - lastClaim)) / (_end - lastClaim);
    }
    function _hasStarted() private view {
        require(
            start != 0,
            "LinearVesting::_hasStarted: Vesting hasn't started yet"
        );
    }
    modifier hasStarted() {
        _hasStarted();
        _;
    }
}
pragma solidity ^0.8.0;
interface AggregatorV3Interface {
  function decimals()
    external
    view
    returns (
      uint8
    );
  function description()
    external
    view
    returns (
      string memory
    );
  function version()
    external
    view
    returns (
      uint256
    );
  function getRoundData(
    uint80 _roundId
  )
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
pragma solidity =0.8.9;
contract TwapOracle is Ownable {
    using FixedPoint for *;
    struct PairData {
        address pair;
        address token0;
        address token1;
        uint256 price0CumulativeLast;
        uint256 price1CumulativeLast;
        uint32 blockTimestampLast;
        FixedPoint.uq112x112 price0Average;
        FixedPoint.uq112x112 price1Average;
    }
    address public VADER;
    address public USDV;
    bool private _usdvEnabled;
    mapping(address => address) private _aggregators;
    IVaderPoolV2 private _vaderPool;
    uint256 private _updatePeriod;
    PairData[] private _pairs;
    mapping(bytes32 => bool) private _pairExists;
    constructor(address vaderPool, uint256 updatePeriod) Ownable() {
        _vaderPool = IVaderPoolV2(vaderPool);
        _updatePeriod = updatePeriod;
    }
    modifier initialized() {
        require(
            VADER != address(0) && USDV != address(0),
            "TwapOracle::initialized: not initialized"
        );
        _;
    }
    function pairExists(address token0, address token1)
        public
        view
        returns (bool)
    {
        bytes32 pairHash0 = keccak256(abi.encodePacked(token0, token1));
        bytes32 pairHash1 = keccak256(abi.encodePacked(token1, token0));
        return _pairExists[pairHash0] || _pairExists[pairHash1];
    }
    function consult(address token) public view returns (uint256 result) {
        uint256 pairCount = _pairs.length;
        uint256 sumNative = 0;
        uint256 sumUSD = 0;
        for (uint256 i = 0; i < pairCount; i++) {
            PairData memory pairData = _pairs[i];
            if (token == pairData.token0) {
                sumNative += pairData.price1Average.mul(1).decode144(); 
                if (pairData.price1Average._x != 0) {
                    require(sumNative != 0);
                }
                (
                    uint80 roundID,
                    int256 price,
                    ,
                    ,
                    uint80 answeredInRound
                ) = AggregatorV3Interface(_aggregators[pairData.token1])
                        .latestRoundData();
                require(
                    answeredInRound >= roundID,
                    "TwapOracle::consult: stale chainlink price"
                );
                require(
                    price != 0,
                    "TwapOracle::consult: chainlink malfunction"
                );
                sumUSD += uint256(price) * (10**10);
            }
        }
        require(sumNative != 0, "TwapOracle::consult: Sum of native is zero");
        result = ((sumUSD * IERC20Metadata(token).decimals()) / sumNative);
    }
    function getRate() public view returns (uint256 result) {
        uint256 tUSDInUSDV = consult(USDV);
        uint256 tUSDInVader = consult(VADER);
        result = tUSDInUSDV / tUSDInVader;
    }
    function usdvtoVader(uint256 usdvAmount) external view returns (uint256) {
        return usdvAmount * getRate();
    }
    function vaderToUsdv(uint256 vaderAmount) external view returns (uint256) {
        if (!_usdvEnabled) {
            return consult(VADER) * vaderAmount;
        }
        return vaderAmount / getRate();
    }
    function initialize(address _usdv, address _vader) external onlyOwner {
        require(
            VADER == address(0),
            "TwapOracle::initialize: Vader already set"
        );
        require(USDV == address(0), "TwapOracle::initialize: USDV already set");
        require(
            _usdv != address(0),
            "TwapOracle::initialize: can not set to a zero address"
        );
        require(
            _vader != address(0),
            "TwapOracle::initialize: can not set to a zero address"
        );
        VADER = _vader;
        USDV = _usdv;
    }
    function enableUSDV() external onlyOwner {
        _usdvEnabled = true;
    }
    function registerAggregator(address asset, address aggregator)
        external
        onlyOwner
        initialized
    {
        require(
            asset != address(0),
            "TwapOracle::registerAggregator: asset zero address provided"
        );
        require(
            aggregator != address(0),
            "TwapOracle::registerAggregator: aggregator zero address provided"
        );
        require(
            _aggregators[asset] == address(0),
            "TwapOracle::registerAggregator: aggregator already exists"
        );
        _aggregators[asset] = aggregator;
    }
    function registerPair(
        address factory,
        address token0,
        address token1
    ) external onlyOwner initialized {
        require(
            token0 == VADER || token0 == USDV,
            "TwapOracle::registerPair: Invalid token0 address"
        );
        require(
            token0 != token1,
            "TwapOracle::registerPair: Same token address"
        );
        require(
            !pairExists(token0, token1),
            "TwapOracle::registerPair: Pair exists"
        );
        address pairAddr;
        uint256 price0CumulativeLast;
        uint256 price1CumulativeLast;
        uint112 reserve0;
        uint112 reserve1;
        uint32 blockTimestampLast;
        if (token0 == VADER) {
            IUniswapV2Pair pair = IUniswapV2Pair(
                IUniswapV2Factory(factory).getPair(token0, token1)
            );
            pairAddr = address(pair);
            price0CumulativeLast = pair.price0CumulativeLast();
            price1CumulativeLast = pair.price1CumulativeLast();
            (reserve0, reserve1, blockTimestampLast) = pair.getReserves();
        } else {
            pairAddr = address(_vaderPool);
            (price0CumulativeLast, price1CumulativeLast, ) = _vaderPool
                .cumulativePrices(IERC20(token1));
            (reserve0, reserve1, blockTimestampLast) = _vaderPool.getReserves(
                IERC20(token1)
            );
        }
        require(
            reserve0 != 0 && reserve1 != 0,
            "TwapOracle::registerPair: No reserves"
        );
        _pairExists[keccak256(abi.encodePacked(token0, token1))] = true;
        _pairs.push(
            PairData({
                pair: pairAddr,
                token0: token0,
                token1: token1,
                price0CumulativeLast: price0CumulativeLast,
                price1CumulativeLast: price1CumulativeLast,
                blockTimestampLast: blockTimestampLast,
                price0Average: FixedPoint.uq112x112({_x: 0}),
                price1Average: FixedPoint.uq112x112({_x: 0})
            })
        );
    }
    function update() external onlyOwner initialized {
        uint256 pairCount = _pairs.length;
        for (uint256 i = 0; i < pairCount; i++) {
            PairData storage pairData = _pairs[i];
            (
                uint256 price0Cumulative,
                uint256 price1Cumulative,
                uint32 blockTimestamp
            ) = (pairData.token0 == VADER)
                    ? UniswapV2OracleLibrary.currentCumulativePrices(
                        pairData.pair
                    )
                    : _vaderPool.cumulativePrices(IERC20(pairData.token1));
            unchecked {
                uint32 timeElapsed = blockTimestamp -
                    pairData.blockTimestampLast;
                require(
                    timeElapsed >= _updatePeriod,
                    "TwapOracle::update: Period not elapsed"
                );
                pairData.price0Average = FixedPoint.uq112x112(
                    uint224(
                        (price0Cumulative - pairData.price0CumulativeLast) /
                            timeElapsed
                    )
                );
                pairData.price1Average = FixedPoint.uq112x112(
                    uint224(
                        (price1Cumulative - pairData.price1CumulativeLast) /
                            timeElapsed
                    )
                );
            }
            pairData.price0CumulativeLast = price0Cumulative;
            pairData.price1CumulativeLast = price1Cumulative;
            pairData.blockTimestampLast = blockTimestamp;
        }
    }
}
pragma solidity =0.8.9;
interface IGasQueue {
}
pragma solidity >=0.4.22 <0.9.0;
contract Migrations {
    address public owner = msg.sender;
    uint256 public last_completed_migration;
    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }
    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }
}