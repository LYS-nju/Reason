pragma solidity ^0.8.10;
import "./MatrixpricerInterface.sol";
import "./InterestRateModel.sol";
import "./LevTokenInterfaces.sol";
import "./EIP20NonStandardInterface.sol";
import "./ErrorReporter.sol";
contract DepTokenStorage {
    bool internal _notEntered;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint internal constant reserveFactorMaxMantissa = 1e18;
    address payable public admin;
    address payable public pendingAdmin;
    MatrixpricerInterface public matrixpricer;
    InterestRateModel public interestRateModel;
    LevErc20Interface public levErc20;
    uint internal initialExchangeRateMantissa;  
    uint public reserveFactorMantissa;  
    uint public accrualBlockNumber;
    uint public borrowIndex;
    uint public totalBorrows;   
    uint public totalReserves;   
    uint public totalSupply;    
    mapping (address => uint) internal accountTokens;
    mapping (address => mapping (address => uint)) internal transferAllowances;
    uint internal constant minTransferAmtUSDT = 50000e6;
    uint internal constant thresholdUSDT = 300000e6;
    uint internal constant extraUSDT = 100000e6;
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }
    mapping(address => BorrowSnapshot) internal accountBorrows;
    uint public constant protocolSeizeShareMantissa = 2.8e16; 
}
abstract contract DepTokenInterface is DepTokenStorage {
    bool public constant isDepToken = true;
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);
    event Mint(address minter, uint mintAmount, uint mintTokens, uint apy);
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens, uint apy);
    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);
    event RepayBorrow(address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows, bool liquidate);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewMatrixpricer(MatrixpricerInterface oldMatrixpricer, MatrixpricerInterface newMatrixpricer);
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);
    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);
    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    function transfer(address dst, uint amount) virtual external returns (bool);
    function transferFrom(address src, address dst, uint amount) virtual external returns (bool);
    function approve(address spender, uint amount) virtual external returns (bool);
    function allowance(address owner, address spender) virtual external view returns (uint);
    function balanceOf(address owner) virtual external view returns (uint);
    function balanceOfUnderlying(address owner) virtual external returns (uint);
    function balanceOfUnderlyingView(address owner) virtual external view returns (uint);
    function getAccountSnapshot(address account) virtual external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() virtual external view returns (uint);
    function supplyRatePerBlock() virtual public view returns (uint);
    function totalBorrowsCurrent() virtual external returns (uint);
    function exchangeRateCurrent() virtual external returns (uint);
    function exchangeRateStored() virtual external view returns (uint);
    function getCash() virtual external view returns (uint);
    function getCompoundBalance() virtual external view returns (uint);
    function accrueInterest() virtual external returns (uint);
    function _setPendingAdmin(address payable newPendingAdmin) virtual external returns (uint);
    function _acceptAdmin() virtual external returns (uint);
    function _setMatrixpricer(MatrixpricerInterface newMatrixpricer) virtual external returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) virtual external returns (uint);
    function _reduceReserves(uint reduceAmount) virtual external returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) virtual external returns (uint);
}
contract DepErc20Storage {
    address public underlying;
}
abstract contract DepErc20Interface is DepErc20Storage {
    function mint(uint mintAmount) virtual external returns (uint);
    function redeem(uint redeemTokens, uint redeemAmount) virtual external returns (uint);
    function borrow(uint borrowAmount) virtual external returns (uint);
    function repayBorrow(uint repayAmount, bool liquidate) virtual external returns (uint);
    function getUnborrowedUSDTBalance() virtual external view returns (uint);
    function getTotalBorrows() virtual external view returns (uint);    
    function getTotalBorrowsAfterAccrueInterest() virtual external returns (uint);    
    function _addReserves(uint addAmount) virtual external returns (uint);
}