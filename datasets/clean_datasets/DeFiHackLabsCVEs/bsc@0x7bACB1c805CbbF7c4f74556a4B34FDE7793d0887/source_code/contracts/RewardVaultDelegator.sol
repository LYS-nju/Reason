pragma solidity 0.8.15;
import "./Adminable.sol";
import "./DelegatorInterface.sol";
contract RewardVaultDelegator is DelegatorInterface, Adminable {
    constructor(
        address payable _admin,
        address _distributor,
        uint64 _defaultExpireDuration,
        address implementation_){
        admin = payable(msg.sender);
        delegateTo(implementation_, abi.encodeWithSignature("initialize(address,address,uint64)",
            _admin,
            _distributor,
            _defaultExpireDuration
            ));
        implementation = implementation_;
        admin = _admin;
    }
    function setImplementation(address implementation_) public override onlyAdmin {
        address oldImplementation = implementation;
        implementation = implementation_;
        emit NewImplementation(oldImplementation, implementation);
    }
}