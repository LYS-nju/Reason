pragma solidity ^0.8.25;
interface IERC20Errors {
    error ERC20InsufficientBalance(address sender, uint256 balance, uint256 needed);
    error ERC20InvalidSender(address sender);
    error ERC20InvalidReceiver(address receiver);
    error ERC20InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error ERC20InvalidApprover(address approver);
    error ERC20InvalidSpender(address spender);
}
interface IERC721Errors {
    error ERC721InvalidOwner(address owner);
    error ERC721NonexistentToken(uint256 tokenId);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721InvalidSender(address sender);
    error ERC721InvalidReceiver(address receiver);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721InvalidApprover(address approver);
    error ERC721InvalidOperator(address operator);
}
interface IERC1155Errors {
    error ERC1155InsufficientBalance(address sender, uint256 balance, uint256 needed, uint256 tokenId);
    error ERC1155InvalidSender(address sender);
    error ERC1155InvalidReceiver(address receiver);
    error ERC1155MissingApprovalForAll(address operator, address owner);
    error ERC1155InvalidApprover(address approver);
    error ERC1155InvalidOperator(address operator);
    error ERC1155InvalidArrayLength(uint256 idsLength, uint256 valuesLength);
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
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
abstract contract ReentrancyGuard {
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;
    uint256 private _status;
    error ReentrancyGuardReentrantCall();
    constructor() {
        _status = NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }
        _status = ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}
interface IBaseBlastManager {
    function getConfiguredGovernor() external view returns (address _governor);
}
enum YieldMode {
    AUTOMATIC,
    VOID,
    CLAIMABLE
}
enum GasMode {
    VOID,
    CLAIMABLE
}
interface IBlastPoints {
    function configurePointsOperator(address operator) external;
}
interface IERC20Rebasing {
    function configure(YieldMode) external returns (uint256);
    function claim(
        address recipient,
        uint256 amount
    ) external returns (uint256);
    function getClaimableAmount(
        address account
    ) external view returns (uint256);
}
interface IBlast {
    function configureContract(
        address contractAddress,
        YieldMode _yield,
        GasMode gasMode,
        address governor
    ) external;
    function configure(
        YieldMode _yield,
        GasMode gasMode,
        address governor
    ) external;
    function configureClaimableYield() external;
    function configureClaimableYieldOnBehalf(address contractAddress) external;
    function configureAutomaticYield() external;
    function configureAutomaticYieldOnBehalf(address contractAddress) external;
    function configureVoidYield() external;
    function configureVoidYieldOnBehalf(address contractAddress) external;
    function configureClaimableGas() external;
    function configureClaimableGasOnBehalf(address contractAddress) external;
    function configureVoidGas() external;
    function configureVoidGasOnBehalf(address contractAddress) external;
    function configureGovernor(address _governor) external;
    function configureGovernorOnBehalf(
        address _newGovernor,
        address contractAddress
    ) external;
    function claimYield(
        address contractAddress,
        address recipientOfYield,
        uint256 amount
    ) external returns (uint256);
    function claimAllYield(
        address contractAddress,
        address recipientOfYield
    ) external returns (uint256);
    function claimAllGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256);
    function claimGasAtMinClaimRate(
        address contractAddress,
        address recipientOfGas,
        uint256 minClaimRateBips
    ) external returns (uint256);
    function claimMaxGas(
        address contractAddress,
        address recipientOfGas
    ) external returns (uint256);
    function claimGas(
        address contractAddress,
        address recipientOfGas,
        uint256 gasToClaim,
        uint256 gasSecondsToConsume
    ) external returns (uint256);
    function readClaimableYield(
        address contractAddress
    ) external view returns (uint256);
    function readYieldConfiguration(
        address contractAddress
    ) external view returns (uint8);
    function readGasParams(
        address contractAddress
    )
        external
        view
        returns (
            uint256 etherSeconds,
            uint256 etherBalance,
            uint256 lastUpdated,
            GasMode
        );
    function isAuthorized(address contractAddress) external view returns (bool);
    function isGovernor(address contractAddress) external view returns (bool);
}
enum StorageKey {
    Many,
    Paused,
    LockManager,
    AccountManager,
    ClaimManager,
    MigrationManager,
    NFTOverlord,
    SnuggeryManager,
    PrimordialManager,
    MunchadexManager,
    MunchNFT,
    MunchToken,
    RewardsManager,
    YieldDistributor,
    GasFeeDistributor,
    BlastContract,
    BlastPointsContract,
    BlastPointsOperator,
    USDBContract,
    WETHContract,
    RNGProxyContract,
    NFTAttributesManager,
    Treasury,
    OldMunchNFT,
    MaxLockDuration,
    DefaultSnuggerySize,
    MaxRevealQueue,
    MaxSchnibbleSpray,
    PetTotalSchnibbles,
    NewSlotCost,
    PrimordialsEnabled,
    BonusManager,
    ReferralBonus,
    RealmBonuses,
    RarityBonuses,
    LevelThresholds,
    PrimordialLevelThresholds,
    TotalMunchables,
    MunchablesPerRealm,
    MunchablesPerRarity,
    RaritySetBonuses,
    PointsPerPeriod,
    PointsPerToken,
    SwapEnabled,
    PointsPerMigratedNFT,
    PointsPerUnrevealedNFT,
    MinETHPetBonus,
    MaxETHPetBonus,
    PetBonusMultiplier,
    RealmLookups,
    CommonSpecies,
    RareSpecies,
    EpicSpecies,
    LegendarySpecies,
    MythicSpecies,
    CommonPercentage,
    RarePercentage,
    EpicPercentage,
    LegendaryPercentage,
    MythicPercentage,
    MigrationBonus,
    MigrationBonusEndTime,
    MigrationDiscountFactor
}
enum Role {
    Admin,
    Social_1,
    Social_2,
    Social_3,
    Social_4,
    Social_5,
    SocialApproval_1,
    SocialApproval_2,
    SocialApproval_3,
    SocialApproval_4,
    SocialApproval_5,
    PriceFeed_1,
    PriceFeed_2,
    PriceFeed_3,
    PriceFeed_4,
    PriceFeed_5,
    Snapshot,
    NewPeriod,
    ClaimYield,
    Minter,
    NFTOracle
}
enum StorageType {
    Uint,
    SmallUintArray,
    UintArray,
    SmallInt,
    SmallIntArray,
    Bool,
    Address,
    AddressArray,
    Bytes32
}
interface IConfigStorage {
    function manualNotify(uint8 _index, uint8 _length) external;
    function manualNotifyAddress(address _contract) external;
    function setRole(Role _role, address _contract, address _addr) external;
    function setUniversalRole(Role _role, address _addr) external;
    function setUint(StorageKey _key, uint256 _value, bool _notify) external;
    function setUintArray(
        StorageKey _key,
        uint256[] memory _value,
        bool _notify
    ) external;
    function setSmallUintArray(
        StorageKey _key,
        uint8[] calldata _smallUintArray,
        bool _notify
    ) external;
    function setSmallInt(StorageKey _key, int16 _value, bool _notify) external;
    function setSmallIntArray(
        StorageKey _key,
        int16[] memory _value,
        bool _notify
    ) external;
    function setBool(StorageKey _key, bool _value, bool _notify) external;
    function setAddress(StorageKey _key, address _value, bool _notify) external;
    function setAddresses(
        StorageKey[] memory _keys,
        address[] memory _values,
        bool _notify
    ) external;
    function setAddressArray(
        StorageKey _key,
        address[] memory _value,
        bool _notify
    ) external;
    function setBytes32(StorageKey _key, bytes32 _value, bool _notify) external;
    function getRole(Role _role) external view returns (address);
    function getContractRole(
        Role _role,
        address _contract
    ) external view returns (address);
    function getUniversalRole(Role _role) external view returns (address);
    function getUint(StorageKey _key) external view returns (uint256);
    function getUintArray(
        StorageKey _key
    ) external view returns (uint256[] memory);
    function getSmallUintArray(
        StorageKey _key
    ) external view returns (uint8[] memory _smallUintArray);
    function getSmallInt(StorageKey _key) external view returns (int16);
    function getSmallIntArray(
        StorageKey _key
    ) external view returns (int16[] memory);
    function getBool(StorageKey _key) external view returns (bool);
    function getAddress(StorageKey _key) external view returns (address);
    function getAddressArray(
        StorageKey _key
    ) external view returns (address[] memory);
    function getBytes32(StorageKey _key) external view returns (bytes32);
    function addNotifiableAddress(address _addr) external;
    function addNotifiableAddresses(address[] memory _addresses) external;
    function removeNotifiableAddress(address _addr) external;
    function getNotifiableAddresses()
        external
        view
        returns (address[] memory _addresses);
    error ArrayTooLongError();
}
interface IERC20YieldClaimable {
    function claimERC20Yield(address _tokenContract, uint256 _amount) external;
}
interface IHoldsGovernorship {
    function reassignBlastGovernor(address _newAddress) external;
    function isGovernorOfContract(
        address _contract
    ) external view returns (bool);
}
interface ILockManager {
    struct Lockdrop {
        uint32 start;
        uint32 end;
        uint32 minLockDuration;
    }
    struct ConfiguredToken {
        uint256 usdPrice;
        uint256 nftCost;
        uint8 decimals;
        bool active;
    }
    struct LockedToken {
        uint256 quantity;
        uint256 remainder;
        uint32 lastLockTime;
        uint32 unlockTime;
    }
    struct LockedTokenWithMetadata {
        LockedToken lockedToken;
        address tokenContract;
    }
    struct PlayerSettings {
        uint32 lockDuration;
    }
    struct USDUpdateProposal {
        uint32 proposedDate;
        address proposer;
        address[] contracts;
        uint256 proposedPrice;
        mapping(address => uint32) approvals;
        mapping(address => uint32) disapprovals;
        uint8 approvalsCount;
        uint8 disapprovalsCount;
    }
    function configureLockdrop(Lockdrop calldata _lockdropData) external;
    function configureToken(
        address _tokenContract,
        ConfiguredToken memory _tokenData
    ) external;
    function setUSDThresholds(uint8 _approve, uint8 _disapprove) external;
    function proposeUSDPrice(
        uint256 _price,
        address[] calldata _contracts
    ) external;
    function approveUSDPrice(uint256 _price) external;
    function disapproveUSDPrice(uint256 _price) external;
    function setLockDuration(uint256 _duration) external;
    function lockOnBehalf(
        address _tokenContract,
        uint256 _quantity,
        address _onBehalfOf
    ) external payable;
    function lock(address _tokenContract, uint256 _quantity) external payable;
    function unlock(address _tokenContract, uint256 _quantity) external;
    function getLocked(
        address _player
    ) external view returns (LockedTokenWithMetadata[] memory _lockedTokens);
    function getLockedWeightedValue(
        address _player
    ) external view returns (uint256 _lockedWeightedValue);
    function getConfiguredToken(
        address _tokenContract
    ) external view returns (ConfiguredToken memory _token);
    function getPlayerSettings(
        address _player
    ) external view returns (PlayerSettings calldata _settings);
    event TokenConfigured(address _tokenContract, ConfiguredToken _tokenData);
    event LockDropConfigured(Lockdrop _lockdrop_data);
    event ProposedUSDPrice(address _proposer, uint256 _price);
    event ApprovedUSDPrice(address _approver);
    event DisapprovedUSDPrice(address _disapprover);
    event RemovedUSDProposal();
    event USDThresholdUpdated(uint8 _approve, uint8 _disapprove);
    event LockDuration(address indexed _player, uint256 _duration);
    event Locked(
        address indexed _player,
        address _sender,
        address _tokenContract,
        uint256 _quantity,
        uint256 _remainder,
        uint256 _numberNFTs,
        uint256 _lockDuration
    );
    event Unlocked(
        address indexed _player,
        address _tokenContract,
        uint256 _quantity
    );
    event DiscountFactorUpdated(uint256 discountFactor);
    event USDPriceUpdated(address _tokenContract, uint256 _newPrice);
    error OnlyAccountManagerError();
    error TokenNotConfiguredError();
    error LockdropEndedError(uint32 end, uint32 block_timestamp);
    error LockdropInvalidError();
    error NFTCostInvalidError();
    error USDPriceInvalidError();
    error ProposalInProgressError();
    error ProposalInvalidContractsError();
    error NoProposalError();
    error ProposerCannotApproveError();
    error ProposalAlreadyApprovedError();
    error ProposalAlreadyDisapprovedError();
    error ProposalPriceNotMatchedError();
    error MaximumLockDurationError();
    error ETHValueIncorrectError();
    error InvalidMessageValueError();
    error InsufficientAllowanceError();
    error InsufficientLockAmountError();
    error TokenStillLockedError();
    error LockManagerInvalidCallError();
    error LockManagerRefuseETHError();
    error InvalidTokenContractError();
    error InvalidLockDurationError();
    error LockDurationReducedError();
    error SubAccountCannotLockError();
    error AccountNotRegisteredError();
    error TooManyNFTsError();
}
library MunchablesCommonLib {
    enum Rarity {
        Primordial,
        Common,
        Rare,
        Epic,
        Legendary,
        Mythic,
        Invalid
    }
    enum Realm {
        Everfrost,
        Drench,
        Moltania,
        Arridia,
        Verdentis,
        Invalid
    }
    struct NFTImmutableAttributes {
        Rarity rarity;
        uint16 species;
        Realm realm;
        uint8 generation;
        uint32 hatchedDate;
    }
    struct NFTAttributes {
        uint256 chonks;
        uint16 level;
        uint16 evolution;
        uint256 lastPettedTime;
    }
    struct NFTGameAttribute {
        GameAttributeType dataType;
        bytes value;
    }
    struct Munchadex {
        mapping(Realm => uint256) numInRealm;
        mapping(Rarity => uint256) numInRarity;
        mapping(bytes32 => uint256) unique;
        uint256 numUnique;
    }
    enum GameAttributeIndex {
        Strength,
        Agility,
        Stamina,
        Defence,
        Voracity,
        Cuteness,
        Charisma,
        Trustworthiness,
        Leadership,
        Empathy,
        Intelligence,
        Cunning,
        Creativity,
        Adaptability,
        Wisdom,
        IsOriginal,
        IndexCount 
    }
    enum GameAttributeType {
        NotSet,
        Bool,
        String,
        SmallInt,
        BigUInt,
        Bytes
    }
    struct PrimordialData {
        uint256 chonks;
        uint32 createdDate;
        int8 level;
        bool hatched;
    }
    struct SnuggeryNFT {
        uint256 tokenId;
        uint32 importedDate;
    }
    struct NFTFull {
        uint256 tokenId;
        NFTImmutableAttributes immutableAttributes;
        NFTAttributes attributes;
        NFTGameAttribute[] gameAttributes;
    }
    struct Player {
        uint32 registrationDate;
        uint32 lastPetMunchable;
        uint32 lastHarvestDate;
        Realm snuggeryRealm;
        uint16 maxSnuggerySize;
        uint256 unfedSchnibbles;
        address referrer;
    }
    error NotEnoughRandomError();
    function calculateRaritySpeciesPercentage(
        bytes memory randomBytes
    ) internal pure returns (uint32, uint32) {
        if (randomBytes.length < 5) revert NotEnoughRandomError();
        uint32 rarityBytes;
        uint8 speciesByte;
        uint32 rarityPercentage;
        uint32 speciesPercent;
        rarityBytes =
            (uint32(uint8(randomBytes[0])) << 24) |
            (uint32(uint8(randomBytes[1])) << 16) |
            (uint32(uint8(randomBytes[2])) << 8) |
            uint32(uint8(randomBytes[3]));
        speciesByte = uint8(randomBytes[4]);
        uint256 rarityPercentageTmp = (uint256(rarityBytes) * 1e6) /
            uint256(4294967295);
        uint256 speciesPercentTmp = (uint256(speciesByte) * 1e6) / uint256(255);
        rarityPercentage = uint32(rarityPercentageTmp);
        speciesPercent = uint32(speciesPercentTmp);
        return (rarityPercentage, speciesPercent);
    }
    function getLevelThresholds(
        uint256[] memory levelThresholds,
        uint256 _chonk
    )
        internal
        pure
        returns (uint16 _currentLevel, uint256 _currentLevelThreshold)
    {
        if (_chonk >= levelThresholds[99]) {
            return (101, levelThresholds[99]);
        }
        if (_chonk < levelThresholds[0]) {
            return (1, 0);
        }
        uint256 low = 0;
        uint256 high = levelThresholds.length;
        uint256 mid = 0;
        uint16 answer = 0;
        while (low < high) {
            mid = (low + high) / 2;
            if (levelThresholds[mid] <= _chonk) {
                low = mid + 1;
            } else {
                answer = uint16(mid);
                high = mid;
            }
        }
        _currentLevel = answer + 1;
        _currentLevelThreshold = levelThresholds[uint256(answer - 1)];
    }
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
abstract contract BaseConfigStorage {
    IConfigStorage public configStorage;
    bool _paused;
    modifier onlyConfigStorage() {
        if (msg.sender != address(configStorage)) revert OnlyStorageError();
        _;
    }
    modifier onlyConfiguredContract(StorageKey _key) {
        address configuredContract = configStorage.getAddress(_key);
        if (configuredContract == address(0)) revert UnconfiguredError(_key);
        if (configuredContract != msg.sender) revert UnauthorisedError();
        _;
    }
    modifier onlyConfiguredContract2(StorageKey _key, StorageKey _key2) {
        address configuredContract = configStorage.getAddress(_key);
        address configuredContract2 = configStorage.getAddress(_key2);
        if (
            configuredContract != msg.sender &&
            configuredContract2 != msg.sender
        ) {
            if (configuredContract == address(0))
                revert UnconfiguredError(_key);
            if (configuredContract2 == address(0))
                revert UnconfiguredError(_key2);
            revert UnauthorisedError();
        }
        _;
    }
    modifier onlyOneOfRoles(Role[5] memory roles) {
        for (uint256 i = 0; i < roles.length; i++) {
            if (msg.sender == configStorage.getRole(roles[i])) {
                _;
                return;
            }
        }
        revert InvalidRoleError();
    }
    modifier onlyRole(Role role) {
        if (msg.sender != configStorage.getRole(role))
            revert InvalidRoleError();
        _;
    }
    modifier onlyUniversalRole(Role role) {
        if (msg.sender != configStorage.getUniversalRole(role))
            revert InvalidRoleError();
        _;
    }
    modifier onlyAdmin() {
        if (msg.sender != configStorage.getUniversalRole(Role.Admin))
            revert InvalidRoleError();
        _;
    }
    modifier notPaused() {
        if (_paused) revert ContractsPausedError();
        _;
    }
    error UnconfiguredError(StorageKey _key);
    error UnauthorisedError();
    error OnlyStorageError();
    error InvalidRoleError();
    error ContractsPausedError();
    function configUpdated() external virtual;
    function __BaseConfigStorage_setConfigStorage(
        address _configStorage
    ) internal {
        configStorage = IConfigStorage(_configStorage);
    }
    function __BaseConfigStorage_reconfigure() internal {
        _paused = configStorage.getBool(StorageKey.Paused);
    }
}
interface IAccountManager {
    struct Squirt {
        address player; 
        uint256 schnibbles; 
    }
    struct SprayProposal {
        uint32 proposedDate; 
        Squirt[] squirts; 
    }
    function register(
        MunchablesCommonLib.Realm _snuggeryRealm,
        address _referrer
    ) external;
    function harvest() external returns (uint256 _harvested);
    function forceHarvest(address _player) external;
    function spraySchnibblesPropose(
        address[] calldata _players,
        uint256[] calldata _schnibbles
    ) external;
    function execSprayProposal(address _proposer) external;
    function removeSprayProposal(address _proposer) external;
    function addSubAccount(address _subAccount) external;
    function removeSubAccount(address _subAccount) external;
    function updatePlayer(
        address _account,
        MunchablesCommonLib.Player memory _player
    ) external;
    function getMainAccount(
        address _maybeSubAccount
    ) external view returns (address _mainAccount);
    function getSubAccounts(
        address _player,
        uint256 _start
    ) external view returns (address[20] memory _subAccounts, bool _more);
    function getPlayer(
        address _account
    )
        external
        view
        returns (
            address _mainAccount,
            MunchablesCommonLib.Player memory _player
        );
    function getFullPlayerData(
        address _account
    )
        external
        view
        returns (
            address _mainAccount,
            MunchablesCommonLib.Player memory _player,
            MunchablesCommonLib.SnuggeryNFT[] memory _snuggery,
            uint256 _snuggerySize
        );
    function getDailySchnibbles(
        address _player
    ) external view returns (uint256 _dailySchnibbles, uint256 _bonus);
    event PlayerRegistered(
        address indexed _player,
        MunchablesCommonLib.Realm _snuggeryRealm,
        address _referrer
    );
    event Harvested(address indexed _player, uint256 _harvestedSchnibbles);
    event SubAccountAdded(address indexed _player, address _subAccount);
    event SubAccountRemoved(address indexed _player, address _subAccount);
    event ProposedScnibblesSpray(address indexed _proposer, Squirt[] _squirts);
    error PlayerAlreadyRegisteredError();
    error PlayerNotRegisteredError();
    error MainAccountNotRegisteredError(address _mainAccount);
    error NoPendingRevealError();
    error SubAccountAlreadyRegisteredError();
    error SubAccountCannotRegisterError();
    error ExistingProposalError();
    error UnMatchedParametersError();
    error TooManyEntriesError();
    error EmptyParameterError();
    error InvalidRealmError();
    error SubAccountNotRegisteredError();
    error EmptyProposalError();
    error SelfReferralError();
    error DuplicateSprayerError();
    error TooManySubAccountsError();
}
interface IConfigNotifiable {
    function configUpdated() external;
}
interface IOldNFT {
    function burn(uint256 _tokenId) external;
}
interface IMigrationManager {
    enum UserLockedChoice {
        NONE,
        LOCKED_FULL_MIGRATION,
        LOCKED_BURN
    }
    struct MigrationSnapshotData {
        uint256 tokenId;
        uint256 lockAmount;
        address token;
        MunchablesCommonLib.NFTAttributes attributes;
        MunchablesCommonLib.NFTImmutableAttributes immutableAttributes;
        MunchablesCommonLib.NFTGameAttribute[] gameAttributes;
        bool claimed;
    }
    struct MigrationTotals {
        uint256 totalPurchasedAmount;
        uint256 totalLockedAmount;
        address tokenLocked;
    }
    function loadMigrationSnapshot(
        address[] calldata users,
        MigrationSnapshotData[] calldata data
    ) external;
    function loadUnrevealedSnapshot(
        address[] calldata users,
        uint16[] calldata unrevealed
    ) external;
    function sealData() external; 
    function burnNFTs(address _user, uint32 _skip) external;
    function burnRemainingPurchasedNFTs(address _user, uint32 _skip) external;
    function lockFundsForAllMigration() external payable;
    function migrateAllNFTs(address _user, uint32 _skip) external;
    function migratePurchasedNFTs(uint256[] memory tokenIds) external payable;
    function burnUnrevealedForPoints() external;
    function getUserMigrationData(
        address _user,
        uint256 _tokenId
    ) external view returns (MigrationSnapshotData memory);
    function getUserMigrationCompletedData(
        address _user
    ) external view returns (bool, MigrationTotals memory);
    function getUserNFTsLength(address _user) external view returns (uint256);
    event MigrationSnapshotLoaded(
        address[] users,
        MigrationSnapshotData[] data
    );
    event UnrevealedSnapshotLoaded(address[] users, uint16[] unrevealed);
    event MigrationSucceeded(
        address user,
        uint256[] _oldTokenIds,
        uint256[] _newTokenIds
    );
    event BurnSucceeded(address user, uint256[] _oldTokenIds);
    event BurnPurchasedSucceeded(address user, uint256[] _oldTokenIds);
    event UnrevealedSwapSucceeded(address user, uint256 amountSwapped);
    event MigrationDataSealed();
    event LockedForMigration(address user, uint256 amount, address token);
    error NotBoughtNFTError();
    error NFTPurchasedContractError();
    error UnrevealedNFTError();
    error NoMigrationExistsError();
    error InvalidMigrationOwnerError(address _owner, address _sender);
    error InvalidMigrationAmountError();
    error InvalidMigrationTokenError();
    error AllowanceTooLowError();
    error MigrationDataSealedError();
    error MigrationDataNotSealedError();
    error NoUnrevealedError();
    error NoNFTsToBurnError();
    error InvalidDataLengthError();
    error DataAlreadyLoadedError();
    error DifferentLockActionError();
    error SelfNeedsToChooseError();
    error InvalidSkipAmountError();
    error InvalidMigrationTokenIdError();
}
interface INFTOverlord {
    struct LevelUpRequest {
        address owner;
        uint16 fromLevel;
        uint16 toLevel;
    }
    struct MintProbability {
        uint32 percentage; 
        uint8[] species; 
    }
    function startReveal() external;
    function addReveal(address _player, uint16 _quantity) external;
    function reveal(
        uint256 _player,
        bytes memory _signature
    ) external returns (uint256 _tokenId);
    function mintFromPrimordial(address _player) external; 
    function revealFromPrimordial(
        uint256 _player,
        bytes memory _signature
    ) external returns (uint256 _tokenId);
    function mintForMigration(
        address _player,
        MunchablesCommonLib.NFTAttributes memory _attributes,
        MunchablesCommonLib.NFTImmutableAttributes memory _immutableAttributes,
        MunchablesCommonLib.NFTGameAttribute[] memory _gameAttributes
    ) external returns (uint256 _tokenId);
    function levelUp(uint256 _tokenId, bytes memory _rng) external;
    function munchableFed(uint256 _tokenId, address _owner) external; 
    function getUnrevealedNFTs(
        address _player
    ) external view returns (uint16 _unrevealed);
    function getLevelUpData(
        uint256 _chonks
    ) external view returns (uint16 _currentLevel, uint256 _nextLevelThreshold);
    event MunchableRevealRequested(address indexed _player);
    event MunchableLevelUpRequest(
        address indexed _player,
        uint256 _tokenId,
        uint16 _levelFrom,
        uint16 _levelTo
    );
    event Revealed(
        address indexed _owner,
        uint256 _tokenId,
        MunchablesCommonLib.NFTImmutableAttributes _immutableAttributes
    );
    event LevelledUp(
        address _owner,
        uint256 _tokenId,
        uint16 _fromLevel,
        uint16 _toLevel
    );
    event PrimordialHatched(
        address indexed _player,
        MunchablesCommonLib.NFTImmutableAttributes _immutableAttributes
    );
    event MintedForMigration(
        address _player,
        uint256 indexed _tokenId,
        MunchablesCommonLib.NFTImmutableAttributes _immutableAttributes,
        MunchablesCommonLib.NFTAttributes _attributes
    );
    error NoUnrevealedMunchablesError();
    error RevealQueueFullError();
    error RevealQueueEmptyError();
    error InvalidLevelUpRequest();
    error NoSpeciesFoundError(MunchablesCommonLib.Rarity _rarity);
    error NoRealmFoundError(uint16 _speciesId);
    error PrimordialNotEligibleError();
    error PlayerNotRegisteredError();
}
interface ISnuggeryManager {
    function importMunchable(uint256 _tokenId) external;
    function exportMunchable(uint256 _tokenId) external;
    function feed(uint256 _tokenId, uint256 _schnibbles) external;
    function increaseSnuggerySize(uint8 _quantity) external;
    function pet(address _pettedOwner, uint256 _tokenId) external;
    function getTotalChonk(
        address _player
    ) external view returns (uint256 _totalChonk);
    function getGlobalTotalChonk()
        external
        view
        returns (uint256 _totalGlobalChonk);
    function getSnuggery(
        address _player,
        uint256 _start
    )
        external
        view
        returns (
            MunchablesCommonLib.SnuggeryNFT[] memory _snuggery,
            uint256 _snuggerySize
        );
    event MunchableImported(address indexed _player, uint256 _tokenId);
    event MunchableExported(address indexed _player, uint256 _tokenId);
    event MunchableFed(
        address indexed _player,
        uint256 _tokenId,
        uint256 _baseChonks,
        int256 _bonusChonks
    );
    event MunchablePetted(
        address indexed _petter,
        address indexed _petted,
        uint256 _tokenId,
        uint256 _petterSchnibbles,
        uint256 _pettedSchnibbles
    );
    event SnuggerySizeIncreased(
        address _player,
        uint16 _previousSize,
        uint16 _newSize
    );
    error TokenNotFoundInSnuggeryError();
    error SnuggeryFullError();
    error IncorrectOwnerError();
    error InvalidOwnerError();
    error PlayerNotRegisteredError();
    error MunchableNotInSnuggeryError();
    error CannotPetOwnError();
    error PettedTooSoonError();
    error PetTooSoonError();
    error InsufficientSchnibblesError(uint256 _currentUnfedSchnibbles);
    error NoPrimordialInSnuggeryError();
    error InvalidTokenIDError();
    error NotApprovedError();
    error NotConfiguredError();
    error NotEnoughPointsError();
    error PettedIsSubAccount();
}
abstract contract ERC20 is Context, IERC20, IERC20Metadata, IERC20Errors {
    mapping(address account => uint256) private _balances;
    mapping(address account => mapping(address spender => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual returns (string memory) {
        return _name;
    }
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, value);
        return true;
    }
    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 value) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, value);
        return true;
    }
    function transferFrom(address from, address to, uint256 value) public virtual returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }
    function _transfer(address from, address to, uint256 value) internal {
        if (from == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        if (to == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(from, to, value);
    }
    function _update(address from, address to, uint256 value) internal virtual {
        if (from == address(0)) {
            _totalSupply += value;
        } else {
            uint256 fromBalance = _balances[from];
            if (fromBalance < value) {
                revert ERC20InsufficientBalance(from, fromBalance, value);
            }
            unchecked {
                _balances[from] = fromBalance - value;
            }
        }
        if (to == address(0)) {
            unchecked {
                _totalSupply -= value;
            }
        } else {
            unchecked {
                _balances[to] += value;
            }
        }
        emit Transfer(from, to, value);
    }
    function _mint(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }
    function _burn(address account, uint256 value) internal {
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }
    function _approve(address owner, address spender, uint256 value) internal {
        _approve(owner, spender, value, true);
    }
    function _approve(address owner, address spender, uint256 value, bool emitEvent) internal virtual {
        if (owner == address(0)) {
            revert ERC20InvalidApprover(address(0));
        }
        if (spender == address(0)) {
            revert ERC20InvalidSpender(address(0));
        }
        _allowances[owner][spender] = value;
        if (emitEvent) {
            emit Approval(owner, spender, value);
        }
    }
    function _spendAllowance(address owner, address spender, uint256 value) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            if (currentAllowance < value) {
                revert ERC20InsufficientAllowance(spender, currentAllowance, value);
            }
            unchecked {
                _approve(owner, spender, currentAllowance - value, false);
            }
        }
    }
}
abstract contract BaseBlastManager is
    IBaseBlastManager,
    IERC20YieldClaimable,
    BaseConfigStorage
{
    IBlast public blastContract;
    IBlastPoints public blastPointsContract;
    address private _governorConfigured;
    address private _pointsOperatorConfigured;
    bool private _blastClaimableConfigured;
    IERC20 public USDB;
    IERC20 public WETH;
    error InvalidGovernorError();
    function __BaseBlastManager_reconfigure() internal {
        address blastAddress = configStorage.getAddress(
            StorageKey.BlastContract
        );
        if (blastAddress != address(blastContract)) {
            blastContract = IBlast(blastAddress);
            if (blastContract.isAuthorized(address(this))) {
                blastContract.configureClaimableGas();
                (bool success, ) = blastAddress.call(
                    abi.encodeWithSelector(
                        bytes4(keccak256("configureClaimableYield()"))
                    )
                );
                if (success) {
                }
            }
        }
        address pointsContractAddress = configStorage.getAddress(
            StorageKey.BlastPointsContract
        );
        if (pointsContractAddress != address(blastPointsContract)) {
            blastPointsContract = IBlastPoints(pointsContractAddress);
            address pointsOperator = configStorage.getAddress(
                StorageKey.BlastPointsOperator
            );
            if (_pointsOperatorConfigured == address(0)) {
                blastPointsContract.configurePointsOperator(pointsOperator);
                _pointsOperatorConfigured = pointsOperator;
            }
        }
        address usdbAddress = configStorage.getAddress(StorageKey.USDBContract);
        address wethAddress = configStorage.getAddress(StorageKey.WETHContract);
        if (usdbAddress != address(USDB)) {
            USDB = IERC20(usdbAddress);
            IERC20Rebasing _USDB = IERC20Rebasing(usdbAddress);
            _USDB.configure(YieldMode.CLAIMABLE);
        }
        if (wethAddress != address(WETH)) {
            WETH = IERC20(wethAddress);
            IERC20Rebasing _WETH = IERC20Rebasing(wethAddress);
            _WETH.configure(YieldMode.CLAIMABLE);
        }
        address rewardsManagerAddress = configStorage.getAddress(
            StorageKey.RewardsManager
        );
        if (rewardsManagerAddress != address(0)) {
            setBlastGovernor(rewardsManagerAddress);
        }
        super.__BaseConfigStorage_reconfigure();
    }
    function setBlastGovernor(address _governor) internal {
        if (_governor == address(0)) revert InvalidGovernorError();
        if (address(blastContract) == address(0)) return;
        if (_governorConfigured == address(0)) {
            if (_governor != address(this)) {
                blastContract.configureGovernor(_governor);
            }
        } else {
            IHoldsGovernorship(_governorConfigured).reassignBlastGovernor(
                _governor
            );
        }
        _governorConfigured = _governor;
    }
    function claimERC20Yield(
        address _tokenContract,
        uint256 _amount
    ) external onlyConfiguredContract(StorageKey.RewardsManager) {
        IERC20Rebasing(_tokenContract).claim(
            configStorage.getAddress(StorageKey.RewardsManager),
            _amount
        );
    }
    function getConfiguredGovernor() external view returns (address _governor) {
        _governor = _governorConfigured;
    }
}
contract LockManager is BaseBlastManager, ILockManager, ReentrancyGuard {
    uint8 APPROVE_THRESHOLD = 3;
    uint8 DISAPPROVE_THRESHOLD = 3;
    mapping(address => ConfiguredToken) public configuredTokens;
    address[] public configuredTokenContracts;
    mapping(address => mapping(address => LockedToken)) public lockedTokens;
    mapping(address => PlayerSettings) playerSettings;
    Lockdrop public lockdrop;
    USDUpdateProposal usdUpdateProposal;
    uint32 private _usdProposalId;
    IAccountManager public accountManager;
    ISnuggeryManager public snuggeryManager;
    IMigrationManager public migrationManager;
    INFTOverlord public nftOverlord;
    modifier onlyConfiguredToken(address _tokenContract) {
        if (configuredTokens[_tokenContract].nftCost == 0)
            revert TokenNotConfiguredError();
        _;
    }
    modifier onlyActiveToken(address _tokenContract) {
        if (!configuredTokens[_tokenContract].active)
            revert TokenNotConfiguredError();
        _;
    }
    constructor(address _configStorage) {
        __BaseConfigStorage_setConfigStorage(_configStorage);
        _reconfigure();
    }
    function _reconfigure() internal {
        accountManager = IAccountManager(
            configStorage.getAddress(StorageKey.AccountManager)
        );
        migrationManager = IMigrationManager(
            configStorage.getAddress(StorageKey.MigrationManager)
        );
        snuggeryManager = ISnuggeryManager(
            configStorage.getAddress(StorageKey.SnuggeryManager)
        );
        nftOverlord = INFTOverlord(
            configStorage.getAddress(StorageKey.NFTOverlord)
        );
        super.__BaseBlastManager_reconfigure();
    }
    function configUpdated() external override onlyConfigStorage {
        _reconfigure();
    }
    fallback() external payable {
        revert LockManagerInvalidCallError();
    }
    receive() external payable {
        revert LockManagerRefuseETHError();
    }
    function configureLockdrop(
        Lockdrop calldata _lockdropData
    ) external onlyAdmin {
        if (_lockdropData.end < block.timestamp)
            revert LockdropEndedError(
                _lockdropData.end,
                uint32(block.timestamp)
            ); 
        if (_lockdropData.start >= _lockdropData.end)
            revert LockdropInvalidError();
        lockdrop = _lockdropData;
        emit LockDropConfigured(_lockdropData);
    }
    function configureToken(
        address _tokenContract,
        ConfiguredToken memory _tokenData
    ) external onlyAdmin {
        if (_tokenData.nftCost == 0) revert NFTCostInvalidError();
        if (configuredTokens[_tokenContract].nftCost == 0) {
            configuredTokenContracts.push(_tokenContract);
        }
        configuredTokens[_tokenContract] = _tokenData;
        emit TokenConfigured(_tokenContract, _tokenData);
    }
    function setUSDThresholds(
        uint8 _approve,
        uint8 _disapprove
    ) external onlyAdmin {
        if (usdUpdateProposal.proposer != address(0))
            revert ProposalInProgressError();
        APPROVE_THRESHOLD = _approve;
        DISAPPROVE_THRESHOLD = _disapprove;
        emit USDThresholdUpdated(_approve, _disapprove);
    }
    function proposeUSDPrice(
        uint256 _price,
        address[] calldata _contracts
    )
        external
        onlyOneOfRoles(
            [
                Role.PriceFeed_1,
                Role.PriceFeed_2,
                Role.PriceFeed_3,
                Role.PriceFeed_4,
                Role.PriceFeed_5
            ]
        )
    {
        if (usdUpdateProposal.proposer != address(0))
            revert ProposalInProgressError();
        if (_contracts.length == 0) revert ProposalInvalidContractsError();
        delete usdUpdateProposal;
        ++_usdProposalId;
        usdUpdateProposal.proposedDate = uint32(block.timestamp);
        usdUpdateProposal.proposer = msg.sender;
        usdUpdateProposal.proposedPrice = _price;
        usdUpdateProposal.contracts = _contracts;
        usdUpdateProposal.approvals[msg.sender] = _usdProposalId;
        usdUpdateProposal.approvalsCount++;
        emit ProposedUSDPrice(msg.sender, _price);
    }
    function approveUSDPrice(
        uint256 _price
    )
        external
        onlyOneOfRoles(
            [
                Role.PriceFeed_1,
                Role.PriceFeed_2,
                Role.PriceFeed_3,
                Role.PriceFeed_4,
                Role.PriceFeed_5
            ]
        )
    {
        if (usdUpdateProposal.proposer == address(0)) revert NoProposalError();
        if (usdUpdateProposal.proposer == msg.sender)
            revert ProposerCannotApproveError();
        if (usdUpdateProposal.approvals[msg.sender] == _usdProposalId)
            revert ProposalAlreadyApprovedError();
        if (usdUpdateProposal.proposedPrice != _price)
            revert ProposalPriceNotMatchedError();
        usdUpdateProposal.approvals[msg.sender] = _usdProposalId;
        usdUpdateProposal.approvalsCount++;
        if (usdUpdateProposal.approvalsCount >= APPROVE_THRESHOLD) {
            _execUSDPriceUpdate();
        }
        emit ApprovedUSDPrice(msg.sender);
    }
    function disapproveUSDPrice(
        uint256 _price
    )
        external
        onlyOneOfRoles(
            [
                Role.PriceFeed_1,
                Role.PriceFeed_2,
                Role.PriceFeed_3,
                Role.PriceFeed_4,
                Role.PriceFeed_5
            ]
        )
    {
        if (usdUpdateProposal.proposer == address(0)) revert NoProposalError();
        if (usdUpdateProposal.approvals[msg.sender] == _usdProposalId)
            revert ProposalAlreadyApprovedError();
        if (usdUpdateProposal.disapprovals[msg.sender] == _usdProposalId)
            revert ProposalAlreadyDisapprovedError();
        if (usdUpdateProposal.proposedPrice != _price)
            revert ProposalPriceNotMatchedError();
        usdUpdateProposal.disapprovalsCount++;
        usdUpdateProposal.disapprovals[msg.sender] = _usdProposalId;
        emit DisapprovedUSDPrice(msg.sender);
        if (usdUpdateProposal.disapprovalsCount >= DISAPPROVE_THRESHOLD) {
            delete usdUpdateProposal;
            emit RemovedUSDProposal();
        }
    }
    function setLockDuration(uint256 _duration) external notPaused {
        if (_duration > configStorage.getUint(StorageKey.MaxLockDuration))
            revert MaximumLockDurationError();
        playerSettings[msg.sender].lockDuration = uint32(_duration);
        uint256 configuredTokensLength = configuredTokenContracts.length;
        for (uint256 i; i < configuredTokensLength; i++) {
            address tokenContract = configuredTokenContracts[i];
            if (lockedTokens[msg.sender][tokenContract].quantity > 0) {
                if (
                    uint32(block.timestamp) + uint32(_duration) <
                    lockedTokens[msg.sender][tokenContract].unlockTime
                ) {
                    revert LockDurationReducedError();
                }
                uint32 lastLockTime = lockedTokens[msg.sender][tokenContract]
                    .lastLockTime;
                lockedTokens[msg.sender][tokenContract].unlockTime =
                    lastLockTime +
                    uint32(_duration);
            }
        }
        emit LockDuration(msg.sender, _duration);
    }
    function lockOnBehalf(
        address _tokenContract,
        uint256 _quantity,
        address _onBehalfOf
    )
        external
        payable
        notPaused
        onlyActiveToken(_tokenContract)
        onlyConfiguredToken(_tokenContract)
        nonReentrant
    {
        address tokenOwner = msg.sender;
        address lockRecipient = msg.sender;
        if (_onBehalfOf != address(0)) {
            lockRecipient = _onBehalfOf;
        }
        _lock(_tokenContract, _quantity, tokenOwner, lockRecipient);
    }
    function lock(
        address _tokenContract,
        uint256 _quantity
    )
        external
        payable
        notPaused
        onlyActiveToken(_tokenContract)
        onlyConfiguredToken(_tokenContract)
        nonReentrant
    {
        _lock(_tokenContract, _quantity, msg.sender, msg.sender);
    }
    function _lock(
        address _tokenContract,
        uint256 _quantity,
        address _tokenOwner,
        address _lockRecipient
    ) private {
        (
            address _mainAccount,
            MunchablesCommonLib.Player memory _player
        ) = accountManager.getPlayer(_lockRecipient);
        if (_mainAccount != _lockRecipient) revert SubAccountCannotLockError();
        if (_player.registrationDate == 0) revert AccountNotRegisteredError();
        if (_tokenContract == address(0)) {
            if (msg.value != _quantity) revert ETHValueIncorrectError();
        } else {
            if (msg.value != 0) revert InvalidMessageValueError();
            IERC20 token = IERC20(_tokenContract);
            uint256 allowance = token.allowance(_tokenOwner, address(this));
            if (allowance < _quantity) revert InsufficientAllowanceError();
        }
        LockedToken storage lockedToken = lockedTokens[_lockRecipient][
            _tokenContract
        ];
        ConfiguredToken storage configuredToken = configuredTokens[
            _tokenContract
        ];
        accountManager.forceHarvest(_lockRecipient);
        uint256 quantity = _quantity + lockedToken.remainder;
        uint256 remainder;
        uint256 numberNFTs;
        uint32 _lockDuration = playerSettings[_lockRecipient].lockDuration;
        if (_lockDuration == 0) {
            _lockDuration = lockdrop.minLockDuration;
        }
        if (
            lockdrop.start <= uint32(block.timestamp) &&
            lockdrop.end >= uint32(block.timestamp)
        ) {
            if (
                _lockDuration < lockdrop.minLockDuration ||
                _lockDuration >
                uint32(configStorage.getUint(StorageKey.MaxLockDuration))
            ) revert InvalidLockDurationError();
            if (msg.sender != address(migrationManager)) {
                remainder = quantity % configuredToken.nftCost;
                numberNFTs = (quantity - remainder) / configuredToken.nftCost;
                if (numberNFTs > type(uint16).max) revert TooManyNFTsError();
                nftOverlord.addReveal(_lockRecipient, uint16(numberNFTs));
            }
        }
        if (_tokenContract != address(0)) {
            IERC20 token = IERC20(_tokenContract);
            token.transferFrom(_tokenOwner, address(this), _quantity);
        }
        lockedToken.remainder = remainder;
        lockedToken.quantity += _quantity;
        lockedToken.lastLockTime = uint32(block.timestamp);
        lockedToken.unlockTime =
            uint32(block.timestamp) +
            uint32(_lockDuration);
        playerSettings[_lockRecipient].lockDuration = _lockDuration;
        emit Locked(
            _lockRecipient,
            _tokenOwner,
            _tokenContract,
            _quantity,
            remainder,
            numberNFTs,
            _lockDuration
        );
    }
    function unlock(
        address _tokenContract,
        uint256 _quantity
    ) external notPaused nonReentrant {
        LockedToken storage lockedToken = lockedTokens[msg.sender][
            _tokenContract
        ];
        if (lockedToken.quantity < _quantity)
            revert InsufficientLockAmountError();
        if (lockedToken.unlockTime > uint32(block.timestamp))
            revert TokenStillLockedError();
        accountManager.forceHarvest(msg.sender);
        lockedToken.quantity -= _quantity;
        if (_tokenContract == address(0)) {
            payable(msg.sender).transfer(_quantity);
        } else {
            IERC20 token = IERC20(_tokenContract);
            token.transfer(msg.sender, _quantity);
        }
        emit Unlocked(msg.sender, _tokenContract, _quantity);
    }
    function getLocked(
        address _player
    ) external view returns (LockedTokenWithMetadata[] memory _lockedTokens) {
        uint256 configuredTokensLength = configuredTokenContracts.length;
        LockedTokenWithMetadata[]
            memory tmpLockedTokens = new LockedTokenWithMetadata[](
                configuredTokensLength
            );
        for (uint256 i; i < configuredTokensLength; i++) {
            LockedToken memory tmpLockedToken;
            tmpLockedToken.unlockTime = lockedTokens[_player][
                configuredTokenContracts[i]
            ].unlockTime;
            tmpLockedToken.quantity = lockedTokens[_player][
                configuredTokenContracts[i]
            ].quantity;
            tmpLockedToken.lastLockTime = lockedTokens[_player][
                configuredTokenContracts[i]
            ].lastLockTime;
            tmpLockedToken.remainder = lockedTokens[_player][
                configuredTokenContracts[i]
            ].remainder;
            tmpLockedTokens[i] = LockedTokenWithMetadata(
                tmpLockedToken,
                configuredTokenContracts[i]
            );
        }
        _lockedTokens = tmpLockedTokens;
    }
    function getLockedWeightedValue(
        address _player
    ) external view returns (uint256 _lockedWeightedValue) {
        uint256 lockedWeighted = 0;
        uint256 configuredTokensLength = configuredTokenContracts.length;
        for (uint256 i; i < configuredTokensLength; i++) {
            if (
                lockedTokens[_player][configuredTokenContracts[i]].quantity >
                0 &&
                configuredTokens[configuredTokenContracts[i]].active
            ) {
                uint256 deltaDecimal = 10 **
                    (18 -
                        configuredTokens[configuredTokenContracts[i]].decimals);
                lockedWeighted +=
                    (deltaDecimal *
                        lockedTokens[_player][configuredTokenContracts[i]]
                            .quantity *
                        configuredTokens[configuredTokenContracts[i]]
                            .usdPrice) /
                    1e18;
            }
        }
        _lockedWeightedValue = lockedWeighted;
    }
    function getConfiguredToken(
        address _tokenContract
    ) external view returns (ConfiguredToken memory _token) {
        _token = configuredTokens[_tokenContract];
    }
    function getPlayerSettings(
        address _player
    ) external view returns (PlayerSettings memory _settings) {
        _settings = playerSettings[_player];
    }
    function _execUSDPriceUpdate() internal {
        if (
            usdUpdateProposal.approvalsCount >= APPROVE_THRESHOLD &&
            usdUpdateProposal.disapprovalsCount < DISAPPROVE_THRESHOLD
        ) {
            uint256 updateTokensLength = usdUpdateProposal.contracts.length;
            for (uint256 i; i < updateTokensLength; i++) {
                address tokenContract = usdUpdateProposal.contracts[i];
                if (configuredTokens[tokenContract].nftCost != 0) {
                    configuredTokens[tokenContract].usdPrice = usdUpdateProposal
                        .proposedPrice;
                    emit USDPriceUpdated(
                        tokenContract,
                        usdUpdateProposal.proposedPrice
                    );
                }
            }
            delete usdUpdateProposal;
        }
    }
}