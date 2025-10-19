pragma solidity 0.8.10;
import "./interfaces/IMIMOAutoAction.sol";
import "../../core/interfaces/IAddressProvider.sol";
import { CustomErrors } from "../../libraries/CustomErrors.sol";
import "../../libraries/WadRayMath.sol";
contract MIMOAutoAction is IMIMOAutoAction {
  using WadRayMath for uint256;
  IAddressProvider public immutable a;
  IMIMOProxyRegistry public immutable proxyRegistry;
  mapping(uint256 => AutomatedVault) internal _automatedVaults;
  mapping(uint256 => uint256) internal _operationTracker;
  constructor(IAddressProvider _a, IMIMOProxyRegistry _proxyRegistry) {
    if (address(_a) == address(0) || address(_proxyRegistry) == address(0)) {
      revert CustomErrors.CANNOT_SET_TO_ADDRESS_ZERO();
    }
    a = _a;
    proxyRegistry = _proxyRegistry;
  }
  function setAutomation(uint256 vaultId, AutomatedVault calldata autoParams) external override {
    address vaultOwner = a.vaultsData().vaultOwner(vaultId);
    address mimoProxy = address(proxyRegistry.getCurrentProxy(msg.sender));
    if (mimoProxy != vaultOwner && vaultOwner != msg.sender) {
      revert CustomErrors.CALLER_NOT_VAULT_OWNER(mimoProxy, vaultOwner);
    }
    uint256 toVaultMcr = a.config().collateralMinCollateralRatio(autoParams.toCollateral);
    uint256 maxVarFee = (autoParams.targetRatio.wadDiv(toVaultMcr + autoParams.mcrBuffer) + WadRayMath.WAD).wadDiv(
      autoParams.targetRatio
    );
    if (autoParams.varFee >= maxVarFee) {
      revert CustomErrors.VARIABLE_FEE_TOO_HIGH(maxVarFee, autoParams.varFee);
    }
    _automatedVaults[vaultId] = autoParams;
    emit AutomationSet(vaultId, autoParams);
  }
  function getAutomatedVault(uint256 vaultId) external view override returns (AutomatedVault memory) {
    return _automatedVaults[vaultId];
  }
  function getOperationTracker(uint256 vaultId) external view override returns (uint256) {
    return _operationTracker[vaultId];
  }
  function _getVaultStats(uint256 vaultId) internal view returns (uint256 vaultRatio, VaultState memory vaultState) {
    IAddressProvider _a = a;
    IVaultsDataProvider vaultsData = _a.vaultsData();
    IPriceFeed priceFeed = _a.priceFeed();
    uint256 collateralBalance = vaultsData.vaultCollateralBalance(vaultId);
    address collateralType = vaultsData.vaultCollateralType(vaultId);
    uint256 collateralValue = priceFeed.convertFrom(collateralType, collateralBalance);
    uint256 vaultDebt = vaultsData.vaultDebt(vaultId);
    vaultRatio = vaultDebt == 0 ? type(uint256).max : collateralValue.wadDiv(vaultDebt);
    vaultState = VaultState({ collateralType: collateralType, collateralValue: collateralValue, vaultDebt: vaultDebt });
  }
  function _isVaultVariationAllowed(
    AutomatedVault memory autoVault,
    uint256 rebalanceValue,
    uint256 swapResultValue
  ) internal pure returns (bool) {
    if (swapResultValue >= rebalanceValue) {
      return true;
    }
    uint256 vaultVariation = (rebalanceValue - swapResultValue).wadDiv(rebalanceValue);
    if (vaultVariation > autoVault.allowedVariation) {
      return false;
    }
    return true;
  }
}