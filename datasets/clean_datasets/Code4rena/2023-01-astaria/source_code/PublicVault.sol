pragma solidity ^0.8.17;
pragma experimental ABIEncoderV2;
contract Clone {
    function _getArgAddress(
        uint256 argOffset
    ) internal pure returns (address arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0x60, calldataload(add(offset, argOffset)))
        }
    }
    function _getArgUint256(
        uint256 argOffset
    ) internal pure returns (uint256 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := calldataload(add(offset, argOffset))
        }
    }
    function _getArgUint256Array(
        uint256 argOffset,
        uint64 arrLen
    ) internal pure returns (uint256[] memory arr) {
        uint256 offset = _getImmutableArgsOffset();
        uint256 el;
        arr = new uint256[](arrLen);
        for (uint64 i = 0; i < arrLen; i++) {
            assembly {
                el := calldataload(add(add(offset, argOffset), mul(i, 32)))
            }
            arr[i] = el;
        }
        return arr;
    }
    function _getArgUint64(
        uint256 argOffset
    ) internal pure returns (uint64 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xc0, calldataload(add(offset, argOffset)))
        }
    }
    function _getArgUint8(uint256 argOffset) internal pure returns (uint8 arg) {
        uint256 offset = _getImmutableArgsOffset();
        assembly {
            arg := shr(0xf8, calldataload(add(offset, argOffset)))
        }
    }
    function _getImmutableArgsOffset() internal pure returns (uint256 offset) {
        assembly {
            offset := sub(
                calldatasize(),
                add(shr(240, calldataload(sub(calldatasize(), 2))), 2)
            )
        }
    }
}
library ClonesWithImmutableArgs {
    uint256 private constant _CREATE3_PROXY_BYTECODE =
        0x67363d3d37363d34f03d5260086018f3;
    bytes32 private constant _CREATE3_PROXY_BYTECODE_HASH =
        0x21c35dbe1b344a2488cf3321d6ce542f8e9f305544ff09e4993a62319a497c1f;
    error CreateFail();
    error InitializeFail();
    enum CloneType {
        CREATE,
        CREATE2,
        PREDICT_CREATE2
    }
    function clone(
        address implementation,
        bytes memory data
    ) internal returns (address payable instance) {
        return clone(implementation, data, 0);
    }
    function clone(
        address implementation,
        bytes memory data,
        uint256 value
    ) internal returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        assembly {
            instance := create(
                value,
                add(creationcode, 0x20),
                mload(creationcode)
            )
        }
        if (instance == address(0)) {
            revert CreateFail();
        }
    }
    function clone2(
        address implementation,
        bytes memory data
    ) internal returns (address payable instance) {
        return clone2(implementation, data, 0);
    }
    function clone2(
        address implementation,
        bytes memory data,
        uint256 value
    ) internal returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        assembly {
            instance := create2(
                value,
                add(creationcode, 0x20),
                mload(creationcode),
                0
            )
        }
        if (instance == address(0)) {
            revert CreateFail();
        }
    }
    function addressOfClone2(
        address implementation,
        bytes memory data
    ) internal view returns (address payable instance) {
        bytes memory creationcode = getCreationBytecode(implementation, data);
        bytes32 bytecodeHash = keccak256(creationcode);
        instance = payable(
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xff),
                                address(this),
                                bytes32(0),
                                bytecodeHash
                            )
                        )
                    )
                )
            )
        );
    }
    function getCreationBytecode(
        address implementation,
        bytes memory data
    ) internal pure returns (bytes memory ret) {
        unchecked {
            uint256 extraLength = data.length + 2; 
            uint256 creationSize = 0x41 + extraLength;
            uint256 runSize = creationSize - 10;
            uint256 dataPtr;
            uint256 ptr;
            assembly {
                ret := mload(0x40)
                mstore(ret, creationSize)
                mstore(0x40, add(ret, creationSize))
                ptr := add(ret, 0x20)
                mstore(
                    ptr,
                    0x6100000000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x01), shl(240, runSize)) 
                mstore(
                    add(ptr, 0x03),
                    0x3d81600a3d39f33d3d3d3d363d3d376100000000000000000000000000000000
                )
                mstore(add(ptr, 0x13), shl(240, extraLength))
                mstore(
                    add(ptr, 0x15),
                    0x6037363936610000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x1b), shl(240, extraLength))
                mstore(
                    add(ptr, 0x1d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x20), shl(0x60, implementation))
                mstore(
                    add(ptr, 0x34),
                    0x5af43d3d93803e603557fd5bf300000000000000000000000000000000000000
                )
            }
            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x41;
            assembly {
                dataPtr := add(data, 32)
            }
            for (; counter >= 32; counter -= 32) {
                assembly {
                    mstore(copyPtr, mload(dataPtr))
                }
                copyPtr += 32;
                dataPtr += 32;
            }
            uint256 mask = ~(256 ** (32 - counter) - 1);
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }
        }
    }
    function clone3(
        address implementation,
        bytes memory data,
        bytes32 salt
    ) internal returns (address deployed) {
        return clone3(implementation, data, salt, 0);
    }
    function clone3(
        address implementation,
        bytes memory data,
        bytes32 salt,
        uint256 value
    ) internal returns (address deployed) {
        unchecked {
            uint256 extraLength = data.length + 2; 
            uint256 creationSize = 0x43 + extraLength;
            uint256 ptr;
            assembly {
                ptr := mload(0x40)
                mstore(
                    ptr,
                    0x3d61000000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x02), shl(240, sub(creationSize, 11))) 
                mstore(
                    add(ptr, 0x04),
                    0x80600b3d3981f300000000000000000000000000000000000000000000000000
                )
                mstore(
                    add(ptr, 0x0b),
                    0x363d3d3761000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x10), shl(240, extraLength))
                mstore(
                    add(ptr, 0x12),
                    0x603836393d3d3d36610000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x1b), shl(240, extraLength))
                mstore(
                    add(ptr, 0x1d),
                    0x013d730000000000000000000000000000000000000000000000000000000000
                )
                mstore(add(ptr, 0x20), shl(0x60, implementation))
                mstore(
                    add(ptr, 0x34),
                    0x5af43d82803e903d91603657fd5bf30000000000000000000000000000000000
                )
            }
            extraLength -= 2;
            uint256 counter = extraLength;
            uint256 copyPtr = ptr + 0x43;
            uint256 dataPtr;
            assembly {
                dataPtr := add(data, 32)
            }
            for (; counter >= 32; counter -= 32) {
                assembly {
                    mstore(copyPtr, mload(dataPtr))
                }
                copyPtr += 32;
                dataPtr += 32;
            }
            uint256 mask = ~(256 ** (32 - counter) - 1);
            assembly {
                mstore(copyPtr, and(mload(dataPtr), mask))
            }
            copyPtr += counter;
            assembly {
                mstore(copyPtr, shl(240, extraLength))
            }
            assembly {
                mstore(0x00, _CREATE3_PROXY_BYTECODE)
                let proxy := create2(0, 0x10, 0x10, salt)
                if iszero(proxy) {
                    mstore(0x00, 0xebfef188)
                    revert(0x1c, 0x04)
                }
                mstore(0x14, proxy)
                mstore(0x00, 0xd694)
                mstore8(0x34, 0x01)
                deployed := and(
                    keccak256(0x1e, 0x17),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
                if or(
                    iszero(extcodesize(deployed)),
                    iszero(
                        call(
                            gas(), 
                            proxy, 
                            value, 
                            ptr, 
                            creationSize, 
                            0x00, 
                            0x00 
                        )
                    )
                ) {
                    mstore(0x00, 0x8f86d2f1)
                    revert(0x1c, 0x04)
                }
            }
        }
    }
    function addressOfClone3(
        bytes32 salt
    ) internal view returns (address deployed) {
        assembly {
            let m := mload(0x40)
            mstore(0x00, address())
            mstore8(0x0b, 0xff)
            mstore(0x20, salt)
            mstore(0x40, _CREATE3_PROXY_BYTECODE_HASH)
            mstore(0x14, keccak256(0x0b, 0x55))
            mstore(0x40, m)
            mstore(0x00, 0xd694)
            mstore8(0x34, 0x01)
            deployed := and(
                keccak256(0x1e, 0x17),
                0xffffffffffffffffffffffffffffffffffffffff
            )
        }
    }
}
library SafeCastLib {
  function safeCastTo248(uint256 x) internal pure returns (uint248 y) {
    require(x < 1 << 248);
    y = uint248(x);
  }
  function safeCastTo240(uint256 x) internal pure returns (uint240 y) {
    require(x < 1 << 240);
    y = uint240(x);
  }
  function safeCastTo224(uint256 x) internal pure returns (uint224 y) {
    require(x < 1 << 224);
    y = uint224(x);
  }
  function safeCastTo216(uint256 x) internal pure returns (uint216 y) {
    require(x < 1 << 216);
    y = uint216(x);
  }
  function safeCastTo208(uint256 x) internal pure returns (uint208 y) {
    require(x < 1 << 208);
    y = uint208(x);
  }
  function safeCastTo200(uint256 x) internal pure returns (uint200 y) {
    require(x < 1 << 200);
    y = uint200(x);
  }
  function safeCastTo192(uint256 x) internal pure returns (uint192 y) {
    require(x < 1 << 192);
    y = uint192(x);
  }
  function safeCastTo176(uint256 x) internal pure returns (uint176 y) {
    require(x < 1 << 176);
    y = uint176(x);
  }
  function safeCastTo160(uint256 x) internal pure returns (uint160 y) {
    require(x < 1 << 160);
    y = uint160(x);
  }
  function safeCastTo128(uint256 x) internal pure returns (uint128 y) {
    require(x < 1 << 128);
    y = uint128(x);
  }
  function safeCastTo96(uint256 x) internal pure returns (uint96 y) {
    require(x < 1 << 96);
    y = uint96(x);
  }
  function safeCastTo88(uint256 x) internal pure returns (uint88 y) {
    require(x < 1 << 88);
    y = uint88(x);
  }
  function safeCastTo64(uint256 x) internal pure returns (uint64 y) {
    require(x < 1 << 64);
    y = uint64(x);
  }
  function safeCastTo32(uint256 x) internal pure returns (uint32 y) {
    require(x < 1 << 32);
    y = uint32(x);
  }
  function safeCastTo40(uint256 x) internal pure returns (uint40 y) {
    require(x < 1 << 40);
    y = uint40(x);
  }
  function safeCastTo48(uint256 x) internal pure returns (uint48 y) {
    require(x < 1 << 48);
    y = uint48(x);
  }
  function safeCastTo24(uint256 x) internal pure returns (uint24 y) {
    require(x < 1 << 24);
    y = uint24(x);
  }
  function safeCastTo16(uint256 x) internal pure returns (uint16 y) {
    require(x < 1 << 16);
    y = uint16(x);
  }
  function safeCastTo8(uint256 x) internal pure returns (uint8 y) {
    require(x < 1 << 8);
    y = uint8(x);
  }
}
interface AmountDerivationErrors {
    error InexactFraction();
}
interface ConduitControllerInterface {
    struct ConduitProperties {
        bytes32 key;
        address owner;
        address potentialOwner;
        address[] channels;
        mapping(address => uint256) channelIndexesPlusOne;
    }
    event NewConduit(address conduit, bytes32 conduitKey);
    event OwnershipTransferred(
        address indexed conduit,
        address indexed previousOwner,
        address indexed newOwner
    );
    event PotentialOwnerUpdated(address indexed newPotentialOwner);
    error InvalidCreator();
    error InvalidInitialOwner();
    error NewPotentialOwnerAlreadySet(
        address conduit,
        address newPotentialOwner
    );
    error NoPotentialOwnerCurrentlySet(address conduit);
    error NoConduit();
    error ConduitAlreadyExists(address conduit);
    error CallerIsNotOwner(address conduit);
    error NewPotentialOwnerIsZeroAddress(address conduit);
    error CallerIsNotNewPotentialOwner(address conduit);
    error ChannelOutOfRange(address conduit);
    function createConduit(bytes32 conduitKey, address initialOwner)
        external
        returns (address conduit);
    function updateChannel(
        address conduit,
        address channel,
        bool isOpen
    ) external;
    function transferOwnership(address conduit, address newPotentialOwner)
        external;
    function cancelOwnershipTransfer(address conduit) external;
    function acceptOwnership(address conduit) external;
    function ownerOf(address conduit) external view returns (address owner);
    function getKey(address conduit) external view returns (bytes32 conduitKey);
    function getConduit(bytes32 conduitKey)
        external
        view
        returns (address conduit, bool exists);
    function getPotentialOwner(address conduit)
        external
        view
        returns (address potentialOwner);
    function getChannelStatus(address conduit, address channel)
        external
        view
        returns (bool isOpen);
    function getTotalChannels(address conduit)
        external
        view
        returns (uint256 totalChannels);
    function getChannel(address conduit, uint256 channelIndex)
        external
        view
        returns (address channel);
    function getChannels(address conduit)
        external
        view
        returns (address[] memory channels);
    function getConduitCodeHashes()
        external
        view
        returns (bytes32 creationCodeHash, bytes32 runtimeCodeHash);
}
uint256 constant NameLengthPtr = 77;
uint256 constant NameWithLength = 0x0d436F6E73696465726174696F6E;
uint256 constant information_version_offset = 0;
uint256 constant information_version_cd_offset = 0x60;
uint256 constant information_domainSeparator_offset = 0x20;
uint256 constant information_conduitController_offset = 0x40;
uint256 constant information_versionLengthPtr = 0x63;
uint256 constant information_versionWithLength = 0x03312e31;
uint256 constant information_length = 0xa0;
uint256 constant _NOT_ENTERED = 1;
uint256 constant _ENTERED = 2;
uint256 constant Common_token_offset = 0x20;
uint256 constant Common_identifier_offset = 0x40;
uint256 constant Common_amount_offset = 0x60;
uint256 constant Common_endAmount_offset = 0x80;
uint256 constant ReceivedItem_size = 0xa0;
uint256 constant ReceivedItem_amount_offset = 0x60;
uint256 constant ReceivedItem_recipient_offset = 0x80;
uint256 constant ReceivedItem_CommonParams_size = 0x60;
uint256 constant ConsiderationItem_recipient_offset = 0xa0;
uint256 constant ConsiderItem_recipient_offset = 0xa0;
uint256 constant Execution_offerer_offset = 0x20;
uint256 constant Execution_conduit_offset = 0x40;
uint256 constant Panic_arithmetic = 0x11;
uint256 constant OrderParameters_offer_head_offset = 0x40;
uint256 constant OrderParameters_consideration_head_offset = 0x60;
uint256 constant OrderParameters_conduit_offset = 0x120;
uint256 constant OrderParameters_counter_offset = 0x140;
uint256 constant Fulfillment_itemIndex_offset = 0x20;
uint256 constant AdvancedOrder_numerator_offset = 0x20;
uint256 constant AlmostOneWord = 0x1f;
uint256 constant OneWord = 0x20;
uint256 constant TwoWords = 0x40;
uint256 constant ThreeWords = 0x60;
uint256 constant FourWords = 0x80;
uint256 constant FiveWords = 0xa0;
uint256 constant FreeMemoryPointerSlot = 0x40;
uint256 constant ZeroSlot = 0x60;
uint256 constant DefaultFreeMemoryPointer = 0x80;
uint256 constant Slot0x80 = 0x80;
uint256 constant Slot0xA0 = 0xa0;
uint256 constant BasicOrder_endAmount_cdPtr = 0x104;
uint256 constant BasicOrder_common_params_size = 0xa0;
uint256 constant BasicOrder_considerationHashesArray_ptr = 0x160;
uint256 constant EIP712_Order_size = 0x180;
uint256 constant EIP712_OfferItem_size = 0xc0;
uint256 constant EIP712_ConsiderationItem_size = 0xe0;
uint256 constant AdditionalRecipients_size = 0x40;
uint256 constant EIP712_DomainSeparator_offset = 0x02;
uint256 constant EIP712_OrderHash_offset = 0x22;
uint256 constant EIP712_DigestPayload_size = 0x42;
uint256 constant EIP712_BulkOrder_minSize = 0x121;
uint256 constant BulkOrderProof_proofAndKeySize = 0xe1;
uint256 constant receivedItemsHash_ptr = 0x60;
uint256 constant OrderFulfilled_baseSize = 0x1e0;
uint256 constant OrderFulfilled_selector = (
    0x9d9af8e38d66c62e2c12f0225249fd9d721c54b83f48d9352c97c6cacdcb6f31
);
uint256 constant OrderFulfilled_baseOffset = 0x180;
uint256 constant OrderFulfilled_consideration_length_baseOffset = 0x2a0;
uint256 constant OrderFulfilled_offer_length_baseOffset = 0x200;
uint256 constant OrderFulfilled_fulfiller_offset = 0x20;
uint256 constant OrderFulfilled_offer_head_offset = 0x40;
uint256 constant OrderFulfilled_offer_body_offset = 0x80;
uint256 constant OrderFulfilled_consideration_head_offset = 0x60;
uint256 constant OrderFulfilled_consideration_body_offset = 0x120;
uint256 constant BasicOrder_parameters_cdPtr = 0x04;
uint256 constant BasicOrder_considerationToken_cdPtr = 0x24;
uint256 constant BasicOrder_considerationAmount_cdPtr = 0x64;
uint256 constant BasicOrder_offerer_cdPtr = 0x84;
uint256 constant BasicOrder_zone_cdPtr = 0xa4;
uint256 constant BasicOrder_offerToken_cdPtr = 0xc4;
uint256 constant BasicOrder_offerAmount_cdPtr = 0x104;
uint256 constant BasicOrder_basicOrderType_cdPtr = 0x124;
uint256 constant BasicOrder_startTime_cdPtr = 0x144;
uint256 constant BasicOrder_offererConduit_cdPtr = 0x1c4;
uint256 constant BasicOrder_fulfillerConduit_cdPtr = 0x1e4;
uint256 constant BasicOrder_totalOriginalAdditionalRecipients_cdPtr = 0x204;
uint256 constant BasicOrder_additionalRecipients_head_cdPtr = 0x224;
uint256 constant BasicOrder_signature_cdPtr = 0x244;
uint256 constant BasicOrder_additionalRecipients_length_cdPtr = 0x264;
uint256 constant BasicOrder_additionalRecipients_data_cdPtr = 0x284;
uint256 constant BasicOrder_parameters_ptr = 0x20;
uint256 constant BasicOrder_basicOrderType_range = 0x18; 
uint256 constant BasicOrder_considerationItem_typeHash_ptr = 0x80; 
uint256 constant BasicOrder_considerationItem_itemType_ptr = 0xa0;
uint256 constant BasicOrder_considerationItem_token_ptr = 0xc0;
uint256 constant BasicOrder_considerationItem_identifier_ptr = 0xe0;
uint256 constant BasicOrder_considerationItem_startAmount_ptr = 0x100;
uint256 constant BasicOrder_considerationItem_endAmount_ptr = 0x120;
uint256 constant BasicOrder_offerItem_typeHash_ptr = DefaultFreeMemoryPointer;
uint256 constant BasicOrder_offerItem_itemType_ptr = 0xa0;
uint256 constant BasicOrder_offerItem_token_ptr = 0xc0;
uint256 constant BasicOrder_offerItem_endAmount_ptr = 0x120;
uint256 constant BasicOrder_order_typeHash_ptr = 0x80;
uint256 constant BasicOrder_order_offerer_ptr = 0xa0;
uint256 constant BasicOrder_order_offerHashes_ptr = 0xe0;
uint256 constant BasicOrder_order_considerationHashes_ptr = 0x100;
uint256 constant BasicOrder_order_orderType_ptr = 0x120;
uint256 constant BasicOrder_order_startTime_ptr = 0x140;
uint256 constant BasicOrder_order_counter_ptr = 0x1e0;
uint256 constant BasicOrder_additionalRecipients_head_ptr = 0x240;
uint256 constant BasicOrder_signature_ptr = 0x260;
bytes32 constant EIP2098_allButHighestBitMask = (
    0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
);
bytes32 constant ECDSA_twentySeventhAndTwentyEighthBytesSet = (
    0x0000000000000000000000000000000000000000000000000000000101000000
);
uint256 constant ECDSA_MaxLength = 65;
uint256 constant ECDSA_signature_s_offset = 0x40;
uint256 constant ECDSA_signature_v_offset = 0x60;
bytes32 constant EIP1271_isValidSignature_selector = (
    0x1626ba7e00000000000000000000000000000000000000000000000000000000
);
uint256 constant EIP1271_isValidSignature_signatureHead_negativeOffset = 0x20;
uint256 constant EIP1271_isValidSignature_digest_negativeOffset = 0x40;
uint256 constant EIP1271_isValidSignature_selector_negativeOffset = 0x44;
uint256 constant EIP1271_isValidSignature_calldata_baseLength = 0x64;
uint256 constant EIP1271_isValidSignature_signature_head_offset = 0x40;
uint256 constant EIP_712_PREFIX = (
    0x1901000000000000000000000000000000000000000000000000000000000000
);
uint256 constant ExtraGasBuffer = 0x20;
uint256 constant CostPerWord = 3;
uint256 constant MemoryExpansionCoefficient = 0x200; 
uint256 constant Create2AddressDerivation_ptr = 0x0b;
uint256 constant Create2AddressDerivation_length = 0x55;
uint256 constant MaskOverByteTwelve = (
    0x0000000000000000000000ff0000000000000000000000000000000000000000
);
uint256 constant MaskOverLastTwentyBytes = (
    0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff
);
uint256 constant MaskOverFirstFourBytes = (
    0xffffffff00000000000000000000000000000000000000000000000000000000
);
uint256 constant Conduit_execute_signature = (
    0x4ce34aa200000000000000000000000000000000000000000000000000000000
);
uint256 constant MaxUint8 = 0xff;
uint256 constant MaxUint120 = 0xffffffffffffffffffffffffffffff;
uint256 constant Conduit_execute_ConduitTransfer_ptr = 0x20;
uint256 constant Conduit_execute_ConduitTransfer_length = 0x01;
uint256 constant Conduit_execute_ConduitTransfer_offset_ptr = 0x04;
uint256 constant Conduit_execute_ConduitTransfer_length_ptr = 0x24;
uint256 constant Conduit_execute_transferItemType_ptr = 0x44;
uint256 constant Conduit_execute_transferToken_ptr = 0x64;
uint256 constant Conduit_execute_transferFrom_ptr = 0x84;
uint256 constant Conduit_execute_transferTo_ptr = 0xa4;
uint256 constant Conduit_execute_transferIdentifier_ptr = 0xc4;
uint256 constant Conduit_execute_transferAmount_ptr = 0xe4;
uint256 constant OneConduitExecute_size = 0x104;
uint256 constant AccumulatorDisarmed = 0x20;
uint256 constant AccumulatorArmed = 0x40;
uint256 constant Accumulator_conduitKey_ptr = 0x20;
uint256 constant Accumulator_selector_ptr = 0x40;
uint256 constant Accumulator_array_offset_ptr = 0x44;
uint256 constant Accumulator_array_length_ptr = 0x64;
uint256 constant Accumulator_itemSizeOffsetDifference = 0x3c;
uint256 constant Accumulator_array_offset = 0x20;
uint256 constant Conduit_transferItem_size = 0xc0;
uint256 constant Conduit_transferItem_token_ptr = 0x20;
uint256 constant Conduit_transferItem_from_ptr = 0x40;
uint256 constant Conduit_transferItem_to_ptr = 0x60;
uint256 constant Conduit_transferItem_identifier_ptr = 0x80;
uint256 constant Conduit_transferItem_amount_ptr = 0xa0;
uint256 constant Ecrecover_precompile = 1;
uint256 constant Ecrecover_args_size = 0x80;
uint256 constant Signature_lower_v = 27;
uint256 constant NumBitsAfterSelector = 0xe0;
uint256 constant NonMatchSelector_MagicModulus = 69;
uint256 constant NonMatchSelector_MagicRemainder = 0x1d;
uint256 constant IsValidOrder_signature = (
    0x0e1d31dc00000000000000000000000000000000000000000000000000000000
);
uint256 constant IsValidOrder_sig_ptr = 0x0;
uint256 constant IsValidOrder_orderHash_ptr = 0x04;
uint256 constant IsValidOrder_caller_ptr = 0x24;
uint256 constant IsValidOrder_offerer_ptr = 0x44;
uint256 constant IsValidOrder_zoneHash_ptr = 0x64;
uint256 constant IsValidOrder_length = 0x84; 
uint256 constant MissingFulfillmentComponentOnAggregation_error_selector = 0x375c24c1;
uint256 constant MissingFulfillmentComponentOnAggregation_error_side_ptr = 0x20;
uint256 constant MissingFulfillmentComponentOnAggregation_error_length = 0x24;
uint256 constant OfferAndConsiderationRequiredOnFulfillment_error_selector = 0x98e9db6e;
uint256 constant OfferAndConsiderationRequiredOnFulfillment_error_length = 0x04;
uint256 constant MismatchedFulfillmentOfferAndConsiderationComponents_error_selector = 0x09cfb455;
uint256 constant MismatchedFulfillmentOfferAndConsiderationComponents_error_length = 0x04;
uint256 constant InvalidFulfillmentComponentData_error_selector = 0x7fda7279;
uint256 constant InvalidFulfillmentComponentData_error_length = 0x04;
uint256 constant InexactFraction_error_selector = 0xc63cf089;
uint256 constant InexactFraction_error_length = 0x04;
uint256 constant OrderCriteriaResolverOutOfRange_error_selector = 0x869586c4;
uint256 constant OrderCriteriaResolverOutOfRange_error_length = 0x04;
uint256 constant UnresolvedOfferCriteria_error_selector = 0xa6cfc673;
uint256 constant UnresolvedOfferCriteria_error_length = 0x04;
uint256 constant UnresolvedConsiderationCriteria_error_selector = 0xff75a340;
uint256 constant UnresolvedConsiderationCriteria_error_length = 0x04;
uint256 constant OfferCriteriaResolverOutOfRange_error_selector = 0xbfb3f8ce;
uint256 constant OfferCriteriaResolverOutOfRange_error_length = 0x04;
uint256 constant ConsiderationCriteriaResolverOutOfRange_error_selector = 0x6088d7de;
uint256 constant ConsiderationCriteriaResolverOutOfRange_error_length = 0x04;
uint256 constant CriteriaNotEnabledForItem_error_selector = 0x94eb6af6;
uint256 constant CriteriaNotEnabledForItem_error_length = 0x04;
uint256 constant InvalidProof_error_selector = 0x09bde339;
uint256 constant InvalidProof_error_length = 0x04;
uint256 constant InvalidRestrictedOrder_error_selector = 0xfb5014fc;
uint256 constant InvalidRestrictedOrder_error_orderHash_ptr = 0x20;
uint256 constant InvalidRestrictedOrder_error_length = 0x24;
uint256 constant BadSignatureV_error_selector = 0x1f003d0a;
uint256 constant BadSignatureV_error_v_ptr = 0x20;
uint256 constant BadSignatureV_error_length = 0x24;
uint256 constant InvalidSigner_error_selector = 0x815e1d64;
uint256 constant InvalidSigner_error_length = 0x04;
uint256 constant InvalidSignature_error_selector = 0x8baa579f;
uint256 constant InvalidSignature_error_length = 0x04;
uint256 constant BadContractSignature_error_selector = 0x4f7fb80d;
uint256 constant BadContractSignature_error_length = 0x04;
uint256 constant InvalidERC721TransferAmount_error_selector = 0xefcc00b1;
uint256 constant InvalidERC721TransferAmount_error_length = 0x04;
uint256 constant MissingItemAmount_error_selector = 0x91b3e514;
uint256 constant MissingItemAmount_error_length = 0x04;
uint256 constant UnusedItemParameters_error_selector = 0x6ab37ce7;
uint256 constant UnusedItemParameters_error_length = 0x04;
uint256 constant BadReturnValueFromERC20OnTransfer_error_selector = 0x98891923;
uint256 constant BadReturnValueFromERC20OnTransfer_error_token_ptr = 0x20;
uint256 constant BadReturnValueFromERC20OnTransfer_error_from_ptr = 0x40;
uint256 constant BadReturnValueFromERC20OnTransfer_error_to_ptr = 0x60;
uint256 constant BadReturnValueFromERC20OnTransfer_error_amount_ptr = 0x80;
uint256 constant BadReturnValueFromERC20OnTransfer_error_length = 0x84;
uint256 constant NoContract_error_selector = 0x5f15d672;
uint256 constant NoContract_error_account_ptr = 0x20;
uint256 constant NoContract_error_length = 0x24;
uint256 constant Invalid1155BatchTransferEncoding_error_selector = 0xeba2084c;
uint256 constant Invalid1155BatchTransferEncoding_error_length = 0x04;
uint256 constant NoReentrantCalls_error_selector = 0x7fa8a987;
uint256 constant NoReentrantCalls_error_length = 0x04;
uint256 constant OrderAlreadyFilled_error_selector = 0x10fda3e1;
uint256 constant OrderAlreadyFilled_error_orderHash_ptr = 0x20;
uint256 constant OrderAlreadyFilled_error_length = 0x24;
uint256 constant InvalidTime_error_selector = 0x6f7eac26;
uint256 constant InvalidTime_error_length = 0x04;
uint256 constant InvalidConduit_error_selector = 0x1cf99b26;
uint256 constant InvalidConduit_error_conduitKey_ptr = 0x20;
uint256 constant InvalidConduit_error_conduit_ptr = 0x40;
uint256 constant InvalidConduit_error_length = 0x44;
uint256 constant MissingOriginalConsiderationItems_error_selector = 0x466aa616;
uint256 constant MissingOriginalConsiderationItems_error_length = 0x04;
uint256 constant InvalidCallToConduit_error_selector = 0xd13d53d4;
uint256 constant InvalidCallToConduit_error_conduit_ptr = 0x20;
uint256 constant InvalidCallToConduit_error_length = 0x24;
uint256 constant ConsiderationNotMet_error_selector = 0xa5f54208;
uint256 constant ConsiderationNotMet_error_orderIndex_ptr = 0x20;
uint256 constant ConsiderationNotMet_error_considerationIndex_ptr = 0x40;
uint256 constant ConsiderationNotMet_error_shortfallAmount_ptr = 0x60;
uint256 constant ConsiderationNotMet_error_length = 0x64;
uint256 constant InsufficientEtherSupplied_error_selector = 0x1a783b8d;
uint256 constant InsufficientEtherSupplied_error_length = 0x04;
uint256 constant EtherTransferGenericFailure_error_selector = 0x470c7c1d;
uint256 constant EtherTransferGenericFailure_error_account_ptr = 0x20;
uint256 constant EtherTransferGenericFailure_error_amount_ptr = 0x40;
uint256 constant EtherTransferGenericFailure_error_length = 0x44;
uint256 constant PartialFillsNotEnabledForOrder_error_selector = 0xa11b63ff;
uint256 constant PartialFillsNotEnabledForOrder_error_length = 0x04;
uint256 constant OrderIsCancelled_error_selector = 0x1a515574;
uint256 constant OrderIsCancelled_error_orderHash_ptr = 0x20;
uint256 constant OrderIsCancelled_error_length = 0x24;
uint256 constant OrderPartiallyFilled_error_selector = 0xee9e0e63;
uint256 constant OrderPartiallyFilled_error_orderHash_ptr = 0x20;
uint256 constant OrderPartiallyFilled_error_length = 0x24;
uint256 constant InvalidCanceller_error_selector = 0x80ec7374;
uint256 constant InvalidCanceller_error_length = 0x04;
uint256 constant BadFraction_error_selector = 0x5a052b32;
uint256 constant BadFraction_error_length = 0x04;
uint256 constant InvalidMsgValue_error_selector = 0xa61be9f0;
uint256 constant InvalidMsgValue_error_value_ptr = 0x20;
uint256 constant InvalidMsgValue_error_length = 0x24;
uint256 constant InvalidBasicOrderParameterEncoding_error_selector = 0x39f3e3fd;
uint256 constant InvalidBasicOrderParameterEncoding_error_length = 0x04;
uint256 constant NoSpecifiedOrdersAvailable_error_selector = 0xd5da9a1b;
uint256 constant NoSpecifiedOrdersAvailable_error_length = 0x04;
uint256 constant InvalidNativeOfferItem_error_selector = 0x12d3f5a3;
uint256 constant InvalidNativeOfferItem_error_length = 0x04;
uint256 constant Panic_error_selector = 0x4e487b71;
uint256 constant Panic_error_code_ptr = 0x20;
uint256 constant Panic_error_length = 0x24;
enum OrderType {
    FULL_OPEN,
    PARTIAL_OPEN,
    FULL_RESTRICTED,
    PARTIAL_RESTRICTED,
    CONTRACT
}
enum BasicOrderType {
    ETH_TO_ERC721_FULL_OPEN,
    ETH_TO_ERC721_PARTIAL_OPEN,
    ETH_TO_ERC721_FULL_RESTRICTED,
    ETH_TO_ERC721_PARTIAL_RESTRICTED,
    ETH_TO_ERC1155_FULL_OPEN,
    ETH_TO_ERC1155_PARTIAL_OPEN,
    ETH_TO_ERC1155_FULL_RESTRICTED,
    ETH_TO_ERC1155_PARTIAL_RESTRICTED,
    ERC20_TO_ERC721_FULL_OPEN,
    ERC20_TO_ERC721_PARTIAL_OPEN,
    ERC20_TO_ERC721_FULL_RESTRICTED,
    ERC20_TO_ERC721_PARTIAL_RESTRICTED,
    ERC20_TO_ERC1155_FULL_OPEN,
    ERC20_TO_ERC1155_PARTIAL_OPEN,
    ERC20_TO_ERC1155_FULL_RESTRICTED,
    ERC20_TO_ERC1155_PARTIAL_RESTRICTED,
    ERC721_TO_ERC20_FULL_OPEN,
    ERC721_TO_ERC20_PARTIAL_OPEN,
    ERC721_TO_ERC20_FULL_RESTRICTED,
    ERC721_TO_ERC20_PARTIAL_RESTRICTED,
    ERC1155_TO_ERC20_FULL_OPEN,
    ERC1155_TO_ERC20_PARTIAL_OPEN,
    ERC1155_TO_ERC20_FULL_RESTRICTED,
    ERC1155_TO_ERC20_PARTIAL_RESTRICTED
}
enum BasicOrderRouteType {
    ETH_TO_ERC721,
    ETH_TO_ERC1155,
    ERC20_TO_ERC721,
    ERC20_TO_ERC1155,
    ERC721_TO_ERC20,
    ERC1155_TO_ERC20
}
enum ItemType {
    NATIVE,
    ERC20,
    ERC721,
    ERC1155,
    ERC721_WITH_CRITERIA,
    ERC1155_WITH_CRITERIA
}
enum Side {
    OFFER,
    CONSIDERATION
}
abstract contract Auth {
    event OwnershipTransferred(address indexed user, address indexed newOwner);
    event AuthorityUpdated(address indexed user, Authority indexed newAuthority);
    address public owner;
    Authority public authority;
    constructor(address _owner, Authority _authority) {
        owner = _owner;
        authority = _authority;
        emit OwnershipTransferred(msg.sender, _owner);
        emit AuthorityUpdated(msg.sender, _authority);
    }
    modifier requiresAuth() virtual {
        require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");
        _;
    }
    function isAuthorized(address user, bytes4 functionSig) internal view virtual returns (bool) {
        Authority auth = authority; 
        return (address(auth) != address(0) && auth.canCall(user, address(this), functionSig)) || user == owner;
    }
    function setAuthority(Authority newAuthority) public virtual {
        require(msg.sender == owner || authority.canCall(msg.sender, address(this), msg.sig));
        authority = newAuthority;
        emit AuthorityUpdated(msg.sender, newAuthority);
    }
    function transferOwnership(address newOwner) public virtual requiresAuth {
        owner = newOwner;
        emit OwnershipTransferred(msg.sender, newOwner);
    }
}
interface Authority {
    function canCall(
        address user,
        address target,
        bytes4 functionSig
    ) external view returns (bool);
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
abstract contract ERC721_0 {
    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Approval(address indexed owner, address indexed spender, uint256 indexed id);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    string public name;
    string public symbol;
    function tokenURI(uint256 id) public view virtual returns (string memory);
    mapping(uint256 => address) internal _ownerOf;
    mapping(address => uint256) internal _balanceOf;
    function ownerOf(uint256 id) public view virtual returns (address owner) {
        require((owner = _ownerOf[id]) != address(0), "NOT_MINTED");
    }
    function balanceOf(address owner) public view virtual returns (uint256) {
        require(owner != address(0), "ZERO_ADDRESS");
        return _balanceOf[owner];
    }
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    function approve(address spender, uint256 id) public virtual {
        address owner = _ownerOf[id];
        require(msg.sender == owner || isApprovedForAll[owner][msg.sender], "NOT_AUTHORIZED");
        getApproved[id] = spender;
        emit Approval(owner, spender, id);
    }
    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }
    function transferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        require(from == _ownerOf[id], "WRONG_FROM");
        require(to != address(0), "INVALID_RECIPIENT");
        require(
            msg.sender == from || isApprovedForAll[from][msg.sender] || msg.sender == getApproved[id],
            "NOT_AUTHORIZED"
        );
        unchecked {
            _balanceOf[from]--;
            _balanceOf[to]++;
        }
        _ownerOf[id] = to;
        delete getApproved[id];
        emit Transfer(from, to, id);
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver_0(to).onERC721Received(msg.sender, from, id, "") ==
                ERC721TokenReceiver_0.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver_0(to).onERC721Received(msg.sender, from, id, data) ==
                ERC721TokenReceiver_0.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
    function supportsInterface(bytes4 interfaceId) public view virtual returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || 
            interfaceId == 0x80ac58cd || 
            interfaceId == 0x5b5e139f; 
    }
    function _mint(address to, uint256 id) internal virtual {
        require(to != address(0), "INVALID_RECIPIENT");
        require(_ownerOf[id] == address(0), "ALREADY_MINTED");
        unchecked {
            _balanceOf[to]++;
        }
        _ownerOf[id] = to;
        emit Transfer(address(0), to, id);
    }
    function _burn(uint256 id) internal virtual {
        address owner = _ownerOf[id];
        require(owner != address(0), "NOT_MINTED");
        unchecked {
            _balanceOf[owner]--;
        }
        delete _ownerOf[id];
        delete getApproved[id];
        emit Transfer(owner, address(0), id);
    }
    function _safeMint(address to, uint256 id) internal virtual {
        _mint(to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver_0(to).onERC721Received(msg.sender, address(0), id, "") ==
                ERC721TokenReceiver_0.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
    function _safeMint(
        address to,
        uint256 id,
        bytes memory data
    ) internal virtual {
        _mint(to, id);
        require(
            to.code.length == 0 ||
                ERC721TokenReceiver_0(to).onERC721Received(msg.sender, address(0), id, data) ==
                ERC721TokenReceiver_0.onERC721Received.selector,
            "UNSAFE_RECIPIENT"
        );
    }
}
abstract contract ERC721TokenReceiver_0 {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721TokenReceiver_0.onERC721Received.selector;
    }
}
library Bytes32AddressLib {
    function fromLast20Bytes(bytes32 bytesValue) internal pure returns (address) {
        return address(uint160(uint256(bytesValue)));
    }
    function fillLast12Bytes(address addressValue) internal pure returns (bytes32) {
        return bytes32(bytes20(addressValue));
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
interface IBeacon {
  function getImpl(uint8) external view returns (address);
}
interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC20 {
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
interface IERC721Receiver {
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external returns (bytes4);
}
interface IFlashAction {
  struct Underlying {
    address returnTarget;
    address token;
    uint256 tokenId;
  }
  function onFlashAction(Underlying calldata, bytes calldata)
    external
    returns (bytes32);
}
interface ITransferProxy {
  function tokenTransferFrom(
    address token,
    address from,
    address to,
    uint256 amount
  ) external;
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
    return
      functionCallWithValue(target, data, 0, "Address: low-level call failed");
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
    (bool success, bytes memory returndata) = target.call{value: value}(data);
    return
      verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
    (bool success, bytes memory returndata) = target.staticcall(data);
    return
      verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
    (bool success, bytes memory returndata) = target.delegatecall(data);
    return
      verifyCallResultFromTarget(target, success, returndata, errorMessage);
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
  function _revert(bytes memory returndata, string memory errorMessage)
    private
    pure
  {
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
abstract contract Initializable {
  uint256 private constant INITIALIZER_SLOT =
    uint256(
      uint256(keccak256("core.astaria.xyz.initializer.storage.location")) - 1
    );
  struct InitializerState {
    uint8 _initialized;
    bool _initializing;
  }
  event Initialized(uint8 version);
  function _getInitializerSlot()
    private
    view
    returns (InitializerState storage state)
  {
    uint256 slot = INITIALIZER_SLOT;
    assembly {
      state.slot := slot
    }
  }
  modifier initializer() {
    InitializerState storage s = _getInitializerSlot();
    bool isTopLevelCall = !s._initializing;
    require(
      (isTopLevelCall && s._initialized < 1) ||
        (!Address.isContract(address(this)) && s._initialized == 1),
      "Initializable: contract is already initialized"
    );
    s._initialized = 1;
    if (isTopLevelCall) {
      s._initializing = true;
    }
    _;
    if (isTopLevelCall) {
      s._initializing = false;
      emit Initialized(1);
    }
  }
  modifier reinitializer(uint8 version) {
    InitializerState storage s = _getInitializerSlot();
    require(
      !s._initializing && s._initialized < version,
      "Initializable: contract is already initialized"
    );
    s._initialized = version;
    s._initializing = true;
    _;
    s._initializing = false;
    emit Initialized(version);
  }
  modifier onlyInitializing() {
    InitializerState storage s = _getInitializerSlot();
    require(s._initializing, "Initializable: contract is not initializing");
    _;
  }
  function _disableInitializers() internal virtual {
    InitializerState storage s = _getInitializerSlot();
    require(!s._initializing, "Initializable: contract is initializing");
    if (s._initialized < type(uint8).max) {
      s._initialized = type(uint8).max;
      emit Initialized(type(uint8).max);
    }
  }
}
library Math {
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }
  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
  function average(uint256 a, uint256 b) internal pure returns (uint256) {
    return (a & b) + (a ^ b) / 2;
  }
  function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256 ret) {
    assembly {
      if iszero(b) {
        revert(0, 0)
      }
      ret := add(div(a, b), gt(mod(a, b), 0x0))
    }
  }
}
interface IPausable {
  function paused() external view returns (bool);
}
abstract contract Pausable is IPausable {
  uint256 private constant PAUSE_SLOT =
    uint256(keccak256("xyz.astaria.AstariaRouter.Pausable.storage.location")) -
      1;
  event Paused(address account);
  event Unpaused(address account);
  struct PauseStorage {
    bool _paused;
  }
  function _loadPauseSlot() internal pure returns (PauseStorage storage s) {
    uint256 slot = PAUSE_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function paused() public view virtual returns (bool) {
    return _loadPauseSlot()._paused;
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
    _loadPauseSlot()._paused = true;
    emit Paused(msg.sender);
  }
  function _unpause() internal virtual whenPaused {
    _loadPauseSlot()._paused = false;
    emit Unpaused(msg.sender);
  }
}
struct OrderComponents {
    address offerer;
    address zone;
    OfferItem[] offer;
    ConsiderationItem[] consideration;
    OrderType orderType;
    uint256 startTime;
    uint256 endTime;
    bytes32 zoneHash;
    uint256 salt;
    bytes32 conduitKey;
    uint256 counter;
}
struct OfferItem {
    ItemType itemType;
    address token;
    uint256 identifierOrCriteria;
    uint256 startAmount;
    uint256 endAmount;
}
struct ConsiderationItem {
    ItemType itemType;
    address token;
    uint256 identifierOrCriteria;
    uint256 startAmount;
    uint256 endAmount;
    address payable recipient;
}
struct SpentItem {
    ItemType itemType;
    address token;
    uint256 identifier;
    uint256 amount;
}
struct ReceivedItem {
    ItemType itemType;
    address token;
    uint256 identifier;
    uint256 amount;
    address payable recipient;
}
struct BasicOrderParameters {
    address considerationToken; 
    uint256 considerationIdentifier; 
    uint256 considerationAmount; 
    address payable offerer; 
    address zone; 
    address offerToken; 
    uint256 offerIdentifier; 
    uint256 offerAmount; 
    BasicOrderType basicOrderType; 
    uint256 startTime; 
    uint256 endTime; 
    bytes32 zoneHash; 
    uint256 salt; 
    bytes32 offererConduitKey; 
    bytes32 fulfillerConduitKey; 
    uint256 totalOriginalAdditionalRecipients; 
    AdditionalRecipient[] additionalRecipients; 
    bytes signature; 
}
struct AdditionalRecipient {
    uint256 amount;
    address payable recipient;
}
struct OrderParameters {
    address offerer; 
    address zone; 
    OfferItem[] offer; 
    ConsiderationItem[] consideration; 
    OrderType orderType; 
    uint256 startTime; 
    uint256 endTime; 
    bytes32 zoneHash; 
    uint256 salt; 
    bytes32 conduitKey; 
    uint256 totalOriginalConsiderationItems; 
}
struct Order {
    OrderParameters parameters;
    bytes signature;
}
struct AdvancedOrder {
    OrderParameters parameters;
    uint120 numerator;
    uint120 denominator;
    bytes signature;
    bytes extraData;
}
struct OrderStatus {
    bool isValidated;
    bool isCancelled;
    uint120 numerator;
    uint120 denominator;
}
struct CriteriaResolver {
    uint256 orderIndex;
    Side side;
    uint256 index;
    uint256 identifier;
    bytes32[] criteriaProof;
}
struct Fulfillment {
    FulfillmentComponent[] offerComponents;
    FulfillmentComponent[] considerationComponents;
}
struct FulfillmentComponent {
    uint256 orderIndex;
    uint256 itemIndex;
}
struct Execution {
    ReceivedItem item;
    address offerer;
    bytes32 conduitKey;
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
            mstore(add(freeMemoryPointer, 4), from) 
            mstore(add(freeMemoryPointer, 36), to) 
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
            mstore(add(freeMemoryPointer, 4), to) 
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
            mstore(add(freeMemoryPointer, 4), to) 
            mstore(add(freeMemoryPointer, 36), amount) 
            success := and(
                or(and(eq(mload(0), 1), gt(returndatasize(), 31)), iszero(returndatasize())),
                call(gas(), token, 0, freeMemoryPointer, 68, 0, 32)
            )
        }
        require(success, "APPROVE_FAILED");
    }
}
abstract contract AuthInitializable {
  event OwnershipTransferred(address indexed user, address indexed newOwner);
  event AuthorityUpdated(address indexed user, Authority indexed newAuthority);
  uint256 private constant authSlot =
    uint256(uint256(keccak256("xyz.astaria.Auth.storage.location")) - 1);
  struct AuthStorage {
    address owner;
    Authority authority;
  }
  function _getAuthSlot() internal view returns (AuthStorage storage s) {
    uint256 slot = authSlot;
    assembly {
      s.slot := slot
    }
  }
  function __initAuth(address _owner, address _authority) internal {
    AuthStorage storage s = _getAuthSlot();
    require(s.owner == address(0), "Already initialized");
    s.owner = _owner;
    s.authority = Authority(_authority);
    emit OwnershipTransferred(msg.sender, _owner);
    emit AuthorityUpdated(msg.sender, Authority(_authority));
  }
  modifier requiresAuth() virtual {
    require(isAuthorized(msg.sender, msg.sig), "UNAUTHORIZED");
    _;
  }
  function owner() public view returns (address) {
    return _getAuthSlot().owner;
  }
  function authority() public view returns (Authority) {
    return _getAuthSlot().authority;
  }
  function isAuthorized(address user, bytes4 functionSig)
    internal
    view
    virtual
    returns (bool)
  {
    AuthStorage storage s = _getAuthSlot();
    Authority auth = s.authority; 
    return
      (address(auth) != address(0) &&
        auth.canCall(user, address(this), functionSig)) || user == s.owner;
  }
  function setAuthority(Authority newAuthority) public virtual {
    AuthStorage storage s = _getAuthSlot();
    require(
      msg.sender == s.owner ||
        s.authority.canCall(msg.sender, address(this), msg.sig)
    );
    s.authority = newAuthority;
    emit AuthorityUpdated(msg.sender, newAuthority);
  }
  function transferOwnership(address newOwner) public virtual requiresAuth {
    AuthStorage storage s = _getAuthSlot();
    s.owner = newOwner;
    emit OwnershipTransferred(msg.sender, newOwner);
  }
}
interface IERC1155 is IERC165 {
  event TransferSingle(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256 id,
    uint256 value
  );
  event TransferBatch(
    address indexed operator,
    address indexed from,
    address indexed to,
    uint256[] ids,
    uint256[] values
  );
  event ApprovalForAll(
    address indexed account,
    address indexed operator,
    bool approved
  );
  event URI(string value, uint256 indexed id);
  function balanceOf(address account, uint256 id)
    external
    view
    returns (uint256);
  function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
    external
    view
    returns (uint256[] memory);
  function setApprovalForAll(address operator, bool approved) external;
  function isApprovedForAll(address account, address operator)
    external
    view
    returns (bool);
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    uint256 amount,
    bytes calldata data
  ) external;
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
  ) external;
}
interface IERC20Metadata is IERC20 {
  function name() external view returns (string memory);
  function symbol() external view returns (string memory);
  function decimals() external view returns (uint8);
}
interface IERC721 is IERC165 {
  event Transfer(address indexed from, address indexed to, uint256 indexed id);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 indexed id
  );
  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );
  function tokenURI(uint256 id) external view returns (string memory);
  function ownerOf(uint256 id) external view returns (address owner);
  function balanceOf(address owner) external view returns (uint256 balance);
  function approve(address spender, uint256 id) external;
  function setApprovalForAll(address operator, bool approved) external;
  function transferFrom(
    address from,
    address to,
    uint256 id
  ) external;
  function safeTransferFrom(
    address from,
    address to,
    uint256 id
  ) external;
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    bytes calldata data
  ) external;
}
abstract contract ERC20Cloned is IERC20Metadata {
  uint256 constant ERC20_SLOT =
    uint256(keccak256("xyz.astaria.ERC20.storage.location")) - 1;
  bytes32 private constant PERMIT_TYPEHASH =
    keccak256(
      "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
    );
  struct ERC20Data {
    uint256 _totalSupply;
    mapping(address => uint256) balanceOf;
    mapping(address => mapping(address => uint256)) allowance;
    mapping(address => uint256) nonces;
  }
  function _loadERC20Slot() internal pure returns (ERC20Data storage s) {
    uint256 slot = ERC20_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function balanceOf(address account) external view returns (uint256) {
    return _loadERC20Slot().balanceOf[account];
  }
  function approve(address spender, uint256 amount)
    public
    virtual
    returns (bool)
  {
    ERC20Data storage s = _loadERC20Slot();
    s.allowance[msg.sender][spender] = amount;
    emit Approval(msg.sender, spender, amount);
    return true;
  }
  function transfer(address to, uint256 amount) public virtual returns (bool) {
    ERC20Data storage s = _loadERC20Slot();
    s.balanceOf[msg.sender] -= amount;
    unchecked {
      s.balanceOf[to] += amount;
    }
    emit Transfer(msg.sender, to, amount);
    return true;
  }
  function allowance(address owner, address spender)
    external
    view
    returns (uint256)
  {
    ERC20Data storage s = _loadERC20Slot();
    return s.allowance[owner][spender];
  }
  function totalSupply() public view virtual returns (uint256) {
    ERC20Data storage s = _loadERC20Slot();
    return s._totalSupply;
  }
  function transferFrom(
    address from,
    address to,
    uint256 amount
  ) public virtual returns (bool) {
    ERC20Data storage s = _loadERC20Slot();
    uint256 allowed = s.allowance[from][msg.sender]; 
    if (allowed != type(uint256).max) {
      s.allowance[from][msg.sender] = allowed - amount;
    }
    s.balanceOf[from] -= amount;
    unchecked {
      s.balanceOf[to] += amount;
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
                PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _loadERC20Slot().nonces[owner]++,
                deadline
              )
            )
          )
        ),
        v,
        r,
        s
      );
      require(
        recoveredAddress != address(0) && recoveredAddress == owner,
        "INVALID_SIGNER"
      );
      _loadERC20Slot().allowance[recoveredAddress][spender] = value;
    }
    emit Approval(owner, spender, value);
  }
  function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
    return computeDomainSeparator();
  }
  function computeDomainSeparator() internal view virtual returns (bytes32) {
    return
      keccak256(
        abi.encode(
          keccak256(
            "EIP712Domain(string version,uint256 chainId,address verifyingContract)"
          ),
          keccak256("1"),
          block.chainid,
          address(this)
        )
      );
  }
  function _mint(address to, uint256 amount) internal virtual {
    ERC20Data storage s = _loadERC20Slot();
    s._totalSupply += amount;
    unchecked {
      s.balanceOf[to] += amount;
    }
    emit Transfer(address(0), to, amount);
  }
  function _burn(address from, uint256 amount) internal virtual {
    ERC20Data storage s = _loadERC20Slot();
    s.balanceOf[from] -= amount;
    unchecked {
      s._totalSupply -= amount;
    }
    emit Transfer(from, address(0), amount);
  }
}
interface ConsiderationInterface {
    function fulfillBasicOrder(BasicOrderParameters calldata parameters)
        external
        payable
        returns (bool fulfilled);
    function fulfillOrder(Order calldata order, bytes32 fulfillerConduitKey)
        external
        payable
        returns (bool fulfilled);
    function fulfillAdvancedOrder(
        AdvancedOrder calldata advancedOrder,
        CriteriaResolver[] calldata criteriaResolvers,
        bytes32 fulfillerConduitKey,
        address recipient
    ) external payable returns (bool fulfilled);
    function fulfillAvailableOrders(
        Order[] calldata orders,
        FulfillmentComponent[][] calldata offerFulfillments,
        FulfillmentComponent[][] calldata considerationFulfillments,
        bytes32 fulfillerConduitKey,
        uint256 maximumFulfilled
    )
        external
        payable
        returns (bool[] memory availableOrders, Execution[] memory executions);
    function fulfillAvailableAdvancedOrders(
        AdvancedOrder[] calldata advancedOrders,
        CriteriaResolver[] calldata criteriaResolvers,
        FulfillmentComponent[][] calldata offerFulfillments,
        FulfillmentComponent[][] calldata considerationFulfillments,
        bytes32 fulfillerConduitKey,
        address recipient,
        uint256 maximumFulfilled
    )
        external
        payable
        returns (bool[] memory availableOrders, Execution[] memory executions);
    function matchOrders(
        Order[] calldata orders,
        Fulfillment[] calldata fulfillments
    ) external payable returns (Execution[] memory executions);
    function matchAdvancedOrders(
        AdvancedOrder[] calldata orders,
        CriteriaResolver[] calldata criteriaResolvers,
        Fulfillment[] calldata fulfillments
    ) external payable returns (Execution[] memory executions);
    function cancel(OrderComponents[] calldata orders)
        external
        returns (bool cancelled);
    function validate(Order[] calldata orders)
        external
        returns (bool validated);
    function incrementCounter() external returns (uint256 newCounter);
    function getOrderHash(OrderComponents calldata order)
        external
        view
        returns (bytes32 orderHash);
    function getOrderStatus(bytes32 orderHash)
        external
        view
        returns (
            bool isValidated,
            bool isCancelled,
            uint256 totalFilled,
            uint256 totalSize
        );
    function getCounter(address offerer)
        external
        view
        returns (uint256 counter);
    function information()
        external
        view
        returns (
            string memory version,
            bytes32 domainSeparator,
            address conduitController
        );
    function getContractOffererNonce(address contractOfferer)
        external
        view
        returns (uint256 nonce);
    function name() external view returns (string memory contractName);
}
contract AmountDeriver is AmountDerivationErrors {
    function _locateCurrentAmount(
        uint256 startAmount,
        uint256 endAmount,
        uint256 startTime,
        uint256 endTime,
        bool roundUp
    ) internal view returns (uint256 amount) {
        if (startAmount != endAmount) {
            uint256 duration;
            uint256 elapsed;
            uint256 remaining;
            unchecked {
                duration = endTime - startTime;
                elapsed = block.timestamp - startTime;
                remaining = duration - elapsed;
            }
            uint256 totalBeforeDivision = ((startAmount * remaining) +
                (endAmount * elapsed));
            assembly {
                amount := mul(
                    iszero(iszero(totalBeforeDivision)),
                    add(
                        div(sub(totalBeforeDivision, roundUp), duration),
                        roundUp
                    )
                )
            }
            return amount;
        }
        return endAmount;
    }
    function _getFraction(
        uint256 numerator,
        uint256 denominator,
        uint256 value
    ) internal pure returns (uint256 newValue) {
        if (numerator == denominator) {
            return value;
        }
        assembly {
            if mulmod(value, numerator, denominator) {
                mstore(0, InexactFraction_error_selector)
                revert(0x1c, InexactFraction_error_length)
            }
        }
        uint256 valueTimesNumerator = value * numerator;
        assembly {
            newValue := div(valueTimesNumerator, denominator)
        }
    }
    function _applyFraction(
        uint256 startAmount,
        uint256 endAmount,
        uint256 numerator,
        uint256 denominator,
        uint256 startTime,
        uint256 endTime,
        bool roundUp
    ) internal view returns (uint256 amount) {
        if (startAmount == endAmount) {
            amount = _getFraction(numerator, denominator, endAmount);
        } else {
            amount = _locateCurrentAmount(
                _getFraction(numerator, denominator, startAmount),
                _getFraction(numerator, denominator, endAmount),
                startTime,
                endTime,
                roundUp
            );
        }
    }
}
contract WETH is ERC20("Wrapped Ether", "WETH", 18) {
    using SafeTransferLib for address;
    event Deposit(address indexed from, uint256 amount);
    event Withdrawal(address indexed to, uint256 amount);
    function deposit() public payable virtual {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }
    function withdraw(uint256 amount) public virtual {
        _burn(msg.sender, amount);
        emit Withdrawal(msg.sender, amount);
        msg.sender.safeTransferETH(amount);
    }
    receive() external payable virtual {
        deposit();
    }
}
interface IERC4626 is IERC20, IERC20Metadata {
  event Deposit(
    address indexed sender,
    address indexed owner,
    uint256 assets,
    uint256 shares
  );
  event Withdraw(
    address indexed sender,
    address indexed receiver,
    address indexed owner,
    uint256 assets,
    uint256 shares
  );
  function asset() external view returns (address assetTokenAddress);
  function totalAssets() external view returns (uint256 totalManagedAssets);
  function convertToShares(uint256 assets)
    external
    view
    returns (uint256 shares);
  function convertToAssets(uint256 shares)
    external
    view
    returns (uint256 assets);
  function maxDeposit(address receiver)
    external
    view
    returns (uint256 maxAssets);
  function previewDeposit(uint256 assets)
    external
    view
    returns (uint256 shares);
  function deposit(uint256 assets, address receiver)
    external
    returns (uint256 shares);
  function maxMint(address receiver) external view returns (uint256 maxShares);
  function previewMint(uint256 shares) external view returns (uint256 assets);
  function mint(uint256 shares, address receiver)
    external
    returns (uint256 assets);
  function maxWithdraw(address owner) external view returns (uint256 maxAssets);
  function previewWithdraw(uint256 assets)
    external
    view
    returns (uint256 shares);
  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  ) external returns (uint256 shares);
  function maxRedeem(address owner) external view returns (uint256 maxShares);
  function previewRedeem(uint256 shares) external view returns (uint256 assets);
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) external returns (uint256 assets);
}
library CollateralLookup {
  function computeId(address token, uint256 tokenId)
    internal
    pure
    returns (uint256 hash)
  {
    assembly {
      mstore(0, token) 
      mstore(0x20, tokenId) 
      hash := keccak256(12, 52) 
    }
  }
}
abstract contract ERC721_1 is Initializable, IERC721 {
  uint256 private constant ERC721_SLOT =
    uint256(keccak256("xyz.astaria.ERC721.storage.location")) - 1;
  struct ERC721Storage {
    string name;
    string symbol;
    mapping(uint256 => address) _ownerOf;
    mapping(address => uint256) _balanceOf;
    mapping(uint256 => address) getApproved;
    mapping(address => mapping(address => bool)) isApprovedForAll;
  }
  function getApproved(uint256 tokenId) public view returns (address) {
    return _loadERC721Slot().getApproved[tokenId];
  }
  function isApprovedForAll(address owner, address operator)
    public
    view
    returns (bool)
  {
    return _loadERC721Slot().isApprovedForAll[owner][operator];
  }
  function tokenURI(uint256 id) external view virtual returns (string memory);
  function _loadERC721Slot() internal pure returns (ERC721Storage storage s) {
    uint256 slot = ERC721_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function ownerOf(uint256 id) public view virtual returns (address owner) {
    require(
      (owner = _loadERC721Slot()._ownerOf[id]) != address(0),
      "NOT_MINTED"
    );
  }
  function balanceOf(address owner) public view virtual returns (uint256) {
    require(owner != address(0), "ZERO_ADDRESS");
    return _loadERC721Slot()._balanceOf[owner];
  }
  function __initERC721(string memory _name, string memory _symbol) internal {
    ERC721Storage storage s = _loadERC721Slot();
    s.name = _name;
    s.symbol = _symbol;
  }
  function name() public view returns (string memory) {
    return _loadERC721Slot().name;
  }
  function symbol() public view returns (string memory) {
    return _loadERC721Slot().symbol;
  }
  function approve(address spender, uint256 id) external virtual {
    ERC721Storage storage s = _loadERC721Slot();
    address owner = s._ownerOf[id];
    require(
      msg.sender == owner || s.isApprovedForAll[owner][msg.sender],
      "NOT_AUTHORIZED"
    );
    s.getApproved[id] = spender;
    emit Approval(owner, spender, id);
  }
  function setApprovalForAll(address operator, bool approved) external virtual {
    _loadERC721Slot().isApprovedForAll[msg.sender][operator] = approved;
    emit ApprovalForAll(msg.sender, operator, approved);
  }
  function transferFrom(
    address from,
    address to,
    uint256 id
  ) public virtual override(IERC721) {
    ERC721Storage storage s = _loadERC721Slot();
    require(from == s._ownerOf[id], "WRONG_FROM");
    require(to != address(0), "INVALID_RECIPIENT");
    require(
      msg.sender == from ||
        s.isApprovedForAll[from][msg.sender] ||
        msg.sender == s.getApproved[id],
      "NOT_AUTHORIZED"
    );
    _transfer(from, to, id);
  }
  function _transfer(
    address from,
    address to,
    uint256 id
  ) internal {
    ERC721Storage storage s = _loadERC721Slot();
    unchecked {
      s._balanceOf[from]--;
      s._balanceOf[to]++;
    }
    s._ownerOf[id] = to;
    delete s.getApproved[id];
    emit Transfer(from, to, id);
  }
  function safeTransferFrom(
    address from,
    address to,
    uint256 id
  ) external virtual {
    transferFrom(from, to, id);
    require(
      to.code.length == 0 ||
        ERC721TokenReceiver_1(to).onERC721Received(msg.sender, from, id, "") ==
        ERC721TokenReceiver_1.onERC721Received.selector,
      "UNSAFE_RECIPIENT"
    );
  }
  function safeTransferFrom(
    address from,
    address to,
    uint256 id,
    bytes calldata data
  ) external override(IERC721) {
    transferFrom(from, to, id);
    require(
      to.code.length == 0 ||
        ERC721TokenReceiver_1(to).onERC721Received(msg.sender, from, id, data) ==
        ERC721TokenReceiver_1.onERC721Received.selector,
      "UNSAFE_RECIPIENT"
    );
  }
  function supportsInterface(bytes4 interfaceId)
    public
    view
    virtual
    returns (bool)
  {
    return
      interfaceId == 0x01ffc9a7 || 
      interfaceId == 0x80ac58cd || 
      interfaceId == 0x5b5e139f; 
  }
  function _mint(address to, uint256 id) internal virtual {
    require(to != address(0), "INVALID_RECIPIENT");
    ERC721Storage storage s = _loadERC721Slot();
    require(s._ownerOf[id] == address(0), "ALREADY_MINTED");
    unchecked {
      s._balanceOf[to]++;
    }
    s._ownerOf[id] = to;
    emit Transfer(address(0), to, id);
  }
  function _burn(uint256 id) internal virtual {
    ERC721Storage storage s = _loadERC721Slot();
    address owner = s._ownerOf[id];
    require(owner != address(0), "NOT_MINTED");
    unchecked {
      s._balanceOf[owner]--;
    }
    delete s._ownerOf[id];
    delete s.getApproved[id];
    emit Transfer(owner, address(0), id);
  }
  function _safeMint(address to, uint256 id) internal virtual {
    _mint(to, id);
    require(
      to.code.length == 0 ||
        ERC721TokenReceiver_1(to).onERC721Received(
          msg.sender,
          address(0),
          id,
          ""
        ) ==
        ERC721TokenReceiver_1.onERC721Received.selector,
      "UNSAFE_RECIPIENT"
    );
  }
  function _safeMint(
    address to,
    uint256 id,
    bytes memory data
  ) internal virtual {
    _mint(to, id);
    require(
      to.code.length == 0 ||
        ERC721TokenReceiver_1(to).onERC721Received(
          msg.sender,
          address(0),
          id,
          data
        ) ==
        ERC721TokenReceiver_1.onERC721Received.selector,
      "UNSAFE_RECIPIENT"
    );
  }
}
abstract contract ERC721TokenReceiver_1 {
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external virtual returns (bytes4) {
    return ERC721TokenReceiver_1.onERC721Received.selector;
  }
}
interface IERC4626RouterBase {
  error MinAmountError();
  error MinSharesError();
  error MaxAmountError();
  error MaxSharesError();
  function mint(
    IERC4626 vault,
    address to,
    uint256 shares,
    uint256 maxAmountIn
  ) external payable returns (uint256 amountIn);
  function deposit(
    IERC4626 vault,
    address to,
    uint256 amount,
    uint256 minSharesOut
  ) external payable returns (uint256 sharesOut);
  function withdraw(
    IERC4626 vault,
    address to,
    uint256 amount,
    uint256 minSharesOut
  ) external payable returns (uint256 sharesOut);
  function redeem(
    IERC4626 vault,
    address to,
    uint256 shares,
    uint256 minAmountOut
  ) external payable returns (uint256 amountOut);
}
abstract contract ERC4626 is ERC20 {
    using SafeTransferLib for ERC20;
    using FixedPointMathLib for uint256;
    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed caller,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    ERC20 public immutable asset;
    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC20(_name, _symbol, _asset.decimals()) {
        asset = _asset;
    }
    function deposit(uint256 assets, address receiver) public virtual returns (uint256 shares) {
        require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function mint(uint256 shares, address receiver) public virtual returns (uint256 assets) {
        assets = previewMint(shares); 
        asset.safeTransferFrom(msg.sender, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(msg.sender, receiver, assets, shares);
        afterDeposit(assets, shares);
    }
    function withdraw(
        uint256 assets,
        address receiver,
        address owner
    ) public virtual returns (uint256 shares) {
        shares = previewWithdraw(assets); 
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        asset.safeTransfer(receiver, assets);
    }
    function redeem(
        uint256 shares,
        address receiver,
        address owner
    ) public virtual returns (uint256 assets) {
        if (msg.sender != owner) {
            uint256 allowed = allowance[owner][msg.sender]; 
            if (allowed != type(uint256).max) allowance[owner][msg.sender] = allowed - shares;
        }
        require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
        beforeWithdraw(assets, shares);
        _burn(owner, shares);
        emit Withdraw(msg.sender, receiver, owner, assets, shares);
        asset.safeTransfer(receiver, assets);
    }
    function totalAssets() public view virtual returns (uint256);
    function convertToShares(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
    }
    function convertToAssets(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
    }
    function previewDeposit(uint256 assets) public view virtual returns (uint256) {
        return convertToShares(assets);
    }
    function previewMint(uint256 shares) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? shares : shares.mulDivUp(totalAssets(), supply);
    }
    function previewWithdraw(uint256 assets) public view virtual returns (uint256) {
        uint256 supply = totalSupply; 
        return supply == 0 ? assets : assets.mulDivUp(supply, totalAssets());
    }
    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return convertToAssets(shares);
    }
    function maxDeposit(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxMint(address) public view virtual returns (uint256) {
        return type(uint256).max;
    }
    function maxWithdraw(address owner) public view virtual returns (uint256) {
        return convertToAssets(balanceOf[owner]);
    }
    function maxRedeem(address owner) public view virtual returns (uint256) {
        return balanceOf[owner];
    }
    function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}
    function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
abstract contract ERC4626Cloned is IERC4626, ERC20Cloned {
  using SafeTransferLib for ERC20;
  using FixedPointMathLib for uint256;
  function minDepositAmount() public view virtual returns (uint256);
  function asset() public view virtual returns (address);
  function deposit(uint256 assets, address receiver)
    public
    virtual
    returns (uint256 shares)
  {
    require((shares = previewDeposit(assets)) != 0, "ZERO_SHARES");
    require(shares > minDepositAmount(), "VALUE_TOO_SMALL");
    ERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);
    _mint(receiver, shares);
    emit Deposit(msg.sender, receiver, assets, shares);
    afterDeposit(assets, shares);
  }
  function mint(
    uint256 shares,
    address receiver
  ) public virtual returns (uint256 assets) {
    assets = previewMint(shares); 
    require(assets > minDepositAmount(), "VALUE_TOO_SMALL");
    ERC20(asset()).safeTransferFrom(msg.sender, address(this), assets);
    _mint(receiver, shares);
    emit Deposit(msg.sender, receiver, assets, shares);
    afterDeposit(assets, shares);
  }
  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  ) public virtual returns (uint256 shares) {
    shares = previewWithdraw(assets); 
    ERC20Data storage s = _loadERC20Slot();
    if (msg.sender != owner) {
      uint256 allowed = s.allowance[owner][msg.sender]; 
      if (allowed != type(uint256).max) {
        s.allowance[owner][msg.sender] = allowed - shares;
      }
    }
    beforeWithdraw(assets, shares);
    _burn(owner, shares);
    emit Withdraw(msg.sender, receiver, owner, assets, shares);
    ERC20(asset()).safeTransfer(receiver, assets);
  }
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) public virtual returns (uint256 assets) {
    ERC20Data storage s = _loadERC20Slot();
    if (msg.sender != owner) {
      uint256 allowed = s.allowance[owner][msg.sender]; 
      if (allowed != type(uint256).max) {
        s.allowance[owner][msg.sender] = allowed - shares;
      }
    }
    require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
    beforeWithdraw(assets, shares);
    _burn(owner, shares);
    emit Withdraw(msg.sender, receiver, owner, assets, shares);
    ERC20(asset()).safeTransfer(receiver, assets);
  }
  function totalAssets() public view virtual returns (uint256);
  function convertToShares(
    uint256 assets
  ) public view virtual returns (uint256) {
    uint256 supply = totalSupply(); 
    return supply == 0 ? assets : assets.mulDivDown(supply, totalAssets());
  }
  function convertToAssets(
    uint256 shares
  ) public view virtual returns (uint256) {
    uint256 supply = totalSupply(); 
    return supply == 0 ? shares : shares.mulDivDown(totalAssets(), supply);
  }
  function previewDeposit(
    uint256 assets
  ) public view virtual returns (uint256) {
    return convertToShares(assets);
  }
  function previewMint(uint256 shares) public view virtual returns (uint256) {
    uint256 supply = totalSupply(); 
    return supply == 0 ? 10e18 : shares.mulDivUp(totalAssets(), supply);
  }
  function previewWithdraw(
    uint256 assets
  ) public view virtual returns (uint256) {
    uint256 supply = totalSupply(); 
    return supply == 0 ? 10e18 : assets.mulDivUp(supply, totalAssets());
  }
  function previewRedeem(uint256 shares) public view virtual returns (uint256) {
    return convertToAssets(shares);
  }
  function maxDeposit(address) public view virtual returns (uint256) {
    return type(uint256).max;
  }
  function maxMint(address) public view virtual returns (uint256) {
    return type(uint256).max;
  }
  function maxWithdraw(address owner) public view virtual returns (uint256) {
    ERC20Data storage s = _loadERC20Slot();
    return convertToAssets(s.balanceOf[owner]);
  }
  function maxRedeem(address owner) public view virtual returns (uint256) {
    ERC20Data storage s = _loadERC20Slot();
    return s.balanceOf[owner];
  }
  function beforeWithdraw(uint256 assets, uint256 shares) internal virtual {}
  function afterDeposit(uint256 assets, uint256 shares) internal virtual {}
}
contract ClearingHouse is AmountDeriver, Clone, IERC1155, IERC721Receiver {
  using Bytes32AddressLib for bytes32;
  using SafeTransferLib for ERC20;
  struct ClearingHouseStorage {
    ILienToken.AuctionData auctionStack;
  }
  uint256 private constant CLEARING_HOUSE_STORAGE_SLOT =
    uint256(keccak256("xyz.astaria.ClearingHouse.storage.location")) - 1;
  function ROUTER() public pure returns (IAstariaRouter) {
    return IAstariaRouter(_getArgAddress(0));
  }
  function COLLATERAL_ID() public pure returns (uint256) {
    return _getArgUint256(21);
  }
  function IMPL_TYPE() public pure returns (uint8) {
    return _getArgUint8(20);
  }
  function _getStorage()
    internal
    pure
    returns (ClearingHouseStorage storage s)
  {
    uint256 slot = CLEARING_HOUSE_STORAGE_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function setAuctionData(ILienToken.AuctionData calldata auctionData)
    external
  {
    IAstariaRouter ASTARIA_ROUTER = IAstariaRouter(_getArgAddress(0)); 
    require(msg.sender == address(ASTARIA_ROUTER.LIEN_TOKEN()));
    ClearingHouseStorage storage s = _getStorage();
    s.auctionStack = auctionData;
  }
  function supportsInterface(bytes4 interfaceId) external view returns (bool) {
    return interfaceId == type(IERC1155).interfaceId;
  }
  function balanceOf(address account, uint256 id)
    external
    view
    returns (uint256)
  {
    return type(uint256).max;
  }
  function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
    external
    view
    returns (uint256[] memory output)
  {
    output = new uint256[](accounts.length);
    for (uint256 i; i < accounts.length; ) {
      output[i] = type(uint256).max;
      unchecked {
        ++i;
      }
    }
  }
  function setApprovalForAll(address operator, bool approved) external {}
  function isApprovedForAll(address account, address operator)
    external
    view
    returns (bool)
  {
    return true;
  }
  function _execute(
    address tokenContract, 
    address to, 
    uint256 encodedMetaData, 
    uint256 
  ) internal {
    IAstariaRouter ASTARIA_ROUTER = IAstariaRouter(_getArgAddress(0)); 
    ClearingHouseStorage storage s = _getStorage();
    address paymentToken = bytes32(encodedMetaData).fromLast20Bytes();
    uint256 currentOfferPrice = _locateCurrentAmount({
      startAmount: s.auctionStack.startAmount,
      endAmount: s.auctionStack.endAmount,
      startTime: s.auctionStack.startTime,
      endTime: s.auctionStack.endTime,
      roundUp: true 
    });
    uint256 payment = ERC20(paymentToken).balanceOf(address(this));
    require(payment >= currentOfferPrice, "not enough funds received");
    uint256 collateralId = _getArgUint256(21);
    ILienToken.AuctionStack[] storage stack = s.auctionStack.stack;
    uint256 liquidatorPayment = ASTARIA_ROUTER.getLiquidatorFee(payment);
    ERC20(paymentToken).safeTransfer(
      s.auctionStack.liquidator,
      liquidatorPayment
    );
    ERC20(paymentToken).safeApprove(
      address(ASTARIA_ROUTER.TRANSFER_PROXY()),
      payment - liquidatorPayment
    );
    ASTARIA_ROUTER.LIEN_TOKEN().payDebtViaClearingHouse(
      paymentToken,
      collateralId,
      payment - liquidatorPayment,
      s.auctionStack.stack
    );
    if (ERC20(paymentToken).balanceOf(address(this)) > 0) {
      ERC20(paymentToken).safeTransfer(
        ASTARIA_ROUTER.COLLATERAL_TOKEN().ownerOf(collateralId),
        ERC20(paymentToken).balanceOf(address(this))
      );
    }
    ASTARIA_ROUTER.COLLATERAL_TOKEN().settleAuction(collateralId);
  }
  function safeTransferFrom(
    address from, 
    address to,
    uint256 identifier,
    uint256 amount,
    bytes calldata data 
  ) public {
    _execute(from, to, identifier, amount);
  }
  function safeBatchTransferFrom(
    address from,
    address to,
    uint256[] calldata ids,
    uint256[] calldata amounts,
    bytes calldata data
  ) public {}
  function onERC721Received(
    address operator_,
    address from_,
    uint256 tokenId_,
    bytes calldata data_
  ) external override returns (bytes4) {
    return IERC721Receiver.onERC721Received.selector;
  }
  function validateOrder(Order memory order) external {
    IAstariaRouter ASTARIA_ROUTER = IAstariaRouter(_getArgAddress(0));
    require(msg.sender == address(ASTARIA_ROUTER.COLLATERAL_TOKEN()));
    Order[] memory listings = new Order[](1);
    listings[0] = order;
    ERC721_0(order.parameters.offer[0].token).approve(
      ASTARIA_ROUTER.COLLATERAL_TOKEN().getConduit(),
      order.parameters.offer[0].identifierOrCriteria
    );
    ASTARIA_ROUTER.COLLATERAL_TOKEN().SEAPORT().validate(listings);
  }
  function transferUnderlying(
    address tokenContract,
    uint256 tokenId,
    address target
  ) external {
    IAstariaRouter ASTARIA_ROUTER = IAstariaRouter(_getArgAddress(0));
    require(msg.sender == address(ASTARIA_ROUTER.COLLATERAL_TOKEN()));
    ERC721_0(tokenContract).safeTransferFrom(address(this), target, tokenId);
  }
  function settleLiquidatorNFTClaim() external {
    IAstariaRouter ASTARIA_ROUTER = IAstariaRouter(_getArgAddress(0));
    require(msg.sender == address(ASTARIA_ROUTER.COLLATERAL_TOKEN()));
    ClearingHouseStorage storage s = _getStorage();
    ASTARIA_ROUTER.LIEN_TOKEN().payDebtViaClearingHouse(
      address(0),
      COLLATERAL_ID(),
      0,
      s.auctionStack.stack
    );
  }
}
interface IAstariaRouter is IPausable, IBeacon {
  enum FileType {
    FeeTo,
    LiquidationFee,
    ProtocolFee,
    StrategistFee,
    MinInterestBPS,
    MinEpochLength,
    MaxEpochLength,
    MinInterestRate,
    MaxInterestRate,
    BuyoutFee,
    MinDurationIncrease,
    AuctionWindow,
    StrategyValidator,
    Implementation,
    CollateralToken,
    LienToken,
    TransferProxy
  }
  struct File {
    FileType what;
    bytes data;
  }
  event FileUpdated(FileType what, bytes data);
  struct RouterStorage {
    uint32 auctionWindow;
    uint32 auctionWindowBuffer;
    uint32 liquidationFeeNumerator;
    uint32 liquidationFeeDenominator;
    uint32 maxEpochLength;
    uint32 minEpochLength;
    uint32 protocolFeeNumerator;
    uint32 protocolFeeDenominator;
    ERC20 WETH; 
    ICollateralToken COLLATERAL_TOKEN; 
    ILienToken LIEN_TOKEN; 
    ITransferProxy TRANSFER_PROXY; 
    address feeTo; 
    address BEACON_PROXY_IMPLEMENTATION; 
    uint88 maxInterestRate; 
    uint32 minInterestBPS; 
    address guardian; 
    address newGuardian; 
    uint32 buyoutFeeNumerator;
    uint32 buyoutFeeDenominator;
    uint32 minDurationIncrease;
    mapping(uint8 => address) strategyValidators;
    mapping(uint8 => address) implementations;
    mapping(address => bool) vaults;
  }
  enum ImplementationType {
    PrivateVault,
    PublicVault,
    WithdrawProxy,
    ClearingHouse
  }
  enum LienRequestType {
    DEACTIVATED,
    UNIQUE,
    COLLECTION,
    UNIV3_LIQUIDITY
  }
  struct StrategyDetailsParam {
    uint8 version;
    uint256 deadline;
    address vault;
  }
  struct MerkleData {
    bytes32 root;
    bytes32[] proof;
  }
  struct NewLienRequest {
    StrategyDetailsParam strategy;
    ILienToken.Stack[] stack;
    bytes nlrDetails;
    MerkleData merkle;
    uint256 amount;
    uint8 v;
    bytes32 r;
    bytes32 s;
  }
  struct Commitment {
    address tokenContract;
    uint256 tokenId;
    NewLienRequest lienRequest;
  }
  function validateCommitment(
    IAstariaRouter.Commitment calldata commitment,
    uint256 timeToSecondEpochEnd
  ) external returns (ILienToken.Lien memory lien);
  function newPublicVault(
    uint256 epochLength,
    address delegate,
    address underlying,
    uint256 vaultFee,
    bool allowListEnabled,
    address[] calldata allowList,
    uint256 depositCap
  ) external returns (address);
  function newVault(address delegate, address underlying)
    external
    returns (address);
  function feeTo() external returns (address);
  function commitToLiens(Commitment[] memory commitments)
    external
    returns (uint256[] memory, ILienToken.Stack[] memory);
  function requestLienPosition(
    IAstariaRouter.Commitment calldata params,
    address recipient
  )
    external
    returns (
      uint256,
      ILienToken.Stack[] memory,
      uint256
    );
  function LIEN_TOKEN() external view returns (ILienToken);
  function TRANSFER_PROXY() external view returns (ITransferProxy);
  function BEACON_PROXY_IMPLEMENTATION() external view returns (address);
  function COLLATERAL_TOKEN() external view returns (ICollateralToken);
  function getAuctionWindow(bool includeBuffer) external view returns (uint256);
  function getProtocolFee(uint256) external view returns (uint256);
  function getBuyoutFee(uint256) external view returns (uint256);
  function getLiquidatorFee(uint256) external view returns (uint256);
  function liquidate(ILienToken.Stack[] calldata stack, uint8 position)
    external
    returns (OrderParameters memory);
  function canLiquidate(ILienToken.Stack calldata) external view returns (bool);
  function isValidVault(address vault) external view returns (bool);
  function fileBatch(File[] calldata files) external;
  function file(File calldata incoming) external;
  function setNewGuardian(address _guardian) external;
  function fileGuardian(File[] calldata file) external;
  function getImpl(uint8 implType) external view returns (address impl);
  function isValidRefinance(
    ILienToken.Lien calldata newLien,
    uint8 position,
    ILienToken.Stack[] calldata stack
  ) external view returns (bool);
  event Liquidation(uint256 collateralId, uint256 position);
  event NewVault(
    address strategist,
    address delegate,
    address vault,
    uint8 vaultType
  );
  error InvalidFileData();
  error InvalidEpochLength(uint256);
  error InvalidRefinanceRate(uint256);
  error InvalidRefinanceDuration(uint256);
  error InvalidRefinanceCollateral(uint256);
  error InvalidVaultState(VaultState);
  error InvalidSenderForCollateral(address, uint256);
  error InvalidLienState(LienState);
  error InvalidCollateralState(CollateralStates);
  error InvalidCommitmentState(CommitmentState);
  error InvalidStrategy(uint16);
  error InvalidVault(address);
  error UnsupportedFile();
  enum LienState {
    HEALTHY,
    AUCTION
  }
  enum CollateralStates {
    AUCTION,
    NO_AUCTION,
    NO_DEPOSIT,
    NO_LIENS
  }
  enum CommitmentState {
    INVALID,
    INVALID_RATE,
    INVALID_AMOUNT,
    EXPIRED,
    COLLATERAL_AUCTION,
    COLLATERAL_NO_DEPOSIT
  }
  enum VaultState {
    UNINITIALIZED,
    CLOSED,
    LIQUIDATED
  }
}
interface ICollateralToken is IERC721 {
  event ListedOnSeaport(uint256 collateralId, Order listingOrder);
  event FileUpdated(FileType what, bytes data);
  event Deposit721(
    address indexed tokenContract,
    uint256 indexed tokenId,
    uint256 indexed collateralId,
    address depositedFor
  );
  event ReleaseTo(
    address indexed underlyingAsset,
    uint256 assetId,
    address indexed to
  );
  struct Asset {
    address tokenContract;
    uint256 tokenId;
  }
  struct CollateralStorage {
    ITransferProxy TRANSFER_PROXY;
    ILienToken LIEN_TOKEN;
    IAstariaRouter ASTARIA_ROUTER;
    ConsiderationInterface SEAPORT;
    ConduitControllerInterface CONDUIT_CONTROLLER;
    address CONDUIT;
    bytes32 CONDUIT_KEY;
    mapping(uint256 => bytes32) collateralIdToAuction;
    mapping(address => bool) flashEnabled;
    mapping(uint256 => Asset) idToUnderlying;
    mapping(address => address) securityHooks;
    mapping(uint256 => address) clearingHouse;
  }
  struct ListUnderlyingForSaleParams {
    ILienToken.Stack[] stack;
    uint256 listPrice;
    uint56 maxDuration;
  }
  enum FileType {
    NotSupported,
    AstariaRouter,
    SecurityHook,
    FlashEnabled,
    Seaport
  }
  struct File {
    FileType what;
    bytes data;
  }
  function fileBatch(File[] calldata files) external;
  function file(File calldata incoming) external;
  function flashAction(
    IFlashAction receiver,
    uint256 collateralId,
    bytes calldata data
  ) external;
  function securityHooks(address) external view returns (address);
  function getConduit() external view returns (address);
  function getConduitKey() external view returns (bytes32);
  function getClearingHouse(uint256) external view returns (ClearingHouse);
  struct AuctionVaultParams {
    address settlementToken;
    uint256 collateralId;
    uint256 maxDuration;
    uint256 startingPrice;
    uint256 endingPrice;
  }
  function auctionVault(AuctionVaultParams calldata params)
    external
    returns (OrderParameters memory);
  function settleAuction(uint256 collateralId) external;
  function SEAPORT() external view returns (ConsiderationInterface);
  function getUnderlying(uint256 collateralId)
    external
    view
    returns (address, uint256);
  function releaseToAddress(uint256 collateralId, address releaseTo) external;
  function liquidatorNFTClaim(OrderParameters memory params) external;
  error UnsupportedFile();
  error InvalidCollateral();
  error InvalidSender();
  error InvalidCollateralState(InvalidCollateralStates);
  error ProtocolPaused();
  error ListPriceTooLow();
  error InvalidConduitKey();
  error InvalidZone();
  enum InvalidCollateralStates {
    NO_AUTHORITY,
    NO_AUCTION,
    FLASH_DISABLED,
    AUCTION_ACTIVE,
    INVALID_AUCTION_PARAMS,
    ACTIVE_LIENS
  }
  error FlashActionCallbackFailed();
  error FlashActionSecurityCheckFailed();
  error FlashActionNFTNotReturned();
}
interface ILienToken is IERC721 {
  enum FileType {
    NotSupported,
    CollateralToken,
    AstariaRouter
  }
  struct File {
    FileType what;
    bytes data;
  }
  event FileUpdated(FileType what, bytes data);
  struct LienStorage {
    uint8 maxLiens;
    address WETH;
    ITransferProxy TRANSFER_PROXY;
    IAstariaRouter ASTARIA_ROUTER;
    ICollateralToken COLLATERAL_TOKEN;
    mapping(uint256 => bytes32) collateralStateHash;
    mapping(uint256 => AuctionData) auctionData;
    mapping(uint256 => LienMeta) lienMeta;
  }
  struct LienMeta {
    address payee;
    bool atLiquidation;
  }
  struct Details {
    uint256 maxAmount;
    uint256 rate; 
    uint256 duration;
    uint256 maxPotentialDebt;
    uint256 liquidationInitialAsk;
  }
  struct Lien {
    uint8 collateralType;
    address token; 
    address vault; 
    bytes32 strategyRoot; 
    uint256 collateralId; 
    Details details; 
  }
  struct Point {
    uint88 amount; 
    uint40 last; 
    uint40 end; 
    uint256 lienId; 
  }
  struct Stack {
    Lien lien;
    Point point;
  }
  struct LienActionEncumber {
    uint256 amount;
    address receiver;
    ILienToken.Lien lien;
    Stack[] stack;
  }
  struct LienActionBuyout {
    uint8 position;
    LienActionEncumber encumber;
  }
  function validateLien(Lien calldata lien)
    external
    view
    returns (uint256 lienId);
  function ASTARIA_ROUTER() external view returns (IAstariaRouter);
  function COLLATERAL_TOKEN() external view returns (ICollateralToken);
  function calculateSlope(Stack calldata stack)
    external
    pure
    returns (uint256 slope);
  function stopLiens(
    uint256 collateralId,
    uint256 auctionWindow,
    Stack[] calldata stack,
    address liquidator
  ) external;
  function getBuyout(Stack calldata stack)
    external
    view
    returns (uint256 owed, uint256 buyout);
  function getOwed(Stack calldata stack) external view returns (uint88);
  function getOwed(Stack calldata stack, uint256 timestamp)
    external
    view
    returns (uint88);
  function getInterest(Stack calldata stack) external returns (uint256);
  function getCollateralState(uint256 collateralId)
    external
    view
    returns (bytes32);
  function getAmountOwingAtLiquidation(ILienToken.Stack calldata stack)
    external
    view
    returns (uint256);
  function createLien(LienActionEncumber memory params)
    external
    returns (
      uint256 lienId,
      Stack[] memory stack,
      uint256 slope
    );
  function buyoutLien(LienActionBuyout memory params)
    external
    returns (Stack[] memory, Stack memory);
  function payDebtViaClearingHouse(
    address token,
    uint256 collateralId,
    uint256 payment,
    AuctionStack[] memory auctionStack
  ) external;
  function makePayment(
    uint256 collateralId,
    Stack[] memory stack,
    uint256 amount
  ) external returns (Stack[] memory newStack);
  function makePayment(
    uint256 collateralId,
    Stack[] calldata stack,
    uint8 position,
    uint256 amount
  ) external returns (Stack[] memory newStack);
  struct AuctionStack {
    uint256 lienId;
    uint88 amountOwed;
    uint40 end;
  }
  struct AuctionData {
    uint88 startAmount;
    uint88 endAmount;
    uint48 startTime;
    uint48 endTime;
    address liquidator;
    AuctionStack[] stack;
  }
  function getAuctionData(uint256 collateralId)
    external
    view
    returns (AuctionData memory);
  function getAuctionLiquidator(uint256 collateralId)
    external
    view
    returns (address liquidator);
  function getMaxPotentialDebtForCollateral(ILienToken.Stack[] memory stack)
    external
    view
    returns (uint256);
  function getMaxPotentialDebtForCollateral(
    ILienToken.Stack[] memory stack,
    uint256 end
  ) external view returns (uint256);
  function getPayee(uint256 lienId) external view returns (address);
  function file(File calldata file) external;
  event AddLien(
    uint256 indexed collateralId,
    uint8 position,
    uint256 indexed lienId,
    Stack stack
  );
  enum StackAction {
    CLEAR,
    ADD,
    REMOVE,
    REPLACE
  }
  event LienStackUpdated(
    uint256 indexed collateralId,
    uint8 position,
    StackAction action,
    uint8 stackLength
  );
  event RemovedLiens(uint256 indexed collateralId);
  event Payment(uint256 indexed lienId, uint256 amount);
  event BuyoutLien(address indexed buyer, uint256 lienId, uint256 buyout);
  event PayeeChanged(uint256 indexed lienId, address indexed payee);
  error UnsupportedFile();
  error InvalidTokenId(uint256 tokenId);
  error InvalidBuyoutDetails(uint256 lienMaxAmount, uint256 owed);
  error InvalidTerms();
  error InvalidRefinance();
  error InvalidLoanState();
  error InvalidSender();
  enum InvalidStates {
    NO_AUTHORITY,
    COLLATERAL_MISMATCH,
    ASSET_MISMATCH,
    NOT_ENOUGH_FUNDS,
    INVALID_LIEN_ID,
    COLLATERAL_AUCTION,
    COLLATERAL_NOT_DEPOSITED,
    LIEN_NO_DEBT,
    EXPIRED_LIEN,
    DEBT_LIMIT,
    MAX_LIENS,
    INVALID_HASH,
    INVALID_LIQUIDATION_INITIAL_ASK,
    INITIAL_ASK_EXCEEDED,
    EMPTY_STATE,
    PUBLIC_VAULT_RECIPIENT,
    COLLATERAL_NOT_LIQUIDATED
  }
  error InvalidState(InvalidStates);
  error InvalidCollateralState(InvalidStates);
}
interface IRouterBase {
  function ROUTER() external view returns (IAstariaRouter);
  function IMPL_TYPE() external view returns (uint8);
}
interface IAstariaVaultBase is IRouterBase {
  function owner() external view returns (address);
  function asset() external view returns (address);
  function COLLATERAL_TOKEN() external view returns (ICollateralToken);
  function START() external view returns (uint256);
  function EPOCH_LENGTH() external view returns (uint256);
  function VAULT_FEE() external view returns (uint256);
}
interface IWithdrawProxy is IRouterBase, IERC165, IERC4626 {
  function VAULT() external pure returns (address);
  function CLAIMABLE_EPOCH() external pure returns (uint64);
  function setWithdrawRatio(uint256 liquidationWithdrawRatio) external;
  function handleNewLiquidation(
    uint256 newLienExpectedValue,
    uint256 finalAuctionDelta
  ) external;
  function drain(uint256 amount, address withdrawProxy)
    external
    returns (uint256);
  function claim() external;
  function increaseWithdrawReserveReceived(uint256 amount) external;
  function getExpected() external view returns (uint256);
  function getWithdrawRatio() external view returns (uint256);
  function getFinalAuctionEnd() external view returns (uint256);
  error NotSupported();
}
abstract contract AstariaVaultBase is Clone, IAstariaVaultBase {
  function name() external view virtual returns (string memory);
  function symbol() external view virtual returns (string memory);
  function ROUTER() public pure returns (IAstariaRouter) {
    return IAstariaRouter(_getArgAddress(0)); 
  }
  function IMPL_TYPE() public pure returns (uint8) {
    return _getArgUint8(20); 
  }
  function owner() public pure returns (address) {
    return _getArgAddress(21); 
  }
  function asset()
    public
    pure
    virtual
    override(IAstariaVaultBase)
    returns (address)
  {
    return _getArgAddress(41); 
  }
  function START() public pure returns (uint256) {
    return _getArgUint256(61);
  }
  function EPOCH_LENGTH() public pure returns (uint256) {
    return _getArgUint256(93); 
  }
  function VAULT_FEE() public pure returns (uint256) {
    return _getArgUint256(125);
  }
  function COLLATERAL_TOKEN() public view returns (ICollateralToken) {
    return ROUTER().COLLATERAL_TOKEN();
  }
}
abstract contract WithdrawVaultBase is Clone, IWithdrawProxy {
  function name() public view virtual returns (string memory);
  function symbol() public view virtual returns (string memory);
  function ROUTER() external pure returns (IAstariaRouter) {
    return IAstariaRouter(_getArgAddress(0));
  }
  function IMPL_TYPE() public pure override(IRouterBase) returns (uint8) {
    return _getArgUint8(20);
  }
  function asset() public pure virtual override(IERC4626) returns (address) {
    return _getArgAddress(21);
  }
  function VAULT() public pure returns (address) {
    return _getArgAddress(41);
  }
  function CLAIMABLE_EPOCH() public pure returns (uint64) {
    return _getArgUint64(61);
  }
}
interface IVaultImplementation is IAstariaVaultBase, IERC165 {
  enum InvalidRequestReason {
    NO_AUTHORITY,
    INVALID_SIGNATURE,
    INVALID_COMMITMENT,
    INVALID_AMOUNT,
    INSUFFICIENT_FUNDS,
    INVALID_RATE,
    INVALID_POTENTIAL_DEBT,
    SHUTDOWN,
    PAUSED
  }
  error InvalidRequest(InvalidRequestReason reason);
  struct InitParams {
    address delegate;
    bool allowListEnabled;
    address[] allowList;
    uint256 depositCap; 
  }
  struct VIData {
    uint88 depositCap;
    address delegate;
    bool allowListEnabled;
    bool isShutdown;
    uint256 strategistNonce;
    mapping(address => bool) allowList;
  }
  event AllowListUpdated(address, bool);
  event AllowListEnabled(bool);
  event DelegateUpdated(address);
  event NonceUpdated(uint256 nonce);
  event IncrementNonce(uint256 nonce);
  event VaultShutdown();
  function getShutdown() external view returns (bool);
  function shutdown() external;
  function incrementNonce() external;
  function commitToLien(
    IAstariaRouter.Commitment calldata params,
    address receiver
  )
    external
    returns (
      uint256 lienId,
      ILienToken.Stack[] memory stack,
      uint256 payout
    );
  function buyoutLien(
    ILienToken.Stack[] calldata stack,
    uint8 position,
    IAstariaRouter.Commitment calldata incomingTerms
  ) external returns (ILienToken.Stack[] memory, ILienToken.Stack memory);
  function recipient() external view returns (address);
  function setDelegate(address delegate_) external;
  function init(InitParams calldata params) external;
  function encodeStrategyData(
    IAstariaRouter.StrategyDetailsParam calldata strategy,
    bytes32 root
  ) external view returns (bytes memory);
  function domainSeparator() external view returns (bytes32);
  function modifyDepositCap(uint256 newCap) external;
  function getStrategistNonce() external view returns (uint256);
  function STRATEGY_TYPEHASH() external view returns (bytes32);
}
interface IPublicVault is IVaultImplementation {
  struct EpochData {
    uint64 liensOpenForEpoch;
    address withdrawProxy;
  }
  struct VaultData {
    uint88 yIntercept;
    uint48 slope;
    uint40 last;
    uint64 currentEpoch;
    uint88 withdrawReserve;
    uint88 liquidationWithdrawRatio;
    uint88 strategistUnclaimedShares;
    mapping(uint64 => EpochData) epochData;
  }
  struct BeforePaymentParams {
    uint256 lienSlope;
    uint256 amount;
    uint256 interestOwed;
  }
  struct BuyoutLienParams {
    uint256 lienSlope;
    uint256 lienEnd;
    uint256 increaseYIntercept;
  }
  struct AfterLiquidationParams {
    uint256 lienSlope;
    uint256 newAmount;
    uint40 lienEnd;
  }
  struct LiquidationPaymentParams {
    uint256 remaining;
  }
  function updateAfterLiquidationPayment(
    LiquidationPaymentParams calldata params
  ) external;
  function redeemFutureEpoch(
    uint256 shares,
    address receiver,
    address owner,
    uint64 epoch
  ) external returns (uint256 assets);
  function beforePayment(BeforePaymentParams calldata params) external;
  function decreaseEpochLienCount(uint64 epoch) external;
  function getLienEpoch(uint64 end) external view returns (uint64);
  function afterPayment(uint256 computedSlope) external;
  function claim() external;
  function timeToEpochEnd() external view returns (uint256);
  function timeToSecondEpochEnd() external view returns (uint256);
  function transferWithdrawReserve() external;
  function processEpoch() external;
  function increaseYIntercept(uint256 amount) external;
  function decreaseYIntercept(uint256 amount) external;
  function handleBuyoutLien(BuyoutLienParams calldata params) external;
  function updateVaultAfterLiquidation(
    uint256 maxAuctionWindow,
    AfterLiquidationParams calldata params
  ) external returns (address withdrawProxyIfNearBoundary);
  error InvalidState(InvalidStates);
  enum InvalidStates {
    EPOCH_TOO_LOW,
    EPOCH_TOO_HIGH,
    EPOCH_NOT_OVER,
    WITHDRAW_RESERVE_NOT_ZERO,
    LIENS_OPEN_FOR_EPOCH_NOT_ZERO,
    LIQUIDATION_ACCOUNTANT_FINAL_AUCTION_OPEN,
    LIQUIDATION_ACCOUNTANT_ALREADY_DEPLOYED_FOR_EPOCH,
    DEPOSIT_CAP_EXCEEDED
  }
  event StrategistFee(uint88 feeInShares);
  event LiensOpenForEpochRemaining(uint64 epoch, uint256 liensOpenForEpoch);
  event YInterceptChanged(uint88 newYintercept);
  event WithdrawReserveTransferred(uint256 amount);
  event LienOpen(uint256 lienId, uint256 epoch);
}
contract LienToken is ERC721_1, ILienToken, AuthInitializable {
  using FixedPointMathLib for uint256;
  using CollateralLookup for address;
  using SafeCastLib for uint256;
  using SafeTransferLib for ERC20;
  uint256 private constant LIEN_SLOT =
    uint256(keccak256("xyz.astaria.LienToken.storage.location")) - 1;
  bytes32 constant ACTIVE_AUCTION = bytes32("ACTIVE_AUCTION");
  constructor() {
    _disableInitializers();
  }
  function initialize(Authority _AUTHORITY, ITransferProxy _TRANSFER_PROXY)
    public
    initializer
  {
    __initAuth(msg.sender, address(_AUTHORITY));
    __initERC721("Astaria Lien Token", "ALT");
    LienStorage storage s = _loadLienStorageSlot();
    s.TRANSFER_PROXY = _TRANSFER_PROXY;
    s.maxLiens = uint8(5);
  }
  function _loadLienStorageSlot()
    internal
    pure
    returns (LienStorage storage s)
  {
    uint256 slot = LIEN_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function file(File calldata incoming) external requiresAuth {
    FileType what = incoming.what;
    bytes memory data = incoming.data;
    LienStorage storage s = _loadLienStorageSlot();
    if (what == FileType.CollateralToken) {
      s.COLLATERAL_TOKEN = ICollateralToken(abi.decode(data, (address)));
    } else if (what == FileType.AstariaRouter) {
      s.ASTARIA_ROUTER = IAstariaRouter(abi.decode(data, (address)));
    } else {
      revert UnsupportedFile();
    }
    emit FileUpdated(what, data);
  }
  function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721_1, IERC165)
    returns (bool)
  {
    return
      interfaceId == type(ILienToken).interfaceId ||
      super.supportsInterface(interfaceId);
  }
  function buyoutLien(ILienToken.LienActionBuyout calldata params)
    external
    validateStack(params.encumber.lien.collateralId, params.encumber.stack)
    returns (Stack[] memory, Stack memory newStack)
  {
    if (block.timestamp >= params.encumber.stack[params.position].point.end) {
      revert InvalidState(InvalidStates.EXPIRED_LIEN);
    }
    LienStorage storage s = _loadLienStorageSlot();
    if (!s.ASTARIA_ROUTER.isValidVault(msg.sender)) {
      revert InvalidSender();
    }
    return _buyoutLien(s, params);
  }
  function _buyoutLien(
    LienStorage storage s,
    ILienToken.LienActionBuyout calldata params
  ) internal returns (Stack[] memory newStack, Stack memory newLien) {
    (, newLien) = _createLien(s, params.encumber);
    if (
      !s.ASTARIA_ROUTER.isValidRefinance({
        newLien: params.encumber.lien,
        position: params.position,
        stack: params.encumber.stack
      })
    ) {
      revert InvalidRefinance();
    }
    if (
      s.collateralStateHash[params.encumber.lien.collateralId] == ACTIVE_AUCTION
    ) {
      revert InvalidState(InvalidStates.COLLATERAL_AUCTION);
    }
    (uint256 owed, uint256 buyout) = _getBuyout(
      s,
      params.encumber.stack[params.position]
    );
    if (params.encumber.lien.details.maxAmount < owed) {
      revert InvalidBuyoutDetails(params.encumber.lien.details.maxAmount, owed);
    }
    uint256 potentialDebt = 0;
    for (uint256 i = params.encumber.stack.length; i > 0; ) {
      uint256 j = i - 1;
      if (block.timestamp >= params.encumber.stack[j].point.end) {
        revert InvalidState(InvalidStates.EXPIRED_LIEN);
      }
      potentialDebt += _getOwed(
        params.encumber.stack[j],
        params.encumber.stack[j].point.end
      );
      if (
        potentialDebt >
        params.encumber.stack[j].lien.details.liquidationInitialAsk
      ) {
        revert InvalidState(InvalidStates.INITIAL_ASK_EXCEEDED);
      }
      unchecked {
        --i;
      }
    }
    address payee = _getPayee(
      s,
      params.encumber.stack[params.position].point.lienId
    );
    s.TRANSFER_PROXY.tokenTransferFrom(
      params.encumber.stack[params.position].lien.token,
      msg.sender,
      payee,
      buyout
    );
    if (_isPublicVault(s, payee)) {
      IPublicVault(payee).handleBuyoutLien(
        IPublicVault.BuyoutLienParams({
          lienSlope: calculateSlope(params.encumber.stack[params.position]),
          lienEnd: params.encumber.stack[params.position].point.end,
          increaseYIntercept: buyout -
            params.encumber.stack[params.position].point.amount
        })
      );
    }
    newStack = _replaceStackAtPositionWithNewLien(
      s,
      params.encumber.stack,
      params.position,
      newLien,
      params.encumber.stack[params.position].point.lienId
    );
    uint256 maxPotentialDebt;
    uint256 n = newStack.length;
    uint256 i;
    for (i; i < n; ) {
      maxPotentialDebt += _getOwed(newStack[i], newStack[i].point.end);
      if (i == params.position) {
        if (maxPotentialDebt > params.encumber.lien.details.maxPotentialDebt) {
          revert InvalidState(InvalidStates.DEBT_LIMIT);
        }
      }
      if (
        i > params.position &&
        (maxPotentialDebt > newStack[i].lien.details.maxPotentialDebt)
      ) {
        revert InvalidState(InvalidStates.DEBT_LIMIT);
      }
      unchecked {
        ++i;
      }
    }
    s.collateralStateHash[params.encumber.lien.collateralId] = keccak256(
      abi.encode(newStack)
    );
  }
  function _replaceStackAtPositionWithNewLien(
    LienStorage storage s,
    ILienToken.Stack[] calldata stack,
    uint256 position,
    Stack memory newLien,
    uint256 oldLienId
  ) internal returns (ILienToken.Stack[] memory newStack) {
    newStack = stack;
    newStack[position] = newLien;
    _burn(oldLienId);
    delete s.lienMeta[oldLienId];
  }
  function getInterest(Stack calldata stack) public view returns (uint256) {
    return _getInterest(stack, block.timestamp);
  }
  function _getInterest(Stack memory stack, uint256 timestamp)
    internal
    pure
    returns (uint256)
  {
    uint256 delta_t = timestamp - stack.point.last;
    return (delta_t * stack.lien.details.rate).mulWadDown(stack.point.amount);
  }
  modifier validateStack(uint256 collateralId, Stack[] memory stack) {
    LienStorage storage s = _loadLienStorageSlot();
    bytes32 stateHash = s.collateralStateHash[collateralId];
    if (stateHash == bytes32(0) && stack.length != 0) {
      revert InvalidState(InvalidStates.EMPTY_STATE);
    }
    if (stateHash != bytes32(0) && keccak256(abi.encode(stack)) != stateHash) {
      revert InvalidState(InvalidStates.INVALID_HASH);
    }
    _;
  }
  function stopLiens(
    uint256 collateralId,
    uint256 auctionWindow,
    Stack[] calldata stack,
    address liquidator
  ) external validateStack(collateralId, stack) requiresAuth {
    _stopLiens(
      _loadLienStorageSlot(),
      collateralId,
      auctionWindow,
      stack,
      liquidator
    );
  }
  function _stopLiens(
    LienStorage storage s,
    uint256 collateralId,
    uint256 auctionWindow,
    Stack[] calldata stack,
    address liquidator
  ) internal {
    AuctionData memory auctionData;
    auctionData.liquidator = liquidator;
    auctionData.stack = new AuctionStack[](stack.length);
    s.auctionData[collateralId].liquidator = liquidator;
    uint256 i;
    for (; i < stack.length; ) {
      AuctionStack memory auctionStack;
      auctionStack.lienId = stack[i].point.lienId;
      auctionStack.end = stack[i].point.end;
      uint88 owed = _getOwed(stack[i], block.timestamp);
      auctionStack.amountOwed = owed;
      s.lienMeta[auctionStack.lienId].atLiquidation = true;
      auctionData.stack[i] = auctionStack;
      address payee = _getPayee(s, auctionStack.lienId);
      if (_isPublicVault(s, payee)) {
        address withdrawProxyIfNearBoundary = IPublicVault(payee)
          .updateVaultAfterLiquidation(
            auctionWindow,
            IPublicVault.AfterLiquidationParams({
              lienSlope: calculateSlope(stack[i]),
              newAmount: owed,
              lienEnd: stack[i].point.end
            })
          );
        if (withdrawProxyIfNearBoundary != address(0)) {
          _setPayee(s, auctionStack.lienId, withdrawProxyIfNearBoundary);
        }
      }
      unchecked {
        ++i;
      }
    }
    s.collateralStateHash[collateralId] = ACTIVE_AUCTION;
    auctionData.startTime = block.timestamp.safeCastTo48();
    auctionData.endTime = (block.timestamp + auctionWindow).safeCastTo48();
    auctionData.startAmount = stack[0]
      .lien
      .details
      .liquidationInitialAsk
      .safeCastTo88();
    auctionData.endAmount = uint88(1000 wei);
    s.COLLATERAL_TOKEN.getClearingHouse(collateralId).setAuctionData(
      auctionData
    );
  }
  function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721_1, IERC721)
    returns (string memory)
  {
    if (!_exists(tokenId)) {
      revert InvalidTokenId(tokenId);
    }
    return "";
  }
  function transferFrom(
    address from,
    address to,
    uint256 id
  ) public override(ERC721_1, IERC721) {
    LienStorage storage s = _loadLienStorageSlot();
    if (_isPublicVault(s, to)) {
      revert InvalidState(InvalidStates.PUBLIC_VAULT_RECIPIENT);
    }
    if (s.lienMeta[id].atLiquidation) {
      revert InvalidState(InvalidStates.COLLATERAL_AUCTION);
    }
    delete s.lienMeta[id].payee;
    emit PayeeChanged(id, address(0));
    super.transferFrom(from, to, id);
  }
  function ASTARIA_ROUTER() public view returns (IAstariaRouter) {
    return _loadLienStorageSlot().ASTARIA_ROUTER;
  }
  function COLLATERAL_TOKEN() public view returns (ICollateralToken) {
    return _loadLienStorageSlot().COLLATERAL_TOKEN;
  }
  function _exists(uint256 tokenId) internal view returns (bool) {
    return _loadERC721Slot()._ownerOf[tokenId] != address(0);
  }
  function createLien(ILienToken.LienActionEncumber memory params)
    external
    requiresAuth
    validateStack(params.lien.collateralId, params.stack)
    returns (
      uint256 lienId,
      Stack[] memory newStack,
      uint256 lienSlope
    )
  {
    LienStorage storage s = _loadLienStorageSlot();
    Stack memory newStackSlot;
    (lienId, newStackSlot) = _createLien(s, params);
    newStack = _appendStack(s, params.stack, newStackSlot);
    s.collateralStateHash[params.lien.collateralId] = keccak256(
      abi.encode(newStack)
    );
    lienSlope = calculateSlope(newStackSlot);
    emit AddLien(
      params.lien.collateralId,
      uint8(params.stack.length),
      lienId,
      newStackSlot
    );
    emit LienStackUpdated(
      params.lien.collateralId,
      uint8(params.stack.length),
      StackAction.ADD,
      uint8(newStack.length)
    );
  }
  function _createLien(
    LienStorage storage s,
    ILienToken.LienActionEncumber memory params
  ) internal returns (uint256 newLienId, ILienToken.Stack memory newSlot) {
    if (s.collateralStateHash[params.lien.collateralId] == ACTIVE_AUCTION) {
      revert InvalidState(InvalidStates.COLLATERAL_AUCTION);
    }
    if (
      params.lien.details.liquidationInitialAsk < params.amount ||
      params.lien.details.liquidationInitialAsk == 0
    ) {
      revert InvalidState(InvalidStates.INVALID_LIQUIDATION_INITIAL_ASK);
    }
    if (params.stack.length > 0) {
      if (params.lien.collateralId != params.stack[0].lien.collateralId) {
        revert InvalidState(InvalidStates.COLLATERAL_MISMATCH);
      }
      if (params.lien.token != params.stack[0].lien.token) {
        revert InvalidState(InvalidStates.ASSET_MISMATCH);
      }
    }
    newLienId = uint256(keccak256(abi.encode(params.lien)));
    Point memory point = Point({
      lienId: newLienId,
      amount: params.amount.safeCastTo88(),
      last: block.timestamp.safeCastTo40(),
      end: (block.timestamp + params.lien.details.duration).safeCastTo40()
    });
    _mint(params.receiver, newLienId);
    return (newLienId, Stack({lien: params.lien, point: point}));
  }
  function _appendStack(
    LienStorage storage s,
    Stack[] memory stack,
    Stack memory newSlot
  ) internal returns (Stack[] memory newStack) {
    if (stack.length >= s.maxLiens) {
      revert InvalidState(InvalidStates.MAX_LIENS);
    }
    newStack = new Stack[](stack.length + 1);
    newStack[stack.length] = newSlot;
    uint256 potentialDebt = _getOwed(newSlot, newSlot.point.end);
    for (uint256 i = stack.length; i > 0; ) {
      uint256 j = i - 1;
      newStack[j] = stack[j];
      if (block.timestamp >= newStack[j].point.end) {
        revert InvalidState(InvalidStates.EXPIRED_LIEN);
      }
      unchecked {
        potentialDebt += _getOwed(newStack[j], newStack[j].point.end);
      }
      if (potentialDebt > newStack[j].lien.details.liquidationInitialAsk) {
        revert InvalidState(InvalidStates.INITIAL_ASK_EXCEEDED);
      }
      unchecked {
        --i;
      }
    }
    if (
      stack.length > 0 && potentialDebt > newSlot.lien.details.maxPotentialDebt
    ) {
      revert InvalidState(InvalidStates.DEBT_LIMIT);
    }
  }
  function payDebtViaClearingHouse(
    address token,
    uint256 collateralId,
    uint256 payment,
    AuctionStack[] memory auctionStack
  ) external {
    LienStorage storage s = _loadLienStorageSlot();
    require(
      msg.sender == address(s.COLLATERAL_TOKEN.getClearingHouse(collateralId))
    );
    _payDebt(s, token, payment, msg.sender, auctionStack);
    delete s.collateralStateHash[collateralId];
  }
  function _payDebt(
    LienStorage storage s,
    address token,
    uint256 payment,
    address payer,
    AuctionStack[] memory stack
  ) internal returns (uint256 totalSpent) {
    uint256 i;
    for (; i < stack.length;) {
      uint256 spent;
      unchecked {
        spent = _paymentAH(s, token, stack, i, payment, payer);
        totalSpent += spent;
        payment -= spent;
        ++i;
      }
    }
  }
  function getAuctionData(uint256 collateralId)
    external
    view
    returns (AuctionData memory)
  {
    return _loadLienStorageSlot().auctionData[collateralId];
  }
  function getAuctionLiquidator(uint256 collateralId)
    external
    view
    returns (address liquidator)
  {
    liquidator = _loadLienStorageSlot().auctionData[collateralId].liquidator;
    if (liquidator == address(0)) {
      revert InvalidState(InvalidStates.COLLATERAL_NOT_LIQUIDATED);
    }
  }
  function getAmountOwingAtLiquidation(ILienToken.Stack calldata stack)
    public
    view
    returns (uint256)
  {
    return
      _loadLienStorageSlot()
        .auctionData[stack.lien.collateralId]
        .stack[stack.point.lienId]
        .amountOwed;
  }
  function validateLien(Lien memory lien) public view returns (uint256 lienId) {
    lienId = uint256(keccak256(abi.encode(lien)));
    if (!_exists(lienId)) {
      revert InvalidState(InvalidStates.INVALID_LIEN_ID);
    }
  }
  function getCollateralState(uint256 collateralId)
    external
    view
    returns (bytes32)
  {
    return _loadLienStorageSlot().collateralStateHash[collateralId];
  }
  function getBuyout(Stack calldata stack)
    public
    view
    returns (uint256 owed, uint256 buyout)
  {
    return _getBuyout(_loadLienStorageSlot(), stack);
  }
  function _getBuyout(LienStorage storage s, Stack calldata stack)
    internal
    view
    returns (uint256 owed, uint256 buyout)
  {
    owed = _getOwed(stack, block.timestamp);
    buyout =
      owed +
      s.ASTARIA_ROUTER.getBuyoutFee(_getRemainingInterest(s, stack));
  }
  function makePayment(
    uint256 collateralId,
    Stack[] calldata stack,
    uint256 amount
  )
    public
    validateStack(collateralId, stack)
    returns (Stack[] memory newStack)
  {
    return _makePayment(_loadLienStorageSlot(), stack, amount);
  }
  function makePayment(
    uint256 collateralId,
    Stack[] calldata stack,
    uint8 position,
    uint256 amount
  )
    external
    validateStack(collateralId, stack)
    returns (Stack[] memory newStack)
  {
    LienStorage storage s = _loadLienStorageSlot();
    (newStack, ) = _payment(s, stack, position, amount, msg.sender);
    _updateCollateralStateHash(s, collateralId, newStack);
  }
  function _paymentAH(
    LienStorage storage s,
    address token,
    AuctionStack[] memory stack,
    uint256 position,
    uint256 payment,
    address payer
  ) internal returns (uint256) {
    uint256 lienId = stack[position].lienId;
    uint256 end = stack[position].end;
    uint256 owing = stack[position].amountOwed;
    address payee = _getPayee(s, lienId);
    uint256 remaining = 0;
    if (owing > payment.safeCastTo88()) {
      remaining = owing - payment;
    } else {
      payment = owing;
    }
    if (payment > 0)
      s.TRANSFER_PROXY.tokenTransferFrom(token, payer, payee, payment);
    delete s.lienMeta[lienId]; 
    delete stack[position];
    _burn(lienId);
    if (_isPublicVault(s, payee)) {
      IPublicVault(payee).updateAfterLiquidationPayment(
        IPublicVault.LiquidationPaymentParams({remaining: remaining})
      );
    }
    emit Payment(lienId, payment);
    return payment;
  }
  function _makePayment(
    LienStorage storage s,
    Stack[] calldata stack,
    uint256 totalCapitalAvailable
  ) internal returns (Stack[] memory newStack) {
    newStack = stack;
    for (uint256 i; i < newStack.length; ) {
      uint256 oldLength = newStack.length;
      uint256 spent;
      (newStack, spent) = _payment(
        s,
        newStack,
        uint8(i),
        totalCapitalAvailable,
        msg.sender
      );
      totalCapitalAvailable -= spent;
      if (totalCapitalAvailable == 0) break;
      if (newStack.length == oldLength) {
        unchecked {
          ++i;
        }
      }
    }
    _updateCollateralStateHash(s, stack[0].lien.collateralId, newStack);
  }
  function _updateCollateralStateHash(
    LienStorage storage s,
    uint256 collateralId,
    Stack[] memory stack
  ) internal {
    if (stack.length == 0) {
      delete s.collateralStateHash[collateralId];
    } else {
      s.collateralStateHash[collateralId] = keccak256(abi.encode(stack));
    }
  }
  function calculateSlope(Stack memory stack) public pure returns (uint256) {
    return stack.lien.details.rate.mulWadDown(stack.point.amount);
  }
  function getMaxPotentialDebtForCollateral(Stack[] memory stack)
    public
    view
    validateStack(stack[0].lien.collateralId, stack)
    returns (uint256 maxPotentialDebt)
  {
    return _getMaxPotentialDebtForCollateralUpToNPositions(stack, stack.length);
  }
  function _getMaxPotentialDebtForCollateralUpToNPositions(
    Stack[] memory stack,
    uint256 n
  ) internal pure returns (uint256 maxPotentialDebt) {
    for (uint256 i; i < n; ) {
      maxPotentialDebt += _getOwed(stack[i], stack[i].point.end);
      unchecked {
        ++i;
      }
    }
  }
  function getMaxPotentialDebtForCollateral(Stack[] memory stack, uint256 end)
    public
    view
    validateStack(stack[0].lien.collateralId, stack)
    returns (uint256 maxPotentialDebt)
  {
    uint256 i;
    for (; i < stack.length; ) {
      maxPotentialDebt += _getOwed(stack[i], end);
      unchecked {
        ++i;
      }
    }
  }
  function getOwed(Stack memory stack) external view returns (uint88) {
    validateLien(stack.lien);
    return _getOwed(stack, block.timestamp);
  }
  function getOwed(Stack memory stack, uint256 timestamp)
    external
    view
    returns (uint88)
  {
    validateLien(stack.lien);
    return _getOwed(stack, timestamp);
  }
  function _getOwed(Stack memory stack, uint256 timestamp)
    internal
    pure
    returns (uint88)
  {
    return stack.point.amount + _getInterest(stack, timestamp).safeCastTo88();
  }
  function _getRemainingInterest(LienStorage storage s, Stack memory stack)
    internal
    view
    returns (uint256)
  {
    uint256 delta_t = stack.point.end - block.timestamp;
    return (delta_t * stack.lien.details.rate).mulWadDown(stack.point.amount);
  }
  function _payment(
    LienStorage storage s,
    Stack[] memory activeStack,
    uint8 position,
    uint256 amount,
    address payer
  ) internal returns (Stack[] memory, uint256) {
    Stack memory stack = activeStack[position];
    uint256 lienId = stack.point.lienId;
    if (s.lienMeta[lienId].atLiquidation) {
      revert InvalidState(InvalidStates.COLLATERAL_AUCTION);
    }
    uint64 end = stack.point.end;
    if (block.timestamp >= end) {
      revert InvalidLoanState();
    }
    uint256 owed = _getOwed(stack, block.timestamp);
    address lienOwner = ownerOf(lienId);
    bool isPublicVault = _isPublicVault(s, lienOwner);
    address payee = _getPayee(s, lienId);
    if (amount > owed) amount = owed;
    if (isPublicVault) {
      IPublicVault(lienOwner).beforePayment(
        IPublicVault.BeforePaymentParams({
          interestOwed: owed - stack.point.amount,
          amount: stack.point.amount,
          lienSlope: calculateSlope(stack)
        })
      );
    }
    stack.point.amount = owed.safeCastTo88();
    stack.point.last = block.timestamp.safeCastTo40();
    if (stack.point.amount > amount) {
      stack.point.amount -= amount.safeCastTo88();
      if (isPublicVault) {
        IPublicVault(lienOwner).afterPayment(calculateSlope(stack));
      }
    } else {
      amount = stack.point.amount;
      if (isPublicVault) {
        IPublicVault(lienOwner).decreaseEpochLienCount(
          IPublicVault(lienOwner).getLienEpoch(end)
        );
      }
      delete s.lienMeta[lienId]; 
      _burn(lienId);
      activeStack = _removeStackPosition(activeStack, position);
    }
    s.TRANSFER_PROXY.tokenTransferFrom(stack.lien.token, payer, payee, amount);
    emit Payment(lienId, amount);
    return (activeStack, amount);
  }
  function _removeStackPosition(Stack[] memory stack, uint8 position)
    internal
    returns (Stack[] memory newStack)
  {
    uint256 length = stack.length;
    require(position < length);
    newStack = new ILienToken.Stack[](length - 1);
    uint256 i;
    for (; i < position; ) {
      newStack[i] = stack[i];
      unchecked {
        ++i;
      }
    }
    for (; i < length - 1; ) {
      unchecked {
        newStack[i] = stack[i + 1];
        ++i;
      }
    }
    emit LienStackUpdated(
      stack[position].lien.collateralId,
      position,
      StackAction.REMOVE,
      uint8(newStack.length)
    );
  }
  function _isPublicVault(LienStorage storage s, address account)
    internal
    view
    returns (bool)
  {
    return
      s.ASTARIA_ROUTER.isValidVault(account) &&
      IPublicVault(account).supportsInterface(type(IPublicVault).interfaceId);
  }
  function getPayee(uint256 lienId) public view returns (address) {
    if (!_exists(lienId)) {
      revert InvalidState(InvalidStates.INVALID_LIEN_ID);
    }
    return _getPayee(_loadLienStorageSlot(), lienId);
  }
  function _getPayee(LienStorage storage s, uint256 lienId)
    internal
    view
    returns (address)
  {
    return
      s.lienMeta[lienId].payee != address(0)
        ? s.lienMeta[lienId].payee
        : ownerOf(lienId);
  }
  function _setPayee(
    LienStorage storage s,
    uint256 lienId,
    address newPayee
  ) internal {
    s.lienMeta[lienId].payee = newPayee;
    emit PayeeChanged(lienId, newPayee);
  }
}
abstract contract VaultImplementation is
  AstariaVaultBase,
  ERC721TokenReceiver_0,
  IVaultImplementation
{
  using SafeTransferLib for ERC20;
  using SafeCastLib for uint256;
  using CollateralLookup for address;
  using FixedPointMathLib for uint256;
  bytes32 public constant STRATEGY_TYPEHASH =
    keccak256("StrategyDetails(uint256 nonce,uint256 deadline,bytes32 root)");
  bytes32 constant EIP_DOMAIN =
    keccak256(
      "EIP712Domain(string version,uint256 chainId,address verifyingContract)"
    );
  bytes32 constant VERSION = keccak256("0");
  function name() external view virtual override returns (string memory);
  function symbol() external view virtual override returns (string memory);
  uint256 private constant VI_SLOT =
    uint256(keccak256("xyz.astaria.VaultImplementation.storage.location")) - 1;
  function getStrategistNonce() external view returns (uint256) {
    return _loadVISlot().strategistNonce;
  }
  function incrementNonce() external {
    VIData storage s = _loadVISlot();
    if (msg.sender != owner() && msg.sender != s.delegate) {
      revert InvalidRequest(InvalidRequestReason.NO_AUTHORITY);
    }
    s.strategistNonce++;
    emit NonceUpdated(s.strategistNonce);
  }
  function modifyDepositCap(uint256 newCap) external {
    require(msg.sender == owner()); 
    _loadVISlot().depositCap = newCap.safeCastTo88();
  }
  function _loadVISlot() internal pure returns (VIData storage s) {
    uint256 slot = VI_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function modifyAllowList(address depositor, bool enabled) external virtual {
    require(msg.sender == owner()); 
    _loadVISlot().allowList[depositor] = enabled;
    emit AllowListUpdated(depositor, enabled);
  }
  function disableAllowList() external virtual {
    require(msg.sender == owner()); 
    _loadVISlot().allowListEnabled = false;
    emit AllowListEnabled(false);
  }
  function enableAllowList() external virtual {
    require(msg.sender == owner()); 
    _loadVISlot().allowListEnabled = true;
    emit AllowListEnabled(true);
  }
  function onERC721Received(
    address, 
    address, 
    uint256, 
    bytes calldata 
  ) external pure override returns (bytes4) {
    return ERC721TokenReceiver_0.onERC721Received.selector;
  }
  modifier whenNotPaused() {
    if (ROUTER().paused()) {
      revert InvalidRequest(InvalidRequestReason.PAUSED);
    }
    if (_loadVISlot().isShutdown) {
      revert InvalidRequest(InvalidRequestReason.SHUTDOWN);
    }
    _;
  }
  function getShutdown() external view returns (bool) {
    return _loadVISlot().isShutdown;
  }
  function shutdown() external {
    require(msg.sender == owner()); 
    _loadVISlot().isShutdown = true;
    emit VaultShutdown();
  }
  function domainSeparator() public view virtual returns (bytes32) {
    return
      keccak256(
        abi.encode(
          EIP_DOMAIN,
          VERSION, 
          block.chainid,
          address(this)
        )
      );
  }
  function encodeStrategyData(
    IAstariaRouter.StrategyDetailsParam calldata strategy,
    bytes32 root
  ) external view returns (bytes memory) {
    VIData storage s = _loadVISlot();
    return _encodeStrategyData(s, strategy, root);
  }
  function _encodeStrategyData(
    VIData storage s,
    IAstariaRouter.StrategyDetailsParam calldata strategy,
    bytes32 root
  ) internal view returns (bytes memory) {
    bytes32 hash = keccak256(
      abi.encode(STRATEGY_TYPEHASH, s.strategistNonce, strategy.deadline, root)
    );
    return
      abi.encodePacked(bytes1(0x19), bytes1(0x01), domainSeparator(), hash);
  }
  function init(InitParams calldata params) external virtual {
    require(msg.sender == address(ROUTER()));
    VIData storage s = _loadVISlot();
    if (params.delegate != address(0)) {
      s.delegate = params.delegate;
    }
    s.depositCap = params.depositCap.safeCastTo88();
    if (params.allowListEnabled) {
      s.allowListEnabled = true;
      uint256 i;
      for (; i < params.allowList.length; ) {
        s.allowList[params.allowList[i]] = true;
        unchecked {
          ++i;
        }
      }
    }
  }
  function setDelegate(address delegate_) external {
    require(msg.sender == owner()); 
    VIData storage s = _loadVISlot();
    s.delegate = delegate_;
    emit DelegateUpdated(delegate_);
    emit AllowListUpdated(delegate_, true);
  }
  function _validateCommitment(
    IAstariaRouter.Commitment calldata params,
    address receiver
  ) internal view {
    uint256 collateralId = params.tokenContract.computeId(params.tokenId);
    ERC721_0 CT = ERC721_0(address(COLLATERAL_TOKEN()));
    address holder = CT.ownerOf(collateralId);
    address operator = CT.getApproved(collateralId);
    if (
      msg.sender != holder &&
      receiver != holder &&
      receiver != operator &&
      !CT.isApprovedForAll(holder, msg.sender)
    ) {
      revert InvalidRequest(InvalidRequestReason.NO_AUTHORITY);
    }
    VIData storage s = _loadVISlot();
    address recovered = ecrecover(
      keccak256(
        _encodeStrategyData(
          s,
          params.lienRequest.strategy,
          params.lienRequest.merkle.root
        )
      ),
      params.lienRequest.v,
      params.lienRequest.r,
      params.lienRequest.s
    );
    if (
      (recovered != owner() && recovered != s.delegate) ||
      recovered == address(0)
    ) {
      revert IVaultImplementation.InvalidRequest(
        InvalidRequestReason.INVALID_SIGNATURE
      );
    }
  }
  function _afterCommitToLien(
    uint40 end,
    uint256 lienId,
    uint256 slope
  ) internal virtual {}
  function _beforeCommitToLien(IAstariaRouter.Commitment calldata)
    internal
    virtual
  {}
  function commitToLien(
    IAstariaRouter.Commitment calldata params,
    address receiver
  )
    external
    whenNotPaused
    returns (uint256 lienId, ILienToken.Stack[] memory stack, uint256 payout)
  {
    _beforeCommitToLien(params);
    uint256 slopeAddition;
    (lienId, stack, slopeAddition, payout) = _requestLienAndIssuePayout(
      params,
      receiver
    );
    _afterCommitToLien(
      stack[stack.length - 1].point.end,
      lienId,
      slopeAddition
    );
  }
  function buyoutLien(
    ILienToken.Stack[] calldata stack,
    uint8 position,
    IAstariaRouter.Commitment calldata incomingTerms
  )
    external
    whenNotPaused
    returns (ILienToken.Stack[] memory, ILienToken.Stack memory)
  {
    LienToken lienToken = LienToken(address(ROUTER().LIEN_TOKEN()));
    (uint256 owed, uint256 buyout) = lienToken.getBuyout(stack[position]);
    if (buyout > ERC20(asset()).balanceOf(address(this))) {
      revert IVaultImplementation.InvalidRequest(
        InvalidRequestReason.INSUFFICIENT_FUNDS
      );
    }
    _validateCommitment(incomingTerms, recipient());
    ERC20(asset()).safeApprove(address(ROUTER().TRANSFER_PROXY()), buyout);
    return
      lienToken.buyoutLien(
        ILienToken.LienActionBuyout({
          position: position,
          encumber: ILienToken.LienActionEncumber({
            amount: owed,
            receiver: recipient(),
            lien: ROUTER().validateCommitment({
              commitment: incomingTerms,
              timeToSecondEpochEnd: _timeToSecondEndIfPublic()
            }),
            stack: stack
          })
        })
      );
  }
  function _timeToSecondEndIfPublic()
    internal
    view
    virtual
    returns (uint256 timeToSecondEpochEnd)
  {
    return 0;
  }
  function recipient() public view returns (address) {
    if (IMPL_TYPE() == uint8(IAstariaRouter.ImplementationType.PublicVault)) {
      return address(this);
    } else {
      return owner();
    }
  }
  function _requestLienAndIssuePayout(
    IAstariaRouter.Commitment calldata c,
    address receiver
  )
    internal
    returns (
      uint256 newLienId,
      ILienToken.Stack[] memory stack,
      uint256 slope,
      uint256 payout
    )
  {
    _validateCommitment(c, receiver);
    (newLienId, stack, slope) = ROUTER().requestLienPosition(c, recipient());
    payout = _handleProtocolFee(c.lienRequest.amount);
    ERC20(asset()).safeTransfer(receiver, payout);
  }
  function _handleProtocolFee(uint256 amount) internal returns (uint256) {
    address feeTo = ROUTER().feeTo();
    bool feeOn = feeTo != address(0);
    if (feeOn) {
      uint256 fee = ROUTER().getProtocolFee(amount);
      unchecked {
        amount -= fee;
      }
      ERC20(asset()).safeTransfer(feeTo, fee);
    }
    return amount;
  }
}
contract WithdrawProxy is ERC4626Cloned, WithdrawVaultBase {
  using SafeTransferLib for ERC20;
  using FixedPointMathLib for uint256;
  using SafeCastLib for uint256;
  event Claimed(
    address withdrawProxy,
    uint256 withdrawProxyAmount,
    address publicVault,
    uint256 publicVaultAmount
  );
  uint256 private constant WITHDRAW_PROXY_SLOT =
    uint256(keccak256("xyz.astaria.WithdrawProxy.storage.location")) - 1;
  struct WPStorage {
    uint88 withdrawRatio;
    uint88 expected; 
    uint40 finalAuctionEnd; 
    uint256 withdrawReserveReceived; 
  }
  enum InvalidStates {
    PROCESS_EPOCH_NOT_COMPLETE,
    FINAL_AUCTION_NOT_OVER,
    NOT_CLAIMED,
    CANT_CLAIM
  }
  error InvalidState(InvalidStates);
  function minDepositAmount()
    public
    view
    virtual
    override(ERC4626Cloned)
    returns (uint256)
  {
    return 0;
  }
  function decimals() public pure override returns (uint8) {
    return 18;
  }
  function asset()
    public
    pure
    override(ERC4626Cloned, WithdrawVaultBase)
    returns (address)
  {
    return super.asset();
  }
  function totalAssets()
    public
    view
    override(ERC4626Cloned, IERC4626)
    returns (uint256)
  {
    return ERC20(asset()).balanceOf(address(this));
  }
  function name()
    public
    view
    override(IERC20Metadata, WithdrawVaultBase)
    returns (string memory)
  {
    return
      string(abi.encodePacked("AST-WithdrawVault-", ERC20(asset()).symbol()));
  }
  function symbol()
    public
    view
    override(IERC20Metadata, WithdrawVaultBase)
    returns (string memory)
  {
    return
      string(abi.encodePacked("AST-W", VAULT(), "-", ERC20(asset()).symbol()));
  }
  function mint(uint256 shares, address receiver)
    public
    virtual
    override(ERC4626Cloned, IERC4626)
    returns (uint256 assets)
  {
    require(msg.sender == VAULT(), "only vault can mint");
    _mint(receiver, shares);
    return shares;
  }
  function deposit(uint256 assets, address receiver)
    public
    virtual
    override(ERC4626Cloned, IERC4626)
    returns (uint256 shares)
  {
    revert NotSupported();
  }
  modifier onlyWhenNoActiveAuction() {
    WPStorage storage s = _loadSlot();
    if (s.finalAuctionEnd != 0) {
      revert InvalidState(InvalidStates.NOT_CLAIMED);
    }
    _;
  }
  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  )
    public
    virtual
    override(ERC4626Cloned, IERC4626)
    onlyWhenNoActiveAuction
    returns (uint256 shares)
  {
    return super.withdraw(assets, receiver, owner);
  }
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  )
    public
    virtual
    override(ERC4626Cloned, IERC4626)
    onlyWhenNoActiveAuction
    returns (uint256 assets)
  {
    return super.redeem(shares, receiver, owner);
  }
  function supportsInterface(bytes4 interfaceId)
    external
    view
    virtual
    returns (bool)
  {
    return interfaceId == type(IWithdrawProxy).interfaceId;
  }
  function _loadSlot() internal pure returns (WPStorage storage s) {
    uint256 slot = WITHDRAW_PROXY_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function getFinalAuctionEnd() public view returns (uint256) {
    WPStorage storage s = _loadSlot();
    return s.finalAuctionEnd;
  }
  function getWithdrawRatio() public view returns (uint256) {
    WPStorage storage s = _loadSlot();
    return s.withdrawRatio;
  }
  function getExpected() public view returns (uint256) {
    WPStorage storage s = _loadSlot();
    return s.expected;
  }
  modifier onlyVault() {
    require(msg.sender == VAULT(), "only vault can call");
    _;
  }
  function increaseWithdrawReserveReceived(uint256 amount) external onlyVault {
    WPStorage storage s = _loadSlot();
    s.withdrawReserveReceived += amount;
  }
  function claim() public {
    WPStorage storage s = _loadSlot();
    if (s.finalAuctionEnd == 0) {
      revert InvalidState(InvalidStates.CANT_CLAIM);
    }
    if (PublicVault(VAULT()).getCurrentEpoch() < CLAIMABLE_EPOCH()) {
      revert InvalidState(InvalidStates.PROCESS_EPOCH_NOT_COMPLETE);
    }
    if (block.timestamp < s.finalAuctionEnd) {
      revert InvalidState(InvalidStates.FINAL_AUCTION_NOT_OVER);
    }
    uint256 transferAmount = 0;
    uint256 balance = ERC20(asset()).balanceOf(address(this)) -
      s.withdrawReserveReceived; 
    if (balance < s.expected) {
      PublicVault(VAULT()).decreaseYIntercept(
        (s.expected - balance).mulWadDown(1e18 - s.withdrawRatio)
      );
    } else {
      PublicVault(VAULT()).increaseYIntercept(
        (balance - s.expected).mulWadDown(1e18 - s.withdrawRatio)
      );
    }
    if (s.withdrawRatio == uint256(0)) {
      ERC20(asset()).safeTransfer(VAULT(), balance);
    } else {
      transferAmount = uint256(s.withdrawRatio).mulDivDown(
        balance,
        10**ERC20(asset()).decimals()
      );
      unchecked {
        balance -= transferAmount;
      }
      if (balance > 0) {
        ERC20(asset()).safeTransfer(VAULT(), balance);
      }
    }
    s.finalAuctionEnd = 0;
    emit Claimed(address(this), transferAmount, VAULT(), balance);
  }
  function drain(uint256 amount, address withdrawProxy)
    public
    onlyVault
    returns (uint256)
  {
    uint256 balance = ERC20(asset()).balanceOf(address(this));
    if (amount > balance) {
      amount = balance;
    }
    ERC20(asset()).safeTransfer(withdrawProxy, amount);
    return amount;
  }
  function setWithdrawRatio(uint256 liquidationWithdrawRatio) public onlyVault {
    _loadSlot().withdrawRatio = liquidationWithdrawRatio.safeCastTo88();
  }
  function handleNewLiquidation(
    uint256 newLienExpectedValue,
    uint256 finalAuctionDelta
  ) public onlyVault {
    WPStorage storage s = _loadSlot();
    unchecked {
      s.expected += newLienExpectedValue.safeCastTo88();
      uint40 auctionEnd = (block.timestamp + finalAuctionDelta).safeCastTo40();
      if (auctionEnd > s.finalAuctionEnd) s.finalAuctionEnd = auctionEnd;
    }
  }
}
contract PublicVault is VaultImplementation, IPublicVault, ERC4626Cloned {
  using FixedPointMathLib for uint256;
  using SafeTransferLib for ERC20;
  using SafeCastLib for uint256;
  uint256 private constant PUBLIC_VAULT_SLOT =
    uint256(keccak256("xyz.astaria.PublicVault.storage.location")) - 1;
  function asset()
    public
    pure
    virtual
    override(IAstariaVaultBase, AstariaVaultBase, ERC4626Cloned)
    returns (address)
  {
    return super.asset();
  }
  function decimals()
    public
    pure
    virtual
    override(IERC20Metadata)
    returns (uint8)
  {
    return 18;
  }
  function name()
    public
    view
    virtual
    override(IERC20Metadata, VaultImplementation)
    returns (string memory)
  {
    return string(abi.encodePacked("AST-Vault-", ERC20(asset()).symbol()));
  }
  function symbol()
    public
    view
    virtual
    override(IERC20Metadata, VaultImplementation)
    returns (string memory)
  {
    return string(abi.encodePacked("AST-V-", ERC20(asset()).symbol()));
  }
  function minDepositAmount()
    public
    view
    virtual
    override(ERC4626Cloned)
    returns (uint256)
  {
    if (ERC20(asset()).decimals() == uint8(18)) {
      return 100 gwei;
    } else {
      return 10**(ERC20(asset()).decimals() - 1);
    }
  }
  function redeem(
    uint256 shares,
    address receiver,
    address owner
  ) public virtual override(ERC4626Cloned) returns (uint256 assets) {
    VaultData storage s = _loadStorageSlot();
    assets = _redeemFutureEpoch(s, shares, receiver, owner, s.currentEpoch);
  }
  function withdraw(
    uint256 assets,
    address receiver,
    address owner
  ) public virtual override(ERC4626Cloned) returns (uint256 shares) {
    shares = previewWithdraw(assets);
    VaultData storage s = _loadStorageSlot();
    _redeemFutureEpoch(s, shares, receiver, owner, s.currentEpoch);
  }
  function redeemFutureEpoch(
    uint256 shares,
    address receiver,
    address owner,
    uint64 epoch
  ) public virtual returns (uint256 assets) {
    return
      _redeemFutureEpoch(_loadStorageSlot(), shares, receiver, owner, epoch);
  }
  function _redeemFutureEpoch(
    VaultData storage s,
    uint256 shares,
    address receiver,
    address owner,
    uint64 epoch
  ) internal virtual returns (uint256 assets) {
    ERC20Data storage es = _loadERC20Slot();
    if (msg.sender != owner) {
      uint256 allowed = es.allowance[owner][msg.sender]; 
      if (allowed != type(uint256).max) {
        es.allowance[owner][msg.sender] = allowed - shares;
      }
    }
    if (epoch < s.currentEpoch) {
      revert InvalidState(InvalidStates.EPOCH_TOO_LOW);
    }
    require((assets = previewRedeem(shares)) != 0, "ZERO_ASSETS");
    es.balanceOf[owner] -= shares;
    unchecked {
      es.balanceOf[address(this)] += shares;
    }
    emit Transfer(owner, address(this), shares);
    _deployWithdrawProxyIfNotDeployed(s, epoch);
    emit Withdraw(msg.sender, receiver, owner, assets, shares);
    WithdrawProxy(s.epochData[epoch].withdrawProxy).mint(shares, receiver);
  }
  function getWithdrawProxy(uint64 epoch) public view returns (WithdrawProxy) {
    return WithdrawProxy(_loadStorageSlot().epochData[epoch].withdrawProxy);
  }
  function getCurrentEpoch() public view returns (uint64) {
    return _loadStorageSlot().currentEpoch;
  }
  function getSlope() public view returns (uint256) {
    return uint256(_loadStorageSlot().slope);
  }
  function getWithdrawReserve() public view returns (uint256) {
    return uint256(_loadStorageSlot().withdrawReserve);
  }
  function getLiquidationWithdrawRatio() public view returns (uint256) {
    return uint256(_loadStorageSlot().liquidationWithdrawRatio);
  }
  function getYIntercept() public view returns (uint256) {
    return uint256(_loadStorageSlot().yIntercept);
  }
  function _deployWithdrawProxyIfNotDeployed(VaultData storage s, uint64 epoch)
    internal
  {
    if (s.epochData[epoch].withdrawProxy == address(0)) {
      s.epochData[epoch].withdrawProxy = ClonesWithImmutableArgs.clone(
        IAstariaRouter(ROUTER()).BEACON_PROXY_IMPLEMENTATION(),
        abi.encodePacked(
          address(ROUTER()), 
          uint8(IAstariaRouter.ImplementationType.WithdrawProxy),
          asset(), 
          address(this), 
          epoch + 1 
        )
      );
    }
  }
  function mint(uint256 shares, address receiver)
    public
    override(ERC4626Cloned)
    whenNotPaused
    returns (uint256)
  {
    VIData storage s = _loadVISlot();
    if (s.allowListEnabled) {
      require(s.allowList[receiver]);
    }
    return super.mint(shares, receiver);
  }
  function deposit(uint256 amount, address receiver)
    public
    override(ERC4626Cloned)
    whenNotPaused
    returns (uint256)
  {
    VIData storage s = _loadVISlot();
    if (s.allowListEnabled) {
      require(s.allowList[receiver]);
    }
    uint256 assets = totalAssets();
    return super.deposit(amount, receiver);
  }
  function computeDomainSeparator() internal view override returns (bytes32) {
    return super.domainSeparator();
  }
  function processEpoch() public {
    if (timeToEpochEnd() > 0) {
      revert InvalidState(InvalidStates.EPOCH_NOT_OVER);
    }
    VaultData storage s = _loadStorageSlot();
    if (s.withdrawReserve > 0) {
      revert InvalidState(InvalidStates.WITHDRAW_RESERVE_NOT_ZERO);
    }
    WithdrawProxy currentWithdrawProxy = WithdrawProxy(
      s.epochData[s.currentEpoch].withdrawProxy
    );
    if (s.currentEpoch != 0) {
      WithdrawProxy previousWithdrawProxy = WithdrawProxy(
        s.epochData[s.currentEpoch - 1].withdrawProxy
      );
      if (
        address(previousWithdrawProxy) != address(0) &&
        previousWithdrawProxy.getFinalAuctionEnd() != 0
      ) {
        previousWithdrawProxy.claim();
      }
    }
    if (s.epochData[s.currentEpoch].liensOpenForEpoch > 0) {
      revert InvalidState(InvalidStates.LIENS_OPEN_FOR_EPOCH_NOT_ZERO);
    }
    s.liquidationWithdrawRatio = 0;
    if ((address(currentWithdrawProxy) != address(0))) {
      uint256 proxySupply = currentWithdrawProxy.totalSupply();
      s.liquidationWithdrawRatio = proxySupply
        .mulDivDown(1e18, totalSupply())
        .safeCastTo88();
      currentWithdrawProxy.setWithdrawRatio(s.liquidationWithdrawRatio);
      uint256 expected = currentWithdrawProxy.getExpected();
      unchecked {
        if (totalAssets() > expected) {
          s.withdrawReserve = (totalAssets() - expected)
            .mulWadDown(s.liquidationWithdrawRatio)
            .safeCastTo88();
        } else {
          s.withdrawReserve = 0;
        }
      }
      _setYIntercept(
        s,
        s.yIntercept -
          totalAssets().mulDivDown(s.liquidationWithdrawRatio, 1e18)
      );
      _burn(address(this), proxySupply);
    }
    unchecked {
      s.currentEpoch++;
    }
  }
  function supportsInterface(bytes4 interfaceId)
    public
    pure
    override(IERC165)
    returns (bool)
  {
    return
      interfaceId == type(IPublicVault).interfaceId ||
      interfaceId == type(ERC4626Cloned).interfaceId ||
      interfaceId == type(ERC4626).interfaceId ||
      interfaceId == type(ERC20).interfaceId ||
      interfaceId == type(IERC165).interfaceId;
  }
  function transferWithdrawReserve() public {
    VaultData storage s = _loadStorageSlot();
    if (s.currentEpoch == uint64(0)) {
      return;
    }
    address currentWithdrawProxy = s
      .epochData[s.currentEpoch - 1]
      .withdrawProxy;
    if (currentWithdrawProxy != address(0)) {
      uint256 withdrawBalance = ERC20(asset()).balanceOf(address(this));
      if (s.withdrawReserve <= withdrawBalance) {
        withdrawBalance = s.withdrawReserve;
        s.withdrawReserve = 0;
      } else {
        unchecked {
          s.withdrawReserve -= withdrawBalance.safeCastTo88();
        }
      }
      ERC20(asset()).safeTransfer(currentWithdrawProxy, withdrawBalance);
      WithdrawProxy(currentWithdrawProxy).increaseWithdrawReserveReceived(
        withdrawBalance
      );
      emit WithdrawReserveTransferred(withdrawBalance);
    }
    address withdrawProxy = s.epochData[s.currentEpoch].withdrawProxy;
    if (
      s.withdrawReserve > 0 &&
      timeToEpochEnd() == 0 &&
      withdrawProxy != address(0)
    ) {
      address currentWithdrawProxy = s
        .epochData[s.currentEpoch - 1]
        .withdrawProxy;
      uint256 drainBalance = WithdrawProxy(withdrawProxy).drain(
        s.withdrawReserve,
        s.epochData[s.currentEpoch - 1].withdrawProxy
      );
      unchecked {
        s.withdrawReserve -= drainBalance.safeCastTo88();
      }
      WithdrawProxy(currentWithdrawProxy).increaseWithdrawReserveReceived(
        drainBalance
      );
    }
  }
  function _beforeCommitToLien(IAstariaRouter.Commitment calldata params)
    internal
    virtual
    override(VaultImplementation)
  {
    VaultData storage s = _loadStorageSlot();
    if (s.withdrawReserve > uint256(0)) {
      transferWithdrawReserve();
    }
    if (timeToEpochEnd() == uint256(0)) {
      processEpoch();
    }
  }
  function _loadStorageSlot() internal pure returns (VaultData storage s) {
    uint256 slot = PUBLIC_VAULT_SLOT;
    assembly {
      s.slot := slot
    }
  }
  function _afterCommitToLien(
    uint40 lienEnd,
    uint256 lienId,
    uint256 lienSlope
  ) internal virtual override {
    VaultData storage s = _loadStorageSlot();
    _accrue(s);
    unchecked {
      uint48 newSlope = s.slope + lienSlope.safeCastTo48();
      _setSlope(s, newSlope);
    }
    uint64 epoch = getLienEpoch(lienEnd);
    _increaseOpenLiens(s, epoch);
    emit LienOpen(lienId, epoch);
  }
  event SlopeUpdated(uint48 newSlope);
  function accrue() public returns (uint256) {
    return _accrue(_loadStorageSlot());
  }
  function _accrue(VaultData storage s) internal returns (uint256) {
    unchecked {
      s.yIntercept = (_totalAssets(s)).safeCastTo88();
      s.last = block.timestamp.safeCastTo40();
    }
    emit YInterceptChanged(s.yIntercept);
    return s.yIntercept;
  }
  function totalAssets()
    public
    view
    virtual
    override(ERC4626Cloned)
    returns (uint256)
  {
    VaultData storage s = _loadStorageSlot();
    return _totalAssets(s);
  }
  function _totalAssets(VaultData storage s) internal view returns (uint256) {
    uint256 delta_t = block.timestamp - s.last;
    return uint256(s.slope).mulDivDown(delta_t, 1) + uint256(s.yIntercept);
  }
  function totalSupply()
    public
    view
    virtual
    override(IERC20, ERC20Cloned)
    returns (uint256)
  {
    return
      _loadERC20Slot()._totalSupply +
      _loadStorageSlot().strategistUnclaimedShares;
  }
  function claim() external {
    require(msg.sender == owner()); 
    VaultData storage s = _loadStorageSlot();
    uint256 unclaimed = s.strategistUnclaimedShares;
    s.strategistUnclaimedShares = 0;
    _mint(msg.sender, unclaimed);
  }
  function beforePayment(BeforePaymentParams calldata params)
    external
    onlyLienToken
  {
    VaultData storage s = _loadStorageSlot();
    _accrue(s);
    unchecked {
      uint48 newSlope = s.slope - params.lienSlope.safeCastTo48();
      _setSlope(s, newSlope);
    }
    _handleStrategistInterestReward(s, params.interestOwed, params.amount);
  }
  function _setSlope(VaultData storage s, uint48 newSlope) internal {
    s.slope = newSlope;
    emit SlopeUpdated(newSlope);
  }
  function decreaseEpochLienCount(uint64 epoch) public onlyLienToken {
    _decreaseEpochLienCount(_loadStorageSlot(), epoch);
  }
  function _decreaseEpochLienCount(VaultData storage s, uint64 epoch) internal {
    s.epochData[epoch].liensOpenForEpoch--;
    emit LiensOpenForEpochRemaining(
      epoch,
      s.epochData[epoch].liensOpenForEpoch
    );
  }
  function getLienEpoch(uint64 end) public pure returns (uint64) {
    return
      uint256(Math.ceilDiv(end - uint64(START()), EPOCH_LENGTH()) - 1)
        .safeCastTo64();
  }
  function getEpochEnd(uint256 epoch) public pure returns (uint64) {
    return uint256(START() + (epoch + 1) * EPOCH_LENGTH()).safeCastTo64();
  }
  function _increaseOpenLiens(VaultData storage s, uint64 epoch) internal {
    unchecked {
      s.epochData[epoch].liensOpenForEpoch++;
    }
  }
  function afterPayment(uint256 computedSlope) public onlyLienToken {
    VaultData storage s = _loadStorageSlot();
    unchecked {
      s.slope += computedSlope.safeCastTo48();
    }
    emit SlopeUpdated(s.slope);
  }
  function afterDeposit(uint256 assets, uint256 shares)
    internal
    virtual
    override
  {
    VaultData storage s = _loadStorageSlot();
    unchecked {
      s.yIntercept += assets.safeCastTo88();
    }
    VIData storage v = _loadVISlot();
    if (v.depositCap != 0 && totalAssets() >= v.depositCap) {
      revert InvalidState(InvalidStates.DEPOSIT_CAP_EXCEEDED);
    }
    emit YInterceptChanged(s.yIntercept);
  }
  function _handleStrategistInterestReward(
    VaultData storage s,
    uint256 interestOwing,
    uint256 amount
  ) internal virtual {
    if (VAULT_FEE() != uint256(0)) {
      uint256 x = (amount > interestOwing) ? interestOwing : amount;
      uint256 fee = x.mulDivDown(VAULT_FEE(), 10000);
      uint88 feeInShares = convertToShares(fee).safeCastTo88();
      s.strategistUnclaimedShares += feeInShares;
      emit StrategistFee(feeInShares);
    }
  }
  function LIEN_TOKEN() public view returns (ILienToken) {
    return ROUTER().LIEN_TOKEN();
  }
  function handleBuyoutLien(BuyoutLienParams calldata params)
    public
    onlyLienToken
  {
    VaultData storage s = _loadStorageSlot();
    unchecked {
      uint48 newSlope = s.slope - params.lienSlope.safeCastTo48();
      _setSlope(s, newSlope);
      s.yIntercept += params.increaseYIntercept.safeCastTo88();
      s.last = block.timestamp.safeCastTo40();
    }
    _decreaseEpochLienCount(s, getLienEpoch(params.lienEnd.safeCastTo64()));
    emit YInterceptChanged(s.yIntercept);
  }
  function updateAfterLiquidationPayment(
    LiquidationPaymentParams calldata params
  ) external onlyLienToken {
    VaultData storage s = _loadStorageSlot();
    if (params.remaining > 0)
      _setYIntercept(s, s.yIntercept - params.remaining);
  }
  function updateVaultAfterLiquidation(
    uint256 maxAuctionWindow,
    AfterLiquidationParams calldata params
  ) public onlyLienToken returns (address withdrawProxyIfNearBoundary) {
    VaultData storage s = _loadStorageSlot();
    _accrue(s);
    unchecked {
      _setSlope(s, s.slope - params.lienSlope.safeCastTo48());
    }
    if (s.currentEpoch != 0) {
      transferWithdrawReserve();
    }
    uint64 lienEpoch = getLienEpoch(params.lienEnd);
    _decreaseEpochLienCount(s, lienEpoch);
    uint256 timeToEnd = timeToEpochEnd(lienEpoch);
    if (timeToEnd < maxAuctionWindow) {
      _deployWithdrawProxyIfNotDeployed(s, lienEpoch);
      withdrawProxyIfNearBoundary = s.epochData[lienEpoch].withdrawProxy;
      WithdrawProxy(withdrawProxyIfNearBoundary).handleNewLiquidation(
        params.newAmount,
        maxAuctionWindow
      );
    }
  }
  function increaseYIntercept(uint256 amount) public {
    VaultData storage s = _loadStorageSlot();
    uint64 currentEpoch = s.currentEpoch;
    require(
      currentEpoch != 0 &&
        msg.sender == s.epochData[currentEpoch - 1].withdrawProxy
    );
    _setYIntercept(s, s.yIntercept + amount);
  }
  modifier onlyLienToken() {
    require(msg.sender == address(LIEN_TOKEN()));
    _;
  }
  function decreaseYIntercept(uint256 amount) public {
    VaultData storage s = _loadStorageSlot();
    uint64 currentEpoch = s.currentEpoch;
    require(
      currentEpoch != 0 &&
        msg.sender == s.epochData[currentEpoch - 1].withdrawProxy
    );
    _setYIntercept(s, s.yIntercept - amount);
  }
  function _setYIntercept(VaultData storage s, uint256 newYIntercept) internal {
    s.yIntercept = newYIntercept.safeCastTo88();
    emit YInterceptChanged(s.yIntercept);
  }
  function timeToEpochEnd() public view returns (uint256) {
    return timeToEpochEnd(_loadStorageSlot().currentEpoch);
  }
  function timeToEpochEnd(uint256 epoch) public view returns (uint256) {
    uint256 epochEnd = START() + ((epoch + 1) * EPOCH_LENGTH());
    if (block.timestamp >= epochEnd) {
      return uint256(0);
    }
    return epochEnd - block.timestamp;
  }
  function _timeToSecondEndIfPublic()
    internal
    view
    override
    returns (uint256 timeToSecondEpochEnd)
  {
    return timeToEpochEnd() + EPOCH_LENGTH();
  }
  function timeToSecondEpochEnd() public view returns (uint256) {
    return _timeToSecondEndIfPublic();
  }
}