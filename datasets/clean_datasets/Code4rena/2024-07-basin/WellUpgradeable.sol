pragma solidity ^0.8.20;
import {Well} from "src/Well.sol";
import {UUPSUpgradeable} from "ozu/proxy/utils/UUPSUpgradeable.sol";
import {OwnableUpgradeable} from "ozu/access/OwnableUpgradeable.sol";
import {IERC20, SafeERC20} from "oz/token/ERC20/utils/SafeERC20.sol";
import {IAquifer} from "src/interfaces/IAquifer.sol";
contract WellUpgradeable is Well, UUPSUpgradeable, OwnableUpgradeable {
    address private immutable ___self = address(this);
    modifier notDelegatedOrIsMinimalProxy() {
        if (address(this) != ___self) {
            address aquifer = aquifer();
            address wellImplmentation = IAquifer(aquifer).wellImplementation(address(this));
            require(wellImplmentation == ___self, "Function must be called by a Well bored by an aquifer");
        } else {
            revert("UUPSUpgradeable: must not be called through delegatecall");
        }
        _;
    }
    function init(string memory _name, string memory _symbol) external override reinitializer(2) {
        __ERC20Permit_init(_name);
        __ERC20_init(_name, _symbol);
        __ReentrancyGuard_init();
        __UUPSUpgradeable_init();
        __Ownable_init();
        IERC20[] memory _tokens = tokens();
        uint256 tokensLength = _tokens.length;
        for (uint256 i; i < tokensLength - 1; ++i) {
            for (uint256 j = i + 1; j < tokensLength; ++j) {
                if (_tokens[i] == _tokens[j]) {
                    revert DuplicateTokens(_tokens[i]);
                }
            }
        }
    }
    function initNoWellToken() external initializer {}
    function _authorizeUpgrade(address newImplmentation) internal view override {
        require(address(this) != ___self, "Function must be called through delegatecall");
        address aquifer = aquifer();
        address activeProxy = IAquifer(aquifer).wellImplementation(_getImplementation());
        require(activeProxy == ___self, "Function must be called through active proxy bored by an aquifer");
        require(
            IAquifer(aquifer).wellImplementation(newImplmentation) != address(0),
            "New implementation must be a well implmentation"
        );
        require(
            UUPSUpgradeable(newImplmentation).proxiableUUID() == _IMPLEMENTATION_SLOT,
            "New implementation must be a valid ERC-1967 implmentation"
        );
    }
    function upgradeTo(address newImplementation) public override {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, new bytes(0), false);
    }
    function upgradeToAndCall(address newImplementation, bytes memory data) public payable override {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallUUPS(newImplementation, data, true);
    }
    function proxiableUUID() external view override notDelegatedOrIsMinimalProxy returns (bytes32) {
        return _IMPLEMENTATION_SLOT;
    }
    function getImplementation() external view returns (address) {
        return _getImplementation();
    }
    function getVersion() external pure virtual returns (uint256) {
        return 1;
    }
    function getInitializerVersion() external view returns (uint256) {
        return _getInitializedVersion();
    }
}