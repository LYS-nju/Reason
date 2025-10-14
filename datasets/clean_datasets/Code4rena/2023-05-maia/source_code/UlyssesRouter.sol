pragma solidity ^0.8.18;
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
interface IERC4626MultiToken {
    function assets(uint256 index) external view returns (address asset);
    function weights(uint256 index) external view returns (uint256);
    function assetId(address asset) external view returns (uint256 assetId);
    function totalWeights() external view returns (uint256 totalWeights);
    function getAssets() external view returns (address[] memory assets);
    function totalAssets() external view returns (uint256 _totalAssets);
    function deposit(uint256[] calldata assetsAmounts, address receiver) external returns (uint256 shares);
    function mint(uint256 shares, address receiver) external returns (uint256[] memory assetsAmounts);
    function withdraw(uint256[] calldata assetsAmounts, address receiver, address owner)
        external
        returns (uint256 shares);
    function redeem(uint256 shares, address receiver, address owner)
        external
        returns (uint256[] memory assetsAmounts);
    function convertToShares(uint256[] calldata assetsAmounts) external view returns (uint256 shares);
    function convertToAssets(uint256 shares) external view returns (uint256[] memory assetsAmounts);
    function previewDeposit(uint256[] calldata assetsAmounts) external view returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256[] memory assetsAmounts);
    function previewWithdraw(uint256[] calldata assetsAmounts) external view returns (uint256 shares);
    function previewRedeem(uint256 shares) external view returns (uint256[] memory);
    function maxDeposit(address owner) external view returns (uint256);
    function maxMint(address owner) external view returns (uint256);
    function maxWithdraw(address owner) external view returns (uint256[] memory);
    function maxRedeem(address owner) external view returns (uint256);
    error ZeroAssets();
    error InvalidLength();
    event Deposit(address indexed caller, address indexed owner, uint256[] assets, uint256 shares);
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256[] assets, uint256 shares
    );
    event AssetAdded(address asset, uint256 weight);
    event AssetRemoved(address asset);
}
interface IUlyssesERC4626 {
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function previewDeposit(uint256 assets) external view returns (uint256);
    function previewMint(uint256 shares) external view returns (uint256);
    function previewRedeem(uint256 shares) external view returns (uint256);
    function maxDeposit(address owner) external view returns (uint256);
    function maxMint(address owner) external view returns (uint256);
    function maxRedeem(address owner) external view returns (uint256);
    error InvalidAssetDecimals();
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares
    );
}
interface IUlyssesToken {
    function addAsset(address asset, uint256 _weight) external;
    function removeAsset(address asset) external;
    function setWeights(uint256[] memory _weights) external;
    error AssetAlreadyAdded();
    error CannotRemoveLastAsset();
    error InvalidWeightsLength();
}
interface IUlyssesFactory {
    function createPool(ERC20 asset, address owner) external returns (uint256);
    function createPools(ERC20[] calldata assets, uint8[][] calldata weights, address owner)
        external
        returns (uint256[] memory poolIds);
    function createToken(uint256[] calldata poolIds, uint256[] calldata weights, address owner)
        external
        returns (uint256 _tokenId);
}
abstract contract ERC4626MultiToken is ERC20, ReentrancyGuard, IERC4626MultiToken {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    address[] public assets;
    uint256[] public weights;
    mapping(address => uint256) public assetId;
    uint256 public totalWeights;
    function getAssets() external view returns (address[] memory) {
        return assets;
    }
    constructor(address[] memory _assets, uint256[] memory _weights, string memory _name, string memory _symbol)
        ERC20(_name, _symbol, 18)
    {
        assets = _assets;
        weights = _weights;
        uint256 length = _weights.length;
        uint256 _totalWeights;
        if (length != _assets.length || length == 0) revert InvalidLength();
        for (uint256 i = 0; i < length;) {
            require(ERC20(_assets[i]).decimals() == 18);
            require(_weights[i] > 0);
            _totalWeights += _weights[i];
            assetId[_assets[i]] = i + 1;
            emit AssetAdded(_assets[i], _weights[i]);
            unchecked {
                i++;
            }
        }
        totalWeights = _totalWeights;
    }
    function receiveAssets(uint256[] memory assetsAmounts) private {
        uint256 length = assetsAmounts.length;
        for (uint256 i = 0; i < length;) {
            assets[i].safeTransferFrom(msg.sender, address(this), assetsAmounts[i]);
            unchecked {
                i++;
            }
        }
    }
    function sendAssets(uint256[] memory assetsAmounts, address receiver) private {
        uint256 length = assetsAmounts.length;
        for (uint256 i = 0; i < length;) {
            assets[i].safeTransfer(receiver, assetsAmounts[i]);
            unchecked {
                i++;
            }
        }
    }
    function deposit(uint256[] calldata assetsAmounts, address receiver)
        public
        virtual
        nonReentrant
        returns (uint256 shares)
    {
        require((shares = previewDeposit(assetsAmounts)) != 0, "ZERO_SHARES");
        receiveAssets(assetsAmounts);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assetsAmounts, shares);
        afterDeposit(assetsAmounts, shares);
    }
    function mint(uint256 shares, address receiver)
        public
        virtual
        nonReentrant
        returns (uint256[] memory assetsAmounts)
    {
        assetsAmounts = previewMint(shares); 
        receiveAssets(assetsAmounts);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assetsAmounts, shares);
        afterDeposit(assetsAmounts, shares);
    }
    function withdraw(uint256[] calldata assetsAmounts, address receiver, address owner)
        public
        virtual
        nonReentrant
        returns (uint256 shares)
    {
        shares = previewWithdraw(assetsAmounts); 
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        beforeWithdraw(assetsAmounts, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assetsAmounts, shares);
        sendAssets(assetsAmounts, receiver);
    }
    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        nonReentrant
        returns (uint256[] memory assetsAmounts)
    {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        assetsAmounts = previewRedeem(shares);
        uint256 length = assetsAmounts.length;
        for (uint256 i = 0; i < length;) {
            if (assetsAmounts[i] == 0) revert ZeroAssets();
            unchecked {
                i++;
            }
        }
        beforeWithdraw(assetsAmounts, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assetsAmounts, shares);
        sendAssets(assetsAmounts, receiver);
    }
    function totalAssets() public view virtual returns (uint256);
    function convertToShares(uint256[] calldata assetsAmounts) public view virtual returns (uint256 shares) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assetsAmounts.length;
        if (length != assets.length) revert InvalidLength();
        shares = type(uint256).max;
        for (uint256 i = 0; i < length;) {
            uint256 share = assetsAmounts[i].mulDiv(_totalWeights, weights[i]);
            if (share < shares) shares = share;
            unchecked {
                i++;
            }
        }
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256[] memory assetsAmounts) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assets.length;
        assetsAmounts = new uint256[](length);
        for (uint256 i = 0; i < length;) {
            assetsAmounts[i] = shares.mulDiv(weights[i], _totalWeights);
            unchecked {
                i++;
            }
        }
    }
    function previewDeposit(uint256[] calldata assetsAmounts) public view virtual returns (uint256) {
        return convertToShares(assetsAmounts);
    }
    function previewMint(uint256 shares) public view virtual returns (uint256[] memory assetsAmounts) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assets.length;
        assetsAmounts = new uint256[](length);
        for (uint256 i = 0; i < length;) {
            assetsAmounts[i] = shares.mulDivUp(weights[i], _totalWeights);
            unchecked {
                i++;
            }
        }
    }
    function previewWithdraw(uint256[] calldata assetsAmounts) public view virtual returns (uint256 shares) {
        uint256 _totalWeights = totalWeights;
        uint256 length = assetsAmounts.length;
        if (length != assets.length) revert InvalidLength();
        for (uint256 i = 0; i < length;) {
            uint256 share = assetsAmounts[i].mulDivUp(_totalWeights, weights[i]);
            if (share > shares) shares = share;
            unchecked {
                i++;
            }
        }
    }
    function previewRedeem(uint256 shares) public view virtual returns (uint256[] memory) {
        return convertToAssets(shares);
    }
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxWithdraw(address owner) public view virtual returns (uint256[] memory) {
        return convertToAssets(balanceOf[owner]);
    }
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }
    function beforeWithdraw(uint256[] memory assetsAmounts, uint256 shares) internal virtual {}
    function afterDeposit(uint256[] memory assetsAmounts, uint256 shares) internal virtual {}
}
abstract contract UlyssesERC4626 is ERC20, ReentrancyGuard, IUlyssesERC4626 {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    address public immutable asset;
    constructor(address _asset, string memory _name, string memory _symbol) ERC20(_name, _symbol, 18) {
        asset = _asset;
        if (ERC20(_asset).decimals() != 18) revert InvalidAssetDecimals();
    }
    function deposit(uint256 assets, address receiver) public virtual nonReentrant returns (uint256 shares) {
        asset.safeTransferFrom(msg.sender, address(this), assets);
        shares = beforeDeposit(assets);
        require(shares != 0, "ZERO_SHARES");
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    function mint(uint256 shares, address receiver) public virtual nonReentrant returns (uint256 assets) {
        assets = beforeMint(shares); 
        require(assets != 0, "ZERO_ASSETS");
        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
    }
    function redeem(uint256 shares, address receiver, address owner)
        public
        virtual
        nonReentrant
        returns (uint256 assets)
    {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        _burn(owner, shares);
        assets = afterRedeem(shares);
        require(assets != 0, "ZERO_ASSETS");
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        asset.safeTransfer(receiver, assets);
    }
    function totalAssets() public view virtual returns (uint256);
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        return assets;
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return assets;
    }
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return shares;
    }
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }
    function beforeDeposit(uint256 assets) internal virtual returns (uint256 shares);
    function beforeMint(uint256 shares) internal virtual returns (uint256 assets);
    function afterRedeem(uint256 shares) internal virtual returns (uint256 assets);
}
contract UlyssesToken is ERC4626MultiToken, Ownable, IUlyssesToken {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    uint256 public immutable id;
    constructor(
        uint256 _id,
        address[] memory _assets,
        uint256[] memory _weights,
        string memory _name,
        string memory _symbol,
        address _owner
    ) ERC4626MultiToken(_assets, _weights, _name, _symbol) {
        _initializeOwner(_owner);
        require(_id != 0);
        id = _id;
    }
    function totalAssets() public view override returns (uint256 _totalAssets) {
        return totalSupply;
    }
    function addAsset(address asset, uint256 _weight) external nonReentrant onlyOwner {
        if (assetId[asset] != 0) revert AssetAlreadyAdded();
        require(ERC20(asset).decimals() == 18);
        require(_weight > 0);
        assetId[asset] = assets.length + 1;
        assets.push(asset);
        weights.push(_weight);
        totalWeights += _weight;
        emit AssetAdded(asset, _weight);
        updateAssetBalances();
    }
    function removeAsset(address asset) external nonReentrant onlyOwner {
        uint256 assetIndex = assetId[asset] - 1;
        uint256 newAssetsLength = assets.length - 1;
        if (newAssetsLength == 0) revert CannotRemoveLastAsset();
        totalWeights -= weights[assetIndex];
        address lastAsset = assets[newAssetsLength];
        assetId[lastAsset] = assetIndex;
        assets[assetIndex] = lastAsset;
        weights[assetIndex] = weights[newAssetsLength];
        assets.pop();
        weights.pop();
        assetId[asset] = 0;
        emit AssetRemoved(asset);
        updateAssetBalances();
        asset.safeTransfer(msg.sender, asset.balanceOf(address(this)));
    }
    function setWeights(uint256[] memory _weights) external nonReentrant onlyOwner {
        if (_weights.length != assets.length) revert InvalidWeightsLength();
        weights = _weights;
        uint256 newTotalWeights;
        for (uint256 i = 0; i < assets.length; i++) {
            newTotalWeights += _weights[i];
            emit AssetRemoved(assets[i]);
            emit AssetAdded(assets[i], _weights[i]);
        }
        totalWeights = newTotalWeights;
        updateAssetBalances();
    }
    function updateAssetBalances() internal {
        for (uint256 i = 0; i < assets.length; i++) {
            uint256 assetBalance = assets[i].balanceOf(address(this));
            uint256 newAssetBalance = totalSupply.mulDivUp(weights[i], totalWeights);
            if (assetBalance > newAssetBalance) {
                assets[i].safeTransfer(msg.sender, assetBalance - newAssetBalance);
            } else {
                assets[i].safeTransferFrom(msg.sender, address(this), newAssetBalance - assetBalance);
            }
        }
    }
}
interface IUlyssesPool {
    struct BandwidthState {
        uint248 bandwidth;
        uint8 weight;
        UlyssesPool destination;
    }
    struct Fees {
        uint64 lambda1;
        uint64 lambda2;
        uint64 sigma1;
        uint64 sigma2;
    }
    function getBandwidth(uint256 destinationId) external view returns (uint256);
    function getBandwidthStateList() external view returns (BandwidthState[] memory);
    function getProtocolFees() external view returns (uint256);
    function claimProtocolFees() external returns (uint256 claimed);
    function addNewBandwidth(uint256 poolId, uint8 weight) external returns (uint256 index);
    function setWeight(uint256 poolId, uint8 weight) external;
    function setFees(Fees calldata _fees) external;
    function setProtocolFee(uint256 _protocolFee) external;
    function swapIn(uint256 amount, uint256 poolId) external returns (uint256 output);
    function swapFromPool(uint256 amount, address user) external returns (uint256 output);
    error InvalidPool();
    error NotUlyssesLP();
    error FeeError();
    error AmountTooSmall();
    error InvalidWeight();
    error InvalidFee();
    error TooManyDestinations();
    error NotInitialized();
    error MulDivFailed();
    error Overflow();
    error Underflow();
    event Swap(address indexed caller, uint256 indexed poolId, uint256 assets);
}
contract UlyssesPool is UlyssesERC4626, Ownable, IUlyssesPool {
    using SafeTransferLib for address;
    using FixedPointMathLib for uint256;
    using SafeCastLib for uint256;
    UlyssesFactory public immutable factory;
    uint256 public immutable id;
    BandwidthState[] public bandwidthStateList;
    mapping(uint256 => uint256) public destinations;
    mapping(address => uint256) public destinationIds;
    uint256 public totalWeights;
    uint256 private constant MIN_SWAP_AMOUNT = 1e4;
    uint256 private constant MAX_TOTAL_WEIGHT = 256;
    uint256 private constant MAX_DESTINATIONS = 15;
    uint256 private constant MAX_PROTOCOL_FEE = 1e16;
    uint256 private constant MAX_LAMBDA1 = 1e17;
    uint256 private constant MIN_SIGMA2 = 1e16;
    uint256 private constant DIVISIONER = 1 ether;
    uint256 public protocolFee = 1e14;
    Fees public fees = Fees({lambda1: 20e14, lambda2: 4980e14, sigma1: 6000e14, sigma2: 500e14});
    constructor(
        uint256 _id,
        address _asset,
        string memory _name,
        string memory _symbol,
        address _owner,
        address _factory
    ) UlyssesERC4626(_asset, _name, _symbol) {
        require(_owner != address(0));
        factory = UlyssesFactory(_factory);
        _initializeOwner(_owner);
        require(_id != 0);
        id = _id;
        bandwidthStateList.push(BandwidthState({bandwidth: 0, destination: UlyssesPool(address(0)), weight: 0}));
    }
    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this)) - getProtocolFees();
    }
    function maxRedeem(address owner) public view override returns (uint256) {
        return balanceOf[owner].min(asset.balanceOf(address(this)));
    }
    function getBandwidth(uint256 destinationId) external view returns (uint256) {
        return bandwidthStateList[destinations[destinationId]].bandwidth;
    }
    function getBandwidthStateList() external view returns (BandwidthState[] memory) {
        return bandwidthStateList;
    }
    function getProtocolFees() public view returns (uint256) {
        uint256 balance = asset.balanceOf(address(this));
        uint256 assets;
        for (uint256 i = 1; i < bandwidthStateList.length; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);
            assets += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
            assets += bandwidthStateList[i].bandwidth;
        }
        if (balance > assets) {
            return balance - assets;
        } else {
            return 0;
        }
    }
    function claimProtocolFees() external nonReentrant returns (uint256 claimed) {
        claimed = getProtocolFees();
        if (claimed > 0) {
            asset.safeTransfer(factory.owner(), claimed);
        }
    }
    function addNewBandwidth(uint256 poolId, uint8 weight) external nonReentrant onlyOwner returns (uint256 index) {
        if (weight == 0) revert InvalidWeight();
        UlyssesPool destination = factory.pools(poolId);
        uint256 destinationId = destination.id();
        if (destinationIds[address(destination)] != 0 || destinationId == id) revert InvalidPool();
        if (destinationId == 0) revert NotUlyssesLP();
        index = bandwidthStateList.length;
        if (index > MAX_DESTINATIONS) revert TooManyDestinations();
        uint256 oldRebalancingFee;
        for (uint256 i = 1; i < index; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);
            oldRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }
        uint256 oldTotalWeights = totalWeights;
        uint256 newTotalWeights = oldTotalWeights + weight;
        totalWeights = newTotalWeights;
        if (newTotalWeights > MAX_TOTAL_WEIGHT) revert InvalidWeight();
        uint256 newBandwidth;
        for (uint256 i = 1; i < index;) {
            uint256 oldBandwidth = bandwidthStateList[i].bandwidth;
            if (oldBandwidth > 0) {
                bandwidthStateList[i].bandwidth = oldBandwidth.mulDivUp(oldTotalWeights, newTotalWeights).toUint248();
                newBandwidth += oldBandwidth - bandwidthStateList[i].bandwidth;
            }
            unchecked {
                ++i;
            }
        }
        bandwidthStateList.push(
            BandwidthState({bandwidth: newBandwidth.toUint248(), destination: destination, weight: weight})
        );
        destinations[destinationId] = index;
        destinationIds[address(destination)] = index;
        uint256 newRebalancingFee;
        for (uint256 i = 1; i <= index; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);
            newRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }
        if (oldRebalancingFee < newRebalancingFee) {
            asset.safeTransferFrom(msg.sender, address(this), newRebalancingFee - oldRebalancingFee);
        }
    }
    function setWeight(uint256 poolId, uint8 weight) external nonReentrant onlyOwner {
        if (weight == 0) revert InvalidWeight();
        uint256 poolIndex = destinations[poolId];
        if (poolIndex == 0) revert NotUlyssesLP();
        uint256 oldRebalancingFee;
        for (uint256 i = 1; i < bandwidthStateList.length; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);
            oldRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }
        uint256 oldTotalWeights = totalWeights;
        uint256 weightsWithoutPool = oldTotalWeights - bandwidthStateList[poolIndex].weight;
        uint256 newTotalWeights = weightsWithoutPool + weight;
        totalWeights = newTotalWeights;
        if (totalWeights > MAX_TOTAL_WEIGHT || oldTotalWeights == newTotalWeights) {
            revert InvalidWeight();
        }
        uint256 leftOverBandwidth;
        BandwidthState storage poolState = bandwidthStateList[poolIndex];
        poolState.weight = weight;
        if (oldTotalWeights > newTotalWeights) {
            for (uint256 i = 1; i < bandwidthStateList.length;) {
                if (i != poolIndex) {
                    uint256 oldBandwidth = bandwidthStateList[i].bandwidth;
                    if (oldBandwidth > 0) {
                        bandwidthStateList[i].bandwidth =
                            oldBandwidth.mulDivUp(oldTotalWeights, newTotalWeights).toUint248();
                        leftOverBandwidth += oldBandwidth - bandwidthStateList[i].bandwidth;
                    }
                }
                unchecked {
                    ++i;
                }
            }
            poolState.bandwidth += leftOverBandwidth.toUint248();
        } else {
            uint256 oldBandwidth = poolState.bandwidth;
            if (oldBandwidth > 0) {
                poolState.bandwidth = oldBandwidth.mulDivUp(oldTotalWeights, newTotalWeights).toUint248();
                leftOverBandwidth += oldBandwidth - poolState.bandwidth;
            }
            for (uint256 i = 1; i < bandwidthStateList.length;) {
                if (i != poolIndex) {
                    if (i == bandwidthStateList.length - 1) {
                        bandwidthStateList[i].bandwidth += leftOverBandwidth.toUint248();
                    } else if (leftOverBandwidth > 0) {
                        bandwidthStateList[i].bandwidth +=
                            leftOverBandwidth.mulDiv(bandwidthStateList[i].weight, weightsWithoutPool).toUint248();
                    }
                }
                unchecked {
                    ++i;
                }
            }
        }
        uint256 newRebalancingFee;
        for (uint256 i = 1; i < bandwidthStateList.length; i++) {
            uint256 targetBandwidth = totalSupply.mulDiv(bandwidthStateList[i].weight, totalWeights);
            newRebalancingFee += _calculateRebalancingFee(bandwidthStateList[i].bandwidth, targetBandwidth, false);
        }
        if (oldRebalancingFee < newRebalancingFee) {
            asset.safeTransferFrom(msg.sender, address(this), newRebalancingFee - oldRebalancingFee);
        }
    }
    function setFees(Fees calldata _fees) external nonReentrant onlyOwner {
        if (_fees.lambda1 > MAX_LAMBDA1) revert InvalidFee();
        if (_fees.lambda1 + _fees.lambda2 != DIVISIONER / 2) revert InvalidFee();
        if (_fees.sigma1 > DIVISIONER) revert InvalidFee();
        if (_fees.sigma1 <= _fees.sigma2 || _fees.sigma2 < MIN_SIGMA2) revert InvalidFee();
        fees = _fees;
    }
    function setProtocolFee(uint256 _protocolFee) external nonReentrant {
        if (msg.sender != factory.owner()) revert Unauthorized();
        if (_protocolFee > MAX_PROTOCOL_FEE) revert InvalidFee();
        protocolFee = _protocolFee;
    }
    function getBandwidthUpdateAmounts(
        bool roundUp,
        bool positiveTransfer,
        uint256 amount,
        uint256 _totalWeights,
        uint256 _totalSupply
    ) private view returns (uint256[] memory bandwidthUpdateAmounts, uint256 length) {
        length = bandwidthStateList.length;
        assembly {
            if eq(length, 1) {
                mstore(0x00, 0x87138d5c)
                revert(0x1c, 0x04)
            }
            if lt(amount, MIN_SWAP_AMOUNT) {
                mstore(0x00, 0xc2f5625a)
                revert(0x1c, 0x04)
            }
        }
        bandwidthUpdateAmounts = new uint256[](length);
        uint256[] memory diffs = new uint256[](length);
        assembly {
            mstore(0x00, bandwidthStateList.slot)
            let bandwidthStateListStart := keccak256(0x00, 0x20)
            let totalDiff
            let transfered
            let transferedChange
            for { let i := 1 } lt(i, length) { i := add(i, 1) } {
                let slot := sload(add(bandwidthStateListStart, mul(i, 2)))
                let bandwidth := and(slot, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                let weight := shr(248, slot)
                if mul(weight, gt(_totalSupply, div(not(0), weight))) {
                    mstore(0x00, 0xad251c27)
                    revert(0x1c, 0x04)
                }
                let targetBandwidth := div(mul(_totalSupply, weight), _totalWeights)
                switch positiveTransfer
                case true {
                    if gt(targetBandwidth, bandwidth) {
                        let diff := sub(targetBandwidth, bandwidth)
                        totalDiff := add(totalDiff, diff)
                        mstore(add(diffs, add(mul(i, 0x20), 0x20)), diff)
                    }
                }
                default {
                    if gt(bandwidth, targetBandwidth) {
                        let diff := sub(bandwidth, targetBandwidth)
                        totalDiff := add(totalDiff, diff)
                        mstore(add(diffs, add(mul(i, 0x20), 0x20)), diff)
                    }
                }
            }
            switch gt(amount, totalDiff)
            case true {
                transfered := totalDiff
                transferedChange := sub(amount, totalDiff)
            }
            default {
                transfered := amount
            }
            for { let i := 1 } lt(i, length) { i := add(i, 1) } {
                let bandwidthUpdate
                if gt(transfered, 0) {
                    let diff := mload(add(diffs, add(mul(i, 0x20), 0x20)))
                    if mul(diff, gt(transfered, div(not(0), diff))) {
                        mstore(0x00, 0xad251c27)
                        revert(0x1c, 0x04)
                    }
                    switch roundUp
                    case true {
                        bandwidthUpdate :=
                            add(
                                iszero(iszero(mod(mul(transfered, diff), totalDiff))), div(mul(transfered, diff), totalDiff)
                            )
                    }
                    default { bandwidthUpdate := div(mul(transfered, diff), totalDiff) }
                }
                if gt(transferedChange, 0) {
                    let weight := shr(248, sload(add(bandwidthStateListStart, mul(i, 2))))
                    if mul(weight, gt(transferedChange, div(not(0), weight))) {
                        mstore(0x00, 0xad251c27)
                        revert(0x1c, 0x04)
                    }
                    switch roundUp
                    case true {
                        bandwidthUpdate :=
                            add(
                                bandwidthUpdate,
                                add(
                                    iszero(iszero(mod(mul(transferedChange, weight), _totalWeights))),
                                    div(mul(transferedChange, weight), _totalWeights)
                                )
                            )
                    }
                    default {
                        bandwidthUpdate := add(bandwidthUpdate, div(mul(transferedChange, weight), _totalWeights))
                    }
                }
                if gt(bandwidthUpdate, 0) {
                    mstore(add(bandwidthUpdateAmounts, add(mul(i, 0x20), 0x20)), bandwidthUpdate)
                }
            }
        }
    }
    function updateBandwidth(
        bool depositFees,
        bool positiveTransfer,
        BandwidthState storage destinationState,
        uint256 difference,
        uint256 _totalWeights,
        uint256 _totalSupply,
        uint256 _newTotalSupply
    ) private returns (uint256 positivefee, uint256 negativeFee) {
        uint256 bandwidth;
        uint256 targetBandwidth;
        uint256 weight;
        assembly {
            let slot := sload(destinationState.slot)
            bandwidth := and(slot, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            weight := shr(248, slot)
            if mul(weight, gt(_totalSupply, div(not(0), weight))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            targetBandwidth := div(mul(_totalSupply, weight), _totalWeights)
        }
        uint256 oldRebalancingFee = _calculateRebalancingFee(
            bandwidth,
            targetBandwidth,
            positiveTransfer 
        );
        assembly {
            switch positiveTransfer
            case true {
                bandwidth := add(bandwidth, difference)
                if lt(bandwidth, difference) {
                    mstore(0x00, 0x35278d12)
                    revert(0x1c, 0x04)
                }
            }
            default {
                if gt(difference, bandwidth) {
                    mstore(0x00, 0xcaccb6d9)
                    revert(0x1c, 0x04)
                }
                bandwidth := sub(bandwidth, difference)
            }
            if gt(_newTotalSupply, 0) {
                if mul(weight, gt(_newTotalSupply, div(not(0), weight))) {
                    mstore(0x00, 0xad251c27)
                    revert(0x1c, 0x04)
                }
                targetBandwidth := div(mul(_newTotalSupply, weight), _totalWeights)
            }
        }
        uint256 newRebalancingFee = _calculateRebalancingFee(
            bandwidth,
            targetBandwidth,
            positiveTransfer 
        );
        assembly {
            switch lt(newRebalancingFee, oldRebalancingFee)
            case true {
                positivefee := sub(oldRebalancingFee, newRebalancingFee)
                if depositFees {
                    bandwidth := add(bandwidth, positivefee)
                    if lt(bandwidth, positivefee) {
                        mstore(0x00, 0x35278d12)
                        revert(0x1c, 0x04)
                    }
                }
            }
            default {
                if gt(newRebalancingFee, oldRebalancingFee) {
                    negativeFee := sub(newRebalancingFee, oldRebalancingFee)
                }
            }
            if gt(bandwidth, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff) {
                mstore(0x00, 0x35278d12)
                revert(0x1c, 0x04)
            }
            sstore(destinationState.slot, or(bandwidth, shl(248, weight)))
        }
    }
    function _calculateRebalancingFee(uint256 bandwidth, uint256 targetBandwidth, bool roundDown)
        internal
        view
        returns (uint256 fee)
    {
        if (bandwidth >= targetBandwidth) return 0;
        uint256 upperBound1;
        uint256 upperBound2;
        uint256 lambda1;
        uint256 lambda2;
        assembly {
            let feeSlot := sload(fees.slot)
            let sigma2 := shr(192, feeSlot)
            let sigma1 := and(shr(128, feeSlot), 0xffffffffffffffff)
            lambda2 := and(shr(64, feeSlot), 0xffffffffffffffff)
            lambda1 := and(feeSlot, 0xffffffffffffffff)
            if mul(sigma1, gt(targetBandwidth, div(not(0), sigma1))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            upperBound1 := div(mul(targetBandwidth, sigma1), DIVISIONER)
            if mul(sigma2, gt(targetBandwidth, div(not(0), sigma2))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            upperBound2 := div(mul(targetBandwidth, sigma2), DIVISIONER)
        }
        if (bandwidth >= upperBound1) return 0;
        uint256 maxWidth;
        assembly {
            maxWidth := sub(upperBound1, upperBound2)
        }
        if (bandwidth >= upperBound2) {
            fee = calcFee(lambda1, maxWidth, upperBound1, bandwidth, 0, roundDown);
        } else {
            fee = calcFee(lambda1, maxWidth, upperBound1, upperBound2, 0, roundDown);
            assembly {
                lambda1 := shl(1, lambda1)
            }
            uint256 fee2 = calcFee(lambda2, upperBound2, upperBound2, bandwidth, lambda1, roundDown);
            assembly {
                fee := add(fee, fee2)
            }
        }
    }
    function calcFee(
        uint256 feeTier,
        uint256 maxWidth,
        uint256 upperBound,
        uint256 bandwidth,
        uint256 offset,
        bool roundDown
    ) private pure returns (uint256 fee) {
        assembly {
            let height := sub(upperBound, bandwidth)
            if mul(feeTier, gt(height, div(not(0), feeTier))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            let width :=
                add(add(iszero(iszero(mod(mul(height, feeTier), maxWidth))), div(mul(height, feeTier), maxWidth)), offset)
            if mul(height, gt(width, div(not(0), height))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            switch roundDown
            case true { fee := div(mul(width, height), DIVISIONER) }
            default {
                fee := add(iszero(iszero(mod(mul(width, height), DIVISIONER))), div(mul(width, height), DIVISIONER))
            }
        }
    }
    function ulyssesSwap(uint256 assets) private returns (uint256 output) {
        uint256 _totalWeights = totalWeights;
        uint256 _totalSupply = totalSupply;
        (uint256[] memory bandwidthUpdateAmounts, uint256 length) = getBandwidthUpdateAmounts(
            false, 
            true, 
            assets,
            _totalWeights,
            _totalSupply
        );
        for (uint256 i = 1; i < length;) {
            uint256 updateAmount = bandwidthUpdateAmounts[i];
            if (updateAmount > 0) {
                assembly {
                    output := add(output, updateAmount)
                }
                (uint256 positiveFee,) =
                    updateBandwidth(true, true, bandwidthStateList[i], updateAmount, _totalWeights, _totalSupply, 0);
                assembly {
                    if gt(positiveFee, 0) { output := add(output, positiveFee) }
                }
            }
            unchecked {
                ++i;
            }
        }
    }
    function ulyssesAddLP(uint256 amount, bool depositFees) private returns (uint256 output) {
        uint256 _totalWeights = totalWeights;
        uint256 _totalSupply = totalSupply;
        uint256 _newTotalSupply;
        assembly {
            _newTotalSupply := add(_totalSupply, amount)
        }
        (uint256[] memory bandwidthUpdateAmounts, uint256 length) =
            getBandwidthUpdateAmounts(!depositFees, true, amount, _totalWeights, _newTotalSupply);
        uint256 negativeFee;
        for (uint256 i = 1; i < length;) {
            uint256 updateAmount = bandwidthUpdateAmounts[i];
            assembly {
                if gt(updateAmount, 0) { output := add(output, updateAmount) }
            }
            (uint256 _positiveFee, uint256 _negativeFee) = updateBandwidth(
                depositFees, true, bandwidthStateList[i], updateAmount, _totalWeights, _totalSupply, _newTotalSupply
            );
            assembly {
                switch depositFees
                case true {
                    switch gt(_positiveFee, 0)
                    case true { output := add(output, _positiveFee) }
                    default { negativeFee := add(negativeFee, _negativeFee) }
                }
                default {
                    switch gt(_positiveFee, 0)
                    case true { negativeFee := add(negativeFee, _positiveFee) }
                    default { output := add(output, _negativeFee) }
                }
            }
            unchecked {
                ++i;
            }
        }
        assembly {
            if gt(negativeFee, output) {
                mstore(0x00, 0xcaccb6d9)
                revert(0x1c, 0x04)
            }
            output := sub(output, negativeFee)
        }
    }
    function ulyssesRemoveLP(uint256 shares) private returns (uint256 assets) {
        uint256 _totalWeights = totalWeights;
        uint256 _totalSupply;
        uint256 _newTotalSupply = totalSupply;
        assembly {
            _totalSupply := add(_newTotalSupply, shares)
        }
        (uint256[] memory bandwidthUpdateAmounts, uint256 length) =
            getBandwidthUpdateAmounts(false, false, shares, _totalWeights, _totalSupply);
        uint256 negativeFee;
        for (uint256 i = 1; i < length;) {
            uint256 updateAmount = bandwidthUpdateAmounts[i];
            if (updateAmount > 0) {
                assembly {
                    assets := add(assets, updateAmount)
                }
                (, uint256 _negativeFee) = updateBandwidth(
                    false, false, bandwidthStateList[i], updateAmount, _totalWeights, _totalSupply, _newTotalSupply
                );
                assembly {
                    negativeFee := add(negativeFee, _negativeFee)
                }
            }
            unchecked {
                ++i;
            }
        }
        assembly {
            if gt(negativeFee, assets) {
                mstore(0x00, 0xcaccb6d9)
                revert(0x1c, 0x04)
            }
            assets := sub(assets, negativeFee)
        }
    }
    function swapIn(uint256 assets, uint256 poolId) external nonReentrant returns (uint256 output) {
        uint256 index = destinations[poolId]; 
        assembly {
            if iszero(index) {
                mstore(0x00, 0x3c930918)
                revert(0x1c, 0x04)
            }
        }
        asset.safeTransferFrom(msg.sender, address(this), assets);
        assembly {
            let _protocolFee := sload(protocolFee.slot)
            if mul(_protocolFee, gt(assets, div(not(0), _protocolFee))) {
                mstore(0x00, 0xad251c27)
                revert(0x1c, 0x04)
            }
            let baseFee :=
                add(iszero(iszero(mod(mul(assets, _protocolFee), DIVISIONER))), div(mul(assets, _protocolFee), DIVISIONER))
            if gt(baseFee, assets) {
                mstore(0x00, 0xcaccb6d9)
                revert(0x1c, 0x04)
            }
            output := sub(assets, baseFee)
        }
        emit Swap(msg.sender, poolId, assets);
        output = bandwidthStateList[index].destination.swapFromPool(ulyssesSwap(output), msg.sender);
    }
    function swapFromPool(uint256 assets, address user) external nonReentrant returns (uint256 output) {
        uint256 index = destinationIds[msg.sender]; 
        assembly {
            if iszero(index) {
                mstore(0x00, 0x3c930918)
                revert(0x1c, 0x04)
            }
            if iszero(assets) {
                mstore(0x00, 0xc2f5625a)
                revert(0x1c, 0x04)
            }
        }
        (, uint256 negativeFee) =
            updateBandwidth(false, false, bandwidthStateList[index], assets, totalWeights, totalSupply, 0);
        assembly {
            if gt(negativeFee, assets) {
                mstore(0x00, 0xcaccb6d9)
                revert(0x1c, 0x04)
            }
            output := sub(assets, negativeFee)
        }
        asset.safeTransfer(user, output);
    }
    function beforeDeposit(uint256 assets) internal override returns (uint256 shares) {
        shares = ulyssesAddLP(assets, true);
    }
    function beforeMint(uint256 shares) internal override returns (uint256 assets) {
        assets = ulyssesAddLP(shares, false);
    }
    function afterRedeem(uint256 shares) internal override returns (uint256 assets) {
        assets = ulyssesRemoveLP(shares);
    }
}
library UlyssesPoolDeployer {
    function deployPool(
        uint256 id,
        address asset,
        string calldata name,
        string calldata symbol,
        address owner,
        address factory
    ) public returns (UlyssesPool) {
        return new UlyssesPool(id, asset, name, symbol, owner, factory);
    }
}
contract UlyssesFactory is Ownable, IUlyssesFactory {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    error ParameterLengthError();
    error InvalidPoolId();
    error InvalidAsset();
    uint256 public poolId = 1;
    uint256 public tokenId = 1;
    mapping(uint256 => UlyssesPool) public pools;
    mapping(uint256 => UlyssesToken) public tokens;
    constructor(address _owner) {
        require(_owner != address(0), "Owner cannot be 0");
        _initializeOwner(_owner);
    }
    function renounceOwnership() public payable override onlyOwner {
        revert("Cannot renounce ownership");
    }
    function createPool(ERC20 asset, address owner) external returns (uint256) {
        return _createPool(asset, owner);
    }
    function _createPool(ERC20 asset, address owner) private returns (uint256 _poolId) {
        if (address(asset) == address(0)) revert InvalidAsset();
        _poolId = ++poolId;
        pools[_poolId] =
            UlyssesPoolDeployer.deployPool(_poolId, address(asset), "Ulysses Pool", "ULP", owner, address(this));
    }
    function createPools(ERC20[] calldata assets, uint8[][] calldata weights, address owner)
        external
        returns (uint256[] memory poolIds)
    {
        uint256 length = assets.length;
        if (length != weights.length) revert ParameterLengthError();
        for (uint256 i = 0; i < length;) {
            poolIds[i] = _createPool(assets[i], address(this));
            unchecked {
                ++i;
            }
        }
        for (uint256 i = 0; i < length;) {
            if (length != weights[i].length) revert ParameterLengthError();
            for (uint256 j = 0; j < length;) {
                if (j != i && weights[i][j] > 0) pools[poolIds[i]].addNewBandwidth(poolIds[j], weights[i][j]);
                unchecked {
                    ++j;
                }
            }
            unchecked {
                ++i;
            }
        }
        for (uint256 i = 0; i < length;) {
            pools[poolIds[i]].transferOwnership(owner);
            unchecked {
                ++i;
            }
        }
    }
    function createToken(uint256[] calldata poolIds, uint256[] calldata weights, address owner)
        external
        returns (uint256 _tokenId)
    {
        _tokenId = ++tokenId;
        uint256 length = poolIds.length;
        address[] memory destinations = new address[](length);
        for (uint256 i = 0; i < length;) {
            address destination = address(pools[poolIds[i]]);
            if (destination == address(0)) revert InvalidPoolId();
            destinations[i] = destination;
            unchecked {
                ++i;
            }
        }
        tokens[_tokenId] = new UlyssesToken(
            _tokenId,
            destinations,
            weights,
            "Ulysses Token",
            "ULT",
            owner
        );
    }
}
interface IUlyssesRouter {
    struct Route {
        uint128 from;
        uint128 to;
    }
    function ulyssesFactory() external view returns (UlyssesFactory);
    function addLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256);
    function removeLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256);
    function swap(uint256 amount, uint256 minOutput, Route[] calldata routes) external returns (uint256);
    error OutputTooLow();
    error UnrecognizedUlyssesLP();
}
contract UlyssesRouter is IUlyssesRouter {
    using SafeTransferLib for address;
    mapping(uint256 => UlyssesPool) private pools;
    UlyssesFactory public ulyssesFactory;
    constructor(UlyssesFactory _ulyssesFactory) {
        ulyssesFactory = _ulyssesFactory;
    }
    function getUlyssesLP(uint256 id) private returns (UlyssesPool ulysses) {
        ulysses = pools[id];
        if (address(ulysses) == address(0)) {
            ulysses = ulyssesFactory.pools(id);
            if (address(ulysses) == address(0)) revert UnrecognizedUlyssesLP();
            pools[id] = ulysses;
            address(ulysses.asset()).safeApprove(address(ulysses), type(uint256).max);
        }
    }
    function addLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256) {
        UlyssesPool ulysses = getUlyssesLP(poolId);
        amount = ulysses.deposit(amount, msg.sender);
        if (amount < minOutput) revert OutputTooLow();
        return amount;
    }
    function removeLiquidity(uint256 amount, uint256 minOutput, uint256 poolId) external returns (uint256) {
        UlyssesPool ulysses = getUlyssesLP(poolId);
        amount = ulysses.redeem(amount, msg.sender, msg.sender);
        if (amount < minOutput) revert OutputTooLow();
        return amount;
    }
    function swap(uint256 amount, uint256 minOutput, Route[] calldata routes) external returns (uint256) {
        address(getUlyssesLP(routes[0].from).asset()).safeTransferFrom(msg.sender, address(this), amount);
        uint256 length = routes.length;
        for (uint256 i = 0; i < length;) {
            amount = getUlyssesLP(routes[i].from).swapIn(amount, routes[i].to);
            unchecked {
                ++i;
            }
        }
        if (amount < minOutput) revert OutputTooLow();
        unchecked {
            --length;
        }
        address(getUlyssesLP(routes[length].to).asset()).safeTransfer(msg.sender, amount);
        return amount;
    }
}