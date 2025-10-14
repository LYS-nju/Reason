pragma solidity ^0.8.17;
interface IEUSD {
    function totalSupply() external view returns (uint256);
    function getTotalShares() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function sharesOf(address _account) external view returns (uint256);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
    function approve(address _spender, uint256 _amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
    function transferShares(
        address _recipient,
        uint256 _sharesAmount
    ) external returns (uint256);
    function getSharesByMintedEUSD(
        uint256 _EUSDAmount
    ) external view returns (uint256);
    function getMintedEUSDByShares(
        uint256 _sharesAmount
    ) external view returns (uint256);
    function mint(
        address _recipient,
        uint256 _mintAmount
    ) external returns (uint256 newTotalShares);
    function burnShares(
        address _account,
        uint256 burnAmount
    ) external returns (uint256 newTotalShares);
    function burn(
        address _account,
        uint256 burnAmount
    ) external returns (uint256 newTotalShares);
    function transfer(address to, uint256 amount) external returns (bool);
}
interface IGovernanceTimelock {
   function checkRole(bytes32 role, address sender) external view returns(bool);
   function checkOnlyRole(bytes32 role, address sender) external view returns(bool);
}
interface IProtocolRewardsPool {
    function notifyRewardAmount(uint256 amount, uint256 tokenType) external;
}
interface IeUSDMiningIncentives {
    function refreshReward(address user) external;
}
interface IVault {
    function vaultType() external view returns (uint8);
}
interface ICurvePool{
    function get_dy_underlying(int128 i, int128 j, uint256 dx) external view returns (uint256);
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external returns(uint256);
}
contract Configurator {
    mapping(address => bool) public mintVault;
    mapping(address => uint256) public mintVaultMaxSupply;
    mapping(address => bool) public vaultMintPaused;
    mapping(address => bool) public vaultBurnPaused;
    mapping(address => uint256) vaultSafeCollateralRatio;
    mapping(address => uint256) vaultBadCollateralRatio;
    mapping(address => uint256) public vaultMintFeeApy;
    mapping(address => uint256) public vaultKeeperRatio;
    mapping(address => bool) redemptionProvider;
    mapping(address => bool) public tokenMiner;
    uint256 public redemptionFee = 50;
    IGovernanceTimelock public GovernanceTimelock;
    IeUSDMiningIncentives public eUSDMiningIncentives;
    IProtocolRewardsPool public lybraProtocolRewardsPool;
    IEUSD public EUSD;
    IEUSD public peUSD;
    uint256 public flashloanFee = 500;
    uint256 maxStableRatio = 5_000;
    address public stableToken;
    ICurvePool public curvePool;
    bool public premiumTradingEnabled;
    event RedemptionFeeChanged(uint256 newSlippage);
    event SafeCollateralRatioChanged(address indexed pool, uint256 newRatio);
    event RedemptionProvider(address indexed user, bool status);
    event ProtocolRewardsPoolChanged(address indexed pool, uint256 timestamp);
    event EUSDMiningIncentivesChanged(address indexed pool, uint256 timestamp);
    event BorrowApyChanged(address indexed pool, uint256 newApy);
    event KeeperRatioChanged(address indexed pool, uint256 newSlippage);
    event tokenMinerChanges(address indexed pool, bool status);
    event FlashloanFeeUpdated(uint256 fee);
    bytes32 public constant DAO = keccak256("DAO");
    bytes32 public constant TIMELOCK = keccak256("TIMELOCK");
    bytes32 public constant ADMIN = keccak256("ADMIN");
    constructor(address _dao, address _curvePool) {
        GovernanceTimelock = IGovernanceTimelock(_dao);
        curvePool = ICurvePool(_curvePool);
    }
    modifier onlyRole(bytes32 role) {
        GovernanceTimelock.checkOnlyRole(role, msg.sender);
        _;
    }
    modifier checkRole(bytes32 role) {
        GovernanceTimelock.checkRole(role, msg.sender);
        _;
    }
    function initToken(address _eusd, address _peusd) external onlyRole(DAO) {
        if (address(EUSD) == address(0)) EUSD = IEUSD(_eusd);
        if (address(peUSD) == address(0)) peUSD = IEUSD(_peusd);
    }
    function setMintVault(address pool, bool isActive) external onlyRole(DAO) {
        mintVault[pool] = isActive;
    }
    function setMintVaultMaxSupply(address pool, uint256 maxSupply) external onlyRole(DAO) {
        mintVaultMaxSupply[pool] = maxSupply;
    }
    function setBadCollateralRatio(address pool, uint256 newRatio) external onlyRole(DAO) {
        require(newRatio >= 130 * 1e18 && newRatio <= 150 * 1e18 && newRatio <= vaultSafeCollateralRatio[pool] + 1e19, "LNA");
        vaultBadCollateralRatio[pool] = newRatio;
        emit SafeCollateralRatioChanged(pool, newRatio);
    }
    function setProtocolRewardsPool(address addr) external checkRole(TIMELOCK) {
        lybraProtocolRewardsPool = IProtocolRewardsPool(addr);
        emit ProtocolRewardsPoolChanged(addr, block.timestamp);
    }
    function setEUSDMiningIncentives(address addr) external checkRole(TIMELOCK) {
        eUSDMiningIncentives = IeUSDMiningIncentives(addr);
        emit EUSDMiningIncentivesChanged(addr, block.timestamp);
    }
    function setvaultBurnPaused(address pool, bool isActive) external checkRole(TIMELOCK) {
        vaultBurnPaused[pool] = isActive;
    }
    function setPremiumTradingEnabled(bool isActive) external checkRole(TIMELOCK) {
        premiumTradingEnabled = isActive;
    }
    function setvaultMintPaused(address pool, bool isActive) external checkRole(ADMIN) {
        vaultMintPaused[pool] = isActive;
    }
    function setRedemptionFee(uint256 newFee) external checkRole(TIMELOCK) {
        require(newFee <= 500, "Max Redemption Fee is 5%");
        redemptionFee = newFee;
        emit RedemptionFeeChanged(newFee);
    }
    function setSafeCollateralRatio(address pool, uint256 newRatio) external checkRole(TIMELOCK) {
        if(IVault(pool).vaultType() == 0) {
            require(newRatio >= 160 * 1e18, "eUSD vault safe collateralRatio should more than 160%");
        } else {
            require(newRatio >= vaultBadCollateralRatio[pool] + 1e19, "PeUSD vault safe collateralRatio should more than bad collateralRatio");
        }
        vaultSafeCollateralRatio[pool] = newRatio;
        emit SafeCollateralRatioChanged(pool, newRatio);
    }
    function setBorrowApy(address pool, uint256 newApy) external checkRole(TIMELOCK) {
        require(newApy <= 200, "Borrow APY cannot exceed 2%");
        vaultMintFeeApy[pool] = newApy;
        emit BorrowApyChanged(pool, newApy);
    }
    function setKeeperRatio(address pool,uint256 newRatio) external checkRole(TIMELOCK) {
        require(newRatio <= 5, "Max Keeper reward is 5%");
        vaultKeeperRatio[pool] = newRatio;
        emit KeeperRatioChanged(pool, newRatio);
    }
    function setTokenMiner(address[] calldata _contracts, bool[] calldata _bools) external checkRole(TIMELOCK) {
        for (uint256 i = 0; i < _contracts.length; i++) {
            tokenMiner[_contracts[i]] = _bools[i];
            emit tokenMinerChanges(_contracts[i], _bools[i]);
        }
    }
    function setMaxStableRatio(uint256 _ratio) external checkRole(TIMELOCK) {
        require(_ratio <= 10_000, "The maximum value is 10000");
        maxStableRatio = _ratio;
    }
    function setFlashloanFee(uint256 fee) external checkRole(TIMELOCK) {
        if (fee > 10_000) revert('EL');
        emit FlashloanFeeUpdated(fee);
        flashloanFee = fee;
    }
    function setProtocolRewardsToken(address _token) external checkRole(TIMELOCK) {
        stableToken = _token;
    }
    function becomeRedemptionProvider(bool _bool) external {
        eUSDMiningIncentives.refreshReward(msg.sender);
        redemptionProvider[msg.sender] = _bool;
        emit RedemptionProvider(msg.sender, _bool);
    }
    function refreshMintReward(address user) external {
        eUSDMiningIncentives.refreshReward(user);
    }
    function distributeRewards() external {
        uint256 peUSDBalance = peUSD.balanceOf(address(this));
        if(peUSDBalance >= 1e21) {
            peUSD.transfer(address(lybraProtocolRewardsPool), peUSDBalance);
            lybraProtocolRewardsPool.notifyRewardAmount(peUSDBalance, 2);
        }
        uint256 balance = EUSD.balanceOf(address(this));
        if (balance > 1e21) {
            uint256 price = curvePool.get_dy_underlying(0, 2, 1e18);
            if(!premiumTradingEnabled || price <= 1005000) {
                EUSD.transfer(address(lybraProtocolRewardsPool), balance);
                lybraProtocolRewardsPool.notifyRewardAmount(balance, 0);
            } else {
                EUSD.approve(address(curvePool), balance);
                uint256 amount = curvePool.exchange_underlying(0, 2, balance, balance * price * 998 / 1e21);
                IEUSD(stableToken).transfer(address(lybraProtocolRewardsPool), amount);
                lybraProtocolRewardsPool.notifyRewardAmount(amount, 1);
            }
        }
    }
    function getEUSDAddress() external view returns (address) {
        return address(EUSD);
    }
    function getProtocolRewardsPool() external view returns (address) {
        return address(lybraProtocolRewardsPool);
    }
    function getSafeCollateralRatio(
        address pool
    ) external view returns (uint256) {
        if (vaultSafeCollateralRatio[pool] == 0) return 160 * 1e18;
        return vaultSafeCollateralRatio[pool];
    }
    function getBadCollateralRatio(address pool) external view returns(uint256) {
        if(vaultBadCollateralRatio[pool] == 0) return vaultSafeCollateralRatio[pool] - 1e19;
        return vaultBadCollateralRatio[pool];
    }
    function isRedemptionProvider(address user) external view returns (bool) {
        return redemptionProvider[user];
    }
    function getEUSDMaxLocked() external view returns (uint256) {
        return (EUSD.totalSupply() * maxStableRatio) / 10_000;
    }
    function hasRole(bytes32 role, address caller) external view returns (bool) {
        return GovernanceTimelock.checkRole(role, caller);
    }
}