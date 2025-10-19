pragma solidity >= 0.8.0;
import "./interfaces/vault/IJoinFactory.sol";
import "./Join.sol";
contract JoinFactory is IJoinFactory {
  bytes32 public constant override JOIN_BYTECODE_HASH = keccak256(type(Join).creationCode);
  address private _nextAsset;
  function isContract(address account) internal view returns (bool) {
      uint256 size;
      assembly { size := extcodesize(account) }
      return size > 0;
  }
  function calculateJoinAddress(address asset) external view override returns (address) {
    return _calculateJoinAddress(asset);
  }
  function _calculateJoinAddress(address asset)
    private view returns (address calculatedAddress)
  {
    calculatedAddress = address(uint160(uint256(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(this),
      keccak256(abi.encodePacked(asset)),
      JOIN_BYTECODE_HASH
    )))));
  }
  function getJoin(address asset) external view override returns (address join) {
    join = _calculateJoinAddress(asset);
    if(!isContract(join)) {
      join = address(0);
    }
  }
  function createJoin(address asset) external override returns (address) {
    _nextAsset = asset;
    Join join = new Join{salt: keccak256(abi.encodePacked(asset))}();
    _nextAsset = address(0);
    join.grantRole(join.ROOT(), msg.sender);
    join.renounceRole(join.ROOT(), address(this));
    emit JoinCreated(asset, address(join));
    return address(join);
  }
  function nextAsset() external view override returns (address) {
    return _nextAsset;
  }
}