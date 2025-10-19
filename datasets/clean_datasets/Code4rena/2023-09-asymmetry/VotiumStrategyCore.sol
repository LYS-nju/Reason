pragma solidity 0.8.19;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "../../external_interfaces/IWETH.sol";
import "../../external_interfaces/ISwapRouter.sol";
import "../../external_interfaces/IVotiumMerkleStash.sol";
import "../../external_interfaces/ISnapshotDelegationRegistry.sol";
import "../../external_interfaces/ILockedCvx.sol";
import "../../external_interfaces/IClaimZap.sol";
import "../../external_interfaces/ICrvEthPool.sol";
import "../../external_interfaces/IAfEth.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "../AbstractStrategy.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../../external_interfaces/ISafEth.sol";
import "hardhat/console.sol";
contract VotiumStrategyCore is
    Initializable,
    OwnableUpgradeable,
    ERC20Upgradeable
{
    address public constant SNAPSHOT_DELEGATE_REGISTRY =
        0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446;
    address constant CVX_ADDRESS = 0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B;
    address constant VLCVX_ADDRESS = 0x72a19342e8F1838460eBFCCEf09F6585e32db86E;
    struct SwapData {
        address sellToken;
        address spender;
        address swapTarget;
        bytes swapCallData;
    }
    struct ChainlinkResponse {
        uint80 roundId;
        int256 answer;
        uint256 updatedAt;
        bool success;
    }
    uint256 public cvxUnlockObligations;
    address public rewarder;
    address public manager;
    AggregatorV3Interface public chainlinkCvxEthFeed;
    uint256 latestWithdrawId;
    uint256[20] private __gap;
    event DepositReward(
        uint256 indexed newPrice,
        uint256 indexed ethAmount,
        uint256 indexed cvxAmount
    );
    event FailedToSell(address indexed tokenAddress);
    error SwapFailed(uint256 index);
    error ChainlinkFailed();
    error NotRewarder();
    error InvalidLockedAmount();
    error NotOwner();
    error WithdrawNotReady();
    error AlreadyWithdrawn();
    function setChainlinkCvxEthFeed(
        address _cvxEthFeedAddress
    ) public onlyOwner {
        chainlinkCvxEthFeed = AggregatorV3Interface(_cvxEthFeedAddress);
    }
    modifier onlyRewarder() {
        if (msg.sender != rewarder) revert NotRewarder();
        _;
    }
    constructor() {
        _disableInitializers();
    }
    function initialize(
        address _owner,
        address _rewarder,
        address _manager
    ) external initializer {
        bytes32 VotiumVoteDelegationId = 0x6376782e65746800000000000000000000000000000000000000000000000000;
        address DelegationRegistry = 0x469788fE6E9E9681C6ebF3bF78e7Fd26Fc015446;
        address votiumVoteProxyAddress = 0xde1E6A7ED0ad3F61D531a8a78E83CcDdbd6E0c49;
        ISnapshotDelegationRegistry(DelegationRegistry).setDelegate(
            VotiumVoteDelegationId,
            votiumVoteProxyAddress
        );
        rewarder = _rewarder;
        manager = _manager;
        __ERC20_init("Votium AfEth Strategy", "vAfEth");
        _transferOwnership(_owner);
        chainlinkCvxEthFeed = AggregatorV3Interface(
            0xC9CbF687f43176B302F03f5e58470b77D07c61c6
        );
    }
    function setRewarder(address _rewarder) external onlyOwner {
        rewarder = _rewarder;
    }
    function cvxInSystem() public view returns (uint256) {
        (uint256 total, , , ) = ILockedCvx(VLCVX_ADDRESS).lockedBalances(
            address(this)
        );
        return total + IERC20(CVX_ADDRESS).balanceOf(address(this));
    }
    function cvxPerVotium() public view returns (uint256) {
        uint256 supply = totalSupply();
        uint256 totalCvx = cvxInSystem();
        if (supply == 0 || totalCvx == 0) return 1e18;
        return ((totalCvx - cvxUnlockObligations) * 1e18) / supply;
    }
    function ethPerCvx(bool _validate) public view returns (uint256) {
        ChainlinkResponse memory cl;
        try chainlinkCvxEthFeed.latestRoundData() returns (
            uint80 roundId,
            int256 answer,
            uint256 ,
            uint256 updatedAt,
            uint80 
        ) {
            cl.success = true;
            cl.roundId = roundId;
            cl.answer = answer;
            cl.updatedAt = updatedAt;
        } catch {
            cl.success = false;
        }
        if (
            (!_validate ||
                (cl.success == true &&
                    cl.roundId != 0 &&
                    cl.answer >= 0 &&
                    cl.updatedAt != 0 &&
                    cl.updatedAt <= block.timestamp &&
                    block.timestamp - cl.updatedAt <= 25 hours))
        ) {
            return uint256(cl.answer);
        } else {
            revert ChainlinkFailed();
        }
    }
    function claimRewards(
        IVotiumMerkleStash.ClaimParam[] calldata _claimProofs
    ) public onlyRewarder {
        claimVotiumRewards(_claimProofs);
        claimVlCvxRewards();
    }
    function depositRewards(uint256 _amount) public payable {
        uint256 cvxAmount = buyCvx(_amount);
        IERC20(CVX_ADDRESS).approve(VLCVX_ADDRESS, cvxAmount);
        ILockedCvx(VLCVX_ADDRESS).lock(address(this), cvxAmount, 0);
        emit DepositReward(cvxPerVotium(), _amount, cvxAmount);
    }
    function withdrawStuckTokens(address _token) public onlyOwner {
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }
    function buyCvx(
        uint256 _ethAmountIn
    ) internal returns (uint256 cvxAmountOut) {
        address CVX_ETH_CRV_POOL_ADDRESS = 0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;
        uint256 cvxBalanceBefore = IERC20(CVX_ADDRESS).balanceOf(address(this));
        ICrvEthPool(CVX_ETH_CRV_POOL_ADDRESS).exchange_underlying{
            value: _ethAmountIn
        }(
            0,
            1,
            _ethAmountIn,
            0 
        );
        uint256 cvxBalanceAfter = IERC20(CVX_ADDRESS).balanceOf(address(this));
        cvxAmountOut = cvxBalanceAfter - cvxBalanceBefore;
    }
    function sellCvx(
        uint256 _cvxAmountIn
    ) internal returns (uint256 ethAmountOut) {
        address CVX_ETH_CRV_POOL_ADDRESS = 0xB576491F1E6e5E62f1d8F26062Ee822B40B0E0d4;
        uint256 ethBalanceBefore = address(this).balance;
        IERC20(CVX_ADDRESS).approve(CVX_ETH_CRV_POOL_ADDRESS, _cvxAmountIn);
        ICrvEthPool(CVX_ETH_CRV_POOL_ADDRESS).exchange_underlying(
            1,
            0,
            _cvxAmountIn,
            0 
        );
        ethAmountOut = address(this).balance - ethBalanceBefore;
    }
    function applyRewards(SwapData[] calldata _swapsData) public onlyRewarder {
        uint256 ethBalanceBefore = address(this).balance;
        for (uint256 i = 0; i < _swapsData.length; i++) {
            uint256 allowance = IERC20(_swapsData[i].sellToken).allowance(
                address(this),
                address(_swapsData[i].spender)
            );
            if (allowance != type(uint256).max) {
                if (allowance > 0) {
                    IERC20(_swapsData[i].sellToken).approve(
                        address(_swapsData[i].spender),
                        0
                    );
                }
                IERC20(_swapsData[i].sellToken).approve(
                    address(_swapsData[i].spender),
                    type(uint256).max
                );
            }
            (bool success, ) = _swapsData[i].swapTarget.call(
                _swapsData[i].swapCallData
            );
            if (!success) {
                emit FailedToSell(_swapsData[i].sellToken);
            }
        }
        uint256 ethBalanceAfter = address(this).balance;
        uint256 ethReceived = ethBalanceAfter - ethBalanceBefore;
        if (address(manager) != address(0))
            IAfEth(manager).depositRewards{value: ethReceived}(ethReceived);
        else depositRewards(ethReceived);
    }
    function claimVotiumRewards(
        IVotiumMerkleStash.ClaimParam[] calldata _claimProofs
    ) private {
        IVotiumMerkleStash(0x378Ba9B73309bE80BF4C2c027aAD799766a7ED5A)
            .claimMulti(address(this), _claimProofs);
    }
    function claimVlCvxRewards() private {
        address[] memory emptyArray;
        IClaimZap(0x3f29cB4111CbdA8081642DA1f75B3c12DECf2516).claimRewards(
            emptyArray,
            emptyArray,
            emptyArray,
            emptyArray,
            0,
            0,
            0,
            0,
            8
        );
    }
    receive() external payable {}
}