pragma solidity 0.8.18;
abstract contract FullMath {
    function muldiv(
        uint256 a,
        uint256 b,
        uint256 denominator
    ) internal pure returns (uint256 result) {
        require(denominator > 0);
        uint256 prod0; 
        uint256 prod1; 
        assembly {
            let mm := mulmod(a, b, not(0))
            prod0 := mul(a, b)
            prod1 := sub(sub(mm, prod0), lt(mm, prod0))
        }
        if (prod1 == 0) {
            assembly {
                result := div(prod0, denominator)
            }
            return result;
        }
        require(prod1 < denominator);
        uint256 remainder;
        assembly {
            remainder := mulmod(a, b, denominator)
        }
        assembly {
            prod1 := sub(prod1, gt(remainder, prod0))
            prod0 := sub(prod0, remainder)
        }
        uint256 twos = denominator & (~denominator + 1);
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
}
abstract contract TWAML is FullMath {
    function computeMinWeight(
        uint256 _totalWeight,
        uint256 _minWeightFactor
    ) internal pure returns (uint256) {
        uint256 mul = (_totalWeight * _minWeightFactor);
        return mul >= 1e4 ? mul / 1e4 : _totalWeight;
    }
    function computeMagnitude(
        uint256 _timeWeight,
        uint256 _cumulative
    ) internal pure returns (uint256) {
        return
            sqrt(_timeWeight * _timeWeight + _cumulative * _cumulative) -
            _cumulative;
    }
    function computeTarget(
        uint256 _dMin,
        uint256 _dMax,
        uint256 _magnitude,
        uint256 _cumulative
    ) internal pure returns (uint256) {
        if (_cumulative == 0) {
            return _dMax;
        }
        uint256 target = (_magnitude * _dMax) / _cumulative;
        target = target > _dMax ? _dMax : target < _dMin ? _dMin : target;
        return target;
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
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
library ExcessivelySafeCall {
    uint256 constant LOW_28_MASK =
    0x00000000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    function excessivelySafeCall(
        address _target,
        uint256 _gas,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal returns (bool, bytes memory) {
        uint256 _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        assembly {
            _success := call(
            _gas, 
            _target, 
            0, 
            add(_calldata, 0x20), 
            mload(_calldata), 
            0, 
            0 
            )
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            mstore(_returnData, _toCopy)
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }
    function excessivelySafeStaticCall(
        address _target,
        uint256 _gas,
        uint16 _maxCopy,
        bytes memory _calldata
    ) internal view returns (bool, bytes memory) {
        uint256 _toCopy;
        bool _success;
        bytes memory _returnData = new bytes(_maxCopy);
        assembly {
            _success := staticcall(
            _gas, 
            _target, 
            add(_calldata, 0x20), 
            mload(_calldata), 
            0, 
            0 
            )
            _toCopy := returndatasize()
            if gt(_toCopy, _maxCopy) {
                _toCopy := _maxCopy
            }
            mstore(_returnData, _toCopy)
            returndatacopy(add(_returnData, 0x20), 0, _toCopy)
        }
        return (_success, _returnData);
    }
    function swapSelector(bytes4 _newSelector, bytes memory _buf)
    internal
    pure
    {
        require(_buf.length >= 4);
        uint256 _mask = LOW_28_MASK;
        assembly {
            let _word := mload(add(_buf, 0x20))
            _word := and(_word, _mask)
            _word := or(_newSelector, _word)
            mstore(add(_buf, 0x20), _word)
        }
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
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
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
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
abstract contract ERC721Permit is ERC721, EIP712 {
    using Counters for Counters.Counter;
    mapping(address => Counters.Counter) private _nonces;
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256(
            'Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)'
        );
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;
    constructor(string memory name) EIP712(name, '1') {}
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(block.timestamp <= deadline, 'ERC721Permit: expired deadline');
        address owner = ownerOf(tokenId);
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                spender,
                tokenId,
                _useNonce(owner),
                deadline
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, 'ERC721Permit: invalid signature');
        _approve(spender, tokenId);
    }
    function nonces(address owner) public view virtual returns (uint256) {
        return _nonces[owner].current();
    }
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        return _domainSeparatorV4();
    }
    function _useNonce(address owner)
        internal
        virtual
        returns (uint256 current)
    {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}
interface ISendFrom {
    struct LzCallParams {
        address payable refundAddress;
        address zroPaymentAddress;
        bytes adapterParams;
    }
    function sendFrom(
        address _from,
        uint16 _dstChainId,
        bytes32 _toAddress,
        uint256 _amount,
        LzCallParams calldata _callParams
    ) external payable;
    function useCustomAdapterParams() external view returns (bool);
}
interface ITapiocaOptionLiquidityProvision {
    struct IOptionsLockData {
        bool lock;
        address target;
        uint128 lockDuration;
        uint128 amount;
        uint256 fraction;
    }
    struct IOptionsUnlockData {
        bool unlock;
        address target;
        uint256 tokenId;
    }
    function yieldBox() external view returns (address);
    function activeSingularities(
        address singularity
    )
        external
        view
        returns (
            uint256 sglAssetId,
            uint256 totalDeposited,
            uint256 poolWeight
        );
    function lock(
        address to,
        address singularity,
        uint128 lockDuration,
        uint128 amount
    ) external returns (uint256 tokenId);
    function unlock(
        uint256 tokenId,
        address singularity,
        address to
    ) external returns (uint256 sharesOut);
}
interface IMarket {
    function asset() external view returns (address);
    function assetId() external view returns (uint256);
    function collateral() external view returns (address);
    function collateralId() external view returns (uint256);
    function totalBorrowCap() external view returns (uint256);
    function totalCollateralShare() external view returns (uint256);
    function userBorrowPart(address) external view returns (uint256);
    function userCollateralShare(address) external view returns (uint256);
    function totalBorrow()
        external
        view
        returns (uint128 elastic, uint128 base);
    function oracle() external view returns (address);
    function oracleData() external view returns (bytes memory);
    function exchangeRate() external view returns (uint256);
    function yieldBox() external view returns (address payable);
    function liquidationMultiplier() external view returns (uint256);
    function addCollateral(
        address from,
        address to,
        bool skim,
        uint256 amount,
        uint256 share
    ) external;
    function removeCollateral(address from, address to, uint256 share) external;
    function addAsset(
        address from,
        address to,
        bool skim,
        uint256 share
    ) external returns (uint256 fraction);
    function repay(
        address from,
        address to,
        bool skim,
        uint256 part
    ) external returns (uint256 amount);
    function borrow(
        address from,
        address to,
        uint256 amount
    ) external returns (uint256 part, uint256 share);
    function execute(
        bytes[] calldata calls,
        bool revertOnFail
    ) external returns (bool[] memory successes, string[] memory results);
    function refreshPenroseFees(
        address feeTo
    ) external returns (uint256 feeShares);
    function penrose() external view returns (address);
    function owner() external view returns (address);
    function buyCollateral(
        address from,
        uint256 borrowAmount,
        uint256 supplyAmount,
        uint256 minAmountOut,
        address swapper,
        bytes calldata dexData
    ) external returns (uint256 amountOut);
    function sellCollateral(
        address from,
        uint256 share,
        uint256 minAmountOut,
        address swapper,
        bytes calldata dexData
    ) external returns (uint256 amountOut);
}
interface IUSDOBase {
    struct ILeverageExternalContractsData {
        address swapper;
        address magnetar;
        address tOft;
        address srcMarket;
    }
    struct IRemoveAndRepay {
        bool removeAssetFromSGL;
        uint256 removeShare; 
        bool repayAssetOnBB;
        uint256 repayAmount; 
        bool removeCollateralFromBB;
        uint256 collateralShare; 
        ITapiocaOptionsBroker.IOptionsExitData exitData;
        ITapiocaOptionLiquidityProvision.IOptionsUnlockData unlockData;
        ICommonData.IWithdrawParams assetWithdrawData;
        ICommonData.IWithdrawParams collateralWithdrawData;
    }
    struct ILendOrRepayParams {
        bool repay;
        uint256 depositAmount;
        uint256 repayAmount;
        address marketHelper;
        address market;
        bool removeCollateral;
        uint256 removeCollateralShare;
        ITapiocaOptionLiquidityProvision.IOptionsLockData lockData;
        ITapiocaOptionsBroker.IOptionsParticipateData participateData;
    }
    struct ILeverageLZData {
        uint256 srcExtraGasLimit;
        uint16 lzSrcChainId;
        uint16 lzDstChainId;
        address zroPaymentAddress;
        bytes dstAirdropAdapterParam;
        bytes srcAirdropAdapterParam;
        address refundAddress;
    }
    struct ILeverageSwapData {
        address tokenOut;
        uint256 amountOutMin;
        bytes data;
    }
    struct IMintData {
        bool mint;
        uint256 mintAmount;
        ICommonData.IDepositData collateralDepositData;
    }
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
    function sendAndLendOrRepay(
        address _from,
        address _to,
        uint16 lzDstChainId,
        address zroPaymentAddress,
        ILendOrRepayParams calldata lendParams,
        ICommonData.IApproval[] calldata approvals,
        ICommonData.IWithdrawParams calldata withdrawParams, 
        bytes calldata adapterParams
    ) external payable;
    function sendForLeverage(
        uint256 amount,
        address leverageFor,
        ILeverageLZData calldata lzData,
        ILeverageSwapData calldata swapData,
        ILeverageExternalContractsData calldata externalData
    ) external payable;
    function initMultiHopBuy(
        address from,
        uint256 collateralAmount,
        uint256 borrowAmount,
        IUSDOBase.ILeverageSwapData calldata swapData,
        IUSDOBase.ILeverageLZData calldata lzData,
        IUSDOBase.ILeverageExternalContractsData calldata externalData,
        bytes calldata airdropAdapterParams,
        ICommonData.IApproval[] memory approvals
    ) external payable;
    function removeAsset(
        address from,
        address to,
        uint16 lzDstChainId,
        address zroPaymentAddress,
        bytes calldata adapterParams,
        ICommonData.ICommonExternalContracts calldata externalData,
        IUSDOBase.IRemoveAndRepay calldata removeAndRepayData,
        ICommonData.IApproval[] calldata approvals
    ) external payable;
}
interface ISingularity is IMarket {
    struct AccrueInfo {
        uint64 interestPerSecond;
        uint64 lastAccrued;
        uint128 feesEarnedFraction;
    }
    function accrueInfo()
        external
        view
        returns (
            uint64 interestPerSecond,
            uint64 lastBlockAccrued,
            uint128 feesEarnedFraction
        );
    function totalAsset() external view returns (uint128 elastic, uint128 base);
    function removeAsset(
        address from,
        address to,
        uint256 fraction
    ) external returns (uint256 share);
    function name() external view returns (string memory);
    function nonces(address) external view returns (uint256);
    function permit(
        address owner_,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function allowance(address, address) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address) external view returns (uint256);
    function liquidationQueue() external view returns (address payable);
    function computeAllowedLendShare(
        uint256 amount,
        uint256 tokenId
    ) external view returns (uint256 share);
    function getInterestDetails()
        external
        view
        returns (AccrueInfo memory _accrueInfo, uint256 utilization);
    function multiHopBuyCollateral(
        address from,
        uint256 collateralAmount,
        uint256 borrowAmount,
        IUSDOBase.ILeverageSwapData calldata swapData,
        IUSDOBase.ILeverageLZData calldata lzData,
        IUSDOBase.ILeverageExternalContractsData calldata externalData
    ) external payable;
    function multiHopSellCollateral(
        address from,
        uint256 share,
        IUSDOBase.ILeverageSwapData calldata swapData,
        IUSDOBase.ILeverageLZData calldata lzData,
        IUSDOBase.ILeverageExternalContractsData calldata externalData
    ) external payable;
}
interface ICommonOFT is IERC165 {
    struct LzCallParams {
        address payable refundAddress;
        address zroPaymentAddress;
        bytes adapterParams;
    }
    function estimateSendFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);
    function estimateSendAndCallFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);
    function circulatingSupply() external view returns (uint);
    function token() external view returns (address);
}
interface ICommonData {
    struct IWithdrawParams {
        bool withdraw;
        uint256 withdrawLzFeeAmount;
        bool withdrawOnOtherChain;
        uint16 withdrawLzChainId;
        bytes withdrawAdapterParams;
    }
    struct ISendOptions {
        uint256 extraGasLimit;
        address zroPaymentAddress;
    }
    struct IApproval {
        bool permitAll;
        bool allowFailure;
        address target;
        bool permitBorrow;
        address owner;
        address spender;
        uint256 value;
        uint256 deadline;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    struct ICommonExternalContracts {
        address magnetar;
        address singularity;
        address bigBang;
    }
    struct IDepositData {
        bool deposit;
        uint256 amount;
        bool extractFromSender;
    }
}
interface ITapiocaOptionsBrokerCrossChain {
    struct IExerciseOptionsData {
        address from;
        address target;
        uint256 paymentTokenAmount;
        uint256 oTAPTokenID;
        address paymentToken;
        uint256 tapAmount;
    }
    struct IExerciseLZData {
        uint16 lzDstChainId;
        address zroPaymentAddress;
        uint256 extraGas;
    }
    struct IExerciseLZSendTapData {
        bool withdrawOnAnotherChain;
        address tapOftAddress;
        uint16 lzDstChainId;
        uint256 amount;
        address zroPaymentAddress;
        uint256 extraGas;
    }
    function exerciseOption(
        IExerciseOptionsData calldata optionsData,
        IExerciseLZData calldata lzData,
        IExerciseLZSendTapData calldata tapSendData,
        ICommonData.IApproval[] calldata approvals
    ) external payable;
}
interface ITapiocaOptionsBroker {
    struct IOptionsParticipateData {
        bool participate;
        address target;
        uint256 tOLPTokenId;
    }
    struct IOptionsExitData {
        bool exit;
        address target;
        uint256 oTAPTokenID;
    }
    function oTAP() external view returns (address);
    function exerciseOption(
        uint256 oTAPTokenID,
        address paymentToken,
        uint256 tapAmount
    ) external;
    function participate(
        uint256 tOLPTokenID
    ) external returns (uint256 oTAPTokenID);
    function exitPosition(uint256 oTAPTokenID) external;
}
interface ITapiocaOFTBase {
    function hostChainID() external view returns (uint256);
    function wrap(
        address fromAddress,
        address toAddress,
        uint256 amount
    ) external;
    function wrapNative(address _toAddress) external payable;
    function unwrap(address _toAddress, uint256 _amount) external;
    function erc20() external view returns (address);
    function lzEndpoint() external view returns (address);
}
interface ITapiocaOFT is ISendFrom, ITapiocaOFTBase {
    struct IRemoveParams {
        uint256 share;
        address marketHelper;
        address market;
    }
    struct IBorrowParams {
        uint256 amount;
        uint256 borrowAmount;
        address marketHelper;
        address market;
    }
    function totalFees() external view returns (uint256);
    function erc20() external view returns (address);
    function wrappedAmount(uint256 _amount) external view returns (uint256);
    function isHostChain() external view returns (bool);
    function balanceOf(address _holder) external view returns (uint256);
    function isTrustedRemote(
        uint16 lzChainId,
        bytes calldata path
    ) external view returns (bool);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function extractUnderlying(uint256 _amount) external;
    function harvestFees() external;
    function sendToYBAndBorrow(
        address _from,
        address _to,
        uint16 lzDstChainId,
        bytes calldata airdropAdapterParams,
        IBorrowParams calldata borrowParams,
        ICommonData.IWithdrawParams calldata withdrawParams,
        ICommonData.ISendOptions calldata options,
        ICommonData.IApproval[] calldata approvals
    ) external payable;
    function sendToStrategy(
        address _from,
        address _to,
        uint256 amount,
        uint256 share,
        uint256 assetId,
        uint16 lzDstChainId,
        ICommonData.ISendOptions calldata options
    ) external payable;
    function retrieveFromStrategy(
        address _from,
        uint256 amount,
        uint256 share,
        uint256 assetId,
        uint16 lzDstChainId,
        address zroPaymentAddress,
        bytes memory airdropAdapterParam
    ) external payable;
    function sendForLeverage(
        uint256 amount,
        address leverageFor,
        IUSDOBase.ILeverageLZData calldata lzData,
        IUSDOBase.ILeverageSwapData calldata swapData,
        IUSDOBase.ILeverageExternalContractsData calldata externalData
    ) external payable;
    function removeCollateral(
        address from,
        address to,
        uint16 lzDstChainId,
        address zroPaymentAddress,
        ICommonData.IWithdrawParams calldata withdrawParams,
        ITapiocaOFT.IRemoveParams calldata removeParams,
        ICommonData.IApproval[] calldata approvals,
        bytes calldata adapterParams
    ) external payable;
    function initMultiSell(
        address from,
        uint256 share,
        IUSDOBase.ILeverageSwapData calldata swapData,
        IUSDOBase.ILeverageLZData calldata lzData,
        IUSDOBase.ILeverageExternalContractsData calldata externalData,
        bytes calldata airdropAdapterParams,
        ICommonData.IApproval[] calldata approvals
    ) external payable;
}
pragma experimental ABIEncoderV2;
library LzLib {
    struct CallParams {
        address payable refundAddress;
        address zroPaymentAddress;
    }
    struct AirdropParams {
        uint airdropAmount;
        bytes32 airdropAddress;
    }
    function buildAdapterParams(LzLib.AirdropParams memory _airdropParams, uint _uaGasLimit) internal pure returns (bytes memory adapterParams) {
        if (_airdropParams.airdropAmount == 0 && _airdropParams.airdropAddress == bytes32(0x0)) {
            adapterParams = buildDefaultAdapterParams(_uaGasLimit);
        } else {
            adapterParams = buildAirdropAdapterParams(_uaGasLimit, _airdropParams);
        }
    }
    function buildDefaultAdapterParams(uint _uaGas) internal pure returns (bytes memory) {
        return abi.encodePacked(uint16(1), _uaGas);
    }
    function buildAirdropAdapterParams(uint _uaGas, AirdropParams memory _params) internal pure returns (bytes memory) {
        require(_params.airdropAmount > 0, "Airdrop amount must be greater than 0");
        require(_params.airdropAddress != bytes32(0x0), "Airdrop address must be set");
        return abi.encodePacked(uint16(2), _uaGas, _params.airdropAmount, _params.airdropAddress);
    }
    function getGasLimit(bytes memory _adapterParams) internal pure returns (uint gasLimit) {
        require(_adapterParams.length == 34 || _adapterParams.length > 66, "Invalid adapterParams");
        assembly {
            gasLimit := mload(add(_adapterParams, 34))
        }
    }
    function decodeAdapterParams(bytes memory _adapterParams) internal pure returns (uint16 txType, uint uaGas, uint airdropAmount, address payable airdropAddress) {
        require(_adapterParams.length == 34 || _adapterParams.length > 66, "Invalid adapterParams");
        assembly {
            txType := mload(add(_adapterParams, 2))
            uaGas := mload(add(_adapterParams, 34))
        }
        require(txType == 1 || txType == 2, "Unsupported txType");
        require(uaGas > 0, "Gas too low");
        if (txType == 2) {
            assembly {
                airdropAmount := mload(add(_adapterParams, 66))
                airdropAddress := mload(add(_adapterParams, 86))
            }
        }
    }
    function bytes32ToAddress(bytes32 _bytes32Address) internal pure returns (address _address) {
        return address(uint160(uint(_bytes32Address)));
    }
    function addressToBytes32(address _address) internal pure returns (bytes32 _bytes32Address) {
        return bytes32(uint(uint160(_address)));
    }
}
interface ILayerZeroReceiver {
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
}
interface ILayerZeroUserApplicationConfig {
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external;
    function setSendVersion(uint16 _version) external;
    function setReceiveVersion(uint16 _version) external;
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}
interface ILayerZeroEndpoint is ILayerZeroUserApplicationConfig {
    function send(uint16 _dstChainId, bytes calldata _destination, bytes calldata _payload, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;
    function receivePayload(uint16 _srcChainId, bytes calldata _srcAddress, address _dstAddress, uint64 _nonce, uint _gasLimit, bytes calldata _payload) external;
    function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);
    function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);
    function estimateFees(uint16 _dstChainId, address _userApplication, bytes calldata _payload, bool _payInZRO, bytes calldata _adapterParam) external view returns (uint nativeFee, uint zroFee);
    function getChainId() external view returns (uint16);
    function retryPayload(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external;
    function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);
    function getSendLibraryAddress(address _userApplication) external view returns (address);
    function getReceiveLibraryAddress(address _userApplication) external view returns (address);
    function isSendingPayload() external view returns (bool);
    function isReceivingPayload() external view returns (bool);
    function getConfig(uint16 _version, uint16 _chainId, address _userApplication, uint _configType) external view returns (bytes memory);
    function getSendVersion(address _userApplication) external view returns (uint16);
    function getReceiveVersion(address _userApplication) external view returns (uint16);
}
library BytesLib {
    function concat(
        bytes memory _preBytes,
        bytes memory _postBytes
    )
    internal
    pure
    returns (bytes memory)
    {
        bytes memory tempBytes;
        assembly {
            tempBytes := mload(0x40)
            let length := mload(_preBytes)
            mstore(tempBytes, length)
            let mc := add(tempBytes, 0x20)
            let end := add(mc, length)
            for {
                let cc := add(_preBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }
            length := mload(_postBytes)
            mstore(tempBytes, add(length, mload(tempBytes)))
            mc := end
            end := add(mc, length)
            for {
                let cc := add(_postBytes, 0x20)
            } lt(mc, end) {
                mc := add(mc, 0x20)
                cc := add(cc, 0x20)
            } {
                mstore(mc, mload(cc))
            }
            mstore(0x40, and(
            add(add(end, iszero(add(length, mload(_preBytes)))), 31),
            not(31) 
            ))
        }
        return tempBytes;
    }
    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        assembly {
            let fslot := sload(_preBytes.slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            let newlength := add(slength, mlength)
            switch add(lt(slength, 32), lt(newlength, 32))
            case 2 {
                sstore(
                _preBytes.slot,
                add(
                fslot,
                add(
                mul(
                div(
                mload(add(_postBytes, 0x20)),
                exp(0x100, sub(32, mlength))
                ),
                exp(0x100, sub(32, newlength))
                ),
                mul(mlength, 2)
                )
                )
                )
            }
            case 1 {
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))
                let submod := sub(32, slength)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)
                sstore(
                sc,
                add(
                and(
                fslot,
                0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00
                ),
                and(mload(mc), mask)
                )
                )
                for {
                    mc := add(mc, 0x20)
                    sc := add(sc, 1)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }
                mask := exp(0x100, sub(mc, end))
                sstore(sc, mul(div(mload(mc), mask), mask))
            }
            default {
                mstore(0x0, _preBytes.slot)
                let sc := add(keccak256(0x0, 0x20), div(slength, 32))
                sstore(_preBytes.slot, add(mul(newlength, 2), 1))
                let slengthmod := mod(slength, 32)
                let mlengthmod := mod(mlength, 32)
                let submod := sub(32, slengthmod)
                let mc := add(_postBytes, submod)
                let end := add(_postBytes, mlength)
                let mask := sub(exp(0x100, submod), 1)
                sstore(sc, add(sload(sc), and(mload(mc), mask)))
                for {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } lt(mc, end) {
                    sc := add(sc, 1)
                    mc := add(mc, 0x20)
                } {
                    sstore(sc, mload(mc))
                }
                mask := exp(0x100, sub(mc, end))
                sstore(sc, mul(div(mload(mc), mask), mask))
            }
        }
    }
    function slice(
        bytes memory _bytes,
        uint256 _start,
        uint256 _length
    )
    internal
    pure
    returns (bytes memory)
    {
        require(_length + 31 >= _length, "slice_overflow");
        require(_bytes.length >= _start + _length, "slice_outOfBounds");
        bytes memory tempBytes;
        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)
                let lengthmod := and(_length, 31)
                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)
                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }
                mstore(tempBytes, _length)
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)
                mstore(tempBytes, 0)
                mstore(0x40, add(tempBytes, 0x20))
            }
        }
        return tempBytes;
    }
    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;
        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }
        return tempAddress;
    }
    function toUint8(bytes memory _bytes, uint256 _start) internal pure returns (uint8) {
        require(_bytes.length >= _start + 1 , "toUint8_outOfBounds");
        uint8 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }
        return tempUint;
    }
    function toUint16(bytes memory _bytes, uint256 _start) internal pure returns (uint16) {
        require(_bytes.length >= _start + 2, "toUint16_outOfBounds");
        uint16 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x2), _start))
        }
        return tempUint;
    }
    function toUint32(bytes memory _bytes, uint256 _start) internal pure returns (uint32) {
        require(_bytes.length >= _start + 4, "toUint32_outOfBounds");
        uint32 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x4), _start))
        }
        return tempUint;
    }
    function toUint64(bytes memory _bytes, uint256 _start) internal pure returns (uint64) {
        require(_bytes.length >= _start + 8, "toUint64_outOfBounds");
        uint64 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x8), _start))
        }
        return tempUint;
    }
    function toUint96(bytes memory _bytes, uint256 _start) internal pure returns (uint96) {
        require(_bytes.length >= _start + 12, "toUint96_outOfBounds");
        uint96 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0xc), _start))
        }
        return tempUint;
    }
    function toUint128(bytes memory _bytes, uint256 _start) internal pure returns (uint128) {
        require(_bytes.length >= _start + 16, "toUint128_outOfBounds");
        uint128 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x10), _start))
        }
        return tempUint;
    }
    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        require(_bytes.length >= _start + 32, "toUint256_outOfBounds");
        uint256 tempUint;
        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }
    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        require(_bytes.length >= _start + 32, "toBytes32_outOfBounds");
        bytes32 tempBytes32;
        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }
        return tempBytes32;
    }
    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        bool success = true;
        assembly {
            let length := mload(_preBytes)
            switch eq(length, mload(_postBytes))
            case 1 {
                let cb := 1
                let mc := add(_preBytes, 0x20)
                let end := add(mc, length)
                for {
                    let cc := add(_postBytes, 0x20)
                } eq(add(lt(mc, end), cb), 2) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    if iszero(eq(mload(mc), mload(cc))) {
                        success := 0
                        cb := 0
                    }
                }
            }
            default {
                success := 0
            }
        }
        return success;
    }
    function equalStorage(
        bytes storage _preBytes,
        bytes memory _postBytes
    )
    internal
    view
    returns (bool)
    {
        bool success = true;
        assembly {
            let fslot := sload(_preBytes.slot)
            let slength := div(and(fslot, sub(mul(0x100, iszero(and(fslot, 1))), 1)), 2)
            let mlength := mload(_postBytes)
            switch eq(slength, mlength)
            case 1 {
                if iszero(iszero(slength)) {
                    switch lt(slength, 32)
                    case 1 {
                        fslot := mul(div(fslot, 0x100), 0x100)
                        if iszero(eq(fslot, mload(add(_postBytes, 0x20)))) {
                            success := 0
                        }
                    }
                    default {
                        let cb := 1
                        mstore(0x0, _preBytes.slot)
                        let sc := keccak256(0x0, 0x20)
                        let mc := add(_postBytes, 0x20)
                        let end := add(mc, mlength)
                        for {} eq(add(lt(mc, end), cb), 2) {
                            sc := add(sc, 1)
                            mc := add(mc, 0x20)
                        } {
                            if iszero(eq(sload(sc), mload(mc))) {
                                success := 0
                                cb := 0
                            }
                        }
                    }
                }
            }
            default {
                success := 0
            }
        }
        return success;
    }
}
abstract contract LzApp is Ownable, ILayerZeroReceiver, ILayerZeroUserApplicationConfig {
    using BytesLib for bytes;
    uint constant public DEFAULT_PAYLOAD_SIZE_LIMIT = 10000;
    ILayerZeroEndpoint public immutable lzEndpoint;
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(uint16 => mapping(uint16 => uint)) public minDstGasLookup;
    mapping(uint16 => uint) public payloadSizeLimitLookup;
    address public precrime;
    event SetPrecrime(address precrime);
    event SetTrustedRemote(uint16 _remoteChainId, bytes _path);
    event SetTrustedRemoteAddress(uint16 _remoteChainId, bytes _remoteAddress);
    event SetMinDstGas(uint16 _dstChainId, uint16 _type, uint _minDstGas);
    constructor(address _endpoint) {
        lzEndpoint = ILayerZeroEndpoint(_endpoint);
    }
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) public virtual override {
        require(_msgSender() == address(lzEndpoint), "LzApp: invalid endpoint caller");
        bytes memory trustedRemote = trustedRemoteLookup[_srcChainId];
        require(_srcAddress.length == trustedRemote.length && trustedRemote.length > 0 && keccak256(_srcAddress) == keccak256(trustedRemote), "LzApp: invalid source sending contract");
        _blockingLzReceive(_srcChainId, _srcAddress, _nonce, _payload);
    }
    function _blockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal virtual;
    function _lzSend(uint16 _dstChainId, bytes memory _payload, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams, uint _nativeFee) internal virtual {
        bytes memory trustedRemote = trustedRemoteLookup[_dstChainId];
        require(trustedRemote.length != 0, "LzApp: destination chain is not a trusted source");
        _checkPayloadSize(_dstChainId, _payload.length);
        lzEndpoint.send{value: _nativeFee}(_dstChainId, trustedRemote, _payload, _refundAddress, _zroPaymentAddress, _adapterParams);
    }
    function _checkGasLimit(uint16 _dstChainId, uint16 _type, bytes memory _adapterParams, uint _extraGas) internal view virtual {
        uint providedGasLimit = _getGasLimit(_adapterParams);
        uint minGasLimit = minDstGasLookup[_dstChainId][_type] + _extraGas;
        require(minGasLimit > 0, "LzApp: minGasLimit not set");
        require(providedGasLimit >= minGasLimit, "LzApp: gas limit is too low");
    }
    function _getGasLimit(bytes memory _adapterParams) internal pure virtual returns (uint gasLimit) {
        require(_adapterParams.length >= 34, "LzApp: invalid adapterParams");
        assembly {
            gasLimit := mload(add(_adapterParams, 34))
        }
    }
    function _checkPayloadSize(uint16 _dstChainId, uint _payloadSize) internal view virtual {
        uint payloadSizeLimit = payloadSizeLimitLookup[_dstChainId];
        if (payloadSizeLimit == 0) { 
            payloadSizeLimit = DEFAULT_PAYLOAD_SIZE_LIMIT;
        }
        require(_payloadSize <= payloadSizeLimit, "LzApp: payload size is too large");
    }
    function getConfig(uint16 _version, uint16 _chainId, address, uint _configType) external view returns (bytes memory) {
        return lzEndpoint.getConfig(_version, _chainId, address(this), _configType);
    }
    function setConfig(uint16 _version, uint16 _chainId, uint _configType, bytes calldata _config) external override onlyOwner {
        lzEndpoint.setConfig(_version, _chainId, _configType, _config);
    }
    function setSendVersion(uint16 _version) external override onlyOwner {
        lzEndpoint.setSendVersion(_version);
    }
    function setReceiveVersion(uint16 _version) external override onlyOwner {
        lzEndpoint.setReceiveVersion(_version);
    }
    function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external override onlyOwner {
        lzEndpoint.forceResumeReceive(_srcChainId, _srcAddress);
    }
    function setTrustedRemote(uint16 _srcChainId, bytes calldata _path) external onlyOwner {
        trustedRemoteLookup[_srcChainId] = _path;
        emit SetTrustedRemote(_srcChainId, _path);
    }
    function setTrustedRemoteAddress(uint16 _remoteChainId, bytes calldata _remoteAddress) external onlyOwner {
        trustedRemoteLookup[_remoteChainId] = abi.encodePacked(_remoteAddress, address(this));
        emit SetTrustedRemoteAddress(_remoteChainId, _remoteAddress);
    }
    function getTrustedRemoteAddress(uint16 _remoteChainId) external view returns (bytes memory) {
        bytes memory path = trustedRemoteLookup[_remoteChainId];
        require(path.length != 0, "LzApp: no trusted path record");
        return path.slice(0, path.length - 20); 
    }
    function setPrecrime(address _precrime) external onlyOwner {
        precrime = _precrime;
        emit SetPrecrime(_precrime);
    }
    function setMinDstGas(uint16 _dstChainId, uint16 _packetType, uint _minGas) external onlyOwner {
        require(_minGas > 0, "LzApp: invalid minGas");
        minDstGasLookup[_dstChainId][_packetType] = _minGas;
        emit SetMinDstGas(_dstChainId, _packetType, _minGas);
    }
    function setPayloadSizeLimit(uint16 _dstChainId, uint _size) external onlyOwner {
        payloadSizeLimitLookup[_dstChainId] = _size;
    }
    function isTrustedRemote(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool) {
        bytes memory trustedSource = trustedRemoteLookup[_srcChainId];
        return keccak256(trustedSource) == keccak256(_srcAddress);
    }
}
abstract contract NonblockingLzApp is LzApp {
    using ExcessivelySafeCall for address;
    constructor(address _endpoint) LzApp(_endpoint) {}
    mapping(uint16 => mapping(bytes => mapping(uint64 => bytes32))) public failedMessages;
    event MessageFailed(uint16 _srcChainId, bytes _srcAddress, uint64 _nonce, bytes _payload, bytes _reason);
    event RetryMessageSuccess(uint16 _srcChainId, bytes _srcAddress, uint64 _nonce, bytes32 _payloadHash);
    function _blockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal virtual override {
        (bool success, bytes memory reason) = address(this).excessivelySafeCall(gasleft(), 150, abi.encodeWithSelector(this.nonblockingLzReceive.selector, _srcChainId, _srcAddress, _nonce, _payload));
        if (!success) {
            _storeFailedMessage(_srcChainId, _srcAddress, _nonce, _payload, reason);
        }
    }
    function _storeFailedMessage(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload, bytes memory _reason) internal virtual {
        failedMessages[_srcChainId][_srcAddress][_nonce] = keccak256(_payload);
        emit MessageFailed(_srcChainId, _srcAddress, _nonce, _payload, _reason);
    }
    function nonblockingLzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) public virtual {
        require(_msgSender() == address(this), "NonblockingLzApp: caller must be LzApp");
        _nonblockingLzReceive(_srcChainId, _srcAddress, _nonce, _payload);
    }
    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal virtual;
    function retryMessage(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) public payable virtual {
        bytes32 payloadHash = failedMessages[_srcChainId][_srcAddress][_nonce];
        require(payloadHash != bytes32(0), "NonblockingLzApp: no stored message");
        require(keccak256(_payload) == payloadHash, "NonblockingLzApp: invalid payload");
        failedMessages[_srcChainId][_srcAddress][_nonce] = bytes32(0);
        _nonblockingLzReceive(_srcChainId, _srcAddress, _nonce, _payload);
        emit RetryMessageSuccess(_srcChainId, _srcAddress, _nonce, payloadHash);
    }
}
interface IOFTV2 is ICommonOFT {
    function sendFrom(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, LzCallParams calldata _callParams) external payable;
    function sendAndCall(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, LzCallParams calldata _callParams) external payable;
}
interface IOFTReceiverV2 {
    function onOFTReceived(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes32 _from, uint _amount, bytes calldata _payload) external;
}
abstract contract OFTCoreV2 is NonblockingLzApp {
    using BytesLib for bytes;
    using ExcessivelySafeCall for address;
    uint public constant NO_EXTRA_GAS = 0;
    uint8 public constant PT_SEND = 0;
    uint8 public constant PT_SEND_AND_CALL = 1;
    uint8 public immutable sharedDecimals;
    bool public useCustomAdapterParams;
    mapping(uint16 => mapping(bytes => mapping(uint64 => bool))) public creditedPackets;
    event SendToChain(uint16 indexed _dstChainId, address indexed _from, bytes32 indexed _toAddress, uint _amount);
    event ReceiveFromChain(uint16 indexed _srcChainId, address indexed _to, uint _amount);
    event SetUseCustomAdapterParams(bool _useCustomAdapterParams);
    event CallOFTReceivedSuccess(uint16 indexed _srcChainId, bytes _srcAddress, uint64 _nonce, bytes32 _hash);
    event NonContractAddress(address _address);
    constructor(uint8 _sharedDecimals, address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        sharedDecimals = _sharedDecimals;
    }
    function callOnOFTReceived(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes32 _from, address _to, uint _amount, bytes calldata _payload, uint _gasForCall) public virtual {
        require(_msgSender() == address(this), "OFTCore: caller must be OFTCore");
        _amount = _transferFrom(address(this), _to, _amount);
        emit ReceiveFromChain(_srcChainId, _to, _amount);
        IOFTReceiverV2(_to).onOFTReceived{gas: _gasForCall}(_srcChainId, _srcAddress, _nonce, _from, _amount, _payload);
    }
    function setUseCustomAdapterParams(bool _useCustomAdapterParams) public virtual onlyOwner {
        useCustomAdapterParams = _useCustomAdapterParams;
        emit SetUseCustomAdapterParams(_useCustomAdapterParams);
    }
    function _estimateSendFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bool _useZro, bytes memory _adapterParams) internal view virtual returns (uint nativeFee, uint zroFee) {
        bytes memory payload = _encodeSendPayload(_toAddress, _ld2sd(_amount));
        return lzEndpoint.estimateFees(_dstChainId, address(this), payload, _useZro, _adapterParams);
    }
    function _estimateSendAndCallFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes memory _payload, uint64 _dstGasForCall, bool _useZro, bytes memory _adapterParams) internal view virtual returns (uint nativeFee, uint zroFee) {
        bytes memory payload = _encodeSendAndCallPayload(msg.sender, _toAddress, _ld2sd(_amount), _payload, _dstGasForCall);
        return lzEndpoint.estimateFees(_dstChainId, address(this), payload, _useZro, _adapterParams);
    }
    function _nonblockingLzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal virtual override {
        uint8 packetType = _payload.toUint8(0);
        if (packetType == PT_SEND) {
            _sendAck(_srcChainId, _srcAddress, _nonce, _payload);
        } else if (packetType == PT_SEND_AND_CALL) {
            _sendAndCallAck(_srcChainId, _srcAddress, _nonce, _payload);
        } else {
            revert("OFTCore: unknown packet type");
        }
    }
    function _send(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams) internal virtual returns (uint amount) {
        _checkAdapterParams(_dstChainId, PT_SEND, _adapterParams, NO_EXTRA_GAS);
        (amount,) = _removeDust(_amount);
        amount = _debitFrom(_from, _dstChainId, _toAddress, amount); 
        require(amount > 0, "OFTCore: amount too small");
        bytes memory lzPayload = _encodeSendPayload(_toAddress, _ld2sd(amount));
        _lzSend(_dstChainId, lzPayload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
        emit SendToChain(_dstChainId, _from, _toAddress, amount);
    }
    function _sendAck(uint16 _srcChainId, bytes memory, uint64, bytes memory _payload) internal virtual {
        (address to, uint64 amountSD) = _decodeSendPayload(_payload);
        if (to == address(0)) {
            to = address(0xdead);
        }
        uint amount = _sd2ld(amountSD);
        amount = _creditTo(_srcChainId, to, amount);
        emit ReceiveFromChain(_srcChainId, to, amount);
    }
    function _sendAndCall(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes memory _payload, uint64 _dstGasForCall, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams) internal virtual returns (uint amount) {
        _checkAdapterParams(_dstChainId, PT_SEND_AND_CALL, _adapterParams, _dstGasForCall);
        (amount,) = _removeDust(_amount);
        amount = _debitFrom(_from, _dstChainId, _toAddress, amount);
        require(amount > 0, "OFTCore: amount too small");
        bytes memory lzPayload = _encodeSendAndCallPayload(msg.sender, _toAddress, _ld2sd(amount), _payload, _dstGasForCall);
        _lzSend(_dstChainId, lzPayload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
        emit SendToChain(_dstChainId, _from, _toAddress, amount);
    }
    function _sendAndCallAck(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload) internal virtual {
        (bytes32 from, address to, uint64 amountSD, bytes memory payloadForCall, uint64 gasForCall) = _decodeSendAndCallPayload(_payload);
        bool credited = creditedPackets[_srcChainId][_srcAddress][_nonce];
        uint amount = _sd2ld(amountSD);
        if (!credited) {
            amount = _creditTo(_srcChainId, address(this), amount);
            creditedPackets[_srcChainId][_srcAddress][_nonce] = true;
        }
        if (!_isContract(to)) {
            emit NonContractAddress(to);
            return;
        }
        uint16 srcChainId = _srcChainId;
        bytes memory srcAddress = _srcAddress;
        uint64 nonce = _nonce;
        bytes memory payload = _payload;
        bytes32 from_ = from;
        address to_ = to;
        uint amount_ = amount;
        bytes memory payloadForCall_ = payloadForCall;
        uint gas = credited ? gasleft() : gasForCall;
        (bool success, bytes memory reason) = address(this).excessivelySafeCall(gasleft(), 150, abi.encodeWithSelector(this.callOnOFTReceived.selector, srcChainId, srcAddress, nonce, from_, to_, amount_, payloadForCall_, gas));
        if (success) {
            bytes32 hash = keccak256(payload);
            emit CallOFTReceivedSuccess(srcChainId, srcAddress, nonce, hash);
        } else {
            _storeFailedMessage(srcChainId, srcAddress, nonce, payload, reason);
        }
    }
    function _isContract(address _account) internal view returns (bool) {
        return _account.code.length > 0;
    }
    function _checkAdapterParams(uint16 _dstChainId, uint16 _pkType, bytes memory _adapterParams, uint _extraGas) internal virtual {
        if (useCustomAdapterParams) {
            _checkGasLimit(_dstChainId, _pkType, _adapterParams, _extraGas);
        } else {
            require(_adapterParams.length == 0, "OFTCore: _adapterParams must be empty.");
        }
    }
    function _ld2sd(uint _amount) internal virtual view returns (uint64) {
        uint amountSD = _amount / _ld2sdRate();
        require(amountSD <= type(uint64).max, "OFTCore: amountSD overflow");
        return uint64(amountSD);
    }
    function _sd2ld(uint64 _amountSD) internal virtual view returns (uint) {
        return _amountSD * _ld2sdRate();
    }
    function _removeDust(uint _amount) internal virtual view returns (uint amountAfter, uint dust) {
        dust = _amount % _ld2sdRate();
        amountAfter = _amount - dust;
    }
    function _encodeSendPayload(bytes32 _toAddress, uint64 _amountSD) internal virtual view returns (bytes memory) {
        return abi.encodePacked(PT_SEND, _toAddress, _amountSD);
    }
    function _decodeSendPayload(bytes memory _payload) internal virtual view returns (address to, uint64 amountSD) {
        require(_payload.toUint8(0) == PT_SEND && _payload.length == 41, "OFTCore: invalid payload");
        to = _payload.toAddress(13); 
        amountSD = _payload.toUint64(33);
    }
    function _encodeSendAndCallPayload(address _from, bytes32 _toAddress, uint64 _amountSD, bytes memory _payload, uint64 _dstGasForCall) internal virtual view returns (bytes memory) {
        return abi.encodePacked(
            PT_SEND_AND_CALL,
            _toAddress,
            _amountSD,
            _addressToBytes32(_from),
            _dstGasForCall,
            _payload
        );
    }
    function _decodeSendAndCallPayload(bytes memory _payload) internal virtual view returns (bytes32 from, address to, uint64 amountSD, bytes memory payload, uint64 dstGasForCall) {
        require(_payload.toUint8(0) == PT_SEND_AND_CALL, "OFTCore: invalid payload");
        to = _payload.toAddress(13); 
        amountSD = _payload.toUint64(33);
        from = _payload.toBytes32(41);
        dstGasForCall = _payload.toUint64(73);
        payload = _payload.slice(81, _payload.length - 81);
    }
    function _addressToBytes32(address _address) internal pure virtual returns (bytes32) {
        return bytes32(uint(uint160(_address)));
    }
    function _debitFrom(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount) internal virtual returns (uint);
    function _creditTo(uint16 _srcChainId, address _toAddress, uint _amount) internal virtual returns (uint);
    function _transferFrom(address _from, address _to, uint _amount) internal virtual returns (uint);
    function _ld2sdRate() internal view virtual returns (uint);
}
abstract contract BaseOFTV2 is OFTCoreV2, ERC165, IOFTV2 {
    constructor(uint8 _sharedDecimals, address _lzEndpoint) OFTCoreV2(_sharedDecimals, _lzEndpoint) {
    }
    function sendFrom(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, LzCallParams calldata _callParams) public payable virtual override {
        _send(_from, _dstChainId, _toAddress, _amount, _callParams.refundAddress, _callParams.zroPaymentAddress, _callParams.adapterParams);
    }
    function sendAndCall(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, LzCallParams calldata _callParams) public payable virtual override {
        _sendAndCall(_from, _dstChainId, _toAddress, _amount, _payload, _dstGasForCall, _callParams.refundAddress, _callParams.zroPaymentAddress, _callParams.adapterParams);
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IOFTV2).interfaceId || super.supportsInterface(interfaceId);
    }
    function estimateSendFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bool _useZro, bytes calldata _adapterParams) public view virtual override returns (uint nativeFee, uint zroFee) {
        return _estimateSendFee(_dstChainId, _toAddress, _amount, _useZro, _adapterParams);
    }
    function estimateSendAndCallFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, bool _useZro, bytes calldata _adapterParams) public view virtual override returns (uint nativeFee, uint zroFee) {
        return _estimateSendAndCallFee(_dstChainId, _toAddress, _amount, _payload, _dstGasForCall, _useZro, _adapterParams);
    }
    function circulatingSupply() public view virtual override returns (uint);
    function token() public view virtual override returns (address);
}
contract OFTV2 is BaseOFTV2, ERC20 {
    uint internal immutable ld2sdRate;
    mapping(uint16 => bool) public isLdChain;
    constructor(string memory _name, string memory _symbol, uint8 _sharedDecimals, address _lzEndpoint) ERC20(_name, _symbol) BaseOFTV2(_sharedDecimals, _lzEndpoint) {
        uint8 decimals = decimals();
        require(_sharedDecimals <= decimals, "OFT: sharedDecimals must be <= decimals");
        ld2sdRate = 10 ** (decimals - _sharedDecimals);
    }
    function circulatingSupply() public view virtual override returns (uint) {
        return totalSupply();
    }
    function token() public view virtual override returns (address) {
        return address(this);
    }
    function setLdChain(uint16 _chainId, bool _isLdChain) public virtual onlyOwner {
        isLdChain[_chainId] = _isLdChain;
    }
    function _debitFrom(address _from, uint16, bytes32, uint _amount) internal virtual override returns (uint) {
        address spender = _msgSender();
        if (_from != spender) _spendAllowance(_from, spender, _amount);
        _burn(_from, _amount);
        return _amount;
    }
    function _creditTo(uint16, address _toAddress, uint _amount) internal virtual override returns (uint) {
        _mint(_toAddress, _amount);
        return _amount;
    }
    function _transferFrom(address _from, address _to, uint _amount) internal virtual override returns (uint) {
        address spender = _msgSender();
        if (_from != address(this) && _from != spender) _spendAllowance(_from, spender, _amount);
        _transfer(_from, _to, _amount);
        return _amount;
    }
    function _ld2sdRate() internal view virtual override returns (uint) {
        if(isLdChain[lzEndpoint.getChainId()]) return ld2sdRate;
        return 1;
    }
}
struct IRewardClaimSendFromParams {
    uint256 ethValue;
    ITapiocaOFT.LzCallParams callParams;
}
abstract contract BaseTapOFT is OFTV2 {
    using ExcessivelySafeCall for address;
    using BytesLib for bytes;
    TwTAP public twTap;
    uint16 internal constant PT_LOCK_TWTAP = 870;
    uint16 internal constant PT_UNLOCK_TWTAP = 871;
    uint16 internal constant PT_CLAIM_REWARDS = 872;
    event CallFailedStr(uint16 _srcChainId, bytes _payload, string _reason);
    event CallFailedBytes(uint16 _srcChainId, bytes _payload, bytes _reason);
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _sharedDec,
        address _lzEndpoint
    ) OFTV2(_name, _symbol, _sharedDec, _lzEndpoint) {}
    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64 _nonce,
        bytes memory _payload
    ) internal virtual override {
        uint256 packetType = _payload.toUint256(0);
        if (packetType == PT_LOCK_TWTAP) {
            _lockTwTapPosition(_srcChainId, _payload);
        } else if (packetType == PT_UNLOCK_TWTAP) {
            _unlockTwTapPosition(_srcChainId, _payload);
        } else if (packetType == PT_CLAIM_REWARDS) {
            _claimRewards(_srcChainId, _payload);
        } else {
            packetType = _payload.toUint8(0);
            if (packetType == PT_SEND) {
                _sendAck(_srcChainId, _srcAddress, _nonce, _payload);
            } else if (packetType == PT_SEND_AND_CALL) {
                _sendAndCallAck(_srcChainId, _srcAddress, _nonce, _payload);
            } else {
                revert("TOFT_packet");
            }
        }
    }
    function lockTwTapPosition(
        address to,
        uint256 amount, 
        uint256 duration, 
        uint16 lzDstChainId,
        address zroPaymentAddress,
        bytes calldata adapterParams
    ) external payable {
        bytes memory lzPayload = abi.encode(
            PT_LOCK_TWTAP, 
            msg.sender,
            to,
            amount,
            duration
        );
        require(duration > 0, "TapOFT: Small duration");
        bytes32 senderBytes = LzLib.addressToBytes32(msg.sender);
        _debitFrom(msg.sender, lzEndpoint.getChainId(), senderBytes, amount);
        _lzSend(
            lzDstChainId,
            lzPayload,
            payable(msg.sender),
            zroPaymentAddress,
            adapterParams,
            msg.value
        );
        emit SendToChain(
            lzDstChainId,
            msg.sender,
            LzLib.addressToBytes32(to),
            0
        );
    }
    function _lockTwTapPosition(
        uint16 _srcChainId,
        bytes memory _payload
    ) internal virtual {
        (, , address to, uint256 amount, uint duration) = abi.decode(
            _payload,
            (uint16, address, address, uint256, uint256)
        );
        _creditTo(_srcChainId, address(this), amount);
        approve(address(twTap), amount);
        try twTap.participate(to, amount, duration) {} catch Error(
            string memory _reason
        ) {
            emit CallFailedStr(_srcChainId, _payload, _reason);
            _transferFrom(address(this), to, amount);
        } catch (bytes memory _reason) {
            emit CallFailedBytes(_srcChainId, _payload, _reason);
            _transferFrom(address(this), to, amount);
        }
    }
    function claimRewards(
        address to,
        uint256 tokenID,
        address[] memory rewardTokens,
        uint16 lzDstChainId,
        address zroPaymentAddress,
        bytes calldata adapterParams,
        IRewardClaimSendFromParams[] calldata rewardClaimSendParams
    ) external payable {
        bytes memory lzPayload = abi.encode(
            PT_CLAIM_REWARDS, 
            msg.sender,
            to,
            tokenID,
            rewardTokens,
            rewardClaimSendParams
        );
        _lzSend(
            lzDstChainId,
            lzPayload,
            payable(msg.sender),
            zroPaymentAddress,
            adapterParams,
            msg.value
        );
        emit SendToChain(
            lzDstChainId,
            msg.sender,
            LzLib.addressToBytes32(to),
            0
        );
    }
    function _claimRewards(
        uint16 _srcChainId,
        bytes memory _payload
    ) internal virtual {
        (
            ,
            ,
            address to,
            uint256 tokenID,
            IERC20[] memory rewardTokens,
            IRewardClaimSendFromParams[] memory rewardClaimSendParams
        ) = abi.decode(
                _payload,
                (
                    uint16,
                    address,
                    address,
                    uint256,
                    IERC20[],
                    IRewardClaimSendFromParams[]
                )
            );
        require(twTap.ownerOf(tokenID) == to, "TapOFT: Not owner");
        try twTap.claimAndSendRewards(tokenID, rewardTokens) {
            uint256 len = rewardTokens.length;
            for (uint i = 0; i < len; ) {
                ISendFrom(address(rewardTokens[i])).sendFrom{
                    value: rewardClaimSendParams[i].ethValue
                }(
                    address(this),
                    _srcChainId,
                    LzLib.addressToBytes32(to),
                    IERC20(rewardTokens[i]).balanceOf(address(this)),
                    rewardClaimSendParams[i].callParams
                );
                ++i;
            }
        } catch Error(string memory _reason) {
            emit CallFailedStr(_srcChainId, _payload, _reason);
        } catch (bytes memory _reason) {
            emit CallFailedBytes(_srcChainId, _payload, _reason);
        }
    }
    function unlockTwTapPosition(
        address to,
        uint256 tokenID,
        uint16 lzDstChainId,
        address zroPaymentAddress,
        bytes calldata adapterParams,
        LzCallParams calldata twTapSendBackAdapterParams
    ) external payable {
        bytes memory lzPayload = abi.encode(
            PT_UNLOCK_TWTAP, 
            msg.sender,
            to,
            tokenID,
            twTapSendBackAdapterParams
        );
        _lzSend(
            lzDstChainId,
            lzPayload,
            payable(msg.sender),
            zroPaymentAddress,
            adapterParams,
            msg.value
        );
        emit SendToChain(
            lzDstChainId,
            msg.sender,
            LzLib.addressToBytes32(to),
            0
        );
    }
    function _unlockTwTapPosition(
        uint16 _srcChainId,
        bytes memory _payload
    ) internal virtual {
        (
            ,
            ,
            address to,
            uint256 tokenID,
            LzCallParams memory twTapSendBackAdapterParams
        ) = abi.decode(
                _payload,
                (uint16, address, address, uint256, LzCallParams)
            );
        require(twTap.ownerOf(tokenID) == to, "TapOFT: Not owner");
        try twTap.exitPositionAndSendTap(tokenID) returns (uint256 _amount) {
            this.sendFrom{value: address(this).balance}(
                address(this),
                _srcChainId,
                LzLib.addressToBytes32(to),
                _amount,
                twTapSendBackAdapterParams
            );
        } catch Error(string memory _reason) {
            emit CallFailedStr(_srcChainId, _payload, _reason);
        } catch (bytes memory _reason) {
            emit CallFailedBytes(_srcChainId, _payload, _reason);
        }
    }
    function setTwTap(address _twTap) external onlyOwner {
        twTap = TwTAP(_twTap);
    }
    receive() external payable virtual {}
    function _callApproval(ICommonData.IApproval[] memory approvals) private {
        for (uint256 i = 0; i < approvals.length; ) {
            try
                IERC20Permit(approvals[i].target).permit(
                    approvals[i].owner,
                    approvals[i].spender,
                    approvals[i].value,
                    approvals[i].deadline,
                    approvals[i].v,
                    approvals[i].r,
                    approvals[i].s
                )
            {} catch Error(string memory reason) {
                if (!approvals[i].allowFailure) {
                    revert(reason);
                }
            }
            unchecked {
                ++i;
            }
        }
    }
}
contract TapOFT is BaseTapOFT, ERC20Permit {
    uint256 public constant INITIAL_SUPPLY = 46_686_595 * 1e18; 
    uint256 public dso_supply = 53_313_405 * 1e18;
    uint256 constant decay_rate = 8800000000000000; 
    uint256 constant DECAY_RATE_DECIMAL = 1e18;
    uint256 public constant WEEK = 604800;
    uint256 public immutable emissionsStartTime;
    mapping(uint256 => uint256) public emissionForWeek;
    mapping(uint256 => uint256) public mintedInWeek;
    address public minter;
    uint256 public governanceChainIdentifier;
    bool public paused;
    event MinterUpdated(address indexed _old, address indexed _new);
    event Emitted(uint256 week, uint256 amount);
    event Minted(address indexed _by, address indexed _to, uint256 _amount);
    event Burned(address indexed _from, uint256 _amount);
    event GovernanceChainIdentifierUpdated(uint256 _old, uint256 _new);
    event PausedUpdated(bool oldState, bool newState);
    modifier notPaused() {
        require(!paused, "TAP: paused");
        _;
    }
    constructor(
        address _lzEndpoint,
        address _contributors,
        address _earlySupporters,
        address _supporters,
        address _lbp,
        address _dao,
        address _airdrop,
        uint256 _governanceChainId,
        address _conservator
    ) BaseTapOFT("TapOFT", "TAP", 8, _lzEndpoint) ERC20Permit("TapOFT") {
        require(_lzEndpoint != address(0), "LZ endpoint not valid");
        governanceChainIdentifier = _governanceChainId;
        if (_getChainId() == governanceChainIdentifier) {
            _mint(_contributors, 1e18 * 15_000_000);
            _mint(_earlySupporters, 1e18 * 3_686_595);
            _mint(_supporters, 1e18 * 12_500_000);
            _mint(_lbp, 1e18 * 5_000_000);
            _mint(_dao, 1e18 * 8_000_000);
            _mint(_airdrop, 1e18 * 2_500_000);
            require(
                totalSupply() == INITIAL_SUPPLY,
                "initial supply not valid"
            );
        }
        emissionsStartTime = block.timestamp;
        transferOwnership(_conservator);
    }
    function setGovernanceChainIdentifier(
        uint256 _identifier
    ) external onlyOwner {
        emit GovernanceChainIdentifierUpdated(
            governanceChainIdentifier,
            _identifier
        );
        governanceChainIdentifier = _identifier;
    }
    function updatePause(bool val) external onlyOwner {
        require(val != paused, "TAP: same state");
        emit PausedUpdated(paused, val);
        paused = val;
    }
    function setMinter(address _minter) external onlyOwner {
        require(_minter != address(0), "address not valid");
        emit MinterUpdated(minter, _minter);
        minter = _minter;
    }
    function decimals() public pure override returns (uint8) {
        return 18;
    }
    function timestampToWeek(
        uint256 timestamp
    ) external view returns (uint256) {
        if (timestamp == 0) {
            timestamp = block.timestamp;
        }
        if (timestamp < emissionsStartTime) return 0;
        return _timestampToWeek(timestamp);
    }
    function getCurrentWeek() external view returns (uint256) {
        return _timestampToWeek(block.timestamp);
    }
    function getCurrentWeekEmission() external view returns (uint256) {
        return emissionForWeek[_timestampToWeek(block.timestamp)];
    }
    function emitForWeek() external notPaused returns (uint256) {
        require(_getChainId() == governanceChainIdentifier, "chain not valid");
        uint256 week = _timestampToWeek(block.timestamp);
        if (emissionForWeek[week] > 0) return 0;
        dso_supply -= mintedInWeek[week - 1];
        uint256 unclaimed = emissionForWeek[week - 1] - mintedInWeek[week - 1];
        uint256 emission = uint256(_computeEmission());
        emission += unclaimed;
        emissionForWeek[week] = emission;
        emit Emitted(week, emission);
        return emission;
    }
    function extractTAP(address _to, uint256 _amount) external notPaused {
        require(msg.sender == minter, "unauthorized");
        require(_amount > 0, "amount not valid");
        uint256 week = _timestampToWeek(block.timestamp);
        require(emissionForWeek[week] >= _amount, "exceeds allowable amount");
        _mint(_to, _amount);
        mintedInWeek[week] += _amount;
        emit Minted(msg.sender, _to, _amount);
    }
    function removeTAP(uint256 _amount) external notPaused {
        _burn(msg.sender, _amount);
        emit Burned(msg.sender, _amount);
    }
    function _timestampToWeek(
        uint256 timestamp
    ) internal view returns (uint256) {
        return ((timestamp - emissionsStartTime) / WEEK) + 1; 
    }
    function _getChainId() private view returns (uint256) {
        return block.chainid;
    }
    function _computeEmission() internal view returns (uint256 result) {
        result = (dso_supply * decay_rate) / DECAY_RATE_DECIMAL;
    }
}
struct Participation {
    uint256 averageMagnitude;
    bool hasVotingPower;
    bool divergenceForce; 
    bool tapReleased; 
    uint56 expiry; 
    uint88 tapAmount; 
    uint24 multiplier; 
    uint40 lastInactive; 
    uint40 lastActive; 
}
struct TWAMLPool {
    uint256 totalParticipants;
    uint256 averageMagnitude;
    uint256 totalDeposited;
    uint256 cumulative;
}
struct WeekTotals {
    int256 netActiveVotes;
    mapping(uint256 => uint256) totalDistPerVote;
}
interface IONFT721Core is IERC165 {
    event SendToChain(uint16 indexed _dstChainId, address indexed _from, bytes indexed _toAddress, uint[] _tokenIds);
    event ReceiveFromChain(uint16 indexed _srcChainId, bytes indexed _srcAddress, address indexed _toAddress, uint[] _tokenIds);
    event CreditStored(bytes32 _hashedPayload, bytes _payload);
    event CreditCleared(bytes32 _hashedPayload);
    function sendFrom(address _from, uint16 _dstChainId, bytes calldata _toAddress, uint _tokenId, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;
    function sendBatchFrom(address _from, uint16 _dstChainId, bytes calldata _toAddress, uint[] calldata _tokenIds, address payable _refundAddress, address _zroPaymentAddress, bytes calldata _adapterParams) external payable;
    function estimateSendFee(uint16 _dstChainId, bytes calldata _toAddress, uint _tokenId, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);
    function estimateSendBatchFee(uint16 _dstChainId, bytes calldata _toAddress, uint[] calldata _tokenIds, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);
}
interface IONFT721 is IONFT721Core, IERC721 {
}
abstract contract ONFT721Core is NonblockingLzApp, ERC165, IONFT721Core {
    uint16 public constant FUNCTION_TYPE_SEND = 1;
    struct StoredCredit {
        uint16 srcChainId;
        address toAddress;
        uint256 index; 
        bool creditsRemain;
    }
    uint256 public minGasToTransferAndStore; 
    mapping(uint16 => uint256) public dstChainIdToBatchLimit;
    mapping(uint16 => uint256) public dstChainIdToTransferGas; 
    mapping(bytes32 => StoredCredit) public storedCredits;
    constructor(uint256 _minGasToTransferAndStore, address _lzEndpoint) NonblockingLzApp(_lzEndpoint) {
        require(_minGasToTransferAndStore > 0, "ONFT721: minGasToTransferAndStore must be > 0");
        minGasToTransferAndStore = _minGasToTransferAndStore;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IONFT721Core).interfaceId || super.supportsInterface(interfaceId);
    }
    function estimateSendFee(uint16 _dstChainId, bytes memory _toAddress, uint _tokenId, bool _useZro, bytes memory _adapterParams) public view virtual override returns (uint nativeFee, uint zroFee) {
        return estimateSendBatchFee(_dstChainId, _toAddress, _toSingletonArray(_tokenId), _useZro, _adapterParams);
    }
    function estimateSendBatchFee(uint16 _dstChainId, bytes memory _toAddress, uint[] memory _tokenIds, bool _useZro, bytes memory _adapterParams) public view virtual override returns (uint nativeFee, uint zroFee) {
        bytes memory payload = abi.encode(_toAddress, _tokenIds);
        return lzEndpoint.estimateFees(_dstChainId, address(this), payload, _useZro, _adapterParams);
    }
    function sendFrom(address _from, uint16 _dstChainId, bytes memory _toAddress, uint _tokenId, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams) public payable virtual override {
        _send(_from, _dstChainId, _toAddress, _toSingletonArray(_tokenId), _refundAddress, _zroPaymentAddress, _adapterParams);
    }
    function sendBatchFrom(address _from, uint16 _dstChainId, bytes memory _toAddress, uint[] memory _tokenIds, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams) public payable virtual override {
        _send(_from, _dstChainId, _toAddress, _tokenIds, _refundAddress, _zroPaymentAddress, _adapterParams);
    }
    function _send(address _from, uint16 _dstChainId, bytes memory _toAddress, uint[] memory _tokenIds, address payable _refundAddress, address _zroPaymentAddress, bytes memory _adapterParams) internal virtual {
        require(_tokenIds.length > 0, "LzApp: tokenIds[] is empty");
        require(_tokenIds.length == 1 || _tokenIds.length <= dstChainIdToBatchLimit[_dstChainId], "ONFT721: batch size exceeds dst batch limit");
        for (uint i = 0; i < _tokenIds.length; i++) {
            _debitFrom(_from, _dstChainId, _toAddress, _tokenIds[i]);
        }
        bytes memory payload = abi.encode(_toAddress, _tokenIds);
        _checkGasLimit(_dstChainId, FUNCTION_TYPE_SEND, _adapterParams, dstChainIdToTransferGas[_dstChainId] * _tokenIds.length);
        _lzSend(_dstChainId, payload, _refundAddress, _zroPaymentAddress, _adapterParams, msg.value);
        emit SendToChain(_dstChainId, _from, _toAddress, _tokenIds);
    }
    function _nonblockingLzReceive(
        uint16 _srcChainId,
        bytes memory _srcAddress,
        uint64, 
        bytes memory _payload
    ) internal virtual override {
        (bytes memory toAddressBytes, uint[] memory tokenIds) = abi.decode(_payload, (bytes, uint[]));
        address toAddress;
        assembly {
            toAddress := mload(add(toAddressBytes, 20))
        }
        uint nextIndex = _creditTill(_srcChainId, toAddress, 0, tokenIds);
        if (nextIndex < tokenIds.length) {
            bytes32 hashedPayload = keccak256(_payload);
            storedCredits[hashedPayload] = StoredCredit(_srcChainId, toAddress, nextIndex, true);
            emit CreditStored(hashedPayload, _payload);
        }
        emit ReceiveFromChain(_srcChainId, _srcAddress, toAddress, tokenIds);
    }
    function clearCredits(bytes memory _payload) external {
        bytes32 hashedPayload = keccak256(_payload);
        require(storedCredits[hashedPayload].creditsRemain, "ONFT721: no credits stored");
        (, uint[] memory tokenIds) = abi.decode(_payload, (bytes, uint[]));
        uint nextIndex = _creditTill(storedCredits[hashedPayload].srcChainId, storedCredits[hashedPayload].toAddress, storedCredits[hashedPayload].index, tokenIds);
        require(nextIndex > storedCredits[hashedPayload].index, "ONFT721: not enough gas to process credit transfer");
        if (nextIndex == tokenIds.length) {
            delete storedCredits[hashedPayload];
            emit CreditCleared(hashedPayload);
        } else {
            storedCredits[hashedPayload] = StoredCredit(storedCredits[hashedPayload].srcChainId, storedCredits[hashedPayload].toAddress, nextIndex, true);
        }
    }
    function _creditTill(uint16 _srcChainId, address _toAddress, uint _startIndex, uint[] memory _tokenIds) internal returns (uint256){
        uint i = _startIndex;
        while (i < _tokenIds.length) {
            if (gasleft() < minGasToTransferAndStore) break;
            _creditTo(_srcChainId, _toAddress, _tokenIds[i]);
            i++;
        }
        return i;
    }
    function setMinGasToTransferAndStore(uint256 _minGasToTransferAndStore) external onlyOwner {
        require(_minGasToTransferAndStore > 0, "ONFT721: minGasToTransferAndStore must be > 0");
        minGasToTransferAndStore = _minGasToTransferAndStore;
    }
    function setDstChainIdToTransferGas(uint16 _dstChainId, uint256 _dstChainIdToTransferGas) external onlyOwner {
        require(_dstChainIdToTransferGas > 0, "ONFT721: dstChainIdToTransferGas must be > 0");
        dstChainIdToTransferGas[_dstChainId] = _dstChainIdToTransferGas;
    }
    function setDstChainIdToBatchLimit(uint16 _dstChainId, uint256 _dstChainIdToBatchLimit) external onlyOwner {
        require(_dstChainIdToBatchLimit > 0, "ONFT721: dstChainIdToBatchLimit must be > 0");
        dstChainIdToBatchLimit[_dstChainId] = _dstChainIdToBatchLimit;
    }
    function _debitFrom(address _from, uint16 _dstChainId, bytes memory _toAddress, uint _tokenId) internal virtual;
    function _creditTo(uint16 _srcChainId, address _toAddress, uint _tokenId) internal virtual;
    function _toSingletonArray(uint element) internal pure returns (uint[] memory) {
        uint[] memory array = new uint[](1);
        array[0] = element;
        return array;
    }
}
contract ONFT721 is ONFT721Core, ERC721, IONFT721 {
    constructor(string memory _name, string memory _symbol, uint256 _minGasToTransfer, address _lzEndpoint) ERC721(_name, _symbol) ONFT721Core(_minGasToTransfer, _lzEndpoint) {}
    function supportsInterface(bytes4 interfaceId) public view virtual override(ONFT721Core, ERC721, IERC165) returns (bool) {
        return interfaceId == type(IONFT721).interfaceId || super.supportsInterface(interfaceId);
    }
    function _debitFrom(address _from, uint16, bytes memory, uint _tokenId) internal virtual override {
        require(_isApprovedOrOwner(_msgSender(), _tokenId), "ONFT721: send caller is not owner nor approved");
        require(ERC721.ownerOf(_tokenId) == _from, "ONFT721: send from incorrect owner");
        _transfer(_from, address(this), _tokenId);
    }
    function _creditTo(uint16, address _toAddress, uint _tokenId) internal virtual override {
        require(!_exists(_tokenId) || (_exists(_tokenId) && ERC721.ownerOf(_tokenId) == address(this)));
        if (!_exists(_tokenId)) {
            _safeMint(_toAddress, _tokenId);
        } else {
            _transfer(address(this), _toAddress, _tokenId);
        }
    }
}
contract TwTAP is TWAML, ONFT721, ERC721Permit {
    using SafeERC20 for IERC20;
    TapOFT public immutable tapOFT;
    TWAMLPool public twAML; 
    mapping(uint256 => Participation) public participants; 
    uint256 constant MIN_WEIGHT_FACTOR = 10; 
    uint256 constant dMAX = 100 * 1e4; 
    uint256 constant dMIN = 10 * 1e4;
    uint256 public constant EPOCH_DURATION = 7 days;
    uint256 constant DIST_PRECISION = 2 ** 128;
    IERC20[] public rewardTokens;
    mapping(IERC20 => uint256) public rewardTokenIndex;
    mapping(uint256 => mapping(uint256 => uint256)) public claimed;
    uint256 public mintedTWTap;
    uint256 public creation; 
    uint256 public lastProcessedWeek;
    mapping(uint256 => WeekTotals) public weekTotals;
    uint256 public immutable HOST_CHAIN_ID;
    string private baseURI;
    constructor(
        address payable _tapOFT,
        address _owner,
        address _layerZeroEndpoint,
        uint256 _hostChainID,
        uint256 _minGas
    )
        ONFT721("Time Weighted TAP", "twTAP", _minGas, _layerZeroEndpoint)
        ERC721Permit("Time Weighted TAP")
    {
        tapOFT = TapOFT(_tapOFT);
        transferOwnership(_owner);
        creation = block.timestamp;
        HOST_CHAIN_ID = _hostChainID;
    }
    event Participate(
        address indexed participant,
        uint256 tapAmount,
        uint256 multiplier
    );
    event AMLDivergence(
        uint256 cumulative,
        uint256 averageMagnitude,
        uint256 totalParticipants
    );
    event ExitPosition(uint256 tokenId, uint256 amount);
    function currentWeek() public view returns (uint256) {
        return (block.timestamp - creation) / EPOCH_DURATION;
    }
    function getParticipation(
        uint _tokenId
    ) public view returns (Participation memory participant) {
        participant = participants[_tokenId];
        if (participant.expiry < block.timestamp) {
            participant.multiplier = 0;
        }
        return participant;
    }
    function claimable(
        uint256 _tokenId
    ) public view returns (uint256[] memory) {
        uint256 len = rewardTokens.length;
        uint256[] memory result = new uint256[](len);
        Participation memory position = participants[_tokenId];
        uint256 votes;
        unchecked {
            votes = uint256(position.tapAmount) * uint256(position.multiplier);
        }
        if (votes == 0) {
            return result;
        }
        uint256 week = lastProcessedWeek;
        if (week <= position.lastInactive) {
            return result;
        }
        if (position.lastActive < week) {
            week = position.lastActive;
        }
        WeekTotals storage cur = weekTotals[week];
        WeekTotals storage prev = weekTotals[position.lastInactive];
        for (uint256 i = 0; i < len; ) {
            uint256 net = cur.totalDistPerVote[i] - prev.totalDistPerVote[i];
            result[i] = ((votes * net) / DIST_PRECISION) - claimed[_tokenId][i];
            unchecked {
                ++i;
            }
        }
        return result;
    }
    function participate(
        address _participant,
        uint256 _amount,
        uint256 _duration
    ) external returns (uint256 tokenId) {
        require(_duration >= EPOCH_DURATION, "twTAP: Lock not a week");
        tapOFT.transferFrom(msg.sender, address(this), _amount);
        TWAMLPool memory pool = twAML;
        uint256 magnitude = computeMagnitude(_duration, pool.cumulative);
        bool divergenceForce;
        uint256 multiplier = computeTarget(
            dMIN,
            dMAX,
            magnitude,
            pool.cumulative
        );
        bool hasVotingPower = _amount >=
            computeMinWeight(pool.totalDeposited, MIN_WEIGHT_FACTOR);
        if (hasVotingPower) {
            pool.totalParticipants++; 
            pool.averageMagnitude =
                (pool.averageMagnitude + magnitude) /
                pool.totalParticipants; 
            divergenceForce = _duration > pool.cumulative;
            if (divergenceForce) {
                pool.cumulative += pool.averageMagnitude;
            } else {
                if (pool.cumulative > pool.averageMagnitude) {
                    pool.cumulative -= pool.averageMagnitude;
                } else {
                    pool.cumulative = 0;
                }
            }
            pool.totalDeposited += _amount;
            twAML = pool; 
            emit AMLDivergence(
                pool.cumulative,
                pool.averageMagnitude,
                pool.totalParticipants
            );
        }
        tokenId = ++mintedTWTap;
        _safeMint(_participant, tokenId);
        uint256 expiry = block.timestamp + _duration;
        require(expiry < type(uint56).max, "twTAP: too long");
        uint256 w0 = currentWeek();
        uint256 w1 = (expiry - creation) / EPOCH_DURATION;
        uint256 votes = _amount * multiplier;
        participants[tokenId] = Participation({
            averageMagnitude: pool.averageMagnitude,
            hasVotingPower: hasVotingPower,
            divergenceForce: divergenceForce,
            tapReleased: false,
            expiry: uint56(expiry),
            tapAmount: uint88(_amount),
            multiplier: uint24(multiplier),
            lastInactive: uint40(w0),
            lastActive: uint40(w1)
        });
        weekTotals[w0 + 1].netActiveVotes += int256(votes);
        weekTotals[w1 + 1].netActiveVotes -= int256(votes);
        emit Participate(_participant, _amount, multiplier);
    }
    function claimRewards(uint256 _tokenId, address _to) external {
        _requireClaimPermission(_to, _tokenId);
        _claimRewards(_tokenId, _to);
    }
    function claimAndSendRewards(
        uint256 _tokenId,
        IERC20[] memory _rewardTokens
    ) external {
        require(msg.sender == address(tapOFT), "twTAP: only tapOFT");
        _claimRewardsOn(_tokenId, address(tapOFT), _rewardTokens);
    }
    function releaseTap(uint256 _tokenId, address _to) external {
        _requireClaimPermission(_to, _tokenId);
        _releaseTap(_tokenId, _to);
    }
    function exitPosition(uint256 _tokenId) external {
        address to = ownerOf(_tokenId);
        _releaseTap(_tokenId, to);
    }
    function exitPositionAndSendTap(
        uint256 _tokenId
    ) external returns (uint256) {
        require(msg.sender == address(tapOFT), "twTAP: only tapOFT");
        return _releaseTap(_tokenId, address(tapOFT));
    }
    function advanceWeek(uint256 _limit) public {
        uint256 cur = currentWeek();
        uint256 week = lastProcessedWeek;
        uint256 goal = cur;
        unchecked {
            if (goal - week > _limit) {
                goal = week + _limit;
            }
        }
        uint256 len = rewardTokens.length;
        while (week < goal) {
            WeekTotals storage prev = weekTotals[week];
            WeekTotals storage next = weekTotals[++week];
            next.netActiveVotes += prev.netActiveVotes;
            for (uint256 i = 0; i < len; ) {
                next.totalDistPerVote[i] += prev.totalDistPerVote[i];
                unchecked {
                    ++i;
                }
            }
        }
        lastProcessedWeek = goal;
    }
    function distributeReward(
        uint256 _rewardTokenId,
        uint256 _amount
    ) external {
        require(
            lastProcessedWeek == currentWeek(),
            "twTAP: Advance week first"
        );
        WeekTotals storage totals = weekTotals[lastProcessedWeek];
        IERC20 rewardToken = rewardTokens[_rewardTokenId];
        totals.totalDistPerVote[_rewardTokenId] +=
            (_amount * DIST_PRECISION) /
            uint256(totals.netActiveVotes);
        rewardToken.safeTransferFrom(msg.sender, address(this), _amount);
    }
    function addRewardToken(IERC20 token) external onlyOwner returns (uint256) {
        uint256 i = rewardTokens.length;
        rewardTokens.push(token);
        rewardTokenIndex[token] = i;
        return i;
    }
    function _requireClaimPermission(
        address _to,
        uint256 _tokenId
    ) internal view {
        address tokenOwner = ownerOf(_tokenId);
        require(
            msg.sender == tokenOwner ||
                _to == tokenOwner ||
                isApprovedForAll(tokenOwner, msg.sender) ||
                getApproved(_tokenId) == msg.sender,
            "twTAP: cannot claim"
        );
    }
    function _claimRewards(uint256 _tokenId, address _to) internal {
        uint256[] memory amounts = claimable(_tokenId);
        uint256 len = amounts.length;
        unchecked {
            for (uint256 i = 0; i < len; ++i) {
                uint256 amount = amounts[i];
                if (amount > 0) {
                    claimed[_tokenId][i] += amount;
                    rewardTokens[i].safeTransfer(_to, amount);
                }
            }
        }
    }
    function _claimRewardsOn(
        uint256 _tokenId,
        address _to,
        IERC20[] memory _rewardTokens
    ) internal {
        uint256[] memory amounts = claimable(_tokenId);
        unchecked {
            uint256 len = _rewardTokens.length;
            for (uint256 i = 0; i < len; ) {
                uint256 claimableIndex = rewardTokenIndex[_rewardTokens[i]];
                uint256 amount = amounts[i];
                if (amount > 0) {
                    claimed[_tokenId][claimableIndex] += amount;
                    rewardTokens[claimableIndex].safeTransfer(_to, amount);
                }
                ++i;
            }
        }
    }
    function _releaseTap(
        uint256 _tokenId,
        address _to
    ) internal returns (uint256 releasedAmount) {
        Participation memory position = participants[_tokenId];
        if (position.tapReleased) {
            return 0;
        }
        require(position.expiry <= block.timestamp, "twTAP: Lock not expired");
        releasedAmount = position.tapAmount;
        if (position.hasVotingPower) {
            TWAMLPool memory pool = twAML;
            pool.totalParticipants--;
            if (position.divergenceForce) {
                if (pool.cumulative > position.averageMagnitude) {
                    pool.cumulative -= position.averageMagnitude;
                } else {
                    pool.cumulative = 0;
                }
            } else {
                pool.cumulative += position.averageMagnitude;
            }
            pool.totalDeposited -= position.tapAmount;
            twAML = pool; 
            emit AMLDivergence(
                pool.cumulative,
                pool.averageMagnitude,
                pool.totalParticipants
            ); 
        }
        participants[_tokenId].tapReleased = true;
        tapOFT.transfer(_to, releasedAmount);
        emit ExitPosition(_tokenId, releasedAmount);
    }
    function _getChainId() internal view virtual returns (uint256) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        return chainId;
    }
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ONFT721, ERC721) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}