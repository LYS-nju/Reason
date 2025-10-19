pragma solidity =0.7.6;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract DSAuthEvents {
    event LogSetAuthority(address indexed authority);
    event LogSetOwner(address indexed owner);
}
contract DSAuth is DSAuthEvents {
    address public owner;
    function setOwner(address owner_) external auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }
    modifier auth() {
        require(isAuthorized(msg.sender), "ds-auth-unauthorized");
        _;
    }
    function isAuthorized(address src) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else {
            return false;
        }
    }
}
contract DSMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) internal pure returns (uint256 z) {
        return x >= y ? x : y;
    }
    function imin(int256 x, int256 y) internal pure returns (int256 z) {
        return x <= y ? x : y;
    }
    function imax(int256 x, int256 y) internal pure returns (int256 z) {
        return x >= y ? x : y;
    }
    uint256 constant WAD = 10**18;
    uint256 constant RAY = 10**27;
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = add(mul(x, RAY), y / 2) / y;
    }
}
contract EventfulMarket {
    event LogItemUpdate(uint256 id);
    event LogTrade(
        uint256 pay_amt,
        address indexed pay_gem,
        uint256 buy_amt,
        address indexed buy_gem
    );
    event LogMake(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );
    event LogBump(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );
    event LogTake(
        bytes32 id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        address indexed taker,
        uint128 take_amt,
        uint128 give_amt,
        uint64 timestamp
    );
    event LogKill(
        bytes32 indexed id,
        bytes32 indexed pair,
        address indexed maker,
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt,
        uint64 timestamp
    );
    event LogInt(string lol, uint256 input);
    event FeeTake(
        bytes32 indexed id,
        bytes32 indexed pair,
        ERC20 asset,
        address indexed taker,
        address feeTo,
        uint256 feeAmt,
        uint64 timestamp
    );
    event OfferDeleted(uint256 id);
}
contract SimpleMarket is EventfulMarket, DSMath {
    uint256 public last_offer_id;
    mapping(uint256 => OfferInfo) public offers;
    bool locked;
    uint256 internal feeBPS;
    address internal feeTo;
    struct OfferInfo {
        uint256 pay_amt;
        ERC20 pay_gem;
        uint256 buy_amt;
        ERC20 buy_gem;
        address owner;
        uint64 timestamp;
    }
    modifier can_buy(uint256 id) virtual {
        require(isActive(id));
        _;
    }
    modifier can_cancel(uint256 id) virtual {
        require(isActive(id));
        require(getOwner(id) == msg.sender);
        _;
    }
    modifier can_offer() virtual {
        _;
    }
    modifier synchronized() {
        require(!locked);
        locked = true;
        _;
        locked = false;
    }
    function isActive(uint256 id) public view returns (bool active) {
        return offers[id].timestamp > 0;
    }
    function getOwner(uint256 id) public view returns (address owner) {
        return offers[id].owner;
    }
    function getOffer(uint256 id)
        public
        view
        returns (
            uint256,
            ERC20,
            uint256,
            ERC20
        )
    {
        OfferInfo memory _offer = offers[id];
        return (_offer.pay_amt, _offer.pay_gem, _offer.buy_amt, _offer.buy_gem);
    }
    function bump(bytes32 id_) external can_buy(uint256(id_)) {
        uint256 id = uint256(id_);
        emit LogBump(
            id_,
            keccak256(abi.encodePacked(offers[id].pay_gem, offers[id].buy_gem)),
            offers[id].owner,
            offers[id].pay_gem,
            offers[id].buy_gem,
            uint128(offers[id].pay_amt),
            uint128(offers[id].buy_amt),
            offers[id].timestamp
        );
    }
    function buy(uint256 id, uint256 quantity)
        public
        virtual
        can_buy(id)
        synchronized
        returns (bool)
    {
        OfferInfo memory _offer = offers[id];
        uint256 spend = mul(quantity, _offer.buy_amt) / _offer.pay_amt;
        require(uint128(spend) == spend, "spend is not an int");
        require(uint128(quantity) == quantity, "quantity is not an int");
        if (
            quantity == 0 ||
            spend == 0 ||
            quantity > _offer.pay_amt ||
            spend > _offer.buy_amt
        ) {
            return false;
        }
        uint256 fee = mul(spend, feeBPS) / 10000;
        require(
            _offer.buy_gem.transferFrom(msg.sender, feeTo, fee),
            "Insufficient funds to cover fee"
        );
        offers[id].pay_amt = sub(_offer.pay_amt, quantity);
        offers[id].buy_amt = sub(_offer.buy_amt, spend);
        require(
            _offer.buy_gem.transferFrom(msg.sender, _offer.owner, spend),
            "_offer.buy_gem.transferFrom(msg.sender, _offer.owner, spend) failed - check that you can pay the fee"
        );
        require(
            _offer.pay_gem.transfer(msg.sender, quantity),
            "_offer.pay_gem.transfer(msg.sender, quantity) failed"
        );
        emit LogItemUpdate(id);
        emit LogTake(
            bytes32(id),
            keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
            _offer.owner,
            _offer.pay_gem,
            _offer.buy_gem,
            msg.sender,
            uint128(quantity),
            uint128(spend),
            uint64(block.timestamp)
        );
        emit FeeTake(
            bytes32(id),
            keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
            _offer.buy_gem,
            msg.sender,
            feeTo,
            fee,
            uint64(block.timestamp)
        );
        emit LogTrade(
            quantity,
            address(_offer.pay_gem),
            spend,
            address(_offer.buy_gem)
        );
        if (offers[id].pay_amt == 0) {
            delete offers[id];
            emit OfferDeleted(id);
        }
        return true;
    }
    function cancel(uint256 id)
        public
        virtual
        can_cancel(id)
        synchronized
        returns (bool success)
    {
        OfferInfo memory _offer = offers[id];
        delete offers[id];
        require(_offer.pay_gem.transfer(_offer.owner, _offer.pay_amt));
        emit LogItemUpdate(id);
        emit LogKill(
            bytes32(id),
            keccak256(abi.encodePacked(_offer.pay_gem, _offer.buy_gem)),
            _offer.owner,
            _offer.pay_gem,
            _offer.buy_gem,
            uint128(_offer.pay_amt),
            uint128(_offer.buy_amt),
            uint64(block.timestamp)
        );
        success = true;
    }
    function kill(bytes32 id) external virtual {
        require(cancel(uint256(id)));
    }
    function make(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    ) external virtual returns (bytes32 id) {
        return bytes32(offer(pay_amt, pay_gem, buy_amt, buy_gem));
    }
    function offer(
        uint256 pay_amt,
        ERC20 pay_gem,
        uint256 buy_amt,
        ERC20 buy_gem
    ) public virtual can_offer synchronized returns (uint256 id) {
        require(uint128(pay_amt) == pay_amt);
        require(uint128(buy_amt) == buy_amt);
        require(pay_amt > 0);
        require(pay_gem != ERC20(0x0));
        require(buy_amt > 0);
        require(buy_gem != ERC20(0x0));
        require(pay_gem != buy_gem);
        OfferInfo memory info;
        info.pay_amt = pay_amt;
        info.pay_gem = pay_gem;
        info.buy_amt = buy_amt;
        info.buy_gem = buy_gem;
        info.owner = msg.sender;
        info.timestamp = uint64(block.timestamp);
        id = _next_id();
        offers[id] = info;
        require(pay_gem.transferFrom(msg.sender, address(this), pay_amt));
        emit LogItemUpdate(id);
        emit LogMake(
            bytes32(id),
            keccak256(abi.encodePacked(pay_gem, buy_gem)),
            msg.sender,
            pay_gem,
            buy_gem,
            uint128(pay_amt),
            uint128(buy_amt),
            uint64(block.timestamp)
        );
    }
    function take(bytes32 id, uint128 maxTakeAmount) external virtual {
        require(buy(uint256(id), maxTakeAmount));
    }
    function _next_id() internal returns (uint256) {
        last_offer_id++;
        return last_offer_id;
    }
    function getFeeBPS() internal view returns (uint256) {
        return feeBPS;
    }
}
contract ExpiringMarket is DSAuth, SimpleMarket {
    bool public stopped;
    modifier can_offer() override {
        require(!isClosed());
        _;
    }
    modifier can_buy(uint256 id) override {
        require(isActive(id));
        require(!isClosed());
        _;
    }
    modifier can_cancel(uint256 id) virtual override {
        require(isActive(id));
        require((msg.sender == getOwner(id)) || isClosed());
        _;
    }
    function isClosed() public pure returns (bool closed) {
        return false;
    }
    function getTime() public view returns (uint64) {
        return uint64(block.timestamp);
    }
    function stop() external auth {
        stopped = true;
    }
}
contract DSNote {
    event LogNote(
        bytes4 indexed sig,
        address indexed guy,
        bytes32 indexed foo,
        bytes32 indexed bar,
        uint256 wad,
        bytes fax
    ) anonymous;
    modifier note() {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;
        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue()
        }
        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);
        _;
    }
}
contract MatchingEvents {
    event LogBuyEnabled(bool isEnabled);
    event LogMinSell(address pay_gem, uint256 min_amount);
    event LogMatchingEnabled(bool isEnabled);
    event LogUnsortedOffer(uint256 id);
    event LogSortedOffer(uint256 id);
    event LogInsert(address keeper, uint256 id);
    event LogDelete(address keeper, uint256 id);
    event LogMatch(uint256 id, uint256 amount);
}
contract RubiconMarket is MatchingEvents, ExpiringMarket, DSNote {
    bool public buyEnabled = true; 
    bool public matchingEnabled = true; 
    bool public initialized;
    bool public AqueductDistributionLive;
    address public AqueductAddress;
    struct sortInfo {
        uint256 next; 
        uint256 prev; 
        uint256 delb; 
    }
    mapping(uint256 => sortInfo) public _rank; 
    mapping(address => mapping(address => uint256)) public _best; 
    mapping(address => mapping(address => uint256)) public _span; 
    mapping(address => uint256) public _dust; 
    mapping(uint256 => uint256) public _near; 
    uint256 public _head; 
    uint256 public dustId; 
    function initialize(bool _live, address _feeTo) public {
        require(!initialized, "contract is already initialized");
        AqueductDistributionLive = _live;
        feeTo = _feeTo;
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
        feeBPS = 20;
        initialized = true;
        matchingEnabled = true;
        buyEnabled = true;
    }
    modifier can_cancel(uint256 id) override {
        require(isActive(id), "Offer was deleted or taken, or never existed.");
        require(
            isClosed() || msg.sender == getOwner(id) || id == dustId,
            "Offer can not be cancelled because user is not owner, and market is open, and offer sells required amount of tokens."
        );
        _;
    }
    function make(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint128 pay_amt,
        uint128 buy_amt
    ) public override returns (bytes32) {
        return bytes32(offer(pay_amt, pay_gem, buy_amt, buy_gem));
    }
    function take(bytes32 id, uint128 maxTakeAmount) public override {
        require(buy(uint256(id), maxTakeAmount));
    }
    function kill(bytes32 id) external override {
        require(cancel(uint256(id)));
    }
    function offer(
        uint256 pay_amt, 
        ERC20 pay_gem, 
        uint256 buy_amt, 
        ERC20 buy_gem 
    ) public override returns (uint256) {
        require(!locked, "Reentrancy attempt");
            function(uint256, ERC20, uint256, ERC20) returns (uint256) fn
         = matchingEnabled ? _offeru : super.offer;
        return fn(pay_amt, pay_gem, buy_amt, buy_gem);
    }
    function offer(
        uint256 pay_amt, 
        ERC20 pay_gem, 
        uint256 buy_amt, 
        ERC20 buy_gem, 
        uint256 pos 
    ) external can_offer returns (uint256) {
        return offer(pay_amt, pay_gem, buy_amt, buy_gem, pos, true);
    }
    function offer(
        uint256 pay_amt, 
        ERC20 pay_gem, 
        uint256 buy_amt, 
        ERC20 buy_gem, 
        uint256 pos, 
        bool matching 
    ) public can_offer returns (uint256) {
        require(!locked, "Reentrancy attempt");
        require(_dust[address(pay_gem)] <= pay_amt);
        if (matchingEnabled) {
            return _matcho(pay_amt, pay_gem, buy_amt, buy_gem, pos, matching);
        }
        return super.offer(pay_amt, pay_gem, buy_amt, buy_gem);
    }
    function buy(uint256 id, uint256 amount)
        public
        override
        can_buy(id)
        returns (bool)
    {
        require(!locked, "Reentrancy attempt");
        if (AqueductDistributionLive) {
            IAqueduct(AqueductAddress).distributeToMakerAndTaker(
                getOwner(id),
                msg.sender
            );
        }
        function(uint256, uint256) returns (bool) fn = matchingEnabled
            ? _buys
            : super.buy;
        return fn(id, amount);
    }
    function cancel(uint256 id)
        public
        override
        can_cancel(id)
        returns (bool success)
    {
        require(!locked, "Reentrancy attempt");
        if (matchingEnabled) {
            if (isOfferSorted(id)) {
                require(_unsort(id));
            } else {
                require(_hide(id));
            }
        }
        return super.cancel(id); 
    }
    function insert(
        uint256 id, 
        uint256 pos 
    ) public returns (bool) {
        require(!locked, "Reentrancy attempt");
        require(!isOfferSorted(id)); 
        require(isActive(id)); 
        _hide(id); 
        _sort(id, pos); 
        emit LogInsert(msg.sender, id);
        return true;
    }
    function del_rank(uint256 id) external returns (bool) {
        require(!locked, "Reentrancy attempt");
        require(
            !isActive(id) &&
                _rank[id].delb != 0 &&
                _rank[id].delb < block.number - 10
        );
        delete _rank[id];
        emit LogDelete(msg.sender, id);
        return true;
    }
    function setMinSell(
        ERC20 pay_gem, 
        uint256 dust 
    ) external auth note returns (bool) {
        _dust[address(pay_gem)] = dust;
        emit LogMinSell(address(pay_gem), dust);
        return true;
    }
    function getMinSell(
        ERC20 pay_gem 
    ) external view returns (uint256) {
        return _dust[address(pay_gem)];
    }
    function setBuyEnabled(bool buyEnabled_) external auth returns (bool) {
        buyEnabled = buyEnabled_;
        emit LogBuyEnabled(buyEnabled);
        return true;
    }
    function setMatchingEnabled(bool matchingEnabled_)
        external
        auth
        returns (bool)
    {
        matchingEnabled = matchingEnabled_;
        emit LogMatchingEnabled(matchingEnabled);
        return true;
    }
    function getBestOffer(ERC20 sell_gem, ERC20 buy_gem)
        public
        view
        returns (uint256)
    {
        return _best[address(sell_gem)][address(buy_gem)];
    }
    function getWorseOffer(uint256 id) public view returns (uint256) {
        return _rank[id].prev;
    }
    function getBetterOffer(uint256 id) external view returns (uint256) {
        return _rank[id].next;
    }
    function getOfferCount(ERC20 sell_gem, ERC20 buy_gem)
        public
        view
        returns (uint256)
    {
        return _span[address(sell_gem)][address(buy_gem)];
    }
    function getFirstUnsortedOffer() public view returns (uint256) {
        return _head;
    }
    function getNextUnsortedOffer(uint256 id) public view returns (uint256) {
        return _near[id];
    }
    function isOfferSorted(uint256 id) public view returns (bool) {
        return
            _rank[id].next != 0 ||
            _rank[id].prev != 0 ||
            _best[address(offers[id].pay_gem)][address(offers[id].buy_gem)] ==
            id;
    }
    function sellAllAmount(
        ERC20 pay_gem,
        uint256 pay_amt,
        ERC20 buy_gem,
        uint256 min_fill_amount
    ) external returns (uint256 fill_amt) {
        require(!locked, "Reentrancy attempt");
        uint256 offerId;
        while (pay_amt > 0) {
            offerId = getBestOffer(buy_gem, pay_gem); 
            require(offerId != 0); 
            if (
                pay_amt * 1 ether <
                wdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
            ) {
                break; 
            }
            if (pay_amt >= offers[offerId].buy_amt) {
                fill_amt = add(fill_amt, offers[offerId].pay_amt); 
                pay_amt = sub(pay_amt, offers[offerId].buy_amt); 
                take(bytes32(offerId), uint128(offers[offerId].pay_amt)); 
            } else {
                uint256 baux = rmul(
                    pay_amt * 10**9,
                    rdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
                ) / 10**9;
                fill_amt = add(fill_amt, baux); 
                take(bytes32(offerId), uint128(baux)); 
                pay_amt = 0; 
            }
        }
        require(fill_amt >= min_fill_amount);
    }
    function buyAllAmount(
        ERC20 buy_gem,
        uint256 buy_amt,
        ERC20 pay_gem,
        uint256 max_fill_amount
    ) external returns (uint256 fill_amt) {
        require(!locked, "Reentrancy attempt");
        uint256 offerId;
        while (buy_amt > 0) {
            offerId = getBestOffer(buy_gem, pay_gem); 
            require(offerId != 0);
            if (
                buy_amt * 1 ether <
                wdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
            ) {
                break; 
            }
            if (buy_amt >= offers[offerId].pay_amt) {
                fill_amt = add(fill_amt, offers[offerId].buy_amt); 
                buy_amt = sub(buy_amt, offers[offerId].pay_amt); 
                take(bytes32(offerId), uint128(offers[offerId].pay_amt)); 
            } else {
                fill_amt = add(
                    fill_amt,
                    rmul(
                        buy_amt * 10**9,
                        rdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
                    ) / 10**9
                ); 
                take(bytes32(offerId), uint128(buy_amt)); 
                buy_amt = 0; 
            }
        }
        require(fill_amt <= max_fill_amount);
    }
    function getBuyAmount(
        ERC20 buy_gem,
        ERC20 pay_gem,
        uint256 pay_amt
    ) external view returns (uint256 fill_amt) {
        uint256 offerId = getBestOffer(buy_gem, pay_gem); 
        while (pay_amt > offers[offerId].buy_amt) {
            fill_amt = add(fill_amt, offers[offerId].pay_amt); 
            pay_amt = sub(pay_amt, offers[offerId].buy_amt); 
            if (pay_amt > 0) {
                offerId = getWorseOffer(offerId); 
                require(offerId != 0); 
            }
        }
        fill_amt = add(
            fill_amt,
            rmul(
                pay_amt * 10**9,
                rdiv(offers[offerId].pay_amt, offers[offerId].buy_amt)
            ) / 10**9
        ); 
    }
    function getPayAmount(
        ERC20 pay_gem,
        ERC20 buy_gem,
        uint256 buy_amt
    ) external view returns (uint256 fill_amt) {
        uint256 offerId = getBestOffer(buy_gem, pay_gem); 
        while (buy_amt > offers[offerId].pay_amt) {
            fill_amt = add(fill_amt, offers[offerId].buy_amt); 
            buy_amt = sub(buy_amt, offers[offerId].pay_amt); 
            if (buy_amt > 0) {
                offerId = getWorseOffer(offerId); 
                require(offerId != 0); 
            }
        }
        fill_amt = add(
            fill_amt,
            rmul(
                buy_amt * 10**9,
                rdiv(offers[offerId].buy_amt, offers[offerId].pay_amt)
            ) / 10**9
        ); 
    }
    function _buys(uint256 id, uint256 amount) internal returns (bool) {
        require(buyEnabled);
        if (amount == offers[id].pay_amt) {
            if (isOfferSorted(id)) {
                _unsort(id);
            } else {
                _hide(id);
            }
        }
        require(super.buy(id, amount));
        if (
            isActive(id) &&
            offers[id].pay_amt < _dust[address(offers[id].pay_gem)]
        ) {
            dustId = id; 
            cancel(id);
        }
        return true;
    }
    function _find(uint256 id) internal view returns (uint256) {
        require(id > 0);
        address buy_gem = address(offers[id].buy_gem);
        address pay_gem = address(offers[id].pay_gem);
        uint256 top = _best[pay_gem][buy_gem];
        uint256 old_top = 0;
        while (top != 0 && _isPricedLtOrEq(id, top)) {
            old_top = top;
            top = _rank[top].prev;
        }
        return old_top;
    }
    function _findpos(uint256 id, uint256 pos) internal view returns (uint256) {
        require(id > 0);
        while (pos != 0 && !isActive(pos)) {
            pos = _rank[pos].prev;
        }
        if (pos == 0) {
            return _find(id);
        } else {
            if (_isPricedLtOrEq(id, pos)) {
                uint256 old_pos;
                while (pos != 0 && _isPricedLtOrEq(id, pos)) {
                    old_pos = pos;
                    pos = _rank[pos].prev;
                }
                return old_pos;
            } else {
                while (pos != 0 && !_isPricedLtOrEq(id, pos)) {
                    pos = _rank[pos].next;
                }
                return pos;
            }
        }
    }
    function _isPricedLtOrEq(
        uint256 low, 
        uint256 high 
    ) internal view returns (bool) {
        return
            mul(offers[low].buy_amt, offers[high].pay_amt) >=
            mul(offers[high].buy_amt, offers[low].pay_amt);
    }
    function _matcho(
        uint256 t_pay_amt, 
        ERC20 t_pay_gem, 
        uint256 t_buy_amt, 
        ERC20 t_buy_gem, 
        uint256 pos, 
        bool rounding 
    ) internal returns (uint256 id) {
        uint256 best_maker_id; 
        uint256 t_buy_amt_old; 
        uint256 m_buy_amt; 
        uint256 m_pay_amt; 
        while (_best[address(t_buy_gem)][address(t_pay_gem)] > 0) {
            best_maker_id = _best[address(t_buy_gem)][address(t_pay_gem)];
            m_buy_amt = offers[best_maker_id].buy_amt;
            m_pay_amt = offers[best_maker_id].pay_amt;
            if (
                mul(m_buy_amt, t_buy_amt) >
                mul(t_pay_amt, m_pay_amt) +
                    (
                        rounding
                            ? m_buy_amt + t_buy_amt + t_pay_amt + m_pay_amt
                            : 0
                    )
            ) {
                break;
            }
            buy(best_maker_id, min(m_pay_amt, t_buy_amt));
            emit LogMatch(id, min(m_pay_amt, t_buy_amt));
            t_buy_amt_old = t_buy_amt;
            t_buy_amt = sub(t_buy_amt, min(m_pay_amt, t_buy_amt));
            t_pay_amt = mul(t_buy_amt, t_pay_amt) / t_buy_amt_old;
            if (t_pay_amt == 0 || t_buy_amt == 0) {
                break;
            }
        }
        if (
            t_buy_amt > 0 &&
            t_pay_amt > 0 &&
            t_pay_amt >= _dust[address(t_pay_gem)]
        ) {
            id = super.offer(t_pay_amt, t_pay_gem, t_buy_amt, t_buy_gem);
            _sort(id, pos);
        }
    }
    function _offeru(
        uint256 pay_amt, 
        ERC20 pay_gem, 
        uint256 buy_amt, 
        ERC20 buy_gem 
    ) internal returns (uint256 id) {
        require(_dust[address(pay_gem)] <= pay_amt);
        id = super.offer(pay_amt, pay_gem, buy_amt, buy_gem);
        _near[id] = _head;
        _head = id;
        emit LogUnsortedOffer(id);
    }
    function _sort(
        uint256 id, 
        uint256 pos 
    ) internal {
        require(isActive(id));
        ERC20 buy_gem = offers[id].buy_gem;
        ERC20 pay_gem = offers[id].pay_gem;
        uint256 prev_id; 
        pos = pos == 0 ||
            offers[pos].pay_gem != pay_gem ||
            offers[pos].buy_gem != buy_gem ||
            !isOfferSorted(pos)
            ? _find(id)
            : _findpos(id, pos);
        if (pos != 0) {
            prev_id = _rank[pos].prev;
            _rank[pos].prev = id;
            _rank[id].next = pos;
        } else {
            prev_id = _best[address(pay_gem)][address(buy_gem)];
            _best[address(pay_gem)][address(buy_gem)] = id;
        }
        if (prev_id != 0) {
            _rank[prev_id].next = id;
            _rank[id].prev = prev_id;
        }
        _span[address(pay_gem)][address(buy_gem)]++;
        emit LogSortedOffer(id);
    }
    function _unsort(
        uint256 id 
    ) internal returns (bool) {
        address buy_gem = address(offers[id].buy_gem);
        address pay_gem = address(offers[id].pay_gem);
        require(_span[pay_gem][buy_gem] > 0);
        require(
            _rank[id].delb == 0 && 
                isOfferSorted(id)
        );
        if (id != _best[pay_gem][buy_gem]) {
            require(_rank[_rank[id].next].prev == id);
            _rank[_rank[id].next].prev = _rank[id].prev;
        } else {
            _best[pay_gem][buy_gem] = _rank[id].prev;
        }
        if (_rank[id].prev != 0) {
            require(_rank[_rank[id].prev].next == id);
            _rank[_rank[id].prev].next = _rank[id].next;
        }
        _span[pay_gem][buy_gem]--;
        _rank[id].delb = block.number; 
        return true;
    }
    function _hide(
        uint256 id 
    ) internal returns (bool) {
        uint256 uid = _head; 
        uint256 pre = uid; 
        require(!isOfferSorted(id)); 
        if (_head == id) {
            _head = _near[id]; 
            _near[id] = 0; 
            return true;
        }
        while (uid > 0 && uid != id) {
            pre = uid;
            uid = _near[uid];
        }
        if (uid != id) {
            return false;
        }
        _near[pre] = _near[id]; 
        _near[id] = 0; 
        return true;
    }
    function setFeeBPS(uint256 _newFeeBPS) external auth returns (bool) {
        feeBPS = _newFeeBPS;
        return true;
    }
    function setAqueductDistributionLive(bool live)
        external
        auth
        returns (bool)
    {
        AqueductDistributionLive = live;
        return true;
    }
    function setAqueductAddress(address _Aqueduct)
        external
        auth
        returns (bool)
    {
        AqueductAddress = _Aqueduct;
        return true;
    }
    function setFeeTo(address newFeeTo) external auth returns (bool) {
        feeTo = newFeeTo;
        return true;
    }
}
interface IWETH {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns (bool);
    function withdraw(uint256) external;
    function approve(address guy, uint256 wad) external returns (bool);
}
interface IAqueduct {
    function distributeToMakerAndTaker(address maker, address taker)
        external
        returns (bool);
}