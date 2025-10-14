pragma solidity 0.8.0;
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;
        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        return c;
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
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
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
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
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC721Enumerable is IERC721 {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}
abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;
    constructor() {
        _paused = false;
    }
    function paused() public view virtual returns (bool) {
        return _paused;
    }
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
    function mint(address _recipient,uint _amount, uint _tokenId) external returns (uint);
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
contract ERC721A is
  Context,
  ERC165,
  IERC721,
  IERC721Metadata,
  IERC721Enumerable
{
  using Strings for uint256;
  struct TokenOwnership {
    address addr;
    uint64 startTimestamp;
  }
  struct AddressData {
    uint128 balance;
    uint128 numberMinted;
  }
    mapping(uint256 => NFTTraits) public tokenTraits;
    struct NFTTraits {
        uint256 level;
        uint256 amountOfGSD;
        uint256 amountOfLFT;
        uint256 amountOfsoil;
    }
  uint256 private currentIndex = 0;
  uint256 internal immutable collectionSize;
  uint256 internal immutable maxBatchSize;
  string private _name;
  string private _symbol;
  mapping(uint256 => TokenOwnership) private _ownerships;
  mapping(address => AddressData) private _addressData;
  mapping(uint256 => address) private _tokenApprovals;
  mapping(address => mapping(address => bool)) private _operatorApprovals;
   mapping(address=>mapping(uint=>uint)) public _balanceOfLevel;
   mapping(uint=>uint) public _totalSupplyOfLevel;
  constructor(
    string memory name_,
    string memory symbol_,
    uint256 maxBatchSize_,
    uint256 collectionSize_
  ) {
    require(
      collectionSize_ > 0,
      "ERC721A: collection must have a nonzero supply"
    );
    require(maxBatchSize_ > 0, "ERC721A: max batch size must be nonzero");
    _name = name_;
    _symbol = symbol_;
    maxBatchSize = maxBatchSize_;
    collectionSize = collectionSize_;
  }
  function totalSupply() public view override returns (uint256) {
    return currentIndex;
  }
  function tokenByIndex(uint256 index) external view override returns (uint256) {
    require(index < totalSupply(), "ERC721A: global index out of bounds");
    return index;
  }
  function tokenOfOwnerByIndex(address owner, uint256 index)
    external
    view
    override
    returns (uint256)
  {
    require(index < balanceOf(owner), "ERC721A: owner index out of bounds");
    uint256 numMintedSoFar = totalSupply();
    uint256 tokenIdsIdx = 0;
    address currOwnershipAddr = address(0);
    for (uint256 i = 0; i < numMintedSoFar; i++) {
      TokenOwnership memory ownership = _ownerships[i];
      if (ownership.addr != address(0)) {
        currOwnershipAddr = ownership.addr;
      }
      if (currOwnershipAddr == owner) {
        if (tokenIdsIdx == index) {
          return i;
        }
        tokenIdsIdx++;
      }
    }
    revert("ERC721A: unable to get token of owner by index");
  }
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override(ERC165, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IERC721).interfaceId ||
      interfaceId == type(IERC721Metadata).interfaceId ||
      interfaceId == type(IERC721Enumerable).interfaceId ||
      super.supportsInterface(interfaceId);
  }
   function balanceOfLevel(address owner,uint level) public view returns (uint){
        return _balanceOfLevel[owner][level];
    }
    function  totalSupplyOfLevel(uint level) public view returns (uint){
        return _totalSupplyOfLevel[level];
    }
  function balanceOf(address owner) public view override returns (uint256) {
    require(owner != address(0), "ERC721A: balance query for the zero address");
    return uint256(_addressData[owner].balance);
  }
  function _numberMinted(address owner) internal view returns (uint256) {
    require(
      owner != address(0),
      "ERC721A: number minted query for the zero address"
    );
    return uint256(_addressData[owner].numberMinted);
  }
  function ownershipOf(uint256 tokenId)
    internal
    view
    returns (TokenOwnership memory)
  {
    require(_exists(tokenId), "ERC721A: owner query for nonexistent token");
    uint256 lowestTokenToCheck;
    if (tokenId >= maxBatchSize) {
      lowestTokenToCheck = tokenId - maxBatchSize + 1;
    }
    for (uint256 curr = tokenId; curr >= lowestTokenToCheck; curr--) {
      TokenOwnership memory ownership = _ownerships[curr];
      if (ownership.addr != address(0)) {
        return ownership;
      }
    }
    revert("ERC721A: unable to determine the owner of token");
  }
  function ownerOf(uint256 tokenId) public view override returns (address) {
    return ownershipOf(tokenId).addr;
  }
  function name() public view virtual override returns (string memory) {
    return _name;
  }
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    string memory baseURI = _baseURI();
    return
      bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, (tokenId+1).toString(), ".json"))
        : "";
  }
  function _baseURI() internal view virtual returns (string memory) {
    return "";
  }
  function approve(address to, uint256 tokenId) external override {
    address owner = ERC721A.ownerOf(tokenId);
    require(to != owner, "ERC721A: approval to current owner");
    require(
      _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
      "ERC721A: approve caller is not owner nor approved for all"
    );
    _approve(to, tokenId, owner);
  }
  function getApproved(uint256 tokenId) public view override returns (address) {
    require(_exists(tokenId), "ERC721A: approved query for nonexistent token");
    return _tokenApprovals[tokenId];
  }
  function setApprovalForAll(address operator, bool approved) external override {
    require(operator != _msgSender(), "ERC721A: approve to caller");
    _operatorApprovals[_msgSender()][operator] = approved;
    emit ApprovalForAll(_msgSender(), operator, approved);
  }
  function isApprovedForAll(address owner, address operator)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external override {
    _transfer(from, to, tokenId);
  }
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public override {
    safeTransferFrom(from, to, tokenId, "");
  }
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) public override {
    _transfer(from, to, tokenId);
    require(
      _checkOnERC721Received(from, to, tokenId, _data),
      "ERC721A: transfer to non ERC721Receiver implementer"
    );
  }
  function _exists(uint256 tokenId) internal view returns (bool) {
    return tokenId < currentIndex;
  }
  function _safeMint(address to, uint256 quantity) internal {
    _safeMint(to, quantity, "");
  }
  function _safeMint(
    address to,
    uint256 quantity,
    bytes memory _data
  ) internal {
    uint256 startTokenId = currentIndex;
    require(to != address(0), "ERC721A: mint to the zero address");
    require(!_exists(startTokenId), "ERC721A: token already minted");
    require(quantity <= maxBatchSize, "ERC721A: quantity to mint too high");
    _beforeTokenTransfers(address(0), to, startTokenId, quantity);
    AddressData memory addressData = _addressData[to];
    _addressData[to] = AddressData(
      addressData.balance + uint128(quantity),
      addressData.numberMinted + uint128(quantity)
    );
    _ownerships[startTokenId] = TokenOwnership(to, uint64(block.timestamp));
    uint256 updatedIndex = startTokenId;
    for (uint256 i = 0; i < quantity; i++) {
      tokenTraits[updatedIndex].level=1;
      _balanceOfLevel[to][1]+=1;
      _totalSupplyOfLevel[1]+=1;
      emit Transfer(address(0), to, updatedIndex);
      require(
        _checkOnERC721Received(address(0), to, updatedIndex, _data),
        "ERC721A: transfer to non ERC721Receiver implementer"
      );
      updatedIndex++;
    }
    currentIndex = updatedIndex;
    _afterTokenTransfers(address(0), to, startTokenId, quantity);
  }
  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) private {
    TokenOwnership memory prevOwnership = ownershipOf(tokenId);
    bool isApprovedOrOwner = (_msgSender() == prevOwnership.addr ||
      getApproved(tokenId) == _msgSender() ||
      isApprovedForAll(prevOwnership.addr, _msgSender()));
    require(
      isApprovedOrOwner,
      "ERC721A: transfer caller is not owner nor approved"
    );
    require(
      prevOwnership.addr == from,
      "ERC721A: transfer from incorrect owner"
    );
    require(to != address(0), "ERC721A: transfer to the zero address");
    _beforeTokenTransfers(from, to, tokenId, 1);
    _approve(address(0), tokenId, prevOwnership.addr);
    _addressData[from].balance -= 1;
    _addressData[to].balance += 1;
    _ownerships[tokenId] = TokenOwnership(to, uint64(block.timestamp));
    uint256 nextTokenId = tokenId + 1;
    if (_ownerships[nextTokenId].addr == address(0)) {
      if (_exists(nextTokenId)) {
        _ownerships[nextTokenId] = TokenOwnership(
          prevOwnership.addr,
          prevOwnership.startTimestamp
        );
      }
    }
    _balanceOfLevel[from][tokenTraits[tokenId].level]-=1;
    _balanceOfLevel[to][tokenTraits[tokenId].level]+=1;
    emit Transfer(from, to, tokenId);
    _afterTokenTransfers(from, to, tokenId, 1);
  }
  function _approve(
    address to,
    uint256 tokenId,
    address owner
  ) private {
    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }
  uint256 public nextOwnerToExplicitlySet = 0;
  function _setOwnersExplicit(uint256 quantity) internal {
    uint256 oldNextOwnerToSet = nextOwnerToExplicitlySet;
    require(quantity > 0, "quantity must be nonzero");
    uint256 endIndex = oldNextOwnerToSet + quantity - 1;
    if (endIndex > collectionSize - 1) {
      endIndex = collectionSize - 1;
    }
    require(_exists(endIndex), "not enough minted yet for this cleanup");
    for (uint256 i = oldNextOwnerToSet; i <= endIndex; i++) {
      if (_ownerships[i].addr == address(0)) {
        TokenOwnership memory ownership = ownershipOf(i);
        _ownerships[i] = TokenOwnership(
          ownership.addr,
          ownership.startTimestamp
        );
      }
    }
    nextOwnerToExplicitlySet = endIndex + 1;
  }
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes memory _data
  ) private returns (bool) {
    if (Address.isContract(to)) {
      try
        IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data)
      returns (bytes4 retval) {
        return retval == IERC721Receiver(to).onERC721Received.selector;
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC721A: transfer to non ERC721Receiver implementer");
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
  function _beforeTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
  ) internal virtual {}
  function _afterTokenTransfers(
    address from,
    address to,
    uint256 startTokenId,
    uint256 quantity
  ) internal virtual {}
}
    contract landNFT is  Ownable, ERC721A, ReentrancyGuard,Pausable{
        using Strings for uint256;
        using Strings for uint8;
        using SafeMath for uint;
        using Address for address;
        string private _baseURIextended;
        uint256 public constant MAX_SUPPLY =1500;
        string public extension;
        struct History{
            uint tokenId;
            uint time;
            uint level;
        }
        mapping(address=>History[]) public historyList;
        struct consume{
            uint256 consumedGSD;
            uint256 consumedLFT;
            uint256 consumedsoil;
        }
        mapping(string=>consume) public consumption;
        address public GSDAddress=0xB12E8Eb6b1F24e14381514d2f3B75e7c61487016;
        address public LFTAddress;
        address public soilAddress;
        event Synthesis(address, uint, uint, uint256);
        mapping(address=>bool) public miner;
        constructor() ERC721A("land", "land",200,1000) {
            _baseURIextended="https:
            extension = ".png";
            miner[msg.sender]=true;
            consumption["2"].consumedGSD=50*10**18;
            consumption["2"].consumedLFT=5000*10**18;
            consumption["2"].consumedsoil=2;
            consumption["3"].consumedGSD=100*10**18;
            consumption["3"].consumedLFT=10000*10**18;
            consumption["3"].consumedsoil=4;
            consumption["4"].consumedGSD=150*10**18;
            consumption["4"].consumedLFT=15000*10**18;
            consumption["4"].consumedsoil=5;
            consumption["5"].consumedGSD=200*10**18;
            consumption["5"].consumedLFT=20000*10**18;
            consumption["5"].consumedsoil=7;
        }
        modifier onlyMiner() {
            require(miner[msg.sender]==true, "Ownable: caller is not the miner");
            _;
        }
        function setMiner(address _addr,bool _bool) public onlyOwner() {
            miner[_addr]=_bool;
        }
        function setBaseURI(string memory baseURI_) external onlyOwner() {
            _baseURIextended = baseURI_;
        }
        function setsoilAddress(address _addr) public onlyOwner{
            soilAddress=_addr;
        }
        function setGSDAddress(address _addr) public onlyOwner{
            GSDAddress=_addr;
        }
        function setLFTAddress(address _addr) public onlyOwner{
            LFTAddress=_addr;
        }
        function _baseURI() internal view virtual override returns (string memory) {
            return _baseURIextended;
        }
        function tokenURI(uint256 tokenId) public view override(ERC721A) returns (string memory) {
            require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
            string memory baseURI = _baseURI();
            string memory metadata = string(abi.encodePacked(
                    '{"name": "',
                    'land NFT #',
                    tokenId.toString(),
                    '", "description": "Land of Genesis NFT is the ecological core andeconomic construction foundation of Miracle Farm,with a total of 1500 scarce resources.If you ownland NFT will get the entrance ticket of MiracleFarm ecology.", "image": "',
                    string(abi.encodePacked(baseURI,tokenTraits[tokenId].level.toString(),extension)),
                    '", "attributes":',
                    compileAttributes(tokenId),
                    "}"
                ));
            return string(abi.encodePacked(
                    "data:application/json;base64,",
                    base64(bytes(metadata))
                ));
        }
        function compileAttributes(uint256 tokenId) internal view returns (string memory) {
            return string(abi.encodePacked(
                    '[',
                    '{"trait_type":"level","value":"',
                    tokenTraits[tokenId].level.toString(),
                    '"},{"trait_type":"consumed GSD","value":"',
                    tokenTraits[tokenId].amountOfGSD.toString(),
                    '"},{"trait_type":"consumed soil","value":"',
                    tokenTraits[tokenId].amountOfsoil.toString(),
                    '"},{"trait_type":"consumed LFT","value":"',
                    tokenTraits[tokenId].amountOfLFT.toString(),
                    '"}]'
                ));
        }
        string internal constant TABLE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        function base64(bytes memory data) internal pure returns (string memory) {
            if (data.length == 0) return '';
            string memory table = TABLE;
            uint256 encodedLen = 4 * ((data.length + 2) / 3);
            string memory result = new string(encodedLen + 32);
            assembly {
                mstore(result, encodedLen)
                let tablePtr := add(table, 1)
                let dataPtr := data
                let endPtr := add(dataPtr, mload(data))
                let resultPtr := add(result, 32)
                for {} lt(dataPtr, endPtr) {}
                {
                    dataPtr := add(dataPtr, 3)
                    let input := mload(dataPtr)
                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                    mstore(resultPtr, shl(248, mload(add(tablePtr, and(input, 0x3F)))))
                    resultPtr := add(resultPtr, 1)
                }
                switch mod(mload(data), 3)
                case 1 {mstore(sub(resultPtr, 2), shl(240, 0x3d3d))}
                case 2 {mstore(sub(resultPtr, 1), shl(248, 0x3d))}
            }
            return result;
        }
        function setExtension(string memory _extension) public onlyOwner {
                extension = _extension;
        }
        function setPaused(bool _paused) external onlyOwner {
            if (_paused) _pause();
            else _unpause();
        }
        function upgrade(uint256 _tokenId)external whenNotPaused{
            require(msg.sender == tx.origin,"Address: The address cannot be a contract");
            require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
            require(ownerOf(_tokenId)==msg.sender,"ERC721: transfer of token that is not own");
            require(tokenTraits[_tokenId].level<5,"Already the highest level of land");
            History memory history;
            uint beforeLevel=tokenTraits[_tokenId].level;
            if (tokenTraits[_tokenId].level==1){
                IERC20(GSDAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["2"].consumedGSD
                );
                IERC20(LFTAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["2"].consumedLFT
                );
                IERC1155(soilAddress).safeTransferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    1,
                                    consumption["2"].consumedsoil,
                                    new bytes(0)
                );
                tokenTraits[_tokenId].level=2;
                tokenTraits[_tokenId].amountOfGSD=consumption["2"].consumedGSD;
                tokenTraits[_tokenId].amountOfLFT=consumption["2"].consumedLFT;
                tokenTraits[_tokenId].amountOfsoil=consumption["2"].consumedsoil;
                emit Synthesis(msg.sender,beforeLevel, tokenTraits[_tokenId].level, block.timestamp);
            }else if (tokenTraits[_tokenId].level==2){
                IERC20(GSDAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["3"].consumedGSD
                );
                IERC20(LFTAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["3"].consumedLFT
                );
                IERC1155(soilAddress).safeTransferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    1,
                                    consumption["3"].consumedsoil,
                                    new bytes(0)
                );
                tokenTraits[_tokenId].level=3;
                tokenTraits[_tokenId].amountOfGSD=consumption["3"].consumedGSD;
                tokenTraits[_tokenId].amountOfLFT=consumption["3"].consumedLFT;
                tokenTraits[_tokenId].amountOfsoil=consumption["3"].consumedsoil;
            }else if ((tokenTraits[_tokenId].level==3)){
                IERC20(GSDAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["4"].consumedGSD
                );
                IERC20(LFTAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["4"].consumedLFT
                );
                IERC1155(soilAddress).safeTransferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    1,
                                    consumption["4"].consumedsoil,
                                    new bytes(0)
                );
                tokenTraits[_tokenId].level=4;
                tokenTraits[_tokenId].amountOfGSD=consumption["4"].consumedGSD;
                tokenTraits[_tokenId].amountOfLFT=consumption["4"].consumedLFT;
                tokenTraits[_tokenId].amountOfsoil=consumption["4"].consumedsoil;
            }else if (tokenTraits[_tokenId].level==4){
                IERC20(GSDAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["5"].consumedGSD
                );
                IERC20(LFTAddress).transferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    consumption["5"].consumedLFT
                );
                IERC1155(soilAddress).safeTransferFrom(
                                    msg.sender,
                                    address(0xdead),
                                    1,
                                    consumption["5"].consumedsoil,
                                    new bytes(0)
                );
                tokenTraits[_tokenId].level=5;
                tokenTraits[_tokenId].amountOfGSD=consumption["5"].consumedGSD;
                tokenTraits[_tokenId].amountOfLFT=consumption["5"].consumedLFT;
                tokenTraits[_tokenId].amountOfsoil=consumption["5"].consumedsoil;
            }
            _totalSupplyOfLevel[beforeLevel]=_totalSupplyOfLevel[beforeLevel].sub(1);
            _totalSupplyOfLevel[tokenTraits[_tokenId].level]=_totalSupplyOfLevel[tokenTraits[_tokenId].level].add(1);
            _balanceOfLevel[msg.sender][beforeLevel]=_balanceOfLevel[msg.sender][beforeLevel].sub(1);
            _balanceOfLevel[msg.sender][tokenTraits[_tokenId].level]=_balanceOfLevel[msg.sender][tokenTraits[_tokenId].level].add(1);
             history.tokenId=_tokenId;
             history.level=tokenTraits[_tokenId].level;
             history.time=block.timestamp;
             historyList[msg.sender].push(history);
             emit Synthesis(msg.sender,beforeLevel, tokenTraits[_tokenId].level, block.timestamp);
        }
        function mint(address player,uint256 amount) external whenNotPaused() onlyMiner{
            uint256 _tokenId = totalSupply();
            require(_tokenId.add(amount)<=MAX_SUPPLY,"MAX_SUPPLY err");
            _safeMint(player, amount);
        }
        function gethistoryList(address _addr) public view returns(History[] memory){
             return historyList[_addr];
        }
        function supportsInterface(bytes4 interfaceId)
            public
            view
            override(ERC721A)
            returns (bool)
        {
            return super.supportsInterface(interfaceId);
        }
        function getLevel(uint _tokenId) public view returns(uint){
            require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
            return tokenTraits[_tokenId].level;
        }
}