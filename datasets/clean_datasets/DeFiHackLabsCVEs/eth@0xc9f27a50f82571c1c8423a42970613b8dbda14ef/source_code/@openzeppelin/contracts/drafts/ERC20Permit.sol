pragma solidity >=0.6.5 <0.8.0;
import "../token/ERC20/ERC20.sol";
import "./IERC20Permit.sol";
import "../cryptography/ECDSA.sol";
import "../utils/Counters.sol";
import "./EIP712.sol";
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;
    mapping (address => Counters.Counter) private _nonces;
    bytes32 private immutable _PERMIT_TYPEHASH = keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    constructor(string memory name) internal EIP712(name, "1") {
    }
    function permit(address owner, address spender, uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _nonces[owner].current(),
                deadline
            )
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");
        _nonces[owner].increment();
        _approve(owner, spender, value);
    }
    function nonces(address owner) public view override returns (uint256) {
        return _nonces[owner].current();
    }
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
}