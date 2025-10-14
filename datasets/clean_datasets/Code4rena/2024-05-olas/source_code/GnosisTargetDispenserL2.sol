pragma solidity ^0.8.25;
interface IBridgeErrors {
    error ManagerOnly(address sender, address manager);
    error OwnerOnly(address sender, address owner);
    error ZeroAddress();
    error ZeroValue();
    error IncorrectDataLength(uint256 expected, uint256 provided);
    error LowerThan(uint256 provided, uint256 expected);
    error Overflow(uint256 provided, uint256 max);
    error TargetRelayerOnly(address provided, address expected);
    error WrongMessageSender(address provided, address expected);
    error WrongChainId(uint256 provided, uint256 expected);
    error TargetAmountNotQueued(address target, uint256 amount, uint256 batchNonce);
    error InsufficientBalance(uint256 provided, uint256 expected);
    error TransferFailed(address token, address from, address to, uint256 amount);
    error AlreadyDelivered(bytes32 deliveryHash);
    error WrongAmount(uint256 provided, uint256 expected);
    error WrongTokenAddress(address provided, address expected);
    error Paused();
    error Unpaused();
    error ReentrancyGuard();
    error WrongAccount(address account);
}
pragma solidity ^0.8.25;
interface IStaking {
    function deposit(uint256 amount) external;
}
interface IStakingFactory {
    function verifyInstanceAndGetEmissionsAmount(address instance) external view returns (uint256 amount);
}
interface IToken {
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transfer(address to, uint256 amount) external returns (bool);
}
abstract contract DefaultTargetDispenserL2 is IBridgeErrors {
    event OwnerUpdated(address indexed owner);
    event FundsReceived(address indexed sender, uint256 value);
    event StakingTargetDeposited(address indexed target, uint256 amount);
    event AmountWithheld(address indexed target, uint256 amount);
    event StakingRequestQueued(bytes32 indexed queueHash, address indexed target, uint256 amount,
        uint256 batchNonce, uint256 paused);
    event MessagePosted(uint256 indexed sequence, address indexed messageSender, address indexed l1Processor,
        uint256 amount);
    event MessageReceived(address indexed sender, uint256 chainId, bytes data);
    event WithheldAmountSynced(address indexed sender, uint256 amount);
    event Drain(address indexed owner, uint256 amount);
    event TargetDispenserPaused();
    event TargetDispenserUnpaused();
    event Migrated(address indexed sender, address indexed newL2TargetDispenser, uint256 amount);
    bytes4 public constant RECEIVE_MESSAGE = bytes4(keccak256(bytes("receiveMessage(bytes)")));
    uint256 public constant MAX_CHAIN_ID = type(uint64).max / 2 - 36;
    uint256 public constant GAS_LIMIT = 300_000;
    uint256 public constant MAX_GAS_LIMIT = 2_000_000;
    address public immutable olas;
    address public immutable stakingFactory;
    address public immutable l2MessageRelayer;
    address public immutable l1DepositProcessor;
    uint256 public immutable l1SourceChainId;
    uint256 public withheldAmount;
    uint256 public stakingBatchNonce;
    address public owner;
    uint8 public paused;
    uint8 internal _locked;
    mapping(bytes32 => bool) public stakingQueueingNonces;
    constructor(
        address _olas,
        address _stakingFactory,
        address _l2MessageRelayer,
        address _l1DepositProcessor,
        uint256 _l1SourceChainId
    ) {
        if (_olas == address(0) || _stakingFactory == address(0) || _l2MessageRelayer == address(0)
            || _l1DepositProcessor == address(0)) {
            revert ZeroAddress();
        }
        if (_l1SourceChainId == 0) {
            revert ZeroValue();
        }
        if (_l1SourceChainId > MAX_CHAIN_ID) {
            revert Overflow(_l1SourceChainId, MAX_CHAIN_ID);
        }
        olas = _olas;
        stakingFactory = _stakingFactory;
        l2MessageRelayer = _l2MessageRelayer;
        l1DepositProcessor = _l1DepositProcessor;
        l1SourceChainId = _l1SourceChainId;
        owner = msg.sender;
        paused = 1;
        _locked = 1;
    }
    function _processData(bytes memory data) internal {
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;
        (address[] memory targets, uint256[] memory amounts) = abi.decode(data, (address[], uint256[]));
        uint256 batchNonce = stakingBatchNonce;
        uint256 localWithheldAmount = 0;
        uint256 localPaused = paused;
        for (uint256 i = 0; i < targets.length; ++i) {
            address target = targets[i];
            uint256 amount = amounts[i];
            bytes memory verifyData = abi.encodeCall(IStakingFactory.verifyInstanceAndGetEmissionsAmount, target);
            (bool success, bytes memory returnData) = stakingFactory.call(verifyData);
            uint256 limitAmount;
            if (success && returnData.length == 32) {
                limitAmount = abi.decode(returnData, (uint256));
            }
            if (limitAmount == 0) {
                localWithheldAmount += amount;
                emit AmountWithheld(target, amount);
                continue;
            }
            if (amount > limitAmount) {
                uint256 targetWithheldAmount = amount - limitAmount;
                localWithheldAmount += targetWithheldAmount;
                amount = limitAmount;
                emit AmountWithheld(target, targetWithheldAmount);
            }
            if (IToken(olas).balanceOf(address(this)) >= amount && localPaused == 1) {
                IToken(olas).approve(target, amount);
                IStaking(target).deposit(amount);
                emit StakingTargetDeposited(target, amount);
            } else {
                bytes32 queueHash = keccak256(abi.encode(target, amount, batchNonce));
                stakingQueueingNonces[queueHash] = true;
                emit StakingRequestQueued(queueHash, target, amount, batchNonce, localPaused);
            }
        }
        stakingBatchNonce = batchNonce + 1;
        if (localWithheldAmount > 0) {
            withheldAmount += localWithheldAmount;
        }
        _locked = 1;
    }
    function _sendMessage(uint256 amount, bytes memory bridgePayload) internal virtual;
    function _receiveMessage(
        address messageRelayer,
        address sourceProcessor,
        bytes memory data
    ) internal virtual {
        if (messageRelayer != l2MessageRelayer) {
            revert TargetRelayerOnly(messageRelayer, l2MessageRelayer);
        }
        if (sourceProcessor != l1DepositProcessor) {
            revert WrongMessageSender(sourceProcessor, l1DepositProcessor);
        }
        emit MessageReceived(l1DepositProcessor, l1SourceChainId, data);
        _processData(data);
    }
    function changeOwner(address newOwner) external {
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }
        if (newOwner == address(0)) {
            revert ZeroAddress();
        }
        owner = newOwner;
        emit OwnerUpdated(newOwner);
    }
    function redeem(address target, uint256 amount, uint256 batchNonce) external {
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;
        if (paused == 2) {
            revert Paused();
        }
        bytes32 queueHash = keccak256(abi.encode(target, amount, batchNonce));
        bool queued = stakingQueueingNonces[queueHash];
        if (!queued) {
            revert TargetAmountNotQueued(target, amount, batchNonce);
        }
        uint256 olasBalance = IToken(olas).balanceOf(address(this));
        if (olasBalance >= amount) {
            IToken(olas).approve(target, amount);
            IStaking(target).deposit(amount);
            emit StakingTargetDeposited(target, amount);
            stakingQueueingNonces[queueHash] = false;
        } else {
            revert InsufficientBalance(olasBalance, amount);
        }
        _locked = 1;
    }
    function processDataMaintenance(bytes memory data) external {
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }
        _processData(data);
    }
    function syncWithheldTokens(bytes memory bridgePayload) external payable {
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;
        if (paused == 2) {
            revert Paused();
        }
        uint256 amount = withheldAmount;
        if (amount == 0) {
            revert ZeroValue();
        }
        withheldAmount = 0;
        _sendMessage(amount, bridgePayload);
        emit WithheldAmountSynced(msg.sender, amount);
        _locked = 1;
    }
    function pause() external {
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }
        paused = 2;
        emit TargetDispenserPaused();
    }
    function unpause() external {
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }
        paused = 1;
        emit TargetDispenserUnpaused();
    }
    function drain() external returns (uint256 amount) {
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }
        amount = address(this).balance;
        if (amount == 0) {
            revert ZeroValue();
        }
        (bool success, ) = msg.sender.call{value: amount}("");
        if (!success) {
            revert TransferFailed(address(0), address(this), msg.sender, amount);
        }
        emit Drain(msg.sender, amount);
        _locked = 1;
    }
    function migrate(address newL2TargetDispenser) external {
        if (_locked > 1) {
            revert ReentrancyGuard();
        }
        _locked = 2;
        if (msg.sender != owner) {
            revert OwnerOnly(msg.sender, owner);
        }
        if (paused == 1) {
            revert Unpaused();
        }
        if (newL2TargetDispenser.code.length == 0) {
            revert WrongAccount(newL2TargetDispenser);
        }
        if (newL2TargetDispenser == address(this)) {
            revert WrongAccount(address(this));
        }
        uint256 amount = IToken(olas).balanceOf(address(this));
        if (amount > 0) {
            bool success = IToken(olas).transfer(newL2TargetDispenser, amount);
            if (!success) {
                revert TransferFailed(olas, address(this), newL2TargetDispenser, amount);
            }
        }
        owner = address(0);
        emit Migrated(msg.sender, newL2TargetDispenser, amount);
    }
    receive() external payable {
        if (owner == address(0)) {
            revert TransferFailed(address(0), msg.sender, address(this), msg.value);
        }
        emit FundsReceived(msg.sender, msg.value);
    }
}
pragma solidity ^0.8.25;
interface IBridge {
    function requireToPassMessage(address target, bytes memory data, uint256 maxGasLimit) external returns (bytes32);
    function messageSender() external returns (address);
}
contract GnosisTargetDispenserL2 is DefaultTargetDispenserL2 {
    uint256 public constant BRIDGE_PAYLOAD_LENGTH = 32;
    address public immutable l2TokenRelayer;
    constructor(
        address _olas,
        address _proxyFactory,
        address _l2MessageRelayer,
        address _l1DepositProcessor,
        uint256 _l1SourceChainId,
        address _l2TokenRelayer
    )
        DefaultTargetDispenserL2(_olas, _proxyFactory, _l2MessageRelayer, _l1DepositProcessor, _l1SourceChainId)
    {
        if (_l2TokenRelayer == address(0)) {
            revert ZeroAddress();
        }
        l2TokenRelayer = _l2TokenRelayer;
    }
    function _sendMessage(uint256 amount, bytes memory bridgePayload) internal override {
        if (bridgePayload.length != BRIDGE_PAYLOAD_LENGTH) {
            revert IncorrectDataLength(BRIDGE_PAYLOAD_LENGTH, bridgePayload.length);
        }
        uint256 gasLimitMessage = abi.decode(bridgePayload, (uint256));
        if (gasLimitMessage < GAS_LIMIT) {
            gasLimitMessage = GAS_LIMIT;
        }
        if (gasLimitMessage > MAX_GAS_LIMIT) {
            gasLimitMessage = MAX_GAS_LIMIT;
        }
        bytes memory data = abi.encodeWithSelector(RECEIVE_MESSAGE, abi.encode(amount));
        bytes32 iMsg = IBridge(l2MessageRelayer).requireToPassMessage(l1DepositProcessor, data, gasLimitMessage);
        emit MessagePosted(uint256(iMsg), msg.sender, l1DepositProcessor, amount);
    }
    function receiveMessage(bytes memory data) external {
        address processor = IBridge(l2MessageRelayer).messageSender();
        _receiveMessage(msg.sender, processor, data);
    }
    function onTokenBridged(address, uint256, bytes calldata data) external {
        if (msg.sender != l2TokenRelayer) {
            revert TargetRelayerOnly(msg.sender, l2TokenRelayer);
        }
        _receiveMessage(l2MessageRelayer, l1DepositProcessor, data);
    }
}