pragma solidity 0.6.7;
import "../lib/erc20.sol";
import "../lib/ownable.sol";
contract PickleToken is ERC20("PickleToken", "PICKLE"), Ownable {
    function mint(address _to, uint256 _amount) public onlyOwner {
        _mint(_to, _amount);
    }
}