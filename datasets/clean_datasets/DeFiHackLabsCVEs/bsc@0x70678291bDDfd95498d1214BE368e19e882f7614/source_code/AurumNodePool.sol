pragma solidity 0.8.13;
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );
        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(
            data
        );
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
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
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; 
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() external virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) external virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
contract AurumNodePool is Context, Ownable {
    struct NodeEntity {
        uint256 nodeId;
        uint256 creationTime;
        uint256 lastClaimTime; 
    }
    mapping(address => uint256) nodeOwners;
    mapping(address => NodeEntity[]) private _nodesOfUser;
    uint256 public nodePrice;
    uint256 public rewardPerDay;
    uint256 public maxNodes = 30; 
    uint256 public totalNodesCreated = 0;
    address public teamWallet = 0xf0439f9895c0EacF46009Feeb3a26EAA61907890; 
    uint256 public teamFee = 100;
    uint256 public feeDenomiator = 1000;
    IERC20 public AURUM = IERC20(0x73A1163EA930A0a67dFEFB9C3713Ef0923755B78);
    constructor(
        uint256 _nodePrice,
        uint256 _rewardPerDay
    ) {
        nodePrice = _nodePrice;
        rewardPerDay = _rewardPerDay;
    }
    function createNode(uint256 count) external {
        require(count > 0, "Count should be not 0");
        address account = msg.sender;
        require(nodeOwners[account] + count <= maxNodes, "Count Limited");
        uint256 price = nodePrice * count;
        uint256 operationsPrice = price*teamFee/feeDenomiator;
        AURUM.transferFrom(account, address(this), price);
        AURUM.transfer(teamWallet, operationsPrice);  
        for (uint256 i = 0; i < count; i ++) {
            _nodesOfUser[account].push(
                NodeEntity({
                    nodeId: (totalNodesCreated + 1),
                    creationTime: block.timestamp + i,
                    lastClaimTime: block.timestamp + i
                })
            );
            nodeOwners[account]++;
            totalNodesCreated++;
        }
    }
    function _getNodeWithCreatime(NodeEntity[] storage nodes, uint256 _creationTime) internal view returns (NodeEntity storage) {
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CLAIM ERROR: You don't have nodes to claim"
        );
        bool found = false;
        int256 index = binary_search(nodes, 0, numberOfNodes, _creationTime);
        uint256 validIndex;
        if (index >= 0) {
            found = true;
            validIndex = uint256(index);
        }
        require(found, "NODE SEARCH: No NODE Found with this blocktime");
        return nodes[validIndex];
    }
    function binary_search(NodeEntity[] memory arr, uint256 low, uint256 high, uint256 x) internal view returns (int256) {
        if (high >= low) {
            uint256 mid = (high + low) / 2;
            if (arr[mid].creationTime == x) {
                return int256(mid);
            } else if (arr[mid].creationTime > x) {
                return binary_search(arr, low, mid - 1, x);
            } else {
                return binary_search(arr, mid + 1, high, x);
            }
        } else {
            return -1;
        }
    }
    function getNodeReward(NodeEntity memory node) internal view returns (uint256) {
        return rewardPerDay * (block.timestamp - node.lastClaimTime) / 86400;
    } 
    function claimNodeReward(uint256 _creationTime) external {
        address account = msg.sender;
        require(_creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CLAIM ERROR: You don't have nodes to claim"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, _creationTime);
        uint256 rewardNode = getNodeReward(node);
        node.lastClaimTime = block.timestamp;
        AURUM.transfer(account, rewardNode);
    }
    function claimAllNodesReward() external {
        address account = msg.sender;
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 nodesCount = nodes.length;
        require(nodesCount > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity storage _node;
        uint256 rewardsTotal = 0;
        for (uint256 i = 0; i < nodesCount; i++) {
            _node = nodes[i];
            uint nodeReward = getNodeReward(_node);
            rewardsTotal += nodeReward;
            _node.lastClaimTime = block.timestamp;
        }
        AURUM.transfer(account, rewardsTotal);
    }
    function getRewardTotalAmountOf(address account) external view returns (uint256) {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        uint256 nodesCount;
        uint256 rewardCount = 0;
        NodeEntity[] storage nodes = _nodesOfUser[account];
        nodesCount = nodes.length;
        for (uint256 i = 0; i < nodesCount; i++) {
            uint256 nodeReward = getNodeReward(nodes[i]);
            rewardCount += nodeReward;
        }
        return rewardCount;
    }
    function getRewardAmountOf(address account, uint256 creationTime) external view returns (uint256) {
        require(isNodeOwner(account), "GET REWARD OF: NO NODE OWNER");
        require(creationTime > 0, "NODE: CREATIME must be higher than zero");
        NodeEntity[] storage nodes = _nodesOfUser[account];
        uint256 numberOfNodes = nodes.length;
        require(
            numberOfNodes > 0,
            "CLAIM ERROR: You don't have nodes to claim"
        );
        NodeEntity storage node = _getNodeWithCreatime(nodes, creationTime);        
        uint256 nodeReward = getNodeReward(node);
        return nodeReward;
    }
    function getNodes(address account) external view returns(NodeEntity[] memory nodes) {
        nodes = _nodesOfUser[account];
    }
    function changeNodePrice(uint256 newNodePrice) external {
        nodePrice = newNodePrice;
    }
    function changeRewardPerNode(uint256 _rewardPerDay) external {        
        rewardPerDay = _rewardPerDay;
    }
    function getNodeNumberOf(address account) external view returns (uint256) {
        return nodeOwners[account];
    }
    function isNodeOwner(address account) internal view returns (bool) {
        return nodeOwners[account] > 0;
    }
    function setTeamWallet(address _wallet) external onlyOwner {
        teamWallet = _wallet;
    }
    function setTeamFees(uint256 _teamFee) external onlyOwner {
        teamFee = _teamFee; 
    }  
    function setMaxNodes(uint256 _count) external onlyOwner {
        maxNodes = _count;
    }
}