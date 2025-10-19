pragma solidity >=0.8.4;
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./interfaces/IMIMOProxy.sol";
import "./interfaces/IMIMOProxyFactory.sol";
import "./MIMOProxy.sol";
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