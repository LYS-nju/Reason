pragma solidity >=0.8.4;
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "../libraries/BoringBatchable.sol";
import "./interfaces/IMIMOProxy.sol";
import { CustomErrors } from "../libraries/CustomErrors.sol";
contract MIMOProxy is IMIMOProxy, Initializable, BoringBatchable {
  address public override owner;
  uint256 public override minGasReserve;
  mapping(address => mapping(address => mapping(bytes4 => bool))) internal _permissions;
  function initialize() external initializer {
    minGasReserve = 5_000;
    owner = msg.sender;
    emit TransferOwnership(address(0), msg.sender);
  }
  receive() external payable {}
  function getPermission(
    address envoy,
    address target,
    bytes4 selector
  ) external view override returns (bool) {
    return _permissions[envoy][target][selector];
  }
  function execute(address target, bytes calldata data) public payable override returns (bytes memory response) {
    if (owner != msg.sender) {
      bytes4 selector;
      assembly {
        selector := calldataload(data.offset)
      }
      if (!_permissions[msg.sender][target][selector]) {
        revert CustomErrors.EXECUTION_NOT_AUTHORIZED(owner, msg.sender, target, selector);
      }
    }
    if (target.code.length == 0) {
      revert CustomErrors.TARGET_INVALID(target);
    }
    address owner_ = owner;
    uint256 stipend = gasleft() - minGasReserve;
    bool success;
    (success, response) = target.delegatecall{ gas: stipend }(data);
    if (owner_ != owner) {
      revert CustomErrors.OWNER_CHANGED(owner_, owner);
    }
    emit Execute(target, data, response);
    if (!success) {
      if (response.length > 0) {
        assembly {
          let returndata_size := mload(response)
          revert(add(32, response), returndata_size)
        }
      } else {
        revert CustomErrors.EXECUTION_REVERTED();
      }
    }
  }
  function setPermission(
    address envoy,
    address target,
    bytes4 selector,
    bool permission
  ) public override {
    if (owner != msg.sender) {
      revert CustomErrors.NOT_OWNER(owner, msg.sender);
    }
    _permissions[envoy][target][selector] = permission;
  }
  function transferOwnership(address newOwner) external override {
    address oldOwner = owner;
    if (oldOwner != msg.sender) {
      revert CustomErrors.NOT_OWNER(oldOwner, msg.sender);
    }
    owner = newOwner;
    emit TransferOwnership(oldOwner, newOwner);
  }
  function multicall(address[] calldata targets, bytes[] calldata data) external override returns (bytes[] memory) {
    if (msg.sender != owner) {
      revert CustomErrors.NOT_OWNER(owner, msg.sender);
    }
    bytes[] memory results = new bytes[](data.length);
    for (uint256 i = 0; i < targets.length; i++) {
      (bool success, bytes memory response) = targets[i].call(data[i]);
      if (!success) {
        if (response.length > 0) {
          assembly {
            let returndata_size := mload(response)
            revert(add(32, response), returndata_size)
          }
        } else {
          revert CustomErrors.LOW_LEVEL_CALL_FAILED();
        }
      }
      results[i] = response;
    }
    return results;
  }
}