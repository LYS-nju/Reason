pragma solidity ^0.8.1;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
interface IFYToken is IERC20 {
    function underlying() external view returns (address);
    function maturity() external view returns (uint256);
    function mature() external;
    function redeem(address to, uint256 amount) external returns (uint256);
    function mint(address to, uint256 fyTokenAmount) external;
    function burn(address from, uint256 fyTokenAmount) external;
}
interface IOracle {
    function peek(bytes32 base, bytes32 quote, uint256 amount) external view returns (uint256 value, uint256 updateTime);
    function get(bytes32 base, bytes32 quote, uint256 amount) external returns (uint256 value, uint256 updateTime);
}
library DataTypes {
    struct Series {
        IFYToken fyToken;                                               
        bytes6  baseId;                                                 
        uint32  maturity;                                               
    }
    struct Debt {
        uint96 max;                                                     
        uint24 min;                                                     
        uint8 dec;                                                      
        uint128 sum;                                                    
    }
    struct SpotOracle {
        IOracle oracle;                                                 
        uint32  ratio;                                                  
    }
    struct Vault {
        address owner;
        bytes6  seriesId;                                                
        bytes6  ilkId;                                                   
    }
    struct Balances {
        uint128 art;                                                     
        uint128 ink;                                                     
    }
}
contract AccessControl {
    struct RoleData {
        mapping (address => bool) members;
        bytes4 adminRole;
    }
    mapping (bytes4 => RoleData) private _roles;
    bytes4 public constant ROOT = 0x00000000;
    bytes4 public constant LOCK = 0xFFFFFFFF; 
    event RoleAdminChanged(bytes4 indexed role, bytes4 indexed newAdminRole);
    event RoleGranted(bytes4 indexed role, address indexed account, address indexed sender);
    event RoleRevoked(bytes4 indexed role, address indexed account, address indexed sender);
    constructor () {
        _grantRole(ROOT, msg.sender);   
        _setRoleAdmin(LOCK, LOCK);      
    }
    modifier auth() {
        require (_hasRole(msg.sig, msg.sender), "Access denied");
        _;
    }
    modifier admin(bytes4 role) {
        require (_hasRole(_getRoleAdmin(role), msg.sender), "Only admin");
        _;
    }
    function hasRole(bytes4 role, address account) external view returns (bool) {
        return _hasRole(role, account);
    }
    function getRoleAdmin(bytes4 role) external view returns (bytes4) {
        return _getRoleAdmin(role);
    }
    function setRoleAdmin(bytes4 role, bytes4 adminRole) external virtual admin(role) {
        _setRoleAdmin(role, adminRole);
    }
    function grantRole(bytes4 role, address account) external virtual admin(role) {
        _grantRole(role, account);
    }
    function grantRoles(bytes4[] memory roles, address account) external virtual {
        for (uint256 i = 0; i < roles.length; i++) {
            require (_hasRole(_getRoleAdmin(roles[i]), msg.sender), "Only admin");
            _grantRole(roles[i], account);
        }
    }
    function lockRole(bytes4 role) external virtual admin(role) {
        _setRoleAdmin(role, LOCK);
    }
    function revokeRole(bytes4 role, address account) external virtual admin(role) {
        _revokeRole(role, account);
    }
    function revokeRoles(bytes4[] memory roles, address account) external virtual {
        for (uint256 i = 0; i < roles.length; i++) {
            require (_hasRole(_getRoleAdmin(roles[i]), msg.sender), "Only admin");
            _revokeRole(roles[i], account);
        }
    }
    function renounceRole(bytes4 role, address account) external virtual {
        require(account == msg.sender, "Renounce only for self");
        _revokeRole(role, account);
    }
    function _hasRole(bytes4 role, address account) internal view returns (bool) {
        return _roles[role].members[account];
    }
    function _getRoleAdmin(bytes4 role) internal view returns (bytes4) {
        return _roles[role].adminRole;
    }
    function _setRoleAdmin(bytes4 role, bytes4 adminRole) internal virtual {
        if (_getRoleAdmin(role) != adminRole) {
            _roles[role].adminRole = adminRole;
            emit RoleAdminChanged(role, adminRole);
        }
    }
    function _grantRole(bytes4 role, address account) internal {
        if (!_hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }
    function _revokeRole(bytes4 role, address account) internal {
        if (_hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
}
library WMul {
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y;
        unchecked { z /= 1e18; }
    }
}
library WDiv { 
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = (x * 1e18) / y;
    }
}
library CastU128I128 {
    function i128(uint128 x) internal pure returns (int128 y) {
        require (x <= uint128(type(int128).max), "Cast overflow");
        y = int128(x);
    }
}
library CastI128U128 {
    function u128(int128 x) internal pure returns (uint128 y) {
        require (x >= 0, "Cast overflow");
        y = uint128(x);
    }
}
library CastU256U32 {
    function u32(uint256 x) internal pure returns (uint32 y) {
        require (x <= type(uint32).max, "Cast overflow");
        y = uint32(x);
    }
}
library CastU256I256 {
    function i256(uint256 x) internal pure returns (int256 y) {
        require (x <= uint256(type(int256).max), "Cast overflow");
        y = int256(x);
    }
}
library CauldronMath {
    function add(uint128 x, int128 y) internal pure returns (uint128 z) {
        require (y > 0 || x >= uint128(-y), "Result below zero");
        z = y > 0 ? x + uint128(y) : x - uint128(-y);
    }
}
contract Cauldron is AccessControl() {
    using CauldronMath for uint128;
    using WMul for uint256;
    using WDiv for uint256;
    using CastU128I128 for uint128;
    using CastU256U32 for uint256;
    using CastU256I256 for uint256;
    using CastI128U128 for int128;
    event AuctionIntervalSet(uint32 indexed auctionInterval);
    event AssetAdded(bytes6 indexed assetId, address indexed asset);
    event SeriesAdded(bytes6 indexed seriesId, bytes6 indexed baseId, address indexed fyToken);
    event IlkAdded(bytes6 indexed seriesId, bytes6 indexed ilkId);
    event SpotOracleAdded(bytes6 indexed baseId, bytes6 indexed ilkId, address indexed oracle, uint32 ratio);
    event RateOracleAdded(bytes6 indexed baseId, address indexed oracle);
    event DebtLimitsSet(bytes6 indexed baseId, bytes6 indexed ilkId, uint96 max, uint24 min, uint8 dec);
    event VaultBuilt(bytes12 indexed vaultId, address indexed owner, bytes6 indexed seriesId, bytes6 ilkId);
    event VaultTweaked(bytes12 indexed vaultId, bytes6 indexed seriesId, bytes6 indexed ilkId);
    event VaultDestroyed(bytes12 indexed vaultId);
    event VaultGiven(bytes12 indexed vaultId, address indexed receiver);
    event VaultPoured(bytes12 indexed vaultId, bytes6 indexed seriesId, bytes6 indexed ilkId, int128 ink, int128 art);
    event VaultStirred(bytes12 indexed from, bytes12 indexed to, uint128 ink, uint128 art);
    event VaultRolled(bytes12 indexed vaultId, bytes6 indexed seriesId, uint128 art);
    event VaultLocked(bytes12 indexed vaultId, uint256 indexed timestamp);
    event SeriesMatured(bytes6 indexed seriesId, uint256 rateAtMaturity);
    mapping (bytes6 => address)                                 public assets;          
    mapping (bytes6 => DataTypes.Series)                        public series;          
    mapping (bytes6 => mapping(bytes6 => bool))                 public ilks;            
    mapping (bytes6 => IOracle)                                 public rateOracles;     
    mapping (bytes6 => mapping(bytes6 => DataTypes.SpotOracle)) public spotOracles;     
    mapping (bytes6 => mapping(bytes6 => DataTypes.Debt))       public debt;            
    mapping (bytes6 => uint256)                                 public ratesAtMaturity; 
    uint32                                                      public auctionInterval;
    mapping (bytes12 => DataTypes.Vault)                        public vaults;          
    mapping (bytes12 => DataTypes.Balances)                     public balances;        
    mapping (bytes12 => uint32)                                 public auctions;        
    function addAsset(bytes6 assetId, address asset)
        external
        auth
    {
        require (assetId != bytes6(0), "Asset id is zero");
        require (assets[assetId] == address(0), "Id already used");
        assets[assetId] = asset;
        emit AssetAdded(assetId, address(asset));
    }
    function setDebtLimits(bytes6 baseId, bytes6 ilkId, uint96 max, uint24 min, uint8 dec)
        external
        auth
    {
        require (assets[baseId] != address(0), "Base not found");
        require (assets[ilkId] != address(0), "Ilk not found");
        DataTypes.Debt memory debt_ = debt[baseId][ilkId];
        debt_.max = max;
        debt_.min = min;
        debt_.dec = dec;
        debt[baseId][ilkId] = debt_;
        emit DebtLimitsSet(baseId, ilkId, max, min, dec);
    }
    function setRateOracle(bytes6 baseId, IOracle oracle)
        external
        auth
    {
        require (assets[baseId] != address(0), "Base not found");
        rateOracles[baseId] = oracle;
        emit RateOracleAdded(baseId, address(oracle));
    }
    function setAuctionInterval(uint32 auctionInterval_)
        external
        auth
    {
        auctionInterval = auctionInterval_;
        emit AuctionIntervalSet(auctionInterval_);
    }
    function setSpotOracle(bytes6 baseId, bytes6 ilkId, IOracle oracle, uint32 ratio)
        external
        auth
    {
        require (assets[baseId] != address(0), "Base not found");
        require (assets[ilkId] != address(0), "Ilk not found");
        spotOracles[baseId][ilkId] = DataTypes.SpotOracle({
            oracle: oracle,
            ratio: ratio                                                                    
        });                                                                                 
        emit SpotOracleAdded(baseId, ilkId, address(oracle), ratio);
    }
    function addSeries(bytes6 seriesId, bytes6 baseId, IFYToken fyToken)
        external
        auth
    {
        require (seriesId != bytes6(0), "Series id is zero");
        address base = assets[baseId];
        require (base != address(0), "Base not found");
        require (fyToken != IFYToken(address(0)), "Series need a fyToken");
        require (fyToken.underlying() == base, "Mismatched series and base");
        require (rateOracles[baseId] != IOracle(address(0)), "Rate oracle not found");
        require (series[seriesId].fyToken == IFYToken(address(0)), "Id already used");
        series[seriesId] = DataTypes.Series({
            fyToken: fyToken,
            maturity: fyToken.maturity().u32(),
            baseId: baseId
        });
        emit SeriesAdded(seriesId, baseId, address(fyToken));
    }
    function addIlks(bytes6 seriesId, bytes6[] calldata ilkIds)
        external
        auth
    {
        DataTypes.Series memory series_ = series[seriesId];
        require (
            series_.fyToken != IFYToken(address(0)),
            "Series not found"
        );
        for (uint256 i = 0; i < ilkIds.length; i++) {
            require (
                spotOracles[series_.baseId][ilkIds[i]].oracle != IOracle(address(0)),
                "Spot oracle not found"
            );
            ilks[seriesId][ilkIds[i]] = true;
            emit IlkAdded(seriesId, ilkIds[i]);
        }
    }
    function build(address owner, bytes12 vaultId, bytes6 seriesId, bytes6 ilkId)
        external
        auth
        returns(DataTypes.Vault memory vault)
    {
        require (vaultId != bytes12(0), "Vault id is zero");
        require (vaults[vaultId].seriesId == bytes6(0), "Vault already exists");   
        require (ilks[seriesId][ilkId] == true, "Ilk not added to series");
        vault = DataTypes.Vault({
            owner: owner,
            seriesId: seriesId,
            ilkId: ilkId
        });
        vaults[vaultId] = vault;
        emit VaultBuilt(vaultId, owner, seriesId, ilkId);
    }
    function destroy(bytes12 vaultId)
        external
        auth
    {
        DataTypes.Balances memory balances_ = balances[vaultId];
        require (balances_.art == 0 && balances_.ink == 0, "Only empty vaults");
        delete auctions[vaultId];
        delete vaults[vaultId];
        emit VaultDestroyed(vaultId);
    }
    function _tweak(bytes12 vaultId, DataTypes.Vault memory vault)
        internal
    {
        require (ilks[vault.seriesId][vault.ilkId] == true, "Ilk not added to series");
        vaults[vaultId] = vault;
        emit VaultTweaked(vaultId, vault.seriesId, vault.ilkId);
    }
    function tweak(bytes12 vaultId, bytes6 seriesId, bytes6 ilkId)
        external
        auth
        returns(DataTypes.Vault memory vault)
    {
        DataTypes.Balances memory balances_ = balances[vaultId];
        vault = vaults[vaultId];
        if (seriesId != vault.seriesId) {
            require (balances_.art == 0, "Only with no debt");
            vault.seriesId = seriesId;
        }
        if (ilkId != vault.ilkId) {
            require (balances_.ink == 0, "Only with no collateral");
            vault.ilkId = ilkId;
        }
        _tweak(vaultId, vault);
    }
    function _give(bytes12 vaultId, address receiver)
        internal
        returns(DataTypes.Vault memory vault)
    {
        vault = vaults[vaultId];
        vault.owner = receiver;
        vaults[vaultId] = vault;
        emit VaultGiven(vaultId, receiver);
    }
    function give(bytes12 vaultId, address receiver)
        external
        auth
        returns(DataTypes.Vault memory vault)
    {
        vault = _give(vaultId, receiver);
    }
    function vaultData(bytes12 vaultId, bool getSeries)
        internal
        view
        returns (DataTypes.Vault memory vault_, DataTypes.Series memory series_, DataTypes.Balances memory balances_)
    {
        vault_ = vaults[vaultId];
        require (vault_.seriesId != bytes6(0), "Vault not found");
        if (getSeries) series_ = series[vault_.seriesId];
        balances_ = balances[vaultId];
    }
    function stir(bytes12 from, bytes12 to, uint128 ink, uint128 art)
        external
        auth
        returns (DataTypes.Balances memory, DataTypes.Balances memory)
    {
        (DataTypes.Vault memory vaultFrom, , DataTypes.Balances memory balancesFrom) = vaultData(from, false);
        (DataTypes.Vault memory vaultTo, , DataTypes.Balances memory balancesTo) = vaultData(to, false);
        if (ink > 0) {
            require (vaultFrom.ilkId == vaultTo.ilkId, "Different collateral");
            balancesFrom.ink -= ink;
            balancesTo.ink += ink;
        }
        if (art > 0) {
            require (vaultFrom.seriesId == vaultTo.seriesId, "Different series");
            balancesFrom.art -= art;
            balancesTo.art += art;
        }
        balances[from] = balancesFrom;
        balances[to] = balancesTo;
        if (ink > 0) require(_level(vaultFrom, balancesFrom, series[vaultFrom.seriesId]) >= 0, "Undercollateralized at origin");
        if (art > 0) require(_level(vaultTo, balancesTo, series[vaultTo.seriesId]) >= 0, "Undercollateralized at destination");
        emit VaultStirred(from, to, ink, art);
        return (balancesFrom, balancesTo);
    }
    function _pour(
        bytes12 vaultId,
        DataTypes.Vault memory vault_,
        DataTypes.Balances memory balances_,
        DataTypes.Series memory series_,
        int128 ink,
        int128 art
    )
        internal returns (DataTypes.Balances memory)
    {
        if (ink != 0) {
            balances_.ink = balances_.ink.add(ink);
        }
        if (art != 0) {
            DataTypes.Debt memory debt_ = debt[series_.baseId][vault_.ilkId];
            balances_.art = balances_.art.add(art);
            debt_.sum = debt_.sum.add(art);
            uint128 dust = debt_.min * uint128(10) ** debt_.dec;
            uint128 line = debt_.max * uint128(10) ** debt_.dec;
            require (balances_.art == 0 || balances_.art >= dust, "Min debt not reached");
            if (art > 0) require (debt_.sum <= line, "Max debt exceeded");
            debt[series_.baseId][vault_.ilkId] = debt_;
        }
        balances[vaultId] = balances_;
        emit VaultPoured(vaultId, vault_.seriesId, vault_.ilkId, ink, art);
        return balances_;
    }
    function pour(bytes12 vaultId, int128 ink, int128 art)
        external
        auth
        returns (DataTypes.Balances memory)
    {
        (DataTypes.Vault memory vault_, DataTypes.Series memory series_, DataTypes.Balances memory balances_) = vaultData(vaultId, true);
        balances_ = _pour(vaultId, vault_, balances_, series_, ink, art);
        if (balances_.art > 0 && (ink < 0 || art > 0))                          
            require(_level(vault_, balances_, series_) >= 0, "Undercollateralized");
        return balances_;
    }
    function grab(bytes12 vaultId, address receiver)
        external
        auth
    {
        uint32 now_ = uint32(block.timestamp);
        require (auctions[vaultId] + auctionInterval <= now_, "Vault under auction");        
        (DataTypes.Vault memory vault_, DataTypes.Series memory series_, DataTypes.Balances memory balances_) = vaultData(vaultId, true);
        require(_level(vault_, balances_, series_) < 0, "Not undercollateralized");
        auctions[vaultId] = now_;
        _give(vaultId, receiver);
        emit VaultLocked(vaultId, now_);
    }
    function slurp(bytes12 vaultId, uint128 ink, uint128 art)
        external
        auth
        returns (DataTypes.Balances memory)
    {
        (DataTypes.Vault memory vault_, DataTypes.Series memory series_, DataTypes.Balances memory balances_) = vaultData(vaultId, true);
        balances_ = _pour(vaultId, vault_, balances_, series_, -(ink.i128()), -(art.i128()));
        return balances_;
    }
    function roll(bytes12 vaultId, bytes6 newSeriesId, int128 art)
        external
        auth
        returns (DataTypes.Vault memory, DataTypes.Balances memory)
    {
        (DataTypes.Vault memory vault_, DataTypes.Series memory oldSeries_, DataTypes.Balances memory balances_) = vaultData(vaultId, true);
        DataTypes.Series memory newSeries_ = series[newSeriesId];
        require (oldSeries_.baseId == newSeries_.baseId, "Mismatched bases in series");
        vault_.seriesId = newSeriesId;
        _tweak(vaultId, vault_);
        balances_ = _pour(vaultId, vault_, balances_, newSeries_, 0, art);
        require(_level(vault_, balances_, newSeries_) >= 0, "Undercollateralized");
        emit VaultRolled(vaultId, newSeriesId, balances_.art);
        return (vault_, balances_);
    }
    function level(bytes12 vaultId) public returns (int256) {
        (DataTypes.Vault memory vault_, DataTypes.Series memory series_, DataTypes.Balances memory balances_) = vaultData(vaultId, true);
        return _level(vault_, balances_, series_);
    }
    function mature(bytes6 seriesId)
        public
    {
        DataTypes.Series memory series_ = series[seriesId];
        require (uint32(block.timestamp) >= series_.maturity, "Only after maturity");
        require (ratesAtMaturity[seriesId] == 0, "Already matured");
        _mature(seriesId, series_);
    }
    function _mature(bytes6 seriesId, DataTypes.Series memory series_)
        internal
    {
        IOracle rateOracle = rateOracles[series_.baseId];
        (uint256 rateAtMaturity,) = rateOracle.get(series_.baseId, bytes32("rate"), 1e18);
        ratesAtMaturity[seriesId] = rateAtMaturity;
        emit SeriesMatured(seriesId, rateAtMaturity);
    }
    function accrual(bytes6 seriesId)
        public
        returns (uint256)
    {
        DataTypes.Series memory series_ = series[seriesId];
        require (uint32(block.timestamp) >= series_.maturity, "Only after maturity");
        return _accrual(seriesId, series_);
    }
    function _accrual(bytes6 seriesId, DataTypes.Series memory series_)
        private
        returns (uint256 accrual_)
    {
        uint256 rateAtMaturity = ratesAtMaturity[seriesId];
        if (rateAtMaturity == 0) {  
            _mature(seriesId, series_);
        } else {
            IOracle rateOracle = rateOracles[series_.baseId];
            (uint256 rate,) = rateOracle.get(series_.baseId, bytes32("rate"), 1e18);
            accrual_ = rate.wdiv(rateAtMaturity);
        }
        accrual_ = accrual_ >= 1e18 ? accrual_ : 1e18;     
    }
    function _level(
        DataTypes.Vault memory vault_,
        DataTypes.Balances memory balances_,
        DataTypes.Series memory series_
    )
        internal
        returns (int256)
    {
        DataTypes.SpotOracle memory spotOracle_ = spotOracles[series_.baseId][vault_.ilkId];
        uint256 ratio = uint256(spotOracle_.ratio) * 1e12;   
        (uint256 inkValue,) = spotOracle_.oracle.get(series_.baseId, vault_.ilkId, balances_.ink);    
        if (uint32(block.timestamp) >= series_.maturity) {
            uint256 accrual_ = _accrual(vault_.seriesId, series_);
            return inkValue.i256() - uint256(balances_.art).wmul(accrual_).wmul(ratio).i256();
        }
        return inkValue.i256() - uint256(balances_.art).wmul(ratio).i256();
    }
}
interface IERC3156FlashBorrower {
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}
interface IERC3156FlashLender {
    function maxFlashLoan(
        address token
    ) external view returns (uint256);
    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);
    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is IERC20Metadata {
    uint256                                           internal  _totalSupply;
    mapping (address => uint256)                      internal  _balanceOf;
    mapping (address => mapping (address => uint256)) internal  _allowance;
    string                                            public override name = "???";
    string                                            public override symbol = "???";
    uint8                                             public override decimals = 18;
    constructor(string memory name_, string memory symbol_, uint8 decimals_) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
    }
    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address guy) external view virtual override returns (uint256) {
        return _balanceOf[guy];
    }
    function allowance(address owner, address spender) external view virtual override returns (uint256) {
        return _allowance[owner][spender];
    }
    function approve(address spender, uint wad) external virtual override returns (bool) {
        return _setAllowance(msg.sender, spender, wad);
    }
    function transfer(address dst, uint wad) external virtual override returns (bool) {
        return _transfer(msg.sender, dst, wad);
    }
    function transferFrom(address src, address dst, uint wad) external virtual override returns (bool) {
        _decreaseAllowance(src, wad);
        return _transfer(src, dst, wad);
    }
    function _transfer(address src, address dst, uint wad) internal virtual returns (bool) {
        require(_balanceOf[src] >= wad, "ERC20: Insufficient balance");
        unchecked { _balanceOf[src] = _balanceOf[src] - wad; }
        _balanceOf[dst] = _balanceOf[dst] + wad;
        emit Transfer(src, dst, wad);
        return true;
    }
    function _setAllowance(address owner, address spender, uint wad) internal virtual returns (bool) {
        _allowance[owner][spender] = wad;
        emit Approval(owner, spender, wad);
        return true;
    }
    function _decreaseAllowance(address src, uint wad) internal virtual returns (bool) {
        if (src != msg.sender) {
            uint256 allowed = _allowance[src][msg.sender];
            if (allowed != type(uint).max) {
                require(allowed >= wad, "ERC20: Insufficient approval");
                unchecked { _setAllowance(src, msg.sender, allowed - wad); }
            }
        }
        return true;
    }
    function _mint(address dst, uint wad) internal virtual returns (bool) {
        _balanceOf[dst] = _balanceOf[dst] + wad;
        _totalSupply = _totalSupply + wad;
        emit Transfer(address(0), dst, wad);
        return true;
    }
    function _burn(address src, uint wad) internal virtual returns (bool) {
        unchecked {
            require(_balanceOf[src] >= wad, "ERC20: Insufficient balance");
            _balanceOf[src] = _balanceOf[src] - wad;
            _totalSupply = _totalSupply - wad;
            emit Transfer(src, address(0), wad);
        }
        return true;
    }
}
interface IERC2612 {
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;
    function nonces(address owner) external view returns (uint256);
}
abstract contract ERC20Permit is ERC20, IERC2612 {
    mapping (address => uint256) public override nonces;
    bytes32 public immutable PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private immutable _DOMAIN_SEPARATOR;
    uint256 public immutable deploymentChainId;
    constructor(string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_, decimals_) {
        uint256 chainId;
        assembly {chainId := chainid()}
        deploymentChainId = chainId;
        _DOMAIN_SEPARATOR = _calculateDomainSeparator(chainId);
    }
    function _calculateDomainSeparator(uint256 chainId) private view returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256(bytes(version())),
                chainId,
                address(this)
            )
        );
    }
    function DOMAIN_SEPARATOR() external view returns (bytes32) {
        uint256 chainId;
        assembly {chainId := chainid()}
        return chainId == deploymentChainId ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId);
    }
    function version() public pure virtual returns(string memory) { return "1"; }
    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external virtual override {
        require(deadline >= block.timestamp, "ERC20Permit: expired deadline");
        uint256 chainId;
        assembly {chainId := chainid()}
        bytes32 hashStruct = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                amount,
                nonces[owner]++,
                deadline
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                chainId == deploymentChainId ? _DOMAIN_SEPARATOR : _calculateDomainSeparator(chainId),
                hashStruct
            )
        );
        address signer = ecrecover(hash, v, r, s);
        require(
            signer != address(0) && signer == owner,
            "ERC20Permit: invalid signature"
        );
        _setAllowance(owner, spender, amount);
    }
}
interface IJoin {
    function asset() external view returns (address);
    function join(address user, uint128 wad) external returns (uint128);
    function exit(address user, uint128 wad) external returns (uint128);
}
library CastU256U128 {
    function u128(uint256 x) internal pure returns (uint128 y) {
        require (x <= type(uint128).max, "Cast overflow");
        y = uint128(x);
    }
}
contract FYToken is IFYToken, IERC3156FlashLender, AccessControl(), ERC20Permit {
    using WMul for uint256;
    using WDiv for uint256;
    using CastU256U128 for uint256;
    using CastU256U32 for uint256;
    event SeriesMatured(uint256 chiAtMaturity);
    event Redeemed(address indexed from, address indexed to, uint256 amount, uint256 redeemed);
    event OracleSet(address indexed oracle);
    bytes32 constant CHI = "chi";
    uint256 constant internal MAX_TIME_TO_MATURITY = 126144000; 
    bytes32 constant internal FLASH_LOAN_RETURN = keccak256("ERC3156FlashBorrower.onFlashLoan");
    IOracle public oracle;                                      
    IJoin public immutable join;                                
    address public immutable override underlying;
    bytes6 public immutable underlyingId;                             
    uint256 public immutable override maturity;
    uint256 public chiAtMaturity = type(uint256).max;           
    constructor(
        bytes6 underlyingId_,
        IOracle oracle_, 
        IJoin join_,
        uint256 maturity_,
        string memory name,
        string memory symbol
    ) ERC20Permit(name, symbol, IERC20Metadata(address(IJoin(join_).asset())).decimals()) { 
        uint256 now_ = block.timestamp;
        require(
            maturity_ > now_ &&
            maturity_ < now_ + MAX_TIME_TO_MATURITY &&
            maturity_ < type(uint32).max,
            "Invalid maturity"
        );
        underlyingId = underlyingId_;
        join = join_;
        maturity = maturity_;
        underlying = address(IJoin(join_).asset());
        setOracle(oracle_);
    }
    modifier afterMaturity() {
        require(
            uint32(block.timestamp) >= maturity,
            "Only after maturity"
        );
        _;
    }
    modifier beforeMaturity() {
        require(
            uint32(block.timestamp) < maturity,
            "Only before maturity"
        );
        _;
    }
    function setOracle(IOracle oracle_)
        public
        auth    
    {
        oracle = oracle_;
        emit OracleSet(address(oracle_));
    }
    function mature()
        external override
        afterMaturity
    {
        require (chiAtMaturity == type(uint256).max, "Already matured");
        _mature();
    }
    function _mature() 
        private
        returns (uint256 _chiAtMaturity)
    {
        (_chiAtMaturity,) = oracle.get(underlyingId, CHI, 1e18);
        chiAtMaturity = _chiAtMaturity;
        emit SeriesMatured(_chiAtMaturity);
    }
    function accrual()
        external
        afterMaturity
        returns (uint256)
    {
        return _accrual();
    }
    function _accrual()
        private
        returns (uint256 accrual_)
    {
        if (chiAtMaturity == type(uint256).max) {  
            _mature();
        } else {
            (uint256 chi,) = oracle.get(underlyingId, CHI, 1e18);
            accrual_ = chi.wdiv(chiAtMaturity);
        }
        accrual_ = accrual_ >= 1e18 ? accrual_ : 1e18;     
    }
    function redeem(address to, uint256 amount)
        external override
        afterMaturity
        returns (uint256 redeemed)
    {
        _burn(msg.sender, amount);
        redeemed = amount.wmul(_accrual());
        join.exit(to, redeemed.u128());
        emit Redeemed(msg.sender, to, amount, redeemed);
        return amount;
    }
    function mint(address to, uint256 amount)
        external override
        beforeMaturity
        auth
    {
        _mint(to, amount);
    }
    function burn(address from, uint256 amount)
        external override
        auth
    {
        _burn(from, amount);
    }
    function _burn(address from, uint256 amount)
        internal override
        returns (bool)
    {
        uint256 available = _balanceOf[address(this)];
        if (available >= amount) {
            unchecked { return super._burn(address(this), amount); }
        } else {
            if (available > 0 ) super._burn(address(this), available);
            unchecked { _decreaseAllowance(from, amount - available); }
            unchecked { return super._burn(from, amount - available); }
        }
    }
    function maxFlashLoan(address token)
        external view override
        beforeMaturity
        returns (uint256)
    {
        return token == address(this) ? type(uint256).max - _totalSupply : 0;
    }
    function flashFee(address token, uint256)
        external view override
        beforeMaturity
        returns (uint256)
    {
        require(token == address(this), "Unsupported currency");
        return 0;
    }
    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes memory data)
        external override
        beforeMaturity
        returns(bool)
    {
        require(token == address(this), "Unsupported currency");
        _mint(address(receiver), amount);
        require(receiver.onFlashLoan(msg.sender, token, amount, 0, data) == FLASH_LOAN_RETURN, "Non-compliant borrower");
        _burn(address(receiver), amount);
        return true;
    }
}
interface IWETH9 is IERC20 {
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);
    function deposit() external payable;
    function withdraw(uint wad) external;
}
interface ICauldron {
    function rateOracles(bytes6 baseId) external view returns (IOracle);
    function vaults(bytes12 vault) external view returns (DataTypes.Vault memory);
    function series(bytes6 seriesId) external view returns (DataTypes.Series memory);
    function assets(bytes6 assetsId) external view returns (address);
    function balances(bytes12 vault) external view returns (DataTypes.Balances memory);
    function auctions(bytes12 vault) external view returns (uint32);
    function build(address owner, bytes12 vaultId, bytes6 seriesId, bytes6 ilkId) external returns (DataTypes.Vault memory);
    function destroy(bytes12 vault) external;
    function tweak(bytes12 vaultId, bytes6 seriesId, bytes6 ilkId) external returns (DataTypes.Vault memory);
    function give(bytes12 vaultId, address receiver) external returns (DataTypes.Vault memory);
    function stir(bytes12 from, bytes12 to, uint128 ink, uint128 art) external returns (DataTypes.Balances memory, DataTypes.Balances memory);
    function pour(bytes12 vaultId, int128 ink, int128 art) external returns (DataTypes.Balances memory);
    function roll(bytes12 vaultId, bytes6 seriesId, int128 art) external returns (DataTypes.Vault memory, DataTypes.Balances memory);
    function grab(bytes12 vault, address receiver) external;
    function slurp(bytes12 vaultId, uint128 ink, uint128 art) external returns (DataTypes.Balances memory);
    function mature(bytes6 seriesId) external;
    function accrual(bytes6 seriesId) external returns (uint256);
}
interface ICauldronGov {
    function assets(bytes6) external view returns (address);
    function series(bytes6) external view returns (DataTypes.Series memory);
    function rateOracles(bytes6) external view returns (IOracle);
    function addAsset(bytes6, address) external;
    function addSeries(bytes6, bytes6, IFYToken) external;
    function addIlks(bytes6, bytes6[] memory) external;
    function setRateOracle(bytes6, IOracle) external;
    function setSpotOracle(bytes6, bytes6, IOracle, uint32) external;
    function setDebtLimits(bytes6, bytes6, uint96, uint24, uint8) external;
}
interface ILadleGov {
    function joins(bytes6) external view returns (IJoin);
    function addJoin(bytes6, address) external;
    function addPool(bytes6, address) external;
}
interface IPool is IERC20, IERC2612 {
    function base() external view returns(IERC20);
    function fyToken() external view returns(IFYToken);
    function maturity() external view returns(uint32);
    function getBaseBalance() external view returns(uint112);
    function getFYTokenBalance() external view returns(uint112);
    function retrieveBase(address to) external returns(uint128 retrieved);
    function retrieveFYToken(address to) external returns(uint128 retrieved);
    function sellBase(address to, uint128 min) external returns(uint128);
    function buyBase(address to, uint128 baseOut, uint128 max) external returns(uint128);
    function sellFYToken(address to, uint128 min) external returns(uint128);
    function buyFYToken(address to, uint128 fyTokenOut, uint128 max) external returns(uint128);
    function sellBasePreview(uint128 baseIn) external view returns(uint128);
    function buyBasePreview(uint128 baseOut) external view returns(uint128);
    function sellFYTokenPreview(uint128 fyTokenIn) external view returns(uint128);
    function buyFYTokenPreview(uint128 fyTokenOut) external view returns(uint128);
    function mint(address to, bool calculateFromBase, uint256 minTokensMinted) external returns (uint256, uint256, uint256);
    function mintWithBase(address to, uint256 fyTokenToBuy, uint256 minTokensMinted) external returns (uint256, uint256, uint256);
    function burn(address to, uint256 minBaseOut, uint256 minFYTokenOut) external returns (uint256, uint256, uint256);
    function burnForBase(address to, uint256 minBaseOut) external returns (uint256, uint256);
}
interface IJoinFactory {
  event JoinCreated(address indexed asset, address pool);
  function JOIN_BYTECODE_HASH() external pure returns (bytes32);
  function calculateJoinAddress(address asset) external view returns (address);
  function getJoin(address asset) external view returns (address);
  function createJoin(address asset) external returns (address);
  function nextAsset() external view returns (address);
}
library RevertMsgExtractor {
    function getRevertMsg(bytes memory returnData)
        internal pure
        returns (string memory)
    {
        if (returnData.length < 68) return "Transaction reverted silently";
        assembly {
            returnData := add(returnData, 0x04)
        }
        return abi.decode(returnData, (string)); 
    }
}
library TransferHelper {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        if (!(success && (data.length == 0 || abi.decode(data, (bool))))) revert(RevertMsgExtractor.getRevertMsg(data));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        if (!(success && (data.length == 0 || abi.decode(data, (bool))))) revert(RevertMsgExtractor.getRevertMsg(data));
    }
    function safeTransferETH(address payable to, uint256 value) internal {
        (bool success, bytes memory data) = to.call{value: value}(new bytes(0));
        if (!success) revert(RevertMsgExtractor.getRevertMsg(data));
    }
}
contract Join is IJoin, IERC3156FlashLender, AccessControl() {
    using TransferHelper for IERC20;
    using WMul for uint256;
    using CastU256U128 for uint256;
    event FlashFeeFactorSet(uint256 indexed fee);
    bytes32 constant internal FLASH_LOAN_RETURN = keccak256("ERC3156FlashBorrower.onFlashLoan");
    address public immutable override asset;
    uint256 public storedBalance;
    uint256 public flashFeeFactor; 
    constructor() {
        asset = IJoinFactory(msg.sender).nextAsset();
    }
    function setFlashFeeFactor(uint256 flashFeeFactor_)
        public
        auth
    {
        flashFeeFactor = flashFeeFactor_;
        emit FlashFeeFactorSet(flashFeeFactor_);
    }
    function join(address user, uint128 amount)
        external override
        auth
        returns (uint128)
    {
        return _join(user, amount);
    }
    function _join(address user, uint128 amount)
        internal
        returns (uint128)
    {
        IERC20 token = IERC20(asset);
        uint256 _storedBalance = storedBalance;
        uint256 available = token.balanceOf(address(this)) - _storedBalance; 
        storedBalance = _storedBalance + amount;
        unchecked { if (available < amount) token.safeTransferFrom(user, address(this), amount - available); }
        return amount;        
    }
    function exit(address user, uint128 amount)
        external override
        auth
        returns (uint128)
    {
        return _exit(user, amount);
    }
    function _exit(address user, uint128 amount)
        internal
        returns (uint128)
    {
        IERC20 token = IERC20(asset);
        storedBalance -= amount;
        token.safeTransfer(user, amount);
        return amount;
    }
    function retrieve(IERC20 token, address to)
        external
        auth
    {
        require(address(token) != address(asset), "Use exit for asset");
        token.safeTransfer(to, token.balanceOf(address(this)));
    }
    function maxFlashLoan(address token) public view override returns (uint256) {
        return token == asset ? storedBalance : 0;
    }
    function flashFee(address token, uint256 amount) public view override returns (uint256) {
        require(token == asset, "Unsupported currency");
        return _flashFee(amount);
    }
    function _flashFee(uint256 amount) internal view returns (uint256) {
        return amount.wmul(flashFeeFactor);
    }
    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes memory data) public override returns(bool) {
        require(token == asset, "Unsupported currency");
        uint128 _amount = amount.u128();
        uint128 _fee = _flashFee(amount).u128();
        _exit(address(receiver), _amount);
        require(receiver.onFlashLoan(msg.sender, token, _amount, _fee, data) == FLASH_LOAN_RETURN, "Non-compliant borrower");
        _join(address(receiver), _amount + _fee);
        return true;
    }
}
contract JoinFactory is IJoinFactory {
  bytes32 public constant override JOIN_BYTECODE_HASH = keccak256(type(Join).creationCode);
  address private _nextAsset;
  function isContract(address account) internal view returns (bool) {
      uint256 size;
      assembly { size := extcodesize(account) }
      return size > 0;
  }
  function calculateJoinAddress(address asset) external view override returns (address) {
    return _calculateJoinAddress(asset);
  }
  function _calculateJoinAddress(address asset)
    private view returns (address calculatedAddress)
  {
    calculatedAddress = address(uint160(uint256(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(this),
      keccak256(abi.encodePacked(asset)),
      JOIN_BYTECODE_HASH
    )))));
  }
  function getJoin(address asset) external view override returns (address join) {
    join = _calculateJoinAddress(asset);
    if(!isContract(join)) {
      join = address(0);
    }
  }
  function createJoin(address asset) external override returns (address) {
    _nextAsset = asset;
    Join join = new Join{salt: keccak256(abi.encodePacked(asset))}();
    _nextAsset = address(0);
    join.grantRole(join.ROOT(), msg.sender);
    join.renounceRole(join.ROOT(), address(this));
    emit JoinCreated(asset, address(join));
    return address(join);
  }
  function nextAsset() external view override returns (address) {
    return _nextAsset;
  }
}
interface DaiAbstract {
    function wards(address) external view returns (uint256);
    function rely(address) external;
    function deny(address) external;
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function version() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function allowance(address, address) external view returns (uint256);
    function nonces(address) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external view returns (bytes32);
    function transfer(address, uint256) external;
    function transferFrom(address, address, uint256) external returns (bool);
    function mint(address, uint256) external;
    function burn(address, uint256) external;
    function approve(address, uint256) external returns (bool);
    function push(address, uint256) external;
    function pull(address, uint256) external;
    function move(address, address, uint256) external;
    function permit(address, address, uint256, uint256, bool, uint8, bytes32, bytes32) external;
}
contract LadleStorage {
    enum Operation {
        BUILD,               
        TWEAK,               
        GIVE,                
        DESTROY,             
        STIR,                
        POUR,                
        SERVE,               
        ROLL,                
        CLOSE,               
        REPAY,               
        REPAY_VAULT,         
        REPAY_LADLE,         
        RETRIEVE,            
        FORWARD_PERMIT,      
        FORWARD_DAI_PERMIT,  
        JOIN_ETHER,          
        EXIT_ETHER,          
        TRANSFER_TO_POOL,    
        ROUTE,               
        TRANSFER_TO_FYTOKEN, 
        REDEEM,              
        MODULE               
    }
    ICauldron public immutable cauldron;
    uint256 public borrowingFee;
    mapping (bytes6 => IJoin)                   public joins;            
    mapping (bytes6 => IPool)                   public pools;            
    mapping (address => bool)                   public modules;          
    event JoinAdded(bytes6 indexed assetId, address indexed join);
    event PoolAdded(bytes6 indexed seriesId, address indexed pool);
    event ModuleSet(address indexed module, bool indexed set);
    event FeeSet(uint256 fee);
    constructor (ICauldron cauldron_) {
        cauldron = cauldron_;
    }
}
contract Ladle is LadleStorage, AccessControl() {
    using WMul for uint256;
    using CastU256U128 for uint256;
    using CastU128I128 for uint128;
    using TransferHelper for IERC20;
    using TransferHelper for address payable;
    IWETH9 public immutable weth;
    constructor (ICauldron cauldron, IWETH9 weth_) LadleStorage(cauldron) {
        weth = weth_;
    }
    function getOwnedVault(bytes12 vaultId)
        internal view returns(DataTypes.Vault memory vault)
    {
        vault = cauldron.vaults(vaultId);
        require (vault.owner == msg.sender, "Only vault owner");
    }
    function getSeries(bytes6 seriesId)
        internal view returns(DataTypes.Series memory series)
    {
        series = cauldron.series(seriesId);
        require (series.fyToken != IFYToken(address(0)), "Series not found");
    }
    function getJoin(bytes6 assetId)
        internal view returns(IJoin join)
    {
        join = joins[assetId];
        require (join != IJoin(address(0)), "Join not found");
    }
    function getPool(bytes6 seriesId)
        internal view returns(IPool pool)
    {
        pool = pools[seriesId];
        require (pool != IPool(address(0)), "Pool not found");
    }
    function addJoin(bytes6 assetId, IJoin join)
        external
        auth
    {
        address asset = cauldron.assets(assetId);
        require (asset != address(0), "Asset not found");
        require (join.asset() == asset, "Mismatched asset and join");
        joins[assetId] = join;
        emit JoinAdded(assetId, address(join));
    }
    function addPool(bytes6 seriesId, IPool pool)
        external
        auth
    {
        IFYToken fyToken = getSeries(seriesId).fyToken;
        require (fyToken == pool.fyToken(), "Mismatched pool fyToken and series");
        require (fyToken.underlying() == address(pool.base()), "Mismatched pool base and series");
        pools[seriesId] = pool;
        emit PoolAdded(seriesId, address(pool));
    }
    function setModule(address module, bool set)
        external
        auth
    {
        modules[module] = set;
        emit ModuleSet(module, set);
    }
    function setFee(uint256 fee)
        public
        auth    
    {
        borrowingFee = fee;
        emit FeeSet(fee);
    }
    function batch(
        Operation[] calldata operations,
        bytes[] calldata data
    ) external payable {
        require(operations.length == data.length, "Mismatched operation data");
        bytes12 cachedId;
        DataTypes.Vault memory vault;
        for (uint256 i = 0; i < operations.length; i += 1) {
            Operation operation = operations[i];
            if (operation == Operation.BUILD) {
                (bytes12 vaultId, bytes6 seriesId, bytes6 ilkId) = abi.decode(data[i], (bytes12, bytes6, bytes6));
                (cachedId, vault) = (vaultId, _build(vaultId, seriesId, ilkId));   
            } else if (operation == Operation.FORWARD_PERMIT) {
                (bytes6 id, bool isAsset, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) =
                    abi.decode(data[i], (bytes6, bool, address, uint256, uint256, uint8, bytes32, bytes32));
                _forwardPermit(id, isAsset, spender, amount, deadline, v, r, s);
            } else if (operation == Operation.JOIN_ETHER) {
                (bytes6 etherId) = abi.decode(data[i], (bytes6));
                _joinEther(etherId);
            } else if (operation == Operation.POUR) {
                (bytes12 vaultId, address to, int128 ink, int128 art) = abi.decode(data[i], (bytes12, address, int128, int128));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                _pour(vaultId, vault, to, ink, art);
            } else if (operation == Operation.SERVE) {
                (bytes12 vaultId, address to, uint128 ink, uint128 base, uint128 max) = abi.decode(data[i], (bytes12, address, uint128, uint128, uint128));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                _serve(vaultId, vault, to, ink, base, max);
            } else if (operation == Operation.ROLL) {
                (bytes12 vaultId, bytes6 newSeriesId, uint8 loan, uint128 max) = abi.decode(data[i], (bytes12, bytes6, uint8, uint128));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                (vault,) = _roll(vaultId, vault, newSeriesId, loan, max);
            } else if (operation == Operation.FORWARD_DAI_PERMIT) {
                (bytes6 id, bool isAsset, address spender, uint256 nonce, uint256 deadline, bool allowed, uint8 v, bytes32 r, bytes32 s) =
                    abi.decode(data[i], (bytes6, bool, address, uint256, uint256, bool, uint8, bytes32, bytes32));
                _forwardDaiPermit(id, isAsset, spender, nonce, deadline, allowed, v, r, s);
            } else if (operation == Operation.TRANSFER_TO_POOL) {
                (bytes6 seriesId, bool base, uint128 wad) =
                    abi.decode(data[i], (bytes6, bool, uint128));
                IPool pool = getPool(seriesId);
                _transferToPool(pool, base, wad);
            } else if (operation == Operation.ROUTE) {
                (bytes6 seriesId, bytes memory poolCall) =
                    abi.decode(data[i], (bytes6, bytes));
                IPool pool = getPool(seriesId);
                _route(pool, poolCall);
            } else if (operation == Operation.EXIT_ETHER) {
                (address to) = abi.decode(data[i], (address));
                _exitEther(payable(to));
            } else if (operation == Operation.CLOSE) {
                (bytes12 vaultId, address to, int128 ink, int128 art) = abi.decode(data[i], (bytes12, address, int128, int128));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                _close(vaultId, vault, to, ink, art);
            } else if (operation == Operation.REPAY) {
                (bytes12 vaultId, address to, int128 ink, uint128 min) = abi.decode(data[i], (bytes12, address, int128, uint128));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                _repay(vaultId, vault, to, ink, min);
            } else if (operation == Operation.REPAY_VAULT) {
                (bytes12 vaultId, address to, int128 ink, uint128 max) = abi.decode(data[i], (bytes12, address, int128, uint128));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                _repayVault(vaultId, vault, to, ink, max);
            } else if (operation == Operation.REPAY_LADLE) {
                (bytes12 vaultId) = abi.decode(data[i], (bytes12));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                _repayLadle(vaultId, vault);
            } else if (operation == Operation.RETRIEVE) {
                (bytes6 assetId, bool isAsset, address to) = abi.decode(data[i], (bytes6, bool, address));
                _retrieve(assetId, isAsset, to);
            } else if (operation == Operation.TRANSFER_TO_FYTOKEN) {
                (bytes6 seriesId, uint256 amount) = abi.decode(data[i], (bytes6, uint256));
                IFYToken fyToken = getSeries(seriesId).fyToken;
                _transferToFYToken(fyToken, amount);
            } else if (operation == Operation.REDEEM) {
                (bytes6 seriesId, address to, uint256 amount) = abi.decode(data[i], (bytes6, address, uint256));
                IFYToken fyToken = getSeries(seriesId).fyToken;
                _redeem(fyToken, to, amount);
            } else if (operation == Operation.STIR) {
                (bytes12 from, bytes12 to, uint128 ink, uint128 art) = abi.decode(data[i], (bytes12, bytes12, uint128, uint128));
                _stir(from, to, ink, art);  
            } else if (operation == Operation.TWEAK) {
                (bytes12 vaultId, bytes6 seriesId, bytes6 ilkId) = abi.decode(data[i], (bytes12, bytes6, bytes6));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                vault = _tweak(vaultId, seriesId, ilkId);
            } else if (operation == Operation.GIVE) {
                (bytes12 vaultId, address to) = abi.decode(data[i], (bytes12, address));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                vault = _give(vaultId, to);
                delete vault;   
                cachedId = bytes12(0);
            } else if (operation == Operation.DESTROY) {
                (bytes12 vaultId) = abi.decode(data[i], (bytes12));
                if (cachedId != vaultId) (cachedId, vault) = (vaultId, getOwnedVault(vaultId));
                _destroy(vaultId);
                delete vault;   
                cachedId = bytes12(0);
            } else if (operation == Operation.MODULE) {
                (address module, bytes memory moduleCall) = abi.decode(data[i], (address, bytes));
                _moduleCall(module, moduleCall);
            }
        }
    }
    function _build(bytes12 vaultId, bytes6 seriesId, bytes6 ilkId)
        private
        returns(DataTypes.Vault memory vault)
    {
        return cauldron.build(msg.sender, vaultId, seriesId, ilkId);
    }
    function _tweak(bytes12 vaultId, bytes6 seriesId, bytes6 ilkId)
        private
        returns(DataTypes.Vault memory vault)
    {
        return cauldron.tweak(vaultId, seriesId, ilkId);
    }
    function _give(bytes12 vaultId, address receiver)
        private
        returns(DataTypes.Vault memory vault)
    {
        return cauldron.give(vaultId, receiver);
    }
    function _destroy(bytes12 vaultId)
        private
    {
        cauldron.destroy(vaultId);
    }
    function _stir(bytes12 from, bytes12 to, uint128 ink, uint128 art)
        private
        returns (DataTypes.Balances memory, DataTypes.Balances memory)
    {
        if (ink > 0) require (cauldron.vaults(from).owner == msg.sender, "Only origin vault owner");
        if (art > 0) require (cauldron.vaults(to).owner == msg.sender, "Only destination vault owner");
        return cauldron.stir(from, to, ink, art);
    }
    function _pour(bytes12 vaultId, DataTypes.Vault memory vault, address to, int128 ink, int128 art)
        private
        returns (DataTypes.Balances memory balances)
    {
        DataTypes.Series memory series;
        if (art != 0) series = getSeries(vault.seriesId);
        int128 fee;
        if (art > 0) fee = ((series.maturity - block.timestamp) * uint256(int256(art)).wmul(borrowingFee)).u128().i128();
        balances = cauldron.pour(vaultId, ink, art + fee);
        if (ink != 0) {
            IJoin ilkJoin = getJoin(vault.ilkId);
            if (ink > 0) ilkJoin.join(vault.owner, uint128(ink));
            if (ink < 0) ilkJoin.exit(to, uint128(-ink));
        }
        if (art != 0) {
            if (art > 0) series.fyToken.mint(to, uint128(art));
            else series.fyToken.burn(msg.sender, uint128(-art));
        }
    }
    function _serve(bytes12 vaultId, DataTypes.Vault memory vault, address to, uint128 ink, uint128 base, uint128 max)
        private
        returns (DataTypes.Balances memory balances, uint128 art)
    {
        IPool pool = getPool(vault.seriesId);
        art = pool.buyBasePreview(base);
        balances = _pour(vaultId, vault, address(pool), ink.i128(), art.i128());
        pool.buyBase(to, base, max);
    }
    function _close(bytes12 vaultId, DataTypes.Vault memory vault, address to, int128 ink, int128 art)
        private
        returns (DataTypes.Balances memory balances)
    {
        require (art < 0, "Only repay debt");                                          
        DataTypes.Series memory series = getSeries(vault.seriesId);
        uint128 amt = _debtInBase(vault.seriesId, series, uint128(-art));
        balances = cauldron.pour(vaultId, ink, art);
        if (ink != 0) {
            IJoin ilkJoin = getJoin(vault.ilkId);
            if (ink > 0) ilkJoin.join(vault.owner, uint128(ink));
            if (ink < 0) ilkJoin.exit(to, uint128(-ink));
        }
        IJoin baseJoin = getJoin(series.baseId);
        baseJoin.join(msg.sender, amt);
    }
    function _debtInBase(bytes6 seriesId, DataTypes.Series memory series, uint128 art)
        private
        returns (uint128 amt)
    {
        if (uint32(block.timestamp) >= series.maturity) {
            amt = uint256(art).wmul(cauldron.accrual(seriesId)).u128();
        } else {
            amt = art;
        }
    }
    function _repay(bytes12 vaultId, DataTypes.Vault memory vault, address to, int128 ink, uint128 min)
        private
        returns (DataTypes.Balances memory balances, uint128 art)
    {
        DataTypes.Series memory series = getSeries(vault.seriesId);
        IPool pool = getPool(vault.seriesId);
        art = pool.sellBase(address(series.fyToken), min);
        balances = _pour(vaultId, vault, to, ink, -(art.i128()));
    }
    function _repayVault(bytes12 vaultId, DataTypes.Vault memory vault, address to, int128 ink, uint128 max)
        private
        returns (DataTypes.Balances memory balances, uint128 base)
    {
        DataTypes.Series memory series = getSeries(vault.seriesId);
        IPool pool = getPool(vault.seriesId);
        balances = cauldron.balances(vaultId);
        base = pool.buyFYToken(address(series.fyToken), balances.art, max);
        balances = _pour(vaultId, vault, to, ink, -(balances.art.i128()));
        pool.retrieveBase(msg.sender);
    }
    function _roll(bytes12 vaultId, DataTypes.Vault memory vault, bytes6 newSeriesId, uint8 loan, uint128 max)
        private
        returns (DataTypes.Vault memory, DataTypes.Balances memory)
    {
        DataTypes.Series memory series = getSeries(vault.seriesId);
        DataTypes.Series memory newSeries = getSeries(newSeriesId);
        DataTypes.Balances memory balances = cauldron.balances(vaultId);
        uint128 newDebt;
        {
            IPool pool = getPool(newSeriesId);
            IFYToken fyToken = IFYToken(newSeries.fyToken);
            IJoin baseJoin = getJoin(series.baseId);
            uint128 amt = _debtInBase(vault.seriesId, series, balances.art);
            fyToken.mint(address(pool), amt * loan);                
            newDebt = pool.buyBase(address(baseJoin), amt, max);
            baseJoin.join(address(baseJoin), amt);                  
            pool.retrieveFYToken(address(fyToken));                 
            fyToken.burn(address(fyToken), (amt * loan) - newDebt);    
        }
        newDebt += ((newSeries.maturity - block.timestamp) * uint256(newDebt).wmul(borrowingFee)).u128();  
        return cauldron.roll(vaultId, newSeriesId, newDebt.i128() - balances.art.i128()); 
    }
    function _repayLadle(bytes12 vaultId, DataTypes.Vault memory vault)
        private
        returns (DataTypes.Balances memory balances)
    {
        DataTypes.Series memory series = getSeries(vault.seriesId);
        balances = cauldron.balances(vaultId);
        uint256 amount = series.fyToken.balanceOf(address(this));
        amount = amount <= balances.art ? amount : balances.art;
        balances = cauldron.pour(vaultId, 0, -(amount.u128().i128()));
        series.fyToken.burn(address(this), amount);
    }
    function _retrieve(bytes6 id, bool isAsset, address to) 
        private
        returns (uint256 amount)
    {
        IERC20 token = IERC20(findToken(id, isAsset));
        amount = token.balanceOf(address(this));
        token.safeTransfer(to, amount);
    }
    function settle(bytes12 vaultId, address user, uint128 ink, uint128 art)
        external
        auth
    {
        DataTypes.Vault memory vault = getOwnedVault(vaultId);
        DataTypes.Series memory series = getSeries(vault.seriesId);
        cauldron.slurp(vaultId, ink, art);                                                  
        if (ink != 0) {                                                                     
            IJoin ilkJoin = getJoin(vault.ilkId);
            ilkJoin.exit(user, ink);
        }
        if (art != 0) {                                                                     
            IJoin baseJoin = getJoin(series.baseId);
            baseJoin.join(user, art);
        }
    }
    function findToken(bytes6 id, bool isAsset)
        private view returns (address token)
    {
        token = isAsset ? cauldron.assets(id) : address(getSeries(id).fyToken);
        require (token != address(0), "Token not found");
    }
    function _forwardPermit(bytes6 id, bool isAsset, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        private
    {
        IERC2612 token = IERC2612(findToken(id, isAsset));
        token.permit(msg.sender, spender, amount, deadline, v, r, s);
    }
    function _forwardDaiPermit(bytes6 id, bool isAsset, address spender, uint256 nonce, uint256 deadline, bool allowed, uint8 v, bytes32 r, bytes32 s)
        private
    {
        DaiAbstract token = DaiAbstract(findToken(id, isAsset));
        token.permit(msg.sender, spender, nonce, deadline, allowed, v, r, s);
    }
    receive() external payable { }
    function _joinEther(bytes6 etherId)
        private
        returns (uint256 ethTransferred)
    {
        ethTransferred = address(this).balance;
        IJoin wethJoin = getJoin(etherId);
        weth.deposit{ value: ethTransferred }();   
        IERC20(address(weth)).safeTransfer(address(wethJoin), ethTransferred);
    }
    function _exitEther(address payable to)
        private
        returns (uint256 ethTransferred)
    {
        ethTransferred = weth.balanceOf(address(this));
        weth.withdraw(ethTransferred);   
        to.safeTransferETH(ethTransferred);
    }
    function _transferToPool(IPool pool, bool base, uint128 wad)
        private
    {
        IERC20 token = base ? pool.base() : pool.fyToken();
        token.safeTransferFrom(msg.sender, address(pool), wad);
    }
    function _route(IPool pool, bytes memory data)
        private
        returns (bool success, bytes memory result)
    {
        (success, result) = address(pool).call(data);
        if (!success) revert(RevertMsgExtractor.getRevertMsg(result));
    }
    function _transferToFYToken(IFYToken fyToken, uint256 wad)
        private
    {
        IERC20(fyToken).safeTransferFrom(msg.sender, address(fyToken), wad);
    }
    function _redeem(IFYToken fyToken, address to, uint256 wad)
        private
        returns (uint256)
    {
        return fyToken.redeem(to, wad != 0 ? wad : fyToken.balanceOf(address(this)));
    }
    function _moduleCall(address module, bytes memory moduleCall)
        private
        returns (bool success, bytes memory result)
    {
        require (modules[module], "Unregistered module");
        (success, result) = module.delegatecall(moduleCall);
        if (!success) revert(RevertMsgExtractor.getRevertMsg(result));
    }
}
contract DAIMock is ERC20  {
    mapping (address => uint)                      public nonces;
    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public constant PERMIT_TYPEHASH = keccak256("Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)");
    string  public constant version  = "1";
    constructor() ERC20("Dai Stablecoin", "DAI", 18) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
            keccak256(bytes(name)),
            keccak256(bytes(version)),
            chainId,
            address(this)
        ));
    }
    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }
    function permit(address holder, address spender, uint256 nonce, uint256 expiry,
                    bool allowed, uint8 v, bytes32 r, bytes32 s) external
    {
        bytes32 digest =
            keccak256(abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(abi.encode(PERMIT_TYPEHASH,
                                     holder,
                                     spender,
                                     nonce,
                                     expiry,
                                     allowed))
        ));
        require(holder != address(0), "Dai/invalid-address-0");
        require(holder == ecrecover(digest, v, r, s), "Dai/invalid-permit");
        require(expiry == 0 || block.timestamp <= expiry, "Dai/permit-expired");
        require(nonce == nonces[holder]++, "Dai/invalid-nonce");
        uint wad = allowed ? type(uint256).max : 0;
        _allowance[holder][spender] = wad;
        emit Approval(holder, spender, wad);
    }
}
contract ERC20Mock is ERC20Permit  {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20Permit(name, symbol, 18) { }
    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }
}
contract FlashBorrower is IERC3156FlashBorrower {
    enum Action {NORMAL, TRANSFER, STEAL, REENTER, APPROVE}
    IERC3156FlashLender public lender;
    uint256 public flashBalance;
    address public flashInitiator;
    address public flashToken;
    uint256 public flashAmount;
    uint256 public flashFee;
    constructor (IERC3156FlashLender lender_) {
        lender = lender_;
    }
    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) external override returns(bytes32) {
        require(msg.sender == address(lender), "FlashBorrower: Untrusted lender");
        (Action action) = abi.decode(data, (Action)); 
        flashInitiator = initiator;
        flashToken = token;
        flashAmount = amount;
        flashFee = fee;
        if (action == Action.NORMAL) {
            flashBalance = IERC20(token).balanceOf(address(this));
        } else if (action == Action.TRANSFER) {
            flashBalance = IERC20(token).balanceOf(address(this));
            IERC20(token).transfer(address(lender), amount + fee);
        } else if (action == Action.STEAL) {
            IERC20(token).transfer(address(0), amount);
        } else if (action == Action.REENTER) {    
            flashBorrow(token, amount * 2, Action.NORMAL);
        }
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
    function flashBorrow(address token, uint256 amount, Action action) public {
        bytes memory data = abi.encode(action);
        uint256 allowance = IERC20(token).allowance(address(this), address(lender));
        IERC20(token).approve(address(lender), allowance + amount + lender.flashFee(token, amount));
        lender.flashLoan(this, token, amount, data);
    }
}
interface ISourceMock {
    function set(uint) external;
}
contract ChainlinkAggregatorV3Mock is ISourceMock {
    int public price;   
    uint public timestamp;
    uint8 public decimals;  
    constructor (uint8 decimals_) {
        decimals = decimals_;
    }
    function set(uint price_) external override {
        if (decimals <= 18) price = int(price_ / 10**(18 - decimals));
        else price = int(price_ * 10**(decimals - 18));          
        timestamp = block.timestamp;
    }
    function latestRoundData() public view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, price, 0, timestamp, 0);
    }
}
contract CTokenChiMock is ISourceMock {
    uint public exchangeRateStored;
    function set(uint chi) external override {
        exchangeRateStored = chi;
    }
    function exchangeRateCurrent() public view returns (uint) {
        return exchangeRateStored;
    }
}
contract CTokenRateMock is ISourceMock {
    uint public borrowIndex;
    function set(uint rate) external override {
        borrowIndex = rate;          
    }
}
contract OracleMock is IOracle {
    address public immutable source;
    uint256 public spot;
    uint256 public updated;
    constructor() {
        source = address(this);
    }
    function peek(bytes32, bytes32, uint256 amount) external view virtual override returns (uint256, uint256) {
        return (spot * amount / 1e18, updated);
    }
    function get(bytes32, bytes32, uint256 amount) external virtual override returns (uint256, uint256) {
        updated = block.timestamp;
        return (spot * amount / 1e18, updated = block.timestamp);
    }
    function set(uint256 spot_) external virtual {
        updated = block.timestamp;
        spot = spot_;
    }
}
interface IUniswapV3PoolImmutables {
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function fee() external view returns (uint24);
    function tickSpacing() external view returns (int24);
    function maxLiquidityPerTick() external view returns (uint128);
}
contract UniswapV3PoolMock is ISourceMock, IUniswapV3PoolImmutables {
    uint public price;
    address public immutable override factory;
    address public immutable override token0;
    address public immutable override token1;
    uint24 public immutable override fee;
    constructor(address factory_, address token0_, address token1_, uint24 fee_) {
        (factory, token0, token1, fee) = (factory_, token0_, token1_, fee_);
    }
    function set(uint price_) external override {
        price = price_;
    }
    function tickSpacing() public pure override returns (int24) {
        return 0;
    }
    function maxLiquidityPerTick() public pure override returns (uint128) {
        return 0;
    }
}
contract UniswapV3FactoryMock {
    mapping(address => mapping(address => mapping(uint24 => address))) public getPool;
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool) {
        require(tokenA != tokenB, "Cannot create pool of same tokens");
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "No nil token address");
        require(getPool[token0][token1][fee] == address(0), "Pool already exists");
        pool = address(new UniswapV3PoolMock(address(this), token0, token1, fee));
        getPool[token0][token1][fee] = pool;
        getPool[token1][token0][fee] = pool;
    }
}
library UniswapV3OracleLibraryMock {
    using WMul for uint256;
    using WDiv for uint256;
    function consult(
        address factory,
        address baseToken,
        address quoteToken,
        uint24 fee,
        uint256 baseAmount,
        uint32 
    ) internal view returns (uint256 quoteAmount) {
        UniswapV3PoolMock pool = UniswapV3PoolMock(UniswapV3FactoryMock(factory).getPool(baseToken, quoteToken, fee));
        if (baseToken == pool.token0()) {
            return baseAmount.wmul(pool.price());
        }
        return baseAmount.wdiv(pool.price());
    }
}
contract RestrictedERC20Mock is AccessControl(), ERC20Permit  {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20Permit(name, symbol, 18) { }
    function mint(address to, uint256 amount) public virtual auth {
        _mint(to, amount);
    }
    function burn(address from, uint256 amount) public virtual auth {
        _burn(from, amount);
    }
}
contract GemJoinMock {
    IERC20 public immutable gem;
    constructor(IERC20 gem_) {
        gem = gem_;
    }
    function pull(address from, uint256 amount) public {
        gem.transferFrom(from, address(this), amount);
    }
}
contract TLMMock  {
    bytes32 public constant FYDAI = "FYDAI";    
    IERC20 public immutable dai;
    IERC20 public immutable gem;
    struct Ilk {
        address gemJoin;
        uint256 yield;
    }
    mapping (bytes32 => Ilk) public ilks; 
    constructor(IERC20 dai_, IERC20 fyDai_) {
        dai = dai_;
        gem = fyDai_;
        ilks[FYDAI].gemJoin = address(new GemJoinMock(fyDai_));
    }
    function sellGem(bytes32 ilk, address usr, uint256 gemAmt)
        external returns(uint256)
    {
        require(ilk == FYDAI, "Mismatched ilk");
        uint256 daiAmt = gemAmt;
        GemJoinMock(ilks[FYDAI].gemJoin).pull(msg.sender, gemAmt);
        ERC20Mock(address(dai)).mint(usr, daiAmt);
        return daiAmt;
    }
}
contract USDCMock is ERC20Permit {
    constructor() ERC20Permit("USD Coin", "USDC", 6) { }
    function version() public pure override returns(string memory) { return "2"; }
    function mint(address to, uint256 amount) public virtual {
        _mint(to, amount);
    }
}
contract WETH9Mock is ERC20 {
    event  Deposit(address indexed dst, uint wad);
    event  Withdrawal(address indexed src, uint wad);
    constructor () ERC20("Wrapped Ether", "WETH", 18) { }
    receive() external payable {
        deposit();
    }
    function deposit() public payable {
        _balanceOf[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint wad) public {
        require(_balanceOf[msg.sender] >= wad, "WETH9: Insufficient balance");
        _balanceOf[msg.sender] -= wad;
        payable(msg.sender).transfer(wad);
        emit Withdrawal(msg.sender, wad);
    }
    function totalSupply() public view override returns (uint) {
        return address(this).balance;
    }
}
library CastBytes32Bytes6 {
    function b6(bytes32 x) internal pure returns (bytes6 y){
        require (bytes32(y = bytes6(x)) == x, "Cast overflow");
    }
}
interface AggregatorV3Interface {
  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
contract ChainlinkMultiOracle is IOracle, AccessControl {
    using CastBytes32Bytes6 for bytes32;
    event SourceSet(bytes6 indexed baseId, bytes6 indexed quoteId, address indexed source);
    struct Source {
        address source;
        uint8 decimals;
        bool inverse;
    }
    mapping(bytes6 => mapping(bytes6 => Source)) public sources;
    function setSource(bytes6 base, bytes6 quote, address source) public auth {
        uint8 decimals = AggregatorV3Interface(source).decimals();
        require (decimals <= 18, "Unsupported decimals");
        sources[base][quote] = Source({
            source: source,
            decimals: decimals,
            inverse: false
        });
        sources[quote][base] = Source({
            source: source,
            decimals: decimals,
            inverse: true
        });
        emit SourceSet(base, quote, source);
        emit SourceSet(quote, base, source);
    }
    function setSources(bytes6[] memory bases, bytes6[] memory quotes, address[] memory sources_) public auth {
        require(
            bases.length == quotes.length && 
            bases.length == sources_.length,
            "Mismatched inputs"
        );
        for (uint256 i = 0; i < bases.length; i++) {
            setSource(bases[i], quotes[i], sources_[i]);
        }
    }
    function _peek(bytes6 base, bytes6 quote) private view returns (uint price, uint updateTime) {
        int rawPrice;
        uint80 roundId;
        uint80 answeredInRound;
        Source memory source = sources[base][quote];
        require (source.source != address(0), "Source not found");
        (roundId, rawPrice,, updateTime, answeredInRound) = AggregatorV3Interface(source.source).latestRoundData();
        require(rawPrice > 0, "Chainlink price <= 0");
        require(updateTime != 0, "Incomplete round");
        require(answeredInRound >= roundId, "Stale price");
        if (source.inverse == true) {
            price = 10 ** (source.decimals + 18) / uint(rawPrice);
        } else {
            price = uint(rawPrice) * 10 ** (18 - source.decimals);
        }  
    }
    function peek(bytes32 base, bytes32 quote, uint256 amount) public virtual override view returns (uint256 value, uint256 updateTime) {
        uint256 price;
        (price, updateTime) = _peek(base.b6(), quote.b6());
        value = price * amount / 1e18;
    }
    function get(bytes32 base, bytes32 quote, uint256 amount) public virtual override view returns (uint256 value, uint256 updateTime) {
        uint256 price;
        (price, updateTime) = _peek(base.b6(), quote.b6());
        value = price * amount / 1e18;
    }
}
interface CTokenInterface {
    function borrowIndex() external view returns (uint);
    function exchangeRateCurrent() external returns (uint);
    function exchangeRateStored() external view returns (uint);
}
contract CompoundMultiOracle is IOracle, AccessControl {
    using CastBytes32Bytes6 for bytes32;
    event SourceSet(bytes6 indexed baseId, bytes6 indexed kind, address indexed source);
    uint public constant SCALE_FACTOR = 1; 
    mapping(bytes6 => mapping(bytes6 => address)) public sources;
    function setSource(bytes6 base, bytes6 kind, address source) public auth {
        sources[base][kind] = source;
        emit SourceSet(base, kind, source);
    }
    function setSources(bytes6[] memory bases, bytes6[] memory kinds, address[] memory sources_) public auth {
        require(bases.length == kinds.length && kinds.length == sources_.length, "Mismatched inputs");
        for (uint256 i = 0; i < bases.length; i++)
            setSource(bases[i], kinds[i], sources_[i]);
    }
    function _peek(bytes6 base, bytes6 kind) private view returns (uint price, uint updateTime) {
        uint256 rawPrice;
        address source = sources[base][kind];
        require (source != address(0), "Source not found");
        if (kind == "rate") rawPrice = CTokenInterface(source).borrowIndex();
        else if (kind == "chi") rawPrice = CTokenInterface(source).exchangeRateStored();
        else revert("Unknown oracle type");
        require(rawPrice > 0, "Compound price is zero");
        price = rawPrice * SCALE_FACTOR;
        updateTime = block.timestamp;
    }
    function peek(bytes32 base, bytes32 kind, uint256 amount) public virtual override view returns (uint256 value, uint256 updateTime) {
        uint256 price;
        (price, updateTime) = _peek(base.b6(), kind.b6());
        value = price * amount / 1e18;
    }
    function get(bytes32 base, bytes32 kind, uint256 amount) public virtual override view returns (uint256 value, uint256 updateTime) {
        uint256 price;
        (price, updateTime) = _peek(base.b6(), kind.b6());
        value = price * amount / 1e18;
    }
}
contract UniswapV3Oracle is IOracle, AccessControl {
    using CastBytes32Bytes6 for bytes32;
    event SecondsAgoSet(uint32 indexed secondsAgo);
    event SourceSet(bytes6 indexed base, bytes6 indexed quote, address indexed source);
    struct Source {
        address source;
        bool inverse;
    }
    struct SourceData {
        address factory;
        address baseToken;
        address quoteToken;
        uint24 fee;
    }
    uint32 public secondsAgo;
    mapping(bytes6 => mapping(bytes6 => Source)) public sources;
    mapping(address => SourceData) public sourcesData;
    function setSecondsAgo(uint32 secondsAgo_) public auth {
        require(secondsAgo_ != 0, "Uniswap must look into the past.");
        secondsAgo = secondsAgo_;
        emit SecondsAgoSet(secondsAgo_);
    }
    function setSource(bytes6 base, bytes6 quote, address source) public auth {
        sources[base][quote] = Source(source, false);
        sources[quote][base] = Source(source, true);
        sourcesData[source] = SourceData(
            IUniswapV3PoolImmutables(source).factory(),
            IUniswapV3PoolImmutables(source).token0(),
            IUniswapV3PoolImmutables(source).token1(),
            IUniswapV3PoolImmutables(source).fee()
        );
        emit SourceSet(base, quote, source);
        emit SourceSet(quote, base, source);
    }
    function setSources(bytes6[] memory bases, bytes6[] memory quotes, address[] memory sources_) public auth {
        require(bases.length == quotes.length && quotes.length == sources_.length, "Mismatched inputs");
        for (uint256 i = 0; i < bases.length; i++) {
            setSource(bases[i], quotes[i], sources_[i]);
        }
    }
    function _peek(bytes6 base, bytes6 quote, uint256 amount) public virtual view returns (uint256 value, uint256 updateTime) {
        Source memory source = sources[base][quote];
        SourceData memory sourceData;
        require(source.source != address(0), "Source not found");
        sourceData = sourcesData[source.source];
        if (source.inverse) {
            value = UniswapV3OracleLibraryMock.consult(sourceData.factory, sourceData.quoteToken, sourceData.baseToken, sourceData.fee, amount, secondsAgo);
        } else {
            value = UniswapV3OracleLibraryMock.consult(sourceData.factory, sourceData.baseToken, sourceData.quoteToken, sourceData.fee, amount, secondsAgo);
        }
        updateTime = block.timestamp - secondsAgo;
    }
    function peek(bytes32 base, bytes32 quote, uint256 amount) public virtual override view returns (uint256 value, uint256 updateTime) {
        return _peek(base.b6(), quote.b6(), amount);
    }
    function get(bytes32 base, bytes32 quote, uint256 amount) public virtual override view returns (uint256 value, uint256 updateTime) {
        return _peek(base.b6(), quote.b6(), amount);
    }
}
library MinimalTransferHelper {
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        if (!(success && (data.length == 0 || abi.decode(data, (bool))))) revert(RevertMsgExtractor.getRevertMsg(data));
    }
}
library AddressStringUtil {
    function toAsciiString(address addr, uint256 len) internal pure returns (string memory) {
        require(len % 2 == 0 && len > 0 && len <= 40, 'AddressStringUtil: INVALID_LEN');
        bytes memory s = new bytes(len);
        uint256 addrNum = uint256(uint160(addr));
        for (uint256 i = 0; i < len / 2; i++) {
            uint8 b = uint8(addrNum >> (8 * (19 - i)));
            uint8 hi = b >> 4;
            uint8 lo = b - (hi << 4);
            s[2 * i] = char(hi);
            s[2 * i + 1] = char(lo);
        }
        return string(s);
    }
    function char(uint8 b) private pure returns (bytes1 c) {
        if (b < 10) {
            return bytes1(b + 0x30);
        } else {
            return bytes1(b + 0x37);
        }
    }
}
library SafeERC20Namer {
    function bytes32ToString(bytes32 x) private pure returns (string memory) {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        for (uint256 j = 0; j < 32; j++) {
            bytes1 char = x[j];
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }
    function parseStringData(bytes memory b) private pure returns (string memory) {
        uint256 charCount = 0;
        for (uint256 i = 32; i < 64; i++) {
            charCount <<= 8;
            charCount += uint8(b[i]);
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (uint256 i = 0; i < charCount; i++) {
            bytesStringTrimmed[i] = b[i + 64];
        }
        return string(bytesStringTrimmed);
    }
    function addressToName(address token) private pure returns (string memory) {
        return AddressStringUtil.toAsciiString(token, 40);
    }
    function addressToSymbol(address token) private pure returns (string memory) {
        return AddressStringUtil.toAsciiString(token, 6);
    }
    function callAndParseStringReturn(address token, bytes4 selector) private view returns (string memory) {
        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSelector(selector));
        if (!success || data.length == 0) {
            return '';
        }
        if (data.length == 32) {
            bytes32 decoded = abi.decode(data, (bytes32));
            return bytes32ToString(decoded);
        } else if (data.length > 64) {
            return abi.decode(data, (string));
        }
        return '';
    }
    function tokenSymbol(address token) public view returns (string memory) {
        string memory symbol = callAndParseStringReturn(token, 0x95d89b41);
        if (bytes(symbol).length == 0) {
            return addressToSymbol(token);
        }
        return symbol;
    }
    function tokenName(address token) public view returns (string memory) {
        string memory name = callAndParseStringReturn(token, 0x06fdde03);
        if (bytes(name).length == 0) {
            return addressToName(token);
        }
        return name;
    }
    function tokenDecimals(address token) internal view returns (uint8) {
        (bool success, bytes memory data) = token.staticcall(abi.encodeWithSelector(0x313ce567));
        return success && data.length == 32 ? abi.decode(data, (uint8)) : 18;
    }
}
interface IMultiOracleGov {
    function setSource(bytes6, bytes6, address) external;
}
interface IPoolFactory {
  event PoolCreated(address indexed base, address indexed fyToken, address pool);
  function POOL_BYTECODE_HASH() external pure returns (bytes32);
  function calculatePoolAddress(address base, address fyToken) external view returns (address);
  function getPool(address base, address fyToken) external view returns (address);
  function createPool(address base, address fyToken) external returns (address);
  function nextBase() external view returns (address);
  function nextFYToken() external view returns (address);
}
interface IOwnable {
    function transferOwnership(address) external;
}
contract Wand is AccessControl {
    bytes4 public constant JOIN = bytes4(keccak256("join(address,uint128)"));
    bytes4 public constant EXIT = bytes4(keccak256("exit(address,uint128)"));
    bytes4 public constant MINT = bytes4(keccak256("mint(address,uint256)"));
    bytes4 public constant BURN = bytes4(keccak256("burn(address,uint256)"));
    bytes6 public constant CHI = "chi";
    bytes6 public constant RATE = "rate";
    ICauldronGov public immutable cauldron;
    ILadleGov public immutable ladle;
    IPoolFactory public immutable poolFactory;
    IJoinFactory public immutable joinFactory;
    constructor (ICauldronGov cauldron_, ILadleGov ladle_, IPoolFactory poolFactory_, IJoinFactory joinFactory_) {
        cauldron = cauldron_;
        ladle = ladle_;
        poolFactory = poolFactory_;
        joinFactory = joinFactory_;
    }
    function addAsset(
        bytes6 assetId,
        address asset
    ) public auth {
        require (address(asset) != address(0), "Asset required");
        cauldron.addAsset(assetId, asset);
        AccessControl join = AccessControl(joinFactory.createJoin(asset));  
        bytes4[] memory sigs = new bytes4[](2);
        sigs[0] = JOIN;
        sigs[1] = EXIT;
        join.grantRoles(sigs, address(ladle));
        join.grantRole(join.ROOT(), msg.sender);
        ladle.addJoin(assetId, address(join));
    }
    function makeBase(bytes6 assetId, IMultiOracleGov oracle, address rateSource, address chiSource) public auth {
        require (address(oracle) != address(0), "Oracle required");
        require (rateSource != address(0), "Rate source required");
        require (chiSource != address(0), "Chi source required");
        oracle.setSource(assetId, RATE, rateSource);
        oracle.setSource(assetId, CHI, chiSource);
        cauldron.setRateOracle(assetId, IOracle(address(oracle))); 
    }
    function makeIlk(bytes6 baseId, bytes6 ilkId, IMultiOracleGov oracle, address spotSource, uint32 ratio, uint96 max, uint24 min, uint8 dec) public auth {
        oracle.setSource(baseId, ilkId, spotSource);
        cauldron.setSpotOracle(baseId, ilkId, IOracle(address(oracle)), ratio);
        cauldron.setDebtLimits(baseId, ilkId, max, min, dec);
    }
    function addSeries(
        bytes6 seriesId,
        bytes6 baseId,
        uint32 maturity,
        bytes6[] memory ilkIds,
        string memory name,
        string memory symbol
    ) public auth {
        address base = cauldron.assets(baseId);
        require(base != address(0), "Base not found");
        IJoin baseJoin = ladle.joins(baseId);
        require(address(baseJoin) != address(0), "Join not found");
        IOracle oracle = cauldron.rateOracles(baseId);
        require(address(oracle) != address(0), "Chi oracle not found");
        FYToken fyToken = new FYToken(
            baseId,
            oracle,
            baseJoin,
            maturity,
            name,     
            symbol    
        ); 
        bytes4[] memory sigs = new bytes4[](1);
        sigs[0] = EXIT;
        AccessControl(address(baseJoin)).grantRoles(sigs, address(fyToken));
        sigs = new bytes4[](2);
        sigs[0] = MINT;
        sigs[1] = BURN;
        fyToken.grantRoles(sigs, address(ladle));
        fyToken.grantRole(fyToken.ROOT(), msg.sender);
        fyToken.renounceRole(fyToken.ROOT(), address(this));
        cauldron.addSeries(seriesId, baseId, fyToken);
        cauldron.addIlks(seriesId, ilkIds);
        poolFactory.createPool(base, address(fyToken));
        IOwnable pool = IOwnable(poolFactory.calculatePoolAddress(base, address(fyToken)));
        pool.transferOwnership(msg.sender);
        ladle.addPool(seriesId, address(pool));
    }
}
interface ILadle {
    function settle(bytes12 vaultId, address user, uint128 ink, uint128 art) external;
}
library WDivUp { 
    function wdivup(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * 1e18 + y;            
        unchecked { z -= 1; }       
        z /= y;
    }
}
contract Witch is AccessControl() {
    using WMul for uint256;
    using WDiv for uint256;
    using WDivUp for uint256;
    using CastU256U128 for uint256;
    event AuctionTimeSet(uint128 indexed auctionTime);
    event InitialProportionSet(uint128 indexed initialProportion);
    event Bought(bytes12 indexed vaultId, address indexed buyer, uint256 ink, uint256 art);
    uint128 public auctionTime = 4 * 60 * 60; 
    uint128 public initialProportion = 5e17;  
    ICauldron immutable public cauldron;
    ILadle immutable public ladle;
    mapping(bytes12 => address) public vaultOwners;
    constructor (ICauldron cauldron_, ILadle ladle_) {
        cauldron = cauldron_;
        ladle = ladle_;
    }
    function setAuctionTime(uint128 auctionTime_) public auth {
        auctionTime = auctionTime_;
        emit AuctionTimeSet(auctionTime_);
    }
    function setInitialProportion(uint128 initialProportion_) public auth {
        require (initialProportion_ <= 1e18, "Only at or under 100%");
        initialProportion = initialProportion_;
        emit InitialProportionSet(initialProportion_);
    }
    function grab(bytes12 vaultId) public {
        DataTypes.Vault memory vault = cauldron.vaults(vaultId);
        vaultOwners[vaultId] = vault.owner;
        cauldron.grab(vaultId, address(this));
    }
    function buy(bytes12 vaultId, uint128 art, uint128 min) public {
        DataTypes.Balances memory balances_ = cauldron.balances(vaultId);
        require (balances_.art > 0, "Nothing to buy");                                      
        uint256 elapsed = uint32(block.timestamp) - cauldron.auctions(vaultId);           
        uint256 price;
        {
            (uint256 auctionTime_, uint256 initialProportion_) = (auctionTime, initialProportion);
            uint256 term1 = uint256(balances_.ink).wdiv(balances_.art);
            uint256 dividend2 = auctionTime_ < elapsed ? auctionTime_ : elapsed;
            uint256 divisor2 = auctionTime_;
            uint256 term2 = initialProportion_ + (1e18 - initialProportion_).wmul(dividend2.wdiv(divisor2));
            price = uint256(1e18).wdiv(term1.wmul(term2));
        }
        uint256 ink = uint256(art).wdivup(price);                                                    
        require (ink >= min, "Not enough bought");
        ladle.settle(vaultId, msg.sender, ink.u128(), art);                                        
        if (balances_.art - art == 0) {                                                             
            cauldron.give(vaultId, vaultOwners[vaultId]);
            delete vaultOwners[vaultId];
        }
        emit Bought(vaultId, msg.sender, ink, art);
    }
}
contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);
    constructor () {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}
library Math64x64 {
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
    return int128 (uint128 (x << 64));
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
    uint256 lo = (uint256 (uint128 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
    uint256 hi = uint256 (uint128 (x)) * (y >> 128);
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
    return int128 (sqrtu (uint256 (m), uint256 (uint128 (x)) + uint256 (uint128 (y)) >> 1));
    }
  }
  function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
    uint256 absoluteResult;
    bool negativeResult = false;
    if (x >= 0) {
      absoluteResult = powu (uint256 (uint128 (x)) << 63, y);
    } else {
      absoluteResult = powu (uint256 (uint128 (-x)) << 63, y);
      negativeResult = y & 1 > 0;
    }
    absoluteResult >>= 63;
    if (negativeResult) {
      require (absoluteResult <= 0x80000000000000000000000000000000);
      return -int128 (uint128 (absoluteResult)); 
    } else {
      require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return int128 (uint128 (absoluteResult)); 
    }
    }
  }
  function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
    require (x >= 0);
    return int128 (sqrtu (uint256 (uint128 (x)) << 64, 0x10000000000000000));
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
    uint256 ux = uint256 (uint128 (x)) << uint256(127 - msb);
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
    return int128 ( uint128 (
        uint256 (uint128 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
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
    result >>= uint256( uint128 (63 - (x >> 64)));
    require (result <= uint256 (uint128 (MAX_64x64)));
    return int128 (uint128 (result));
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
      assert (xh == hi >> 128);
      result += xl / y;
    }
    require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
    return uint128 (result);
    }
  }
  function powu (uint256 x, uint256 y) private pure returns (uint256) {
    unchecked {
    if (y == 0) return 0x80000000000000000000000000000000;
    else if (x == 0) return 0;
    else {
      int256 msb = 0;
      uint256 xc = x;
      if (xc >= 0x100000000000000000000000000000000) { xc >>= 128; msb += 128; }
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  
      int256 xe = msb - 127;
      if (xe > 0) x >>= uint256(xe);
      else x <<= uint256(-xe);
      uint256 result = 0x80000000000000000000000000000000;
      int256 re = 0;
      while (y > 0) {
        if (y & 1 > 0) {
          result = result * x;
          y -= 1;
          re += xe;
          if (result >=
            0x8000000000000000000000000000000000000000000000000000000000000000) {
            result >>= 128;
            re += 1;
          } else result >>= 127;
          if (re < -127) return 0; 
          require (re < 128); 
        } else {
          x = x * x;
          y >>= 1;
          xe <<= 1;
          if (x >=
            0x8000000000000000000000000000000000000000000000000000000000000000) {
            x >>= 128;
            xe += 1;
          } else x >>= 127;
          if (xe < -127) return 0; 
          require (xe < 128); 
        }
      }
      if (re > 0) result <<= uint256(re);
      else if (re < 0) result >>= uint256(-re);
      return result;
    }
    }
  }
  function sqrtu (uint256 x, uint256 r) private pure returns (uint128) {
    unchecked {
    if (x == 0) return 0;
    else {
      require (r > 0);
      while (true) {
        uint256 rr = x / r;
        if (r == rr || r + 1 == rr) return uint128 (r);
        else if (r == rr + 1) return uint128 (rr);
        r = r + rr + 1 >> 1;
      }
    }
    }
  }
}
library Exp64x64 {
  function pow(uint128 x, uint128 y, uint128 z)
  internal pure returns(uint128) {
    unchecked {
      require(z != 0);
      if(x == 0) {
        require(y != 0);
        return 0;
      } else {
        uint256 l =
          uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - log_2(x)) * y / z;
        if(l > 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) return 0;
        else return pow_2(uint128(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - l));
      }
    }
  }
  function log_2(uint128 x)
  internal pure returns(uint128) {
    unchecked {
      require(x != 0);
      uint b = x;
      uint l = 0xFE000000000000000000000000000000;
      if(b < 0x10000000000000000) {l -= 0x80000000000000000000000000000000; b <<= 64;}
      if(b < 0x1000000000000000000000000) {l -= 0x40000000000000000000000000000000; b <<= 32;}
      if(b < 0x10000000000000000000000000000) {l -= 0x20000000000000000000000000000000; b <<= 16;}
      if(b < 0x1000000000000000000000000000000) {l -= 0x10000000000000000000000000000000; b <<= 8;}
      if(b < 0x10000000000000000000000000000000) {l -= 0x8000000000000000000000000000000; b <<= 4;}
      if(b < 0x40000000000000000000000000000000) {l -= 0x4000000000000000000000000000000; b <<= 2;}
      if(b < 0x80000000000000000000000000000000) {l -= 0x2000000000000000000000000000000; b <<= 1;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x1000000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x800000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x400000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x200000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x100000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x80000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x40000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x20000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x10000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x8000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x4000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x2000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x1000000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x800000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x400000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x200000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x100000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x80000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x40000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x20000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x10000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x8000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x4000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x2000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x1000000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x800000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x400000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x200000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x100000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x80000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x40000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x20000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x10000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x8000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x4000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x2000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x1000000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x800000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x400000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x200000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x100000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x80000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x40000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x20000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x10000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x8000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x4000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x2000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x1000000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x800000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x400000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x200000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x100000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x80000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x40000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x20000000000000000;}
      b = b * b >> 127; if(b > 0x100000000000000000000000000000000) {b >>= 1; l |= 0x10000000000000000;} 
      return uint128(l);
    }
  }
  function pow_2(uint128 x)
  internal pure returns(uint128) {
    unchecked {
      uint r = 0x80000000000000000000000000000000;
      if(x & 0x1000000000000000000000000000000 > 0) r = r * 0xb504f333f9de6484597d89b3754abe9f >> 127;
      if(x & 0x800000000000000000000000000000 > 0) r = r * 0x9837f0518db8a96f46ad23182e42f6f6 >> 127;
      if(x & 0x400000000000000000000000000000 > 0) r = r * 0x8b95c1e3ea8bd6e6fbe4628758a53c90 >> 127;
      if(x & 0x200000000000000000000000000000 > 0) r = r * 0x85aac367cc487b14c5c95b8c2154c1b2 >> 127;
      if(x & 0x100000000000000000000000000000 > 0) r = r * 0x82cd8698ac2ba1d73e2a475b46520bff >> 127;
      if(x & 0x80000000000000000000000000000 > 0) r = r * 0x8164d1f3bc0307737be56527bd14def4 >> 127;
      if(x & 0x40000000000000000000000000000 > 0) r = r * 0x80b1ed4fd999ab6c25335719b6e6fd20 >> 127;
      if(x & 0x20000000000000000000000000000 > 0) r = r * 0x8058d7d2d5e5f6b094d589f608ee4aa2 >> 127;
      if(x & 0x10000000000000000000000000000 > 0) r = r * 0x802c6436d0e04f50ff8ce94a6797b3ce >> 127;
      if(x & 0x8000000000000000000000000000 > 0) r = r * 0x8016302f174676283690dfe44d11d008 >> 127;
      if(x & 0x4000000000000000000000000000 > 0) r = r * 0x800b179c82028fd0945e54e2ae18f2f0 >> 127;
      if(x & 0x2000000000000000000000000000 > 0) r = r * 0x80058baf7fee3b5d1c718b38e549cb93 >> 127;
      if(x & 0x1000000000000000000000000000 > 0) r = r * 0x8002c5d00fdcfcb6b6566a58c048be1f >> 127;
      if(x & 0x800000000000000000000000000 > 0) r = r * 0x800162e61bed4a48e84c2e1a463473d9 >> 127;
      if(x & 0x400000000000000000000000000 > 0) r = r * 0x8000b17292f702a3aa22beacca949013 >> 127;
      if(x & 0x200000000000000000000000000 > 0) r = r * 0x800058b92abbae02030c5fa5256f41fe >> 127;
      if(x & 0x100000000000000000000000000 > 0) r = r * 0x80002c5c8dade4d71776c0f4dbea67d6 >> 127;
      if(x & 0x80000000000000000000000000 > 0) r = r * 0x8000162e44eaf636526be456600bdbe4 >> 127;
      if(x & 0x40000000000000000000000000 > 0) r = r * 0x80000b1721fa7c188307016c1cd4e8b6 >> 127;
      if(x & 0x20000000000000000000000000 > 0) r = r * 0x8000058b90de7e4cecfc487503488bb1 >> 127;
      if(x & 0x10000000000000000000000000 > 0) r = r * 0x800002c5c8678f36cbfce50a6de60b14 >> 127;
      if(x & 0x8000000000000000000000000 > 0) r = r * 0x80000162e431db9f80b2347b5d62e516 >> 127;
      if(x & 0x4000000000000000000000000 > 0) r = r * 0x800000b1721872d0c7b08cf1e0114152 >> 127;
      if(x & 0x2000000000000000000000000 > 0) r = r * 0x80000058b90c1aa8a5c3736cb77e8dff >> 127;
      if(x & 0x1000000000000000000000000 > 0) r = r * 0x8000002c5c8605a4635f2efc2362d978 >> 127;
      if(x & 0x800000000000000000000000 > 0) r = r * 0x800000162e4300e635cf4a109e3939bd >> 127;
      if(x & 0x400000000000000000000000 > 0) r = r * 0x8000000b17217ff81bef9c551590cf83 >> 127;
      if(x & 0x200000000000000000000000 > 0) r = r * 0x800000058b90bfdd4e39cd52c0cfa27c >> 127;
      if(x & 0x100000000000000000000000 > 0) r = r * 0x80000002c5c85fe6f72d669e0e76e411 >> 127;
      if(x & 0x80000000000000000000000 > 0) r = r * 0x8000000162e42ff18f9ad35186d0df28 >> 127;
      if(x & 0x40000000000000000000000 > 0) r = r * 0x80000000b17217f84cce71aa0dcfffe7 >> 127;
      if(x & 0x20000000000000000000000 > 0) r = r * 0x8000000058b90bfc07a77ad56ed22aaa >> 127;
      if(x & 0x10000000000000000000000 > 0) r = r * 0x800000002c5c85fdfc23cdead40da8d6 >> 127;
      if(x & 0x8000000000000000000000 > 0) r = r * 0x80000000162e42fefc25eb1571853a66 >> 127;
      if(x & 0x4000000000000000000000 > 0) r = r * 0x800000000b17217f7d97f692baacded5 >> 127;
      if(x & 0x2000000000000000000000 > 0) r = r * 0x80000000058b90bfbead3b8b5dd254d7 >> 127;
      if(x & 0x1000000000000000000000 > 0) r = r * 0x8000000002c5c85fdf4eedd62f084e67 >> 127;
      if(x & 0x800000000000000000000 > 0) r = r * 0x800000000162e42fefa58aef378bf586 >> 127;
      if(x & 0x400000000000000000000 > 0) r = r * 0x8000000000b17217f7d24a78a3c7ef02 >> 127;
      if(x & 0x200000000000000000000 > 0) r = r * 0x800000000058b90bfbe9067c93e474a6 >> 127;
      if(x & 0x100000000000000000000 > 0) r = r * 0x80000000002c5c85fdf47b8e5a72599f >> 127;
      if(x & 0x80000000000000000000 > 0) r = r * 0x8000000000162e42fefa3bdb315934a2 >> 127;
      if(x & 0x40000000000000000000 > 0) r = r * 0x80000000000b17217f7d1d7299b49c46 >> 127;
      if(x & 0x20000000000000000000 > 0) r = r * 0x8000000000058b90bfbe8e9a8d1c4ea0 >> 127;
      if(x & 0x10000000000000000000 > 0) r = r * 0x800000000002c5c85fdf4745969ea76f >> 127;
      if(x & 0x8000000000000000000 > 0) r = r * 0x80000000000162e42fefa3a0df5373bf >> 127;
      if(x & 0x4000000000000000000 > 0) r = r * 0x800000000000b17217f7d1cff4aac1e1 >> 127;
      if(x & 0x2000000000000000000 > 0) r = r * 0x80000000000058b90bfbe8e7db95a2f1 >> 127;
      if(x & 0x1000000000000000000 > 0) r = r * 0x8000000000002c5c85fdf473e61ae1f8 >> 127;
      if(x & 0x800000000000000000 > 0) r = r * 0x800000000000162e42fefa39f121751c >> 127;
      if(x & 0x400000000000000000 > 0) r = r * 0x8000000000000b17217f7d1cf815bb96 >> 127;
      if(x & 0x200000000000000000 > 0) r = r * 0x800000000000058b90bfbe8e7bec1e0d >> 127;
      if(x & 0x100000000000000000 > 0) r = r * 0x80000000000002c5c85fdf473dee5f17 >> 127;
      if(x & 0x80000000000000000 > 0) r = r * 0x8000000000000162e42fefa39ef5438f >> 127;
      if(x & 0x40000000000000000 > 0) r = r * 0x80000000000000b17217f7d1cf7a26c8 >> 127;
      if(x & 0x20000000000000000 > 0) r = r * 0x8000000000000058b90bfbe8e7bcf4a4 >> 127;
      if(x & 0x10000000000000000 > 0) r = r * 0x800000000000002c5c85fdf473de72a2 >> 127; 
      r >>= 127 -(x >> 121);
      return uint128(r);
    }
  }
}
library YieldMath {
  using Math64x64 for int128;
  using Math64x64 for uint128;
  using Math64x64 for int256;
  using Math64x64 for uint256;
  using Exp64x64 for uint128;
  uint128 public constant ONE = 0x10000000000000000; 
  uint256 public constant MAX = type(uint128).max;   
  function fyTokenOutForBaseIn(
    uint128 baseReserves, uint128 fyTokenReserves, uint128 baseAmount,
    uint128 timeTillMaturity, int128 k, int128 g)
  public pure returns(uint128) {
    unchecked {
      uint128 a = _computeA(timeTillMaturity, k, g);
      uint256 za = baseReserves.pow(a, ONE);
      uint256 ya = fyTokenReserves.pow(a, ONE);
      uint256 zx = uint256(baseReserves) + uint256(baseAmount);
      require(zx <= MAX, "YieldMath: Too much base in");
      uint256 zxa = uint128(zx).pow(a, ONE);
      uint256 sum = za + ya - zxa; 
      require(sum <= MAX, "YieldMath: Insufficient fyToken reserves");
      uint256 result = uint256(fyTokenReserves) - uint256(uint128(sum).pow(ONE, a));
      require(result <= MAX, "YieldMath: Rounding induced error");
      result = result > 1e12 ? result - 1e12 : 0; 
      return uint128(result);
    }
  }
  function baseOutForFYTokenIn(
    uint128 baseReserves, uint128 fyTokenReserves, uint128 fyTokenAmount,
    uint128 timeTillMaturity, int128 k, int128 g)
  public pure returns(uint128) {
    unchecked {
      uint128 a = _computeA(timeTillMaturity, k, g);
      uint256 za = baseReserves.pow(a, ONE);
      uint256 ya = fyTokenReserves.pow(a, ONE);
      uint256 yx = uint256(fyTokenReserves) + uint256(fyTokenAmount);
      require(yx <= MAX, "YieldMath: Too much fyToken in");
      uint256 yxa = uint128(yx).pow(a, ONE);
      uint256 sum = za + ya - yxa; 
      require(sum <= MAX, "YieldMath: Insufficient base reserves");
      uint256 result = uint256(baseReserves) - uint256(uint128(sum).pow(ONE, a));
      require(result <= MAX, "YieldMath: Rounding induced error");
      result = result > 1e12 ? result - 1e12 : 0; 
      return uint128(result);
    }
  }
  function fyTokenInForBaseOut(
    uint128 baseReserves, uint128 fyTokenReserves, uint128 baseAmount,
    uint128 timeTillMaturity, int128 k, int128 g)
  public pure returns(uint128) {
    unchecked {
      uint128 a = _computeA(timeTillMaturity, k, g);
      uint256 za = baseReserves.pow(a, ONE);
      uint256 ya = fyTokenReserves.pow(a, ONE);
      uint256 zx = uint256(baseReserves) - uint256(baseAmount);
      require(zx <= MAX, "YieldMath: Too much base out");
      uint256 zxa = uint128(zx).pow(a, ONE);
      uint256 sum = za + ya - zxa; 
      require(sum <= MAX, "YieldMath: Resulting fyToken reserves too high");
      uint256 result = uint256(uint128(sum).pow(ONE, a)) - uint256(fyTokenReserves);
      require(result <= MAX, "YieldMath: Rounding induced error");
      result = result < MAX - 1e12 ? result + 1e12 : MAX; 
      return uint128(result);
    }
  }
  function baseInForFYTokenOut(
    uint128 baseReserves, uint128 fyTokenReserves, uint128 fyTokenAmount,
    uint128 timeTillMaturity, int128 k, int128 g)
  public pure returns(uint128) {
    unchecked {
      uint128 a = _computeA(timeTillMaturity, k, g);
      uint256 za = baseReserves.pow(a, ONE);
      uint256 ya = fyTokenReserves.pow(a, ONE);
      uint256 yx = uint256(fyTokenReserves) - uint256(fyTokenAmount);
      require(yx <= MAX, "YieldMath: Too much fyToken out");
      uint256 yxa = uint128(yx).pow(a, ONE);
      uint256 sum = za + ya - yxa; 
      require(sum <= MAX, "YieldMath: Resulting base reserves too high");
      uint256 result = uint256(uint128(sum).pow(ONE, a)) - uint256(baseReserves);
      require(result <= MAX, "YieldMath: Rounding induced error");
      result = result < MAX - 1e12 ? result + 1e12 : MAX; 
      return uint128(result);
    }
  }
  function _computeA(uint128 timeTillMaturity, int128 k, int128 g) private pure returns (uint128) {
    unchecked {
      int128 t = k.mul(timeTillMaturity.fromUInt());
      require(t >= 0, "YieldMath: t must be positive"); 
      int128 a = int128(ONE).sub(g.mul(t));
      require(a > 0, "YieldMath: Too far from maturity");
      require(a <= int128(ONE), "YieldMath: g must be positive");
      return uint128(a);
    }
  }
  function initialReservesValue(
    uint128 baseReserves, uint128 fyTokenReserves, uint128 timeTillMaturity,
    int128 k, int128 c0)
  external pure returns(uint128) {
    unchecked {
      uint256 normalizedBaseReserves = c0.mulu(baseReserves);
      require(normalizedBaseReserves <= MAX);
      int128 a = int128(ONE).sub(k.mul(timeTillMaturity.fromUInt()));
      require(a > 0);
      uint256 sum =
        uint256(uint128(normalizedBaseReserves).pow(uint128(a), ONE)) +
        uint256(fyTokenReserves.pow(uint128(a), ONE)) >> 1;
      require(sum <= MAX);
      uint256 result = uint256(uint128(sum).pow(ONE, uint128(a))) << 1;
      require(result <= MAX);
      return uint128(result);
    }
  }
}
library SafeCast256 {
    function u112(uint256 x) internal pure returns (uint112 y) {
        require (x <= type(uint112).max, "Cast overflow");
        y = uint112(x);
    }
    function u128(uint256 x) internal pure returns (uint128 y) {
        require (x <= type(uint128).max, "Cast overflow");
        y = uint128(x);
    }
    function i256(uint256 x) internal pure returns(int256) {
        require(x <= uint256(type(int256).max), "Cast overflow");
        return int256(x);
    }
}
library SafeCast128 {
    function i128(uint128 x) internal pure returns (int128 y) {
        require (x <= uint128(type(int128).max), "Cast overflow");
        y = int128(x);
    }
    function u112(uint128 x) internal pure returns (uint112 y) {
        require (x <= uint128(type(uint112).max), "Cast overflow");
        y = uint112(x);
    }
}
contract Pool is IPool, ERC20Permit, Ownable {
    using SafeCast256 for uint256;
    using SafeCast128 for uint128;
    using MinimalTransferHelper for IERC20;
    event Trade(uint32 maturity, address indexed from, address indexed to, int256 bases, int256 fyTokens);
    event Liquidity(uint32 maturity, address indexed from, address indexed to, int256 bases, int256 fyTokens, int256 poolTokens);
    event Sync(uint112 baseCached, uint112 fyTokenCached, uint256 cumulativeBalancesRatio);
    event ParameterSet(bytes32 parameter, int128 k);
    int128 private k1 = int128(uint128(uint256((1 << 64))) / 315576000); 
    int128 private g1 = int128(uint128(uint256((950 << 64))) / 1000); 
    int128 private k2 = int128(uint128(uint256((1 << 64))) / 315576000); 
    int128 private g2 = int128(uint128(uint256((1000 << 64))) / 950); 
    uint32 public immutable override maturity;
    IERC20 public immutable override base;
    IFYToken public immutable override fyToken;
    uint112 private baseCached;              
    uint112 private fyTokenCached;           
    uint32  private blockTimestampLast;             
    uint256 public cumulativeBalancesRatio;
    constructor()
        ERC20Permit(
            string(abi.encodePacked("Yield ", SafeERC20Namer.tokenName(IPoolFactory(msg.sender).nextFYToken()), " LP Token")),
            string(abi.encodePacked(SafeERC20Namer.tokenSymbol(IPoolFactory(msg.sender).nextFYToken()), "LP")),
            SafeERC20Namer.tokenDecimals(IPoolFactory(msg.sender).nextBase())
        )
    {
        IFYToken _fyToken = IFYToken(IPoolFactory(msg.sender).nextFYToken());
        fyToken = _fyToken;
        base = IERC20(IPoolFactory(msg.sender).nextBase());
        uint256 _maturity = _fyToken.maturity();
        require (_maturity <= type(uint32).max, "Pool: Maturity too far in the future");
        maturity = uint32(_maturity);
    }
    modifier beforeMaturity() {
        require(
            block.timestamp < maturity,
            "Pool: Too late"
        );
        _;
    }
    function setParameter(bytes32 parameter, int128 value) public onlyOwner {
        if (parameter == "k") k1 = k2 = value;
        else if (parameter == "g1") g1 = value;
        else if (parameter == "g2") g2 = value;
        else revert("Pool: Unrecognized parameter");
        emit ParameterSet(parameter, value);
    }
    function getK() public view returns (int128) {
        assert(k1 == k2);
        return k1;
    }
    function getG1() public view returns (int128) {
        return g1;
    }
    function getG2() public view returns (int128) {
        return g2;
    }
    function sync() external {
        _update(getBaseBalance(), getFYTokenBalance(), baseCached, fyTokenCached);
    }
    function getCache() public view returns (uint112, uint112, uint32) {
        return (baseCached, fyTokenCached, blockTimestampLast);
    }
    function getFYTokenBalance()
        public view override
        returns(uint112)
    {
        return (fyToken.balanceOf(address(this)) + _totalSupply).u112();
    }
    function getBaseBalance()
        public view override
        returns(uint112)
    {
        return base.balanceOf(address(this)).u112();
    }
    function retrieveBase(address to)
        external override
        returns(uint128 retrieved)
    {
        retrieved = getBaseBalance() - baseCached; 
        base.safeTransfer(to, retrieved);
    }
    function retrieveFYToken(address to)
        external override
        returns(uint128 retrieved)
    {
        retrieved = getFYTokenBalance() - fyTokenCached; 
        IERC20(address(fyToken)).safeTransfer(to, retrieved);
    }
    function _update(uint128 baseBalance, uint128 fyBalance, uint112 _baseCached, uint112 _fyTokenCached) private {
        uint32 blockTimestamp = uint32(block.timestamp);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; 
        if (timeElapsed > 0 && _baseCached != 0 && _fyTokenCached != 0) {
            uint256 scaledFYTokenCached = uint256(_fyTokenCached) * 1e27;
            cumulativeBalancesRatio += scaledFYTokenCached / _baseCached * timeElapsed;
        }
        baseCached = baseBalance.u112();
        fyTokenCached = fyBalance.u112();
        blockTimestampLast = blockTimestamp;
        emit Sync(baseCached, fyTokenCached, cumulativeBalancesRatio);
    }
    function mint(address to, bool calculateFromBase, uint256 minTokensMinted)
        external override
        returns (uint256, uint256, uint256)
    {
        return _mintInternal(to, calculateFromBase, 0, minTokensMinted);
    }
    function mintWithBase(address to, uint256 fyTokenToBuy, uint256 minTokensMinted)
        external override
        returns (uint256, uint256, uint256)
    {
        return _mintInternal(to, false, fyTokenToBuy, minTokensMinted);
    }
    function _mintInternal(address to, bool calculateFromBase, uint256 fyTokenToBuy, uint256 minTokensMinted)
        internal
        returns (uint256, uint256, uint256)
    {
        uint256 supply = _totalSupply;
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        uint256 _realFYTokenCached = _fyTokenCached - supply;    
        uint256 tokensMinted;
        uint256 baseIn;
        uint256 baseReturned;
        uint256 fyTokenIn;
        if (supply == 0) {
            require (calculateFromBase && fyTokenToBuy == 0, "Pool: Initialize only from base");
            baseIn = base.balanceOf(address(this)) - _baseCached;
            tokensMinted = baseIn;   
        } else {
            uint256 baseToSell;
            if (fyTokenToBuy > 0) {     
                baseToSell = _buyFYTokenPreview(
                    fyTokenToBuy.u128(),
                    _baseCached,
                    _fyTokenCached
                ); 
            }
            if (calculateFromBase) {   
                baseIn = base.balanceOf(address(this)) - _baseCached;
                tokensMinted = (supply * baseIn) / _baseCached;
                fyTokenIn = (_realFYTokenCached * tokensMinted) / supply;
                require(_realFYTokenCached + fyTokenIn <= fyToken.balanceOf(address(this)), "Pool: Not enough fyToken in");
            } else {                   
                fyTokenIn = fyToken.balanceOf(address(this)) - _realFYTokenCached;
                tokensMinted = (supply * (fyTokenToBuy + fyTokenIn)) / (_realFYTokenCached - fyTokenToBuy);
                baseIn = baseToSell + ((_baseCached + baseToSell) * tokensMinted) / supply;
                uint256 _baseBalance = base.balanceOf(address(this));
                require(_baseBalance - _baseCached >= baseIn, "Pool: Not enough base token in");
                if (fyTokenToBuy > 0) baseReturned = (_baseBalance - _baseCached) - baseIn;
            }
        }
        require (tokensMinted >= minTokensMinted, "Pool: Not enough tokens minted");
        _update(
            (_baseCached + baseIn).u128(),
            (_fyTokenCached + fyTokenIn + tokensMinted).u128(), 
            _baseCached,
            _fyTokenCached
        );
        _mint(to, tokensMinted);
        if (supply > 0 && fyTokenToBuy > 0) base.safeTransfer(to, baseReturned);
        emit Liquidity(maturity, msg.sender, to, -(baseIn.i256()), -(fyTokenIn.i256()), tokensMinted.i256());
        return (baseIn, fyTokenIn, tokensMinted);
    }
    function burn(address to, uint256 minBaseOut, uint256 minFYTokenOut)
        external override
        returns (uint256, uint256, uint256)
    {
        return _burnInternal(to, false, minBaseOut, minFYTokenOut);
    }
    function burnForBase(address to, uint256 minBaseOut)
        external override
        returns (uint256 tokensBurned, uint256 baseOut)
    {
        (tokensBurned, baseOut, ) = _burnInternal(to, true, minBaseOut, 0);
    }
    function _burnInternal(address to, bool tradeToBase, uint256 minBaseOut, uint256 minFYTokenOut)
        internal
        returns (uint256, uint256, uint256)
    {
        uint256 tokensBurned = _balanceOf[address(this)];
        uint256 supply = _totalSupply;
        uint256 fyTokenBalance = fyToken.balanceOf(address(this));          
        uint256 baseBalance = base.balanceOf(address(this));
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        uint256 tokenOut = (tokensBurned * baseBalance) / supply;
        uint256 fyTokenOut = (tokensBurned * fyTokenBalance) / supply;
        if (tradeToBase) {
            (int128 _k, int128 _g2) = (k2, g2);
            tokenOut += YieldMath.baseOutForFYTokenIn(                      
                _baseCached - tokenOut.u128(),                              
                _fyTokenCached - fyTokenOut.u128(),                         
                fyTokenOut.u128(),                                          
                maturity - uint32(block.timestamp),                         
                _k,
                _g2
            );
            fyTokenOut = 0;
        }
        require (tokenOut >= minBaseOut, "Pool: Not enough base tokens obtained");
        require (fyTokenOut >= minFYTokenOut, "Pool: Not enough fyToken obtained");
        _update(
            (baseBalance - tokenOut).u128(),
            (fyTokenBalance - fyTokenOut + supply - tokensBurned).u128(),
            _baseCached,
            _fyTokenCached
        );
        _burn(address(this), tokensBurned);
        base.safeTransfer(to, tokenOut);
        if (fyTokenOut > 0) IERC20(address(fyToken)).safeTransfer(to, fyTokenOut);
        emit Liquidity(maturity, msg.sender, to, tokenOut.i256(), fyTokenOut.i256(), -(tokensBurned.i256()));
        return (tokensBurned, tokenOut, 0);
    }
    function sellBase(address to, uint128 min)
        external override
        returns(uint128)
    {
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        uint112 _baseBalance = getBaseBalance();
        uint112 _fyTokenBalance = getFYTokenBalance();
        uint128 baseIn = _baseBalance - _baseCached;
        uint128 fyTokenOut = _sellBasePreview(
            baseIn,
            _baseCached,
            _fyTokenBalance
        );
        require(
            fyTokenOut >= min,
            "Pool: Not enough fyToken obtained"
        );
        _update(
            _baseBalance,
            _fyTokenBalance - fyTokenOut,
            _baseCached,
            _fyTokenCached
        );
        IERC20(address(fyToken)).safeTransfer(to, fyTokenOut);
        emit Trade(maturity, msg.sender, to, -(baseIn.i128()), fyTokenOut.i128());
        return fyTokenOut;
    }
    function sellBasePreview(uint128 baseIn)
        external view override
        returns(uint128)
    {
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        return _sellBasePreview(baseIn, _baseCached, _fyTokenCached);
    }
    function _sellBasePreview(
        uint128 baseIn,
        uint112 baseBalance,
        uint112 fyTokenBalance
    )
        private view
        beforeMaturity
        returns(uint128)
    {
        (int128 _k, int128 _g1) = (k1, g1);
        uint128 fyTokenOut = YieldMath.fyTokenOutForBaseIn(
            baseBalance,
            fyTokenBalance,
            baseIn,
            maturity - uint32(block.timestamp),             
            _k,
            _g1
        );
        require(
            fyTokenBalance - fyTokenOut >= baseBalance + baseIn,
            "Pool: fyToken balance too low"
        );
        return fyTokenOut;
    }
    function buyBase(address to, uint128 tokenOut, uint128 max)
        external override
        returns(uint128)
    {
        uint128 fyTokenBalance = getFYTokenBalance();
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        uint128 fyTokenIn = _buyBasePreview(
            tokenOut,
            _baseCached,
            _fyTokenCached
        );
        require(
            fyTokenBalance - _fyTokenCached >= fyTokenIn,
            "Pool: Not enough fyToken in"
        );
        require(
            fyTokenIn <= max,
            "Pool: Too much fyToken in"
        );
        _update(
            _baseCached - tokenOut,
            _fyTokenCached + fyTokenIn,
            _baseCached,
            _fyTokenCached
        );
        base.safeTransfer(to, tokenOut);
        emit Trade(maturity, msg.sender, to, tokenOut.i128(), -(fyTokenIn.i128()));
        return fyTokenIn;
    }
    function buyBasePreview(uint128 tokenOut)
        external view override
        returns(uint128)
    {
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        return _buyBasePreview(tokenOut, _baseCached, _fyTokenCached);
    }
    function _buyBasePreview(
        uint128 tokenOut,
        uint112 baseBalance,
        uint112 fyTokenBalance
    )
        private view
        beforeMaturity
        returns(uint128)
    {
        (int128 _k, int128 _g2) = (k2, g2);
        return YieldMath.fyTokenInForBaseOut(
            baseBalance,
            fyTokenBalance,
            tokenOut,
            maturity - uint32(block.timestamp),             
            _k,
            _g2
        );
    }
    function sellFYToken(address to, uint128 min)
        external override
        returns(uint128)
    {
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        uint112 _fyTokenBalance = getFYTokenBalance();
        uint112 _baseBalance = getBaseBalance();
        uint128 fyTokenIn = _fyTokenBalance - _fyTokenCached;
        uint128 baseOut = _sellFYTokenPreview(
            fyTokenIn,
            _baseCached,
            _fyTokenCached
        );
        require(
            baseOut >= min,
            "Pool: Not enough base obtained"
        );
        _update(
            _baseBalance - baseOut,
            _fyTokenBalance,
            _baseCached,
            _fyTokenCached
        );
        base.safeTransfer(to, baseOut);
        emit Trade(maturity, msg.sender, to, baseOut.i128(), -(fyTokenIn.i128()));
        return baseOut;
    }
    function sellFYTokenPreview(uint128 fyTokenIn)
        external view override
        returns(uint128)
    {
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        return _sellFYTokenPreview(fyTokenIn, _baseCached, _fyTokenCached);
    }
    function _sellFYTokenPreview(
        uint128 fyTokenIn,
        uint112 baseBalance,
        uint112 fyTokenBalance
    )
        private view
        beforeMaturity
        returns(uint128)
    {
        (int128 _k, int128 _g2) = (k2, g2);
        return YieldMath.baseOutForFYTokenIn(
            baseBalance,
            fyTokenBalance,
            fyTokenIn,
            maturity - uint32(block.timestamp),             
            _k,
            _g2
        );
    }
    function buyFYToken(address to, uint128 fyTokenOut, uint128 max)
        external override
        returns(uint128)
    {
        uint128 baseBalance = getBaseBalance();
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        uint128 baseIn = _buyFYTokenPreview(
            fyTokenOut,
            _baseCached,
            _fyTokenCached
        );
        require(
            baseBalance - _baseCached >= baseIn,
            "Pool: Not enough base token in"
        );
        require(
            baseIn <= max,
            "Pool: Too much base token in"
        );
        _update(
            _baseCached + baseIn,
            _fyTokenCached - fyTokenOut,
            _baseCached,
            _fyTokenCached
        );
        IERC20(address(fyToken)).safeTransfer(to, fyTokenOut);
        emit Trade(maturity, msg.sender, to, -(baseIn.i128()), fyTokenOut.i128());
        return baseIn;
    }
    function buyFYTokenPreview(uint128 fyTokenOut)
        external view override
        returns(uint128)
    {
        (uint112 _baseCached, uint112 _fyTokenCached) =
            (baseCached, fyTokenCached);
        return _buyFYTokenPreview(fyTokenOut, _baseCached, _fyTokenCached);
    }
    function _buyFYTokenPreview(
        uint128 fyTokenOut,
        uint128 baseBalance,
        uint128 fyTokenBalance
    )
        private view
        beforeMaturity
        returns(uint128)
    {
        (int128 _k, int128 _g1) = (k1, g1);
        uint128 baseIn = YieldMath.baseInForFYTokenOut(
            baseBalance,
            fyTokenBalance,
            fyTokenOut,
            maturity - uint32(block.timestamp),             
            _k,
            _g1
        );
        require(
            fyTokenBalance - fyTokenOut >= baseBalance + baseIn,
            "Pool: fyToken balance too low"
        );
        return baseIn;
    }
}
contract PoolFactory is IPoolFactory {
  bytes32 public constant override POOL_BYTECODE_HASH = keccak256(type(Pool).creationCode);
  address private _nextBase;
  address private _nextFYToken;
  function isContract(address account) internal view returns (bool) {
      uint256 size;
      assembly { size := extcodesize(account) }
      return size > 0;
  }
  function calculatePoolAddress(address base, address fyToken) external view override returns (address) {
    return _calculatePoolAddress(base, fyToken);
  }
  function _calculatePoolAddress(address base, address fyToken)
    private view returns (address calculatedAddress)
  {
    calculatedAddress = address(uint160(uint256(keccak256(abi.encodePacked(
      bytes1(0xff),
      address(this),
      keccak256(abi.encodePacked(base, fyToken)),
      POOL_BYTECODE_HASH
    )))));
  }
  function getPool(address base, address fyToken) external view override returns (address pool) {
    pool = _calculatePoolAddress(base, fyToken);
    if(!isContract(pool)) {
      pool = address(0);
    }
  }
  function createPool(address base, address fyToken) external override returns (address) {
    _nextBase = base;
    _nextFYToken = fyToken;
    Pool pool = new Pool{salt: keccak256(abi.encodePacked(base, fyToken))}();
    _nextBase = address(0);
    _nextFYToken = address(0);
    pool.transferOwnership(msg.sender);
    emit PoolCreated(base, fyToken, address(pool));
    return address(pool);
  }
  function nextBase() external view override returns (address) {
    return _nextBase;
  }
  function nextFYToken() external view override returns (address) {
    return _nextFYToken;
  }
}
library PoolDataTypes {
  enum TokenType { BASE, FYTOKEN, LP }
  enum Operation {
    ROUTE, 
    TRANSFER_TO_POOL, 
    FORWARD_PERMIT, 
    FORWARD_DAI_PERMIT, 
    JOIN_ETHER, 
    EXIT_ETHER 
  }
}
contract PoolRouter {
    using TransferHelper for IERC20;
    using TransferHelper for address payable;
    IPoolFactory public immutable factory;
    IWETH9 public immutable weth;
    constructor(IPoolFactory factory_, IWETH9 weth_) {
        factory = factory_;
        weth = weth_;
    }
    struct PoolAddresses {
        address base;
        address fyToken;
        address pool;
    }
    function batch(
        PoolDataTypes.Operation[] calldata operations,
        bytes[] calldata data
    ) external payable {
        require(operations.length == data.length, "Mismatched operation data");
        PoolAddresses memory cache;
        for (uint256 i = 0; i < operations.length; i += 1) {
            PoolDataTypes.Operation operation = operations[i];
            if (operation == PoolDataTypes.Operation.ROUTE) {
                (address base, address fyToken, bytes memory poolcall) = abi.decode(data[i], (address, address, bytes));
                if (cache.base != base || cache.fyToken != fyToken) cache = PoolAddresses(base, fyToken, findPool(base, fyToken));
                _route(cache, poolcall);
            } else if (operation == PoolDataTypes.Operation.TRANSFER_TO_POOL) {
                (address base, address fyToken, address token, uint128 wad) = abi.decode(data[i], (address, address, address, uint128));
                if (cache.base != base || cache.fyToken != fyToken) cache = PoolAddresses(base, fyToken, findPool(base, fyToken));
                _transferToPool(cache, token, wad);
            } else if (operation == PoolDataTypes.Operation.FORWARD_PERMIT) {
                (address base, address fyToken, address token, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) = 
                    abi.decode(data[i], (address, address, address, address, uint256, uint256, uint8, bytes32, bytes32));
                if (cache.base != base || cache.fyToken != fyToken) cache = PoolAddresses(base, fyToken, findPool(base, fyToken));
                _forwardPermit(cache, token, spender, amount, deadline, v, r, s);
            } else if (operation == PoolDataTypes.Operation.FORWARD_DAI_PERMIT) {
                        (address base, address fyToken, address spender, uint256 nonce, uint256 deadline, bool allowed, uint8 v, bytes32 r, bytes32 s) = 
                    abi.decode(data[i], (address, address, address, uint256, uint256, bool, uint8, bytes32, bytes32));
                if (cache.base != base || cache.fyToken != fyToken) cache = PoolAddresses(base, fyToken, findPool(base, fyToken));
                _forwardDaiPermit(cache, spender, nonce, deadline, allowed, v, r, s);
            } else if (operation == PoolDataTypes.Operation.JOIN_ETHER) {
                (address base, address fyToken) = abi.decode(data[i], (address, address));
                if (cache.base != base || cache.fyToken != fyToken) cache = PoolAddresses(base, fyToken, findPool(base, fyToken));
                _joinEther(cache.pool);
            } else if (operation == PoolDataTypes.Operation.EXIT_ETHER) {
                (address to) = abi.decode(data[i], (address));
                _exitEther(to);
            } else {
                revert("Invalid operation");
            }
        }
    }
    function findPool(address base, address fyToken)
        private view returns (address pool)
    {
        pool = factory.getPool(base, fyToken);
        require (pool != address(0), "Pool not found");
    }
    function transferToPool(address base, address fyToken, address token, uint128 wad)
        external payable
        returns (bool)
    {
        return _transferToPool(
            PoolAddresses(base, fyToken, findPool(base, fyToken)),
            token, wad
        );
    }
    function _transferToPool(PoolAddresses memory addresses, address token, uint128 wad)
        private
        returns (bool)
    {
        require(token == addresses.base || token == addresses.fyToken || token == addresses.pool, "Mismatched token");
        IERC20(token).safeTransferFrom(msg.sender, address(addresses.pool), wad);
        return true;
    }
    function _route(PoolAddresses memory addresses, bytes memory data)
        private
        returns (bool success, bytes memory result)
    {
        (success, result) = addresses.pool.call(data);
        if (!success) revert(RevertMsgExtractor.getRevertMsg(result));
    }
    function _forwardPermit(PoolAddresses memory addresses, address token, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s)
        private
    {
        require(token == addresses.base || token == addresses.fyToken || token == addresses.pool, "Mismatched token");
        IERC2612(token).permit(msg.sender, spender, amount, deadline, v, r, s);
    }
    function _forwardDaiPermit(PoolAddresses memory addresses, address spender, uint256 nonce, uint256 deadline, bool allowed, uint8 v, bytes32 r, bytes32 s)
        private
    {
        DaiAbstract(addresses.base).permit(msg.sender, spender, nonce, deadline, allowed, v, r, s);
    }
    receive() external payable {
        require (msg.sender == address(weth), "Only Weth contract allowed");
    }
    function _joinEther(address pool)
        private
        returns (uint256 ethTransferred)
    {
        ethTransferred = address(this).balance;
        weth.deposit{ value: ethTransferred }();   
        IERC20(weth).safeTransfer(pool, ethTransferred);
    }
    function _exitEther(address to)
        private
        returns (uint256 ethTransferred)
    {
        ethTransferred = weth.balanceOf(address(this));
        weth.withdraw(ethTransferred);   
        payable(to).safeTransferETH(ethTransferred);
    }
}
library WMulUp { 
    function wmulup(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x * y + 1e18 - 1;        
        unchecked { z /= 1e18; }     
    }
}
contract UniswapV2PairMock {
    uint112 public reserves0;
    uint112 public reserves1;
    uint32 public blockTimestamp;
    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    function setReserves(uint112 reserves0_, uint112 reserves1_, uint32 blockTimestamp_) external {
        reserves0 = reserves0_;
        reserves1 = reserves1_;
        blockTimestamp = blockTimestamp_;
    }
    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserves0, reserves1, blockTimestamp);
    }
    function setCumulativePrices(uint cumPrice0, uint cumPrice1) external {
        price0CumulativeLast = cumPrice0;
        price1CumulativeLast = cumPrice1;
    }
}