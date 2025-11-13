pragma solidity ^0.8.10;
import "./TensorpricerInterface.sol";
import "./InterestRateModel.sol";
import "./DepTokenInterfaces.sol";
import "./EIP20NonStandardInterface.sol";
import "./ErrorReporter.sol";
import "./DepositWithdraw.sol";
import "./CurveSwap.sol";
contract LevTokenStorage {
    bool internal _notEntered;
    string public name;
    string public symbol;
    uint8 public decimals;
    address payable public admin;
    address payable public pendingAdmin;
    TensorpricerInterface public tensorpricer;
    DepErc20Interface public depErc20;
    uint internal constant initialNetAssetValueMantissa = 1e18;  
    uint internal constant initialTargetLevRatio = 5e18;
    uint public totalSupply;    
    uint public borrowBalanceUSDT;  
    uint public borrowBalanceUSDC;  
    uint public totalAssetValue;  
    uint public netAssetValue;  
    uint public levRatio;   
    uint public extraBorrowDemand;  
    uint public extraBorrowSupply;  
    uint public targetLevRatio; 
    mapping (address => uint) internal accountTokens;
    mapping (address => mapping (address => uint)) internal transferAllowances;
    uint internal constant minTransferAmtUSDC = 50000e6;
    uint internal constant thresholdUSDC = 300000e6;
    uint internal constant extraUSDC = 100000e6;
    struct checkRebalanceRes {
        uint res;
        uint targetLevRatio;
        uint tmpBorrowBalanceUSDC;
        uint tmpTotalAssetValue;
        uint tmpLevRatio;
    }
    uint internal hisHighNav;
    uint internal levReserve;   
    uint internal constant redeemFeePC = 1e15;
    uint internal constant perfPC = 1e17;
    uint internal redeemAmountInUSDC;
}
abstract contract LevTokenInterface is LevTokenStorage {
    bool public constant isLevToken = true;
    event Mint(address minter, uint mintAmount, uint mintTokens, uint nav);
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens, uint nav);
    event ForceRepay(address forcer, uint repayAmount);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewTensorpricer(TensorpricerInterface oldTensorpricer, TensorpricerInterface newTensorpricer);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event ReservesReduced(address admin, uint reduceAmount, uint newLevReserve);
    function transfer(address dst, uint amount) virtual external returns (bool);
    function transferFrom(address src, address dst, uint amount) virtual external returns (bool);
    function approve(address spender, uint amount) virtual external returns (bool);
    function allowance(address owner, address spender) virtual external view returns (uint);
    function balanceOf(address owner) virtual external view returns (uint);
    function getNAV(address owner) virtual external view returns (uint);
    function getAccountSnapshot(address account) virtual external view returns (uint, uint);
    function getCash() virtual external view returns (uint);
    function getCompoundBalance() virtual external view returns (uint);
    function getLevReserve() virtual external view returns (uint);
    function getHisHighNav() virtual external view returns (uint);
    function _setPendingAdmin(address payable newPendingAdmin) virtual external returns (uint);
    function _acceptAdmin() virtual external returns (uint);
    function _setTensorpricer(TensorpricerInterface newTensorpricer) virtual external returns (uint);
    function _reduceReserves(uint reduceAmount) virtual external returns (uint);
}
contract LevErc20Storage {
    address public underlying;  
    address public borrowUnderlying;    
}
abstract contract LevErc20Interface is LevErc20Storage {
    function getAdmin() virtual external returns (address payable);
    function mint(uint mintAmount) virtual external returns (uint);
    function redeem(uint redeemTokens) virtual external returns (uint);
    function sweepToken(EIP20NonStandardInterface token) virtual external;
    function getExtraBorrowDemand() virtual external view returns (uint256);
    function getExtraBorrowSupply() virtual external view returns (uint256);
    function forceRepay(uint256 repayAmount) virtual external returns (uint);
    function updateLedger() virtual external;
}