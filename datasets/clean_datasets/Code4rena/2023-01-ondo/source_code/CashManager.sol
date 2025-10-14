pragma solidity ^0.8.16;
interface IAccessControl {
  event RoleAdminChanged(
    bytes32 indexed role,
    bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole
  );
  event RoleGranted(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );
  event RoleRevoked(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );
  function hasRole(bytes32 role, address account) external view returns (bool);
  function getRoleAdmin(bytes32 role) external view returns (bytes32);
  function grantRole(bytes32 role, address account) external;
  function revokeRole(bytes32 role, address account) external;
  function renounceRole(bytes32 role, address account) external;
}
abstract contract ReentrancyGuard {
  uint256 private constant _NOT_ENTERED = 1;
  uint256 private constant _ENTERED = 2;
  uint256 private _status;
  constructor() {
    _status = _NOT_ENTERED;
  }
  modifier nonReentrant() {
    require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
    _status = _ENTERED;
    _;
    _status = _NOT_ENTERED;
  }
}
interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
library Address {
  function isContract(address account) internal view returns (bool) {
    return account.code.length > 0;
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");
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
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(target, data, "Address: low-level static call failed");
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
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
}
library EnumerableSet {
  struct Set {
    bytes32[] _values;
    mapping(bytes32 => uint256) _indexes;
  }
  function _add(Set storage set, bytes32 value) private returns (bool) {
    if (!_contains(set, value)) {
      set._values.push(value);
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }
  function _remove(Set storage set, bytes32 value) private returns (bool) {
    uint256 valueIndex = set._indexes[value];
    if (valueIndex != 0) {
      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;
      if (lastIndex != toDeleteIndex) {
        bytes32 lastvalue = set._values[lastIndex];
        set._values[toDeleteIndex] = lastvalue;
        set._indexes[lastvalue] = valueIndex; 
      }
      set._values.pop();
      delete set._indexes[value];
      return true;
    } else {
      return false;
    }
  }
  function _contains(Set storage set, bytes32 value)
    private
    view
    returns (bool)
  {
    return set._indexes[value] != 0;
  }
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    return set._values[index];
  }
  function _values(Set storage set) private view returns (bytes32[] memory) {
    return set._values;
  }
  struct Bytes32Set {
    Set _inner;
  }
  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _add(set._inner, value);
  }
  function remove(Bytes32Set storage set, bytes32 value)
    internal
    returns (bool)
  {
    return _remove(set._inner, value);
  }
  function contains(Bytes32Set storage set, bytes32 value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, value);
  }
  function length(Bytes32Set storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(Bytes32Set storage set, uint256 index)
    internal
    view
    returns (bytes32)
  {
    return _at(set._inner, index);
  }
  function values(Bytes32Set storage set)
    internal
    view
    returns (bytes32[] memory)
  {
    return _values(set._inner);
  }
  struct AddressSet {
    Set _inner;
  }
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(uint160(value))));
  }
  function remove(AddressSet storage set, address value)
    internal
    returns (bool)
  {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }
  function contains(AddressSet storage set, address value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, bytes32(uint256(uint160(value))));
  }
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(AddressSet storage set, uint256 index)
    internal
    view
    returns (address)
  {
    return address(uint160(uint256(_at(set._inner, index))));
  }
  function values(AddressSet storage set)
    internal
    view
    returns (address[] memory)
  {
    bytes32[] memory store = _values(set._inner);
    address[] memory result;
    assembly {
      result := store
    }
    return result;
  }
  struct UintSet {
    Set _inner;
  }
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }
  function contains(UintSet storage set, uint256 value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, bytes32(value));
  }
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(UintSet storage set, uint256 index)
    internal
    view
    returns (uint256)
  {
    return uint256(_at(set._inner, index));
  }
  function values(UintSet storage set)
    internal
    view
    returns (uint256[] memory)
  {
    bytes32[] memory store = _values(set._inner);
    uint256[] memory result;
    assembly {
      result := store
    }
    return result;
  }
}
interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
library Strings {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
  function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }
  function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
  {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }
}
interface IAccessControlUpgradeable {
  event RoleAdminChanged(
    bytes32 indexed role,
    bytes32 indexed previousAdminRole,
    bytes32 indexed newAdminRole
  );
  event RoleGranted(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );
  event RoleRevoked(
    bytes32 indexed role,
    address indexed account,
    address indexed sender
  );
  function hasRole(bytes32 role, address account) external view returns (bool);
  function getRoleAdmin(bytes32 role) external view returns (bytes32);
  function grantRole(bytes32 role, address account) external;
  function revokeRole(bytes32 role, address account) external;
  function renounceRole(bytes32 role, address account) external;
}
interface IERC20Upgradeable {
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  function totalSupply() external view returns (uint256);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address to, uint256 amount) external returns (bool);
  function allowance(address owner, address spender)
    external
    view
    returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) external returns (bool);
}
library AddressUpgradeable {
  function isContract(address account) internal view returns (bool) {
    return account.code.length > 0;
  }
  function sendValue(address payable recipient, uint256 amount) internal {
    require(address(this).balance >= amount, "Address: insufficient balance");
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
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return verifyCallResult(success, returndata, errorMessage);
  }
  function functionStaticCall(address target, bytes memory data)
    internal
    view
    returns (bytes memory)
  {
    return
      functionStaticCall(target, data, "Address: low-level static call failed");
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
library EnumerableSetUpgradeable {
  struct Set {
    bytes32[] _values;
    mapping(bytes32 => uint256) _indexes;
  }
  function _add(Set storage set, bytes32 value) private returns (bool) {
    if (!_contains(set, value)) {
      set._values.push(value);
      set._indexes[value] = set._values.length;
      return true;
    } else {
      return false;
    }
  }
  function _remove(Set storage set, bytes32 value) private returns (bool) {
    uint256 valueIndex = set._indexes[value];
    if (valueIndex != 0) {
      uint256 toDeleteIndex = valueIndex - 1;
      uint256 lastIndex = set._values.length - 1;
      if (lastIndex != toDeleteIndex) {
        bytes32 lastValue = set._values[lastIndex];
        set._values[toDeleteIndex] = lastValue;
        set._indexes[lastValue] = valueIndex; 
      }
      set._values.pop();
      delete set._indexes[value];
      return true;
    } else {
      return false;
    }
  }
  function _contains(Set storage set, bytes32 value)
    private
    view
    returns (bool)
  {
    return set._indexes[value] != 0;
  }
  function _length(Set storage set) private view returns (uint256) {
    return set._values.length;
  }
  function _at(Set storage set, uint256 index) private view returns (bytes32) {
    return set._values[index];
  }
  function _values(Set storage set) private view returns (bytes32[] memory) {
    return set._values;
  }
  struct Bytes32Set {
    Set _inner;
  }
  function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
    return _add(set._inner, value);
  }
  function remove(Bytes32Set storage set, bytes32 value)
    internal
    returns (bool)
  {
    return _remove(set._inner, value);
  }
  function contains(Bytes32Set storage set, bytes32 value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, value);
  }
  function length(Bytes32Set storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(Bytes32Set storage set, uint256 index)
    internal
    view
    returns (bytes32)
  {
    return _at(set._inner, index);
  }
  function values(Bytes32Set storage set)
    internal
    view
    returns (bytes32[] memory)
  {
    return _values(set._inner);
  }
  struct AddressSet {
    Set _inner;
  }
  function add(AddressSet storage set, address value) internal returns (bool) {
    return _add(set._inner, bytes32(uint256(uint160(value))));
  }
  function remove(AddressSet storage set, address value)
    internal
    returns (bool)
  {
    return _remove(set._inner, bytes32(uint256(uint160(value))));
  }
  function contains(AddressSet storage set, address value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, bytes32(uint256(uint160(value))));
  }
  function length(AddressSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(AddressSet storage set, uint256 index)
    internal
    view
    returns (address)
  {
    return address(uint160(uint256(_at(set._inner, index))));
  }
  function values(AddressSet storage set)
    internal
    view
    returns (address[] memory)
  {
    bytes32[] memory store = _values(set._inner);
    address[] memory result;
    assembly {
      result := store
    }
    return result;
  }
  struct UintSet {
    Set _inner;
  }
  function add(UintSet storage set, uint256 value) internal returns (bool) {
    return _add(set._inner, bytes32(value));
  }
  function remove(UintSet storage set, uint256 value) internal returns (bool) {
    return _remove(set._inner, bytes32(value));
  }
  function contains(UintSet storage set, uint256 value)
    internal
    view
    returns (bool)
  {
    return _contains(set._inner, bytes32(value));
  }
  function length(UintSet storage set) internal view returns (uint256) {
    return _length(set._inner);
  }
  function at(UintSet storage set, uint256 index)
    internal
    view
    returns (uint256)
  {
    return uint256(_at(set._inner, index));
  }
  function values(UintSet storage set)
    internal
    view
    returns (uint256[] memory)
  {
    bytes32[] memory store = _values(set._inner);
    uint256[] memory result;
    assembly {
      result := store
    }
    return result;
  }
}
interface IERC165Upgradeable {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
library StringsUpgradeable {
  bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
  uint8 private constant _ADDRESS_LENGTH = 20;
  function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }
  function toHexString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0x00";
    }
    uint256 temp = value;
    uint256 length = 0;
    while (temp != 0) {
      length++;
      temp >>= 8;
    }
    return toHexString(value, length);
  }
  function toHexString(uint256 value, uint256 length)
    internal
    pure
    returns (string memory)
  {
    bytes memory buffer = new bytes(2 * length + 2);
    buffer[0] = "0";
    buffer[1] = "x";
    for (uint256 i = 2 * length + 1; i > 1; --i) {
      buffer[i] = _HEX_SYMBOLS[value & 0xf];
      value >>= 4;
    }
    require(value == 0, "Strings: hex length insufficient");
    return string(buffer);
  }
  function toHexString(address addr) internal pure returns (string memory) {
    return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
  }
}
interface ICashManager {
  function requestMint(uint256 collateralIn) external;
  function claimMint(address user, uint256 epochToClaim) external;
  function overrideExchangeRate(
    uint256 correctExchangeRate,
    uint256 epochToSet,
    uint256 _lastSetMintExchangeRate
  ) external;
  function setAssetRecipient(address _assetRecipient) external;
  function setFeeRecipient(address _feeRecipient) external;
  function setAssetSender(address newAssetSender) external;
  function setMinimumDepositAmount(uint256 _minimumDepositAmount) external;
  function setMintFee(uint256 _mintFee) external;
  function setMintExchangeRate(
    uint256 _mintExchangeRate,
    uint256 epochToSet
  ) external;
  function setMintExchangeRateDeltaLimit(
    uint256 _exchangeRateDeltaLimit
  ) external;
  function requestRedemption(uint256 amountSharesTokenToRedeem) external;
  function completeRedemptions(
    address[] calldata redeemers,
    address[] calldata refundees,
    uint256 collateralAmountToDist,
    uint256 epochToService,
    uint256 fees
  ) external;
  event FeeRecipientSet(address oldFeeRecipient, address newFeeRecipient);
  event AssetRecipientSet(address oldAssetRecipient, address newAssetRecipient);
  event AssetSenderSet(address oldAssetSender, address newAssetSender);
  event MinimumDepositAmountSet(uint256 oldMinimum, uint256 newMinimum);
  event MinimumRedeemAmountSet(uint256 oldRedeemMin, uint256 newRedeemMin);
  event MintFeeSet(uint256 oldFee, uint256 newFee);
  event MintExchangeRateSet(
    uint256 indexed epoch,
    uint256 oldRate,
    uint256 newRate
  );
  event MintExchangeRateOverridden(
    uint256 indexed epoch,
    uint256 oldRate,
    uint256 newRate,
    uint256 lastSetMintExchangeRate
  );
  event ExchangeRateDeltaLimitSet(uint256 oldLimit, uint256 newLimit);
  event MintExchangeRateCheckFailed(
    uint256 indexed epoch,
    uint256 lastEpochRate,
    uint256 newRate
  );
  event MintLimitSet(uint256 oldLimit, uint256 newLimit);
  event RedeemLimitSet(uint256 oldLimit, uint256 newLimit);
  event EpochDurationSet(uint256 oldDuration, uint256 newDuration);
  event RedemptionRequested(
    address indexed user,
    uint256 cashAmountIn,
    uint256 indexed epoch
  );
  event MintRequested(
    address indexed user,
    uint256 indexed epoch,
    uint256 collateralAmountDeposited,
    uint256 depositAmountAfterFee,
    uint256 feeAmount
  );
  event RedemptionCompleted(
    address indexed user,
    uint256 cashAmountRequested,
    uint256 collateralAmountReturned,
    uint256 indexed epoch
  );
  event MintCompleted(
    address indexed user,
    uint256 cashAmountOut,
    uint256 collateralAmountDeposited,
    uint256 exchangeRate,
    uint256 indexed epochClaimedFrom
  );
  event RedemptionFeesCollected(
    address indexed beneficiary,
    uint256 collateralAmountOut,
    uint256 indexed epoch
  );
  event RefundIssued(
    address indexed user,
    uint256 cashAmountOut,
    uint256 indexed epoch
  );
  event PendingMintBalanceSet(
    address indexed user,
    uint256 indexed epoch,
    uint256 oldBalance,
    uint256 newBalance
  );
  event PendingRedemptionBalanceSet(
    address indexed user,
    uint256 indexed epoch,
    uint256 balance,
    uint256 totalBurned
  );
  error CollateralZeroAddress();
  error CashZeroAddress();
  error AssetRecipientZeroAddress();
  error AssetSenderZeroAddress();
  error FeeRecipientZeroAddress();
  error MinimumDepositAmountTooSmall();
  error ZeroExchangeRate();
  error KYCCheckFailed();
  error MintRequestAmountTooSmall();
  error NoCashToClaim();
  error ExchangeRateNotSet();
  error EpochNotElapsed();
  error EpochExchangeRateAlreadySet();
  error UnexpectedMintBalance();
  error MintFeeTooLarge();
  error MintExceedsRateLimit();
  error RedeemAmountCannotBeZero();
  error RedeemExceedsRateLimit();
  error WithdrawRequestAmountTooSmall();
  error CollateralRedemptionTooSmall();
  error MustServicePastEpoch();
  error CannotServiceFutureEpoch();
}
interface IKYCRegistry {
  function getKYCStatus(
    uint256 kycRequirementGroup,
    address account
  ) external view returns (bool);
}
interface IMulticall {
  struct ExCallData {
    address target;
    bytes data;
    uint256 value;
  }
  function multiexcall(
    ExCallData[] calldata exdata
  ) external payable returns (bytes[] memory results);
}
interface IAccessControlEnumerable is IAccessControl {
  function getRoleMember(bytes32 role, uint256 index)
    external
    view
    returns (address);
  function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
abstract contract Pausable is Context {
  event Paused(address account);
  event Unpaused(address account);
  bool private _paused;
  constructor() {
    _paused = false;
  }
  function paused() public view virtual returns (bool) {
    return _paused;
  }
  modifier whenNotPaused() {
    require(!paused(), "Pausable: paused");
    _;
  }
  modifier whenPaused() {
    require(paused(), "Pausable: not paused");
    _;
  }
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
}
interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}
abstract contract ERC165 is IERC165 {
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return interfaceId == type(IERC165).interfaceId;
  }
}
interface IAccessControlEnumerableUpgradeable is IAccessControlUpgradeable {
  function getRoleMember(bytes32 role, uint256 index)
    external
    view
    returns (address);
  function getRoleMemberCount(bytes32 role) external view returns (uint256);
}
abstract contract Initializable {
  uint8 private _initialized;
  bool private _initializing;
  event Initialized(uint8 version);
  modifier initializer() {
    bool isTopLevelCall = !_initializing;
    require(
      (isTopLevelCall && _initialized < 1) ||
        (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
      "Initializable: contract is already initialized"
    );
    _initialized = 1;
    if (isTopLevelCall) {
      _initializing = true;
    }
    _;
    if (isTopLevelCall) {
      _initializing = false;
      emit Initialized(1);
    }
  }
  modifier reinitializer(uint8 version) {
    require(
      !_initializing && _initialized < version,
      "Initializable: contract is already initialized"
    );
    _initialized = version;
    _initializing = true;
    _;
    _initializing = false;
    emit Initialized(version);
  }
  modifier onlyInitializing() {
    require(_initializing, "Initializable: contract is not initializing");
    _;
  }
  function _disableInitializers() internal virtual {
    require(!_initializing, "Initializable: contract is initializing");
    if (_initialized < type(uint8).max) {
      _initialized = type(uint8).max;
      emit Initialized(type(uint8).max);
    }
  }
}
interface IERC20MetadataUpgradeable is IERC20Upgradeable {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}
interface IKYCRegistryClient {
  function kycRequirementGroup() external view returns (uint256);
  function kycRegistry() external view returns (IKYCRegistry);
  function setKYCRequirementGroup(uint256 group) external;
  function setKYCRegistry(address registry) external;
  error RegistryZeroAddress();
  event KYCRegistrySet(address oldRegistry, address newRegistry);
  event KYCRequirementGroupSet(
    uint256 oldRequirementGroup,
    uint256 newRequirementGroup
  );
}
library SafeERC20 {
  using Address for address;
  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transfer.selector, to, value)
    );
  }
  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  ) internal {
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
    );
  }
  function safeApprove(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    require(
      (value == 0) || (token.allowance(address(this), spender) == 0),
      "SafeERC20: approve from non-zero to non-zero allowance"
    );
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, value)
    );
  }
  function safeIncreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    uint256 newAllowance = token.allowance(address(this), spender) + value;
    _callOptionalReturn(
      token,
      abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
    );
  }
  function safeDecreaseAllowance(
    IERC20 token,
    address spender,
    uint256 value
  ) internal {
    unchecked {
      uint256 oldAllowance = token.allowance(address(this), spender);
      require(
        oldAllowance >= value,
        "SafeERC20: decreased allowance below zero"
      );
      uint256 newAllowance = oldAllowance - value;
      _callOptionalReturn(
        token,
        abi.encodeWithSelector(token.approve.selector, spender, newAllowance)
      );
    }
  }
  function _callOptionalReturn(IERC20 token, bytes memory data) private {
    bytes memory returndata =
      address(token).functionCall(data, "SafeERC20: low-level call failed");
    if (returndata.length > 0) {
      require(
        abi.decode(returndata, (bool)),
        "SafeERC20: ERC20 operation did not succeed"
      );
    }
  }
}
abstract contract ContextUpgradeable is Initializable {
  function __Context_init() internal onlyInitializing {}
  function __Context_init_unchained() internal onlyInitializing {}
  function _msgSender() internal view virtual returns (address) {
    return msg.sender;
  }
  function _msgData() internal view virtual returns (bytes calldata) {
    return msg.data;
  }
  uint256[50] private __gap;
}
abstract contract KYCRegistryClient is IKYCRegistryClient {
  IKYCRegistry public override kycRegistry;
  uint256 public override kycRequirementGroup;
  function _setKYCRegistry(address _kycRegistry) internal {
    if (_kycRegistry == address(0)) {
      revert RegistryZeroAddress();
    }
    address oldKYCRegistry = address(kycRegistry);
    kycRegistry = IKYCRegistry(_kycRegistry);
    emit KYCRegistrySet(oldKYCRegistry, _kycRegistry);
  }
  function _setKYCRequirementGroup(uint256 _kycRequirementGroup) internal {
    uint256 oldKYCLevel = kycRequirementGroup;
    kycRequirementGroup = _kycRequirementGroup;
    emit KYCRequirementGroupSet(oldKYCLevel, _kycRequirementGroup);
  }
  function _getKYCStatus(address account) internal view returns (bool) {
    return kycRegistry.getKYCStatus(kycRequirementGroup, account);
  }
}
abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
  event Paused(address account);
  event Unpaused(address account);
  bool private _paused;
  function __Pausable_init() internal onlyInitializing {
    __Pausable_init_unchained();
  }
  function __Pausable_init_unchained() internal onlyInitializing {
    _paused = false;
  }
  modifier whenNotPaused() {
    _requireNotPaused();
    _;
  }
  modifier whenPaused() {
    _requirePaused();
    _;
  }
  function paused() public view virtual returns (bool) {
    return _paused;
  }
  function _requireNotPaused() internal view virtual {
    require(!paused(), "Pausable: paused");
  }
  function _requirePaused() internal view virtual {
    require(paused(), "Pausable: not paused");
  }
  function _pause() internal virtual whenNotPaused {
    _paused = true;
    emit Paused(_msgSender());
  }
  function _unpause() internal virtual whenPaused {
    _paused = false;
    emit Unpaused(_msgSender());
  }
  uint256[49] private __gap;
}
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
  function __ERC165_init() internal onlyInitializing {}
  function __ERC165_init_unchained() internal onlyInitializing {}
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return interfaceId == type(IERC165Upgradeable).interfaceId;
  }
  uint256[50] private __gap;
}
abstract contract KYCRegistryClientConstructable is KYCRegistryClient {
  constructor(address _kycRegistry, uint256 _kycRequirementGroup) {
    _setKYCRegistry(_kycRegistry);
    _setKYCRequirementGroup(_kycRequirementGroup);
  }
}
abstract contract AccessControl is Context, IAccessControl, ERC165 {
  struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
  }
  mapping(bytes32 => RoleData) private _roles;
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
  modifier onlyRole(bytes32 role) {
    _checkRole(role, _msgSender());
    _;
  }
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControl).interfaceId ||
      super.supportsInterface(interfaceId);
  }
  function hasRole(bytes32 role, address account)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _roles[role].members[account];
  }
  function _checkRole(bytes32 role, address account) internal view virtual {
    if (!hasRole(role, account)) {
      revert(
        string(
          abi.encodePacked(
            "AccessControl: account ",
            Strings.toHexString(uint160(account), 20),
            " is missing role ",
            Strings.toHexString(uint256(role), 32)
          )
        )
      );
    }
  }
  function getRoleAdmin(bytes32 role)
    public
    view
    virtual
    override
    returns (bytes32)
  {
    return _roles[role].adminRole;
  }
  function grantRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    _grantRole(role, account);
  }
  function revokeRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    _revokeRole(role, account);
  }
  function renounceRole(bytes32 role, address account) public virtual override {
    require(
      account == _msgSender(),
      "AccessControl: can only renounce roles for self"
    );
    _revokeRole(role, account);
  }
  function _setupRole(bytes32 role, address account) internal virtual {
    _grantRole(role, account);
  }
  function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
    bytes32 previousAdminRole = getRoleAdmin(role);
    _roles[role].adminRole = adminRole;
    emit RoleAdminChanged(role, previousAdminRole, adminRole);
  }
  function _grantRole(bytes32 role, address account) internal virtual {
    if (!hasRole(role, account)) {
      _roles[role].members[account] = true;
      emit RoleGranted(role, account, _msgSender());
    }
  }
  function _revokeRole(bytes32 role, address account) internal virtual {
    if (hasRole(role, account)) {
      _roles[role].members[account] = false;
      emit RoleRevoked(role, account, _msgSender());
    }
  }
}
contract ERC20Upgradeable is
  Initializable,
  ContextUpgradeable,
  IERC20Upgradeable,
  IERC20MetadataUpgradeable
{
  mapping(address => uint256) private _balances;
  mapping(address => mapping(address => uint256)) private _allowances;
  uint256 private _totalSupply;
  string private _name;
  string private _symbol;
  function __ERC20_init(string memory name_, string memory symbol_)
    internal
    onlyInitializing
  {
    __ERC20_init_unchained(name_, symbol_);
  }
  function __ERC20_init_unchained(string memory name_, string memory symbol_)
    internal
    onlyInitializing
  {
    _name = name_;
    _symbol = symbol_;
  }
  function name() public view virtual override returns (string memory) {
    return _name;
  }
  function symbol() public view virtual override returns (string memory) {
    return _symbol;
  }
  function decimals() public view virtual override returns (uint8) {
    return 18;
  }
  function totalSupply() public view virtual override returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _balances[account];
  }
  function transfer(address to, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    address owner = _msgSender();
    _transfer(owner, to, amount);
    return true;
  }
  function allowance(address owner, address spender)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _allowances[owner][spender];
  }
  function approve(address spender, uint256 amount)
    public
    virtual
    override
    returns (bool)
  {
    address owner = _msgSender();
    _approve(owner, spender, amount);
    return true;
  }
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual override returns (bool) {
    address spender = _msgSender();
    _spendAllowance(from, spender, amount);
    _transfer(from, to, amount);
    return true;
  }
  function increaseAllowance(address spender, uint256 addedValue)
    public
    virtual
    returns (bool)
  {
    address owner = _msgSender();
    _approve(owner, spender, allowance(owner, spender) + addedValue);
    return true;
  }
  function decreaseAllowance(address spender, uint256 subtractedValue)
    public
    virtual
    returns (bool)
  {
    address owner = _msgSender();
    uint256 currentAllowance = allowance(owner, spender);
    require(
      currentAllowance >= subtractedValue,
      "ERC20: decreased allowance below zero"
    );
    unchecked {
      _approve(owner, spender, currentAllowance - subtractedValue);
    }
    return true;
  }
  function _transfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {
    require(from != address(0), "ERC20: transfer from the zero address");
    require(to != address(0), "ERC20: transfer to the zero address");
    _beforeTokenTransfer(from, to, amount);
    uint256 fromBalance = _balances[from];
    require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
    unchecked {
      _balances[from] = fromBalance - amount;
    }
    _balances[to] += amount;
    emit Transfer(from, to, amount);
    _afterTokenTransfer(from, to, amount);
  }
  function _mint(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: mint to the zero address");
    _beforeTokenTransfer(address(0), account, amount);
    _totalSupply += amount;
    _balances[account] += amount;
    emit Transfer(address(0), account, amount);
    _afterTokenTransfer(address(0), account, amount);
  }
  function _burn(address account, uint256 amount) internal virtual {
    require(account != address(0), "ERC20: burn from the zero address");
    _beforeTokenTransfer(account, address(0), amount);
    uint256 accountBalance = _balances[account];
    require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
    unchecked {
      _balances[account] = accountBalance - amount;
    }
    _totalSupply -= amount;
    emit Transfer(account, address(0), amount);
    _afterTokenTransfer(account, address(0), amount);
  }
  function _approve(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    require(owner != address(0), "ERC20: approve from the zero address");
    require(spender != address(0), "ERC20: approve to the zero address");
    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
  function _spendAllowance(
    address owner,
    address spender,
    uint256 amount
  ) internal virtual {
    uint256 currentAllowance = allowance(owner, spender);
    if (currentAllowance != type(uint256).max) {
      require(currentAllowance >= amount, "ERC20: insufficient allowance");
      unchecked {
        _approve(owner, spender, currentAllowance - amount);
      }
    }
  }
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
  function _afterTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual {}
  uint256[45] private __gap;
}
abstract contract ERC20BurnableUpgradeable is
  Initializable,
  ContextUpgradeable,
  ERC20Upgradeable
{
  function __ERC20Burnable_init() internal onlyInitializing {}
  function __ERC20Burnable_init_unchained() internal onlyInitializing {}
  function burn(uint256 amount) public virtual {
    _burn(_msgSender(), amount);
  }
  function burnFrom(address account, uint256 amount) public virtual {
    _spendAllowance(account, _msgSender(), amount);
    _burn(account, amount);
  }
  uint256[50] private __gap;
}
abstract contract AccessControlUpgradeable is
  Initializable,
  ContextUpgradeable,
  IAccessControlUpgradeable,
  ERC165Upgradeable
{
  function __AccessControl_init() internal onlyInitializing {}
  function __AccessControl_init_unchained() internal onlyInitializing {}
  struct RoleData {
    mapping(address => bool) members;
    bytes32 adminRole;
  }
  mapping(bytes32 => RoleData) private _roles;
  bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
  modifier onlyRole(bytes32 role) {
    _checkRole(role);
    _;
  }
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControlUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
  }
  function hasRole(bytes32 role, address account)
    public
    view
    virtual
    override
    returns (bool)
  {
    return _roles[role].members[account];
  }
  function _checkRole(bytes32 role) internal view virtual {
    _checkRole(role, _msgSender());
  }
  function _checkRole(bytes32 role, address account) internal view virtual {
    if (!hasRole(role, account)) {
      revert(
        string(
          abi.encodePacked(
            "AccessControl: account ",
            StringsUpgradeable.toHexString(uint160(account), 20),
            " is missing role ",
            StringsUpgradeable.toHexString(uint256(role), 32)
          )
        )
      );
    }
  }
  function getRoleAdmin(bytes32 role)
    public
    view
    virtual
    override
    returns (bytes32)
  {
    return _roles[role].adminRole;
  }
  function grantRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    _grantRole(role, account);
  }
  function revokeRole(bytes32 role, address account)
    public
    virtual
    override
    onlyRole(getRoleAdmin(role))
  {
    _revokeRole(role, account);
  }
  function renounceRole(bytes32 role, address account) public virtual override {
    require(
      account == _msgSender(),
      "AccessControl: can only renounce roles for self"
    );
    _revokeRole(role, account);
  }
  function _setupRole(bytes32 role, address account) internal virtual {
    _grantRole(role, account);
  }
  function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
    bytes32 previousAdminRole = getRoleAdmin(role);
    _roles[role].adminRole = adminRole;
    emit RoleAdminChanged(role, previousAdminRole, adminRole);
  }
  function _grantRole(bytes32 role, address account) internal virtual {
    if (!hasRole(role, account)) {
      _roles[role].members[account] = true;
      emit RoleGranted(role, account, _msgSender());
    }
  }
  function _revokeRole(bytes32 role, address account) internal virtual {
    if (hasRole(role, account)) {
      _roles[role].members[account] = false;
      emit RoleRevoked(role, account, _msgSender());
    }
  }
  uint256[49] private __gap;
}
abstract contract ERC20PausableUpgradeable is
  Initializable,
  ERC20Upgradeable,
  PausableUpgradeable
{
  function __ERC20Pausable_init() internal onlyInitializing {
    __Pausable_init_unchained();
  }
  function __ERC20Pausable_init_unchained() internal onlyInitializing {}
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override {
    super._beforeTokenTransfer(from, to, amount);
    require(!paused(), "ERC20Pausable: token transfer while paused");
  }
  uint256[50] private __gap;
}
abstract contract AccessControlEnumerable is
  IAccessControlEnumerable,
  AccessControl
{
  using EnumerableSet for EnumerableSet.AddressSet;
  mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControlEnumerable).interfaceId ||
      super.supportsInterface(interfaceId);
  }
  function getRoleMember(bytes32 role, uint256 index)
    public
    view
    virtual
    override
    returns (address)
  {
    return _roleMembers[role].at(index);
  }
  function getRoleMemberCount(bytes32 role)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _roleMembers[role].length();
  }
  function _grantRole(bytes32 role, address account) internal virtual override {
    super._grantRole(role, account);
    _roleMembers[role].add(account);
  }
  function _revokeRole(bytes32 role, address account)
    internal
    virtual
    override
  {
    super._revokeRole(role, account);
    _roleMembers[role].remove(account);
  }
}
abstract contract AccessControlEnumerableUpgradeable is
  Initializable,
  IAccessControlEnumerableUpgradeable,
  AccessControlUpgradeable
{
  function __AccessControlEnumerable_init() internal onlyInitializing {}
  function __AccessControlEnumerable_init_unchained()
    internal
    onlyInitializing
  {}
  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.AddressSet;
  mapping(bytes32 => EnumerableSetUpgradeable.AddressSet) private _roleMembers;
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    override
    returns (bool)
  {
    return
      interfaceId == type(IAccessControlEnumerableUpgradeable).interfaceId ||
      super.supportsInterface(interfaceId);
  }
  function getRoleMember(bytes32 role, uint256 index)
    public
    view
    virtual
    override
    returns (address)
  {
    return _roleMembers[role].at(index);
  }
  function getRoleMemberCount(bytes32 role)
    public
    view
    virtual
    override
    returns (uint256)
  {
    return _roleMembers[role].length();
  }
  function _grantRole(bytes32 role, address account) internal virtual override {
    super._grantRole(role, account);
    _roleMembers[role].add(account);
  }
  function _revokeRole(bytes32 role, address account)
    internal
    virtual
    override
  {
    super._revokeRole(role, account);
    _roleMembers[role].remove(account);
  }
  uint256[49] private __gap;
}
contract ERC20PresetMinterPauserUpgradeable is
  Initializable,
  ContextUpgradeable,
  AccessControlEnumerableUpgradeable,
  ERC20BurnableUpgradeable,
  ERC20PausableUpgradeable
{
  function initialize(string memory name, string memory symbol)
    public
    virtual
    initializer
  {
    __ERC20PresetMinterPauser_init(name, symbol);
  }
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  function __ERC20PresetMinterPauser_init(
    string memory name,
    string memory symbol
  ) internal onlyInitializing {
    __ERC20_init_unchained(name, symbol);
    __Pausable_init_unchained();
    __ERC20PresetMinterPauser_init_unchained(name, symbol);
  }
  function __ERC20PresetMinterPauser_init_unchained(
    string memory,
    string memory
  ) internal onlyInitializing {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(MINTER_ROLE, _msgSender());
    _setupRole(PAUSER_ROLE, _msgSender());
  }
  function mint(address to, uint256 amount) public virtual {
    require(
      hasRole(MINTER_ROLE, _msgSender()),
      "ERC20PresetMinterPauser: must have minter role to mint"
    );
    _mint(to, amount);
  }
  function pause() public virtual {
    require(
      hasRole(PAUSER_ROLE, _msgSender()),
      "ERC20PresetMinterPauser: must have pauser role to pause"
    );
    _pause();
  }
  function unpause() public virtual {
    require(
      hasRole(PAUSER_ROLE, _msgSender()),
      "ERC20PresetMinterPauser: must have pauser role to unpause"
    );
    _unpause();
  }
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override(ERC20Upgradeable, ERC20PausableUpgradeable) {
    super._beforeTokenTransfer(from, to, amount);
  }
  uint256[50] private __gap;
}
contract Cash is ERC20PresetMinterPauserUpgradeable {
  bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");
  constructor() {
    _disableInitializers();
  }
  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    super._beforeTokenTransfer(from, to, amount);
    require(
      hasRole(TRANSFER_ROLE, _msgSender()),
      "Cash: must have TRANSFER_ROLE to transfer"
    );
  }
}
contract CashManager is
  ICashManager,
  IMulticall,
  AccessControlEnumerable,
  KYCRegistryClientConstructable,
  Pausable,
  ReentrancyGuard
{
  using SafeERC20 for IERC20;
  IERC20 public immutable collateral;
  Cash public immutable cash;
  address public assetRecipient;
  address public feeRecipient;
  address public assetSender;
  uint256 public minimumDepositAmount = 10_000;
  uint256 public minimumRedeemAmount;
  uint256 public mintFee = 0;
  uint256 public exchangeRateDeltaLimit = 100;
  struct RedemptionRequests {
    uint256 totalBurned;
    mapping(address => uint256) addressToBurnAmt;
  }
  mapping(uint256 => RedemptionRequests) public redemptionInfoPerEpoch;
  mapping(uint256 => uint256) public epochToExchangeRate;
  mapping(uint256 => mapping(address => uint256)) public mintRequestsPerEpoch;
  uint256 public constant BPS_DENOMINATOR = 10_000;
  uint256 public immutable decimalsMultiplier;
  uint256 public currentEpoch;
  uint256 public epochDuration;
  uint256 public currentEpochStartTimestamp;
  uint256 public lastSetMintExchangeRate = 1e6;
  uint256 public mintLimit;
  uint256 public currentMintAmount;
  uint256 public redeemLimit;
  uint256 public currentRedeemAmount;
  bytes32 public constant MANAGER_ADMIN = keccak256("MANAGER_ADMIN");
  bytes32 public constant PAUSER_ADMIN = keccak256("PAUSER_ADMIN");
  bytes32 public constant SETTER_ADMIN = keccak256("SETTER_ADMIN");
  constructor(
    address _collateral,
    address _cash,
    address managerAdmin,
    address pauser,
    address _assetRecipient,
    address _assetSender,
    address _feeRecipient,
    uint256 _mintLimit,
    uint256 _redeemLimit,
    uint256 _epochDuration,
    address _kycRegistry,
    uint256 _kycRequirementGroup
  ) KYCRegistryClientConstructable(_kycRegistry, _kycRequirementGroup) {
    if (_collateral == address(0)) {
      revert CollateralZeroAddress();
    }
    if (_cash == address(0)) {
      revert CashZeroAddress();
    }
    if (_assetRecipient == address(0)) {
      revert AssetRecipientZeroAddress();
    }
    if (_assetSender == address(0)) {
      revert AssetSenderZeroAddress();
    }
    if (_feeRecipient == address(0)) {
      revert FeeRecipientZeroAddress();
    }
    _grantRole(DEFAULT_ADMIN_ROLE, managerAdmin);
    _grantRole(MANAGER_ADMIN, managerAdmin);
    _setRoleAdmin(PAUSER_ADMIN, MANAGER_ADMIN);
    _setRoleAdmin(SETTER_ADMIN, MANAGER_ADMIN);
    _grantRole(PAUSER_ADMIN, pauser);
    collateral = IERC20(_collateral);
    cash = Cash(_cash);
    feeRecipient = _feeRecipient;
    assetRecipient = _assetRecipient;
    assetSender = _assetSender;
    currentEpoch = currentEpoch;
    mintLimit = _mintLimit;
    redeemLimit = _redeemLimit;
    epochDuration = _epochDuration;
    currentEpochStartTimestamp =
      block.timestamp -
      (block.timestamp % epochDuration);
    decimalsMultiplier =
      10 **
        (IERC20Metadata(_cash).decimals() -
          IERC20Metadata(_collateral).decimals());
  }
  function requestMint(
    uint256 collateralAmountIn
  )
    external
    override
    updateEpoch
    nonReentrant
    whenNotPaused
    checkKYC(msg.sender)
  {
    if (collateralAmountIn < minimumDepositAmount) {
      revert MintRequestAmountTooSmall();
    }
    uint256 feesInCollateral = _getMintFees(collateralAmountIn);
    uint256 depositValueAfterFees = collateralAmountIn - feesInCollateral;
    _checkAndUpdateMintLimit(depositValueAfterFees);
    collateral.safeTransferFrom(msg.sender, feeRecipient, feesInCollateral);
    collateral.safeTransferFrom(
      msg.sender,
      assetRecipient,
      depositValueAfterFees
    );
    mintRequestsPerEpoch[currentEpoch][msg.sender] += depositValueAfterFees;
    emit MintRequested(
      msg.sender,
      currentEpoch,
      collateralAmountIn,
      depositValueAfterFees,
      feesInCollateral
    );
  }
  function claimMint(
    address user,
    uint256 epochToClaim
  ) external override updateEpoch nonReentrant whenNotPaused checkKYC(user) {
    uint256 collateralDeposited = mintRequestsPerEpoch[epochToClaim][user];
    if (collateralDeposited == 0) {
      revert NoCashToClaim();
    }
    if (epochToExchangeRate[epochToClaim] == 0) {
      revert ExchangeRateNotSet();
    }
    uint256 cashOwed = _getMintAmountForEpoch(
      collateralDeposited,
      epochToClaim
    );
    mintRequestsPerEpoch[epochToClaim][user] = 0;
    cash.mint(user, cashOwed);
    emit MintCompleted(
      user,
      cashOwed,
      collateralDeposited,
      epochToExchangeRate[epochToClaim],
      epochToClaim
    );
  }
  function setMintExchangeRate(
    uint256 exchangeRate,
    uint256 epochToSet
  ) external override updateEpoch onlyRole(SETTER_ADMIN) {
    if (exchangeRate == 0) {
      revert ZeroExchangeRate();
    }
    if (epochToSet >= currentEpoch) {
      revert EpochNotElapsed();
    }
    if (epochToExchangeRate[epochToSet] != 0) {
      revert EpochExchangeRateAlreadySet();
    }
    uint256 rateDifference;
    if (exchangeRate > lastSetMintExchangeRate) {
      rateDifference = exchangeRate - lastSetMintExchangeRate;
    } else if (exchangeRate < lastSetMintExchangeRate) {
      rateDifference = lastSetMintExchangeRate - exchangeRate;
    }
    uint256 maxDifferenceThisEpoch = (lastSetMintExchangeRate *
      exchangeRateDeltaLimit) / BPS_DENOMINATOR;
    if (rateDifference > maxDifferenceThisEpoch) {
      epochToExchangeRate[epochToSet] = exchangeRate;
      _pause();
      emit MintExchangeRateCheckFailed(
        epochToSet,
        lastSetMintExchangeRate,
        exchangeRate
      );
    } else {
      uint256 oldExchangeRate = lastSetMintExchangeRate;
      epochToExchangeRate[epochToSet] = exchangeRate;
      lastSetMintExchangeRate = exchangeRate;
      emit MintExchangeRateSet(epochToSet, oldExchangeRate, exchangeRate);
    }
  }
  function setPendingMintBalance(
    address user,
    uint256 epoch,
    uint256 oldBalance,
    uint256 newBalance
  ) external updateEpoch onlyRole(MANAGER_ADMIN) {
    if (oldBalance != mintRequestsPerEpoch[epoch][user]) {
      revert UnexpectedMintBalance();
    }
    if (epoch > currentEpoch) {
      revert CannotServiceFutureEpoch();
    }
    mintRequestsPerEpoch[epoch][user] = newBalance;
    emit PendingMintBalanceSet(user, epoch, oldBalance, newBalance);
  }
  function overrideExchangeRate(
    uint256 correctExchangeRate,
    uint256 epochToSet,
    uint256 _lastSetMintExchangeRate
  ) external override updateEpoch onlyRole(MANAGER_ADMIN) {
    if (epochToSet >= currentEpoch) {
      revert MustServicePastEpoch();
    }
    uint256 incorrectRate = epochToExchangeRate[epochToSet];
    epochToExchangeRate[epochToSet] = correctExchangeRate;
    if (_lastSetMintExchangeRate != 0) {
      lastSetMintExchangeRate = _lastSetMintExchangeRate;
    }
    emit MintExchangeRateOverridden(
      epochToSet,
      incorrectRate,
      correctExchangeRate,
      lastSetMintExchangeRate
    );
  }
  function setMintExchangeRateDeltaLimit(
    uint256 _exchangeRateDeltaLimit
  ) external override onlyRole(MANAGER_ADMIN) {
    uint256 oldExchangeRateDeltaLimit = exchangeRateDeltaLimit;
    exchangeRateDeltaLimit = _exchangeRateDeltaLimit;
    emit ExchangeRateDeltaLimitSet(
      oldExchangeRateDeltaLimit,
      _exchangeRateDeltaLimit
    );
  }
  function setMintFee(
    uint256 _mintFee
  ) external override onlyRole(MANAGER_ADMIN) {
    if (_mintFee >= BPS_DENOMINATOR) {
      revert MintFeeTooLarge();
    }
    uint256 oldMintFee = mintFee;
    mintFee = _mintFee;
    emit MintFeeSet(oldMintFee, _mintFee);
  }
  function setMinimumDepositAmount(
    uint256 _minimumDepositAmount
  ) external override onlyRole(MANAGER_ADMIN) {
    if (_minimumDepositAmount < BPS_DENOMINATOR) {
      revert MinimumDepositAmountTooSmall();
    }
    uint256 oldMinimumDepositAmount = minimumDepositAmount;
    minimumDepositAmount = _minimumDepositAmount;
    emit MinimumDepositAmountSet(
      oldMinimumDepositAmount,
      _minimumDepositAmount
    );
  }
  function setFeeRecipient(
    address _feeRecipient
  ) external override onlyRole(MANAGER_ADMIN) {
    address oldFeeRecipient = feeRecipient;
    feeRecipient = _feeRecipient;
    emit FeeRecipientSet(oldFeeRecipient, _feeRecipient);
  }
  function setAssetRecipient(
    address _assetRecipient
  ) external override onlyRole(MANAGER_ADMIN) {
    address oldAssetRecipient = assetRecipient;
    assetRecipient = _assetRecipient;
    emit AssetRecipientSet(oldAssetRecipient, _assetRecipient);
  }
  function _getMintAmountForEpoch(
    uint256 collateralAmountIn,
    uint256 epoch
  ) private view returns (uint256 cashAmountOut) {
    uint256 amountE24 = _scaleUp(collateralAmountIn) * 1e6;
    cashAmountOut = amountE24 / epochToExchangeRate[epoch];
  }
  function _getMintFees(
    uint256 collateralAmount
  ) private view returns (uint256) {
    return (collateralAmount * mintFee) / BPS_DENOMINATOR;
  }
  function _scaleUp(uint256 amount) private view returns (uint256) {
    return amount * decimalsMultiplier;
  }
  function pause() external onlyRole(PAUSER_ADMIN) {
    _pause();
  }
  function unpause() external onlyRole(MANAGER_ADMIN) {
    _unpause();
  }
  function setEpochDuration(
    uint256 _epochDuration
  ) external onlyRole(MANAGER_ADMIN) {
    uint256 oldEpochDuration = epochDuration;
    epochDuration = _epochDuration;
    emit EpochDurationSet(oldEpochDuration, _epochDuration);
  }
  modifier updateEpoch() {
    transitionEpoch();
    _;
  }
  function transitionEpoch() public {
    uint256 epochDifference = (block.timestamp - currentEpochStartTimestamp) /
      epochDuration;
    if (epochDifference > 0) {
      currentRedeemAmount = 0;
      currentMintAmount = 0;
      currentEpoch += epochDifference;
      currentEpochStartTimestamp =
        block.timestamp -
        (block.timestamp % epochDuration);
    }
  }
  function setMintLimit(uint256 _mintLimit) external onlyRole(MANAGER_ADMIN) {
    uint256 oldMintLimit = mintLimit;
    mintLimit = _mintLimit;
    emit MintLimitSet(oldMintLimit, _mintLimit);
  }
  function setRedeemLimit(
    uint256 _redeemLimit
  ) external onlyRole(MANAGER_ADMIN) {
    uint256 oldRedeemLimit = redeemLimit;
    redeemLimit = _redeemLimit;
    emit RedeemLimitSet(oldRedeemLimit, _redeemLimit);
  }
  function _checkAndUpdateMintLimit(uint256 collateralAmountIn) private {
    if (collateralAmountIn > mintLimit - currentMintAmount) {
      revert MintExceedsRateLimit();
    }
    currentMintAmount += collateralAmountIn;
  }
  function _checkAndUpdateRedeemLimit(uint256 amount) private {
    if (amount == 0) {
      revert RedeemAmountCannotBeZero();
    }
    if (amount > redeemLimit - currentRedeemAmount) {
      revert RedeemExceedsRateLimit();
    }
    currentRedeemAmount += amount;
  }
  function requestRedemption(
    uint256 amountCashToRedeem
  )
    external
    override
    updateEpoch
    nonReentrant
    whenNotPaused
    checkKYC(msg.sender)
  {
    if (amountCashToRedeem < minimumRedeemAmount) {
      revert WithdrawRequestAmountTooSmall();
    }
    _checkAndUpdateRedeemLimit(amountCashToRedeem);
    redemptionInfoPerEpoch[currentEpoch].addressToBurnAmt[
        msg.sender
      ] += amountCashToRedeem;
    redemptionInfoPerEpoch[currentEpoch].totalBurned += amountCashToRedeem;
    cash.burnFrom(msg.sender, amountCashToRedeem);
    emit RedemptionRequested(msg.sender, amountCashToRedeem, currentEpoch);
  }
  function completeRedemptions(
    address[] calldata redeemers,
    address[] calldata refundees,
    uint256 collateralAmountToDist,
    uint256 epochToService,
    uint256 fees
  ) external override updateEpoch onlyRole(MANAGER_ADMIN) {
    _checkAddressesKYC(redeemers);
    _checkAddressesKYC(refundees);
    if (epochToService >= currentEpoch) {
      revert MustServicePastEpoch();
    }
    uint256 refundedAmt = _processRefund(refundees, epochToService);
    uint256 quantityBurned = redemptionInfoPerEpoch[epochToService]
      .totalBurned - refundedAmt;
    uint256 amountToDist = collateralAmountToDist - fees;
    _processRedemption(redeemers, amountToDist, quantityBurned, epochToService);
    collateral.safeTransferFrom(assetSender, feeRecipient, fees);
    emit RedemptionFeesCollected(feeRecipient, fees, epochToService);
  }
  function _processRedemption(
    address[] calldata redeemers,
    uint256 amountToDist,
    uint256 quantityBurned,
    uint256 epochToService
  ) private {
    uint256 size = redeemers.length;
    for (uint256 i = 0; i < size; ++i) {
      address redeemer = redeemers[i];
      uint256 cashAmountReturned = redemptionInfoPerEpoch[epochToService]
        .addressToBurnAmt[redeemer];
      redemptionInfoPerEpoch[epochToService].addressToBurnAmt[redeemer] = 0;
      uint256 collateralAmountDue = (amountToDist * cashAmountReturned) /
        quantityBurned;
      if (collateralAmountDue == 0) {
        revert CollateralRedemptionTooSmall();
      }
      collateral.safeTransferFrom(assetSender, redeemer, collateralAmountDue);
      emit RedemptionCompleted(
        redeemer,
        cashAmountReturned,
        collateralAmountDue,
        epochToService
      );
    }
  }
  function _processRefund(
    address[] calldata refundees,
    uint256 epochToService
  ) private returns (uint256 totalCashAmountRefunded) {
    uint256 size = refundees.length;
    for (uint256 i = 0; i < size; ++i) {
      address refundee = refundees[i];
      uint256 cashAmountBurned = redemptionInfoPerEpoch[epochToService]
        .addressToBurnAmt[refundee];
      redemptionInfoPerEpoch[epochToService].addressToBurnAmt[refundee] = 0;
      cash.mint(refundee, cashAmountBurned);
      totalCashAmountRefunded += cashAmountBurned;
      emit RefundIssued(refundee, cashAmountBurned, epochToService);
    }
    return totalCashAmountRefunded;
  }
  function setAssetSender(
    address newAssetSender
  ) external onlyRole(MANAGER_ADMIN) {
    address oldAssetSender = assetSender;
    assetSender = newAssetSender;
    emit AssetSenderSet(oldAssetSender, newAssetSender);
  }
  function setRedeemMinimum(
    uint256 newRedeemMinimum
  ) external onlyRole(MANAGER_ADMIN) {
    uint256 oldRedeemMin = minimumRedeemAmount;
    minimumRedeemAmount = newRedeemMinimum;
    emit MinimumRedeemAmountSet(oldRedeemMin, minimumRedeemAmount);
  }
  function getBurnedQuantity(
    uint256 epoch,
    address user
  ) external view returns (uint256) {
    return redemptionInfoPerEpoch[epoch].addressToBurnAmt[user];
  }
  function setPendingRedemptionBalance(
    address user,
    uint256 epoch,
    uint256 balance
  ) external updateEpoch onlyRole(MANAGER_ADMIN) {
    if (epoch > currentEpoch) {
      revert CannotServiceFutureEpoch();
    }
    uint256 previousBalance = redemptionInfoPerEpoch[epoch].addressToBurnAmt[
      user
    ];
    if (balance < previousBalance) {
      redemptionInfoPerEpoch[epoch].totalBurned -= previousBalance - balance;
    } else if (balance > previousBalance) {
      redemptionInfoPerEpoch[epoch].totalBurned += balance - previousBalance;
    }
    redemptionInfoPerEpoch[epoch].addressToBurnAmt[user] = balance;
    emit PendingRedemptionBalanceSet(
      user,
      epoch,
      balance,
      redemptionInfoPerEpoch[epoch].totalBurned
    );
  }
  modifier checkKYC(address account) {
    _checkKYC(account);
    _;
  }
  function setKYCRequirementGroup(
    uint256 _kycRequirementGroup
  ) external override onlyRole(MANAGER_ADMIN) {
    _setKYCRequirementGroup(_kycRequirementGroup);
  }
  function setKYCRegistry(
    address _kycRegistry
  ) external override onlyRole(MANAGER_ADMIN) {
    _setKYCRegistry(_kycRegistry);
  }
  function _checkKYC(address account) private view {
    if (!_getKYCStatus(account)) {
      revert KYCCheckFailed();
    }
  }
  function _checkAddressesKYC(address[] calldata accounts) private view {
    uint256 size = accounts.length;
    for (uint256 i = 0; i < size; ++i) {
      _checkKYC(accounts[i]);
    }
  }
  function multiexcall(
    ExCallData[] calldata exCallData
  )
    external
    payable
    override
    nonReentrant
    onlyRole(MANAGER_ADMIN)
    whenPaused
    returns (bytes[] memory results)
  {
    results = new bytes[](exCallData.length);
    for (uint256 i = 0; i < exCallData.length; ++i) {
      (bool success, bytes memory ret) = address(exCallData[i].target).call{
        value: exCallData[i].value
      }(exCallData[i].data);
      require(success, "Call Failed");
      results[i] = ret;
    }
  }
}