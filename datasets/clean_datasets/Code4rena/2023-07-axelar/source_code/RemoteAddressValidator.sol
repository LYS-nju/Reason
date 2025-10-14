pragma solidity ^0.8.9;
interface IOwnable {
    error NotOwner();
    error InvalidOwner();
    event OwnershipTransferStarted(address indexed newOwner);
    event OwnershipTransferred(address indexed newOwner);
    function owner() external view returns (address);
    function pendingOwner() external view returns (address);
    function transferOwnership(address newOwner) external;
    function proposeOwnership(address newOwner) external;
    function acceptOwnership() external;
}
interface IUpgradable is IOwnable {
    error InvalidCodeHash();
    error InvalidImplementation();
    error SetupFailed();
    error NotProxy();
    event Upgraded(address indexed newImplementation);
    function implementation() external view returns (address);
    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata params
    ) external;
    function setup(bytes calldata data) external;
    function contractId() external pure returns (bytes32);
}
abstract contract Ownable is IOwnable {
    bytes32 internal constant _OWNER_SLOT = 0x02016836a56b71f0d02689e69e326f4f4c1b9057164ef592671cf0d37c8040c0;
    bytes32 internal constant _OWNERSHIP_TRANSFER_SLOT = 0x9855384122b55936fbfb8ca5120e63c6537a1ac40caf6ae33502b3c5da8c87d1;
    modifier onlyOwner() {
        if (owner() != msg.sender) revert NotOwner();
        _;
    }
    function owner() public view returns (address owner_) {
        assembly {
            owner_ := sload(_OWNER_SLOT)
        }
    }
    function pendingOwner() public view returns (address owner_) {
        assembly {
            owner_ := sload(_OWNERSHIP_TRANSFER_SLOT)
        }
    }
    function transferOwnership(address newOwner) external virtual onlyOwner {
        emit OwnershipTransferred(newOwner);
        assembly {
            sstore(_OWNER_SLOT, newOwner)
            sstore(_OWNERSHIP_TRANSFER_SLOT, 0)
        }
    }
    function proposeOwnership(address newOwner) external virtual onlyOwner {
        emit OwnershipTransferStarted(newOwner);
        assembly {
            sstore(_OWNERSHIP_TRANSFER_SLOT, newOwner)
        }
    }
    function acceptOwnership() external virtual {
        address newOwner = pendingOwner();
        if (newOwner != msg.sender) revert InvalidOwner();
        emit OwnershipTransferred(newOwner);
        assembly {
            sstore(_OWNERSHIP_TRANSFER_SLOT, 0)
            sstore(_OWNER_SLOT, newOwner)
        }
    }
}
abstract contract Upgradable is Ownable, IUpgradable {
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
    address internal immutable implementationAddress;
    constructor() {
        implementationAddress = address(this);
    }
    modifier onlyProxy() {
        if (address(this) == implementationAddress) revert NotProxy();
        _;
    }
    function implementation() public view returns (address implementation_) {
        assembly {
            implementation_ := sload(_IMPLEMENTATION_SLOT)
        }
    }
    function upgrade(
        address newImplementation,
        bytes32 newImplementationCodeHash,
        bytes calldata params
    ) external override onlyOwner {
        if (IUpgradable(newImplementation).contractId() != IUpgradable(this).contractId()) revert InvalidImplementation();
        if (newImplementationCodeHash != newImplementation.codehash) revert InvalidCodeHash();
        if (params.length > 0) {
            (bool success, ) = newImplementation.delegatecall(abi.encodeWithSelector(this.setup.selector, params));
            if (!success) revert SetupFailed();
        }
        emit Upgraded(newImplementation);
        assembly {
            sstore(_IMPLEMENTATION_SLOT, newImplementation)
        }
    }
    function setup(bytes calldata data) external override onlyProxy {
        _setup(data);
    }
    function _setup(bytes calldata data) internal virtual {}
}
library StringToAddress {
    error InvalidAddressString();
    function toAddress(string memory addressString) internal pure returns (address) {
        bytes memory stringBytes = bytes(addressString);
        uint160 addressNumber = 0;
        uint8 stringByte;
        if (stringBytes.length != 42 || stringBytes[0] != '0' || stringBytes[1] != 'x') revert InvalidAddressString();
        for (uint256 i = 2; i < 42; ++i) {
            stringByte = uint8(stringBytes[i]);
            if ((stringByte >= 97) && (stringByte <= 102)) stringByte -= 87;
            else if ((stringByte >= 65) && (stringByte <= 70)) stringByte -= 55;
            else if ((stringByte >= 48) && (stringByte <= 57)) stringByte -= 48;
            else revert InvalidAddressString();
            addressNumber |= uint160(uint256(stringByte) << ((41 - i) << 2));
        }
        return address(addressNumber);
    }
}
library AddressToString {
    function toString(address addr) internal pure returns (string memory) {
        bytes memory addressBytes = abi.encodePacked(addr);
        uint256 length = addressBytes.length;
        bytes memory characters = '0123456789abcdef';
        bytes memory stringBytes = new bytes(2 + addressBytes.length * 2);
        stringBytes[0] = '0';
        stringBytes[1] = 'x';
        for (uint256 i; i < length; ++i) {
            stringBytes[2 + i * 2] = characters[uint8(addressBytes[i] >> 4)];
            stringBytes[3 + i * 2] = characters[uint8(addressBytes[i] & 0x0f)];
        }
        return string(stringBytes);
    }
}
interface IRemoteAddressValidator {
    error ZeroAddress();
    error LengthMismatch();
    error ZeroStringLength();
    event TrustedAddressAdded(string souceChain, string sourceAddress);
    event TrustedAddressRemoved(string souceChain);
    event GatewaySupportedChainAdded(string chain);
    event GatewaySupportedChainRemoved(string chain);
    function validateSender(string calldata sourceChain, string calldata sourceAddress) external view returns (bool);
    function addTrustedAddress(string memory sourceChain, string memory sourceAddress) external;
    function removeTrustedAddress(string calldata sourceChain) external;
    function getRemoteAddress(string calldata chainName) external view returns (string memory remoteAddress);
    function supportedByGateway(string calldata chainName) external view returns (bool);
    function addGatewaySupportedChains(string[] calldata chainNames) external;
    function removeGatewaySupportedChains(string[] calldata chainNames) external;
}
contract RemoteAddressValidator is IRemoteAddressValidator, Upgradable {
    using AddressToString for address;
    mapping(string => bytes32) public remoteAddressHashes;
    mapping(string => string) public remoteAddresses;
    address public immutable interchainTokenServiceAddress;
    bytes32 public immutable interchainTokenServiceAddressHash;
    mapping(string => bool) public supportedByGateway;
    bytes32 private constant CONTRACT_ID = keccak256('remote-address-validator');
    constructor(address _interchainTokenServiceAddress) {
        if (_interchainTokenServiceAddress == address(0)) revert ZeroAddress();
        interchainTokenServiceAddress = _interchainTokenServiceAddress;
        interchainTokenServiceAddressHash = keccak256(bytes(_lowerCase(interchainTokenServiceAddress.toString())));
    }
    function contractId() external pure returns (bytes32) {
        return CONTRACT_ID;
    }
    function _setup(bytes calldata params) internal override {
        (string[] memory trustedChainNames, string[] memory trustedAddresses) = abi.decode(params, (string[], string[]));
        uint256 length = trustedChainNames.length;
        if (length != trustedAddresses.length) revert LengthMismatch();
        for (uint256 i; i < length; ++i) {
            addTrustedAddress(trustedChainNames[i], trustedAddresses[i]);
        }
    }
    function _lowerCase(string memory s) internal pure returns (string memory) {
        uint256 length = bytes(s).length;
        for (uint256 i; i < length; i++) {
            uint8 b = uint8(bytes(s)[i]);
            if ((b >= 65) && (b <= 70)) bytes(s)[i] = bytes1(b + uint8(32));
        }
        return s;
    }
    function validateSender(string calldata sourceChain, string calldata sourceAddress) external view returns (bool) {
        string memory sourceAddressLC = _lowerCase(sourceAddress);
        bytes32 sourceAddressHash = keccak256(bytes(sourceAddressLC));
        if (sourceAddressHash == interchainTokenServiceAddressHash) {
            return true;
        }
        return sourceAddressHash == remoteAddressHashes[sourceChain];
    }
    function addTrustedAddress(string memory chain, string memory addr) public onlyOwner {
        if (bytes(chain).length == 0) revert ZeroStringLength();
        if (bytes(addr).length == 0) revert ZeroStringLength();
        remoteAddressHashes[chain] = keccak256(bytes(_lowerCase(addr)));
        remoteAddresses[chain] = addr;
        emit TrustedAddressAdded(chain, addr);
    }
    function removeTrustedAddress(string calldata chain) external onlyOwner {
        if (bytes(chain).length == 0) revert ZeroStringLength();
        remoteAddressHashes[chain] = bytes32(0);
        remoteAddresses[chain] = '';
        emit TrustedAddressRemoved(chain);
    }
    function addGatewaySupportedChains(string[] calldata chainNames) external onlyOwner {
        uint256 length = chainNames.length;
        for (uint256 i; i < length; ++i) {
            string calldata chainName = chainNames[i];
            supportedByGateway[chainName] = true;
            emit GatewaySupportedChainAdded(chainName);
        }
    }
    function removeGatewaySupportedChains(string[] calldata chainNames) external onlyOwner {
        uint256 length = chainNames.length;
        for (uint256 i; i < length; ++i) {
            string calldata chainName = chainNames[i];
            supportedByGateway[chainName] = false;
            emit GatewaySupportedChainRemoved(chainName);
        }
    }
    function getRemoteAddress(string calldata chainName) external view returns (string memory remoteAddress) {
        remoteAddress = remoteAddresses[chainName];
        if (bytes(remoteAddress).length == 0) {
            remoteAddress = interchainTokenServiceAddress.toString();
        }
    }
}