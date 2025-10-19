pragma solidity 0.8.7;
import "./interfaces/IOwnership.sol";
import "./interfaces/IRegistry.sol";
contract Registry is IRegistry {
    event ExistenceSet(address indexed template, address indexed target);
    event NewMarketRegistered(address market);
    event FactorySet(address factory);
    event CDSSet(address indexed target, address cds);
    address public factory;
    mapping(address => address) cds; 
    mapping(address => bool) markets; 
    mapping(address => mapping(address => bool)) existence; 
    address[] allMarkets;
    IOwnership public ownership;
    modifier onlyOwner() {
        require(
            ownership.owner() == msg.sender,
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    constructor(address _ownership) {
        ownership = IOwnership(_ownership);
    }
    function setFactory(address _factory) external override onlyOwner {
        require(_factory != address(0), "ERROR: ZERO_ADDRESS");
        factory = _factory;
        emit FactorySet(_factory);
    }
    function supportMarket(address _market) external override {
        require(!markets[_market], "ERROR: ALREADY_REGISTERED");
        require(
            msg.sender == factory || msg.sender == ownership.owner(),
            "ERROR: UNAUTHORIZED_CALLER"
        );
        require(_market != address(0), "ERROR: ZERO_ADDRESS");
        allMarkets.push(_market);
        markets[_market] = true;
        emit NewMarketRegistered(_market);
    }
    function setExistence(address _template, address _target)
        external
        override
    {
        require(
            msg.sender == factory || msg.sender == ownership.owner(),
            "ERROR: UNAUTHORIZED_CALLER"
        );
        existence[_template][_target] = true;
        emit ExistenceSet(_template, _target);
    }
    function setCDS(address _address, address _cds)
        external
        override
        onlyOwner
    {
        require(_cds != address(0), "ERROR: ZERO_ADDRESS");
        cds[_address] = _cds;
        emit CDSSet(_address, _cds);
    }
    function getCDS(address _address) external view override returns (address) {
        if (cds[_address] == address(0)) {
            return cds[address(0)];
        } else {
            return cds[_address];
        }
    }
    function confirmExistence(address _template, address _target)
        external
        view
        override
        returns (bool)
    {
        return existence[_template][_target];
    }
    function isListed(address _market) external view override returns (bool) {
        return markets[_market];
    }
    function getAllMarkets() external view returns (address[] memory) {
        return allMarkets;
    }
}