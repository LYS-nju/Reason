pragma solidity ^0.8.10;
import "hardhat/console.sol";
import "./TensorpricerInterface.sol";
import "./LevTokenInterfaces.sol";
import "./ErrorReporter.sol";
import "./EIP20Interface.sol";
import "./ExponentialNoError.sol";
import "./DepositWithdraw.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
abstract contract LevToken is LevTokenInterface, DepositWithdraw, CurveSwap, ExponentialNoError, TokenErrorReporter, Initializable {
    function setDepErc20(DepErc20Interface depErc20_) public virtual{
        require(msg.sender == admin, "only admin may set depErc20");
        depErc20 = depErc20_;
    }
    function initialize(address underlying_,
                        address borrowUnderlying_,
                        TensorpricerInterface tensorpricer_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_) public virtual onlyInitializing {
        require(msg.sender == admin, "only admin may initialize the market");
        uint err = _setTensorpricer(tensorpricer_);
        require(err == NO_ERROR, "setting tensorpricer failed");
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        _notEntered = true;
    }
    function setAddressesForCompound(address compoundV2cUSDCAddress_, address compoundV2cUSDTAddress_, address USDCAddress_, address USDTAddress_) public {
        require(msg.sender==admin, "only admin can set addresses in general");
        setAddresses(compoundV2cUSDCAddress_, compoundV2cUSDTAddress_, USDCAddress_, USDTAddress_);
    }
    function setAddressesForCurve(address TriPool_, address ADDRESSPROVIDER_, address USDC_ADDRESS_, address USDT_ADDRESS_) public {
        require(msg.sender==admin, "only admin can set addresses in general");
        setAddressesCurve(TriPool_, ADDRESSPROVIDER_, USDC_ADDRESS_, USDT_ADDRESS_);
    }
    function transferTokens(address spender, address src, address dst, uint tokens) internal returns (uint) {
        uint allowed = tensorpricer.transferAllowed(address(this), src, dst, tokens);
        if (allowed != 0) {
            revert TransferTensorpricerRejection(allowed);   
        }
        if (src == dst) {
            revert TransferNotAllowed();
        }
        uint startingAllowance = 0;
        if (spender == src) {
            startingAllowance = type(uint).max;
        } else {
            startingAllowance = transferAllowances[src][spender];
            if(startingAllowance < tokens){
                revert TransferNotEnoughAllowance();
            }
        }
        uint allowanceNew = startingAllowance - tokens;
        uint srLevTokensNew = accountTokens[src] - tokens;
        uint dstTokensNew = accountTokens[dst] + tokens;
        accountTokens[src] = srLevTokensNew;
        accountTokens[dst] = dstTokensNew;
        if (startingAllowance != type(uint).max) {
            transferAllowances[src][spender] = allowanceNew;
        }
        emit Transfer(src, dst, tokens);
        return NO_ERROR;
    }
    function transfer(address dst, uint256 amount) override external nonReentrant returns (bool) {
        return transferTokens(msg.sender, msg.sender, dst, amount) == NO_ERROR;
    }
    function transferFrom(address src, address dst, uint256 amount) override external nonReentrant returns (bool) {
        return transferTokens(msg.sender, src, dst, amount) == NO_ERROR;
    }
    function approve(address spender, uint256 amount) override external returns (bool) {
        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }
    function allowance(address owner, address spender) override external view returns (uint256) {
        return transferAllowances[owner][spender];
    }
    function balanceOf(address owner) override external view returns (uint256) {
        return accountTokens[owner];
    }
    function getNAV(address owner) override external view returns (uint) {
        Exp memory nav = Exp({mantissa: netAssetValue});
        return mul_ScalarTruncate(nav, accountTokens[owner]);
    }
    function getAccountSnapshot(address account) override external view returns (uint, uint) {
        return (
            NO_ERROR,
            accountTokens[account]
        );
    }
    function getCash() override external view returns (uint) {
        return getCashPrior();
    }
    function getCompoundBalance() override external view returns (uint) {
        return getCmpBalanceInternal();
    }
    function getCmpBalanceInternal() internal view returns (uint) {
        Exp memory exchangeRate = Exp({mantissa: getCmpUSDCExchRate()});
        return mul_ScalarTruncate(exchangeRate, getCUSDCNumber());
    }
    function getLevReserve() override external view returns (uint) {
        return levReserve;
    }
    function getHisHighNav() override external view returns (uint) {
        return hisHighNav;
    }
    function updateNetAssetValue(uint latestBorrowBalanceUSDC, uint offset) internal {
        netAssetValue = calcNetAssetValue(latestBorrowBalanceUSDC, offset);
    }
    function calcNetAssetValue(uint latestBorrowBalanceUSDC, uint offset) internal view returns (uint){
        uint _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return initialNetAssetValueMantissa;
        } else {
            uint balanceUSDCExReserves = getCashExReserves() + getCmpBalanceInternal();
            if(balanceUSDCExReserves > latestBorrowBalanceUSDC + offset){
                return (balanceUSDCExReserves - latestBorrowBalanceUSDC - offset) * expScale / _totalSupply;
            }else{
                return 0;
            }
        }
    }
    function updateStats(bool recalc, uint tmpTotalAssetValue, uint tmpLevRatio, uint redeemTokensIn) internal {
        if(recalc){
            uint availCash = getCashExReserves() + getCmpBalanceInternal();
            if(redeemTokensIn > 0){
                uint currTotalAssetValue;
                uint amtToSubtract;
                if(availCash > borrowBalanceUSDC){
                    currTotalAssetValue = availCash - borrowBalanceUSDC;
                    uint currNav = currTotalAssetValue * expScale / totalSupply;
                    redeemAmountInUSDC = currNav * redeemTokensIn / expScale;
                    amtToSubtract = borrowBalanceUSDC + redeemAmountInUSDC;
                }else{
                    currTotalAssetValue = 0;
                    amtToSubtract = borrowBalanceUSDC;
                }
                if(availCash > amtToSubtract){
                    totalAssetValue = availCash - amtToSubtract;
                    levRatio = borrowBalanceUSDC*expScale / totalAssetValue;
                }else{
                    totalAssetValue = 0;
                    levRatio = 0;
                }
            }else{
                uint amtToSubtract = borrowBalanceUSDC;
                if(availCash > amtToSubtract){
                    totalAssetValue = availCash - amtToSubtract;
                    levRatio = borrowBalanceUSDC*expScale / totalAssetValue;
                }else{
                    totalAssetValue = 0;
                    levRatio = 0;
                }
            }
        }else{
            if(redeemTokensIn > 0){
                uint availCash = getCashExReserves() + getCmpBalanceInternal();
                uint currNav = tmpTotalAssetValue * expScale / (totalSupply - redeemTokensIn);
                redeemAmountInUSDC = currNav * redeemTokensIn / expScale;
                uint amtToSubtract = borrowBalanceUSDC + redeemAmountInUSDC;
                if(availCash > amtToSubtract){
                    totalAssetValue = availCash - amtToSubtract;
                    levRatio = borrowBalanceUSDC*expScale / totalAssetValue;
                }else{
                    totalAssetValue = 0;
                    levRatio = 0;
                }
            }else{  
                totalAssetValue = tmpTotalAssetValue;
                levRatio = tmpLevRatio; 
            }
        }
    }
    function refreshTargetLevRatio(uint fx_USDTUSDC_Mantissa) public pure returns (uint, uint, uint) {
        if(fx_USDTUSDC_Mantissa < 6e17 || fx_USDTUSDC_Mantissa > 14e17){
            return (1e18, 0, 2e18);
        }else if(fx_USDTUSDC_Mantissa < 9e17 || fx_USDTUSDC_Mantissa > 11e17){
            return (3e18, 2e18, 4e18);
        }else{
            return (5e18, 4e18, 6e18);
        }
    }
    function updateExtraBorrow(Exp memory fx_USDTUSDC, uint tmpTotalAssetValue, uint targetLevRatio) internal {
        uint targetBorrowUSDT = div_(targetLevRatio*tmpTotalAssetValue/expScale, fx_USDTUSDC);
        if(targetBorrowUSDT > borrowBalanceUSDT){
            extraBorrowDemand = targetBorrowUSDT - borrowBalanceUSDT;
            extraBorrowSupply = 0;
        }else{
            extraBorrowDemand = 0;
            extraBorrowSupply = borrowBalanceUSDT - targetBorrowUSDT;
        }
    }
    function updateBorrowBalances(uint fxToUse, uint newBorrowBalanceUSDT) internal {
        borrowBalanceUSDT = newBorrowBalanceUSDT;
        borrowBalanceUSDC = newBorrowBalanceUSDT * fxToUse / expScale;
    }
    function releverage(uint newBorrowDemand) internal {
        uint transFx = depErc20.borrow(newBorrowDemand);
        updateBorrowBalances(transFx, depErc20.getTotalBorrows());  
    }
    function deleverage(Exp memory fx_USDTUSDC, uint newBorrowSupply, bool isRedeemAll) internal returns (bool) {
        uint amtUSDC = mul_(newBorrowSupply, fx_USDTUSDC);
        if(isRedeemAll){
            amtUSDC = amtUSDC * 105 / 100;  
            withdrawUSDCfromCmp(getCmpBalanceInternal());  
        }else{
            uint cashOnBook = getCashExReserves();
            if(amtUSDC > cashOnBook){   
                uint amtUSDCmissing = amtUSDC - cashOnBook;
                uint compoundBalance = getCmpBalanceInternal();
                if(compoundBalance > (amtUSDCmissing + extraUSDC)){
                    withdrawUSDCfromCmp(amtUSDCmissing + extraUSDC);
                }else{
                    withdrawUSDCfromCmp(compoundBalance);  
                }
            }
        }
        uint latestCashOnBook = getCashExReserves();
        uint finalRepayAmount;
        if(latestCashOnBook >= amtUSDC){ 
            finalRepayAmount = changeUSDC2USDT(amtUSDC, 0, address(depErc20));
            uint transFx = amtUSDC * expScale / finalRepayAmount;
            depErc20.repayBorrow(finalRepayAmount, false);
            updateBorrowBalances(transFx, depErc20.getTotalBorrows());  
        }else{
            finalRepayAmount = changeUSDC2USDT(latestCashOnBook, 0, address(depErc20)); 
            uint transFx = latestCashOnBook * expScale / finalRepayAmount;
            if(isRedeemAll){
                uint depTotalBorrows = depErc20.getTotalBorrows();
                if(depTotalBorrows > finalRepayAmount){ 
                    updateBorrowBalances(transFx, depTotalBorrows - finalRepayAmount);
                }else{
                    updateBorrowBalances(transFx, 0); 
                }
                depErc20.repayBorrow(finalRepayAmount, true);
                return true;    
            }else{
                depErc20.repayBorrow(finalRepayAmount, false);
                updateBorrowBalances(transFx, depErc20.getTotalBorrows());  
            }
        }
        return false;
    }
    function deleverageAll() internal returns (bool) {
        uint cashOnBook = getCashExReserves();
        uint compoundBalance = getCmpBalanceInternal();
        if(compoundBalance > 0) {
            withdrawUSDCfromCmp(compoundBalance);  
        }
        cashOnBook = getCashExReserves();   
        if(cashOnBook > 0){
            uint finalRepayAmount = changeUSDC2USDT(cashOnBook, 0, address(depErc20));
            uint transFx = cashOnBook * expScale / finalRepayAmount;
            uint origBorrowBalanceUSDT = depErc20.getTotalBorrowsAfterAccrueInterest();    
            extraBorrowDemand = 0;
            extraBorrowSupply = 0;
            if(origBorrowBalanceUSDT > finalRepayAmount){
                updateBorrowBalances(transFx, origBorrowBalanceUSDT - finalRepayAmount);  
                depErc20.repayBorrow(finalRepayAmount, true);
                updateStats(false, 0, 0, 0);
                tensorpricer._setMintPausedLev(address(this), true);
                tensorpricer._setRedeemPausedLev(address(this), true);
            }else{  
                updateBorrowBalances(transFx, 0);
                depErc20.repayBorrow(finalRepayAmount, false);
                updateStats(true, 0, 0, 0);
                return false;
            }
        }
        return true;
    }
    function checkRebalanceExt() external view returns (checkRebalanceRes memory) {
        return checkRebalance(2, 0);
    }
    function checkRebalance(uint callingSrc, uint tmpRedeemAmountInUSDC) internal view returns (checkRebalanceRes memory) {
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        (uint targetLevRatio, uint releverageTrigger, uint deleverageTrigger) = refreshTargetLevRatio(fx_USDTUSDC_Mantissa);
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        if(callingSrc==0){   
            uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
            uint tmpBalanceUSDC = getCashExReserves() + getCmpBalanceInternal();
            if(tmpBalanceUSDC > tmpBorrowBalanceUSDC){
                uint tmpTotalAssetValue = tmpBalanceUSDC - tmpBorrowBalanceUSDC;
                uint tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
                if(tmpLevRatio < releverageTrigger){    
                    return checkRebalanceRes({res:1, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                }else if(tmpLevRatio > deleverageTrigger){
                    return checkRebalanceRes({res:2, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                }else{  
                    return checkRebalanceRes({res:0, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                }
            }else{
                return checkRebalanceRes({res:3, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:0, tmpLevRatio:0});
            }
        }else if (callingSrc==1){  
            if(totalSupply > 0){
                uint tmpBalanceUSDC = getCashExReserves() + getCmpBalanceInternal() - tmpRedeemAmountInUSDC;
                uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
                if(tmpBalanceUSDC > tmpBorrowBalanceUSDC){
                    uint tmpTotalAssetValue = tmpBalanceUSDC - tmpBorrowBalanceUSDC;
                    uint tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
                    if(tmpLevRatio > deleverageTrigger){ 
                        return checkRebalanceRes({res:2, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else if(tmpLevRatio < releverageTrigger){
                        return checkRebalanceRes({res:1, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else{  
                        return checkRebalanceRes({res:0, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }
                }else{
                    return checkRebalanceRes({res:3, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:0, tmpLevRatio:0});
                }
            }else{
                return checkRebalanceRes({res:0, targetLevRatio:0, tmpBorrowBalanceUSDC:0, tmpTotalAssetValue:0, tmpLevRatio:0});
            }
        }else{  
            if(totalSupply > 0){
                uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
                uint tmpBalanceUSDC = getCashExReserves() + getCmpBalanceInternal();
                if(tmpBalanceUSDC > tmpBorrowBalanceUSDC){
                    uint tmpTotalAssetValue = tmpBalanceUSDC - tmpBorrowBalanceUSDC;
                    uint tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
                    if(tmpLevRatio < releverageTrigger){    
                        return checkRebalanceRes({res:1, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else if(tmpLevRatio > deleverageTrigger){ 
                        return checkRebalanceRes({res:2, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else{
                        return checkRebalanceRes({res:0, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }
                }else{
                    return checkRebalanceRes({res:3, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:0, tmpLevRatio:0});
                }
            }else{
                return checkRebalanceRes({res:0, targetLevRatio:0, tmpBorrowBalanceUSDC:0, tmpTotalAssetValue:0, tmpLevRatio:0});
            }
        }
    }
    function doRebalanceExt() public {
        checkRebalanceRes memory myRes = checkRebalance(2, 0);
        doRebalance(2, myRes, 0);
    }
    function doRebalance(uint callingSrc, checkRebalanceRes memory myRes, uint redeemTokensIn) internal {
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        targetLevRatio = myRes.targetLevRatio;  
        if(myRes.res == 3){ 
            if(deleverageAll()){
                netAssetValue = 0;
            }else{
                updateNetAssetValue(borrowBalanceUSDC, 0);
            }
        }else{
            if(callingSrc==0){   
                if(myRes.res==1){    
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowDemand > 0) {
                        releverage(extraBorrowDemand);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, 0);
                }else if(myRes.res==2){
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowSupply > 0){
                        deleverage(fx_USDTUSDC, extraBorrowSupply, false);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, 0);
                }else if(myRes.res==0){  
                    borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    updateStats(false, myRes.tmpTotalAssetValue, myRes.tmpLevRatio, 0);
                    extraBorrowDemand = 0;
                    extraBorrowSupply = 0;
                }
            }else if (callingSrc==1){  
                if(myRes.res==2){ 
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowSupply > 0){
                        deleverage(fx_USDTUSDC, extraBorrowSupply, false);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, redeemTokensIn);
                }else if(myRes.res==1){
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowDemand > 0) {
                        releverage(extraBorrowDemand);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, redeemTokensIn);
                }else if(myRes.res==0){  
                    borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    updateStats(false, myRes.tmpTotalAssetValue, myRes.tmpLevRatio, redeemTokensIn);
                    extraBorrowDemand = 0;
                    extraBorrowSupply = 0;
                }
            }else{  
                if(myRes.res==1){    
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowDemand > 0) {
                        releverage(extraBorrowDemand);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    uint currUSDCBalance = getCashExReserves();
                    if(checkCompound(currUSDCBalance)){
                        supplyUSDC(currUSDCBalance - thresholdUSDC);
                    }
                    updateStats(true, 0, 0, 0);
                    updateNetAssetValue(borrowBalanceUSDC, 0);  
                }else if(myRes.res==2){ 
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowSupply > 0){
                        deleverage(fx_USDTUSDC, extraBorrowSupply, false);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, 0);
                    updateNetAssetValue(borrowBalanceUSDC, 0);
                }
            }
        }
    }
    function redeemAllRebalance() internal returns (uint){
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        extraBorrowDemand = 0;
        extraBorrowSupply = borrowBalanceUSDT;
        bool isLiquidate = deleverage(fx_USDTUSDC, extraBorrowSupply, true);    
        if(isLiquidate){
            updateStats(false, 0, 0, 0);
            netAssetValue = 0;
            tensorpricer._setMintPausedLev(address(this), true);
            tensorpricer._setRedeemPausedLev(address(this), true);
            return 0;
        }else{
            uint currUSDCBalance = getCashExReserves(); 
            uint redeemFeeBeforeLevRatio = (redeemFeePC * currUSDCBalance) / expScale;
            uint redeemFee = (targetLevRatio * redeemFeeBeforeLevRatio) / expScale;
            if(currUSDCBalance <= redeemFee){
                redeemFee = currUSDCBalance;
                currUSDCBalance = 0;
            }else{
                currUSDCBalance = currUSDCBalance - redeemFee;
            }
            levReserve = levReserve + redeemFee;
            updateStats(false, 0, 0, 0);
            netAssetValue = initialNetAssetValueMantissa;
            return currUSDCBalance;
        }
    }
    function checkCompound(uint currUSDCBalance) internal pure returns (bool) {
        if(currUSDCBalance > minTransferAmtUSDC+thresholdUSDC){
            return true;
        }else{
            return false;
        }
    }
    function checkLeveragibility(Exp memory fx_USDTUSDC, uint mintAmount) internal view returns (bool) {
        uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
        uint availCash = getCashExReserves() + getCmpBalanceInternal();
        uint tmpLevRatio = 0;
        if(availCash > tmpBorrowBalanceUSDC){   
            uint tmpTotalAssetValue = availCash - tmpBorrowBalanceUSDC;
            tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
        }else{  
            (uint initLevRatio,,) = refreshTargetLevRatio(fx_USDTUSDC.mantissa);
            tmpLevRatio = initLevRatio;
        }
        uint loanNeeded = tmpLevRatio * div_(mintAmount, fx_USDTUSDC) / expScale;
        uint unborrowedCashAtDep = depErc20.getUnborrowedUSDTBalance();
        return unborrowedCashAtDep > loanNeeded;
    }
    function payback(address minter, uint _totalAssetValue) internal {
        if(_totalAssetValue > 0){
            uint compoundBalance = getCmpBalanceInternal();
            if(compoundBalance > 0){
                withdrawUSDCfromCmp(compoundBalance);  
            }
            doTransferOut(payable(minter), _totalAssetValue);
            emit Transfer(minter, address(this), 0);
        }
        updateStats(false, 0, 0, 0);
        extraBorrowDemand = 0;
        extraBorrowSupply = 0;
        netAssetValue = 0;
        tensorpricer._setMintPausedLev(address(this), true);
        tensorpricer._setRedeemPausedLev(address(this), true);
    }
    function mintInternal(uint mintAmount) internal nonReentrant {
        address minter = msg.sender;   
        uint allowed = tensorpricer.mintAllowed(address(this), minter);
        if (allowed != 0) {
            revert MintTensorpricerRejection(allowed);
        }
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        if(!checkLeveragibility(fx_USDTUSDC, mintAmount)){
            return;
        }
        uint actualMintAmount = doTransferIn(minter, mintAmount);
        uint mintTokens;
        uint navAfterTradeMantissa;
        Exp memory tmpNav;
        uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
        uint tmpNavMantissa = calcNetAssetValue(tmpBorrowBalanceUSDC, actualMintAmount);
        bool skipRebalance = false;
        if(tmpNavMantissa == 0){
            if(deleverageAll()){
                return;
            }
            skipRebalance = true;
        }
        tmpNav = Exp({mantissa: takePerfFee(tmpNavMantissa)});
        checkRebalanceRes memory myRes;
        if(!skipRebalance){
            myRes = checkRebalance(0, 0);
            doRebalance(0, myRes, 0);    
        }
        if(!skipRebalance && myRes.res==0){   
            mintTokens = div_(actualMintAmount, tmpNav);
        }else{  
            uint _totalSupply = totalSupply;
            if(_totalSupply == 0){
                navAfterTradeMantissa = initialNetAssetValueMantissa;
                mintTokens = div_(actualMintAmount, Exp({mantissa: navAfterTradeMantissa}));
            }else{
                uint _totalAssetValue = totalAssetValue;
                if(_totalAssetValue > actualMintAmount){
                    navAfterTradeMantissa = (_totalAssetValue - actualMintAmount) * expScale / _totalSupply;
                    mintTokens = div_(actualMintAmount, Exp({mantissa: navAfterTradeMantissa}));
                }else{
                    payback(minter, _totalAssetValue);
                    return;
                }
            }
        }
        uint currUSDCBalance = getCashExReserves();
        if(checkCompound(currUSDCBalance)){
            supplyUSDC(currUSDCBalance - thresholdUSDC);
        }
        totalSupply = totalSupply + mintTokens;
        accountTokens[minter] = accountTokens[minter] + mintTokens;
        updateNetAssetValue(borrowBalanceUSDC, 0);
        emit Mint(minter, actualMintAmount, mintTokens, netAssetValue);
        emit Transfer(address(this), minter, mintTokens);
    }
    function redeemInternal(uint redeemTokensIn) internal nonReentrant {
        address payable redeemer = payable(msg.sender);
        uint allowed = tensorpricer.redeemAllowed(address(this), redeemer, redeemTokensIn);
        if (allowed != 0) {
            revert RedeemTensorpricerRejection(allowed);
        }
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, Exp({mantissa: fx_USDTUSDC_Mantissa}));
        uint tmpNetAssetValue = calcNetAssetValue(tmpBorrowBalanceUSDC, 0);
        (uint targetLevRatio,,) = refreshTargetLevRatio(fx_USDTUSDC_Mantissa);
        uint updatedTmpNavMantissa = takePerfFee(tmpNetAssetValue);  
        uint tmpRedeemAmount = mul_ScalarTruncate(Exp({mantissa: updatedTmpNavMantissa}), redeemTokensIn);
        uint trueRedeemAmount;
        if(totalSupply == redeemTokensIn){  
            trueRedeemAmount = redeemAllRebalance();
            totalSupply = 0;
        }else{
            redeemAmountInUSDC = 0; 
            if(tmpNetAssetValue > 0){
                doRebalance(1, checkRebalance(1, tmpRedeemAmount), redeemTokensIn);    
            }else{
                if(deleverageAll()){
                    emit Redeem(redeemer, 0, redeemTokensIn, netAssetValue);
                    return;
                }
            }
            uint redeemFeeBeforeLevRatio = (redeemFeePC * redeemAmountInUSDC) / expScale;
            uint redeemFee = (targetLevRatio * redeemFeeBeforeLevRatio) / expScale;
            trueRedeemAmount = redeemAmountInUSDC - redeemFee;
            levReserve = levReserve + redeemFee;
            uint currUSDCBalance = getCashExReserves();
            if (redeemAmountInUSDC > currUSDCBalance) { 
                uint amtNeeded = redeemAmountInUSDC - currUSDCBalance;
                uint compoundBalance = getCmpBalanceInternal();
                if(compoundBalance > (amtNeeded + extraUSDC)){
                    withdrawUSDCfromCmp(amtNeeded + extraUSDC);
                }else{
                    withdrawUSDCfromCmp(compoundBalance);  
                }
            }
            totalSupply = totalSupply - redeemTokensIn;
            updateNetAssetValue(borrowBalanceUSDC, trueRedeemAmount); 
        }
        accountTokens[redeemer] = accountTokens[redeemer] - redeemTokensIn;
        if(trueRedeemAmount > 0){
            doTransferOut(redeemer, trueRedeemAmount);
            emit Transfer(redeemer, address(this), redeemTokensIn);
            emit Redeem(redeemer, trueRedeemAmount, redeemTokensIn, netAssetValue);
        }else{
            emit Redeem(redeemer, 0, redeemTokensIn, netAssetValue);
        }
    }
    function forceRepayInternal(uint repayAmountInUSDT) internal nonReentrant returns (uint) {
        Exp memory fx_USDTUSDC = Exp({mantissa: tensorpricer.getFx('USDTUSDC')});
        uint amtUSDC = mul_(repayAmountInUSDT, fx_USDTUSDC);
        amtUSDC = (amtUSDC * 105) / 100;    
        uint availCash = getCashExReserves();
        if(amtUSDC > availCash){
            uint amtUSDCmissing = amtUSDC - availCash; 
            uint compoundBalance = getCmpBalanceInternal();
            if(compoundBalance > (amtUSDCmissing + extraUSDC)){
                withdrawUSDCfromCmp(amtUSDCmissing + extraUSDC);
            }else{
                withdrawUSDCfromCmp(compoundBalance);  
            }
        }
        uint netForceRepayAmount = changeUSDC2USDT(amtUSDC, 0, address(depErc20));
        return netForceRepayAmount;
    }
    function updateLedgerInternal() internal {
        updateBorrowBalances(tensorpricer.getFx('USDTUSDC'), depErc20.getTotalBorrows());   
        updateStats(true, 0, 0, 0);
        updateNetAssetValue(borrowBalanceUSDC, 0);
    }
    function takePerfFee(uint navMantissa) internal returns (uint) {
        uint perfFee = 0;
        if(navMantissa > hisHighNav && totalSupply > 0){
            uint gain = (navMantissa-hisHighNav) * totalSupply / expScale;    
            hisHighNav = navMantissa;
            perfFee = gain * perfPC / expScale;
            uint tmpTotalAssetValue = navMantissa * totalSupply / expScale;
            console.log("tmpTotalAssetValue,perffee,gain = %d,%d,%d",tmpTotalAssetValue,perfFee,gain);
            levReserve = levReserve + perfFee;
            uint updatedNavMantissa = (tmpTotalAssetValue - perfFee)*expScale / totalSupply;  
            console.log("updatedNavMantissa = ",updatedNavMantissa);
            return updatedNavMantissa;  
        }else{
            return navMantissa;
        }
    }
    function _setPendingAdmin(address payable newPendingAdmin) override external returns (uint) {
        if (msg.sender != admin) {
            revert SetPendingAdminOwnerCheck();
        }
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
        return NO_ERROR;
    }
    function _acceptAdmin() override external returns (uint) {
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            revert AcceptAdminPendingAdminCheck();
        }
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = payable(address(0));
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
        return NO_ERROR;
    }
    function _reduceReserves(uint reduceAmount) override external nonReentrant returns (uint) {
        return _reduceReservesFresh(reduceAmount);
    }
    function _reduceReservesFresh(uint reduceAmount) internal returns (uint) {
        uint levReserveNew;
        if (msg.sender != admin) {
            revert ReduceReservesAdminCheck();
        }
        if (getCashPrior() < reduceAmount) {
            revert ReduceReservesCashNotAvailable();
        }
        if (reduceAmount > levReserve) {
            revert ReduceReservesCashValidation();
        }
        levReserveNew = levReserve - reduceAmount;
        levReserve = levReserveNew;
        doTransferOut(admin, reduceAmount);
        emit ReservesReduced(admin, reduceAmount, levReserveNew);
        return NO_ERROR;
    }
    function _setTensorpricer(TensorpricerInterface newTensorpricer) override public returns (uint) {
        if (msg.sender != admin) {
            revert SetTensorpricerOwnerCheck();
        }
        TensorpricerInterface oldTensorpricer = tensorpricer;
        require(newTensorpricer.isTensorpricer(), "marker method returned false");
        tensorpricer = newTensorpricer;
        emit NewTensorpricer(oldTensorpricer, newTensorpricer);
        return NO_ERROR;
    }
    function getCashExReserves() internal view returns (uint) {
        uint allCash = getCashPrior();
        if(allCash > levReserve){
            return allCash - levReserve;
        }else{
            return 0;
        }
    }
    function getCashPrior() virtual internal view returns (uint);
    function doTransferIn(address from, uint amount) virtual internal returns (uint);
    function doTransferOut(address payable to, uint amount) virtual internal;
    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; 
    }
}