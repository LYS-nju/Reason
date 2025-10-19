pragma solidity ^0.8.0;
import {Ownable} from "solady/auth/Ownable.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {IERC20hTokenRootFactory} from "./interfaces/IERC20hTokenRootFactory.sol";
import {IRootBridgeAgent as IBridgeAgent} from "./interfaces/IRootBridgeAgent.sol";
import {IRootPort, ICoreRootRouter, GasParams, VirtualAccount} from "./interfaces/IRootPort.sol";
import {ERC20hTokenRoot} from "./token/ERC20hTokenRoot.sol";
contract RootPort is Ownable, IRootPort {
    using SafeTransferLib for address;
    bool internal _setup;
    bool internal _setupCore;
    uint256 public immutable localChainId;
    address public localBranchPortAddress;
    address public coreRootRouterAddress;
    address public coreRootBridgeAgentAddress;
    mapping(address user => VirtualAccount account) public getUserAccount;
    mapping(VirtualAccount acount => mapping(address router => bool allowed)) public isRouterApproved;
    mapping(uint256 chainId => bool isActive) public isChainId;
    mapping(address bridgeAgent => bool isActive) public isBridgeAgent;
    address[] public bridgeAgents;
    mapping(address bridgeAgent => address bridgeAgentManager) public getBridgeAgentManager;
    mapping(address bridgeAgentFactory => bool isActive) public isBridgeAgentFactory;
    address[] public bridgeAgentFactories;
    mapping(address token => bool isGlobalToken) public isGlobalAddress;
    mapping(address chainId => mapping(uint256 localAddress => address globalAddress)) public getGlobalTokenFromLocal;
    mapping(address chainId => mapping(uint256 globalAddress => address localAddress)) public getLocalTokenFromGlobal;
    mapping(address chainId => mapping(uint256 underlyingAddress => address localAddress)) public
        getLocalTokenFromUnderlying;
    mapping(address chainId => mapping(uint256 localAddress => address underlyingAddress)) public
        getUnderlyingTokenFromLocal;
    constructor(uint256 _localChainId) {
        localChainId = _localChainId;
        isChainId[_localChainId] = true;
        _initializeOwner(msg.sender);
        _setup = true;
        _setupCore = true;
    }
    function initialize(address _bridgeAgentFactory, address _coreRootRouter) external onlyOwner {
        require(_bridgeAgentFactory != address(0), "Bridge Agent Factory cannot be 0 address.");
        require(_coreRootRouter != address(0), "Core Root Router cannot be 0 address.");
        require(_setup, "Setup ended.");
        _setup = false;
        isBridgeAgentFactory[_bridgeAgentFactory] = true;
        bridgeAgentFactories.push(_bridgeAgentFactory);
        coreRootRouterAddress = _coreRootRouter;
    }
    function initializeCore(
        address _coreRootBridgeAgent,
        address _coreLocalBranchBridgeAgent,
        address _localBranchPortAddress
    ) external onlyOwner {
        require(_coreRootBridgeAgent != address(0), "Core Root Bridge Agent cannot be 0 address.");
        require(_coreLocalBranchBridgeAgent != address(0), "Core Local Branch Bridge Agent cannot be 0 address.");
        require(_localBranchPortAddress != address(0), "Local Branch Port Address cannot be 0 address.");
        require(isBridgeAgent[_coreRootBridgeAgent], "Core Bridge Agent doesn't exist.");
        require(_setupCore, "Core Setup ended.");
        _setupCore = false;
        coreRootBridgeAgentAddress = _coreRootBridgeAgent;
        localBranchPortAddress = _localBranchPortAddress;
        IBridgeAgent(_coreRootBridgeAgent).syncBranchBridgeAgent(_coreLocalBranchBridgeAgent, localChainId);
        getBridgeAgentManager[_coreRootBridgeAgent] = owner();
    }
    function renounceOwnership() public payable override onlyOwner {
        revert("Cannot renounce ownership");
    }
    function getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        override
        returns (address)
    {
        return _getLocalToken(_localAddress, _srcChainId, _dstChainId);
    }
    function _getLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        internal
        view
        returns (address)
    {
        address globalAddress = getGlobalTokenFromLocal[_localAddress][_srcChainId];
        return getLocalTokenFromGlobal[globalAddress][_dstChainId];
    }
    function getUnderlyingTokenFromGlobal(address _globalAddress, uint256 _srcChainId)
        external
        view
        override
        returns (address)
    {
        address localAddress = getLocalTokenFromGlobal[_globalAddress][_srcChainId];
        return getUnderlyingTokenFromLocal[localAddress][_srcChainId];
    }
    function isGlobalToken(address _globalAddress, uint256 _srcChainId) external view override returns (bool) {
        return getLocalTokenFromGlobal[_globalAddress][_srcChainId] != address(0);
    }
    function isLocalToken(address _localAddress, uint256 _srcChainId) external view override returns (bool) {
        return getGlobalTokenFromLocal[_localAddress][_srcChainId] != address(0);
    }
    function isLocalToken(address _localAddress, uint256 _srcChainId, uint256 _dstChainId)
        external
        view
        returns (bool)
    {
        return _getLocalToken(_localAddress, _srcChainId, _dstChainId) != address(0);
    }
    function isUnderlyingToken(address _underlyingToken, uint256 _srcChainId) external view override returns (bool) {
        return getLocalTokenFromUnderlying[_underlyingToken][_srcChainId] != address(0);
    }
    function setAddresses(
        address _globalAddress,
        address _localAddress,
        address _underlyingAddress,
        uint256 _srcChainId
    ) external override requiresCoreRootRouter {
        if (_globalAddress == address(0)) revert InvalidGlobalAddress();
        if (_localAddress == address(0)) revert InvalidLocalAddress();
        if (_underlyingAddress == address(0)) revert InvalidUnderlyingAddress();
        isGlobalAddress[_globalAddress] = true;
        getGlobalTokenFromLocal[_localAddress][_srcChainId] = _globalAddress;
        getLocalTokenFromGlobal[_globalAddress][_srcChainId] = _localAddress;
        getLocalTokenFromUnderlying[_underlyingAddress][_srcChainId] = _localAddress;
        getUnderlyingTokenFromLocal[_localAddress][_srcChainId] = _underlyingAddress;
        emit LocalTokenAdded(_underlyingAddress, _localAddress, _globalAddress, _srcChainId);
    }
    function setLocalAddress(address _globalAddress, address _localAddress, uint256 _srcChainId)
        external
        override
        requiresCoreRootRouter
    {
        if (_localAddress == address(0)) revert InvalidLocalAddress();
        getGlobalTokenFromLocal[_localAddress][_srcChainId] = _globalAddress;
        getLocalTokenFromGlobal[_globalAddress][_srcChainId] = _localAddress;
        emit GlobalTokenAdded(_localAddress, _globalAddress, _srcChainId);
    }
    function bridgeToRoot(address _recipient, address _hToken, uint256 _amount, uint256 _deposit, uint256 _srcChainId)
        external
        override
        requiresBridgeAgent
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        if (_amount - _deposit > 0) {
            unchecked {
                _hToken.safeTransfer(_recipient, _amount - _deposit);
            }
        }
        if (_deposit > 0) if (!ERC20hTokenRoot(_hToken).mint(_recipient, _deposit, _srcChainId)) revert UnableToMint();
    }
    function bridgeToRootFromLocalBranch(address _from, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        _hToken.safeTransferFrom(_from, address(this), _amount);
    }
    function bridgeToLocalBranchFromRoot(address _to, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        _hToken.safeTransfer(_to, _amount);
    }
    function burn(address _from, address _hToken, uint256 _amount, uint256 _srcChainId)
        external
        override
        requiresBridgeAgent
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        ERC20hTokenRoot(_hToken).burn(_from, _amount, _srcChainId);
    }
    function burnFromLocalBranch(address _from, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        ERC20hTokenRoot(_hToken).burn(_from, _amount, localChainId);
    }
    function mintToLocalBranch(address _to, address _hToken, uint256 _amount)
        external
        override
        requiresLocalBranchPort
    {
        if (!isGlobalAddress[_hToken]) revert UnrecognizedToken();
        if (!ERC20hTokenRoot(_hToken).mint(_to, _amount, localChainId)) revert UnableToMint();
    }
    function fetchVirtualAccount(address _user) external override returns (VirtualAccount account) {
        account = getUserAccount[_user];
        if (address(account) == address(0)) account = addVirtualAccount(_user);
    }
    function addVirtualAccount(address _user) internal returns (VirtualAccount newAccount) {
        if (_user == address(0)) revert InvalidUserAddress();
        newAccount = new VirtualAccount{salt: keccak256(abi.encode(_user))}(_user, address(this));
        getUserAccount[_user] = newAccount;
        emit VirtualAccountCreated(_user, address(newAccount));
    }
    function toggleVirtualAccountApproved(VirtualAccount _userAccount, address _router)
        external
        override
        requiresBridgeAgent
    {
        isRouterApproved[_userAccount][_router] = !isRouterApproved[_userAccount][_router];
    }
    function addBridgeAgent(address _manager, address _bridgeAgent) external override requiresBridgeAgentFactory {
        if (isBridgeAgent[_bridgeAgent]) revert AlreadyAddedBridgeAgent();
        bridgeAgents.push(_bridgeAgent);
        getBridgeAgentManager[_bridgeAgent] = _manager;
        isBridgeAgent[_bridgeAgent] = true;
        emit BridgeAgentAdded(_bridgeAgent, _manager);
    }
    function syncBranchBridgeAgentWithRoot(
        address _newBranchBridgeAgent,
        address _rootBridgeAgent,
        uint256 _branchChainId
    ) external override requiresCoreRootRouter {
        if (IBridgeAgent(_rootBridgeAgent).getBranchBridgeAgent(_branchChainId) != address(0)) {
            revert AlreadyAddedBridgeAgent();
        }
        if (!IBridgeAgent(_rootBridgeAgent).isBranchBridgeAgentAllowed(_branchChainId)) {
            revert BridgeAgentNotAllowed();
        }
        IBridgeAgent(_rootBridgeAgent).syncBranchBridgeAgent(_newBranchBridgeAgent, _branchChainId);
        emit BridgeAgentSynced(_newBranchBridgeAgent, _rootBridgeAgent, _branchChainId);
    }
    function toggleBridgeAgent(address _bridgeAgent) external override onlyOwner {
        isBridgeAgent[_bridgeAgent] = !isBridgeAgent[_bridgeAgent];
        emit BridgeAgentToggled(_bridgeAgent);
    }
    function addBridgeAgentFactory(address _bridgeAgentFactory) external override onlyOwner {
        if (isBridgeAgentFactory[_bridgeAgentFactory]) revert AlreadyAddedBridgeAgentFactory();
        bridgeAgentFactories.push(_bridgeAgentFactory);
        isBridgeAgentFactory[_bridgeAgentFactory] = true;
        emit BridgeAgentFactoryAdded(_bridgeAgentFactory);
    }
    function toggleBridgeAgentFactory(address _bridgeAgentFactory) external override onlyOwner {
        isBridgeAgentFactory[_bridgeAgentFactory] = !isBridgeAgentFactory[_bridgeAgentFactory];
        emit BridgeAgentFactoryToggled(_bridgeAgentFactory);
    }
    function addNewChain(
        address _coreBranchBridgeAgentAddress,
        uint256 _chainId,
        string memory _wrappedGasTokenName,
        string memory _wrappedGasTokenSymbol,
        uint8 _wrappedGasTokenDecimals,
        address _newLocalBranchWrappedNativeTokenAddress,
        address _newUnderlyingBranchWrappedNativeTokenAddress
    ) external override onlyOwner {
        if (isChainId[_chainId]) revert AlreadyAddedChain();
        address newGlobalToken = address(
            IERC20hTokenRootFactory(ICoreRootRouter(coreRootRouterAddress).hTokenFactoryAddress()).createToken(
                _wrappedGasTokenName, _wrappedGasTokenSymbol, _wrappedGasTokenDecimals
            )
        );
        IBridgeAgent(ICoreRootRouter(coreRootRouterAddress).bridgeAgentAddress()).syncBranchBridgeAgent(
            _coreBranchBridgeAgentAddress, _chainId
        );
        isChainId[_chainId] = true;
        isGlobalAddress[newGlobalToken] = true;
        getGlobalTokenFromLocal[_newLocalBranchWrappedNativeTokenAddress][_chainId] = newGlobalToken;
        getLocalTokenFromGlobal[newGlobalToken][_chainId] = _newLocalBranchWrappedNativeTokenAddress;
        getLocalTokenFromUnderlying[_newUnderlyingBranchWrappedNativeTokenAddress][_chainId] =
            _newLocalBranchWrappedNativeTokenAddress;
        getUnderlyingTokenFromLocal[_newLocalBranchWrappedNativeTokenAddress][_chainId] =
            _newUnderlyingBranchWrappedNativeTokenAddress;
        emit NewChainAdded(_chainId);
    }
    function addEcosystemToken(address _ecoTokenGlobalAddress) external override onlyOwner {
        if (isGlobalAddress[_ecoTokenGlobalAddress]) revert AlreadyAddedEcosystemToken();
        if (getUnderlyingTokenFromLocal[_ecoTokenGlobalAddress][localChainId] != address(0)) {
            revert AlreadyAddedEcosystemToken();
        }
        if (getLocalTokenFromUnderlying[_ecoTokenGlobalAddress][localChainId] != address(0)) {
            revert AlreadyAddedEcosystemToken();
        }
        isGlobalAddress[_ecoTokenGlobalAddress] = true;
        getGlobalTokenFromLocal[_ecoTokenGlobalAddress][localChainId] = _ecoTokenGlobalAddress;
        getLocalTokenFromGlobal[_ecoTokenGlobalAddress][localChainId] = _ecoTokenGlobalAddress;
        emit EcosystemTokenAdded(_ecoTokenGlobalAddress);
    }
    function setCoreRootRouter(address _coreRootRouter, address _coreRootBridgeAgent) external override onlyOwner {
        if (_coreRootRouter == address(0)) revert InvalidCoreRootRouter();
        if (_coreRootBridgeAgent == address(0)) revert InvalidCoreRootBridgeAgent();
        coreRootRouterAddress = _coreRootRouter;
        coreRootBridgeAgentAddress = _coreRootBridgeAgent;
        getBridgeAgentManager[_coreRootBridgeAgent] = owner();
        emit CoreRootSet(_coreRootRouter, _coreRootBridgeAgent);
    }
    function setCoreBranchRouter(
        address _refundee,
        address _coreBranchRouter,
        address _coreBranchBridgeAgent,
        uint16 _dstChainId,
        GasParams calldata _gParams
    ) external payable override onlyOwner {
        if (_coreBranchRouter == address(0)) revert InvalidCoreBranchRouter();
        if (_coreBranchBridgeAgent == address(0)) revert InvalidCoreBrancBridgeAgent();
        ICoreRootRouter(coreRootRouterAddress).setCoreBranch{value: msg.value}(
            _refundee, _coreBranchRouter, _coreBranchBridgeAgent, _dstChainId, _gParams
        );
        emit CoreBranchSet(_coreBranchRouter, _coreBranchBridgeAgent, _dstChainId);
    }
    function syncNewCoreBranchRouter(address _coreBranchRouter, address _coreBranchBridgeAgent, uint16 _dstChainId)
        external
        override
        onlyOwner
    {
        if (_coreBranchRouter == address(0)) revert InvalidCoreBranchRouter();
        if (_coreBranchBridgeAgent == address(0)) revert InvalidCoreBrancBridgeAgent();
        IBridgeAgent(coreRootBridgeAgentAddress).syncBranchBridgeAgent(_coreBranchBridgeAgent, _dstChainId);
        emit CoreBranchSynced(_coreBranchRouter, _coreBranchBridgeAgent, _dstChainId);
    }
    modifier requiresBridgeAgentFactory() {
        if (!isBridgeAgentFactory[msg.sender]) revert UnrecognizedBridgeAgentFactory();
        _;
    }
    modifier requiresBridgeAgent() {
        if (!isBridgeAgent[msg.sender]) revert UnrecognizedBridgeAgent();
        _;
    }
    modifier requiresCoreRootRouter() {
        if (msg.sender != coreRootRouterAddress) revert UnrecognizedCoreRootRouter();
        _;
    }
    modifier requiresLocalBranchPort() {
        if (msg.sender != localBranchPortAddress) revert UnrecognizedLocalBranchPort();
        _;
    }
}