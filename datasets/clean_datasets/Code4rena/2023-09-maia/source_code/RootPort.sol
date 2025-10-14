pragma solidity ^0.8.19;
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
    function _ownershipHandoverValidFor() internal view virtual returns (uint64) {
        return 48 * 3600;
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
            uint256 expires = block.timestamp + _ownershipHandoverValidFor();
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
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}
library SafeTransferLib {
    error ETHTransferFailed();
    error TransferFromFailed();
    error TransferFailed();
    error ApproveFailed();
    uint256 internal constant GAS_STIPEND_NO_STORAGE_WRITES = 2300;
    uint256 internal constant GAS_STIPEND_NO_GRIEF = 100000;
    function safeTransferETH(address to, uint256 amount) internal {
        assembly {
            if iszero(call(gas(), to, amount, gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, 0xb12d13eb) 
                revert(0x1c, 0x04)
            }
        }
    }
    function safeTransferAllETH(address to) internal {
        assembly {
            if iszero(call(gas(), to, selfbalance(), gas(), 0x00, gas(), 0x00)) {
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
            if iszero(call(gasStipend, to, amount, gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) 
                }
            }
        }
    }
    function forceSafeTransferAllETH(address to, uint256 gasStipend) internal {
        assembly {
            if iszero(call(gasStipend, to, selfbalance(), gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(selfbalance(), 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) 
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
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, amount, gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) 
                }
            }
        }
    }
    function forceSafeTransferAllETH(address to) internal {
        assembly {
            if iszero(call(GAS_STIPEND_NO_GRIEF, to, selfbalance(), gas(), 0x00, gas(), 0x00)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(selfbalance(), 0x0b, 0x16)) {
                    returndatacopy(gas(), returndatasize(), shr(20, gas())) 
                }
            }
        }
    }
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        assembly {
            success := call(gasStipend, to, amount, gas(), 0x00, gas(), 0x00)
        }
    }
    function trySafeTransferAllETH(address to, uint256 gasStipend)
        internal
        returns (bool success)
    {
        assembly {
            success := call(gasStipend, to, selfbalance(), gas(), 0x00, gas(), 0x00)
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
    function safeApproveWithRetry(address token, address to, uint256 amount) internal {
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
                mstore(0x34, 0) 
                mstore(0x00, 0x095ea7b3000000000000000000000000) 
                pop(call(gas(), token, 0, 0x10, 0x44, 0x00, 0x00)) 
                mstore(0x34, amount) 
                if iszero(
                    and(
                        or(eq(mload(0x00), 1), iszero(returndatasize())), 
                        call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x3e3f8f73) 
                    revert(0x1c, 0x04)
                }
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
struct GasParams {
    uint256 gasLimit; 
    uint256 remoteBranchExecutionGas; 
}
struct Deposit {
    uint8 status;
    address owner;
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
}
struct DepositMultipleInput {
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
}
struct DepositMultipleParams {
    uint8 numberOfAssets; 
    uint32 depositNonce; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
}
struct DepositParams {
    uint32 depositNonce; 
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
}
struct Settlement {
    uint16 dstChainId; 
    uint80 status; 
    address owner; 
    address recipient; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
}
struct SettlementInput {
    address globalAddress; 
    uint256 amount; 
    uint256 deposit; 
}
struct SettlementMultipleInput {
    address[] globalAddresses; 
    uint256[] amounts; 
    uint256[] deposits; 
}
struct SettlementParams {
    uint32 settlementNonce; 
    address recipient; 
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
}
struct SettlementMultipleParams {
    uint8 numberOfAssets; 
    address recipient; 
    uint32 settlementNonce; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
}
interface IERC20hTokenRoot {
    function localChainId() external view returns (uint16);
    function factoryAddress() external view returns (address);
    function getTokenBalance(uint256 chainId) external view returns (uint256);
    function mint(address to, uint256 amount, uint256 chainId) external returns (bool);
    function burn(address from, uint256 amount, uint256 chainId) external;
    error UnrecognizedPort();
}
interface ILayerZeroReceiver {
    function lzReceive(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload) external;
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
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
struct Call {
    address target;
    bytes callData;
}
struct PayableCall {
    address target;
    bytes callData;
    uint256 value;
}
interface IVirtualAccount is IERC721Receiver {
    function userAddress() external view returns (address);
    function localPortAddress() external view returns (address);
    function withdrawNative(uint256 _amount) external;
    function withdrawERC20(address _token, uint256 _amount) external;
    function withdrawERC721(address _token, uint256 _tokenId) external;
    function call(Call[] calldata callInput) external returns (bytes[] memory);
    function payableCall(PayableCall[] calldata calls) external payable returns (bytes[] memory);
    error CallFailed();
    error UnauthorizedCaller();
}
interface IRootBridgeAgent is ILayerZeroReceiver {
    function settlementNonce() external view returns (uint32 nonce);
    function getSettlementEntry(uint32 _settlementNonce) external view returns (Settlement memory);
    function bridgeAgentExecutorAddress() external view returns (address);
    function factoryAddress() external view returns (address);
    function getBranchBridgeAgent(uint256 _chainId) external view returns (address);
    function isBranchBridgeAgentAllowed(uint256 _chainId) external view returns (bool);
    function getFeeEstimate(
        uint256 _gasLimit,
        uint256 _remoteBranchExecutionGas,
        bytes calldata _payload,
        uint16 _dstChainId
    ) external view returns (uint256 _fee);
    function callOut(
        address payable _refundee,
        address _recipient,
        uint16 _dstChainId,
        bytes memory _params,
        GasParams calldata _gParams
    ) external payable;
    function callOutAndBridge(
        address payable _refundee,
        address _recipient,
        uint16 _dstChainId,
        bytes calldata _params,
        SettlementInput calldata _sParams,
        GasParams calldata _gParams,
        bool _hasFallbackToggled
    ) external payable;
    function callOutAndBridgeMultiple(
        address payable _refundee,
        address _recipient,
        uint16 _dstChainId,
        bytes calldata _params,
        SettlementMultipleInput calldata _sParams,
        GasParams calldata _gParams,
        bool _hasFallbackToggled
    ) external payable;
    function retrySettlement(
        uint32 _settlementNonce,
        address _recipient,
        bytes calldata _params,
        GasParams calldata _gParams,
        bool _hasFallbackToggled
    ) external payable;
    function retrieveSettlement(uint32 _settlementNonce, GasParams calldata _gParams) external payable;
    function redeemSettlement(uint32 _depositNonce) external;
    function bridgeIn(address _recipient, DepositParams memory _dParams, uint256 _srcChainId) external;
    function bridgeInMultiple(address _recipient, DepositMultipleParams calldata _dParams, uint256 _srcChainId)
        external;
    function lzReceiveNonBlocking(
        address _endpoint,
        uint16 _srcChainId,
        bytes calldata _srcAddress,
        bytes calldata _payload
    ) external;
    function approveBranchBridgeAgent(uint256 _branchChainId) external;
    function syncBranchBridgeAgent(address _newBranchBridgeAgent, uint256 _branchChainId) external;
    event LogExecute(uint256 indexed depositNonce, uint256 indexed srcChainId);
    event LogFallback(uint256 indexed settlementNonce, uint256 indexed dstChainId);
    error ExecutionFailure();
    error GasErrorOrRepeatedTx();
    error AlreadyExecutedTransaction();
    error UnknownFlag();
    error NotDao();
    error LayerZeroUnauthorizedEndpoint();
    error LayerZeroUnauthorizedCaller();
    error AlreadyAddedBridgeAgent();
    error UnrecognizedExecutor();
    error UnrecognizedPort();
    error UnrecognizedBridgeAgent();
    error UnrecognizedLocalBridgeAgent();
    error UnrecognizedBridgeAgentManager();
    error UnrecognizedRouter();
    error UnrecognizedUnderlyingAddress();
    error UnrecognizedLocalAddress();
    error SettlementRetryUnavailable();
    error SettlementRetryUnavailableUseCallout();
    error SettlementRedeemUnavailable();
    error SettlementRetrieveUnavailable();
    error NotSettlementOwner();
    error InsufficientBalanceForSettlement();
    error InsufficientGasForFees();
    error InvalidInputParams();
    error InvalidInputParamsLength();
    error CallerIsNotPool();
    error AmountsAreZero();
}
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
contract ERC20hTokenRoot is ERC20, Ownable, IERC20hTokenRoot {
    uint16 public immutable override localChainId;
    address public immutable override factoryAddress;
    mapping(uint256 chainId => uint256 balance) public override getTokenBalance;
    constructor(
        uint16 _localChainId,
        address _factoryAddress,
        address _rootPortAddress,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) ERC20(string(string.concat(_name)), string(string.concat(_symbol)), _decimals) {
        require(_rootPortAddress != address(0), "Root Port Address cannot be 0");
        require(_factoryAddress != address(0), "Factory Address cannot be 0");
        localChainId = _localChainId;
        factoryAddress = _factoryAddress;
        _initializeOwner(_rootPortAddress);
    }
    function mint(address to, uint256 amount, uint256 chainId) external onlyOwner returns (bool) {
        getTokenBalance[chainId] += amount;
        _mint(to, amount);
        return true;
    }
    function burn(address from, uint256 amount, uint256 chainId) external onlyOwner {
        getTokenBalance[chainId] -= amount;
        _burn(from, amount);
    }
}
interface IERC20hTokenRootFactory {
    function createToken(string memory _name, string memory _symbol, uint8 _decimals)
        external
        returns (ERC20hTokenRoot newToken);
    error UnrecognizedCoreRouterOrPort();
}
contract VirtualAccount is IVirtualAccount, ERC1155Receiver {
    using SafeTransferLib for address;
    address public immutable override userAddress;
    address public immutable override localPortAddress;
    constructor(address _userAddress, address _localPortAddress) {
        userAddress = _userAddress;
        localPortAddress = _localPortAddress;
    }
    receive() external payable {}
    function withdrawNative(uint256 _amount) external override requiresApprovedCaller {
        msg.sender.safeTransferETH(_amount);
    }
    function withdrawERC20(address _token, uint256 _amount) external override requiresApprovedCaller {
        _token.safeTransfer(msg.sender, _amount);
    }
    function withdrawERC721(address _token, uint256 _tokenId) external override requiresApprovedCaller {
        ERC721(_token).transferFrom(address(this), msg.sender, _tokenId);
    }
    function call(Call[] calldata calls) external override requiresApprovedCaller returns (bytes[] memory returnData) {
        uint256 length = calls.length;
        returnData = new bytes[](length);
        for (uint256 i = 0; i < length;) {
            bool success;
            Call calldata _call = calls[i];
            if (isContract(_call.target)) (success, returnData[i]) = _call.target.call(_call.callData);
            if (!success) revert CallFailed();
            unchecked {
                ++i;
            }
        }
    }
    function payableCall(PayableCall[] calldata calls) public payable returns (bytes[] memory returnData) {
        uint256 valAccumulator;
        uint256 length = calls.length;
        returnData = new bytes[](length);
        PayableCall calldata _call;
        for (uint256 i = 0; i < length;) {
            _call = calls[i];
            uint256 val = _call.value;
            unchecked {
                valAccumulator += val;
            }
            bool success;
            if (isContract(_call.target)) (success, returnData[i]) = _call.target.call{value: val}(_call.callData);
            if (!success) revert CallFailed();
            unchecked {
                ++i;
            }
        }
        if (msg.value != valAccumulator) revert CallFailed();
    }
    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return this.onERC1155BatchReceived.selector;
    }
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    modifier requiresApprovedCaller() {
        if (!IRootPort(localPortAddress).isRouterApproved(this, msg.sender)) {
            if (msg.sender != userAddress) {
                revert UnauthorizedCaller();
            }
        }
        _;
    }
}
interface ICoreRootRouter {
    function bridgeAgentAddress() external view returns (address);
    function hTokenFactoryAddress() external view returns (address);
    function setCoreBranch(
        address _refundee,
        address _coreBranchRouter,
        address _coreBranchBridgeAgent,
        uint16 _dstChainId,
        GasParams calldata _gParams
    ) external payable;
}
interface IRootPort {
    function isChainId(uint256 _chainId) external view returns (bool);
    function getBridgeAgentManager(address _rootBridgeAgent) external view returns (address);
    function isBridgeAgentFactory(address _bridgeAgentFactory) external view returns (bool);
    function isGlobalAddress(address _globalAddress) external view returns (bool);
    function getGlobalTokenFromLocal(address _localAddress, uint256 _srcChainId) external view returns (address);
    function getLocalTokenFromGlobal(address _globalAddress, uint256 _srcChainId) external view returns (address);
    function getLocalTokenFromUnderlying(address _underlyingAddress, uint256 _srcChainId)
        external
        view
        returns (address);
    function getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        returns (address);
    function getUnderlyingTokenFromLocal(address _localAddress, uint256 _srcChainId) external view returns (address);
    function getUnderlyingTokenFromGlobal(address _globalAddress, uint256 _srcChainId)
        external
        view
        returns (address);
    function isGlobalToken(address _globalAddress, uint256 _srcChainId) external view returns (bool);
    function isLocalToken(address _localAddress, uint256 _srcChainId) external view returns (bool);
    function isLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        returns (bool);
    function isUnderlyingToken(address _underlyingToken, uint256 _srcChainId) external view returns (bool);
    function getUserAccount(address _user) external view returns (VirtualAccount);
    function isRouterApproved(VirtualAccount _userAccount, address _router) external returns (bool);
    function burn(address _from, address _hToken, uint256 _amount, uint256 _srcChainId) external;
    function bridgeToRoot(address _recipient, address _hToken, uint256 _amount, uint256 _deposit, uint256 _srcChainId)
        external;
    function bridgeToRootFromLocalBranch(address _from, address _hToken, uint256 _amount) external;
    function bridgeToLocalBranchFromRoot(address _to, address _hToken, uint256 _amount) external;
    function mintToLocalBranch(address _recipient, address _hToken, uint256 _amount) external;
    function burnFromLocalBranch(address _from, address _hToken, uint256 _amount) external;
    function setAddresses(
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _srcChainId
    ) external;
    function setLocalAddress(address _globalAddress, address _localAddress, uint256 _srcChainId) external;
    function fetchVirtualAccount(address _user) external returns (VirtualAccount account);
    function toggleVirtualAccountApproved(VirtualAccount _userAccount, address _router) external;
    function syncBranchBridgeAgentWithRoot(address _newBranchBridgeAgent, address _rootBridgeAgent, uint256 _srcChainId)
        external;
    function addBridgeAgent(address _manager, address _bridgeAgent) external;
    function toggleBridgeAgent(address _bridgeAgent) external;
    function addBridgeAgentFactory(address _bridgeAgentFactory) external;
    function toggleBridgeAgentFactory(address _bridgeAgentFactory) external;
    function addNewChain(
        address _coreBranchBridgeAgentAddress,
        uint256 _chainId,
        string memory _wrappedGasTokenName,
        string memory _wrappedGasTokenSymbol,
        uint8 _wrappedGasTokenDecimals,
        address _newLocalBranchWrappedNativeTokenAddress,
        address _newUnderlyingBranchWrappedNativeTokenAddress
    ) external;
    function addEcosystemToken(address ecoTokenGlobalAddress) external;
    function setCoreRootRouter(address _coreRootRouter, address _coreRootBridgeAgent) external;
    function setCoreBranchRouter(
        address _refundee,
        address _coreBranchRouter,
        address _coreBranchBridgeAgent,
        uint16 _dstChainId,
        GasParams calldata _gParams
    ) external payable;
    function syncNewCoreBranchRouter(address _coreBranchRouter, address _coreBranchBridgeAgent, uint16 _dstChainId)
        external;
    event BridgeAgentFactoryAdded(address indexed bridgeAgentFactory);
    event BridgeAgentFactoryToggled(address indexed bridgeAgentFactory);
    event BridgeAgentAdded(address indexed bridgeAgent, address indexed manager);
    event BridgeAgentToggled(address indexed bridgeAgent);
    event BridgeAgentSynced(address indexed bridgeAgent, address indexed rootBridgeAgent, uint256 indexed srcChainId);
    event NewChainAdded(uint256 indexed chainId);
    event VirtualAccountCreated(address indexed user, address account);
    event LocalTokenAdded(
        address indexed underlyingAddress, address indexed localAddress, address indexed globalAddress, uint256 chainId
    );
    event GlobalTokenAdded(address indexed localAddress, address indexed globalAddress, uint256 indexed chainId);
    event EcosystemTokenAdded(address indexed ecoTokenGlobalAddress);
    event CoreRootSet(address indexed coreRootRouter, address indexed coreRootBridgeAgent);
    event CoreBranchSet(
        address indexed coreBranchRouter, address indexed coreBranchBridgeAgent, uint16 indexed dstChainId
    );
    event CoreBranchSynced(
        address indexed coreBranchRouter, address indexed coreBranchBridgeAgent, uint16 indexed dstChainId
    );
    error InvalidGlobalAddress();
    error InvalidLocalAddress();
    error InvalidUnderlyingAddress();
    error InvalidUserAddress();
    error InvalidCoreRootRouter();
    error InvalidCoreRootBridgeAgent();
    error InvalidCoreBranchRouter();
    error InvalidCoreBrancBridgeAgent();
    error UnrecognizedBridgeAgentFactory();
    error UnrecognizedBridgeAgent();
    error UnrecognizedToken();
    error UnableToMint();
    error AlreadyAddedChain();
    error AlreadyAddedEcosystemToken();
    error AlreadyAddedBridgeAgent();
    error AlreadyAddedBridgeAgentFactory();
    error BridgeAgentNotAllowed();
    error UnrecognizedCoreRootRouter();
    error UnrecognizedLocalBranchPort();
}
contract RootPort is Ownable, IRootPort {
    using SafeTransferLib for address;
    bool internal _setup;
    bool internal _setupCore;
    uint256 public immutable localChainId;
    address public localBranchPortAddress;
    address public coreRootRouterAddress;
    address public coreRootBridgeAgentAddress;
    mapping(address user => VirtualAccount account) public getUserAccount;
    mapping(VirtualAccount acount => mapping(address router => bool allowed)) public isRouterApproved;
    mapping(uint256 chainId => bool isActive) public isChainId;
    mapping(address bridgeAgent => bool isActive) public isBridgeAgent;
    address[] public bridgeAgents;
    mapping(address bridgeAgent => address bridgeAgentManager) public getBridgeAgentManager;
    mapping(address bridgeAgentFactory => bool isActive) public isBridgeAgentFactory;
    address[] public bridgeAgentFactories;
    mapping(address token => bool isGlobalToken) public isGlobalAddress;
    mapping(address chainId => mapping(uint256 localAddress => address globalAddress)) public getGlobalTokenFromLocal;
    mapping(address chainId => mapping(uint256 globalAddress => address localAddress)) public getLocalTokenFromGlobal;
    mapping(address chainId => mapping(uint256 underlyingAddress => address localAddress)) public
        getLocalTokenFromUnderlying;
    mapping(address chainId => mapping(uint256 localAddress => address underlyingAddress)) public
        getUnderlyingTokenFromLocal;
    constructor(uint256 _localChainId) {
        localChainId = _localChainId;
        isChainId[_localChainId] = true;
        _initializeOwner(msg.sender);
        _setup = true;
        _setupCore = true;
    }
    function initialize(address _bridgeAgentFactory, address _coreRootRouter) external onlyOwner {
        require(_bridgeAgentFactory != address(0), "Bridge Agent Factory cannot be 0 address.");
        require(_coreRootRouter != address(0), "Core Root Router cannot be 0 address.");
        require(_setup, "Setup ended.");
        _setup = false;
        isBridgeAgentFactory[_bridgeAgentFactory] = true;
        bridgeAgentFactories.push(_bridgeAgentFactory);
        coreRootRouterAddress = _coreRootRouter;
    }
    function initializeCore(
        address _coreRootBridgeAgent,
        address _coreLocalBranchBridgeAgent,
        address _localBranchPortAddress
    ) external onlyOwner {
        require(_coreRootBridgeAgent != address(0), "Core Root Bridge Agent cannot be 0 address.");
        require(_coreLocalBranchBridgeAgent != address(0), "Core Local Branch Bridge Agent cannot be 0 address.");
        require(_localBranchPortAddress != address(0), "Local Branch Port Address cannot be 0 address.");
        require(isBridgeAgent[_coreRootBridgeAgent], "Core Bridge Agent doesn't exist.");
        require(_setupCore, "Core Setup ended.");
        _setupCore = false;
        coreRootBridgeAgentAddress = _coreRootBridgeAgent;
        localBranchPortAddress = _localBranchPortAddress;
        IRootBridgeAgent(_coreRootBridgeAgent).syncBranchBridgeAgent(_coreLocalBranchBridgeAgent, localChainId);
        getBridgeAgentManager[_coreRootBridgeAgent] = owner();
    }
    function renounceOwnership() public payable override onlyOwner {
        revert("Cannot renounce ownership");
    }
    function getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        override
        returns (address)
    {
        return _getLocalToken(_localAddress, _srcChainId, _dstChainId);
    }
    function _getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        internal
        view
        returns (address)
    {
        address globalAddress = getGlobalTokenFromLocal[_localAddress][_srcChainId];
        return getLocalTokenFromGlobal[globalAddress][_dstChainId];
    }
    function getUnderlyingTokenFromGlobal(address _globalAddress, uint256 _srcChainId)
        external
        view
        override
        returns (address)
    {
        address localAddress = getLocalTokenFromGlobal[_globalAddress][_srcChainId];
        return getUnderlyingTokenFromLocal[localAddress][_srcChainId];
    }
    function isGlobalToken(address _globalAddress, uint256 _srcChainId) external view override returns (bool) {
        return getLocalTokenFromGlobal[_globalAddress][_srcChainId] != address(0);
    }
    function isLocalToken(address _localAddress, uint256 _srcChainId) external view override returns (bool) {
        return getGlobalTokenFromLocal[_localAddress][_srcChainId] != address(0);
    }
    function isLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        returns (bool)
    {
        return _getLocalToken(_localAddress, _srcChainId, _dstChainId) != address(0);
    }
    function isUnderlyingToken(address _underlyingToken, uint256 _srcChainId) external view override returns (bool) {
        return getLocalTokenFromUnderlying[_underlyingToken][_srcChainId] != address(0);
    }
    function setAddresses(
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _srcChainId
    ) external override requiresCoreRootRouter {
        if (_globalAddress == address(0)) revert InvalidGlobalAddress();
        if (_localAddress == address(0)) revert InvalidLocalAddress();
        if (_underlyingAddress == address(0)) revert InvalidUnderlyingAddress();
        isGlobalAddress[_globalAddress] = true;
        getGlobalTokenFromLocal[_localAddress][_srcChainId] = _globalAddress;
        getLocalTokenFromGlobal[_globalAddress][_srcChainId] = _localAddress;
        getLocalTokenFromUnderlying[_underlyingAddress][_srcChainId] = _localAddress;
        getUnderlyingTokenFromLocal[_localAddress][_srcChainId] = _underlyingAddress;
        emit LocalTokenAdded(_underlyingAddress, _localAddress, _globalAddress, _srcChainId);
    }
    function setLocalAddress(address _globalAddress, address _localAddress, uint256 _srcChainId)
        external
        override
        requiresCoreRootRouter
    {
        if (_localAddress == address(0)) revert InvalidLocalAddress();
        getGlobalTokenFromLocal[_localAddress][_srcChainId] = _globalAddress;
        getLocalTokenFromGlobal[_globalAddress][_srcChainId] = _localAddress;
        emit GlobalTokenAdded(_localAddress, _globalAddress, _srcChainId);
    }
    function bridgeToRoot(address _recipient, address _hToken, uint256 _amount, uint256 _deposit, uint256 _srcChainId)
        external
        override
        requiresBridgeAgent
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        if (_amount - _deposit > 0) {
            unchecked {
                _hToken.safeTransfer(_recipient, _amount - _deposit);
            }
        }
        if (_deposit > 0) if (!ERC20hTokenRoot(_hToken).mint(_recipient, _deposit, _srcChainId)) revert UnableToMint();
    }
    function bridgeToRootFromLocalBranch(address _from, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        _hToken.safeTransferFrom(_from, address(this), _amount);
    }
    function bridgeToLocalBranchFromRoot(address _to, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        _hToken.safeTransfer(_to, _amount);
    }
    function burn(address _from, address _hToken, uint256 _amount, uint256 _srcChainId)
        external
        override
        requiresBridgeAgent
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        ERC20hTokenRoot(_hToken).burn(_from, _amount, _srcChainId);
    }
    function burnFromLocalBranch(address _from, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        ERC20hTokenRoot(_hToken).burn(_from, _amount, localChainId);
    }
    function mintToLocalBranch(address _to, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        if (!ERC20hTokenRoot(_hToken).mint(_to, _amount, localChainId)) revert UnableToMint();
    }
    function fetchVirtualAccount(address _user) external override returns (VirtualAccount account) {
        account = getUserAccount[_user];
        if (address(account) == address(0)) account = addVirtualAccount(_user);
    }
    function addVirtualAccount(address _user) internal returns (VirtualAccount newAccount) {
        if (_user == address(0)) revert InvalidUserAddress();
        newAccount = new VirtualAccount{salt: keccak256(abi.encode(_user))}(_user, address(this));
        getUserAccount[_user] = newAccount;
        emit VirtualAccountCreated(_user, address(newAccount));
    }
    function toggleVirtualAccountApproved(VirtualAccount _userAccount, address _router)
        external
        override
        requiresBridgeAgent
    {
        isRouterApproved[_userAccount][_router] = !isRouterApproved[_userAccount][_router];
    }
    function addBridgeAgent(address _manager, address _bridgeAgent) external override requiresBridgeAgentFactory {
        if (isBridgeAgent[_bridgeAgent]) revert AlreadyAddedBridgeAgent();
        bridgeAgents.push(_bridgeAgent);
        getBridgeAgentManager[_bridgeAgent] = _manager;
        isBridgeAgent[_bridgeAgent] = true;
        emit BridgeAgentAdded(_bridgeAgent, _manager);
    }
    function syncBranchBridgeAgentWithRoot(
        address _newBranchBridgeAgent,
        address _rootBridgeAgent,
        uint256 _branchChainId
    ) external override requiresCoreRootRouter {
        if (IRootBridgeAgent(_rootBridgeAgent).getBranchBridgeAgent(_branchChainId) != address(0)) {
            revert AlreadyAddedBridgeAgent();
        }
        if (!IRootBridgeAgent(_rootBridgeAgent).isBranchBridgeAgentAllowed(_branchChainId)) {
            revert BridgeAgentNotAllowed();
        }
        IRootBridgeAgent(_rootBridgeAgent).syncBranchBridgeAgent(_newBranchBridgeAgent, _branchChainId);
        emit BridgeAgentSynced(_newBranchBridgeAgent, _rootBridgeAgent, _branchChainId);
    }
    function toggleBridgeAgent(address _bridgeAgent) external override onlyOwner {
        isBridgeAgent[_bridgeAgent] = !isBridgeAgent[_bridgeAgent];
        emit BridgeAgentToggled(_bridgeAgent);
    }
    function addBridgeAgentFactory(address _bridgeAgentFactory) external override onlyOwner {
        if (isBridgeAgentFactory[_bridgeAgentFactory]) revert AlreadyAddedBridgeAgentFactory();
        bridgeAgentFactories.push(_bridgeAgentFactory);
        isBridgeAgentFactory[_bridgeAgentFactory] = true;
        emit BridgeAgentFactoryAdded(_bridgeAgentFactory);
    }
    function toggleBridgeAgentFactory(address _bridgeAgentFactory) external override onlyOwner {
        isBridgeAgentFactory[_bridgeAgentFactory] = !isBridgeAgentFactory[_bridgeAgentFactory];
        emit BridgeAgentFactoryToggled(_bridgeAgentFactory);
    }
    function addNewChain(
        address _coreBranchBridgeAgentAddress,
        uint256 _chainId,
        string memory _wrappedGasTokenName,
        string memory _wrappedGasTokenSymbol,
        uint8 _wrappedGasTokenDecimals,
        address _newLocalBranchWrappedNativeTokenAddress,
        address _newUnderlyingBranchWrappedNativeTokenAddress
    ) external override onlyOwner {
        if (isChainId[_chainId]) revert AlreadyAddedChain();
        address newGlobalToken = address(
            IERC20hTokenRootFactory(ICoreRootRouter(coreRootRouterAddress).hTokenFactoryAddress()).createToken(
                _wrappedGasTokenName, _wrappedGasTokenSymbol, _wrappedGasTokenDecimals
            )
        );
        IRootBridgeAgent(ICoreRootRouter(coreRootRouterAddress).bridgeAgentAddress()).syncBranchBridgeAgent(
            _coreBranchBridgeAgentAddress, _chainId
        );
        isChainId[_chainId] = true;
        isGlobalAddress[newGlobalToken] = true;
        getGlobalTokenFromLocal[_newLocalBranchWrappedNativeTokenAddress][_chainId] = newGlobalToken;
        getLocalTokenFromGlobal[newGlobalToken][_chainId] = _newLocalBranchWrappedNativeTokenAddress;
        getLocalTokenFromUnderlying[_newUnderlyingBranchWrappedNativeTokenAddress][_chainId] =
            _newLocalBranchWrappedNativeTokenAddress;
        getUnderlyingTokenFromLocal[_newLocalBranchWrappedNativeTokenAddress][_chainId] =
            _newUnderlyingBranchWrappedNativeTokenAddress;
        emit NewChainAdded(_chainId);
    }
    function addEcosystemToken(address _ecoTokenGlobalAddress) external override onlyOwner {
        if (isGlobalAddress[_ecoTokenGlobalAddress]) revert AlreadyAddedEcosystemToken();
        if (getUnderlyingTokenFromLocal[_ecoTokenGlobalAddress][localChainId] != address(0)) {
            revert AlreadyAddedEcosystemToken();
        }
        if (getLocalTokenFromUnderlying[_ecoTokenGlobalAddress][localChainId] != address(0)) {
            revert AlreadyAddedEcosystemToken();
        }
        isGlobalAddress[_ecoTokenGlobalAddress] = true;
        getGlobalTokenFromLocal[_ecoTokenGlobalAddress][localChainId] = _ecoTokenGlobalAddress;
        getLocalTokenFromGlobal[_ecoTokenGlobalAddress][localChainId] = _ecoTokenGlobalAddress;
        emit EcosystemTokenAdded(_ecoTokenGlobalAddress);
    }
    function setCoreRootRouter(address _coreRootRouter, address _coreRootBridgeAgent) external override onlyOwner {
        if (_coreRootRouter == address(0)) revert InvalidCoreRootRouter();
        if (_coreRootBridgeAgent == address(0)) revert InvalidCoreRootBridgeAgent();
        coreRootRouterAddress = _coreRootRouter;
        coreRootBridgeAgentAddress = _coreRootBridgeAgent;
        getBridgeAgentManager[_coreRootBridgeAgent] = owner();
        emit CoreRootSet(_coreRootRouter, _coreRootBridgeAgent);
    }
    function setCoreBranchRouter(
        address _refundee,
        address _coreBranchRouter,
        address _coreBranchBridgeAgent,
        uint16 _dstChainId,
        GasParams calldata _gParams
    ) external payable override onlyOwner {
        if (_coreBranchRouter == address(0)) revert InvalidCoreBranchRouter();
        if (_coreBranchBridgeAgent == address(0)) revert InvalidCoreBrancBridgeAgent();
        ICoreRootRouter(coreRootRouterAddress).setCoreBranch{value: msg.value}(
            _refundee, _coreBranchRouter, _coreBranchBridgeAgent, _dstChainId, _gParams
        );
        emit CoreBranchSet(_coreBranchRouter, _coreBranchBridgeAgent, _dstChainId);
    }
    function syncNewCoreBranchRouter(address _coreBranchRouter, address _coreBranchBridgeAgent, uint16 _dstChainId)
        external
        override
        onlyOwner
    {
        if (_coreBranchRouter == address(0)) revert InvalidCoreBranchRouter();
        if (_coreBranchBridgeAgent == address(0)) revert InvalidCoreBrancBridgeAgent();
        IRootBridgeAgent(coreRootBridgeAgentAddress).syncBranchBridgeAgent(_coreBranchBridgeAgent, _dstChainId);
        emit CoreBranchSynced(_coreBranchRouter, _coreBranchBridgeAgent, _dstChainId);
    }
    modifier requiresBridgeAgentFactory() {
        if (!isBridgeAgentFactory[msg.sender]) revert UnrecognizedBridgeAgentFactory();
        _;
    }
    modifier requiresBridgeAgent() {
        if (!isBridgeAgent[msg.sender]) revert UnrecognizedBridgeAgent();
        _;
    }
    modifier requiresCoreRootRouter() {
        if (msg.sender != coreRootRouterAddress) revert UnrecognizedCoreRootRouter();
        _;
    }
    modifier requiresLocalBranchPort() {
        if (msg.sender != localBranchPortAddress) revert UnrecognizedLocalBranchPort();
        _;
    }
}