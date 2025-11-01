pragma solidity 0.8.19;
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "contracts/strategies/votium/VotiumStrategy.sol";
import "contracts/external_interfaces/IVotiumStrategy.sol";
import "contracts/strategies/AbstractStrategy.sol";
contract AfEth is Initializable, OwnableUpgradeable, ERC20Upgradeable {
    uint256 public ratio;
    uint256 public protocolFee;
    address public feeAddress;
    address public constant SAF_ETH_ADDRESS =
        0x6732Efaf6f39926346BeF8b821a04B6361C4F3e5;
    address public vEthAddress; 
    uint256 public latestWithdrawId;
    struct WithdrawInfo {
        address owner;
        uint256 amount;
        uint256 safEthWithdrawAmount;
        uint256 vEthWithdrawId;
        uint256 withdrawTime;
    }
    mapping(uint256 => WithdrawInfo) public withdrawIdInfo;
    bool public pauseDeposit;
    bool public pauseWithdraw;
    error StrategyAlreadyAdded();
    error StrategyNotFound();
    error InsufficientBalance();
    error InvalidStrategy();
    error InvalidFee();
    error CanNotWithdraw();
    error NotOwner();
    error FailedToSend();
    error FailedToDeposit();
    error Paused();
    error BelowMinOut();
    event WithdrawRequest(
        address indexed account,
        uint256 amount,
        uint256 withdrawId,
        uint256 withdrawTime
    );
    address private constant CVX_ADDRESS =
        0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address private constant VLCVX_ADDRESS =
        0x72a19342e8F1838460eBFCCEf09F6585e32db86E;
    uint256 public pendingSafEthWithdraws;
    modifier onlyWithdrawIdOwner(uint256 withdrawId) {
        if (withdrawIdInfo[withdrawId].owner != msg.sender) revert NotOwner();
        _;
    }
    constructor() {
        _disableInitializers();
    }
    function initialize() external initializer {
        _transferOwnership(msg.sender);
        ratio = 5e17;
    }
    function setStrategyAddress(address _vEthAddress) external onlyOwner {
        vEthAddress = _vEthAddress;
    }
    function setRatio(uint256 _newRatio) public onlyOwner {
        ratio = _newRatio;
    }
    function setFeeAddress(address _newFeeAddress) public onlyOwner {
        feeAddress = _newFeeAddress;
    }
    function setProtocolFee(uint256 _newFee) public onlyOwner {
        if (_newFee > 1e18) revert InvalidFee();
        protocolFee = _newFee;
    }
    function setPauseDeposit(bool _pauseDeposit) external onlyOwner {
        pauseDeposit = _pauseDeposit;
    }
    function setPauseWithdraw(bool _pauseWithdraw) external onlyOwner {
        pauseWithdraw = _pauseWithdraw;
    }
    function price() public view returns (uint256) {
        if (totalSupply() == 0) return 1e18;
        AbstractStrategy vEthStrategy = AbstractStrategy(vEthAddress);
        uint256 safEthValueInEth = (ISafEth(SAF_ETH_ADDRESS).approxPrice(true) *
            safEthBalanceMinusPending()) / 1e18;
        uint256 vEthValueInEth = (vEthStrategy.price() *
            vEthStrategy.balanceOf(address(this))) / 1e18;
        return ((vEthValueInEth + safEthValueInEth) * 1e18) / totalSupply();
    }
    function deposit(uint256 _minout) external payable virtual {
        if (pauseDeposit) revert Paused();
        uint256 amount = msg.value;
        uint256 priceBeforeDeposit = price();
        uint256 totalValue;
        AbstractStrategy vStrategy = AbstractStrategy(vEthAddress);
        uint256 sValue = (amount * ratio) / 1e18;
        uint256 sMinted = sValue > 0
            ? ISafEth(SAF_ETH_ADDRESS).stake{value: sValue}(0)
            : 0;
        uint256 vValue = (amount * (1e18 - ratio)) / 1e18;
        uint256 vMinted = vValue > 0 ? vStrategy.deposit{value: vValue}() : 0;
        totalValue +=
            (sMinted * ISafEth(SAF_ETH_ADDRESS).approxPrice(true)) +
            (vMinted * vStrategy.price());
        if (totalValue == 0) revert FailedToDeposit();
        uint256 amountToMint = totalValue / priceBeforeDeposit;
        if (amountToMint < _minout) revert BelowMinOut();
        _mint(msg.sender, amountToMint);
    }
    function requestWithdraw(uint256 _amount) external virtual {
        uint256 withdrawTimeBefore = withdrawTime(_amount);
        if (pauseWithdraw) revert Paused();
        latestWithdrawId++;
        uint256 afEthBalance = balanceOf(address(this));
        uint256 withdrawRatio = (_amount * 1e18) /
            (totalSupply() - afEthBalance);
        _transfer(msg.sender, address(this), _amount);
        uint256 votiumBalance = IERC20(vEthAddress).balanceOf(address(this));
        uint256 votiumWithdrawAmount = (withdrawRatio * votiumBalance) / 1e18;
        uint256 vEthWithdrawId = AbstractStrategy(vEthAddress).requestWithdraw(
            votiumWithdrawAmount
        );
        uint256 safEthBalance = safEthBalanceMinusPending();
        uint256 safEthWithdrawAmount = (withdrawRatio * safEthBalance) / 1e18;
        pendingSafEthWithdraws += safEthWithdrawAmount;
        withdrawIdInfo[latestWithdrawId]
            .safEthWithdrawAmount = safEthWithdrawAmount;
        withdrawIdInfo[latestWithdrawId].vEthWithdrawId = vEthWithdrawId;
        withdrawIdInfo[latestWithdrawId].owner = msg.sender;
        withdrawIdInfo[latestWithdrawId].amount = _amount;
        withdrawIdInfo[latestWithdrawId].withdrawTime = withdrawTimeBefore;
        emit WithdrawRequest(
            msg.sender,
            _amount,
            latestWithdrawId,
            withdrawTimeBefore
        );
    }
    function canWithdraw(uint256 _withdrawId) public view returns (bool) {
        return
            AbstractStrategy(vEthAddress).canWithdraw(
                withdrawIdInfo[_withdrawId].vEthWithdrawId
            );
    }
    function withdrawTime(uint256 _amount) public view returns (uint256) {
        return AbstractStrategy(vEthAddress).withdrawTime(_amount);
    }
    function withdraw(
        uint256 _withdrawId,
        uint256 _minout
    ) external virtual onlyWithdrawIdOwner(_withdrawId) {
        if (pauseWithdraw) revert Paused();
        uint256 ethBalanceBefore = address(this).balance;
        WithdrawInfo memory withdrawInfo = withdrawIdInfo[_withdrawId];
        if (!canWithdraw(_withdrawId)) revert CanNotWithdraw();
        ISafEth(SAF_ETH_ADDRESS).unstake(withdrawInfo.safEthWithdrawAmount, 0);
        AbstractStrategy(vEthAddress).withdraw(withdrawInfo.vEthWithdrawId);
        _burn(address(this), withdrawIdInfo[_withdrawId].amount);
        uint256 ethBalanceAfter = address(this).balance;
        uint256 ethReceived = ethBalanceAfter - ethBalanceBefore;
        pendingSafEthWithdraws -= withdrawInfo.safEthWithdrawAmount;
        if (ethReceived < _minout) revert BelowMinOut();
        (bool sent, ) = msg.sender.call{value: ethReceived}("");
        if (!sent) revert FailedToSend();
    }
    function depositRewards(uint256 _amount) public payable {
        IVotiumStrategy votiumStrategy = IVotiumStrategy(vEthAddress);
        uint256 feeAmount = (_amount * protocolFee) / 1e18;
        if (feeAmount > 0) {
            (bool sent, ) = feeAddress.call{value: feeAmount}("");
            if (!sent) revert FailedToSend();
        }
        uint256 amount = _amount - feeAmount;
        uint256 safEthTvl = (ISafEth(SAF_ETH_ADDRESS).approxPrice(true) *
            safEthBalanceMinusPending()) / 1e18;
        uint256 votiumTvl = ((votiumStrategy.cvxPerVotium() *
            votiumStrategy.ethPerCvx(true)) *
            IERC20(vEthAddress).balanceOf(address(this))) / 1e36;
        uint256 totalTvl = (safEthTvl + votiumTvl);
        uint256 safEthRatio = (safEthTvl * 1e18) / totalTvl;
        if (safEthRatio < ratio) {
            ISafEth(SAF_ETH_ADDRESS).stake{value: amount}(0);
        } else {
            votiumStrategy.depositRewards{value: amount}(amount);
        }
    }
    function safEthBalanceMinusPending() public view returns (uint256) {
        return
            IERC20(SAF_ETH_ADDRESS).balanceOf(address(this)) -
            pendingSafEthWithdraws;
    }
    receive() external payable {}
}