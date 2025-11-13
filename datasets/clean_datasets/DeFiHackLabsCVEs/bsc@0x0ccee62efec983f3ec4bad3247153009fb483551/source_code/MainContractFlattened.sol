pragma solidity 0.6.7;
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint c) {
        require((c = a - b) <= a, errorMessage);
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b > 0, errorMessage);
        uint c = a / b;
        return c;
    }
    function mod(uint a, uint b) internal pure returns (uint) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}
contract Context {
    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view returns (bytes memory) {
        this; 
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { 
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library UniversalERC20 {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    IERC20 private constant ZERO_ADDRESS = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private constant BNB_ADDRESS = IERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    function universalTransfer(IERC20 token, address to, uint256 amount) internal returns(bool) {
        if (amount == 0) {
            return true;
        }
        if (isBNB(token)) {
            address(uint160(to)).transfer(amount);
        } else {
            token.safeTransfer(to, amount);
            return true;
        }
    }
    function universalTransferFrom(IERC20 token, address from, address to, uint256 amount) internal {
        if (amount == 0) {
            return;
        }
        if (isBNB(token)) {
            require(msg.value >= amount, "Wrong useage of BNB.universalTransferFrom()");
            if (to != address(this)) {
                address(uint160(to)).transfer(amount);
            }
            if (msg.value > amount) {
                address(uint160(from)).transfer(msg.value.sub(amount));
            }
        } else {
            token.safeTransferFrom(from, to, amount);
        }
    }
    function universalTransferFromSenderToThis(IERC20 token, uint256 amount) internal {
        if (amount == 0) {
            return;
        }
        if (isBNB(token)) {
            require(msg.value >= amount, "Wrong useage of BNB.universalTransferFrom()");
            if (msg.value > amount) {
                msg.sender.transfer(msg.value.sub(amount));
            }
        } else {
            token.safeTransferFrom(msg.sender, address(this), amount);
        }
    }
    function universalApprove(IERC20 token, address to, uint256 amount) internal {
        if (!isBNB(token)) {
            if (amount == 0) {
                token.safeApprove(to, 0);
                return;
            }
            uint256 allowance = token.allowance(address(this), to);
            if (allowance < amount) {
                if (allowance > 0) {
                    token.safeApprove(to, 0);
                }
                token.safeApprove(to, amount);
            }
        }
    }
    function universalBalanceOf(IERC20 token, address who) internal view returns (uint256) {
        if (isBNB(token)) {
            return who.balance;
        } else {
            return token.balanceOf(who);
        }
    }
    function universalDecimals(IERC20 token) internal view returns (uint256) {
        if (isBNB(token)) {
            return 18;
        }
        (bool success, bytes memory data) = address(token).staticcall{gas: 10000}(
            abi.encodeWithSignature("decimals()")
        );
        if (!success || data.length == 0) {
            (success, data) = address(token).staticcall{gas: 10000}(
                abi.encodeWithSignature("DECIMALS()")
            );
        }
        return (success && data.length > 0) ? abi.decode(data, (uint256)) : 18;
    }
    function isBNB(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(ZERO_ADDRESS) || address(token) == address(BNB_ADDRESS));
    }
    function eq(IERC20 a, IERC20 b) internal pure returns(bool) {
        return a == b || (isBNB(a) && isBNB(b));
    }
    function notExist(IERC20 token) internal pure returns(bool) {
        return (address(token) == address(-1));
    }
}
contract SwapXProxy is Ownable {
    using SafeMath for uint256;
    using UniversalERC20 for IERC20;
    address public swapXImpl;
    bool public paused;
    event Swapped(
        address indexed sender,
        IERC20 indexed srcToken,
        IERC20 indexed dstToken,
        address dstReceiver,
        uint256 amount,
        uint256 spentAmount,
        uint256 returnAmount,
        uint256 minReturnAmount,
        address referrer
    );
    event ImplementationUpdated(address indexed newImpl);
    event Paused(address account);
    event Unpaused(address account);
    modifier whenPaused() {
        require(paused, "Pausable: not paused");
        _;
    }
    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }
    constructor(address impl) public {
        setNewImpl(impl);
        paused = false;
    }
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused(msg.sender);
    }
    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused(msg.sender);
    }
    receive() external payable {
        require(msg.sender != tx.origin, "SwapX: do not send BNB directly");
    }
    function setNewImpl(address impl) public onlyOwner {
        swapXImpl = impl;
        emit ImplementationUpdated(address(impl));
    }
    function swap(
        IERC20 srcToken,
        IERC20 dstToken,
        address dstReceiver,
        uint256 amount,
        uint256 minReturnAmount,
        address referrer,
        bytes calldata data
    ) 
        external 
        payable 
        whenNotPaused
        returns (uint256 returnAmount)
    {
        require(minReturnAmount > 0, "Min return should not be 0");
        require(data.length > 0, "Call data should exist");
        dstReceiver = (dstReceiver == address(0)) ? msg.sender : dstReceiver;
        uint256 initialSrcBalance = srcToken.universalBalanceOf(msg.sender);
        uint256 initialDstBalance = dstToken.universalBalanceOf(dstReceiver);
        {
        (bool success, bytes memory returndata) = swapXImpl.call{value: msg.value}(data);
        if (!success)  {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("swap failed");
            }
        }
        }
        uint256 spentAmount = initialSrcBalance.sub(srcToken.universalBalanceOf(msg.sender));
        returnAmount = dstToken.universalBalanceOf(dstReceiver).sub(initialDstBalance);
        require(returnAmount >= minReturnAmount, "Return amount is not enough");
        emit Swapped(
            msg.sender,
            srcToken,
            dstToken,
            dstReceiver,
            amount,
            spentAmount,
            returnAmount,
            minReturnAmount,
            referrer
        );
    }
    function rescueFund(IERC20 asset, uint256 amount) public onlyOwner {
        asset.universalTransfer(msg.sender, amount);
    }
}