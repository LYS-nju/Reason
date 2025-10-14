pragma solidity ^0.8.20;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IOFTReceiverV2 {
    function onOFTReceived(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes32 _from, uint _amount, bytes calldata _payload) external;
}
abstract contract Owned {
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    address public owner;
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }
    constructor(address _owner) {
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
interface IDecentEthRouter {
    event ReceivedDecentEth(
        uint8 msgType,
        uint16 _srcChainId,
        address from,
        address _to,
        uint amount,
        bytes payload
    );
    function MT_ETH_TRANSFER() external view returns (uint8);
    function MT_ETH_TRANSFER_WITH_PAYLOAD() external view returns (uint8);
    function registerDcntEth(address _addr) external;
    function addDestinationBridge(
        uint16 _dstChainId,
        address _routerAddress
    ) external;
    function estimateSendAndCallFee(
        uint8 msgType,
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth,
        bytes memory payload
    ) external view returns (uint nativeFee, uint zroFee);
    function bridgeWithPayload(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        bool deliverEth,
        uint64 _dstGasForCall,
        bytes memory additionalPayload
    ) external payable;
    function bridge(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth 
    ) external payable;
    function redeemEth(uint256 amount) external;
    function redeemWeth(uint256 amount) external;
    function addLiquidityEth() external payable;
    function removeLiquidityEth(uint256 amount) external;
    function addLiquidityWeth(uint256 amount) external payable;
    function removeLiquidityWeth(uint256 amount) external;
}
interface ICommonOFT is IERC165 {
    struct LzCallParams {
        address payable refundAddress;
        address zroPaymentAddress;
        bytes adapterParams;
    }
    function estimateSendFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);
    function estimateSendAndCallFee(uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, bool _useZro, bytes calldata _adapterParams) external view returns (uint nativeFee, uint zroFee);
    function circulatingSupply() external view returns (uint);
    function token() external view returns (address);
}
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint) external;
}
interface IOFTV2 is ICommonOFT {
    function sendFrom(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, LzCallParams calldata _callParams) external payable;
    function sendAndCall(address _from, uint16 _dstChainId, bytes32 _toAddress, uint _amount, bytes calldata _payload, uint64 _dstGasForCall, LzCallParams calldata _callParams) external payable;
}
interface IDcntEth is IOFTV2, IERC20 {
    function setRouter(address _router) external;
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
    function mintByOwner(address _to, uint256 _amount) external;
    function burnByOwner(address _from, uint256 _amount) external;
}
interface IDecentBridgeExecutor {
    function execute(
      address from,
      address target,
      bool deliverEth,
      uint256 amount,
      bytes memory callPayload
    ) external;
}
contract DecentEthRouter is IDecentEthRouter, IOFTReceiverV2, Owned {
    IWETH public weth;
    IDcntEth public dcntEth;
    IDecentBridgeExecutor public executor;
    uint8 public constant MT_ETH_TRANSFER = 0;
    uint8 public constant MT_ETH_TRANSFER_WITH_PAYLOAD = 1;
    uint16 public constant PT_SEND_AND_CALL = 1;
    bool public gasCurrencyIsEth; 
    mapping(uint16 => address) public destinationBridges;
    mapping(address => uint256) public balanceOf;
    constructor(
        address payable _wethAddress,
        bool gasIsEth,
        address _executor
    ) Owned(msg.sender) {
        weth = IWETH(_wethAddress);
        gasCurrencyIsEth = gasIsEth;
        executor = IDecentBridgeExecutor(payable(_executor));
    }
    modifier onlyEthChain() {
        require(gasCurrencyIsEth, "Gas currency is not ETH");
        _;
    }
    modifier onlyLzApp() {
        require(
            address(dcntEth) == msg.sender,
            "DecentEthRouter: only lz App can call"
        );
        _;
    }
    modifier onlyIfWeHaveEnoughReserves(uint256 amount) {
        require(weth.balanceOf(address(this)) > amount, "not enough reserves");
        _;
    }
    modifier userDepositing(uint256 amount) {
        balanceOf[msg.sender] += amount;
        _;
    }
    modifier userIsWithdrawing(uint256 amount) {
        uint256 balance = balanceOf[msg.sender];
        require(balance >= amount, "not enough balance");
        _;
        balanceOf[msg.sender] -= amount;
    }
    function registerDcntEth(address _addr) public onlyOwner {
        dcntEth = IDcntEth(_addr);
    }
    function addDestinationBridge(
        uint16 _dstChainId,
        address _routerAddress
    ) public onlyOwner {
        destinationBridges[_dstChainId] = _routerAddress;
    }
    function _getCallParams(
        uint8 msgType,
        address _toAddress,
        uint16 _dstChainId,
        uint64 _dstGasForCall,
        bool deliverEth,
        bytes memory additionalPayload
    )
        private
        view
        returns (
            bytes32 destBridge,
            bytes memory adapterParams,
            bytes memory payload
        )
    {
        uint256 GAS_FOR_RELAY = 100000;
        uint256 gasAmount = GAS_FOR_RELAY + _dstGasForCall;
        adapterParams = abi.encodePacked(PT_SEND_AND_CALL, gasAmount);
        destBridge = bytes32(abi.encode(destinationBridges[_dstChainId]));
        if (msgType == MT_ETH_TRANSFER) {
            payload = abi.encode(msgType, msg.sender, _toAddress, deliverEth);
        } else {
            payload = abi.encode(
                msgType,
                msg.sender,
                _toAddress,
                deliverEth,
                additionalPayload
            );
        }
    }
    function estimateSendAndCallFee(
        uint8 msgType,
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth,
        bytes memory payload
    ) public view returns (uint nativeFee, uint zroFee) {
        (
            bytes32 destinationBridge,
            bytes memory adapterParams,
            bytes memory _payload
        ) = _getCallParams(
                msgType,
                _toAddress,
                _dstChainId,
                _dstGasForCall,
                deliverEth,
                payload
            );
        return
            dcntEth.estimateSendAndCallFee(
                _dstChainId,
                destinationBridge,
                _amount,
                _payload,
                _dstGasForCall,
                false, 
                adapterParams 
            );
    }
    function _bridgeWithPayload(
        uint8 msgType,
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bytes memory additionalPayload,
        bool deliverEth
    ) internal {
        (
            bytes32 destinationBridge,
            bytes memory adapterParams,
            bytes memory payload
        ) = _getCallParams(
                msgType,
                _toAddress,
                _dstChainId,
                _dstGasForCall,
                deliverEth,
                additionalPayload
            );
        ICommonOFT.LzCallParams memory callParams = ICommonOFT.LzCallParams({
            refundAddress: payable(msg.sender),
            zroPaymentAddress: address(0x0),
            adapterParams: adapterParams
        });
        uint gasValue;
        if (gasCurrencyIsEth) {
            weth.deposit{value: _amount}();
            gasValue = msg.value - _amount;
        } else {
            weth.transferFrom(msg.sender, address(this), _amount);
            gasValue = msg.value;
        }
        dcntEth.sendAndCall{value: gasValue}(
            address(this), 
            _dstChainId,
            destinationBridge, 
            _amount, 
            payload, 
            _dstGasForCall, 
            callParams 
        );
    }
    function bridgeWithPayload(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        bool deliverEth,
        uint64 _dstGasForCall,
        bytes memory additionalPayload
    ) public payable {
        return
            _bridgeWithPayload(
                MT_ETH_TRANSFER_WITH_PAYLOAD,
                _dstChainId,
                _toAddress,
                _amount,
                _dstGasForCall,
                additionalPayload,
                deliverEth
            );
    }
    function bridge(
        uint16 _dstChainId,
        address _toAddress,
        uint _amount,
        uint64 _dstGasForCall,
        bool deliverEth 
    ) public payable {
        _bridgeWithPayload(
            MT_ETH_TRANSFER,
            _dstChainId,
            _toAddress,
            _amount,
            _dstGasForCall,
            bytes(""),
            deliverEth
        );
    }
    function onOFTReceived(
        uint16 _srcChainId,
        bytes calldata,
        uint64,
        bytes32,
        uint _amount,
        bytes memory _payload
    ) external override onlyLzApp {
        (uint8 msgType, address _from, address _to, bool deliverEth) = abi
            .decode(_payload, (uint8, address, address, bool));
        bytes memory callPayload = "";
        if (msgType == MT_ETH_TRANSFER_WITH_PAYLOAD) {
            (, , , , callPayload) = abi.decode(
                _payload,
                (uint8, address, address, bool, bytes)
            );
        }
        emit ReceivedDecentEth(
            msgType,
            _srcChainId,
            _from,
            _to,
            _amount,
            callPayload
        );
        if (weth.balanceOf(address(this)) < _amount) {
            dcntEth.transfer(_to, _amount);
            return;
        }
        if (msgType == MT_ETH_TRANSFER) {
            if (!gasCurrencyIsEth || !deliverEth) {
                weth.transfer(_to, _amount);
            } else {
                weth.withdraw(_amount);
                payable(_to).transfer(_amount);
            }
        } else {
            weth.approve(address(executor), _amount);
            executor.execute(_from, _to, deliverEth, _amount, callPayload);
        }
    }
    function redeemEth(
        uint256 amount
    ) public onlyIfWeHaveEnoughReserves(amount) {
        dcntEth.transferFrom(msg.sender, address(this), amount);
        weth.withdraw(amount);
        payable(msg.sender).transfer(amount);
    }
    function redeemWeth(
        uint256 amount
    ) public onlyIfWeHaveEnoughReserves(amount) {
        dcntEth.transferFrom(msg.sender, address(this), amount);
        weth.transfer(msg.sender, amount);
    }
    function addLiquidityEth()
        public
        payable
        onlyEthChain
        userDepositing(msg.value)
    {
        weth.deposit{value: msg.value}();
        dcntEth.mint(address(this), msg.value);
    }
    function removeLiquidityEth(
        uint256 amount
    ) public onlyEthChain userIsWithdrawing(amount) {
        dcntEth.burn(address(this), amount);
        weth.withdraw(amount);
        payable(msg.sender).transfer(amount);
    }
    function addLiquidityWeth(
        uint256 amount
    ) public payable userDepositing(amount) {
        weth.transferFrom(msg.sender, address(this), amount);
        dcntEth.mint(address(this), amount);
    }
    function removeLiquidityWeth(
        uint256 amount
    ) public userIsWithdrawing(amount) {
        dcntEth.burn(address(this), amount);
        weth.transfer(msg.sender, amount);
    }
    receive() external payable {}
    fallback() external payable {}
}