pragma solidity ^0.8.0;
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        _afterTokenTransfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
        _afterTokenTransfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");
        _beforeTokenTransfer(account, address(0), amount);
        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
interface IController {
    function withdraw(address, uint256) external;
    function balanceOf(address) external view returns (uint256);
    function earn(address, uint256) external;
    function want(address) external view returns (address);
    function feeAddress() external view returns (address);
    function vaults(address) external view returns (address);
    function strategies(address) external view returns (address);
    function balanceOfJPEG(address strategyToken)
        external
        view
        returns (uint256);
    function withdrawJPEG(address strategyToken, address to) external;
}
interface IYVault is IERC20 {
    function token() external view returns (address);
    function controller() external view returns (address);
    function deposit(uint256 amount) external;
    function withdraw(uint256 shares) external;
    function withdrawJPEG() external;
    function balanceOfJPEG() external view returns (uint256);
}
contract YVault is ERC20, Ownable {
    using SafeERC20 for ERC20;
    using Address for address;
    event Deposit(address indexed depositor, uint256 wantAmount);
    event Withdrawal(address indexed withdrawer, uint256 wantAmount);
    struct Rate {
        uint128 numerator;
        uint128 denominator;
    }
    ERC20 public immutable token;
    IController public controller;
    address public farm;
    Rate internal availableTokensRate;
    mapping(address => bool) public whitelistedContracts;
    constructor(
        address _token,
        address _controller,
        Rate memory _availableTokensRate
    )
        ERC20(
            string(
                abi.encodePacked("JPEG\xE2\x80\x99d ", ERC20(_token).name())
            ),
            string(abi.encodePacked("JPEGD", ERC20(_token).symbol()))
        )
    {
        setController(_controller);
        setAvailableTokensRate(_availableTokensRate);
        token = ERC20(_token);
    }
    modifier noContract(address _account) {
        require(
            !_account.isContract() || whitelistedContracts[_account],
            "Contracts not allowed"
        );
        _;
    }
    function decimals() public view virtual override returns (uint8) {
        return token.decimals();
    }
    function balance() public view returns (uint256) {
        return
            token.balanceOf(address(this)) +
            controller.balanceOf(address(token));
    }
    function balanceOfJPEG() external view returns (uint256) {
        return controller.balanceOfJPEG(address(token));
    }
    function setContractWhitelisted(address _contract, bool _isWhitelisted)
        external
        onlyOwner
    {
        whitelistedContracts[_contract] = _isWhitelisted;
    }
    function setAvailableTokensRate(Rate memory _rate) public onlyOwner {
        require(
            _rate.numerator > 0 && _rate.denominator >= _rate.numerator,
            "INVALID_RATE"
        );
        availableTokensRate = _rate;
    }
    function setController(address _controller) public onlyOwner {
        require(_controller != address(0), "INVALID_CONTROLLER");
        controller = IController(_controller);
    }
    function setFarmingPool(address _farm) public onlyOwner {
        require(_farm != address(0), "INVALID_FARMING_POOL");
        farm = _farm;
    }
    function available() public view returns (uint256) {
        return
            (token.balanceOf(address(this)) * availableTokensRate.numerator) /
            availableTokensRate.denominator;
    }
    function earn() external {
        uint256 _bal = available();
        token.safeTransfer(address(controller), _bal);
        controller.earn(address(token), _bal);
    }
    function depositAll() external {
        deposit(token.balanceOf(msg.sender));
    }
    function deposit(uint256 _amount) public noContract(msg.sender) {
        require(_amount > 0, "INVALID_AMOUNT");
        uint256 balanceBefore = balance();
        token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 supply = totalSupply();
        uint256 shares;
        if (supply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * supply) / balanceBefore;
        }
        _mint(msg.sender, shares);
        emit Deposit(msg.sender, _amount);
    }
    function withdrawAll() external {
        withdraw(balanceOf(msg.sender));
    }
    function withdraw(uint256 _shares) public noContract(msg.sender) {
        require(_shares > 0, "INVALID_AMOUNT");
        uint256 supply = totalSupply();
        require(supply > 0, "NO_TOKENS_DEPOSITED");
        uint256 backingTokens = (balance() * _shares) / supply;
        _burn(msg.sender, _shares);
        uint256 vaultBalance = token.balanceOf(address(this));
        if (vaultBalance < backingTokens) {
            uint256 toWithdraw = backingTokens - vaultBalance;
            controller.withdraw(address(token), toWithdraw);
        }
        token.safeTransfer(msg.sender, backingTokens);
        emit Withdrawal(msg.sender, backingTokens);
    }
    function withdrawJPEG() external {
        require(farm != address(0), "NO_FARM");
        controller.withdrawJPEG(address(token), farm);
    }
    function getPricePerFullShare() external view returns (uint256) {
        uint256 supply = totalSupply();
        if (supply == 0) return 0;
        return (balance() * 1e18) / supply;
    }
    function renounceOwnership() public view override onlyOwner {
        revert("Cannot renounce ownership");
    }
}