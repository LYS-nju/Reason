pragma solidity ^0.8.18;
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
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
interface IAnycallConfig {
    function calcSrcFees(address _app, uint256 _toChainID, uint256 _dataLength) external view returns (uint256);
    function executionBudget(address _app) external view returns (uint256);
    function deposit(address _account) external payable;
    function withdraw(uint256 _amount) external;
}
interface IAnycallExecutor {
    function context() external view returns (address from, uint256 fromChainID, uint256 nonce);
    function execute(
        address _to,
        bytes calldata _data,
        address _from,
        uint256 _fromChainID,
        uint256 _nonce,
        uint256 _flags,
        bytes calldata _extdata
    ) external returns (bool success, bytes memory result);
}
interface IAnycallProxy {
    function executor() external view returns (address);
    function config() external view returns (address);
    function anyCall(address _to, bytes calldata _data, uint256 _toChainID, uint256 _flags, bytes calldata _extdata)
        external
        payable;
    function anyCall(
        string calldata _to,
        bytes calldata _data,
        uint256 _toChainID,
        uint256 _flags,
        bytes calldata _extdata
    ) external payable;
}
interface IApp {
    function anyExecute(bytes calldata _data) external returns (bool success, bytes memory result);
    function anyFallback(bytes calldata _data) external returns (bool success, bytes memory result);
}
interface IERC20hTokenRoot {
    function localChainId() external view returns (uint256);
    function rootPortAddress() external view returns (address);
    function localBranchPortAddress() external view returns (address);
    function factoryAddress() external view returns (address);
    function getTokenBalance(uint256 chainId) external view returns (uint256);
    function mint(address to, uint256 amount, uint256 chainId) external returns (bool);
    function burn(address from, uint256 value, uint256 chainId) external;
    error UnrecognizedPort();
}
interface WETH9 {
    function withdraw(uint256 wad) external;
    function deposit() external payable;
    function balanceOf(address guy) external view returns (uint256 wad);
    function transfer(address dst, uint256 wad) external;
}
library AnycallFlags {
    uint256 public constant FLAG_NONE = 0x0;
    uint256 public constant FLAG_MERGE_CONFIG_FLAGS = 0x1;
    uint256 public constant FLAG_PAY_FEE_ON_DEST = 0x1 << 1;
    uint256 public constant FLAG_ALLOW_FALLBACK = 0x1 << 2;
    uint256 public constant FLAG_ALLOW_FALLBACK_DST = 6;
    uint256 public constant FLAG_EXEC_START_VALUE = 0x1 << 16;
    uint256 public constant FLAG_EXEC_FALLBACK = 0x1 << 16;
}
struct UserFeeInfo_0 {
    uint256 depositedGas;
    uint256 feesOwed;
}
enum DepositStatus {
    Success,
    Failed
}
struct Deposit {
    uint128 depositedGas;
    address owner;
    DepositStatus status;
    address[] hTokens;
    address[] tokens;
    uint256[] amounts;
    uint256[] deposits;
}
struct DepositInput {
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
    uint24 toChain; 
}
struct DepositMultipleInput {
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
    uint24 toChain; 
}
struct DepositParams_0 {
    uint32 depositNonce; 
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
    uint24 toChain; 
    uint128 depositedGas; 
}
struct DepositMultipleParams_0 {
    uint8 numberOfAssets; 
    uint32 depositNonce; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
    uint24 toChain; 
    uint128 depositedGas; 
}
struct SettlementParams_0 {
    uint32 settlementNonce;
    address recipient;
    address hToken;
    address token;
    uint256 amount;
    uint256 deposit;
}
struct SettlementMultipleParams_0 {
    uint8 numberOfAssets; 
    address recipient;
    uint32 settlementNonce;
    address[] hTokens;
    address[] tokens;
    uint256[] amounts;
    uint256[] deposits;
}
interface IBranchBridgeAgent is IApp {
    function bridgeAgentExecutorAddress() external view returns (address);
    function getDepositEntry(uint32 _depositNonce) external view returns (Deposit memory);
    function callOut(bytes calldata params, uint128 remoteExecutionGas) external payable;
    function callOutAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable;
    function callOutAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable;
    function callOutSigned(bytes calldata params, uint128 remoteExecutionGas) external payable;
    function callOutSignedAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable;
    function callOutSignedAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable;
    function retryDeposit(
        bool _isSigned,
        uint32 _depositNonce,
        bytes calldata _params,
        uint128 _remoteExecutionGas,
        uint24 _toChain
    ) external payable;
    function retrySettlement(uint32 _settlementNonce, uint128 _gasToBoostSettlement) external payable;
    function retrieveDeposit(uint32 _depositNonce) external payable;
    function redeemDeposit(uint32 _depositNonce) external;
    function clearToken(address _recipient, address _hToken, address _token, uint256 _amount, uint256 _deposit)
        external;
    function clearTokens(bytes calldata _sParams, address _recipient)
        external
        returns (SettlementMultipleParams_0 memory);
    function performSystemCallOut(
        address depositor,
        bytes memory params,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;
    function performCallOut(address depositor, bytes memory params, uint128 gasToBridgeOut, uint128 remoteExecutionGas)
        external
        payable;
    function performCallOutAndBridge(
        address depositor,
        bytes calldata params,
        DepositInput memory dParams,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;
    function performCallOutAndBridgeMultiple(
        address depositor,
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;
    function forceRevert() external;
    function depositGasAnycallConfig() external payable;
    event LogCallin(bytes1 selector, bytes data, uint256 fromChainId);
    event LogCallout(bytes1 selector, bytes data, uint256, uint256 toChainId);
    event LogCalloutFail(bytes1 selector, bytes data, uint256 toChainId);
    error AnycallUnauthorizedCaller();
    error AlreadyExecutedTransaction();
    error InvalidInput();
    error InvalidChain();
    error InsufficientGas();
    error NotDepositOwner();
    error DepositRedeemUnavailable();
    error UnrecognizedCallerNotRouter();
    error UnrecognizedBridgeAgentExecutor();
}
struct SwapCallbackData {
    address tokenIn; 
}
struct UserFeeInfo_1 {
    uint128 depositedGas; 
    uint128 gasToBridgeOut; 
}
struct GasPoolInfo_0 {
    bool zeroForOneOnInflow;
    uint24 priceImpactPercentage; 
    address poolAddress; 
}
enum SettlementStatus {
    Success, 
    Failed 
}
struct Settlement {
    uint24 toChain; 
    uint128 gasToBridgeOut; 
    address owner; 
    address recipient; 
    SettlementStatus status; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
    bytes callData; 
}
struct SettlementParams_1 {
    uint32 settlementNonce; 
    address recipient; 
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
}
struct SettlementMultipleParams_1 {
    uint8 numberOfAssets; 
    uint32 settlementNonce; 
    address recipient; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
}
struct DepositParams_1 {
    uint32 depositNonce; 
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
    uint24 toChain; 
}
struct DepositMultipleParams_1 {
    uint8 numberOfAssets; 
    uint32 depositNonce; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
    uint24 toChain; 
}
interface IRootBridgeAgent is IApp {
    function initialGas() external view returns (uint256);
    function userFeeInfo() external view returns (uint128, uint128);
    function bridgeAgentExecutorAddress() external view returns (address);
    function factoryAddress() external view returns (address);
    function getBranchBridgeAgent(uint256 _chainId) external view returns (address);
    function isBranchBridgeAgentAllowed(uint256 _chainId) external view returns (bool);
    function callOut(address _recipient, bytes memory _calldata, uint24 _toChain) external payable;
    function callOutAndBridge(
        address _owner,
        address _recipient,
        bytes memory _data,
        address _globalAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) external payable;
    function callOutAndBridgeMultiple(
        address _owner,
        address _recipient,
        bytes memory _data,
        address[] memory _globalAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        uint24 _toChain
    ) external payable;
    function bridgeIn(address _recipient, DepositParams_1 memory _dParams, uint24 _fromChain) external;
    function bridgeInMultiple(address _recipient, DepositMultipleParams_1 memory _dParams, uint24 _fromChain) external;
    function settlementNonce() external view returns (uint32 nonce);
    function redeemSettlement(uint32 _depositNonce) external;
    function retrySettlement(uint32 _settlementNonce, uint128 _remoteExecutionGas) external payable;
    function getSettlementEntry(uint32 _settlementNonce) external view returns (Settlement memory);
    function syncBranchBridgeAgent(address _newBranchBridgeAgent, uint24 _branchChainId) external;
    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata _data) external;
    function forceRevert() external;
    function depositGasAnycallConfig() external payable;
    function sweep() external;
    function approveBranchBridgeAgent(uint256 _branchChainId) external;
    event LogCallin(bytes1 selector, bytes data, uint24 fromChainId);
    event LogCallout(bytes1 selector, bytes data, uint256, uint24 toChainId);
    event LogCalloutFail(bytes1 selector, bytes data, uint24 toChainId);
    error GasErrorOrRepeatedTx();
    error NotDao();
    error AnycallUnauthorizedCaller();
    error AlreadyAddedBridgeAgent();
    error UnrecognizedExecutor();
    error UnrecognizedPort();
    error UnrecognizedBridgeAgent();
    error UnrecognizedBridgeAgentManager();
    error UnrecognizedCallerNotRouter();
    error UnrecognizedUnderlyingAddress();
    error UnrecognizedLocalAddress();
    error UnrecognizedGlobalAddress();
    error UnrecognizedAddressInDestination();
    error SettlementRedeemUnavailable();
    error NotSettlementOwner();
    error InsufficientBalanceForSettlement();
    error InsufficientGasForFees();
    error InvalidInputParams();
    error InvalidGasPool();
    error CallerIsNotPool();
    error AmountsAreZero();
}
struct Call {
    address target;
    bytes callData;
}
interface IVirtualAccount is IERC721Receiver {
    function userAddress() external view returns (address);
    function localPortAddress() external view returns (address);
    function withdrawERC20(address _token, uint256 _amount) external;
    function withdrawERC721(address _token, uint256 _tokenId) external;
    function call(Call[] calldata callInput) external returns (uint256 blockNumber, bytes[] memory);
    error CallFailed();
    error UnauthorizedCaller();
}
interface IRootRouter {
    function anyExecuteResponse(bytes1 funcId, bytes memory encodedData, uint24 fromChainId)
        external
        payable
        returns (bool success, bytes memory result);
    function anyExecute(bytes1 funcId, bytes memory encodedData, uint24 fromChainId)
        external
        payable
        returns (bool success, bytes memory result);
    function anyExecuteDepositSingle(
        bytes1 funcId,
        bytes memory encodedData,
        DepositParams_1 memory dParams,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);
    function anyExecuteDepositMultiple(
        bytes1 funcId,
        bytes memory encodedData,
        DepositMultipleParams_1 memory dParams,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);
    function anyExecuteSigned(bytes1 funcId, bytes memory encodedData, address userAccount, uint24 fromChainId)
        external
        payable
        returns (bool success, bytes memory result);
    function anyExecuteSignedDepositSingle(
        bytes1 funcId,
        bytes memory encodedData,
        DepositParams_1 memory dParams,
        address userAccount,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);
    function anyExecuteSignedDepositMultiple(
        bytes1 funcId,
        bytes memory encodedData,
        DepositMultipleParams_1 memory dParams,
        address userAccount,
        uint24 fromChainId
    ) external payable returns (bool success, bytes memory result);
    error UnrecognizedBridgeAgentExecutor();
}
contract VirtualAccount is IVirtualAccount {
    using SafeTransferLib for address;
    address public immutable userAddress;
    address public localPortAddress;
    constructor(address _userAddress, address _localPortAddress) {
        userAddress = _userAddress;
        localPortAddress = _localPortAddress;
    }
    function withdrawERC20(address _token, uint256 _amount) external requiresApprovedCaller {
        _token.safeTransfer(msg.sender, _amount);
    }
    function withdrawERC721(address _token, uint256 _tokenId) external requiresApprovedCaller {
        ERC721(_token).transferFrom(address(this), msg.sender, _tokenId);
    }
    function call(Call[] calldata calls)
        external
        requiresApprovedCaller
        returns (uint256 blockNumber, bytes[] memory returnData)
    {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        for (uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory data) = calls[i].target.call(calls[i].callData);
            if (!success) revert CallFailed();
            returnData[i] = data;
        }
    }
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    modifier requiresApprovedCaller() {
        if ((!IRootPort(localPortAddress).isRouterApproved(this, msg.sender)) && (msg.sender != userAddress)) {
            revert UnauthorizedCaller();
        }
        _;
    }
}
interface ICoreRootRouter {
    function bridgeAgentAddress() external view returns (address);
    function hTokenFactoryAddress() external view returns (address);
}
struct GasPoolInfo_1 {
    bool zeroForOneOnInflow;
    uint24 priceImpactPercentage;
    address gasTokenGlobalAddress;
    address poolAddress;
}
interface IRootPort {
    function getBridgeAgentManager(address _rootBridgeAgent) external view returns (address);
    function isChainId(uint256 _chainId) external view returns (bool);
    function isBridgeAgentFactory(address _bridgeAgentFactory) external view returns (bool);
    function isGlobalAddress(address _globalAddress) external view returns (bool);
    function isRouterApproved(VirtualAccount _userAccount, address _router) external returns (bool);
    function getGlobalTokenFromLocal(address _localAddress, uint256 _fromChain) external view returns (address);
    function getLocalTokenFromGlobal(address _globalAddress, uint256 _fromChain) external view returns (address);
    function getLocalTokenFromUnder(address _underlyingAddress, uint256 _fromChain) external view returns (address);
    function getLocalToken(address _localAddress, uint24 _fromChain, uint24 _toChain) external view returns (address);
    function getUnderlyingTokenFromLocal(address _localAddress, uint256 _fromChain) external view returns (address);
    function getUnderlyingTokenFromGlobal(address _globalAddress, uint24 _fromChain) external view returns (address);
    function isGlobalToken(address _globalAddress, uint24 _fromChain) external view returns (bool);
    function isLocalToken(address _localAddress, uint24 _fromChain) external view returns (bool);
    function isLocalToken(address _localAddress, uint24 _fromChain, uint24 _toChain) external view returns (bool);
    function isUnderlyingToken(address _underlyingToken, uint24 _fromChain) external view returns (bool);
    function getWrappedNativeToken(uint256 _chainId) external view returns (address);
    function getGasPoolInfo(uint256 _chainId)
        external
        view
        returns (
            bool zeroForOneOnInflow,
            uint24 priceImpactPercentage,
            address gasTokenGlobalAddress,
            address poolAddress
        );
    function getUserAccount(address _user) external view returns (VirtualAccount);
    function burn(address _from, address _hToken, uint256 _amount, uint24 _fromChain) external;
    function bridgeToRoot(address _recipient, address _hToken, uint256 _amount, uint256 _deposit, uint24 _fromChainId)
        external;
    function bridgeToRootFromLocalBranch(address _from, address _hToken, uint256 _amount) external;
    function bridgeToLocalBranchFromRoot(address _to, address _hToken, uint256 _amount) external;
    function mintToLocalBranch(address _recipient, address _hToken, uint256 _amount) external;
    function burnFromLocalBranch(address _from, address _hToken, uint256 _amount) external;
    function setAddresses(address _globalAddress, address _localAddress, address _underlyingAddress, uint24 _fromChain)
        external;
    function setLocalAddress(address _globalAddress, address _localAddress, uint24 _fromChain) external;
    function fetchVirtualAccount(address _user) external returns (VirtualAccount account);
    function toggleVirtualAccountApproved(VirtualAccount _userAccount, address _router) external;
    function syncBranchBridgeAgentWithRoot(address _newBranchBridgeAgent, address _rootBridgeAgent, uint24 _fromChain)
        external;
    function addBridgeAgent(address _manager, address _bridgeAgent) external;
    function toggleBridgeAgent(address _bridgeAgent) external;
    function addBridgeAgentFactory(address _bridgeAgentFactory) external;
    function toggleBridgeAgentFactory(address _bridgeAgentFactory) external;
    function addNewChain(
        address _pledger,
        uint256 _pledgedInitialAmount,
        address _coreBranchBridgeAgentAddress,
        uint24 _chainId,
        string memory _wrappedGasTokenName,
        string memory _wrappedGasTokenSymbol,
        uint24 _fee,
        uint24 _priceImpactPercentage,
        uint160 _sqrtPriceX96,
        address _nonFungiblePositionManagerAddress,
        address _newLocalBranchWrappedNativeTokenAddress,
        address _newUnderlyingBranchWrappedNativeTokenAddress
    ) external;
    function setGasPoolInfo(uint24 _chainId, GasPoolInfo_1 calldata _gasPoolInfo) external;
    function addEcosystemToken(address ecoTokenGlobalAddress) external;
    event BridgeAgentFactoryAdded(address indexed bridgeAgentFactory);
    event BridgeAgentFactoryToggled(address indexed bridgeAgentFactory);
    event BridgeAgentAdded(address indexed bridgeAgent, address manager);
    event BridgeAgentToggled(address indexed bridgeAgent);
    event BridgeAgentSynced(address indexed bridgeAgent, address indexed rootBridgeAgent, uint24 indexed fromChain);
    event NewChainAdded(uint24 indexed chainId);
    event GasPoolInfoSet(uint24 indexed chainId, GasPoolInfo_1 gasPoolInfo);
    event VirtualAccountCreated(address indexed user, address account);
    event LocalTokenAdded(
        address indexed underlyingAddress, address localAddress, address globalAddress, uint24 chainId
    );
    event GlobalTokenAdded(address indexed localAddress, address indexed globalAddress, uint24 chainId);
    event EcosystemTokenAdded(address indexed ecoTokenGlobalAddress);
    error UnrecognizedBridgeAgentFactory();
    error UnrecognizedBridgeAgent();
    error UnrecognizedToken();
    error AlreadyAddedEcosystemToken();
    error AlreadyAddedBridgeAgent();
    error BridgeAgentNotAllowed();
    error UnrecognizedCoreRootRouter();
    error UnrecognizedLocalBranchPort();
    error UnknowHTokenFactory();
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
library DeployRootBridgeAgentExecutor {
    function deploy(address _owner) external returns (address) {
        return address(new RootBridgeAgentExecutor(_owner));
    }
}
contract RootBridgeAgentExecutor is Ownable {
    uint8 internal constant PARAMS_START = 1;
    uint8 internal constant PARAMS_START_SIGNED = 21;
    uint8 internal constant PARAMS_END_OFFSET = 9;
    uint8 internal constant PARAMS_END_SIGNED_OFFSET = 29;
    uint8 internal constant PARAMS_ENTRY_SIZE = 32;
    uint8 internal constant PARAMS_ADDRESS_SIZE = 20;
    uint8 internal constant PARAMS_TKN_SET_SIZE = 104;
    uint8 internal constant PARAMS_TKN_SET_SIZE_MULTIPLE = 128;
    uint8 internal constant PARAMS_GAS_IN = 32;
    uint8 internal constant PARAMS_GAS_OUT = 16;
    uint8 internal constant PARAMS_TKN_START = 5;
    uint8 internal constant PARAMS_AMT_OFFSET = 64;
    uint8 internal constant PARAMS_DEPOSIT_OFFSET = 96;
    constructor(address owner) {
        _initializeOwner(owner);
    }
    function executeSystemRequest(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        (success, result) = IRootRouter(_router).anyExecuteResponse(
            bytes1(_data[PARAMS_TKN_START]), _data[6:_data.length - PARAMS_GAS_IN], _fromChainId
        );
    }
    function executeNoDeposit(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        (success, result) =
            IRootRouter(_router).anyExecute(bytes1(_data[5]), _data[6:_data.length - PARAMS_GAS_IN], _fromChainId);
    }
    function executeWithDeposit(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        DepositParams_1 memory dParams = DepositParams_1({
            depositNonce: uint32(bytes4(_data[PARAMS_START:PARAMS_TKN_START])),
            hToken: address(uint160(bytes20(_data[PARAMS_TKN_START:25]))),
            token: address(uint160(bytes20(_data[25:45]))),
            amount: uint256(bytes32(_data[45:77])),
            deposit: uint256(bytes32(_data[77:109])),
            toChain: uint24(bytes3(_data[109:112]))
        });
        _bridgeIn(_router, dParams, _fromChainId);
        if (_data.length - PARAMS_GAS_IN > 112) {
            (success, result) = IRootRouter(_router).anyExecuteDepositSingle(
                _data[112], _data[113:_data.length - PARAMS_GAS_IN], dParams, _fromChainId
            );
        } else {
            success = true;
        }
    }
    function executeWithDepositMultiple(address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        DepositMultipleParams_1 memory dParams = _bridgeInMultiple(
            _router,
            _data[
                PARAMS_START:
                    PARAMS_END_OFFSET + uint16(uint8(bytes1(_data[PARAMS_START]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
            ],
            _fromChainId
        );
        uint8 numOfAssets = uint8(bytes1(_data[PARAMS_START]));
        uint256 length = _data.length;
        if (
            length - PARAMS_GAS_IN
                > PARAMS_END_OFFSET + uint16(uint8(bytes1(_data[PARAMS_START]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
        ) {
            (success, result) = IRootRouter(_router).anyExecuteDepositMultiple(
                bytes1(_data[PARAMS_END_OFFSET + uint16(numOfAssets) * PARAMS_TKN_SET_SIZE_MULTIPLE]),
                _data[
                    PARAMS_START + PARAMS_END_OFFSET + uint16(numOfAssets) * PARAMS_TKN_SET_SIZE_MULTIPLE:
                        length - PARAMS_GAS_IN
                ],
                dParams,
                _fromChainId
            );
        } else {
            success = true;
        }
    }
    function executeSignedNoDeposit(address _account, address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        (success, result) =
            IRootRouter(_router).anyExecuteSigned(_data[25], _data[26:_data.length - PARAMS_GAS_IN], _account, _fromChainId);
    }
    function executeSignedWithDeposit(address _account, address _router, bytes calldata _data, uint24 _fromChainId)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        DepositParams_1 memory dParams = DepositParams_1({
            depositNonce: uint32(bytes4(_data[PARAMS_START_SIGNED:25])),
            hToken: address(uint160(bytes20(_data[25:45]))),
            token: address(uint160(bytes20(_data[45:65]))),
            amount: uint256(bytes32(_data[65:97])),
            deposit: uint256(bytes32(_data[97:129])),
            toChain: uint24(bytes3(_data[129:132]))
        });
        _bridgeIn(_account, dParams, _fromChainId);
        if (_data.length - PARAMS_GAS_IN > 132) {
            (success, result) = IRootRouter(_router).anyExecuteSignedDepositSingle(
                _data[132], _data[133:_data.length - PARAMS_GAS_IN], dParams, _account, _fromChainId
            );
        } else {
            success = true;
        }
    }
    function executeSignedWithDepositMultiple(
        address _account,
        address _router,
        bytes calldata _data,
        uint24 _fromChainId
    ) external onlyOwner returns (bool success, bytes memory result) {
        DepositMultipleParams_1 memory dParams = _bridgeInMultiple(
            _account,
            _data[
                PARAMS_START_SIGNED:
                    PARAMS_END_SIGNED_OFFSET
                        + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
            ],
            _fromChainId
        );
        {
            if (
                _data.length - PARAMS_GAS_IN
                    > PARAMS_END_SIGNED_OFFSET
                        + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE
            ) {
                (success, result) = IRootRouter(_router).anyExecuteSignedDepositMultiple(
                    _data[PARAMS_END_SIGNED_OFFSET
                        + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE],
                    _data[
                        PARAMS_START + PARAMS_END_SIGNED_OFFSET
                            + uint16(uint8(bytes1(_data[PARAMS_START_SIGNED]))) * PARAMS_TKN_SET_SIZE_MULTIPLE:
                            _data.length - PARAMS_GAS_IN
                    ],
                    dParams,
                    _account,
                    _fromChainId
                );
            } else {
                success = true;
            }
        }
    }
    function executeRetrySettlement(uint32 _settlementNonce)
        external
        onlyOwner
        returns (bool success, bytes memory result)
    {
        RootBridgeAgent(payable(msg.sender)).retrySettlement(_settlementNonce, 0);
        (success, result) = (true, "");
    }
    function _bridgeIn(address _recipient, DepositParams_1 memory _dParams, uint24 _fromChain) internal {
        RootBridgeAgent(payable(msg.sender)).bridgeIn(_recipient, _dParams, _fromChain);
    }
    function _bridgeInMultiple(address _recipient, bytes calldata _dParams, uint24 _fromChain)
        internal
        returns (DepositMultipleParams_1 memory dParams)
    {
        uint8 numOfAssets = uint8(bytes1(_dParams[0]));
        uint32 nonce = uint32(bytes4(_dParams[PARAMS_START:5]));
        uint24 toChain = uint24(bytes3(_dParams[_dParams.length - 3:_dParams.length]));
        address[] memory hTokens = new address[](numOfAssets);
        address[] memory tokens = new address[](numOfAssets);
        uint256[] memory amounts = new uint256[](numOfAssets);
        uint256[] memory deposits = new uint256[](numOfAssets);
        for (uint256 i = 0; i < uint256(uint8(numOfAssets));) {
            hTokens[i] = address(
                uint160(
                    bytes20(
                        bytes32(
                            _dParams[
                                PARAMS_TKN_START + (PARAMS_ENTRY_SIZE * i) + 12:
                                    PARAMS_TKN_START + (PARAMS_ENTRY_SIZE * (PARAMS_START + i))
                            ]
                        )
                    )
                )
            );
            tokens[i] = address(
                uint160(
                    bytes20(
                        _dParams[
                            PARAMS_TKN_START + PARAMS_ENTRY_SIZE * uint16(i + numOfAssets) + 12:
                                PARAMS_TKN_START + PARAMS_ENTRY_SIZE * uint16(PARAMS_START + i + numOfAssets)
                        ]
                    )
                )
            );
            amounts[i] = uint256(
                bytes32(
                    _dParams[
                        PARAMS_TKN_START + PARAMS_AMT_OFFSET * uint16(numOfAssets) + (PARAMS_ENTRY_SIZE * uint16(i)):
                            PARAMS_TKN_START + PARAMS_AMT_OFFSET * uint16(numOfAssets)
                                + PARAMS_ENTRY_SIZE * uint16(PARAMS_START + i)
                    ]
                )
            );
            deposits[i] = uint256(
                bytes32(
                    _dParams[
                        PARAMS_TKN_START + PARAMS_DEPOSIT_OFFSET * uint16(numOfAssets) + (PARAMS_ENTRY_SIZE * uint16(i)):
                            PARAMS_TKN_START + PARAMS_DEPOSIT_OFFSET * uint16(numOfAssets)
                                + PARAMS_ENTRY_SIZE * uint16(PARAMS_START + i)
                    ]
                )
            );
            unchecked {
                ++i;
            }
        }
        dParams = DepositMultipleParams_1({
            numberOfAssets: numOfAssets,
            depositNonce: nonce,
            hTokens: hTokens,
            tokens: tokens,
            amounts: amounts,
            deposits: deposits,
            toChain: toChain
        });
        RootBridgeAgent(payable(msg.sender)).bridgeInMultiple(_recipient, dParams, _fromChain);
    }
}
library CheckParamsLib {
    function checkParams(address _localPortAddress, DepositParams_1 memory _dParams, uint24 _fromChain)
        internal
        view
        returns (bool)
    {
        if (
            (_dParams.amount < _dParams.deposit) 
                || (_dParams.amount > 0 && !IRootPort(_localPortAddress).isLocalToken(_dParams.hToken, _fromChain)) 
                || (_dParams.deposit > 0 && !IRootPort(_localPortAddress).isUnderlyingToken(_dParams.token, _fromChain)) 
        ) {
            return false;
        }
        return true;
    }
}
library DeployRootBridgeAgent {
    function deploy(
        WETH9 _wrappedNativeToken,
        uint24 _localChainId,
        address _daoAddress,
        address _localAnyCallAddress,
        address _localAnyCallExecutorAddress,
        address _localPortAddress,
        address _localRouterAddress
    ) external returns (RootBridgeAgent) {
        return new RootBridgeAgent(
            _wrappedNativeToken,
            _localChainId,
            _daoAddress,
            _localAnyCallAddress,
            _localAnyCallExecutorAddress,
            _localPortAddress,
            _localRouterAddress
        );
    }
}
contract RootBridgeAgent is IRootBridgeAgent {
    using SafeTransferLib for address;
    using SafeCastLib for uint256;
    uint8 internal constant PARAMS_START = 1;
    uint8 internal constant PARAMS_START_SIGNED = 21;
    uint8 internal constant PARAMS_ADDRESS_SIZE = 20;
    uint8 internal constant PARAMS_GAS_IN = 32;
    uint8 internal constant PARAMS_GAS_OUT = 16;
    uint8 internal constant PARAMS_TKN_START = 5;
    uint8 internal constant PARAMS_AMT_OFFSET = 64;
    uint8 internal constant PARAMS_DEPOSIT_OFFSET = 96;
    uint24 public immutable localChainId;
    WETH9 public immutable wrappedNativeToken;
    address public immutable factoryAddress;
    address public immutable daoAddress;
    address public immutable localRouterAddress;
    address public immutable localPortAddress;
    address public immutable localAnyCallAddress;
    address public immutable localAnyCallExecutorAddress;
    address public immutable bridgeAgentExecutorAddress;
    mapping(uint256 => address) public getBranchBridgeAgent;
    mapping(uint256 => bool) public isBranchBridgeAgentAllowed;
    uint32 public settlementNonce;
    mapping(uint32 => Settlement) public getSettlement;
    mapping(uint256 => mapping(uint32 => bool)) public executionHistory;
    uint256 internal constant MIN_FALLBACK_RESERVE = 155_000; 
    uint256 internal constant MIN_EXECUTION_OVERHEAD = 155_000; 
    uint256 public initialGas;
    UserFeeInfo_1 public userFeeInfo;
    uint256 public accumulatedFees;
    constructor(
        WETH9 _wrappedNativeToken,
        uint24 _localChainId,
        address _daoAddress,
        address _localAnyCallAddress,
        address _localAnyCallExecutorAddress,
        address _localPortAddress,
        address _localRouterAddress
    ) {
        require(address(_wrappedNativeToken) != address(0), "Wrapped native token cannot be zero address");
        require(_daoAddress != address(0), "DAO cannot be zero address");
        require(_localAnyCallAddress != address(0), "Anycall Address cannot be zero address");
        require(_localAnyCallExecutorAddress != address(0), "Anycall Executor Address cannot be zero address");
        require(_localPortAddress != address(0), "Port Address cannot be zero address");
        require(_localRouterAddress != address(0), "Router Address cannot be zero address");
        wrappedNativeToken = _wrappedNativeToken;
        factoryAddress = msg.sender;
        daoAddress = _daoAddress;
        localChainId = _localChainId;
        localAnyCallAddress = _localAnyCallAddress;
        localPortAddress = _localPortAddress;
        localRouterAddress = _localRouterAddress;
        bridgeAgentExecutorAddress = DeployRootBridgeAgentExecutor.deploy(address(this));
        localAnyCallExecutorAddress = _localAnyCallExecutorAddress;
        settlementNonce = 1;
        accumulatedFees = 1; 
    }
    function getSettlementEntry(uint32 _settlementNonce) external view returns (Settlement memory) {
        return getSettlement[_settlementNonce];
    }
    function retrySettlement(uint32 _settlementNonce, uint128 _remoteExecutionGas) external payable {
        if (initialGas == 0) {
            userFeeInfo.depositedGas = uint128(msg.value);
            userFeeInfo.gasToBridgeOut = _remoteExecutionGas;
        }
        _retrySettlement(_settlementNonce);
    }
    function redeemSettlement(uint32 _depositNonce) external lock {
        address depositOwner = getSettlement[_depositNonce].owner;
        if (getSettlement[_depositNonce].status != SettlementStatus.Failed || depositOwner == address(0)) {
            revert SettlementRedeemUnavailable();
        } else if (
            msg.sender != depositOwner && msg.sender != address(IRootPort(localPortAddress).getUserAccount(depositOwner))
        ) {
            revert NotSettlementOwner();
        }
        _redeemSettlement(_depositNonce);
    }
    function callOut(address _recipient, bytes memory _data, uint24 _toChain) external payable lock requiresRouter {
        bytes memory data =
            abi.encodePacked(bytes1(0x00), _recipient, settlementNonce++, _data, _manageGasOut(_toChain));
        _performCall(data, _toChain);
    }
    function callOutAndBridge(
        address _owner,
        address _recipient,
        bytes memory _data,
        address _globalAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) external payable lock requiresRouter {
        address localAddress = IRootPort(localPortAddress).getLocalTokenFromGlobal(_globalAddress, _toChain);
        address underlyingAddress = IRootPort(localPortAddress).getUnderlyingTokenFromLocal(localAddress, _toChain);
        if (localAddress == address(0) || (underlyingAddress == address(0) && _deposit > 0)) {
            revert InvalidInputParams();
        }
        bytes memory data = abi.encodePacked(
            bytes1(0x01),
            _recipient,
            settlementNonce,
            localAddress,
            underlyingAddress,
            _amount,
            _deposit,
            _data,
            _manageGasOut(_toChain)
        );
        _updateStateOnBridgeOut(
            msg.sender, _globalAddress, localAddress, underlyingAddress, _amount, _deposit, _toChain
        );
        _createSettlement(_owner, _recipient, localAddress, underlyingAddress, _amount, _deposit, data, _toChain);
        _performCall(data, _toChain);
    }
    function callOutAndBridgeMultiple(
        address _owner,
        address _recipient,
        bytes memory _data,
        address[] memory _globalAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        uint24 _toChain
    ) external payable lock requiresRouter {
        address[] memory hTokens = new address[](_globalAddresses.length);
        address[] memory tokens = new address[](_globalAddresses.length);
        for (uint256 i = 0; i < _globalAddresses.length;) {
            hTokens[i] = IRootPort(localPortAddress).getLocalTokenFromGlobal(_globalAddresses[i], _toChain);
            tokens[i] = IRootPort(localPortAddress).getUnderlyingTokenFromLocal(hTokens[i], _toChain);
            if (hTokens[i] == address(0) || (tokens[i] == address(0) && _deposits[i] > 0)) revert InvalidInputParams();
            _updateStateOnBridgeOut(
                msg.sender, _globalAddresses[i], hTokens[i], tokens[i], _amounts[i], _deposits[i], _toChain
            );
            unchecked {
                ++i;
            }
        }
        bytes memory data = abi.encodePacked(
            bytes1(0x02),
            _recipient,
            uint8(hTokens.length),
            settlementNonce,
            hTokens,
            tokens,
            _amounts,
            _deposits,
            _data,
            _manageGasOut(_toChain)
        );
        _createMultipleSettlement(_owner, _recipient, hTokens, tokens, _amounts, _deposits, data, _toChain);
        _performCall(data, _toChain);
    }
    function bridgeIn(address _recipient, DepositParams_1 memory _dParams, uint24 _fromChain)
        public
        requiresAgentExecutor
    {
        if (!CheckParamsLib.checkParams(localPortAddress, _dParams, _fromChain)) {
            revert InvalidInputParams();
        }
        address globalAddress = IRootPort(localPortAddress).getGlobalTokenFromLocal(_dParams.hToken, _fromChain);
        if (globalAddress == address(0)) revert InvalidInputParams();
        IRootPort(localPortAddress).bridgeToRoot(_recipient, globalAddress, _dParams.amount, _dParams.deposit, _fromChain);
    }
    function bridgeInMultiple(address _recipient, DepositMultipleParams_1 memory _dParams, uint24 _fromChain)
        external
        requiresAgentExecutor
    {
        for (uint256 i = 0; i < _dParams.hTokens.length;) {
            bridgeIn(
                _recipient,
                DepositParams_1({
                    hToken: _dParams.hTokens[i],
                    token: _dParams.tokens[i],
                    amount: _dParams.amounts[i],
                    deposit: _dParams.deposits[i],
                    toChain: _dParams.toChain,
                    depositNonce: 0
                }),
                _fromChain
            );
            unchecked {
                ++i;
            }
        }
    }
    function _updateStateOnBridgeOut(
        address _sender,
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _amount,
        uint256 _deposit,
        uint24 _toChain
    ) internal {
        if (_amount - _deposit > 0) {
            if (_localAddress == address(0)) revert UnrecognizedLocalAddress();
            _globalAddress.safeTransferFrom(_sender, localPortAddress, _amount - _deposit);
        }
        if (_deposit > 0) {
            if (_underlyingAddress == address(0)) revert UnrecognizedUnderlyingAddress();
            if (IERC20hTokenRoot(_globalAddress).getTokenBalance(_toChain) < _deposit) {
                revert InsufficientBalanceForSettlement();
            }
            IRootPort(localPortAddress).burn(_sender, _globalAddress, _deposit, _toChain);
        }
    }
    function _createSettlement(
        address _owner,
        address _recipient,
        address _hToken,
        address _token,
        uint256 _amount,
        uint256 _deposit,
        bytes memory _callData,
        uint24 _toChain
    ) internal {
        address[] memory hTokens = new address[](1);
        hTokens[0] = _hToken;
        address[] memory tokens = new address[](1);
        tokens[0] = _token;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = _amount;
        uint256[] memory deposits = new uint256[](1);
        deposits[0] = _deposit;
        _createMultipleSettlement(_owner, _recipient, hTokens, tokens, amounts, deposits, _callData, _toChain);
    }
    function _createMultipleSettlement(
        address _owner,
        address _recipient,
        address[] memory _hTokens,
        address[] memory _tokens,
        uint256[] memory _amounts,
        uint256[] memory _deposits,
        bytes memory _callData,
        uint24 _toChain
    ) internal {
        getSettlement[_getAndIncrementSettlementNonce()] = Settlement({
            owner: _owner,
            recipient: _recipient,
            hTokens: _hTokens,
            tokens: _tokens,
            amounts: _amounts,
            deposits: _deposits,
            callData: _callData,
            toChain: _toChain,
            status: SettlementStatus.Success,
            gasToBridgeOut: userFeeInfo.gasToBridgeOut
        });
    }
    function _retrySettlement(uint32 _settlementNonce) internal returns (bool) {
        Settlement memory settlement = getSettlement[_settlementNonce];
        if (settlement.owner == address(0)) return false;
        bytes memory newGas = abi.encodePacked(_manageGasOut(settlement.toChain));
        for (uint256 i = 0; i < newGas.length;) {
            settlement.callData[settlement.callData.length - 16 + i] = newGas[i];
            unchecked {
                ++i;
            }
        }
        Settlement storage settlementReference = getSettlement[_settlementNonce];
        settlementReference.gasToBridgeOut = userFeeInfo.gasToBridgeOut;
        settlementReference.callData = settlement.callData;
        settlementReference.status = SettlementStatus.Success;
        _performCall(settlement.callData, settlement.toChain);
        return true;
    }
    function _redeemSettlement(uint32 _settlementNonce) internal {
        Settlement storage settlement = getSettlement[_settlementNonce];
        for (uint256 i = 0; i < settlement.hTokens.length;) {
            if (settlement.hTokens[i] != address(0)) {
                IRootPort(localPortAddress).bridgeToRoot(
                    msg.sender,
                    IRootPort(localPortAddress).getGlobalTokenFromLocal(settlement.hTokens[i], settlement.toChain),
                    settlement.amounts[i],
                    settlement.deposits[i],
                    settlement.toChain
                );
            }
            unchecked {
                ++i;
            }
        }
        delete getSettlement[_settlementNonce];
    }
    function _reopenSettlemment(uint32 _settlementNonce) internal {
        getSettlement[_settlementNonce].status = SettlementStatus.Failed;
    }
    function _getAndIncrementSettlementNonce() internal returns (uint32) {
        return settlementNonce++;
    }
    uint24 private constant GLOBAL_DIVISIONER = 1e6; 
    mapping(address => bool) private approvedGasPool;
    function uniswapV3SwapCallback(int256 amount0, int256 amount1, bytes calldata _data) external {
        if (!approvedGasPool[msg.sender]) revert CallerIsNotPool();
        if (amount0 == 0 && amount1 == 0) revert AmountsAreZero();
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        address(data.tokenIn).safeTransfer(msg.sender, uint256(amount0 > 0 ? amount0 : amount1));
    }
    function _gasSwapIn(uint256 _amount, uint24 _fromChain) internal returns (uint256) {
        (bool zeroForOneOnInflow, uint24 priceImpactPercentage, address gasTokenGlobalAddress, address poolAddress) =
            IRootPort(localPortAddress).getGasPoolInfo(_fromChain);
        if (gasTokenGlobalAddress == address(0) || poolAddress == address(0)) revert InvalidGasPool();
        IRootPort(localPortAddress).bridgeToRoot(address(this), gasTokenGlobalAddress, _amount, _amount, _fromChain);
        if (!approvedGasPool[poolAddress]) approvedGasPool[poolAddress] = true;
        (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(poolAddress).slot0();
        uint160 exactSqrtPriceImpact = (sqrtPriceX96 * (priceImpactPercentage / 2)) / GLOBAL_DIVISIONER;
        uint160 sqrtPriceLimitX96 =
            zeroForOneOnInflow ? sqrtPriceX96 - exactSqrtPriceImpact : sqrtPriceX96 + exactSqrtPriceImpact;
        try IUniswapV3Pool(poolAddress).swap(
            address(this),
            zeroForOneOnInflow,
            int256(_amount),
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({tokenIn: gasTokenGlobalAddress}))
        ) returns (int256 amount0, int256 amount1) {
            return uint256(zeroForOneOnInflow ? amount1 : amount0);
        } catch (bytes memory) {
            _forceRevert();
            return 0;
        }
    }
    function _gasSwapOut(uint256 _amount, uint24 _toChain) internal returns (uint256, address) {
        (bool zeroForOneOnInflow, uint24 priceImpactPercentage, address gasTokenGlobalAddress, address poolAddress) =
            IRootPort(localPortAddress).getGasPoolInfo(_toChain);
        if (gasTokenGlobalAddress == address(0) || poolAddress == address(0)) revert InvalidGasPool();
        if (!approvedGasPool[poolAddress]) approvedGasPool[poolAddress] = true;
        uint160 sqrtPriceLimitX96;
        {
            (uint160 sqrtPriceX96,,,,,,) = IUniswapV3Pool(poolAddress).slot0();
            uint160 exactSqrtPriceImpact = (sqrtPriceX96 * (priceImpactPercentage / 2)) / GLOBAL_DIVISIONER;
            sqrtPriceLimitX96 =
                zeroForOneOnInflow ? sqrtPriceX96 + exactSqrtPriceImpact : sqrtPriceX96 - exactSqrtPriceImpact;
        }
        (int256 amount0, int256 amount1) = IUniswapV3Pool(poolAddress).swap(
            address(this),
            !zeroForOneOnInflow,
            int256(_amount),
            sqrtPriceLimitX96,
            abi.encode(SwapCallbackData({tokenIn: address(wrappedNativeToken)}))
        );
        return (uint256(!zeroForOneOnInflow ? amount1 : amount0), gasTokenGlobalAddress);
    }
    function _manageGasOut(uint24 _toChain) internal returns (uint128) {
        uint256 amountOut;
        address gasToken;
        uint256 _initialGas = initialGas;
        if (_toChain == localChainId) {
            if (_initialGas > 0) {
                address(wrappedNativeToken).safeTransfer(getBranchBridgeAgent[localChainId], userFeeInfo.gasToBridgeOut);
            }
            return uint128(userFeeInfo.gasToBridgeOut);
        }
        if (_initialGas > 0) {
            if (userFeeInfo.gasToBridgeOut <= MIN_FALLBACK_RESERVE * tx.gasprice) revert InsufficientGasForFees();
            (amountOut, gasToken) = _gasSwapOut(userFeeInfo.gasToBridgeOut, _toChain);
        } else {
            if (msg.value <= MIN_FALLBACK_RESERVE * tx.gasprice) revert InsufficientGasForFees();
            wrappedNativeToken.deposit{value: msg.value}();
            (amountOut, gasToken) = _gasSwapOut(msg.value, _toChain);
        }
        IRootPort(localPortAddress).burn(address(this), gasToken, amountOut, _toChain);
        return amountOut.toUint128();
    }
    function _performCall(bytes memory _calldata, uint256 _toChain) internal {
        address callee = getBranchBridgeAgent[_toChain];
        if (callee == address(0)) revert UnrecognizedBridgeAgent();
        if (_toChain != localChainId) {
            IAnycallProxy(localAnyCallAddress).anyCall(
                callee, _calldata, _toChain, AnycallFlags.FLAG_ALLOW_FALLBACK_DST, ""
            );
        } else {
            IBranchBridgeAgent(callee).anyExecute(_calldata);
        }
    }
    function _payExecutionGas(uint128 _depositedGas, uint128 _gasToBridgeOut, uint256 _initialGas, uint24 _fromChain)
        internal
    {
        delete(initialGas);
        delete(userFeeInfo);
        if (_fromChain == localChainId) return;
        uint256 availableGas = _depositedGas - _gasToBridgeOut;
        uint256 minExecCost = tx.gasprice * (MIN_EXECUTION_OVERHEAD + _initialGas - gasleft());
        if (minExecCost > availableGas) {
            _forceRevert();
            return;
        }
        _replenishGas(minExecCost);
        accumulatedFees += availableGas - minExecCost;
    }
    function _payFallbackGas(uint32 _settlementNonce, uint256 _initialGas) internal virtual {
        uint256 gasLeft = gasleft();
        uint256 minExecCost = tx.gasprice * (MIN_FALLBACK_RESERVE + _initialGas - gasLeft);
        if (minExecCost > getSettlement[_settlementNonce].gasToBridgeOut) {
            _forceRevert();
            return;
        }
        getSettlement[_settlementNonce].gasToBridgeOut -= minExecCost.toUint128();
    }
    function _replenishGas(uint256 _executionGasSpent) internal {
        wrappedNativeToken.withdraw(_executionGasSpent);
        IAnycallConfig(IAnycallProxy(localAnyCallAddress).config()).deposit{value: _executionGasSpent}(address(this));
    }
    function _getContext() internal view returns (address from, uint256 fromChainId) {
        (from, fromChainId,) = IAnycallExecutor(localAnyCallExecutorAddress).context();
    }
    function anyExecute(bytes calldata data)
        external
        virtual
        requiresExecutor
        returns (bool success, bytes memory result)
    {
        uint256 _initialGas = gasleft();
        uint24 fromChainId;
        UserFeeInfo_1 memory _userFeeInfo;
        if (localAnyCallExecutorAddress == msg.sender) {
            initialGas = _initialGas;
            (, uint256 _fromChainId) = _getContext();
            fromChainId = _fromChainId.toUint24();
            _userFeeInfo.depositedGas = _gasSwapIn(
                uint256(uint128(bytes16(data[data.length - PARAMS_GAS_IN:data.length - PARAMS_GAS_OUT]))), fromChainId
            ).toUint128();
            _userFeeInfo.gasToBridgeOut = uint128(bytes16(data[data.length - PARAMS_GAS_OUT:data.length]));
        } else {
            fromChainId = localChainId;
            _userFeeInfo.depositedGas = uint128(bytes16(data[data.length - 32:data.length - 16]));
            _userFeeInfo.gasToBridgeOut = _userFeeInfo.depositedGas;
        }
        if (_userFeeInfo.depositedGas < _userFeeInfo.gasToBridgeOut) {
            _forceRevert();
            return (true, "Not enough gas to bridge out");
        }
        userFeeInfo = _userFeeInfo;
        bytes1 flag = data[0];
        if (flag == 0x00) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSystemRequest(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                (success, result) = (false, reason);
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x01) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeNoDeposit(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                (success, result) = (true, reason);
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x02) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START:PARAMS_TKN_START]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeWithDeposit(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x03) {
            uint32 nonce = uint32(bytes4(data[2:6]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeWithDepositMultiple(
                localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x04) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            VirtualAccount userAccount = IRootPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedNoDeposit(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                (success, result) = (true, reason);
            }
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x05) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            VirtualAccount userAccount = IRootPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedWithDeposit(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x06) {
            uint32 nonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            VirtualAccount userAccount = IRootPort(localPortAddress).fetchVirtualAccount(
                address(uint160(bytes20(data[PARAMS_START:PARAMS_START_SIGNED])))
            );
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeSignedWithDepositMultiple(
                address(userAccount), localRouterAddress, data, fromChainId
            ) returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            IRootPort(localPortAddress).toggleVirtualAccountApproved(userAccount, localRouterAddress);
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x07) {
            uint32 nonce = uint32(bytes4(data[1:5]));
            if (executionHistory[fromChainId][nonce]) {
                _forceRevert();
                return (true, "already executed tx");
            }
            try RootBridgeAgentExecutor(bridgeAgentExecutorAddress).executeRetrySettlement(uint32(bytes4(data[5:9])))
            returns (bool, bytes memory res) {
                (success, result) = (true, res);
            } catch (bytes memory reason) {
                result = reason;
            }
            executionHistory[fromChainId][nonce] = true;
        } else if (flag == 0x08) {
            uint32 nonce = uint32(bytes4(data[1:5]));
            if (!executionHistory[fromChainId][uint32(bytes4(data[1:5]))]) {
                executionHistory[fromChainId][nonce] = true;
                (success, result) = (false, "");
            } else {
                _forceRevert();
                return (true, "already executed tx");
            }
        } else {
            if (initialGas > 0) {
                _payExecutionGas(userFeeInfo.depositedGas, userFeeInfo.gasToBridgeOut, _initialGas, fromChainId);
            }
            return (false, "unknown selector");
        }
        emit LogCallin(flag, data, fromChainId);
        if (initialGas > 0) {
            _payExecutionGas(userFeeInfo.depositedGas, userFeeInfo.gasToBridgeOut, _initialGas, fromChainId);
        }
    }
    function anyFallback(bytes calldata data)
        external
        virtual
        requiresExecutor
        returns (bool success, bytes memory result)
    {
        uint256 _initialGas = gasleft();
        (, uint256 _fromChainId) = _getContext();
        uint24 fromChainId = _fromChainId.toUint24();
        bytes1 flag = data[0];
        uint32 _settlementNonce;
        if (flag == 0x00) {
            _settlementNonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            _reopenSettlemment(_settlementNonce);
        } else if (flag == 0x01) {
            _settlementNonce = uint32(bytes4(data[PARAMS_START_SIGNED:25]));
            _reopenSettlemment(_settlementNonce);
        } else if (flag == 0x02) {
            _settlementNonce = uint32(bytes4(data[22:26]));
            _reopenSettlemment(_settlementNonce);
        }
        emit LogCalloutFail(flag, data, fromChainId);
        _payFallbackGas(_settlementNonce, _initialGas);
        return (true, "");
    }
    function depositGasAnycallConfig() external payable {
        _replenishGas(msg.value);
    }
    function forceRevert() external requiresLocalBranchBridgeAgent {
        _forceRevert();
    }
    function _forceRevert() internal {
        if (initialGas == 0) revert GasErrorOrRepeatedTx();
        IAnycallConfig anycallConfig = IAnycallConfig(IAnycallProxy(localAnyCallAddress).config());
        uint256 executionBudget = anycallConfig.executionBudget(address(this));
        if (executionBudget > 0) try anycallConfig.withdraw(executionBudget) {} catch {}
    }
    function approveBranchBridgeAgent(uint256 _branchChainId) external requiresManager {
        if (getBranchBridgeAgent[_branchChainId] != address(0)) revert AlreadyAddedBridgeAgent();
        isBranchBridgeAgentAllowed[_branchChainId] = true;
    }
    function syncBranchBridgeAgent(address _newBranchBridgeAgent, uint24 _branchChainId) external requiresPort {
        getBranchBridgeAgent[_branchChainId] = _newBranchBridgeAgent;
    }
    function sweep() external {
        if (msg.sender != daoAddress) revert NotDao();
        uint256 _accumulatedFees = accumulatedFees - 1;
        accumulatedFees = 1;
        SafeTransferLib.safeTransferETH(daoAddress, _accumulatedFees);
    }
    uint256 internal _unlocked = 1;
    modifier lock() {
        require(_unlocked == 1);
        _unlocked = 2;
        _;
        _unlocked = 1;
    }
    modifier requiresExecutor() {
        _requiresExecutor();
        _;
    }
    function _requiresExecutor() internal view {
        if (msg.sender == getBranchBridgeAgent[localChainId]) return;
        if (msg.sender != localAnyCallExecutorAddress) revert AnycallUnauthorizedCaller();
        (address from, uint256 fromChainId,) = IAnycallExecutor(localAnyCallExecutorAddress).context();
        if (getBranchBridgeAgent[fromChainId] != from) revert AnycallUnauthorizedCaller();
    }
    modifier requiresRouter() {
        _requiresRouter();
        _;
    }
    function _requiresRouter() internal view {
        if (msg.sender != localRouterAddress) revert UnrecognizedCallerNotRouter();
    }
    modifier requiresAgentExecutor() {
        if (msg.sender != bridgeAgentExecutorAddress) revert UnrecognizedExecutor();
        _;
    }
    modifier requiresLocalBranchBridgeAgent() {
        if (msg.sender != getBranchBridgeAgent[localChainId]) {
            revert UnrecognizedExecutor();
        }
        _;
    }
    modifier requiresPort() {
        if (msg.sender != localPortAddress) revert UnrecognizedPort();
        _;
    }
    modifier requiresManager() {
        if (msg.sender != IRootPort(localPortAddress).getBridgeAgentManager(address(this))) {
            revert UnrecognizedBridgeAgentManager();
        }
        _;
    }
    fallback() external payable {}
}