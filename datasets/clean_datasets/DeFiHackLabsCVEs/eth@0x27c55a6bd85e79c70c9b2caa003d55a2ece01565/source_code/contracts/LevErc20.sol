pragma solidity ^0.8.10;
import "./LevToken.sol";
contract LevErc20 is LevToken, LevErc20Interface {
    string public prologue;
    function setDepErc20(DepErc20Interface depErc20_) public override{
        super.setDepErc20(depErc20_);
    }
    function initialize(address underlying_,
                        address borrowUnderlying_,
                        TensorpricerInterface tensorpricer_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_) public override initializer {
        admin = payable(msg.sender);
        super.initialize(underlying_, borrowUnderlying_, tensorpricer_, name_, symbol_, decimals_);
        underlying = underlying_;
        EIP20Interface(underlying).totalSupply();
        borrowUnderlying = borrowUnderlying_;
        EIP20Interface(borrowUnderlying).totalSupply();
        netAssetValue = initialNetAssetValueMantissa;
        hisHighNav = initialNetAssetValueMantissa;
        targetLevRatio = initialTargetLevRatio;
    }
    function setPrologue() public {
        require(msg.sender == admin, "only admin may set prologue");
        prologue = 'leverc20 success';
    }
    function getAdmin() override external view returns (address payable) {
        return admin;
    }
    function mint(uint mintAmount) override external returns (uint) {
        require(mintAmount > 0, "cannot mint <= 0");
        mintInternal(mintAmount);
        return NO_ERROR;
    }
    function redeem(uint redeemTokens) override external returns (uint) {
        redeemInternal(redeemTokens);
        return NO_ERROR;
    }
    function sweepToken(EIP20NonStandardInterface token) override external {
        require(msg.sender == admin, "DepErc20::sweepToken: only admin can sweep tokens");
        require(address(token) != underlying, "DepErc20::sweepToken: can not sweep underlying token");
        uint256 balance = token.balanceOf(address(this));
        token.transfer(admin, balance);
    }
    function getExtraBorrowDemand() override external view returns (uint256){
        return extraBorrowDemand;
    }
    function getExtraBorrowSupply() override external view returns (uint256){
        return extraBorrowSupply;
    }
    function forceRepay(uint256 repayAmountInUSDT) override virtual external returns (uint) {
        require(msg.sender==address(depErc20), "only depToken can call forceRepay");
        return forceRepayInternal(repayAmountInUSDT);
    }
    function updateLedger() override virtual external {
        require(msg.sender==address(depErc20), "only depToken can call updateLedger");
        return updateLedgerInternal();
    }
    function getCashPrior() virtual override internal view returns (uint) {
        EIP20Interface token = EIP20Interface(underlying);
        return token.balanceOf(address(this));
    }
    function doTransferIn(address from, uint amount) virtual override internal returns (uint) {
        address underlying_ = underlying;
        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying_);
        uint balanceBefore = EIP20Interface(underlying_).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);
        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       
                    success := not(0)          
                }
                case 32 {                      
                    returndatacopy(0, 0, 32)
                    success := mload(0)        
                }
                default {                      
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");
        uint balanceAfter = EIP20Interface(underlying_).balanceOf(address(this));
        return balanceAfter - balanceBefore;   
    }
    function doTransferOut(address payable to, uint amount) virtual override internal {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        token.transfer(to, amount);
        bool success;
        assembly {
            switch returndatasize()
                case 0 {                      
                    success := not(0)          
                }
                case 32 {                     
                    returndatacopy(0, 0, 32)
                    success := mload(0)        
                }
                default {                     
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }
}