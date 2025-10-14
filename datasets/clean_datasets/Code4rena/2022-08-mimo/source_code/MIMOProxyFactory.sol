pragma solidity ^0.8.10;
library Clones {
    function clone(address implementation) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }
    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}
interface IMIMOProxy {
  event Execute(address indexed target, bytes data, bytes response);
  event TransferOwnership(address indexed oldOwner, address indexed newOwner);
  function initialize() external;
  function getPermission(
    address envoy,
    address target,
    bytes4 selector
  ) external view returns (bool);
  function owner() external view returns (address);
  function minGasReserve() external view returns (uint256);
  function execute(address target, bytes calldata data) external payable returns (bytes memory response);
  function setPermission(
    address envoy,
    address target,
    bytes4 selector,
    bool permission
  ) external;
  function transferOwnership(address newOwner) external;
  function multicall(address[] calldata targets, bytes[] calldata data) external returns (bytes[] memory);
}
interface IMIMOProxyFactory {
  event DeployProxy(address indexed deployer, address indexed owner, address proxy);
  function isProxy(address proxy) external view returns (bool result);
  function VERSION() external view returns (uint256);
  function deploy() external returns (IMIMOProxy proxy);
  function deployFor(address owner) external returns (IMIMOProxy proxy);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
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
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }
    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !Address.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
    }
}
pragma experimental ABIEncoderV2;
contract BoringBatchable {
  error BatchError(bytes innerError);
  function _getRevertMsg(bytes memory _returnData) internal pure {
    if (_returnData.length < 68) revert BatchError(_returnData);
    assembly {
      _returnData := add(_returnData, 0x04)
    }
    revert(abi.decode(_returnData, (string))); 
  }
  function batch(bytes[] calldata calls, bool revertOnFail) external payable {
    for (uint256 i = 0; i < calls.length; i++) {
      (bool success, bytes memory result) = address(this).delegatecall(calls[i]);
      if (!success && revertOnFail) {
        _getRevertMsg(result);
      }
    }
  }
}
library CustomErrors {
  error CANNOT_SET_TO_ADDRESS_ZERO();
  error INITIATOR_NOT_AUTHORIZED(address actual, address expected);
  error CALLER_NOT_LENDING_POOL(address actual, address expected);
  error CANNOT_REPAY_FLASHLOAN();
  error INVALID_AGGREGATOR();
  error AGGREGATOR_CALL_FAILED();
  error EXECUTION_NOT_AUTHORIZED(address owner, address caller, address target, bytes4 selector);
  error EXECUTION_REVERTED();
  error NOT_OWNER(address owner, address caller);
  error OWNER_CHANGED(address originalOwner, address newOwner);
  error TARGET_INVALID(address target);
  error CALLER_NOT_VAULT_OWNER(address callerProxy, address vaultOwner);
  error CALLER_NOT_PROTOCOL_MANAGER();
  error MANAGER_NOT_LISTED();
  error VAULT_NOT_UNDER_MANAGEMENT();
  error CALLER_NOT_SELECTED_MANAGER();
  error PROXY_ALREADY_EXISTS(address owner);
  error MAX_OPERATIONS_REACHED();
  error MINT_AMOUNT_GREATER_THAN_VAULT_DEBT();
  error VAULT_VALUE_CHANGE_TOO_HIGH();
  error FINAL_VAULT_RATIO_TOO_LOW(uint256 minRatio, uint256 actualRatio);
  error VAULT_NOT_AUTOMATED();
  error VAULT_TRIGGER_RATIO_NOT_REACHED(uint256 actual, uint256 expected);
  error TARGETS_LENGTH_DIFFERENT_THAN_DATA_LENGTH(uint256 targetsLength, uint256 dataLength);
  error LOW_LEVEL_CALL_FAILED();
  error REBALANCE_AMOUNT_CANNOT_BE_ZERO();
  error VARIABLE_FEE_TOO_HIGH(uint256 maxVarFee, uint256 actualVarFee);
}
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
contract MIMOProxyFactory is IMIMOProxyFactory {
  using Clones for address;
  address public immutable mimoProxyBase;
  uint256 public constant override VERSION = 1;
  mapping(address => bool) internal _proxies;
  constructor(address _mimoProxyBase) {
    mimoProxyBase = _mimoProxyBase;
  }
  function isProxy(address proxy) external view override returns (bool result) {
    result = _proxies[proxy];
  }
  function deploy() external override returns (IMIMOProxy proxy) {
    proxy = deployFor(msg.sender);
  }
  function deployFor(address owner) public override returns (IMIMOProxy proxy) {
    proxy = IMIMOProxy(mimoProxyBase.clone());
    proxy.initialize();
    proxy.transferOwnership(owner);
    _proxies[address(proxy)] = true;
    emit DeployProxy(msg.sender, owner, address(proxy));
  }
}