pragma solidity ^0.8.21;
library Panic {
    uint256 internal constant GENERIC = 0x00;
    uint256 internal constant ASSERT = 0x01;
    uint256 internal constant UNDER_OVERFLOW = 0x11;
    uint256 internal constant DIVISION_BY_ZERO = 0x12;
    uint256 internal constant ENUM_CONVERSION_ERROR = 0x21;
    uint256 internal constant STORAGE_ENCODING_ERROR = 0x22;
    uint256 internal constant EMPTY_ARRAY_POP = 0x31;
    uint256 internal constant ARRAY_OUT_OF_BOUNDS = 0x32;
    uint256 internal constant RESOURCE_ERROR = 0x41;
    uint256 internal constant INVALID_INTERNAL_FUNCTION = 0x51;
    function panic(uint256 code) internal pure {
        assembly {
            mstore(0x00, 0x4e487b71)
            mstore(0x20, code)
            revert(0x1c, 0x24)
        }
    }
}
library SafeCast {
    error SafeCastOverflowedUintDowncast(uint8 bits, uint256 value);
    error SafeCastOverflowedIntToUint(int256 value);
    error SafeCastOverflowedIntDowncast(uint8 bits, int256 value);
    error SafeCastOverflowedUintToInt(uint256 value);
    function toUint248(uint256 value) internal pure returns (uint248) {
        if (value > type(uint248).max) {
            revert SafeCastOverflowedUintDowncast(248, value);
        }
        return uint248(value);
    }
    function toUint240(uint256 value) internal pure returns (uint240) {
        if (value > type(uint240).max) {
            revert SafeCastOverflowedUintDowncast(240, value);
        }
        return uint240(value);
    }
    function toUint232(uint256 value) internal pure returns (uint232) {
        if (value > type(uint232).max) {
            revert SafeCastOverflowedUintDowncast(232, value);
        }
        return uint232(value);
    }
    function toUint224(uint256 value) internal pure returns (uint224) {
        if (value > type(uint224).max) {
            revert SafeCastOverflowedUintDowncast(224, value);
        }
        return uint224(value);
    }
    function toUint216(uint256 value) internal pure returns (uint216) {
        if (value > type(uint216).max) {
            revert SafeCastOverflowedUintDowncast(216, value);
        }
        return uint216(value);
    }
    function toUint208(uint256 value) internal pure returns (uint208) {
        if (value > type(uint208).max) {
            revert SafeCastOverflowedUintDowncast(208, value);
        }
        return uint208(value);
    }
    function toUint200(uint256 value) internal pure returns (uint200) {
        if (value > type(uint200).max) {
            revert SafeCastOverflowedUintDowncast(200, value);
        }
        return uint200(value);
    }
    function toUint192(uint256 value) internal pure returns (uint192) {
        if (value > type(uint192).max) {
            revert SafeCastOverflowedUintDowncast(192, value);
        }
        return uint192(value);
    }
    function toUint184(uint256 value) internal pure returns (uint184) {
        if (value > type(uint184).max) {
            revert SafeCastOverflowedUintDowncast(184, value);
        }
        return uint184(value);
    }
    function toUint176(uint256 value) internal pure returns (uint176) {
        if (value > type(uint176).max) {
            revert SafeCastOverflowedUintDowncast(176, value);
        }
        return uint176(value);
    }
    function toUint168(uint256 value) internal pure returns (uint168) {
        if (value > type(uint168).max) {
            revert SafeCastOverflowedUintDowncast(168, value);
        }
        return uint168(value);
    }
    function toUint160(uint256 value) internal pure returns (uint160) {
        if (value > type(uint160).max) {
            revert SafeCastOverflowedUintDowncast(160, value);
        }
        return uint160(value);
    }
    function toUint152(uint256 value) internal pure returns (uint152) {
        if (value > type(uint152).max) {
            revert SafeCastOverflowedUintDowncast(152, value);
        }
        return uint152(value);
    }
    function toUint144(uint256 value) internal pure returns (uint144) {
        if (value > type(uint144).max) {
            revert SafeCastOverflowedUintDowncast(144, value);
        }
        return uint144(value);
    }
    function toUint136(uint256 value) internal pure returns (uint136) {
        if (value > type(uint136).max) {
            revert SafeCastOverflowedUintDowncast(136, value);
        }
        return uint136(value);
    }
    function toUint128(uint256 value) internal pure returns (uint128) {
        if (value > type(uint128).max) {
            revert SafeCastOverflowedUintDowncast(128, value);
        }
        return uint128(value);
    }
    function toUint120(uint256 value) internal pure returns (uint120) {
        if (value > type(uint120).max) {
            revert SafeCastOverflowedUintDowncast(120, value);
        }
        return uint120(value);
    }
    function toUint112(uint256 value) internal pure returns (uint112) {
        if (value > type(uint112).max) {
            revert SafeCastOverflowedUintDowncast(112, value);
        }
        return uint112(value);
    }
    function toUint104(uint256 value) internal pure returns (uint104) {
        if (value > type(uint104).max) {
            revert SafeCastOverflowedUintDowncast(104, value);
        }
        return uint104(value);
    }
    function toUint96(uint256 value) internal pure returns (uint96) {
        if (value > type(uint96).max) {
            revert SafeCastOverflowedUintDowncast(96, value);
        }
        return uint96(value);
    }
    function toUint88(uint256 value) internal pure returns (uint88) {
        if (value > type(uint88).max) {
            revert SafeCastOverflowedUintDowncast(88, value);
        }
        return uint88(value);
    }
    function toUint80(uint256 value) internal pure returns (uint80) {
        if (value > type(uint80).max) {
            revert SafeCastOverflowedUintDowncast(80, value);
        }
        return uint80(value);
    }
    function toUint72(uint256 value) internal pure returns (uint72) {
        if (value > type(uint72).max) {
            revert SafeCastOverflowedUintDowncast(72, value);
        }
        return uint72(value);
    }
    function toUint64(uint256 value) internal pure returns (uint64) {
        if (value > type(uint64).max) {
            revert SafeCastOverflowedUintDowncast(64, value);
        }
        return uint64(value);
    }
    function toUint56(uint256 value) internal pure returns (uint56) {
        if (value > type(uint56).max) {
            revert SafeCastOverflowedUintDowncast(56, value);
        }
        return uint56(value);
    }
    function toUint48(uint256 value) internal pure returns (uint48) {
        if (value > type(uint48).max) {
            revert SafeCastOverflowedUintDowncast(48, value);
        }
        return uint48(value);
    }
    function toUint40(uint256 value) internal pure returns (uint40) {
        if (value > type(uint40).max) {
            revert SafeCastOverflowedUintDowncast(40, value);
        }
        return uint40(value);
    }
    function toUint32(uint256 value) internal pure returns (uint32) {
        if (value > type(uint32).max) {
            revert SafeCastOverflowedUintDowncast(32, value);
        }
        return uint32(value);
    }
    function toUint24(uint256 value) internal pure returns (uint24) {
        if (value > type(uint24).max) {
            revert SafeCastOverflowedUintDowncast(24, value);
        }
        return uint24(value);
    }
    function toUint16(uint256 value) internal pure returns (uint16) {
        if (value > type(uint16).max) {
            revert SafeCastOverflowedUintDowncast(16, value);
        }
        return uint16(value);
    }
    function toUint8(uint256 value) internal pure returns (uint8) {
        if (value > type(uint8).max) {
            revert SafeCastOverflowedUintDowncast(8, value);
        }
        return uint8(value);
    }
    function toUint256(int256 value) internal pure returns (uint256) {
        if (value < 0) {
            revert SafeCastOverflowedIntToUint(value);
        }
        return uint256(value);
    }
    function toInt248(int256 value) internal pure returns (int248 downcasted) {
        downcasted = int248(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(248, value);
        }
    }
    function toInt240(int256 value) internal pure returns (int240 downcasted) {
        downcasted = int240(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(240, value);
        }
    }
    function toInt232(int256 value) internal pure returns (int232 downcasted) {
        downcasted = int232(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(232, value);
        }
    }
    function toInt224(int256 value) internal pure returns (int224 downcasted) {
        downcasted = int224(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(224, value);
        }
    }
    function toInt216(int256 value) internal pure returns (int216 downcasted) {
        downcasted = int216(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(216, value);
        }
    }
    function toInt208(int256 value) internal pure returns (int208 downcasted) {
        downcasted = int208(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(208, value);
        }
    }
    function toInt200(int256 value) internal pure returns (int200 downcasted) {
        downcasted = int200(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(200, value);
        }
    }
    function toInt192(int256 value) internal pure returns (int192 downcasted) {
        downcasted = int192(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(192, value);
        }
    }
    function toInt184(int256 value) internal pure returns (int184 downcasted) {
        downcasted = int184(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(184, value);
        }
    }
    function toInt176(int256 value) internal pure returns (int176 downcasted) {
        downcasted = int176(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(176, value);
        }
    }
    function toInt168(int256 value) internal pure returns (int168 downcasted) {
        downcasted = int168(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(168, value);
        }
    }
    function toInt160(int256 value) internal pure returns (int160 downcasted) {
        downcasted = int160(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(160, value);
        }
    }
    function toInt152(int256 value) internal pure returns (int152 downcasted) {
        downcasted = int152(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(152, value);
        }
    }
    function toInt144(int256 value) internal pure returns (int144 downcasted) {
        downcasted = int144(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(144, value);
        }
    }
    function toInt136(int256 value) internal pure returns (int136 downcasted) {
        downcasted = int136(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(136, value);
        }
    }
    function toInt128(int256 value) internal pure returns (int128 downcasted) {
        downcasted = int128(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(128, value);
        }
    }
    function toInt120(int256 value) internal pure returns (int120 downcasted) {
        downcasted = int120(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(120, value);
        }
    }
    function toInt112(int256 value) internal pure returns (int112 downcasted) {
        downcasted = int112(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(112, value);
        }
    }
    function toInt104(int256 value) internal pure returns (int104 downcasted) {
        downcasted = int104(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(104, value);
        }
    }
    function toInt96(int256 value) internal pure returns (int96 downcasted) {
        downcasted = int96(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(96, value);
        }
    }
    function toInt88(int256 value) internal pure returns (int88 downcasted) {
        downcasted = int88(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(88, value);
        }
    }
    function toInt80(int256 value) internal pure returns (int80 downcasted) {
        downcasted = int80(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(80, value);
        }
    }
    function toInt72(int256 value) internal pure returns (int72 downcasted) {
        downcasted = int72(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(72, value);
        }
    }
    function toInt64(int256 value) internal pure returns (int64 downcasted) {
        downcasted = int64(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(64, value);
        }
    }
    function toInt56(int256 value) internal pure returns (int56 downcasted) {
        downcasted = int56(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(56, value);
        }
    }
    function toInt48(int256 value) internal pure returns (int48 downcasted) {
        downcasted = int48(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(48, value);
        }
    }
    function toInt40(int256 value) internal pure returns (int40 downcasted) {
        downcasted = int40(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(40, value);
        }
    }
    function toInt32(int256 value) internal pure returns (int32 downcasted) {
        downcasted = int32(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(32, value);
        }
    }
    function toInt24(int256 value) internal pure returns (int24 downcasted) {
        downcasted = int24(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(24, value);
        }
    }
    function toInt16(int256 value) internal pure returns (int16 downcasted) {
        downcasted = int16(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(16, value);
        }
    }
    function toInt8(int256 value) internal pure returns (int8 downcasted) {
        downcasted = int8(value);
        if (downcasted != value) {
            revert SafeCastOverflowedIntDowncast(8, value);
        }
    }
    function toInt256(uint256 value) internal pure returns (int256) {
        if (value > uint256(type(int256).max)) {
            revert SafeCastOverflowedUintToInt(value);
        }
        return int256(value);
    }
    function toUint(bool b) internal pure returns (uint256 u) {
        assembly {
            u := iszero(iszero(b))
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
            int256 mask = n >> 255;
            return uint256((n + mask) ^ mask);
        }
    }
}
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 value => uint256) _positions;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 position = set._positions[value];
        if (position != 0) {
            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;
            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[valueIndex] = lastValue;
                set._positions[lastValue] = position;
            }
            set._values.pop();
            delete set._positions[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
    }
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }
    struct Bytes32Set {
        Set _inner;
    }
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;
        assembly {
            result := store
        }
        return result;
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;
        assembly {
            result := store
        }
        return result;
    }
    struct UintSet {
        Set _inner;
    }
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {
            result := store
        }
        return result;
    }
}
abstract contract Owned {
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    address public owner;
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }
    constructor(address _owner) {
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; 
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;
        balanceOf[from] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
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
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");
            allowance[recoveredAddress][spender] = value;
        }
        emit Approval(owner, spender, value);
    }
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }
    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }
    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }
    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        unchecked {
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }
}
abstract contract ERC721 {
    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    string public name;
    string public symbol;
    function tokenURI(uint256 id) public view virtual returns (string memory);
    mapping(uint256 => address) internal _ownerOf;
    mapping(address => uint256) internal _balanceOf;
    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }
    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");
        return _balanceOf[owner];
    }
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");
        getApproved[id] = spender;
        emit Approval(owner, spender, id);
    }
    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");
        require(to != address(0), "INVALID_RECIPIENT");
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );
        unchecked {
            _balanceOf[from]--;
            _balanceOf[to]++;
        }
        _ownerOf[id] = to;
        delete getApproved[id];
        emit Transfer(from, to, id);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || 
            interfaceId == 0x80ac58cd || 
            interfaceId == 0x5b5e139f; 
    }
    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");
        require(_ownerOf[id] == address(0), "ALREADY_MINTED");
        unchecked {
            _balanceOf[to]++;
        }
        _ownerOf[id] = to;
        emit Transfer(address(0), to, id);
    }
    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];
        require(owner != address(0), "NOT_MINTED");
        unchecked {
            _balanceOf[owner]--;
        }
        delete _ownerOf[id];
        delete getApproved[id];
        emit Transfer(owner, address(0), id);
    }
    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}
abstract contract ERC721TokenReceiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver.onERC721Received.selector;
    }
}
library FixedPointMathLib {
    uint256 internal constant MAX_UINT256 = 2**256 - 1;
    uint256 internal constant WAD = 1e18; 
    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); 
    }
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); 
    }
    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); 
    }
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); 
    }
    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }
            z := div(mul(x, y), denominator)
        }
    }
    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }
    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := scalar
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := scalar
                }
                default {
                    z := x
                }
                let half := shr(1, scalar)
                for {
                    n := shr(1, n)
                } n {
                    n := shr(1, n)
                } {
                    if shr(128, x) {
                        revert(0, 0)
                    }
                    let xx := mul(x, x)
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }
                    x := div(xxRound, scalar)
                    if mod(n, 2) {
                        let zx := mul(z, x)
                        if iszero(eq(div(zx, x), z)) {
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            let y := x 
            z := 181 
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }
            z := shr(18, mul(z, add(y, 65536))) 
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := sub(z, lt(div(x, z), z))
        }
    }
    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := mod(x, y)
        }
    }
    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        assembly {
            r := div(x, y)
        }
    }
    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}
abstract contract ReentrancyGuard {
    uint256 private locked = 1;
    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");
        locked = 2;
        _;
        locked = 1;
    }
}
interface IMulticall {
    error MulticallFailed(uint256 i, bytes returndata);
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results);
}
interface ILoanManager {
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external;
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external;
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external;
}
interface IBaseInterestAllocator {
    event Reallocated(uint256 currentIdle, uint256 targetIdle);
    event AllTransfered(uint256 total);
    function getBaseApr() external view returns (uint256);
    function getBaseAprWithUpdate() external returns (uint256);
    function getAssetsAllocated() external view returns (uint256);
    function reallocate(uint256 _currentIdle, uint256 _targetIdle, bool _force) external;
    function transferAll() external;
}
interface IFeeManager {
    struct Fees {
        uint256 managementFee;
        uint256 performanceFee;
    }
    function PRECISION() external view returns (uint256);
    function getFees() external returns (Fees memory);
    function getPendingFees() external returns (Fees memory);
    function setPendingFees(Fees calldata _fee) external;
    function confirmFees(Fees calldata _fees) external;
    function getPendingFeesSetTime() external returns (uint256);
    function processFees(uint256 _principal, uint256 _interest) external returns (uint256);
}
interface IPool {
    struct OptimalIdleRange {
        uint80 min;
        uint80 max;
        uint80 mid;
    }
    event PoolPaused(bool status);
    function getMaxTotalWithdrawalQueues() external returns (uint256);
    function getMinTimeBetweenWithdrawalQueues() external returns (uint256);
    function getBaseInterestAllocator() external returns (address);
    function isActive() external returns (bool);
    function pausePool() external;
    function setBaseInterestAllocator(address _newBaseInterestAllocator) external;
    function confirmBaseInterestAllocator(address _newBaseInterestAllocator) external;
    function getPendingBaseInterestAllocator() external returns (address);
    function getPendingBaseInterestAllocatorSetTime() external returns (uint256);
    function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external;
    function setReallocationBonus(uint256 _newReallocationBonus) external;
    function reallocate() external returns (uint256);
}
interface IPoolOfferHandler {
    error InvalidDurationError();
    error InvalidPrincipalAmountError();
    error InvalidAprError();
    function validateOffer(uint256 _baseRate, bytes calldata _offer)
        external
        returns (uint256 principalAmount, uint256 aprBps);
    function getMaxDuration() external returns (uint32);
}
interface IPoolWithWithdrawalQueues {
    struct DeployedQueue {
        address contractAddress;
        uint96 deployedTime;
    }
    function getDeployedQueue(uint256 _idx) external view returns (DeployedQueue memory);
    function queueClaimAll() external;
    function getPendingQueueIndex() external view returns (uint256);
    function deployWithdrawalQueue() external;
}
abstract contract InputChecker {
    error AddressZeroError();
    function _checkAddressNotZero(address _address) internal pure {
        if (_address == address(0)) {
            revert AddressZeroError();
        }
    }
}
library SafeTransferLib {
    function safeTransferETH(address to, uint256 amount) internal {
        bool success;
        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }
        require(success, "ETH_TRANSFER_FAILED");
    }
    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 68), amount) 
            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }
        require(success, "TRANSFER_FROM_FAILED");
    }
    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 36), amount) 
            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
        require(success, "TRANSFER_FAILED");
    }
    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 36), amount) 
            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
        require(success, "APPROVE_FAILED");
    }
}
abstract contract Multicall is IMulticall {
    function multicall(bytes[] calldata data) external payable override returns (bytes[] memory results) {
        results = new bytes[](data.length);
        bool success;
        for (uint256 i = 0; i < data.length;) {
            (success, results[i]) = address(this).delegatecall(data[i]);
            if (!success) revert MulticallFailed(i, results[i]);
            unchecked {
                ++i;
            }
        }
    }
}
abstract contract TwoStepOwned is Owned {
    event TransferOwnerRequested(address newOwner);
    error TooSoonError();
    error InvalidInputError();
    uint256 public MIN_WAIT_TIME;
    address public pendingOwner;
    uint256 public pendingOwnerTime;
    constructor(address _owner, uint256 _minWaitTime) Owned(_owner) {
        pendingOwnerTime = type(uint256).max;
        MIN_WAIT_TIME = _minWaitTime;
    }
    function requestTransferOwner(address _newOwner) external onlyOwner {
        pendingOwner = _newOwner;
        pendingOwnerTime = block.timestamp;
        emit TransferOwnerRequested(_newOwner);
    }
    function transferOwnership(address newOwner) public override onlyOwner {
        if (pendingOwnerTime + MIN_WAIT_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (pendingOwner != newOwner) {
            revert InvalidInputError();
        }
        owner = newOwner;
        pendingOwner = address(0);
        pendingOwnerTime = type(uint256).max;
        emit OwnershipTransferred(owner, newOwner);
    }
}
library Math {
    enum Rounding {
        Floor, 
        Ceil, 
        Trunc, 
        Expand 
    }
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool success, uint256 result) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
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
        if (b == 0) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        unchecked {
            return a == 0 ? 0 : (a - 1) / b + 1;
        }
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0 = x * y; 
            uint256 prod1; 
            assembly {
                let mm := mulmod(x, y, not(0))
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            if (denominator <= prod1) {
                Panic.panic(denominator == 0 ? Panic.DIVISION_BY_ZERO : Panic.UNDER_OVERFLOW);
            }
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (0 - denominator);
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
        return mulDiv(x, y, denominator) + SafeCast.toUint(unsignedRoundsUp(rounding) && mulmod(x, y, denominator) > 0);
    }
    function invMod(uint256 a, uint256 n) internal pure returns (uint256) {
        unchecked {
            if (n == 0) return 0;
            uint256 remainder = a % n;
            uint256 gcd = n;
            int256 x = 0;
            int256 y = 1;
            while (remainder != 0) {
                uint256 quotient = gcd / remainder;
                (gcd, remainder) = (
                    remainder,
                    gcd - remainder * quotient
                );
                (x, y) = (
                    y,
                    x - y * int256(quotient)
                );
            }
            if (gcd != 1) return 0; 
            return x < 0 ? (n - uint256(-x)) : uint256(x); 
        }
    }
    function modExp(uint256 b, uint256 e, uint256 m) internal view returns (uint256) {
        (bool success, uint256 result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }
    function tryModExp(uint256 b, uint256 e, uint256 m) internal view returns (bool success, uint256 result) {
        if (m == 0) return (false, 0);
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x20)
            mstore(add(ptr, 0x20), 0x20)
            mstore(add(ptr, 0x40), 0x20)
            mstore(add(ptr, 0x60), b)
            mstore(add(ptr, 0x80), e)
            mstore(add(ptr, 0xa0), m)
            success := staticcall(gas(), 0x05, ptr, 0xc0, 0x00, 0x20)
            result := mload(0x00)
        }
    }
    function modExp(bytes memory b, bytes memory e, bytes memory m) internal view returns (bytes memory) {
        (bool success, bytes memory result) = tryModExp(b, e, m);
        if (!success) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return result;
    }
    function tryModExp(
        bytes memory b,
        bytes memory e,
        bytes memory m
    ) internal view returns (bool success, bytes memory result) {
        if (_zeroBytes(m)) return (false, new bytes(0));
        uint256 mLen = m.length;
        result = abi.encodePacked(b.length, e.length, mLen, b, e, m);
        assembly {
            let dataPtr := add(result, 0x20)
            success := staticcall(gas(), 0x05, dataPtr, mload(result), dataPtr, mLen)
            mstore(result, mLen)
            mstore(0x40, add(dataPtr, mLen))
        }
    }
    function _zeroBytes(bytes memory byteArray) private pure returns (bool) {
        for (uint256 i = 0; i < byteArray.length; ++i) {
            if (byteArray[i] != 0) {
                return false;
            }
        }
        return true;
    }
    function sqrt(uint256 a) internal pure returns (uint256) {
        unchecked {
            if (a <= 1) {
                return a;
            }
            uint256 aa = a;
            uint256 xn = 1;
            if (aa >= (1 << 128)) {
                aa >>= 128;
                xn <<= 64;
            }
            if (aa >= (1 << 64)) {
                aa >>= 64;
                xn <<= 32;
            }
            if (aa >= (1 << 32)) {
                aa >>= 32;
                xn <<= 16;
            }
            if (aa >= (1 << 16)) {
                aa >>= 16;
                xn <<= 8;
            }
            if (aa >= (1 << 8)) {
                aa >>= 8;
                xn <<= 4;
            }
            if (aa >= (1 << 4)) {
                aa >>= 4;
                xn <<= 2;
            }
            if (aa >= (1 << 2)) {
                xn <<= 1;
            }
            xn = (3 * xn) >> 1; 
            xn = (xn + a / xn) >> 1; 
            xn = (xn + a / xn) >> 1; 
            xn = (xn + a / xn) >> 1; 
            xn = (xn + a / xn) >> 1; 
            xn = (xn + a / xn) >> 1; 
            xn = (xn + a / xn) >> 1; 
            return xn - SafeCast.toUint(xn > a / xn);
        }
    }
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && result * result < a);
        }
    }
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 exp;
        unchecked {
            exp = 128 * SafeCast.toUint(value > (1 << 128) - 1);
            value >>= exp;
            result += exp;
            exp = 64 * SafeCast.toUint(value > (1 << 64) - 1);
            value >>= exp;
            result += exp;
            exp = 32 * SafeCast.toUint(value > (1 << 32) - 1);
            value >>= exp;
            result += exp;
            exp = 16 * SafeCast.toUint(value > (1 << 16) - 1);
            value >>= exp;
            result += exp;
            exp = 8 * SafeCast.toUint(value > (1 << 8) - 1);
            value >>= exp;
            result += exp;
            exp = 4 * SafeCast.toUint(value > (1 << 4) - 1);
            value >>= exp;
            result += exp;
            exp = 2 * SafeCast.toUint(value > (1 << 2) - 1);
            value >>= exp;
            result += exp;
            result += SafeCast.toUint(value > 1);
        }
        return result;
    }
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << result < value);
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
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 10 ** result < value);
        }
    }
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 isGt;
        unchecked {
            isGt = SafeCast.toUint(value > (1 << 128) - 1);
            value >>= isGt * 128;
            result += isGt * 16;
            isGt = SafeCast.toUint(value > (1 << 64) - 1);
            value >>= isGt * 64;
            result += isGt * 8;
            isGt = SafeCast.toUint(value > (1 << 32) - 1);
            value >>= isGt * 32;
            result += isGt * 4;
            isGt = SafeCast.toUint(value > (1 << 16) - 1);
            value >>= isGt * 16;
            result += isGt * 2;
            result += SafeCast.toUint(value > (1 << 8) - 1);
        }
        return result;
    }
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + SafeCast.toUint(unsignedRoundsUp(rounding) && 1 << (result << 3) < value);
        }
    }
    function unsignedRoundsUp(Rounding rounding) internal pure returns (bool) {
        return uint8(rounding) % 2 == 1;
    }
}
interface ILoanLiquidator {
    function liquidateLoan(
        uint256 _loanId,
        address _contract,
        uint256 _tokenId,
        address _asset,
        uint96 _duration,
        address _originator
    ) external returns (bytes memory);
}
interface IBaseLoan {
    struct ImprovementMinimum {
        uint256 principalAmount;
        uint256 interest;
        uint256 duration;
    }
    struct OfferValidator {
        address validator;
        bytes arguments;
    }
    function getTotalLoansIssued() external view returns (uint256);
    function cancelOffer(uint256 _offerId) external;
    function cancelAllOffers(uint256 _minOfferId) external;
    function cancelRenegotiationOffer(uint256 _renegotiationId) external;
}
interface IMultiSourceLoan {
    struct LoanOffer {
        uint256 offerId;
        address lender;
        uint256 fee;
        uint256 capacity;
        address nftCollateralAddress;
        uint256 nftCollateralTokenId;
        address principalAddress;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
        uint256 maxSeniorRepayment;
        IBaseLoan.OfferValidator[] validators;
    }
    struct OfferExecution {
        LoanOffer offer;
        uint256 amount;
        bytes lenderOfferSignature;
    }
    struct ExecutionData {
        OfferExecution[] offerExecution;
        uint256 tokenId;
        uint256 duration;
        uint256 expirationTime;
        address principalReceiver;
        bytes callbackData;
    }
    struct LoanExecutionData {
        ExecutionData executionData;
        address borrower;
        bytes borrowerOfferSignature;
    }
    struct SignableRepaymentData {
        uint256 loanId;
        bytes callbackData;
        bool shouldDelegate;
    }
    struct LoanRepaymentData {
        SignableRepaymentData data;
        Loan loan;
        bytes borrowerSignature;
    }
    struct Tranche {
        uint256 loanId;
        uint256 floor;
        uint256 principalAmount;
        address lender;
        uint256 accruedInterest;
        uint256 startTime;
        uint256 aprBps;
    }
    struct Loan {
        address borrower;
        uint256 nftCollateralTokenId;
        address nftCollateralAddress;
        address principalAddress;
        uint256 principalAmount;
        uint256 startTime;
        uint256 duration;
        Tranche[] tranche;
        uint256 protocolFee;
    }
    struct RenegotiationOffer {
        uint256 renegotiationId;
        uint256 loanId;
        address lender;
        uint256 fee;
        uint256[] trancheIndex;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
    }
    event LoanLiquidated(uint256 loanId);
    event LoanEmitted(uint256 loanId, uint256[] offerId, Loan loan, uint256 fee);
    event LoanRefinanced(uint256 renegotiationId, uint256 oldLoanId, uint256 newLoanId, Loan loan, uint256 fee);
    event LoanRepaid(uint256 loanId, uint256 totalRepayment, uint256 fee);
    event LoanRefinancedFromNewOffers(
        uint256 loanId, uint256 newLoanId, Loan loan, uint256[] offerIds, uint256 totalFee
    );
    event TranchesMerged(Loan loan, uint256 minTranche, uint256 maxTranche);
    event DelegateRegistryUpdated(address newdelegateRegistry);
    event Delegated(uint256 loanId, address delegate, bool value);
    event FlashActionContractUpdated(address newFlashActionContract);
    event FlashActionExecuted(uint256 loanId, address target, bytes data);
    event RevokeDelegate(address delegate, address collection, uint256 tokenId);
    event MinLockPeriodUpdated(uint256 minLockPeriod);
    function emitLoan(LoanExecutionData calldata _loanExecutionData) external returns (uint256, Loan memory);
    function refinanceFull(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);
    function addNewTranche(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);
    function mergeTranches(uint256 _loanId, Loan memory _loan, uint256 _minTranche, uint256 _maxTranche)
        external
        returns (uint256, Loan memory);
    function refinancePartial(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)
        external
        returns (uint256, Loan memory);
    function refinanceFromLoanExecutionData(
        uint256 _loanId,
        Loan calldata _loan,
        LoanExecutionData calldata _loanExecutionData
    ) external returns (uint256, Loan memory);
    function repayLoan(LoanRepaymentData calldata _repaymentData) external;
    function liquidateLoan(uint256 _loanId, Loan calldata _loan) external returns (bytes memory);
    function getMaxTranches() external view returns (uint256);
    function setMinLockPeriod(uint256 _minLockPeriod) external;
    function getMinLockPeriod() external view returns (uint256);
    function getDelegateRegistry() external view returns (address);
    function setDelegateRegistry(address _newDelegationRegistry) external;
    function delegate(uint256 _loanId, Loan calldata _loan, address _delegate, bytes32 _rights, bool _value) external;
    function revokeDelegate(address _delegate, address _collection, uint256 _tokenId) external;
    function getFlashActionContract() external view returns (address);
    function setFlashActionContract(address _newFlashActionContract) external;
    function getLoanHash(uint256 _loanId) external view returns (bytes32);
    function executeFlashAction(uint256 _loanId, Loan calldata _loan, address _target, bytes calldata _data) external;
    function loanLiquidated(uint256 _loanId, Loan calldata _loan) external;
}
abstract contract ERC4626 is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    ERC20 public immutable asset;
    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); 
        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); 
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        asset.safeTransfer(receiver, assets);
    }
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        asset.safeTransfer(receiver, assets);
    }
    function totalAssets() public view virtual returns (uint256);
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }
    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}
    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
library Strings {
    bytes16 private constant HEX_DIGITS = "0123456789abcdef";
    uint8 private constant ADDRESS_LENGTH = 20;
    error StringsInsufficientHexLength(uint256 value, uint256 length);
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
                    mstore8(ptr, byte(mod(value, 10), HEX_DIGITS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
    function toStringSigned(int256 value) internal pure returns (string memory) {
        return string.concat(value < 0 ? "-" : "", toString(SignedMath.abs(value)));
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        uint256 localValue = value;
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = HEX_DIGITS[localValue & 0xf];
            localValue >>= 4;
        }
        if (localValue != 0) {
            revert StringsInsufficientHexLength(value, length);
        }
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), ADDRESS_LENGTH);
    }
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return bytes(a).length == bytes(b).length && keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
library Interest {
    using FixedPointMathLib for uint256;
    uint256 private constant _PRECISION = 10000;
    uint256 private constant _SECONDS_PER_YEAR = 31536000;
    function getInterest(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (uint256) {
        return _getInterest(_loanOffer.principalAmount, _loanOffer.aprBps, _loanOffer.duration);
    }
    function getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) internal pure returns (uint256) {
        return _getInterest(_amount, _aprBps, _duration);
    }
    function getTotalOwed(IMultiSourceLoan.Loan memory _loan, uint256 _timestamp) internal pure returns (uint256) {
        uint256 owed = 0;
        for (uint256 i = 0; i < _loan.tranche.length;) {
            IMultiSourceLoan.Tranche memory tranche = _loan.tranche[i];
            owed += tranche.principalAmount + tranche.accruedInterest
                + _getInterest(tranche.principalAmount, tranche.aprBps, _timestamp - tranche.startTime);
            unchecked {
                ++i;
            }
        }
        return owed;
    }
    function _getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) private pure returns (uint256) {
        return _amount.mulDivUp(_aprBps * _duration, _PRECISION * _SECONDS_PER_YEAR);
    }
}
abstract contract LoanManager is ILoanManager, InputChecker, TwoStepOwned {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct PendingCaller {
        address caller;
        bool isLoanContract;
    }
    uint256 public immutable UPDATE_WAITING_TIME;
    PendingCaller[] public getPendingAcceptedCallers;
    uint256 public getPendingAcceptedCallersSetTime;
    EnumerableSet.AddressSet internal _acceptedCallers;
    mapping(address => bool) internal _isLoanContract;
    address public getUnderwriter;
    address public getPendingUnderwriter;
    uint256 public getPendingUnderwriterSetTime;
    event RequestCallersAdded(PendingCaller[] callers);
    event CallersAdded(PendingCaller[] callers);
    event PendingUnderwriterSet(address underwriter);
    event UnderwriterSet(address underwriter);
    error CallerNotAccepted();
    constructor(address _owner, address __underwriter, uint256 _updateWaitingTime)
        TwoStepOwned(_owner, _updateWaitingTime)
    {
        _checkAddressNotZero(__underwriter);
        getUnderwriter = __underwriter;
        UPDATE_WAITING_TIME = _updateWaitingTime;
        getPendingUnderwriterSetTime = type(uint256).max;
        getPendingAcceptedCallersSetTime = type(uint256).max;
    }
    modifier onlyAcceptedCallers() {
        if (!_acceptedCallers.contains(msg.sender)) {
            revert CallerNotAccepted();
        }
        _;
    }
    function requestAddCallers(PendingCaller[] calldata _callers) external onlyOwner {
        getPendingAcceptedCallers = _callers;
        getPendingAcceptedCallersSetTime = block.timestamp;
        emit RequestCallersAdded(_callers);
    }
    function addCallers(PendingCaller[] calldata _callers) external onlyOwner {
        if (getPendingAcceptedCallersSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        PendingCaller[] memory pendingCallers = getPendingAcceptedCallers;
        for (uint256 i = 0; i < _callers.length;) {
            PendingCaller calldata caller = _callers[i];
            if (pendingCallers[i].caller != caller.caller || pendingCallers[i].isLoanContract != caller.isLoanContract)
            {
                revert InvalidInputError();
            }
            _acceptedCallers.add(caller.caller);
            _isLoanContract[caller.caller] = caller.isLoanContract;
            afterCallerAdded(caller.caller);
            unchecked {
                ++i;
            }
        }
        emit CallersAdded(_callers);
    }
    function isCallerAccepted(address _caller) external view returns (bool) {
        return _acceptedCallers.contains(_caller);
    }
    function setUnderwriter(address __underwriter) external onlyOwner {
        _checkAddressNotZero(__underwriter);
        getPendingUnderwriter = __underwriter;
        getPendingUnderwriterSetTime = block.timestamp;
        emit PendingUnderwriterSet(__underwriter);
    }
    function confirmUnderwriter(address __underwriter) external onlyOwner {
        if (getPendingUnderwriterSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (getPendingUnderwriter != __underwriter) {
            revert InvalidInputError();
        }
        getUnderwriter = __underwriter;
        getPendingUnderwriter = address(0);
        getPendingUnderwriterSetTime = type(uint256).max;
        emit UnderwriterSet(__underwriter);
    }
    function afterCallerAdded(address _caller) internal virtual;
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external virtual;
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external virtual;
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external virtual;
}
contract WithdrawalQueue is ERC721, Multicall {
    using SafeTransferLib for ERC20;
    string private constant _NAME = "GPoolWithdrawalQueue";
    string private constant _SYMBOL = "WQ";
    string private constant _BASE_URI = "https:
    address public immutable getPool;
    uint256 public getTotalShares;
    uint256 public getNextTokenId;
    mapping(uint256 tokenId => uint256 shares) public getShares;
    mapping(uint256 tokenId => uint256 withdrawn) public getWithdrawn;
    mapping(uint256 tokenId => uint256 unlockTime) public getUnlockTime;
    ERC20 private immutable _asset;
    uint256 private _totalWithdrawn;
    event WithdrawalPositionMinted(uint256 tokenId, address to, uint256 shares);
    event Withdrawn(address to, uint256 tokenId, uint256 available);
    event WithdrawalLocked(uint256 tokenId, uint256 unlockTime);
    error PoolOnlyCallableError();
    error NotApprovedOrOwnerError();
    error WithdrawalsLockedError(uint256 tokenId, uint256 unlockTime);
    error CanOnlyExtendWithdrawalError(uint256 tokenId, uint256 unlockTime);
    constructor(ERC20 __asset) ERC721(_NAME, _SYMBOL) {
        getPool = msg.sender;
        _asset = __asset;
    }
    function mint(address _to, uint256 _shares) external returns (uint256) {
        if (msg.sender != getPool) {
            revert PoolOnlyCallableError();
        }
        _mint(_to, getNextTokenId);
        getShares[getNextTokenId] = _shares;
        getTotalShares += _shares;
        emit WithdrawalPositionMinted(getNextTokenId, _to, _shares);
        return getNextTokenId++;
    }
    function tokenURI(uint256 _id) public pure override returns (string memory) {
        return string.concat(_BASE_URI, Strings.toString(_id));
    }
    function withdraw(address _to, uint256 _tokenId) external returns (uint256) {
        uint256 unlockTime = getUnlockTime[_tokenId];
        if (unlockTime > block.timestamp) {
            revert WithdrawalsLockedError(_tokenId, unlockTime);
        }
        address caller = msg.sender;
        address owner = _ownerOf[_tokenId];
        if (!(caller == owner || isApprovedForAll[owner][caller] || caller == getApproved[_tokenId])) {
            revert NotApprovedOrOwnerError();
        }
        uint256 available = _getAvailable(_tokenId);
        getWithdrawn[_tokenId] += available;
        _totalWithdrawn += available;
        _asset.safeTransfer(_to, available);
        emit Withdrawn(_to, _tokenId, available);
        return available;
    }
    function getAvailable(uint256 _tokenId) external view returns (uint256) {
        return _getAvailable(_tokenId);
    }
    function lockWithdrawals(uint256 _tokenId, uint256 _time) external {
        address owner = _ownerOf[_tokenId];
        if (!(msg.sender == owner || isApprovedForAll[owner][msg.sender] || msg.sender == getApproved[_tokenId])) {
            revert NotApprovedOrOwnerError();
        }
        if (block.timestamp + _time < getUnlockTime[_tokenId]) {
            revert CanOnlyExtendWithdrawalError(_tokenId, getUnlockTime[_tokenId]);
        }
        uint256 unlockTime = block.timestamp + _time;
        getUnlockTime[_tokenId] = unlockTime;
        emit WithdrawalLocked(_tokenId, unlockTime);
    }
    function _getAvailable(uint256 _tokenId) private view returns (uint256) {
        return getShares[_tokenId] * _getWithdrawablePerShare() - getWithdrawn[_tokenId];
    }
    function _getWithdrawablePerShare() private view returns (uint256) {
        return (_totalWithdrawn + _asset.balanceOf(address(this))) / getTotalShares;
    }
}
contract Pool is ERC4626, InputChecker, IPool, IPoolWithWithdrawalQueues, LoanManager, ReentrancyGuard {
    using EnumerableSet for EnumerableSet.AddressSet;
    using FixedPointMathLib for uint128;
    using FixedPointMathLib for uint256;
    using Interest for uint256;
    using SafeTransferLib for ERC20;
    uint80 public constant PRINCIPAL_PRECISION = 1e20;
    uint256 private constant _SECONDS_PER_YEAR = 31536000;
    uint16 private constant _BPS = 10000;
    uint16 private _MAX_BONUS = 500;
    uint256 public getCollectedFees;
    struct OutstandingValues {
        uint128 principalAmount;
        uint128 accruedInterest;
        uint128 sumApr;
        uint128 lastTs;
    }
    struct QueueAccounting {
        uint128 thisQueueFraction;
        uint128 netPoolFraction;
    }
    uint256 private constant _LOAN_BUFFER_TIME = 7 days;
    address public immutable getFeeManager;
    uint256 public immutable getMaxTotalWithdrawalQueues;
    uint256 public immutable getMinTimeBetweenWithdrawalQueues;
    uint256 public getReallocationBonus;
    address public getPendingBaseInterestAllocator;
    address public getBaseInterestAllocator;
    uint256 public getPendingBaseInterestAllocatorSetTime;
    bool public isActive;
    OptimalIdleRange public getOptimalIdleRange;
    mapping(uint256 queueIndex => mapping(address loanContract => uint256 loanId)) public getLastLoanId;
    mapping(uint256 queueIndex => uint256 totalReceived) public getTotalReceived;
    uint256 public getAvailableToWithdraw;
    DeployedQueue[] private _deployedQueues;
    OutstandingValues private _outstandingValues;
    uint256 private _pendingQueueIndex;
    OutstandingValues[] private _queueOutstandingValues;
    QueueAccounting[] private _queueAccounting;
    error PoolStatusError();
    error InsufficientAssetsError();
    error AllocationAlreadyOptimalError();
    error CannotDeployQueueTooSoonError();
    error NoSharesPendingWithdrawalError();
    event ReallocationBonusUpdated(uint256 newReallocationBonus);
    event PendingBaseInterestAllocatorSet(address newBaseInterestAllocator);
    event BaseInterestAllocatorSet(address newBaseInterestAllocator);
    event OptimalIdleRangeSet(OptimalIdleRange optimalIdleRange);
    event QueueClaimed(address queue, uint256 amount);
    event Reallocated(uint256 delta, uint256 bonusShares);
    constructor(
        address _feeManager,
        address _offerHandler,
        uint256 _waitingTimeBetweenUpdates,
        OptimalIdleRange memory _optimalIdleRange,
        uint256 _maxTotalWithdrawalQueues,
        uint256 _reallocationBonus,
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset, _name, _symbol) LoanManager(tx.origin, _offerHandler, _waitingTimeBetweenUpdates) {
        getFeeManager = _feeManager;
        isActive = true;
        _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) / 2;
        getOptimalIdleRange = _optimalIdleRange;
        getPendingBaseInterestAllocatorSetTime = type(uint256).max;
        if (_reallocationBonus > _MAX_BONUS) {
            revert InvalidInputError();
        }
        getReallocationBonus = _reallocationBonus;
        getMaxTotalWithdrawalQueues = _maxTotalWithdrawalQueues;
        getMinTimeBetweenWithdrawalQueues = (IPoolOfferHandler(_offerHandler).getMaxDuration() + _LOAN_BUFFER_TIME)
            .mulDivUp(1, _maxTotalWithdrawalQueues);
        _deployedQueues = new DeployedQueue[](_maxTotalWithdrawalQueues + 1);
        DeployedQueue memory deployedQueue = _deployQueue(_asset);
        _deployedQueues[_pendingQueueIndex] = deployedQueue;
        _queueOutstandingValues = new OutstandingValues[](_maxTotalWithdrawalQueues + 1);
        _queueAccounting = new QueueAccounting[](_maxTotalWithdrawalQueues + 1);
        _asset.approve(address(_feeManager), type(uint256).max);
    }
    function pausePool() external onlyOwner {
        isActive = !isActive;
        emit PoolPaused(isActive);
    }
    function setOptimalIdleRange(OptimalIdleRange memory _optimalIdleRange) external onlyOwner {
        _optimalIdleRange.mid = (_optimalIdleRange.min + _optimalIdleRange.max) / 2;
        getOptimalIdleRange = _optimalIdleRange;
        emit OptimalIdleRangeSet(_optimalIdleRange);
    }
    function setBaseInterestAllocator(address _newBaseInterestAllocator) external onlyOwner {
        _checkAddressNotZero(_newBaseInterestAllocator);
        getPendingBaseInterestAllocator = _newBaseInterestAllocator;
        getPendingBaseInterestAllocatorSetTime = block.timestamp;
        emit PendingBaseInterestAllocatorSet(_newBaseInterestAllocator);
    }
    function confirmBaseInterestAllocator(address _newBaseInterestAllocator) external {
        address cachedAllocator = getBaseInterestAllocator;
        if (cachedAllocator != address(0)) {
            if (getPendingBaseInterestAllocatorSetTime + UPDATE_WAITING_TIME > block.timestamp) {
                revert TooSoonError();
            }
            if (getPendingBaseInterestAllocator != _newBaseInterestAllocator) {
                revert InvalidInputError();
            }
            IBaseInterestAllocator(cachedAllocator).transferAll();
            asset.approve(cachedAllocator, 0);
        }
        asset.approve(_newBaseInterestAllocator, type(uint256).max);
        getBaseInterestAllocator = _newBaseInterestAllocator;
        getPendingBaseInterestAllocator = address(0);
        getPendingBaseInterestAllocatorSetTime = type(uint256).max;
        emit BaseInterestAllocatorSet(_newBaseInterestAllocator);
    }
    function setReallocationBonus(uint256 _newReallocationBonus) external onlyOwner {
        if (_newReallocationBonus > _MAX_BONUS) {
            revert InvalidInputError();
        }
        getReallocationBonus = _newReallocationBonus;
        emit ReallocationBonusUpdated(_newReallocationBonus);
    }
    function afterCallerAdded(address _caller) internal override onlyOwner {
        asset.approve(_caller, type(uint256).max);
    }
    function totalAssets() public view override returns (uint256) {
        return _getUndeployedAssets() + _getTotalOutstandingValue();
    }
    function getOutstandingValues() external view returns (OutstandingValues memory) {
        return _outstandingValues;
    }
    function getDeployedQueue(uint256 _idx) external view returns (DeployedQueue memory) {
        return _deployedQueues[_idx];
    }
    function getOutstandingValuesForQueue(uint256 _idx) external view returns (OutstandingValues memory) {
        return _queueOutstandingValues[_idx];
    }
    function getPendingQueueIndex() external view returns (uint256) {
        return _pendingQueueIndex;
    }
    function getAccountingValuesForQueue(uint256 _idx) external view returns (QueueAccounting memory) {
        return _queueAccounting[_idx];
    }
    function withdraw(uint256 assets, address receiver, address owner) public override returns (uint256 shares) {
        shares = previewWithdraw(assets); 
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        _withdraw(owner, receiver, assets, shares);
    }
    function redeem(uint256 shares, address receiver, address owner) public override returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
        _withdraw(owner, receiver, assets, shares);
    }
    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        _preDeposit();
        return super.deposit(assets, receiver);
    }
    function mint(uint256 shares, address receiver) public override returns (uint256) {
        _preDeposit();
        return super.mint(shares, receiver);
    }
    function queueClaimAll() external nonReentrant {
        _queueClaimAll(getAvailableToWithdraw, _pendingQueueIndex);
    }
    function deployWithdrawalQueue() external nonReentrant {
        uint256 pendingQueueIndex = _pendingQueueIndex;
        DeployedQueue memory queue = _deployedQueues[pendingQueueIndex];
        if (block.timestamp - queue.deployedTime < getMinTimeBetweenWithdrawalQueues) {
            revert TooSoonError();
        }
        uint256 sharesPendingWithdrawal = WithdrawalQueue(queue.contractAddress).getTotalShares();
        if (sharesPendingWithdrawal == 0) {
            revert NoSharesPendingWithdrawalError();
        }
        uint256 totalQueues = _deployedQueues.length;
        uint256 lastQueueIndex = (pendingQueueIndex + 1) % totalQueues;
        uint256 totalSupplyCached = totalSupply;
        uint256 proRataLiquid = _getUndeployedAssets().mulDivDown(sharesPendingWithdrawal, totalSupplyCached);
        uint128 poolFraction =
            uint128((totalSupplyCached - sharesPendingWithdrawal).mulDivDown(PRINCIPAL_PRECISION, totalSupplyCached));
        _queueAccounting[pendingQueueIndex] = QueueAccounting(
            uint128(sharesPendingWithdrawal.mulDivDown(PRINCIPAL_PRECISION, totalSupplyCached)), poolFraction
        );
        _queueClaimAll(proRataLiquid + getAvailableToWithdraw, pendingQueueIndex);
        asset.safeTransfer(queue.contractAddress, proRataLiquid);
        _deployedQueues[lastQueueIndex] = _deployQueue(asset);
        uint256 baseIdx = pendingQueueIndex + totalQueues;
        for (uint256 i = 1; i < totalQueues - 1;) {
            uint256 idx = (baseIdx - i) % totalQueues;
            if (_deployedQueues[idx].contractAddress == address(0)) {
                break;
            }
            QueueAccounting memory thisQueueAccounting = _queueAccounting[idx];
            uint128 newQueueFraction =
                uint128(thisQueueAccounting.netPoolFraction.mulDivDown(sharesPendingWithdrawal, totalSupplyCached));
            _queueAccounting[idx].netPoolFraction -= newQueueFraction;
            unchecked {
                ++i;
            }
        }
        _queueOutstandingValues[pendingQueueIndex] = _outstandingValues;
        delete _queueOutstandingValues[lastQueueIndex];
        delete _outstandingValues;
        _updateLoanLastIds();
        _pendingQueueIndex = lastQueueIndex;
        unchecked {
            totalSupply -= sharesPendingWithdrawal;
        }
    }
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external override onlyAcceptedCallers {
        if (!isActive) {
            revert PoolStatusError();
        }
        uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw;
        uint256 baseRateBalance = IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated();
        uint256 undeployedAssets = currentBalance + baseRateBalance;
        (uint256 principalAmount, uint256 apr) = IPoolOfferHandler(getUnderwriter).validateOffer(
            IBaseInterestAllocator(getBaseInterestAllocator).getBaseAprWithUpdate(), _offer
        );
        if (principalAmount > undeployedAssets) {
            revert InsufficientAssetsError();
        } else if (principalAmount > currentBalance) {
            IBaseInterestAllocator(getBaseInterestAllocator).reallocate(
                currentBalance, principalAmount - currentBalance, true
            );
        }
        _outstandingValues = _getNewLoanAccounting(principalAmount, _netApr(apr, _protocolFee));
    }
    function reallocate() external nonReentrant returns (uint256) {
        (uint256 currentBalance, uint256 targetIdle) = _reallocate();
        uint256 delta = currentBalance > targetIdle ? currentBalance - targetIdle : targetIdle - currentBalance;
        uint256 shares = delta.mulDivDown(totalSupply * getReallocationBonus, totalAssets() * _BPS);
        _mint(msg.sender, shares);
        emit Reallocated(delta, shares);
        return shares;
    }
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256,
        uint256 _protocolFee,
        uint256 _startTime
    ) external override onlyAcceptedCallers {
        uint256 netApr = _netApr(_apr, _protocolFee);
        uint256 interestEarned = _principalAmount.getInterest(netApr, block.timestamp - _startTime);
        uint256 received = _principalAmount + interestEarned;
        uint256 fees = IFeeManager(getFeeManager).processFees(_principalAmount, interestEarned);
        getCollectedFees += fees;
        _loanTermination(msg.sender, _loanId, _principalAmount, netApr, interestEarned, received - fees);
    }
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external override onlyAcceptedCallers {
        uint256 netApr = _netApr(_apr, _protocolFee);
        uint256 interestEarned = _principalAmount.getInterest(netApr, block.timestamp - _startTime);
        uint256 fees = IFeeManager(getFeeManager).processFees(_received, 0);
        getCollectedFees += fees;
        _loanTermination(msg.sender, _loanId, _principalAmount, netApr, interestEarned, _received - fees);
    }
    function _getTotalOutstandingValue() private view returns (uint256) {
        uint256 totalOutstandingValue = _getOutstandingValue(_outstandingValues);
        uint256 totalQueues = _queueOutstandingValues.length;
        uint256 newest = (_pendingQueueIndex + totalQueues - 1) % totalQueues;
        for (uint256 i; i < totalQueues - 1;) {
            uint256 idx = (newest + totalQueues - i) % totalQueues;
            OutstandingValues memory queueOutstandingValues = _queueOutstandingValues[idx];
            totalOutstandingValue += _getOutstandingValue(queueOutstandingValues).mulDivDown(
                _queueAccounting[idx].netPoolFraction, PRINCIPAL_PRECISION
            );
            unchecked {
                ++i;
            }
        }
        return totalOutstandingValue;
    }
    function _getOutstandingValue(OutstandingValues memory __outstandingValues) private view returns (uint256) {
        uint256 principal = uint256(__outstandingValues.principalAmount);
        return principal + uint256(__outstandingValues.accruedInterest)
            + principal.getInterest(
                uint256(_outstandingApr(__outstandingValues)), block.timestamp - uint256(__outstandingValues.lastTs)
            );
    }
    function _getNewLoanAccounting(uint256 _principalAmount, uint256 _apr)
        private
        view
        returns (OutstandingValues memory outstandingValues)
    {
        outstandingValues = _outstandingValues;
        outstandingValues.accruedInterest += uint128(
            uint256(outstandingValues.principalAmount).getInterest(
                uint256(_outstandingApr(outstandingValues)), block.timestamp - uint256(outstandingValues.lastTs)
            )
        );
        outstandingValues.sumApr += uint128(_apr * _principalAmount);
        outstandingValues.principalAmount += uint128(_principalAmount);
        outstandingValues.lastTs = uint128(block.timestamp);
    }
    function _loanTermination(
        address _loanContract,
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _interestEarned,
        uint256 _received
    ) private {
        uint256 pendingIndex = _pendingQueueIndex;
        uint256 totalQueues = getMaxTotalWithdrawalQueues + 1;
        uint256 idx;
        uint256 i;
        for (i = 1; i < totalQueues;) {
            idx = (pendingIndex + i) % totalQueues;
            if (getLastLoanId[idx][_loanContract] >= _loanId) {
                break;
            }
            unchecked {
                ++i;
            }
        }
        if (i == totalQueues) {
            _outstandingValues =
                _updateOutstandingValuesOnTermination(_outstandingValues, _principalAmount, _apr, _interestEarned);
            return;
        } else {
            uint256 pendingToQueue =
                _received.mulDivDown(PRINCIPAL_PRECISION - _queueAccounting[idx].netPoolFraction, PRINCIPAL_PRECISION);
            getTotalReceived[idx] += _received;
            getAvailableToWithdraw += pendingToQueue;
            _queueOutstandingValues[idx] = _updateOutstandingValuesOnTermination(
                _queueOutstandingValues[idx], _principalAmount, _apr, _interestEarned
            );
        }
    }
    function _preDeposit() private view {
        if (!isActive) {
            revert PoolStatusError();
        }
    }
    function _getUndeployedAssets() private view returns (uint256) {
        return asset.balanceOf(address(this)) + IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated()
            - getAvailableToWithdraw - getCollectedFees;
    }
    function _reallocate() private returns (uint256, uint256) {
        uint256 currentBalance = asset.balanceOf(address(this)) - getAvailableToWithdraw;
        if (currentBalance == 0) {
            revert AllocationAlreadyOptimalError();
        }
        uint256 baseRateBalance = IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated();
        uint256 total = currentBalance + baseRateBalance;
        uint256 fraction = currentBalance.mulDivDown(PRINCIPAL_PRECISION, total);
        OptimalIdleRange memory optimalIdleRange = getOptimalIdleRange;
        if (fraction >= optimalIdleRange.min && fraction < optimalIdleRange.max) {
            revert AllocationAlreadyOptimalError();
        }
        uint256 targetIdle = total.mulDivDown(optimalIdleRange.mid, PRINCIPAL_PRECISION);
        IBaseInterestAllocator(getBaseInterestAllocator).reallocate(currentBalance, targetIdle, false);
        return (currentBalance, targetIdle);
    }
    function _reallocateOnWithdrawal(uint256 _withdrawn) private {
        uint256 currentBalance = asset.balanceOf(address(this));
        if (currentBalance > _withdrawn) {
            return;
        }
        uint256 baseRateBalance = IBaseInterestAllocator(getBaseInterestAllocator).getAssetsAllocated();
        uint256 finalBalance = currentBalance + baseRateBalance - _withdrawn;
        uint256 targetIdle = finalBalance.mulDivDown(getOptimalIdleRange.mid, PRINCIPAL_PRECISION);
        IBaseInterestAllocator(getBaseInterestAllocator).reallocate(currentBalance, _withdrawn + targetIdle, true);
    }
    function _netApr(uint256 _apr, uint256 _protocolFee) private pure returns (uint256) {
        return _apr.mulDivDown(_BPS - _protocolFee, _BPS);
    }
    function _deployQueue(ERC20 _asset) private returns (DeployedQueue memory) {
        address deployed = address(new WithdrawalQueue(_asset));
        return DeployedQueue(deployed, uint96(block.timestamp));
    }
    function _burn(address from, uint256 amount) internal override {
        balanceOf[from] -= amount;
        emit Transfer(from, address(0), amount);
    }
    function _updateLoanLastIds() private {
        for (uint256 i; i < _acceptedCallers.length();) {
            address caller = _acceptedCallers.at(i);
            if (_isLoanContract[caller]) {
                getLastLoanId[_pendingQueueIndex][caller] = IBaseLoan(caller).getTotalLoansIssued();
            }
            unchecked {
                ++i;
            }
        }
    }
    function _updatePendingWithdrawalWithQueue(
        uint256 _idx,
        uint256 _cachedPendingQueueIndex,
        uint256[] memory _pendingWithdrawal
    ) private returns (uint256[] memory) {
        uint256 totalReceived = getTotalReceived[_idx];
        uint256 totalQueues = getMaxTotalWithdrawalQueues + 1;
        if (totalReceived == 0) {
            return _pendingWithdrawal;
        }
        getTotalReceived[_idx] = 0;
        for (uint256 i; i < totalQueues;) {
            uint256 secondIdx = (_idx + i) % totalQueues;
            QueueAccounting memory queueAccounting = _queueAccounting[secondIdx];
            if (queueAccounting.thisQueueFraction == 0) {
                unchecked {
                    ++i;
                }
                continue;
            }
            if (secondIdx == _cachedPendingQueueIndex + 1) {
                break;
            }
            uint256 pendingForQueue = totalReceived.mulDivDown(queueAccounting.thisQueueFraction, PRINCIPAL_PRECISION);
            totalReceived -= pendingForQueue;
            _pendingWithdrawal[secondIdx] = pendingForQueue;
            unchecked {
                ++i;
            }
        }
        return _pendingWithdrawal;
    }
    function _queueClaimAll(uint256 _totalToBeWithdrawn, uint256 _cachedPendingQueueIndex) private {
        _reallocateOnWithdrawal(_totalToBeWithdrawn);
        uint256 totalQueues = (getMaxTotalWithdrawalQueues + 1);
        uint256 oldestQueueIdx = (_cachedPendingQueueIndex + 1) % totalQueues;
        uint256[] memory pendingWithdrawal = new uint256[](totalQueues);
        for (uint256 i; i < pendingWithdrawal.length;) {
            uint256 idx = (oldestQueueIdx + i) % totalQueues;
            _updatePendingWithdrawalWithQueue(idx, _cachedPendingQueueIndex, pendingWithdrawal);
            unchecked {
                ++i;
            }
        }
        getAvailableToWithdraw = 0;
        for (uint256 i; i < pendingWithdrawal.length;) {
            if (pendingWithdrawal[i] == 0) {
                unchecked {
                    ++i;
                }
                continue;
            }
            address queueAddr = _deployedQueues[i].contractAddress;
            uint256 amount = pendingWithdrawal[i];
            asset.safeTransfer(queueAddr, amount);
            emit QueueClaimed(queueAddr, amount);
            unchecked {
                ++i;
            }
        }
    }
    function _outstandingApr(OutstandingValues memory __outstandingValues) private pure returns (uint128) {
        if (__outstandingValues.principalAmount == 0) {
            return 0;
        }
        return __outstandingValues.sumApr / __outstandingValues.principalAmount;
    }
    function _updateOutstandingValuesOnTermination(
        OutstandingValues memory __outstandingValues,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _interestEarned
    ) private view returns (OutstandingValues memory) {
        uint256 newlyAccrued = uint256(__outstandingValues.sumApr).mulDivUp(
            block.timestamp - uint256(__outstandingValues.lastTs), _SECONDS_PER_YEAR * _BPS
        );
        uint256 total = __outstandingValues.accruedInterest + newlyAccrued;
        if (total < _interestEarned) {
            __outstandingValues.accruedInterest = 0;
        } else {
            __outstandingValues.accruedInterest = uint128(total - _interestEarned);
        }
        __outstandingValues.sumApr -= uint128(_apr * _principalAmount);
        __outstandingValues.principalAmount -= uint128(_principalAmount);
        __outstandingValues.lastTs = uint128(block.timestamp);
        return __outstandingValues;
    }
    function _withdraw(address owner, address receiver, uint256 assets, uint256 shares) private {
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        WithdrawalQueue(_deployedQueues[_pendingQueueIndex].contractAddress).mint(receiver, shares);
    }
}