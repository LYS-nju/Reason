pragma solidity ^0.8.0;
library Math {
    enum Rounding {
        Down, 
        Up, 
        Zero 
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0; 
            uint256 prod1; 
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            require(denominator > prod1, "Math: mulDiv overflow");
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            result = prod0 * inverse;
            return result;
        }
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = 1 << (log2(a) >> 1);
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
pragma solidity ^0.8.0;
library SignedMath {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }
    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            return uint256(n >= 0 ? n : -n);
        }
    }
}
pragma solidity ^0.8.0;
library Strings {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = Math.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMath.abs(value))));
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, Math.log256(value) + 1);
        }
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
pragma solidity ^0.8.0;
library ECDSA {
    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV 
    }
    function _throwError(RecoverError error) private pure {
        if (error == RecoverError.NoError) {
            return; 
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        }
    }
    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {
        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address, RecoverError) {
        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
        return tryRecover(hash, v, r, s);
    }
    function recover(bytes32 hash, bytes32 r, bytes32 vs) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }
    function tryRecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address, RecoverError) {
        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }
        return (signer, RecoverError.NoError);
    }
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32 message) {
        assembly {
            mstore(0x00, "\x19Ethereum Signed Message:\n32")
            mstore(0x1c, hash)
            message := keccak256(0x00, 0x3c)
        }
    }
    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }
    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 data) {
        assembly {
            let ptr := mload(0x40)
            mstore(ptr, "\x19\x01")
            mstore(add(ptr, 0x02), domainSeparator)
            mstore(add(ptr, 0x22), structHash)
            data := keccak256(ptr, 0x42)
        }
    }
    function toDataWithIntendedValidatorHash(address validator, bytes memory data) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x00", validator, data));
    }
}
pragma solidity ^0.8.0;
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
pragma solidity ^0.8.1;
library Address {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
pragma solidity 0.8.4;
library LibUtils {
    function revertIfCallFailed(bool success, bytes memory returnData)
        internal
        pure
    {
        if (!success) {
            assembly {
                revert(add(returnData, 0x20), mload(returnData))
            }
        }
    }
}
pragma solidity 0.8.4;
library LibERC20 {
    function wrapCall(address assetId, bytes memory callData)
        internal
        returns (bool)
    {
        require(Address.isContract(assetId), "LibERC20: NO_CODE");
        (bool success, bytes memory returnData) = assetId.call(callData);
        LibUtils.revertIfCallFailed(success, returnData);
        return returnData.length == 0 || abi.decode(returnData, (bool));
    }
    function approve(
        address assetId,
        address spender,
        uint256 amount
    ) internal returns (bool) {
        return
            wrapCall(
                assetId,
                abi.encodeWithSignature(
                    "approve(address,uint256)",
                    spender,
                    amount
                )
            );
    }
    function transferFrom(
        address assetId,
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        return
            wrapCall(
                assetId,
                abi.encodeWithSignature(
                    "transferFrom(address,address,uint256)",
                    sender,
                    recipient,
                    amount
                )
            );
    }
    function transfer(
        address assetId,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        return
            wrapCall(
                assetId,
                abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    recipient,
                    amount
                )
            );
    }
}
pragma solidity 0.8.4;
library LibAsset {
    address constant ETHER_ASSETID = address(0);
    function isEther(address assetId) internal pure returns (bool) {
        return assetId == ETHER_ASSETID;
    }
    function getOwnBalance(address assetId) internal view returns (uint256) {
        return
            isEther(assetId)
                ? address(this).balance
                : IERC20(assetId).balanceOf(address(this));
    }
    function transferEther(address payable recipient, uint256 amount)
        internal
        returns (bool)
    {
        (bool success, bytes memory returnData) =
            recipient.call{value: amount}("");
        LibUtils.revertIfCallFailed(success, returnData);
        return true;
    }
    function transferERC20(
        address assetId,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        return LibERC20.transfer(assetId, recipient, amount);
    }
    function transferAsset(
        address assetId,
        address payable recipient,
        uint256 amount
    ) internal returns (bool) {
        return
            isEther(assetId)
                ? transferEther(recipient, amount)
                : transferERC20(assetId, recipient, amount);
    }
}
pragma solidity ^0.8.0;
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }
    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
    }
    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}
pragma solidity 0.8.4;
interface IFulfillHelper {
  function addFunds(
    address user,
    bytes32 transactionId,
    address assetId,
    uint256 amount
  ) external payable;
  function execute(
    address user,
    bytes32 transactionId,
    address assetId,
    uint256 amount,
    bytes calldata callData
  ) external;
}
pragma solidity 0.8.4;
interface ITransactionManager {
  struct InvariantTransactionData {
    address user;
    address router;
    address sendingAssetId;
    address receivingAssetId;
    address sendingChainFallback; 
    address receivingAddress;
    address callTo;
    uint256 sendingChainId;
    uint256 receivingChainId;
    bytes32 callDataHash; 
    bytes32 transactionId;
  }
  struct VariantTransactionData {
    uint256 amount;
    uint256 expiry;
    uint256 preparedBlockNumber;
  }
  struct TransactionData {
    address user;
    address router;
    address sendingAssetId;
    address receivingAssetId;
    address sendingChainFallback;
    address receivingAddress;
    address callTo;
    bytes32 callDataHash;
    bytes32 transactionId;
    uint256 sendingChainId;
    uint256 receivingChainId;
    uint256 amount;
    uint256 expiry;
    uint256 preparedBlockNumber; 
  }
  struct SignedCancelData {
    bytes32 transactionId;
    uint256 relayerFee;
    string cancel; 
  }
  struct SignedFulfillData {
    bytes32 transactionId;
    uint256 relayerFee;
  }
  event LiquidityAdded(address indexed router, address indexed assetId, uint256 amount, address caller);
  event LiquidityRemoved(address indexed router, address indexed assetId, uint256 amount, address recipient);
  event TransactionPrepared(
    address indexed user,
    address indexed router,
    bytes32 indexed transactionId,
    TransactionData txData,
    address caller,
    bytes encryptedCallData,
    bytes encodedBid,
    bytes bidSignature
  );
  event TransactionFulfilled(
    address indexed user,
    address indexed router,
    bytes32 indexed transactionId,
    TransactionData txData,
    uint256 relayerFee,
    bytes signature,
    bytes callData,
    address caller
  );
  event TransactionCancelled(
    address indexed user,
    address indexed router,
    bytes32 indexed transactionId,
    TransactionData txData,
    uint256 relayerFee,
    address caller
  );
  function addLiquidity(uint256 amount, address assetId, address router) external payable;
  function removeLiquidity(
    uint256 amount,
    address assetId,
    address payable recipient
  ) external;
  function prepare(
    InvariantTransactionData calldata txData,
    uint256 amount,
    uint256 expiry,
    bytes calldata encryptedCallData,
    bytes calldata encodedBid,
    bytes calldata bidSignature
  ) external payable returns (TransactionData memory);
  function fulfill(
    TransactionData calldata txData,
    uint256 relayerFee,
    bytes calldata signature,
    bytes calldata callData
  ) external returns (TransactionData memory);
  function cancel(TransactionData calldata txData, uint256 relayerFee, bytes calldata signature) external returns (TransactionData memory);
  function getActiveTransactionBlocks(address user) external view returns (uint256[] memory);
}
pragma solidity 0.8.4;
contract TransactionManager is ReentrancyGuard, ITransactionManager {
  mapping(address => mapping(address => uint256)) public routerBalances;
  mapping(address => uint256[]) public activeTransactionBlocks;
  mapping(bytes32 => bytes32) public variantTransactionData;
  uint256 public immutable chainId;
  uint256 public constant MIN_TIMEOUT = 24 hours;
  constructor(uint256 _chainId) {
    chainId = _chainId;
  }
  function addLiquidity(uint256 amount, address assetId, address router) external payable override nonReentrant {
    require(amount > 0, "addLiquidity: AMOUNT_IS_ZERO");
    if (LibAsset.isEther(assetId)) {
      require(msg.value == amount, "addLiquidity: VALUE_MISMATCH");
    } else {
      require(msg.value == 0, "addLiquidity: ETH_WITH_ERC_TRANSFER");
      require(LibERC20.transferFrom(assetId, router, address(this), amount), "addLiquidity: ERC20_TRANSFER_FAILED");
    }
    routerBalances[router][assetId] += amount;
    emit LiquidityAdded(router, assetId, amount, msg.sender);
  }
  function removeLiquidity(
    uint256 amount,
    address assetId,
    address payable recipient
  ) external override nonReentrant {
    require(amount > 0, "removeLiquidity: AMOUNT_IS_ZERO");
    require(routerBalances[msg.sender][assetId] >= amount, "removeLiquidity: INSUFFICIENT_FUNDS");
    routerBalances[msg.sender][assetId] -= amount;
    require(LibAsset.transferAsset(assetId, recipient, amount), "removeLiquidity: TRANSFER_FAILED");
    emit LiquidityRemoved(msg.sender, assetId, amount, recipient);
  }
  function prepare(
    InvariantTransactionData calldata invariantData,
    uint256 amount,
    uint256 expiry,
    bytes calldata encryptedCallData,
    bytes calldata encodedBid,
    bytes calldata bidSignature
  ) external payable override nonReentrant returns (TransactionData memory) {
    require(invariantData.user != address(0), "prepare: USER_EMPTY");
    require(invariantData.router != address(0), "prepare: ROUTER_EMPTY");
    require(invariantData.receivingAddress != address(0), "prepare: RECEIVING_ADDRESS_EMPTY");
    require(invariantData.sendingChainId != invariantData.receivingChainId, "prepare: SAME_CHAINIDS");
    require(invariantData.sendingChainId == chainId || invariantData.receivingChainId == chainId, "prepare: INVALID_CHAINIDS");
    require((expiry - block.timestamp) >= MIN_TIMEOUT, "prepare: TIMEOUT_TOO_LOW");
    bytes32 digest = keccak256(abi.encode(invariantData));
    require(variantTransactionData[digest] == bytes32(0), "prepare: DIGEST_EXISTS");
    variantTransactionData[digest] = keccak256(abi.encode(VariantTransactionData({
      amount: amount,
      expiry: expiry,
      preparedBlockNumber: block.number
    })));
    activeTransactionBlocks[invariantData.user].push(block.number);
    if (invariantData.sendingChainId == chainId) {
      require(amount > 0, "prepare: AMOUNT_IS_ZERO");
      if (LibAsset.isEther(invariantData.sendingAssetId)) {
        require(msg.value == amount, "prepare: VALUE_MISMATCH");
      } else {
        require(msg.value == 0, "prepare: ETH_WITH_ERC_TRANSFER");
        require(
          LibERC20.transferFrom(invariantData.sendingAssetId, msg.sender, address(this), amount),
          "prepare: ERC20_TRANSFER_FAILED"
        );
      }
    } else {
      require(msg.sender == invariantData.router, "prepare: ROUTER_MISMATCH");
      require(msg.value == 0, "prepare: ETH_WITH_ROUTER_PREPARE");
      require(
        routerBalances[invariantData.router][invariantData.receivingAssetId] >= amount,
        "prepare: INSUFFICIENT_LIQUIDITY"
      );
      routerBalances[invariantData.router][invariantData.receivingAssetId] -= amount;
    }
    TransactionData memory txData = TransactionData({
      user: invariantData.user,
      router: invariantData.router,
      sendingAssetId: invariantData.sendingAssetId,
      receivingAssetId: invariantData.receivingAssetId,
      sendingChainFallback: invariantData.sendingChainFallback,
      callTo: invariantData.callTo,
      receivingAddress: invariantData.receivingAddress,
      callDataHash: invariantData.callDataHash,
      transactionId: invariantData.transactionId,
      sendingChainId: invariantData.sendingChainId,
      receivingChainId: invariantData.receivingChainId,
      amount: amount,
      expiry: expiry,
      preparedBlockNumber: block.number
    });
    emit TransactionPrepared(txData.user, txData.router, txData.transactionId, txData, msg.sender, encryptedCallData, encodedBid, bidSignature);
    return txData;
  }
  function fulfill(
    TransactionData calldata txData,
    uint256 relayerFee,
    bytes calldata signature, 
    bytes calldata callData
  ) external override nonReentrant returns (TransactionData memory) {
    bytes32 digest = hashInvariantTransactionData(txData);
    require(variantTransactionData[digest] == hashVariantTransactionData(txData), "fulfill: INVALID_VARIANT_DATA");
    require(txData.expiry > block.timestamp, "fulfill: EXPIRED");
    require(txData.preparedBlockNumber > 0, "fulfill: ALREADY_COMPLETED");
    require(recoverFulfillSignature(txData, relayerFee, signature) == txData.user, "fulfill: INVALID_SIGNATURE");
    require(relayerFee <= txData.amount, "fulfill: INVALID_RELAYER_FEE");
    require(keccak256(callData) == txData.callDataHash, "fulfill: INVALID_CALL_DATA");
    variantTransactionData[digest] = keccak256(abi.encode(VariantTransactionData({
      amount: txData.amount,
      expiry: txData.expiry,
      preparedBlockNumber: 0
    })));
    removeUserActiveBlocks(txData.user, txData.preparedBlockNumber);
    if (txData.sendingChainId == chainId) {
      require(msg.sender == txData.router, "fulfill: ROUTER_MISMATCH");
      routerBalances[txData.router][txData.sendingAssetId] += txData.amount;
    } else {
      uint256 toSend = txData.amount - relayerFee;
      if (relayerFee > 0) {
        require(
          LibAsset.transferAsset(txData.receivingAssetId, payable(msg.sender), relayerFee),
          "fulfill: FEE_TRANSFER_FAILED"
        );
      }
      if (txData.callTo == address(0)) {
        require(
          LibAsset.transferAsset(txData.receivingAssetId, payable(txData.receivingAddress), toSend),
          "fulfill: TRANSFER_FAILED"
        );
      } else {
        if (!LibAsset.isEther(txData.receivingAssetId) && toSend > 0) {
          require(LibERC20.approve(txData.receivingAssetId, txData.callTo, toSend), "fulfill: APPROVAL_FAILED");
        }
        if (toSend > 0) {
          try
            IFulfillHelper(txData.callTo).addFunds{ value: LibAsset.isEther(txData.receivingAssetId) ? toSend : 0}(
              txData.user,
              txData.transactionId,
              txData.receivingAssetId,
              toSend
            )
          {} catch {
            require(
              LibAsset.transferAsset(txData.receivingAssetId, payable(txData.receivingAddress), toSend),
              "fulfill: TRANSFER_FAILED"
            );
          }
        }
        try
          IFulfillHelper(txData.callTo).execute(
            txData.user,
            txData.transactionId,
            txData.receivingAssetId,
            toSend,
            callData
          )
        {} catch {
          require(
            LibAsset.transferAsset(txData.receivingAssetId, payable(txData.receivingAddress), toSend),
            "fulfill: TRANSFER_FAILED"
          );
        }
      }
    }
    emit TransactionFulfilled(txData.user, txData.router, txData.transactionId, txData, relayerFee, signature, callData, msg.sender);
    return txData;
  }
  function cancel(TransactionData calldata txData, uint256 relayerFee, bytes calldata signature)
    external
    override
    nonReentrant
    returns (TransactionData memory)
  {
    bytes32 digest = hashInvariantTransactionData(txData);
    require(variantTransactionData[digest] == hashVariantTransactionData(txData), "cancel: INVALID_VARIANT_DATA");
    require(txData.preparedBlockNumber > 0, "cancel: ALREADY_COMPLETED");
    require(relayerFee <= txData.amount, "cancel: INVALID_RELAYER_FEE");
    variantTransactionData[digest] = keccak256(abi.encode(VariantTransactionData({
      amount: txData.amount,
      expiry: txData.expiry,
      preparedBlockNumber: 0
    })));
    removeUserActiveBlocks(txData.user, txData.preparedBlockNumber);
    if (txData.sendingChainId == chainId) {
      if (txData.expiry >= block.timestamp) {
        require(msg.sender == txData.router, "cancel: ROUTER_MUST_CANCEL");
        require(
          LibAsset.transferAsset(txData.sendingAssetId, payable(txData.sendingChainFallback), txData.amount),
          "cancel: TRANSFER_FAILED"
        );
      } else {
        if (relayerFee > 0) {
          require(recoverCancelSignature(txData, relayerFee, signature) == txData.user, "cancel: INVALID_SIGNATURE");
          require(
            LibAsset.transferAsset(txData.receivingAssetId, payable(msg.sender), relayerFee),
            "cancel: FEE_TRANSFER_FAILED"
          );
        }
        uint256 toRefund = txData.amount - relayerFee;
        if (toRefund > 0) {
          require(
            LibAsset.transferAsset(txData.sendingAssetId, payable(txData.sendingChainFallback), toRefund),
            "cancel: TRANSFER_FAILED"
          );
        }
      }
    } else {
      if (txData.expiry >= block.timestamp) {
        require(recoverCancelSignature(txData, relayerFee, signature) == txData.user, "cancel: INVALID_SIGNATURE");
      }
      routerBalances[txData.router][txData.receivingAssetId] += txData.amount;
    }
    emit TransactionCancelled(txData.user, txData.router, txData.transactionId, txData, relayerFee, msg.sender);
    return txData;
  }
  function getActiveTransactionBlocks(address user) external override view returns (uint256[] memory) {
    return activeTransactionBlocks[user];
  }
  function removeUserActiveBlocks(address user, uint256 preparedBlock) internal {
    uint256 newLength = activeTransactionBlocks[user].length - 1;
    uint256[] memory updated = new uint256[](newLength);
    bool removed = false;
    uint256 updatedIdx = 0;
    for (uint256 i; i < newLength + 1; i++) {
      if (!removed && activeTransactionBlocks[user][i] == preparedBlock) {
        removed = true;
        continue;
      }
      updated[updatedIdx] = activeTransactionBlocks[user][i];
      updatedIdx++;
    }
    activeTransactionBlocks[user] = updated;
  }
  function recoverFulfillSignature(
    TransactionData calldata txData,
    uint256 relayerFee,
    bytes calldata signature
  ) internal pure returns (address) {
    SignedFulfillData memory payload = SignedFulfillData({transactionId: txData.transactionId, relayerFee: relayerFee});
    return ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(abi.encode(payload))), signature);
  }
  function recoverCancelSignature(TransactionData calldata txData, uint256 relayerFee, bytes calldata signature)
    internal
    pure
    returns (address)
  {
    SignedCancelData memory payload = SignedCancelData({transactionId: txData.transactionId, cancel: "cancel", relayerFee: relayerFee});
    return ECDSA.recover(ECDSA.toEthSignedMessageHash(keccak256(abi.encode(payload))), signature);
  }
  function hashInvariantTransactionData(TransactionData calldata txData) internal pure returns (bytes32) {
    InvariantTransactionData memory invariant = InvariantTransactionData({
      user: txData.user,
      router: txData.router,
      sendingAssetId: txData.sendingAssetId,
      receivingAssetId: txData.receivingAssetId,
      sendingChainFallback: txData.sendingChainFallback,
      callTo: txData.callTo,
      receivingAddress: txData.receivingAddress,
      sendingChainId: txData.sendingChainId,
      receivingChainId: txData.receivingChainId,
      callDataHash: txData.callDataHash,
      transactionId: txData.transactionId
    });
    return keccak256(abi.encode(invariant));
  }
  function hashVariantTransactionData(TransactionData calldata txData) internal pure returns (bytes32) {
    return keccak256(abi.encode(VariantTransactionData({
      amount: txData.amount,
      expiry: txData.expiry,
      preparedBlockNumber: txData.preparedBlockNumber
    })));
  }
}