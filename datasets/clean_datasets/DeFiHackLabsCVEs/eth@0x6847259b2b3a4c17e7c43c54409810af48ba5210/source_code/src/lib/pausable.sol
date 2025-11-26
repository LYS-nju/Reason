pragma solidity ^0.6.7;
import "./owned.sol";
abstract contract Pausable is Owned {
    uint256 public lastPauseTime;
    bool public paused;
    constructor() internal {
        require(owner != address(0), "Owner must be set");
    }
    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }
        paused = _paused;
        if (paused) {
            lastPauseTime = now;
        }
        emit PauseChanged(paused);
    }
    event PauseChanged(bool isPaused);
    modifier notPaused {
        require(
            !paused,
            "This action cannot be performed while the contract is paused"
        );
        _;
    }
}