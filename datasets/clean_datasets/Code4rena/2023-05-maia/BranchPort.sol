pragma solidity ^0.8.0;
import {Ownable} from "solady/auth/Ownable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IPortStrategy} from "./interfaces/IPortStrategy.sol";
import {IBranchPort} from "./interfaces/IBranchPort.sol";
import {ERC20hTokenBranch} from "./token/ERC20hTokenBranch.sol";
contract BranchPort is Ownable, IBranchPort {
    using SafeTransferLib for address;
    address public coreBranchRouterAddress;
    mapping(address => bool) public isBridgeAgent;
    address[] public bridgeAgents;
    uint256 public bridgeAgentsLenght;
    mapping(address => bool) public isBridgeAgentFactory;
    address[] public bridgeAgentFactories;
    uint256 public bridgeAgentFactoriesLenght;
    mapping(address => bool) public isStrategyToken;
    address[] public strategyTokens;
    uint256 public strategyTokensLenght;
    mapping(address => uint256) public getStrategyTokenDebt;
    mapping(address => uint256) public getMinimumTokenReserveRatio;
    mapping(address => mapping(address => bool)) public isPortStrategy;
    address[] public portStrategies;
    uint256 public portStrategiesLenght;
    mapping(address => mapping(address => uint256)) public getPortStrategyTokenDebt;
    mapping(address => mapping(address => uint256)) public lastManaged;
    mapping(address => mapping(address => uint256)) public strategyDailyLimitAmount;
    mapping(address => mapping(address => uint256)) public strategyDailyLimitRemaining;
    uint256 internal constant DIVISIONER = 1e4;
    uint256 internal constant MIN_RESERVE_RATIO = 3e3;
    constructor(address _owner) {
        require(_owner != address(0), "Owner is zero address");
        _initializeOwner(_owner);
    }
    function initialize(address _coreBranchRouter, address _bridgeAgentFactory) external virtual onlyOwner {
        require(coreBranchRouterAddress == address(0), "Contract already initialized");
        require(!isBridgeAgentFactory[_bridgeAgentFactory], "Contract already initialized");
        require(_coreBranchRouter != address(0), "CoreBranchRouter is zero address");
        require(_bridgeAgentFactory != address(0), "BridgeAgentFactory is zero address");
        coreBranchRouterAddress = _coreBranchRouter;
        isBridgeAgentFactory[_bridgeAgentFactory] = true;
        bridgeAgentFactories.push(_bridgeAgentFactory);
        bridgeAgentFactoriesLenght++;
    }
    function renounceOwnership() public payable override onlyOwner {
        revert("Cannot renounce ownership");
    }
    function _excessReserves(address _token) internal view returns (uint256) {
        uint256 currBalance = ERC20(_token).balanceOf(address(this));
        uint256 minReserves = _minimumReserves(currBalance, _token);
        return currBalance > minReserves ? currBalance - minReserves : 0;
    }
    function _reservesLacking(address _token) internal view returns (uint256) {
        uint256 currBalance = ERC20(_token).balanceOf(address(this));
        uint256 minReserves = _minimumReserves(currBalance, _token);
        return currBalance < minReserves ? minReserves - currBalance : 0;
    }
    function _minimumReserves(uint256 _currBalance, address _token) internal view returns (uint256) {
        return ((_currBalance + getStrategyTokenDebt[_token]) * getMinimumTokenReserveRatio[_token]) / DIVISIONER;
    }
    function manage(address _token, uint256 _amount) external requiresPortStrategy(_token) {
        if (_amount > _excessReserves(_token)) revert InsufficientReserves();
        _checkTimeLimit(_token, _amount);
        getStrategyTokenDebt[_token] += _amount;
        getPortStrategyTokenDebt[msg.sender][_token] += _amount;
        _token.safeTransfer(msg.sender, _amount);
        emit DebtCreated(msg.sender, _token, _amount);
    }
    function replenishReserves(address _strategy, address _token, uint256 _amount) external lock {
        if (!isStrategyToken[_token]) revert UnrecognizedStrategyToken();
        if (!isPortStrategy[_strategy][_token]) revert UnrecognizedPortStrategy();
        uint256 reservesLacking = _reservesLacking(_token);
        uint256 amountToWithdraw = _amount < reservesLacking ? _amount : reservesLacking;
        IPortStrategy(_strategy).withdraw(address(this), _token, amountToWithdraw);
        getPortStrategyTokenDebt[_strategy][_token] -= amountToWithdraw;
        getStrategyTokenDebt[_token] -= amountToWithdraw;
        emit DebtRepaid(_strategy, _token, amountToWithdraw);
    }
    function _checkTimeLimit(address _token, uint256 _amount) internal {
        if (block.timestamp - lastManaged[msg.sender][_token] >= 1 days) {
            strategyDailyLimitRemaining[msg.sender][_token] = strategyDailyLimitAmount[msg.sender][_token];
        }
        strategyDailyLimitRemaining[msg.sender][_token] -= _amount;
        lastManaged[msg.sender][_token] = block.timestamp;
    }
    function withdraw(address _recipient, address _underlyingAddress, uint256 _deposit)
        external
        virtual
        requiresBridgeAgent
    {
        _underlyingAddress.safeTransfer(
            _recipient, _denormalizeDecimals(_deposit, ERC20(_underlyingAddress).decimals())
        );
    }
    function bridgeIn(address _recipient, address _localAddress, uint256 _amount)
        external
        virtual
        requiresBridgeAgent
    {
        ERC20hTokenBranch(_localAddress).mint(_recipient, _amount);
    }
    function bridgeInMultiple(address _recipient, address[] memory _localAddresses, uint256[] memory _amounts)
        external
        virtual
        requiresBridgeAgent
    {
        for (uint256 i = 0; i < _localAddresses.length;) {
            ERC20hTokenBranch(_localAddresses[i]).mint(_recipient, _amounts[i]);
            unchecked {
                ++i;
            }
        }
    }
    function bridgeOut(
        address _depositor,
        address _localAddress,
        address _underlyingAddress,
        uint256 _amount,
        uint256 _deposit
    ) external virtual requiresBridgeAgent {
        if (_amount - _deposit > 0) {
            _localAddress.safeTransferFrom(_depositor, address(this), _amount - _deposit);
            ERC20hTokenBranch(_localAddress).burn(_amount - _deposit);
        }
        if (_deposit > 0) {
            _underlyingAddress.safeTransferFrom(
                _depositor, address(this), _denormalizeDecimals(_deposit, ERC20(_underlyingAddress).decimals())
            );
        }
    }
    function bridgeOutMultiple(
        address _depositor,
        address[] memory _localAddresses,
        address[] memory _underlyingAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits
    ) external virtual requiresBridgeAgent {
        for (uint256 i = 0; i < _localAddresses.length;) {
            if (_deposits[i] > 0) {
                _underlyingAddresses[i].safeTransferFrom(
                    _depositor,
                    address(this),
                    _denormalizeDecimals(_deposits[i], ERC20(_underlyingAddresses[i]).decimals())
                );
            }
            if (_amounts[i] - _deposits[i] > 0) {
                _localAddresses[i].safeTransferFrom(_depositor, address(this), _amounts[i] - _deposits[i]);
                ERC20hTokenBranch(_localAddresses[i]).burn(_amounts[i] - _deposits[i]);
            }
            unchecked {
                i++;
            }
        }
    }
    function addBridgeAgent(address _bridgeAgent) external requiresBridgeAgentFactory {
        isBridgeAgent[_bridgeAgent] = true;
        bridgeAgents.push(_bridgeAgent);
        bridgeAgentsLenght++;
    }
    function setCoreRouter(address _newCoreRouter) external requiresCoreRouter {
        require(coreBranchRouterAddress != address(0), "CoreRouter address is zero");
        require(_newCoreRouter != address(0), "New CoreRouter address is zero");
        coreBranchRouterAddress = _newCoreRouter;
    }
    function addBridgeAgentFactory(address _newBridgeAgentFactory) external requiresCoreRouter {
        isBridgeAgentFactory[_newBridgeAgentFactory] = true;
        bridgeAgentFactories.push(_newBridgeAgentFactory);
        bridgeAgentFactoriesLenght++;
        emit BridgeAgentFactoryAdded(_newBridgeAgentFactory);
    }
    function toggleBridgeAgentFactory(address _newBridgeAgentFactory) external requiresCoreRouter {
        isBridgeAgentFactory[_newBridgeAgentFactory] = !isBridgeAgentFactory[_newBridgeAgentFactory];
        emit BridgeAgentFactoryToggled(_newBridgeAgentFactory);
    }
    function toggleBridgeAgent(address _bridgeAgent) external requiresCoreRouter {
        isBridgeAgent[_bridgeAgent] = !isBridgeAgent[_bridgeAgent];
        emit BridgeAgentToggled(_bridgeAgent);
    }
    function addStrategyToken(address _token, uint256 _minimumReservesRatio) external requiresCoreRouter {
        if (_minimumReservesRatio >= DIVISIONER) revert InvalidMinimumReservesRatio();
        strategyTokens.push(_token);
        strategyTokensLenght++;
        getMinimumTokenReserveRatio[_token] = _minimumReservesRatio;
        isStrategyToken[_token] = true;
        emit StrategyTokenAdded(_token, _minimumReservesRatio);
    }
    function toggleStrategyToken(address _token) external requiresCoreRouter {
        isStrategyToken[_token] = !isStrategyToken[_token];
        emit StrategyTokenToggled(_token);
    }
    function addPortStrategy(address _portStrategy, address _token, uint256 _dailyManagementLimit)
        external
        requiresCoreRouter
    {
        if (!isStrategyToken[_token]) revert UnrecognizedStrategyToken();
        portStrategies.push(_portStrategy);
        portStrategiesLenght++;
        strategyDailyLimitAmount[_portStrategy][_token] = _dailyManagementLimit;
        isPortStrategy[_portStrategy][_token] = true;
        emit PortStrategyAdded(_portStrategy, _token, _dailyManagementLimit);
    }
    function togglePortStrategy(address _portStrategy, address _token) external requiresCoreRouter {
        isPortStrategy[_portStrategy][_token] = !isPortStrategy[_portStrategy][_token];
        emit PortStrategyToggled(_portStrategy, _token);
    }
    function updatePortStrategy(address _portStrategy, address _token, uint256 _dailyManagementLimit)
        external
        requiresCoreRouter
    {
        strategyDailyLimitAmount[_portStrategy][_token] = _dailyManagementLimit;
        emit PortStrategyUpdated(_portStrategy, _token, _dailyManagementLimit);
    }
    function _denormalizeDecimals(uint256 _amount, uint8 _decimals) internal pure returns (uint256) {
        return _decimals == 18 ? _amount : _amount * 1 ether / (10 ** _decimals);
    }
    modifier requiresCoreRouter() {
        if (msg.sender != coreBranchRouterAddress) revert UnrecognizedCore();
        _;
    }
    modifier requiresBridgeAgent() {
        if (!isBridgeAgent[msg.sender]) revert UnrecognizedBridgeAgent();
        _;
    }
    modifier requiresBridgeAgentFactory() {
        if (!isBridgeAgentFactory[msg.sender]) revert UnrecognizedBridgeAgentFactory();
        _;
    }
    modifier requiresPortStrategy(address _token) {
        if (!isPortStrategy[msg.sender][_token]) revert UnrecognizedPortStrategy();
        _;
    }
    uint256 internal _unlocked = 1;
    modifier lock() {
        require(_unlocked == 1);
        _unlocked = 2;
        _;
        _unlocked = 1;
    }
}