pragma solidity ^0.8.18;
pragma abicoder v2;
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];
        if (valueIndex != 0) {
            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;
            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];
                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; 
            }
            set._values.pop();
            delete set._indexes[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
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
        return _values(set._inner);
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
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
abstract contract Ownable {
    error Unauthorized();
    error NewOwnerIsZeroAddress();
    error NoHandoverRequest();
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event OwnershipHandoverRequested(address indexed pendingOwner);
    event OwnershipHandoverCanceled(address indexed pendingOwner);
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;
    uint256 private constant _OWNER_SLOT_NOT = 0x8b78c6d8;
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;
    function _initializeOwner(address newOwner) internal virtual {
        assembly {
            newOwner := shr(96, shl(96, newOwner))
            sstore(not(_OWNER_SLOT_NOT), newOwner)
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
        }
    }
    function _setOwner(address newOwner) internal virtual {
        assembly {
            let ownerSlot := not(_OWNER_SLOT_NOT)
            newOwner := shr(96, shl(96, newOwner))
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
            sstore(ownerSlot, newOwner)
        }
    }
    function _checkOwner() internal view virtual {
        assembly {
            if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                mstore(0x00, 0x82b42900) 
                revert(0x1c, 0x04)
            }
        }
    }
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, 0x7448fbae) 
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + ownershipHandoverValidFor();
            assembly {
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }
    function cancelOwnershipHandover() public payable virtual {
        assembly {
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
        assembly {
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, 0x6f5e8818) 
                revert(0x1c, 0x04)
            }
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }
    function owner() public view virtual returns (address result) {
        assembly {
            result := sload(not(_OWNER_SLOT_NOT))
        }
    }
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        assembly {
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            result := sload(keccak256(0x0c, 0x20))
        }
    }
    function ownershipHandoverValidFor() public view virtual returns (uint64) {
        return 48 * 3600;
    }
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}
library FixedPointMathLib {
    error ExpOverflow();
    error FactorialOverflow();
    error MulWadFailed();
    error DivWadFailed();
    error MulDivFailed();
    error DivFailed();
    error FullMulDivFailed();
    error LnWadUndefined();
    error Log2Undefined();
    uint256 internal constant WAD = 1e18;
    function mulWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b)
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), WAD)
        }
    }
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            if mul(y, gt(x, div(not(0), y))) {
                mstore(0x00, 0xbac65e5b)
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), WAD))), div(mul(x, y), WAD))
        }
    }
    function divWad(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d)
                revert(0x1c, 0x04)
            }
            z := div(mul(x, WAD), y)
        }
    }
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(y, iszero(mul(WAD, gt(x, div(not(0), WAD)))))) {
                mstore(0x00, 0x7c5f487d)
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, WAD), y))), div(mul(x, WAD), y))
        }
    }
    function powWad(int256 x, int256 y) internal pure returns (int256) {
        return expWad((lnWad(x) * y) / int256(WAD));
    }
    function expWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            if (x <= -42139678854452767551) return r;
            assembly {
                if iszero(slt(x, 135305999368893231589)) {
                    mstore(0x00, 0xa37bfec9)
                    revert(0x1c, 0x04)
                }
            }
            x = (x << 78) / 5 ** 18;
            int256 k = ((x << 96) / 54916777467707473351141471128 + 2 ** 95) >> 96;
            x = x - k * 54916777467707473351141471128;
            int256 y = x + 1346386616545796478920950773328;
            y = ((y * x) >> 96) + 57155421227552351082224309758442;
            int256 p = y + x - 94201549194550492254356042504812;
            p = ((p * y) >> 96) + 28719021644029726153956944680412240;
            p = p * x + (4385272521454847904659076985693276 << 96);
            int256 q = x - 2855989394907223263936484059900;
            q = ((q * x) >> 96) + 50020603652535783019961831881945;
            q = ((q * x) >> 96) - 533845033583426703283633433725380;
            q = ((q * x) >> 96) + 3604857256930695427073651918091429;
            q = ((q * x) >> 96) - 14423608567350463180887372962807573;
            q = ((q * x) >> 96) + 26449188498355588339934803723976023;
            assembly {
                r := sdiv(p, q)
            }
            r = int256(
                (uint256(r) * 3822833074963236453042738258902158003155416615667) >> uint256(195 - k)
            );
        }
    }
    function lnWad(int256 x) internal pure returns (int256 r) {
        unchecked {
            assembly {
                if iszero(sgt(x, 0)) {
                    mstore(0x00, 0x1615e638)
                    revert(0x1c, 0x04)
                }
            }
            int256 k;
            assembly {
                let v := x
                k := shl(7, lt(0xffffffffffffffffffffffffffffffff, v))
                k := or(k, shl(6, lt(0xffffffffffffffff, shr(k, v))))
                k := or(k, shl(5, lt(0xffffffff, shr(k, v))))
                v := shr(k, v)
                v := or(v, shr(1, v))
                v := or(v, shr(2, v))
                v := or(v, shr(4, v))
                v := or(v, shr(8, v))
                v := or(v, shr(16, v))
                k := sub(or(k, byte(shr(251, mul(v, shl(224, 0x07c4acdd))),
                    0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f)), 96)
            }
            x <<= uint256(159 - k);
            x = int256(uint256(x) >> 159);
            int256 p = x + 3273285459638523848632254066296;
            p = ((p * x) >> 96) + 24828157081833163892658089445524;
            p = ((p * x) >> 96) + 43456485725739037958740375743393;
            p = ((p * x) >> 96) - 11111509109440967052023855526967;
            p = ((p * x) >> 96) - 45023709667254063763336534515857;
            p = ((p * x) >> 96) - 14706773417378608786704636184526;
            p = p * x - (795164235651350426258249787498 << 96);
            int256 q = x + 5573035233440673466300451813936;
            q = ((q * x) >> 96) + 71694874799317883764090561454958;
            q = ((q * x) >> 96) + 283447036172924575727196451306956;
            q = ((q * x) >> 96) + 401686690394027663651624208769553;
            q = ((q * x) >> 96) + 204048457590392012362485061816622;
            q = ((q * x) >> 96) + 31853899698501571402653359427138;
            q = ((q * x) >> 96) + 909429971244387300277376558375;
            assembly {
                r := sdiv(p, q)
            }
            r *= 1677202110996718588342820967067443963516166;
            r += 16597577552685614221487285958193947469193820559219878177908093499208371 * k;
            r += 600920179829731861736702779321621459595472258049074101567377883020018308;
            r >>= 174;
        }
    }
    function fullMulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        assembly {
            for {} 1 {} {
                let prod0 := mul(x, y)
                let mm := mulmod(x, y, not(0))
                let prod1 := sub(mm, add(prod0, lt(mm, prod0)))
                if iszero(prod1) {
                    if iszero(d) {
                        mstore(0x00, 0xae47f702)
                        revert(0x1c, 0x04)
                    }
                    result := div(prod0, d)
                    break       
                }
                if iszero(gt(d, prod1)) {
                    mstore(0x00, 0xae47f702)
                    revert(0x1c, 0x04)
                }
                let remainder := mulmod(x, y, d)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
                let twos := and(d, sub(0, d))
                d := div(d, twos)
                prod0 := div(prod0, twos)
                prod0 := or(prod0, mul(prod1, add(div(sub(0, twos), twos), 1)))
                let inv := xor(mul(3, d), 2)
                inv := mul(inv, sub(2, mul(d, inv))) 
                inv := mul(inv, sub(2, mul(d, inv))) 
                inv := mul(inv, sub(2, mul(d, inv))) 
                inv := mul(inv, sub(2, mul(d, inv))) 
                inv := mul(inv, sub(2, mul(d, inv))) 
                result := mul(prod0, mul(inv, sub(2, mul(d, inv)))) 
                break
            }
        }
    }
    function fullMulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 result) {
        result = fullMulDiv(x, y, d);
        assembly {
            if mulmod(x, y, d) {
                if iszero(add(result, 1)) {
                    mstore(0x00, 0xae47f702)
                    revert(0x1c, 0x04)
                }
                result := add(result, 1)
            }
        }
    }
    function mulDiv(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            z := div(mul(x, y), d)
        }
    }
    function mulDivUp(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(d, iszero(mul(y, gt(x, div(not(0), y)))))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(mul(x, y), d))), div(mul(x, y), d))
        }
    }
    function divUp(uint256 x, uint256 d) internal pure returns (uint256 z) {
        assembly {
            if iszero(d) {
                mstore(0x00, 0x65244e4e)
                revert(0x1c, 0x04)
            }
            z := add(iszero(iszero(mod(x, d))), div(x, d))
        }
    }
    function zeroFloorSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := mul(gt(x, y), sub(x, y))
        }
    }
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            z := 181 
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffffff, shr(r, x))))
            z := shl(shr(1, r), z)
            z := shr(18, mul(z, add(shr(r, x), 65536))) 
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
    function cbrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            let r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            r := or(r, shl(4, lt(0xffff, shr(r, x))))
            r := or(r, shl(3, lt(0xff, shr(r, x))))
            z := shl(add(div(r, 3), lt(0xf, shr(r, x))), 0xff)
            z := div(z, byte(mod(r, 3), shl(232, 0x7f624b)))
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := div(add(add(div(x, mul(z, z)), z), z), 3)
            z := sub(z, lt(div(x, mul(z, z)), z))
        }
    }
    function factorial(uint256 x) internal pure returns (uint256 result) {
        assembly {
            for {} 1 {} {
                if iszero(lt(10, x)) {
                    result := and(
                        shr(mul(22, x), 0x375f0016260009d80004ec0002d00001e0000180000180000200000400001),
                        0x3fffff
                    )
                    break
                }
                if iszero(lt(57, x)) {
                    let end := 31
                    result := 8222838654177922817725562880000000
                    if iszero(lt(end, x)) {
                        end := 10
                        result := 3628800
                    }
                    for { let w := not(0) } 1 {} {
                        result := mul(result, x)
                        x := add(x, w)
                        if eq(x, end) { break }
                    }
                    break
                }
                mstore(0x00, 0xaba0f2a2)
                revert(0x1c, 0x04)
            }
        }
    }
    function log2(uint256 x) internal pure returns (uint256 r) {
        assembly {
            if iszero(x) {
                mstore(0x00, 0x5be3aa5c)
                revert(0x1c, 0x04)
            }
            r := shl(7, lt(0xffffffffffffffffffffffffffffffff, x))
            r := or(r, shl(6, lt(0xffffffffffffffff, shr(r, x))))
            r := or(r, shl(5, lt(0xffffffff, shr(r, x))))
            x := shr(r, x)
            x := or(x, shr(1, x))
            x := or(x, shr(2, x))
            x := or(x, shr(4, x))
            x := or(x, shr(8, x))
            x := or(x, shr(16, x))
            r := or(r, byte(shr(251, mul(x, shl(224, 0x07c4acdd))),
                0x0009010a0d15021d0b0e10121619031e080c141c0f111807131b17061a05041f))
        }
    }
    function log2Up(uint256 x) internal pure returns (uint256 r) {
        unchecked {
            uint256 isNotPo2;
            assembly {
                isNotPo2 := iszero(iszero(and(x, sub(x, 1))))
            }
            return log2(x) + isNotPo2;
        }
    }
    function avg(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = (x & y) + ((x ^ y) >> 1);
        }
    }
    function avg(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = (x >> 1) + (y >> 1) + (((x & 1) + (y & 1)) >> 1);
        }
    }
    function abs(int256 x) internal pure returns (uint256 z) {
        assembly {
            let mask := sub(0, shr(255, x))
            z := xor(mask, add(mask, x))
        }
    }
    function dist(int256 x, int256 y) internal pure returns (uint256 z) {
        assembly {
            let a := sub(y, x)
            z := xor(a, mul(xor(a, sub(x, y)), sgt(x, y)))
        }
    }
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := xor(x, mul(xor(x, y), lt(y, x)))
        }
    }
    function min(int256 x, int256 y) internal pure returns (int256 z) {
        assembly {
            z := xor(x, mul(xor(x, y), slt(y, x)))
        }
    }
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := xor(x, mul(xor(x, y), gt(y, x)))
        }
    }
    function max(int256 x, int256 y) internal pure returns (int256 z) {
        assembly {
            z := xor(x, mul(xor(x, y), sgt(y, x)))
        }
    }
    function clamp(uint256 x, uint256 minValue, uint256 maxValue)
        internal
        pure
        returns (uint256 z)
    {
        z = min(max(x, minValue), maxValue);
    }
    function clamp(int256 x, int256 minValue, int256 maxValue) internal pure returns (int256 z) {
        z = min(max(x, minValue), maxValue);
    }
    function gcd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            for { z := x } y {} {
                let t := y
                y := mod(z, y)
                z := t
            }
        }
    }
    function rawAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x + y;
        }
    }
    function rawAdd(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x + y;
        }
    }
    function rawSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x - y;
        }
    }
    function rawSub(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x - y;
        }
    }
    function rawMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        unchecked {
            z = x * y;
        }
    }
    function rawMul(int256 x, int256 y) internal pure returns (int256 z) {
        unchecked {
            z = x * y;
        }
    }
    function rawDiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := div(x, y)
        }
    }
    function rawSDiv(int256 x, int256 y) internal pure returns (int256 z) {
        assembly {
            z := sdiv(x, y)
        }
    }
    function rawMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := mod(x, y)
        }
    }
    function rawSMod(int256 x, int256 y) internal pure returns (int256 z) {
        assembly {
            z := smod(x, y)
        }
    }
    function rawAddMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        assembly {
            z := addmod(x, y, d)
        }
    }
    function rawMulMod(uint256 x, uint256 y, uint256 d) internal pure returns (uint256 z) {
        assembly {
            z := mulmod(x, y, d)
        }
    }
}
abstract contract Multicallable {
    function multicall(bytes[] calldata data) public virtual returns (bytes[] memory) {
        assembly {
            mstore(0x00, 0x20)
            mstore(0x20, data.length) 
            if iszero(data.length) { return(0x00, 0x40) }
            let results := 0x40
            let end := shl(5, data.length)
            calldatacopy(0x40, data.offset, end)
            let resultsOffset := end
            end := add(results, end)
            for {} 1 {} {
                let o := add(data.offset, mload(results))
                let memPtr := add(resultsOffset, 0x40)
                calldatacopy(
                    memPtr,
                    add(o, 0x20), 
                    calldataload(o) 
                )
                if iszero(delegatecall(gas(), address(), memPtr, calldataload(o), 0x00, 0x00)) {
                    returndatacopy(0x00, 0x00, returndatasize())
                    revert(0x00, returndatasize())
                }
                mstore(results, resultsOffset)
                results := add(results, 0x20)
                mstore(memPtr, returndatasize())
                returndatacopy(add(memPtr, 0x20), 0x00, returndatasize())
                resultsOffset :=
                    and(add(add(resultsOffset, returndatasize()), 0x3f), 0xffffffffffffffe0)
                if iszero(lt(results, end)) { break }
            }
            return(0x00, add(resultsOffset, 0x40))
        }
    }
}
library SafeCastLib {
    error Overflow();
    function toUint8(uint256 x) internal pure returns (uint8) {
        if (x >= 1 << 8) _revertOverflow();
        return uint8(x);
    }
    function toUint16(uint256 x) internal pure returns (uint16) {
        if (x >= 1 << 16) _revertOverflow();
        return uint16(x);
    }
    function toUint24(uint256 x) internal pure returns (uint24) {
        if (x >= 1 << 24) _revertOverflow();
        return uint24(x);
    }
    function toUint32(uint256 x) internal pure returns (uint32) {
        if (x >= 1 << 32) _revertOverflow();
        return uint32(x);
    }
    function toUint40(uint256 x) internal pure returns (uint40) {
        if (x >= 1 << 40) _revertOverflow();
        return uint40(x);
    }
    function toUint48(uint256 x) internal pure returns (uint48) {
        if (x >= 1 << 48) _revertOverflow();
        return uint48(x);
    }
    function toUint56(uint256 x) internal pure returns (uint56) {
        if (x >= 1 << 56) _revertOverflow();
        return uint56(x);
    }
    function toUint64(uint256 x) internal pure returns (uint64) {
        if (x >= 1 << 64) _revertOverflow();
        return uint64(x);
    }
    function toUint72(uint256 x) internal pure returns (uint72) {
        if (x >= 1 << 72) _revertOverflow();
        return uint72(x);
    }
    function toUint80(uint256 x) internal pure returns (uint80) {
        if (x >= 1 << 80) _revertOverflow();
        return uint80(x);
    }
    function toUint88(uint256 x) internal pure returns (uint88) {
        if (x >= 1 << 88) _revertOverflow();
        return uint88(x);
    }
    function toUint96(uint256 x) internal pure returns (uint96) {
        if (x >= 1 << 96) _revertOverflow();
        return uint96(x);
    }
    function toUint104(uint256 x) internal pure returns (uint104) {
        if (x >= 1 << 104) _revertOverflow();
        return uint104(x);
    }
    function toUint112(uint256 x) internal pure returns (uint112) {
        if (x >= 1 << 112) _revertOverflow();
        return uint112(x);
    }
    function toUint120(uint256 x) internal pure returns (uint120) {
        if (x >= 1 << 120) _revertOverflow();
        return uint120(x);
    }
    function toUint128(uint256 x) internal pure returns (uint128) {
        if (x >= 1 << 128) _revertOverflow();
        return uint128(x);
    }
    function toUint136(uint256 x) internal pure returns (uint136) {
        if (x >= 1 << 136) _revertOverflow();
        return uint136(x);
    }
    function toUint144(uint256 x) internal pure returns (uint144) {
        if (x >= 1 << 144) _revertOverflow();
        return uint144(x);
    }
    function toUint152(uint256 x) internal pure returns (uint152) {
        if (x >= 1 << 152) _revertOverflow();
        return uint152(x);
    }
    function toUint160(uint256 x) internal pure returns (uint160) {
        if (x >= 1 << 160) _revertOverflow();
        return uint160(x);
    }
    function toUint168(uint256 x) internal pure returns (uint168) {
        if (x >= 1 << 168) _revertOverflow();
        return uint168(x);
    }
    function toUint176(uint256 x) internal pure returns (uint176) {
        if (x >= 1 << 176) _revertOverflow();
        return uint176(x);
    }
    function toUint184(uint256 x) internal pure returns (uint184) {
        if (x >= 1 << 184) _revertOverflow();
        return uint184(x);
    }
    function toUint192(uint256 x) internal pure returns (uint192) {
        if (x >= 1 << 192) _revertOverflow();
        return uint192(x);
    }
    function toUint200(uint256 x) internal pure returns (uint200) {
        if (x >= 1 << 200) _revertOverflow();
        return uint200(x);
    }
    function toUint208(uint256 x) internal pure returns (uint208) {
        if (x >= 1 << 208) _revertOverflow();
        return uint208(x);
    }
    function toUint216(uint256 x) internal pure returns (uint216) {
        if (x >= 1 << 216) _revertOverflow();
        return uint216(x);
    }
    function toUint224(uint256 x) internal pure returns (uint224) {
        if (x >= 1 << 224) _revertOverflow();
        return uint224(x);
    }
    function toUint232(uint256 x) internal pure returns (uint232) {
        if (x >= 1 << 232) _revertOverflow();
        return uint232(x);
    }
    function toUint240(uint256 x) internal pure returns (uint240) {
        if (x >= 1 << 240) _revertOverflow();
        return uint240(x);
    }
    function toUint248(uint256 x) internal pure returns (uint248) {
        if (x >= 1 << 248) _revertOverflow();
        return uint248(x);
    }
    function toInt8(int256 x) internal pure returns (int8) {
        int8 y = int8(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt16(int256 x) internal pure returns (int16) {
        int16 y = int16(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt24(int256 x) internal pure returns (int24) {
        int24 y = int24(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt32(int256 x) internal pure returns (int32) {
        int32 y = int32(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt40(int256 x) internal pure returns (int40) {
        int40 y = int40(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt48(int256 x) internal pure returns (int48) {
        int48 y = int48(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt56(int256 x) internal pure returns (int56) {
        int56 y = int56(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt64(int256 x) internal pure returns (int64) {
        int64 y = int64(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt72(int256 x) internal pure returns (int72) {
        int72 y = int72(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt80(int256 x) internal pure returns (int80) {
        int80 y = int80(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt88(int256 x) internal pure returns (int88) {
        int88 y = int88(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt96(int256 x) internal pure returns (int96) {
        int96 y = int96(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt104(int256 x) internal pure returns (int104) {
        int104 y = int104(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt112(int256 x) internal pure returns (int112) {
        int112 y = int112(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt120(int256 x) internal pure returns (int120) {
        int120 y = int120(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt128(int256 x) internal pure returns (int128) {
        int128 y = int128(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt136(int256 x) internal pure returns (int136) {
        int136 y = int136(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt144(int256 x) internal pure returns (int144) {
        int144 y = int144(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt152(int256 x) internal pure returns (int152) {
        int152 y = int152(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt160(int256 x) internal pure returns (int160) {
        int160 y = int160(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt168(int256 x) internal pure returns (int168) {
        int168 y = int168(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt176(int256 x) internal pure returns (int176) {
        int176 y = int176(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt184(int256 x) internal pure returns (int184) {
        int184 y = int184(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt192(int256 x) internal pure returns (int192) {
        int192 y = int192(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt200(int256 x) internal pure returns (int200) {
        int200 y = int200(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt208(int256 x) internal pure returns (int208) {
        int208 y = int208(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt216(int256 x) internal pure returns (int216) {
        int216 y = int216(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt224(int256 x) internal pure returns (int224) {
        int224 y = int224(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt232(int256 x) internal pure returns (int232) {
        int232 y = int232(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt240(int256 x) internal pure returns (int240) {
        int240 y = int240(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function toInt248(int256 x) internal pure returns (int248) {
        int248 y = int248(x);
        if (x != y) _revertOverflow();
        return y;
    }
    function _revertOverflow() private pure {
        assembly {
            mstore(0x00, 0x35278d12)
            revert(0x1c, 0x04)
        }
    }
}
library SafeTransferLib {
    error ETHTransferFailed();
    error TransferFromFailed();
    error TransferFailed();
    error ApproveFailed();
    uint256 internal constant _GAS_STIPEND_NO_STORAGE_WRITES = 2300;
    uint256 internal constant _GAS_STIPEND_NO_GRIEF = 100000;
    function safeTransferETH(address to, uint256 amount) internal {
        assembly {
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                mstore(0x00, 0xb12d13eb)
                revert(0x1c, 0x04)
            }
        }
    }
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb)
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) {
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }
    function forceSafeTransferETH(address to, uint256 amount) internal {
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb)
                revert(0x1c, 0x04)
            }
            if iszero(call(_GAS_STIPEND_NO_GRIEF, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) {
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        assembly {
            success := call(gasStipend, to, amount, 0, 0, 0, 0)
        }
    }
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        assembly {
            let m := mload(0x40) 
            mstore(0x60, amount) 
            mstore(0x40, to) 
            mstore(0x2c, shl(96, from)) 
            mstore(0x0c, 0x23b872dd000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424)
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) 
            mstore(0x40, m) 
        }
    }
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        assembly {
            let m := mload(0x40) 
            mstore(0x40, to) 
            mstore(0x2c, shl(96, from)) 
            mstore(0x0c, 0x70a08231000000000000000000000000)
            if iszero(
                and( 
                    gt(returndatasize(), 0x1f), 
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424)
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd)
            amount := mload(0x60)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424)
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) 
            mstore(0x40, m) 
        }
    }
    function safeTransfer(address token, address to, uint256 amount) internal {
        assembly {
            mstore(0x14, to) 
            mstore(0x34, amount) 
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18)
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0)
        }
    }
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        assembly {
            mstore(0x00, 0x70a08231) 
            mstore(0x20, address()) 
            if iszero(
                and( 
                    gt(returndatasize(), 0x1f), 
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18)
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) 
            amount := mload(0x34)
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18)
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0)
        }
    }
    function safeApprove(address token, address to, uint256 amount) internal {
        assembly {
            mstore(0x14, to) 
            mstore(0x34, amount) 
            mstore(0x00, 0x095ea7b3000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73)
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0)
        }
    }
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        assembly {
            mstore(0x14, account) 
            mstore(0x00, 0x70a08231000000000000000000000000)
            amount :=
                mul(
                    mload(0x20),
                    and( 
                        gt(returndatasize(), 0x1f), 
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
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
abstract contract ReentrancyGuard {
    uint256 private locked = 1;
    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");
        locked = 2;
        _;
        locked = 1;
    }
}
interface IUniswapV3Factory {
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);
    function owner() external view returns (address);
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);
    function setOwner(address _owner) external;
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}
interface IUniswapV3PoolActions {
    function initialize(uint160 sqrtPriceX96) external;
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}
interface IUniswapV3PoolDerivedState {
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}
interface IUniswapV3PoolErrors {
    error LOK();
    error TLU();
    error TLM();
    error TUM();
    error AI();
    error M0();
    error M1();
    error AS();
    error IIA();
    error L();
    error F0();
    error F1();
}
interface IUniswapV3PoolEvents {
    event Initialize(uint160 sqrtPriceX96, int24 tick);
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
interface IUniswapV3PoolImmutables {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
    function tickSpacing() external view returns (int24);
    function maxLiquidityPerTick() external view returns (uint128);
}
interface IUniswapV3PoolOwnerActions {
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}
interface IUniswapV3PoolState {
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
    function feeGrowthGlobal0X128() external view returns (uint256);
    function feeGrowthGlobal1X128() external view returns (uint256);
    function protocolFees() external view returns (uint128 token0, uint128 token1);
    function liquidity() external view returns (uint128);
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );
    function tickBitmap(int16 wordPosition) external view returns (uint256);
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
interface IPeripheryImmutableState {
    function factory() external view returns (address);
    function WETH9() external view returns (address);
}
interface IPeripheryPayments {
    function unwrapWETH9(uint256 amountMinimum, address recipient) external payable;
    function refundETH() external payable;
    function sweepToken(
        address token,
        uint256 amountMinimum,
        address recipient
    ) external payable;
}
interface IPoolInitializer {
    function createAndInitializePoolIfNecessary(
        address token0,
        address token1,
        uint24 fee,
        uint160 sqrtPriceX96
    ) external payable returns (address pool);
}
library PoolAddress {
    bytes32 internal constant POOL_INIT_CODE_HASH = 0x995089ad791508a023ec76172d56c12f2049e3382b7c2a78f2747b2b0ac7db69;
    struct PoolKey {
        address token0;
        address token1;
        uint24 fee;
    }
    function getPoolKey(
        address tokenA,
        address tokenB,
        uint24 fee
    ) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }
    function computeAddress(address factory, PoolKey memory key) internal pure returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex'ff',
                            factory,
                            keccak256(abi.encode(key.token0, key.token1, key.fee)),
                            POOL_INIT_CODE_HASH
                        )
                    )
                )
            )
        );
    }
}
interface Errors {
    error NonContractError();
}
interface IERC20Boost {
    struct GaugeState {
        uint128 userGaugeBoost;
        uint128 totalGaugeBoost;
    }
    function getUserGaugeBoost(address user, address gauge)
        external
        view
        returns (uint128 userGaugeBoost, uint128 totalGaugeBoost);
    function getUserBoost(address user) external view returns (uint256 boost);
    function gauges() external view returns (address[] memory);
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values);
    function isGauge(address gauge) external view returns (bool);
    function numGauges() external view returns (uint256);
    function deprecatedGauges() external view returns (address[] memory);
    function numDeprecatedGauges() external view returns (uint256);
    function freeGaugeBoost(address user) external view returns (uint256);
    function userGauges(address user) external view returns (address[] memory);
    function isUserGauge(address user, address gauge) external view returns (bool);
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values);
    function numUserGauges(address user) external view returns (uint256);
    function attach(address user) external;
    function detach(address user) external;
    function updateUserBoost(address user) external;
    function decrementGaugeBoost(address gauge, uint256 boost) external;
    function decrementGaugeAllBoost(address gauge) external;
    function decrementAllGaugesBoost(uint256 boost) external;
    function decrementGaugesBoostIndexed(uint256 boost, uint256 offset, uint256 num) external;
    function decrementAllGaugesAllBoost() external;
    function addGauge(address gauge) external;
    function removeGauge(address gauge) external;
    function replaceGauge(address oldGauge, address newGauge) external;
    event AddGauge(address indexed gauge);
    event RemoveGauge(address indexed gauge);
    event Attach(address indexed user, address indexed gauge, uint256 boost);
    event Detach(address indexed user, address indexed gauge);
    event UpdateUserBoost(address indexed user, uint256 updatedBoost);
    event DecrementUserGaugeBoost(address indexed user, address indexed gauge, uint256 UpdatedBoost);
    error InvalidGauge();
    error GaugeAlreadyAttached();
    error AttachedBoost();
}
interface IERC20Gauges {
    struct Weight {
        uint112 storedWeight;
        uint112 currentWeight;
        uint32 currentCycle;
    }
    function getUserWeight(address) external view returns (uint112);
    function gaugeCycleLength() external view returns (uint32);
    function incrementFreezeWindow() external view returns (uint32);
    function getUserGaugeWeight(address, address) external view returns (uint112);
    function getGaugeCycleEnd() external view returns (uint32);
    function getGaugeWeight(address gauge) external view returns (uint112);
    function getStoredGaugeWeight(address gauge) external view returns (uint112);
    function totalWeight() external view returns (uint112);
    function storedTotalWeight() external view returns (uint112);
    function gauges() external view returns (address[] memory);
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values);
    function isGauge(address gauge) external view returns (bool);
    function numGauges() external view returns (uint256);
    function deprecatedGauges() external view returns (address[] memory);
    function numDeprecatedGauges() external view returns (uint256);
    function userGauges(address user) external view returns (address[] memory);
    function isUserGauge(address user, address gauge) external view returns (bool);
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values);
    function numUserGauges(address user) external view returns (uint256);
    function calculateGaugeAllocation(address gauge, uint256 quantity) external view returns (uint256);
    function incrementGauge(address gauge, uint112 weight) external returns (uint112 newUserWeight);
    function incrementGauges(address[] memory gaugeList, uint112[] memory weights)
        external
        returns (uint256 newUserWeight);
    function decrementGauge(address gauge, uint112 weight) external returns (uint112 newUserWeight);
    function decrementGauges(address[] memory gaugeList, uint112[] memory weights)
        external
        returns (uint112 newUserWeight);
    function maxGauges() external view returns (uint256);
    function canContractExceedMaxGauges(address) external view returns (bool);
    function addGauge(address gauge) external returns (uint112);
    function removeGauge(address gauge) external;
    function replaceGauge(address oldGauge, address newGauge) external;
    function setMaxGauges(uint256 newMax) external;
    function setContractExceedMaxGauges(address account, bool canExceedMax) external;
    event IncrementGaugeWeight(address indexed user, address indexed gauge, uint256 weight, uint32 cycleEnd);
    event DecrementGaugeWeight(address indexed user, address indexed gauge, uint256 weight, uint32 cycleEnd);
    event AddGauge(address indexed gauge);
    event RemoveGauge(address indexed gauge);
    event MaxGaugesUpdate(uint256 oldMaxGauges, uint256 newMaxGauges);
    event CanContractExceedMaxGaugesUpdate(address indexed account, bool canContractExceedMaxGauges);
    error SizeMismatchError();
    error MaxGaugeError();
    error OverWeightError();
    error IncrementFreezeError();
    error InvalidGaugeError();
}
interface IERC20MultiVotes {
    struct Checkpoint {
        uint32 fromBlock;
        uint224 votes;
    }
    function checkpoints(address account, uint32 pos) external view returns (Checkpoint memory);
    function numCheckpoints(address account) external view returns (uint32);
    function freeVotes(address account) external view returns (uint256);
    function getVotes(address account) external view returns (uint256);
    function userUnusedVotes(address user) external view returns (uint256);
    function getPriorVotes(address account, uint256 blockNumber) external view returns (uint256);
    function maxDelegates() external view returns (uint256);
    function canContractExceedMaxDelegates(address) external view returns (bool);
    function setMaxDelegates(uint256 newMax) external;
    function setContractExceedMaxDelegates(address account, bool canExceedMax) external;
    function userDelegatedVotes(address) external view returns (uint256);
    function delegatesVotesCount(address delegator, address delegatee) external view returns (uint256);
    function delegates(address delegator) external view returns (address[] memory);
    function delegateCount(address delegator) external view returns (uint256);
    function incrementDelegation(address delegatee, uint256 amount) external;
    function undelegate(address delegatee, uint256 amount) external;
    function delegate(address newDelegatee) external;
    event MaxDelegatesUpdate(uint256 oldMaxDelegates, uint256 newMaxDelegates);
    event CanContractExceedMaxDelegatesUpdate(address indexed account, bool canContractExceedMaxDelegates);
    event Delegation(address indexed delegator, address indexed delegate, uint256 amount);
    event Undelegation(address indexed delegator, address indexed delegate, uint256 amount);
    event DelegateVotesChanged(address indexed delegate, uint256 previousBalance, uint256 newBalance);
    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);
    error BlockError();
    error DelegationError();
    error UndelegationVoteError();
}
interface IERC4626 {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256);
    function previewWithdraw(uint256 assets) external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function maxDeposit(address) external view returns (uint256);
    function maxMint(address) external view returns (uint256);
    function maxWithdraw(address owner) external view returns (uint256);
    function maxRedeem(address owner) external view returns (uint256);
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
}
interface IERC4626DepositOnly {
    function totalAssets() external view returns (uint256 _totalAssets);
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256);
    function maxDeposit(address owner) external view returns (uint256);
    function maxMint(address owner) external view returns (uint256);
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
}
interface IUniswapV3Gauge {
    function uniswapV3Staker() external view returns (address);
    function minimumWidth() external view returns (uint24);
    event NewMinimumWidth(uint24 minimumWidth);
    function setMinimumWidth(uint24 _minimumWidth) external;
}
interface IbHermesUnderlying {
    error NotbHermes();
    function bHermes() external view returns (address);
    function mint(address to, uint256 amount) external;
}
interface IMultiRewardsDepot {
    function getRewards() external returns (uint256 balance);
    function addAsset(address rewardsContract, address asset) external;
    function removeAsset(address rewardsContract) external;
    event AssetAdded(address indexed rewardsContract, address indexed asset);
    event AssetRemoved(address indexed rewardsContract, address indexed asset);
    error ErrorAddingAsset();
    error ErrorRemovingAsset();
}
interface IRewardsDepot {
    function getRewards() external returns (uint256 balance);
    error FlywheelRewardsError();
}
library IncentiveTime {
    error InvalidStartTime();
    uint256 private constant INCENTIVES_DURATION = 1 weeks; 
    uint256 private constant INCENTIVES_OFFSET = 12 hours;
    function computeStart(uint256 timestamp) internal pure returns (uint96 start) {
        return uint96(((timestamp - INCENTIVES_OFFSET) / INCENTIVES_DURATION) * INCENTIVES_DURATION + INCENTIVES_OFFSET);
    }
    function computeEnd(uint256 timestamp) internal pure returns (uint96 end) {
        return uint96(
            (((timestamp - INCENTIVES_OFFSET) / INCENTIVES_DURATION) + 1) * INCENTIVES_DURATION + INCENTIVES_OFFSET
        );
    }
    function getEnd(uint96 start) internal pure returns (uint96 end) {
        end = start + uint96(INCENTIVES_DURATION);
    }
    function getEndAndDuration(uint96 start, uint40 stakedTimestamp, uint256 timestamp)
        internal
        pure
        returns (uint96 end, uint256 stakedDuration)
    {
        if (stakedTimestamp < start) revert InvalidStartTime();
        end = start + uint96(INCENTIVES_DURATION);
        uint256 earliest = timestamp < end ? timestamp : end;
        stakedDuration = earliest - stakedTimestamp;
    }
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
interface IFlywheelAcummulatedRewards {
    function rewardsCycleLength() external view returns (uint256);
    function endCycle() external view returns (uint256);
    function getAccruedRewards(ERC20 strategy) external returns (uint256 amount);
    event NewRewardsCycle(uint32 indexed start, uint256 indexed end, uint256 reward);
}
interface IFlywheelBooster {
    function boostedTotalSupply(ERC20 strategy) external view returns (uint256);
    function boostedBalanceOf(ERC20 strategy, address user) external view returns (uint256);
}
library RewardMath {
    using FixedPointMathLib for uint256;
    function computeBoostedSecondsInsideX128(
        uint256 stakedDuration,
        uint128 liquidity,
        uint128 boostAmount,
        uint128 boostTotalSupply,
        uint160 secondsPerLiquidityInsideInitialX128,
        uint160 secondsPerLiquidityInsideX128
    ) internal pure returns (uint160 boostedSecondsInsideX128) {
        uint160 secondsInsideX128 = (secondsPerLiquidityInsideX128 - secondsPerLiquidityInsideInitialX128) * liquidity;
        if (boostTotalSupply > 0) {
            boostedSecondsInsideX128 = uint160(
                ((secondsInsideX128 * 4) / 10) + ((((stakedDuration << 128) * boostAmount) / boostTotalSupply) * 6) / 10
            );
            if (boostedSecondsInsideX128 > secondsInsideX128) {
                boostedSecondsInsideX128 = secondsInsideX128;
            }
        } else {
            boostedSecondsInsideX128 = (secondsInsideX128 * 4) / 10;
        }
    }
    function computeBoostedRewardAmount(
        uint256 totalRewardUnclaimed,
        uint160 totalSecondsClaimedX128,
        uint256 startTime,
        uint256 endTime,
        uint160 secondsInsideX128,
        uint256 currentTime
    ) internal pure returns (uint256) {
        assert(currentTime >= startTime);
        uint256 totalSecondsUnclaimedX128 = ((endTime.max(currentTime) - startTime) << 128) - totalSecondsClaimedX128;
        return totalRewardUnclaimed.mulDiv(secondsInsideX128, totalSecondsUnclaimedX128);
    }
}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IERC721Permit is IERC721 {
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}
contract HERMES is ERC20, Ownable {
    constructor(address _owner) ERC20("Hermes", "HERMES", 18) {
        _initializeOwner(_owner);
    }
    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
interface IFlywheelCore {
    function rewardToken() external view returns (address);
    function allStrategies(uint256) external view returns (ERC20);
    function strategyIds(ERC20) external view returns (uint256);
    function flywheelRewards() external view returns (address);
    function flywheelBooster() external view returns (IFlywheelBooster);
    function rewardsAccrued(address) external view returns (uint256);
    function accrue(address user) external returns (uint256);
    function accrue(ERC20 strategy, address user) external returns (uint256);
    function accrue(ERC20 strategy, address user, address secondUser) external returns (uint256, uint256);
    function claimRewards(address user) external;
    function addStrategyForRewards(ERC20 strategy) external;
    function getAllStrategies() external view returns (ERC20[] memory);
    function setFlywheelRewards(address newFlywheelRewards) external;
    function setBooster(IFlywheelBooster newBooster) external;
    function strategyIndex(ERC20) external view returns (uint256);
    function userIndex(ERC20, address) external view returns (uint256);
    event AccrueRewards(ERC20 indexed strategy, address indexed user, uint256 rewardsDelta, uint256 rewardsIndex);
    event ClaimRewards(address indexed user, uint256 amount);
    event AddStrategy(address indexed newStrategy);
    event FlywheelRewardsUpdate(address indexed newFlywheelRewards);
    event FlywheelBoosterUpdate(address indexed newBooster);
}
abstract contract ERC4626 is ERC20, IERC4626 {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    ERC20 public immutable asset;
    constructor(ERC20 _asset, string memory _name, string memory _symbol) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
        address(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); 
        address(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function withdraw(uint256 assets, address receiver, address owner) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); 
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        address(asset).safeTransfer(receiver, assets);
    }
    function redeem(uint256 shares, address receiver, address owner) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        address(asset).safeTransfer(receiver, assets);
    }
    function totalAssets() public view virtual returns (uint256);
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? assets : assets.mulDiv(supply, totalAssets());
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? shares : shares.mulDiv(totalAssets(), supply);
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
abstract contract ERC4626DepositOnly is ERC20, IERC4626DepositOnly {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    ERC20 public immutable asset;
    constructor(ERC20 _asset, string memory _name, string memory _symbol) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
        address(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); 
        address(asset).safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function totalAssets() public view virtual returns (uint256);
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? assets : assets.mulDiv(supply, totalAssets());
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? shares : shares.mulDiv(totalAssets(), supply);
    }
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
abstract contract RewardsDepot is IRewardsDepot {
    using SafeTransferLib for address;
    function getRewards() external virtual returns (uint256);
    function transferRewards(address _asset, address _rewardsContract) internal returns (uint256 balance) {
        balance = _asset.balanceOf(address(this));
        _asset.safeTransfer(_rewardsContract, balance);
    }
    modifier onlyFlywheelRewards() virtual;
}
abstract contract FlywheelCore_0 is Ownable, IFlywheelCore {
    using SafeTransferLib for address;
    using SafeCastLib for uint256;
    address public immutable override rewardToken;
    ERC20[] public override allStrategies;
    mapping(ERC20 => uint256) public override strategyIds;
    address public override flywheelRewards;
    IFlywheelBooster public override flywheelBooster;
    constructor(address _rewardToken, address _flywheelRewards, IFlywheelBooster _flywheelBooster, address _owner) {
        _initializeOwner(_owner);
        rewardToken = _rewardToken;
        flywheelRewards = _flywheelRewards;
        flywheelBooster = _flywheelBooster;
    }
    function getAllStrategies() external view returns (ERC20[] memory) {
        return allStrategies;
    }
    mapping(address => uint256) public override rewardsAccrued;
    function accrue(address user) external returns (uint256) {
        return _accrue(ERC20(msg.sender), user);
    }
    function accrue(ERC20 strategy, address user) external returns (uint256) {
        return _accrue(strategy, user);
    }
    function _accrue(ERC20 strategy, address user) internal returns (uint256) {
        uint256 index = strategyIndex[strategy];
        if (index == 0) return 0;
        index = accrueStrategy(strategy, index);
        return accrueUser(strategy, user, index);
    }
    function accrue(ERC20 strategy, address user, address secondUser) public returns (uint256, uint256) {
        uint256 index = strategyIndex[strategy];
        if (index == 0) return (0, 0);
        index = accrueStrategy(strategy, index);
        return (accrueUser(strategy, user, index), accrueUser(strategy, secondUser, index));
    }
    function claimRewards(address user) external {
        uint256 accrued = rewardsAccrued[user];
        if (accrued != 0) {
            rewardsAccrued[user] = 0;
            rewardToken.safeTransferFrom(address(flywheelRewards), user, accrued);
            emit ClaimRewards(user, accrued);
        }
    }
    function addStrategyForRewards(ERC20 strategy) external onlyOwner {
        _addStrategyForRewards(strategy);
    }
    function _addStrategyForRewards(ERC20 strategy) internal {
        require(strategyIndex[strategy] == 0, "strategy");
        strategyIndex[strategy] = ONE;
        strategyIds[strategy] = allStrategies.length;
        allStrategies.push(strategy);
        emit AddStrategy(address(strategy));
    }
    function setFlywheelRewards(address newFlywheelRewards) external onlyOwner {
        uint256 oldRewardBalance = rewardToken.balanceOf(address(flywheelRewards));
        if (oldRewardBalance > 0) {
            rewardToken.safeTransferFrom(address(flywheelRewards), address(newFlywheelRewards), oldRewardBalance);
        }
        flywheelRewards = newFlywheelRewards;
        emit FlywheelRewardsUpdate(address(newFlywheelRewards));
    }
    function setBooster(IFlywheelBooster newBooster) external onlyOwner {
        flywheelBooster = newBooster;
        emit FlywheelBoosterUpdate(address(newBooster));
    }
    uint256 private constant ONE = 1e18;
    mapping(ERC20 => uint256) public strategyIndex;
    mapping(ERC20 => mapping(address => uint256)) public userIndex;
    function accrueStrategy(ERC20 strategy, uint256 state) private returns (uint256 rewardsIndex) {
        uint256 strategyRewardsAccrued = _getAccruedRewards(strategy);
        rewardsIndex = state;
        if (strategyRewardsAccrued > 0) {
            uint256 supplyTokens = address(flywheelBooster) != address(0)
                ? flywheelBooster.boostedTotalSupply(strategy)
                : strategy.totalSupply();
            uint224 deltaIndex;
            if (supplyTokens != 0) {
                deltaIndex = ((strategyRewardsAccrued * ONE) / supplyTokens).toUint224();
            }
            rewardsIndex += deltaIndex;
            strategyIndex[strategy] = rewardsIndex;
        }
    }
    function accrueUser(ERC20 strategy, address user, uint256 index) private returns (uint256) {
        uint256 supplierIndex = userIndex[strategy][user];
        userIndex[strategy][user] = index;
        if (supplierIndex == 0) {
            supplierIndex = ONE;
        }
        uint256 deltaIndex = index - supplierIndex;
        uint256 supplierTokens = address(flywheelBooster) != address(0)
            ? flywheelBooster.boostedBalanceOf(strategy, user)
            : strategy.balanceOf(user);
        uint256 supplierDelta = (supplierTokens * deltaIndex) / ONE;
        uint256 supplierAccrued = rewardsAccrued[user] + supplierDelta;
        rewardsAccrued[user] = supplierAccrued;
        emit AccrueRewards(strategy, user, supplierDelta, index);
        return supplierAccrued;
    }
    function _getAccruedRewards(ERC20 strategy) internal virtual returns (uint256);
}
interface IFlywheelBribeRewards is IFlywheelAcummulatedRewards {
    function rewardsDepots(ERC20) external view returns (RewardsDepot);
    function setRewardsDepot(RewardsDepot rewardsDepot) external;
    event AddRewardsDepot(address indexed strategy, RewardsDepot indexed rewardsDepot);
}
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolErrors,
    IUniswapV3PoolEvents
{
}
contract MultiRewardsDepot is Ownable, RewardsDepot, IMultiRewardsDepot {
    mapping(address => address) private _assets;
    mapping(address => bool) private _isRewardsContract;
    mapping(address => bool) private _isAsset;
    constructor(address _owner) {
        _initializeOwner(_owner);
    }
    function getRewards() external override(RewardsDepot, IMultiRewardsDepot) onlyFlywheelRewards returns (uint256) {
        return transferRewards(_assets[msg.sender], msg.sender);
    }
    function addAsset(address rewardsContract, address asset) external onlyOwner {
        if (_isAsset[asset] || _isRewardsContract[rewardsContract]) revert ErrorAddingAsset();
        _isAsset[asset] = true;
        _isRewardsContract[rewardsContract] = true;
        _assets[rewardsContract] = asset;
        emit AssetAdded(rewardsContract, asset);
    }
    function removeAsset(address rewardsContract) external onlyOwner {
        if (!_isRewardsContract[rewardsContract]) revert ErrorRemovingAsset();
        emit AssetRemoved(rewardsContract, _assets[rewardsContract]);
        delete _isAsset[_assets[rewardsContract]];
        delete _isRewardsContract[rewardsContract];
        delete _assets[rewardsContract];
    }
    modifier onlyFlywheelRewards() override {
        if (!_isRewardsContract[msg.sender]) revert FlywheelRewardsError();
        _;
    }
}
interface IFlywheelRewards {
    function rewardToken() external view returns (address);
    function flywheel() external view returns (FlywheelCore_0);
    error FlywheelError();
}
abstract contract BaseFlywheelRewards is IFlywheelRewards {
    using SafeTransferLib for address;
    address public immutable override rewardToken;
    FlywheelCore_0 public immutable override flywheel;
    constructor(FlywheelCore_0 _flywheel) {
        flywheel = _flywheel;
        address _rewardToken = _flywheel.rewardToken();
        rewardToken = _rewardToken;
        _rewardToken.safeApprove(address(_flywheel), type(uint256).max);
    }
    modifier onlyFlywheel() {
        if (msg.sender != address(flywheel)) revert FlywheelError();
        _;
    }
}
interface INonfungiblePositionManager is
    IPoolInitializer,
    IPeripheryPayments,
    IPeripheryImmutableState,
    IERC721Metadata,
    IERC721Enumerable,
    IERC721Permit
{
    event IncreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event DecreaseLiquidity(uint256 indexed tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);
    event Collect(uint256 indexed tokenId, address recipient, uint256 amount0, uint256 amount1);
    function positions(uint256 tokenId)
        external
        view
        returns (
            uint96 nonce,
            address operator,
            address token0,
            address token1,
            uint24 fee,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );
    struct MintParams {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        address recipient;
        uint256 deadline;
    }
    function mint(MintParams calldata params)
        external
        payable
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );
    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }
    function increaseLiquidity(IncreaseLiquidityParams calldata params)
        external
        payable
        returns (
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        );
    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }
    function decreaseLiquidity(DecreaseLiquidityParams calldata params)
        external
        payable
        returns (uint256 amount0, uint256 amount1);
    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }
    function collect(CollectParams calldata params) external payable returns (uint256 amount0, uint256 amount1);
    function burn(uint256 tokenId) external payable;
}
contract FlywheelCore_1 is FlywheelCore_0 {
    constructor(
        address _rewardToken,
        IFlywheelRewards _flywheelRewards,
        IFlywheelBooster _flywheelBooster,
        address _owner
    ) FlywheelCore_0(_rewardToken, address(_flywheelRewards), _flywheelBooster, _owner) {}
    function _getAccruedRewards(ERC20 strategy) internal override returns (uint256) {
        return IFlywheelAcummulatedRewards(flywheelRewards).getAccruedRewards(strategy);
    }
}
abstract contract FlywheelAcummulatedRewards is BaseFlywheelRewards, IFlywheelAcummulatedRewards {
    using SafeCastLib for uint256;
    uint256 public immutable override rewardsCycleLength;
    uint256 public override endCycle;
    constructor(FlywheelCore_0 _flywheel, uint256 _rewardsCycleLength) BaseFlywheelRewards(_flywheel) {
        rewardsCycleLength = _rewardsCycleLength;
    }
    function getAccruedRewards(ERC20 strategy) external override onlyFlywheel returns (uint256 amount) {
        uint32 timestamp = block.timestamp.toUint32();
        if (timestamp >= endCycle) {
            amount = getNextCycleRewards(strategy);
            uint256 newEndCycle = ((timestamp + rewardsCycleLength) / rewardsCycleLength) * rewardsCycleLength;
            endCycle = newEndCycle;
            emit NewRewardsCycle(timestamp, newEndCycle, amount);
        } else {
            amount = 0;
        }
    }
    function getNextCycleRewards(ERC20 strategy) internal virtual returns (uint256);
}
contract FlywheelBribeRewards is FlywheelAcummulatedRewards, IFlywheelBribeRewards {
    mapping(ERC20 => RewardsDepot) public override rewardsDepots;
    constructor(FlywheelCore_0 _flywheel, uint256 _rewardsCycleLength)
        FlywheelAcummulatedRewards(_flywheel, _rewardsCycleLength)
    {}
    function getNextCycleRewards(ERC20 strategy) internal override returns (uint256) {
        return rewardsDepots[strategy].getRewards();
    }
    function setRewardsDepot(RewardsDepot rewardsDepot) external {
        rewardsDepots[ERC20(msg.sender)] = rewardsDepot;
        emit AddRewardsDepot(msg.sender, rewardsDepot);
    }
}
library NFTPositionInfo {
    function getPositionInfo(
        IUniswapV3Factory factory,
        INonfungiblePositionManager nonfungiblePositionManager,
        uint256 tokenId
    ) internal view returns (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) {
        address token0;
        address token1;
        uint24 fee;
        (,, token0, token1, fee, tickLower, tickUpper, liquidity,,,,) = nonfungiblePositionManager.positions(tokenId);
        pool = IUniswapV3Pool(
            PoolAddress.computeAddress(
                address(factory), PoolAddress.PoolKey({token0: token0, token1: token1, fee: fee})
            )
        );
    }
}
abstract contract ERC20MultiVotes is ERC20, Ownable, IERC20MultiVotes {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeCastLib for *;
    mapping(address => Checkpoint[]) private _checkpoints;
    function checkpoints(address account, uint32 pos) public view virtual returns (Checkpoint memory) {
        return _checkpoints[account][pos];
    }
    function numCheckpoints(address account) public view virtual returns (uint32) {
        return _checkpoints[account].length.toUint32();
    }
    function freeVotes(address account) public view virtual returns (uint256) {
        return balanceOf[account] - userDelegatedVotes[account];
    }
    function getVotes(address account) public view virtual returns (uint256) {
        uint256 pos = _checkpoints[account].length;
        return pos == 0 ? 0 : _checkpoints[account][pos - 1].votes;
    }
    function userUnusedVotes(address user) public view virtual returns (uint256) {
        return getVotes(user);
    }
    function getPriorVotes(address account, uint256 blockNumber) public view virtual returns (uint256) {
        if (blockNumber >= block.number) revert BlockError();
        return _checkpointsLookup(_checkpoints[account], blockNumber);
    }
    function _checkpointsLookup(Checkpoint[] storage ckpts, uint256 blockNumber) private view returns (uint256) {
        uint256 high = ckpts.length;
        uint256 low = 0;
        while (low < high) {
            uint256 mid = average(low, high);
            if (ckpts[mid].fromBlock > blockNumber) {
                high = mid;
            } else {
                low = mid + 1;
            }
        }
        return high == 0 ? 0 : ckpts[high - 1].votes;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }
    uint256 public override maxDelegates;
    mapping(address => bool) public override canContractExceedMaxDelegates;
    function setMaxDelegates(uint256 newMax) external onlyOwner {
        uint256 oldMax = maxDelegates;
        maxDelegates = newMax;
        emit MaxDelegatesUpdate(oldMax, newMax);
    }
    function setContractExceedMaxDelegates(address account, bool canExceedMax) external onlyOwner {
        if (canExceedMax && account.code.length == 0) revert Errors.NonContractError(); 
        canContractExceedMaxDelegates[account] = canExceedMax;
        emit CanContractExceedMaxDelegatesUpdate(account, canExceedMax);
    }
    mapping(address => mapping(address => uint256)) private _delegatesVotesCount;
    mapping(address => uint256) public userDelegatedVotes;
    mapping(address => EnumerableSet.AddressSet) private _delegates;
    function delegatesVotesCount(address delegator, address delegatee) public view virtual returns (uint256) {
        return _delegatesVotesCount[delegator][delegatee];
    }
    function delegates(address delegator) public view returns (address[] memory) {
        return _delegates[delegator].values();
    }
    function delegateCount(address delegator) public view returns (uint256) {
        return _delegates[delegator].length();
    }
    function incrementDelegation(address delegatee, uint256 amount) public virtual {
        _incrementDelegation(msg.sender, delegatee, amount);
    }
    function undelegate(address delegatee, uint256 amount) public virtual {
        _undelegate(msg.sender, delegatee, amount);
    }
    function delegate(address newDelegatee) external virtual {
        _delegate(msg.sender, newDelegatee);
    }
    function _delegate(address delegator, address newDelegatee) internal virtual {
        uint256 count = delegateCount(delegator);
        if (count > 1) revert DelegationError();
        address oldDelegatee;
        if (count == 1) {
            oldDelegatee = _delegates[delegator].at(0);
            _undelegate(delegator, oldDelegatee, _delegatesVotesCount[delegator][oldDelegatee]);
        }
        if (newDelegatee != address(0)) {
            _incrementDelegation(delegator, newDelegatee, freeVotes(delegator));
        }
        emit DelegateChanged(delegator, oldDelegatee, newDelegatee);
    }
    function _incrementDelegation(address delegator, address delegatee, uint256 amount) internal virtual {
        uint256 free = freeVotes(delegator);
        if (delegatee == address(0) || free < amount || amount == 0) revert DelegationError();
        bool newDelegate = _delegates[delegator].add(delegatee); 
        if (newDelegate && delegateCount(delegator) > maxDelegates && !canContractExceedMaxDelegates[delegator]) {
            revert DelegationError();
        }
        _delegatesVotesCount[delegator][delegatee] += amount;
        userDelegatedVotes[delegator] += amount;
        emit Delegation(delegator, delegatee, amount);
        _writeCheckpoint(delegatee, _add, amount);
    }
    function _undelegate(address delegator, address delegatee, uint256 amount) internal virtual {
        if (userUnusedVotes(delegatee) < amount) revert UndelegationVoteError();
        uint256 newDelegates = _delegatesVotesCount[delegator][delegatee] - amount;
        if (newDelegates == 0) {
            require(_delegates[delegator].remove(delegatee));
        }
        _delegatesVotesCount[delegator][delegatee] = newDelegates;
        userDelegatedVotes[delegator] -= amount;
        emit Undelegation(delegator, delegatee, amount);
        _writeCheckpoint(delegatee, _subtract, amount);
    }
    function _writeCheckpoint(address delegatee, function(uint256, uint256) view returns (uint256) op, uint256 delta)
        private
    {
        Checkpoint[] storage ckpts = _checkpoints[delegatee];
        uint256 pos = ckpts.length;
        uint256 oldWeight = pos == 0 ? 0 : ckpts[pos - 1].votes;
        uint256 newWeight = op(oldWeight, delta);
        if (pos > 0 && ckpts[pos - 1].fromBlock == block.number) {
            ckpts[pos - 1].votes = newWeight.toUint224();
        } else {
            ckpts.push(Checkpoint({fromBlock: block.number.toUint32(), votes: newWeight.toUint224()}));
        }
        emit DelegateVotesChanged(delegatee, oldWeight, newWeight);
    }
    function _add(uint256 a, uint256 b) private pure returns (uint256) {
        return a + b;
    }
    function _subtract(uint256 a, uint256 b) private pure returns (uint256) {
        return a - b;
    }
    function _burn(address from, uint256 amount) internal virtual override {
        _decrementVotesUntilFree(from, amount);
        super._burn(from, amount);
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _decrementVotesUntilFree(msg.sender, amount);
        return super.transfer(to, amount);
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _decrementVotesUntilFree(from, amount);
        return super.transferFrom(from, to, amount);
    }
    function _decrementVotesUntilFree(address user, uint256 votes) internal {
        uint256 userFreeVotes = freeVotes(user);
        if (userFreeVotes >= votes) return;
        uint256 totalFreed;
        address[] memory delegateList = _delegates[user].values();
        uint256 size = delegateList.length;
        for (uint256 i = 0; i < size && (userFreeVotes + totalFreed) < votes; i++) {
            address delegatee = delegateList[i];
            uint256 delegateVotes = _delegatesVotesCount[user][delegatee];
            uint256 votesToFree = FixedPointMathLib.min(delegateVotes, userUnusedVotes(delegatee));
            if (votesToFree != 0) {
                totalFreed += votesToFree;
                if (delegateVotes == votesToFree) {
                    require(_delegates[user].remove(delegatee)); 
                    _delegatesVotesCount[user][delegatee] = 0;
                } else {
                    _delegatesVotesCount[user][delegatee] -= votesToFree;
                }
                _writeCheckpoint(delegatee, _subtract, votesToFree);
                emit Undelegation(user, delegatee, votesToFree);
            }
        }
        if ((userFreeVotes + totalFreed) < votes) revert UndelegationVoteError();
        userDelegatedVotes[user] -= totalFreed;
    }
    bytes32 public constant DELEGATION_TYPEHASH =
        keccak256("Delegation(address delegatee,uint256 nonce,uint256 expiry)");
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) public {
        require(block.timestamp <= expiry, "ERC20MultiVotes: signature expired");
        address signer = ecrecover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01", DOMAIN_SEPARATOR(), keccak256(abi.encode(DELEGATION_TYPEHASH, delegatee, nonce, expiry))
                )
            ),
            v,
            r,
            s
        );
        require(nonce == nonces[signer]++, "ERC20MultiVotes: invalid nonce");
        require(signer != address(0));
        _delegate(signer, delegatee);
    }
}
abstract contract ERC20Gauges is ERC20MultiVotes, ReentrancyGuard, IERC20Gauges {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeCastLib for *;
    constructor(uint32 _gaugeCycleLength, uint32 _incrementFreezeWindow) {
        if (_incrementFreezeWindow >= _gaugeCycleLength) revert IncrementFreezeError();
        gaugeCycleLength = _gaugeCycleLength;
        incrementFreezeWindow = _incrementFreezeWindow;
    }
    uint32 public immutable override gaugeCycleLength;
    uint32 public immutable override incrementFreezeWindow;
    mapping(address => mapping(address => uint112)) public override getUserGaugeWeight;
    mapping(address => uint112) public override getUserWeight;
    mapping(address => Weight) internal _getGaugeWeight;
    Weight internal _totalWeight;
    mapping(address => EnumerableSet.AddressSet) internal _userGauges;
    EnumerableSet.AddressSet internal _gauges;
    EnumerableSet.AddressSet internal _deprecatedGauges;
    function getGaugeCycleEnd() external view returns (uint32) {
        return _getGaugeCycleEnd();
    }
    function _getGaugeCycleEnd() internal view returns (uint32) {
        uint32 nowPlusOneCycle = block.timestamp.toUint32() + gaugeCycleLength;
        unchecked {
            return (nowPlusOneCycle / gaugeCycleLength) * gaugeCycleLength; 
        }
    }
    function getGaugeWeight(address gauge) external view returns (uint112) {
        return _getGaugeWeight[gauge].currentWeight;
    }
    function getStoredGaugeWeight(address gauge) external view returns (uint112) {
        if (_deprecatedGauges.contains(gauge)) return 0;
        return _getStoredWeight(_getGaugeWeight[gauge], _getGaugeCycleEnd());
    }
    function _getStoredWeight(Weight storage gaugeWeight, uint32 currentCycle) internal view returns (uint112) {
        return gaugeWeight.currentCycle < currentCycle ? gaugeWeight.currentWeight : gaugeWeight.storedWeight;
    }
    function totalWeight() external view returns (uint112) {
        return _totalWeight.currentWeight;
    }
    function storedTotalWeight() external view returns (uint112) {
        return _getStoredWeight(_totalWeight, _getGaugeCycleEnd());
    }
    function gauges() external view returns (address[] memory) {
        return _gauges.values();
    }
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _gauges.at(offset + i); 
                i++;
            }
        }
    }
    function isGauge(address gauge) external view returns (bool) {
        return _gauges.contains(gauge) && !_deprecatedGauges.contains(gauge);
    }
    function numGauges() external view returns (uint256) {
        return _gauges.length();
    }
    function deprecatedGauges() external view returns (address[] memory) {
        return _deprecatedGauges.values();
    }
    function numDeprecatedGauges() external view returns (uint256) {
        return _deprecatedGauges.length();
    }
    function userGauges(address user) external view returns (address[] memory) {
        return _userGauges[user].values();
    }
    function isUserGauge(address user, address gauge) external view returns (bool) {
        return _userGauges[user].contains(gauge);
    }
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _userGauges[user].at(offset + i); 
                i++;
            }
        }
    }
    function numUserGauges(address user) external view returns (uint256) {
        return _userGauges[user].length();
    }
    function userUnusedVotes(address user) public view override returns (uint256) {
        return super.userUnusedVotes(user) - getUserWeight[user];
    }
    function calculateGaugeAllocation(address gauge, uint256 quantity) external view returns (uint256) {
        if (_deprecatedGauges.contains(gauge)) return 0;
        uint32 currentCycle = _getGaugeCycleEnd();
        uint112 total = _getStoredWeight(_totalWeight, currentCycle);
        uint112 weight = _getStoredWeight(_getGaugeWeight[gauge], currentCycle);
        return (quantity * weight) / total;
    }
    function incrementGauge(address gauge, uint112 weight) external nonReentrant returns (uint112 newUserWeight) {
        uint32 currentCycle = _getGaugeCycleEnd();
        _incrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
        return _incrementUserAndGlobalWeights(msg.sender, weight, currentCycle);
    }
    function _incrementGaugeWeight(address user, address gauge, uint112 weight, uint32 cycle) internal {
        if (!_gauges.contains(gauge) || _deprecatedGauges.contains(gauge)) revert InvalidGaugeError();
        unchecked {
            if (cycle - block.timestamp <= incrementFreezeWindow) revert IncrementFreezeError();
        }
        IBaseV2Gauge(gauge).accrueBribes(user);
        bool added = _userGauges[user].add(gauge); 
        if (added && _userGauges[user].length() > maxGauges && !canContractExceedMaxGauges[user]) {
            revert MaxGaugeError();
        }
        getUserGaugeWeight[user][gauge] += weight;
        _writeGaugeWeight(_getGaugeWeight[gauge], _add112, weight, cycle);
        emit IncrementGaugeWeight(user, gauge, weight, cycle);
    }
    function _incrementUserAndGlobalWeights(address user, uint112 weight, uint32 cycle)
        internal
        returns (uint112 newUserWeight)
    {
        newUserWeight = getUserWeight[user] + weight;
        if (newUserWeight > getVotes(user)) revert OverWeightError();
        getUserWeight[user] = newUserWeight;
        _writeGaugeWeight(_totalWeight, _add112, weight, cycle);
    }
    function incrementGauges(address[] calldata gaugeList, uint112[] calldata weights)
        external
        nonReentrant
        returns (uint256 newUserWeight)
    {
        uint256 size = gaugeList.length;
        if (weights.length != size) revert SizeMismatchError();
        uint112 weightsSum;
        uint32 currentCycle = _getGaugeCycleEnd();
        for (uint256 i = 0; i < size;) {
            address gauge = gaugeList[i];
            uint112 weight = weights[i];
            weightsSum += weight;
            _incrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
            unchecked {
                i++;
            }
        }
        return _incrementUserAndGlobalWeights(msg.sender, weightsSum, currentCycle);
    }
    function decrementGauge(address gauge, uint112 weight) external nonReentrant returns (uint112 newUserWeight) {
        uint32 currentCycle = _getGaugeCycleEnd();
        _decrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
        if (!_deprecatedGauges.contains(gauge)) {
            _writeGaugeWeight(_totalWeight, _subtract112, weight, currentCycle);
        }
        return _decrementUserWeights(msg.sender, weight);
    }
    function _decrementGaugeWeight(address user, address gauge, uint112 weight, uint32 cycle) internal {
        if (!_gauges.contains(gauge)) revert InvalidGaugeError();
        uint112 oldWeight = getUserGaugeWeight[user][gauge];
        IBaseV2Gauge(gauge).accrueBribes(user);
        getUserGaugeWeight[user][gauge] = oldWeight - weight;
        if (oldWeight == weight) {
            require(_userGauges[user].remove(gauge));
        }
        _writeGaugeWeight(_getGaugeWeight[gauge], _subtract112, weight, cycle);
        emit DecrementGaugeWeight(user, gauge, weight, cycle);
    }
    function _decrementUserWeights(address user, uint112 weight) internal returns (uint112 newUserWeight) {
        newUserWeight = getUserWeight[user] - weight;
        getUserWeight[user] = newUserWeight;
    }
    function decrementGauges(address[] calldata gaugeList, uint112[] calldata weights)
        external
        nonReentrant
        returns (uint112 newUserWeight)
    {
        uint256 size = gaugeList.length;
        if (weights.length != size) revert SizeMismatchError();
        uint112 weightsSum;
        uint112 globalWeightsSum;
        uint32 currentCycle = _getGaugeCycleEnd();
        for (uint256 i = 0; i < size;) {
            address gauge = gaugeList[i];
            uint112 weight = weights[i];
            weightsSum += weight;
            if (!_deprecatedGauges.contains(gauge)) globalWeightsSum += weight;
            _decrementGaugeWeight(msg.sender, gauge, weight, currentCycle);
            unchecked {
                i++;
            }
        }
        _writeGaugeWeight(_totalWeight, _subtract112, globalWeightsSum, currentCycle);
        return _decrementUserWeights(msg.sender, weightsSum);
    }
    function _writeGaugeWeight(
        Weight storage weight,
        function(uint112, uint112) view returns (uint112) op,
        uint112 delta,
        uint32 cycle
    ) private {
        uint112 currentWeight = weight.currentWeight;
        uint112 stored = weight.currentCycle < cycle ? currentWeight : weight.storedWeight;
        uint112 newWeight = op(currentWeight, delta);
        weight.storedWeight = stored;
        weight.currentWeight = newWeight;
        weight.currentCycle = cycle;
    }
    function _add112(uint112 a, uint112 b) private pure returns (uint112) {
        return a + b;
    }
    function _subtract112(uint112 a, uint112 b) private pure returns (uint112) {
        return a - b;
    }
    uint256 public override maxGauges;
    mapping(address => bool) public override canContractExceedMaxGauges;
    function addGauge(address gauge) external onlyOwner returns (uint112) {
        return _addGauge(gauge);
    }
    function _addGauge(address gauge) internal returns (uint112 weight) {
        bool newAdd = _gauges.add(gauge);
        bool previouslyDeprecated = _deprecatedGauges.remove(gauge);
        if (gauge == address(0) || !(newAdd || previouslyDeprecated)) revert InvalidGaugeError();
        uint32 currentCycle = _getGaugeCycleEnd();
        weight = _getGaugeWeight[gauge].currentWeight;
        if (weight > 0) {
            _writeGaugeWeight(_totalWeight, _add112, weight, currentCycle);
        }
        emit AddGauge(gauge);
    }
    function removeGauge(address gauge) external onlyOwner {
        _removeGauge(gauge);
    }
    function _removeGauge(address gauge) internal {
        if (!_deprecatedGauges.add(gauge)) revert InvalidGaugeError();
        uint32 currentCycle = _getGaugeCycleEnd();
        uint112 weight = _getGaugeWeight[gauge].currentWeight;
        if (weight > 0) {
            _writeGaugeWeight(_totalWeight, _subtract112, weight, currentCycle);
        }
        emit RemoveGauge(gauge);
    }
    function replaceGauge(address oldGauge, address newGauge) external onlyOwner {
        _removeGauge(oldGauge);
        _addGauge(newGauge);
    }
    function setMaxGauges(uint256 newMax) external onlyOwner {
        uint256 oldMax = maxGauges;
        maxGauges = newMax;
        emit MaxGaugesUpdate(oldMax, newMax);
    }
    function setContractExceedMaxGauges(address account, bool canExceedMax) external onlyOwner {
        if (canExceedMax && account.code.length == 0) revert Errors.NonContractError(); 
        canContractExceedMaxGauges[account] = canExceedMax;
        emit CanContractExceedMaxGaugesUpdate(account, canExceedMax);
    }
    function _burn(address from, uint256 amount) internal virtual override {
        _decrementWeightUntilFree(from, amount);
        super._burn(from, amount);
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _decrementWeightUntilFree(msg.sender, amount);
        return super.transfer(to, amount);
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        _decrementWeightUntilFree(from, amount);
        return super.transferFrom(from, to, amount);
    }
    function _decrementWeightUntilFree(address user, uint256 weight) internal nonReentrant {
        uint256 userFreeWeight = freeVotes(user) + userUnusedVotes(user);
        if (userFreeWeight >= weight) return;
        uint32 currentCycle = _getGaugeCycleEnd();
        uint112 userFreed;
        uint112 totalFreed;
        address[] memory gaugeList = _userGauges[user].values();
        uint256 size = gaugeList.length;
        for (uint256 i = 0; i < size && (userFreeWeight + totalFreed) < weight;) {
            address gauge = gaugeList[i];
            uint112 userGaugeWeight = getUserGaugeWeight[user][gauge];
            if (userGaugeWeight != 0) {
                if (!_deprecatedGauges.contains(gauge)) {
                    totalFreed += userGaugeWeight;
                }
                userFreed += userGaugeWeight;
                _decrementGaugeWeight(user, gauge, userGaugeWeight, currentCycle);
                unchecked {
                    i++;
                }
            }
        }
        getUserWeight[user] -= userFreed;
        _writeGaugeWeight(_totalWeight, _subtract112, totalFreed, currentCycle);
    }
}
interface IBaseV2Gauge {
    function rewardToken() external returns (address);
    function flywheelGaugeRewards() external returns (FlywheelGaugeRewards);
    function isActive(FlywheelCore_1 flywheel) external returns (bool);
    function added(FlywheelCore_1 flywheel) external returns (bool);
    function strategy() external returns (address);
    function multiRewardsDepot() external returns (MultiRewardsDepot);
    function epoch() external returns (uint256);
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory);
    function newEpoch() external;
    function attachUser(address user) external;
    function detachUser(address user) external;
    function accrueBribes(address user) external;
    function addBribeFlywheel(FlywheelCore_1 bribeFlywheel) external;
    function removeBribeFlywheel(FlywheelCore_1 bribeFlywheel) external;
    event Distribute(uint256 indexed amount, uint256 indexed epoch);
    event AddedBribeFlywheel(FlywheelCore_1 indexed bribeFlywheel);
    event RemoveBribeFlywheel(FlywheelCore_1 indexed bribeFlywheel);
    error StrategyError();
    error FlywheelAlreadyAdded();
    error FlywheelNotActive();
}
interface IRewardsStream {
    function getRewards() external returns (uint256);
}
interface IBaseV2Minter is IRewardsStream {
    function underlying() external view returns (address);
    function vault() external view returns (ERC4626);
    function flywheelGaugeRewards() external view returns (FlywheelGaugeRewards);
    function dao() external view returns (address);
    function daoShare() external view returns (uint256);
    function tailEmission() external view returns (uint256);
    function weekly() external view returns (uint256);
    function activePeriod() external view returns (uint256);
    function initialize(FlywheelGaugeRewards _flywheelGaugeRewards) external;
    function setTailEmission(uint256 _tail_emission) external;
    function setDao(address _dao) external;
    function setDaoShare(uint256 _dao_share) external;
    function circulatingSupply() external view returns (uint256);
    function weeklyEmission() external view returns (uint256);
    function calculateGrowth(uint256 _minted) external view returns (uint256);
    function updatePeriod() external returns (uint256);
    function getRewards() external returns (uint256 totalQueuedForCycle);
    event Mint(address indexed sender, uint256 weekly, uint256 circulatingSupply, uint256 growth, uint256 dao_share);
    error NotFlywheelGaugeRewards();
    error NotInitializer();
    error TailEmissionTooHigh();
    error DaoShareTooHigh();
}
interface IFlywheelGaugeRewards {
    struct QueuedRewards {
        uint112 priorCycleRewards;
        uint112 cycleRewards;
        uint32 storedCycle;
    }
    function gaugeToken() external view returns (ERC20Gauges);
    function rewardToken() external view returns (address);
    function gaugeCycle() external view returns (uint32);
    function gaugeCycleLength() external view returns (uint32);
    function gaugeQueuedRewards(ERC20)
        external
        view
        returns (uint112 priorCycleRewards, uint112 cycleRewards, uint32 storedCycle);
    function queueRewardsForCycle() external returns (uint256 totalQueuedForCycle);
    function queueRewardsForCyclePaginated(uint256 numRewards) external;
    function getAccruedRewards() external returns (uint256 amount);
    event CycleStart(uint32 indexed cycleStart, uint256 rewardAmount);
    event QueueRewards(address indexed gauge, uint32 indexed cycleStart, uint256 rewardAmount);
    error CycleError();
    error EmptyGaugesError();
}
contract FlywheelGaugeRewards is Ownable, IFlywheelGaugeRewards {
    using SafeTransferLib for address;
    using SafeCastLib for uint256;
    ERC20Gauges public immutable override gaugeToken;
    IBaseV2Minter public immutable minter;
    address public immutable override rewardToken;
    uint32 public override gaugeCycle;
    uint32 public immutable override gaugeCycleLength;
    mapping(ERC20 => QueuedRewards) public override gaugeQueuedRewards;
    uint32 internal nextCycle;
    uint112 internal nextCycleQueuedRewards;
    uint32 internal paginationOffset;
    constructor(address _rewardToken, address _owner, ERC20Gauges _gaugeToken, IBaseV2Minter _minter) {
        _initializeOwner(_owner);
        rewardToken = _rewardToken;
        gaugeCycleLength = _gaugeToken.gaugeCycleLength();
        gaugeCycle = (block.timestamp.toUint32() / gaugeCycleLength) * gaugeCycleLength;
        gaugeToken = _gaugeToken;
        minter = _minter;
    }
    function queueRewardsForCycle() external returns (uint256 totalQueuedForCycle) {
        minter.updatePeriod();
        uint32 currentCycle = (block.timestamp.toUint32() / gaugeCycleLength) * gaugeCycleLength;
        uint32 lastCycle = gaugeCycle;
        if (currentCycle <= lastCycle) revert CycleError();
        gaugeCycle = currentCycle;
        uint256 balanceBefore = rewardToken.balanceOf(address(this));
        totalQueuedForCycle = minter.getRewards();
        require(rewardToken.balanceOf(address(this)) - balanceBefore >= totalQueuedForCycle);
        totalQueuedForCycle += nextCycleQueuedRewards;
        address[] memory gauges = gaugeToken.gauges();
        _queueRewards(gauges, currentCycle, lastCycle, totalQueuedForCycle);
        nextCycleQueuedRewards = 0;
        paginationOffset = 0;
        emit CycleStart(currentCycle, totalQueuedForCycle);
    }
    function queueRewardsForCyclePaginated(uint256 numRewards) external {
        minter.updatePeriod();
        uint32 currentCycle = (block.timestamp.toUint32() / gaugeCycleLength) * gaugeCycleLength;
        uint32 lastCycle = gaugeCycle;
        if (currentCycle <= lastCycle) revert CycleError();
        if (currentCycle > nextCycle) {
            nextCycle = currentCycle;
            paginationOffset = 0;
        }
        uint32 offset = paginationOffset;
        if (offset == 0) {
            uint256 balanceBefore = rewardToken.balanceOf(address(this));
            uint256 newRewards = minter.getRewards();
            require(rewardToken.balanceOf(address(this)) - balanceBefore >= newRewards);
            require(newRewards <= type(uint112).max); 
            nextCycleQueuedRewards += uint112(newRewards); 
        }
        uint112 queued = nextCycleQueuedRewards;
        uint256 remaining = gaugeToken.numGauges() - offset;
        if (remaining <= numRewards) {
            numRewards = remaining;
            gaugeCycle = currentCycle;
            nextCycleQueuedRewards = 0;
            paginationOffset = 0;
            emit CycleStart(currentCycle, queued);
        } else {
            paginationOffset = offset + numRewards.toUint32();
        }
        address[] memory gauges = gaugeToken.gauges(offset, numRewards);
        _queueRewards(gauges, currentCycle, lastCycle, queued);
    }
    function _queueRewards(address[] memory gauges, uint32 currentCycle, uint32 lastCycle, uint256 totalQueuedForCycle)
        internal
    {
        uint256 size = gauges.length;
        if (size == 0) revert EmptyGaugesError();
        for (uint256 i = 0; i < size; i++) {
            ERC20 gauge = ERC20(gauges[i]);
            QueuedRewards memory queuedRewards = gaugeQueuedRewards[gauge];
            require(queuedRewards.storedCycle < currentCycle);
            assert(queuedRewards.storedCycle == 0 || queuedRewards.storedCycle >= lastCycle);
            uint112 completedRewards = queuedRewards.storedCycle == lastCycle ? queuedRewards.cycleRewards : 0;
            uint256 nextRewards = gaugeToken.calculateGaugeAllocation(address(gauge), totalQueuedForCycle);
            require(nextRewards <= type(uint112).max); 
            gaugeQueuedRewards[gauge] = QueuedRewards({
                priorCycleRewards: queuedRewards.priorCycleRewards + completedRewards,
                cycleRewards: uint112(nextRewards),
                storedCycle: currentCycle
            });
            emit QueueRewards(address(gauge), currentCycle, nextRewards);
        }
    }
    function getAccruedRewards() external returns (uint256 accruedRewards) {
        minter.updatePeriod();
        QueuedRewards memory queuedRewards = gaugeQueuedRewards[ERC20(msg.sender)];
        uint32 cycle = gaugeCycle;
        bool incompleteCycle = queuedRewards.storedCycle > cycle;
        if (queuedRewards.priorCycleRewards == 0 && (queuedRewards.cycleRewards == 0 || incompleteCycle)) {
            return 0;
        }
        assert(queuedRewards.storedCycle >= cycle);
        accruedRewards = queuedRewards.priorCycleRewards;
        uint112 cycleRewardsNext = queuedRewards.cycleRewards;
        if (incompleteCycle) {
        } else {
            accruedRewards += cycleRewardsNext;
            cycleRewardsNext = 0;
        }
        gaugeQueuedRewards[ERC20(msg.sender)] = QueuedRewards({
            priorCycleRewards: 0,
            cycleRewards: cycleRewardsNext,
            storedCycle: queuedRewards.storedCycle
        });
        if (accruedRewards > 0) rewardToken.safeTransfer(msg.sender, accruedRewards);
    }
}
abstract contract ERC20Boost is ERC20, Ownable, IERC20Boost {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeCastLib for *;
    mapping(address => mapping(address => GaugeState)) public override getUserGaugeBoost;
    mapping(address => uint256) public override getUserBoost;
    mapping(address => EnumerableSet.AddressSet) internal _userGauges;
    EnumerableSet.AddressSet internal _gauges;
    EnumerableSet.AddressSet internal _deprecatedGauges;
    function gauges() external view returns (address[] memory) {
        return _gauges.values();
    }
    function gauges(uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _gauges.at(offset + i); 
                i++;
            }
        }
    }
    function isGauge(address gauge) external view returns (bool) {
        return _gauges.contains(gauge) && !_deprecatedGauges.contains(gauge);
    }
    function numGauges() external view returns (uint256) {
        return _gauges.length();
    }
    function deprecatedGauges() external view returns (address[] memory) {
        return _deprecatedGauges.values();
    }
    function numDeprecatedGauges() external view returns (uint256) {
        return _deprecatedGauges.length();
    }
    function freeGaugeBoost(address user) public view returns (uint256) {
        return balanceOf[user] - getUserBoost[user];
    }
    function userGauges(address user) external view returns (address[] memory) {
        return _userGauges[user].values();
    }
    function isUserGauge(address user, address gauge) external view returns (bool) {
        return _userGauges[user].contains(gauge);
    }
    function userGauges(address user, uint256 offset, uint256 num) external view returns (address[] memory values) {
        values = new address[](num);
        for (uint256 i = 0; i < num;) {
            unchecked {
                values[i] = _userGauges[user].at(offset + i); 
                i++;
            }
        }
    }
    function numUserGauges(address user) external view returns (uint256) {
        return _userGauges[user].length();
    }
    function attach(address user) external {
        if (!_gauges.contains(msg.sender) || _deprecatedGauges.contains(msg.sender)) {
            revert InvalidGauge();
        }
        if (!_userGauges[user].add(msg.sender)) revert GaugeAlreadyAttached();
        uint128 userGaugeBoost = balanceOf[user].toUint128();
        if (getUserBoost[user] < userGaugeBoost) {
            getUserBoost[user] = userGaugeBoost;
            emit UpdateUserBoost(user, userGaugeBoost);
        }
        getUserGaugeBoost[user][msg.sender] =
            GaugeState({userGaugeBoost: userGaugeBoost, totalGaugeBoost: totalSupply.toUint128()});
        emit Attach(user, msg.sender, userGaugeBoost);
    }
    function detach(address user) external {
        require(_userGauges[user].remove(msg.sender));
        delete getUserGaugeBoost[user][msg.sender];
        emit Detach(user, msg.sender);
    }
    function updateUserBoost(address user) external {
        uint256 userBoost = 0;
        address[] memory gaugeList = _userGauges[user].values();
        uint256 length = gaugeList.length;
        for (uint256 i = 0; i < length;) {
            address gauge = gaugeList[i];
            if (!_deprecatedGauges.contains(gauge)) {
                uint256 gaugeBoost = getUserGaugeBoost[user][gauge].userGaugeBoost;
                if (userBoost < gaugeBoost) userBoost = gaugeBoost;
            }
            unchecked {
                i++;
            }
        }
        getUserBoost[user] = userBoost;
        emit UpdateUserBoost(user, userBoost);
    }
    function decrementGaugeBoost(address gauge, uint256 boost) public {
        GaugeState storage gaugeState = getUserGaugeBoost[msg.sender][gauge];
        if (boost >= gaugeState.userGaugeBoost) {
            _userGauges[msg.sender].remove(gauge);
            delete getUserGaugeBoost[msg.sender][gauge];
            emit Detach(msg.sender, gauge);
        } else {
            gaugeState.userGaugeBoost -= boost.toUint128();
            emit DecrementUserGaugeBoost(msg.sender, gauge, gaugeState.userGaugeBoost);
        }
    }
    function decrementGaugeAllBoost(address gauge) external {
        require(_userGauges[msg.sender].remove(gauge));
        delete getUserGaugeBoost[msg.sender][gauge];
        emit Detach(msg.sender, gauge);
    }
    function decrementAllGaugesBoost(uint256 boost) external {
        decrementGaugesBoostIndexed(boost, 0, _userGauges[msg.sender].length());
    }
    function decrementGaugesBoostIndexed(uint256 boost, uint256 offset, uint256 num) public {
        address[] memory gaugeList = _userGauges[msg.sender].values();
        uint256 length = gaugeList.length;
        for (uint256 i = 0; i < num && i < length;) {
            address gauge = gaugeList[offset + i];
            GaugeState storage gaugeState = getUserGaugeBoost[msg.sender][gauge];
            if (_deprecatedGauges.contains(gauge) || boost >= gaugeState.userGaugeBoost) {
                require(_userGauges[msg.sender].remove(gauge)); 
                delete getUserGaugeBoost[msg.sender][gauge];
                emit Detach(msg.sender, gauge);
            } else {
                gaugeState.userGaugeBoost -= boost.toUint128();
                emit DecrementUserGaugeBoost(msg.sender, gauge, gaugeState.userGaugeBoost);
            }
            unchecked {
                i++;
            }
        }
    }
    function decrementAllGaugesAllBoost() external {
        address[] memory gaugeList = _userGauges[msg.sender].values();
        uint256 size = gaugeList.length;
        for (uint256 i = 0; i < size;) {
            address gauge = gaugeList[i];
            require(_userGauges[msg.sender].remove(gauge)); 
            delete getUserGaugeBoost[msg.sender][gauge];
            emit Detach(msg.sender, gauge);
            unchecked {
                i++;
            }
        }
        getUserBoost[msg.sender] = 0;
        emit UpdateUserBoost(msg.sender, 0);
    }
    function addGauge(address gauge) external onlyOwner {
        _addGauge(gauge);
    }
    function _addGauge(address gauge) internal {
        bool newAdd = _gauges.add(gauge);
        bool previouslyDeprecated = _deprecatedGauges.remove(gauge);
        if (gauge == address(0) || !(newAdd || previouslyDeprecated)) revert InvalidGauge();
        emit AddGauge(gauge);
    }
    function removeGauge(address gauge) external onlyOwner {
        _removeGauge(gauge);
    }
    function _removeGauge(address gauge) internal {
        if (!_deprecatedGauges.add(gauge)) revert InvalidGauge();
        emit RemoveGauge(gauge);
    }
    function replaceGauge(address oldGauge, address newGauge) external onlyOwner {
        _removeGauge(oldGauge);
        _addGauge(newGauge);
    }
    function _burn(address from, uint256 amount) internal override notAttached(from, amount) {
        super._burn(from, amount);
    }
    function transfer(address to, uint256 amount) public override notAttached(msg.sender, amount) returns (bool) {
        return super.transfer(to, amount);
    }
    function transferFrom(address from, address to, uint256 amount)
        public
        override
        notAttached(from, amount)
        returns (bool)
    {
        return super.transferFrom(from, to, amount);
    }
    modifier notAttached(address user, uint256 amount) {
        if (freeGaugeBoost(user) < amount) revert AttachedBoost();
        _;
    }
}
contract bHermesGauges is ERC20Gauges, IbHermesUnderlying {
    address public immutable bHermes;
    constructor(address _owner, uint32 _rewardsCycleLength, uint32 _incrementFreezeWindow)
        ERC20Gauges(_rewardsCycleLength, _incrementFreezeWindow)
        ERC20("bHermes Gauges", "bHERMES-G", 18)
    {
        _initializeOwner(_owner);
        bHermes = msg.sender;
    }
    function mint(address to, uint256 amount) external onlybHermes {
        _mint(to, amount);
    }
    modifier onlybHermes() {
        if (msg.sender != bHermes) revert NotbHermes();
        _;
    }
}
contract bHermesVotes is ERC20MultiVotes, IbHermesUnderlying {
    address public immutable bHermes;
    constructor(address _owner) ERC20("bHermes Votes", "bHERMES-V", 18) {
        _initializeOwner(_owner);
        bHermes = msg.sender;
    }
    function mint(address to, uint256 amount) external onlybHermes {
        _mint(to, amount);
    }
    function burn(address from, uint256 amount) external onlybHermes {
        _burn(from, amount);
    }
    modifier onlybHermes() {
        if (msg.sender != bHermes) revert NotbHermes();
        _;
    }
}
contract FlywheelBoosterGaugeWeight is IFlywheelBooster {
    bHermesGauges private immutable bhermes;
    constructor(bHermesGauges _bHermesGauges) {
        bhermes = _bHermesGauges;
    }
    function boostedTotalSupply(ERC20 strategy) external view returns (uint256) {
        return bhermes.getGaugeWeight(address(strategy));
    }
    function boostedBalanceOf(ERC20 strategy, address user) external view returns (uint256) {
        return bhermes.getUserGaugeWeight(user, address(strategy));
    }
}
contract bHermesBoost is ERC20Boost, IbHermesUnderlying {
    address public immutable bHermes;
    constructor(address _owner) ERC20("bHermes Boost", "bHERMES-B", 18) {
        _initializeOwner(_owner);
        bHermes = msg.sender;
    }
    function mint(address to, uint256 amount) external onlybHermes {
        _mint(to, amount);
    }
    modifier onlybHermes() {
        if (msg.sender != bHermes) revert NotbHermes();
        _;
    }
}
interface IUtilityManager {
    function gaugeWeight() external view returns (bHermesGauges);
    function gaugeBoost() external view returns (bHermesBoost);
    function governance() external view returns (bHermesVotes);
    function userClaimedWeight(address) external view returns (uint256);
    function userClaimedBoost(address) external view returns (uint256);
    function userClaimedGovernance(address) external view returns (uint256);
    function forfeitMultiple(uint256 amount) external;
    function forfeitMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) external;
    function forfeitWeight(uint256 amount) external;
    function forfeitBoost(uint256 amount) external;
    function forfeitGovernance(uint256 amount) external;
    function claimMultiple(uint256 amount) external;
    function claimMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) external;
    function claimWeight(uint256 amount) external;
    function claimBoost(uint256 amount) external;
    function claimGovernance(uint256 amount) external;
    event ForfeitWeight(address indexed user, uint256 amount);
    event ForfeitBoost(address indexed user, uint256 amount);
    event ForfeitGovernance(address indexed user, uint256 amount);
    event ClaimWeight(address indexed user, uint256 amount);
    event ClaimBoost(address indexed user, uint256 amount);
    event ClaimGovernance(address indexed user, uint256 amount);
    error InsufficientShares();
}
abstract contract UtilityManager is IUtilityManager {
    using SafeTransferLib for address;
    bHermesGauges public immutable gaugeWeight;
    bHermesBoost public immutable gaugeBoost;
    bHermesVotes public immutable governance;
    mapping(address => uint256) public userClaimedWeight;
    mapping(address => uint256) public userClaimedBoost;
    mapping(address => uint256) public userClaimedGovernance;
    constructor(address _gaugeWeight, address _gaugeBoost, address _governance) {
        gaugeWeight = bHermesGauges(_gaugeWeight);
        gaugeBoost = bHermesBoost(_gaugeBoost);
        governance = bHermesVotes(_governance);
    }
    function forfeitMultiple(uint256 amount) public virtual {
        forfeitWeight(amount);
        forfeitBoost(amount);
        forfeitGovernance(amount);
    }
    function forfeitMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) public virtual {
        forfeitWeight(weight);
        forfeitBoost(boost);
        forfeitGovernance(_governance);
    }
    function forfeitWeight(uint256 amount) public virtual {
        if (amount == 0) return;
        userClaimedWeight[msg.sender] -= amount;
        address(gaugeWeight).safeTransferFrom(msg.sender, address(this), amount);
        emit ForfeitWeight(msg.sender, amount);
    }
    function forfeitBoost(uint256 amount) public virtual {
        if (amount == 0) return;
        userClaimedBoost[msg.sender] -= amount;
        address(gaugeBoost).safeTransferFrom(msg.sender, address(this), amount);
        emit ForfeitBoost(msg.sender, amount);
    }
    function forfeitGovernance(uint256 amount) public virtual {
        if (amount == 0) return;
        userClaimedGovernance[msg.sender] -= amount;
        address(governance).safeTransferFrom(msg.sender, address(this), amount);
        emit ForfeitGovernance(msg.sender, amount);
    }
    function claimMultiple(uint256 amount) public virtual {
        claimWeight(amount);
        claimBoost(amount);
        claimGovernance(amount);
    }
    function claimMultipleAmounts(uint256 weight, uint256 boost, uint256 _governance) public virtual {
        claimWeight(weight);
        claimBoost(boost);
        claimGovernance(_governance);
    }
    function claimWeight(uint256 amount) public virtual checkWeight(amount) {
        if (amount == 0) return;
        userClaimedWeight[msg.sender] += amount;
        address(gaugeWeight).safeTransfer(msg.sender, amount);
        emit ClaimWeight(msg.sender, amount);
    }
    function claimBoost(uint256 amount) public virtual checkBoost(amount) {
        if (amount == 0) return;
        userClaimedBoost[msg.sender] += amount;
        address(gaugeBoost).safeTransfer(msg.sender, amount);
        emit ClaimBoost(msg.sender, amount);
    }
    function claimGovernance(uint256 amount) public virtual checkGovernance(amount) {
        if (amount == 0) return;
        userClaimedGovernance[msg.sender] += amount;
        address(governance).safeTransfer(msg.sender, amount);
        emit ClaimGovernance(msg.sender, amount);
    }
    modifier checkWeight(uint256 amount) virtual;
    modifier checkBoost(uint256 amount) virtual;
    modifier checkGovernance(uint256 amount) virtual;
}
contract bHermes is UtilityManager, ERC4626DepositOnly {
    using SafeTransferLib for address;
    constructor(ERC20 _hermes, address _owner, uint32 _gaugeCycleLength, uint32 _incrementFreezeWindow)
        UtilityManager(
            address(new bHermesGauges(_owner, _gaugeCycleLength, _incrementFreezeWindow)),
            address(new bHermesBoost(_owner)),
            address(new bHermesVotes(_owner))
        )
        ERC4626DepositOnly(_hermes, "Burned Hermes: Gov + Yield + Boost", "bHermes")
    {}
    modifier checkWeight(uint256 amount) override {
        if (balanceOf[msg.sender] < amount + userClaimedWeight[msg.sender]) {
            revert InsufficientShares();
        }
        _;
    }
    modifier checkBoost(uint256 amount) override {
        if (balanceOf[msg.sender] < amount + userClaimedBoost[msg.sender]) {
            revert InsufficientShares();
        }
        _;
    }
    modifier checkGovernance(uint256 amount) override {
        if (balanceOf[msg.sender] < amount + userClaimedGovernance[msg.sender]) {
            revert InsufficientShares();
        }
        _;
    }
    function claimOutstanding() public virtual {
        uint256 balance = balanceOf[msg.sender];
        claimWeight(balance - userClaimedWeight[msg.sender]);
        claimBoost(balance - userClaimedBoost[msg.sender]);
        claimGovernance(balance - userClaimedGovernance[msg.sender]);
    }
    function totalAssets() public view virtual override returns (uint256) {
        return address(asset).balanceOf(address(this));
    }
    function _mint(address to, uint256 amount) internal virtual override {
        gaugeWeight.mint(address(this), amount);
        gaugeBoost.mint(address(this), amount);
        governance.mint(address(this), amount);
        super._mint(to, amount);
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        uint256 userBalance = balanceOf[msg.sender];
        if (
            userBalance - userClaimedWeight[msg.sender] < amount || userBalance - userClaimedBoost[msg.sender] < amount
                || userBalance - userClaimedGovernance[msg.sender] < amount
        ) revert InsufficientUnderlying();
        return super.transfer(to, amount);
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        uint256 userBalance = balanceOf[from];
        if (
            userBalance - userClaimedWeight[from] < amount || userBalance - userClaimedBoost[from] < amount
                || userBalance - userClaimedGovernance[from] < amount
        ) revert InsufficientUnderlying();
        return super.transferFrom(from, to, amount);
    }
    error InsufficientUnderlying();
}
abstract contract BaseV2Gauge is Ownable, IBaseV2Gauge {
    address public immutable override rewardToken;
    bHermesBoost public immutable hermesGaugeBoost;
    FlywheelGaugeRewards public immutable override flywheelGaugeRewards;
    mapping(FlywheelCore_1 => bool) public override isActive;
    mapping(FlywheelCore_1 => bool) public override added;
    address public override strategy;
    MultiRewardsDepot public override multiRewardsDepot;
    uint256 public override epoch;
    FlywheelCore_1[] private bribeFlywheels;
    uint256 internal constant WEEK = 1 weeks;
    constructor(FlywheelGaugeRewards _flywheelGaugeRewards, address _strategy, address _owner) {
        _initializeOwner(_owner);
        flywheelGaugeRewards = _flywheelGaugeRewards;
        rewardToken = _flywheelGaugeRewards.rewardToken();
        hermesGaugeBoost = BaseV2GaugeFactory(msg.sender).bHermesBoostToken();
        strategy = _strategy;
        epoch = (block.timestamp / WEEK) * WEEK;
        multiRewardsDepot = new MultiRewardsDepot(address(this));
    }
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory) {
        return bribeFlywheels;
    }
    function newEpoch() external {
        uint256 _newEpoch = (block.timestamp / WEEK) * WEEK;
        if (epoch < _newEpoch) {
            epoch = _newEpoch;
            uint256 accruedRewards = flywheelGaugeRewards.getAccruedRewards();
            distribute(accruedRewards);
            emit Distribute(accruedRewards, _newEpoch);
        }
    }
    function distribute(uint256 amount) internal virtual;
    function attachUser(address user) external onlyStrategy {
        hermesGaugeBoost.attach(user);
    }
    function detachUser(address user) external onlyStrategy {
        hermesGaugeBoost.detach(user);
    }
    function accrueBribes(address user) external {
        FlywheelCore_1[] storage _bribeFlywheels = bribeFlywheels;
        uint256 length = _bribeFlywheels.length;
        for (uint256 i = 0; i < length;) {
            if (isActive[_bribeFlywheels[i]]) _bribeFlywheels[i].accrue(ERC20(address(this)), user);
            unchecked {
                i++;
            }
        }
    }
    function addBribeFlywheel(FlywheelCore_1 bribeFlywheel) external onlyOwner {
        if (added[bribeFlywheel]) revert FlywheelAlreadyAdded();
        address flyWheelRewards = address(bribeFlywheel.flywheelRewards());
        FlywheelBribeRewards(flyWheelRewards).setRewardsDepot(multiRewardsDepot);
        multiRewardsDepot.addAsset(flyWheelRewards, bribeFlywheel.rewardToken());
        bribeFlywheels.push(bribeFlywheel);
        isActive[bribeFlywheel] = true;
        added[bribeFlywheel] = true;
        emit AddedBribeFlywheel(bribeFlywheel);
    }
    function removeBribeFlywheel(FlywheelCore_1 bribeFlywheel) external onlyOwner {
        if (!isActive[bribeFlywheel]) revert FlywheelNotActive();
        delete isActive[bribeFlywheel];
        emit RemoveBribeFlywheel(bribeFlywheel);
    }
    modifier onlyStrategy() virtual {
        if (msg.sender != strategy) revert StrategyError();
        _;
    }
}
interface IBaseV2GaugeFactory {
    function gaugeManager() external view returns (BaseV2GaugeManager);
    function bHermesBoostToken() external view returns (bHermesBoost);
    function bribesFactory() external view returns (BribesFactory);
    function gauges(uint256) external view returns (BaseV2Gauge);
    function gaugeIds(BaseV2Gauge) external view returns (uint256);
    function activeGauges(BaseV2Gauge) external view returns (bool);
    function strategyGauges(address) external view returns (BaseV2Gauge);
    function getGauges() external view returns (BaseV2Gauge[] memory);
    function newEpoch() external;
    function newEpoch(uint256 start, uint256 end) external;
    function createGauge(address strategy, bytes memory data) external;
    function removeGauge(BaseV2Gauge gauge) external;
    function addBribeToGauge(BaseV2Gauge gauge, address bribeToken) external;
    function removeBribeFromGauge(BaseV2Gauge gauge, address bribeToken) external;
    error GaugeAlreadyExists();
    error NotOwnerOrBribesFactoryOwner();
    error InvalidGauge();
}
abstract contract BaseV2GaugeFactory is Ownable, IBaseV2GaugeFactory {
    BaseV2GaugeManager public immutable override gaugeManager;
    bHermesBoost public immutable override bHermesBoostToken;
    BribesFactory public immutable override bribesFactory;
    BaseV2Gauge[] public override gauges;
    mapping(BaseV2Gauge => uint256) public override gaugeIds;
    mapping(BaseV2Gauge => bool) public override activeGauges;
    mapping(address => BaseV2Gauge) public override strategyGauges;
    constructor(
        BaseV2GaugeManager _gaugeManager,
        bHermesBoost _bHermesBoost,
        BribesFactory _bribesFactory,
        address _owner
    ) {
        _initializeOwner(_owner);
        bribesFactory = _bribesFactory;
        bHermesBoostToken = _bHermesBoost;
        gaugeManager = _gaugeManager;
    }
    function getGauges() external view returns (BaseV2Gauge[] memory) {
        return gauges;
    }
    function newEpoch() external {
        BaseV2Gauge[] storage _gauges = gauges;
        uint256 length = _gauges.length;
        for (uint256 i = 0; i < length;) {
            if (activeGauges[_gauges[i]]) _gauges[i].newEpoch();
            unchecked {
                i++;
            }
        }
    }
    function newEpoch(uint256 start, uint256 end) external {
        BaseV2Gauge[] storage _gauges = gauges;
        uint256 length = _gauges.length;
        if (end > length) end = length;
        for (uint256 i = start; i < end;) {
            if (activeGauges[_gauges[i]]) _gauges[i].newEpoch();
            unchecked {
                i++;
            }
        }
    }
    function createGauge(address strategy, bytes memory data) external onlyOwner {
        if (address(strategyGauges[strategy]) != address(0)) revert GaugeAlreadyExists();
        BaseV2Gauge gauge = newGauge(strategy, data);
        strategyGauges[strategy] = gauge;
        uint256 id = gauges.length;
        gauges.push(gauge);
        gaugeIds[gauge] = id;
        activeGauges[gauge] = true;
        gaugeManager.addGauge(address(gauge));
        afterCreateGauge(strategy, data);
    }
    function afterCreateGauge(address strategy, bytes memory data) internal virtual;
    function newGauge(address strategy, bytes memory data) internal virtual returns (BaseV2Gauge gauge);
    function removeGauge(BaseV2Gauge gauge) external onlyOwner {
        if (!activeGauges[gauge] || gauges[gaugeIds[gauge]] != gauge) revert InvalidGauge();
        delete gauges[gaugeIds[gauge]];
        delete gaugeIds[gauge];
        delete activeGauges[gauge];
        delete strategyGauges[gauge.strategy()];
        gaugeManager.removeGauge(address(gauge));
    }
    function addBribeToGauge(BaseV2Gauge gauge, address bribeToken) external onlyOwnerOrBribesFactoryOwner {
        if (!activeGauges[gauge]) revert InvalidGauge();
        gauge.addBribeFlywheel(bribesFactory.flywheelTokens(bribeToken));
        bribesFactory.addGaugetoFlywheel(address(gauge), bribeToken);
    }
    function removeBribeFromGauge(BaseV2Gauge gauge, address bribeToken) external onlyOwnerOrBribesFactoryOwner {
        if (!activeGauges[gauge]) revert InvalidGauge();
        gauge.removeBribeFlywheel(bribesFactory.flywheelTokens(bribeToken));
    }
    modifier onlyOwnerOrBribesFactoryOwner() {
        if (msg.sender != bribesFactory.owner() && msg.sender != owner()) {
            revert NotOwnerOrBribesFactoryOwner();
        }
        _;
    }
}
interface IBaseV2GaugeManager {
    function admin() external view returns (address);
    function bHermesGaugeWeight() external view returns (bHermesGauges);
    function bHermesGaugeBoost() external view returns (bHermesBoost);
    function gaugeFactories(uint256) external view returns (BaseV2GaugeFactory);
    function gaugeFactoryIds(BaseV2GaugeFactory) external view returns (uint256);
    function activeGaugeFactories(BaseV2GaugeFactory) external view returns (bool);
    function getGaugeFactories() external view returns (BaseV2GaugeFactory[] memory);
    function newEpoch() external;
    function newEpoch(uint256 start, uint256 end) external;
    function addGauge(address gauge) external;
    function removeGauge(address gauge) external;
    function addGaugeFactory(BaseV2GaugeFactory gaugeFactory) external;
    function removeGaugeFactory(BaseV2GaugeFactory gaugeFactory) external;
    function changebHermesGaugeOwner(address newOwner) external;
    function changeAdmin(address newAdmin) external;
    event AddedGaugeFactory(address gaugeFactory);
    event RemovedGaugeFactory(address gaugeFactory);
    event ChangedbHermesGaugeOwner(address newOwner);
    event ChangedAdmin(address newAdmin);
    error GaugeFactoryAlreadyExists();
    error NotActiveGaugeFactory();
    error NotAdmin();
}
contract BaseV2GaugeManager is Ownable, IBaseV2GaugeManager {
    address public admin;
    bHermesGauges public immutable bHermesGaugeWeight;
    bHermesBoost public immutable bHermesGaugeBoost;
    BaseV2GaugeFactory[] public gaugeFactories;
    mapping(BaseV2GaugeFactory => uint256) public gaugeFactoryIds;
    mapping(BaseV2GaugeFactory => bool) public activeGaugeFactories;
    constructor(bHermes _bHermes, address _owner, address _admin) {
        admin = _admin;
        _initializeOwner(_owner);
        bHermesGaugeWeight = _bHermes.gaugeWeight();
        bHermesGaugeBoost = _bHermes.gaugeBoost();
    }
    function getGaugeFactories() external view returns (BaseV2GaugeFactory[] memory) {
        return gaugeFactories;
    }
    function newEpoch() external {
        BaseV2GaugeFactory[] storage _gaugeFactories = gaugeFactories;
        uint256 length = _gaugeFactories.length;
        for (uint256 i = 0; i < length;) {
            if (activeGaugeFactories[_gaugeFactories[i]]) _gaugeFactories[i].newEpoch();
            unchecked {
                i++;
            }
        }
    }
    function newEpoch(uint256 start, uint256 end) external {
        BaseV2GaugeFactory[] storage _gaugeFactories = gaugeFactories;
        uint256 length = _gaugeFactories.length;
        if (end > length) end = length;
        for (uint256 i = start; i < end;) {
            if (activeGaugeFactories[_gaugeFactories[i]]) _gaugeFactories[i].newEpoch();
            unchecked {
                i++;
            }
        }
    }
    function addGauge(address gauge) external onlyActiveGaugeFactory {
        bHermesGaugeWeight.addGauge(gauge);
        bHermesGaugeBoost.addGauge(gauge);
    }
    function removeGauge(address gauge) external onlyActiveGaugeFactory {
        bHermesGaugeWeight.removeGauge(gauge);
        bHermesGaugeBoost.removeGauge(gauge);
    }
    function addGaugeFactory(BaseV2GaugeFactory gaugeFactory) external onlyOwner {
        if (activeGaugeFactories[gaugeFactory]) revert GaugeFactoryAlreadyExists();
        gaugeFactoryIds[gaugeFactory] = gaugeFactories.length;
        gaugeFactories.push(gaugeFactory);
        activeGaugeFactories[gaugeFactory] = true;
        emit AddedGaugeFactory(address(gaugeFactory));
    }
    function removeGaugeFactory(BaseV2GaugeFactory gaugeFactory) external onlyOwner {
        if (!activeGaugeFactories[gaugeFactory] || gaugeFactories[gaugeFactoryIds[gaugeFactory]] != gaugeFactory) {
            revert NotActiveGaugeFactory();
        }
        delete gaugeFactories[gaugeFactoryIds[gaugeFactory]];
        delete gaugeFactoryIds[gaugeFactory];
        delete activeGaugeFactories[gaugeFactory];
        emit RemovedGaugeFactory(address(gaugeFactory));
    }
    function changebHermesGaugeOwner(address newOwner) external onlyAdmin {
        bHermesGaugeWeight.transferOwnership(newOwner);
        bHermesGaugeBoost.transferOwnership(newOwner);
        emit ChangedbHermesGaugeOwner(newOwner);
    }
    function changeAdmin(address newAdmin) external onlyAdmin {
        admin = newAdmin;
        emit ChangedAdmin(newAdmin);
    }
    modifier onlyActiveGaugeFactory() {
        if (!activeGaugeFactories[BaseV2GaugeFactory(msg.sender)]) revert NotActiveGaugeFactory();
        _;
    }
    modifier onlyAdmin() {
        if (msg.sender != admin) revert NotAdmin();
        _;
    }
}
interface IBribesFactory {
    function rewardsCycleLength() external view returns (uint256);
    function bribeFlywheels(uint256) external view returns (FlywheelCore_1);
    function bribeFlywheelIds(FlywheelCore_1) external view returns (uint256);
    function activeBribeFlywheels(FlywheelCore_1) external view returns (bool);
    function flywheelTokens(address) external view returns (FlywheelCore_1);
    function gaugeManager() external view returns (BaseV2GaugeManager);
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory);
    function addGaugetoFlywheel(address gauge, address bribeToken) external;
    function createBribeFlywheel(address bribeToken) external;
    event BribeFlywheelCreated(address indexed bribeToken, FlywheelCore_1 flywheel);
    error BribeFlywheelAlreadyExists();
}
contract BribesFactory is Ownable, IBribesFactory {
    uint256 public immutable rewardsCycleLength;
    FlywheelBoosterGaugeWeight private immutable flywheelGaugeWeightBooster;
    FlywheelCore_1[] public bribeFlywheels;
    mapping(FlywheelCore_1 => uint256) public bribeFlywheelIds;
    mapping(FlywheelCore_1 => bool) public activeBribeFlywheels;
    mapping(address => FlywheelCore_1) public flywheelTokens;
    BaseV2GaugeManager public immutable gaugeManager;
    constructor(
        BaseV2GaugeManager _gaugeManager,
        FlywheelBoosterGaugeWeight _flywheelGaugeWeightBooster,
        uint256 _rewardsCycleLength,
        address _owner
    ) {
        _initializeOwner(_owner);
        gaugeManager = _gaugeManager;
        flywheelGaugeWeightBooster = _flywheelGaugeWeightBooster;
        rewardsCycleLength = _rewardsCycleLength;
    }
    function getBribeFlywheels() external view returns (FlywheelCore_1[] memory) {
        return bribeFlywheels;
    }
    function addGaugetoFlywheel(address gauge, address bribeToken) external onlyGaugeFactory {
        if (address(flywheelTokens[bribeToken]) == address(0)) createBribeFlywheel(bribeToken);
        flywheelTokens[bribeToken].addStrategyForRewards(ERC20(gauge));
    }
    function createBribeFlywheel(address bribeToken) public {
        if (address(flywheelTokens[bribeToken]) != address(0)) revert BribeFlywheelAlreadyExists();
        FlywheelCore_1 flywheel = new FlywheelCore_1(
            bribeToken,
            FlywheelBribeRewards(address(0)),
            flywheelGaugeWeightBooster,
            address(this)
        );
        flywheelTokens[bribeToken] = flywheel;
        uint256 id = bribeFlywheels.length;
        bribeFlywheels.push(flywheel);
        bribeFlywheelIds[flywheel] = id;
        activeBribeFlywheels[flywheel] = true;
        flywheel.setFlywheelRewards(address(new FlywheelBribeRewards(flywheel, rewardsCycleLength)));
        emit BribeFlywheelCreated(bribeToken, flywheel);
    }
    modifier onlyGaugeFactory() {
        if (!gaugeManager.activeGaugeFactories(BaseV2GaugeFactory(msg.sender))) {
            revert Unauthorized();
        }
        _;
    }
}
contract UniswapV3Gauge is BaseV2Gauge, IUniswapV3Gauge {
    using SafeTransferLib for address;
    address public immutable override uniswapV3Staker;
    uint24 public override minimumWidth;
    constructor(
        FlywheelGaugeRewards _flywheelGaugeRewards,
        address _uniswapV3Staker,
        address _uniswapV3Pool,
        uint24 _minimumWidth,
        address _owner
    ) BaseV2Gauge(_flywheelGaugeRewards, _uniswapV3Pool, _owner) {
        uniswapV3Staker = _uniswapV3Staker;
        minimumWidth = _minimumWidth;
        emit NewMinimumWidth(_minimumWidth);
        rewardToken.safeApprove(_uniswapV3Staker, type(uint256).max);
    }
    function distribute(uint256 amount) internal override {
        IUniswapV3Staker(uniswapV3Staker).createIncentiveFromGauge(amount);
    }
    function setMinimumWidth(uint24 _minimumWidth) external onlyOwner {
        minimumWidth = _minimumWidth;
        emit NewMinimumWidth(_minimumWidth);
    }
    modifier onlyStrategy() override {
        if (msg.sender != uniswapV3Staker) revert StrategyError();
        _;
    }
}
interface IUniswapV3Staker is IERC721Receiver {
    struct IncentiveKey {
        IUniswapV3Pool pool;
        uint96 startTime;
    }
    struct Incentive {
        uint256 totalRewardUnclaimed;
        uint160 totalSecondsClaimedX128;
        uint96 numberOfStakes;
    }
    struct Deposit {
        address owner;
        int24 tickLower;
        int24 tickUpper;
        uint40 stakedTimestamp;
    }
    struct Stake {
        uint160 secondsPerLiquidityInsideInitialX128;
        uint96 liquidityNoOverflow;
        uint128 liquidityIfOverflow;
    }
    function factory() external view returns (IUniswapV3Factory);
    function nonfungiblePositionManager() external view returns (INonfungiblePositionManager);
    function maxIncentiveStartLeadTime() external view returns (uint256);
    function minter() external view returns (address);
    function hermes() external view returns (address);
    function hermesGaugeBoost() external view returns (bHermesBoost);
    function gaugePool(address) external view returns (IUniswapV3Pool);
    function gauges(IUniswapV3Pool) external view returns (UniswapV3Gauge);
    function bribeDepots(IUniswapV3Pool) external view returns (address);
    function poolsMinimumWidth(IUniswapV3Pool) external view returns (uint24);
    function incentives(bytes32 incentiveId)
        external
        view
        returns (uint256 totalRewardUnclaimed, uint160 totalSecondsClaimedX128, uint96 numberOfStakes);
    function deposits(uint256 tokenId)
        external
        view
        returns (address owner, int24 tickLower, int24 tickUpper, uint40 stakedTimestamp);
    function userAttachements(address user, IUniswapV3Pool pool) external view returns (uint256);
    function stakes(uint256 tokenId, bytes32 incentiveId)
        external
        view
        returns (uint160 secondsPerLiquidityInsideInitialX128, uint128 liquidity);
    function rewards(address owner) external view returns (uint256 rewardsOwed);
    function tokenIdRewards(uint256 tokenId) external view returns (uint256 rewards);
    function createIncentiveFromGauge(uint256 reward) external;
    function createIncentive(IncentiveKey memory key, uint256 reward) external;
    function endIncentive(IncentiveKey memory key) external returns (uint256 refund);
    function withdrawToken(uint256 tokenId, address to, bytes memory data) external;
    function claimReward(address to, uint256 amountRequested) external returns (uint256 reward);
    function claimAllRewards(address to) external returns (uint256 reward);
    function getRewardInfo(IncentiveKey memory key, uint256 tokenId)
        external
        returns (uint256 reward, uint160 secondsInsideX128);
    function unstakeToken(uint256 tokenId) external;
    function unstakeToken(IncentiveKey memory key, uint256 tokenId) external;
    function stakeToken(uint256 tokenId) external;
    function updateGauges(IUniswapV3Pool uniswapV3Pool) external;
    function updateBribeDepot(IUniswapV3Pool uniswapV3Pool) external;
    function updatePoolMinimumWidth(IUniswapV3Pool uniswapV3Pool) external;
    event IncentiveCreated(IUniswapV3Pool indexed pool, uint256 startTime, uint256 reward);
    event IncentiveEnded(bytes32 indexed incentiveId, uint256 refund);
    event DepositTransferred(uint256 indexed tokenId, address indexed oldOwner, address indexed newOwner);
    event TokenStaked(uint256 indexed tokenId, bytes32 indexed incentiveId, uint128 liquidity);
    event TokenUnstaked(uint256 indexed tokenId, bytes32 indexed incentiveId);
    event RewardClaimed(address indexed to, uint256 reward);
    event BribeDepotUpdated(IUniswapV3Pool indexed uniswapV3Pool, address bribeDepot);
    event PoolMinimumWidthUpdated(IUniswapV3Pool indexed uniswapV3Pool, uint24 indexed poolMinimumWidth);
    event GaugeUpdated(IUniswapV3Pool indexed uniswapV3Pool, address indexed uniswapV3Gauge);
    error InvalidGauge();
    error NotCalledByOwner();
    error IncentiveRewardMustBePositive();
    error IncentiveStartTimeMustBeNowOrInTheFuture();
    error IncentiveStartTimeNotAtEndOfAnEpoch();
    error IncentiveStartTimeTooFarIntoFuture();
    error IncentiveCallerMustBeRegisteredGauge();
    error IncentiveCannotBeCreatedForPoolWithNoGauge();
    error EndIncentiveBeforeEndTime();
    error EndIncentiveWhileStakesArePresent();
    error EndIncentiveNoRefundAvailable();
    error TokenNotUniswapV3NFT();
    error TokenNotStaked();
    error TokenNotDeposited();
    error InvalidRecipient();
    error TokenStakedError();
    error NonExistentIncentiveError();
    error RangeTooSmallError();
    error NoLiquidityError();
}
library IncentiveId {
    function compute(IUniswapV3Staker.IncentiveKey memory key) internal pure returns (bytes32 incentiveId) {
        return keccak256(abi.encode(key));
    }
}
interface IUniswapV3GaugeFactory is IBaseV2GaugeFactory {
    function uniswapV3Staker() external view returns (UniswapV3Staker);
    function flywheelGaugeRewards() external view returns (FlywheelGaugeRewards);
    function setMinimumWidth(address gauge, uint24 minimumWidth) external;
}
contract UniswapV3Staker is IUniswapV3Staker, Multicallable {
    using SafeTransferLib for address;
    mapping(address => IUniswapV3Pool) public gaugePool;
    mapping(IUniswapV3Pool => UniswapV3Gauge) public gauges;
    mapping(IUniswapV3Pool => address) public bribeDepots;
    mapping(IUniswapV3Pool => uint24) public poolsMinimumWidth;
    mapping(bytes32 => Incentive) public override incentives;
    mapping(uint256 => Deposit) public override deposits;
    mapping(address => mapping(IUniswapV3Pool => uint256)) private _userAttachements;
    mapping(uint256 => mapping(bytes32 => Stake)) private _stakes;
    mapping(uint256 => IncentiveKey) private stakedIncentiveKey;
    function stakes(uint256 tokenId, bytes32 incentiveId)
        public
        view
        override
        returns (uint160 secondsPerLiquidityInsideInitialX128, uint128 liquidity)
    {
        Stake storage stake = _stakes[tokenId][incentiveId];
        secondsPerLiquidityInsideInitialX128 = stake.secondsPerLiquidityInsideInitialX128;
        liquidity = stake.liquidityNoOverflow;
        if (liquidity == type(uint96).max) {
            liquidity = stake.liquidityIfOverflow;
        }
    }
    function userAttachements(address user, IUniswapV3Pool pool) external view override returns (uint256) {
        return hermesGaugeBoost.isUserGauge(user, address(gauges[pool])) ? _userAttachements[user][pool] : 0;
    }
    mapping(address => uint256) public override rewards;
    mapping(uint256 => uint256) public tokenIdRewards;
    IUniswapV3GaugeFactory public immutable uniswapV3GaugeFactory;
    IUniswapV3Factory public immutable override factory;
    INonfungiblePositionManager public immutable override nonfungiblePositionManager;
    uint256 public immutable override maxIncentiveStartLeadTime;
    address public immutable minter;
    address public immutable hermes;
    bHermesBoost public immutable hermesGaugeBoost;
    constructor(
        IUniswapV3Factory _factory,
        INonfungiblePositionManager _nonfungiblePositionManager,
        IUniswapV3GaugeFactory _uniswapV3GaugeFactory,
        bHermesBoost _hermesGaugeBoost,
        uint256 _maxIncentiveStartLeadTime,
        address _minter,
        address _hermes
    ) {
        factory = _factory;
        nonfungiblePositionManager = _nonfungiblePositionManager;
        maxIncentiveStartLeadTime = _maxIncentiveStartLeadTime;
        uniswapV3GaugeFactory = _uniswapV3GaugeFactory;
        hermesGaugeBoost = _hermesGaugeBoost;
        minter = _minter;
        hermes = _hermes;
    }
    function createIncentiveFromGauge(uint256 reward) external {
        if (reward <= 0) revert IncentiveRewardMustBePositive();
        uint96 startTime = IncentiveTime.computeEnd(block.timestamp);
        IUniswapV3Pool pool = gaugePool[msg.sender];
        if (address(pool) == address(0)) revert IncentiveCallerMustBeRegisteredGauge();
        IncentiveKey memory key = IncentiveKey({startTime: startTime, pool: pool});
        bytes32 incentiveId = IncentiveId.compute(key);
        incentives[incentiveId].totalRewardUnclaimed += reward;
        hermes.safeTransferFrom(msg.sender, address(this), reward);
        emit IncentiveCreated(pool, startTime, reward);
    }
    function createIncentive(IncentiveKey memory key, uint256 reward) external {
        if (reward <= 0) revert IncentiveRewardMustBePositive();
        uint96 startTime = IncentiveTime.computeStart(key.startTime);
        if (startTime != key.startTime) revert IncentiveStartTimeNotAtEndOfAnEpoch();
        if (startTime <= block.timestamp) revert IncentiveStartTimeMustBeNowOrInTheFuture();
        if (startTime - block.timestamp > maxIncentiveStartLeadTime) {
            revert IncentiveStartTimeTooFarIntoFuture();
        }
        if (address(gauges[key.pool]) == address(0)) {
            revert IncentiveCannotBeCreatedForPoolWithNoGauge();
        }
        bytes32 incentiveId = IncentiveId.compute(key);
        incentives[incentiveId].totalRewardUnclaimed += reward;
        hermes.safeTransferFrom(msg.sender, address(this), reward);
        emit IncentiveCreated(key.pool, startTime, reward);
    }
    function endIncentive(IncentiveKey memory key) external returns (uint256 refund) {
        if (block.timestamp < IncentiveTime.getEnd(key.startTime)) {
            revert EndIncentiveBeforeEndTime();
        }
        bytes32 incentiveId = IncentiveId.compute(key);
        Incentive storage incentive = incentives[incentiveId];
        refund = incentive.totalRewardUnclaimed;
        if (refund == 0) revert EndIncentiveNoRefundAvailable();
        if (incentive.numberOfStakes > 0) revert EndIncentiveWhileStakesArePresent();
        incentive.totalRewardUnclaimed = 0;
        hermes.safeTransfer(minter, refund);
        emit IncentiveEnded(incentiveId, refund);
    }
    function onERC721Received(address, address from, uint256 tokenId, bytes calldata)
        external
        override
        returns (bytes4)
    {
        INonfungiblePositionManager _nonfungiblePositionManager = nonfungiblePositionManager;
        if (msg.sender != address(_nonfungiblePositionManager)) revert TokenNotUniswapV3NFT();
        (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) =
            NFTPositionInfo.getPositionInfo(factory, nonfungiblePositionManager, tokenId);
        deposits[tokenId] = Deposit({owner: from, tickLower: tickLower, tickUpper: tickUpper, stakedTimestamp: 0});
        emit DepositTransferred(tokenId, address(0), from);
        _stakeToken(tokenId, pool, tickLower, tickUpper, liquidity);
        return this.onERC721Received.selector;
    }
    function withdrawToken(uint256 tokenId, address to, bytes memory data) external {
        if (to == address(0)) revert InvalidRecipient();
        Deposit storage deposit = deposits[tokenId];
        if (deposit.owner != msg.sender) revert NotCalledByOwner();
        if (deposit.stakedTimestamp != 0) revert TokenStakedError();
        delete deposits[tokenId];
        emit DepositTransferred(tokenId, msg.sender, address(0));
        nonfungiblePositionManager.safeTransferFrom(address(this), to, tokenId, data);
    }
    function claimReward(address to, uint256 amountRequested) external returns (uint256 reward) {
        reward = rewards[msg.sender];
        if (amountRequested != 0 && amountRequested < reward) {
            reward = amountRequested;
            rewards[msg.sender] -= reward;
        } else {
            rewards[msg.sender] = 0;
        }
        if (reward > 0) hermes.safeTransfer(to, reward);
        emit RewardClaimed(to, reward);
    }
    function claimAllRewards(address to) external returns (uint256 reward) {
        reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        if (reward > 0) hermes.safeTransfer(to, reward);
        emit RewardClaimed(to, reward);
    }
    function getRewardInfo(IncentiveKey memory key, uint256 tokenId)
        external
        view
        override
        returns (uint256 reward, uint160 secondsInsideX128)
    {
        Deposit storage deposit = deposits[tokenId];
        (uint96 endTime, uint256 stakedDuration) =
            IncentiveTime.getEndAndDuration(key.startTime, deposit.stakedTimestamp, block.timestamp);
        bytes32 incentiveId = IncentiveId.compute(key);
        {
            uint128 boostAmount;
            uint128 boostTotalSupply;
            address owner = deposit.owner;
            if (_userAttachements[owner][key.pool] == tokenId) {
                (boostAmount, boostTotalSupply) = hermesGaugeBoost.getUserGaugeBoost(owner, address(gauges[key.pool]));
            }
            (uint160 secondsPerLiquidityInsideInitialX128, uint128 liquidity) = stakes(tokenId, incentiveId);
            if (liquidity == 0) revert TokenNotStaked();
            (, uint160 secondsPerLiquidityInsideX128,) =
                key.pool.snapshotCumulativesInside(deposit.tickLower, deposit.tickUpper);
            secondsInsideX128 = RewardMath.computeBoostedSecondsInsideX128(
                stakedDuration,
                liquidity,
                uint128(boostAmount),
                uint128(boostTotalSupply),
                secondsPerLiquidityInsideInitialX128,
                secondsPerLiquidityInsideX128
            );
        }
        Incentive storage incentive = incentives[incentiveId];
        reward = RewardMath.computeBoostedRewardAmount(
            incentive.totalRewardUnclaimed,
            incentive.totalSecondsClaimedX128,
            key.startTime,
            endTime,
            secondsInsideX128,
            block.timestamp
        );
    }
    function restakeToken(uint256 tokenId) external {
        IncentiveKey storage incentiveId = stakedIncentiveKey[tokenId];
        if (incentiveId.startTime != 0) _unstakeToken(incentiveId, tokenId, true);
        (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) =
            NFTPositionInfo.getPositionInfo(factory, nonfungiblePositionManager, tokenId);
        _stakeToken(tokenId, pool, tickLower, tickUpper, liquidity);
    }
    function unstakeToken(uint256 tokenId) external {
        IncentiveKey storage incentiveId = stakedIncentiveKey[tokenId];
        if (incentiveId.startTime != 0) _unstakeToken(incentiveId, tokenId, true);
    }
    function unstakeToken(IncentiveKey memory key, uint256 tokenId) external {
        _unstakeToken(key, tokenId, true);
    }
    function _unstakeToken(IncentiveKey memory key, uint256 tokenId, bool isNotRestake) private {
        Deposit storage deposit = deposits[tokenId];
        (uint96 endTime, uint256 stakedDuration) =
            IncentiveTime.getEndAndDuration(key.startTime, deposit.stakedTimestamp, block.timestamp);
        address owner = deposit.owner;
        if ((isNotRestake || block.timestamp < endTime) && owner != msg.sender) revert NotCalledByOwner();
        {
            address bribeAddress = bribeDepots[key.pool];
            if (bribeAddress != address(0)) {
                nonfungiblePositionManager.collect(
                    INonfungiblePositionManager.CollectParams({
                        tokenId: tokenId,
                        recipient: bribeAddress,
                        amount0Max: type(uint128).max,
                        amount1Max: type(uint128).max
                    })
                );
            }
        }
        bytes32 incentiveId = IncentiveId.compute(key);
        uint160 secondsInsideX128;
        uint128 liquidity;
        {
            uint128 boostAmount;
            uint128 boostTotalSupply;
            UniswapV3Gauge gauge = gauges[key.pool]; 
            if (hermesGaugeBoost.isUserGauge(owner, address(gauge)) && _userAttachements[owner][key.pool] == tokenId) {
                (boostAmount, boostTotalSupply) = hermesGaugeBoost.getUserGaugeBoost(owner, address(gauge));
                gauge.detachUser(owner);
                _userAttachements[owner][key.pool] = 0;
            }
            uint160 secondsPerLiquidityInsideInitialX128;
            (secondsPerLiquidityInsideInitialX128, liquidity) = stakes(tokenId, incentiveId);
            if (liquidity == 0) revert TokenNotStaked();
            (, uint160 secondsPerLiquidityInsideX128,) =
                key.pool.snapshotCumulativesInside(deposit.tickLower, deposit.tickUpper);
            secondsInsideX128 = RewardMath.computeBoostedSecondsInsideX128(
                stakedDuration,
                liquidity,
                uint128(boostAmount),
                uint128(boostTotalSupply),
                secondsPerLiquidityInsideInitialX128,
                secondsPerLiquidityInsideX128
            );
        }
        deposit.stakedTimestamp = 0;
        Incentive storage incentive = incentives[incentiveId];
        incentive.numberOfStakes--;
        uint256 reward = RewardMath.computeBoostedRewardAmount(
            incentive.totalRewardUnclaimed,
            incentive.totalSecondsClaimedX128,
            key.startTime,
            endTime,
            secondsInsideX128,
            block.timestamp
        );
        unchecked {
            incentive.totalSecondsClaimedX128 += secondsInsideX128;
            incentive.totalRewardUnclaimed -= reward;
            rewards[owner] += reward;
            tokenIdRewards[tokenId] += reward;
        }
        Stake storage stake = _stakes[tokenId][incentiveId];
        stake.secondsPerLiquidityInsideInitialX128 = 0;
        stake.liquidityNoOverflow = 0;
        if (liquidity >= type(uint96).max) stake.liquidityIfOverflow = 0;
        delete stakedIncentiveKey[tokenId];
        emit TokenUnstaked(tokenId, incentiveId);
    }
    function stakeToken(uint256 tokenId) external override {
        if (deposits[tokenId].stakedTimestamp != 0) revert TokenStakedError();
        (IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity) =
            NFTPositionInfo.getPositionInfo(factory, nonfungiblePositionManager, tokenId);
        _stakeToken(tokenId, pool, tickLower, tickUpper, liquidity);
    }
    function _stakeToken(uint256 tokenId, IUniswapV3Pool pool, int24 tickLower, int24 tickUpper, uint128 liquidity)
        private
    {
        IncentiveKey memory key = IncentiveKey({pool: pool, startTime: IncentiveTime.computeStart(block.timestamp)});
        bytes32 incentiveId = IncentiveId.compute(key);
        if (incentives[incentiveId].totalRewardUnclaimed == 0) revert NonExistentIncentiveError();
        if (uint24(tickUpper - tickLower) < poolsMinimumWidth[pool]) revert RangeTooSmallError();
        if (liquidity == 0) revert NoLiquidityError();
        stakedIncentiveKey[tokenId] = key;
        address tokenOwner = deposits[tokenId].owner;
        if (tokenOwner == address(0)) revert TokenNotDeposited();
        UniswapV3Gauge gauge = gauges[pool]; 
        if (!hermesGaugeBoost.isUserGauge(tokenOwner, address(gauge))) {
            _userAttachements[tokenOwner][pool] = tokenId;
            gauge.attachUser(tokenOwner);
        }
        deposits[tokenId].stakedTimestamp = uint40(block.timestamp);
        incentives[incentiveId].numberOfStakes++;
        (, uint160 secondsPerLiquidityInsideX128,) = pool.snapshotCumulativesInside(tickLower, tickUpper);
        if (liquidity >= type(uint96).max) {
            _stakes[tokenId][incentiveId] = Stake({
                secondsPerLiquidityInsideInitialX128: secondsPerLiquidityInsideX128,
                liquidityNoOverflow: type(uint96).max,
                liquidityIfOverflow: liquidity
            });
        } else {
            Stake storage stake = _stakes[tokenId][incentiveId];
            stake.secondsPerLiquidityInsideInitialX128 = secondsPerLiquidityInsideX128;
            stake.liquidityNoOverflow = uint96(liquidity);
        }
        emit TokenStaked(tokenId, incentiveId, liquidity);
    }
    function updateGauges(IUniswapV3Pool uniswapV3Pool) external {
        address uniswapV3Gauge = address(uniswapV3GaugeFactory.strategyGauges(address(uniswapV3Pool)));
        if (uniswapV3Gauge == address(0)) revert InvalidGauge();
        if (address(gauges[uniswapV3Pool]) != uniswapV3Gauge) {
            emit GaugeUpdated(uniswapV3Pool, uniswapV3Gauge);
            gauges[uniswapV3Pool] = UniswapV3Gauge(uniswapV3Gauge);
            gaugePool[uniswapV3Gauge] = uniswapV3Pool;
        }
        updateBribeDepot(uniswapV3Pool);
        updatePoolMinimumWidth(uniswapV3Pool);
    }
    function updateBribeDepot(IUniswapV3Pool uniswapV3Pool) public {
        address newDepot = address(gauges[uniswapV3Pool].multiRewardsDepot());
        if (newDepot != bribeDepots[uniswapV3Pool]) {
            bribeDepots[uniswapV3Pool] = newDepot;
            emit BribeDepotUpdated(uniswapV3Pool, newDepot);
        }
    }
    function updatePoolMinimumWidth(IUniswapV3Pool uniswapV3Pool) public {
        uint24 minimumWidth = gauges[uniswapV3Pool].minimumWidth();
        if (minimumWidth != poolsMinimumWidth[uniswapV3Pool]) {
            poolsMinimumWidth[uniswapV3Pool] = minimumWidth;
            emit PoolMinimumWidthUpdated(uniswapV3Pool, minimumWidth);
        }
    }
}