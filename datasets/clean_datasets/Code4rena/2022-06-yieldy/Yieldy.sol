pragma solidity 0.8.9;
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./YieldyStorage.sol";
import "../libraries/ERC20PermitUpgradeable.sol";
contract Yieldy is
    YieldyStorage,
    ERC20PermitUpgradeable,
    AccessControlUpgradeable
{
    event LogSupply(
        uint256 indexed epoch,
        uint256 timestamp,
        uint256 totalSupply
    );
    event LogRebase(uint256 indexed epoch, uint256 rebase, uint256 index);
    function initialize(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint8 _decimal
    ) external initializer {
        ERC20Upgradeable.__ERC20_init(_tokenName, _tokenSymbol);
        ERC20PermitUpgradeable.__ERC20Permit_init(_tokenName);
        AccessControlUpgradeable.__AccessControl_init();
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _setRoleAdmin(MINTER_BURNER_ROLE, ADMIN_ROLE);
        _setRoleAdmin(REBASE_ROLE, ADMIN_ROLE);
        decimal = _decimal;
        WAD = 10**decimal;
        rebasingCreditsPerToken = WAD;
        _setIndex(WAD);
    }
    function initializeStakingContract(address _stakingContract)
        external
        onlyRole(ADMIN_ROLE)
    {
        require(stakingContract == address(0), "Already Initialized");
        require(_stakingContract != address(0), "Invalid address");
        stakingContract = _stakingContract;
        _setupRole(MINTER_BURNER_ROLE, _stakingContract);
        _setupRole(REBASE_ROLE, _stakingContract);
    }
    function _setIndex(uint256 _index) internal {
        index = creditsForTokenBalance(_index);
    }
    function rebase(uint256 _profit, uint256 _epoch)
        external
        onlyRole(REBASE_ROLE)
    {
        uint256 currentTotalSupply = _totalSupply;
        require(_totalSupply > 0, "Can't rebase if not circulating");
        if (_profit == 0) {
            emit LogSupply(_epoch, block.timestamp, currentTotalSupply);
            emit LogRebase(_epoch, 0, getIndex());
        } else {
            uint256 updatedTotalSupply = currentTotalSupply + _profit;
            if (updatedTotalSupply > MAX_SUPPLY) {
                updatedTotalSupply = MAX_SUPPLY;
            }
            rebasingCreditsPerToken = rebasingCredits / updatedTotalSupply;
            require(rebasingCreditsPerToken > 0, "Invalid change in supply");
            _totalSupply = updatedTotalSupply;
            _storeRebase(updatedTotalSupply, _profit, _epoch);
        }
    }
    function _storeRebase(
        uint256 _previousCirculating,
        uint256 _profit,
        uint256 _epoch
    ) internal {
        uint256 rebasePercent = (_profit * WAD) / _previousCirculating;
        rebases.push(
            Rebase({
                epoch: _epoch,
                rebase: rebasePercent,
                totalStakedBefore: _previousCirculating,
                totalStakedAfter: _totalSupply,
                amountRebased: _profit,
                index: getIndex(),
                blockNumberOccurred: block.number
            })
        );
        emit LogSupply(_epoch, block.timestamp, _totalSupply);
        emit LogRebase(_epoch, rebasePercent, getIndex());
    }
    function balanceOf(address _wallet) public view override returns (uint256) {
        return creditBalances[_wallet] / rebasingCreditsPerToken;
    }
    function creditsForTokenBalance(uint256 _amount)
        public
        view
        returns (uint256)
    {
        return _amount * rebasingCreditsPerToken;
    }
    function tokenBalanceForCredits(uint256 _credits)
        public
        view
        returns (uint256)
    {
        return _credits / rebasingCreditsPerToken;
    }
    function getIndex() public view returns (uint256) {
        return tokenBalanceForCredits(index);
    }
    function transfer(address _to, uint256 _value)
        public
        override
        returns (bool)
    {
        require(_to != address(0), "Invalid address");
        uint256 creditAmount = _value * rebasingCreditsPerToken;
        require(creditAmount <= creditBalances[msg.sender], "Not enough funds");
        creditBalances[msg.sender] = creditBalances[msg.sender] - creditAmount;
        creditBalances[_to] = creditBalances[_to] + creditAmount;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public override returns (bool) {
        require(_allowances[_from][msg.sender] >= _value, "Allowance too low");
        uint256 newValue = _allowances[_from][msg.sender] - _value;
        _allowances[_from][msg.sender] = newValue;
        emit Approval(_from, msg.sender, newValue);
        uint256 creditAmount = creditsForTokenBalance(_value);
        creditBalances[_from] = creditBalances[_from] - creditAmount;
        creditBalances[_to] = creditBalances[_to] + creditAmount;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function decimals() public view override returns (uint8) {
        return decimal;
    }
    function mint(address _address, uint256 _amount)
        external
        onlyRole(MINTER_BURNER_ROLE)
    {
        _mint(_address, _amount);
    }
    function _mint(address _address, uint256 _amount) internal override {
        require(_address != address(0), "Mint to the zero address");
        uint256 creditAmount = _amount * rebasingCreditsPerToken;
        creditBalances[_address] = creditBalances[_address] + creditAmount;
        rebasingCredits = rebasingCredits + creditAmount;
        _totalSupply = _totalSupply + _amount;
        require(_totalSupply < MAX_SUPPLY, "Max supply");
        emit Transfer(address(0), _address, _amount);
    }
    function burn(address _address, uint256 _amount)
        external
        onlyRole(MINTER_BURNER_ROLE)
    {
        _burn(_address, _amount);
    }
    function _burn(address _address, uint256 _amount) internal override {
        require(_address != address(0), "Burn from the zero address");
        if (_amount == 0) {
            return;
        }
        uint256 creditAmount = _amount * rebasingCreditsPerToken;
        uint256 currentCredits = creditBalances[_address];
        require(currentCredits >= creditAmount, "Not enough balance");
        creditBalances[_address] = creditBalances[_address] - creditAmount;
        rebasingCredits = rebasingCredits - creditAmount;
        _totalSupply = _totalSupply - _amount;
        emit Transfer(_address, address(0), _amount);
    }
}