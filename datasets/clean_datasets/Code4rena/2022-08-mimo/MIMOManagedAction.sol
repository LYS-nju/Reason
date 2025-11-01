pragma solidity 0.8.10;
import "./interfaces/IMIMOManagedAction.sol";
import { CustomErrors } from "../../libraries/CustomErrors.sol";
import "../../core/interfaces/IAddressProvider.sol";
import "../../libraries/WadRayMath.sol";
contract MIMOManagedAction is IMIMOManagedAction {
  using WadRayMath for uint256;
  IAddressProvider public immutable a;
  IMIMOProxyRegistry public immutable proxyRegistry;
  mapping(uint256 => ManagedVault) internal _managedVaults;
  mapping(uint256 => uint256) internal _operationTracker;
  mapping(address => bool) internal _managers;
  constructor(IAddressProvider _a, IMIMOProxyRegistry _proxyRegistry) {
    if (address(_a) == address(0) || address(_proxyRegistry) == address(0)) {
      revert CustomErrors.CANNOT_SET_TO_ADDRESS_ZERO();
    }
    a = _a;
    proxyRegistry = _proxyRegistry;
  }
  function setManagement(uint256 vaultId, ManagedVault calldata mgtParams) external override {
    address vaultOwner = a.vaultsData().vaultOwner(vaultId);
    address mimoProxy = address(proxyRegistry.getCurrentProxy(msg.sender));
    if (mimoProxy != vaultOwner && vaultOwner != msg.sender) {
      revert CustomErrors.CALLER_NOT_VAULT_OWNER(mimoProxy, vaultOwner);
    }
    if (!_managers[mgtParams.manager]) {
      revert CustomErrors.MANAGER_NOT_LISTED();
    }
    _managedVaults[vaultId] = mgtParams;
    emit ManagementSet(vaultId, mgtParams);
  }
  function setManager(address manager, bool isManager) external override {
    IAccessController controller = a.controller();
    if (!controller.hasRole(controller.MANAGER_ROLE(), msg.sender)) {
      revert CustomErrors.CALLER_NOT_PROTOCOL_MANAGER();
    }
    _managers[manager] = isManager;
    emit ManagerSet(manager, isManager);
  }
  function getManagedVault(uint256 vaultId) external view override returns (ManagedVault memory) {
    return _managedVaults[vaultId];
  }
  function getOperationTracker(uint256 vaultId) external view override returns (uint256) {
    return _operationTracker[vaultId];
  }
  function getManager(address manager) external view override returns (bool) {
    return _managers[manager];
  }
  function _getVaultRatio(uint256 vaultId) internal view returns (uint256) {
    IAddressProvider _a = a;
    IVaultsDataProvider vaultsData = _a.vaultsData();
    IPriceFeed priceFeed = _a.priceFeed();
    uint256 collateralBalance = vaultsData.vaultCollateralBalance(vaultId);
    address collateralType = vaultsData.vaultCollateralType(vaultId);
    uint256 collateralValue = priceFeed.convertFrom(collateralType, collateralBalance);
    uint256 vaultDebt = vaultsData.vaultDebt(vaultId);
    if (vaultDebt == 0) {
      return (type(uint256).max);
    }
    uint256 vaultRatio = collateralValue.wadDiv(vaultDebt);
    return (vaultRatio);
  }
  function _isVaultVariationAllowed(
    ManagedVault memory managedVault,
    uint256 rebalanceValue,
    uint256 swapResultValue
  ) internal pure returns (bool) {
    if (swapResultValue >= rebalanceValue) {
      return true;
    }
    uint256 vaultVariation = (rebalanceValue - swapResultValue).wadDiv(rebalanceValue);
    if (vaultVariation > managedVault.allowedVariation) {
      return false;
    }
    return true;
  }
}