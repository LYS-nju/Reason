pragma solidity 0.8.16;
import "./IERC721Metadata.sol";
import "./ISeawaterAMM.sol";
import "./IERC721TokenReceiver.sol";
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