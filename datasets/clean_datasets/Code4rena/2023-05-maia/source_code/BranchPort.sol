pragma solidity ^0.8.18;
abstract contract Ownable {
    error Unauthorized();
    error NewOwnerIsZeroAddress();
    error NoHandoverRequest();
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    event OwnershipHandoverRequested(address indexed pendingOwner);
    event OwnershipHandoverCanceled(address indexed pendingOwner);
    uint256 private constant _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE =
        0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0;
    uint256 private constant _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE =
        0xdbf36a107da19e49527a7176a1babf963b4b0ff8cde35ee35d6cd8f1f9ac7e1d;
    uint256 private constant _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE =
        0xfa7b8eab7da67f412cc9575ed43464468f9bfbae89d1675917346ca6d8fe3c92;
    uint256 private constant _OWNER_SLOT_NOT = 0x8b78c6d8;
    uint256 private constant _HANDOVER_SLOT_SEED = 0x389a75e1;
    function _initializeOwner(address newOwner) internal virtual {
        assembly {
            newOwner := shr(96, shl(96, newOwner))
            sstore(not(_OWNER_SLOT_NOT), newOwner)
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, 0, newOwner)
        }
    }
    function _setOwner(address newOwner) internal virtual {
        assembly {
            let ownerSlot := not(_OWNER_SLOT_NOT)
            newOwner := shr(96, shl(96, newOwner))
            log3(0, 0, _OWNERSHIP_TRANSFERRED_EVENT_SIGNATURE, sload(ownerSlot), newOwner)
            sstore(ownerSlot, newOwner)
        }
    }
    function _checkOwner() internal view virtual {
        assembly {
            if iszero(eq(caller(), sload(not(_OWNER_SLOT_NOT)))) {
                mstore(0x00, 0x82b42900) 
                revert(0x1c, 0x04)
            }
        }
    }
    function transferOwnership(address newOwner) public payable virtual onlyOwner {
        assembly {
            if iszero(shl(96, newOwner)) {
                mstore(0x00, 0x7448fbae) 
                revert(0x1c, 0x04)
            }
        }
        _setOwner(newOwner);
    }
    function renounceOwnership() public payable virtual onlyOwner {
        _setOwner(address(0));
    }
    function requestOwnershipHandover() public payable virtual {
        unchecked {
            uint256 expires = block.timestamp + ownershipHandoverValidFor();
            assembly {
                mstore(0x0c, _HANDOVER_SLOT_SEED)
                mstore(0x00, caller())
                sstore(keccak256(0x0c, 0x20), expires)
                log2(0, 0, _OWNERSHIP_HANDOVER_REQUESTED_EVENT_SIGNATURE, caller())
            }
        }
    }
    function cancelOwnershipHandover() public payable virtual {
        assembly {
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, caller())
            sstore(keccak256(0x0c, 0x20), 0)
            log2(0, 0, _OWNERSHIP_HANDOVER_CANCELED_EVENT_SIGNATURE, caller())
        }
    }
    function completeOwnershipHandover(address pendingOwner) public payable virtual onlyOwner {
        assembly {
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            let handoverSlot := keccak256(0x0c, 0x20)
            if gt(timestamp(), sload(handoverSlot)) {
                mstore(0x00, 0x6f5e8818) 
                revert(0x1c, 0x04)
            }
            sstore(handoverSlot, 0)
        }
        _setOwner(pendingOwner);
    }
    function owner() public view virtual returns (address result) {
        assembly {
            result := sload(not(_OWNER_SLOT_NOT))
        }
    }
    function ownershipHandoverExpiresAt(address pendingOwner)
        public
        view
        virtual
        returns (uint256 result)
    {
        assembly {
            mstore(0x0c, _HANDOVER_SLOT_SEED)
            mstore(0x00, pendingOwner)
            result := sload(keccak256(0x0c, 0x20))
        }
    }
    function ownershipHandoverValidFor() public view virtual returns (uint64) {
        return 48 * 3600;
    }
    modifier onlyOwner() virtual {
        _checkOwner();
        _;
    }
}
library SafeTransferLib {
    error ETHTransferFailed();
    error TransferFromFailed();
    error TransferFailed();
    error ApproveFailed();
    uint256 internal constant _GAS_STIPEND_NO_STORAGE_WRITES = 2300;
    uint256 internal constant _GAS_STIPEND_NO_GRIEF = 100000;
    function safeTransferETH(address to, uint256 amount) internal {
        assembly {
            if iszero(call(gas(), to, amount, 0, 0, 0, 0)) {
                mstore(0x00, 0xb12d13eb)
                revert(0x1c, 0x04)
            }
        }
    }
    function forceSafeTransferETH(address to, uint256 amount, uint256 gasStipend) internal {
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb)
                revert(0x1c, 0x04)
            }
            if iszero(call(gasStipend, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) {
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }
    function forceSafeTransferETH(address to, uint256 amount) internal {
        assembly {
            if lt(selfbalance(), amount) {
                mstore(0x00, 0xb12d13eb)
                revert(0x1c, 0x04)
            }
            if iszero(call(_GAS_STIPEND_NO_GRIEF, to, amount, 0, 0, 0, 0)) {
                mstore(0x00, to) 
                mstore8(0x0b, 0x73) 
                mstore8(0x20, 0xff) 
                if iszero(create(amount, 0x0b, 0x16)) {
                    if iszero(gt(gas(), 1000000)) { revert(0, 0) }
                }
            }
        }
    }
    function trySafeTransferETH(address to, uint256 amount, uint256 gasStipend)
        internal
        returns (bool success)
    {
        assembly {
            success := call(gasStipend, to, amount, 0, 0, 0, 0)
        }
    }
    function safeTransferFrom(address token, address from, address to, uint256 amount) internal {
        assembly {
            let m := mload(0x40) 
            mstore(0x60, amount) 
            mstore(0x40, to) 
            mstore(0x2c, shl(96, from)) 
            mstore(0x0c, 0x23b872dd000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424)
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) 
            mstore(0x40, m) 
        }
    }
    function safeTransferAllFrom(address token, address from, address to)
        internal
        returns (uint256 amount)
    {
        assembly {
            let m := mload(0x40) 
            mstore(0x40, to) 
            mstore(0x2c, shl(96, from)) 
            mstore(0x0c, 0x70a08231000000000000000000000000)
            if iszero(
                and( 
                    gt(returndatasize(), 0x1f), 
                    staticcall(gas(), token, 0x1c, 0x24, 0x60, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424)
                revert(0x1c, 0x04)
            }
            mstore(0x00, 0x23b872dd)
            amount := mload(0x60)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x1c, 0x64, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x7939f424)
                revert(0x1c, 0x04)
            }
            mstore(0x60, 0) 
            mstore(0x40, m) 
        }
    }
    function safeTransfer(address token, address to, uint256 amount) internal {
        assembly {
            mstore(0x14, to) 
            mstore(0x34, amount) 
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18)
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0)
        }
    }
    function safeTransferAll(address token, address to) internal returns (uint256 amount) {
        assembly {
            mstore(0x00, 0x70a08231) 
            mstore(0x20, address()) 
            if iszero(
                and( 
                    gt(returndatasize(), 0x1f), 
                    staticcall(gas(), token, 0x1c, 0x24, 0x34, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18)
                revert(0x1c, 0x04)
            }
            mstore(0x14, to) 
            amount := mload(0x34)
            mstore(0x00, 0xa9059cbb000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18)
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0)
        }
    }
    function safeApprove(address token, address to, uint256 amount) internal {
        assembly {
            mstore(0x14, to) 
            mstore(0x34, amount) 
            mstore(0x00, 0x095ea7b3000000000000000000000000)
            if iszero(
                and( 
                    or(eq(mload(0x00), 1), iszero(returndatasize())),
                    call(gas(), token, 0, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x3e3f8f73)
                revert(0x1c, 0x04)
            }
            mstore(0x34, 0)
        }
    }
    function balanceOf(address token, address account) internal view returns (uint256 amount) {
        assembly {
            mstore(0x14, account) 
            mstore(0x00, 0x70a08231000000000000000000000000)
            amount :=
                mul(
                    mload(0x20),
                    and( 
                        gt(returndatasize(), 0x1f), 
                        staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)
                    )
                )
        }
    }
}
abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; 
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;
        balanceOf[from] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");
            allowance[recoveredAddress][spender] = value;
        }
        emit Approval(owner, spender, value);
    }
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }
    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }
    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }
    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        unchecked {
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }
}
interface IBranchPort {
    function isBridgeAgent(address _bridgeAgent) external view returns (bool);
    function isStrategyToken(address _token) external view returns (bool);
    function isPortStrategy(address _strategy, address _token) external view returns (bool);
    function isBridgeAgentFactory(address _bridgeAgentFactory) external view returns (bool);
    function manage(address _token, uint256 _amount) external;
    function replenishReserves(address _strategy, address _token, uint256 _amount) external;
    function withdraw(address _recipient, address _underlyingAddress, uint256 _amount) external;
    function bridgeIn(address _recipient, address _localAddress, uint256 _amount) external;
    function bridgeInMultiple(address _recipient, address[] memory _localAddresses, uint256[] memory _amounts)
        external;
    function bridgeOut(
        address _depositor,
        address _localAddress,
        address _underlyingAddress,
        uint256 _amount,
        uint256 _deposit
    ) external;
    function bridgeOutMultiple(
        address _depositor,
        address[] memory _localAddresses,
        address[] memory _underlyingAddresses,
        uint256[] memory _amounts,
        uint256[] memory _deposits
    ) external;
    function addBridgeAgent(address _bridgeAgent) external;
    function setCoreRouter(address _newCoreRouter) external;
    function addBridgeAgentFactory(address _bridgeAgentFactory) external;
    function toggleBridgeAgentFactory(address _newBridgeAgentFactory) external;
    function toggleBridgeAgent(address _bridgeAgent) external;
    function addStrategyToken(address _token, uint256 _minimumReservesRatio) external;
    function toggleStrategyToken(address _token) external;
    function addPortStrategy(address _portStrategy, address _token, uint256 _dailyManagementLimit) external;
    function togglePortStrategy(address _portStrategy, address _token) external;
    function updatePortStrategy(address _portStrategy, address _token, uint256 _dailyManagementLimit) external;
    event DebtCreated(address indexed _strategy, address indexed _token, uint256 _amount);
    event DebtRepaid(address indexed _strategy, address indexed _token, uint256 _amount);
    event StrategyTokenAdded(address indexed _token, uint256 _minimumReservesRatio);
    event StrategyTokenToggled(address indexed _token);
    event PortStrategyAdded(address indexed _portStrategy, address indexed _token, uint256 _dailyManagementLimit);
    event PortStrategyToggled(address indexed _portStrategy, address indexed _token);
    event PortStrategyUpdated(address indexed _portStrategy, address indexed _token, uint256 _dailyManagementLimit);
    event BridgeAgentFactoryAdded(address indexed _bridgeAgentFactory);
    event BridgeAgentFactoryToggled(address indexed _bridgeAgentFactory);
    event BridgeAgentToggled(address indexed _bridgeAgent);
    error InvalidMinimumReservesRatio();
    error InsufficientReserves();
    error UnrecognizedCore();
    error UnrecognizedBridgeAgent();
    error UnrecognizedBridgeAgentFactory();
    error UnrecognizedPortStrategy();
    error UnrecognizedStrategyToken();
}
interface IERC20hTokenBranch {
    function mint(address account, uint256 amount) external returns (bool);
    function burn(uint256 value) external;
}
interface IPortStrategy {
    function withdraw(address _recipient, address _token, uint256 _amount) external;
    error UnrecognizedPort();
}
contract ERC20hTokenBranch is ERC20, Ownable, IERC20hTokenBranch {
    constructor(string memory _name, string memory _symbol, address _owner)
        ERC20(string(string.concat("Hermes - ", _name)), string(string.concat("h-", _symbol)), 18)
    {
        _initializeOwner(_owner);
    }
    function mint(address account, uint256 amount) external override onlyOwner returns (bool) {
        _mint(account, amount);
        return true;
    }
    function burn(uint256 value) public override onlyOwner {
        _burn(msg.sender, value);
    }
}
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