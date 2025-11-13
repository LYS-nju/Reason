pragma solidity 0.8.20;
library AddressUpgradeable {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
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
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }
    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}
abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }
    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}
abstract contract ReentrancyGuardUpgradeable is Initializable {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }
    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
    uint256[49] private __gap;
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function mint(address to, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
    function transferOwnership(address newOwner) external;
}
interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}
interface IUniswapV2Factory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
contract XBridge is OwnableUpgradeable, ReentrancyGuardUpgradeable {
    uint256 public listingFee;
    address public factory;
    address public tokenFeeCollector;
    address public listingFeeCollector;
    address[] public admin;
    address public usdt;
    IUniswapV2Router02 public router;
    uint256 public thresholdLimit;
    struct tokenInfo {
        address token;
        uint256 chain;
    }
    mapping(address => bool) public isBase;
    mapping(address => bool) public isWrapped;
    mapping(address => uint256) public tokenTax;
    mapping(uint256 => bool) public chainSupported;
    mapping(address => uint256) public feesForToken;
    mapping(address => uint256) public tokenChainId;
    mapping(address => address) public tokenToToken;
    mapping(address => bool) public excludeFeeFromListing;
    mapping(address => mapping(address => bool)) public isMintable;
    mapping(uint256 => mapping(address => uint256)) public inNonce;
    mapping(address => mapping(address => address)) public tokenOwner;
    mapping(address => mapping(address => uint256)) public tokenDeposited;
    mapping(address => mapping(address => uint256)) public tokenWithdrawn;
    mapping(uint256 => mapping(address => mapping(uint256 => bool))) public nonceProcessed;
    event Locked(address indexed user, address indexed inToken, address indexed outToken, uint256 amount, uint256 feeAmount, uint256 _nonce, uint256 isWrapped, uint256 srcId, uint256 dstId);
    event UnLocked(address indexed user, address indexed outToken, uint256 amount, uint256 feeAmount, uint256 _nonce, uint256 srcId, uint256 dstId);
    event TokenListed(address indexed baseToken, uint256 baseTokenChain, address indexed correspondingToken, uint256 correspondingTokenChain, bool isMintable, address indexed user);
    event TokenDelisted(address indexed baseToken, uint256 baseTokenChain, address indexed correspondingToken, uint256 correspondingTokenChain);
    event TokenDeposited(address indexed user, uint256 amount);
    event TokenWithdrawn(address indexed user, address indexed receiver, uint256 amount);
    event SignersChanged(address[] indexed newSigners);
    event ChainSupported(uint256 _chain, bool _supported);
    event FeeExcludedFromListing(address indexed user, bool ifExcluded);
    event TokenFee(address indexed _token, uint256 _fee);
    mapping(uint256 => mapping(uint256 => mapping(address => bool))) public isWrappedWithChainId;
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(address => address)))) public tokenOwnerWithChainId;
    mapping(uint256 => mapping(uint256 => mapping(address => address))) public tokenToTokenWithChainId;
    mapping(uint256 => mapping(uint256 => mapping(address => mapping(address => bool)))) public isMintableWithChainId;
    mapping(address => address) public _tokenOwner;
    address public native;                          
    constructor() {
        _disableInitializers();
    }
    function initialize(address[] memory _admin, uint256 _listingFee, address _tokenFeeCollector, address _listingFeeCollector, address _router, address _factory, address _usdt) external initializer {
        require(_admin.length >= 3, "MINIMUM_SIGNERS_SHOULD_BE_3");
        require(_listingFee > 0, "LISTING_FEE_CANT_BE_ZERO");
        require(_tokenFeeCollector != address(0) && _listingFeeCollector != address(0), "CANT_PROVIDE_ZERO_ADDRESS");
        __Ownable_init();
        __ReentrancyGuard_init();
        admin = _admin;
        listingFee = _listingFee;
        tokenFeeCollector = _tokenFeeCollector;
        listingFeeCollector = _listingFeeCollector;
        router = IUniswapV2Router02(_router);
        factory = _factory;
        usdt = _usdt;
        thresholdLimit = 100 * 10**6;
    }
    receive() external payable {
        revert("DIRECT_ETH_TRANSFER_NOT_SUPPORTED");
    }
    fallback() external payable {
        revert("DIRECT_ETH_TRANSFER_NOT_SUPPORTED");
    }
    function lock(address inToken, uint256 _amount, uint256 dstId) external payable nonReentrant {
        require(_amount > 0, "AMOUNT_CANT_BE_ZERO");    
        require(inToken != address(0), "TOKEN_ADDRESS_CANT_BE_NULL");
        require(chainSupported[dstId], "INVALID_CHAIN");
        uint256 srcId;
        assembly {
            srcId := chainid()
        }
        address outToken = tokenToTokenWithChainId[srcId][dstId][inToken];
        require(outToken != address(0), "UNSUPPORTED_TOKEN");
        uint256 _isWrapped;
        if(isWrappedWithChainId[srcId][dstId][inToken]) _isWrapped = 1;
        else if(inToken == native || outToken == native) _isWrapped =2;
        else _isWrapped = 0;
        address _user = msg.sender;
        uint256 tokenAmount;
        uint256 fee = feesForToken[inToken];
        uint256 feesAmount;
        if(_isWrapped == 0) {
                (tokenAmount, feesAmount) = transferAndCalcAmountAndFees(inToken, _user, _amount, fee);
                emit Locked(_user, inToken, outToken, tokenAmount, feesAmount, inNonce[dstId][_user]++, _isWrapped, srcId, dstId);
        } else if(_isWrapped == 1) {
                (tokenAmount, feesAmount) = transferAndCalcAmountAndFees(inToken, _user, _amount, fee);
                burn(inToken, tokenAmount+feesAmount);
                emit Locked(_user, inToken, outToken, tokenAmount, feesAmount, inNonce[dstId][_user]++, _isWrapped, srcId, dstId);
        } else if (_isWrapped == 2) {
            if(inToken == native) {
                tokenAmount = _amount;
                fee = feesForToken[inToken];
                if(fee > 0) {
                    feesAmount = _amount * fee / 100;
                    tokenAmount -= feesAmount;
                }
                require(_amount == msg.value, "LESS_LOCKING");
                emit Locked(_user, inToken, outToken, tokenAmount, feesAmount, inNonce[dstId][_user]++, _isWrapped, srcId, dstId);
            } else {
                (tokenAmount, feesAmount) = transferAndCalcAmountAndFees(inToken, _user, _amount, fee);
                emit Locked(_user, inToken, outToken, tokenAmount, feesAmount, inNonce[dstId][_user]++, _isWrapped, srcId, dstId);
            }
        }
    }
    function unlock(address inToken, uint256 amount, uint256 feeAmount, uint256 _nonce, uint256 _isWrapped, uint256 srcId, bytes32[] memory r, bytes32[] memory s, uint8[] memory v) external payable nonReentrant {
        address user = msg.sender;
        require(inToken != address(0), "TOKEN_ADDRESS_CANT_BE_NULL");
        require(user != address(0), "INVALID_RECEIVER");
        require(amount > 0, "AMOUNT_CANT_BE_ZERO");
        require(!nonceProcessed[srcId][user][_nonce], "NONCE_ALREADY_PROCESSED");
        require(chainSupported[srcId], "INVALID_CHAIN");
        uint256 dstId;
        assembly {
            dstId := chainid()
        }
        address outToken = tokenToTokenWithChainId[srcId][dstId][inToken];
        require(outToken != address(0), "UNSUPPORTED_TOKEN");
        bool mintable = isMintableWithChainId[srcId][dstId][inToken][outToken];
        bool success = verify(address(this), user, inToken, outToken, _nonce, amount, feeAmount, _isWrapped, srcId, dstId, r, s, v);
        require(success, "INVALID_RECOVERED_SIGNER");
        if(!mintable && outToken !=native) require((IERC20(outToken).balanceOf(address(this)) - tokenTax[outToken]) >= (amount + feeAmount), "INSUFFICIENT_LIQUIDITY_IN_BRIDGE");
        nonceProcessed[srcId][user][_nonce] = true;
        if(_isWrapped == 0) {
            if(mintable) {
                if(feeAmount > 0) mint(outToken, tokenFeeCollector, feeAmount);
                mint(outToken, user, amount);
            } else {
                if(feeAmount > 0) {
                    tokenTax[outToken] += feeAmount;
                }
                success = IERC20(outToken).transfer(user, amount);
                if(!success) revert("TOKEN_TRANSFER_FAILED");
            }
        } else if(_isWrapped == 1) {
            if(outToken == native) {
                require(address(this).balance >= amount+feeAmount, "INSUFFICIENT_FUND_IN_BRIDE");
                if(feeAmount > 0) {
                    (success, ) = payable(tokenFeeCollector).call{value: feeAmount}("");
                    require(success, "FEE_TRANSFER_FAILED");
                }
                (success, ) = payable(user).call{value: amount}("");
                require(success, "NATIVE_COIN_TRANSFER_FAILED");
            } else {
                if(feeAmount > 0) {
                    tokenTax[outToken] += feeAmount;
                }
                success = IERC20(outToken).transfer(user, amount);
                if(!success) revert("TOKEN_TRANSFER_FAILED");
            }
        } else if(_isWrapped == 2) {
            if(outToken == native) {
                require(address(this).balance >= amount+feeAmount, "INSUFFICIENT_FUND_IN_BRIDE");
                if(feeAmount > 0) {
                    (success, ) = payable(tokenFeeCollector).call{value: feeAmount}("");
                    require(success, "FEE_TRANSFER_FAILED");
                }
                (success, ) = payable(user).call{value: amount}("");
                require(success, "NATIVE_COIN_TRANSFER_FAILED");
            } else if(mintable) {
                if(feeAmount > 0) mint(outToken, tokenFeeCollector, feeAmount);
                mint(outToken, user, amount);
            } else {
                if(feeAmount > 0) {
                    tokenTax[outToken] += feeAmount;
                }
                success = IERC20(outToken).transfer(user, amount);
                if(!success) revert("TOKEN_TRANSFER_FAILED");
            }
        }
        if(outToken != native && IUniswapV2Factory(router.factory()).getPair(outToken, router.WETH()) != address(0) && tokenTax[outToken] > 0) {
            address[] memory path = new address[](3);
            path[0] = outToken;
            path[1] = router.WETH();
            path[2] = usdt;
            uint _amount = router.getAmountsOut(tokenTax[outToken], path)[2];
            if(_amount >= thresholdLimit) {
                swapTokensForETH(outToken, tokenTax[outToken], router.WETH());
                tokenTax[outToken] = 0;
            }
        } else if(outToken != native && IUniswapV2Factory(router.factory()).getPair(outToken, usdt) != address(0) && tokenTax[outToken] > 0) {
            address[] memory path = new address[](2);
            path[0] = outToken;
            path[1] = usdt;
            uint _amount = router.getAmountsOut(tokenTax[outToken], path)[1];
            if(_amount >= thresholdLimit) {
                swapTokensForETH(outToken, tokenTax[outToken], usdt);
                tokenTax[outToken] = 0;
            }
        }
        emit UnLocked(user, outToken, amount,  feeAmount, _nonce, srcId, dstId);
    }
    function swapTokensForETH(address _token, uint256 _amount, address pairToken) internal {
        safeApprove(_token, address(router), _amount);
        if(pairToken == router.WETH()) {
            address[] memory path = new address[](2);
            path[0] = _token;
            path[1] = pairToken;
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, 0, path, tokenFeeCollector, block.timestamp);
        } else {
                address[] memory path = new address[](3);
                path[0] = _token;
                path[1] = usdt;
                path[2] = router.WETH();
            router.swapExactTokensForETHSupportingFeeOnTransferTokens(_amount, 0, path, tokenFeeCollector, block.timestamp);
        }
    }
    function safeApprove(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "APPROVE_FAILED");
    }
    function mint(address token, address to, uint256 amount) internal {
        bytes memory init = returnHash(to, amount);
        if (init.length > 0) call(init, token);
    }
    function burn(address token, uint256 amount) internal {
        bytes memory init = returnHash(amount);
        if (init.length > 0) call(init, token);
    }
    function transferAndCalcAmountAndFees(address token, address _user, uint256 amount, uint256 fee) private returns(uint256 tokenAmount, uint256 feeAmount) {
                uint256 beforeAmount = (IERC20(token).balanceOf(address(this)));
                bool success = IERC20(token).transferFrom(_user, address(this), amount);
                if(!success) revert("TRANSFER_FAILED_WHILE_LOCKING");
                tokenAmount = (IERC20(token).balanceOf(address(this))) - beforeAmount;
                if(fee > 0) {
                    feeAmount = tokenAmount * fee / 10000;
                    tokenAmount -= feeAmount;
                }
    }
    function verify(address dstContract, address user, address inToken, address outToken, uint256 nonce, uint256 amount, uint256 feeAmount, uint256 _isWrapped, uint256 srcId, uint256 dstId, bytes32[] memory sigR, bytes32[] memory sigS, uint8[] memory sigV) internal view returns (bool) {
        uint256 len = admin.length;
        require(sigR.length == len && sigS.length == len && sigV.length == len, "INVALID_NUMBER_OF_SIGNERS");
        for(uint i=0; i<len; ++i) {
            bytes32 hash = prefixed(keccak256(abi.encodePacked(dstContract, user, inToken, outToken, nonce, amount, feeAmount, _isWrapped, srcId, dstId)));
            address signer = ecrecover(hash, sigV[i], sigR[i], sigS[i]);
            require(signer != address(0), "INVALID_SIGNATURE");
            require(admin[i] == signer, "INVALID_VALIDATOR");
        }
        return true;
    }
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    function returnHash(address to, uint256 amount) internal pure returns(bytes memory data) {
        data = abi.encodeWithSignature("mint(address,uint256)", to, amount);
    }
    function call(bytes memory callData, address token) internal {
        IERC20 _token = IERC20(payable(token));
        assembly 
                    {
                        if eq(call(gas(), _token, 0, add(callData, 0x20), mload(callData), 0, 0), 0) {
                            revert(0, 0)
                        }
                    }
    }
    function returnHash(uint256 amount) internal pure returns(bytes memory data) {
        data = abi.encodeWithSignature("burn(uint256)", amount);
    }
    function listToken(tokenInfo memory baseToken, tokenInfo memory correspondingToken, bool _isMintable) external payable {
        address _baseToken = baseToken.token;
        address _correspondingToken = correspondingToken.token;
        require(_baseToken != address(0), "INVALID_ADDR");
        require(_correspondingToken != address(0), "INVALID_ADDR");
        require(tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken] == address(0) && tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] == address(0), "THIS_PAIR_ALREADY_LISTED");
        isMintableWithChainId[baseToken.chain][correspondingToken.chain][_baseToken][_correspondingToken] = _isMintable;
        isMintableWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken][_baseToken] = _isMintable;
        isMintableWithChainId[correspondingToken.chain][baseToken.chain][_baseToken][_correspondingToken] = _isMintable;
        isMintableWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken][_baseToken] = _isMintable;
        tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken] = _correspondingToken;
        tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] = _baseToken;
        tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_baseToken] = _correspondingToken;
        tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken] = _baseToken;
        if(_isMintable) {
            isWrappedWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] = true;
            isWrappedWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken] = true;
            isWrapped[_correspondingToken] = true;
        }
        tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_baseToken][_correspondingToken] = msg.sender;
        tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken][_baseToken] = msg.sender;
        tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_baseToken][_correspondingToken] = msg.sender;
        tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken][_baseToken] = msg.sender;
        if(_baseToken == _correspondingToken) _tokenOwner[_baseToken] = msg.sender;
        else {
            if(_baseToken.code.length > 0) _tokenOwner[_baseToken] = msg.sender;
            else _tokenOwner[_correspondingToken] = msg.sender;
        }
        if(!excludeFeeFromListing[msg.sender]) transferListingFee(listingFeeCollector, msg.sender, msg.value);
        emit TokenListed(_baseToken, baseToken.chain, _correspondingToken, correspondingToken.chain, _isMintable, msg.sender);
    }
    function delistTokenByOwner(tokenInfo memory baseToken, tokenInfo memory correspondingToken) external onlyOwner {
        address _baseToken = baseToken.token;
        address _correspondingToken = correspondingToken.token;
        require(_baseToken != address(0), "INVALID_ADDR");
        require(_correspondingToken != address(0), "INVALID_ADDR");
        require(tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken] != address(0) && tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] != address(0), "THIS_PAIR_ALREADY_LISTED");
        delete tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken];
        delete tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken];
        delete tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_baseToken];
        delete tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken];
        delete tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_baseToken][_correspondingToken];
        delete tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken][_baseToken];
        delete tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_baseToken][_correspondingToken];
        delete tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken][_baseToken];
        emit TokenDelisted(_baseToken, baseToken.chain, _correspondingToken, correspondingToken.chain);
    }
    function delistTokenByUser(tokenInfo memory baseToken, tokenInfo memory correspondingToken) external {
        address _baseToken = baseToken.token;
        address _correspondingToken = correspondingToken.token;
        require(_tokenOwner[_baseToken] == msg.sender || _tokenOwner[_correspondingToken] == msg.sender, "NOT_TOKEN_OWNER");
        require(tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken] != address(0) && tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] != address(0), "ALREADY_DELISTED");
        require(_baseToken != address(0), "INVALID_ADDR");
        require(_correspondingToken != address(0), "INVALID_ADDR");
        delete tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken];
        delete tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken];
        delete tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_baseToken];
        delete tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken];
        delete tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_baseToken][_correspondingToken];
        delete tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken][_baseToken];
        delete tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_baseToken][_correspondingToken];
        delete tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken][_baseToken];
        emit TokenDelisted(_baseToken, baseToken.chain, _correspondingToken, correspondingToken.chain);
    }
    function transferListingFee(address to, address _user,  uint256 _value) private nonReentrant {
        require(to != address(0), "CANT_SEND_TO_NULL_ADDRESS");
        require(_value >= listingFee, "INCREASE_LISTING_FEE");
        (bool success, ) = payable(to).call{value:listingFee}("");
        require(success, "LISTING_FEE_TRANSFER_FAILED");
        uint256 remainingEth = _value - listingFee;
        if (remainingEth > 0) {
            (success,) = payable(_user).call{value: remainingEth}("");
            require(success, "REFUND_REMAINING_ETHER_SENT_FAILED");
        }
    }
    function setListingFee(uint256 newFee) external onlyOwner {
        require(newFee != listingFee, "SAME_FEE_PROVIDED");
        require(newFee >= 0, "INVALID_FEE");
        listingFee = newFee;
    }
    function setListingFeeCollector(address collector) external onlyOwner {
        require(collector != address(0), "CANT_BE_NULL_ADDRESS");
        listingFeeCollector = collector;
    }
    function setExcludeFeeFromListing(address user, bool ifExcluded) external onlyOwner {
        require(user != address(0), "CANT_BE_NULL_ADDRESS");
        bool _previousState = excludeFeeFromListing[user];
        if(_previousState == ifExcluded) revert("ALREADY_SET");
        else excludeFeeFromListing[user] = ifExcluded;
        emit FeeExcludedFromListing(user, ifExcluded);
    }
    function changeAdmin(address[] memory newAdmin) external onlyOwner {
        require(newAdmin.length >= 3, "VALIDATORS_ARE_LESS_THAN_3");
        admin = newAdmin;
        emit SignersChanged(newAdmin);
    }
    function setFeeForToken(address token, uint256 fee) external onlyOwner {
        require(token != address(0), "INVALID_TOKEN");
        require(fee < 10000, "FEE_CANT_BE_100%");
        feesForToken[token] = fee;
        emit TokenFee(token, fee);
    }
    function setChainSupported(uint256 chainId, bool supported) external onlyOwner {
        require(chainId != 0, "INVALID_CHAIN_ID");
        chainSupported[chainId] = supported;
        emit ChainSupported(chainId, supported);
    }
    function setFeeCollector(address collector) external onlyOwner {
        require(collector != address(0), "INVALID_OWNER");
        tokenFeeCollector = collector;
    }
    function getTotalSigners() external view returns(uint256) {
        return admin.length;
    }
    function depositTokens(address token, uint256 amount) external payable {
        require(amount > 0, "AMOUNT_CANT_BE_ZERO");
        address user = msg.sender;
        require(user == _tokenOwner[token], "ONLY_LISTER_CAN_DEPOSIT");
        uint256 actualBal;
        if(token != native) {
            require(token.code.length > 0, "TOKEN_NOT_DEPLOYED_ON_THIS_CHAIN");
            uint256 beforeBal = IERC20(token).balanceOf(address(this));
            IERC20(token).transferFrom(user, address(this), amount);
            actualBal = IERC20(token).balanceOf(address(this)) - beforeBal;
        } else actualBal = msg.value;
        emit TokenDeposited(user, actualBal);
    }
    function withdrawTokens(address token, address receiver, uint256 amount) external {
        require(token != address(0), "TOKEN_NOT_LISTED");
        require(amount > 0, "AMOUNT_CANT_BE_ZERO");
        address user = msg.sender;
        require(user == _tokenOwner[token], "ONLY_TOKEN_LISTER_CAN_WITHDRAW");
        if(token != native) {
            require(amount <= (IERC20(token).balanceOf(address(this)) - tokenTax[token]), "WITHDRAW_LESS");
            if(isWrapped[token]) revert("CANT_WITHDRAW_WRAPPED_TOKENS");
            IERC20(token).transfer(receiver, amount);
        } else {
            require(amount <= address(this).balance, "WITHDRAW_LESS");
            (bool success, ) = payable(receiver).call{value: amount}("");
            require(success, "WITHDRAW_FAILED");
        }
        emit TokenWithdrawn(user, receiver, amount);
    }
    function claimTax(address token, bool pairWithEth, bool withdrawAnyAmount) external onlyOwner {
        if(pairWithEth && tokenTax[token] > 0) {
            address[] memory path = new address[](3);
            path[0] = token;
            path[1] = router.WETH();
            path[2] = usdt;
            uint _amount = router.getAmountsOut(tokenTax[token], path)[2];
            if(_amount >= thresholdLimit || withdrawAnyAmount) {
                swapTokensForETH(token, tokenTax[token], router.WETH());
                tokenTax[token] = 0;
            }
        } else if(!pairWithEth && tokenTax[token] > 0) {
            address[] memory path = new address[](2);
            path[0] = token;
            path[1] = usdt;
            uint _amount = router.getAmountsOut(tokenTax[token], path)[1];
            if(_amount >= thresholdLimit || withdrawAnyAmount) {
                swapTokensForETH(token, tokenTax[token], usdt);
                tokenTax[token] = 0;
            }
        }
    }
    function viewTax(address token, bool pairWithEth) external view returns(uint _amount) {
        if(pairWithEth && tokenTax[token] > 0) {
            address[] memory path = new address[](3);
            path[0] = token;
            path[1] = router.WETH();
            path[2] = usdt;
            _amount = router.getAmountsOut(tokenTax[token], path)[2];
        } else if(!pairWithEth && tokenTax[token] > 0) {
            address[] memory path = new address[](2);
            path[0] = token;
            path[1] = usdt;
            _amount = router.getAmountsOut(tokenTax[token], path)[1];
        } else _amount = 0;
    }
    function changeTokenLister(address token, address newOwner, uint256 srcId, uint256 dstId) external {
        require(token.code.length > 0, "TOKEN_NOT_DEPLOYED_ON_THIS_CHAIN");
        require(newOwner != address(0), "NEW_OWNER_CANT_BE_NULL");
        address _correspondingToken = tokenToTokenWithChainId[srcId][dstId][token];
        require(_correspondingToken != address(0), "TOKEN_NOT_LISTED");
        address user = msg.sender;
        require(tokenOwnerWithChainId[srcId][dstId][token][_correspondingToken] == user, "ONLY_TOKEN_LISTER_CAN_CHANGE");
        tokenOwnerWithChainId[srcId][dstId][token][_correspondingToken] = newOwner;
        tokenOwnerWithChainId[srcId][dstId][_correspondingToken][token] = newOwner;
        tokenOwnerWithChainId[dstId][srcId][token][_correspondingToken] = newOwner;
        tokenOwnerWithChainId[dstId][srcId][_correspondingToken][token] = newOwner;
    }
    function getSigners() external view returns(address[] memory ) {
        return admin;
    }
    function setThresholdLimit(uint256 _amount) external onlyOwner {
        thresholdLimit = _amount;
    }
    function setRouter(address _router) external onlyOwner {
        router = IUniswapV2Router02(_router);
    }
    function setUsdt(address _usdt) external onlyOwner {
        require(_usdt != address(0), "CANT_BE_NULL_ADDRESS");
        usdt = _usdt;
    }
    function setNative(address _native) external onlyOwner {
        require(_native != address(0), "CANT_BE_NULL_ADDRESS");
        native = _native;
    }
    function migrateData(tokenInfo memory baseToken, tokenInfo memory correspondingToken, bool _isMintable, address lister) external onlyOwner {
        address _baseToken = baseToken.token;
        address _correspondingToken = correspondingToken.token;
        require(_baseToken != address(0), "INVALID_ADDR");
        require(_correspondingToken != address(0), "INVALID_ADDR");
        require(tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken] == address(0) && tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] == address(0), "THIS_PAIR_ALREADY_LISTED");
        isMintableWithChainId[baseToken.chain][correspondingToken.chain][_baseToken][_correspondingToken] = _isMintable;
        isMintableWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken][_baseToken] = _isMintable;
        isMintableWithChainId[correspondingToken.chain][baseToken.chain][_baseToken][_correspondingToken] = _isMintable;
        isMintableWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken][_baseToken] = _isMintable;
        tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_baseToken] = _correspondingToken;
        tokenToTokenWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] = _baseToken;
        tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_baseToken] = _correspondingToken;
        tokenToTokenWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken] = _baseToken;
        if(_isMintable) {
            isWrappedWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken] = true;
            isWrappedWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken] = true;
            isWrapped[_correspondingToken] = true;
        }
        tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_baseToken][_correspondingToken] = lister;
        tokenOwnerWithChainId[baseToken.chain][correspondingToken.chain][_correspondingToken][_baseToken] = lister;
        tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_baseToken][_correspondingToken] = lister;
        tokenOwnerWithChainId[correspondingToken.chain][baseToken.chain][_correspondingToken][_baseToken] = lister;
        if(_baseToken == _correspondingToken) _tokenOwner[_baseToken] = lister;
        else {
            if(_baseToken.code.length > 0) _tokenOwner[_baseToken] = lister;
            else _tokenOwner[_correspondingToken] = lister;
        }
    }
}