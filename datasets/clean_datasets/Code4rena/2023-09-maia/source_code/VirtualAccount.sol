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