pragma solidity ^0.8.7;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}
contract InsureDAOERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    bool tokenInitialized;
    string private _name = "InsureDAO LP Token";
    string private _symbol = "iLP";
    uint8 private _decimals = 18;
    constructor() {}
    function initializeToken(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) internal {
        assert(!tokenInitialized);
        tokenInitialized = true;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
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
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(
            currentAllowance >= subtractedValue,
            "ERC20: decreased allowance below zero"
        );
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
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
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] = senderBalance - amount;
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
        _balances[account] = accountBalance - amount;
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
interface ICDSTemplate {
    function compensate(uint256) external returns (uint256 _compensated);
    function defund(uint256 _amount) external;
}
abstract contract IParameters {
    function setVault(address _token, address _vault) external virtual;
    function setLockup(address _address, uint256 _target) external virtual;
    function setGrace(address _address, uint256 _target) external virtual;
    function setMinDate(address _address, uint256 _target) external virtual;
    function setUpperSlack(address _address, uint256 _target) external virtual;
    function setLowerSlack(address _address, uint256 _target) external virtual;
    function setWithdrawable(address _address, uint256 _target)
        external
        virtual;
    function setPremiumModel(address _address, address _target)
        external
        virtual;
    function setFeeRate(address _address, uint256 _target) external virtual;
    function setMaxList(address _address, uint256 _target) external virtual;
    function setCondition(bytes32 _reference, bytes32 _target) external virtual;
    function getOwner() external view virtual returns (address);
    function getVault(address _token) external view virtual returns (address);
    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount,
        address _target
    ) external view virtual returns (uint256);
    function getFeeRate(address _target) external view virtual returns (uint256);
    function getUpperSlack(address _target)
        external
        view
        virtual
        returns (uint256);
    function getLowerSlack(address _target)
        external
        view
        virtual
        returns (uint256);
    function getLockup(address _target) external view virtual returns (uint256);
    function getWithdrawable(address _target)
        external
        view
        virtual
        returns (uint256);
    function getGrace(address _target) external view virtual returns (uint256);
    function getMinDate(address _target) external view virtual returns (uint256);
    function getMaxList(address _target)
        external
        view
        virtual
        returns (uint256);
    function getCondition(bytes32 _reference)
        external
        view
        virtual
        returns (bytes32);
}
interface IRegistry {
    function isListed(address _market) external view returns (bool);
    function getCDS(address _address) external view returns (address);
    function confirmExistence(address _template, address _target)
        external
        view
        returns (bool);
    function setFactory(address _factory) external;
    function supportMarket(address _market) external;
    function setExistence(address _template, address _target) external;
    function setCDS(address _address, address _cds) external;
}
interface IUniversalMarket {
    function initialize(
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external;
    function setPaused(bool state) external;
    function changeMetadata(string calldata _metadata) external;
}
interface IVault {
    function addValueBatch(
        uint256 _amount,
        address _from,
        address[2] memory _beneficiaries,
        uint256[2] memory _shares
    ) external returns (uint256[2] memory _allocations);
    function addValue(
        uint256 _amount,
        address _from,
        address _attribution
    ) external returns (uint256 _attributions);
    function withdrawValue(uint256 _amount, address _to)
        external
        returns (uint256 _attributions);
    function transferValue(uint256 _amount, address _destination)
        external
        returns (uint256 _attributions);
    function withdrawAttribution(uint256 _attribution, address _to)
        external
        returns (uint256 _retVal);
    function withdrawAllAttribution(address _to)
        external
        returns (uint256 _retVal);
    function transferAttribution(uint256 _amount, address _destination)
        external;
    function attributionOf(address _target) external view returns (uint256);
    function underlyingValue(address _target) external view returns (uint256);
    function attributionValue(uint256 _attribution)
        external
        view
        returns (uint256);
    function utilize() external returns (uint256 _amount);
    function token() external returns (address);
    function borrowValue(uint256 _amount, address _to) external;
    function offsetDebt(uint256 _amount, address _target)
        external
        returns (uint256 _attributions);
    function repayDebt(uint256 _amount, address _target) external;
    function debts(address _debtor) external view returns (uint256);
    function transferDebt(uint256 _amount) external;
    function withdrawRedundant(address _token, address _to) external;
    function setController(address _controller) external;
    function setKeeper(address _keeper) external;
}
contract CDSTemplate is InsureDAOERC20, ICDSTemplate, IUniversalMarket {
    event Deposit(address indexed depositor, uint256 amount, uint256 mint);
    event Fund(address indexed depositor, uint256 amount, uint256 attribution);
    event Defund(
        address indexed depositor,
        uint256 amount,
        uint256 attribution
    );
    event WithdrawRequested(
        address indexed withdrawer,
        uint256 amount,
        uint256 time
    );
    event Withdraw(address indexed withdrawer, uint256 amount, uint256 retVal);
    event Compensated(address indexed index, uint256 amount);
    event Paused(bool paused);
    event MetadataChanged(string metadata);
    bool public initialized;
    bool public paused;
    string public metadata;
    IParameters public parameters;
    IRegistry public registry;
    IVault public vault;
    uint256 public surplusPool;
    uint256 public crowdPool;
    uint256 public constant MAGIC_SCALE_1E6 = 1e6; 
    struct Withdrawal {
        uint256 timestamp;
        uint256 amount;
    }
    mapping(address => Withdrawal) public withdrawalReq;
    modifier onlyOwner() {
        require(
            msg.sender == parameters.getOwner(),
            "ERROR: ONLY_OWNER"
        );
        _;
    }
    constructor() {
        initialized = true;
    }
    function initialize(
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external override{
        require(
            initialized == false &&
                bytes(_metaData).length > 0 &&
                _references[0] != address(0) &&
                _references[1] != address(0) &&
                _references[2] != address(0),
            "ERROR: INITIALIZATION_BAD_CONDITIONS"
        );
        initialized = true;
        string memory _name = "InsureDAO-CDS";
        string memory _symbol = "iCDS";
        uint8 _decimals = IERC20Metadata(_references[0]).decimals();
        initializeToken(_name, _symbol, _decimals);
        parameters = IParameters(_references[2]);
        vault = IVault(parameters.getVault(_references[0]));
        registry = IRegistry(_references[1]);
        metadata = _metaData;
    }
    function deposit(uint256 _amount) external returns (uint256 _mintAmount) {
        require(paused == false, "ERROR: PAUSED");
        require(_amount > 0, "ERROR: DEPOSIT_ZERO");
        uint256 _liquidity = vault.attributionValue(crowdPool); 
        uint256 _supply = totalSupply();
        crowdPool += vault.addValue(_amount, msg.sender, address(this)); 
        if (_supply > 0 && _liquidity > 0) {
            _mintAmount = (_amount * _supply) / _liquidity;
        } else if (_supply > 0 && _liquidity == 0) {
            _mintAmount = _amount * _supply; 
        } else {
            _mintAmount = _amount;
        }
        emit Deposit(msg.sender, _amount, _mintAmount);
        _mint(msg.sender, _mintAmount);
    }
    function fund(uint256 _amount) external {
        require(paused == false, "ERROR: PAUSED");
        uint256 _attribution = vault.addValue(
            _amount,
            msg.sender,
            address(this)
        );
        surplusPool += _attribution;
        emit Fund(msg.sender, _amount, _attribution);
    }
    function defund(uint256 _amount) external override onlyOwner {
        require(paused == false, "ERROR: PAUSED");
        uint256 _attribution = vault.withdrawValue(_amount, msg.sender);
        surplusPool -= _attribution;
        emit Defund(msg.sender, _amount, _attribution);
    }
    function requestWithdraw(uint256 _amount) external {
        uint256 _balance = balanceOf(msg.sender);
        require(_balance >= _amount, "ERROR: REQUEST_EXCEED_BALANCE");
        require(_amount > 0, "ERROR: REQUEST_ZERO");
        withdrawalReq[msg.sender].timestamp = block.timestamp;
        withdrawalReq[msg.sender].amount = _amount;
        emit WithdrawRequested(msg.sender, _amount, block.timestamp);
    }
    function withdraw(uint256 _amount) external returns (uint256 _retVal) {
        Withdrawal memory request = withdrawalReq[msg.sender];
        require(paused == false, "ERROR: PAUSED");
        require(
            request.timestamp +
                parameters.getLockup(msg.sender) <
                block.timestamp,
            "ERROR: WITHDRAWAL_QUEUE"
        );
        require(
            request.timestamp +
                parameters.getLockup(msg.sender) +
                parameters.getWithdrawable(msg.sender) >
                block.timestamp,
            "ERROR: WITHDRAWAL_NO_ACTIVE_REQUEST"
        );
        require(
            request.amount >= _amount,
            "ERROR: WITHDRAWAL_EXCEEDED_REQUEST"
        );
        require(_amount > 0, "ERROR: WITHDRAWAL_ZERO");
        _retVal = (vault.attributionValue(crowdPool) * _amount) / totalSupply();
        request.amount -= _amount;
        _burn(msg.sender, _amount);
        crowdPool -= vault.withdrawValue(_retVal, msg.sender);
        emit Withdraw(msg.sender, _amount, _retVal);
    }
    function compensate(uint256 _amount)
        external
        override
        returns (uint256 _compensated)
    {
        require(registry.isListed(msg.sender));
        uint256 _available = vault.underlyingValue(address(this));
        uint256 _crowdAttribution = crowdPool;
        uint256 _surplusAttribution = surplusPool;
        uint256 _attributionLoss;
        if (_available >= _amount) {
            _compensated = _amount;
            _attributionLoss = vault.transferValue(_amount, msg.sender);
            emit Compensated(msg.sender, _amount);
        } else {
            _compensated = _available;
            _attributionLoss = vault.transferValue(_available, msg.sender);
            emit Compensated(msg.sender, _available);
        }
        uint256 _crowdPoolLoss = 
            (_crowdAttribution * _attributionLoss) /
            (_crowdAttribution + _surplusAttribution);
        crowdPool -= _crowdPoolLoss;
        surplusPool -= (_attributionLoss - _crowdPoolLoss);
    }
    function totalLiquidity() public view returns (uint256 _balance) {
        return vault.underlyingValue(address(this));
    }
    function rate() external view returns (uint256) {
        if (totalSupply() > 0) {
            return
                (vault.attributionValue(crowdPool) * MAGIC_SCALE_1E6) /
                totalSupply();
        } else {
            return 0;
        }
    }
    function valueOfUnderlying(address _owner) public view returns (uint256) {
        uint256 _balance = balanceOf(_owner);
        if (_balance == 0) {
            return 0;
        } else {
            return
                _balance * vault.attributionValue(crowdPool) / totalSupply();
        }
    }
    function changeMetadata(string calldata _metadata)
        external
        override
        onlyOwner
    {
        metadata = _metadata;
        emit MetadataChanged(_metadata);
    }
    function setPaused(bool _state) external override onlyOwner {
        if (paused != _state) {
            paused = _state;
            emit Paused(_state);
        }
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (from != address(0)) {
            uint256 _after = balanceOf(from) - amount;
            if (_after < withdrawalReq[from].amount) {
                withdrawalReq[from].amount = _after;
            }
        }
    }
}
interface IFactory {
    function approveTemplate(
        IUniversalMarket _template,
        bool _approval,
        bool _isOpen,
        bool _duplicate
    ) external;
    function approveReference(
        IUniversalMarket _template,
        uint256 _slot,
        address _target,
        bool _approval
    ) external;
    function setCondition(
        IUniversalMarket _template,
        uint256 _slot,
        uint256 _target
    ) external;
    function createMarket(
        IUniversalMarket _template,
        string memory _metaData,
        uint256[] memory _conditions,
        address[] memory _references
    ) external returns (address);
}
interface IOwnership {
    function owner() external view returns (address);
    function futureOwner() external view returns (address);
    function commitTransferOwnership(address newOwner) external;
    function acceptTransferOwnership() external;
}
library console {
    address constant CONSOLE_ADDRESS =
        0x000000000000000000636F6e736F6c652e6c6f67;
    function _sendLogPayloadImplementation(bytes memory payload) internal view {
        address consoleAddress = CONSOLE_ADDRESS;
        assembly {
            pop(
                staticcall(
                    gas(),
                    consoleAddress,
                    add(payload, 32),
                    mload(payload),
                    0,
                    0
                )
            )
        }
    }
    function _castToPure(
      function(bytes memory) internal view fnIn
    ) internal pure returns (function(bytes memory) pure fnOut) {
        assembly {
            fnOut := fnIn
        }
    }
    function _sendLogPayload(bytes memory payload) internal pure {
        _castToPure(_sendLogPayloadImplementation)(payload);
    }
    function log() internal pure {
        _sendLogPayload(abi.encodeWithSignature("log()"));
    }
    function logInt(int256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
    }
    function logUint(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }
    function logString(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }
    function logBool(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }
    function logAddress(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }
    function logBytes(bytes memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
    }
    function logBytes1(bytes1 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
    }
    function logBytes2(bytes2 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
    }
    function logBytes3(bytes3 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
    }
    function logBytes4(bytes4 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
    }
    function logBytes5(bytes5 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
    }
    function logBytes6(bytes6 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
    }
    function logBytes7(bytes7 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
    }
    function logBytes8(bytes8 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
    }
    function logBytes9(bytes9 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
    }
    function logBytes10(bytes10 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
    }
    function logBytes11(bytes11 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
    }
    function logBytes12(bytes12 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
    }
    function logBytes13(bytes13 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
    }
    function logBytes14(bytes14 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
    }
    function logBytes15(bytes15 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
    }
    function logBytes16(bytes16 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
    }
    function logBytes17(bytes17 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
    }
    function logBytes18(bytes18 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
    }
    function logBytes19(bytes19 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
    }
    function logBytes20(bytes20 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
    }
    function logBytes21(bytes21 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
    }
    function logBytes22(bytes22 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
    }
    function logBytes23(bytes23 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
    }
    function logBytes24(bytes24 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
    }
    function logBytes25(bytes25 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
    }
    function logBytes26(bytes26 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
    }
    function logBytes27(bytes27 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
    }
    function logBytes28(bytes28 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
    }
    function logBytes29(bytes29 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
    }
    function logBytes30(bytes30 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
    }
    function logBytes31(bytes31 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
    }
    function logBytes32(bytes32 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
    }
    function log(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }
    function log(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }
    function log(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }
    function log(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }
    function log(uint256 p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
    }
    function log(uint256 p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
    }
    function log(uint256 p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
    }
    function log(uint256 p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
    }
    function log(string memory p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
    }
    function log(string memory p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
    }
    function log(string memory p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
    }
    function log(string memory p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
    }
    function log(bool p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
    }
    function log(bool p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
    }
    function log(bool p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
    }
    function log(bool p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
    }
    function log(address p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
    }
    function log(address p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
    }
    function log(address p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
    }
    function log(address p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
    }
    function log(uint256 p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
    }
    function log(string memory p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
    }
    function log(string memory p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
    }
    function log(string memory p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
    }
    function log(string memory p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
    }
    function log(bool p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
    }
    function log(bool p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
    }
    function log(bool p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
    }
    function log(bool p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
    }
    function log(bool p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
    }
    function log(bool p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
    }
    function log(bool p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
    }
    function log(bool p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
    }
    function log(address p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
    }
    function log(address p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
    }
    function log(address p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
    }
    function log(address p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
    }
    function log(address p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
    }
    function log(address p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
    }
    function log(address p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
    }
    function log(address p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
    }
    function log(address p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
    }
    function log(address p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
    }
    function log(address p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
    }
    function log(address p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
    }
}
contract Factory is IFactory {
    event MarketCreated(
        address indexed market,
        address indexed template,
        string _metaData,
        uint256[] conditions,
        address[] references
    );
    event TemplateApproval(
        IUniversalMarket indexed template,
        bool approval,
        bool isOpen,
        bool duplicate
    );
    event ReferenceApproval(
        IUniversalMarket indexed template,
        uint256 indexed slot,
        address target,
        bool approval
    );
    event ConditionApproval(
        IUniversalMarket indexed template,
        uint256 indexed slot,
        uint256 target
    );
    address[] public markets;
    struct Template {
        bool isOpen; 
        bool approval; 
        bool allowDuplicate; 
    }
    mapping(address => Template) public templates;
    mapping(address => mapping(uint256 => mapping(address => bool)))
        public reflist;
    mapping(address => mapping(uint256 => uint256)) public conditionlist;
    address public registry;
    IOwnership public ownership;
    modifier onlyOwner() {
        require(
            ownership.owner() == msg.sender,
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    constructor(address _registry, address _ownership) {
        registry = _registry;
        ownership = IOwnership(_ownership);
    }
    function approveTemplate(
        IUniversalMarket _template,
        bool _approval,
        bool _isOpen,
        bool _duplicate
    ) external override onlyOwner {
        require(address(_template) != address(0));
        templates[address(_template)].approval = _approval;
        templates[address(_template)].isOpen = _isOpen;
        templates[address(_template)].allowDuplicate = _duplicate;
        emit TemplateApproval(_template, _approval, _isOpen, _duplicate);
    }
    function approveReference(
        IUniversalMarket _template,
        uint256 _slot,
        address _target,
        bool _approval
    ) external override onlyOwner {
        require(
            templates[address(_template)].approval == true,
            "ERROR: UNAUTHORIZED_TEMPLATE"
        );
        reflist[address(_template)][_slot][_target] = _approval;
        emit ReferenceApproval(_template, _slot, _target, _approval);
    }
    function setCondition(
        IUniversalMarket _template,
        uint256 _slot,
        uint256 _target
    ) external override onlyOwner {
        require(
            templates[address(_template)].approval == true,
            "ERROR: UNAUTHORIZED_TEMPLATE"
        );
        conditionlist[address(_template)][_slot] = _target;
        emit ConditionApproval(_template, _slot, _target);
    }
    function createMarket(
        IUniversalMarket _template,
        string memory _metaData,
        uint256[] memory _conditions,
        address[] memory _references
    ) public override returns (address) {
        require(
            templates[address(_template)].approval == true,
            "ERROR: UNAUTHORIZED_TEMPLATE"
        );
        if (templates[address(_template)].isOpen == false) {
            require(
                ownership.owner() == msg.sender,
                "ERROR: UNAUTHORIZED_SENDER"
            );
        }
        if (_references.length > 0) {
            for (uint256 i = 0; i < _references.length; i++) {
                require(
                    reflist[address(_template)][i][_references[i]] == true ||
                        reflist[address(_template)][i][address(0)] == true,
                    "ERROR: UNAUTHORIZED_REFERENCE"
                );
            }
        }
        if (_conditions.length > 0) {
            for (uint256 i = 0; i < _conditions.length; i++) {
                if (conditionlist[address(_template)][i] > 0) {
                    _conditions[i] = conditionlist[address(_template)][i];
                }
            }
        }
        if (
            IRegistry(registry).confirmExistence(
                address(_template),
                _references[0]
            ) == false
        ) {
            IRegistry(registry).setExistence(
                address(_template),
                _references[0]
            );
        } else {
            if (templates[address(_template)].allowDuplicate == false) {
                revert("ERROR: DUPLICATE_MARKET");
            }
        }
        IUniversalMarket market = IUniversalMarket(
            _createClone(address(_template))
        );
        IRegistry(registry).supportMarket(address(market));
        markets.push(address(market));
        market.initialize(_metaData, _conditions, _references);
        emit MarketCreated(
            address(market),
            address(_template),
            _metaData,
            _conditions,
            _references
        );
        return address(market);
    }
    function _createClone(address target) internal returns (address result) {
        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }
}
interface IIndexTemplate {
    function compensate(uint256) external returns (uint256 _compensated);
    function lock() external;
    function resume() external;
    function setLeverage(uint256 _target) external;
    function set(
        uint256 _index,
        address _pool,
        uint256 _allocPoint
    ) external;
}
abstract contract IPoolTemplate {
    function allocateCredit(uint256 _credit)
        external
        virtual
        returns (uint256 _mintAmount);
    function allocatedCredit(address _index)
        external
        view
        virtual
        returns (uint256);
    function withdrawCredit(uint256 _credit)
        external
        virtual
        returns (uint256 _retVal);
    function availableBalance() public view virtual returns (uint256 _balance);
    function utilizationRate() public view virtual returns (uint256 _rate);
    function totalLiquidity() public view virtual returns (uint256 _balance);
    function totalCredit() external view virtual returns (uint256);
    function lockedAmount() external view virtual returns (uint256);
    function valueOfUnderlying(address _owner)
        public
        view
        virtual
        returns (uint256);
    function pendingPremium(address _index)
        external
        view
        virtual
        returns (uint256);
    function paused() external view virtual returns (bool);
    function applyCover(
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external virtual;
}
contract IndexTemplate is InsureDAOERC20, IIndexTemplate, IUniversalMarket {
    event Deposit(address indexed depositor, uint256 amount, uint256 mint);
    event WithdrawRequested(
        address indexed withdrawer,
        uint256 amount,
        uint256 time
    );
    event Withdraw(address indexed withdrawer, uint256 amount, uint256 retVal);
    event Compensated(address indexed index, uint256 amount);
    event Paused(bool paused);
    event Resumed();
    event Locked();
    event MetadataChanged(string metadata);
    event LeverageSet(uint256 target);
    event AllocationSet(
        uint256 indexed _index,
        address indexed pool,
        uint256 allocPoint
    );
    bool public initialized;
    bool public paused;
    bool public locked;
    uint256 public pendingEnd;
    string public metadata;
    IParameters public parameters;
    IVault public vault;
    IRegistry public registry;
    uint256 public totalAllocatedCredit; 
    mapping(address => uint256) public allocPoints; 
    uint256 public totalAllocPoint; 
    address[] public poolList; 
    uint256 public targetLev; 
    struct Withdrawal {
        uint256 timestamp;
        uint256 amount;
    }
    mapping(address => Withdrawal) public withdrawalReq;
    struct PoolStatus {
        uint256 current;
        uint256 available;
        uint256 allocation;
        address addr;
    }
    uint256 public constant MAGIC_SCALE_1E6 = 1e6; 
    modifier onlyOwner() {
        require(
            msg.sender == parameters.getOwner(),
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    constructor() {
        initialized = true;
    }
    function initialize(
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external override {
        require(
            initialized == false &&
                bytes(_metaData).length > 0 &&
                _references[0] != address(0) &&
                _references[1] != address(0) &&
                _references[2] != address(0),
            "ERROR: INITIALIZATION_BAD_CONDITIONS"
        );
        initialized = true;
        string memory _name = "InsureDAO-Index";
        string memory _symbol = "iIndex";
        uint8 _decimals = IERC20Metadata(_references[0]).decimals();
        initializeToken(_name, _symbol, _decimals);
        parameters = IParameters(_references[2]);
        vault = IVault(parameters.getVault(_references[0]));
        registry = IRegistry(_references[1]);
        metadata = _metaData;
    }
    function deposit(uint256 _amount) public returns (uint256 _mintAmount) {
        require(locked == false && paused == false, "ERROR: DEPOSIT_DISABLED");
        require(_amount > 0, "ERROR: DEPOSIT_ZERO");
        uint256 _supply = totalSupply();
        uint256 _totalLiquidity = totalLiquidity();
        vault.addValue(_amount, msg.sender, address(this));
        if (_supply > 0 && _totalLiquidity > 0) {
            _mintAmount = (_amount * _supply) / _totalLiquidity;
        } else if (_supply > 0 && _totalLiquidity == 0) {
            _mintAmount = _amount * _supply;
        } else {
            _mintAmount = _amount;
        }
        emit Deposit(msg.sender, _amount, _mintAmount);
        _mint(msg.sender, _mintAmount);
        uint256 _liquidityAfter = _totalLiquidity + _amount;
        uint256 _leverage = (totalAllocatedCredit * MAGIC_SCALE_1E6) /
            _liquidityAfter;
        if (targetLev - parameters.getLowerSlack(address(this)) > _leverage) {
            _adjustAlloc(_liquidityAfter);
        }
    }
    function requestWithdraw(uint256 _amount) external {
        uint256 _balance = balanceOf(msg.sender);
        require(_balance >= _amount, "ERROR: REQUEST_EXCEED_BALANCE");
        require(_amount > 0, "ERROR: REQUEST_ZERO");
        withdrawalReq[msg.sender].timestamp = block.timestamp;
        withdrawalReq[msg.sender].amount = _amount;
        emit WithdrawRequested(msg.sender, _amount, block.timestamp);
    }
    function withdraw(uint256 _amount) external returns (uint256 _retVal) {
        uint256 _liquidty = totalLiquidity();
        uint256 _lockup = parameters.getLockup(msg.sender);
        uint256 _requestTime = withdrawalReq[msg.sender].timestamp;
        _retVal = (_liquidty * _amount) / totalSupply();
        require(locked == false, "ERROR: WITHDRAWAL_PENDING");
        require(
            _requestTime + _lockup < block.timestamp,
            "ERROR: WITHDRAWAL_QUEUE"
        );
        require(
            _requestTime + _lockup + parameters.getWithdrawable(msg.sender) >
                block.timestamp,
            "ERROR: WITHDRAWAL_NO_ACTIVE_REQUEST"
        );
        require(
            withdrawalReq[msg.sender].amount >= _amount,
            "ERROR: WITHDRAWAL_EXCEEDED_REQUEST"
        );
        require(_amount > 0, "ERROR: WITHDRAWAL_ZERO");
        require(
            _retVal <= withdrawable(),
            "ERROR: WITHDRAW_INSUFFICIENT_LIQUIDITY"
        );
        withdrawalReq[msg.sender].amount -= _amount;
        _burn(msg.sender, _amount);
        uint256 _liquidityAfter = _liquidty - _retVal;
        if (_liquidityAfter > 0) {
            uint256 _leverage = (totalAllocatedCredit * MAGIC_SCALE_1E6) /
                _liquidityAfter;
            if (
                targetLev + parameters.getUpperSlack(address(this)) < _leverage
            ) {
                _adjustAlloc(_liquidityAfter);
            }
        } else {
            _adjustAlloc(0);
        }
        vault.withdrawValue(_retVal, msg.sender);
        emit Withdraw(msg.sender, _amount, _retVal);
    }
    function withdrawable() public view returns (uint256 _retVal) {
        uint256 _totalLiquidity = totalLiquidity();
        if(_totalLiquidity > 0){
            uint256 _length = poolList.length;
            uint256 _lowestAvailableRate = MAGIC_SCALE_1E6;
            uint256 _targetAllocPoint;
            uint256 _targetLockedCreditScore;
            for (uint256 i = 0; i < _length; i++) {
                address _poolAddress = poolList[i];
                uint256 _allocPoint = allocPoints[_poolAddress];
                if (_allocPoint > 0) {
                    uint256 _allocated = IPoolTemplate(_poolAddress)
                        .allocatedCredit(address(this));
                    uint256 _availableBalance = IPoolTemplate(_poolAddress)
                        .availableBalance();
                    if (_allocated > _availableBalance) {
                        uint256 _availableRate = (_availableBalance *
                            MAGIC_SCALE_1E6) / _allocated;
                        uint256 _lockedCredit = _allocated - _availableBalance;
                        if (i == 0 || _availableRate < _lowestAvailableRate) {
                            _lowestAvailableRate = _availableRate;
                            _targetLockedCreditScore = _lockedCredit;
                            _targetAllocPoint = _allocPoint;
                        }
                    }
                }
            }
            if (_lowestAvailableRate == MAGIC_SCALE_1E6) {
                _retVal = _totalLiquidity;
            } else {
                uint256 _necessaryAmount = _targetLockedCreditScore * totalAllocPoint /  _targetAllocPoint;
                _necessaryAmount = _necessaryAmount *  MAGIC_SCALE_1E6 / targetLev;
                if(_necessaryAmount < _totalLiquidity){
                    _retVal = _totalLiquidity - _necessaryAmount;
                }else{
                    _retVal = 0;
                }
            }
        }
    }
    function adjustAlloc() public {
        _adjustAlloc(totalLiquidity());
    }
    function _adjustAlloc(uint256 _liquidity) internal {
        uint256 _targetCredit = (targetLev * _liquidity) / MAGIC_SCALE_1E6;
        uint256 _allocatable = _targetCredit;
        uint256 _allocatablePoints = totalAllocPoint;
        uint256 _length = poolList.length;
        PoolStatus[] memory _poolList = new PoolStatus[](_length);
        for (uint256 i = 0; i < _length; i++) {
            address _pool = poolList[i];
            if (_pool != address(0)) {
                uint256 _allocation = allocPoints[_pool];
                uint256 _target = (_targetCredit * _allocation) /
                    _allocatablePoints;
                uint256 _current = IPoolTemplate(_pool).allocatedCredit(
                    address(this)
                );
                uint256 _available = IPoolTemplate(_pool).availableBalance();
                if (
                    (_current > _target && _current - _target > _available) ||
                    IPoolTemplate(_pool).paused() == true
                ) {
                    IPoolTemplate(_pool).withdrawCredit(_available);
                    totalAllocatedCredit -= _available;
                    _poolList[i].addr = address(0);
                    _allocatable -= _current - _available;
                    _allocatablePoints -= _allocation;
                } else {
                    _poolList[i].addr = _pool;
                    _poolList[i].current = _current;
                    _poolList[i].available = _available;
                    _poolList[i].allocation = _allocation;
                }
            }
        }
        for (uint256 i = 0; i < _length; i++) {
            if (_poolList[i].addr != address(0)) {
                uint256 _target = (_allocatable * _poolList[i].allocation) /
                    _allocatablePoints;
                uint256 _current = _poolList[i].current;
                uint256 _available = _poolList[i].available;
                if (_current > _target && _available != 0) {
                    uint256 _decrease = _current - _target;
                    IPoolTemplate(_poolList[i].addr).withdrawCredit(_decrease);
                    totalAllocatedCredit -= _decrease;
                }
                if (_current < _target) {
                    uint256 _allocate = _target - _current;
                    IPoolTemplate(_poolList[i].addr).allocateCredit(_allocate);
                    totalAllocatedCredit += _allocate;
                }
                if (_current == _target) {
                    IPoolTemplate(_poolList[i].addr).allocateCredit(0);
                }
            }
        }
    }
    function compensate(uint256 _amount)
        external
        override
        returns (uint256 _compensated)
    {
        require(
            allocPoints[msg.sender] > 0,
            "ERROR_COMPENSATE_UNAUTHORIZED_CALLER"
        );
        uint256 _value = vault.underlyingValue(address(this));
        if (_value >= _amount) {
            vault.offsetDebt(_amount, msg.sender);
            _compensated = _amount;
        } else {
            uint256 _shortage;
            if (totalLiquidity() < _amount) {
                _shortage = _amount - _value;
                uint256 _cds = ICDSTemplate(registry.getCDS(address(this)))
                    .compensate(_shortage);
                _compensated = _value + _cds;
            }
            vault.offsetDebt(_compensated, msg.sender);
        }
        adjustAlloc();
        emit Compensated(msg.sender, _compensated);
    }
    function resume() external override {
        uint256 _poolLength = poolList.length;
        for (uint256 i = 0; i < _poolLength; i++) {
            require(
                IPoolTemplate(poolList[i]).paused() == false,
                "ERROR: POOL_IS_PAUSED"
            );
        }
        locked = false;
        emit Resumed();
    }
    function lock() external override {
        require(allocPoints[msg.sender] > 0);
        locked = true;
        emit Locked();
    }
    function leverage() public view returns (uint256 _rate) {
        if (totalLiquidity() > 0) {
            return (totalAllocatedCredit * MAGIC_SCALE_1E6) / totalLiquidity();
        } else {
            return 0;
        }
    }
    function totalLiquidity() public view returns (uint256 _balance) {
        return vault.underlyingValue(address(this)) + _accruedPremiums();
    }
    function rate() external view returns (uint256) {
        if (totalSupply() > 0) {
            return (totalLiquidity() * MAGIC_SCALE_1E6) / totalSupply();
        } else {
            return 0;
        }
    }
    function valueOfUnderlying(address _owner) public view returns (uint256) {
        uint256 _balance = balanceOf(_owner);
        if (_balance == 0) {
            return 0;
        } else {
            return (_balance * totalLiquidity()) / totalSupply();
        }
    }
    function getAllPools() external view returns (address[] memory) {
        return poolList;
    }
    function setPaused(bool _state) external override onlyOwner {
        if (paused != _state) {
            paused = _state;
            emit Paused(_state);
        }
    }
    function changeMetadata(string calldata _metadata)
        external
        override
        onlyOwner
    {
        metadata = _metadata;
        emit MetadataChanged(_metadata);
    }
    function setLeverage(uint256 _target) external override onlyOwner {
        targetLev = _target;
        adjustAlloc();
        emit LeverageSet(_target);
    }
    function set(
        uint256 _index,
        address _pool,
        uint256 _allocPoint
    ) public override onlyOwner {
        require(registry.isListed(_pool), "ERROR:UNREGISTERED_POOL");
        require(
            _index <= parameters.getMaxList(address(this)),
            "ERROR: EXCEEEDED_MAX_INDEX"
        );
        uint256 _length = poolList.length;
        if (_length <= _index) {
            require(_length == _index, "ERROR: BAD_INDEX");
            poolList.push(_pool);
        } else {
            address _poolAddress = poolList[_index];
            if (_poolAddress != address(0) && _poolAddress != _pool) {
                uint256 _current = IPoolTemplate(_poolAddress).allocatedCredit(
                    address(this)
                );
                IPoolTemplate(_poolAddress).withdrawCredit(_current);
            }
            poolList[_index] = _pool;
        }
        if (totalAllocPoint > 0) {
            totalAllocPoint =
                totalAllocPoint -
                allocPoints[_pool] +
                _allocPoint;
        } else {
            totalAllocPoint = _allocPoint;
        }
        allocPoints[_pool] = _allocPoint;
        adjustAlloc();
        emit AllocationSet(_index, _pool, _allocPoint);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (from != address(0)) {
            uint256 _after = balanceOf(from) - amount;
            if (_after < withdrawalReq[from].amount) {
                withdrawalReq[from].amount = _after;
            }
        }
    }
    function _accruedPremiums() internal view returns (uint256 _totalValue) {
        for (uint256 i = 0; i < poolList.length; i++) {
            if (allocPoints[poolList[i]] > 0) {
                _totalValue =
                    _totalValue +
                    IPoolTemplate(poolList[i]).pendingPremium(address(this));
            }
        }
    }
}
library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}
contract ERC20 is IERC20 {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 value)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount)
        );
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue)
        );
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function _approve(
        address owner,
        address spender,
        uint256 value
    ) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount)
        );
    }
}
contract TestERC20Mock is ERC20 {
    string public name = "DAI";
    string public symbol = "DAI";
    uint8 public decimals = 18;
    constructor() {}
    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
contract ControllerMock {
    TestERC20Mock public token;
    IVault public vault;
    IOwnership public ownership;
    modifier onlyOwner() {
        require(ownership.owner() == msg.sender, 'Restricted: caller is not allowed to operate');
        _;
    }
    constructor(address _token, address _ownership) {
        token = TestERC20Mock(_token);
        ownership = IOwnership(_ownership);
    }
    function withdraw(address _to, uint256 _amount) external {
        require(msg.sender == address(vault));
        token.transfer(_to, _amount);
    }
    function valueAll() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
    function earn(address, uint256) external {
    }
    function setVault(address _address) external onlyOwner{
        vault = IVault(_address);
    }
    function yield() external onlyOwner{
        uint256 _amount = vault.utilize();
        uint256 _mint = (_amount * 5) / 10;
        token.mint(address(this), _mint);
    }
    function migrate(address) external {
    }
}
contract ERC20Mock is ERC20 {
    string public name = "USDC";
    string public symbol = "USDC";
    uint8 public decimals = 6;
    constructor(address _address) {
        _mint(_address, 1e20);
    }
    mapping(address => bool) public minted;
    function mint() public {
        require(minted[msg.sender] == false);
        minted[msg.sender] = true;
        _mint(msg.sender, 1e10);
    }
}
contract InsureDAOERC20Mock is InsureDAOERC20 {
    constructor() {}
    function initialize(
        string memory name_,
        string memory symbol_,
        uint8 decimals_
    ) external {
        initializeToken(name_, symbol_, decimals_);
    }
    function mint(address _account, uint256 _amount) external {
        _mint(_account, _amount);
    }
    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }
}
library MerkleProof {
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }
    function verifyCalldata(bytes32[] calldata proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        return processProofCalldata(proof, leaf) == root;
    }
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }
    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }
    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProof(proof, proofFlags, leaves) == root;
    }
    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32 root,
        bytes32[] memory leaves
    ) internal pure returns (bool) {
        return processMultiProofCalldata(proof, proofFlags, leaves) == root;
    }
    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }
        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }
    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) internal pure returns (bytes32 merkleRoot) {
        uint256 leavesLen = leaves.length;
        uint256 proofLen = proof.length;
        uint256 totalHashes = proofFlags.length;
        require(leavesLen + proofLen - 1 == totalHashes, "MerkleProof: invalid multiproof");
        bytes32[] memory hashes = new bytes32[](totalHashes);
        uint256 leafPos = 0;
        uint256 hashPos = 0;
        uint256 proofPos = 0;
        for (uint256 i = 0; i < totalHashes; i++) {
            bytes32 a = leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++];
            bytes32 b = proofFlags[i]
                ? (leafPos < leavesLen ? leaves[leafPos++] : hashes[hashPos++])
                : proof[proofPos++];
            hashes[i] = _hashPair(a, b);
        }
        if (totalHashes > 0) {
            require(proofPos == proofLen, "MerkleProof: invalid multiproof");
            unchecked {
                return hashes[totalHashes - 1];
            }
        } else if (leavesLen > 0) {
            return leaves[0];
        } else {
            return proof[0];
        }
    }
    function _hashPair(bytes32 a, bytes32 b) private pure returns (bytes32) {
        return a < b ? _efficientHash(a, b) : _efficientHash(b, a);
    }
    function _efficientHash(bytes32 a, bytes32 b) private pure returns (bytes32 value) {
        assembly {
            mstore(0x00, a)
            mstore(0x20, b)
            value := keccak256(0x00, 0x40)
        }
    }
}
contract PoolTemplate is InsureDAOERC20, IPoolTemplate, IUniversalMarket {
    event Deposit(address indexed depositor, uint256 amount, uint256 mint);
    event WithdrawRequested(
        address indexed withdrawer,
        uint256 amount,
        uint256 time
    );
    event Withdraw(address indexed withdrawer, uint256 amount, uint256 retVal);
    event Unlocked(uint256 indexed id, uint256 amount);
    event Insured(
        uint256 indexed id,
        uint256 amount,
        bytes32 target,
        uint256 startTime,
        uint256 endTime,
        address insured,
        uint256 premium
    );
    event Redeemed(
        uint256 indexed id,
        address insured,
        bytes32 target,
        uint256 amount,
        uint256 payout
    );
    event CoverApplied(
        uint256 pending,
        uint256 payoutNumerator,
        uint256 payoutDenominator,
        uint256 incidentTimestamp,
        bytes32 merkleRoot,
        string rawdata,
        string memo
    );
    event TransferInsurance(uint256 indexed id, address from, address to);
    event CreditIncrease(address indexed depositor, uint256 credit);
    event CreditDecrease(address indexed withdrawer, uint256 credit);
    event MarketStatusChanged(MarketStatus statusValue);
    event Paused(bool paused);
    event MetadataChanged(string metadata);
    bool public initialized;
    bool public override paused;
    string public metadata;
    IParameters public parameters;
    IRegistry public registry;
    IVault public vault;
    uint256 public attributionDebt; 
    uint256 public override lockedAmount; 
    uint256 public override totalCredit; 
    uint256 public rewardPerCredit; 
    uint256 public pendingEnd; 
    struct IndexInfo {
        uint256 credit; 
        uint256 rewardDebt; 
        bool exist; 
    }
    mapping(address => IndexInfo) public indicies;
    address[] public indexList;
    enum MarketStatus {
        Trading,
        Payingout
    }
    MarketStatus public marketStatus;
    struct Withdrawal {
        uint256 timestamp;
        uint256 amount;
    }
    mapping(address => Withdrawal) public withdrawalReq;
    struct Insurance {
        uint256 id; 
        uint256 startTime; 
        uint256 endTime; 
        uint256 amount; 
        bytes32 target; 
        address insured; 
        bool status; 
    }
    mapping(uint256 => Insurance) public insurances;
    uint256 public allInsuranceCount;
    struct Incident {
        uint256 payoutNumerator;
        uint256 payoutDenominator;
        uint256 incidentTimestamp;
        bytes32 merkleRoot;
    }
    Incident public incident;
    uint256 public constant MAGIC_SCALE_1E6 = 1e6; 
    modifier onlyOwner() {
        require(
            msg.sender == parameters.getOwner(),
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    constructor() {
        initialized = true;
    }
    function initialize(
        string calldata _metaData,
        uint256[] calldata _conditions,
        address[] calldata _references
    ) external override {
        require(
            initialized == false &&
                bytes(_metaData).length > 0 &&
                _references[0] != address(0) &&
                _references[1] != address(0) &&
                _references[2] != address(0) &&
                _references[3] != address(0) &&
                _references[4] != address(0) &&
                _conditions[0] <= _conditions[1],
            "ERROR: INITIALIZATION_BAD_CONDITIONS"
        );
        initialized = true;
        string memory _name = string(
            abi.encodePacked(
                "InsureDAO-",
                IERC20Metadata(_references[1]).name(),
                "-PoolInsurance"
            )
        );
        string memory _symbol = string(
            abi.encodePacked("i-", IERC20Metadata(_references[1]).symbol())
        );
        uint8 _decimals = IERC20Metadata(_references[0]).decimals();
        initializeToken(_name, _symbol, _decimals);
        registry = IRegistry(_references[2]);
        parameters = IParameters(_references[3]);
        vault = IVault(parameters.getVault(_references[1]));
        metadata = _metaData;
        marketStatus = MarketStatus.Trading;
        if (_conditions[1] > 0) {
            _depositFrom(_conditions[1], _references[4]);
        }
    }
    function deposit(uint256 _amount) public returns (uint256 _mintAmount) {
        require(
            marketStatus == MarketStatus.Trading && paused == false,
            "ERROR: DEPOSIT_DISABLED"
        );
        require(_amount > 0, "ERROR: DEPOSIT_ZERO");
        _mintAmount = worth(_amount);
        vault.addValue(_amount, msg.sender, address(this));
        emit Deposit(msg.sender, _amount, _mintAmount);
        _mint(msg.sender, _mintAmount);
    }
    function _depositFrom(uint256 _amount, address _from)
        internal
        returns (uint256 _mintAmount)
    {
        require(
            marketStatus == MarketStatus.Trading && paused == false,
            "ERROR: DEPOSIT_DISABLED"
        );
        require(_amount > 0, "ERROR: DEPOSIT_ZERO");
        _mintAmount = worth(_amount);
        vault.addValue(_amount, _from, address(this));
        emit Deposit(_from, _amount, _mintAmount);
        _mint(_from, _mintAmount);
    }
    function requestWithdraw(uint256 _amount) external {
        uint256 _balance = balanceOf(msg.sender);
        require(_balance >= _amount, "ERROR: REQUEST_EXCEED_BALANCE");
        require(_amount > 0, "ERROR: REQUEST_ZERO");
        withdrawalReq[msg.sender].timestamp = block.timestamp;
        withdrawalReq[msg.sender].amount = _amount;
        emit WithdrawRequested(msg.sender, _amount, block.timestamp);
    }
    function withdraw(uint256 _amount) external returns (uint256 _retVal) {
        uint256 _supply = totalSupply();
        require(_supply != 0, "ERROR: NO_AVAILABLE_LIQUIDITY");
        uint256 _liquidity = originalLiquidity();
        _retVal = (_amount * _liquidity) / _supply;
        require(
            marketStatus == MarketStatus.Trading,
            "ERROR: WITHDRAWAL_PENDING"
        );
        require(
            withdrawalReq[msg.sender].timestamp +
                parameters.getLockup(msg.sender) <
                block.timestamp,
            "ERROR: WITHDRAWAL_QUEUE"
        );
        require(
            withdrawalReq[msg.sender].timestamp +
                parameters.getLockup(msg.sender) +
                parameters.getWithdrawable(msg.sender) >
                block.timestamp,
            "ERROR: WITHDRAWAL_NO_ACTIVE_REQUEST"
        );
        require(
            withdrawalReq[msg.sender].amount >= _amount,
            "ERROR: WITHDRAWAL_EXCEEDED_REQUEST"
        );
        require(_amount > 0, "ERROR: WITHDRAWAL_ZERO");
        require(
            _retVal <= availableBalance(),
            "ERROR: WITHDRAW_INSUFFICIENT_LIQUIDITY"
        );
        withdrawalReq[msg.sender].amount -= _amount;
        _burn(msg.sender, _amount);
        vault.withdrawValue(_retVal, msg.sender);
        emit Withdraw(msg.sender, _amount, _retVal);
    }
    function unlockBatch(uint256[] calldata _ids) external {
        for (uint256 i = 0; i < _ids.length; i++) {
            unlock(_ids[i]);
        }
    }
    function unlock(uint256 _id) public {
        require(
            insurances[_id].status == true &&
                marketStatus == MarketStatus.Trading &&
                insurances[_id].endTime + parameters.getGrace(msg.sender) <
                block.timestamp,
            "ERROR: UNLOCK_BAD_COINDITIONS"
        );
        insurances[_id].status == false;
        lockedAmount = lockedAmount - insurances[_id].amount;
        emit Unlocked(_id, insurances[_id].amount);
    }
    function allocateCredit(uint256 _credit)
        external
        override
        returns (uint256 _pending)
    {
        require(
            IRegistry(registry).isListed(msg.sender),
            "ERROR: ALLOCATE_CREDIT_BAD_CONDITIONS"
        );
        IndexInfo storage _index = indicies[msg.sender];
        uint256 _rewardPerCredit = rewardPerCredit;
        if (_index.exist == false) {
            _index.exist = true;
            indexList.push(msg.sender);
        } else if (_index.credit > 0) {
            _pending = _sub(
                (_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6,
                _index.rewardDebt
            );
            if (_pending > 0) {
                vault.transferAttribution(_pending, msg.sender);
                attributionDebt -= _pending;
            }
        }
        if (_credit > 0) {
            totalCredit += _credit;
            _index.credit += _credit;
            emit CreditIncrease(msg.sender, _credit);
        }
        _index.rewardDebt =
            (_index.credit * _rewardPerCredit) /
            MAGIC_SCALE_1E6;
    }
    function withdrawCredit(uint256 _credit)
        external
        override
        returns (uint256 _pending)
    {
        IndexInfo storage _index = indicies[msg.sender];
        uint256 _rewardPerCredit = rewardPerCredit;
        require(
            IRegistry(registry).isListed(msg.sender) &&
                _index.credit >= _credit &&
                _credit <= availableBalance(),
            "ERROR: WITHDRAW_CREDIT_BAD_CONDITIONS"
        );
        _pending = _sub(
            (_index.credit * _rewardPerCredit) / MAGIC_SCALE_1E6,
            _index.rewardDebt
        );
        if (_credit > 0) {
            totalCredit -= _credit;
            _index.credit -= _credit;
            emit CreditDecrease(msg.sender, _credit);
        }
        if (_pending > 0) {
            vault.transferAttribution(_pending, msg.sender);
            attributionDebt -= _pending;
            _index.rewardDebt =
                (_index.credit * _rewardPerCredit) /
                MAGIC_SCALE_1E6;
        }
    }
    function insure(
        uint256 _amount,
        uint256 _maxCost,
        uint256 _span,
        bytes32 _target
    ) external returns (uint256) {
        uint256 _endTime = _span + block.timestamp;
        uint256 _premium = getPremium(_amount, _span);
        uint256 _fee = parameters.getFeeRate(msg.sender);
        require(
            _amount <= availableBalance(),
            "ERROR: INSURE_EXCEEDED_AVAILABLE_BALANCE"
        );
        require(_premium <= _maxCost, "ERROR: INSURE_EXCEEDED_MAX_COST");
        require(_span <= 365 days, "ERROR: INSURE_EXCEEDED_MAX_SPAN");
        require(
            parameters.getMinDate(msg.sender) <= _span,
            "ERROR: INSURE_SPAN_BELOW_MIN"
        );
        require(
            marketStatus == MarketStatus.Trading,
            "ERROR: INSURE_MARKET_PENDING"
        );
        require(paused == false, "ERROR: INSURE_MARKET_PAUSED");
        uint256 _liquidity = totalLiquidity();
        uint256 _totalCredit = totalCredit;
        uint256[2] memory _newAttribution = vault.addValueBatch(
            _premium,
            msg.sender,
            [address(this), parameters.getOwner()],
            [MAGIC_SCALE_1E6 - _fee, _fee]
        );
        uint256 _id = allInsuranceCount;
        lockedAmount += _amount;
        Insurance memory _insurance = Insurance(
            _id,
            block.timestamp,
            _endTime,
            _amount,
            _target,
            msg.sender,
            true
        );
        insurances[_id] = _insurance;
        allInsuranceCount += 1;
        if (_totalCredit > 0) {
            uint256 _attributionForIndex = (_newAttribution[0] * _totalCredit) /
                _liquidity;
            attributionDebt += _attributionForIndex;
            rewardPerCredit += ((_attributionForIndex * MAGIC_SCALE_1E6) /
                _totalCredit);
        }
        emit Insured(
            _id,
            _amount,
            _target,
            block.timestamp,
            _endTime,
            msg.sender,
            _premium
        );
        return _id;
    }
    function redeem(uint256 _id, bytes32[] calldata _merkleProof) external {
        Insurance storage _insurance = insurances[_id];
        require(_insurance.status == true, "ERROR: INSURANCE_NOT_ACTIVE");
        uint256 _payoutNumerator = incident.payoutNumerator;
        uint256 _payoutDenominator = incident.payoutDenominator;
        uint256 _incidentTimestamp = incident.incidentTimestamp;
        bytes32 _targets = incident.merkleRoot;
        require(
            marketStatus == MarketStatus.Payingout,
            "ERROR: NO_APPLICABLE_INCIDENT"
        );
        require(_insurance.insured == msg.sender, "ERROR: NOT_YOUR_INSURANCE");
        require(
            marketStatus == MarketStatus.Payingout &&
                _insurance.startTime <= _incidentTimestamp &&
                _insurance.endTime >= _incidentTimestamp,
            "ERROR: INSURANCE_NOT_APPLICABLE"
        );
        require(
            MerkleProof.verify(
                _merkleProof,
                _targets,
                keccak256(
                    abi.encodePacked(_insurance.target, _insurance.insured)
                )
            ) ||
                MerkleProof.verify(
                    _merkleProof,
                    _targets,
                    keccak256(abi.encodePacked(_insurance.target, address(0)))
                ),
            "ERROR: INSURANCE_EXEMPTED"
        );
        _insurance.status = false;
        lockedAmount -= _insurance.amount;
        uint256 _payoutAmount = (_insurance.amount * _payoutNumerator) /
            _payoutDenominator;
        vault.borrowValue(_payoutAmount, msg.sender);
        emit Redeemed(
            _id,
            msg.sender,
            _insurance.target,
            _insurance.amount,
            _payoutAmount
        );
    }
    function transferInsurance(uint256 _id, address _to) external {
        Insurance storage insurance = insurances[_id];
        require(
            _to != address(0) &&
                insurance.insured == msg.sender &&
                insurance.endTime >= block.timestamp &&
                insurance.status == true,
            "ERROR: INSURANCE_TRANSFER_BAD_CONDITIONS"
        );
        insurance.insured = _to;
        emit TransferInsurance(_id, msg.sender, _to);
    }
    function getPremium(uint256 _amount, uint256 _span)
        public
        view
        returns (uint256 premium)
    {
        return
            parameters.getPremium(
                _amount,
                _span,
                totalLiquidity(),
                lockedAmount,
                address(this)
            );
    }
    function applyCover(
        uint256 _pending,
        uint256 _payoutNumerator,
        uint256 _payoutDenominator,
        uint256 _incidentTimestamp,
        bytes32 _merkleRoot,
        string calldata _rawdata,
        string calldata _memo
    ) external override onlyOwner {
        require(paused == false, "ERROR: UNABLE_TO_APPLY");
        incident.payoutNumerator = _payoutNumerator;
        incident.payoutDenominator = _payoutDenominator;
        incident.incidentTimestamp = _incidentTimestamp;
        incident.merkleRoot = _merkleRoot;
        marketStatus = MarketStatus.Payingout;
        pendingEnd = block.timestamp + _pending;
        for (uint256 i = 0; i < indexList.length; i++) {
            if (indicies[indexList[i]].credit > 0) {
                IIndexTemplate(indexList[i]).lock();
            }
        }
        emit CoverApplied(
            _pending,
            _payoutNumerator,
            _payoutDenominator,
            _incidentTimestamp,
            _merkleRoot,
            _rawdata,
            _memo
        );
        emit MarketStatusChanged(marketStatus);
    }
    function resume() external {
        require(
            marketStatus == MarketStatus.Payingout &&
                pendingEnd < block.timestamp,
            "ERROR: UNABLE_TO_RESUME"
        );
        uint256 _debt = vault.debts(address(this));
        uint256 _totalCredit = totalCredit;
        uint256 _deductionFromIndex = (_debt * _totalCredit * MAGIC_SCALE_1E6) /
            totalLiquidity();
        uint256 _actualDeduction;
        for (uint256 i = 0; i < indexList.length; i++) {
            address _index = indexList[i];
            uint256 _credit = indicies[_index].credit;
            if (_credit > 0) {
                uint256 _shareOfIndex = (_credit * MAGIC_SCALE_1E6) /
                    _totalCredit;
                uint256 _redeemAmount = _divCeil(
                    _deductionFromIndex,
                    _shareOfIndex
                );
                _actualDeduction += IIndexTemplate(_index).compensate(
                    _redeemAmount
                );
            }
        }
        uint256 _deductionFromPool = _debt -
            _deductionFromIndex /
            MAGIC_SCALE_1E6;
        uint256 _shortage = _deductionFromIndex /
            MAGIC_SCALE_1E6 -
            _actualDeduction;
        if (_deductionFromPool > 0) {
            vault.offsetDebt(_deductionFromPool, address(this));
        }
        vault.transferDebt(_shortage);
        marketStatus = MarketStatus.Trading;
        emit MarketStatusChanged(MarketStatus.Trading);
    }
    function rate() external view returns (uint256) {
        if (totalSupply() > 0) {
            return (originalLiquidity() * MAGIC_SCALE_1E6) / totalSupply();
        } else {
            return 0;
        }
    }
    function valueOfUnderlying(address _owner)
        public
        view
        override
        returns (uint256)
    {
        uint256 _balance = balanceOf(_owner);
        if (_balance == 0) {
            return 0;
        } else {
            return (_balance * originalLiquidity()) / totalSupply();
        }
    }
    function pendingPremium(address _index)
        external
        view
        override
        returns (uint256)
    {
        uint256 _credit = indicies[_index].credit;
        if (_credit == 0) {
            return 0;
        } else {
            return
                _sub(
                    (_credit * rewardPerCredit) / MAGIC_SCALE_1E6,
                    indicies[_index].rewardDebt
                );
        }
    }
    function worth(uint256 _value) public view returns (uint256 _amount) {
        uint256 _supply = totalSupply();
        uint256 _originalLiquidity = originalLiquidity();
        if (_supply > 0 && _originalLiquidity > 0) {
            _amount = (_value * _supply) / _originalLiquidity;
        } else if (_supply > 0 && _originalLiquidity == 0) {
            _amount = _value * _supply;
        } else {
            _amount = _value;
        }
    }
    function allocatedCredit(address _index)
        public
        view
        override
        returns (uint256)
    {
        return indicies[_index].credit;
    }
    function availableBalance()
        public
        view
        override
        returns (uint256 _balance)
    {
        if (totalLiquidity() > 0) {
            return totalLiquidity() - lockedAmount;
        } else {
            return 0;
        }
    }
    function utilizationRate() public view override returns (uint256 _rate) {
        if (lockedAmount > 0) {
            return (lockedAmount * MAGIC_SCALE_1E6) / totalLiquidity();
        } else {
            return 0;
        }
    }
    function totalLiquidity() public view override returns (uint256 _balance) {
        return originalLiquidity() + totalCredit;
    }
    function originalLiquidity() public view returns (uint256 _balance) {
        return
            vault.underlyingValue(address(this)) -
            vault.attributionValue(attributionDebt);
    }
    function setPaused(bool _state) external override onlyOwner {
        if (paused != _state) {
            paused = _state;
            emit Paused(_state);
        }
    }
    function changeMetadata(string calldata _metadata)
        external
        override
        onlyOwner
    {
        metadata = _metadata;
        emit MetadataChanged(_metadata);
    }
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, amount);
        if (from != address(0)) {
            uint256 _after = balanceOf(from) - amount;
            if (_after < withdrawalReq[from].amount) {
                withdrawalReq[from].amount = _after;
            }
        }
    }
    function _divCeil(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        if (a % b != 0) c = c + 1;
        return c;
    }
    function _sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a < b) {
            return 0;
        } else {
            return a - b;
        }
    }
}
contract MarketMock is PoolTemplate {
    constructor() {}
    function mint(address _to, uint256 _amount)public {
        _mint(_to, _amount);
    }
}
contract MinterMock {
    constructor() {}
    function emergency_mint(address _tokenOut, uint256 _amountOut) external {
        TestERC20Mock(_tokenOut).mint(msg.sender, _amountOut);
    }
}
contract TestPremiumModel {
    using SafeMath for uint256;
    using Address for address;
    constructor() {
    }
    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view returns (uint256) {
        return _amount / 10;
    }
}
contract Ownership is IOwnership {
    address private _owner;
    address private _futureOwner;
    event CommitNewOwnership(address indexed futureOwner);
    event AcceptNewOwnership(address indexed owner);
    constructor() {
        _owner = msg.sender;
        emit AcceptNewOwnership(_owner);
    }
    function owner() external view override returns (address) {
        return _owner;
    }
    function futureOwner() external view override returns (address) {
        return _futureOwner;
    }
    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    modifier onlyFutureOwner() {
        require(
            _futureOwner == msg.sender,
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    function commitTransferOwnership(address newOwner)
        external
        override
        onlyOwner
    {
        _futureOwner = newOwner;
        emit CommitNewOwnership(_futureOwner);
    }
    function acceptTransferOwnership() external override onlyFutureOwner {
        _owner = _futureOwner;
        emit AcceptNewOwnership(_owner);
    }
}
interface IPremiumModel {
    function getCurrentPremiumRate(
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view returns (uint256);
    function getPremiumRate(
        uint256 _amount,
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view returns (uint256);
    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view returns (uint256);
    function setPremiumParameters(
        uint256,
        uint256,
        uint256,
        uint256
    ) external;
}
contract Parameters is IParameters {
    event VaultSet(address indexed token, address vault);
    event FeeRateSet(address indexed target, uint256 rate);
    event PremiumSet(address indexed target, address model);
    event UpperSlack(address indexed target, uint256 rate);
    event LowerSlack(address indexed target, uint256 rate);
    event LockupSet(address indexed target, uint256 span);
    event GraceSet(address indexed target, uint256 span);
    event MinDateSet(address indexed target, uint256 span);
    event WithdrawableSet(address indexed target, uint256 span);
    event ConditionSet(bytes32 indexed ref, bytes32 condition);
    event MaxListSet(address target, uint256 max);
    address public ownership;
    mapping(address => address) private _vaults; 
    mapping(address => uint256) private _fee; 
    mapping(address => address) private _premium; 
    mapping(address => uint256) private _lowerSlack; 
    mapping(address => uint256) private _upperSlack; 
    mapping(address => uint256) private _grace; 
    mapping(address => uint256) private _lockup; 
    mapping(address => uint256) private _min; 
    mapping(address => uint256) private _maxList; 
    mapping(address => uint256) private _withdawable; 
    mapping(bytes32 => bytes32) private _conditions; 
    constructor(address _ownership) {
        ownership = _ownership;
    }
    modifier onlyOwner() {
        require(
            IOwnership(ownership).owner() == msg.sender,
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    function setVault(address _token, address _vault)
        external
        override
        onlyOwner
    {
        require(_vaults[_token] == address(0), "dev: already initialized");
        require(_vault != address(0), "dev: zero address");
        _vaults[_token] = _vault;
        emit VaultSet(_token, _vault);
    }
    function setLockup(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _lockup[_address] = _target;
        emit LockupSet(_address, _target);
    }
    function setGrace(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _grace[_address] = _target;
        emit GraceSet(_address, _target);
    }
    function setMinDate(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _min[_address] = _target;
        emit MinDateSet(_address, _target);
    }
    function setUpperSlack(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _upperSlack[_address] = _target;
        emit UpperSlack(_address, _target);
    }
    function setLowerSlack(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _lowerSlack[_address] = _target;
        emit LowerSlack(_address, _target);
    }
    function setWithdrawable(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _withdawable[_address] = _target;
        emit WithdrawableSet(_address, _target);
    }
    function setPremiumModel(address _address, address _target)
        external
        override
        onlyOwner
    {
        require(_target != address(0), "dev: zero address");
        _premium[_address] = _target;
        emit PremiumSet(_address, _target);
    }
    function setFeeRate(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _fee[_address] = _target;
        emit FeeRateSet(_address, _target);
    }
    function setMaxList(address _address, uint256 _target)
        external
        override
        onlyOwner
    {
        _maxList[_address] = _target;
        emit MaxListSet(_address, _target);
    }
    function setCondition(bytes32 _reference, bytes32 _target)
        external
        override
        onlyOwner
    {
        _conditions[_reference] = _target;
        emit ConditionSet(_reference, _target);
    }
    function getOwner() public view override returns (address) {
        return IOwnership(ownership).owner();
    }
    function getVault(address _token) external view override returns (address) {
        return _vaults[_token];
    }
    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount,
        address _target
    ) external view override returns (uint256) {
        if (_premium[_target] == address(0)) {
            return
                IPremiumModel(_premium[address(0)]).getPremium(
                    _amount,
                    _term,
                    _totalLiquidity,
                    _lockedAmount
                );
        } else {
            return
                IPremiumModel(_premium[_target]).getPremium(
                    _amount,
                    _term,
                    _totalLiquidity,
                    _lockedAmount
                );
        }
    }
    function getFeeRate(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_fee[_target] == 0) {
            return _fee[address(0)];
        } else {
            return _fee[_target];
        }
    }
    function getUpperSlack(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_upperSlack[_target] == 0) {
            return _upperSlack[address(0)];
        } else {
            return _upperSlack[_target];
        }
    }
    function getLowerSlack(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_lowerSlack[_target] == 0) {
            return _lowerSlack[address(0)];
        } else {
            return _lowerSlack[_target];
        }
    }
    function getLockup(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_lockup[_target] == 0) {
            return _lockup[address(0)];
        } else {
            return _lockup[_target];
        }
    }
    function getWithdrawable(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_withdawable[_target] == 0) {
            return _withdawable[address(0)];
        } else {
            return _withdawable[_target];
        }
    }
    function getGrace(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_grace[_target] == 0) {
            return _grace[address(0)];
        } else {
            return _grace[_target];
        }
    }
    function getMinDate(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_min[_target] == 0) {
            return _min[address(0)];
        } else {
            return _min[_target];
        }
    }
    function getMaxList(address _target)
        external
        view
        override
        returns (uint256)
    {
        if (_maxList[_target] == 0) {
            return _maxList[address(0)];
        } else {
            return _maxList[_target];
        }
    }
    function getCondition(bytes32 _reference)
        external
        view
        override
        returns (bytes32)
    {
        return _conditions[_reference];
    }
}
library ABDKMath64x64 {
  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;
  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  function fromInt (int256 x) internal pure returns (int128) {
    unchecked {
      require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (x << 64);
    }
  }
  function toInt (int128 x) internal pure returns (int64) {
    unchecked {
      return int64 (x >> 64);
    }
  }
  function fromUInt (uint256 x) internal pure returns (int128) {
    unchecked {
      require (x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (int256 (x << 64));
    }
  }
  function toUInt (int128 x) internal pure returns (uint64) {
    unchecked {
      require (x >= 0);
      return uint64 (uint128 (x >> 64));
    }
  }
  function from128x128 (int256 x) internal pure returns (int128) {
    unchecked {
      int256 result = x >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }
  function to128x128 (int128 x) internal pure returns (int256) {
    unchecked {
      return int256 (x) << 64;
    }
  }
  function add (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) + y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }
  function sub (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) - y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }
  function mul (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) * y >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }
  function muli (int128 x, int256 y) internal pure returns (int256) {
    unchecked {
      if (x == MIN_64x64) {
        require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
          y <= 0x1000000000000000000000000000000000000000000000000);
        return -y << 63;
      } else {
        bool negativeResult = false;
        if (x < 0) {
          x = -x;
          negativeResult = true;
        }
        if (y < 0) {
          y = -y; 
          negativeResult = !negativeResult;
        }
        uint256 absoluteResult = mulu (x, uint256 (y));
        if (negativeResult) {
          require (absoluteResult <=
            0x8000000000000000000000000000000000000000000000000000000000000000);
          return -int256 (absoluteResult); 
        } else {
          require (absoluteResult <=
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
          return int256 (absoluteResult);
        }
      }
    }
  }
  function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    unchecked {
      if (y == 0) return 0;
      require (x >= 0);
      uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      uint256 hi = uint256 (int256 (x)) * (y >> 128);
      require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      hi <<= 64;
      require (hi <=
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
      return hi + lo;
    }
  }
  function div (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      int256 result = (int256 (x) << 64) / y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }
  function divi (int256 x, int256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      bool negativeResult = false;
      if (x < 0) {
        x = -x; 
        negativeResult = true;
      }
      if (y < 0) {
        y = -y; 
        negativeResult = !negativeResult;
      }
      uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
      if (negativeResult) {
        require (absoluteResult <= 0x80000000000000000000000000000000);
        return -int128 (absoluteResult); 
      } else {
        require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int128 (absoluteResult); 
      }
    }
  }
  function divu (uint256 x, uint256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      uint128 result = divuu (x, y);
      require (result <= uint128 (MAX_64x64));
      return int128 (result);
    }
  }
  function neg (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return -x;
    }
  }
  function abs (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return x < 0 ? -x : x;
    }
  }
  function inv (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != 0);
      int256 result = int256 (0x100000000000000000000000000000000) / x;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }
  function avg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      return int128 ((int256 (x) + int256 (y)) >> 1);
    }
  }
  function gavg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 m = int256 (x) * int256 (y);
      require (m >= 0);
      require (m <
          0x4000000000000000000000000000000000000000000000000000000000000000);
      return int128 (sqrtu (uint256 (m)));
    }
  }
  function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
      bool negative = x < 0 && y & 1 == 1;
      uint256 absX = uint128 (x < 0 ? -x : x);
      uint256 absResult;
      absResult = 0x100000000000000000000000000000000;
      if (absX <= 0x10000000000000000) {
        absX <<= 63;
        while (y != 0) {
          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;
          if (y & 0x2 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;
          if (y & 0x4 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;
          if (y & 0x8 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;
          y >>= 4;
        }
        absResult >>= 64;
      } else {
        uint256 absXShift = 63;
        if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
        if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
        if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
        if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
        if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
        if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }
        uint256 resultShift = 0;
        while (y != 0) {
          require (absXShift < 64);
          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
            resultShift += absXShift;
            if (absResult > 0x100000000000000000000000000000000) {
              absResult >>= 1;
              resultShift += 1;
            }
          }
          absX = absX * absX >> 127;
          absXShift <<= 1;
          if (absX >= 0x100000000000000000000000000000000) {
              absX >>= 1;
              absXShift += 1;
          }
          y >>= 1;
        }
        require (resultShift < 64);
        absResult >>= 64 - resultShift;
      }
      int256 result = negative ? -int256 (absResult) : int256 (absResult);
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }
  function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
      require (x >= 0);
      return int128 (sqrtu (uint256 (int256 (x)) << 64));
    }
  }
  function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);
      int256 msb = 0;
      int256 xc = x;
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  
      int256 result = msb - 64 << 64;
      uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256 (b);
      }
      return int128 (result);
    }
  }
  function ln (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);
      return int128 (int256 (
          uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
    }
  }
  function exp_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); 
      if (x < -0x400000000000000000) return 0; 
      uint256 result = 0x80000000000000000000000000000000;
      if (x & 0x8000000000000000 > 0)
        result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (x & 0x4000000000000000 > 0)
        result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (x & 0x2000000000000000 > 0)
        result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (x & 0x1000000000000000 > 0)
        result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (x & 0x800000000000000 > 0)
        result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (x & 0x400000000000000 > 0)
        result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (x & 0x200000000000000 > 0)
        result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (x & 0x100000000000000 > 0)
        result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (x & 0x80000000000000 > 0)
        result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (x & 0x40000000000000 > 0)
        result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (x & 0x20000000000000 > 0)
        result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (x & 0x10000000000000 > 0)
        result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (x & 0x8000000000000 > 0)
        result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (x & 0x4000000000000 > 0)
        result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (x & 0x2000000000000 > 0)
        result = result * 0x1000162E525EE054754457D5995292026 >> 128;
      if (x & 0x1000000000000 > 0)
        result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (x & 0x800000000000 > 0)
        result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (x & 0x400000000000 > 0)
        result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (x & 0x200000000000 > 0)
        result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (x & 0x100000000000 > 0)
        result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (x & 0x80000000000 > 0)
        result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (x & 0x40000000000 > 0)
        result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (x & 0x20000000000 > 0)
        result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (x & 0x10000000000 > 0)
        result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (x & 0x8000000000 > 0)
        result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (x & 0x4000000000 > 0)
        result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (x & 0x2000000000 > 0)
        result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (x & 0x1000000000 > 0)
        result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (x & 0x800000000 > 0)
        result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (x & 0x400000000 > 0)
        result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (x & 0x200000000 > 0)
        result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (x & 0x100000000 > 0)
        result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (x & 0x80000000 > 0)
        result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (x & 0x40000000 > 0)
        result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (x & 0x20000000 > 0)
        result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (x & 0x10000000 > 0)
        result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (x & 0x8000000 > 0)
        result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (x & 0x4000000 > 0)
        result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (x & 0x2000000 > 0)
        result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (x & 0x1000000 > 0)
        result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (x & 0x800000 > 0)
        result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (x & 0x400000 > 0)
        result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (x & 0x200000 > 0)
        result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (x & 0x100000 > 0)
        result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (x & 0x80000 > 0)
        result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (x & 0x40000 > 0)
        result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (x & 0x20000 > 0)
        result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (x & 0x10000 > 0)
        result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (x & 0x8000 > 0)
        result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (x & 0x4000 > 0)
        result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (x & 0x2000 > 0)
        result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (x & 0x1000 > 0)
        result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (x & 0x800 > 0)
        result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (x & 0x400 > 0)
        result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (x & 0x200 > 0)
        result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (x & 0x100 > 0)
        result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (x & 0x80 > 0)
        result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (x & 0x40 > 0)
        result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (x & 0x20 > 0)
        result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (x & 0x10 > 0)
        result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (x & 0x8 > 0)
        result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (x & 0x4 > 0)
        result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (x & 0x2 > 0)
        result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (x & 0x1 > 0)
        result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;
      result >>= uint256 (int256 (63 - (x >> 64)));
      require (result <= uint256 (int256 (MAX_64x64)));
      return int128 (int256 (result));
    }
  }
  function exp (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); 
      if (x < -0x400000000000000000) return 0; 
      return exp_2 (
          int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }
  }
  function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    unchecked {
      require (y != 0);
      uint256 result;
      if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        result = (x << 64) / y;
      else {
        uint256 msb = 192;
        uint256 xc = x >> 192;
        if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
        if (xc >= 0x10000) { xc >>= 16; msb += 16; }
        if (xc >= 0x100) { xc >>= 8; msb += 8; }
        if (xc >= 0x10) { xc >>= 4; msb += 4; }
        if (xc >= 0x4) { xc >>= 2; msb += 2; }
        if (xc >= 0x2) msb += 1;  
        result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
        require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        uint256 hi = result * (y >> 128);
        uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        uint256 xh = x >> 192;
        uint256 xl = x << 64;
        if (xl < lo) xh -= 1;
        xl -= lo; 
        lo = hi << 128;
        if (xl < lo) xh -= 1;
        xl -= lo; 
        result += xh == hi >> 128 ? xl / y : 1;
      }
      require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return uint128 (result);
    }
  }
  function sqrtu (uint256 x) private pure returns (uint128) {
    unchecked {
      if (x == 0) return 0;
      else {
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
        if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
        if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
        if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
        if (xx >= 0x100) { xx >>= 8; r <<= 4; }
        if (xx >= 0x10) { xx >>= 4; r <<= 2; }
        if (xx >= 0x4) { r <<= 1; }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; 
        uint256 r1 = x / r;
        return uint128 (r < r1 ? r : r1);
      }
    }
  }
}
contract BondingPremium is IPremiumModel {
    using ABDKMath64x64 for uint256;
    using ABDKMath64x64 for int128;
    IOwnership public ownership;
    uint256 public k; 
    uint256 public c; 
    uint256 public b; 
    uint256 public T_1; 
    uint256 public constant DECIMAL = uint256(1e6); 
    uint256 public constant BASE = uint256(1e6); 
    uint256 public constant BASE_x2 = uint256(1e12); 
    uint256 public constant ADJUSTER = uint256(10); 
    modifier onlyOwner() {
        require(
            ownership.owner() == msg.sender,
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    constructor(address _ownership) {
        ownership = IOwnership(_ownership);
        k = 200100000;
        c = 10000;
        b = 1000;
        T_1 = 1000000 * DECIMAL;
    }
    function getCurrentPremiumRate(
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) public view override returns (uint256) {
        require(
            _totalLiquidity >= _lockedAmount,
            "ERROR: _lockedAmount > _totalLiquidity"
        );
        uint256 _util = (_lockedAmount * BASE) / _totalLiquidity;
        uint256 _premiumRate;
        uint256 T_0 = _totalLiquidity;
        if (T_0 > T_1) {
            T_0 = T_1;
        }
        uint256 a = (sqrt(
            (BASE_x2 * BASE_x2 * T_1 + 4 * k * T_0 * BASE_x2) / T_1
        ) - BASE_x2) / 2; 
        uint256 Q = (BASE - _util) + a / BASE; 
        _premiumRate =
            365 *
            (k * T_0 * BASE - a * Q * T_1) +
            Q *
            (c - b) *
            (T_1 - T_0) *
            BASE +
            b *
            Q *
            T_1 *
            BASE;
        _premiumRate = _premiumRate / Q / T_1 / BASE;
        return _premiumRate;
    }
    struct Temp {
        int128 u;
        int128 a;
        int128 BASE_temp;
    }
    function getPremiumRate(
        uint256 _amount,
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) public view override returns (uint256) {
        require(
            _amount + _lockedAmount <= _totalLiquidity,
            "exceed available balance"
        );
        if (_totalLiquidity == 0 || _amount == 0) {
            return 0;
        }
        uint256 u1 = BASE - ((_lockedAmount * BASE) / _totalLiquidity); 
        uint256 u2 = BASE -
            (((_lockedAmount + _amount) * BASE) / _totalLiquidity); 
        uint256 T_0 = _totalLiquidity;
        if (T_0 > T_1) {
            T_0 = T_1;
        }
        uint256 a = (sqrt(
            (BASE_x2 * BASE_x2 * T_1 + 4 * k * T_0 * BASE_x2) / T_1
        ) - BASE_x2) / 2; 
        Temp memory temp;
        temp.a = a.fromUInt();
        temp.BASE_temp = BASE.fromUInt();
        temp.a = temp.a.div(temp.BASE_temp);
        temp.u = u1.fromUInt();
        int128 ln_u1 = (temp.u).add(temp.a).ln();
        uint256 ln_res_u1 = ln_u1.mulu(k); 
        uint256 _premium_u1 = (365 * T_0 * ln_res_u1 * BASE) +
            u1 *
            ((T_1 - T_0) * c * BASE + T_0 * b * BASE) -
            T_1 *
            365 *
            a *
            u1;
        temp.u = u2.fromUInt();
        int128 ln_u2 = (temp.u).add(temp.a).ln();
        uint256 ln_res_u2 = ln_u2.mulu(k); 
        uint256 _premium_u2 = (365 * T_0 * ln_res_u2 * BASE) +
            u2 *
            ((T_1 - T_0) * c * BASE + T_0 * b * BASE) -
            T_1 *
            365 *
            a *
            u2;
        uint256 premiumRate = _premium_u1 - _premium_u2;
        premiumRate = premiumRate / T_1 / (u1 - u2) / BASE;
        return premiumRate;
    }
    function getPremium(
        uint256 _amount,
        uint256 _term,
        uint256 _totalLiquidity,
        uint256 _lockedAmount
    ) external view override returns (uint256) {
        require(_amount + _lockedAmount <= _totalLiquidity, "Amount exceeds.");
        require(_totalLiquidity != 0, "_totalLiquidity cannnot be 0");
        if (_amount == 0) {
            return 0;
        }
        uint256 premiumRate = getPremiumRate(
            _amount,
            _totalLiquidity,
            _lockedAmount
        );
        uint256 premium = (_amount * premiumRate * _term) / 365 days / BASE;
        return premium;
    }
    function setPremiumParameters(
        uint256 _multiplierPerYear,
        uint256 _initialBaseRatePerYear,
        uint256 _finalBaseRatePerYear,
        uint256 _goalTVL
    ) external override onlyOwner {
        require(
            _multiplierPerYear != 0 &&
                _initialBaseRatePerYear != 0 &&
                _finalBaseRatePerYear != 0 &&
                _goalTVL != 0,
            "ERROR_ZERO_VALUE_PROHIBITED"
        );
        k = _multiplierPerYear;
        c = _initialBaseRatePerYear;
        b = _finalBaseRatePerYear;
        T_1 = _goalTVL;
    }
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}
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
interface IController {
    function withdraw(address, uint256) external;
    function valueAll() external view returns (uint256);
    function earn(address, uint256) external;
    function migrate(address) external;
}
contract Vault is IVault {
    using SafeERC20 for IERC20;
    address public override token;
    IController public controller;
    IRegistry public registry;
    IOwnership public ownership;
    mapping(address => uint256) public override debts;
    mapping(address => uint256) public attributions;
    uint256 public totalAttributions;
    address public keeper; 
    uint256 public balance; 
    uint256 public totalDebt; 
    uint256 public constant MAGIC_SCALE_1E6 = 1e6; 
    event ControllerSet(address controller);
    modifier onlyOwner() {
        require(
            ownership.owner() == msg.sender,
            "Restricted: caller is not allowed to operate"
        );
        _;
    }
    modifier onlyMarket() {
        require(
            IRegistry(registry).isListed(msg.sender),
            "ERROR_ONLY_MARKET"
        );
        _;
    }
    constructor(
        address _token,
        address _registry,
        address _controller,
        address _ownership
    ) {
        require(_token != address(0));
        require(_registry != address(0));
        require(_ownership != address(0));
        token = _token;
        registry = IRegistry(_registry);
        controller = IController(_controller);
        ownership = IOwnership(_ownership);
    }
    function addValueBatch(
        uint256 _amount,
        address _from,
        address[2] memory _beneficiaries,
        uint256[2] memory _shares
    ) external override onlyMarket returns (uint256[2] memory _allocations) {
        require(_shares[0] + _shares[1] == 1000000, "ERROR_INCORRECT_SHARE");
        uint256 _attributions;
        if (totalAttributions == 0) {
            _attributions = _amount;
        } else {
            uint256 _pool = valueAll();
            _attributions = (_amount * totalAttributions) / _pool;
        }
        IERC20(token).safeTransferFrom(_from, address(this), _amount);
        balance += _amount;
        totalAttributions += _attributions;
        for (uint128 i = 0; i < 2; i++) {
            uint256 _allocation = (_shares[i] * _attributions) / MAGIC_SCALE_1E6;
            attributions[_beneficiaries[i]] += _allocation;
            _allocations[i] = _allocation;
        }
    }
    function addValue(
        uint256 _amount,
        address _from,
        address _beneficiary
    ) external override onlyMarket returns (uint256 _attributions) {
        if (totalAttributions == 0) {
            _attributions = _amount;
        } else {
            uint256 _pool = valueAll();
            _attributions = (_amount * totalAttributions) / _pool;
        }
        IERC20(token).safeTransferFrom(_from, address(this), _amount);
        balance += _amount;
        totalAttributions += _attributions;
        attributions[_beneficiary] += _attributions;
    }
    function withdrawValue(uint256 _amount, address _to)
        external
        override
        returns (uint256 _attributions)
    {
        require(
            attributions[msg.sender] > 0 &&
                underlyingValue(msg.sender) >= _amount,
            "ERROR_WITHDRAW-VALUE_BADCONDITOONS"
        );
        _attributions = (totalAttributions * _amount) / valueAll();
        attributions[msg.sender] -= _attributions;
        totalAttributions -= _attributions;
        if (available() < _amount) {
            uint256 _shortage = _amount - available();
            _unutilize(_shortage);
            assert(available() >= _amount);
        }
        balance -= _amount;
        IERC20(token).safeTransfer(_to, _amount);
    }
    function transferValue(uint256 _amount, address _destination)
        external
        override
        returns (uint256 _attributions)
    {
        require(
            attributions[msg.sender] > 0 &&
                underlyingValue(msg.sender) >= _amount,
            "ERROR_TRANSFER-VALUE_BADCONDITOONS"
        );
        _attributions = (_amount * totalAttributions) / valueAll();
        attributions[msg.sender] -= _attributions;
        attributions[_destination] += _attributions;
    }
    function borrowValue(uint256 _amount, address _to) external onlyMarket override {
        debts[msg.sender] += _amount;
        totalDebt += _amount;
        IERC20(token).safeTransfer(_to, _amount);
    }
    function offsetDebt(uint256 _amount, address _target)
        external
        override
        returns (uint256 _attributions)
    {
        require(
            attributions[msg.sender] > 0 &&
                underlyingValue(msg.sender) >= _amount,
            "ERROR_REPAY_DEBT_BADCONDITOONS"
        );
        _attributions = (_amount * totalAttributions) / valueAll();
        attributions[msg.sender] -= _attributions;
        totalAttributions -= _attributions;
        balance -= _amount;
        debts[_target] -= _amount;
        totalDebt -= _amount;
    }
    function transferDebt(uint256 _amount) external onlyMarket override {
        if(_amount != 0){
            debts[msg.sender] -= _amount;
            debts[address(0)] += _amount;
        }
    }
    function repayDebt(uint256 _amount, address _target) external override {
        uint256 _debt = debts[_target];
        if (_debt >= _amount) {
            debts[_target] -= _amount;
            totalDebt -= _amount;
            IERC20(token).safeTransferFrom(msg.sender, address(this), _amount);
        } else {
            debts[_target] = 0;
            totalDebt -= _debt;
            IERC20(token).safeTransferFrom(msg.sender, address(this), _debt);
        }
    }
    function withdrawAttribution(uint256 _attribution, address _to)
        external
        override
        returns (uint256 _retVal)
    {
        _retVal = _withdrawAttribution(_attribution, _to);
    }
    function withdrawAllAttribution(address _to)
        external
        override
        returns (uint256 _retVal)
    {
        _retVal = _withdrawAttribution(attributions[msg.sender], _to);
    }
    function _withdrawAttribution(uint256 _attribution, address _to)
        internal
        returns (uint256 _retVal)
    {
        require(
            attributions[msg.sender] >= _attribution,
            "ERROR_WITHDRAW-ATTRIBUTION_BADCONDITOONS"
        );
        _retVal = (_attribution * valueAll()) / totalAttributions;
        attributions[msg.sender] -= _attribution;
        totalAttributions -= _attribution;
        if (available() < _retVal) {
            uint256 _shortage = _retVal - available();
            _unutilize(_shortage);
        }
        balance -= _retVal;
        IERC20(token).safeTransfer(_to, _retVal);
    }
    function transferAttribution(uint256 _amount, address _destination)
        external
        override
    {
        require(_destination != address(0), "ERROR_ZERO_ADDRESS");
        require(
            _amount != 0 && attributions[msg.sender] >= _amount,
            "ERROR_TRANSFER-ATTRIBUTION_BADCONDITOONS"
        );
        attributions[msg.sender] -= _amount;
        attributions[_destination] += _amount;
    }
    function utilize() external override returns (uint256 _amount) {
        if (keeper != address(0)) {
            require(msg.sender == keeper, "ERROR_NOT_KEEPER");
        }
        _amount = available(); 
        if (_amount > 0) {
            IERC20(token).safeTransfer(address(controller), _amount);
            balance -= _amount;
            controller.earn(address(token), _amount);
        }
    }
    function attributionOf(address _target)
        external
        view
        override
        returns (uint256)
    {
        return attributions[_target];
    }
    function attributionAll() external view returns (uint256) {
        return totalAttributions;
    }
    function attributionValue(uint256 _attribution)
        external
        view
        override
        returns (uint256)
    {
        if (totalAttributions > 0 && _attribution > 0) {
            return (_attribution * valueAll()) / totalAttributions;
        } else {
            return 0;
        }
    }
    function underlyingValue(address _target)
        public
        view
        override
        returns (uint256)
    {
        if (attributions[_target] > 0) {
            return (valueAll() * attributions[_target]) / totalAttributions;
        } else {
            return 0;
        }
    }
    function valueAll() public view returns (uint256) {
        if (address(controller) != address(0)) {
            return balance + controller.valueAll();
        } else {
            return balance;
        }
    }
    function _unutilize(uint256 _amount) internal {
        require(address(controller) != address(0), "ERROR_CONTROLLER_NOT_SET");
        controller.withdraw(address(this), _amount);
        balance += _amount;
    }
    function available() public view returns (uint256) {
        return balance - totalDebt;
    }
    function getPricePerFullShare() public view returns (uint256) {
        return (valueAll() * MAGIC_SCALE_1E6) / totalAttributions;
    }
    function withdrawRedundant(address _token, address _to)
        external
        override
        onlyOwner
    {
        if (
            _token == address(token) &&
            balance < IERC20(token).balanceOf(address(this))
        ) {
            uint256 _redundant = IERC20(token).balanceOf(address(this)) -
                balance;
            IERC20(token).safeTransfer(_to, _redundant);
        } else if (IERC20(_token).balanceOf(address(this)) > 0) {
            IERC20(_token).safeTransfer(
                _to,
                IERC20(_token).balanceOf(address(this))
            );
        }
    }
    function setController(address _controller) public override onlyOwner {
        require(_controller != address(0), "ERROR_ZERO_ADDRESS");
        if (address(controller) != address(0)) {
            controller.migrate(address(_controller));
            controller = IController(_controller);
        } else {
            controller = IController(_controller);
        }
        emit ControllerSet(_controller);
    }
    function setKeeper(address _keeper) external override onlyOwner {
        if (keeper != _keeper) {
            keeper = _keeper;
        }
    }
}
contract SimplePoolMock {
    constructor() {}
    uint256 u;
    function utilizationRate() external view returns (uint256) {
        return u;
    }
    function changeU(uint256 _u) external {
        u = _u;
    }
}