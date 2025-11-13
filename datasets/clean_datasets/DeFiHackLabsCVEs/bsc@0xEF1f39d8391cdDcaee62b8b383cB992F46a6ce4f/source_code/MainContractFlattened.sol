pragma solidity 0.8.24;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
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
interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}
interface IERC721Errors {
    error ERC721InvalidOwner(address owner);
    error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721InvalidSender(address sender);
    error ERC721InvalidReceiver(address receiver);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);
}
interface IERC1155Errors {
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155MissingApprovalForAll(address operator, address owner);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override(IERC20Metadata, IERC20) returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
        emit Transfer(from, to, value);
    }
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC721Enumerable {
    function totalSupply() external view returns (uint256);
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256);
    function tokenByIndex(uint256 index) external view returns (uint256);
}
interface IERC721Burnable {
    function burn(uint256 tokenId) external;
}
interface IERC721Mintable {
    function mint(address to) external;
}
interface iERC721CheckAuth {
    function isAuthorized(
        address _owner,
        address _spender,
        uint256 _tokenId
    ) external view returns (bool);
}
interface IP404 {
    function isValidTokenId(
        uint256 _tokenOrAmount
    ) external view returns (bool);
}
contract P404Token is ERC20, IP404 {
    address public erc721;
    uint256 public constant MAX_SUPPLY = 300000000 * 10 ** 18;
    uint256 public constant MAX_ERC20_TOKENS = 300000000 * 10 ** 18;
    uint256 public constant TRANSFORM_PRICE = 10000 * 10 ** 18;
    uint256 public constant TRANSFORM_LOSE_RATE = 200; 
    uint256 public constant MAX_NFT_MINT = 4000; 
    uint256 public constant MAX_MINT_VALUE = 0.6 ether;
    uint256 public constant MINT_PRICE = 0.2 ether;
    uint256 public nftMinted;
    address public feeTo;
    address public owner;
    event FromTokenToNFT(address from, uint256 amount);
    event FromNFTToToken(address from, uint256 tokenId);
    event PayToMint(address from, uint256 price, uint256 tokenId);
    mapping(address => bool) public allowlist;
    mapping(address => uint256) public mintedAmount;
    constructor(
        string memory _name,
        string memory _symbol,
        address _erc721,
        address _feeTo
    ) ERC20(_name, _symbol) {
        _mint(msg.sender, 260000000 * 10 ** 18);
        erc721 = _erc721;
        feeTo = _feeTo;
        owner = msg.sender;
    }
    function batchSetAllowlist(
        address[] calldata _addres,
        bool _allow
    ) external {
        require(owner == msg.sender, "META: no owner");
        for (uint256 i = 0; i < _addres.length; i++) {
            allowlist[_addres[i]] = _allow;
        }
    }
    function isValidTokenId(uint256 tokenId) public pure returns (bool) {
        return tokenId < 30001;
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public override returns (bool) {
        if (isValidTokenId(value)) {
            require(
                iERC721CheckAuth(erc721).isAuthorized(from, msg.sender, value),
                "P404: not authorized"
            );
            IERC721(erc721).safeTransferFrom(from, to, value);
            if (to == address(this)) {
                transform(value);
            }
        } else {
            super.transferFrom(from, to, value);
        }
        return true;
    }
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        if (!isValidTokenId(value)) {
            super._update(from, to, value);
        }
        if (to == address(this) || to == erc721) {
            transform(value);
        } else {
            if (isValidTokenId(value)) {
                if (from != address(0)) {
                    require(
                        iERC721CheckAuth(erc721).isAuthorized(
                            from,
                            msg.sender,
                            value
                        ),
                        "P404: not authorized"
                    );
                }
                IERC721(erc721).safeTransferFrom(from, to, value);
            }
        }
    }
    function transform(uint256 tokenIdOrValue) internal {
        if (isValidTokenId(tokenIdOrValue)) {
            _erc721ToErc20(tokenIdOrValue);
        } else {
            _erc20ToErc721(tokenIdOrValue);
        }
    }
    function approve(
        address spender,
        uint256 tokenIdOrValue
    ) public override returns (bool) {
        if (isValidTokenId(tokenIdOrValue)) {
            IERC721(erc721).approve(spender, tokenIdOrValue);
            return true;
        } else {
            return super.approve(spender, tokenIdOrValue);
        }
    }
    function setApproveForAll(address operator, bool approved) public {
        IERC721(erc721).setApprovalForAll(operator, approved);
    }
    function getApproved(uint256 tokenId) public view returns (address) {
        return IERC721(erc721).getApproved(tokenId);
    }
    function isApprovedForAll(
        address _owner,
        address operator
    ) public view returns (bool) {
        return IERC721(erc721).isApprovedForAll(_owner, operator);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public {
        require(
            iERC721CheckAuth(erc721).isAuthorized(from, msg.sender, tokenId),
            "P404: not authorized"
        );
        IERC721(erc721).safeTransferFrom(from, to, tokenId, data);
        if (to == address(this)) {
            transform(tokenId);
        }
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        require(
            iERC721CheckAuth(erc721).isAuthorized(from, msg.sender, tokenId),
            "P404: not authorized"
        );
        IERC721(erc721).safeTransferFrom(from, to, tokenId);
        if (to == address(this)) {
            transform(tokenId);
        }
    }
    function ownerOf(uint256 tokenId) public view returns (address) {
        return IERC721(erc721).ownerOf(tokenId);
    }
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        return IERC721Metadata(erc721).tokenURI(tokenId);
    }
    function totalSupplyERC721() public view returns (uint256) {
        return IERC721Enumerable(erc721).totalSupply();
    }
    function tokenOfOwnerByIndex(
        address _owner,
        uint256 index
    ) public view returns (uint256) {
        return IERC721Enumerable(erc721).tokenOfOwnerByIndex(_owner, index);
    }
    function tokenByIndex(uint256 index) public view returns (uint256) {
        return IERC721Enumerable(erc721).tokenByIndex(index);
    }
    function _erc20ToErc721(uint256 _amount) internal {
        require(_amount >= TRANSFORM_PRICE, "P404: insufficient amount");
        require(_amount % TRANSFORM_PRICE == 0, "P404: invalid amount");
        uint256 nfts = _amount / TRANSFORM_PRICE;
        uint256 _realcost = nfts * TRANSFORM_PRICE;
        _burn(address(this), _realcost);
        for (uint256 i = 0; i < nfts; i++) {
            IERC721Mintable(erc721).mint(msg.sender);
        }
        emit FromTokenToNFT(msg.sender, _amount);
    }
    function _erc721ToErc20(uint256 _tokenId) internal {
        IERC721Burnable(erc721).burn(_tokenId);
        _mint(
            msg.sender,
            (TRANSFORM_PRICE * (10000 - TRANSFORM_LOSE_RATE)) / 10000
        );
        emit FromNFTToToken(msg.sender, _tokenId);
    }
    function mint(address to, uint256 amount) public {
        require(msg.sender == erc721, "P404: only nft contract can mint");
        require(
            totalSupply() + amount <= MAX_SUPPLY,
            "P404: exceed max supply"
        );
        _mint(to, amount);
    }
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Receiver).interfaceId ||
            interfaceId == type(IERC20).interfaceId ||
            interfaceId == type(IP404).interfaceId;
    }
    function mintNFT() public payable {
        require(msg.value >= MINT_PRICE, "P404: insufficient amount");
        require(tx.origin == msg.sender, "P404: not allow contract");
        require(allowlist[msg.sender], "P404: not in allowlist");
        require(msg.value <= MAX_MINT_VALUE, "P404: too much money, max is 0.6 ether");
        uint256 _mint = msg.value / MINT_PRICE;
        uint256 realcost = _mint * MINT_PRICE;
        require(mintedAmount[msg.sender] + realcost <= MAX_MINT_VALUE, "P404: exceed max mint value");
        require(nftMinted + _mint <= MAX_NFT_MINT, "P404: exceed max mint");
        for (uint256 i = 0; i < _mint; i++) {
            IERC721Mintable(erc721).mint(msg.sender);
        }
        emit PayToMint(msg.sender, realcost, _mint);
        nftMinted += _mint;
        mintedAmount[msg.sender] += realcost;
        if (feeTo != address(0)) {
            payable(feeTo).transfer(realcost);
        }
        uint256 refund = msg.value - realcost;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
    }
    receive() external payable {
        mintNFT();
    }
}