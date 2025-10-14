pragma solidity 0.8.16;
interface IERC721Metadata  {
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;
    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256) external view returns (string memory);
}
interface IERC721TokenReceiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes calldata _data) external returns (bytes4);
}
interface ISeawaterEvents {
    event MintPosition(
        uint256 indexed id,
        address indexed owner,
        address indexed pool,
        int32 lower,
        int32 upper
    );
    event BurnPosition(
        uint256 indexed id,
        address indexed owner
    );
    event TransferPosition(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
    event UpdatePositionLiquidity(
        uint256 indexed id,
        int256 token0,
        int256 token1
    );
    event CollectFees(
        uint256 indexed id,
        address indexed pool,
        address indexed to,
        uint128 amount0,
        uint128 amount1
    );
    event NewPool(
        address indexed token,
        uint32 indexed fee,
        uint8 decimals,
        uint8 tickSpacing
    );
    event CollectProtocolFees(
        address indexed pool,
        address indexed to,
        uint128 amount0,
        uint128 amount1
    );
    event Swap2(
        address indexed user,
        address indexed from,
        address indexed to,
        uint256 amountIn,
        uint256 amountOut,
        uint256 fluidVolume,
        int32 finalTick0,
        int32 finalTick1
    );
    event Swap1(
        address indexed user,
        address indexed pool,
        bool zeroForOne,
        uint256 amount0,
        uint256 amount1,
        int32 finalTick
    );
}
interface ISeawaterExecutorSwap {
    function swap904369BE(
        address pool,
        bool zeroForOne,
        int256 amount,
        uint256 priceLimit
    ) external returns (int256, int256);
    function swap2ExactIn41203F1D(
        address from,
        address to,
        uint256 amount,
        uint256 minOut
    ) external returns (uint256, uint256);
}
interface ISeawaterExecutorSwapPermit2 {
    function swapPermit2EE84AD91(
        address pool,
        bool zeroForOne,
        int256 amount,
        uint256 priceLimit,
        uint256 nonce,
        uint256 deadline,
        uint256 maxAmount,
        bytes memory sig
    ) external returns (int256, int256);
    function swap2ExactInPermit236B2FDD8(
        address from,
        address to,
        uint256 amount,
        uint256 minOut,
        uint256 nonce,
        uint256 deadline,
        bytes memory sig
    ) external returns (uint256, uint256);
}
interface ISeawaterExecutorQuote {
    function quote72E2ADE7(
        address pool,
        bool zeroForOne,
        int256 amount,
        uint256 priceLimit
    ) external;
    function quote2CD06B86E(
        address from,
        address to,
        uint256 amount,
        uint256 minOut
    ) external;
}
interface ISeawaterExecutorPosition {
    struct CollectResult {
        uint128 amount0;
        uint128 amount1;
    }
    function mintPositionBC5B086D(
        address pool,
        int32 lower,
        int32 upper
    ) external returns (uint256 id);
    function burnPositionAE401070(uint256 id) external;
    function transferPositionEEC7A3CD(uint256 id, address from, address to) external;
    function positionOwnerD7878480(uint256 id) external returns (address);
    function positionBalance4F32C7DB(address user) external returns (uint256);
    function positionLiquidity8D11C045(address pool, uint256 id) external returns (uint128);
    function positionTickLower2F77CCE1(address pool, uint256 id) external returns (int32);
    function positionTickUpper67FD55BA(address pool, uint256 id) external returns (int32);
    function collectSingleTo6D76575F(
        address pool,
        uint256 id,
        address recipient
    ) external returns (uint128 amount0, uint128 amount1);
    function collect7F21947C(
        address[] memory pools,
        uint256[] memory ids
    ) external returns (CollectResult[] memory);
}
interface ISeawaterExecutorUpdatePosition {
    function updatePositionC7F1F740(
        address pool,
        uint256 id,
        int128 delta
    ) external returns (int256, int256);
    function incrPositionC3AC7CAA(
        address pool,
        uint256 id,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 amount0Desired,
        uint256 amount1Desired
    ) external returns (uint256, uint256);
    function decrPosition09293696(
        uint256 id,
        uint256 amount0Min,
        uint256 amount1Min,
        uint256 amount0Max,
        uint256 amount1Max
    ) external returns (uint256, uint256);
    function incrPositionPermit25468326E(
        address ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 ,
        uint256 ,
        bytes memory ,
        uint256 ,
        uint256 ,
        uint256 ,
        bytes memory 
    ) external returns (uint256, uint256);
}
interface ISeawaterExecutorAdminExposed {
    function createPoolD650E2D0(
        address pool,
        uint256 sqrtPriceX96,
        uint32 fee,
        uint8 tickSpacing,
        uint128 maxLiquidityPerTick
    ) external;
    function collectProtocol7540FA9F(
        address pool,
        uint128 amount0,
        uint128 amount1,
        address recipient
    ) external returns (uint128, uint128);
    function feesOwed22F28DBD(address pool, uint256 id) external returns (uint128, uint128);
    function sqrtPriceX967B8F5FC5(address pool) external returns (uint256);
    function curTick181C6FD9(address pool) external returns (int32);
    function tickSpacing653FE28F(address pool) external returns (uint8);
    function feeBB3CF608(address pool) external returns (uint32);
    function feeGrowthGlobal038B5665B(address pool) external returns (uint256);
    function feeGrowthGlobal1A33A5A1B(address pool) external returns (uint256);
    function enablePool579DA658(address pool, bool enabled) external;
    function authoriseEnabler5B17C274(address enabler, bool enabled) external;
    function setSqrtPriceFF4DB98C(address pool, uint256 price) external;
    function updateNftManager9BDF41F6(address manager) external;
    function updateEmergencyCouncil7D0C1C58(address newCouncil) external;
}
interface ISeawaterExecutorAdmin  is ISeawaterExecutorAdminExposed {
    function ctor(address seawaterAdmin, address nftManager, address emergencyCouncil) external;
}
interface ISeawaterExecutorFallback {}
interface ISeawaterAMM is
    ISeawaterEvents,
    ISeawaterExecutorSwap,
    ISeawaterExecutorSwapPermit2,
    ISeawaterExecutorQuote,
    ISeawaterExecutorPosition,
    ISeawaterExecutorUpdatePosition,
    ISeawaterExecutorAdminExposed
    {
    function swapIn32502CA71(
        address _token,
        uint256 _amount,
        uint256 _minOut
    ) external returns (int256, int256);
    function swapInPermit2CEAAB576(
        address _token,
        uint256 _amount,
        uint256 _minOut,
        uint256 _nonce,
        uint256 _deadline,
        uint256 _maxAmount,
        bytes memory _sig
    ) external returns (int256, int256);
    function swapOut5E08A399(
        address _token,
        uint256 _amount,
        uint256 _minOut
    ) external returns (int256, int256);
    function swapOutPermit23273373B(
        address _token,
        uint256 _amount,
        uint256 _minOut,
        uint256 _nonce,
        uint256 _deadline,
        uint256 _maxAmount,
        bytes memory _sig
    ) external returns (int256, int256);
    function swap2ExactIn41203F1D(
        address _tokenA,
        address _tokenB,
        uint256 _amount,
        uint256 _minOut
    ) external returns (uint256, uint256);
}
contract OwnershipNFTs is IERC721Metadata {
    ISeawaterAMM immutable public SEAWATER;
    string public TOKEN_URI;
    string public name;
    string public symbol;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _tokenURI,
        ISeawaterAMM _seawater
    ) {
        name = _name;
        symbol = _symbol;
        TOKEN_URI = _tokenURI;
        SEAWATER = _seawater;
    }
    function ownerOf(uint256 _tokenId) public view returns (address) {
        (bool ok, bytes memory rc) = address(SEAWATER).staticcall(abi.encodeWithSelector(
            SEAWATER.positionOwnerD7878480.selector,
            _tokenId
        ));
        require(ok, "position owner revert");
        (address owner) = abi.decode(rc, (address));
        return owner;
    }
    function _onTransferReceived(
        address _sender,
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        if (_to.code.length == 0) return;
        bytes4 data = IERC721TokenReceiver(_to).onERC721Received(
            _sender,
            _from,
            _tokenId,
            ""
        );
        require(
            data != IERC721TokenReceiver.onERC721Received.selector,
            "bad nft transfer received data"
        );
    }
    function _requireAuthorised(address _from, uint256 _tokenId) internal view {
        bool isAllowed =
            msg.sender == _from ||
            isApprovedForAll[_from][msg.sender] ||
            msg.sender == getApproved[_tokenId];
        require(isAllowed, "not allowed");
        require(ownerOf(_tokenId) == _from, "_from is not the owner!");
    }
    function _transfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        _requireAuthorised(_from, _tokenId);
        SEAWATER.transferPositionEEC7A3CD(_tokenId, _from, _to);
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata 
    ) external payable {
        _transfer(_from, _to, _tokenId);
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transfer(_from, _to, _tokenId);
    }
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable {
        _transfer(_from, _to, _tokenId);
        _onTransferReceived(msg.sender, _from, _to, _tokenId);
    }
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata 
    ) external payable {
        _transfer(_from, _to, _tokenId);
        _onTransferReceived(msg.sender, _from, _to, _tokenId);
    }
    function approve(address _approved, uint256 _tokenId) external payable {
        _requireAuthorised(msg.sender, _tokenId);
        getApproved[_tokenId] = _approved;
    }
    function setApprovalForAll(address _operator, bool _approved) external {
        isApprovedForAll[msg.sender][_operator] = _approved;
    }
    function balanceOf(address _spender) external view returns (uint256) {
        (bool ok, bytes memory rc) = address(SEAWATER).staticcall(abi.encodeWithSelector(
            SEAWATER.positionBalance4F32C7DB.selector,
            _spender
        ));
        require(ok, "position balance revert");
        (uint256 balance) = abi.decode(rc, (uint256));
        return balance;
    }
    function tokenURI(uint256 ) external view returns (string memory) {
        return TOKEN_URI;
    }
}