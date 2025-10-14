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
interface IApp {
    function anyExecute(bytes calldata _data) external returns (bool success, bytes memory result);
    function anyFallback(bytes calldata _data) external returns (bool success, bytes memory result);
}
interface IBranchBridgeAgentFactory {
    function createBridgeAgent(
        address newRootRouterAddress,
        address rootBridgeAgentAddress,
        address _rootBridgeAgentFactoryAddress
    ) external returns (address newBridgeAgent);
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
interface ICoreBranchRouter {
    function addGlobalToken(
        address _globalAddress,
        uint256 _toChain,
        uint128 _remoteExecutionGas,
        uint128 _rootExecutionGas
    ) external payable;
    function addLocalToken(address _underlyingAddress) external payable;
    function syncBridgeAgent(address _newBridgeAgentAddress, address _rootBridgeAgentAddress) external payable;
}
interface IERC20hTokenBranch {
    function mint(address account, uint256 amount) external returns (bool);
    function burn(uint256 value) external;
}
struct UserFeeInfo {
    uint256 depositedGas;
    uint256 feesOwed;
}
enum DepositStatus {
    Success,
    Failed
}
struct Deposit {
    uint128 depositedGas;
    address owner;
    DepositStatus status;
    address[] hTokens;
    address[] tokens;
    uint256[] amounts;
    uint256[] deposits;
}
struct DepositInput {
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
    uint24 toChain; 
}
struct DepositMultipleInput {
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
    uint24 toChain; 
}
struct DepositParams {
    uint32 depositNonce; 
    address hToken; 
    address token; 
    uint256 amount; 
    uint256 deposit; 
    uint24 toChain; 
    uint128 depositedGas; 
}
struct DepositMultipleParams {
    uint8 numberOfAssets; 
    uint32 depositNonce; 
    address[] hTokens; 
    address[] tokens; 
    uint256[] amounts; 
    uint256[] deposits; 
    uint24 toChain; 
    uint128 depositedGas; 
}
struct SettlementParams {
    uint32 settlementNonce;
    address recipient;
    address hToken;
    address token;
    uint256 amount;
    uint256 deposit;
}
struct SettlementMultipleParams {
    uint8 numberOfAssets; 
    address recipient;
    uint32 settlementNonce;
    address[] hTokens;
    address[] tokens;
    uint256[] amounts;
    uint256[] deposits;
}
interface IBranchBridgeAgent is IApp {
    function bridgeAgentExecutorAddress() external view returns (address);
    function getDepositEntry(uint32 _depositNonce) external view returns (Deposit memory);
    function callOut(bytes calldata params, uint128 remoteExecutionGas) external payable;
    function callOutAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable;
    function callOutAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable;
    function callOutSigned(bytes calldata params, uint128 remoteExecutionGas) external payable;
    function callOutSignedAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable;
    function callOutSignedAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable;
    function retryDeposit(
        bool _isSigned,
        uint32 _depositNonce,
        bytes calldata _params,
        uint128 _remoteExecutionGas,
        uint24 _toChain
    ) external payable;
    function retrySettlement(uint32 _settlementNonce, uint128 _gasToBoostSettlement) external payable;
    function retrieveDeposit(uint32 _depositNonce) external payable;
    function redeemDeposit(uint32 _depositNonce) external;
    function clearToken(address _recipient, address _hToken, address _token, uint256 _amount, uint256 _deposit)
        external;
    function clearTokens(bytes calldata _sParams, address _recipient)
        external
        returns (SettlementMultipleParams memory);
    function performSystemCallOut(
        address depositor,
        bytes memory params,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;
    function performCallOut(address depositor, bytes memory params, uint128 gasToBridgeOut, uint128 remoteExecutionGas)
        external
        payable;
    function performCallOutAndBridge(
        address depositor,
        bytes calldata params,
        DepositInput memory dParams,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;
    function performCallOutAndBridgeMultiple(
        address depositor,
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 gasToBridgeOut,
        uint128 remoteExecutionGas
    ) external payable;
    function forceRevert() external;
    function depositGasAnycallConfig() external payable;
    event LogCallin(bytes1 selector, bytes data, uint256 fromChainId);
    event LogCallout(bytes1 selector, bytes data, uint256, uint256 toChainId);
    event LogCalloutFail(bytes1 selector, bytes data, uint256 toChainId);
    error AnycallUnauthorizedCaller();
    error AlreadyExecutedTransaction();
    error InvalidInput();
    error InvalidChain();
    error InsufficientGas();
    error NotDepositOwner();
    error DepositRedeemUnavailable();
    error UnrecognizedCallerNotRouter();
    error UnrecognizedBridgeAgentExecutor();
}
interface IBranchRouter {
    function localBridgeAgentAddress() external view returns (address);
    function bridgeAgentExecutorAddress() external view returns (address);
    function callOut(bytes calldata params, uint128 rootExecutionGas) external payable;
    function callOutAndBridge(bytes calldata params, DepositInput memory dParams, uint128 rootExecutionGas)
        external
        payable;
    function callOutAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 rootExecutionGas
    ) external payable;
    function retrySettlement(uint32 _settlementNonce, uint128 _gasToBoostSettlement) external payable;
    function redeemDeposit(uint32 _depositNonce) external;
    function getDepositEntry(uint32 _depositNonce) external view returns (Deposit memory);
    function anyExecuteNoSettlement(bytes calldata data) external returns (bool success, bytes memory result);
    function anyExecuteSettlement(bytes calldata data, SettlementParams memory sParams)
        external
        returns (bool success, bytes memory result);
    function anyExecuteSettlementMultiple(bytes calldata data, SettlementMultipleParams memory sParams)
        external
        returns (bool success, bytes memory result);
    error UnrecognizedBridgeAgentExecutor();
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
contract BaseBranchRouter is IBranchRouter, Ownable {
    address public localBridgeAgentAddress;
    address public bridgeAgentExecutorAddress;
    constructor() {
        _initializeOwner(msg.sender);
    }
    function initialize(address _localBridgeAgentAddress) external onlyOwner {
        require(_localBridgeAgentAddress != address(0), "Bridge Agent address cannot be 0");
        localBridgeAgentAddress = _localBridgeAgentAddress;
        bridgeAgentExecutorAddress = IBranchBridgeAgent(localBridgeAgentAddress).bridgeAgentExecutorAddress();
        renounceOwnership();
    }
    function getDepositEntry(uint32 _depositNonce) external view returns (Deposit memory) {
        return IBranchBridgeAgent(localBridgeAgentAddress).getDepositEntry(_depositNonce);
    }
    function callOut(bytes calldata params, uint128 remoteExecutionGas) external payable lock {
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(
            msg.sender, params, 0, remoteExecutionGas
        );
    }
    function callOutAndBridge(bytes calldata params, DepositInput memory dParams, uint128 remoteExecutionGas)
        external
        payable
        lock
    {
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOutAndBridge{value: msg.value}(
            msg.sender, params, dParams, 0, remoteExecutionGas
        );
    }
    function callOutAndBridgeMultiple(
        bytes calldata params,
        DepositMultipleInput memory dParams,
        uint128 remoteExecutionGas
    ) external payable lock {
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOutAndBridgeMultiple{value: msg.value}(
            msg.sender, params, dParams, 0, remoteExecutionGas
        );
    }
    function retrySettlement(uint32 _settlementNonce, uint128 _gasToBoostSettlement) external payable lock {
        IBranchBridgeAgent(localBridgeAgentAddress).retrySettlement{value: msg.value}(_settlementNonce, _gasToBoostSettlement);
    }
    function redeemDeposit(uint32 _depositNonce) external lock {
        IBranchBridgeAgent(localBridgeAgentAddress).redeemDeposit(_depositNonce);
    }
    function anyExecuteNoSettlement(bytes calldata)
        external
        virtual
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        return (false, "unknown selector");
    }
    function anyExecuteSettlement(bytes calldata, SettlementParams memory)
        external
        virtual
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        return (false, "unknown selector");
    }
    function anyExecuteSettlementMultiple(bytes calldata, SettlementMultipleParams memory)
        external
        virtual
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        return (false, "unknown selector");
    }
    modifier requiresAgentExecutor() {
        if (msg.sender != bridgeAgentExecutorAddress) revert UnrecognizedBridgeAgentExecutor();
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
interface IERC20hTokenBranchFactory {
    function createToken(string memory _name, string memory _symbol) external returns (ERC20hTokenBranch newToken);
    error UnrecognizedCoreRouter();
    error UnrecognizedPort();
}
contract CoreBranchRouter is BaseBranchRouter {
    address public hTokenFactoryAddress;
    address public localPortAddress;
    constructor(address _hTokenFactoryAddress, address _localPortAddress) BaseBranchRouter() {
        localPortAddress = _localPortAddress;
        hTokenFactoryAddress = _hTokenFactoryAddress;
    }
    function addGlobalToken(
        address _globalAddress,
        uint24 _toChain,
        uint128 _remoteExecutionGas,
        uint128 _rootExecutionGas
    ) external payable {
        bytes memory data = abi.encode(msg.sender, _globalAddress, _toChain, _rootExecutionGas);
        bytes memory packedData = abi.encodePacked(bytes1(0x01), data);
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(
            msg.sender, packedData, 0, _remoteExecutionGas
        );
    }
    function addLocalToken(address _underlyingAddress) external payable virtual {
        string memory name = ERC20(_underlyingAddress).name();
        string memory symbol = ERC20(_underlyingAddress).symbol();
        ERC20hTokenBranch newToken = IERC20hTokenBranchFactory(hTokenFactoryAddress).createToken(name, symbol);
        bytes memory data = abi.encode(_underlyingAddress, newToken, name, symbol);
        bytes memory packedData = abi.encodePacked(bytes1(0x02), data);
        IBranchBridgeAgent(localBridgeAgentAddress).performCallOut{value: msg.value}(msg.sender, packedData, 0, 0);
    }
    function _receiveAddGlobalToken(
        address _globalAddress,
        string memory _name,
        string memory _symbol,
        uint128 _rootExecutionGas
    ) internal {
        ERC20hTokenBranch newToken = IERC20hTokenBranchFactory(hTokenFactoryAddress).createToken(_name, _symbol);
        bytes memory data = abi.encode(_globalAddress, newToken);
        bytes memory packedData = abi.encodePacked(bytes1(0x03), data);
        IBranchBridgeAgent(localBridgeAgentAddress).performSystemCallOut(address(this), packedData, _rootExecutionGas, 0);
    }
    function _receiveAddBridgeAgent(
        address _newBranchRouter,
        address _branchBridgeAgentFactory,
        address _rootBridgeAgent,
        address _rootBridgeAgentFactory,
        uint128 _remoteExecutionGas
    ) internal virtual {
        if (!IBranchPort(localPortAddress).isBridgeAgentFactory(_branchBridgeAgentFactory)) {
            revert UnrecognizedBridgeAgentFactory();
        }
        address newBridgeAgent = IBranchBridgeAgentFactory(_branchBridgeAgentFactory).createBridgeAgent(
            _newBranchRouter, _rootBridgeAgent, _rootBridgeAgentFactory
        );
        if (!IBranchPort(localPortAddress).isBridgeAgent(newBridgeAgent)) {
            revert UnrecognizedBridgeAgent();
        }
        bytes memory data = abi.encode(newBridgeAgent, _rootBridgeAgent);
        bytes memory packedData = abi.encodePacked(bytes1(0x04), data);
        IBranchBridgeAgent(localBridgeAgentAddress).performSystemCallOut(address(this), packedData, _remoteExecutionGas, 0);
    }
    function _toggleBranchBridgeAgentFactory(address _newBridgeAgentFactoryAddress) internal {
        if (!IBranchPort(localPortAddress).isBridgeAgentFactory(_newBridgeAgentFactoryAddress)) {
            IBranchPort(localPortAddress).addBridgeAgentFactory(_newBridgeAgentFactoryAddress);
        } else {
            IBranchPort(localPortAddress).toggleBridgeAgentFactory(_newBridgeAgentFactoryAddress);
        }
    }
    function _removeBranchBridgeAgent(address _branchBridgeAgent) internal {
        if (!IBranchPort(localPortAddress).isBridgeAgent(_branchBridgeAgent)) revert UnrecognizedBridgeAgent();
        IBranchPort(localPortAddress).toggleBridgeAgent(_branchBridgeAgent);
    }
    function _manageStrategyToken(address _underlyingToken, uint256 _minimumReservesRatio) internal {
        if (!IBranchPort(localPortAddress).isStrategyToken(_underlyingToken)) {
            IBranchPort(localPortAddress).addStrategyToken(_underlyingToken, _minimumReservesRatio);
        } else {
            IBranchPort(localPortAddress).toggleStrategyToken(_underlyingToken);
        }
    }
    function _managePortStrategy(
        address _portStrategy,
        address _underlyingToken,
        uint256 _dailyManagementLimit,
        bool _isUpdateDailyLimit
    ) internal {
        if (!IBranchPort(localPortAddress).isPortStrategy(_portStrategy, _underlyingToken)) {
            IBranchPort(localPortAddress).addPortStrategy(_portStrategy, _underlyingToken, _dailyManagementLimit);
        } else if (_isUpdateDailyLimit) {
            IBranchPort(localPortAddress).updatePortStrategy(_portStrategy, _underlyingToken, _dailyManagementLimit);
        } else {
            IBranchPort(localPortAddress).togglePortStrategy(_portStrategy, _underlyingToken);
        }
    }
    function anyExecuteNoSettlement(bytes calldata _data)
        external
        virtual
        override
        requiresAgentExecutor
        returns (bool success, bytes memory result)
    {
        if (_data[0] == 0x01) {
            (address globalAddress, string memory name, string memory symbol, uint128 gasToBridgeOut) =
                abi.decode(_data[1:], (address, string, string, uint128));
            _receiveAddGlobalToken(globalAddress, name, symbol, gasToBridgeOut);
        } else if (_data[0] == 0x02) {
            (
                address newBranchRouter,
                address branchBridgeAgentFactory,
                address rootBridgeAgent,
                address rootBridgeAgentFactory,
                uint128 remoteExecutionGas
            ) = abi.decode(_data[1:], (address, address, address, address, uint128));
            _receiveAddBridgeAgent(
                newBranchRouter, branchBridgeAgentFactory, rootBridgeAgent, rootBridgeAgentFactory, remoteExecutionGas
            );
        } else if (_data[0] == 0x03) {
            (address bridgeAgentFactoryAddress) = abi.decode(_data[1:], (address));
            _toggleBranchBridgeAgentFactory(bridgeAgentFactoryAddress);
        } else if (_data[0] == 0x04) {
            (address branchBridgeAgent) = abi.decode(_data[1:], (address));
            _removeBranchBridgeAgent(branchBridgeAgent);
        } else if (_data[0] == 0x05) {
            (address underlyingToken, uint256 minimumReservesRatio) = abi.decode(_data[1:], (address, uint256));
            _manageStrategyToken(underlyingToken, minimumReservesRatio);
        } else if (_data[0] == 0x06) {
            (address portStrategy, address underlyingToken, uint256 dailyManagementLimit, bool isUpdateDailyLimit) =
                abi.decode(_data[1:], (address, address, uint256, bool));
            _managePortStrategy(portStrategy, underlyingToken, dailyManagementLimit, isUpdateDailyLimit);
        } else {
            return (false, "unknown selector");
        }
        return (true, "");
    }
    fallback() external payable {}
    error UnrecognizedBridgeAgent();
    error UnrecognizedBridgeAgentFactory();
}