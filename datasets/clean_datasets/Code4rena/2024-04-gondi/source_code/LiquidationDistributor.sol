pragma solidity ^0.8.21;
library EnumerableSet {
    struct Set {
        bytes32[] _values;
        mapping(bytes32 value => uint256) _positions;
    }
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._positions[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 position = set._positions[value];
        if (position != 0) {
            uint256 valueIndex = position - 1;
            uint256 lastIndex = set._values.length - 1;
            if (valueIndex != lastIndex) {
                bytes32 lastValue = set._values[lastIndex];
                set._values[valueIndex] = lastValue;
                set._positions[lastValue] = position;
            }
            set._values.pop();
            delete set._positions[value];
            return true;
        } else {
            return false;
        }
    }
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._positions[value] != 0;
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
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        bytes32[] memory store = _values(set._inner);
        bytes32[] memory result;
        assembly {
            result := store
        }
        return result;
    }
    struct AddressSet {
        Set _inner;
    }
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }
    function values(AddressSet storage set) internal view returns (address[] memory) {
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
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;
        assembly {
            result := store
        }
        return result;
    }
}
abstract contract Owned {
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    address public owner;
    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");
        _;
    }
    constructor(address _owner) {
        owner = _owner;
        emit OwnershipTransferred(address(0), _owner);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(msg.sender, to, amount);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; 
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;
        balanceOf[from] -= amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
        return true;
    }
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );
            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");
            allowance[recoveredAddress][spender] = value;
        }
        emit Approval(owner, spender, value);
    }
    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }
    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }
    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }
    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        unchecked {
            totalSupply -= amount;
        }
        emit Transfer(from, address(0), amount);
    }
}
library FixedPointMathLib {
    uint256 internal constant MAX_UINT256 = 2**256 - 1;
    uint256 internal constant WAD = 1e18; 
    function mulWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, y, WAD); 
    }
    function mulWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, y, WAD); 
    }
    function divWadDown(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivDown(x, WAD, y); 
    }
    function divWadUp(uint256 x, uint256 y) internal pure returns (uint256) {
        return mulDivUp(x, WAD, y); 
    }
    function mulDivDown(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }
            z := div(mul(x, y), denominator)
        }
    }
    function mulDivUp(
        uint256 x,
        uint256 y,
        uint256 denominator
    ) internal pure returns (uint256 z) {
        assembly {
            if iszero(mul(denominator, iszero(mul(y, gt(x, div(MAX_UINT256, y)))))) {
                revert(0, 0)
            }
            z := add(gt(mod(mul(x, y), denominator), 0), div(mul(x, y), denominator))
        }
    }
    function rpow(
        uint256 x,
        uint256 n,
        uint256 scalar
    ) internal pure returns (uint256 z) {
        assembly {
            switch x
            case 0 {
                switch n
                case 0 {
                    z := scalar
                }
                default {
                    z := 0
                }
            }
            default {
                switch mod(n, 2)
                case 0 {
                    z := scalar
                }
                default {
                    z := x
                }
                let half := shr(1, scalar)
                for {
                    n := shr(1, n)
                } n {
                    n := shr(1, n)
                } {
                    if shr(128, x) {
                        revert(0, 0)
                    }
                    let xx := mul(x, x)
                    let xxRound := add(xx, half)
                    if lt(xxRound, xx) {
                        revert(0, 0)
                    }
                    x := div(xxRound, scalar)
                    if mod(n, 2) {
                        let zx := mul(z, x)
                        if iszero(eq(div(zx, x), z)) {
                            if iszero(iszero(x)) {
                                revert(0, 0)
                            }
                        }
                        let zxRound := add(zx, half)
                        if lt(zxRound, zx) {
                            revert(0, 0)
                        }
                        z := div(zxRound, scalar)
                    }
                }
            }
        }
    }
    function sqrt(uint256 x) internal pure returns (uint256 z) {
        assembly {
            let y := x 
            z := 181 
            if iszero(lt(y, 0x10000000000000000000000000000000000)) {
                y := shr(128, y)
                z := shl(64, z)
            }
            if iszero(lt(y, 0x1000000000000000000)) {
                y := shr(64, y)
                z := shl(32, z)
            }
            if iszero(lt(y, 0x10000000000)) {
                y := shr(32, y)
                z := shl(16, z)
            }
            if iszero(lt(y, 0x1000000)) {
                y := shr(16, y)
                z := shl(8, z)
            }
            z := shr(18, mul(z, add(y, 65536))) 
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := shr(1, add(z, div(x, z)))
            z := sub(z, lt(div(x, z), z))
        }
    }
    function unsafeMod(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := mod(x, y)
        }
    }
    function unsafeDiv(uint256 x, uint256 y) internal pure returns (uint256 r) {
        assembly {
            r := div(x, y)
        }
    }
    function unsafeDivUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}
abstract contract ReentrancyGuard {
    uint256 private locked = 1;
    modifier nonReentrant() virtual {
        require(locked == 1, "REENTRANCY");
        locked = 2;
        _;
        locked = 1;
    }
}
interface ILoanManager {
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external;
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external;
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external;
}
interface ILoanManagerRegistry {
    function addLoanManager(address _loanManager) external;
    function removeLoanManager(address _loanManager) external;
    function isLoanManager(address _loanManager) external view returns (bool);
}
abstract contract InputChecker {
    error AddressZeroError();
    function _checkAddressNotZero(address _address) internal pure {
        if (_address == address(0)) {
            revert AddressZeroError();
        }
    }
}
library SafeTransferLib {
    function safeTransferETH(address to, uint256 amount) internal {
        bool success;
        assembly {
            success := call(gas(), to, amount, 0, 0, 0, 0)
        }
        require(success, "ETH_TRANSFER_FAILED");
    }
    function safeTransferFrom(
        ERC20 token,
        address from,
        address to,
        uint256 amount
    ) internal {
        bool success;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(from, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 36), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 68), amount) 
            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 100, 0, 32)
            )
        }
        require(success, "TRANSFER_FROM_FAILED");
    }
    function safeTransfer(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 36), amount) 
            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
        require(success, "TRANSFER_FAILED");
    }
    function safeApprove(
        ERC20 token,
        address to,
        uint256 amount
    ) internal {
        bool success;
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
            mstore(add(freeMemoryPointer, 4), and(to, 0xffffffffffffffffffffffffffffffffffffffff)) 
            mstore(add(freeMemoryPointer, 36), amount) 
            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
        require(success, "APPROVE_FAILED");
    }
}
abstract contract WithLoanManagers is Owned {
    mapping(address => bool) internal _loanManagers;
    event LoanManagerAdded(address loanManagerAdded);
    event LoanManagerRemoved(address loanManagerRemoved);
    constructor() Owned(tx.origin) {}
    function addLoanManager(address _loanManager) external onlyOwner {
        _loanManagers[_loanManager] = true;
        emit LoanManagerAdded(_loanManager);
    }
    function removeLoanManager(address _loanManager) external onlyOwner {
        _loanManagers[_loanManager] = false;
        emit LoanManagerRemoved(_loanManager);
    }
    function isLoanManager(address _loanManager) external view returns (bool) {
        return _loanManagers[_loanManager];
    }
}
abstract contract TwoStepOwned is Owned {
    event TransferOwnerRequested(address newOwner);
    error TooSoonError();
    error InvalidInputError();
    uint256 public MIN_WAIT_TIME;
    address public pendingOwner;
    uint256 public pendingOwnerTime;
    constructor(address _owner, uint256 _minWaitTime) Owned(_owner) {
        pendingOwnerTime = type(uint256).max;
        MIN_WAIT_TIME = _minWaitTime;
    }
    function requestTransferOwner(address _newOwner) external onlyOwner {
        pendingOwner = _newOwner;
        pendingOwnerTime = block.timestamp;
        emit TransferOwnerRequested(_newOwner);
    }
    function transferOwnership(address newOwner) public override onlyOwner {
        if (pendingOwnerTime + MIN_WAIT_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (pendingOwner != newOwner) {
            revert InvalidInputError();
        }
        owner = newOwner;
        pendingOwner = address(0);
        pendingOwnerTime = type(uint256).max;
        emit OwnershipTransferred(owner, newOwner);
    }
}
interface ILoanLiquidator {
    function liquidateLoan(
        uint256 _loanId,
        address _contract,
        uint256 _tokenId,
        address _asset,
        uint96 _duration,
        address _originator
    ) external returns (bytes memory);
}
interface IBaseLoan {
    struct ImprovementMinimum {
        uint256 principalAmount;
        uint256 interest;
        uint256 duration;
    }
    struct OfferValidator {
        address validator;
        bytes arguments;
    }
    function getTotalLoansIssued() external view returns (uint256);
    function cancelOffer(uint256 _offerId) external;
    function cancelAllOffers(uint256 _minOfferId) external;
    function cancelRenegotiationOffer(uint256 _renegotiationId) external;
}
interface IMultiSourceLoan {
    struct LoanOffer {
        uint256 offerId;
        address lender;
        uint256 fee;
        uint256 capacity;
        address nftCollateralAddress;
        uint256 nftCollateralTokenId;
        address principalAddress;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
        uint256 maxSeniorRepayment;
        IBaseLoan.OfferValidator[] validators;
    }
    struct OfferExecution {
        LoanOffer offer;
        uint256 amount;
        bytes lenderOfferSignature;
    }
    struct ExecutionData {
        OfferExecution[] offerExecution;
        uint256 tokenId;
        uint256 duration;
        uint256 expirationTime;
        address principalReceiver;
        bytes callbackData;
    }
    struct LoanExecutionData {
        ExecutionData executionData;
        address borrower;
        bytes borrowerOfferSignature;
    }
    struct SignableRepaymentData {
        uint256 loanId;
        bytes callbackData;
        bool shouldDelegate;
    }
    struct LoanRepaymentData {
        SignableRepaymentData data;
        Loan loan;
        bytes borrowerSignature;
    }
    struct Tranche {
        uint256 loanId;
        uint256 floor;
        uint256 principalAmount;
        address lender;
        uint256 accruedInterest;
        uint256 startTime;
        uint256 aprBps;
    }
    struct Loan {
        address borrower;
        uint256 nftCollateralTokenId;
        address nftCollateralAddress;
        address principalAddress;
        uint256 principalAmount;
        uint256 startTime;
        uint256 duration;
        Tranche[] tranche;
        uint256 protocolFee;
    }
    struct RenegotiationOffer {
        uint256 renegotiationId;
        uint256 loanId;
        address lender;
        uint256 fee;
        uint256[] trancheIndex;
        uint256 principalAmount;
        uint256 aprBps;
        uint256 expirationTime;
        uint256 duration;
    }
    event LoanLiquidated(uint256 loanId);
    event LoanEmitted(uint256 loanId, uint256[] offerId, Loan loan, uint256 fee);
    event LoanRefinanced(uint256 renegotiationId, uint256 oldLoanId, uint256 newLoanId, Loan loan, uint256 fee);
    event LoanRepaid(uint256 loanId, uint256 totalRepayment, uint256 fee);
    event LoanRefinancedFromNewOffers(
        uint256 loanId, uint256 newLoanId, Loan loan, uint256[] offerIds, uint256 totalFee
    );
    event TranchesMerged(Loan loan, uint256 minTranche, uint256 maxTranche);
    event DelegateRegistryUpdated(address newdelegateRegistry);
    event Delegated(uint256 loanId, address delegate, bool value);
    event FlashActionContractUpdated(address newFlashActionContract);
    event FlashActionExecuted(uint256 loanId, address target, bytes data);
    event RevokeDelegate(address delegate, address collection, uint256 tokenId);
    event MinLockPeriodUpdated(uint256 minLockPeriod);
    function emitLoan(LoanExecutionData calldata _loanExecutionData) external returns (uint256, Loan memory);
    function refinanceFull(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);
    function addNewTranche(
        RenegotiationOffer calldata _renegotiationOffer,
        Loan memory _loan,
        bytes calldata _renegotiationOfferSignature
    ) external returns (uint256, Loan memory);
    function mergeTranches(uint256 _loanId, Loan memory _loan, uint256 _minTranche, uint256 _maxTranche)
        external
        returns (uint256, Loan memory);
    function refinancePartial(RenegotiationOffer calldata _renegotiationOffer, Loan memory _loan)
        external
        returns (uint256, Loan memory);
    function refinanceFromLoanExecutionData(
        uint256 _loanId,
        Loan calldata _loan,
        LoanExecutionData calldata _loanExecutionData
    ) external returns (uint256, Loan memory);
    function repayLoan(LoanRepaymentData calldata _repaymentData) external;
    function liquidateLoan(uint256 _loanId, Loan calldata _loan) external returns (bytes memory);
    function getMaxTranches() external view returns (uint256);
    function setMinLockPeriod(uint256 _minLockPeriod) external;
    function getMinLockPeriod() external view returns (uint256);
    function getDelegateRegistry() external view returns (address);
    function setDelegateRegistry(address _newDelegationRegistry) external;
    function delegate(uint256 _loanId, Loan calldata _loan, address _delegate, bytes32 _rights, bool _value) external;
    function revokeDelegate(address _delegate, address _collection, uint256 _tokenId) external;
    function getFlashActionContract() external view returns (address);
    function setFlashActionContract(address _newFlashActionContract) external;
    function getLoanHash(uint256 _loanId) external view returns (bytes32);
    function executeFlashAction(uint256 _loanId, Loan calldata _loan, address _target, bytes calldata _data) external;
    function loanLiquidated(uint256 _loanId, Loan calldata _loan) external;
}
interface ILiquidationDistributor {
    function distribute(uint256 _repayment, IMultiSourceLoan.Loan calldata _loan) external;
}
library Interest {
    using FixedPointMathLib for uint256;
    uint256 private constant _PRECISION = 10000;
    uint256 private constant _SECONDS_PER_YEAR = 31536000;
    function getInterest(IMultiSourceLoan.LoanOffer memory _loanOffer) internal pure returns (uint256) {
        return _getInterest(_loanOffer.principalAmount, _loanOffer.aprBps, _loanOffer.duration);
    }
    function getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) internal pure returns (uint256) {
        return _getInterest(_amount, _aprBps, _duration);
    }
    function getTotalOwed(IMultiSourceLoan.Loan memory _loan, uint256 _timestamp) internal pure returns (uint256) {
        uint256 owed = 0;
        for (uint256 i = 0; i < _loan.tranche.length;) {
            IMultiSourceLoan.Tranche memory tranche = _loan.tranche[i];
            owed += tranche.principalAmount + tranche.accruedInterest
                + _getInterest(tranche.principalAmount, tranche.aprBps, _timestamp - tranche.startTime);
            unchecked {
                ++i;
            }
        }
        return owed;
    }
    function _getInterest(uint256 _amount, uint256 _aprBps, uint256 _duration) private pure returns (uint256) {
        return _amount.mulDivUp(_aprBps * _duration, _PRECISION * _SECONDS_PER_YEAR);
    }
}
abstract contract LoanManager is ILoanManager, InputChecker, TwoStepOwned {
    using EnumerableSet for EnumerableSet.AddressSet;
    struct PendingCaller {
        address caller;
        bool isLoanContract;
    }
    uint256 public immutable UPDATE_WAITING_TIME;
    PendingCaller[] public getPendingAcceptedCallers;
    uint256 public getPendingAcceptedCallersSetTime;
    EnumerableSet.AddressSet internal _acceptedCallers;
    mapping(address => bool) internal _isLoanContract;
    address public getUnderwriter;
    address public getPendingUnderwriter;
    uint256 public getPendingUnderwriterSetTime;
    event RequestCallersAdded(PendingCaller[] callers);
    event CallersAdded(PendingCaller[] callers);
    event PendingUnderwriterSet(address underwriter);
    event UnderwriterSet(address underwriter);
    error CallerNotAccepted();
    constructor(address _owner, address __underwriter, uint256 _updateWaitingTime)
        TwoStepOwned(_owner, _updateWaitingTime)
    {
        _checkAddressNotZero(__underwriter);
        getUnderwriter = __underwriter;
        UPDATE_WAITING_TIME = _updateWaitingTime;
        getPendingUnderwriterSetTime = type(uint256).max;
        getPendingAcceptedCallersSetTime = type(uint256).max;
    }
    modifier onlyAcceptedCallers() {
        if (!_acceptedCallers.contains(msg.sender)) {
            revert CallerNotAccepted();
        }
        _;
    }
    function requestAddCallers(PendingCaller[] calldata _callers) external onlyOwner {
        getPendingAcceptedCallers = _callers;
        getPendingAcceptedCallersSetTime = block.timestamp;
        emit RequestCallersAdded(_callers);
    }
    function addCallers(PendingCaller[] calldata _callers) external onlyOwner {
        if (getPendingAcceptedCallersSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        PendingCaller[] memory pendingCallers = getPendingAcceptedCallers;
        for (uint256 i = 0; i < _callers.length;) {
            PendingCaller calldata caller = _callers[i];
            if (pendingCallers[i].caller != caller.caller || pendingCallers[i].isLoanContract != caller.isLoanContract)
            {
                revert InvalidInputError();
            }
            _acceptedCallers.add(caller.caller);
            _isLoanContract[caller.caller] = caller.isLoanContract;
            afterCallerAdded(caller.caller);
            unchecked {
                ++i;
            }
        }
        emit CallersAdded(_callers);
    }
    function isCallerAccepted(address _caller) external view returns (bool) {
        return _acceptedCallers.contains(_caller);
    }
    function setUnderwriter(address __underwriter) external onlyOwner {
        _checkAddressNotZero(__underwriter);
        getPendingUnderwriter = __underwriter;
        getPendingUnderwriterSetTime = block.timestamp;
        emit PendingUnderwriterSet(__underwriter);
    }
    function confirmUnderwriter(address __underwriter) external onlyOwner {
        if (getPendingUnderwriterSetTime + UPDATE_WAITING_TIME > block.timestamp) {
            revert TooSoonError();
        }
        if (getPendingUnderwriter != __underwriter) {
            revert InvalidInputError();
        }
        getUnderwriter = __underwriter;
        getPendingUnderwriter = address(0);
        getPendingUnderwriterSetTime = type(uint256).max;
        emit UnderwriterSet(__underwriter);
    }
    function afterCallerAdded(address _caller) internal virtual;
    function validateOffer(bytes calldata _offer, uint256 _protocolFee) external virtual;
    function loanRepayment(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _startTime
    ) external virtual;
    function loanLiquidation(
        uint256 _loanId,
        uint256 _principalAmount,
        uint256 _apr,
        uint256 _accruedInterest,
        uint256 _protocolFee,
        uint256 _received,
        uint256 _startTime
    ) external virtual;
}
contract LiquidationDistributor is ILiquidationDistributor, ReentrancyGuard {
    using FixedPointMathLib for uint256;
    using Interest for uint256;
    using SafeTransferLib for ERC20;
    ILoanManagerRegistry public immutable getLoanManagerRegistry;
    constructor(address _loanManagerRegistry) {
        getLoanManagerRegistry = ILoanManagerRegistry(_loanManagerRegistry);
    }
    function distribute(uint256 _proceeds, IMultiSourceLoan.Loan calldata _loan) external {
        uint256[] memory owedPerTranche = new uint256[](_loan.tranche.length);
        uint256 totalPrincipalAndPaidInterestOwed = _loan.principalAmount;
        uint256 totalPendingInterestOwed = 0;
        for (uint256 i = 0; i < _loan.tranche.length;) {
            IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
            uint256 pendingInterest =
                thisTranche.principalAmount.getInterest(thisTranche.aprBps, block.timestamp - thisTranche.startTime);
            totalPrincipalAndPaidInterestOwed += thisTranche.accruedInterest;
            totalPendingInterestOwed += pendingInterest;
            owedPerTranche[i] += thisTranche.principalAmount + thisTranche.accruedInterest + pendingInterest;
            unchecked {
                ++i;
            }
        }
        if (_proceeds > totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed) {
            for (uint256 i = 0; i < _loan.tranche.length;) {
                IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                _handleTrancheExcess(
                    _loan.principalAddress,
                    thisTranche,
                    msg.sender,
                    _proceeds,
                    totalPrincipalAndPaidInterestOwed + totalPendingInterestOwed
                );
                unchecked {
                    ++i;
                }
            }
        } else {
            for (uint256 i = 0; i < _loan.tranche.length && _proceeds > 0;) {
                IMultiSourceLoan.Tranche calldata thisTranche = _loan.tranche[i];
                _proceeds = _handleTrancheInsufficient(
                    _loan.principalAddress, thisTranche, msg.sender, _proceeds, owedPerTranche[i]
                );
                unchecked {
                    ++i;
                }
            }
        }
    }
    function _handleTrancheExcess(
        address _tokenAddress,
        IMultiSourceLoan.Tranche calldata _tranche,
        address _liquidator,
        uint256 _proceeds,
        uint256 _totalOwed
    ) private {
        uint256 excess = _proceeds - _totalOwed;
        uint256 owed = _tranche.principalAmount + _tranche.accruedInterest
            + _tranche.principalAmount.getInterest(_tranche.aprBps, block.timestamp - _tranche.startTime);
        uint256 total = owed + excess.mulDivDown(owed, _totalOwed);
        _handleLoanManagerCall(_tranche, total);
        ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, total);
    }
    function _handleTrancheInsufficient(
        address _tokenAddress,
        IMultiSourceLoan.Tranche calldata _tranche,
        address _liquidator,
        uint256 _proceedsLeft,
        uint256 _trancheOwed
    ) private returns (uint256) {
        if (_proceedsLeft > _trancheOwed) {
            _handleLoanManagerCall(_tranche, _trancheOwed);
            ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _trancheOwed);
            _proceedsLeft -= _trancheOwed;
        } else {
            _handleLoanManagerCall(_tranche, _proceedsLeft);
            ERC20(_tokenAddress).safeTransferFrom(_liquidator, _tranche.lender, _proceedsLeft);
            _proceedsLeft = 0;
        }
        return _proceedsLeft;
    }
    function _handleLoanManagerCall(IMultiSourceLoan.Tranche calldata _tranche, uint256 _sent) private {
        if (getLoanManagerRegistry.isLoanManager(_tranche.lender)) {
            LoanManager(_tranche.lender).loanLiquidation(
                _tranche.loanId,
                _tranche.principalAmount,
                _tranche.aprBps,
                _tranche.accruedInterest,
                0,
                _sent,
                _tranche.startTime
            );
        }
    }
}