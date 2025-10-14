pragma solidity ^0.8.4;
abstract contract LimboDAOLike {
    function approveFlanMintingPower(address minter, bool enabled)
        public
        virtual;
    function makeProposal(address proposal, address proposer) public virtual;
    function currentProposalState() public view virtual returns (uint,uint,address,uint,address);
    function setProposalConfig(
        uint256 votingDuration,
        uint256 requiredFateStake,
        address proposalFactory
    ) public virtual;
    function setApprovedAsset(address asset, bool approved) public virtual;
    function successfulProposal(address proposal)
        public
        view
        virtual
        returns (bool);
    function domainConfig()
        public
        virtual
        returns (
            address,
            address,
            address,
            address,
            bool,
            address,
            address
        );
    function getFlashGoverner() external view virtual returns (address);
    function proposalConfig() public virtual view returns (uint,uint,address);
  function setFateToFlan(uint256 rate) public virtual;
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
abstract contract FlashGovernanceArbiterLike {
    function assertGovernanceApproved(address sender, address target, bool emergency)
        public
        virtual;
    function enforceToleranceInt(int256 v1, int256 v2) public view virtual;
    function enforceTolerance(uint256 v1, uint256 v2) public view virtual;
    function burnFlashGovernanceAsset(
        address targetContract,
        address user,
        address asset,
        uint256 amount
    ) public virtual;
     function setEnforcement(bool enforce) public virtual;
}
abstract contract ProposalFactoryLike {
     function toggleWhitelistProposal(address proposal) public virtual;
     function soulUpdateProposal () public  virtual view returns (address); 
}
abstract contract Governable {
  FlashGovernanceArbiterLike internal flashGoverner;
  bool public configured;
  address public DAO;
  function endConfiguration() public {
    configured = true;
  }
  modifier onlySuccessfulProposal() {
    assertSuccessfulProposal(msg.sender);
    _;
  }
  modifier onlySoulUpdateProposal() {
    assertSoulUpdateProposal(msg.sender);
    _;
  }
  function assertSoulUpdateProposal(address sender) internal view {
    (, , address proposalFactory) = LimboDAOLike(DAO).proposalConfig();
    require(!configured || sender == ProposalFactoryLike(proposalFactory).soulUpdateProposal(), "EJ");
    assertSuccessfulProposal(sender);
  }
  function _governanceApproved(bool emergency) internal {
    bool successfulProposal = LimboDAOLike(DAO).successfulProposal(msg.sender);
    if (successfulProposal) {
      flashGoverner.setEnforcement(false);
    } else if (configured) flashGoverner.assertGovernanceApproved(msg.sender, address(this), emergency);
  }
  modifier governanceApproved(bool emergency) {
    _governanceApproved(emergency);
    _;
    flashGoverner.setEnforcement(true);
  }
  function assertSuccessfulProposal(address sender) internal view {
    require(!configured || LimboDAOLike(DAO).successfulProposal(sender), "EJ");
  }
  constructor(address dao) {
    setDAO(dao);
  }
  function setDAO(address dao) public {
    require(DAO == address(0) || msg.sender == DAO || !configured, "EK");
    DAO = dao;
    flashGoverner = FlashGovernanceArbiterLike(LimboDAOLike(dao).getFlashGoverner());
  }
}
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
        _transferOwnership(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}
abstract contract Proposal {
  string public description;
  LimboDAOLike DAO;
  constructor(address dao, string memory _description) {
    DAO = LimboDAOLike(dao);
    description = _description;
  }
  modifier onlyDAO() {
    address dao = address(DAO);
    require(dao != address(0), "PROPOSAL: DAO not set");
    require(msg.sender == dao, "PROPOSAL: only DAO can invoke");
    _;
  }
  modifier notCurrent() {
    (, , , , address proposal) = DAO.currentProposalState();
    require(proposal != address(this), "LimboDAO: proposal locked");
    _;
  }
  function orchestrateExecute() public onlyDAO {
    require(execute(), "LimboDAO: execution of proposal failed");
  }
  function execute() internal virtual returns (bool);
}
contract ProposalFactory is Governable, Ownable {
  mapping(address => bool) public whitelistedProposalContracts;
  address public soulUpdateProposal;
  constructor(
    address _dao,
    address whitelistingProposal,
    address _soulUpdateProposal
  ) Governable(_dao) {
    whitelistedProposalContracts[whitelistingProposal] = true;
    whitelistedProposalContracts[_soulUpdateProposal] = true;
    soulUpdateProposal = _soulUpdateProposal;
  }
  function changeSoulUpdateProposal(address newProposal) public onlyOwner {
    soulUpdateProposal = newProposal;
  }
  function toggleWhitelistProposal(address proposal) public onlySuccessfulProposal {
    whitelistedProposalContracts[proposal] = !whitelistedProposalContracts[proposal];
  }
  function lodgeProposal(address proposal) public {
    require(whitelistedProposalContracts[proposal], "LimboDAO: invalid proposal");
    LimboDAOLike(DAO).makeProposal(proposal, msg.sender);
  }
}
contract BurnFlashStakeDeposit is Proposal {
    struct Parameters {
        address user;
        address asset;
        uint256 amount;
        address flashGoverner;
        address targetContract;
    }
    Parameters public params;
    constructor(address dao, string memory _description)
        Proposal(dao, description)
    {}
    function parameterize(
        address user,
        address asset,
        uint256 amount,
        address flashGoverner,
        address targetContract
    ) public notCurrent {
        params.user = user;
        params.asset = asset;
        params.amount = amount;
        params.flashGoverner = flashGoverner;
        params.targetContract = targetContract;
    }
    function execute() internal override returns (bool) {
        FlashGovernanceArbiterLike(params.flashGoverner)
            .burnFlashGovernanceAsset(
            params.targetContract,
            params.user,
            params.asset,
            params.amount
        );
        return true;
    }
}