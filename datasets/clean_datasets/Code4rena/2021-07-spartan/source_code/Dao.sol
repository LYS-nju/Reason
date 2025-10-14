pragma solidity 0.8.3;
interface iDAO {
    function ROUTER() external view returns(address);
    function BASE() external view returns(address);
    function UTILS() external view returns(address);
    function DAO() external view returns (address);
    function RESERVE() external view returns(address);
    function BOND() external view returns (address);
    function SYNTHFACTORY() external view returns(address);
    function POOLFACTORY() external view returns(address);
    function depositForMember(address pool, uint256 amount, address member) external;
    function bondingPeriodSeconds() external returns (uint256);
}
pragma solidity 0.8.3;
interface iBASE {
    function DAO() external view returns (iDAO);
    function secondsPerEra() external view returns (uint256);
    function changeDAO(address) external;
    function setParams(uint256, uint256) external;
    function flipEmissions() external;
    function mintFromDAO(uint256, address) external; 
    function burn(uint256) external; 
}
pragma solidity 0.8.3;
interface iBEP20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
    function transfer(address, uint256) external returns (bool);
    function allowance(address, address) external view returns (uint256);
    function approve(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
    function burn(uint) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity 0.8.3;
interface iPOOL {
    function TOKEN() external view returns(address);
    function removeLiquidity() external returns (uint, uint);
    function genesis() external view returns(uint);
    function baseAmount() external view returns(uint);
    function tokenAmount() external view returns(uint);
    function fees() external view returns(uint);
    function volume() external view returns(uint);
    function txCount() external view returns(uint);
    function mintSynth(address, address) external returns (uint256, uint256);
}
pragma solidity 0.8.3;
interface iPOOLFACTORY {
    function isCuratedPool(address) external view returns (bool);
    function addCuratedPool(address) external;
    function removeCuratedPool(address) external;
    function isPool(address) external returns (bool);
    function getPool(address) external view returns(address);
    function createPool(address) external view returns(address);
    function getPoolArray(uint) external view returns(address);
    function poolCount() external view returns(uint);
    function getToken(uint) external view returns(address);
    function tokenCount() external view returns(uint);
    function getCuratedPoolsLength() external view returns (uint);
}
pragma solidity 0.8.3;
interface iROUTER {
    function addLiquidityForMember(uint, uint, address, address) external payable returns (uint);
    function grantFunds(uint, address) external payable returns (bool);
    function changeArrayFeeSize(uint) external;
    function changeMaxTrades(uint) external;
    function addLiquidity(uint, uint, address) external payable returns (uint);
    function totalPooled() external view returns (uint);
    function totalVolume() external view returns (uint);
    function totalFees() external view returns (uint);
    function getPool(address) external view returns(address payable);
}
pragma solidity 0.8.3;
interface iUTILS {
    function calcShare(uint, uint, uint) external pure returns (uint);
    function getFeeOnTransfer(uint256, uint256) external view returns(uint);
    function getPoolShareWeight(address, uint)external view returns(uint);
    function calcAsymmetricValueBase(address, uint) external pure returns (uint);
    function calcAsymmetricValueToken(address, uint) external pure returns (uint);
    function calcLiquidityUnits(uint, uint, uint, uint, uint) external pure returns (uint);
    function calcLiquidityHoldings(uint, address, address) external pure returns (uint);
    function calcSwapOutput(uint, uint, uint) external pure returns (uint);
    function calcSwapFee(uint, uint, uint) external pure returns (uint);
    function calcSwapValueInBase(address, uint) external view returns (uint);
    function calcSpotValueInBaseWithPool(address, uint) external view returns (uint);
    function calcSpotValueInBase(address, uint) external view returns (uint);
    function calcSpotValueIn(address, uint) external view returns (uint);
    function calcPart(uint, uint) external pure returns (uint);
    function calcLiquidityUnitsAsym(uint, address)external pure returns (uint);
    function calcActualSynthUnits(uint amount, address synth) external view returns (uint);
}
pragma solidity 0.8.3;
contract BondVault {
    address public BASE;
    address public DEPLOYER;
    uint256 public totalWeight;
    bool private bondRelease;
    address [] public arrayMembers;
    struct ListedAssets {
        bool isListed;
        address[] members;
        mapping(address => bool) isMember;
        mapping(address => uint256) bondedLP;
        mapping(address => uint256) claimRate;
        mapping(address => uint256) lastBlockTime;
    }
    struct MemberDetails {
        bool isMember;
        uint256 bondedLP;
        uint256 claimRate;
        uint256 lastBlockTime;
    }
    mapping(address => ListedAssets) public mapBondAsset_memberDetails;
    mapping(address => uint256) private mapMember_weight; 
    mapping(address => mapping(address => uint256)) private mapMemberPool_weight; 
    constructor (address _base) {
        BASE = _base;
        DEPLOYER = msg.sender;
        bondRelease = false;
    }
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER);
        _;
    }
    function purgeDeployer() public onlyDAO {
        DEPLOYER = address(0);
    }
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    function depositForMember(address asset, address member, uint LPS) external onlyDAO returns(bool){
        if(!mapBondAsset_memberDetails[asset].isMember[member]){
            mapBondAsset_memberDetails[asset].isMember[member] = true; 
            arrayMembers.push(member); 
            mapBondAsset_memberDetails[asset].members.push(member); 
        }
        if(mapBondAsset_memberDetails[asset].bondedLP[member] != 0){
            claimForMember(asset, member); 
        }
        mapBondAsset_memberDetails[asset].bondedLP[member] += LPS; 
        mapBondAsset_memberDetails[asset].lastBlockTime[member] = block.timestamp; 
        mapBondAsset_memberDetails[asset].claimRate[member] = mapBondAsset_memberDetails[asset].bondedLP[member] / iDAO(_DAO().DAO()).bondingPeriodSeconds(); 
        increaseWeight(asset, member); 
        return true;
    }
    function increaseWeight(address asset, address member) internal{
        address pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(asset); 
        if (mapMemberPool_weight[member][pool] > 0) {
            totalWeight -= mapMemberPool_weight[member][pool]; 
            mapMember_weight[member] -= mapMemberPool_weight[member][pool]; 
            mapMemberPool_weight[member][pool] = 0; 
        }
        uint256 weight = iUTILS(_DAO().UTILS()).getPoolShareWeight(asset, mapBondAsset_memberDetails[asset].bondedLP[member]); 
        mapMemberPool_weight[member][pool] = weight; 
        mapMember_weight[member] += weight; 
        totalWeight += weight; 
    }
    function calcBondedLP(address member, address asset) public view returns (uint claimAmount){ 
        if(mapBondAsset_memberDetails[asset].isMember[member]){
            uint256 _secondsSinceClaim = block.timestamp - mapBondAsset_memberDetails[asset].lastBlockTime[member]; 
            uint256 rate = mapBondAsset_memberDetails[asset].claimRate[member]; 
            claimAmount = _secondsSinceClaim * rate; 
            if(claimAmount >= mapBondAsset_memberDetails[asset].bondedLP[member] || bondRelease){
                claimAmount = mapBondAsset_memberDetails[asset].bondedLP[member]; 
            }
            return claimAmount;
        }
    }
    function claimForMember(address asset, address member) public onlyDAO returns (bool){
        require(mapBondAsset_memberDetails[asset].bondedLP[member] > 0, '!bonded'); 
        require(mapBondAsset_memberDetails[asset].isMember[member], '!member'); 
        uint256 _claimable = calcBondedLP(member, asset); 
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(asset); 
        mapBondAsset_memberDetails[asset].lastBlockTime[member] = block.timestamp; 
        mapBondAsset_memberDetails[asset].bondedLP[member] -= _claimable; 
        if(_claimable == mapBondAsset_memberDetails[asset].bondedLP[member]){
            mapBondAsset_memberDetails[asset].claimRate[member] = 0; 
        }
        decreaseWeight(asset, member); 
        iBEP20(_pool).transfer(member, _claimable); 
        return true;
    }
    function decreaseWeight(address asset, address member) internal {
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(asset); 
        totalWeight -= mapMemberPool_weight[member][_pool]; 
        mapMember_weight[member] -= mapMemberPool_weight[member][_pool]; 
        mapMemberPool_weight[member][_pool] = 0; 
        uint256 weight = iUTILS(_DAO().UTILS()).getPoolShareWeight(asset, mapBondAsset_memberDetails[asset].bondedLP[member]); 
        mapMemberPool_weight[member][_pool] = weight; 
        mapMember_weight[member] += weight; 
        totalWeight += weight; 
    }
    function memberCount() external view returns (uint256 count){
        return arrayMembers.length;
    }
    function allMembers() external view returns (address[] memory _allMembers){
        return arrayMembers;
    }
    function release() external onlyDAO {
        bondRelease = true;
    }
    function getMemberDetails(address member, address asset) external view returns (MemberDetails memory memberDetails){
        memberDetails.isMember = mapBondAsset_memberDetails[asset].isMember[member];
        memberDetails.bondedLP = mapBondAsset_memberDetails[asset].bondedLP[member];
        memberDetails.claimRate = mapBondAsset_memberDetails[asset].claimRate[member];
        memberDetails.lastBlockTime = mapBondAsset_memberDetails[asset].lastBlockTime[member];
        return memberDetails;
    }
    function getMemberWeight(address member) external view returns (uint256) {
        if (mapMember_weight[member] > 0) {
            return mapMember_weight[member];
        } else {
            return 0;
        }
    } 
}
pragma solidity 0.8.3;
interface iBONDVAULT{
 function depositForMember(address asset, address member, uint liquidityUnits) external;
 function claimForMember(address listedAsset, address member) external;
 function calcBondedLP(address bondedMember, address asset) external returns(uint);
 function getMemberWeight(address) external view returns (uint256);
 function totalWeight() external view returns (uint);
}
pragma solidity 0.8.3;
interface iDAOVAULT{
function getMemberWeight(address) external view returns (uint256);
function depositLP(address, uint, address) external;
function withdraw(address, address) external returns (bool);
function totalWeight() external view returns (uint);
}
pragma solidity 0.8.3;
interface iRESERVE {
    function grantFunds(uint, address) external; 
    function emissions() external returns(bool); 
}
pragma solidity 0.8.3;
interface iSYNTHFACTORY {
    function isSynth(address) external view returns (bool);
    function getSynth(address) external view returns (address);
}
pragma solidity 0.8.3;
interface iSYNTHVAULT{
}
pragma solidity 0.8.3;
contract Dao {
    address public DEPLOYER;
    address public BASE;
    uint256 public secondsPerEra;   
    uint256 public coolOffPeriod;   
    uint256 public proposalCount;   
    uint256 public majorityFactor;  
    uint256 public erasToEarn;      
    uint256 public daoClaim;        
    uint256 public daoFee;          
    uint256 public currentProposal; 
    struct MemberDetails {
        bool isMember;
        uint weight;
        uint lastBlock;
        uint poolCount;
    }
    struct ProposalDetails {
        uint id;
        string proposalType;
        uint votes;
        uint coolOffTime;
        bool finalising;
        bool finalised;
        uint param;
        address proposedAddress;
        bool open;
        uint startTime;
    }
    bool public daoHasMoved;
    address public DAO;
    iROUTER private _ROUTER;
    iUTILS private _UTILS;
    iBONDVAULT private _BONDVAULT;
    iDAOVAULT private _DAOVAULT;
    iPOOLFACTORY private _POOLFACTORY;
    iSYNTHFACTORY private _SYNTHFACTORY;
    iRESERVE private _RESERVE;
    iSYNTHVAULT private _SYNTHVAULT;
    address[] public arrayMembers;
    address [] listedBondAssets; 
    uint256 public bondingPeriodSeconds = 15552000; 
    mapping(address => bool) public isMember;
    mapping(address => bool) public isListed; 
    mapping(address => uint256) public mapMember_lastTime;
    mapping(uint256 => uint256) public mapPID_param;
    mapping(uint256 => address) public mapPID_address;
    mapping(uint256 => string) public mapPID_type;
    mapping(uint256 => uint256) public mapPID_votes;
    mapping(uint256 => uint256) public mapPID_coolOffTime;
    mapping(uint256 => bool) public mapPID_finalising;
    mapping(uint256 => bool) public mapPID_finalised;
    mapping(uint256 => bool) public mapPID_open;
    mapping(uint256 => uint256) public mapPID_startTime;
    mapping(uint256 => mapping(address => uint256)) public mapPIDMember_votes;
    event MemberDeposits(address indexed member, address indexed pool, uint256 amount);
    event MemberWithdraws(address indexed member, address indexed pool, uint256 balance);
    event NewProposal(address indexed member, uint indexed proposalID, string proposalType);
    event NewVote(address indexed member, uint indexed proposalID, uint voteWeight, uint totalVotes, string proposalType);
    event RemovedVote(address indexed member, uint indexed proposalID, uint voteWeight, uint totalVotes, string proposalType);
    event ProposalFinalising(address indexed member, uint indexed proposalID, uint timeFinalised, string proposalType);
    event CancelProposal(address indexed member, uint indexed proposalID);
    event FinalisedProposal(address indexed member, uint indexed proposalID, uint votesCast, uint totalWeight, string proposalType);
    event ListedAsset(address indexed DAO, address indexed asset);
    event DelistedAsset(address indexed DAO, address indexed asset);
    event DepositAsset(address indexed owner, uint256 depositAmount, uint256 bondedLP);
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER);
        _;
    }
    constructor (address _base){
        BASE = _base;
        DEPLOYER = msg.sender;
        DAO = address(this);
        coolOffPeriod = 259200;
        erasToEarn = 30;
        majorityFactor = 6666;
        daoClaim = 1000;
        daoFee = 100;
        proposalCount = 0;
        secondsPerEra = iBASE(BASE).secondsPerEra();
    }
    function setGenesisAddresses(address _router, address _utils, address _reserve) external onlyDAO {
        _ROUTER = iROUTER(_router);
        _UTILS = iUTILS(_utils);
        _RESERVE = iRESERVE(_reserve);
    }
    function setVaultAddresses(address _daovault, address _bondvault, address _synthVault) external onlyDAO {
        _DAOVAULT = iDAOVAULT(_daovault);
        _BONDVAULT = iBONDVAULT(_bondvault);
        _SYNTHVAULT = iSYNTHVAULT(_synthVault); 
    }
    function setFactoryAddresses(address _poolFactory, address _synthFactory) external onlyDAO {
        _POOLFACTORY = iPOOLFACTORY(_poolFactory);
        _SYNTHFACTORY = iSYNTHFACTORY(_synthFactory);
    }
    function setGenesisFactors(uint32 _coolOff, uint32 _daysToEarn, uint32 _majorityFactor, uint32 _daoClaim, uint32 _daoFee) external onlyDAO {
        coolOffPeriod = _coolOff;
        erasToEarn = _daysToEarn;
        majorityFactor = _majorityFactor;
        daoClaim = _daoClaim;
        daoFee = _daoFee;
    }
    function purgeDeployer() external onlyDAO {
        DEPLOYER = address(0);
    }
    function changeBondingPeriod(uint256 bondingSeconds) external onlyDAO{
        bondingPeriodSeconds = bondingSeconds;
    }
    function deposit(address pool, uint256 amount) external {
        depositLPForMember(pool, amount, msg.sender);
    }
    function depositLPForMember(address pool, uint256 amount, address member) public {
        require(_POOLFACTORY.isCuratedPool(pool) == true, "!curated"); 
        require(amount > 0, "!amount"); 
        if (isMember[member] != true) {
            arrayMembers.push(member); 
            isMember[member] = true; 
        }
        if((_DAOVAULT.getMemberWeight(member) + _BONDVAULT.getMemberWeight(member)) > 0) {
            harvest(); 
        }
        require(iBEP20(pool).transferFrom(msg.sender, address(_DAOVAULT), amount), "!funds"); 
        _DAOVAULT.depositLP(pool, amount, member); 
        mapMember_lastTime[member] = block.timestamp; 
        emit MemberDeposits(member, pool, amount);
    }
    function withdraw(address pool) external {
        removeVote(); 
        require(_DAOVAULT.withdraw(pool, msg.sender), "!transfer"); 
    }
    function harvest() public {
        require(_RESERVE.emissions(), "!emissions"); 
        uint reward = calcCurrentReward(msg.sender); 
        mapMember_lastTime[msg.sender] = block.timestamp; 
        uint reserve = iBEP20(BASE).balanceOf(address(_RESERVE)); 
        uint daoReward = (reserve * daoClaim) / 10000; 
        if(reward > daoReward){
            reward = daoReward; 
        }
        _RESERVE.grantFunds(reward, msg.sender); 
    }
    function calcCurrentReward(address member) public view returns(uint){
        uint secondsSinceClaim = block.timestamp - mapMember_lastTime[member]; 
        uint share = calcReward(member); 
        uint reward = (share * secondsSinceClaim) / secondsPerEra; 
        return reward;
    }
    function calcReward(address member) public view returns(uint){
        uint weight = _DAOVAULT.getMemberWeight(member) + _BONDVAULT.getMemberWeight(member); 
        uint _totalWeight = _DAOVAULT.totalWeight() + _BONDVAULT.totalWeight(); 
        uint reserve = iBEP20(BASE).balanceOf(address(_RESERVE)) / erasToEarn; 
        uint daoReward = (reserve * daoClaim) / 10000; 
        return _UTILS.calcShare(weight, _totalWeight, daoReward); 
    }
    function burnBalance() external onlyDAO returns (bool){
        uint256 baseBal = iBEP20(BASE).balanceOf(address(this));
        iBASE(BASE).burn(baseBal);   
        return true;
    }
    function moveBASEBalance(address newDAO) external onlyDAO {
        uint256 baseBal = iBEP20(BASE).balanceOf(address(this));
        iBEP20(BASE).transfer(newDAO, baseBal);
    }
    function listBondAsset(address asset) external onlyDAO {
        if(!isListed[asset]){
            isListed[asset] = true; 
            listedBondAssets.push(asset); 
        }
        emit ListedAsset(msg.sender, asset);
    }
    function delistBondAsset(address asset) external onlyDAO {
        isListed[asset] = false; 
        emit DelistedAsset(msg.sender, asset);
    }
    function bond(address asset, uint256 amount) external payable returns (bool success) {
        require(amount > 0, '!amount'); 
        require(isListed[asset], '!listed'); 
        if (isMember[msg.sender] != true) {
            arrayMembers.push(msg.sender); 
            isMember[msg.sender] = true; 
        }
        if((_DAOVAULT.getMemberWeight(msg.sender) + _BONDVAULT.getMemberWeight(msg.sender)) > 0) {
            harvest(); 
        }
        uint256 liquidityUnits = handleTransferIn(asset, amount); 
        _BONDVAULT.depositForMember(asset, msg.sender, liquidityUnits); 
        mapMember_lastTime[msg.sender] = block.timestamp; 
        emit DepositAsset(msg.sender, amount, liquidityUnits);
        return true;
    }
    function handleTransferIn(address _token, uint _amount) internal returns (uint LPunits){
        uint256 spartaAllocation = _UTILS.calcSwapValueInBase(_token, _amount); 
        if(iBEP20(BASE).allowance(address(this), address(_ROUTER)) < spartaAllocation){
            iBEP20(BASE).approve(address(_ROUTER), iBEP20(BASE).totalSupply()); 
        }
        if(_token == address(0)){
            require((_amount == msg.value), "!amount");
            LPunits = _ROUTER.addLiquidityForMember{value:_amount}(spartaAllocation, _amount, _token, address(_BONDVAULT)); 
        } else {
            iBEP20(_token).transferFrom(msg.sender, address(this), _amount); 
            if(iBEP20(_token).allowance(address(this), address(_ROUTER)) < _amount){
                uint256 approvalTNK = iBEP20(_token).totalSupply();
                iBEP20(_token).approve(address(_ROUTER), approvalTNK); 
            }
            LPunits = _ROUTER.addLiquidityForMember(spartaAllocation, _amount, _token, address(_BONDVAULT)); 
        } 
    }
    function claimAllForMember(address member) external returns (bool){
        address [] memory listedAssets = listedBondAssets; 
        for(uint i = 0; i < listedAssets.length; i++){
            uint claimA = calcClaimBondedLP(member, listedAssets[i]); 
            if(claimA > 0){
               _BONDVAULT.claimForMember(listedAssets[i], member); 
            }
        }
        return true;
    }
    function claimForMember(address asset) external returns (bool){
        uint claimA = calcClaimBondedLP(msg.sender, asset); 
        if(claimA > 0){
            _BONDVAULT.claimForMember(asset, msg.sender); 
        }
        return true;
    }
    function calcClaimBondedLP(address bondedMember, address asset) public returns (uint){
        uint claimAmount = _BONDVAULT.calcBondedLP(bondedMember, asset); 
        return claimAmount;
    }
    function newActionProposal(string memory typeStr) external returns(uint) {
        checkProposal(); 
        payFee(); 
        mapPID_type[currentProposal] = typeStr; 
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }
    function newParamProposal(uint32 param, string memory typeStr) external returns(uint) {
        checkProposal(); 
        payFee(); 
        mapPID_param[currentProposal] = param; 
        mapPID_type[currentProposal] = typeStr; 
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }
    function newAddressProposal(address proposedAddress, string memory typeStr) external returns(uint) {
        checkProposal(); 
        payFee(); 
        mapPID_address[currentProposal] = proposedAddress; 
        mapPID_type[currentProposal] = typeStr; 
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }
    function newGrantProposal(address recipient, uint amount) external returns(uint) {
        checkProposal(); 
        payFee(); 
        string memory typeStr = "GRANT";
        mapPID_type[currentProposal] = typeStr; 
        mapPID_address[currentProposal] = recipient; 
        mapPID_param[currentProposal] = amount; 
        emit NewProposal(msg.sender, currentProposal, typeStr);
        return currentProposal;
    }
    function checkProposal() internal {
        require(mapPID_open[currentProposal] == false, '!open'); 
        proposalCount += 1; 
        currentProposal = proposalCount; 
        mapPID_open[currentProposal] = true; 
        mapPID_startTime[currentProposal] = block.timestamp; 
    }
    function payFee() internal returns(bool){
        uint _amount = daoFee*(10**18); 
        require(iBEP20(BASE).transferFrom(msg.sender, address(_RESERVE), _amount), '!fee'); 
        return true;
    } 
    function voteProposal() external returns (uint voteWeight) {
        require(mapPID_open[currentProposal] == true, "!open"); 
        bytes memory _type = bytes(mapPID_type[currentProposal]); 
        voteWeight = countVotes(); 
        if(hasQuorum(currentProposal) && mapPID_finalising[currentProposal] == false){
            if(isEqual(_type, 'DAO') || isEqual(_type, 'UTILS') || isEqual(_type, 'RESERVE') ||isEqual(_type, 'GET_SPARTA') || isEqual(_type, 'ROUTER') || isEqual(_type, 'LIST_BOND')|| isEqual(_type, 'GRANT')|| isEqual(_type, 'ADD_CURATED_POOL')){
                if(hasMajority(currentProposal)){
                    _finalise(); 
                }
            } else {
                _finalise(); 
            }
        }
        emit NewVote(msg.sender, currentProposal, voteWeight, mapPID_votes[currentProposal], string(_type));
    }
    function removeVote() public returns (uint voteWeightRemoved){
        bytes memory _type = bytes(mapPID_type[currentProposal]); 
        voteWeightRemoved = mapPIDMember_votes[currentProposal][msg.sender]; 
        if(mapPID_open[currentProposal]){
            mapPID_votes[currentProposal] -= voteWeightRemoved; 
        }
        mapPIDMember_votes[currentProposal][msg.sender] = 0; 
        emit RemovedVote(msg.sender, currentProposal, voteWeightRemoved, mapPID_votes[currentProposal], string(_type));
        return voteWeightRemoved;
    }
    function _finalise() internal {
        bytes memory _type = bytes(mapPID_type[currentProposal]); 
        mapPID_finalising[currentProposal] = true; 
        mapPID_coolOffTime[currentProposal] = block.timestamp; 
        emit ProposalFinalising(msg.sender, currentProposal, block.timestamp+coolOffPeriod, string(_type));
    }
    function cancelProposal() external {
        require(block.timestamp > (mapPID_startTime[currentProposal] + 1296000), "!days"); 
        mapPID_votes[currentProposal] = 0; 
        mapPID_open[currentProposal] = false; 
        emit CancelProposal(msg.sender, currentProposal);
    }
    function finaliseProposal() external {
        require((block.timestamp - mapPID_coolOffTime[currentProposal]) > coolOffPeriod, "!cooloff"); 
        require(mapPID_finalising[currentProposal] == true, "!finalising"); 
        if(!hasQuorum(currentProposal)){
            mapPID_finalising[currentProposal] = false; 
        } else {
            bytes memory _type = bytes(mapPID_type[currentProposal]); 
            if(isEqual(_type, 'DAO')){
                moveDao(currentProposal);
            } else if (isEqual(_type, 'ROUTER')) {
                moveRouter(currentProposal);
            } else if (isEqual(_type, 'UTILS')){
                moveUtils(currentProposal);
            } else if (isEqual(_type, 'RESERVE')){
                moveReserve(currentProposal);
            } else if (isEqual(_type, 'FLIP_EMISSIONS')){
                flipEmissions(currentProposal);
            } else if (isEqual(_type, 'COOL_OFF')){
                changeCooloff(currentProposal);
            } else if (isEqual(_type, 'ERAS_TO_EARN')){
                changeEras(currentProposal);
            } else if (isEqual(_type, 'GRANT')){
                grantFunds(currentProposal);
            } else if (isEqual(_type, 'GET_SPARTA')){
                _increaseSpartaAllocation(currentProposal);
            } else if (isEqual(_type, 'LIST_BOND')){
                _listBondingAsset(currentProposal);
            } else if (isEqual(_type, 'DELIST_BOND')){
                _delistBondingAsset(currentProposal);
            } else if (isEqual(_type, 'ADD_CURATED_POOL')){
                _addCuratedPool(currentProposal);
            } else if (isEqual(_type, 'REMOVE_CURATED_POOL')){
                _removeCuratedPool(currentProposal);
            } 
        }
    }
    function moveDao(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        require(_proposedAddress != address(0), "!address"); 
        DAO = _proposedAddress; 
        iBASE(BASE).changeDAO(_proposedAddress); 
        daoHasMoved = true; 
        completeProposal(_proposalID); 
    }
    function moveRouter(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        require(_proposedAddress != address(0), "!address"); 
        _ROUTER = iROUTER(_proposedAddress); 
        completeProposal(_proposalID); 
    }
    function moveUtils(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        require(_proposedAddress != address(0), "!address"); 
        _UTILS = iUTILS(_proposedAddress); 
        completeProposal(_proposalID); 
    }
    function moveReserve(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        require(_proposedAddress != address(0), "!address"); 
        _RESERVE = iRESERVE(_proposedAddress); 
        completeProposal(_proposalID); 
    }
    function flipEmissions(uint _proposalID) internal {
        iBASE(BASE).flipEmissions(); 
        completeProposal(_proposalID); 
    }
    function changeCooloff(uint _proposalID) internal {
        uint256 _proposedParam = mapPID_param[_proposalID]; 
        require(_proposedParam != 0, "!param"); 
        coolOffPeriod = _proposedParam; 
        completeProposal(_proposalID); 
    }
    function changeEras(uint _proposalID) internal {
        uint256 _proposedParam = mapPID_param[_proposalID]; 
        require(_proposedParam != 0, "!param"); 
        erasToEarn = _proposedParam; 
        completeProposal(_proposalID); 
    }
    function grantFunds(uint _proposalID) internal {
        uint256 _proposedAmount = mapPID_param[_proposalID]; 
        address _proposedAddress = mapPID_address[_proposalID]; 
        require(_proposedAmount != 0, "!param"); 
        require(_proposedAddress != address(0), "!address"); 
        _RESERVE.grantFunds(_proposedAmount, _proposedAddress); 
        completeProposal(_proposalID); 
    }
    function _increaseSpartaAllocation(uint _proposalID) internal {
        uint256 _2point5m = 2.5*10**6*10**18; 
        iBASE(BASE).mintFromDAO(_2point5m, address(this)); 
        completeProposal(_proposalID); 
    }
    function _listBondingAsset(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        if(!isListed[_proposedAddress]){
            isListed[_proposedAddress] = true; 
            listedBondAssets.push(_proposedAddress); 
        }
        completeProposal(_proposalID); 
    }
    function _delistBondingAsset(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        isListed[_proposedAddress] = false; 
        completeProposal(_proposalID); 
    }
    function _addCuratedPool(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        _POOLFACTORY.addCuratedPool(_proposedAddress); 
        completeProposal(_proposalID); 
    }
    function _removeCuratedPool(uint _proposalID) internal {
        address _proposedAddress = mapPID_address[_proposalID]; 
        _POOLFACTORY.removeCuratedPool(_proposedAddress); 
        completeProposal(_proposalID); 
    }
    function completeProposal(uint _proposalID) internal {
        string memory _typeStr = mapPID_type[_proposalID]; 
        emit FinalisedProposal(msg.sender, _proposalID, mapPID_votes[_proposalID], _DAOVAULT.totalWeight(), _typeStr);
        mapPID_votes[_proposalID] = 0; 
        mapPID_finalised[_proposalID] = true; 
        mapPID_finalising[_proposalID] = false; 
        mapPID_open[_proposalID] = false; 
    }
    function countVotes() internal returns (uint voteWeight){
        mapPID_votes[currentProposal] -= mapPIDMember_votes[currentProposal][msg.sender]; 
        voteWeight = _DAOVAULT.getMemberWeight(msg.sender) + _BONDVAULT.getMemberWeight(msg.sender); 
        mapPID_votes[currentProposal] += voteWeight; 
        mapPIDMember_votes[currentProposal][msg.sender] = voteWeight; 
        return voteWeight;
    }
    function hasMajority(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID]; 
        uint _totalWeight = _DAOVAULT.totalWeight() + _BONDVAULT.totalWeight(); 
        uint consensus = _totalWeight * majorityFactor / 10000; 
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }
    function hasQuorum(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID]; 
        uint _totalWeight = _DAOVAULT.totalWeight()  + _BONDVAULT.totalWeight(); 
        uint consensus = _totalWeight / 2; 
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }
    function hasMinority(uint _proposalID) public view returns(bool){
        uint votes = mapPID_votes[_proposalID]; 
        uint _totalWeight = _DAOVAULT.totalWeight()  + _BONDVAULT.totalWeight(); 
        uint consensus = _totalWeight / 6; 
        if(votes > consensus){
            return true;
        } else {
            return false;
        }
    }
    function ROUTER() public view returns(iROUTER){
        if(daoHasMoved){
            return Dao(DAO).ROUTER();
        } else {
            return _ROUTER;
        }
    }
    function UTILS() public view returns(iUTILS){
        if(daoHasMoved){
            return Dao(DAO).UTILS();
        } else {
            return _UTILS;
        }
    }
    function BONDVAULT() public view returns(iBONDVAULT){
        if(daoHasMoved){
            return Dao(DAO).BONDVAULT();
        } else {
            return _BONDVAULT;
        }
    }
    function DAOVAULT() public view returns(iDAOVAULT){
        if(daoHasMoved){
            return Dao(DAO).DAOVAULT();
        } else {
            return _DAOVAULT;
        }
    }
    function POOLFACTORY() public view returns(iPOOLFACTORY){
        if(daoHasMoved){
            return Dao(DAO).POOLFACTORY();
        } else {
            return _POOLFACTORY;
        }
    }
    function SYNTHFACTORY() public view returns(iSYNTHFACTORY){
        if(daoHasMoved){
            return Dao(DAO).SYNTHFACTORY();
        } else {
            return _SYNTHFACTORY;
        }
    }
    function RESERVE() public view returns(iRESERVE){
        if(daoHasMoved){
            return Dao(DAO).RESERVE();
        } else {
            return _RESERVE;
        }
    }
    function SYNTHVAULT() public view returns(iSYNTHVAULT){
        if(daoHasMoved){
            return Dao(DAO).SYNTHVAULT();
        } else {
            return _SYNTHVAULT;
        }
    }
    function memberCount() external view returns(uint){
        return arrayMembers.length;
    }
    function getProposalDetails(uint proposalID) external view returns (ProposalDetails memory proposalDetails){
        proposalDetails.id = proposalID;
        proposalDetails.proposalType = mapPID_type[proposalID];
        proposalDetails.votes = mapPID_votes[proposalID];
        proposalDetails.coolOffTime = mapPID_coolOffTime[proposalID];
        proposalDetails.finalising = mapPID_finalising[proposalID];
        proposalDetails.finalised = mapPID_finalised[proposalID];
        proposalDetails.param = mapPID_param[proposalID];
        proposalDetails.proposedAddress = mapPID_address[proposalID];
        proposalDetails.open = mapPID_open[proposalID];
        proposalDetails.startTime = mapPID_startTime[proposalID];
        return proposalDetails;
    }
    function assetListedCount() external view returns (uint256 count){
        return listedBondAssets.length;
    }
    function allListedAssets() external view returns (address[] memory _allListedAssets){
        return listedBondAssets;
    }
    function isEqual(bytes memory part1, bytes memory part2) private pure returns(bool){
        if(sha256(part1) == sha256(part2)){
            return true;
        } else {
            return false;
        }
    }
}
pragma solidity 0.8.3;
contract DaoVault {
    address public BASE;
    address public DEPLOYER;
    uint256 public totalWeight; 
    constructor(address _base) {
        BASE = _base;
        DEPLOYER = msg.sender;
    }
    mapping(address => uint256) private mapMember_weight; 
    mapping(address => mapping(address => uint256)) private mapMemberPool_balance; 
    mapping(address => mapping(address => uint256)) public mapMember_depositTime; 
    mapping(address => mapping(address => uint256)) private mapMemberPool_weight; 
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER, "!DAO");
        _;
    }
    function _DAO() internal view returns (iDAO) {
        return iBASE(BASE).DAO();
    }
    function depositLP(address pool, uint256 amount, address member) external onlyDAO returns (bool) {
        mapMemberPool_balance[member][pool] += amount; 
        increaseWeight(pool, member); 
        return true;
    }
    function increaseWeight(address pool, address member) internal returns (uint256){
        if (mapMemberPool_weight[member][pool] > 0) {
            totalWeight -= mapMemberPool_weight[member][pool]; 
            mapMember_weight[member] -= mapMemberPool_weight[member][pool]; 
            mapMemberPool_weight[member][pool] = 0; 
        }
        uint256 weight = iUTILS(_DAO().UTILS()).getPoolShareWeight(iPOOL(pool).TOKEN(), mapMemberPool_balance[member][pool]); 
        mapMemberPool_weight[member][pool] = weight; 
        mapMember_weight[member] += weight; 
        totalWeight += weight; 
        mapMember_depositTime[member][pool] = block.timestamp; 
        return weight;
    }
    function decreaseWeight(address pool, address member) internal {
        uint256 weight = mapMemberPool_weight[member][pool]; 
        mapMemberPool_balance[member][pool] = 0; 
        mapMemberPool_weight[member][pool] = 0; 
        totalWeight -= weight; 
        mapMember_weight[member] -= weight; 
    }
    function withdraw(address pool, address member) external onlyDAO returns (bool){
        require(block.timestamp > (mapMember_depositTime[member][pool] + 86400), '!unlocked'); 
        uint256 _balance = mapMemberPool_balance[member][pool]; 
        require(_balance > 0, "!balance"); 
        decreaseWeight(pool, member); 
        require(iBEP20(pool).transfer(member, _balance), "!transfer"); 
        return true;
    }
    function getMemberWeight(address member) external view returns (uint256) {
        if (mapMember_weight[member] > 0) {
            return mapMember_weight[member];
        } else {
            return 0;
        }
    }
    function getMemberPoolBalance(address pool, address member)  external view returns (uint256){
        return mapMemberPool_balance[member][pool];
    }
    function getMemberPoolWeight(address pool, address member) external view returns (uint256){
        return mapMemberPool_weight[member][pool];
    }
}
pragma solidity 0.8.3;
interface iBEP677 {
 function onTokenApproval(address token, uint amount, address member,bytes calldata data) external;
 function onTokenTransfer(address token, uint amount, address member,bytes calldata data) external;
}
pragma solidity 0.8.3;
interface iSYNTH {
    function genesis() external view returns(uint);
    function totalMinted() external view returns(uint);
    function LayerONE()external view returns(address);
    function mintSynth(address, uint) external returns (uint256);
    function burnSynth() external returns(uint);
    function realise(address pool) external;
}
pragma solidity 0.8.3;
contract Pool is iBEP20 {  
    address public BASE;
    address public TOKEN;
    address public DEPLOYER;
    string _name; string _symbol;
    uint8 public override decimals; uint256 public override totalSupply;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    uint256 public baseAmount; 
    uint256 public tokenAmount; 
    uint private lastMonth; 
    uint public genesis; 
    uint256 public map30DPoolRevenue; 
    uint256 public mapPast30DPoolRevenue; 
    uint256 [] public revenueArray; 
    event AddLiquidity(address indexed member, uint inputBase, uint inputToken, uint unitsIssued);
    event RemoveLiquidity(address indexed member, uint outputBase, uint outputToken, uint unitsClaimed);
    event Swapped(address indexed tokenFrom, address indexed tokenTo, address indexed recipient, uint inputAmount, uint outputAmount, uint fee);
    event MintSynth(address indexed member, address indexed base, uint256 baseAmount, address indexed token, uint256 synthAmount);
    event BurnSynth(address indexed member, address indexed base, uint256 baseAmount, address indexed token, uint256 synthAmount);
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    constructor (address _base, address _token) {
        BASE = _base;
        TOKEN = _token;
        string memory poolName = "-SpartanProtocolPool";
        string memory poolSymbol = "-SPP";
        _name = string(abi.encodePacked(iBEP20(_token).name(), poolName));
        _symbol = string(abi.encodePacked(iBEP20(_token).symbol(), poolSymbol));
        decimals = 18;
        genesis = block.timestamp;
        DEPLOYER = msg.sender;
        lastMonth = 0;
    }
    function name() external view override returns (string memory) {
        return _name;
    }
    function symbol() external view override returns (string memory) {
        return _symbol;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "!approval");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "!owner");
        require(spender != address(0), "!spender");
        if (_allowances[owner][spender] < type(uint256).max) { 
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
    }
    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] < type(uint256).max) {
            uint256 currentAllowance = _allowances[sender][msg.sender];
            require(currentAllowance >= amount, "!approval");
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }
    function approveAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
      _approve(msg.sender, recipient, type(uint256).max); 
      iBEP677(recipient).onTokenApproval(address(this), amount, msg.sender, data); 
      return true;
    }
    function transferAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
      _transfer(msg.sender, recipient, amount);
      iBEP677(recipient).onTokenTransfer(address(this), amount, msg.sender, data); 
      return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "!sender");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "!balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function burn(uint256 amount) external virtual override {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint256 amount) external virtual {  
        uint256 decreasedAllowance = allowance(account, msg.sender) - (amount);
        _approve(account, msg.sender, decreasedAllowance); 
        _burn(account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        require(_balances[account] >= amount, "!balance");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function add() external returns(uint liquidityUnits){
        liquidityUnits = addForMember(msg.sender);
        return liquidityUnits;
    }
    function addForMember(address member) public returns(uint liquidityUnits){
        uint256 _actualInputBase = _getAddedBaseAmount(); 
        uint256 _actualInputToken = _getAddedTokenAmount(); 
        if(baseAmount == 0 || tokenAmount == 0){
        require(_actualInputBase != 0 && _actualInputToken != 0, "!Balanced");
        }
        liquidityUnits = iUTILS(_DAO().UTILS()).calcLiquidityUnits(_actualInputBase, baseAmount, _actualInputToken, tokenAmount, totalSupply); 
        _incrementPoolBalances(_actualInputBase, _actualInputToken); 
        _mint(member, liquidityUnits); 
        emit AddLiquidity(member, _actualInputBase, _actualInputToken, liquidityUnits);
        return liquidityUnits;
    }
    function remove() external returns (uint outputBase, uint outputToken) {
        return removeForMember(msg.sender);
    } 
    function removeForMember(address member) public returns (uint outputBase, uint outputToken) {
        uint256 _actualInputUnits = balanceOf(address(this)); 
        outputBase = iUTILS(_DAO().UTILS()).calcLiquidityHoldings(_actualInputUnits, BASE, address(this)); 
        outputToken = iUTILS(_DAO().UTILS()).calcLiquidityHoldings(_actualInputUnits, TOKEN, address(this)); 
        _decrementPoolBalances(outputBase, outputToken); 
        _burn(address(this), _actualInputUnits); 
        iBEP20(BASE).transfer(member, outputBase); 
        iBEP20(TOKEN).transfer(member, outputToken); 
        emit RemoveLiquidity(member, outputBase, outputToken, _actualInputUnits);
        return (outputBase, outputToken);
    }
    function swap(address token) external returns (uint outputAmount, uint fee){
        (outputAmount, fee) = swapTo(token, msg.sender);
        return (outputAmount, fee);
    }
    function swapTo(address token, address member) public payable returns (uint outputAmount, uint fee) {
        require((token == BASE || token == TOKEN), "!BASE||TOKEN"); 
        address _fromToken; uint _amount;
        if(token == BASE){
            _fromToken = TOKEN; 
            _amount = _getAddedTokenAmount(); 
            (outputAmount, fee) = _swapTokenToBase(_amount); 
        } else {
            _fromToken = BASE; 
            _amount = _getAddedBaseAmount(); 
            (outputAmount, fee) = _swapBaseToToken(_amount); 
        }
        emit Swapped(_fromToken, token, member, _amount, outputAmount, fee);
        iBEP20(token).transfer(member, outputAmount); 
        return (outputAmount, fee);
    }
    function mintSynth(address synthOut, address member) external returns(uint outputAmount, uint fee) {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synthOut) == true, "!synth"); 
        uint256 _actualInputBase = _getAddedBaseAmount(); 
        uint output = iUTILS(_DAO().UTILS()).calcSwapOutput(_actualInputBase, baseAmount, tokenAmount); 
        uint _liquidityUnits = iUTILS(_DAO().UTILS()).calcLiquidityUnitsAsym(_actualInputBase, address(this)); 
        _incrementPoolBalances(_actualInputBase, 0); 
        uint _fee = iUTILS(_DAO().UTILS()).calcSwapFee(_actualInputBase, baseAmount, tokenAmount); 
        fee = iUTILS(_DAO().UTILS()).calcSpotValueInBase(TOKEN, _fee); 
        _mint(synthOut, _liquidityUnits); 
        iSYNTH(synthOut).mintSynth(member, output); 
        _addPoolMetrics(fee); 
        emit MintSynth(member, BASE, _actualInputBase, TOKEN, outputAmount);
      return (output, fee);
    }
    function burnSynth(address synthIN, address member) external returns(uint outputAmount, uint fee) {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synthIN) == true, "!synth"); 
        uint _actualInputSynth = iBEP20(synthIN).balanceOf(address(this)); 
        uint outputBase = iUTILS(_DAO().UTILS()).calcSwapOutput(_actualInputSynth, tokenAmount, baseAmount); 
        fee = iUTILS(_DAO().UTILS()).calcSwapFee(_actualInputSynth, tokenAmount, baseAmount); 
        iBEP20(synthIN).transfer(synthIN, _actualInputSynth); 
        iSYNTH(synthIN).burnSynth(); 
        _decrementPoolBalances(outputBase, 0); 
        iBEP20(BASE).transfer(member, outputBase); 
        _addPoolMetrics(fee); 
        emit BurnSynth(member, BASE, outputBase, TOKEN, _actualInputSynth);
      return (outputBase, fee);
    }
    function _getAddedBaseAmount() internal view returns(uint256 _actual){
        uint _baseBalance = iBEP20(BASE).balanceOf(address(this)); 
        if(_baseBalance > baseAmount){
            _actual = _baseBalance-(baseAmount);
        } else {
            _actual = 0;
        }
        return _actual;
    }
    function _getAddedTokenAmount() internal view returns(uint256 _actual){
        uint _tokenBalance = iBEP20(TOKEN).balanceOf(address(this)); 
        if(_tokenBalance > tokenAmount){
            _actual = _tokenBalance-(tokenAmount);
        } else {
            _actual = 0;
        }
        return _actual;
    }
    function _swapBaseToToken(uint256 _x) internal returns (uint256 _y, uint256 _fee){
        uint256 _X = baseAmount;
        uint256 _Y = tokenAmount;
        _y =  iUTILS(_DAO().UTILS()).calcSwapOutput(_x, _X, _Y); 
        uint fee = iUTILS(_DAO().UTILS()).calcSwapFee(_x, _X, _Y); 
        _fee = iUTILS(_DAO().UTILS()).calcSpotValueInBase(TOKEN, fee); 
        _setPoolAmounts(_X + _x, _Y - _y); 
        _addPoolMetrics(_fee); 
        return (_y, _fee);
    }
    function _swapTokenToBase(uint256 _x) internal returns (uint256 _y, uint256 _fee){
        uint256 _X = tokenAmount;
        uint256 _Y = baseAmount;
        _y =  iUTILS(_DAO().UTILS()).calcSwapOutput(_x, _X, _Y); 
        _fee = iUTILS(_DAO().UTILS()).calcSwapFee(_x, _X, _Y); 
        _setPoolAmounts(_Y - _y, _X + _x); 
        _addPoolMetrics(_fee); 
        return (_y, _fee);
    }
    function sync() external {
        baseAmount = iBEP20(BASE).balanceOf(address(this));
        tokenAmount = iBEP20(TOKEN).balanceOf(address(this));
    }
    function _incrementPoolBalances(uint _baseAmount, uint _tokenAmount) internal  {
        baseAmount += _baseAmount;
        tokenAmount += _tokenAmount;
    }
    function _setPoolAmounts(uint256 _baseAmount, uint256 _tokenAmount) internal  {
        baseAmount = _baseAmount;
        tokenAmount = _tokenAmount; 
    }
    function _decrementPoolBalances(uint _baseAmount, uint _tokenAmount) internal  {
        baseAmount -= _baseAmount;
        tokenAmount -= _tokenAmount; 
    }
    function _addPoolMetrics(uint256 _fee) internal {
        if(lastMonth == 0){
            lastMonth = block.timestamp;
        }
        if(block.timestamp <= lastMonth + 2592000){ 
            map30DPoolRevenue = map30DPoolRevenue+(_fee);
        } else {
            lastMonth = block.timestamp;
            mapPast30DPoolRevenue = map30DPoolRevenue;
            addRevenue(mapPast30DPoolRevenue);
            map30DPoolRevenue = 0;
            map30DPoolRevenue = map30DPoolRevenue+(_fee);
        }
    }
    function addRevenue(uint _totalRev) internal {
        if(!(revenueArray.length == 2)){
            revenueArray.push(_totalRev);
        } else {
            addFee(_totalRev);
        }
    }
    function addFee(uint _rev) internal {
        uint _n = revenueArray.length; 
        for (uint i = _n - 1; i > 0; i--) {
            revenueArray[i] = revenueArray[i - 1];
        }
        revenueArray[0] = _rev;
    }
}
pragma solidity 0.8.3;
contract PoolFactory { 
    address public BASE;
    address public WBNB;
    address public DEPLOYER;
    uint public curatedPoolSize;    
    address[] public arrayPools;    
    address[] public arrayTokens;   
    mapping(address=>address) private mapToken_Pool;
    mapping(address=>bool) public isListedPool;
    mapping(address=>bool) public isCuratedPool;
    event CreatePool(address indexed token, address indexed pool);
    event AddCuratePool(address indexed pool, bool Curated);
    event RemoveCuratePool(address indexed pool, bool Curated);
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER || msg.sender == _DAO().DAO());
        _;
    }
    constructor (address _base, address _wbnb) {
        BASE = _base;
        WBNB = _wbnb;
        curatedPoolSize = 10;
        DEPLOYER = msg.sender;
    }
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    function purgeDeployer() external onlyDAO {
        DEPLOYER = address(0);
    }
    function createPoolADD(uint256 inputBase, uint256 inputToken, address token) external payable returns(address pool){
        require(getPool(token) == address(0)); 
        require((inputToken > 0 && inputBase >= (10000*10**18)), "!min"); 
        Pool newPool; address _token = token;
        if(token == address(0)){_token = WBNB;} 
        require(_token != BASE && iBEP20(_token).decimals() == 18); 
        newPool = new Pool(BASE, _token); 
        pool = address(newPool); 
        mapToken_Pool[_token] = pool; 
        _handleTransferIn(BASE, inputBase, pool); 
        _handleTransferIn(token, inputToken, pool); 
        arrayPools.push(pool); 
        arrayTokens.push(_token); 
        isListedPool[pool] = true; 
        Pool(pool).addForMember(msg.sender); 
        emit CreatePool(token, pool);
        return pool;
    }
    function createPool(address token) external onlyDAO returns(address pool){
        require(getPool(token) == address(0)); 
        Pool newPool; address _token = token;
        if(token == address(0)){_token = WBNB;} 
        newPool = new Pool(BASE, _token); 
        pool = address(newPool); 
        mapToken_Pool[_token] = pool; 
        arrayPools.push(pool); 
        arrayTokens.push(_token); 
        isListedPool[pool] = true; 
        emit CreatePool(token, pool);
        return pool;
    }
    function addCuratedPool(address token) external onlyDAO {
        require(token != BASE); 
        address _pool = getPool(token); 
        require(isListedPool[_pool] == true); 
        require(curatedPoolCount() < curatedPoolSize, "maxCurated"); 
        isCuratedPool[_pool] = true; 
        emit AddCuratePool(_pool, isCuratedPool[_pool]);
    }
    function removeCuratedPool(address token) external onlyDAO {
        require(token != BASE); 
        address _pool = getPool(token); 
        require(isCuratedPool[_pool] == true); 
        isCuratedPool[_pool] = false; 
        emit RemoveCuratePool(_pool, isCuratedPool[_pool]);
    }
    function curatedPoolCount() internal view returns (uint){
        uint cPoolCount; 
        for(uint i = 0; i< arrayPools.length; i++){
            if(isCuratedPool[arrayPools[i]] == true){
                cPoolCount += 1;
            }
        }
        return cPoolCount;
    }
    function _handleTransferIn(address _token, uint256 _amount, address _pool) internal returns(uint256 actual){
        if(_amount > 0) {
            uint startBal = iBEP20(_token).balanceOf(_pool); 
            iBEP20(_token).transferFrom(msg.sender, _pool, _amount); 
            actual = iBEP20(_token).balanceOf(_pool) - (startBal);
        }
    }
    function getPool(address token) public view returns(address pool){
        if(token == address(0)){
            pool = mapToken_Pool[WBNB];   
        } else {
            pool = mapToken_Pool[token];  
        } 
        return pool;
    }
    function isPool(address pool) external view returns (bool){
        if(isListedPool[pool] == true){
            return true;
        }
        return  false;
    }
    function poolCount() external view returns(uint256){
        return arrayPools.length;
    }
    function tokenCount() external view returns(uint256){
        return arrayTokens.length;
    }
    function getToken(uint256 i) external view returns(address){
        return arrayTokens[i];
    }
    function getPoolArray(uint256 i) external view returns(address){
        return arrayPools[i];
    }
}
pragma solidity 0.8.3;
interface iWBNB {
    function withdraw(uint256) external;
}
pragma solidity 0.8.3;
contract Router {
    address public BASE;
    address public WBNB;
    address public DEPLOYER;
    uint private maxTrades;         
    uint private eraLength;         
    uint public normalAverageFee;   
    uint private arrayFeeSize;      
    uint [] private feeArray;       
    uint private lastMonth;         
    mapping(address=> uint) public mapAddress_30DayDividends;
    mapping(address=> uint) public mapAddress_Past30DayPoolDividends;
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER);
        _;
    }
    constructor (address _base, address _wbnb) {
        BASE = _base;
        WBNB = _wbnb;
        arrayFeeSize = 20;
        eraLength = 30;
        maxTrades = 100;
        lastMonth = 0;
        DEPLOYER = msg.sender;
    }
    receive() external payable {}
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    function addLiquidity(uint inputBase, uint inputToken, address token) external payable{
        addLiquidityForMember(inputBase, inputToken, token, msg.sender);
    }
    function addLiquidityForMember(uint inputBase, uint inputToken, address token, address member) public payable{
        address pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token);  
        _handleTransferIn(BASE, inputBase, pool); 
        _handleTransferIn(token, inputToken, pool); 
        Pool(pool).addForMember(member); 
    }
    function zapLiquidity(uint unitsInput, address fromPool, address toPool) external {
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isPool(fromPool) == true); 
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isPool(toPool) == true); 
        address _fromToken = Pool(fromPool).TOKEN(); 
        address _member = msg.sender; 
        require(unitsInput <= iBEP20(fromPool).totalSupply()); 
        iBEP20(fromPool).transferFrom(_member, fromPool, unitsInput); 
        Pool(fromPool).remove(); 
        iBEP20(_fromToken).transfer(fromPool, iBEP20(_fromToken).balanceOf(address(this))); 
        Pool(fromPool).swapTo(BASE, toPool); 
        iBEP20(BASE).transfer(toPool, iBEP20(BASE).balanceOf(address(this))); 
        Pool(toPool).addForMember(_member); 
    }
    function addLiquiditySingle(uint inputToken, bool fromBase, address token) external payable{
        addLiquiditySingleForMember(inputToken, fromBase, token, msg.sender);
    }
    function addLiquiditySingleForMember(uint inputToken, bool fromBase, address token, address member) public payable{
        require(inputToken > 0); 
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); 
        address _token = token;
        if(token == address(0)){_token = WBNB;} 
        if(fromBase){
            _handleTransferIn(BASE, inputToken, _pool); 
            Pool(_pool).addForMember(member); 
        } else {
            _handleTransferIn(token, inputToken, _pool); 
            Pool(_pool).addForMember(member); 
        }
    }
    function removeLiquidity(uint basisPoints, address token) external{
        require((basisPoints > 0 && basisPoints <= 10000)); 
        uint _units = iUTILS(_DAO().UTILS()).calcPart(basisPoints, iBEP20(iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token)).balanceOf(msg.sender));
        removeLiquidityExact(_units, token);
    }
    function removeLiquidityExact(uint units, address token) public {
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); 
        address _member = msg.sender; 
        iBEP20(_pool).transferFrom(_member, _pool, units); 
        if(token != address(0)){
            Pool(_pool).removeForMember(_member); 
        } else {
            Pool(_pool).remove(); 
            uint outputBase = iBEP20(BASE).balanceOf(address(this)); 
            uint outputToken = iBEP20(WBNB).balanceOf(address(this)); 
            _handleTransferOut(token, outputToken, _member); 
            _handleTransferOut(BASE, outputBase, _member); 
        }
    }
    function removeLiquiditySingle(uint units, bool toBase, address token) external{
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); 
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isPool(_pool) == true); 
        address _member = msg.sender; 
        iBEP20(_pool).transferFrom(_member, _pool, units); 
        Pool(_pool).remove(); 
        address _token = token; 
        if(token == address(0)){_token = WBNB;} 
        if(toBase){
            iBEP20(_token).transfer(_pool, iBEP20(_token).balanceOf(address(this))); 
            Pool(_pool).swapTo(BASE, _member); 
        } else {
            iBEP20(BASE).transfer(_pool, iBEP20(BASE).balanceOf(address(this))); 
            Pool(_pool).swap(_token); 
            _handleTransferOut(token, iBEP20(_token).balanceOf(address(this)), _member); 
        } 
    }
    function buyTo(uint amount, address token, address member) public {
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); 
        _handleTransferIn(BASE, amount, _pool); 
        uint fee;
        if(token != address(0)){
            (, uint feey) = Pool(_pool).swapTo(token, member); 
            fee = feey;
        } else {
            (uint outputAmount, uint feez) = Pool(_pool).swap(WBNB); 
            _handleTransferOut(token, outputAmount, member); 
            fee = feez;
        }
        getsDividend(_pool, fee); 
    }
    function sellTo(uint amount, address token, address member) public payable returns (uint){
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); 
        _handleTransferIn(token, amount, _pool); 
        (, uint fee) = Pool(_pool).swapTo(BASE, member); 
        getsDividend(_pool, fee); 
        return fee;
    }
    function swap(uint256 inputAmount, address fromToken, address toToken) external payable{
        swapTo(inputAmount, fromToken, toToken, msg.sender);
    }
    function swapTo(uint256 inputAmount, address fromToken, address toToken, address member) public payable{
        require(fromToken != toToken); 
        if(fromToken == BASE){
            buyTo(inputAmount, toToken, member); 
        } else if(toToken == BASE) {
            sellTo(inputAmount, fromToken, member); 
        } else {
            address _poolTo = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(toToken); 
            uint feey = sellTo(inputAmount, fromToken, _poolTo); 
            address _toToken = toToken;
            if(toToken == address(0)){_toToken = WBNB;} 
            (uint _zz, uint _feez) = Pool(_poolTo).swap(_toToken); 
            uint fee = feey+(_feez); 
            getsDividend(_poolTo, fee); 
            _handleTransferOut(toToken, _zz, member); 
        }
    }
    function getsDividend(address _pool, uint fee) internal {
        if(iPOOLFACTORY(_DAO().POOLFACTORY()).isCuratedPool(_pool) == true){
            addTradeFee(fee); 
            addDividend(_pool, fee); 
        }
    }
    function _handleTransferIn(address _token, uint256 _amount, address _pool) internal returns(uint256 actual){
        if(_amount > 0) {
            if(_token == address(0)){
                require((_amount == msg.value));
                (bool success, ) = payable(WBNB).call{value: _amount}(""); 
                require(success, "!send");
                iBEP20(WBNB).transfer(_pool, _amount); 
                actual = _amount;
            } else {
                uint startBal = iBEP20(_token).balanceOf(_pool); 
                iBEP20(_token).transferFrom(msg.sender, _pool, _amount); 
                actual = iBEP20(_token).balanceOf(_pool)-(startBal); 
            }
        }
    }
    function _handleTransferOut(address _token, uint256 _amount, address _recipient) internal {
        if(_amount > 0) {
            if (_token == address(0)) {
                iWBNB(WBNB).withdraw(_amount); 
                (bool success, ) = payable(_recipient).call{value:_amount}("");  
                require(success, "!send");
            } else {
                iBEP20(_token).transfer(_recipient, _amount); 
            }
        }
    }
    function swapAssetToSynth(uint inputAmount, address fromToken, address toSynth) external payable {
        require(fromToken != toSynth); 
        address _synthLayer1 = iSYNTH(toSynth).LayerONE(); 
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(_synthLayer1); 
        if(fromToken != BASE){
            sellTo(inputAmount, fromToken, address(this)); 
            iBEP20(BASE).transfer(_pool, iBEP20(BASE).balanceOf(address(this))); 
        } else {
            iBEP20(BASE).transferFrom(msg.sender, _pool, inputAmount); 
        }
        (, uint fee) = Pool(_pool).mintSynth(toSynth, msg.sender); 
        getsDividend(_pool, fee); 
    }
    function swapSynthToAsset(uint inputAmount, address fromSynth, address toToken) external {
        require(fromSynth != toToken); 
        address _synthINLayer1 = iSYNTH(fromSynth).LayerONE(); 
        address _poolIN = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(_synthINLayer1); 
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(toToken); 
        iBEP20(fromSynth).transferFrom(msg.sender, _poolIN, inputAmount); 
        uint outputAmount; uint fee;
        if(toToken == BASE){
            Pool(_poolIN).burnSynth(fromSynth, msg.sender); 
        } else {
            (outputAmount,fee) = Pool(_poolIN).burnSynth(fromSynth, address(this)); 
            if(toToken != address(0)){
                (, uint feey) = Pool(_pool).swapTo(toToken, msg.sender); 
                fee = feey + fee;
            } else {
                (uint outputAmountY, uint feez) = Pool(_pool).swap(WBNB); 
                _handleTransferOut(toToken, outputAmountY, msg.sender); 
                fee = feez + fee;
            }
        }
        getsDividend(_pool, fee); 
    }
    function addDividend(address _pool, uint256 _fees) internal {
        if(!(normalAverageFee == 0)){
            uint reserve = iBEP20(BASE).balanceOf(_DAO().RESERVE()); 
            if(!(reserve == 0)){
                uint dailyAllocation = (reserve / eraLength) / maxTrades; 
                uint numerator = _fees * dailyAllocation;
                uint feeDividend = numerator / (_fees + normalAverageFee); 
                revenueDetails(feeDividend, _pool); 
                iRESERVE(_DAO().RESERVE()).grantFunds(feeDividend, _pool); 
                Pool(_pool).sync(); 
            }
        }
    }
    function addTradeFee(uint _fee) internal {
        uint totalTradeFees = 0;
        uint arrayFeeLength = feeArray.length;
        if(arrayFeeLength < arrayFeeSize){
            feeArray.push(_fee); 
        } else {
            addFee(_fee); 
            for(uint i = 0; i < arrayFeeSize; i++){
                totalTradeFees = totalTradeFees + feeArray[i]; 
            }
        }
        normalAverageFee = totalTradeFees / arrayFeeSize; 
    }
    function addFee(uint _fee) internal {
        uint n = feeArray.length; 
        for (uint i = n - 1; i > 0; i--) {
            feeArray[i] = feeArray[i - 1];
        }
        feeArray[0] = _fee;
    }
    function revenueDetails(uint _fees, address _pool) internal {
        if(lastMonth == 0){
            lastMonth = block.timestamp;
        }
        if(block.timestamp <= lastMonth + 2592000){ 
            mapAddress_30DayDividends[_pool] = mapAddress_30DayDividends[_pool] + _fees;
        } else {
            lastMonth = block.timestamp;
            mapAddress_Past30DayPoolDividends[_pool] = mapAddress_30DayDividends[_pool];
            mapAddress_30DayDividends[_pool] = 0;
            mapAddress_30DayDividends[_pool] = mapAddress_30DayDividends[_pool] + _fees;
        }
    }
    function stringToBytes(string memory s) external pure returns (bytes memory){
        return bytes(s);
    }
    function isEqual(bytes memory part1, bytes memory part2) external pure returns(bool equal){
        if(sha256(part1) == sha256(part2)){
            return true;
        }
    }
    function changeArrayFeeSize(uint _size) external onlyDAO {
        arrayFeeSize = _size;
        delete feeArray;
    }
    function changeMaxTrades(uint _maxtrades) external onlyDAO {
        maxTrades = _maxtrades;
    }
    function changeEraLength(uint _eraLength) external onlyDAO {	
        eraLength = _eraLength;	
    }
    function currentPoolRevenue(address pool) external view returns(uint256) {
        return mapAddress_30DayDividends[pool];
    }
    function pastPoolRevenue(address pool) external view returns(uint256) {
        return mapAddress_Past30DayPoolDividends[pool];
    }
}
pragma solidity 0.8.3;
contract Synth is iBEP20 {
    address public BASE;
    address public LayerONE; 
    uint public genesis;
    address public DEPLOYER;
    string _name; string _symbol;
    uint8 public override decimals; uint256 public override totalSupply;
    mapping(address => uint) private _balances;
    mapping(address => mapping(address => uint)) private _allowances;
    mapping(address => uint) public mapSynth_LPBalance;
    mapping(address => uint) public mapSynth_LPDebt;
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER, "!DAO");
        _;
    }
    modifier onlyPool() {
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isCuratedPool(msg.sender) == true, "!curated");
        _;
    }
    constructor (address _base, address _token) {
        BASE = _base;
        LayerONE = _token;
        string memory synthName = "-SpartanProtocolSynthetic";
        string memory synthSymbol = "-SPS";
        _name = string(abi.encodePacked(iBEP20(_token).name(), synthName));
        _symbol = string(abi.encodePacked(iBEP20(_token).symbol(), synthSymbol));
        decimals = iBEP20(_token).decimals();
        DEPLOYER = msg.sender;
        genesis = block.timestamp;
    }
    function name() external view override returns (string memory) {
        return _name;
    }
    function symbol() external view override returns (string memory) {
        return _symbol;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function transfer(address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) external virtual override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) external virtual returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender]+(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) external virtual returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][spender];
        require(currentAllowance >= subtractedValue, "!approval");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "!owner");
        require(spender != address(0), "!spender");
        if (_allowances[owner][spender] < type(uint256).max) { 
            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }
    }
    function transferFrom(address sender, address recipient, uint256 amount) external virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        if (_allowances[sender][msg.sender] < type(uint256).max) {
            uint256 currentAllowance = _allowances[sender][msg.sender];
            require(currentAllowance >= amount, "!approval");
            _approve(sender, msg.sender, currentAllowance - amount);
        }
        return true;
    }
    function approveAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
        _approve(msg.sender, recipient, type(uint256).max); 
        iBEP677(recipient).onTokenApproval(address(this), amount, msg.sender, data); 
        return true;
    }
    function transferAndCall(address recipient, uint amount, bytes calldata data) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        iBEP677(recipient).onTokenTransfer(address(this), amount, msg.sender, data); 
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "!sender");
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "!balance");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
    function burn(uint256 amount) external virtual override {
        _burn(msg.sender, amount);
    }
    function burnFrom(address account, uint256 amount) external virtual {  
        uint256 decreasedAllowance = allowance(account, msg.sender) - (amount);
        _approve(account, msg.sender, decreasedAllowance); 
        _burn(account, amount);
    }
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "!account");
        require(_balances[account] >= amount, "!balance");
        _balances[account] -= amount;
        totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }
    function mintSynth(address member, uint amount) external onlyPool returns (uint syntheticAmount){
        uint lpUnits = _getAddedLPAmount(msg.sender); 
        mapSynth_LPDebt[msg.sender] += amount; 
        mapSynth_LPBalance[msg.sender] += lpUnits; 
        _mint(member, amount); 
        return amount;
    }
    function burnSynth() external returns (bool){
        uint _syntheticAmount = balanceOf(address(this)); 
        uint _amountUnits = (_syntheticAmount * mapSynth_LPBalance[msg.sender]) / mapSynth_LPDebt[msg.sender]; 
        mapSynth_LPBalance[msg.sender] -= _amountUnits; 
        mapSynth_LPDebt[msg.sender] -= _syntheticAmount; 
        if(_amountUnits > 0){
            _burn(address(this), _syntheticAmount); 
            Pool(msg.sender).burn(_amountUnits); 
        }
        return true;
    }
    function realise(address pool) external {
        uint baseValueLP = iUTILS(_DAO().UTILS()).calcLiquidityHoldings(mapSynth_LPBalance[pool], BASE, pool); 
        uint baseValueSynth = iUTILS(_DAO().UTILS()).calcActualSynthUnits(mapSynth_LPDebt[pool], address(this)); 
        if(baseValueLP > baseValueSynth){
            uint premium = baseValueLP - baseValueSynth; 
            if(premium > 10**18){
                uint premiumLP = iUTILS(_DAO().UTILS()).calcLiquidityUnitsAsym(premium, pool); 
                mapSynth_LPBalance[pool] -= premiumLP; 
                Pool(pool).burn(premiumLP); 
            }
        }
    }
    function _handleTransferIn(address _token, uint256 _amount) internal returns(uint256 _actual){
        if(_amount > 0) {
            uint startBal = iBEP20(_token).balanceOf(address(this)); 
            iBEP20(_token).transferFrom(msg.sender, address(this), _amount); 
            _actual = iBEP20(_token).balanceOf(address(this)) - startBal; 
        }
        return _actual;
    }
    function _getAddedLPAmount(address _pool) internal view returns(uint256 _actual){
        uint _lpCollateralBalance = iBEP20(_pool).balanceOf(address(this)); 
        if(_lpCollateralBalance > mapSynth_LPBalance[_pool]){
            _actual = _lpCollateralBalance - mapSynth_LPBalance[_pool]; 
        } else {
            _actual = 0;
        }
        return _actual;
    }
    function getmapAddress_LPBalance(address pool) external view returns (uint){
        return mapSynth_LPBalance[pool];
    }
    function getmapAddress_LPDebt(address pool) external view returns (uint){
        return mapSynth_LPDebt[pool];
    }
}
pragma solidity 0.8.3;
contract SynthFactory { 
    address public BASE;
    address public WBNB;
    address public DEPLOYER;
    address[] public arraySynths; 
    mapping(address => address) private mapToken_Synth;
    mapping(address => bool) public isSynth;
    event CreateSynth(address indexed token, address indexed pool);
    constructor (address _base, address _wbnb) {
        BASE = _base;
        WBNB = _wbnb;
        DEPLOYER = msg.sender; 
    }
    modifier onlyDAO() {
        require(msg.sender == DEPLOYER, "!DAO");
        _;
    }
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    function purgeDeployer() external onlyDAO {
        DEPLOYER = address(0);
    }
    function createSynth(address token) external returns(address synth){
        require(getSynth(token) == address(0), "exists"); 
        address _pool = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token); 
        require(iPOOLFACTORY(_DAO().POOLFACTORY()).isCuratedPool(_pool) == true, "!curated"); 
        Synth newSynth; address _token = token;
        if(token == address(0)){_token = WBNB;} 
        newSynth = new Synth(BASE, _token); 
        synth = address(newSynth); 
        addSynth(_token, synth); 
        emit CreateSynth(token, synth);
        return synth;
    }
    function addSynth(address _token, address _synth) internal {
        require(_token != BASE); 
        mapToken_Synth[_token] = _synth; 
        arraySynths.push(_synth); 
        isSynth[_synth] = true; 
    }
    function getSynth(address token) public view returns(address synth){
        if(token == address(0)){
            synth = mapToken_Synth[WBNB];   
        } else {
            synth = mapToken_Synth[token];  
        } 
        return synth;
    }
    function synthCount() external view returns(uint256){
        return arraySynths.length;
    }
    function getSynthsArray(uint256 i) external view returns(address){
        return arraySynths[i];
    }
}
pragma solidity 0.8.3;
contract SynthVault {
    address public BASE;
    address public DEPLOYER;
    uint256 public minimumDepositTime;  
    uint256 public totalWeight;         
    uint256 public erasToEarn;          
    uint256 public vaultClaim;          
    address [] public stakedSynthAssets; 
    uint private lastMonth;             
    uint public genesis;                
    uint256 public map30DVaultRevenue; 
    uint256 public mapPast30DVaultRevenue; 
    uint256 [] public revenueArray; 
    modifier onlyDAO() {
        require(msg.sender == _DAO().DAO() || msg.sender == DEPLOYER);
        _;
    }
    constructor(address _base) {
        BASE = _base;
        DEPLOYER = msg.sender;
        erasToEarn = 30;
        minimumDepositTime = 3600; 
        vaultClaim = 1000;
        genesis = block.timestamp;
        lastMonth = 0;
    }
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    mapping(address => mapping(address => uint256)) private mapMemberSynth_weight;
    mapping(address => uint256) private mapMemberTotal_weight;
    mapping(address => mapping(address => uint256)) private mapMemberSynth_deposit;
    mapping(address => mapping(address => uint256)) private mapMemberSynth_lastTime;
    mapping(address => uint256) private mapMember_depositTime;
    mapping(address => uint256) public lastBlock;
    mapping(address => bool) private isStakedSynth;
    mapping(address => mapping(address => bool)) private isSynthMember;
    event MemberDeposits(
        address indexed synth,
        address indexed member,
        uint256 newDeposit,
        uint256 weight,
        uint256 totalWeight
    );
    event MemberWithdraws(
        address indexed synth,
        address indexed member,
        uint256 amount,
        uint256 weight,
        uint256 totalWeight
    );
    event MemberHarvests(
        address indexed synth,
        address indexed member,
        uint256 amount,
        uint256 weight,
        uint256 totalWeight
    );
    function setParams(uint256 one, uint256 two, uint256 three) external onlyDAO {
        erasToEarn = one;
        minimumDepositTime = two;
        vaultClaim = three;
    }
    function deposit(address synth, uint256 amount) external {
        depositForMember(synth, msg.sender, amount);
    }
    function depositForMember(address synth, address member, uint256 amount) public {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synth), "!synth"); 
        require(iBEP20(synth).transferFrom(msg.sender, address(this), amount)); 
        _deposit(synth, member, amount); 
    }
    function _deposit(address _synth, address _member, uint256 _amount) internal {
        if(!isStakedSynth[_synth]){
            isStakedSynth[_synth] = true; 
            stakedSynthAssets.push(_synth); 
        }
        mapMemberSynth_lastTime[_member][_synth] = block.timestamp + minimumDepositTime; 
        mapMember_depositTime[_member] = block.timestamp + minimumDepositTime; 
        mapMemberSynth_deposit[_member][_synth] += _amount; 
        uint256 _weight = iUTILS(_DAO().UTILS()).calcSpotValueInBase(iSYNTH(_synth).LayerONE(), _amount); 
        mapMemberSynth_weight[_member][_synth] += _weight; 
        mapMemberTotal_weight[_member] += _weight; 
        totalWeight += _weight; 
        isSynthMember[_member][_synth] = true; 
        emit MemberDeposits(_synth, _member, _amount, _weight, totalWeight);
    }
    function harvestAll() external returns (bool) {
        for(uint i = 0; i < stakedSynthAssets.length; i++){
            if((block.timestamp > mapMemberSynth_lastTime[msg.sender][stakedSynthAssets[i]])){
                uint256 reward = calcCurrentReward(stakedSynthAssets[i], msg.sender);
                if(reward > 0){
                    harvestSingle(stakedSynthAssets[i]);
                }
            }
        }
        return true;
    }
    function harvestSingle(address synth) public returns (bool) {
        require(iSYNTHFACTORY(_DAO().SYNTHFACTORY()).isSynth(synth), "!synth"); 
        require(iRESERVE(_DAO().RESERVE()).emissions(), "!emissions"); 
        uint256 _weight;
        uint256 reward = calcCurrentReward(synth, msg.sender); 
        mapMemberSynth_lastTime[msg.sender][synth] = block.timestamp; 
        address _poolOUT = iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(iSYNTH(synth).LayerONE()); 
        iRESERVE(_DAO().RESERVE()).grantFunds(reward, _poolOUT); 
        (uint synthReward,) = iPOOL(_poolOUT).mintSynth(synth, address(this)); 
        _weight = iUTILS(_DAO().UTILS()).calcSpotValueInBase(iSYNTH(synth).LayerONE(), synthReward); 
        mapMemberSynth_deposit[msg.sender][synth] += synthReward; 
        mapMemberSynth_weight[msg.sender][synth] += _weight; 
        mapMemberTotal_weight[msg.sender] += _weight; 
        totalWeight += _weight; 
        _addVaultMetrics(reward); 
        iSYNTH(synth).realise(_poolOUT); 
        emit MemberHarvests(synth, msg.sender, reward, _weight, totalWeight);
        return true;
    }
    function calcCurrentReward(address synth, address member) public view returns (uint256 reward){
        require((block.timestamp > mapMemberSynth_lastTime[member][synth]), "!unlocked"); 
        uint256 _secondsSinceClaim = block.timestamp - mapMemberSynth_lastTime[member][synth]; 
        uint256 _share = calcReward(synth, member); 
        reward = (_share * _secondsSinceClaim) / iBASE(BASE).secondsPerEra(); 
        return reward;
    }
    function calcReward(address synth, address member) public view returns (uint256) {
        uint256 _weight = mapMemberSynth_weight[member][synth]; 
        uint256 _reserve = reserveBASE() / erasToEarn; 
        uint256 _vaultReward = (_reserve * vaultClaim) / 10000; 
        return iUTILS(_DAO().UTILS()).calcShare(_weight, totalWeight, _vaultReward); 
    }
    function withdraw(address synth, uint256 basisPoints) external returns (uint256 redeemedAmount) {
        redeemedAmount = _processWithdraw(synth, msg.sender, basisPoints); 
        require(iBEP20(synth).transfer(msg.sender, redeemedAmount)); 
        return redeemedAmount;
    }
    function _processWithdraw(address _synth, address _member, uint256 _basisPoints) internal returns (uint256 synthReward) {
        require((block.timestamp > mapMember_depositTime[_member]), "lockout"); 
        uint256 _principle = iUTILS(_DAO().UTILS()).calcPart(_basisPoints, mapMemberSynth_deposit[_member][_synth]); 
        mapMemberSynth_deposit[_member][_synth] -= _principle; 
        uint256 _weight = iUTILS(_DAO().UTILS()).calcPart(_basisPoints, mapMemberSynth_weight[_member][_synth]); 
        mapMemberTotal_weight[_member] -= _weight; 
        mapMemberSynth_weight[_member][_synth] -= _weight; 
        totalWeight -= _weight; 
        emit MemberWithdraws(_synth, _member, synthReward, _weight, totalWeight);
        return (_principle + synthReward);
    }
    function reserveBASE() public view returns (uint256) {
        return iBEP20(BASE).balanceOf(_DAO().RESERVE());
    }
    function getMemberDeposit(address synth, address member) external view returns (uint256){
        return mapMemberSynth_deposit[member][synth];
    }
    function getMemberWeight(address member) external view returns (uint256) {
        return mapMemberTotal_weight[member];
    }
    function getStakeSynthLength() external view returns (uint256) {
        return stakedSynthAssets.length;
    }
    function getMemberLastTime(address member) external view returns (uint256) {
        return mapMember_depositTime[member];
    }
    function getMemberLastSynthTime(address synth, address member) external view returns (uint256){
        return mapMemberSynth_lastTime[member][synth];
    }
    function getMemberSynthWeight(address synth, address member) external view returns (uint256) {
        return mapMemberSynth_weight[member][synth];
    }
    function _addVaultMetrics(uint256 _fee) internal {
        if(lastMonth == 0){
            lastMonth = block.timestamp;
        }
        if(block.timestamp <= lastMonth + 2592000){ 
            map30DVaultRevenue = map30DVaultRevenue + _fee;
        } else {
            lastMonth = block.timestamp;
            mapPast30DVaultRevenue = map30DVaultRevenue;
            addRevenue(mapPast30DVaultRevenue);
            map30DVaultRevenue = 0;
            map30DVaultRevenue = map30DVaultRevenue + _fee;
        }
    }
    function addRevenue(uint _totalRev) internal {
        if(!(revenueArray.length == 2)){
            revenueArray.push(_totalRev);
        } else {
            addFee(_totalRev);
        }
    }
    function addFee(uint _rev) internal {
        uint _n = revenueArray.length; 
        for (uint i = _n - 1; i > 0; i--) {
            revenueArray[i] = revenueArray[i - 1];
        }
        revenueArray[0] = _rev;
    }
}
pragma solidity 0.8.3;
contract Utils {
    address public BASE;
    uint public one = 10**18;
    constructor (address _base) {
        BASE = _base;
    }
    struct PoolDataStruct {
        address tokenAddress;
        address poolAddress;
        uint genesis;
        uint baseAmount;
        uint tokenAmount;
        uint fees;
        uint volume;
        uint txCount;
        uint poolUnits;
    }
    function _DAO() internal view returns(iDAO) {
        return iBASE(BASE).DAO();
    }
    function getPoolData(address token) external view returns(PoolDataStruct memory poolData){
        address pool = getPool(token);
        poolData.poolAddress = pool;
        poolData.tokenAddress = token;
        poolData.genesis = iPOOL(pool).genesis();
        poolData.baseAmount = iPOOL(pool).baseAmount();
        poolData.tokenAmount = iPOOL(pool).tokenAmount();
        poolData.poolUnits = iBEP20(pool).totalSupply();
        return poolData;
    }
    function getPoolShareWeight(address token, uint units) external view returns(uint weight){
        address pool = getPool(token);
        weight = calcShare(units, iBEP20(pool).totalSupply(), iPOOL(pool).baseAmount());
        return (weight);
    }
    function getPool(address token) public view returns(address pool){
        return iPOOLFACTORY(_DAO().POOLFACTORY()).getPool(token);
    }
    function getFeeOnTransfer(uint256 totalSupply, uint256 maxSupply) external pure returns (uint256) {
        return calcShare(totalSupply, maxSupply, 100); 
    }
    function calcPart(uint256 bp, uint256 total) external pure returns (uint256) {
        require(bp <= 10000, "!bp"); 
        return calcShare(bp, 10000, total);
    }
    function calcShare(uint256 part, uint256 total, uint256 amount) public pure returns (uint256 share) {
        if (part > total) {
            part = total; 
        }
        if (total > 0) {
            share = (amount * part) / total;
        }
    }
    function calcLiquidityUnits(uint b, uint B, uint t, uint T, uint P) external view returns (uint units){
        if(P == 0){
            return b; 
        } else {
            uint slipAdjustment = getSlipAdustment(b, B, t, T);
            uint part1 = t*(B);
            uint part2 = T*(b);
            uint part3 = T*(B)*(2);
            uint _units = (P * (part1 + (part2))) / (part3);
            return _units * slipAdjustment / one;  
        }
    }
    function getSlipAdustment(uint b, uint B, uint t, uint T) public view returns (uint slipAdjustment){
        uint part1 = B * (t);
        uint part2 = b * (T);
        uint part3 = b * (2) + (B);
        uint part4 = t + (T);
        uint numerator;
        if(part1 > part2){
            numerator = part1 - (part2);
        } else {
            numerator = part2 - (part1);
        }
        uint denominator = part3 * (part4);
        return one - ((numerator * (one)) / (denominator)); 
    }
    function calcLiquidityHoldings(uint units, address token, address pool) external view returns (uint share){
        uint amount;
        if(token == BASE){
            amount = iPOOL(pool).baseAmount();
        } else {
            amount = iPOOL(pool).tokenAmount();
        }
        uint totalSupply = iBEP20(pool).totalSupply();
        return(amount*(units))/(totalSupply);
    }
    function calcSwapOutput(uint x, uint X, uint Y) public pure returns (uint output){
        uint numerator = x * (X * (Y));
        uint denominator = (x + (X)) * (x + (X));
        return numerator / (denominator);
    }
    function calcSwapFee(uint x, uint X, uint Y) external pure returns (uint output){
        uint numerator = x * (x * (Y));
        uint denominator = (x + (X)) * (x + (X));
        return numerator / (denominator);
    }
    function calcAsymmetricValueToken(address pool, uint amount) external view returns (uint tokenValue){
        uint baseAmount = calcShare(amount, iBEP20(pool).totalSupply(), iPOOL(pool).baseAmount());
        uint tokenAmount = calcShare(amount, iBEP20(pool).totalSupply(), iPOOL(pool).tokenAmount());
        uint baseSwapped = calcSwapValueInTokenWithPool(pool, baseAmount);
        tokenValue = tokenAmount + baseSwapped;
        return tokenValue;
    }
    function calcLiquidityUnitsAsym(uint amount, address pool) external view returns (uint units){
        uint baseAmount = iPOOL(pool).baseAmount();
        uint totalSupply = iBEP20(pool).totalSupply();
        uint two = 2;
        return (totalSupply * amount) / (two * (amount + baseAmount));
    }
    function calcSpotValueInBase(address token, uint amount) external view returns (uint value){
        address pool = getPool(token);
        return calcSpotValueInBaseWithPool(pool, amount);
    }
    function calcSpotValueInToken(address token, uint amount) external view returns (uint value){
        address pool = getPool(token);
        return calcSpotValueInTokenWithPool(pool, amount);
    }
    function calcSwapValueInBase(address token, uint amount) external view returns (uint _output){
        address pool = getPool(token);
        return  calcSwapValueInBaseWithPool(pool, amount);
    }
    function calcSwapValueInBaseWithSYNTH(address synth, uint amount) external view returns (uint _output){
        address token = iSYNTH(synth).LayerONE();
        address pool = getPool(token);
        return  calcSwapValueInBaseWithPool(pool, amount);
    }
    function calcSwapValueInToken(address token, uint amount) external view returns (uint _output){
        address pool = getPool(token);
        return  calcSwapValueInTokenWithPool(pool, amount);
    }
    function calcSpotValueInBaseWithPool(address pool, uint amount) public view returns (uint value){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return (amount*(_baseAmount))/(_tokenAmount);
    }
    function calcSpotValueInTokenWithPool(address pool, uint amount) public view returns (uint value){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return (amount*(_tokenAmount))/(_baseAmount);
    }
    function calcSwapValueInBaseWithPool(address pool, uint amount) public view returns (uint _output){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return  calcSwapOutput(amount, _tokenAmount, _baseAmount);
    }
    function calcSwapValueInTokenWithPool(address pool, uint amount) public view returns (uint _output){
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return  calcSwapOutput(amount, _baseAmount, _tokenAmount);
    }
    function calcActualSynthUnits(uint amount, address synth) external view returns (uint _output) {
        address token = iSYNTH(synth).LayerONE();
        address pool = getPool(token);
        uint _baseAmount = iPOOL(pool).baseAmount();
        uint _tokenAmount = iPOOL(pool).tokenAmount();
        return ((amount * _baseAmount) / (2 * _tokenAmount));
    }
}
pragma solidity 0.8.3;
interface iBASEv1 {
    function transferTo(address,uint256) external returns(bool);
}