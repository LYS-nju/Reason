pragma solidity 0.8.15;
abstract contract Adminable {
    address payable public admin;
    address payable public pendingAdmin;
    address payable public developer;
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    constructor() {
        developer = payable(msg.sender);
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "caller must be admin");
        _;
    }
    modifier onlyAdminOrDeveloper() {
        require(msg.sender == admin || msg.sender == developer, "caller must be admin or developer");
        _;
    }
    function setPendingAdmin(address payable newPendingAdmin) external virtual onlyAdmin {
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }
    function acceptAdmin() external virtual {
        require(msg.sender == pendingAdmin, "only pendingAdmin can accept admin");
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = payable(oldPendingAdmin);
        pendingAdmin = payable(0);
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }
}