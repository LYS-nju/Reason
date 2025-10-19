pragma solidity >=0.8.20;
import '../interfaces/IWildcatSanctionsSentinel.sol';
import '../libraries/FeeMath.sol';
import '../libraries/SafeCastLib.sol';
import './WildcatMarketBase.sol';
contract WildcatMarketConfig is WildcatMarketBase {
  using SafeCastLib for uint256;
  using BoolUtils for bool;
  function maximumDeposit() external view returns (uint256) {
    MarketState memory state = currentState();
    return state.maximumDeposit();
  }
  function maxTotalSupply() external view returns (uint256) {
    return _state.maxTotalSupply;
  }
  function annualInterestBips() external view returns (uint256) {
    return _state.annualInterestBips;
  }
  function reserveRatioBips() external view returns (uint256) {
    return _state.reserveRatioBips;
  }
  function nukeFromOrbit(address accountAddress) external nonReentrant {
    if (!IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      revert BadLaunchCode();
    }
    MarketState memory state = _getUpdatedState();
    _blockAccount(state, accountAddress);
    _writeState(state);
  }
  function stunningReversal(address accountAddress) external nonReentrant {
    Account memory account = _accounts[accountAddress];
    if (account.approval != AuthRole.Blocked) {
      revert AccountNotBlocked();
    }
    if (IWildcatSanctionsSentinel(sentinel).isSanctioned(borrower, accountAddress)) {
      revert NotReversedOrStunning();
    }
    account.approval = AuthRole.Null;
    emit AuthorizationStatusUpdated(accountAddress, account.approval);
    _accounts[accountAddress] = account;
  }
  function updateAccountAuthorization(
    address _account,
    bool _isAuthorized
  ) external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    Account memory account = _getAccount(_account);
    if (_isAuthorized) {
      account.approval = AuthRole.DepositAndWithdraw;
    } else {
      account.approval = AuthRole.WithdrawOnly;
    }
    _accounts[_account] = account;
    _writeState(state);
    emit AuthorizationStatusUpdated(_account, account.approval);
  }
  function setMaxTotalSupply(uint256 _maxTotalSupply) external onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (_maxTotalSupply < state.totalSupply()) {
      revert NewMaxSupplyTooLow();
    }
    state.maxTotalSupply = _maxTotalSupply.toUint128();
    _writeState(state);
    emit MaxTotalSupplyUpdated(_maxTotalSupply);
  }
  function setAnnualInterestBips(uint16 _annualInterestBips) public onlyController nonReentrant {
    MarketState memory state = _getUpdatedState();
    if (_annualInterestBips > BIP) {
      revert InterestRateTooHigh();
    }
    state.annualInterestBips = _annualInterestBips;
    _writeState(state);
    emit AnnualInterestBipsUpdated(_annualInterestBips);
  }
  function setReserveRatioBips(uint16 _reserveRatioBips) public onlyController nonReentrant {
    if (_reserveRatioBips > BIP) {
      revert ReserveRatioBipsTooHigh();
    }
    MarketState memory state = _getUpdatedState();
    uint256 initialReserveRatioBips = state.reserveRatioBips;
    if (_reserveRatioBips < initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert InsufficientReservesForOldLiquidityRatio();
      }
    }
    state.reserveRatioBips = _reserveRatioBips;
    if (_reserveRatioBips > initialReserveRatioBips) {
      if (state.liquidityRequired() > totalAssets()) {
        revert InsufficientReservesForNewLiquidityRatio();
      }
    }
    _writeState(state);
    emit ReserveRatioBipsUpdated(_reserveRatioBips);
  }
}