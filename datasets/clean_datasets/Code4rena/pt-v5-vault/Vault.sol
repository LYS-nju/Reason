pragma solidity 0.8.17;
import { ERC4626, ERC20, IERC20, IERC4626 } from "openzeppelin/token/ERC20/extensions/ERC4626.sol";
import { ERC20Permit, IERC20Permit } from "openzeppelin/token/ERC20/extensions/draft-ERC20Permit.sol";
import { SafeERC20 } from "openzeppelin/token/ERC20/utils/SafeERC20.sol";
import { Math } from "openzeppelin/utils/math/Math.sol";
import { Ownable } from "owner-manager-contracts/Ownable.sol";
import { LiquidationPair } from "v5-liquidator/LiquidationPair.sol";
import { ILiquidationSource } from "v5-liquidator-interfaces/ILiquidationSource.sol";
import { PrizePool } from "v5-prize-pool/PrizePool.sol";
import { TwabController } from "v5-twab-controller/TwabController.sol";
import { VaultHooks } from "./interfaces/IVaultHooks.sol";
error TwabControllerZeroAddress();
error YieldVaultZeroAddress();
error PrizePoolZeroAddress();
error OwnerZeroAddress();
error DepositMoreThanMax(address receiver, uint256 amount, uint256 max);
error WithdrawMoreThanMax(address owner, uint256 amount, uint256 max);
error RedeemMoreThanMax(address owner, uint256 amount, uint256 max);
error MintMoreThanMax(address receiver, uint256 shares, uint256 max);
error LiquidationCallerNotLP(address caller, address liquidationPair);
error LiquidationTokenInNotPrizeToken(address tokenIn, address prizeToken);
error LiquidationTokenOutNotVaultShare(address tokenOut, address vaultShare);
error LiquidationAmountOutZero();
error LiquidationAmountOutGTYield(uint256 amountOut, uint256 availableYield);
error VaultUnderCollateralized();
error TargetTokenNotSupported(address token);
error CallerNotClaimer(address caller, address claimer);
error YieldFeeGTAvailable(uint256 shares, uint256 yieldFeeTotalSupply);
error LPZeroAddress();
error YieldFeePercentageGTPrecision(uint256 yieldFeePercentage, uint256 maxYieldFeePercentage);
contract Vault is ERC4626, ERC20Permit, ILiquidationSource, Ownable {
  using Math for uint256;
  using SafeERC20 for IERC20;
  event NewVault(
    IERC20 indexed asset,
    string name,
    string symbol,
    TwabController twabController,
    IERC4626 indexed yieldVault,
    PrizePool indexed prizePool,
    address claimer,
    address yieldFeeRecipient,
    uint256 yieldFeePercentage,
    address owner
  );
  event ClaimerSet(address previousClaimer, address newClaimer);
  event SetHooks(address account, VaultHooks hooks);
  event LiquidationPairSet(LiquidationPair newLiquidationPair);
  event MintYieldFee(address indexed caller, address indexed recipient, uint256 shares);
  event YieldFeeRecipientSet(address previousYieldFeeRecipient, address newYieldFeeRecipient);
  event YieldFeePercentageSet(uint256 previousYieldFeePercentage, uint256 newYieldFeePercentage);
  event Sponsor(address indexed caller, address indexed receiver, uint256 assets, uint256 shares);
  event RecordedExchangeRate(uint256 exchangeRate);
  TwabController private immutable _twabController;
  IERC4626 private immutable _yieldVault;
  PrizePool private immutable _prizePool;
  address private _claimer;
  LiquidationPair private _liquidationPair;
  uint256 private _assetUnit;
  uint256 private _lastRecordedExchangeRate;
  uint256 private _yieldFeePercentage;
  address private _yieldFeeRecipient;
  uint256 private _yieldFeeTotalSupply;
  uint256 private constant FEE_PRECISION = 1e9;
  mapping(address => VaultHooks) internal _hooks;
  constructor(
    IERC20 asset_,
    string memory name_,
    string memory symbol_,
    TwabController twabController_,
    IERC4626 yieldVault_,
    PrizePool prizePool_,
    address claimer_,
    address yieldFeeRecipient_,
    uint256 yieldFeePercentage_,
    address owner_
  ) ERC4626(asset_) ERC20(name_, symbol_) ERC20Permit(name_) Ownable(owner_) {
    if (address(twabController_) == address(0)) revert TwabControllerZeroAddress();
    if (address(yieldVault_) == address(0)) revert YieldVaultZeroAddress();
    if (address(prizePool_) == address(0)) revert PrizePoolZeroAddress();
    if (address(owner_) == address(0)) revert OwnerZeroAddress();
    _twabController = twabController_;
    _yieldVault = yieldVault_;
    _prizePool = prizePool_;
    _setClaimer(claimer_);
    _setYieldFeeRecipient(yieldFeeRecipient_);
    _setYieldFeePercentage(yieldFeePercentage_);
    _assetUnit = 10 ** super.decimals();
    asset_.safeApprove(address(yieldVault_), type(uint256).max);
    emit NewVault(
      asset_,
      name_,
      symbol_,
      twabController_,
      yieldVault_,
      prizePool_,
      claimer_,
      yieldFeeRecipient_,
      yieldFeePercentage_,
      owner_
    );
  }
  function availableYieldBalance() public view returns (uint256) {
    uint256 _assets = _totalAssets();
    uint256 _sharesToAssets = _convertToAssets(_totalShares(), Math.Rounding.Down);
    return _sharesToAssets > _assets ? 0 : _assets - _sharesToAssets;
  }
  function availableYieldFeeBalance() public view returns (uint256) {
    uint256 _availableYield = availableYieldBalance();
    if (_availableYield != 0 && _yieldFeePercentage != 0) {
      return _availableYieldFeeBalance(_availableYield);
    }
    return 0;
  }
  function balanceOf(
    address _account
  ) public view virtual override(ERC20, IERC20) returns (uint256) {
    return _twabController.balanceOf(address(this), _account);
  }
  function decimals() public view virtual override(ERC4626, ERC20) returns (uint8) {
    return super.decimals();
  }
  function totalAssets() public view virtual override returns (uint256) {
    return _totalAssets();
  }
  function totalSupply() public view virtual override(ERC20, IERC20) returns (uint256) {
    return _totalSupply();
  }
  function exchangeRate() public view returns (uint256) {
    return _currentExchangeRate();
  }
  function isVaultCollateralized() public view returns (bool) {
    return _isVaultCollateralized();
  }
  function maxDeposit(address) public view virtual override returns (uint256) {
    return _isVaultCollateralized() ? type(uint96).max : 0;
  }
  function maxMint(address) public view virtual override returns (uint256) {
    return _isVaultCollateralized() ? type(uint96).max : 0;
  }
  function mintYieldFee(uint256 _shares, address _recipient) external {
    _requireVaultCollateralized();
    if (_shares > _yieldFeeTotalSupply) revert YieldFeeGTAvailable(_shares, _yieldFeeTotalSupply);
    _yieldFeeTotalSupply -= _shares;
    _mint(_recipient, _shares);
    emit MintYieldFee(msg.sender, _recipient, _shares);
  }
  function deposit(uint256 _assets, address _receiver) public virtual override returns (uint256) {
    if (_assets > maxDeposit(_receiver))
      revert DepositMoreThanMax(_receiver, _assets, maxDeposit(_receiver));
    uint256 _shares = _convertToShares(_assets, Math.Rounding.Down);
    _deposit(msg.sender, _receiver, _assets, _shares);
    return _shares;
  }
  function depositWithPermit(
    uint256 _assets,
    address _receiver,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external returns (uint256) {
    _permit(IERC20Permit(asset()), msg.sender, address(this), _assets, _deadline, _v, _r, _s);
    return deposit(_assets, _receiver);
  }
  function mint(uint256 _shares, address _receiver) public virtual override returns (uint256) {
    uint256 _assets = _beforeMint(_shares, _receiver);
    _deposit(msg.sender, _receiver, _assets, _shares);
    return _assets;
  }
  function mintWithPermit(
    uint256 _shares,
    address _receiver,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external returns (uint256) {
    uint256 _assets = _beforeMint(_shares, _receiver);
    _permit(IERC20Permit(asset()), msg.sender, address(this), _assets, _deadline, _v, _r, _s);
    _deposit(msg.sender, _receiver, _assets, _shares);
    return _assets;
  }
  function sponsor(uint256 _assets, address _receiver) external returns (uint256) {
    return _sponsor(_assets, _receiver);
  }
  function sponsorWithPermit(
    uint256 _assets,
    address _receiver,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external returns (uint256) {
    _permit(IERC20Permit(asset()), msg.sender, address(this), _assets, _deadline, _v, _r, _s);
    return _sponsor(_assets, _receiver);
  }
  function withdraw(
    uint256 _assets,
    address _receiver,
    address _owner
  ) public virtual override returns (uint256) {
    if (_assets > maxWithdraw(_owner))
      revert WithdrawMoreThanMax(_owner, _assets, maxWithdraw(_owner));
    uint256 _shares = _convertToShares(_assets, Math.Rounding.Up);
    _withdraw(msg.sender, _receiver, _owner, _assets, _shares);
    return _shares;
  }
  function redeem(
    uint256 _shares,
    address _receiver,
    address _owner
  ) public virtual override returns (uint256) {
    if (_shares > maxRedeem(_owner)) revert RedeemMoreThanMax(_owner, _shares, maxRedeem(_owner));
    uint256 _assets = _convertToAssets(_shares, Math.Rounding.Down);
    _withdraw(msg.sender, _receiver, _owner, _assets, _shares);
    return _assets;
  }
  function liquidatableBalanceOf(address _token) public view override returns (uint256) {
    return _liquidatableBalanceOf(_token);
  }
  function liquidate(
    address _account,
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut,
    uint256 _amountOut
  ) public virtual override returns (bool) {
    _requireVaultCollateralized();
    if (msg.sender != address(_liquidationPair))
      revert LiquidationCallerNotLP(msg.sender, address(_liquidationPair));
    if (_tokenIn != address(_prizePool.prizeToken()))
      revert LiquidationTokenInNotPrizeToken(_tokenIn, address(_prizePool.prizeToken()));
    if (_tokenOut != address(this))
      revert LiquidationTokenOutNotVaultShare(_tokenOut, address(this));
    if (_amountOut == 0) revert LiquidationAmountOutZero();
    uint256 _liquidableYield = _liquidatableBalanceOf(_tokenOut);
    if (_amountOut > _liquidableYield)
      revert LiquidationAmountOutGTYield(_amountOut, _liquidableYield);
    _prizePool.contributePrizeTokens(address(this), _amountIn);
    if (_yieldFeePercentage != 0) {
      _increaseYieldFeeBalance(
        (_amountOut * FEE_PRECISION) / (FEE_PRECISION - _yieldFeePercentage) - _amountOut
      );
    }
    uint256 _vaultAssets = IERC20(asset()).balanceOf(address(this));
    if (_vaultAssets != 0 && _amountOut >= _vaultAssets) {
      _yieldVault.deposit(_vaultAssets, address(this));
    }
    _mint(_account, _amountOut);
    return true;
  }
  function targetOf(address _token) external view returns (address) {
    if (_token != _liquidationPair.tokenIn()) revert TargetTokenNotSupported(_token);
    return address(_prizePool);
  }
  function claimPrizes(
    uint8 _tier,
    address[] calldata _winners,
    uint32[][] calldata _prizeIndices,
    uint96 _feePerClaim,
    address _feeRecipient
  ) external returns (uint256) {
    if (msg.sender != _claimer) revert CallerNotClaimer(msg.sender, _claimer);
    uint totalPrizes;
    for (uint w = 0; w < _winners.length; w++) {
      uint prizeIndicesLength = _prizeIndices[w].length;
      for (uint p = 0; p < prizeIndicesLength; p++) {
        totalPrizes += _claimPrize(
          _winners[w],
          _tier,
          _prizeIndices[w][p],
          _feePerClaim,
          _feeRecipient
        );
      }
    }
    return totalPrizes;
  }
  function setClaimer(address claimer_) external onlyOwner returns (address) {
    address _previousClaimer = _claimer;
    _setClaimer(claimer_);
    emit ClaimerSet(_previousClaimer, claimer_);
    return claimer_;
  }
  function setHooks(VaultHooks memory hooks) external {
    _hooks[msg.sender] = hooks;
    emit SetHooks(msg.sender, hooks);
  }
  function setLiquidationPair(
    LiquidationPair liquidationPair_
  ) external onlyOwner returns (address) {
    if (address(liquidationPair_) == address(0)) revert LPZeroAddress();
    IERC20 _asset = IERC20(asset());
    address _previousLiquidationPair = address(_liquidationPair);
    if (_previousLiquidationPair != address(0)) {
      _asset.safeApprove(_previousLiquidationPair, 0);
    }
    _asset.safeApprove(address(liquidationPair_), type(uint256).max);
    _liquidationPair = liquidationPair_;
    emit LiquidationPairSet(liquidationPair_);
    return address(liquidationPair_);
  }
  function setYieldFeePercentage(uint256 yieldFeePercentage_) external onlyOwner returns (uint256) {
    uint256 _previousYieldFeePercentage = _yieldFeePercentage;
    _setYieldFeePercentage(yieldFeePercentage_);
    emit YieldFeePercentageSet(_previousYieldFeePercentage, yieldFeePercentage_);
    return yieldFeePercentage_;
  }
  function setYieldFeeRecipient(address yieldFeeRecipient_) external onlyOwner returns (address) {
    address _previousYieldFeeRecipient = _yieldFeeRecipient;
    _setYieldFeeRecipient(yieldFeeRecipient_);
    emit YieldFeeRecipientSet(_previousYieldFeeRecipient, yieldFeeRecipient_);
    return yieldFeeRecipient_;
  }
  function yieldFeeRecipient() public view returns (address) {
    return _yieldFeeRecipient;
  }
  function yieldFeePercentage() public view returns (uint256) {
    return _yieldFeePercentage;
  }
  function yieldFeeTotalSupply() public view returns (uint256) {
    return _yieldFeeTotalSupply;
  }
  function twabController() public view returns (address) {
    return address(_twabController);
  }
  function yieldVault() public view returns (address) {
    return address(_yieldVault);
  }
  function liquidationPair() public view returns (address) {
    return address(_liquidationPair);
  }
  function prizePool() public view returns (address) {
    return address(_prizePool);
  }
  function claimer() public view returns (address) {
    return _claimer;
  }
  function getHooks(address _account) external view returns (VaultHooks memory) {
    return _hooks[_account];
  }
  function _totalAssets() internal view returns (uint256) {
    return _yieldVault.maxWithdraw(address(this)) + super.totalAssets();
  }
  function _totalSupply() internal view returns (uint256) {
    return _twabController.totalSupply(address(this));
  }
  function _totalShares() internal view returns (uint256) {
    return _totalSupply() + _yieldFeeTotalSupply;
  }
  function _liquidatableBalanceOf(address _token) internal view returns (uint256) {
    if (_token != address(this)) revert LiquidationTokenOutNotVaultShare(_token, address(this));
    uint256 _availableYield = availableYieldBalance();
    unchecked {
      return _availableYield -= _availableYieldFeeBalance(_availableYield);
    }
  }
  function _availableYieldFeeBalance(uint256 _availableYield) internal view returns (uint256) {
    return (_availableYield * _yieldFeePercentage) / FEE_PRECISION;
  }
  function _increaseYieldFeeBalance(uint256 _shares) internal {
    _yieldFeeTotalSupply += _shares;
  }
  function _convertToShares(
    uint256 _assets,
    Math.Rounding _rounding
  ) internal view virtual override returns (uint256) {
    uint256 _exchangeRate = _currentExchangeRate();
    return
      (_assets == 0 || _exchangeRate == 0)
        ? _assets
        : _assets.mulDiv(_assetUnit, _exchangeRate, _rounding);
  }
  function _convertToAssets(
    uint256 _shares,
    Math.Rounding _rounding
  ) internal view virtual override returns (uint256) {
    return _convertToAssets(_shares, _currentExchangeRate(), _rounding);
  }
  function _convertToAssets(
    uint256 _shares,
    uint256 _exchangeRate,
    Math.Rounding _rounding
  ) internal view returns (uint256) {
    return
      (_shares == 0 || _exchangeRate == 0)
        ? _shares
        : _shares.mulDiv(_exchangeRate, _assetUnit, _rounding);
  }
  function _deposit(
    address _caller,
    address _receiver,
    uint256 _assets,
    uint256 _shares
  ) internal virtual override {
    IERC20 _asset = IERC20(asset());
    uint256 _vaultAssets = _asset.balanceOf(address(this));
    if (_assets > _vaultAssets) {
      uint256 _assetsDeposit;
      unchecked {
        if (_vaultAssets != 0) {
          _assetsDeposit = _assets - _vaultAssets;
        }
      }
      SafeERC20.safeTransferFrom(
        _asset,
        _caller,
        address(this),
        _assetsDeposit != 0 ? _assetsDeposit : _assets
      );
    }
    _yieldVault.deposit(_assets, address(this));
    _mint(_receiver, _shares);
    emit Deposit(_caller, _receiver, _assets, _shares);
  }
  function _beforeMint(uint256 _shares, address _receiver) internal view returns (uint256) {
    if (_shares > maxMint(_receiver)) revert MintMoreThanMax(_receiver, _shares, maxMint(_receiver));
    return _convertToAssets(_shares, Math.Rounding.Up);
  }
  function _sponsor(uint256 _assets, address _receiver) internal returns (uint256) {
    uint256 _shares = deposit(_assets, _receiver);
    if (
      _twabController.delegateOf(address(this), _receiver) != _twabController.SPONSORSHIP_ADDRESS()
    ) {
      _twabController.sponsor(_receiver);
    }
    emit Sponsor(msg.sender, _receiver, _assets, _shares);
    return _shares;
  }
  function _withdraw(
    address _caller,
    address _receiver,
    address _owner,
    uint256 _assets,
    uint256 _shares
  ) internal virtual override {
    if (_caller != _owner) {
      _spendAllowance(_owner, _caller, _shares);
    }
    _burn(_owner, _shares);
    _yieldVault.withdraw(_assets, address(this), address(this));
    SafeERC20.safeTransfer(IERC20(asset()), _receiver, _assets);
    emit Withdraw(_caller, _receiver, _owner, _assets, _shares);
  }
  function _claimPrize(
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex,
    uint96 _fee,
    address _feeRecipient
  ) internal returns (uint256) {
    VaultHooks memory hooks = _hooks[_winner];
    address recipient;
    if (hooks.useBeforeClaimPrize) {
      recipient = hooks.implementation.beforeClaimPrize(_winner, _tier, _prizeIndex);
    } else {
      recipient = _winner;
    }
    uint prizeTotal = _prizePool.claimPrize(
      _winner,
      _tier,
      _prizeIndex,
      recipient,
      _fee,
      _feeRecipient
    );
    if (hooks.useAfterClaimPrize) {
      hooks.implementation.afterClaimPrize(
        _winner,
        _tier,
        _prizeIndex,
        prizeTotal - _fee,
        recipient
      );
    }
    return prizeTotal;
  }
  function _permit(
    IERC20Permit _asset,
    address _owner,
    address _spender,
    uint256 _assets,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) internal {
    _asset.permit(_owner, _spender, _assets, _deadline, _v, _r, _s);
  }
  function _updateExchangeRate() internal {
    _lastRecordedExchangeRate = _currentExchangeRate();
    emit RecordedExchangeRate(_lastRecordedExchangeRate);
  }
  function _mint(address _receiver, uint256 _shares) internal virtual override {
    _twabController.mint(_receiver, uint96(_shares));
    _updateExchangeRate();
    emit Transfer(address(0), _receiver, _shares);
  }
  function _burn(address _owner, uint256 _shares) internal virtual override {
    _twabController.burn(_owner, uint96(_shares));
    _updateExchangeRate();
    emit Transfer(_owner, address(0), _shares);
  }
  function _transfer(address _from, address _to, uint256 _shares) internal virtual override {
    _twabController.transfer(_from, _to, uint96(_shares));
    emit Transfer(_from, _to, _shares);
  }
  function _currentExchangeRate() internal view returns (uint256) {
    uint256 _totalSupplyAmount = _totalSupply();
    uint256 _totalSupplyToAssets = _convertToAssets(
      _totalSupplyAmount,
      _lastRecordedExchangeRate,
      Math.Rounding.Down
    );
    uint256 _withdrawableAssets = _yieldVault.maxWithdraw(address(this));
    if (_withdrawableAssets > _totalSupplyToAssets) {
      _withdrawableAssets = _withdrawableAssets - (_withdrawableAssets - _totalSupplyToAssets);
    }
    if (_totalSupplyAmount != 0 && _withdrawableAssets != 0) {
      return _withdrawableAssets.mulDiv(_assetUnit, _totalSupplyAmount, Math.Rounding.Down);
    }
    return _assetUnit;
  }
  function _isVaultCollateralized() internal view returns (bool) {
    return _currentExchangeRate() >= _assetUnit;
  }
  function _requireVaultCollateralized() internal view {
    if (!_isVaultCollateralized()) revert VaultUnderCollateralized();
  }
  function _setClaimer(address claimer_) internal {
    _claimer = claimer_;
  }
  function _setYieldFeePercentage(uint256 yieldFeePercentage_) internal {
    if (yieldFeePercentage_ > FEE_PRECISION) {
      revert YieldFeePercentageGTPrecision(yieldFeePercentage_, FEE_PRECISION);
    }
    _yieldFeePercentage = yieldFeePercentage_;
  }
  function _setYieldFeeRecipient(address yieldFeeRecipient_) internal {
    _yieldFeeRecipient = yieldFeeRecipient_;
  }
}