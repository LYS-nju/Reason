pragma solidity 0.8.13;
import "../abstract/Initializable.sol";
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