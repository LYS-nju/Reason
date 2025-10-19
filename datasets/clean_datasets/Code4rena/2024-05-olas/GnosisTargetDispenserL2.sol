pragma solidity ^0.8.25;
import "./DefaultTargetDispenserL2.sol";
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