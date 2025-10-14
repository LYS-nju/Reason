pragma solidity ^0.8.13;
abstract contract Admin {
  bytes32 constant _adminSlot = 0x3f106594dc74eeef980dae234cde8324dc2497b13d27a0c59e55bd2ca10a07c9;
  modifier onlyAdmin() {
    require(msg.sender == getAdmin(), "HOLOGRAPH: admin only function");
    _;
  }
  constructor() {}
  function admin() public view returns (address) {
    return getAdmin();
  }
  function getAdmin() public view returns (address adminAddress) {
    assembly {
      adminAddress := sload(_adminSlot)
    }
  }
  function setAdmin(address adminAddress) public onlyAdmin {
    assembly {
      sstore(_adminSlot, adminAddress)
    }
  }
  function adminCall(address target, bytes calldata data) external payable onlyAdmin {
    assembly {
      calldatacopy(0, data.offset, data.length)
      let result := call(gas(), target, callvalue(), 0, data.length, 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
interface InitializableInterface {
  function init(bytes memory initPayload) external returns (bytes4);
}
abstract contract Initializable is InitializableInterface {
  bytes32 constant _initializedSlot = 0x4e5f991bca30eca2d4643aaefa807e88f96a4a97398933d572a3c0d973004a01;
  constructor() {}
  function init(bytes memory initPayload) external virtual returns (bytes4);
  function _isInitialized() internal view returns (bool initialized) {
    assembly {
      initialized := sload(_initializedSlot)
    }
  }
  function _setInitialized() internal {
    assembly {
      sstore(_initializedSlot, 0x0000000000000000000000000000000000000000000000000000000000000001)
    }
  }
}
interface HolographInterface {
  function getBridge() external view returns (address bridge);
  function setBridge(address bridge) external;
  function getChainId() external view returns (uint256 chainId);
  function setChainId(uint256 chainId) external;
  function getFactory() external view returns (address factory);
  function setFactory(address factory) external;
  function getHolographChainId() external view returns (uint32 holographChainId);
  function setHolographChainId(uint32 holographChainId) external;
  function getInterfaces() external view returns (address interfaces);
  function setInterfaces(address interfaces) external;
  function getOperator() external view returns (address operator);
  function setOperator(address operator) external;
  function getRegistry() external view returns (address registry);
  function setRegistry(address registry) external;
  function getTreasury() external view returns (address treasury);
  function setTreasury(address treasury) external;
  function getUtilityToken() external view returns (address utilityToken);
  function setUtilityToken(address utilityToken) external;
}
contract Holograph is Admin, Initializable, HolographInterface {
  bytes32 constant _bridgeSlot = 0xeb87cbb21687feb327e3d58c6c16d552231d12c7a0e8115042a4165fac8a77f9;
  bytes32 constant _chainIdSlot = 0x7651bfc11f7485d07ab2b41c1312e2007c8cb7efb0f7352a6dee4a1153eebab2;
  bytes32 constant _factorySlot = 0xa49f20855ba576e09d13c8041c8039fa655356ea27f6c40f1ec46a4301cd5b23;
  bytes32 constant _holographChainIdSlot = 0xd840a780c26e07edc6e1ee2eaa6f134ed5488dbd762614116653cee8542a3844;
  bytes32 constant _interfacesSlot = 0xbd3084b8c09da87ad159c247a60e209784196be2530cecbbd8f337fdd1848827;
  bytes32 constant _operatorSlot = 0x7caba557ad34138fa3b7e43fb574e0e6cc10481c3073e0dffbc560db81b5c60f;
  bytes32 constant _registrySlot = 0xce8e75d5c5227ce29a4ee170160bb296e5dea6934b80a9bd723f7ef1e7c850e7;
  bytes32 constant _treasurySlot = 0x4215e7a38d75164ca078bbd61d0992cdeb1ba16f3b3ead5944966d3e4080e8b6;
  bytes32 constant _utilityTokenSlot = 0xbf76518d46db472b71aa7677a0908b8016f3dee568415ffa24055f9a670f9c37;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (
      uint32 holographChainId,
      address bridge,
      address factory,
      address interfaces,
      address operator,
      address registry,
      address treasury,
      address utilityToken
    ) = abi.decode(initPayload, (uint32, address, address, address, address, address, address, address));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_chainIdSlot, chainid())
      sstore(_holographChainIdSlot, holographChainId)
      sstore(_bridgeSlot, bridge)
      sstore(_factorySlot, factory)
      sstore(_interfacesSlot, interfaces)
      sstore(_operatorSlot, operator)
      sstore(_registrySlot, registry)
      sstore(_treasurySlot, treasury)
      sstore(_utilityTokenSlot, utilityToken)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getBridge() external view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function setBridge(address bridge) external onlyAdmin {
    assembly {
      sstore(_bridgeSlot, bridge)
    }
  }
  function getChainId() external view returns (uint256 chainId) {
    assembly {
      chainId := sload(_chainIdSlot)
    }
  }
  function setChainId(uint256 chainId) external onlyAdmin {
    assembly {
      sstore(_chainIdSlot, chainId)
    }
  }
  function getFactory() external view returns (address factory) {
    assembly {
      factory := sload(_factorySlot)
    }
  }
  function setFactory(address factory) external onlyAdmin {
    assembly {
      sstore(_factorySlot, factory)
    }
  }
  function getHolographChainId() external view returns (uint32 holographChainId) {
    assembly {
      holographChainId := sload(_holographChainIdSlot)
    }
  }
  function setHolographChainId(uint32 holographChainId) external onlyAdmin {
    assembly {
      sstore(_holographChainIdSlot, holographChainId)
    }
  }
  function getInterfaces() external view returns (address interfaces) {
    assembly {
      interfaces := sload(_interfacesSlot)
    }
  }
  function setInterfaces(address interfaces) external onlyAdmin {
    assembly {
      sstore(_interfacesSlot, interfaces)
    }
  }
  function getOperator() external view returns (address operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  function setOperator(address operator) external onlyAdmin {
    assembly {
      sstore(_operatorSlot, operator)
    }
  }
  function getRegistry() external view returns (address registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  function setRegistry(address registry) external onlyAdmin {
    assembly {
      sstore(_registrySlot, registry)
    }
  }
  function getTreasury() external view returns (address treasury) {
    assembly {
      treasury := sload(_treasurySlot)
    }
  }
  function setTreasury(address treasury) external onlyAdmin {
    assembly {
      sstore(_treasurySlot, treasury)
    }
  }
  function getUtilityToken() external view returns (address utilityToken) {
    assembly {
      utilityToken := sload(_utilityTokenSlot)
    }
  }
  function setUtilityToken(address utilityToken) external onlyAdmin {
    assembly {
      sstore(_utilityTokenSlot, utilityToken)
    }
  }
  receive() external payable {
    revert();
  }
  fallback() external payable {
    revert();
  }
}
interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address _owner) external view returns (uint256 balance);
  function transfer(address _to, uint256 _value) external returns (bool success);
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  ) external returns (bool success);
  function approve(address _spender, uint256 _value) external returns (bool success);
  function allowance(address _owner, address _spender) external view returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
interface ERC20Burnable {
  function burn(uint256 amount) external;
  function burnFrom(address account, uint256 amount) external returns (bool);
}
interface ERC20Metadata {
  function decimals() external view returns (uint8);
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
}
interface ERC20Permit {
  function permit(
    address account,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
  function nonces(address account) external view returns (uint256);
  function DOMAIN_SEPARATOR() external view returns (bytes32);
}
interface ERC20Receiver {
  function onERC20Received(
    address account,
    address recipient,
    uint256 amount,
    bytes memory data
  ) external returns (bytes4);
}
interface ERC20Safer {
  function safeTransfer(address recipient, uint256 amount) external returns (bool);
  function safeTransfer(
    address recipient,
    uint256 amount,
    bytes memory data
  ) external returns (bool);
  function safeTransferFrom(
    address account,
    address recipient,
    uint256 amount
  ) external returns (bool);
  function safeTransferFrom(
    address account,
    address recipient,
    uint256 amount,
    bytes memory data
  ) external returns (bool);
}
interface ERC165 {
  function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
interface Holographable {
  function bridgeIn(uint32 fromChain, bytes calldata payload) external returns (bytes4);
  function bridgeOut(
    uint32 toChain,
    address sender,
    bytes calldata payload
  ) external returns (bytes4 selector, bytes memory data);
}
interface HolographERC20Interface is
  ERC165,
  ERC20,
  ERC20Burnable,
  ERC20Metadata,
  ERC20Receiver,
  ERC20Safer,
  ERC20Permit,
  Holographable
{
  function holographBridgeMint(address to, uint256 amount) external returns (bytes4);
  function sourceBurn(address from, uint256 amount) external;
  function sourceMint(address to, uint256 amount) external;
  function sourceMintBatch(address[] calldata wallets, uint256[] calldata amounts) external;
  function sourceTransfer(
    address from,
    address to,
    uint256 amount
  ) external;
}
interface HolographBridgeInterface {
  function bridgeInRequest(
    uint256 nonce,
    uint32 fromChain,
    address holographableContract,
    address hToken,
    address hTokenRecipient,
    uint256 hTokenValue,
    bool doNotRevert,
    bytes calldata bridgeInPayload
  ) external payable;
  function bridgeOutRequest(
    uint32 toChain,
    address holographableContract,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata bridgeOutPayload
  ) external payable;
  function revertedBridgeOutRequest(
    address sender,
    uint32 toChain,
    address holographableContract,
    bytes calldata bridgeOutPayload
  ) external returns (string memory revertReason);
  function getBridgeOutRequestPayload(
    uint32 toChain,
    address holographableContract,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata bridgeOutPayload
  ) external returns (bytes memory samplePayload);
  function getMessageFee(
    uint32 toChain,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata crossChainPayload
  ) external view returns (uint256 hlgFee, uint256 msgFee);
  function getFactory() external view returns (address factory);
  function setFactory(address factory) external;
  function getHolograph() external view returns (address holograph);
  function setHolograph(address holograph) external;
  function getJobNonce() external view returns (uint256 jobNonce);
  function getOperator() external view returns (address operator);
  function setOperator(address operator) external;
  function getRegistry() external view returns (address registry);
  function setRegistry(address registry) external;
}
struct DeploymentConfig {
  bytes32 contractType;
  uint32 chainType;
  bytes32 salt;
  bytes byteCode;
  bytes initCode;
}
struct Verification {
  bytes32 r;
  bytes32 s;
  uint8 v;
}
interface HolographFactoryInterface {
  event BridgeableContractDeployed(address indexed contractAddress, bytes32 indexed hash);
  function deployHolographableContract(
    DeploymentConfig memory config,
    Verification memory signature,
    address signer
  ) external;
  function getHolograph() external view returns (address holograph);
  function setHolograph(address holograph) external;
  function getRegistry() external view returns (address registry);
  function setRegistry(address registry) external;
}
struct OperatorJob {
  uint8 pod;
  uint16 blockTimes;
  address operator;
  uint40 startBlock;
  uint64 startTimestamp;
  uint16[5] fallbackOperators;
}
interface HolographOperatorInterface {
  event AvailableOperatorJob(bytes32 jobHash, bytes payload);
  event CrossChainMessageSent(bytes32 messageHash);
  event FailedOperatorJob(bytes32 jobHash);
  function executeJob(bytes calldata bridgeInRequestPayload) external payable;
  function nonRevertingBridgeCall(address msgSender, bytes calldata payload) external payable;
  function crossChainMessage(bytes calldata bridgeInRequestPayload) external payable;
  function jobEstimator(bytes calldata bridgeInRequestPayload) external payable returns (uint256);
  function send(
    uint256 gasLimit,
    uint256 gasPrice,
    uint32 toChain,
    address msgSender,
    uint256 nonce,
    address holographableContract,
    bytes calldata bridgeOutPayload
  ) external payable;
  function getMessageFee(
    uint32 toChain,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata crossChainPayload
  ) external view returns (uint256 hlgFee, uint256 msgFee);
  function getJobDetails(bytes32 jobHash) external view returns (OperatorJob memory);
  function getTotalPods() external view returns (uint256 totalPods);
  function getPodOperatorsLength(uint256 pod) external view returns (uint256);
  function getPodOperators(uint256 pod) external view returns (address[] memory operators);
  function getPodOperators(
    uint256 pod,
    uint256 index,
    uint256 length
  ) external view returns (address[] memory operators);
  function getPodBondAmounts(uint256 pod) external view returns (uint256 base, uint256 current);
  function getBondedAmount(address operator) external view returns (uint256 amount);
  function getBondedPod(address operator) external view returns (uint256 pod);
  function topupUtilityToken(address operator, uint256 amount) external;
  function bondUtilityToken(
    address operator,
    uint256 amount,
    uint256 pod
  ) external;
  function unbondUtilityToken(address operator, address recipient) external;
  function getBridge() external view returns (address bridge);
  function setBridge(address bridge) external;
  function getHolograph() external view returns (address holograph);
  function setHolograph(address holograph) external;
  function getInterfaces() external view returns (address interfaces);
  function setInterfaces(address interfaces) external;
  function getMessagingModule() external view returns (address messagingModule);
  function setMessagingModule(address messagingModule) external;
  function getRegistry() external view returns (address registry);
  function setRegistry(address registry) external;
  function getUtilityToken() external view returns (address utilityToken);
  function setUtilityToken(address utilityToken) external;
}
interface HolographRegistryInterface {
  function isHolographedContract(address smartContract) external view returns (bool);
  function isHolographedHashDeployed(bytes32 hash) external view returns (bool);
  function referenceContractTypeAddress(address contractAddress) external returns (bytes32);
  function getContractTypeAddress(bytes32 contractType) external view returns (address);
  function setContractTypeAddress(bytes32 contractType, address contractAddress) external;
  function getHolograph() external view returns (address holograph);
  function setHolograph(address holograph) external;
  function getHolographableContracts(uint256 index, uint256 length) external view returns (address[] memory contracts);
  function getHolographableContractsLength() external view returns (uint256);
  function getHolographedHashAddress(bytes32 hash) external view returns (address);
  function setHolographedHashAddress(bytes32 hash, address contractAddress) external;
  function getHToken(uint32 chainId) external view returns (address);
  function setHToken(uint32 chainId, address hToken) external;
  function getReservedContractTypeAddress(bytes32 contractType) external view returns (address contractTypeAddress);
  function setReservedContractTypeAddress(bytes32 hash, bool reserved) external;
  function setReservedContractTypeAddresses(bytes32[] calldata hashes, bool[] calldata reserved) external;
  function getUtilityToken() external view returns (address utilityToken);
  function setUtilityToken(address utilityToken) external;
}
contract HolographBridge is Admin, Initializable, HolographBridgeInterface {
  bytes32 constant _factorySlot = 0xa49f20855ba576e09d13c8041c8039fa655356ea27f6c40f1ec46a4301cd5b23;
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _jobNonceSlot = 0x1cda64803f3b43503042e00863791e8d996666552d5855a78d53ee1dd4b3286d;
  bytes32 constant _operatorSlot = 0x7caba557ad34138fa3b7e43fb574e0e6cc10481c3073e0dffbc560db81b5c60f;
  bytes32 constant _registrySlot = 0xce8e75d5c5227ce29a4ee170160bb296e5dea6934b80a9bd723f7ef1e7c850e7;
  modifier onlyOperator() {
    require(msg.sender == address(_operator()), "HOLOGRAPH: operator only call");
    _;
  }
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address factory, address holograph, address operator, address registry) = abi.decode(
      initPayload,
      (address, address, address, address)
    );
    assembly {
      sstore(_adminSlot, origin())
      sstore(_factorySlot, factory)
      sstore(_holographSlot, holograph)
      sstore(_operatorSlot, operator)
      sstore(_registrySlot, registry)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function bridgeInRequest(
    uint256, 
    uint32 fromChain,
    address holographableContract,
    address hToken,
    address hTokenRecipient,
    uint256 hTokenValue,
    bool doNotRevert,
    bytes calldata bridgeInPayload
  ) external payable onlyOperator {
    require(
      _registry().isHolographedContract(holographableContract) || address(_factory()) == holographableContract,
      "HOLOGRAPH: not holographed"
    );
    bytes4 selector = Holographable(holographableContract).bridgeIn(fromChain, bridgeInPayload);
    require(selector == Holographable.bridgeIn.selector, "HOLOGRAPH: bridge in failed");
    if (hTokenValue > 0) {
      require(
        HolographERC20Interface(hToken).holographBridgeMint(hTokenRecipient, hTokenValue) ==
          HolographERC20Interface.holographBridgeMint.selector,
        "HOLOGRAPH: hToken mint failed"
      );
    }
    require(doNotRevert, "HOLOGRAPH: reverted");
  }
  function bridgeOutRequest(
    uint32 toChain,
    address holographableContract,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata bridgeOutPayload
  ) external payable {
    require(
      _registry().isHolographedContract(holographableContract) || address(_factory()) == holographableContract,
      "HOLOGRAPH: not holographed"
    );
    (bytes4 selector, bytes memory returnedPayload) = Holographable(holographableContract).bridgeOut(
      toChain,
      msg.sender,
      bridgeOutPayload
    );
    require(selector == Holographable.bridgeOut.selector, "HOLOGRAPH: bridge out failed");
    _operator().send{value: msg.value}(
      gasLimit,
      gasPrice,
      toChain,
      msg.sender,
      _jobNonce(),
      holographableContract,
      returnedPayload
    );
  }
  function revertedBridgeOutRequest(
    address sender,
    uint32 toChain,
    address holographableContract,
    bytes calldata bridgeOutPayload
  ) external returns (string memory revertReason) {
    try Holographable(holographableContract).bridgeOut(toChain, sender, bridgeOutPayload) returns (
      bytes4 selector,
      bytes memory payload
    ) {
      if (selector != Holographable.bridgeOut.selector) {
        return "HOLOGRAPH: bridge out failed";
      }
      assembly {
        revert(add(payload, 0x20), mload(payload))
      }
    } catch Error(string memory reason) {
      return reason;
    } catch {
      return "HOLOGRAPH: unknown error";
    }
  }
  function getBridgeOutRequestPayload(
    uint32 toChain,
    address holographableContract,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata bridgeOutPayload
  ) external returns (bytes memory samplePayload) {
    require(
      _registry().isHolographedContract(holographableContract) || address(_factory()) == holographableContract,
      "HOLOGRAPH: not holographed"
    );
    bytes memory payload;
    try this.revertedBridgeOutRequest(msg.sender, toChain, holographableContract, bridgeOutPayload) returns (
      string memory revertReason
    ) {
      revert(revertReason);
    } catch (bytes memory realResponse) {
      payload = realResponse;
    }
    uint256 jobNonce;
    assembly {
      jobNonce := sload(_jobNonceSlot)
    }
    uint256 fee = 0;
    if (gasPrice < type(uint256).max && gasLimit < type(uint256).max) {
      (uint256 hlgFee, ) = _operator().getMessageFee(toChain, gasLimit, gasPrice, bridgeOutPayload);
      fee = hlgFee;
    }
    bytes memory encodedData = abi.encodeWithSelector(
      HolographBridgeInterface.bridgeInRequest.selector,
      jobNonce + 1,
      _holograph().getHolographChainId(),
      holographableContract,
      _registry().getHToken(_holograph().getHolographChainId()),
      address(0),
      fee,
      true,
      payload
    );
    samplePayload = abi.encodePacked(encodedData, gasLimit, gasPrice);
  }
  function getMessageFee(
    uint32,
    uint256,
    uint256,
    bytes calldata
  ) external view returns (uint256, uint256) {
    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := staticcall(gas(), sload(_operatorSlot), 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
  function getFactory() external view returns (address factory) {
    assembly {
      factory := sload(_factorySlot)
    }
  }
  function setFactory(address factory) external onlyAdmin {
    assembly {
      sstore(_factorySlot, factory)
    }
  }
  function getHolograph() external view returns (address holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function setHolograph(address holograph) external onlyAdmin {
    assembly {
      sstore(_holographSlot, holograph)
    }
  }
  function getJobNonce() external view returns (uint256 jobNonce) {
    assembly {
      jobNonce := sload(_jobNonceSlot)
    }
  }
  function getOperator() external view returns (address operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  function setOperator(address operator) external onlyAdmin {
    assembly {
      sstore(_operatorSlot, operator)
    }
  }
  function getRegistry() external view returns (address registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  function setRegistry(address registry) external onlyAdmin {
    assembly {
      sstore(_registrySlot, registry)
    }
  }
  function _factory() private view returns (HolographFactoryInterface factory) {
    assembly {
      factory := sload(_factorySlot)
    }
  }
  function _holograph() private view returns (HolographInterface holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function _jobNonce() private returns (uint256 jobNonce) {
    assembly {
      jobNonce := add(sload(_jobNonceSlot), 0x0000000000000000000000000000000000000000000000000000000000000001)
      sstore(_jobNonceSlot, jobNonce)
    }
  }
  function _operator() private view returns (HolographOperatorInterface operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  function _registry() private view returns (HolographRegistryInterface registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  receive() external payable {
    revert();
  }
  fallback() external payable {
    revert();
  }
}
interface HolographerInterface {
  function getDeploymentBlock() external view returns (address holograph);
  function getHolograph() external view returns (address holograph);
  function getHolographEnforcer() external view returns (address);
  function getOriginChain() external view returns (uint32 originChain);
  function getSourceContract() external view returns (address sourceContract);
}
contract Holographer is Admin, Initializable, HolographerInterface {
  bytes32 constant _originChainSlot = 0xd49ffd6af8249d6e6b5963d9d2b22c6db30ad594cb468453047a14e1c1bcde4d;
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _contractTypeSlot = 0x0b671eb65810897366dd82c4cbb7d9dff8beda8484194956e81e89b8a361d9c7;
  bytes32 constant _sourceContractSlot = 0x27d542086d1e831d40b749e7f5509a626c3047a36d160781c40d5acc83e5b074;
  bytes32 constant _blockHeightSlot = 0x9172848b0f1df776dc924b58e7fa303087ae0409bbf611608529e7f747d55de3;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPHER: already initialized");
    (bytes memory encoded, bytes memory initCode) = abi.decode(initPayload, (bytes, bytes));
    (uint32 originChain, address holograph, bytes32 contractType, address sourceContract) = abi.decode(
      encoded,
      (uint32, address, bytes32, address)
    );
    assembly {
      sstore(_adminSlot, caller())
      sstore(_blockHeightSlot, number())
      sstore(_contractTypeSlot, contractType)
      sstore(_holographSlot, holograph)
      sstore(_originChainSlot, originChain)
      sstore(_sourceContractSlot, sourceContract)
    }
    (bool success, bytes memory returnData) = HolographRegistryInterface(HolographInterface(holograph).getRegistry())
      .getReservedContractTypeAddress(contractType)
      .delegatecall(abi.encodeWithSignature("init(bytes)", initCode));
    bytes4 selector = abi.decode(returnData, (bytes4));
    require(success && selector == InitializableInterface.init.selector, "initialization failed");
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getDeploymentBlock() external view returns (address holograph) {
    assembly {
      holograph := sload(_blockHeightSlot)
    }
  }
  function getHolograph() external view returns (address holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function getHolographEnforcer() public view returns (address) {
    HolographInterface holograph;
    bytes32 contractType;
    assembly {
      holograph := sload(_holographSlot)
      contractType := sload(_contractTypeSlot)
    }
    return HolographRegistryInterface(holograph.getRegistry()).getReservedContractTypeAddress(contractType);
  }
  function getOriginChain() external view returns (uint32 originChain) {
    assembly {
      originChain := sload(_originChainSlot)
    }
  }
  function getSourceContract() external view returns (address sourceContract) {
    assembly {
      sourceContract := sload(_sourceContractSlot)
    }
  }
  receive() external payable {}
  fallback() external payable {
    address holographEnforcer = getHolographEnforcer();
    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), holographEnforcer, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract HolographFactory is Admin, Initializable, Holographable, HolographFactoryInterface {
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _registrySlot = 0xce8e75d5c5227ce29a4ee170160bb296e5dea6934b80a9bd723f7ef1e7c850e7;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address holograph, address registry) = abi.decode(initPayload, (address, address));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_holographSlot, holograph)
      sstore(_registrySlot, registry)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function bridgeIn(
    uint32, 
    bytes calldata payload
  ) external returns (bytes4) {
    (DeploymentConfig memory config, Verification memory signature, address signer) = abi.decode(
      payload,
      (DeploymentConfig, Verification, address)
    );
    HolographFactoryInterface(address(this)).deployHolographableContract(config, signature, signer);
    return Holographable.bridgeIn.selector;
  }
  function bridgeOut(
    uint32, 
    address, 
    bytes calldata payload
  ) external pure returns (bytes4 selector, bytes memory data) {
    return (Holographable.bridgeOut.selector, payload);
  }
  function deployHolographableContract(
    DeploymentConfig memory config,
    Verification memory signature,
    address signer
  ) external {
    address registry;
    address holograph;
    assembly {
      holograph := sload(_holographSlot)
      registry := sload(_registrySlot)
    }
    bytes32 hash = keccak256(
      abi.encodePacked(
        config.contractType,
        config.chainType,
        config.salt,
        keccak256(config.byteCode),
        keccak256(config.initCode),
        signer
      )
    );
    require(_verifySigner(signature.r, signature.s, signature.v, hash, signer), "HOLOGRAPH: invalid signature");
    bytes memory holographerBytecode = type(Holographer).creationCode;
    address holographerAddress = address(
      uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), hash, keccak256(holographerBytecode)))))
    );
    require(!_isContract(holographerAddress), "HOLOGRAPH: already deployed");
    uint256 saltInt = uint256(hash);
    address sourceContractAddress;
    bytes memory sourceByteCode = config.byteCode;
    assembly {
      sourceContractAddress := create2(0, add(sourceByteCode, 0x20), mload(sourceByteCode), saltInt)
    }
    assembly {
      holographerAddress := create2(0, add(holographerBytecode, 0x20), mload(holographerBytecode), saltInt)
    }
    require(
      InitializableInterface(holographerAddress).init(
        abi.encode(abi.encode(config.chainType, holograph, config.contractType, sourceContractAddress), config.initCode)
      ) == InitializableInterface.init.selector,
      "initialization failed"
    );
    HolographRegistryInterface(registry).setHolographedHashAddress(hash, holographerAddress);
    emit BridgeableContractDeployed(holographerAddress, hash);
  }
  function getHolograph() external view returns (address holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function setHolograph(address holograph) external onlyAdmin {
    assembly {
      sstore(_holographSlot, holograph)
    }
  }
  function getRegistry() external view returns (address registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  function setRegistry(address registry) external onlyAdmin {
    assembly {
      sstore(_registrySlot, registry)
    }
  }
  function _isContract(address contractAddress) private view returns (bool) {
    bytes32 codehash;
    assembly {
      codehash := extcodehash(contractAddress)
    }
    return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
  }
  function _verifySigner(
    bytes32 r,
    bytes32 s,
    uint8 v,
    bytes32 hash,
    address signer
  ) private pure returns (bool) {
    if (v < 27) {
      v += 27;
    }
    return (ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), v, r, s) == signer ||
      ecrecover(hash, v, r, s) == signer);
  }
  receive() external payable {
    revert();
  }
  fallback() external payable {
    revert();
  }
}
contract HolographGenesis {
  mapping(address => bool) private _approvedDeployers;
  event Message(string message);
  modifier onlyDeployer() {
    require(_approvedDeployers[msg.sender], "HOLOGRAPH: deployer not approved");
    _;
  }
  constructor() {
    _approvedDeployers[tx.origin] = true;
    emit Message("The future of NFTs is Holograph.");
  }
  function deploy(
    uint256 chainId,
    bytes12 saltHash,
    bytes memory sourceCode,
    bytes memory initCode
  ) external onlyDeployer {
    require(chainId == block.chainid, "HOLOGRAPH: incorrect chain id");
    bytes32 salt = bytes32(abi.encodePacked(msg.sender, saltHash));
    address contractAddress = address(
      uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(sourceCode)))))
    );
    require(!_isContract(contractAddress), "HOLOGRAPH: already deployed");
    assembly {
      contractAddress := create2(0, add(sourceCode, 0x20), mload(sourceCode), salt)
    }
    require(_isContract(contractAddress), "HOLOGRAPH: deployment failed");
    require(
      InitializableInterface(contractAddress).init(initCode) == InitializableInterface.init.selector,
      "HOLOGRAPH: initialization failed"
    );
  }
  function approveDeployer(address newDeployer, bool approve) external onlyDeployer {
    _approvedDeployers[newDeployer] = approve;
  }
  function isApprovedDeployer(address deployer) external view returns (bool) {
    return _approvedDeployers[deployer];
  }
  function _isContract(address contractAddress) internal view returns (bool) {
    bytes32 codehash;
    assembly {
      codehash := extcodehash(contractAddress)
    }
    return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
  }
}
enum ChainIdType {
  UNDEFINED, 
  EVM, 
  HOLOGRAPH, 
  LAYERZERO, 
  HYPERLANE 
}
enum InterfaceType {
  UNDEFINED, 
  ERC20, 
  ERC721, 
  ERC1155, 
  PA1D 
}
enum TokenUriType {
  UNDEFINED, 
  IPFS, 
  HTTPS, 
  ARWEAVE 
}
interface CollectionURI {
  function contractURI() external view returns (string memory);
}
interface ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
  function balanceOf(address _owner) external view returns (uint256);
  function ownerOf(uint256 _tokenId) external view returns (address);
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata data
  ) external payable;
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) external payable;
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) external payable;
  function approve(address _approved, uint256 _tokenId) external payable;
  function setApprovalForAll(address _operator, bool _approved) external;
  function getApproved(uint256 _tokenId) external view returns (address);
  function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
interface ERC721Enumerable {
  function totalSupply() external view returns (uint256);
  function tokenByIndex(uint256 _index) external view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}
interface ERC721Metadata {
  function name() external view returns (string memory _name);
  function symbol() external view returns (string memory _symbol);
  function tokenURI(uint256 _tokenId) external view returns (string memory);
}
interface ERC721TokenReceiver {
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bytes4);
}
struct ZoraDecimal {
  uint256 value;
}
struct ZoraBidShares {
  ZoraDecimal prevOwner;
  ZoraDecimal creator;
  ZoraDecimal owner;
}
interface PA1DInterface {
  function initPA1D(bytes memory data) external returns (bytes4);
  function configurePayouts(address payable[] memory addresses, uint256[] memory bps) external;
  function getPayoutInfo() external view returns (address payable[] memory addresses, uint256[] memory bps);
  function getEthPayout() external;
  function getTokenPayout(address tokenAddress) external;
  function getTokensPayout(address[] memory tokenAddresses) external;
  function supportsInterface(bytes4 interfaceId) external pure returns (bool);
  function setRoyalties(
    uint256 tokenId,
    address payable receiver,
    uint256 bp
  ) external;
  function royaltyInfo(uint256 tokenId, uint256 value) external view returns (address, uint256);
  function getFeeBps(uint256 tokenId) external view returns (uint256[] memory);
  function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory);
  function getRoyalties(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);
  function getFees(uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);
  function tokenCreator(
    address, 
    uint256 tokenId
  ) external view returns (address);
  function calculateRoyaltyFee(
    address, 
    uint256 tokenId,
    uint256 amount
  ) external view returns (uint256);
  function marketContract() external view returns (address);
  function tokenCreators(uint256 tokenId) external view returns (address);
  function bidSharesForToken(uint256 tokenId) external view returns (ZoraBidShares memory bidShares);
  function getStorageSlot(string calldata slot) external pure returns (bytes32);
  function getTokenAddress(string memory tokenName) external view returns (address);
}
library Base64 {
  bytes private constant base64stdchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
  bytes private constant base64urlchars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";
  function encode(string memory _str) internal pure returns (string memory) {
    bytes memory _bs = bytes(_str);
    return encode(_bs);
  }
  function encode(bytes memory _bs) internal pure returns (string memory) {
    uint256 rem = _bs.length % 3;
    uint256 res_length = ((_bs.length + 2) / 3) * 4 - ((3 - rem) % 3);
    bytes memory res = new bytes(res_length);
    uint256 i = 0;
    uint256 j = 0;
    for (; i + 3 <= _bs.length; i += 3) {
      (res[j], res[j + 1], res[j + 2], res[j + 3]) = encode3(uint8(_bs[i]), uint8(_bs[i + 1]), uint8(_bs[i + 2]));
      j += 4;
    }
    if (rem != 0) {
      uint8 la0 = uint8(_bs[_bs.length - rem]);
      uint8 la1 = 0;
      if (rem == 2) {
        la1 = uint8(_bs[_bs.length - 1]);
      }
      (
        bytes1 b0,
        bytes1 b1,
        bytes1 b2, 
      ) = encode3(la0, la1, 0);
      res[j] = b0;
      res[j + 1] = b1;
      if (rem == 2) {
        res[j + 2] = b2;
      }
    }
    return string(res);
  }
  function encode3(
    uint256 a0,
    uint256 a1,
    uint256 a2
  )
    private
    pure
    returns (
      bytes1 b0,
      bytes1 b1,
      bytes1 b2,
      bytes1 b3
    )
  {
    uint256 n = (a0 << 16) | (a1 << 8) | a2;
    uint256 c0 = (n >> 18) & 63;
    uint256 c1 = (n >> 12) & 63;
    uint256 c2 = (n >> 6) & 63;
    uint256 c3 = (n) & 63;
    b0 = base64urlchars[c0];
    b1 = base64urlchars[c1];
    b2 = base64urlchars[c2];
    b3 = base64urlchars[c3];
  }
}
library Strings {
  function toHexString(address account) internal pure returns (string memory) {
    return toHexString(uint256(uint160(account)));
  }
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }
  function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = bytes16("0123456789abcdef")[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }
  function toAsciiString(address x) internal pure returns (string memory) {
    bytes memory s = new bytes(40);
    for (uint256 i = 0; i < 20; i++) {
      bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
      bytes1 hi = bytes1(uint8(b) / 16);
      bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
      s[2 * i] = char(hi);
      s[2 * i + 1] = char(lo);
    }
    return string(s);
  }
  function char(bytes1 b) internal pure returns (bytes1 c) {
    if (uint8(b) < 10) {
      return bytes1(uint8(b) + 0x30);
    } else {
      return bytes1(uint8(b) + 0x57);
    }
  }
  function uint2str(uint256 _i) internal pure returns (string memory _uint256AsString) {
    if (_i == 0) {
      return "0";
    }
    uint256 j = _i;
    uint256 len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint256 k = len;
    while (_i != 0) {
      k = k - 1;
      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }
  function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
}
contract HolographInterfaces is Admin, Initializable {
  mapping(InterfaceType => mapping(bytes4 => bool)) private _supportedInterfaces;
  mapping(ChainIdType => mapping(uint256 => mapping(ChainIdType => uint256))) private _chainIdMap;
  mapping(TokenUriType => string) private _prependURI;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    address contractAdmin = abi.decode(initPayload, (address));
    assembly {
      sstore(_adminSlot, contractAdmin)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function contractURI(
    string calldata name,
    string calldata imageURL,
    string calldata externalLink,
    uint16 bps,
    address contractAddress
  ) external pure returns (string memory) {
    return
      string(
        abi.encodePacked(
          "data:application/json;base64,",
          Base64.encode(
            abi.encodePacked(
              '{"name":"',
              name,
              '","description":"',
              name,
              '","image":"',
              imageURL,
              '","external_link":"',
              externalLink,
              '","seller_fee_basis_points":',
              Strings.uint2str(bps),
              ',"fee_recipient":"0x',
              Strings.toAsciiString(contractAddress),
              '"}'
            )
          )
        )
      );
  }
  function getUriPrepend(TokenUriType uriType) external view returns (string memory prepend) {
    prepend = _prependURI[uriType];
  }
  function updateUriPrepend(TokenUriType uriType, string calldata prepend) external onlyAdmin {
    _prependURI[uriType] = prepend;
  }
  function updateUriPrepends(TokenUriType[] calldata uriTypes, string[] calldata prepends) external onlyAdmin {
    for (uint256 i = 0; i < uriTypes.length; i++) {
      _prependURI[uriTypes[i]] = prepends[i];
    }
  }
  function getChainId(
    ChainIdType fromChainType,
    uint256 fromChainId,
    ChainIdType toChainType
  ) external view returns (uint256 toChainId) {
    return _chainIdMap[fromChainType][fromChainId][toChainType];
  }
  function updateChainIdMap(
    ChainIdType fromChainType,
    uint256 fromChainId,
    ChainIdType toChainType,
    uint256 toChainId
  ) external onlyAdmin {
    _chainIdMap[fromChainType][fromChainId][toChainType] = toChainId;
  }
  function updateChainIdMaps(
    ChainIdType[] calldata fromChainType,
    uint256[] calldata fromChainId,
    ChainIdType[] calldata toChainType,
    uint256[] calldata toChainId
  ) external onlyAdmin {
    uint256 length = fromChainType.length;
    for (uint256 i = 0; i < length; i++) {
      _chainIdMap[fromChainType[i]][fromChainId[i]][toChainType[i]] = toChainId[i];
    }
  }
  function supportsInterface(InterfaceType interfaceType, bytes4 interfaceId) external view returns (bool) {
    return _supportedInterfaces[interfaceType][interfaceId];
  }
  function updateInterface(
    InterfaceType interfaceType,
    bytes4 interfaceId,
    bool supported
  ) external onlyAdmin {
    _supportedInterfaces[interfaceType][interfaceId] = supported;
  }
  function updateInterfaces(
    InterfaceType interfaceType,
    bytes4[] calldata interfaceIds,
    bool supported
  ) external onlyAdmin {
    for (uint256 i = 0; i < interfaceIds.length; i++) {
      _supportedInterfaces[interfaceType][interfaceIds[i]] = supported;
    }
  }
  receive() external payable {
    revert();
  }
  fallback() external payable {
    revert();
  }
}
interface CrossChainMessageInterface {
  function send(
    uint256 gasLimit,
    uint256 gasPrice,
    uint32 toChain,
    address msgSender,
    uint256 msgValue,
    bytes calldata crossChainPayload
  ) external payable;
  function getMessageFee(
    uint32 toChain,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata crossChainPayload
  ) external view returns (uint256 hlgFee, uint256 msgFee);
  function getHlgFee(
    uint32 toChain,
    uint256 gasLimit,
    uint256 gasPrice
  ) external view returns (uint256 hlgFee);
}
interface HolographInterfacesInterface {
  function contractURI(
    string calldata name,
    string calldata imageURL,
    string calldata externalLink,
    uint16 bps,
    address contractAddress
  ) external pure returns (string memory);
  function getUriPrepend(TokenUriType uriType) external view returns (string memory prepend);
  function updateUriPrepend(TokenUriType uriType, string calldata prepend) external;
  function updateUriPrepends(TokenUriType[] calldata uriTypes, string[] calldata prepends) external;
  function getChainId(
    ChainIdType fromChainType,
    uint256 fromChainId,
    ChainIdType toChainType
  ) external view returns (uint256 toChainId);
  function updateChainIdMap(
    ChainIdType fromChainType,
    uint256 fromChainId,
    ChainIdType toChainType,
    uint256 toChainId
  ) external;
  function updateChainIdMaps(
    ChainIdType[] calldata fromChainType,
    uint256[] calldata fromChainId,
    ChainIdType[] calldata toChainType,
    uint256[] calldata toChainId
  ) external;
  function supportsInterface(InterfaceType interfaceType, bytes4 interfaceId) external view returns (bool);
  function updateInterface(
    InterfaceType interfaceType,
    bytes4 interfaceId,
    bool supported
  ) external;
  function updateInterfaces(
    InterfaceType interfaceType,
    bytes4[] calldata interfaceIds,
    bool supported
  ) external;
}
interface Ownable {
  function owner() external view returns (address);
  function isOwner() external view returns (bool);
  function isOwner(address wallet) external view returns (bool);
}
contract HolographOperator is Admin, Initializable, HolographOperatorInterface {
  bytes32 constant _bridgeSlot = 0xeb87cbb21687feb327e3d58c6c16d552231d12c7a0e8115042a4165fac8a77f9;
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _interfacesSlot = 0xbd3084b8c09da87ad159c247a60e209784196be2530cecbbd8f337fdd1848827;
  bytes32 constant _jobNonceSlot = 0x1cda64803f3b43503042e00863791e8d996666552d5855a78d53ee1dd4b3286d;
  bytes32 constant _messagingModuleSlot = 0x54176250282e65985d205704ffce44a59efe61f7afd99e29fda50f55b48c061a;
  bytes32 constant _registrySlot = 0xce8e75d5c5227ce29a4ee170160bb296e5dea6934b80a9bd723f7ef1e7c850e7;
  bytes32 constant _utilityTokenSlot = 0xbf76518d46db472b71aa7677a0908b8016f3dee568415ffa24055f9a670f9c37;
  uint256 private _blockTime;
  uint256 private _baseBondAmount;
  uint256 private _podMultiplier;
  uint256 private _operatorThreshold;
  uint256 private _operatorThresholdStep;
  uint256 private _operatorThresholdDivisor;
  uint256 private _inboundMessageCounter;
  mapping(bytes32 => uint256) private _operatorJobs;
  mapping(bytes32 => bool) private _failedJobs;
  mapping(uint256 => address) private _operatorTempStorage;
  uint32 private _operatorTempStorageCounter;
  address[][] private _operatorPods;
  mapping(address => uint256) private _bondedOperators;
  mapping(address => uint256) private _operatorPodIndex;
  mapping(address => uint256) private _bondedAmounts;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address bridge, address holograph, address interfaces, address registry, address utilityToken) = abi.decode(
      initPayload,
      (address, address, address, address, address)
    );
    assembly {
      sstore(_adminSlot, origin())
      sstore(_bridgeSlot, bridge)
      sstore(_holographSlot, holograph)
      sstore(_interfacesSlot, interfaces)
      sstore(_registrySlot, registry)
      sstore(_utilityTokenSlot, utilityToken)
    }
    _blockTime = 60; 
    unchecked {
      _baseBondAmount = 100 * (10**18); 
    }
    _podMultiplier = 2; 
    _operatorThreshold = 1000;
    _operatorThresholdStep = 10;
    _operatorThresholdDivisor = 100; 
    _operatorPods = [[address(0)]];
    _bondedOperators[address(0)] = 1;
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function resetOperator(
    uint256 blockTime,
    uint256 baseBondAmount,
    uint256 podMultiplier,
    uint256 operatorThreshold,
    uint256 operatorThresholdStep,
    uint256 operatorThresholdDivisor
  ) external onlyAdmin {
    _blockTime = blockTime;
    _baseBondAmount = baseBondAmount;
    _podMultiplier = podMultiplier;
    _operatorThreshold = operatorThreshold;
    _operatorThresholdStep = operatorThresholdStep;
    _operatorThresholdDivisor = operatorThresholdDivisor;
    _operatorPods = [[address(0)]];
    _bondedOperators[address(0)] = 1;
  }
  function executeJob(bytes calldata bridgeInRequestPayload) external payable {
    bytes32 hash = keccak256(bridgeInRequestPayload);
    require(_operatorJobs[hash] > 0, "HOLOGRAPH: invalid job");
    uint256 gasLimit = 0;
    uint256 gasPrice = 0;
    assembly {
      gasLimit := calldataload(sub(add(bridgeInRequestPayload.offset, bridgeInRequestPayload.length), 0x40))
      gasPrice := calldataload(sub(add(bridgeInRequestPayload.offset, bridgeInRequestPayload.length), 0x20))
    }
    OperatorJob memory job = getJobDetails(hash);
    delete _operatorJobs[hash];
    if (job.operator != address(0)) {
      uint256 pod = job.pod - 1;
      if (job.operator != msg.sender) {
        uint256 elapsedTime = block.timestamp - uint256(job.startTimestamp);
        uint256 timeDifference = elapsedTime / job.blockTimes;
        require(timeDifference > 0, "HOLOGRAPH: operator has time");
        require(gasPrice >= tx.gasprice, "HOLOGRAPH: gas spike detected");
        if (timeDifference < 6) {
          uint256 podIndex = uint256(job.fallbackOperators[timeDifference - 1]);
          if (podIndex > 0 && podIndex < _operatorPods[pod].length) {
            address fallbackOperator = _operatorPods[pod][podIndex];
            require(fallbackOperator == msg.sender, "HOLOGRAPH: invalid fallback");
          }
        }
        uint256 amount = _getBaseBondAmount(pod);
        _bondedAmounts[job.operator] -= amount;
        _bondedAmounts[msg.sender] += amount;
        if (_bondedAmounts[job.operator] >= amount) {
          _operatorPods[pod].push(job.operator);
          _operatorPodIndex[job.operator] = _operatorPods[pod].length - 1;
          _bondedOperators[job.operator] = job.pod;
        } else {
          uint256 leftovers = _bondedAmounts[job.operator];
          if (leftovers > 0) {
            _bondedAmounts[job.operator] = 0;
            _utilityToken().transfer(job.operator, leftovers);
          }
        }
      } else {
        _operatorPods[pod].push(msg.sender);
        _operatorPodIndex[job.operator] = _operatorPods[pod].length - 1;
        _bondedOperators[msg.sender] = job.pod;
      }
    }
    require(gasleft() > gasLimit, "HOLOGRAPH: not enough gas left");
    try
      HolographOperatorInterface(address(this)).nonRevertingBridgeCall{value: msg.value}(
        msg.sender,
        bridgeInRequestPayload
      )
    {
    } catch {
      _failedJobs[hash] = true;
      emit FailedOperatorJob(hash);
    }
    ++_inboundMessageCounter;
  }
  function nonRevertingBridgeCall(address msgSender, bytes calldata payload) external payable {
    require(msg.sender == address(this), "HOLOGRAPH: operator only call");
    assembly {
      calldatacopy(0, payload.offset, sub(payload.length, 0x20))
      mstore(0x84, msgSender)
      let result := call(
        mload(sub(payload.length, 0x40)),
        sload(_bridgeSlot),
        callvalue(),
        0,
        sub(payload.length, 0x40),
        0,
        0
      )
      if eq(result, 0) {
        revert(0, 0)
      }
      return(0, 0)
    }
  }
  function crossChainMessage(bytes calldata bridgeInRequestPayload) external payable {
    require(msg.sender == address(_messagingModule()), "HOLOGRAPH: messaging only call");
    unchecked {
      bytes32 jobHash = keccak256(bridgeInRequestPayload);
      ++_operatorTempStorageCounter;
      uint256 random = uint256(keccak256(abi.encodePacked(jobHash, _jobNonce(), block.number, block.timestamp)));
      uint256 pod = random % _operatorPods.length;
      uint256 podSize = _operatorPods[pod].length;
      uint256 operatorIndex = random % podSize;
      _operatorTempStorage[_operatorTempStorageCounter] = _operatorPods[pod][operatorIndex];
      _popOperator(pod, operatorIndex);
      if (podSize > 1) {
        podSize--;
      }
      _operatorJobs[jobHash] = uint256(
        ((pod + 1) << 248) |
          (uint256(_operatorTempStorageCounter) << 216) |
          (block.number << 176) |
          (_randomBlockHash(random, podSize, 1) << 160) |
          (_randomBlockHash(random, podSize, 2) << 144) |
          (_randomBlockHash(random, podSize, 3) << 128) |
          (_randomBlockHash(random, podSize, 4) << 112) |
          (_randomBlockHash(random, podSize, 5) << 96) |
          (block.timestamp << 16) |
          0
      ); 
      emit AvailableOperatorJob(jobHash, bridgeInRequestPayload);
    }
  }
  function jobEstimator(bytes calldata bridgeInRequestPayload) external payable returns (uint256) {
    assembly {
      calldatacopy(0, bridgeInRequestPayload.offset, sub(bridgeInRequestPayload.length, 0x40))
      mstore8(0xE3, 0x00)
      let result := call(gas(), sload(_bridgeSlot), callvalue(), 0, sub(bridgeInRequestPayload.length, 0x40), 0, 0)
      if eq(result, 1) {
        returndatacopy(0, 0, returndatasize())
        revert(0, returndatasize())
      }
      mstore(0x00, gas())
      return(0x00, 0x20)
    }
  }
  function send(
    uint256 gasLimit,
    uint256 gasPrice,
    uint32 toChain,
    address msgSender,
    uint256 nonce,
    address holographableContract,
    bytes calldata bridgeOutPayload
  ) external payable {
    require(msg.sender == _bridge(), "HOLOGRAPH: bridge only call");
    CrossChainMessageInterface messagingModule = _messagingModule();
    uint256 hlgFee = messagingModule.getHlgFee(toChain, gasLimit, gasPrice);
    address hToken = _registry().getHToken(_holograph().getHolographChainId());
    require(hlgFee < msg.value, "HOLOGRAPH: not enough value");
    payable(hToken).transfer(hlgFee);
    bytes memory encodedData = abi.encodeWithSelector(
      HolographBridgeInterface.bridgeInRequest.selector,
      nonce,
      _holograph().getHolographChainId(),
      holographableContract,
      hToken,
      address(0),
      hlgFee,
      true,
      bridgeOutPayload
    );
    encodedData = abi.encodePacked(encodedData, gasLimit, gasPrice);
    messagingModule.send{value: msg.value - hlgFee}(
      gasLimit,
      gasPrice,
      toChain,
      msgSender,
      msg.value - hlgFee,
      encodedData
    );
    emit CrossChainMessageSent(keccak256(encodedData));
  }
  function getMessageFee(
    uint32,
    uint256,
    uint256,
    bytes calldata
  ) external view returns (uint256, uint256) {
    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := staticcall(gas(), sload(_messagingModuleSlot), 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
  function getJobDetails(bytes32 jobHash) public view returns (OperatorJob memory) {
    uint256 packed = _operatorJobs[jobHash];
    return
      OperatorJob(
        uint8(packed >> 248),
        uint16(_blockTime),
        _operatorTempStorage[uint32(packed >> 216)],
        uint40(packed >> 176),
        uint64(packed >> 16),
        [
          uint16(packed >> 160),
          uint16(packed >> 144),
          uint16(packed >> 128),
          uint16(packed >> 112),
          uint16(packed >> 96)
        ]
      );
  }
  function getTotalPods() external view returns (uint256 totalPods) {
    return _operatorPods.length;
  }
  function getPodOperatorsLength(uint256 pod) external view returns (uint256) {
    require(_operatorPods.length >= pod, "HOLOGRAPH: pod does not exist");
    return _operatorPods[pod - 1].length;
  }
  function getPodOperators(uint256 pod) external view returns (address[] memory operators) {
    require(_operatorPods.length >= pod, "HOLOGRAPH: pod does not exist");
    operators = _operatorPods[pod - 1];
  }
  function getPodOperators(
    uint256 pod,
    uint256 index,
    uint256 length
  ) external view returns (address[] memory operators) {
    require(_operatorPods.length >= pod, "HOLOGRAPH: pod does not exist");
    pod--;
    uint256 supply = _operatorPods[pod].length;
    if (index + length > supply) {
      length = supply - index;
    }
    operators = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      operators[i] = _operatorPods[pod][index + i];
    }
  }
  function getPodBondAmounts(uint256 pod) external view returns (uint256 base, uint256 current) {
    base = _getBaseBondAmount(pod - 1);
    current = _getCurrentBondAmount(pod - 1);
  }
  function getBondedAmount(address operator) external view returns (uint256 amount) {
    return _bondedAmounts[operator];
  }
  function getBondedPod(address operator) external view returns (uint256 pod) {
    return _bondedOperators[operator];
  }
  function topupUtilityToken(address operator, uint256 amount) external {
    require(_bondedOperators[operator] != 0, "HOLOGRAPH: operator not bonded");
    unchecked {
      _bondedAmounts[operator] += amount;
    }
    require(_utilityToken().transferFrom(msg.sender, address(this), amount), "HOLOGRAPH: token transfer failed");
  }
  function bondUtilityToken(
    address operator,
    uint256 amount,
    uint256 pod
  ) external {
    require(_bondedOperators[operator] == 0 && _bondedAmounts[operator] == 0, "HOLOGRAPH: operator is bonded");
    unchecked {
      uint256 current = _getCurrentBondAmount(pod - 1);
      require(current <= amount, "HOLOGRAPH: bond amount too small");
      if (_operatorPods.length < pod) {
        for (uint256 i = _operatorPods.length; i <= pod; i++) {
          _operatorPods.push([address(0)]);
        }
      }
      require(_operatorPods[pod - 1].length < type(uint16).max, "HOLOGRAPH: too many operators");
      _operatorPods[pod - 1].push(operator);
      _operatorPodIndex[operator] = _operatorPods[pod - 1].length - 1;
      _bondedOperators[operator] = pod;
      _bondedAmounts[operator] = amount;
      require(_utilityToken().transferFrom(msg.sender, address(this), amount), "HOLOGRAPH: token transfer failed");
    }
  }
  function unbondUtilityToken(address operator, address recipient) external {
    require(_bondedOperators[operator] != 0, "HOLOGRAPH: operator not bonded");
    if (msg.sender != operator) {
      require(_isContract(operator), "HOLOGRAPH: operator not contract");
      require(Ownable(operator).isOwner(msg.sender), "HOLOGRAPH: sender not owner");
    }
    uint256 amount = _bondedAmounts[operator];
    _bondedAmounts[operator] = 0;
    _popOperator(_bondedOperators[operator] - 1, _operatorPodIndex[operator]);
    require(_utilityToken().transfer(recipient, amount), "HOLOGRAPH: token transfer failed");
  }
  function getBridge() external view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function setBridge(address bridge) external onlyAdmin {
    assembly {
      sstore(_bridgeSlot, bridge)
    }
  }
  function getHolograph() external view returns (address holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function setHolograph(address holograph) external onlyAdmin {
    assembly {
      sstore(_holographSlot, holograph)
    }
  }
  function getInterfaces() external view returns (address interfaces) {
    assembly {
      interfaces := sload(_interfacesSlot)
    }
  }
  function setInterfaces(address interfaces) external onlyAdmin {
    assembly {
      sstore(_interfacesSlot, interfaces)
    }
  }
  function getMessagingModule() external view returns (address messagingModule) {
    assembly {
      messagingModule := sload(_messagingModuleSlot)
    }
  }
  function setMessagingModule(address messagingModule) external onlyAdmin {
    assembly {
      sstore(_messagingModuleSlot, messagingModule)
    }
  }
  function getRegistry() external view returns (address registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  function setRegistry(address registry) external onlyAdmin {
    assembly {
      sstore(_registrySlot, registry)
    }
  }
  function getUtilityToken() external view returns (address utilityToken) {
    assembly {
      utilityToken := sload(_utilityTokenSlot)
    }
  }
  function setUtilityToken(address utilityToken) external onlyAdmin {
    assembly {
      sstore(_utilityTokenSlot, utilityToken)
    }
  }
  function _bridge() private view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function _holograph() private view returns (HolographInterface holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function _interfaces() private view returns (HolographInterfacesInterface interfaces) {
    assembly {
      interfaces := sload(_interfacesSlot)
    }
  }
  function _messagingModule() private view returns (CrossChainMessageInterface messagingModule) {
    assembly {
      messagingModule := sload(_messagingModuleSlot)
    }
  }
  function _registry() private view returns (HolographRegistryInterface registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  function _utilityToken() private view returns (HolographERC20Interface utilityToken) {
    assembly {
      utilityToken := sload(_utilityTokenSlot)
    }
  }
  function _jobNonce() private returns (uint256 jobNonce) {
    assembly {
      jobNonce := add(sload(_jobNonceSlot), 0x0000000000000000000000000000000000000000000000000000000000000001)
      sstore(_jobNonceSlot, jobNonce)
    }
  }
  function _popOperator(uint256 pod, uint256 operatorIndex) private {
    if (operatorIndex > 0) {
      unchecked {
        address operator = _operatorPods[pod][operatorIndex];
        _bondedOperators[operator] = 0;
        _operatorPodIndex[operator] = 0;
        uint256 lastIndex = _operatorPods[pod].length - 1;
        if (lastIndex != operatorIndex) {
          _operatorPods[pod][operatorIndex] = _operatorPods[pod][lastIndex];
          _operatorPodIndex[_operatorPods[pod][operatorIndex]] = operatorIndex;
        }
        delete _operatorPods[pod][lastIndex];
        _operatorPods[pod].pop();
      }
    }
  }
  function _getBaseBondAmount(uint256 pod) private view returns (uint256) {
    return (_podMultiplier**pod) * _baseBondAmount;
  }
  function _getCurrentBondAmount(uint256 pod) private view returns (uint256) {
    uint256 current = (_podMultiplier**pod) * _baseBondAmount;
    if (pod >= _operatorPods.length) {
      return current;
    }
    uint256 threshold = _operatorThreshold / (2**pod);
    uint256 position = _operatorPods[pod].length;
    if (position > threshold) {
      position -= threshold;
      current += (current / _operatorThresholdDivisor) * (position / _operatorThresholdStep);
    }
    return current;
  }
  function _randomBlockHash(
    uint256 random,
    uint256 podSize,
    uint256 n
  ) private view returns (uint256) {
    unchecked {
      return (random + uint256(blockhash(block.number - n))) % podSize;
    }
  }
  function _isContract(address contractAddress) private view returns (bool) {
    bytes32 codehash;
    assembly {
      codehash := extcodehash(contractAddress)
    }
    return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
  }
  receive() external payable {}
  fallback() external payable {
    revert();
  }
}
contract HolographRegistry is Admin, Initializable, HolographRegistryInterface {
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _utilityTokenSlot = 0xbf76518d46db472b71aa7677a0908b8016f3dee568415ffa24055f9a670f9c37;
  address[] private _holographableContracts;
  mapping(bytes32 => address) private _holographedContractsHashMap;
  mapping(bytes32 => address) private _contractTypeAddresses;
  mapping(bytes32 => bool) private _reservedTypes;
  mapping(address => bool) private _holographedContracts;
  mapping(uint32 => address) private _hTokens;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address holograph, bytes32[] memory reservedTypes) = abi.decode(initPayload, (address, bytes32[]));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_holographSlot, holograph)
    }
    for (uint256 i = 0; i < reservedTypes.length; i++) {
      _reservedTypes[reservedTypes[i]] = true;
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function isHolographedContract(address smartContract) external view returns (bool) {
    return _holographedContracts[smartContract];
  }
  function isHolographedHashDeployed(bytes32 hash) external view returns (bool) {
    return _holographedContractsHashMap[hash] != address(0);
  }
  function referenceContractTypeAddress(address contractAddress) external returns (bytes32) {
    bytes32 contractType;
    assembly {
      contractType := extcodehash(contractAddress)
    }
    require(
      (contractType != 0x0 && contractType != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470),
      "HOLOGRAPH: empty contract"
    );
    require(_contractTypeAddresses[contractType] == address(0), "HOLOGRAPH: contract already set");
    require(!_reservedTypes[contractType], "HOLOGRAPH: reserved address type");
    _contractTypeAddresses[contractType] = contractAddress;
    return contractType;
  }
  function getContractTypeAddress(bytes32 contractType) external view returns (address) {
    return _contractTypeAddresses[contractType];
  }
  function setContractTypeAddress(bytes32 contractType, address contractAddress) external onlyAdmin {
    require(_reservedTypes[contractType], "HOLOGRAPH: not reserved type");
    _contractTypeAddresses[contractType] = contractAddress;
  }
  function getHolograph() external view returns (address holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function setHolograph(address holograph) external onlyAdmin {
    assembly {
      sstore(_holographSlot, holograph)
    }
  }
  function getHolographableContracts(uint256 index, uint256 length) external view returns (address[] memory contracts) {
    uint256 supply = _holographableContracts.length;
    if (index + length > supply) {
      length = supply - index;
    }
    contracts = new address[](length);
    for (uint256 i = 0; i < length; i++) {
      contracts[i] = _holographableContracts[index + i];
    }
  }
  function getHolographableContractsLength() external view returns (uint256) {
    return _holographableContracts.length;
  }
  function getHolographedHashAddress(bytes32 hash) external view returns (address) {
    return _holographedContractsHashMap[hash];
  }
  function setHolographedHashAddress(bytes32 hash, address contractAddress) external {
    address holograph;
    assembly {
      holograph := sload(_holographSlot)
    }
    require(msg.sender == HolographInterface(holograph).getFactory(), "HOLOGRAPH: factory only function");
    _holographedContractsHashMap[hash] = contractAddress;
    _holographedContracts[contractAddress] = true;
    _holographableContracts.push(contractAddress);
  }
  function getHToken(uint32 chainId) external view returns (address) {
    return _hTokens[chainId];
  }
  function setHToken(uint32 chainId, address hToken) external onlyAdmin {
    _hTokens[chainId] = hToken;
  }
  function getReservedContractTypeAddress(bytes32 contractType) external view returns (address contractTypeAddress) {
    if (_reservedTypes[contractType]) {
      contractTypeAddress = _contractTypeAddresses[contractType];
    }
  }
  function setReservedContractTypeAddress(bytes32 hash, bool reserved) external onlyAdmin {
    _reservedTypes[hash] = reserved;
  }
  function setReservedContractTypeAddresses(bytes32[] calldata hashes, bool[] calldata reserved) external onlyAdmin {
    for (uint256 i = 0; i < hashes.length; i++) {
      _reservedTypes[hashes[i]] = reserved[i];
    }
  }
  function getUtilityToken() external view returns (address utilityToken) {
    assembly {
      utilityToken := sload(_utilityTokenSlot)
    }
  }
  function setUtilityToken(address utilityToken) external onlyAdmin {
    assembly {
      sstore(_utilityTokenSlot, utilityToken)
    }
  }
  receive() external payable {
    revert();
  }
  fallback() external payable {
    revert();
  }
}
interface HolographERC721Interface is
  ERC165,
  ERC721,
  ERC721Enumerable,
  ERC721Metadata,
  ERC721TokenReceiver,
  CollectionURI,
  Holographable
{
  function approve(address to, uint256 tokenId) external payable;
  function burn(uint256 tokenId) external;
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external payable;
  function setApprovalForAll(address to, bool approved) external;
  function sourceBurn(uint256 tokenId) external;
  function sourceMint(address to, uint224 tokenId) external;
  function sourceGetChainPrepend() external view returns (uint256);
  function sourceTransfer(address to, uint256 tokenId) external;
  function transfer(address to, uint256 tokenId) external payable;
  function contractURI() external view returns (string memory);
  function getApproved(uint256 tokenId) external view returns (address);
  function isApprovedForAll(address wallet, address operator) external view returns (bool);
  function name() external view returns (string memory);
  function burned(uint256 tokenId) external view returns (bool);
  function decimals() external pure returns (uint256);
  function exists(uint256 tokenId) external view returns (bool);
  function ownerOf(uint256 tokenId) external view returns (address);
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
  function symbol() external view returns (string memory);
  function tokenByIndex(uint256 index) external view returns (uint256);
  function tokenOfOwnerByIndex(address wallet, uint256 index) external view returns (uint256);
  function tokensOfOwner(address wallet) external view returns (uint256[] memory);
  function tokenURI(uint256 tokenId) external view returns (string memory);
  function totalSupply() external view returns (uint256);
}
interface HolographTreasuryInterface {}
contract HolographTreasury is Admin, Initializable, HolographTreasuryInterface {
  bytes32 constant _bridgeSlot = 0xeb87cbb21687feb327e3d58c6c16d552231d12c7a0e8115042a4165fac8a77f9;
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _operatorSlot = 0x7caba557ad34138fa3b7e43fb574e0e6cc10481c3073e0dffbc560db81b5c60f;
  bytes32 constant _registrySlot = 0xce8e75d5c5227ce29a4ee170160bb296e5dea6934b80a9bd723f7ef1e7c850e7;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address bridge, address holograph, address operator, address registry) = abi.decode(
      initPayload,
      (address, address, address, address)
    );
    assembly {
      sstore(_adminSlot, origin())
      sstore(_bridgeSlot, bridge)
      sstore(_holographSlot, holograph)
      sstore(_operatorSlot, operator)
      sstore(_registrySlot, registry)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getBridge() external view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function setBridge(address bridge) external onlyAdmin {
    assembly {
      sstore(_bridgeSlot, bridge)
    }
  }
  function getHolograph() external view returns (address holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function setHolograph(address holograph) external onlyAdmin {
    assembly {
      sstore(_holographSlot, holograph)
    }
  }
  function getOperator() external view returns (address operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  function setOperator(address operator) external onlyAdmin {
    assembly {
      sstore(_operatorSlot, operator)
    }
  }
  function getRegistry() external view returns (address registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  function setRegistry(address registry) external onlyAdmin {
    assembly {
      sstore(_registrySlot, registry)
    }
  }
  function _bridge() private view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function _holograph() private view returns (address holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function _operator() private view returns (address operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  function _registry() private view returns (address registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  receive() external payable {}
  fallback() external payable {
    revert();
  }
}
library ECDSA {
  enum RecoverError {
    NoError,
    InvalidSignature,
    InvalidSignatureLength,
    InvalidSignatureS,
    InvalidSignatureV
  }
  function _throwError(RecoverError error) private pure {
    if (error == RecoverError.NoError) {
      return; 
    } else if (error == RecoverError.InvalidSignature) {
      revert("ECDSA: invalid signature");
    } else if (error == RecoverError.InvalidSignatureLength) {
      revert("ECDSA: invalid signature length");
    } else if (error == RecoverError.InvalidSignatureS) {
      revert("ECDSA: invalid signature 's' value");
    } else if (error == RecoverError.InvalidSignatureV) {
      revert("ECDSA: invalid signature 'v' value");
    }
  }
  function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
    if (signature.length == 65) {
      bytes32 r;
      bytes32 s;
      uint8 v;
      assembly {
        r := mload(add(signature, 0x20))
        s := mload(add(signature, 0x40))
        v := byte(0, mload(add(signature, 0x60)))
      }
      return tryRecover(hash, v, r, s);
    } else if (signature.length == 64) {
      bytes32 r;
      bytes32 vs;
      assembly {
        r := mload(add(signature, 0x20))
        vs := mload(add(signature, 0x40))
      }
      return tryRecover(hash, r, vs);
    } else {
      return (address(0), RecoverError.InvalidSignatureLength);
    }
  }
  function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, signature);
    _throwError(error);
    return recovered;
  }
  function tryRecover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address, RecoverError) {
    bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
    uint8 v = uint8((uint256(vs) >> 255) + 27);
    return tryRecover(hash, v, r, s);
  }
  function recover(
    bytes32 hash,
    bytes32 r,
    bytes32 vs
  ) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, r, vs);
    _throwError(error);
    return recovered;
  }
  function tryRecover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address, RecoverError) {
    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return (address(0), RecoverError.InvalidSignatureS);
    }
    if (v != 27 && v != 28) {
      return (address(0), RecoverError.InvalidSignatureV);
    }
    address signer = ecrecover(hash, v, r, s);
    if (signer == address(0)) {
      return (address(0), RecoverError.InvalidSignature);
    }
    return (signer, RecoverError.NoError);
  }
  function recover(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal pure returns (address) {
    (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
    _throwError(error);
    return recovered;
  }
  function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
  }
  function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
  }
  function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
  }
}
abstract contract EIP712 {
  bytes32 private _CACHED_DOMAIN_SEPARATOR;
  uint256 private _CACHED_CHAIN_ID;
  address private _CACHED_THIS;
  bytes32 private _HASHED_NAME;
  bytes32 private _HASHED_VERSION;
  bytes32 private _TYPE_HASH;
  constructor() {}
  function _eip712_init(string memory name, string memory version) internal {
    bytes32 hashedName = keccak256(bytes(name));
    bytes32 hashedVersion = keccak256(bytes(version));
    bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    _HASHED_NAME = hashedName;
    _HASHED_VERSION = hashedVersion;
    _CACHED_CHAIN_ID = block.chainid;
    _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);
    _CACHED_THIS = address(this);
    _TYPE_HASH = typeHash;
  }
  function _domainSeparatorV4() internal view returns (bytes32) {
    if (address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID) {
      return _CACHED_DOMAIN_SEPARATOR;
    } else {
      return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);
    }
  }
  function _buildDomainSeparator(
    bytes32 typeHash,
    bytes32 nameHash,
    bytes32 versionHash
  ) private view returns (bytes32) {
    return keccak256(abi.encode(typeHash, nameHash, versionHash, block.chainid, address(this)));
  }
  function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
    return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
  }
}
abstract contract ERC1155H is Initializable {
  bytes32 constant _holographerSlot = 0xe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd;
  bytes32 constant _ownerSlot = 0xb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf772777;
  modifier onlyHolographer() {
    require(msg.sender == holographer(), "ERC1155: holographer only");
    _;
  }
  modifier onlyOwner() {
    if (msg.sender == holographer()) {
      require(msgSender() == _getOwner(), "ERC1155: owner only function");
    } else {
      require(msg.sender == _getOwner(), "ERC1155: owner only function");
    }
    _;
  }
  constructor() {}
  function init(bytes memory initPayload) external virtual override returns (bytes4) {
    return _init(initPayload);
  }
  function _init(
    bytes memory 
  ) internal returns (bytes4) {
    require(!_isInitialized(), "ERC1155: already initialized");
    address _holographer = msg.sender;
    assembly {
      sstore(_holographerSlot, _holographer)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function msgSender() internal pure returns (address sender) {
    assembly {
      sender := calldataload(sub(calldatasize(), 0x20))
    }
  }
  function holographer() internal view returns (address _holographer) {
    assembly {
      _holographer := sload(_holographerSlot)
    }
  }
  function supportsInterface(bytes4) external pure returns (bool) {
    return false;
  }
  function owner() external view returns (address) {
    return _getOwner();
  }
  function isOwner() external view returns (bool) {
    if (msg.sender == holographer()) {
      return msgSender() == _getOwner();
    } else {
      return msg.sender == _getOwner();
    }
  }
  function isOwner(address wallet) external view returns (bool) {
    return wallet == _getOwner();
  }
  function _getOwner() internal view returns (address ownerAddress) {
    assembly {
      ownerAddress := sload(_ownerSlot)
    }
  }
  function _setOwner(address ownerAddress) internal {
    assembly {
      sstore(_ownerSlot, ownerAddress)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      switch eq(sload(_holographerSlot), caller())
      case 1 {
        mstore(0x80, 0x0000000000000000000000000000000000000000000000000000000000000001)
        return(0x80, 0x20)
      }
      default {
        revert(0x00, 0x00)
      }
    }
  }
}
abstract contract ERC20H is Initializable {
  bytes32 constant _holographerSlot = 0xe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd;
  bytes32 constant _ownerSlot = 0xb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf772777;
  modifier onlyHolographer() {
    require(msg.sender == holographer(), "ERC20: holographer only");
    _;
  }
  modifier onlyOwner() {
    if (msg.sender == holographer()) {
      require(msgSender() == _getOwner(), "ERC20: owner only function");
    } else {
      require(msg.sender == _getOwner(), "ERC20: owner only function");
    }
    _;
  }
  constructor() {}
  function init(bytes memory initPayload) external virtual override returns (bytes4) {
    return _init(initPayload);
  }
  function _init(
    bytes memory 
  ) internal returns (bytes4) {
    require(!_isInitialized(), "ERC20: already initialized");
    address _holographer = msg.sender;
    assembly {
      sstore(_holographerSlot, _holographer)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function msgSender() internal pure returns (address sender) {
    assembly {
      sender := calldataload(sub(calldatasize(), 0x20))
    }
  }
  function holographer() internal view returns (address _holographer) {
    assembly {
      _holographer := sload(_holographerSlot)
    }
  }
  function supportsInterface(bytes4) external pure returns (bool) {
    return false;
  }
  function owner() external view returns (address) {
    return _getOwner();
  }
  function isOwner() external view returns (bool) {
    if (msg.sender == holographer()) {
      return msgSender() == _getOwner();
    } else {
      return msg.sender == _getOwner();
    }
  }
  function isOwner(address wallet) external view returns (bool) {
    return wallet == _getOwner();
  }
  function _getOwner() internal view returns (address ownerAddress) {
    assembly {
      ownerAddress := sload(_ownerSlot)
    }
  }
  function _setOwner(address ownerAddress) internal {
    assembly {
      sstore(_ownerSlot, ownerAddress)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      switch eq(sload(_holographerSlot), caller())
      case 1 {
        mstore(0x80, 0x0000000000000000000000000000000000000000000000000000000000000001)
        return(0x80, 0x20)
      }
      default {
        revert(0x00, 0x00)
      }
    }
  }
}
abstract contract ERC721H is Initializable {
  bytes32 constant _holographerSlot = 0xe9fcff60011c1a99f7b7244d1f2d9da93d79ea8ef3654ce590d775575255b2bd;
  bytes32 constant _ownerSlot = 0xb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf772777;
  modifier onlyHolographer() {
    require(msg.sender == holographer(), "ERC721: holographer only");
    _;
  }
  modifier onlyOwner() {
    if (msg.sender == holographer()) {
      require(msgSender() == _getOwner(), "ERC721: owner only function");
    } else {
      require(msg.sender == _getOwner(), "ERC721: owner only function");
    }
    _;
  }
  constructor() {}
  function init(bytes memory initPayload) external virtual override returns (bytes4) {
    return _init(initPayload);
  }
  function _init(
    bytes memory 
  ) internal returns (bytes4) {
    require(!_isInitialized(), "ERC721: already initialized");
    address _holographer = msg.sender;
    assembly {
      sstore(_holographerSlot, _holographer)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function msgSender() internal pure returns (address sender) {
    assembly {
      sender := calldataload(sub(calldatasize(), 0x20))
    }
  }
  function holographer() internal view returns (address _holographer) {
    assembly {
      _holographer := sload(_holographerSlot)
    }
  }
  function supportsInterface(bytes4) external pure returns (bool) {
    return false;
  }
  function owner() external view returns (address) {
    return _getOwner();
  }
  function isOwner() external view returns (bool) {
    if (msg.sender == holographer()) {
      return msgSender() == _getOwner();
    } else {
      return msg.sender == _getOwner();
    }
  }
  function isOwner(address wallet) external view returns (bool) {
    return wallet == _getOwner();
  }
  function _getOwner() internal view returns (address ownerAddress) {
    assembly {
      ownerAddress := sload(_ownerSlot)
    }
  }
  function _setOwner(address ownerAddress) internal {
    assembly {
      sstore(_ownerSlot, ownerAddress)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      switch eq(sload(_holographerSlot), caller())
      case 1 {
        mstore(0x80, 0x0000000000000000000000000000000000000000000000000000000000000001)
        return(0x80, 0x20)
      }
      default {
        revert(0x00, 0x00)
      }
    }
  }
}
interface HolographedERC1155 {
  function bridgeIn(
    uint32 _chainId,
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function bridgeOut(
    uint32 _chainId,
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount
  ) external returns (bytes memory _data);
  function afterApprove(
    address _owner,
    address _to,
    uint256 _tokenId,
    uint256 _amount
  ) external returns (bool success);
  function beforeApprove(
    address _owner,
    address _to,
    uint256 _tokenId,
    uint256 _amount
  ) external returns (bool success);
  function afterApprovalAll(address _to, bool _approved) external returns (bool success);
  function beforeApprovalAll(address _to, bool _approved) external returns (bool success);
  function afterBurn(
    address _owner,
    uint256 _tokenId,
    uint256 _amount
  ) external returns (bool success);
  function beforeBurn(
    address _owner,
    uint256 _tokenId,
    uint256 _amount
  ) external returns (bool success);
  function afterMint(
    address _owner,
    uint256 _tokenId,
    uint256 _amount
  ) external returns (bool success);
  function beforeMint(
    address _owner,
    uint256 _tokenId,
    uint256 _amount
  ) external returns (bool success);
  function afterSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function beforeSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function afterTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function beforeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function afterOnERC1155Received(
    address _operator,
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function beforeOnERC1155Received(
    address _operator,
    address _from,
    address _to,
    uint256 _tokenId,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
}
abstract contract StrictERC1155H is ERC1155H, HolographedERC1155 {
  bool private _success;
  function bridgeIn(
    uint32, 
    address, 
    address, 
    uint256, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool) {
    _success = true;
    return true;
  }
  function bridgeOut(
    uint32, 
    address, 
    address, 
    uint256, 
    uint256 
  ) external virtual onlyHolographer returns (bytes memory _data) {
    _success = true;
    _data = abi.encode(holographer());
  }
  function afterApprove(
    address, 
    address, 
    uint256, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeApprove(
    address, 
    address, 
    uint256, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterApprovalAll(
    address, 
    bool 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeApprovalAll(
    address, 
    bool 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterBurn(
    address, 
    uint256, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeBurn(
    address, 
    uint256, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterMint(
    address, 
    uint256, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeMint(
    address, 
    uint256, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterSafeTransfer(
    address, 
    address, 
    uint256, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeSafeTransfer(
    address, 
    address, 
    uint256, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterTransfer(
    address, 
    address, 
    uint256, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeTransfer(
    address, 
    address, 
    uint256, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterOnERC1155Received(
    address, 
    address, 
    address, 
    uint256, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeOnERC1155Received(
    address, 
    address, 
    address, 
    uint256, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
}
interface HolographedERC20 {
  function bridgeIn(
    uint32 _chainId,
    address _from,
    address _to,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function bridgeOut(
    uint32 _chainId,
    address _from,
    address _to,
    uint256 _amount
  ) external returns (bytes memory _data);
  function afterApprove(
    address _owner,
    address _to,
    uint256 _amount
  ) external returns (bool success);
  function beforeApprove(
    address _owner,
    address _to,
    uint256 _amount
  ) external returns (bool success);
  function afterOnERC20Received(
    address _token,
    address _from,
    address _to,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function beforeOnERC20Received(
    address _token,
    address _from,
    address _to,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function afterBurn(address _owner, uint256 _amount) external returns (bool success);
  function beforeBurn(address _owner, uint256 _amount) external returns (bool success);
  function afterMint(address _owner, uint256 _amount) external returns (bool success);
  function beforeMint(address _owner, uint256 _amount) external returns (bool success);
  function afterSafeTransfer(
    address _from,
    address _to,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function beforeSafeTransfer(
    address _from,
    address _to,
    uint256 _amount,
    bytes calldata _data
  ) external returns (bool success);
  function afterTransfer(
    address _from,
    address _to,
    uint256 _amount
  ) external returns (bool success);
  function beforeTransfer(
    address _from,
    address _to,
    uint256 _amount
  ) external returns (bool success);
}
abstract contract StrictERC20H is ERC20H, HolographedERC20 {
  bool private _success;
  function bridgeIn(
    uint32, 
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool) {
    _success = true;
    return true;
  }
  function bridgeOut(
    uint32, 
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bytes memory _data) {
    _data = abi.encodePacked(holographer());
    _success = true;
  }
  function afterApprove(
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeApprove(
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterOnERC20Received(
    address, 
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeOnERC20Received(
    address, 
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterBurn(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeBurn(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterMint(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeMint(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterSafeTransfer(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeSafeTransfer(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterTransfer(
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeTransfer(
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
}
interface HolographedERC721 {
  function bridgeIn(
    uint32 _chainId,
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bool success);
  function bridgeOut(
    uint32 _chainId,
    address _from,
    address _to,
    uint256 _tokenId
  ) external returns (bytes memory _data);
  function afterApprove(
    address _owner,
    address _to,
    uint256 _tokenId
  ) external returns (bool success);
  function beforeApprove(
    address _owner,
    address _to,
    uint256 _tokenId
  ) external returns (bool success);
  function afterApprovalAll(address _to, bool _approved) external returns (bool success);
  function beforeApprovalAll(address _to, bool _approved) external returns (bool success);
  function afterBurn(address _owner, uint256 _tokenId) external returns (bool success);
  function beforeBurn(address _owner, uint256 _tokenId) external returns (bool success);
  function afterMint(address _owner, uint256 _tokenId) external returns (bool success);
  function beforeMint(address _owner, uint256 _tokenId) external returns (bool success);
  function afterSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bool success);
  function beforeSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bool success);
  function afterTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bool success);
  function beforeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bool success);
  function afterOnERC721Received(
    address _operator,
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bool success);
  function beforeOnERC721Received(
    address _operator,
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bool success);
}
abstract contract StrictERC721H is ERC721H, HolographedERC721 {
  bool private _success;
  function bridgeIn(
    uint32, 
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool) {
    _success = true;
    return true;
  }
  function bridgeOut(
    uint32, 
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bytes memory _data) {
    _success = true;
    _data = abi.encode(holographer());
  }
  function afterApprove(
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeApprove(
    address, 
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterApprovalAll(
    address, 
    bool 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeApprovalAll(
    address, 
    bool 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterBurn(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeBurn(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterMint(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeMint(
    address, 
    uint256 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterSafeTransfer(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeSafeTransfer(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterTransfer(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeTransfer(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function afterOnERC721Received(
    address, 
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
  function beforeOnERC721Received(
    address, 
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external virtual onlyHolographer returns (bool success) {
    _success = true;
    return _success;
  }
}
abstract contract NonReentrant {
  bytes32 constant _reentrantSlot = 0x04b524dd539523930d3901481aa9455d7752b49add99e1647adb8b09a3137279;
  modifier nonReentrant() {
    require(getStatus() != 2, "HOLOGRAPH: reentrant call");
    setStatus(2);
    _;
    setStatus(1);
  }
  constructor() {}
  function getStatus() internal view returns (uint256 status) {
    assembly {
      status := sload(_reentrantSlot)
    }
  }
  function setStatus(uint256 status) internal {
    assembly {
      sstore(_reentrantSlot, status)
    }
  }
}
abstract contract Owner {
  bytes32 constant _ownerSlot = 0xb56711ba6bd3ded7639fc335ee7524fe668a79d7558c85992e3f8494cf772777;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  modifier onlyOwner() virtual {
    require(msg.sender == getOwner(), "HOLOGRAPH: owner only function");
    _;
  }
  function owner() public view virtual returns (address) {
    return getOwner();
  }
  constructor() {}
  function getOwner() public view returns (address ownerAddress) {
    assembly {
      ownerAddress := sload(_ownerSlot)
    }
  }
  function setOwner(address ownerAddress) public onlyOwner {
    address previousOwner = getOwner();
    assembly {
      sstore(_ownerSlot, ownerAddress)
    }
    emit OwnershipTransferred(previousOwner, ownerAddress);
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "HOLOGRAPH: zero address");
    assembly {
      sstore(_ownerSlot, newOwner)
    }
  }
  function ownerCall(address target, bytes calldata data) external payable onlyOwner {
    assembly {
      calldatacopy(0, data.offset, data.length)
      let result := call(gas(), target, callvalue(), 0, data.length, 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
enum HolographERC20Event {
  UNDEFINED, 
  bridgeIn, 
  bridgeOut, 
  afterApprove, 
  beforeApprove, 
  afterOnERC20Received, 
  beforeOnERC20Received, 
  afterBurn, 
  beforeBurn, 
  afterMint, 
  beforeMint, 
  afterSafeTransfer, 
  beforeSafeTransfer, 
  afterTransfer, 
  beforeTransfer 
}
contract HolographERC20 is Admin, Owner, Initializable, NonReentrant, EIP712, HolographERC20Interface {
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _sourceContractSlot = 0x27d542086d1e831d40b749e7f5509a626c3047a36d160781c40d5acc83e5b074;
  uint256 private _eventConfig;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  mapping(address => uint256) private _nonces;
  modifier onlyBridge() {
    require(msg.sender == _holograph().getBridge(), "ERC20: bridge only call");
    _;
  }
  modifier onlySource() {
    address sourceContract;
    assembly {
      sourceContract := sload(_sourceContractSlot)
    }
    require(msg.sender == sourceContract, "ERC20: source only call");
    _;
  }
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "ERC20: already initialized");
    InitializableInterface sourceContract;
    assembly {
      sstore(_reentrantSlot, 0x0000000000000000000000000000000000000000000000000000000000000001)
      sstore(_ownerSlot, caller())
      sourceContract := sload(_sourceContractSlot)
    }
    (
      string memory contractName,
      string memory contractSymbol,
      uint8 contractDecimals,
      uint256 eventConfig,
      string memory domainSeperator,
      string memory domainVersion,
      bool skipInit,
      bytes memory initCode
    ) = abi.decode(initPayload, (string, string, uint8, uint256, string, string, bool, bytes));
    _name = contractName;
    _symbol = contractSymbol;
    _decimals = contractDecimals;
    _eventConfig = eventConfig;
    if (!skipInit) {
      require(sourceContract.init(initCode) == InitializableInterface.init.selector, "ERC20: could not init source");
    }
    _setInitialized();
    _eip712_init(domainSeperator, domainVersion);
    return InitializableInterface.init.selector;
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      calldatacopy(0, 0, calldatasize())
      mstore(calldatasize(), caller())
      let result := call(gas(), sload(_sourceContractSlot), callvalue(), 0, add(calldatasize(), 32), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
  function decimals() public view returns (uint8) {
    return _decimals;
  }
  function supportsInterface(bytes4 interfaceId) external view returns (bool) {
    HolographInterfacesInterface interfaces = HolographInterfacesInterface(_interfaces());
    ERC165 erc165Contract;
    assembly {
      erc165Contract := sload(_sourceContractSlot)
    }
    if (
      interfaces.supportsInterface(InterfaceType.ERC20, interfaceId) || erc165Contract.supportsInterface(interfaceId) 
    ) {
      return true;
    } else {
      return false;
    }
  }
  function allowance(address account, address spender) public view returns (uint256) {
    return _allowances[account][spender];
  }
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }
  function DOMAIN_SEPARATOR() public view returns (bytes32) {
    return _domainSeparatorV4();
  }
  function name() public view returns (string memory) {
    return _name;
  }
  function nonces(address account) public view returns (uint256) {
    return _nonces[account];
  }
  function symbol() public view returns (string memory) {
    return _symbol;
  }
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  function approve(address spender, uint256 amount) public returns (bool) {
    if (_isEventRegistered(HolographERC20Event.beforeApprove)) {
      require(SourceERC20().beforeApprove(msg.sender, spender, amount));
    }
    _approve(msg.sender, spender, amount);
    if (_isEventRegistered(HolographERC20Event.afterApprove)) {
      require(SourceERC20().afterApprove(msg.sender, spender, amount));
    }
    return true;
  }
  function burn(uint256 amount) public {
    if (_isEventRegistered(HolographERC20Event.beforeBurn)) {
      require(SourceERC20().beforeBurn(msg.sender, amount));
    }
    _burn(msg.sender, amount);
    if (_isEventRegistered(HolographERC20Event.afterBurn)) {
      require(SourceERC20().afterBurn(msg.sender, amount));
    }
  }
  function burnFrom(address account, uint256 amount) public returns (bool) {
    uint256 currentAllowance = _allowances[account][msg.sender];
    require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
    unchecked {
      _allowances[account][msg.sender] = currentAllowance - amount;
    }
    if (_isEventRegistered(HolographERC20Event.beforeBurn)) {
      require(SourceERC20().beforeBurn(account, amount));
    }
    _burn(account, amount);
    if (_isEventRegistered(HolographERC20Event.afterBurn)) {
      require(SourceERC20().afterBurn(account, amount));
    }
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased below zero");
    uint256 newAllowance;
    unchecked {
      newAllowance = currentAllowance - subtractedValue;
    }
    if (_isEventRegistered(HolographERC20Event.beforeApprove)) {
      require(SourceERC20().beforeApprove(msg.sender, spender, newAllowance));
    }
    _approve(msg.sender, spender, newAllowance);
    if (_isEventRegistered(HolographERC20Event.afterApprove)) {
      require(SourceERC20().afterApprove(msg.sender, spender, newAllowance));
    }
    return true;
  }
  function bridgeIn(uint32 fromChain, bytes calldata payload) external onlyBridge returns (bytes4) {
    (address from, address to, uint256 amount, bytes memory data) = abi.decode(
      payload,
      (address, address, uint256, bytes)
    );
    _mint(to, amount);
    if (_isEventRegistered(HolographERC20Event.bridgeIn)) {
      require(SourceERC20().bridgeIn(fromChain, from, to, amount, data), "HOLOGRAPH: bridge in failed");
    }
    return Holographable.bridgeIn.selector;
  }
  function bridgeOut(
    uint32 toChain,
    address sender,
    bytes calldata payload
  ) external onlyBridge returns (bytes4 selector, bytes memory data) {
    (address from, address to, uint256 amount) = abi.decode(payload, (address, address, uint256));
    if (sender != from) {
      uint256 currentAllowance = _allowances[from][sender];
      require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
      unchecked {
        _allowances[from][sender] = currentAllowance - amount;
      }
    }
    if (_isEventRegistered(HolographERC20Event.bridgeOut)) {
      data = SourceERC20().bridgeOut(toChain, from, to, amount);
    }
    _burn(from, amount);
    return (Holographable.bridgeOut.selector, abi.encode(from, to, amount, data));
  }
  function holographBridgeMint(address to, uint256 amount) external onlyBridge returns (bytes4) {
    _mint(to, amount);
    return HolographERC20Interface.holographBridgeMint.selector;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    uint256 newAllowance;
    unchecked {
      newAllowance = currentAllowance + addedValue;
    }
    unchecked {
      require(newAllowance >= currentAllowance, "ERC20: increased above max value");
    }
    if (_isEventRegistered(HolographERC20Event.beforeApprove)) {
      require(SourceERC20().beforeApprove(msg.sender, spender, newAllowance));
    }
    _approve(msg.sender, spender, newAllowance);
    if (_isEventRegistered(HolographERC20Event.afterApprove)) {
      require(SourceERC20().afterApprove(msg.sender, spender, newAllowance));
    }
    return true;
  }
  function onERC20Received(
    address account,
    address sender,
    uint256 amount,
    bytes calldata data
  ) public returns (bytes4) {
    require(_isContract(account), "ERC20: operator not contract");
    if (_isEventRegistered(HolographERC20Event.beforeOnERC20Received)) {
      require(SourceERC20().beforeOnERC20Received(account, sender, address(this), amount, data));
    }
    try ERC20(account).balanceOf(address(this)) returns (uint256 balance) {
      require(balance >= amount, "ERC20: balance check failed");
    } catch {
      revert("ERC20: failed getting balance");
    }
    if (_isEventRegistered(HolographERC20Event.afterOnERC20Received)) {
      require(SourceERC20().afterOnERC20Received(account, sender, address(this), amount, data));
    }
    return ERC20Receiver.onERC20Received.selector;
  }
  function permit(
    address account,
    address spender,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    require(block.timestamp <= deadline, "ERC20: expired deadline");
    bytes32 structHash = keccak256(
      abi.encode(
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9,
        account,
        spender,
        amount,
        _useNonce(account),
        deadline
      )
    );
    bytes32 hash = _hashTypedDataV4(structHash);
    address signer = ECDSA.recover(hash, v, r, s);
    require(signer == account, "ERC20: invalid signature");
    if (_isEventRegistered(HolographERC20Event.beforeApprove)) {
      require(SourceERC20().beforeApprove(account, spender, amount));
    }
    _approve(account, spender, amount);
    if (_isEventRegistered(HolographERC20Event.afterApprove)) {
      require(SourceERC20().afterApprove(account, spender, amount));
    }
  }
  function safeTransfer(address recipient, uint256 amount) public returns (bool) {
    return safeTransfer(recipient, amount, "");
  }
  function safeTransfer(
    address recipient,
    uint256 amount,
    bytes memory data
  ) public returns (bool) {
    if (_isEventRegistered(HolographERC20Event.beforeSafeTransfer)) {
      require(SourceERC20().beforeSafeTransfer(msg.sender, recipient, amount, data));
    }
    _transfer(msg.sender, recipient, amount);
    require(_checkOnERC20Received(msg.sender, recipient, amount, data), "ERC20: non ERC20Receiver");
    if (_isEventRegistered(HolographERC20Event.afterSafeTransfer)) {
      require(SourceERC20().afterSafeTransfer(msg.sender, recipient, amount, data));
    }
    return true;
  }
  function safeTransferFrom(
    address account,
    address recipient,
    uint256 amount
  ) public returns (bool) {
    return safeTransferFrom(account, recipient, amount, "");
  }
  function safeTransferFrom(
    address account,
    address recipient,
    uint256 amount,
    bytes memory data
  ) public returns (bool) {
    if (account != msg.sender) {
      if (msg.sender != _holograph().getBridge() && msg.sender != _holograph().getOperator()) {
        uint256 currentAllowance = _allowances[account][msg.sender];
        require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
        unchecked {
          _allowances[account][msg.sender] = currentAllowance - amount;
        }
      }
    }
    if (_isEventRegistered(HolographERC20Event.beforeSafeTransfer)) {
      require(SourceERC20().beforeSafeTransfer(account, recipient, amount, data));
    }
    _transfer(account, recipient, amount);
    require(_checkOnERC20Received(account, recipient, amount, data), "ERC20: non ERC20Receiver");
    if (_isEventRegistered(HolographERC20Event.afterSafeTransfer)) {
      require(SourceERC20().afterSafeTransfer(account, recipient, amount, data));
    }
    return true;
  }
  function sourceBurn(address from, uint256 amount) external onlySource {
    _burn(from, amount);
  }
  function sourceMint(address to, uint256 amount) external onlySource {
    _mint(to, amount);
  }
  function sourceMintBatch(address[] calldata wallets, uint256[] calldata amounts) external onlySource {
    for (uint256 i = 0; i < wallets.length; i++) {
      _mint(wallets[i], amounts[i]);
    }
  }
  function sourceTransfer(
    address from,
    address to,
    uint256 amount
  ) external onlySource {
    _transfer(from, to, amount);
  }
  function transfer(address recipient, uint256 amount) public returns (bool) {
    if (_isEventRegistered(HolographERC20Event.beforeTransfer)) {
      require(SourceERC20().beforeTransfer(msg.sender, recipient, amount));
    }
    _transfer(msg.sender, recipient, amount);
    if (_isEventRegistered(HolographERC20Event.afterTransfer)) {
      require(SourceERC20().afterTransfer(msg.sender, recipient, amount));
    }
    return true;
  }
  function transferFrom(
    address account,
    address recipient,
    uint256 amount
  ) public returns (bool) {
    if (account != msg.sender) {
      if (msg.sender != _holograph().getBridge() && msg.sender != _holograph().getOperator()) {
        uint256 currentAllowance = _allowances[account][msg.sender];
        require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
        unchecked {
          _allowances[account][msg.sender] = currentAllowance - amount;
        }
      }
    }
    if (_isEventRegistered(HolographERC20Event.beforeTransfer)) {
      require(SourceERC20().beforeTransfer(account, recipient, amount));
    }
    _transfer(account, recipient, amount);
    if (_isEventRegistered(HolographERC20Event.afterTransfer)) {
      require(SourceERC20().afterTransfer(account, recipient, amount));
    }
    return true;
  }
  function _approve(
    address account,
    address spender,
    uint256 amount
  ) private {
    require(account != address(0), "ERC20: account is zero address");
    require(spender != address(0), "ERC20: spender is zero address");
    _allowances[account][spender] = amount;
    emit Approval(account, spender, amount);
  }
  function _burn(address account, uint256 amount) private {
    require(account != address(0), "ERC20: account is zero address");
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;
    emit Transfer(account, address(0), amount);
  }
  function _checkOnERC20Received(
    address account,
    address recipient,
    uint256 amount,
    bytes memory data
  ) private nonReentrant returns (bool) {
    if (_isContract(recipient)) {
      try ERC165(recipient).supportsInterface(ERC165.supportsInterface.selector) returns (bool erc165support) {
        require(erc165support, "ERC20: no ERC165 support");
        if (ERC165(recipient).supportsInterface(0x534f5876)) {
          try ERC20Receiver(recipient).onERC20Received(address(this), account, amount, data) returns (bytes4 retval) {
            return retval == ERC20Receiver.onERC20Received.selector;
          } catch (bytes memory reason) {
            if (reason.length == 0) {
              revert("ERC20: non ERC20Receiver");
            } else {
              assembly {
                revert(add(32, reason), mload(reason))
              }
            }
          }
        } else {
          revert("ERC20: eip-4524 not supported");
        }
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC20: no ERC165 support");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }
  function _mint(address to, uint256 amount) private {
    require(to != address(0), "ERC20: minting to burn address");
    _totalSupply += amount;
    _balances[to] += amount;
    emit Transfer(address(0), to, amount);
  }
  function _transfer(
    address account,
    address recipient,
    uint256 amount
  ) private {
    require(account != address(0), "ERC20: account is zero address");
    require(recipient != address(0), "ERC20: recipient is zero address");
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _balances[recipient] += amount;
    emit Transfer(account, recipient, amount);
  }
  function _useNonce(address account) private returns (uint256 current) {
    current = _nonces[account];
    _nonces[account]++;
  }
  function _isContract(address contractAddress) private view returns (bool) {
    bytes32 codehash;
    assembly {
      codehash := extcodehash(contractAddress)
    }
    return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
  }
  function SourceERC20() private view returns (HolographedERC20 sourceContract) {
    assembly {
      sourceContract := sload(_sourceContractSlot)
    }
  }
  function _interfaces() private view returns (address) {
    return _holograph().getInterfaces();
  }
  function owner() public view override returns (address) {
    Ownable ownableContract;
    assembly {
      ownableContract := sload(_sourceContractSlot)
    }
    return ownableContract.owner();
  }
  function _holograph() private view returns (HolographInterface holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function _isEventRegistered(HolographERC20Event _eventName) private view returns (bool) {
    return ((_eventConfig >> uint256(_eventName)) & uint256(1) == 1 ? true : false);
  }
}
enum HolographERC721Event {
  UNDEFINED, 
  bridgeIn, 
  bridgeOut, 
  afterApprove, 
  beforeApprove, 
  afterApprovalAll, 
  beforeApprovalAll, 
  afterBurn, 
  beforeBurn, 
  afterMint, 
  beforeMint, 
  afterSafeTransfer, 
  beforeSafeTransfer, 
  afterTransfer, 
  beforeTransfer, 
  beforeOnERC721Received, 
  afterOnERC721Received 
}
contract HolographERC721 is Admin, Owner, HolographERC721Interface, Initializable {
  bytes32 constant _holographSlot = 0xb4107f746e9496e8452accc7de63d1c5e14c19f510932daa04077cd49e8bd77a;
  bytes32 constant _sourceContractSlot = 0x27d542086d1e831d40b749e7f5509a626c3047a36d160781c40d5acc83e5b074;
  uint256 private _eventConfig;
  string private _name;
  string private _symbol;
  uint16 private _bps;
  uint256[] private _allTokens;
  mapping(uint256 => uint256) private _ownedTokensIndex;
  mapping(uint256 => address) private _tokenOwner;
  mapping(uint256 => address) private _tokenApprovals;
  mapping(address => uint256) private _ownedTokensCount;
  mapping(address => uint256[]) private _ownedTokens;
  mapping(address => mapping(address => bool)) private _operatorApprovals;
  mapping(uint256 => uint256) private _allTokensIndex;
  mapping(uint256 => bool) private _burnedTokens;
  modifier onlyBridge() {
    require(msg.sender == _holograph().getBridge(), "ERC721: bridge only call");
    _;
  }
  modifier onlySource() {
    address sourceContract;
    assembly {
      sourceContract := sload(_sourceContractSlot)
    }
    require(msg.sender == sourceContract, "ERC721: source only call");
    _;
  }
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "ERC721: already initialized");
    InitializableInterface sourceContract;
    assembly {
      sstore(_ownerSlot, caller())
      sourceContract := sload(_sourceContractSlot)
    }
    (
      string memory contractName,
      string memory contractSymbol,
      uint16 contractBps,
      uint256 eventConfig,
      bool skipInit,
      bytes memory initCode
    ) = abi.decode(initPayload, (string, string, uint16, uint256, bool, bytes));
    _name = contractName;
    _symbol = contractSymbol;
    _bps = contractBps;
    _eventConfig = eventConfig;
    if (!skipInit) {
      require(sourceContract.init(initCode) == InitializableInterface.init.selector, "ERC721: could not init source");
      (bool success, bytes memory returnData) = _royalties().delegatecall(
        abi.encodeWithSignature("initPA1D(bytes)", abi.encode(address(this), uint256(contractBps)))
      );
      bytes4 selector = abi.decode(returnData, (bytes4));
      require(success && selector == InitializableInterface.init.selector, "ERC721: coud not init PA1D");
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function contractURI() external view returns (string memory) {
    return HolographInterfacesInterface(_interfaces()).contractURI(_name, "", "", _bps, address(this));
  }
  function name() external view returns (string memory) {
    return _name;
  }
  function supportsInterface(bytes4 interfaceId) external view returns (bool) {
    HolographInterfacesInterface interfaces = HolographInterfacesInterface(_interfaces());
    ERC165 erc165Contract;
    assembly {
      erc165Contract := sload(_sourceContractSlot)
    }
    if (
      interfaces.supportsInterface(InterfaceType.ERC721, interfaceId) || 
      interfaces.supportsInterface(InterfaceType.PA1D, interfaceId) || 
      erc165Contract.supportsInterface(interfaceId) 
    ) {
      return true;
    } else {
      return false;
    }
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function tokenURI(uint256 tokenId) external view returns (string memory) {
    require(_exists(tokenId), "ERC721: token does not exist");
    ERC721Metadata sourceContract;
    assembly {
      sourceContract := sload(_sourceContractSlot)
    }
    return sourceContract.tokenURI(tokenId);
  }
  function tokensOfOwner(address wallet) external view returns (uint256[] memory) {
    return _ownedTokens[wallet];
  }
  function tokensOfOwner(
    address wallet,
    uint256 index,
    uint256 length
  ) external view returns (uint256[] memory tokenIds) {
    uint256 supply = _ownedTokensCount[wallet];
    if (index + length > supply) {
      length = supply - index;
    }
    tokenIds = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      tokenIds[i] = _ownedTokens[wallet][index + i];
    }
  }
  function approve(address to, uint256 tokenId) external payable {
    address tokenOwner = _tokenOwner[tokenId];
    require(to != tokenOwner, "ERC721: cannot approve self");
    require(_isApproved(msg.sender, tokenId), "ERC721: not approved sender");
    if (_isEventRegistered(HolographERC721Event.beforeApprove)) {
      require(SourceERC721().beforeApprove(tokenOwner, to, tokenId));
    }
    _tokenApprovals[tokenId] = to;
    emit Approval(tokenOwner, to, tokenId);
    if (_isEventRegistered(HolographERC721Event.afterApprove)) {
      require(SourceERC721().afterApprove(tokenOwner, to, tokenId));
    }
  }
  function burn(uint256 tokenId) external {
    require(_isApproved(msg.sender, tokenId), "ERC721: not approved sender");
    address wallet = _tokenOwner[tokenId];
    if (_isEventRegistered(HolographERC721Event.beforeBurn)) {
      require(SourceERC721().beforeBurn(wallet, tokenId));
    }
    _burn(wallet, tokenId);
    if (_isEventRegistered(HolographERC721Event.afterBurn)) {
      require(SourceERC721().afterBurn(wallet, tokenId));
    }
  }
  function bridgeIn(uint32 fromChain, bytes calldata payload) external onlyBridge returns (bytes4) {
    (address from, address to, uint256 tokenId, bytes memory data) = abi.decode(
      payload,
      (address, address, uint256, bytes)
    );
    require(!_exists(tokenId), "ERC721: token already exists");
    delete _burnedTokens[tokenId];
    _mint(to, tokenId);
    if (_isEventRegistered(HolographERC721Event.bridgeIn)) {
      require(SourceERC721().bridgeIn(fromChain, from, to, tokenId, data), "HOLOGRAPH: bridge in failed");
    }
    return Holographable.bridgeIn.selector;
  }
  function bridgeOut(
    uint32 toChain,
    address sender,
    bytes calldata payload
  ) external onlyBridge returns (bytes4 selector, bytes memory data) {
    (address from, address to, uint256 tokenId) = abi.decode(payload, (address, address, uint256));
    require(to != address(0), "ERC721: zero address");
    require(_isApproved(sender, tokenId), "ERC721: sender not approved");
    require(from == _tokenOwner[tokenId], "ERC721: from is not owner");
    if (_isEventRegistered(HolographERC721Event.bridgeOut)) {
      data = SourceERC721().bridgeOut(toChain, from, to, tokenId);
    }
    _burn(from, tokenId);
    return (Holographable.bridgeOut.selector, abi.encode(from, to, tokenId, data));
  }
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external payable {
    safeTransferFrom(from, to, tokenId, "");
  }
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) public payable {
    require(_isApproved(msg.sender, tokenId), "ERC721: not approved sender");
    if (_isEventRegistered(HolographERC721Event.beforeSafeTransfer)) {
      require(SourceERC721().beforeSafeTransfer(from, to, tokenId, data));
    }
    _transferFrom(from, to, tokenId);
    if (_isContract(to)) {
      require(
        (ERC165(to).supportsInterface(ERC165.supportsInterface.selector) &&
          ERC165(to).supportsInterface(ERC721TokenReceiver.onERC721Received.selector) &&
          ERC721TokenReceiver(to).onERC721Received(address(this), from, tokenId, data) ==
          ERC721TokenReceiver.onERC721Received.selector),
        "ERC721: onERC721Received fail"
      );
    }
    if (_isEventRegistered(HolographERC721Event.afterSafeTransfer)) {
      require(SourceERC721().afterSafeTransfer(from, to, tokenId, data));
    }
  }
  function setApprovalForAll(address to, bool approved) external {
    require(to != msg.sender, "ERC721: cannot approve self");
    if (_isEventRegistered(HolographERC721Event.beforeApprovalAll)) {
      require(SourceERC721().beforeApprovalAll(to, approved));
    }
    _operatorApprovals[msg.sender][to] = approved;
    emit ApprovalForAll(msg.sender, to, approved);
    if (_isEventRegistered(HolographERC721Event.afterApprovalAll)) {
      require(SourceERC721().afterApprovalAll(to, approved));
    }
  }
  function sourceBurn(uint256 tokenId) external onlySource {
    address wallet = _tokenOwner[tokenId];
    _burn(wallet, tokenId);
  }
  function sourceMint(address to, uint224 tokenId) external onlySource {
    uint256 token = uint256(bytes32(abi.encodePacked(_chain(), tokenId)));
    require(!_burnedTokens[token], "ERC721: can't mint burned token");
    _mint(to, token);
  }
  function sourceGetChainPrepend() external view onlySource returns (uint256) {
    return uint256(bytes32(abi.encodePacked(_chain(), uint224(0))));
  }
  function sourceTransfer(address to, uint256 tokenId) external onlySource {
    address wallet = _tokenOwner[tokenId];
    _transferFrom(wallet, to, tokenId);
  }
  function transfer(address to, uint256 tokenId) external payable {
    transferFrom(msg.sender, to, tokenId, "");
  }
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) public payable {
    transferFrom(from, to, tokenId, "");
  }
  function transferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes memory data
  ) public payable {
    require(_isApproved(msg.sender, tokenId), "ERC721: not approved sender");
    if (_isEventRegistered(HolographERC721Event.beforeTransfer)) {
      require(SourceERC721().beforeTransfer(from, to, tokenId, data));
    }
    _transferFrom(from, to, tokenId);
    if (_isEventRegistered(HolographERC721Event.afterTransfer)) {
      require(SourceERC721().afterTransfer(from, to, tokenId, data));
    }
  }
  function balanceOf(address wallet) public view returns (uint256) {
    require(wallet != address(0), "ERC721: zero address");
    return _ownedTokensCount[wallet];
  }
  function burned(uint256 tokenId) public view returns (bool) {
    return _burnedTokens[tokenId];
  }
  function decimals() external pure returns (uint256) {
    return 0;
  }
  function exists(uint256 tokenId) public view returns (bool) {
    return _tokenOwner[tokenId] != address(0);
  }
  function getApproved(uint256 tokenId) external view returns (address) {
    return _tokenApprovals[tokenId];
  }
  function isApprovedForAll(address wallet, address operator) external view returns (bool) {
    return _operatorApprovals[wallet][operator];
  }
  function ownerOf(uint256 tokenId) external view returns (address) {
    address tokenOwner = _tokenOwner[tokenId];
    require(tokenOwner != address(0), "ERC721: token does not exist");
    return tokenOwner;
  }
  function tokenByIndex(uint256 index) external view returns (uint256) {
    require(index < _allTokens.length, "ERC721: index out of bounds");
    return _allTokens[index];
  }
  function tokens(uint256 index, uint256 length) external view returns (uint256[] memory tokenIds) {
    uint256 supply = _allTokens.length;
    if (index + length > supply) {
      length = supply - index;
    }
    tokenIds = new uint256[](length);
    for (uint256 i = 0; i < length; i++) {
      tokenIds[i] = _allTokens[index + i];
    }
  }
  function tokenOfOwnerByIndex(address wallet, uint256 index) external view returns (uint256) {
    require(index < balanceOf(wallet), "ERC721: index out of bounds");
    return _ownedTokens[wallet][index];
  }
  function totalSupply() external view returns (uint256) {
    return _allTokens.length;
  }
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  ) external returns (bytes4) {
    require(_isContract(_operator), "ERC721: operator not contract");
    if (_isEventRegistered(HolographERC721Event.beforeOnERC721Received)) {
      require(SourceERC721().beforeOnERC721Received(_operator, _from, address(this), _tokenId, _data));
    }
    try HolographERC721Interface(_operator).ownerOf(_tokenId) returns (address tokenOwner) {
      require(tokenOwner == address(this), "ERC721: contract not token owner");
    } catch {
      revert("ERC721: token does not exist");
    }
    if (_isEventRegistered(HolographERC721Event.afterOnERC721Received)) {
      require(SourceERC721().afterOnERC721Received(_operator, _from, address(this), _tokenId, _data));
    }
    return ERC721TokenReceiver.onERC721Received.selector;
  }
  function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
    _ownedTokensIndex[tokenId] = _ownedTokensCount[to];
    _ownedTokensCount[to]++;
    _ownedTokens[to].push(tokenId);
    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }
  function _burn(address wallet, uint256 tokenId) private {
    _clearApproval(tokenId);
    _tokenOwner[tokenId] = address(0);
    emit Transfer(wallet, address(0), tokenId);
    _removeTokenFromOwnerEnumeration(wallet, tokenId);
    _burnedTokens[tokenId] = true;
  }
  function _clearApproval(uint256 tokenId) private {
    delete _tokenApprovals[tokenId];
  }
  function _mint(address to, uint256 tokenId) private {
    require(tokenId > 0, "ERC721: token id cannot be zero");
    require(to != address(0), "ERC721: minting to burn address");
    require(!_exists(tokenId), "ERC721: token already exists");
    require(!_burnedTokens[tokenId], "ERC721: token has been burned");
    _tokenOwner[tokenId] = to;
    emit Transfer(address(0), to, tokenId);
    _addTokenToOwnerEnumeration(to, tokenId);
  }
  function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
    uint256 lastTokenIndex = _allTokens.length - 1;
    uint256 tokenIndex = _allTokensIndex[tokenId];
    uint256 lastTokenId = _allTokens[lastTokenIndex];
    _allTokens[tokenIndex] = lastTokenId;
    _allTokensIndex[lastTokenId] = tokenIndex;
    delete _allTokensIndex[tokenId];
    delete _allTokens[lastTokenIndex];
    _allTokens.pop();
  }
  function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
    _removeTokenFromAllTokensEnumeration(tokenId);
    _ownedTokensCount[from]--;
    uint256 lastTokenIndex = _ownedTokensCount[from];
    uint256 tokenIndex = _ownedTokensIndex[tokenId];
    if (tokenIndex != lastTokenIndex) {
      uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
      _ownedTokens[from][tokenIndex] = lastTokenId;
      _ownedTokensIndex[lastTokenId] = tokenIndex;
    }
    if (lastTokenIndex == 0) {
      delete _ownedTokens[from];
    } else {
      delete _ownedTokens[from][lastTokenIndex];
      _ownedTokens[from].pop();
    }
  }
  function _transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) private {
    require(_tokenOwner[tokenId] == from, "ERC721: token not owned");
    require(to != address(0), "ERC721: use burn instead");
    _clearApproval(tokenId);
    _tokenOwner[tokenId] = to;
    emit Transfer(from, to, tokenId);
    _removeTokenFromOwnerEnumeration(from, tokenId);
    _addTokenToOwnerEnumeration(to, tokenId);
  }
  function _chain() private view returns (uint32) {
    uint32 currentChain = HolographInterface(HolographerInterface(payable(address(this))).getHolograph())
      .getHolographChainId();
    if (currentChain != HolographerInterface(payable(address(this))).getOriginChain()) {
      return currentChain;
    }
    return uint32(0);
  }
  function _exists(uint256 tokenId) private view returns (bool) {
    address tokenOwner = _tokenOwner[tokenId];
    return tokenOwner != address(0);
  }
  function _isApproved(address spender, uint256 tokenId) private view returns (bool) {
    require(_exists(tokenId), "ERC721: token does not exist");
    address tokenOwner = _tokenOwner[tokenId];
    return (spender == tokenOwner || _tokenApprovals[tokenId] == spender || _operatorApprovals[tokenOwner][spender]);
  }
  function _isContract(address contractAddress) private view returns (bool) {
    bytes32 codehash;
    assembly {
      codehash := extcodehash(contractAddress)
    }
    return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
  }
  function SourceERC721() private view returns (HolographedERC721 sourceContract) {
    assembly {
      sourceContract := sload(_sourceContractSlot)
    }
  }
  function _interfaces() private view returns (address) {
    return _holograph().getInterfaces();
  }
  function owner() public view override returns (address) {
    Ownable ownableContract;
    assembly {
      ownableContract := sload(_sourceContractSlot)
    }
    return ownableContract.owner();
  }
  function _holograph() private view returns (HolographInterface holograph) {
    assembly {
      holograph := sload(_holographSlot)
    }
  }
  function _royalties() private view returns (address) {
    return
      HolographRegistryInterface(_holograph().getRegistry()).getContractTypeAddress(
        0x0000000000000000000000000000000000000000000000000000000050413144
      );
  }
  receive() external payable {}
  fallback() external payable {
    address _target;
    if (HolographInterfacesInterface(_interfaces()).supportsInterface(InterfaceType.PA1D, msg.sig)) {
      _target = _royalties();
      assembly {
        calldatacopy(0, 0, calldatasize())
        let result := delegatecall(gas(), _target, 0, calldatasize(), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 {
          revert(0, returndatasize())
        }
        default {
          return(0, returndatasize())
        }
      }
    } else {
      assembly {
        calldatacopy(0, 0, calldatasize())
        mstore(calldatasize(), caller())
        let result := call(gas(), sload(_sourceContractSlot), callvalue(), 0, add(calldatasize(), 32), 0, 0)
        returndatacopy(0, 0, returndatasize())
        switch result
        case 0 {
          revert(0, returndatasize())
        }
        default {
          return(0, returndatasize())
        }
      }
    }
  }
  function _isEventRegistered(HolographERC721Event _eventName) private view returns (bool) {
    return ((_eventConfig >> uint256(_eventName)) & uint256(1) == 1 ? true : false);
  }
}
contract PA1D is Admin, Owner, Initializable {
  bytes32 constant _defaultBpSlot = 0x3ab91e3c2ba71a57537d782545f8feb1d402b604f5e070fa6c3b911fc2f18f75;
  bytes32 constant _defaultReceiverSlot = 0xfd430e1c7265cc31dbd9a10ce657e68878a41cfe179c80cd68c5edf961516848;
  bytes32 constant _initializedPaidSlot = 0x33a44e907d5bf333e203bebc20bb8c91c00375213b80f466a908f3d50b337c6c;
  bytes32 constant _payoutAddressesSlot = 0x700a541bc37f227b0d36d34e7b77cc0108bde768297c6f80f448f380387371df;
  bytes32 constant _payoutBpsSlot = 0x7a62e8104cd2cc2ef6bd3a26bcb71428108fbe0e0ead6a5bfb8676781e2ed28d;
  string constant _bpString = "eip1967.Holograph.PA1D.bp";
  string constant _receiverString = "eip1967.Holograph.PA1D.receiver";
  string constant _tokenAddressString = "eip1967.Holograph.PA1D.tokenAddress";
  event SecondarySaleFees(uint256 tokenId, address[] recipients, uint256[] bps);
  modifier onlyOwner() override {
    require(isOwner(), "PA1D: caller not an owner");
    _;
  }
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "PA1D: already initialized");
    assembly {
      sstore(_adminSlot, caller())
      sstore(_ownerSlot, caller())
    }
    (address receiver, uint256 bp) = abi.decode(initPayload, (address, uint256));
    setRoyalties(0, payable(receiver), bp);
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function initPA1D(bytes memory initPayload) external returns (bytes4) {
    uint256 initialized;
    assembly {
      initialized := sload(_initializedPaidSlot)
    }
    require(initialized == 0, "PA1D: already initialized");
    (address receiver, uint256 bp) = abi.decode(initPayload, (address, uint256));
    setRoyalties(0, payable(receiver), bp);
    initialized = 1;
    assembly {
      sstore(_initializedPaidSlot, initialized)
    }
    return InitializableInterface.init.selector;
  }
  function isOwner() private view returns (bool) {
    return (msg.sender == getOwner() ||
      msg.sender == getAdmin() ||
      msg.sender == Owner(address(this)).getOwner() ||
      msg.sender == Admin(address(this)).getAdmin());
  }
  function _getDefaultReceiver() private view returns (address payable receiver) {
    assembly {
      receiver := sload(_defaultReceiverSlot)
    }
  }
  function _setDefaultReceiver(address receiver) private {
    assembly {
      sstore(_defaultReceiverSlot, receiver)
    }
  }
  function _getDefaultBp() private view returns (uint256 bp) {
    assembly {
      bp := sload(_defaultBpSlot)
    }
  }
  function _setDefaultBp(uint256 bp) private {
    assembly {
      sstore(_defaultBpSlot, bp)
    }
  }
  function _getReceiver(uint256 tokenId) private view returns (address payable receiver) {
    bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked(_receiverString, tokenId))) - 1);
    assembly {
      receiver := sload(slot)
    }
  }
  function _setReceiver(uint256 tokenId, address receiver) private {
    bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked(_receiverString, tokenId))) - 1);
    assembly {
      sstore(slot, receiver)
    }
  }
  function _getBp(uint256 tokenId) private view returns (uint256 bp) {
    bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked(_bpString, tokenId))) - 1);
    assembly {
      bp := sload(slot)
    }
  }
  function _setBp(uint256 tokenId, uint256 bp) private {
    bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked(_bpString, tokenId))) - 1);
    assembly {
      sstore(slot, bp)
    }
  }
  function _getPayoutAddresses() private view returns (address payable[] memory addresses) {
    bytes32 slot = _payoutAddressesSlot;
    uint256 length;
    assembly {
      length := sload(slot)
    }
    addresses = new address payable[](length);
    address payable value;
    for (uint256 i = 0; i < length; i++) {
      slot = keccak256(abi.encodePacked(i, slot));
      assembly {
        value := sload(slot)
      }
      addresses[i] = value;
    }
  }
  function _setPayoutAddresses(address payable[] memory addresses) private {
    bytes32 slot = _payoutAddressesSlot;
    uint256 length = addresses.length;
    assembly {
      sstore(slot, length)
    }
    address payable value;
    for (uint256 i = 0; i < length; i++) {
      slot = keccak256(abi.encodePacked(i, slot));
      value = addresses[i];
      assembly {
        sstore(slot, value)
      }
    }
  }
  function _getPayoutBps() private view returns (uint256[] memory bps) {
    bytes32 slot = _payoutBpsSlot;
    uint256 length;
    assembly {
      length := sload(slot)
    }
    bps = new uint256[](length);
    uint256 value;
    for (uint256 i = 0; i < length; i++) {
      slot = keccak256(abi.encodePacked(i, slot));
      assembly {
        value := sload(slot)
      }
      bps[i] = value;
    }
  }
  function _setPayoutBps(uint256[] memory bps) private {
    bytes32 slot = _payoutBpsSlot;
    uint256 length = bps.length;
    assembly {
      sstore(slot, length)
    }
    uint256 value;
    for (uint256 i = 0; i < length; i++) {
      slot = keccak256(abi.encodePacked(i, slot));
      value = bps[i];
      assembly {
        sstore(slot, value)
      }
    }
  }
  function _getTokenAddress(string memory tokenName) private view returns (address tokenAddress) {
    bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked(_tokenAddressString, tokenName))) - 1);
    assembly {
      tokenAddress := sload(slot)
    }
  }
  function _setTokenAddress(string memory tokenName, address tokenAddress) private {
    bytes32 slot = bytes32(uint256(keccak256(abi.encodePacked(_tokenAddressString, tokenName))) - 1);
    assembly {
      sstore(slot, tokenAddress)
    }
  }
  function _payoutEth() private {
    address payable[] memory addresses = _getPayoutAddresses();
    uint256[] memory bps = _getPayoutBps();
    uint256 length = addresses.length;
    uint256 gasCost = (23300 * length) + length;
    uint256 balance = address(this).balance;
    require(balance - gasCost > 10000, "PA1D: Not enough ETH to transfer");
    balance = balance - gasCost;
    uint256 sending;
    for (uint256 i = 0; i < length; i++) {
      sending = ((bps[i] * balance) / 10000);
      addresses[i].transfer(sending);
    }
  }
  function _payoutToken(address tokenAddress) private {
    address payable[] memory addresses = _getPayoutAddresses();
    uint256[] memory bps = _getPayoutBps();
    uint256 length = addresses.length;
    ERC20 erc20 = ERC20(tokenAddress);
    uint256 balance = erc20.balanceOf(address(this));
    require(balance > 10000, "PA1D: Not enough tokens to transfer");
    uint256 sending;
    for (uint256 i = 0; i < length; i++) {
      sending = ((bps[i] * balance) / 10000);
      require(erc20.transfer(addresses[i], sending), "PA1D: Couldn't transfer token");
    }
  }
  function _payoutTokens(address[] memory tokenAddresses) private {
    address payable[] memory addresses = _getPayoutAddresses();
    uint256[] memory bps = _getPayoutBps();
    ERC20 erc20;
    uint256 balance;
    uint256 sending;
    for (uint256 t = 0; t < tokenAddresses.length; t++) {
      erc20 = ERC20(tokenAddresses[t]);
      balance = erc20.balanceOf(address(this));
      require(balance > 10000, "PA1D: Not enough tokens to transfer");
      for (uint256 i = 0; i < addresses.length; i++) {
        sending = ((bps[i] * balance) / 10000);
        require(erc20.transfer(addresses[i], sending), "PA1D: Couldn't transfer token");
      }
    }
  }
  function _validatePayoutRequestor() private view {
    if (!isOwner()) {
      bool matched;
      address payable[] memory addresses = _getPayoutAddresses();
      address payable sender = payable(msg.sender);
      for (uint256 i = 0; i < addresses.length; i++) {
        if (addresses[i] == sender) {
          matched = true;
          break;
        }
      }
      require(matched, "PA1D: sender not authorized");
    }
  }
  function configurePayouts(address payable[] memory addresses, uint256[] memory bps) public onlyOwner {
    require(addresses.length == bps.length, "PA1D: missmatched array lenghts");
    uint256 totalBp;
    for (uint256 i = 0; i < addresses.length; i++) {
      totalBp = totalBp + bps[i];
    }
    require(totalBp == 10000, "PA1D: bps down't equal 10000");
    _setPayoutAddresses(addresses);
    _setPayoutBps(bps);
  }
  function getPayoutInfo() public view returns (address payable[] memory addresses, uint256[] memory bps) {
    addresses = _getPayoutAddresses();
    bps = _getPayoutBps();
  }
  function getEthPayout() public {
    _validatePayoutRequestor();
    _payoutEth();
  }
  function getTokenPayout(address tokenAddress) public {
    _validatePayoutRequestor();
    _payoutToken(tokenAddress);
  }
  function getTokensPayout(address[] memory tokenAddresses) public {
    _validatePayoutRequestor();
    _payoutTokens(tokenAddresses);
  }
  function setRoyalties(
    uint256 tokenId,
    address payable receiver,
    uint256 bp
  ) public onlyOwner {
    if (tokenId == 0) {
      _setDefaultReceiver(receiver);
      _setDefaultBp(bp);
    } else {
      _setReceiver(tokenId, receiver);
      _setBp(tokenId, bp);
    }
    address[] memory receivers = new address[](1);
    receivers[0] = address(receiver);
    uint256[] memory bps = new uint256[](1);
    bps[0] = bp;
    emit SecondarySaleFees(tokenId, receivers, bps);
  }
  function royaltyInfo(uint256 tokenId, uint256 value) public view returns (address, uint256) {
    if (_getReceiver(tokenId) == address(0)) {
      return (_getDefaultReceiver(), (_getDefaultBp() * value) / 10000);
    } else {
      return (_getReceiver(tokenId), (_getBp(tokenId) * value) / 10000);
    }
  }
  function getFeeBps(uint256 tokenId) public view returns (uint256[] memory) {
    uint256[] memory bps = new uint256[](1);
    if (_getReceiver(tokenId) == address(0)) {
      bps[0] = _getDefaultBp();
    } else {
      bps[0] = _getBp(tokenId);
    }
    return bps;
  }
  function getFeeRecipients(uint256 tokenId) public view returns (address payable[] memory) {
    address payable[] memory receivers = new address payable[](1);
    if (_getReceiver(tokenId) == address(0)) {
      receivers[0] = _getDefaultReceiver();
    } else {
      receivers[0] = _getReceiver(tokenId);
    }
    return receivers;
  }
  function getRoyalties(uint256 tokenId) public view returns (address payable[] memory, uint256[] memory) {
    address payable[] memory receivers = new address payable[](1);
    uint256[] memory bps = new uint256[](1);
    if (_getReceiver(tokenId) == address(0)) {
      receivers[0] = _getDefaultReceiver();
      bps[0] = _getDefaultBp();
    } else {
      receivers[0] = _getReceiver(tokenId);
      bps[0] = _getBp(tokenId);
    }
    return (receivers, bps);
  }
  function getFees(uint256 tokenId) public view returns (address payable[] memory, uint256[] memory) {
    address payable[] memory receivers = new address payable[](1);
    uint256[] memory bps = new uint256[](1);
    if (_getReceiver(tokenId) == address(0)) {
      receivers[0] = _getDefaultReceiver();
      bps[0] = _getDefaultBp();
    } else {
      receivers[0] = _getReceiver(tokenId);
      bps[0] = _getBp(tokenId);
    }
    return (receivers, bps);
  }
  function tokenCreator(
    address,
    uint256 tokenId
  ) public view returns (address) {
    address receiver = _getReceiver(tokenId);
    if (receiver == address(0)) {
      return _getDefaultReceiver();
    }
    return receiver;
  }
  function calculateRoyaltyFee(
    address,
    uint256 tokenId,
    uint256 amount
  ) public view returns (uint256) {
    if (_getReceiver(tokenId) == address(0)) {
      return (_getDefaultBp() * amount) / 10000;
    } else {
      return (_getBp(tokenId) * amount) / 10000;
    }
  }
  function marketContract() public view returns (address) {
    return address(this);
  }
  function tokenCreators(uint256 tokenId) public view returns (address) {
    address receiver = _getReceiver(tokenId);
    if (receiver == address(0)) {
      return _getDefaultReceiver();
    }
    return receiver;
  }
  function bidSharesForToken(uint256 tokenId) public view returns (ZoraBidShares memory bidShares) {
    bidShares.prevOwner.value = 0;
    bidShares.owner.value = 0;
    if (_getReceiver(tokenId) == address(0)) {
      bidShares.creator.value = _getDefaultBp();
    } else {
      bidShares.creator.value = _getBp(tokenId);
    }
    return bidShares;
  }
  function getTokenAddress(string memory tokenName) public view returns (address) {
    return _getTokenAddress(tokenName);
  }
}
contract Faucet is Initializable {
  address public owner;
  HolographERC20Interface public token;
  uint256 public faucetDripAmount = 100 ether;
  uint256 public faucetCooldown = 24 hours;
  mapping(address => uint256) lastAccessTime;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "Faucet contract is already initialized");
    (address _contractOwner, address _tokenInstance) = abi.decode(initPayload, (address, address));
    token = HolographERC20Interface(_tokenInstance);
    owner = _contractOwner;
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function requestTokens() external {
    require(isAllowedToWithdraw(msg.sender), "Come back later");
    require(token.balanceOf(address(this)) >= faucetDripAmount, "Faucet is empty");
    lastAccessTime[msg.sender] = block.timestamp;
    token.transfer(msg.sender, faucetDripAmount);
  }
  function setToken(address tokenAddress) external onlyOwner {
    token = HolographERC20Interface(tokenAddress);
  }
  function grantTokens(address _address) external onlyOwner {
    require(token.balanceOf(address(this)) >= faucetDripAmount, "Faucet is empty");
    token.transfer(_address, faucetDripAmount);
  }
  function grantTokens(address _address, uint256 _amountWei) external onlyOwner {
    require(token.balanceOf(address(this)) >= _amountWei, "Insufficient funds");
    token.transfer(_address, _amountWei);
  }
  function withdrawAllTokens(address _receiver) external onlyOwner {
    token.transfer(_receiver, token.balanceOf(address(this)));
  }
  function withdrawTokens(address _receiver, uint256 _amountWei) external onlyOwner {
    require(token.balanceOf(address(this)) >= _amountWei, "Insufficient funds");
    token.transfer(_receiver, _amountWei);
  }
  function setWithdrawCooldown(uint256 _waitTimeSeconds) external onlyOwner {
    faucetCooldown = _waitTimeSeconds;
  }
  function setWithdrawAmount(uint256 _amountWei) external onlyOwner {
    faucetDripAmount = _amountWei;
  }
  function isAllowedToWithdraw(address _address) public view returns (bool) {
    if (lastAccessTime[_address] == 0) {
      return true;
    } else if (block.timestamp >= lastAccessTime[_address] + faucetCooldown) {
      return true;
    }
    return false;
  }
  function getLastAccessTime(address _address) public view returns (uint256) {
    return lastAccessTime[_address];
  }
  modifier onlyOwner() {
    require(msg.sender == owner, "Caller is not the owner");
    _;
  }
}
interface LayerZeroUserApplicationConfigInterface {
  function setConfig(
    uint16 _version,
    uint16 _chainId,
    uint256 _configType,
    bytes calldata _config
  ) external;
  function setSendVersion(uint16 _version) external;
  function setReceiveVersion(uint16 _version) external;
  function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external;
}
interface LayerZeroEndpointInterface is LayerZeroUserApplicationConfigInterface {
  function send(
    uint16 _dstChainId,
    bytes calldata _destination,
    bytes calldata _payload,
    address payable _refundAddress,
    address _zroPaymentAddress,
    bytes calldata _adapterParams
  ) external payable;
  function receivePayload(
    uint16 _srcChainId,
    bytes calldata _srcAddress,
    address _dstAddress,
    uint64 _nonce,
    uint256 _gasLimit,
    bytes calldata _payload
  ) external;
  function getInboundNonce(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint64);
  function getOutboundNonce(uint16 _dstChainId, address _srcAddress) external view returns (uint64);
  function estimateFees(
    uint16 _dstChainId,
    address _userApplication,
    bytes calldata _payload,
    bool _payInZRO,
    bytes calldata _adapterParam
  ) external view returns (uint256 nativeFee, uint256 zroFee);
  function getChainId() external view returns (uint16);
  function retryPayload(
    uint16 _srcChainId,
    bytes calldata _srcAddress,
    bytes calldata _payload
  ) external;
  function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (bool);
  function getSendLibraryAddress(address _userApplication) external view returns (address);
  function getReceiveLibraryAddress(address _userApplication) external view returns (address);
  function isSendingPayload() external view returns (bool);
  function isReceivingPayload() external view returns (bool);
  function getConfig(
    uint16 _version,
    uint16 _chainId,
    address _userApplication,
    uint256 _configType
  ) external view returns (bytes memory);
  function getSendVersion(address _userApplication) external view returns (uint16);
  function getReceiveVersion(address _userApplication) external view returns (uint16);
}
contract ERC20Mock is
  ERC165,
  ERC20,
  ERC20Burnable,
  ERC20Metadata,
  ERC20Receiver,
  ERC20Safer,
  ERC20Permit,
  NonReentrant,
  EIP712
{
  bool private _works;
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  uint8 private _decimals;
  mapping(bytes4 => bool) private _supportedInterfaces;
  mapping(address => uint256) private _nonces;
  constructor(
    string memory contractName,
    string memory contractSymbol,
    uint8 contractDecimals,
    string memory domainSeperator,
    string memory domainVersion
  ) {
    _works = true;
    _name = contractName;
    _symbol = contractSymbol;
    _decimals = contractDecimals;
    _supportedInterfaces[ERC165.supportsInterface.selector] = true;
    _supportedInterfaces[ERC20.allowance.selector] = true;
    _supportedInterfaces[ERC20.approve.selector] = true;
    _supportedInterfaces[ERC20.balanceOf.selector] = true;
    _supportedInterfaces[ERC20.totalSupply.selector] = true;
    _supportedInterfaces[ERC20.transfer.selector] = true;
    _supportedInterfaces[ERC20.transferFrom.selector] = true;
    _supportedInterfaces[
      ERC20.allowance.selector ^
        ERC20.approve.selector ^
        ERC20.balanceOf.selector ^
        ERC20.totalSupply.selector ^
        ERC20.transfer.selector ^
        ERC20.transferFrom.selector
    ] = true;
    _supportedInterfaces[ERC20Metadata.name.selector] = true;
    _supportedInterfaces[ERC20Metadata.symbol.selector] = true;
    _supportedInterfaces[ERC20Metadata.decimals.selector] = true;
    _supportedInterfaces[
      ERC20Metadata.name.selector ^ ERC20Metadata.symbol.selector ^ ERC20Metadata.decimals.selector
    ] = true;
    _supportedInterfaces[ERC20Burnable.burn.selector] = true;
    _supportedInterfaces[ERC20Burnable.burnFrom.selector] = true;
    _supportedInterfaces[ERC20Burnable.burn.selector ^ ERC20Burnable.burnFrom.selector] = true;
    _supportedInterfaces[0x423f6cef] = true;
    _supportedInterfaces[0xeb795549] = true;
    _supportedInterfaces[0x42842e0e] = true;
    _supportedInterfaces[0xb88d4fde] = true;
    _supportedInterfaces[bytes4(0x423f6cef) ^ bytes4(0xeb795549) ^ bytes4(0x42842e0e) ^ bytes4(0xb88d4fde)] = true;
    _supportedInterfaces[ERC20Receiver.onERC20Received.selector] = true;
    _supportedInterfaces[ERC20Permit.permit.selector] = true;
    _supportedInterfaces[ERC20Permit.nonces.selector] = true;
    _supportedInterfaces[ERC20Permit.DOMAIN_SEPARATOR.selector] = true;
    _supportedInterfaces[
      ERC20Permit.permit.selector ^ ERC20Permit.nonces.selector ^ ERC20Permit.DOMAIN_SEPARATOR.selector
    ] = true;
    _eip712_init(domainSeperator, domainVersion);
  }
  function toggleWorks(bool active) external {
    _works = active;
  }
  function transferTokens(
    address payable token,
    address to,
    uint256 amount
  ) external {
    ERC20(token).transfer(to, amount);
  }
  receive() external payable {}
  function decimals() public view returns (uint8) {
    return _decimals;
  }
  function supportsInterface(bytes4 interfaceId) public view returns (bool) {
    return _supportedInterfaces[interfaceId];
  }
  function allowance(address account, address spender) public view returns (uint256) {
    return _allowances[account][spender];
  }
  function balanceOf(address account) public view returns (uint256) {
    return _balances[account];
  }
  function DOMAIN_SEPARATOR() public view returns (bytes32) {
    return _domainSeparatorV4();
  }
  function name() public view returns (string memory) {
    return _name;
  }
  function nonces(address account) public view returns (uint256) {
    return _nonces[account];
  }
  function symbol() public view returns (string memory) {
    return _symbol;
  }
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }
  function approve(address spender, uint256 amount) public returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }
  function burn(uint256 amount) public {
    _burn(msg.sender, amount);
  }
  function burnFrom(address account, uint256 amount) public returns (bool) {
    uint256 currentAllowance = _allowances[account][msg.sender];
    require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
    unchecked {
      _allowances[account][msg.sender] = currentAllowance - amount;
    }
    _burn(account, amount);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    require(currentAllowance >= subtractedValue, "ERC20: decreased below zero");
    uint256 newAllowance;
    unchecked {
      newAllowance = currentAllowance - subtractedValue;
    }
    _approve(msg.sender, spender, newAllowance);
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    uint256 currentAllowance = _allowances[msg.sender][spender];
    uint256 newAllowance;
    unchecked {
      newAllowance = currentAllowance + addedValue;
    }
    unchecked {
      require(newAllowance >= currentAllowance, "ERC20: increased above max value");
    }
    _approve(msg.sender, spender, newAllowance);
    return true;
  }
  function mint(address account, uint256 amount) external {
    _mint(account, amount);
  }
  function onERC20Received(
    address account,
    address, 
    uint256 amount,
    bytes calldata 
  ) public returns (bytes4) {
    assembly {
      sstore(0x17fb676f92438402d8ef92193dd096c59ee1f4ba1bb57f67f3e6d2eef8aeed5e, amount)
    }
    if (_works) {
      require(_isContract(account), "ERC20: operator not contract");
      try ERC20(account).balanceOf(address(this)) returns (uint256 balance) {
        require(balance >= amount, "ERC20: balance check failed");
      } catch {
        revert("ERC20: failed getting balance");
      }
      return ERC20Receiver.onERC20Received.selector;
    } else {
      return 0x00000000;
    }
  }
  function permit(
    address account,
    address spender,
    uint256 amount,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    require(block.timestamp <= deadline, "ERC20: expired deadline");
    bytes32 structHash = keccak256(
      abi.encode(
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9,
        account,
        spender,
        amount,
        _useNonce(account),
        deadline
      )
    );
    bytes32 hash = _hashTypedDataV4(structHash);
    address signer = ECDSA.recover(hash, v, r, s);
    require(signer == account, "ERC20: invalid signature");
    _approve(account, spender, amount);
  }
  function safeTransfer(address recipient, uint256 amount) public returns (bool) {
    return safeTransfer(recipient, amount, "");
  }
  function safeTransfer(
    address recipient,
    uint256 amount,
    bytes memory data
  ) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
    require(_checkOnERC20Received(msg.sender, recipient, amount, data), "ERC20: non ERC20Receiver");
    return true;
  }
  function safeTransferFrom(
    address account,
    address recipient,
    uint256 amount
  ) public returns (bool) {
    return safeTransferFrom(account, recipient, amount, "");
  }
  function safeTransferFrom(
    address account,
    address recipient,
    uint256 amount,
    bytes memory data
  ) public returns (bool) {
    if (account != msg.sender) {
      uint256 currentAllowance = _allowances[account][msg.sender];
      require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
      unchecked {
        _allowances[account][msg.sender] = currentAllowance - amount;
      }
    }
    _transfer(account, recipient, amount);
    require(_checkOnERC20Received(account, recipient, amount, data), "ERC20: non ERC20Receiver");
    return true;
  }
  function transfer(address recipient, uint256 amount) public returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }
  function transferFrom(
    address account,
    address recipient,
    uint256 amount
  ) public returns (bool) {
    if (account != msg.sender) {
      uint256 currentAllowance = _allowances[account][msg.sender];
      require(currentAllowance >= amount, "ERC20: amount exceeds allowance");
      unchecked {
        _allowances[account][msg.sender] = currentAllowance - amount;
      }
    }
    _transfer(account, recipient, amount);
    return true;
  }
  function _approve(
    address account,
    address spender,
    uint256 amount
  ) internal {
    require(account != address(0), "ERC20: account is zero address");
    require(spender != address(0), "ERC20: spender is zero address");
    _allowances[account][spender] = amount;
    emit Approval(account, spender, amount);
  }
  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "ERC20: account is zero address");
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;
    emit Transfer(account, address(0), amount);
  }
  function _checkOnERC20Received(
    address account,
    address recipient,
    uint256 amount,
    bytes memory data
  ) internal nonReentrant returns (bool) {
    if (_isContract(recipient)) {
      try ERC165(recipient).supportsInterface(0x01ffc9a7) returns (bool erc165support) {
        require(erc165support, "ERC20: no ERC165 support");
        if (ERC165(recipient).supportsInterface(0x534f5876)) {
          try ERC20Receiver(recipient).onERC20Received(msg.sender, account, amount, data) returns (bytes4 retval) {
            return retval == ERC20Receiver.onERC20Received.selector;
          } catch (bytes memory reason) {
            if (reason.length == 0) {
              revert("ERC20: non ERC20Receiver");
            } else {
              assembly {
                revert(add(32, reason), mload(reason))
              }
            }
          }
        } else {
          revert("ERC20: eip-4524 not supported");
        }
      } catch (bytes memory reason) {
        if (reason.length == 0) {
          revert("ERC20: no ERC165 support");
        } else {
          assembly {
            revert(add(32, reason), mload(reason))
          }
        }
      }
    } else {
      return true;
    }
  }
  function _mint(address to, uint256 amount) internal {
    require(to != address(0), "ERC20: minting to burn address");
    _totalSupply += amount;
    _balances[to] += amount;
    emit Transfer(address(0), to, amount);
  }
  function _transfer(
    address account,
    address recipient,
    uint256 amount
  ) internal {
    require(account != address(0), "ERC20: account is zero address");
    require(recipient != address(0), "ERC20: recipient is zero address");
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _balances[recipient] += amount;
    emit Transfer(account, recipient, amount);
  }
  function _useNonce(address account) internal returns (uint256 current) {
    current = _nonces[account];
    _nonces[account]++;
  }
  function _isContract(address contractAddress) private view returns (bool) {
    bytes32 codehash;
    assembly {
      codehash := extcodehash(contractAddress)
    }
    return (codehash != 0x0 && codehash != 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470);
  }
}
interface LayerZeroReceiverInterface {
  function lzReceive(
    uint16 _srcChainId,
    bytes calldata _srcAddress,
    uint64 _nonce,
    bytes calldata _payload
  ) external;
}
contract LZEndpointMock is LayerZeroEndpointInterface {
  mapping(address => address) public lzEndpointLookup;
  uint16 public mockChainId;
  address payable public mockOracle;
  address payable public mockRelayer;
  uint256 public mockBlockConfirmations;
  uint16 public mockLibraryVersion;
  uint256 public mockStaticNativeFee;
  uint16 public mockLayerZeroVersion;
  uint256 public nativeFee;
  uint256 public zroFee;
  bool nextMsgBLocked;
  struct StoredPayload {
    uint64 payloadLength;
    address dstAddress;
    bytes32 payloadHash;
  }
  struct QueuedPayload {
    address dstAddress;
    uint64 nonce;
    bytes payload;
  }
  mapping(uint16 => mapping(bytes => uint64)) public inboundNonce;
  mapping(uint16 => mapping(address => uint64)) public outboundNonce;
  mapping(uint16 => mapping(bytes => StoredPayload)) public storedPayload;
  mapping(uint16 => mapping(bytes => QueuedPayload[])) public msgsToDeliver;
  event UaForceResumeReceive(uint16 chainId, bytes srcAddress);
  event PayloadCleared(uint16 srcChainId, bytes srcAddress, uint64 nonce, address dstAddress);
  event PayloadStored(
    uint16 srcChainId,
    bytes srcAddress,
    address dstAddress,
    uint64 nonce,
    bytes payload,
    bytes reason
  );
  constructor(uint16 _chainId) {
    mockStaticNativeFee = 42;
    mockLayerZeroVersion = 1;
    mockChainId = _chainId;
  }
  function setEstimatedFees(uint256 _nativeFee, uint256 _zroFee) public {
    nativeFee = _nativeFee;
    zroFee = _zroFee;
  }
  function getChainId() external view override returns (uint16) {
    return mockChainId;
  }
  function setDestLzEndpoint(address destAddr, address lzEndpointAddr) external {
    lzEndpointLookup[destAddr] = lzEndpointAddr;
  }
  function send(
    uint16 _chainId,
    bytes calldata _destination,
    bytes calldata _payload,
    address payable, 
    address, 
    bytes memory _adapterParams
  ) external payable override {
    address destAddr = packedBytesToAddr(_destination);
    address lzEndpoint = lzEndpointLookup[destAddr];
    require(lzEndpoint != address(0), "LayerZeroMock: destination LayerZero Endpoint not found");
    uint64 nonce;
    {
      nonce = ++outboundNonce[_chainId][msg.sender];
    }
    {
      uint256 extraGas;
      uint256 dstNative;
      address dstNativeAddr;
      assembly {
        extraGas := mload(add(_adapterParams, 34))
        dstNative := mload(add(_adapterParams, 66))
        dstNativeAddr := mload(add(_adapterParams, 86))
      }
    }
    bytes memory bytesSourceUserApplicationAddr = addrToPackedBytes(address(msg.sender)); 
    LZEndpointMock(lzEndpoint).receivePayload(
      mockChainId,
      bytesSourceUserApplicationAddr,
      destAddr,
      nonce,
      0,
      _payload
    );
  }
  function receivePayload(
    uint16 _srcChainId,
    bytes calldata _srcAddress,
    address _dstAddress,
    uint64 _nonce,
    uint256, 
    bytes calldata _payload
  ) external override {
    StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
    require(_nonce == ++inboundNonce[_srcChainId][_srcAddress], "LayerZero: wrong nonce");
    if (sp.payloadHash != bytes32(0)) {
      QueuedPayload[] storage msgs = msgsToDeliver[_srcChainId][_srcAddress];
      QueuedPayload memory newMsg = QueuedPayload(_dstAddress, _nonce, _payload);
      if (msgs.length > 0) {
        msgs.push(newMsg);
        for (uint256 i = 0; i < msgs.length - 1; i++) {
          msgs[i + 1] = msgs[i];
        }
        msgs[0] = newMsg;
      } else {
        msgs.push(newMsg);
      }
    } else if (nextMsgBLocked) {
      storedPayload[_srcChainId][_srcAddress] = StoredPayload(
        uint64(_payload.length),
        _dstAddress,
        keccak256(_payload)
      );
      emit PayloadStored(_srcChainId, _srcAddress, _dstAddress, _nonce, _payload, bytes(""));
      nextMsgBLocked = false;
    } else {
      LayerZeroReceiverInterface(_dstAddress).lzReceive(_srcChainId, _srcAddress, _nonce, _payload); 
    }
  }
  function blockNextMsg() external {
    nextMsgBLocked = true;
  }
  function getLengthOfQueue(uint16 _srcChainId, bytes calldata _srcAddress) external view returns (uint256) {
    return msgsToDeliver[_srcChainId][_srcAddress].length;
  }
  function estimateFees(
    uint16,
    address,
    bytes memory,
    bool,
    bytes memory
  ) external view override returns (uint256 _nativeFee, uint256 _zroFee) {
    _nativeFee = nativeFee;
    _zroFee = zroFee;
  }
  function packedBytesToAddr(bytes calldata _b) public pure returns (address) {
    address addr;
    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, sub(_b.offset, 2), add(_b.length, 2))
      addr := mload(sub(ptr, 10))
    }
    return addr;
  }
  function addrToPackedBytes(address _a) public pure returns (bytes memory) {
    bytes memory data = abi.encodePacked(_a);
    return data;
  }
  function setConfig(
    uint16, 
    uint16, 
    uint256, 
    bytes memory 
  ) external override {}
  function getConfig(
    uint16, 
    uint16, 
    address, 
    uint256 
  ) external pure override returns (bytes memory) {
    return "";
  }
  function setSendVersion(
    uint16 
  ) external override {}
  function setReceiveVersion(
    uint16 
  ) external override {}
  function getSendVersion(
    address 
  ) external pure override returns (uint16) {
    return 1;
  }
  function getReceiveVersion(
    address 
  ) external pure override returns (uint16) {
    return 1;
  }
  function getInboundNonce(uint16 _chainID, bytes calldata _srcAddress) external view override returns (uint64) {
    return inboundNonce[_chainID][_srcAddress];
  }
  function getOutboundNonce(uint16 _chainID, address _srcAddress) external view override returns (uint64) {
    return outboundNonce[_chainID][_srcAddress];
  }
  function _clearMsgQue(uint16 _srcChainId, bytes calldata _srcAddress) internal {
    QueuedPayload[] storage msgs = msgsToDeliver[_srcChainId][_srcAddress];
    while (msgs.length > 0) {
      QueuedPayload memory payload = msgs[msgs.length - 1];
      LayerZeroReceiverInterface(payload.dstAddress).lzReceive(
        _srcChainId,
        _srcAddress,
        payload.nonce,
        payload.payload
      );
      msgs.pop();
    }
  }
  function forceResumeReceive(uint16 _srcChainId, bytes calldata _srcAddress) external override {
    StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
    require(sp.payloadHash != bytes32(0), "LayerZero: no stored payload");
    require(sp.dstAddress == msg.sender, "LayerZero: invalid caller");
    sp.payloadLength = 0;
    sp.dstAddress = address(0);
    sp.payloadHash = bytes32(0);
    emit UaForceResumeReceive(_srcChainId, _srcAddress);
    _clearMsgQue(_srcChainId, _srcAddress);
  }
  function retryPayload(
    uint16 _srcChainId,
    bytes calldata _srcAddress,
    bytes calldata _payload
  ) external override {
    StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
    require(sp.payloadHash != bytes32(0), "LayerZero: no stored payload");
    require(_payload.length == sp.payloadLength && keccak256(_payload) == sp.payloadHash, "LayerZero: invalid payload");
    address dstAddress = sp.dstAddress;
    sp.payloadLength = 0;
    sp.dstAddress = address(0);
    sp.payloadHash = bytes32(0);
    uint64 nonce = inboundNonce[_srcChainId][_srcAddress];
    LayerZeroReceiverInterface(dstAddress).lzReceive(_srcChainId, _srcAddress, nonce, _payload);
    emit PayloadCleared(_srcChainId, _srcAddress, nonce, dstAddress);
  }
  function hasStoredPayload(uint16 _srcChainId, bytes calldata _srcAddress) external view override returns (bool) {
    StoredPayload storage sp = storedPayload[_srcChainId][_srcAddress];
    return sp.payloadHash != bytes32(0);
  }
  function isSendingPayload() external pure override returns (bool) {
    return false;
  }
  function isReceivingPayload() external pure override returns (bool) {
    return false;
  }
  function getSendLibraryAddress(address) external view override returns (address) {
    return address(this);
  }
  function getReceiveLibraryAddress(address) external view override returns (address) {
    return address(this);
  }
}
contract Mock is Initializable {
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "MOCK: already initialized");
    bytes32 arbitraryData = abi.decode(initPayload, (bytes32));
    bool shouldFail = false;
    assembly {
      sstore(0x01, arbitraryData)
      switch arbitraryData
      case 0 {
        shouldFail := 0x01
      }
    }
    _setInitialized();
    if (shouldFail) {
      return bytes4(0x12345678);
    } else {
      return InitializableInterface.init.selector;
    }
  }
  function getStorage(uint256 slot) public view returns (bytes32 data) {
    assembly {
      data := sload(slot)
    }
  }
  function setStorage(uint256 slot, bytes32 data) public {
    assembly {
      sstore(slot, data)
    }
  }
  function mockCall(address target, bytes calldata data) public payable {
    assembly {
      calldatacopy(0, data.offset, data.length)
      let result := call(gas(), target, callvalue(), 0, data.length, 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
  function mockStaticCall(address target, bytes calldata data) public view returns (bytes memory) {
    assembly {
      calldatacopy(0, data.offset, data.length)
      let result := staticcall(gas(), target, 0, data.length, 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
  function mockDelegateCall(address target, bytes calldata data) public returns (bytes memory) {
    assembly {
      calldatacopy(0, data.offset, data.length)
      let result := delegatecall(gas(), target, 0, data.length, 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := call(gas(), sload(0), callvalue(), 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract MockERC721Receiver is ERC165, ERC721TokenReceiver {
  bool private _works;
  constructor() {
    _works = true;
  }
  function toggleWorks(bool active) external {
    _works = active;
  }
  function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
    if (interfaceID == 0x01ffc9a7 || interfaceID == 0x150b7a02) {
      return true;
    } else {
      return false;
    }
  }
  function onERC721Received(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external view returns (bytes4) {
    if (_works) {
      return 0x150b7a02;
    } else {
      return 0x00000000;
    }
  }
  function transferNFT(
    address payable token,
    uint256 tokenId,
    address to
  ) external {
    ERC721(token).safeTransferFrom(address(this), to, tokenId);
  }
}
contract MockHolographChild is Holograph {
  constructor() {}
}
contract MockHolographGenesisChild is HolographGenesis {
  constructor() {}
  function approveDeployerMock(address newDeployer, bool approve) external onlyDeployer {
    return this.approveDeployer(newDeployer, approve);
  }
  function isApprovedDeployerMock(address deployer) external view returns (bool) {
    return this.isApprovedDeployer(deployer);
  }
}
interface LayerZeroOverrides {
  struct ApplicationConfiguration {
    uint16 inboundProofLibraryVersion;
    uint64 inboundBlockConfirmations;
    address relayer;
    uint16 outboundProofType;
    uint64 outboundBlockConfirmations;
    address oracle;
  }
  struct DstPrice {
    uint128 dstPriceRatio; 
    uint128 dstGasPriceInWei;
  }
  struct DstConfig {
    uint128 dstNativeAmtCap;
    uint64 baseGas;
    uint64 gasPerByte;
  }
  function defaultSendLibrary() external view returns (address);
  function getAppConfig(uint16 destinationChainId, address userApplicationAddress)
    external
    view
    returns (ApplicationConfiguration memory);
  function defaultAppConfig(uint16 destinationChainId)
    external
    view
    returns (
      uint16 inboundProofLibraryVersion,
      uint64 inboundBlockConfirmations,
      address relayer,
      uint16 outboundProofType,
      uint64 outboundBlockConfirmations,
      address oracle
    );
  function dstPriceLookup(uint16 destinationChainId)
    external
    view
    returns (uint128 dstPriceRatio, uint128 dstGasPriceInWei);
  function dstConfigLookup(uint16 destinationChainId, uint16 outboundProofType)
    external
    view
    returns (
      uint128 dstNativeAmtCap,
      uint64 baseGas,
      uint64 gasPerByte
    );
  function send(
    uint16 _dstChainId,
    bytes calldata _destination,
    bytes calldata _payload,
    address payable _refundAddress,
    address _zroPaymentAddress,
    bytes calldata _adapterParams
  ) external payable;
  function estimateFees(
    uint16 _dstChainId,
    address _userApplication,
    bytes calldata _payload,
    bool _payInZRO,
    bytes calldata _adapterParam
  ) external view returns (uint256 nativeFee, uint256 zroFee);
}
contract MockLZEndpoint is Admin {
  event LzEvent(uint16 _dstChainId, bytes _destination, bytes _payload);
  constructor() {
    assembly {
      sstore(_adminSlot, origin())
    }
  }
  function send(
    uint16 _dstChainId,
    bytes calldata _destination,
    bytes calldata _payload,
    address payable, 
    address, 
    bytes calldata 
  ) external payable {
    emit LzEvent(_dstChainId, _destination, _payload);
  }
  function estimateFees(
    uint16,
    address,
    bytes calldata,
    bool,
    bytes calldata
  ) external pure returns (uint256 nativeFee, uint256 zroFee) {
    nativeFee = 10**15;
    zroFee = 10**7;
  }
  function defaultSendLibrary() external view returns (address) {
    return address(this);
  }
  function getAppConfig(uint16, address) external view returns (LayerZeroOverrides.ApplicationConfiguration memory) {
    return LayerZeroOverrides.ApplicationConfiguration(0, 0, address(this), 0, 0, address(this));
  }
  function dstPriceLookup(uint16) external pure returns (uint128 dstPriceRatio, uint128 dstGasPriceInWei) {
    dstPriceRatio = 10**10;
    dstGasPriceInWei = 1000000000;
  }
  function dstConfigLookup(uint16, uint16)
    external
    pure
    returns (
      uint128 dstNativeAmtCap,
      uint64 baseGas,
      uint64 gasPerByte
    )
  {
    dstNativeAmtCap = 10**18;
    baseGas = 50000;
    gasPerByte = 25;
  }
}
interface LayerZeroModuleInterface {
  function lzReceive(
    uint16 _srcChainId,
    bytes calldata _srcAddress,
    uint64 _nonce,
    bytes calldata _payload
  ) external payable;
  function getInterfaces() external view returns (address interfaces);
  function setInterfaces(address interfaces) external;
  function getLZEndpoint() external view returns (address lZEndpoint);
  function setLZEndpoint(address lZEndpoint) external;
  function getOperator() external view returns (address operator);
  function setOperator(address operator) external;
}
contract LayerZeroModule is Admin, Initializable, CrossChainMessageInterface, LayerZeroModuleInterface {
  bytes32 constant _bridgeSlot = 0xeb87cbb21687feb327e3d58c6c16d552231d12c7a0e8115042a4165fac8a77f9;
  bytes32 constant _interfacesSlot = 0xbd3084b8c09da87ad159c247a60e209784196be2530cecbbd8f337fdd1848827;
  bytes32 constant _lZEndpointSlot = 0x56825e447adf54cdde5f04815fcf9b1dd26ef9d5c053625147c18b7c13091686;
  bytes32 constant _operatorSlot = 0x7caba557ad34138fa3b7e43fb574e0e6cc10481c3073e0dffbc560db81b5c60f;
  bytes32 constant _baseGasSlot = 0x1eaa99919d5563fbfdd75d9d906ff8de8cf52beab1ed73875294c8a0c9e9d83a;
  bytes32 constant _gasPerByteSlot = 0x99d8b07d37c89d4c4f4fa0fd9b7396caeb5d1d4e58b41c61c71e3cf7d424a625;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address bridge, address interfaces, address operator, uint256 baseGas, uint256 gasPerByte) = abi.decode(
      initPayload,
      (address, address, address, uint256, uint256)
    );
    assembly {
      sstore(_adminSlot, origin())
      sstore(_bridgeSlot, bridge)
      sstore(_interfacesSlot, interfaces)
      sstore(_operatorSlot, operator)
      sstore(_baseGasSlot, baseGas)
      sstore(_gasPerByteSlot, gasPerByte)
    }
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function lzReceive(
    uint16, 
    bytes calldata _srcAddress,
    uint64, 
    bytes calldata _payload
  ) external payable {
    assembly {
      switch eq(sload(_lZEndpointSlot), caller())
      case 0 {
        mstore(0x80, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0xa0, 0x0000002000000000000000000000000000000000000000000000000000000000)
        mstore(0xc0, 0x0000001b484f4c4f47524150483a204c5a206f6e6c7920656e64706f696e7400)
        mstore(0xe0, 0x0000000000000000000000000000000000000000000000000000000000000000)
        revert(0x80, 0xc4)
      }
      let ptr := mload(0x40)
      calldatacopy(add(ptr, 0x0c), _srcAddress.offset, _srcAddress.length)
      switch eq(mload(ptr), address())
      case 0 {
        mstore(0x80, 0x08c379a000000000000000000000000000000000000000000000000000000000)
        mstore(0xa0, 0x0000002000000000000000000000000000000000000000000000000000000000)
        mstore(0xc0, 0x0000001e484f4c4f47524150483a20756e617574686f72697a65642073656e64)
        mstore(0xe0, 0x6572000000000000000000000000000000000000000000000000000000000000)
        revert(0x80, 0xc4)
      }
    }
    _operator().crossChainMessage(_payload);
  }
  function send(
    uint256, 
    uint256, 
    uint32 toChain,
    address msgSender,
    uint256 msgValue,
    bytes calldata crossChainPayload
  ) external payable {
    require(msg.sender == address(_operator()), "HOLOGRAPH: operator only call");
    LayerZeroOverrides lZEndpoint;
    assembly {
      lZEndpoint := sload(_lZEndpointSlot)
    }
    lZEndpoint.send{value: msgValue}(
      uint16(_interfaces().getChainId(ChainIdType.HOLOGRAPH, uint256(toChain), ChainIdType.LAYERZERO)),
      abi.encodePacked(address(this), address(this)),
      crossChainPayload,
      payable(msgSender),
      address(this),
      abi.encodePacked(uint16(1), uint256(_baseGas() + (crossChainPayload.length * _gasPerByte())))
    );
  }
  function getMessageFee(
    uint32 toChain,
    uint256 gasLimit,
    uint256 gasPrice,
    bytes calldata crossChainPayload
  ) external view returns (uint256 hlgFee, uint256 msgFee) {
    uint16 lzDestChain = uint16(
      _interfaces().getChainId(ChainIdType.HOLOGRAPH, uint256(toChain), ChainIdType.LAYERZERO)
    );
    LayerZeroOverrides lz;
    assembly {
      lz := sload(_lZEndpointSlot)
    }
    (uint128 dstPriceRatio, uint128 dstGasPriceInWei) = _getPricing(lz, lzDestChain);
    if (gasPrice == 0) {
      gasPrice = dstGasPriceInWei;
    }
    bytes memory adapterParams = abi.encodePacked(
      uint16(1),
      uint256(_baseGas() + (crossChainPayload.length * _gasPerByte()))
    );
    (uint256 nativeFee, ) = lz.estimateFees(lzDestChain, address(this), crossChainPayload, false, adapterParams);
    return (((gasPrice * (gasLimit + (gasLimit / 10))) * dstPriceRatio) / (10**10), nativeFee);
  }
  function getHlgFee(
    uint32 toChain,
    uint256 gasLimit,
    uint256 gasPrice
  ) external view returns (uint256 hlgFee) {
    LayerZeroOverrides lz;
    assembly {
      lz := sload(_lZEndpointSlot)
    }
    uint16 lzDestChain = uint16(
      _interfaces().getChainId(ChainIdType.HOLOGRAPH, uint256(toChain), ChainIdType.LAYERZERO)
    );
    (uint128 dstPriceRatio, uint128 dstGasPriceInWei) = _getPricing(lz, lzDestChain);
    if (gasPrice == 0) {
      gasPrice = dstGasPriceInWei;
    }
    return ((gasPrice * (gasLimit + (gasLimit / 10))) * dstPriceRatio) / (10**10);
  }
  function _getPricing(LayerZeroOverrides lz, uint16 lzDestChain)
    private
    view
    returns (uint128 dstPriceRatio, uint128 dstGasPriceInWei)
  {
    return
      LayerZeroOverrides(LayerZeroOverrides(lz.defaultSendLibrary()).getAppConfig(lzDestChain, address(this)).relayer)
        .dstPriceLookup(lzDestChain);
  }
  function getBridge() external view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function setBridge(address bridge) external onlyAdmin {
    assembly {
      sstore(_bridgeSlot, bridge)
    }
  }
  function getInterfaces() external view returns (address interfaces) {
    assembly {
      interfaces := sload(_interfacesSlot)
    }
  }
  function setInterfaces(address interfaces) external onlyAdmin {
    assembly {
      sstore(_interfacesSlot, interfaces)
    }
  }
  function getLZEndpoint() external view returns (address lZEndpoint) {
    assembly {
      lZEndpoint := sload(_lZEndpointSlot)
    }
  }
  function setLZEndpoint(address lZEndpoint) external onlyAdmin {
    assembly {
      sstore(_lZEndpointSlot, lZEndpoint)
    }
  }
  function getOperator() external view returns (address operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  function setOperator(address operator) external onlyAdmin {
    assembly {
      sstore(_operatorSlot, operator)
    }
  }
  function _bridge() private view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function _interfaces() private view returns (HolographInterfacesInterface interfaces) {
    assembly {
      interfaces := sload(_interfacesSlot)
    }
  }
  function _operator() private view returns (HolographOperatorInterface operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  receive() external payable {
    revert();
  }
  fallback() external payable {
    revert();
  }
  function getBaseGas() external view returns (uint256 baseGas) {
    assembly {
      baseGas := sload(_baseGasSlot)
    }
  }
  function setBaseGas(uint256 baseGas) external onlyAdmin {
    assembly {
      sstore(_baseGasSlot, baseGas)
    }
  }
  function _baseGas() private view returns (uint256 baseGas) {
    assembly {
      baseGas := sload(_baseGasSlot)
    }
  }
  function getGasPerByte() external view returns (uint256 gasPerByte) {
    assembly {
      gasPerByte := sload(_gasPerByteSlot)
    }
  }
  function setGasPerByte(uint256 gasPerByte) external onlyAdmin {
    assembly {
      sstore(_gasPerByteSlot, gasPerByte)
    }
  }
  function _gasPerByte() private view returns (uint256 gasPerByte) {
    assembly {
      gasPerByte := sload(_gasPerByteSlot)
    }
  }
}
contract CxipERC721Proxy is Admin, Initializable {
  bytes32 constant _contractTypeSlot = 0x0b671eb65810897366dd82c4cbb7d9dff8beda8484194956e81e89b8a361d9c7;
  bytes32 constant _registrySlot = 0xce8e75d5c5227ce29a4ee170160bb296e5dea6934b80a9bd723f7ef1e7c850e7;
  constructor() {}
  function init(bytes memory data) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (bytes32 contractType, address registry, bytes memory initCode) = abi.decode(data, (bytes32, address, bytes));
    assembly {
      sstore(_contractTypeSlot, contractType)
      sstore(_registrySlot, registry)
    }
    (bool success, bytes memory returnData) = getCxipERC721Source().delegatecall(
      abi.encodeWithSignature("init(bytes)", initCode)
    );
    bytes4 selector = abi.decode(returnData, (bytes4));
    require(success && selector == InitializableInterface.init.selector, "initialization failed");
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getCxipERC721Source() public view returns (address) {
    HolographRegistryInterface registry;
    bytes32 contractType;
    assembly {
      registry := sload(_registrySlot)
      contractType := sload(_contractTypeSlot)
    }
    return registry.getContractTypeAddress(contractType);
  }
  receive() external payable {}
  fallback() external payable {
    address cxipErc721Source = getCxipERC721Source();
    assembly {
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), cxipErc721Source, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract HolographBridgeProxy is Admin, Initializable {
  bytes32 constant _bridgeSlot = 0xeb87cbb21687feb327e3d58c6c16d552231d12c7a0e8115042a4165fac8a77f9;
  constructor() {}
  function init(bytes memory data) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address bridge, bytes memory initCode) = abi.decode(data, (address, bytes));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_bridgeSlot, bridge)
    }
    (bool success, bytes memory returnData) = bridge.delegatecall(abi.encodeWithSignature("init(bytes)", initCode));
    bytes4 selector = abi.decode(returnData, (bytes4));
    require(success && selector == InitializableInterface.init.selector, "initialization failed");
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getBridge() external view returns (address bridge) {
    assembly {
      bridge := sload(_bridgeSlot)
    }
  }
  function setBridge(address bridge) external onlyAdmin {
    assembly {
      sstore(_bridgeSlot, bridge)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      let bridge := sload(_bridgeSlot)
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), bridge, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract HolographFactoryProxy is Admin, Initializable {
  bytes32 constant _factorySlot = 0xa49f20855ba576e09d13c8041c8039fa655356ea27f6c40f1ec46a4301cd5b23;
  constructor() {}
  function init(bytes memory data) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address factory, bytes memory initCode) = abi.decode(data, (address, bytes));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_factorySlot, factory)
    }
    (bool success, bytes memory returnData) = factory.delegatecall(abi.encodeWithSignature("init(bytes)", initCode));
    bytes4 selector = abi.decode(returnData, (bytes4));
    require(success && selector == InitializableInterface.init.selector, "initialization failed");
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getFactory() external view returns (address factory) {
    assembly {
      factory := sload(_factorySlot)
    }
  }
  function setFactory(address factory) external onlyAdmin {
    assembly {
      sstore(_factorySlot, factory)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      let factory := sload(_factorySlot)
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), factory, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract HolographOperatorProxy is Admin, Initializable {
  bytes32 constant _operatorSlot = 0x7caba557ad34138fa3b7e43fb574e0e6cc10481c3073e0dffbc560db81b5c60f;
  constructor() {}
  function init(bytes memory data) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address operator, bytes memory initCode) = abi.decode(data, (address, bytes));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_operatorSlot, operator)
    }
    (bool success, bytes memory returnData) = operator.delegatecall(abi.encodeWithSignature("init(bytes)", initCode));
    bytes4 selector = abi.decode(returnData, (bytes4));
    require(success && selector == InitializableInterface.init.selector, "initialization failed");
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getOperator() external view returns (address operator) {
    assembly {
      operator := sload(_operatorSlot)
    }
  }
  function setOperator(address operator) external onlyAdmin {
    assembly {
      sstore(_operatorSlot, operator)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      let operator := sload(_operatorSlot)
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), operator, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract HolographRegistryProxy is Admin, Initializable {
  bytes32 constant _registrySlot = 0xce8e75d5c5227ce29a4ee170160bb296e5dea6934b80a9bd723f7ef1e7c850e7;
  constructor() {}
  function init(bytes memory data) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address registry, bytes memory initCode) = abi.decode(data, (address, bytes));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_registrySlot, registry)
    }
    (bool success, bytes memory returnData) = registry.delegatecall(abi.encodeWithSignature("init(bytes)", initCode));
    bytes4 selector = abi.decode(returnData, (bytes4));
    require(success && selector == InitializableInterface.init.selector, "initialization failed");
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getRegistry() external view returns (address registry) {
    assembly {
      registry := sload(_registrySlot)
    }
  }
  function setRegistry(address registry) external onlyAdmin {
    assembly {
      sstore(_registrySlot, registry)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      let registry := sload(_registrySlot)
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), registry, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract HolographTreasuryProxy is Admin, Initializable {
  bytes32 constant _treasurySlot = 0x4215e7a38d75164ca078bbd61d0992cdeb1ba16f3b3ead5944966d3e4080e8b6;
  constructor() {}
  function init(bytes memory data) external override returns (bytes4) {
    require(!_isInitialized(), "HOLOGRAPH: already initialized");
    (address treasury, bytes memory initCode) = abi.decode(data, (address, bytes));
    assembly {
      sstore(_adminSlot, origin())
      sstore(_treasurySlot, treasury)
    }
    (bool success, bytes memory returnData) = treasury.delegatecall(abi.encodeWithSignature("init(bytes)", initCode));
    bytes4 selector = abi.decode(returnData, (bytes4));
    require(success && selector == InitializableInterface.init.selector, "initialization failed");
    _setInitialized();
    return InitializableInterface.init.selector;
  }
  function getTreasury() external view returns (address treasury) {
    assembly {
      treasury := sload(_treasurySlot)
    }
  }
  function setTreasury(address treasury) external onlyAdmin {
    assembly {
      sstore(_treasurySlot, treasury)
    }
  }
  receive() external payable {}
  fallback() external payable {
    assembly {
      let treasury := sload(_treasurySlot)
      calldatacopy(0, 0, calldatasize())
      let result := delegatecall(gas(), treasury, 0, calldatasize(), 0, 0)
      returndatacopy(0, 0, returndatasize())
      switch result
      case 0 {
        revert(0, returndatasize())
      }
      default {
        return(0, returndatasize())
      }
    }
  }
}
contract CxipERC721 is ERC721H {
  uint224 private _currentTokenId;
  TokenUriType private _uriType;
  mapping(uint256 => TokenUriType) private _tokenUriType;
  mapping(uint256 => mapping(TokenUriType => string)) private _tokenURIs;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    _uriType = TokenUriType.IPFS;
    address owner = abi.decode(initPayload, (address));
    _setOwner(owner);
    return _init(initPayload);
  }
  function tokenURI(uint256 _tokenId) external view onlyHolographer returns (string memory) {
    TokenUriType uriType = _tokenUriType[_tokenId];
    if (uriType == TokenUriType.UNDEFINED) {
      uriType = _uriType;
    }
    return
      string(
        abi.encodePacked(
          HolographInterfacesInterface(
            HolographInterface(HolographerInterface(holographer()).getHolograph()).getInterfaces()
          ).getUriPrepend(uriType),
          _tokenURIs[_tokenId][uriType]
        )
      );
  }
  function cxipMint(
    uint224 tokenId,
    TokenUriType uriType,
    string calldata tokenUri
  ) external onlyHolographer onlyOwner {
    HolographERC721Interface H721 = HolographERC721Interface(holographer());
    uint256 chainPrepend = H721.sourceGetChainPrepend();
    if (tokenId == 0) {
      _currentTokenId += 1;
      while (
        H721.exists(chainPrepend + uint256(_currentTokenId)) || H721.burned(chainPrepend + uint256(_currentTokenId))
      ) {
        _currentTokenId += 1;
      }
      tokenId = _currentTokenId;
    }
    H721.sourceMint(msgSender(), tokenId);
    uint256 id = chainPrepend + uint256(tokenId);
    if (uriType == TokenUriType.UNDEFINED) {
      uriType = _uriType;
    }
    _tokenUriType[id] = uriType;
    _tokenURIs[id][uriType] = tokenUri;
  }
  function bridgeIn(
    uint32, 
    address, 
    address, 
    uint256 _tokenId,
    bytes calldata _data
  ) external onlyHolographer returns (bool) {
    (TokenUriType uriType, string memory tokenUri) = abi.decode(_data, (TokenUriType, string));
    _tokenUriType[_tokenId] = uriType;
    _tokenURIs[_tokenId][uriType] = tokenUri;
    return true;
  }
  function bridgeOut(
    uint32, 
    address, 
    address, 
    uint256 _tokenId
  ) external view onlyHolographer returns (bytes memory _data) {
    TokenUriType uriType = _tokenUriType[_tokenId];
    if (uriType == TokenUriType.UNDEFINED) {
      uriType = _uriType;
    }
    _data = abi.encode(uriType, _tokenURIs[_tokenId][uriType]);
  }
  function afterBurn(
    address, 
    uint256 _tokenId
  ) external onlyHolographer returns (bool) {
    TokenUriType uriType = _tokenUriType[_tokenId];
    if (uriType == TokenUriType.UNDEFINED) {
      uriType = _uriType;
    }
    delete _tokenURIs[_tokenId][uriType];
    return true;
  }
}
contract HolographUtilityToken is ERC20H {
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    address contractOwner = abi.decode(initPayload, (address));
    _setOwner(contractOwner);
    HolographERC20Interface(msg.sender).sourceMint(contractOwner, 10000000 * (10**18));
    return _init(initPayload);
  }
}
contract SampleERC20 is StrictERC20H {
  mapping(address => bytes32) private _walletSalts;
  bool private _dummy;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    address contractOwner = abi.decode(initPayload, (address));
    _setOwner(contractOwner);
    return _init(initPayload);
  }
  function mint(address to, uint256 amount) external onlyHolographer onlyOwner {
    HolographERC20Interface(holographer()).sourceMint(to, amount);
    if (_walletSalts[to] == bytes32(0)) {
      _walletSalts[to] = keccak256(
        abi.encodePacked(to, amount, block.timestamp, block.number, blockhash(block.number - 1))
      );
    }
  }
  function bridgeIn(
    uint32, 
    address, 
    address _to,
    uint256, 
    bytes calldata _data
  ) external override onlyHolographer returns (bool) {
    bytes32 salt = abi.decode(_data, (bytes32));
    _walletSalts[_to] = salt;
    return true;
  }
  function bridgeOut(
    uint32, 
    address, 
    address _to,
    uint256 
  ) external override onlyHolographer returns (bytes memory _data) {
    _dummy = false;
    _data = abi.encode(_walletSalts[_to]);
  }
}
contract SampleERC721 is StrictERC721H {
  mapping(uint256 => string) private _tokenURIs;
  uint224 private _currentTokenId;
  bool private _dummy;
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    address contractOwner = abi.decode(initPayload, (address));
    _setOwner(contractOwner);
    return _init(initPayload);
  }
  function tokenURI(uint256 _tokenId) external view onlyHolographer returns (string memory) {
    return _tokenURIs[_tokenId];
  }
  function mint(
    address to,
    uint224 tokenId,
    string calldata URI
  ) external onlyHolographer onlyOwner {
    HolographERC721Interface H721 = HolographERC721Interface(holographer());
    if (tokenId == 0) {
      _currentTokenId += 1;
      while (H721.exists(uint256(_currentTokenId)) || H721.burned(uint256(_currentTokenId))) {
        _currentTokenId += 1;
      }
      tokenId = _currentTokenId;
    }
    H721.sourceMint(to, tokenId);
    uint256 id = H721.sourceGetChainPrepend() + uint256(tokenId);
    _tokenURIs[id] = URI;
  }
  function bridgeIn(
    uint32, 
    address, 
    address, 
    uint256 _tokenId,
    bytes calldata _data
  ) external override onlyHolographer returns (bool) {
    string memory URI = abi.decode(_data, (string));
    _tokenURIs[_tokenId] = URI;
    return true;
  }
  function bridgeOut(
    uint32, 
    address, 
    address, 
    uint256 _tokenId
  ) external override onlyHolographer returns (bytes memory _data) {
    _dummy = false;
    _data = abi.encode(_tokenURIs[_tokenId]);
  }
  function afterBurn(
    address, 
    uint256 _tokenId
  ) external override onlyHolographer returns (bool) {
    delete _tokenURIs[_tokenId];
    return true;
  }
}
contract hToken is ERC20H {
  uint16 private _feeBp; 
  mapping(address => bool) private _supportedWrappers;
  event Deposit(address indexed from, uint256 amount);
  event TokenDeposit(address indexed token, address indexed from, uint256 amount);
  event Withdrawal(address indexed to, uint256 amount);
  event TokenWithdrawal(address indexed token, address indexed to, uint256 amount);
  constructor() {}
  function init(bytes memory initPayload) external override returns (bytes4) {
    (address contractOwner, uint16 fee) = abi.decode(initPayload, (address, uint16));
    _setOwner(contractOwner);
    _feeBp = fee;
    return _init(initPayload);
  }
  function holographNativeToken(address recipient) external payable onlyHolographer {
    require(
      (HolographerInterface(holographer()).getOriginChain() ==
        HolographInterface(HolographerInterface(holographer()).getHolograph()).getHolographChainId()),
      "hToken: not native token"
    );
    require(msg.value > 0, "hToken: no value received");
    address sender = msgSender();
    if (recipient == address(0)) {
      recipient = sender;
    }
    HolographERC20Interface(holographer()).sourceMint(recipient, msg.value);
    emit Deposit(sender, msg.value);
  }
  function extractNativeToken(address payable recipient, uint256 amount) external onlyHolographer {
    address sender = msgSender();
    require(ERC20(address(this)).balanceOf(sender) >= amount, "hToken: not enough hToken(s)");
    require(
      (HolographerInterface(holographer()).getOriginChain() ==
        HolographInterface(HolographerInterface(holographer()).getHolograph()).getHolographChainId()),
      "hToken: not on native chain"
    );
    require(address(this).balance >= amount, "hToken: not enough native tokens");
    HolographERC20Interface(holographer()).sourceBurn(sender, amount);
    uint256 fee = (amount / 10000) * _feeBp;
    amount = amount - fee;
    recipient.transfer(amount);
    emit Withdrawal(recipient, amount);
  }
  function holographWrappedToken(
    address token,
    address recipient,
    uint256 amount
  ) external onlyHolographer {
    require(_supportedWrappers[token], "hToken: unsupported token type");
    ERC20 erc20 = ERC20(token);
    address sender = msgSender();
    require(erc20.allowance(sender, address(this)) >= amount, "hToken: allowance too low");
    uint256 previousBalance = erc20.balanceOf(address(this));
    require(erc20.transferFrom(sender, address(this), amount), "hToken: ERC20 transfer failed");
    uint256 currentBalance = erc20.balanceOf(address(this));
    uint256 difference = currentBalance - previousBalance;
    require(difference >= 0, "hToken: no tokens transferred");
    if (difference < amount) {
      amount = difference;
    }
    if (recipient == address(0)) {
      recipient = sender;
    }
    HolographERC20Interface(holographer()).sourceMint(recipient, amount);
    emit TokenDeposit(token, sender, amount);
  }
  function extractWrappedToken(
    address token,
    address payable recipient,
    uint256 amount
  ) external onlyHolographer {
    require(_supportedWrappers[token], "hToken: unsupported token type");
    address sender = msgSender();
    require(ERC20(address(this)).balanceOf(sender) >= amount, "hToken: not enough hToken(s)");
    ERC20 erc20 = ERC20(token);
    uint256 previousBalance = erc20.balanceOf(address(this));
    require(previousBalance >= amount, "hToken: not enough ERC20 tokens");
    if (recipient == address(0)) {
      recipient = payable(sender);
    }
    uint256 fee = (amount / 10000) * _feeBp;
    uint256 adjustedAmount = amount - fee;
    erc20.transfer(recipient, adjustedAmount);
    uint256 currentBalance = erc20.balanceOf(address(this));
    uint256 difference = currentBalance - previousBalance;
    require(difference == adjustedAmount, "hToken: incorrect new balance");
    HolographERC20Interface(holographer()).sourceBurn(sender, amount);
    emit TokenWithdrawal(token, recipient, adjustedAmount);
  }
  function availableNativeTokens() external view onlyHolographer returns (uint256) {
    if (
      HolographerInterface(holographer()).getOriginChain() ==
      HolographInterface(HolographerInterface(holographer()).getHolograph()).getHolographChainId()
    ) {
      return address(this).balance;
    } else {
      return 0;
    }
  }
  function availableWrappedTokens(address token) external view onlyHolographer returns (uint256) {
    require(_supportedWrappers[token], "hToken: unsupported token type");
    return ERC20(token).balanceOf(address(this));
  }
  function updateSupportedWrapper(address token, bool supported) external onlyHolographer onlyOwner {
    _supportedWrappers[token] = supported;
  }
}
interface ERC1271 {
  function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}
library Bytes {
  function getBoolean(uint192 _packedBools, uint192 _boolNumber) internal pure returns (bool) {
    uint192 flag = (_packedBools >> _boolNumber) & uint192(1);
    return (flag == 1 ? true : false);
  }
  function setBoolean(
    uint192 _packedBools,
    uint192 _boolNumber,
    bool _value
  ) internal pure returns (uint192) {
    if (_value) {
      return _packedBools | (uint192(1) << _boolNumber);
    } else {
      return _packedBools & ~(uint192(1) << _boolNumber);
    }
  }
  function slice(
    bytes memory _bytes,
    uint256 _start,
    uint256 _length
  ) internal pure returns (bytes memory) {
    require(_length + 31 >= _length, "slice_overflow");
    require(_bytes.length >= _start + _length, "slice_outOfBounds");
    bytes memory tempBytes;
    assembly {
      switch iszero(_length)
      case 0 {
        tempBytes := mload(0x40)
        let lengthmod := and(_length, 31)
        let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
        let end := add(mc, _length)
        for {
          let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
        } lt(mc, end) {
          mc := add(mc, 0x20)
          cc := add(cc, 0x20)
        } {
          mstore(mc, mload(cc))
        }
        mstore(tempBytes, _length)
        mstore(0x40, and(add(mc, 31), not(31)))
      }
      default {
        tempBytes := mload(0x40)
        mstore(tempBytes, 0)
        mstore(0x40, add(tempBytes, 0x20))
      }
    }
    return tempBytes;
  }
  function trim(bytes32 source) internal pure returns (bytes memory) {
    uint256 temp = uint256(source);
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return slice(abi.encodePacked(source), 32 - length, length);
  }
}
contract MockExternalCall {
  function callExternalFn(address contractAddress, bytes calldata encodedSignature) public {
    (bool success, ) = address(contractAddress).call(encodedSignature);
    require(success, "Failed");
  }
}