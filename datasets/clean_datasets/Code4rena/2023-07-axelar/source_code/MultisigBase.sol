pragma solidity ^0.8.9;
interface IMultisigBase {
    error NotSigner();
    error AlreadyVoted();
    error InvalidSigners();
    error InvalidSignerThreshold();
    error DuplicateSigner(address account);
    event MultisigOperationExecuted(bytes32 indexed operationHash);
    event SignersRotated(address[] newAccounts, uint256 newThreshold);
    function signerEpoch() external view returns (uint256);
    function signerThreshold() external view returns (uint256);
    function signerAccounts() external view returns (address[] memory);
    function isSigner(address account) external view returns (bool);
    function hasSignerVoted(address account, bytes32 topic) external view returns (bool);
    function getSignerVotesCount(bytes32 topic) external view returns (uint256);
    function rotateSigners(address[] memory newAccounts, uint256 newThreshold) external;
}
contract MultisigBase is IMultisigBase {
    struct Voting {
        uint256 voteCount;
        mapping(address => bool) hasVoted;
    }
    struct Signers {
        address[] accounts;
        uint256 threshold;
        mapping(address => bool) isSigner;
    }
    Signers public signers;
    uint256 public signerEpoch;
    mapping(uint256 => mapping(bytes32 => Voting)) public votingPerTopic;
    constructor(address[] memory accounts, uint256 threshold) {
        _rotateSigners(accounts, threshold);
    }
    modifier onlySigners() {
        if (!signers.isSigner[msg.sender]) revert NotSigner();
        bytes32 topic = keccak256(msg.data);
        Voting storage voting = votingPerTopic[signerEpoch][topic];
        if (voting.hasVoted[msg.sender]) revert AlreadyVoted();
        voting.hasVoted[msg.sender] = true;
        uint256 voteCount = voting.voteCount + 1;
        if (voteCount < signers.threshold) {
            voting.voteCount = voteCount;
            return;
        }
        voting.voteCount = 0;
        uint256 count = signers.accounts.length;
        for (uint256 i; i < count; ++i) {
            voting.hasVoted[signers.accounts[i]] = false;
        }
        emit MultisigOperationExecuted(topic);
        _;
    }
    function signerThreshold() external view override returns (uint256) {
        return signers.threshold;
    }
    function signerAccounts() external view override returns (address[] memory) {
        return signers.accounts;
    }
    function isSigner(address account) external view override returns (bool) {
        return signers.isSigner[account];
    }
    function hasSignerVoted(address account, bytes32 topic) external view override returns (bool) {
        return votingPerTopic[signerEpoch][topic].hasVoted[account];
    }
    function getSignerVotesCount(bytes32 topic) external view override returns (uint256) {
        uint256 length = signers.accounts.length;
        uint256 voteCount;
        for (uint256 i; i < length; ++i) {
            if (votingPerTopic[signerEpoch][topic].hasVoted[signers.accounts[i]]) {
                voteCount++;
            }
        }
        return voteCount;
    }
    function rotateSigners(address[] memory newAccounts, uint256 newThreshold) external virtual onlySigners {
        _rotateSigners(newAccounts, newThreshold);
    }
    function _rotateSigners(address[] memory newAccounts, uint256 newThreshold) internal {
        uint256 length = signers.accounts.length;
        for (uint256 i; i < length; ++i) {
            signers.isSigner[signers.accounts[i]] = false;
        }
        length = newAccounts.length;
        if (newThreshold > length) revert InvalidSigners();
        if (newThreshold == 0) revert InvalidSignerThreshold();
        ++signerEpoch;
        signers.accounts = newAccounts;
        signers.threshold = newThreshold;
        for (uint256 i; i < length; ++i) {
            address account = newAccounts[i];
            if (signers.isSigner[account]) revert DuplicateSigner(account);
            if (account == address(0)) revert InvalidSigners();
            signers.isSigner[account] = true;
        }
        emit SignersRotated(newAccounts, newThreshold);
    }
}