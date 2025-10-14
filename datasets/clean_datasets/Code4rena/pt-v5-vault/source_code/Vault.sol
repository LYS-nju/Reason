pragma solidity ^0.8.17;
library console2 {
    address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);
    function _castLogPayloadViewToPure(
        function(bytes memory) internal view fnIn
    ) internal pure returns (function(bytes memory) internal pure fnOut) {
        assembly {
            fnOut := fnIn
        }
    }
    function _sendLogPayload(bytes memory payload) internal pure {
        _castLogPayloadViewToPure(_sendLogPayloadView)(payload);
    }
    function _sendLogPayloadView(bytes memory payload) private view {
        uint256 payloadLength = payload.length;
        address consoleAddress = CONSOLE_ADDRESS;
        assembly {
            let payloadStart := add(payload, 32)
            let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
        }
    }
    function log() internal pure {
        _sendLogPayload(abi.encodeWithSignature("log()"));
    }
    function logInt(int256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
    }
    function logUint(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }
    function logString(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }
    function logBool(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }
    function logAddress(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }
    function logBytes(bytes memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
    }
    function logBytes1(bytes1 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
    }
    function logBytes2(bytes2 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
    }
    function logBytes3(bytes3 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
    }
    function logBytes4(bytes4 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
    }
    function logBytes5(bytes5 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
    }
    function logBytes6(bytes6 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
    }
    function logBytes7(bytes7 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
    }
    function logBytes8(bytes8 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
    }
    function logBytes9(bytes9 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
    }
    function logBytes10(bytes10 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
    }
    function logBytes11(bytes11 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
    }
    function logBytes12(bytes12 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
    }
    function logBytes13(bytes13 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
    }
    function logBytes14(bytes14 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
    }
    function logBytes15(bytes15 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
    }
    function logBytes16(bytes16 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
    }
    function logBytes17(bytes17 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
    }
    function logBytes18(bytes18 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
    }
    function logBytes19(bytes19 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
    }
    function logBytes20(bytes20 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
    }
    function logBytes21(bytes21 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
    }
    function logBytes22(bytes22 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
    }
    function logBytes23(bytes23 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
    }
    function logBytes24(bytes24 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
    }
    function logBytes25(bytes25 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
    }
    function logBytes26(bytes26 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
    }
    function logBytes27(bytes27 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
    }
    function logBytes28(bytes28 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
    }
    function logBytes29(bytes29 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
    }
    function logBytes30(bytes30 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
    }
    function logBytes31(bytes31 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
    }
    function logBytes32(bytes32 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
    }
    function log(uint256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
    }
    function log(int256 p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
    }
    function log(string memory p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string)", p0));
    }
    function log(bool p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
    }
    function log(address p0) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address)", p0));
    }
    function log(uint256 p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
    }
    function log(uint256 p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
    }
    function log(uint256 p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
    }
    function log(uint256 p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
    }
    function log(string memory p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
    }
    function log(string memory p0, int256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,int256)", p0, p1));
    }
    function log(string memory p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
    }
    function log(string memory p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
    }
    function log(string memory p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
    }
    function log(bool p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
    }
    function log(bool p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
    }
    function log(bool p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
    }
    function log(bool p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
    }
    function log(address p0, uint256 p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
    }
    function log(address p0, string memory p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
    }
    function log(address p0, bool p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
    }
    function log(address p0, address p1) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
    }
    function log(uint256 p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
    }
    function log(uint256 p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
    }
    function log(uint256 p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
    }
    function log(uint256 p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
    }
    function log(string memory p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
    }
    function log(string memory p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
    }
    function log(string memory p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
    }
    function log(string memory p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
    }
    function log(string memory p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
    }
    function log(string memory p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
    }
    function log(string memory p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
    }
    function log(bool p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
    }
    function log(bool p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
    }
    function log(bool p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
    }
    function log(bool p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
    }
    function log(bool p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
    }
    function log(bool p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
    }
    function log(bool p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
    }
    function log(bool p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
    }
    function log(bool p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
    }
    function log(bool p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
    }
    function log(address p0, uint256 p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
    }
    function log(address p0, string memory p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
    }
    function log(address p0, string memory p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
    }
    function log(address p0, string memory p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
    }
    function log(address p0, string memory p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
    }
    function log(address p0, bool p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
    }
    function log(address p0, bool p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
    }
    function log(address p0, bool p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
    }
    function log(address p0, bool p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
    }
    function log(address p0, address p1, uint256 p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
    }
    function log(address p0, address p1, string memory p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
    }
    function log(address p0, address p1, bool p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
    }
    function log(address p0, address p1, address p2) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
    }
    function log(uint256 p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
    }
    function log(string memory p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
    }
    function log(bool p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, uint256 p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, string memory p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, bool p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, uint256 p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, string memory p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, bool p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, uint256 p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, string memory p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, bool p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
    }
    function log(address p0, address p1, address p2, address p3) internal pure {
        _sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
    }
}
interface IERC5267 {
    event EIP712DomainChanged();
    function eip712Domain()
        external
        view
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        );
}
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
interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
    function nonces(address owner) external view returns (uint256);
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}
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
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
library Counters {
    struct Counter {
        uint256 _value; 
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}
library StorageSlot {
    struct AddressSlot {
        address value;
    }
    struct BooleanSlot {
        bool value;
    }
    struct Bytes32Slot {
        bytes32 value;
    }
    struct Uint256Slot {
        uint256 value;
    }
    struct StringSlot {
        string value;
    }
    struct BytesSlot {
        bytes value;
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
}
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
abstract contract Ownable {
    address private _owner;
    address private _pendingOwner;
    event OwnershipOffered(address indexed pendingOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor(address _initialOwner) {
        _setOwner(_initialOwner);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function pendingOwner() external view virtual returns (address) {
        return _pendingOwner;
    }
    function renounceOwnership() external virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Ownable/pendingOwner-not-zero-address");
        _pendingOwner = _newOwner;
        emit OwnershipOffered(_newOwner);
    }
    function claimOwnership() external onlyPendingOwner {
        _setOwner(_pendingOwner);
        _pendingOwner = address(0);
    }
    function _setOwner(address _newOwner) private {
        address _oldOwner = _owner;
        _owner = _newOwner;
        emit OwnershipTransferred(_oldOwner, _newOwner);
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable/caller-not-owner");
        _;
    }
    modifier onlyPendingOwner() {
        require(msg.sender == _pendingOwner, "Ownable/caller-not-pendingOwner");
        _;
    }
}
interface ILiquidationSource {
  function liquidatableBalanceOf(address tokenOut) external view returns (uint256);
  function liquidate(
    address account,
    address tokenIn,
    uint256 amountIn,
    address tokenOut,
    uint256 amountOut
  ) external returns (bool);
  function targetOf(address tokenIn) external view returns (address);
}
type UFixed32x4 is uint32;
library FixedMathLib {
  uint256 constant multiplier = 1e4;
  function mul(uint256 a, UFixed32x4 b) internal pure returns (uint256) {
    require(a <= type(uint224).max, "FixedMathLib/a-less-than-224-bits");
    return (a * UFixed32x4.unwrap(b)) / multiplier;
  }
  function div(uint256 a, UFixed32x4 b) internal pure returns (uint256) {
    require(UFixed32x4.unwrap(b) > 0, "FixedMathLib/b-greater-than-zero");
    require(a <= type(uint224).max, "FixedMathLib/a-less-than-224-bits");
    return (a * multiplier) / UFixed32x4.unwrap(b);
  }
}
error PRBMath_MulDiv18_Overflow(uint256 x, uint256 y);
error PRBMath_MulDiv_Overflow(uint256 x, uint256 y, uint256 denominator);
error PRBMath_MulDivSigned_InputTooSmall();
error PRBMath_MulDivSigned_Overflow(int256 x, int256 y);
uint128 constant MAX_UINT128 = type(uint128).max;
uint40 constant MAX_UINT40 = type(uint40).max;
uint256 constant UNIT_0 = 1e18;
uint256 constant UNIT_LPOTD = 262144;
uint256 constant UNIT_INVERSE = 78156646155174841979727994598816262306175212592076161876661_508869554232690281;
function msb(uint256 x) pure returns (uint256 result) {
    assembly ("memory-safe") {
        let factor := shl(7, gt(x, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(6, gt(x, 0xFFFFFFFFFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(5, gt(x, 0xFFFFFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(4, gt(x, 0xFFFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(3, gt(x, 0xFF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(2, gt(x, 0xF))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := shl(1, gt(x, 0x3))
        x := shr(factor, x)
        result := or(result, factor)
    }
    assembly ("memory-safe") {
        let factor := gt(x, 0x1)
        result := or(result, factor)
    }
}
function mulDiv(uint256 x, uint256 y, uint256 denominator) pure returns (uint256 result) {
    uint256 prod0; 
    uint256 prod1; 
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }
    if (prod1 == 0) {
        unchecked {
            return prod0 / denominator;
        }
    }
    if (prod1 >= denominator) {
        revert PRBMath_MulDiv_Overflow(x, y, denominator);
    }
    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, denominator)
        prod1 := sub(prod1, gt(remainder, prod0))
        prod0 := sub(prod0, remainder)
    }
    unchecked {
        uint256 lpotdod = denominator & (~denominator + 1);
        assembly ("memory-safe") {
            denominator := div(denominator, lpotdod)
            prod0 := div(prod0, lpotdod)
            lpotdod := add(div(sub(0, lpotdod), lpotdod), 1)
        }
        prod0 |= prod1 * lpotdod;
        uint256 inverse = (3 * denominator) ^ 2;
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        inverse *= 2 - denominator * inverse; 
        result = prod0 * inverse;
    }
}
function mulDiv18(uint256 x, uint256 y) pure returns (uint256 result) {
    uint256 prod0;
    uint256 prod1;
    assembly ("memory-safe") {
        let mm := mulmod(x, y, not(0))
        prod0 := mul(x, y)
        prod1 := sub(sub(mm, prod0), lt(mm, prod0))
    }
    if (prod1 >= UNIT_0) {
        revert PRBMath_MulDiv18_Overflow(x, y);
    }
    uint256 remainder;
    assembly ("memory-safe") {
        remainder := mulmod(x, y, UNIT_0)
    }
    if (prod1 == 0) {
        unchecked {
            return prod0 / UNIT_0;
        }
    }
    assembly ("memory-safe") {
        result := mul(
            or(
                div(sub(prod0, remainder), UNIT_LPOTD),
                mul(sub(prod1, gt(remainder, prod0)), add(div(sub(0, UNIT_LPOTD), UNIT_LPOTD), 1))
            ),
            UNIT_INVERSE
        )
    }
}
function mulDivSigned(int256 x, int256 y, int256 denominator) pure returns (int256 result) {
    if (x == type(int256).min || y == type(int256).min || denominator == type(int256).min) {
        revert PRBMath_MulDivSigned_InputTooSmall();
    }
    uint256 absX;
    uint256 absY;
    uint256 absD;
    unchecked {
        absX = x < 0 ? uint256(-x) : uint256(x);
        absY = y < 0 ? uint256(-y) : uint256(y);
        absD = denominator < 0 ? uint256(-denominator) : uint256(denominator);
    }
    uint256 rAbs = mulDiv(absX, absY, absD);
    if (rAbs > uint256(type(int256).max)) {
        revert PRBMath_MulDivSigned_Overflow(x, y);
    }
    uint256 sx;
    uint256 sy;
    uint256 sd;
    assembly ("memory-safe") {
        sx := sgt(x, sub(0, 1))
        sy := sgt(y, sub(0, 1))
        sd := sgt(denominator, sub(0, 1))
    }
    unchecked {
        result = sx ^ sy ^ sd == 0 ? -int256(rAbs) : int256(rAbs);
    }
}
function prbExp2(uint256 x) pure returns (uint256 result) {
    unchecked {
        result = 0x800000000000000000000000000000000000000000000000;
        if (x & 0xFF00000000000000 > 0) {
            if (x & 0x8000000000000000 > 0) {
                result = (result * 0x16A09E667F3BCC909) >> 64;
            }
            if (x & 0x4000000000000000 > 0) {
                result = (result * 0x1306FE0A31B7152DF) >> 64;
            }
            if (x & 0x2000000000000000 > 0) {
                result = (result * 0x1172B83C7D517ADCE) >> 64;
            }
            if (x & 0x1000000000000000 > 0) {
                result = (result * 0x10B5586CF9890F62A) >> 64;
            }
            if (x & 0x800000000000000 > 0) {
                result = (result * 0x1059B0D31585743AE) >> 64;
            }
            if (x & 0x400000000000000 > 0) {
                result = (result * 0x102C9A3E778060EE7) >> 64;
            }
            if (x & 0x200000000000000 > 0) {
                result = (result * 0x10163DA9FB33356D8) >> 64;
            }
            if (x & 0x100000000000000 > 0) {
                result = (result * 0x100B1AFA5ABCBED61) >> 64;
            }
        }
        if (x & 0xFF000000000000 > 0) {
            if (x & 0x80000000000000 > 0) {
                result = (result * 0x10058C86DA1C09EA2) >> 64;
            }
            if (x & 0x40000000000000 > 0) {
                result = (result * 0x1002C605E2E8CEC50) >> 64;
            }
            if (x & 0x20000000000000 > 0) {
                result = (result * 0x100162F3904051FA1) >> 64;
            }
            if (x & 0x10000000000000 > 0) {
                result = (result * 0x1000B175EFFDC76BA) >> 64;
            }
            if (x & 0x8000000000000 > 0) {
                result = (result * 0x100058BA01FB9F96D) >> 64;
            }
            if (x & 0x4000000000000 > 0) {
                result = (result * 0x10002C5CC37DA9492) >> 64;
            }
            if (x & 0x2000000000000 > 0) {
                result = (result * 0x1000162E525EE0547) >> 64;
            }
            if (x & 0x1000000000000 > 0) {
                result = (result * 0x10000B17255775C04) >> 64;
            }
        }
        if (x & 0xFF0000000000 > 0) {
            if (x & 0x800000000000 > 0) {
                result = (result * 0x1000058B91B5BC9AE) >> 64;
            }
            if (x & 0x400000000000 > 0) {
                result = (result * 0x100002C5C89D5EC6D) >> 64;
            }
            if (x & 0x200000000000 > 0) {
                result = (result * 0x10000162E43F4F831) >> 64;
            }
            if (x & 0x100000000000 > 0) {
                result = (result * 0x100000B1721BCFC9A) >> 64;
            }
            if (x & 0x80000000000 > 0) {
                result = (result * 0x10000058B90CF1E6E) >> 64;
            }
            if (x & 0x40000000000 > 0) {
                result = (result * 0x1000002C5C863B73F) >> 64;
            }
            if (x & 0x20000000000 > 0) {
                result = (result * 0x100000162E430E5A2) >> 64;
            }
            if (x & 0x10000000000 > 0) {
                result = (result * 0x1000000B172183551) >> 64;
            }
        }
        if (x & 0xFF00000000 > 0) {
            if (x & 0x8000000000 > 0) {
                result = (result * 0x100000058B90C0B49) >> 64;
            }
            if (x & 0x4000000000 > 0) {
                result = (result * 0x10000002C5C8601CC) >> 64;
            }
            if (x & 0x2000000000 > 0) {
                result = (result * 0x1000000162E42FFF0) >> 64;
            }
            if (x & 0x1000000000 > 0) {
                result = (result * 0x10000000B17217FBB) >> 64;
            }
            if (x & 0x800000000 > 0) {
                result = (result * 0x1000000058B90BFCE) >> 64;
            }
            if (x & 0x400000000 > 0) {
                result = (result * 0x100000002C5C85FE3) >> 64;
            }
            if (x & 0x200000000 > 0) {
                result = (result * 0x10000000162E42FF1) >> 64;
            }
            if (x & 0x100000000 > 0) {
                result = (result * 0x100000000B17217F8) >> 64;
            }
        }
        if (x & 0xFF00000000 > 0) {
            if (x & 0x80000000 > 0) {
                result = (result * 0x10000000058B90BFC) >> 64;
            }
            if (x & 0x40000000 > 0) {
                result = (result * 0x1000000002C5C85FE) >> 64;
            }
            if (x & 0x20000000 > 0) {
                result = (result * 0x100000000162E42FF) >> 64;
            }
            if (x & 0x10000000 > 0) {
                result = (result * 0x1000000000B17217F) >> 64;
            }
            if (x & 0x8000000 > 0) {
                result = (result * 0x100000000058B90C0) >> 64;
            }
            if (x & 0x4000000 > 0) {
                result = (result * 0x10000000002C5C860) >> 64;
            }
            if (x & 0x2000000 > 0) {
                result = (result * 0x1000000000162E430) >> 64;
            }
            if (x & 0x1000000 > 0) {
                result = (result * 0x10000000000B17218) >> 64;
            }
        }
        if (x & 0xFF0000 > 0) {
            if (x & 0x800000 > 0) {
                result = (result * 0x1000000000058B90C) >> 64;
            }
            if (x & 0x400000 > 0) {
                result = (result * 0x100000000002C5C86) >> 64;
            }
            if (x & 0x200000 > 0) {
                result = (result * 0x10000000000162E43) >> 64;
            }
            if (x & 0x100000 > 0) {
                result = (result * 0x100000000000B1721) >> 64;
            }
            if (x & 0x80000 > 0) {
                result = (result * 0x10000000000058B91) >> 64;
            }
            if (x & 0x40000 > 0) {
                result = (result * 0x1000000000002C5C8) >> 64;
            }
            if (x & 0x20000 > 0) {
                result = (result * 0x100000000000162E4) >> 64;
            }
            if (x & 0x10000 > 0) {
                result = (result * 0x1000000000000B172) >> 64;
            }
        }
        if (x & 0xFF00 > 0) {
            if (x & 0x8000 > 0) {
                result = (result * 0x100000000000058B9) >> 64;
            }
            if (x & 0x4000 > 0) {
                result = (result * 0x10000000000002C5D) >> 64;
            }
            if (x & 0x2000 > 0) {
                result = (result * 0x1000000000000162E) >> 64;
            }
            if (x & 0x1000 > 0) {
                result = (result * 0x10000000000000B17) >> 64;
            }
            if (x & 0x800 > 0) {
                result = (result * 0x1000000000000058C) >> 64;
            }
            if (x & 0x400 > 0) {
                result = (result * 0x100000000000002C6) >> 64;
            }
            if (x & 0x200 > 0) {
                result = (result * 0x10000000000000163) >> 64;
            }
            if (x & 0x100 > 0) {
                result = (result * 0x100000000000000B1) >> 64;
            }
        }
        if (x & 0xFF > 0) {
            if (x & 0x80 > 0) {
                result = (result * 0x10000000000000059) >> 64;
            }
            if (x & 0x40 > 0) {
                result = (result * 0x1000000000000002C) >> 64;
            }
            if (x & 0x20 > 0) {
                result = (result * 0x10000000000000016) >> 64;
            }
            if (x & 0x10 > 0) {
                result = (result * 0x1000000000000000B) >> 64;
            }
            if (x & 0x8 > 0) {
                result = (result * 0x10000000000000006) >> 64;
            }
            if (x & 0x4 > 0) {
                result = (result * 0x10000000000000003) >> 64;
            }
            if (x & 0x2 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
            if (x & 0x1 > 0) {
                result = (result * 0x10000000000000001) >> 64;
            }
        }
        result *= UNIT_0;
        result >>= (191 - (x >> 64));
    }
}
function prbSqrt(uint256 x) pure returns (uint256 result) {
    if (x == 0) {
        return 0;
    }
    uint256 xAux = uint256(x);
    result = 1;
    if (xAux >= 2 ** 128) {
        xAux >>= 128;
        result <<= 64;
    }
    if (xAux >= 2 ** 64) {
        xAux >>= 64;
        result <<= 32;
    }
    if (xAux >= 2 ** 32) {
        xAux >>= 32;
        result <<= 16;
    }
    if (xAux >= 2 ** 16) {
        xAux >>= 16;
        result <<= 8;
    }
    if (xAux >= 2 ** 8) {
        xAux >>= 8;
        result <<= 4;
    }
    if (xAux >= 2 ** 4) {
        xAux >>= 4;
        result <<= 2;
    }
    if (xAux >= 2 ** 2) {
        result <<= 1;
    }
    unchecked {
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        result = (result + x / result) >> 1;
        uint256 roundedDownResult = x / result;
        if (result >= roundedDownResult) {
            result = roundedDownResult;
        }
    }
}
library RingBufferLib {
    function wrap(uint256 _index, uint256 _cardinality) internal pure returns (uint256) {
        return _index % _cardinality;
    }
    function offset(
        uint256 _index,
        uint256 _amount,
        uint256 _count
    ) internal pure returns (uint256) {
        return wrap(_index + _count - _amount, _count);
    }
    function newestIndex(uint256 _nextIndex, uint256 _count)
        internal
        pure
        returns (uint256)
    {
        if (_count == 0) {
            return 0;
        }
        return wrap(_nextIndex + _count - 1, _count);
    }
    function oldestIndex(uint256 _nextIndex, uint256 _count, uint256 _cardinality)
        internal
        pure
        returns (uint256)
    {
        if (_count < _cardinality) {
            return 0;
        } else {
            return wrap(_nextIndex + _cardinality, _cardinality);
        }
    }
    function nextIndex(uint256 _index, uint256 _cardinality)
        internal
        pure
        returns (uint256)
    {
        return wrap(_index + 1, _cardinality);
    }
    function prevIndex(uint256 _index, uint256 _cardinality)
    internal
    pure
    returns (uint256) 
    {
        return _index == 0 ? _cardinality - 1 : _index - 1;
    }
}
library OverflowSafeComparatorLib {
  function lt(uint32 _a, uint32 _b, uint32 _timestamp) internal pure returns (bool) {
    if (_a <= _timestamp && _b <= _timestamp) return _a < _b;
    uint256 aAdjusted = _a > _timestamp ? _a : _a + 2 ** 32;
    uint256 bAdjusted = _b > _timestamp ? _b : _b + 2 ** 32;
    return aAdjusted < bAdjusted;
  }
  function lte(uint32 _a, uint32 _b, uint32 _timestamp) internal pure returns (bool) {
    if (_a <= _timestamp && _b <= _timestamp) return _a <= _b;
    uint256 aAdjusted = _a > _timestamp ? _a : _a + 2 ** 32;
    uint256 bAdjusted = _b > _timestamp ? _b : _b + 2 ** 32;
    return aAdjusted <= bAdjusted;
  }
  function checkedSub(uint32 _a, uint32 _b, uint32 _timestamp) internal pure returns (uint32) {
    if (_a <= _timestamp && _b <= _timestamp) return _a - _b;
    uint256 aAdjusted = _a > _timestamp ? _a : _a + 2 ** 32;
    uint256 bAdjusted = _b > _timestamp ? _b : _b + 2 ** 32;
    return uint32(aAdjusted - bAdjusted);
  }
}
struct VaultHooks {
  bool useBeforeClaimPrize;
  bool useAfterClaimPrize;
  IVaultHooks implementation;
}
interface IVaultHooks {
  function beforeClaimPrize(
    address winner,
    uint8 tier,
    uint32 prizeIndex
  ) external returns (address);
  function afterClaimPrize(
    address winner,
    uint8 tier,
    uint32 prizeIndex,
    uint256 payout,
    address recipient
  ) external;
}
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
type ShortString is bytes32;
library ShortStrings {
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;
    error StringTooLong(string str);
    error InvalidShortString();
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        string memory str = new string(32);
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
interface IERC4626 is IERC20, IERC20Metadata {
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(
        address indexed sender,
        address indexed receiver,
        address indexed owner,
        uint256 assets,
        uint256 shares
    );
    function asset() external view returns (address assetTokenAddress);
    function totalAssets() external view returns (uint256 totalManagedAssets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function maxDeposit(address receiver) external view returns (uint256 maxAssets);
    function previewDeposit(uint256 assets) external view returns (uint256 shares);
    function deposit(uint256 assets, address receiver) external returns (uint256 shares);
    function maxMint(address receiver) external view returns (uint256 maxShares);
    function previewMint(uint256 shares) external view returns (uint256 assets);
    function mint(uint256 shares, address receiver) external returns (uint256 assets);
    function maxWithdraw(address owner) external view returns (uint256 maxAssets);
    function previewWithdraw(uint256 assets) external view returns (uint256 shares);
    function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
    function maxRedeem(address owner) external view returns (uint256 maxShares);
    function previewRedeem(uint256 shares) external view returns (uint256 assets);
    function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
}
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
library LiquidatorLib {
  function getAmountOut(
    uint256 amountIn1,
    uint128 reserve1,
    uint128 reserve0
  ) internal pure returns (uint256 amountOut0) {
    require(reserve0 > 0 && reserve1 > 0, "LiquidatorLib/insufficient-reserve-liquidity-a");
    uint256 numerator = amountIn1 * reserve0;
    uint256 denominator = amountIn1 + reserve1;
    amountOut0 = numerator / denominator;
    return amountOut0;
  }
  function getAmountIn(
    uint256 amountOut0,
    uint128 reserve1,
    uint128 reserve0
  ) internal pure returns (uint256 amountIn1) {
    require(amountOut0 < reserve0, "LiquidatorLib/insufficient-reserve-liquidity-c");
    require(reserve0 > 0 && reserve1 > 0, "LiquidatorLib/insufficient-reserve-liquidity-d");
    uint256 numerator = amountOut0 * reserve1;
    uint256 denominator = uint256(reserve0) - amountOut0;
    amountIn1 = (numerator / denominator) + 1;
  }
  function _virtualBuyback(
    uint128 _reserve0,
    uint128 _reserve1,
    uint256 _amountIn1
  ) internal pure returns (uint128 reserve0, uint128 reserve1) {
    uint256 amountOut0 = getAmountOut(_amountIn1, _reserve1, _reserve0);
    reserve0 = _reserve0 - uint128(amountOut0);
    reserve1 = _reserve1 + uint128(_amountIn1);
  }
  function _virtualSwap(
    uint128 _reserve0,
    uint128 _reserve1,
    uint256 _amountIn1,
    uint256 _amountOut1,
    UFixed32x4 _swapMultiplier,
    UFixed32x4 _liquidityFraction,
    uint256 _minK
  ) internal pure returns (uint128 reserve0, uint128 reserve1) {
    uint256 virtualAmountOut1 = FixedMathLib.mul(_amountOut1, _swapMultiplier);
    uint256 virtualAmountIn0 = 0;
    if (virtualAmountOut1 < _reserve1) {
      virtualAmountIn0 = getAmountIn(virtualAmountOut1, _reserve0, _reserve1);
    } else if (virtualAmountOut1 > 0 && _reserve1 > 1) {
      virtualAmountOut1 = _reserve1 - 1;
      virtualAmountIn0 = getAmountIn(virtualAmountOut1, _reserve0, _reserve1);
    } else {
      virtualAmountOut1 = 0;
    }
    reserve0 = _reserve0 + uint128(virtualAmountIn0);
    reserve1 = _reserve1 - uint128(virtualAmountOut1);
    (reserve0, reserve1) = _applyLiquidityFraction(
      reserve0,
      reserve1,
      _amountIn1,
      _liquidityFraction,
      _minK
    );
  }
  function _applyLiquidityFraction(
    uint128 _reserve0,
    uint128 _reserve1,
    uint256 _amountIn1,
    UFixed32x4 _liquidityFraction,
    uint256 _minK
  ) internal pure returns (uint128 reserve0, uint128 reserve1) {
    uint256 reserve0_1 = (uint256(_reserve0) * _amountIn1 * FixedMathLib.multiplier) /
      (uint256(_reserve1) * UFixed32x4.unwrap(_liquidityFraction));
    uint256 reserve1_1 = FixedMathLib.div(_amountIn1, _liquidityFraction);
    if (
      reserve0_1 <= type(uint112).max &&
      reserve1_1 <= type(uint112).max &&
      uint256(reserve1_1) * reserve0_1 > _minK
    ) {
      reserve0 = uint128(reserve0_1);
      reserve1 = uint128(reserve1_1);
    } else {
      reserve0 = _reserve0;
      reserve1 = _reserve1;
    }
  }
  function computeExactAmountIn(
    uint128 _reserve0,
    uint128 _reserve1,
    uint256 _amountIn1,
    uint256 _amountOut1
  ) internal pure returns (uint256) {
    require(_amountOut1 <= _amountIn1, "LiquidatorLib/insufficient-balance-liquidity-a");
    (uint128 reserve0, uint128 reserve1) = _virtualBuyback(_reserve0, _reserve1, _amountIn1);
    return getAmountIn(_amountOut1, reserve0, reserve1);
  }
  function computeExactAmountOut(
    uint128 _reserve0,
    uint128 _reserve1,
    uint256 _amountIn1,
    uint256 _amountIn0
  ) internal pure returns (uint256) {
    (uint128 reserve0, uint128 reserve1) = _virtualBuyback(_reserve0, _reserve1, _amountIn1);
    uint256 amountOut1 = getAmountOut(_amountIn0, reserve0, reserve1);
    require(amountOut1 <= _amountIn1, "LiquidatorLib/insufficient-balance-liquidity-b");
    return amountOut1;
  }
  function swapExactAmountIn(
    uint128 _reserve0,
    uint128 _reserve1,
    uint256 _amountIn1,
    uint256 _amountIn0,
    UFixed32x4 _swapMultiplier,
    UFixed32x4 _liquidityFraction,
    uint256 _minK
  ) internal pure returns (uint128 reserve0, uint128 reserve1, uint256 amountOut1) {
    (reserve0, reserve1) = _virtualBuyback(_reserve0, _reserve1, _amountIn1);
    amountOut1 = getAmountOut(_amountIn0, reserve0, reserve1);
    require(amountOut1 <= _amountIn1, "LiquidatorLib/insufficient-balance-liquidity-c");
    reserve0 = reserve0 + uint128(_amountIn0);
    reserve1 = reserve1 - uint128(amountOut1);
    (reserve0, reserve1) = _virtualSwap(
      reserve0,
      reserve1,
      _amountIn1,
      amountOut1,
      _swapMultiplier,
      _liquidityFraction,
      _minK
    );
  }
  function swapExactAmountOut(
    uint128 _reserve0,
    uint128 _reserve1,
    uint256 _amountIn1,
    uint256 _amountOut1,
    UFixed32x4 _swapMultiplier,
    UFixed32x4 _liquidityFraction,
    uint256 _minK
  ) internal pure returns (uint128 reserve0, uint128 reserve1, uint256 amountIn0) {
    require(_amountOut1 <= _amountIn1, "LiquidatorLib/insufficient-balance-liquidity-d");
    (reserve0, reserve1) = _virtualBuyback(_reserve0, _reserve1, _amountIn1);
    amountIn0 = getAmountIn(_amountOut1, reserve0, reserve1);
    reserve0 = reserve0 + uint128(amountIn0);
    reserve1 = reserve1 - uint128(_amountOut1);
    (reserve0, reserve1) = _virtualSwap(
      reserve0,
      reserve1,
      _amountIn1,
      _amountOut1,
      _swapMultiplier,
      _liquidityFraction,
      _minK
    );
  }
}
uint16 constant MAX_CARDINALITY = 365; 
library ObservationLib {
  using OverflowSafeComparatorLib for uint32;
  struct Observation {
    uint128 cumulativeBalance;
    uint96 balance;
    uint32 timestamp;
  }
  function binarySearch(
    Observation[MAX_CARDINALITY] storage _observations,
    uint24 _newestObservationIndex,
    uint24 _oldestObservationIndex,
    uint32 _target,
    uint16 _cardinality,
    uint32 _time
  ) internal view returns (Observation memory beforeOrAt, Observation memory afterOrAt) {
    uint256 leftSide = _oldestObservationIndex;
    uint256 rightSide = _newestObservationIndex < leftSide
      ? leftSide + _cardinality - 1
      : _newestObservationIndex;
    uint256 currentIndex;
    while (true) {
      currentIndex = (leftSide + rightSide) / 2;
      beforeOrAt = _observations[uint16(RingBufferLib.wrap(currentIndex, _cardinality))];
      uint32 beforeOrAtTimestamp = beforeOrAt.timestamp;
      if (beforeOrAtTimestamp == 0) {
        leftSide = uint16(RingBufferLib.nextIndex(leftSide, _cardinality));
        continue;
      }
      afterOrAt = _observations[uint16(RingBufferLib.nextIndex(currentIndex, _cardinality))];
      bool targetAfterOrAt = beforeOrAtTimestamp.lte(_target, _time);
      if (targetAfterOrAt && _target.lte(afterOrAt.timestamp, _time)) {
        break;
      }
      if (!targetAfterOrAt) {
        rightSide = currentIndex - 1;
      } else {
        leftSide = currentIndex + 1;
      }
    }
  }
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor(string memory name_, string memory symbol_) {
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
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }
    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }
        return true;
    }
    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(from, to, amount);
        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            _balances[to] += amount;
        }
        emit Transfer(from, to, amount);
        _afterTokenTransfer(from, to, amount);
    }
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _beforeTokenTransfer(address(0), account, amount);
        _totalSupply += amount;
        unchecked {
            _balances[account] += amount;
        }
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
            _totalSupply -= amount;
        }
        emit Transfer(account, address(0), amount);
        _afterTokenTransfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _spendAllowance(address owner, address spender, uint256 amount) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);
        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}
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
error BalanceLTAmount(uint112 balance, uint96 amount, string message);
error DelegateBalanceLTAmount(uint112 delegateBalance, uint96 delegateAmount, string message);
library TwabLib {
  using OverflowSafeComparatorLib for uint32;
  struct AccountDetails {
    uint112 balance;
    uint112 delegateBalance;
    uint16 nextObservationIndex;
    uint16 cardinality;
  }
  struct Account {
    AccountDetails details;
    ObservationLib.Observation[365] observations;
  }
  function increaseBalances(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    Account storage _account,
    uint96 _amount,
    uint96 _delegateAmount
  )
    internal
    returns (ObservationLib.Observation memory observation, bool isNew, bool isObservationRecorded)
  {
    AccountDetails memory accountDetails = _account.details;
    uint32 currentTime = uint32(block.timestamp);
    uint32 index;
    ObservationLib.Observation memory newestObservation;
    isObservationRecorded = _delegateAmount != uint96(0);
    accountDetails.balance += _amount;
    accountDetails.delegateBalance += _delegateAmount;
    if (isObservationRecorded) {
      (index, newestObservation, isNew) = _getNextObservationIndex(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account.observations,
        accountDetails
      );
      if (isNew) {
        accountDetails.nextObservationIndex = uint16(
          RingBufferLib.nextIndex(uint256(index), MAX_CARDINALITY)
        );
        if (accountDetails.cardinality < MAX_CARDINALITY) {
          accountDetails.cardinality += 1;
        }
      }
      observation = ObservationLib.Observation({
        balance: uint96(accountDetails.delegateBalance),
        cumulativeBalance: _extrapolateFromBalance(newestObservation, currentTime),
        timestamp: currentTime
      });
      _account.observations[index] = observation;
    }
    _account.details = accountDetails;
  }
  function decreaseBalances(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    Account storage _account,
    uint96 _amount,
    uint96 _delegateAmount,
    string memory _revertMessage
  )
    internal
    returns (ObservationLib.Observation memory observation, bool isNew, bool isObservationRecorded)
  {
    AccountDetails memory accountDetails = _account.details;
    if (accountDetails.balance < _amount) {
      revert BalanceLTAmount(accountDetails.balance, _amount, _revertMessage);
    }
    if (accountDetails.delegateBalance < _delegateAmount) {
      revert DelegateBalanceLTAmount(
        accountDetails.delegateBalance,
        _delegateAmount,
        _revertMessage
      );
    }
    uint32 currentTime = uint32(block.timestamp);
    uint32 index;
    ObservationLib.Observation memory newestObservation;
    isObservationRecorded = _delegateAmount != uint96(0);
    unchecked {
      accountDetails.balance -= _amount;
      accountDetails.delegateBalance -= _delegateAmount;
    }
    if (isObservationRecorded) {
      (index, newestObservation, isNew) = _getNextObservationIndex(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account.observations,
        accountDetails
      );
      if (isNew) {
        accountDetails.nextObservationIndex = uint16(
          RingBufferLib.nextIndex(uint256(index), MAX_CARDINALITY)
        );
        if (accountDetails.cardinality < MAX_CARDINALITY) {
          accountDetails.cardinality += 1;
        }
      }
      observation = ObservationLib.Observation({
        balance: uint96(accountDetails.delegateBalance),
        cumulativeBalance: _extrapolateFromBalance(newestObservation, currentTime),
        timestamp: currentTime
      });
      _account.observations[index] = observation;
    }
    _account.details = accountDetails;
  }
  function getOldestObservation(
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails
  ) internal view returns (uint16 index, ObservationLib.Observation memory observation) {
    if (_accountDetails.cardinality < MAX_CARDINALITY) {
      index = 0;
      observation = _observations[0];
    } else {
      index = _accountDetails.nextObservationIndex;
      observation = _observations[index];
    }
  }
  function getNewestObservation(
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails
  ) internal view returns (uint16 index, ObservationLib.Observation memory observation) {
    index = uint16(
      RingBufferLib.newestIndex(_accountDetails.nextObservationIndex, MAX_CARDINALITY)
    );
    observation = _observations[index];
  }
  function getBalanceAt(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _targetTime
  ) internal view returns (uint256) {
    ObservationLib.Observation memory prevOrAtObservation = _getPreviousOrAtObservation(
      PERIOD_OFFSET,
      _observations,
      _accountDetails,
      _targetTime
    );
    return prevOrAtObservation.balance;
  }
  function getTwabBetween(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _startTime,
    uint32 _endTime
  ) internal view returns (uint256) {
    ObservationLib.Observation memory startObservation = _getPreviousOrAtObservation(
      PERIOD_OFFSET,
      _observations,
      _accountDetails,
      _startTime
    );
    ObservationLib.Observation memory endObservation = _getPreviousOrAtObservation(
      PERIOD_OFFSET,
      _observations,
      _accountDetails,
      _endTime
    );
    if (startObservation.timestamp != _startTime) {
      startObservation = _calculateTemporaryObservation(startObservation, _startTime);
    }
    if (endObservation.timestamp != _endTime) {
      endObservation = _calculateTemporaryObservation(endObservation, _endTime);
    }
    return
      (endObservation.cumulativeBalance - startObservation.cumulativeBalance) /
      (_endTime - _startTime);
  }
  function _calculateTemporaryObservation(
    ObservationLib.Observation memory _prevObservation,
    uint32 _time
  ) private pure returns (ObservationLib.Observation memory) {
    return
      ObservationLib.Observation({
        balance: _prevObservation.balance,
        cumulativeBalance: _extrapolateFromBalance(_prevObservation, _time),
        timestamp: _time
      });
  }
  function _getNextObservationIndex(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails
  )
    private
    view
    returns (uint16 index, ObservationLib.Observation memory newestObservation, bool isNew)
  {
    uint32 currentTime = uint32(block.timestamp);
    uint16 newestIndex;
    (newestIndex, newestObservation) = getNewestObservation(_observations, _accountDetails);
    if (newestObservation.timestamp == currentTime) {
      return (newestIndex, newestObservation, false);
    }
    uint32 currentPeriod = _getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, currentTime);
    uint32 newestObservationPeriod = _getTimestampPeriod(
      PERIOD_LENGTH,
      PERIOD_OFFSET,
      newestObservation.timestamp
    );
    if (currentPeriod == 0 || currentPeriod > newestObservationPeriod) {
      return (
        uint16(RingBufferLib.wrap(_accountDetails.nextObservationIndex, MAX_CARDINALITY)),
        newestObservation,
        true
      );
    }
    return (newestIndex, newestObservation, false);
  }
  function _extrapolateFromBalance(
    ObservationLib.Observation memory _observation,
    uint32 _timestamp
  ) private pure returns (uint128 cumulativeBalance) {
    return
      _observation.cumulativeBalance +
      uint128(_observation.balance) *
      (_timestamp.checkedSub(_observation.timestamp, _timestamp));
  }
  function getTimestampPeriod(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint32 _timestamp
  ) internal pure returns (uint32 period) {
    return _getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, _timestamp);
  }
  function _getTimestampPeriod(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    uint32 _timestamp
  ) private pure returns (uint32 period) {
    if (_timestamp <= PERIOD_OFFSET) {
      return 0;
    }
    return ((_timestamp - PERIOD_OFFSET - 1) / PERIOD_LENGTH) + 1;
  }
  function getPreviousOrAtObservation(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _targetTime
  ) internal view returns (ObservationLib.Observation memory prevOrAtObservation) {
    return _getPreviousOrAtObservation(PERIOD_OFFSET, _observations, _accountDetails, _targetTime);
  }
  function _getPreviousOrAtObservation(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _targetTime
  ) private view returns (ObservationLib.Observation memory prevOrAtObservation) {
    uint32 currentTime = uint32(block.timestamp);
    uint16 oldestTwabIndex;
    uint16 newestTwabIndex;
    if (_accountDetails.cardinality == 0) {
      return
        ObservationLib.Observation({ cumulativeBalance: 0, balance: 0, timestamp: PERIOD_OFFSET });
    }
    (newestTwabIndex, prevOrAtObservation) = getNewestObservation(_observations, _accountDetails);
    if (_targetTime >= prevOrAtObservation.timestamp) {
      return prevOrAtObservation;
    }
    if (_accountDetails.cardinality == 1) {
      if (_targetTime >= prevOrAtObservation.timestamp) {
        return prevOrAtObservation;
      } else {
        return
          ObservationLib.Observation({
            cumulativeBalance: 0,
            balance: 0,
            timestamp: PERIOD_OFFSET
          });
      }
    }
    (oldestTwabIndex, prevOrAtObservation) = getOldestObservation(_observations, _accountDetails);
    if (_targetTime < prevOrAtObservation.timestamp) {
      return
        ObservationLib.Observation({ cumulativeBalance: 0, balance: 0, timestamp: PERIOD_OFFSET });
    }
    ObservationLib.Observation memory afterOrAtObservation;
    (prevOrAtObservation, afterOrAtObservation) = ObservationLib.binarySearch(
      _observations,
      newestTwabIndex,
      oldestTwabIndex,
      _targetTime,
      _accountDetails.cardinality,
      currentTime
    );
    if (afterOrAtObservation.timestamp == _targetTime) {
      return afterOrAtObservation;
    }
    return prevOrAtObservation;
  }
  function getNextOrNewestObservation(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _targetTime
  ) internal view returns (ObservationLib.Observation memory nextOrNewestObservation) {
    return _getNextOrNewestObservation(PERIOD_OFFSET, _observations, _accountDetails, _targetTime);
  }
  function _getNextOrNewestObservation(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _targetTime
  ) private view returns (ObservationLib.Observation memory nextOrNewestObservation) {
    uint32 currentTime = uint32(block.timestamp);
    uint16 oldestTwabIndex;
    if (_accountDetails.cardinality == 0) {
      return
        ObservationLib.Observation({ cumulativeBalance: 0, balance: 0, timestamp: PERIOD_OFFSET });
    }
    (oldestTwabIndex, nextOrNewestObservation) = getOldestObservation(
      _observations,
      _accountDetails
    );
    if (_targetTime < nextOrNewestObservation.timestamp) {
      return nextOrNewestObservation;
    }
    if (_accountDetails.cardinality == 1) {
      return
        ObservationLib.Observation({ cumulativeBalance: 0, balance: 0, timestamp: PERIOD_OFFSET });
    }
    (
      uint16 newestTwabIndex,
      ObservationLib.Observation memory newestObservation
    ) = getNewestObservation(_observations, _accountDetails);
    if (_targetTime >= newestObservation.timestamp) {
      return newestObservation;
    }
    ObservationLib.Observation memory beforeOrAt;
    (beforeOrAt, nextOrNewestObservation) = ObservationLib.binarySearch(
      _observations,
      newestTwabIndex,
      oldestTwabIndex,
      _targetTime + 1 seconds, 
      _accountDetails.cardinality,
      currentTime
    );
    if (beforeOrAt.timestamp > _targetTime) {
      return beforeOrAt;
    }
    return nextOrNewestObservation;
  }
  function _getSurroundingOrAtObservations(
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _targetTime
  )
    private
    view
    returns (
      ObservationLib.Observation memory prevOrAtObservation,
      ObservationLib.Observation memory nextOrNewestObservation
    )
  {
    prevOrAtObservation = _getPreviousOrAtObservation(
      PERIOD_OFFSET,
      _observations,
      _accountDetails,
      _targetTime
    );
    nextOrNewestObservation = _getNextOrNewestObservation(
      PERIOD_OFFSET,
      _observations,
      _accountDetails,
      _targetTime
    );
  }
  function isTimeSafe(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _time
  ) internal view returns (bool) {
    return _isTimeSafe(PERIOD_LENGTH, PERIOD_OFFSET, _observations, _accountDetails, _time);
  }
  function _isTimeSafe(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _time
  ) private view returns (bool) {
    if (_accountDetails.cardinality == 0) {
      return false;
    }
    uint32 period = _getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, _time);
    if (_accountDetails.cardinality == 1) {
      return
        period != _getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, _observations[0].timestamp)
          ? true
          : _time >= _observations[0].timestamp;
    }
    ObservationLib.Observation memory preOrAtObservation;
    ObservationLib.Observation memory nextOrNewestObservation;
    (, nextOrNewestObservation) = getNewestObservation(_observations, _accountDetails);
    if (_time >= nextOrNewestObservation.timestamp) {
      return true;
    }
    (preOrAtObservation, nextOrNewestObservation) = _getSurroundingOrAtObservations(
      PERIOD_OFFSET,
      _observations,
      _accountDetails,
      _time
    );
    uint32 preOrAtPeriod = _getTimestampPeriod(
      PERIOD_LENGTH,
      PERIOD_OFFSET,
      preOrAtObservation.timestamp
    );
    uint32 postPeriod = _getTimestampPeriod(
      PERIOD_LENGTH,
      PERIOD_OFFSET,
      nextOrNewestObservation.timestamp
    );
    return period >= preOrAtPeriod && period < postPeriod;
  }
  function isTimeRangeSafe(
    uint32 PERIOD_LENGTH,
    uint32 PERIOD_OFFSET,
    ObservationLib.Observation[MAX_CARDINALITY] storage _observations,
    AccountDetails memory _accountDetails,
    uint32 _startTime,
    uint32 _endTime
  ) internal view returns (bool) {
    return
      _isTimeSafe(PERIOD_LENGTH, PERIOD_OFFSET, _observations, _accountDetails, _startTime) &&
      _isTimeSafe(PERIOD_LENGTH, PERIOD_OFFSET, _observations, _accountDetails, _endTime);
  }
}
error SameDelegateAlreadySet(address delegate);
contract TwabController {
  address public constant SPONSORSHIP_ADDRESS = address(1);
  uint32 public immutable PERIOD_LENGTH;
  uint32 public immutable PERIOD_OFFSET;
  mapping(address => mapping(address => TwabLib.Account)) internal userObservations;
  mapping(address => TwabLib.Account) internal totalSupplyObservations;
  mapping(address => mapping(address => address)) internal delegates;
  event IncreasedBalance(
    address indexed vault,
    address indexed user,
    uint96 amount,
    uint96 delegateAmount
  );
  event DecreasedBalance(
    address indexed vault,
    address indexed user,
    uint96 amount,
    uint96 delegateAmount
  );
  event ObservationRecorded(
    address indexed vault,
    address indexed user,
    uint112 balance,
    uint112 delegateBalance,
    bool isNew,
    ObservationLib.Observation observation
  );
  event Delegated(address indexed vault, address indexed delegator, address indexed delegate);
  event IncreasedTotalSupply(address indexed vault, uint96 amount, uint96 delegateAmount);
  event DecreasedTotalSupply(address indexed vault, uint96 amount, uint96 delegateAmount);
  event TotalSupplyObservationRecorded(
    address indexed vault,
    uint112 balance,
    uint112 delegateBalance,
    bool isNew,
    ObservationLib.Observation observation
  );
  constructor(uint32 _periodLength, uint32 _periodOffset) {
    PERIOD_LENGTH = _periodLength;
    PERIOD_OFFSET = _periodOffset;
  }
  function getAccount(address vault, address user) external view returns (TwabLib.Account memory) {
    return userObservations[vault][user];
  }
  function getTotalSupplyAccount(address vault) external view returns (TwabLib.Account memory) {
    return totalSupplyObservations[vault];
  }
  function balanceOf(address vault, address user) external view returns (uint256) {
    return userObservations[vault][user].details.balance;
  }
  function totalSupply(address vault) external view returns (uint256) {
    return totalSupplyObservations[vault].details.balance;
  }
  function totalSupplyDelegateBalance(address vault) external view returns (uint256) {
    return totalSupplyObservations[vault].details.delegateBalance;
  }
  function delegateOf(address vault, address user) external view returns (address) {
    return _delegateOf(vault, user);
  }
  function delegateBalanceOf(address vault, address user) external view returns (uint256) {
    return userObservations[vault][user].details.delegateBalance;
  }
  function getBalanceAt(
    address vault,
    address user,
    uint32 targetTime
  ) external view returns (uint256) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return TwabLib.getBalanceAt(PERIOD_OFFSET, _account.observations, _account.details, targetTime);
  }
  function getTotalSupplyAt(address vault, uint32 targetTime) external view returns (uint256) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return TwabLib.getBalanceAt(PERIOD_OFFSET, _account.observations, _account.details, targetTime);
  }
  function getTwabBetween(
    address vault,
    address user,
    uint32 startTime,
    uint32 endTime
  ) external view returns (uint256) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return
      TwabLib.getTwabBetween(
        PERIOD_OFFSET,
        _account.observations,
        _account.details,
        startTime,
        endTime
      );
  }
  function getTotalSupplyTwabBetween(
    address vault,
    uint32 startTime,
    uint32 endTime
  ) external view returns (uint256) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return
      TwabLib.getTwabBetween(
        PERIOD_OFFSET,
        _account.observations,
        _account.details,
        startTime,
        endTime
      );
  }
  function getNewestObservation(
    address vault,
    address user
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return TwabLib.getNewestObservation(_account.observations, _account.details);
  }
  function getOldestObservation(
    address vault,
    address user
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = userObservations[vault][user];
    return TwabLib.getOldestObservation(_account.observations, _account.details);
  }
  function getNewestTotalSupplyObservation(
    address vault
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return TwabLib.getNewestObservation(_account.observations, _account.details);
  }
  function getOldestTotalSupplyObservation(
    address vault
  ) external view returns (uint16, ObservationLib.Observation memory) {
    TwabLib.Account storage _account = totalSupplyObservations[vault];
    return TwabLib.getOldestObservation(_account.observations, _account.details);
  }
  function getTimestampPeriod(uint32 time) external view returns (uint32) {
    return TwabLib.getTimestampPeriod(PERIOD_LENGTH, PERIOD_OFFSET, time);
  }
  function isTimeSafe(address vault, address user, uint32 time) external view returns (bool) {
    TwabLib.Account storage account = userObservations[vault][user];
    return
      TwabLib.isTimeSafe(PERIOD_LENGTH, PERIOD_OFFSET, account.observations, account.details, time);
  }
  function isTimeRangeSafe(
    address vault,
    address user,
    uint32 startTime,
    uint32 endTime
  ) external view returns (bool) {
    TwabLib.Account storage account = userObservations[vault][user];
    return
      TwabLib.isTimeRangeSafe(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        account.observations,
        account.details,
        startTime,
        endTime
      );
  }
  function isTotalSupplyTimeSafe(address vault, uint32 time) external view returns (bool) {
    TwabLib.Account storage account = totalSupplyObservations[vault];
    return
      TwabLib.isTimeSafe(PERIOD_LENGTH, PERIOD_OFFSET, account.observations, account.details, time);
  }
  function isTotalSupplyTimeRangeSafe(
    address vault,
    uint32 startTime,
    uint32 endTime
  ) external view returns (bool) {
    TwabLib.Account storage account = totalSupplyObservations[vault];
    return
      TwabLib.isTimeRangeSafe(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        account.observations,
        account.details,
        startTime,
        endTime
      );
  }
  function mint(address _to, uint96 _amount) external {
    _transferBalance(msg.sender, address(0), _to, _amount);
  }
  function burn(address _from, uint96 _amount) external {
    _transferBalance(msg.sender, _from, address(0), _amount);
  }
  function transfer(address _from, address _to, uint96 _amount) external {
    _transferBalance(msg.sender, _from, _to, _amount);
  }
  function delegate(address _vault, address _to) external {
    _delegate(_vault, msg.sender, _to);
  }
  function sponsor(address _from) external {
    _delegate(msg.sender, _from, SPONSORSHIP_ADDRESS);
  }
  function _transferBalance(address _vault, address _from, address _to, uint96 _amount) internal {
    if (_from == _to) {
      return;
    }
    address _fromDelegate = _delegateOf(_vault, _from);
    address _toDelegate = _delegateOf(_vault, _to);
    if (_from != address(0)) {
      bool _isFromDelegate = _fromDelegate == _from;
      _decreaseBalances(_vault, _from, _amount, _isFromDelegate ? _amount : 0);
      if (!_isFromDelegate && _fromDelegate != SPONSORSHIP_ADDRESS) {
        _decreaseBalances(_vault, _fromDelegate, 0, _amount);
      }
      if (
        _to == address(0) ||
        (_toDelegate == SPONSORSHIP_ADDRESS && _fromDelegate != SPONSORSHIP_ADDRESS)
      ) {
        _decreaseTotalSupplyBalances(
          _vault,
          _to == address(0) ? _amount : 0,
          (_to == address(0) && _fromDelegate != SPONSORSHIP_ADDRESS) ||
            (_toDelegate == SPONSORSHIP_ADDRESS && _fromDelegate != SPONSORSHIP_ADDRESS)
            ? _amount
            : 0
        );
      }
    }
    if (_to != address(0)) {
      bool _isToDelegate = _toDelegate == _to;
      _increaseBalances(_vault, _to, _amount, _isToDelegate ? _amount : 0);
      if (!_isToDelegate && _toDelegate != SPONSORSHIP_ADDRESS) {
        _increaseBalances(_vault, _toDelegate, 0, _amount);
      }
      if (
        _from == address(0) ||
        (_fromDelegate == SPONSORSHIP_ADDRESS && _toDelegate != SPONSORSHIP_ADDRESS)
      ) {
        _increaseTotalSupplyBalances(
          _vault,
          _from == address(0) ? _amount : 0,
          (_from == address(0) && _toDelegate != SPONSORSHIP_ADDRESS) ||
            (_fromDelegate == SPONSORSHIP_ADDRESS && _toDelegate != SPONSORSHIP_ADDRESS)
            ? _amount
            : 0
        );
      }
    }
  }
  function _delegateOf(address _vault, address _user) internal view returns (address) {
    address _userDelegate;
    if (_user != address(0)) {
      _userDelegate = delegates[_vault][_user];
      if (_userDelegate == address(0)) {
        _userDelegate = _user;
      }
    }
    return _userDelegate;
  }
  function _transferDelegateBalance(
    address _vault,
    address _fromDelegate,
    address _toDelegate,
    uint96 _amount
  ) internal {
    if (_fromDelegate != address(0) && _fromDelegate != SPONSORSHIP_ADDRESS) {
      _decreaseBalances(_vault, _fromDelegate, 0, _amount);
      if (_toDelegate == address(0) || _toDelegate == SPONSORSHIP_ADDRESS) {
        _decreaseTotalSupplyBalances(_vault, 0, _amount);
      }
    }
    if (_toDelegate != address(0) && _toDelegate != SPONSORSHIP_ADDRESS) {
      _increaseBalances(_vault, _toDelegate, 0, _amount);
      if (_fromDelegate == address(0) || _fromDelegate == SPONSORSHIP_ADDRESS) {
        _increaseTotalSupplyBalances(_vault, 0, _amount);
      }
    }
  }
  function _delegate(address _vault, address _from, address _to) internal {
    address _currentDelegate = _delegateOf(_vault, _from);
    if (_to == _currentDelegate) {
      revert SameDelegateAlreadySet(_to);
    }
    delegates[_vault][_from] = _to;
    _transferDelegateBalance(
      _vault,
      _currentDelegate,
      _to,
      uint96(userObservations[_vault][_from].details.balance)
    );
    emit Delegated(_vault, _from, _to);
  }
  function _increaseBalances(
    address _vault,
    address _user,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = userObservations[_vault][_user];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded
    ) = TwabLib.increaseBalances(PERIOD_LENGTH, PERIOD_OFFSET, _account, _amount, _delegateAmount);
    emit IncreasedBalance(_vault, _user, _amount, _delegateAmount);
    if (_isObservationRecorded) {
      emit ObservationRecorded(
        _vault,
        _user,
        _account.details.balance,
        _account.details.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
  function _decreaseBalances(
    address _vault,
    address _user,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = userObservations[_vault][_user];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded
    ) = TwabLib.decreaseBalances(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account,
        _amount,
        _delegateAmount,
        "TC/observation-burn-lt-delegate-balance"
      );
    emit DecreasedBalance(_vault, _user, _amount, _delegateAmount);
    if (_isObservationRecorded) {
      emit ObservationRecorded(
        _vault,
        _user,
        _account.details.balance,
        _account.details.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
  function _decreaseTotalSupplyBalances(
    address _vault,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = totalSupplyObservations[_vault];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded
    ) = TwabLib.decreaseBalances(
        PERIOD_LENGTH,
        PERIOD_OFFSET,
        _account,
        _amount,
        _delegateAmount,
        "TC/burn-amount-exceeds-total-supply-balance"
      );
    emit DecreasedTotalSupply(_vault, _amount, _delegateAmount);
    if (_isObservationRecorded) {
      emit TotalSupplyObservationRecorded(
        _vault,
        _account.details.balance,
        _account.details.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
  function _increaseTotalSupplyBalances(
    address _vault,
    uint96 _amount,
    uint96 _delegateAmount
  ) internal {
    TwabLib.Account storage _account = totalSupplyObservations[_vault];
    (
      ObservationLib.Observation memory _observation,
      bool _isNewObservation,
      bool _isObservationRecorded
    ) = TwabLib.increaseBalances(PERIOD_LENGTH, PERIOD_OFFSET, _account, _amount, _delegateAmount);
    emit IncreasedTotalSupply(_vault, _amount, _delegateAmount);
    if (_isObservationRecorded) {
      emit TotalSupplyObservationRecorded(
        _vault,
        _account.details.balance,
        _account.details.delegateBalance,
        _isNewObservation,
        _observation
      );
    }
  }
}
contract LiquidationPair {
  ILiquidationSource public immutable source;
  address public immutable tokenIn;
  address public immutable tokenOut;
  UFixed32x4 public immutable swapMultiplier;
  UFixed32x4 public immutable liquidityFraction;
  uint128 public virtualReserveIn;
  uint128 public virtualReserveOut;
  uint256 public immutable minK;
  event Swapped(
    address indexed account,
    uint256 amountIn,
    uint256 amountOut,
    uint128 virtualReserveIn,
    uint128 virtualReserveOut
  );
  constructor(
    ILiquidationSource _source,
    address _tokenIn,
    address _tokenOut,
    UFixed32x4 _swapMultiplier,
    UFixed32x4 _liquidityFraction,
    uint128 _virtualReserveIn,
    uint128 _virtualReserveOut,
    uint256 _minK
  ) {
    require(
      UFixed32x4.unwrap(_liquidityFraction) > 0,
      "LiquidationPair/liquidity-fraction-greater-than-zero"
    );
    require(
      UFixed32x4.unwrap(_liquidityFraction) > 0,
      "LiquidationPair/liquidity-fraction-greater-than-zero"
    );
    require(
      UFixed32x4.unwrap(_swapMultiplier) <= 1e4,
      "LiquidationPair/swap-multiplier-less-than-one"
    );
    require(
      UFixed32x4.unwrap(_liquidityFraction) <= 1e4,
      "LiquidationPair/liquidity-fraction-less-than-one"
    );
    require(
      uint256(_virtualReserveIn) * _virtualReserveOut >= _minK,
      "LiquidationPair/virtual-reserves-greater-than-min-k"
    );
    require(_minK > 0, "LiquidationPair/min-k-greater-than-zero");
    require(_virtualReserveIn <= type(uint112).max, "LiquidationPair/virtual-reserve-in-too-large");
    require(
      _virtualReserveOut <= type(uint112).max,
      "LiquidationPair/virtual-reserve-out-too-large"
    );
    source = _source;
    tokenIn = _tokenIn;
    tokenOut = _tokenOut;
    swapMultiplier = _swapMultiplier;
    liquidityFraction = _liquidityFraction;
    virtualReserveIn = _virtualReserveIn;
    virtualReserveOut = _virtualReserveOut;
    minK = _minK;
  }
  function target() external view returns (address) {
    return source.targetOf(tokenIn);
  }
  function maxAmountIn() external view returns (uint256) {
    return
      LiquidatorLib.computeExactAmountIn(
        virtualReserveIn,
        virtualReserveOut,
        _availableReserveOut(),
        _availableReserveOut()
      );
  }
  function maxAmountOut() external view returns (uint256) {
    return _availableReserveOut();
  }
  function nextLiquidationState() external view returns (uint128, uint128) {
    return
      LiquidatorLib._virtualBuyback(virtualReserveIn, virtualReserveOut, _availableReserveOut());
  }
  function computeExactAmountIn(uint256 _amountOut) external view returns (uint256) {
    return
      LiquidatorLib.computeExactAmountIn(
        virtualReserveIn,
        virtualReserveOut,
        _availableReserveOut(),
        _amountOut
      );
  }
  function computeExactAmountOut(uint256 _amountIn) external view returns (uint256) {
    return
      LiquidatorLib.computeExactAmountOut(
        virtualReserveIn,
        virtualReserveOut,
        _availableReserveOut(),
        _amountIn
      );
  }
  function swapExactAmountIn(
    address _account,
    uint256 _amountIn,
    uint256 _amountOutMin
  ) external returns (uint256) {
    uint256 availableBalance = _availableReserveOut();
    (uint128 _virtualReserveIn, uint128 _virtualReserveOut, uint256 amountOut) = LiquidatorLib
      .swapExactAmountIn(
        virtualReserveIn,
        virtualReserveOut,
        availableBalance,
        _amountIn,
        swapMultiplier,
        liquidityFraction,
        minK
      );
    virtualReserveIn = _virtualReserveIn;
    virtualReserveOut = _virtualReserveOut;
    require(amountOut >= _amountOutMin, "LiquidationPair/min-not-guaranteed");
    _swap(_account, amountOut, _amountIn);
    emit Swapped(_account, _amountIn, amountOut, _virtualReserveIn, _virtualReserveOut);
    return amountOut;
  }
  function swapExactAmountOut(
    address _account,
    uint256 _amountOut,
    uint256 _amountInMax
  ) external returns (uint256) {
    uint256 availableBalance = _availableReserveOut();
    (uint128 _virtualReserveIn, uint128 _virtualReserveOut, uint256 amountIn) = LiquidatorLib
      .swapExactAmountOut(
        virtualReserveIn,
        virtualReserveOut,
        availableBalance,
        _amountOut,
        swapMultiplier,
        liquidityFraction,
        minK
      );
    virtualReserveIn = _virtualReserveIn;
    virtualReserveOut = _virtualReserveOut;
    require(amountIn <= _amountInMax, "LiquidationPair/max-not-guaranteed");
    _swap(_account, _amountOut, amountIn);
    emit Swapped(_account, amountIn, _amountOut, _virtualReserveIn, _virtualReserveOut);
    return amountIn;
  }
  function _availableReserveOut() internal view returns (uint256) {
    return source.liquidatableBalanceOf(tokenOut);
  }
  function _swap(address _account, uint256 _amountOut, uint256 _amountIn) internal {
    source.liquidate(_account, tokenIn, _amountIn, tokenOut, _amountOut);
  }
}
abstract contract EIP712 is IERC5267 {
    using ShortStrings for *;
    bytes32 private constant _TYPE_HASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
    bytes32 private immutable _cachedDomainSeparator;
    uint256 private immutable _cachedChainId;
    address private immutable _cachedThis;
    bytes32 private immutable _hashedName;
    bytes32 private immutable _hashedVersion;
    ShortString private immutable _name;
    ShortString private immutable _version;
    string private _nameFallback;
    string private _versionFallback;
    constructor(string memory name, string memory version) {
        _name = name.toShortStringWithFallback(_nameFallback);
        _version = version.toShortStringWithFallback(_versionFallback);
        _hashedName = keccak256(bytes(name));
        _hashedVersion = keccak256(bytes(version));
        _cachedChainId = block.chainid;
        _cachedDomainSeparator = _buildDomainSeparator();
        _cachedThis = address(this);
    }
    function _domainSeparatorV4() internal view returns (bytes32) {
        if (address(this) == _cachedThis && block.chainid == _cachedChainId) {
            return _cachedDomainSeparator;
        } else {
            return _buildDomainSeparator();
        }
    }
    function _buildDomainSeparator() private view returns (bytes32) {
        return keccak256(abi.encode(_TYPE_HASH, _hashedName, _hashedVersion, block.chainid, address(this)));
    }
    function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32) {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
    function eip712Domain()
        public
        view
        virtual
        override
        returns (
            bytes1 fields,
            string memory name,
            string memory version,
            uint256 chainId,
            address verifyingContract,
            bytes32 salt,
            uint256[] memory extensions
        )
    {
        return (
            hex"0f", 
            _name.toStringWithFallback(_nameFallback),
            _version.toStringWithFallback(_versionFallback),
            block.chainid,
            address(this),
            bytes32(0),
            new uint256[](0)
        );
    }
}
abstract contract ERC4626 is ERC20, IERC4626 {
    using Math for uint256;
    IERC20 private immutable _asset;
    uint8 private immutable _underlyingDecimals;
    constructor(IERC20 asset_) {
        (bool success, uint8 assetDecimals) = _tryGetAssetDecimals(asset_);
        _underlyingDecimals = success ? assetDecimals : 18;
        _asset = asset_;
    }
    function _tryGetAssetDecimals(IERC20 asset_) private view returns (bool, uint8) {
        (bool success, bytes memory encodedDecimals) = address(asset_).staticcall(
            abi.encodeWithSelector(IERC20Metadata.decimals.selector)
        );
        if (success && encodedDecimals.length >= 32) {
            uint256 returnedDecimals = abi.decode(encodedDecimals, (uint256));
            if (returnedDecimals <= type(uint8).max) {
                return (true, uint8(returnedDecimals));
            }
        }
        return (false, 0);
    }
    function decimals() public view virtual override(IERC20Metadata, ERC20) returns (uint8) {
        return _underlyingDecimals + _decimalsOffset();
    }
    function asset() public view virtual override returns (address) {
        return address(_asset);
    }
    function totalAssets() public view virtual override returns (uint256) {
        return _asset.balanceOf(address(this));
    }
    function convertToShares(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Down);
    }
    function convertToAssets(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }
    function maxDeposit(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }
    function maxMint(address) public view virtual override returns (uint256) {
        return type(uint256).max;
    }
    function maxWithdraw(address owner) public view virtual override returns (uint256) {
        return _convertToAssets(balanceOf(owner), Math.Rounding.Down);
    }
    function maxRedeem(address owner) public view virtual override returns (uint256) {
        return balanceOf(owner);
    }
    function previewDeposit(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Down);
    }
    function previewMint(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Up);
    }
    function previewWithdraw(uint256 assets) public view virtual override returns (uint256) {
        return _convertToShares(assets, Math.Rounding.Up);
    }
    function previewRedeem(uint256 shares) public view virtual override returns (uint256) {
        return _convertToAssets(shares, Math.Rounding.Down);
    }
    function deposit(uint256 assets, address receiver) public virtual override returns (uint256) {
        require(assets <= maxDeposit(receiver), "ERC4626: deposit more than max");
        uint256 shares = previewDeposit(assets);
        _deposit(_msgSender(), receiver, assets, shares);
        return shares;
    }
    function mint(uint256 shares, address receiver) public virtual override returns (uint256) {
        require(shares <= maxMint(receiver), "ERC4626: mint more than max");
        uint256 assets = previewMint(shares);
        _deposit(_msgSender(), receiver, assets, shares);
        return assets;
    }
    function withdraw(uint256 assets, address receiver, address owner) public virtual override returns (uint256) {
        require(assets <= maxWithdraw(owner), "ERC4626: withdraw more than max");
        uint256 shares = previewWithdraw(assets);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return shares;
    }
    function redeem(uint256 shares, address receiver, address owner) public virtual override returns (uint256) {
        require(shares <= maxRedeem(owner), "ERC4626: redeem more than max");
        uint256 assets = previewRedeem(shares);
        _withdraw(_msgSender(), receiver, owner, assets, shares);
        return assets;
    }
    function _convertToShares(uint256 assets, Math.Rounding rounding) internal view virtual returns (uint256) {
        return assets.mulDiv(totalSupply() + 10 ** _decimalsOffset(), totalAssets() + 1, rounding);
    }
    function _convertToAssets(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, totalSupply() + 10 ** _decimalsOffset(), rounding);
    }
    function _deposit(address caller, address receiver, uint256 assets, uint256 shares) internal virtual {
        SafeERC20.safeTransferFrom(_asset, caller, address(this), assets);
        _mint(receiver, shares);
        emit Deposit(caller, receiver, assets, shares);
    }
    function _withdraw(
        address caller,
        address receiver,
        address owner,
        uint256 assets,
        uint256 shares
    ) internal virtual {
        if (caller != owner) {
            _spendAllowance(owner, caller, shares);
        }
        _burn(owner, shares);
        SafeERC20.safeTransfer(_asset, receiver, assets);
        emit Withdraw(caller, receiver, owner, assets, shares);
    }
    function _decimalsOffset() internal view virtual returns (uint8) {
        return 0;
    }
}
abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;
    mapping(address => Counters.Counter) private _nonces;
    bytes32 private constant _PERMIT_TYPEHASH =
        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 private _PERMIT_TYPEHASH_DEPRECATED_SLOT;
    constructor(string memory name) EIP712(name, "1") {}
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        require(block.timestamp <= deadline, "ERC20Permit: expired deadline");
        bytes32 structHash = keccak256(abi.encode(_PERMIT_TYPEHASH, owner, spender, value, _useNonce(owner), deadline));
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ECDSA.recover(hash, v, r, s);
        require(signer == owner, "ERC20Permit: invalid signature");
        _approve(owner, spender, value);
    }
    function nonces(address owner) public view virtual override returns (uint256) {
        return _nonces[owner].current();
    }
    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }
    function _useNonce(address owner) internal virtual returns (uint256 current) {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}
function intoSD59x18_0(SD1x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(SD1x18.unwrap(x)));
}
function intoUD2x18_0(SD1x18 x) pure returns (UD2x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUD2x18_Underflow(x);
    }
    result = UD2x18.wrap(uint64(xInt));
}
function intoUD60x18_0(SD1x18 x) pure returns (UD60x18 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint64(xInt));
}
function intoUint256_0(SD1x18 x) pure returns (uint256 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUint256_Underflow(x);
    }
    result = uint256(uint64(xInt));
}
function intoUint128_0(SD1x18 x) pure returns (uint128 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUint128_Underflow(x);
    }
    result = uint128(uint64(xInt));
}
function intoUint40_0(SD1x18 x) pure returns (uint40 result) {
    int64 xInt = SD1x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD1x18_ToUint40_Underflow(x);
    }
    if (xInt > int64(uint64(MAX_UINT40))) {
        revert PRBMath_SD1x18_ToUint40_Overflow(x);
    }
    result = uint40(uint64(xInt));
}
function sd1x18(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
function unwrap_0(SD1x18 x) pure returns (int64 result) {
    result = SD1x18.unwrap(x);
}
function wrap_0(int64 x) pure returns (SD1x18 result) {
    result = SD1x18.wrap(x);
}
SD1x18 constant E_0 = SD1x18.wrap(2_718281828459045235);
int64 constant uMAX_SD1x18 = 9_223372036854775807;
SD1x18 constant MAX_SD1x18 = SD1x18.wrap(uMAX_SD1x18);
int64 constant uMIN_SD1x18 = -9_223372036854775808;
SD1x18 constant MIN_SD1x18 = SD1x18.wrap(uMIN_SD1x18);
SD1x18 constant PI_0 = SD1x18.wrap(3_141592653589793238);
SD1x18 constant UNIT_1 = SD1x18.wrap(1e18);
int256 constant uUNIT_0 = 1e18;
error PRBMath_SD1x18_ToUD2x18_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUD60x18_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUint128_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUint256_Underflow(SD1x18 x);
error PRBMath_SD1x18_ToUint40_Overflow(SD1x18 x);
error PRBMath_SD1x18_ToUint40_Underflow(SD1x18 x);
type SD1x18 is int64;
using { intoSD59x18_0, intoUD2x18_0, intoUD60x18_0, intoUint256_0, intoUint128_0, intoUint40_0, unwrap_0 } for SD1x18 global;
function intoInt256(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}
function intoSD1x18_0(SD59x18 x) pure returns (SD1x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < uMIN_SD1x18) {
        revert PRBMath_SD59x18_IntoSD1x18_Underflow(x);
    }
    if (xInt > uMAX_SD1x18) {
        revert PRBMath_SD59x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xInt));
}
function intoUD2x18_1(SD59x18 x) pure returns (UD2x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUD2x18_Underflow(x);
    }
    if (xInt > int256(uint256(uMAX_UD2x18))) {
        revert PRBMath_SD59x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(uint256(xInt)));
}
function intoUD60x18_1(SD59x18 x) pure returns (UD60x18 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUD60x18_Underflow(x);
    }
    result = UD60x18.wrap(uint256(xInt));
}
function intoUint256_1(SD59x18 x) pure returns (uint256 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUint256_Underflow(x);
    }
    result = uint256(xInt);
}
function intoUint128_1(SD59x18 x) pure returns (uint128 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUint128_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT128))) {
        revert PRBMath_SD59x18_IntoUint128_Overflow(x);
    }
    result = uint128(uint256(xInt));
}
function intoUint40_1(SD59x18 x) pure returns (uint40 result) {
    int256 xInt = SD59x18.unwrap(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_IntoUint40_Underflow(x);
    }
    if (xInt > int256(uint256(MAX_UINT40))) {
        revert PRBMath_SD59x18_IntoUint40_Overflow(x);
    }
    result = uint40(uint256(xInt));
}
function sd(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
function sd59x18(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
function unwrap_1(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x);
}
function wrap_1(int256 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(x);
}
SD59x18 constant E_1 = SD59x18.wrap(2_718281828459045235);
int256 constant uHALF_UNIT_0 = 0.5e18;
SD59x18 constant HALF_UNIT_0 = SD59x18.wrap(uHALF_UNIT_0);
int256 constant uLOG2_10_0 = 3_321928094887362347;
SD59x18 constant LOG2_10_0 = SD59x18.wrap(uLOG2_10_0);
int256 constant uLOG2_E_0 = 1_442695040888963407;
SD59x18 constant LOG2_E_0 = SD59x18.wrap(uLOG2_E_0);
int256 constant uMAX_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_792003956564819967;
SD59x18 constant MAX_SD59x18 = SD59x18.wrap(uMAX_SD59x18);
int256 constant uMAX_WHOLE_SD59x18 = 57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MAX_WHOLE_SD59x18 = SD59x18.wrap(uMAX_WHOLE_SD59x18);
int256 constant uMIN_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_792003956564819968;
SD59x18 constant MIN_SD59x18 = SD59x18.wrap(uMIN_SD59x18);
int256 constant uMIN_WHOLE_SD59x18 = -57896044618658097711785492504343953926634992332820282019728_000000000000000000;
SD59x18 constant MIN_WHOLE_SD59x18 = SD59x18.wrap(uMIN_WHOLE_SD59x18);
SD59x18 constant PI_1 = SD59x18.wrap(3_141592653589793238);
int256 constant uUNIT_1 = 1e18;
SD59x18 constant UNIT_2 = SD59x18.wrap(1e18);
SD59x18 constant ZERO_0 = SD59x18.wrap(0);
error PRBMath_SD59x18_Abs_MinSD59x18();
error PRBMath_SD59x18_Ceil_Overflow(SD59x18 x);
error PRBMath_SD59x18_Convert_Overflow(int256 x);
error PRBMath_SD59x18_Convert_Underflow(int256 x);
error PRBMath_SD59x18_Div_InputTooSmall();
error PRBMath_SD59x18_Div_Overflow(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_Exp_InputTooBig(SD59x18 x);
error PRBMath_SD59x18_Exp2_InputTooBig(SD59x18 x);
error PRBMath_SD59x18_Floor_Underflow(SD59x18 x);
error PRBMath_SD59x18_Gm_NegativeProduct(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_Gm_Overflow(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_IntoSD1x18_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoSD1x18_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUD2x18_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoUD2x18_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUD60x18_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint128_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint128_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint256_Underflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint40_Overflow(SD59x18 x);
error PRBMath_SD59x18_IntoUint40_Underflow(SD59x18 x);
error PRBMath_SD59x18_Log_InputTooSmall(SD59x18 x);
error PRBMath_SD59x18_Mul_InputTooSmall();
error PRBMath_SD59x18_Mul_Overflow(SD59x18 x, SD59x18 y);
error PRBMath_SD59x18_Powu_Overflow(SD59x18 x, uint256 y);
error PRBMath_SD59x18_Sqrt_NegativeInput(SD59x18 x);
error PRBMath_SD59x18_Sqrt_Overflow(SD59x18 x);
function add_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    return wrap_1(unwrap_1(x) + unwrap_1(y));
}
function and_0(SD59x18 x, int256 bits) pure returns (SD59x18 result) {
    return wrap_1(unwrap_1(x) & bits);
}
function eq_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = unwrap_1(x) == unwrap_1(y);
}
function gt_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = unwrap_1(x) > unwrap_1(y);
}
function gte_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = unwrap_1(x) >= unwrap_1(y);
}
function isZero_0(SD59x18 x) pure returns (bool result) {
    result = unwrap_1(x) == 0;
}
function lshift_0(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap_1(unwrap_1(x) << bits);
}
function lt_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = unwrap_1(x) < unwrap_1(y);
}
function lte_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = unwrap_1(x) <= unwrap_1(y);
}
function mod_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(unwrap_1(x) % unwrap_1(y));
}
function neq_0(SD59x18 x, SD59x18 y) pure returns (bool result) {
    result = unwrap_1(x) != unwrap_1(y);
}
function or_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(unwrap_1(x) | unwrap_1(y));
}
function rshift_0(SD59x18 x, uint256 bits) pure returns (SD59x18 result) {
    result = wrap_1(unwrap_1(x) >> bits);
}
function sub_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(unwrap_1(x) - unwrap_1(y));
}
function uncheckedAdd_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap_1(unwrap_1(x) + unwrap_1(y));
    }
}
function uncheckedSub_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    unchecked {
        result = wrap_1(unwrap_1(x) - unwrap_1(y));
    }
}
function uncheckedUnary(SD59x18 x) pure returns (SD59x18 result) {
    unchecked {
        result = wrap_1(-unwrap_1(x));
    }
}
function xor_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    result = wrap_1(unwrap_1(x) ^ unwrap_1(y));
}
function abs(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt == uMIN_SD59x18) {
        revert PRBMath_SD59x18_Abs_MinSD59x18();
    }
    result = xInt < 0 ? wrap_1(-xInt) : x;
}
function avg_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    int256 yInt = unwrap_1(y);
    unchecked {
        int256 sum = (xInt >> 1) + (yInt >> 1);
        if (sum < 0) {
            assembly ("memory-safe") {
                result := add(sum, and(or(xInt, yInt), 1))
            }
        } else {
            result = wrap_1(sum + (xInt & yInt & 1));
        }
    }
}
function ceil_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt > uMAX_WHOLE_SD59x18) {
        revert PRBMath_SD59x18_Ceil_Overflow(x);
    }
    int256 remainder = xInt % uUNIT_1;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            int256 resultInt = xInt - remainder;
            if (xInt > 0) {
                resultInt += uUNIT_1;
            }
            result = wrap_1(resultInt);
        }
    }
}
function div_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    int256 yInt = unwrap_1(y);
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert PRBMath_SD59x18_Div_InputTooSmall();
    }
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }
    uint256 resultAbs = mulDiv(xAbs, uint256(uUNIT_1), yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert PRBMath_SD59x18_Div_Overflow(x, y);
    }
    bool sameSign = (xInt ^ yInt) > -1;
    unchecked {
        result = wrap_1(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}
function exp_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt < -41_446531673892822322) {
        return ZERO_0;
    }
    if (xInt >= 133_084258667509499441) {
        revert PRBMath_SD59x18_Exp_InputTooBig(x);
    }
    unchecked {
        int256 doubleUnitProduct = xInt * uLOG2_E_0;
        result = exp2_0(wrap_1(doubleUnitProduct / uUNIT_1));
    }
}
function exp2_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt < 0) {
        if (xInt < -59_794705707972522261) {
            return ZERO_0;
        }
        unchecked {
            result = wrap_1(1e36 / unwrap_1(exp2_0(wrap_1(-xInt))));
        }
    } else {
        if (xInt >= 192e18) {
            revert PRBMath_SD59x18_Exp2_InputTooBig(x);
        }
        unchecked {
            uint256 x_192x64 = uint256((xInt << 64) / uUNIT_1);
            result = wrap_1(int256(prbExp2(x_192x64)));
        }
    }
}
function floor_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt < uMIN_WHOLE_SD59x18) {
        revert PRBMath_SD59x18_Floor_Underflow(x);
    }
    int256 remainder = xInt % uUNIT_1;
    if (remainder == 0) {
        result = x;
    } else {
        unchecked {
            int256 resultInt = xInt - remainder;
            if (xInt < 0) {
                resultInt -= uUNIT_1;
            }
            result = wrap_1(resultInt);
        }
    }
}
function frac_0(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1(unwrap_1(x) % uUNIT_1);
}
function gm_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    int256 yInt = unwrap_1(y);
    if (xInt == 0 || yInt == 0) {
        return ZERO_0;
    }
    unchecked {
        int256 xyInt = xInt * yInt;
        if (xyInt / xInt != yInt) {
            revert PRBMath_SD59x18_Gm_Overflow(x, y);
        }
        if (xyInt < 0) {
            revert PRBMath_SD59x18_Gm_NegativeProduct(x, y);
        }
        uint256 resultUint = prbSqrt(uint256(xyInt));
        result = wrap_1(int256(resultUint));
    }
}
function inv_0(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1(1e36 / unwrap_1(x));
}
function ln_0(SD59x18 x) pure returns (SD59x18 result) {
    result = wrap_1((unwrap_1(log2_0(x)) * uUNIT_1) / uLOG2_E_0);
}
function log10_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_Log_InputTooSmall(x);
    }
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT_1, sub(0, 18)) }
        case 10 { result := mul(uUNIT_1, sub(1, 18)) }
        case 100 { result := mul(uUNIT_1, sub(2, 18)) }
        case 1000 { result := mul(uUNIT_1, sub(3, 18)) }
        case 10000 { result := mul(uUNIT_1, sub(4, 18)) }
        case 100000 { result := mul(uUNIT_1, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT_1, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT_1, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT_1, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT_1, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT_1, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT_1, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT_1, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT_1, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT_1, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT_1, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT_1, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT_1, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT_1 }
        case 100000000000000000000 { result := mul(uUNIT_1, 2) }
        case 1000000000000000000000 { result := mul(uUNIT_1, 3) }
        case 10000000000000000000000 { result := mul(uUNIT_1, 4) }
        case 100000000000000000000000 { result := mul(uUNIT_1, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT_1, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT_1, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT_1, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT_1, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT_1, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT_1, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT_1, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT_1, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT_1, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT_1, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT_1, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT_1, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT_1, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT_1, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT_1, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT_1, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT_1, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT_1, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_1, 58) }
        default {
            result := uMAX_SD59x18
        }
    }
    if (unwrap_1(result) == uMAX_SD59x18) {
        unchecked {
            result = wrap_1((unwrap_1(log2_0(x)) * uUNIT_1) / uLOG2_10_0);
        }
    }
}
function log2_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt <= 0) {
        revert PRBMath_SD59x18_Log_InputTooSmall(x);
    }
    unchecked {
        int256 sign;
        if (xInt >= uUNIT_1) {
            sign = 1;
        } else {
            sign = -1;
            xInt = 1e36 / xInt;
        }
        uint256 n = msb(uint256(xInt / uUNIT_1));
        int256 resultInt = int256(n) * uUNIT_1;
        int256 y = xInt >> n;
        if (y == uUNIT_1) {
            return wrap_1(resultInt * sign);
        }
        int256 DOUBLE_UNIT = 2e18;
        for (int256 delta = uHALF_UNIT_0; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT_1;
            if (y >= DOUBLE_UNIT) {
                resultInt = resultInt + delta;
                y >>= 1;
            }
        }
        resultInt *= sign;
        result = wrap_1(resultInt);
    }
}
function mul_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    int256 yInt = unwrap_1(y);
    if (xInt == uMIN_SD59x18 || yInt == uMIN_SD59x18) {
        revert PRBMath_SD59x18_Mul_InputTooSmall();
    }
    uint256 xAbs;
    uint256 yAbs;
    unchecked {
        xAbs = xInt < 0 ? uint256(-xInt) : uint256(xInt);
        yAbs = yInt < 0 ? uint256(-yInt) : uint256(yInt);
    }
    uint256 resultAbs = mulDiv18(xAbs, yAbs);
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert PRBMath_SD59x18_Mul_Overflow(x, y);
    }
    bool sameSign = (xInt ^ yInt) > -1;
    unchecked {
        result = wrap_1(sameSign ? int256(resultAbs) : -int256(resultAbs));
    }
}
function pow_0(SD59x18 x, SD59x18 y) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    int256 yInt = unwrap_1(y);
    if (xInt == 0) {
        result = yInt == 0 ? UNIT_2 : ZERO_0;
    } else {
        if (yInt == uUNIT_1) {
            result = x;
        } else {
            result = exp2_0(mul_0(log2_0(x), y));
        }
    }
}
function powu_0(SD59x18 x, uint256 y) pure returns (SD59x18 result) {
    uint256 xAbs = uint256(unwrap_1(abs(x)));
    uint256 resultAbs = y & 1 > 0 ? xAbs : uint256(uUNIT_1);
    uint256 yAux = y;
    for (yAux >>= 1; yAux > 0; yAux >>= 1) {
        xAbs = mulDiv18(xAbs, xAbs);
        if (yAux & 1 > 0) {
            resultAbs = mulDiv18(resultAbs, xAbs);
        }
    }
    if (resultAbs > uint256(uMAX_SD59x18)) {
        revert PRBMath_SD59x18_Powu_Overflow(x, y);
    }
    unchecked {
        int256 resultInt = int256(resultAbs);
        bool isNegative = unwrap_1(x) < 0 && y & 1 == 1;
        if (isNegative) {
            resultInt = -resultInt;
        }
        result = wrap_1(resultInt);
    }
}
function sqrt_0(SD59x18 x) pure returns (SD59x18 result) {
    int256 xInt = unwrap_1(x);
    if (xInt < 0) {
        revert PRBMath_SD59x18_Sqrt_NegativeInput(x);
    }
    if (xInt > uMAX_SD59x18 / uUNIT_1) {
        revert PRBMath_SD59x18_Sqrt_Overflow(x);
    }
    unchecked {
        uint256 resultUint = prbSqrt(uint256(xInt * uUNIT_1));
        result = wrap_1(int256(resultUint));
    }
}
type SD59x18 is int256;
using {
    intoInt256,
    intoSD1x18_0,
    intoUD2x18_1,
    intoUD60x18_1,
    intoUint256_1,
    intoUint128_1,
    intoUint40_1,
    unwrap_1
} for SD59x18 global;
using {
    abs,
    avg_0,
    ceil_0,
    div_0,
    exp_0,
    exp2_0,
    floor_0,
    frac_0,
    gm_0,
    inv_0,
    log10_0,
    log2_0,
    ln_0,
    mul_0,
    pow_0,
    powu_0,
    sqrt_0
} for SD59x18 global;
using {
    add_0,
    and_0,
    eq_0,
    gt_0,
    gte_0,
    isZero_0,
    lshift_0,
    lt_0,
    lte_0,
    mod_0,
    neq_0,
    or_0,
    rshift_0,
    sub_0,
    uncheckedAdd_0,
    uncheckedSub_0,
    uncheckedUnary,
    xor_0
} for SD59x18 global;
function intoSD1x18_1(UD2x18 x) pure returns (SD1x18 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(uMAX_SD1x18)) {
        revert PRBMath_UD2x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(xUint));
}
function intoSD59x18_1(UD2x18 x) pure returns (SD59x18 result) {
    result = SD59x18.wrap(int256(uint256(UD2x18.unwrap(x))));
}
function intoUD60x18_2(UD2x18 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(UD2x18.unwrap(x));
}
function intoUint128_2(UD2x18 x) pure returns (uint128 result) {
    result = uint128(UD2x18.unwrap(x));
}
function intoUint256_2(UD2x18 x) pure returns (uint256 result) {
    result = uint256(UD2x18.unwrap(x));
}
function intoUint40_2(UD2x18 x) pure returns (uint40 result) {
    uint64 xUint = UD2x18.unwrap(x);
    if (xUint > uint64(MAX_UINT40)) {
        revert PRBMath_UD2x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}
function ud2x18(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
function unwrap_2(UD2x18 x) pure returns (uint64 result) {
    result = UD2x18.unwrap(x);
}
function wrap_2(uint64 x) pure returns (UD2x18 result) {
    result = UD2x18.wrap(x);
}
UD2x18 constant E_2 = UD2x18.wrap(2_718281828459045235);
uint64 constant uMAX_UD2x18 = 18_446744073709551615;
UD2x18 constant MAX_UD2x18 = UD2x18.wrap(uMAX_UD2x18);
UD2x18 constant PI_2 = UD2x18.wrap(3_141592653589793238);
uint256 constant uUNIT_2 = 1e18;
UD2x18 constant UNIT_3 = UD2x18.wrap(1e18);
error PRBMath_UD2x18_IntoSD1x18_Overflow(UD2x18 x);
error PRBMath_UD2x18_IntoUint40_Overflow(UD2x18 x);
type UD2x18 is uint64;
using { intoSD1x18_1, intoSD59x18_1, intoUD60x18_2, intoUint256_2, intoUint128_2, intoUint40_2, unwrap_2 } for UD2x18 global;
function intoSD1x18_2(UD60x18 x) pure returns (SD1x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(int256(uMAX_SD1x18))) {
        revert PRBMath_UD60x18_IntoSD1x18_Overflow(x);
    }
    result = SD1x18.wrap(int64(uint64(xUint)));
}
function intoUD2x18_2(UD60x18 x) pure returns (UD2x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uMAX_UD2x18) {
        revert PRBMath_UD60x18_IntoUD2x18_Overflow(x);
    }
    result = UD2x18.wrap(uint64(xUint));
}
function intoSD59x18_2(UD60x18 x) pure returns (SD59x18 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > uint256(uMAX_SD59x18)) {
        revert PRBMath_UD60x18_IntoSD59x18_Overflow(x);
    }
    result = SD59x18.wrap(int256(xUint));
}
function intoUint256_3(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}
function intoUint128_3(UD60x18 x) pure returns (uint128 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT128) {
        revert PRBMath_UD60x18_IntoUint128_Overflow(x);
    }
    result = uint128(xUint);
}
function intoUint40_3(UD60x18 x) pure returns (uint40 result) {
    uint256 xUint = UD60x18.unwrap(x);
    if (xUint > MAX_UINT40) {
        revert PRBMath_UD60x18_IntoUint40_Overflow(x);
    }
    result = uint40(xUint);
}
function ud(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
function ud60x18(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
function unwrap_3(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x);
}
function wrap_3(uint256 x) pure returns (UD60x18 result) {
    result = UD60x18.wrap(x);
}
UD60x18 constant E_3 = UD60x18.wrap(2_718281828459045235);
uint256 constant uHALF_UNIT_1 = 0.5e18;
UD60x18 constant HALF_UNIT_1 = UD60x18.wrap(uHALF_UNIT_1);
uint256 constant uLOG2_10_1 = 3_321928094887362347;
UD60x18 constant LOG2_10_1 = UD60x18.wrap(uLOG2_10_1);
uint256 constant uLOG2_E_1 = 1_442695040888963407;
UD60x18 constant LOG2_E_1 = UD60x18.wrap(uLOG2_E_1);
uint256 constant uMAX_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_584007913129639935;
UD60x18 constant MAX_UD60x18 = UD60x18.wrap(uMAX_UD60x18);
uint256 constant uMAX_WHOLE_UD60x18 = 115792089237316195423570985008687907853269984665640564039457_000000000000000000;
UD60x18 constant MAX_WHOLE_UD60x18 = UD60x18.wrap(uMAX_WHOLE_UD60x18);
UD60x18 constant PI_3 = UD60x18.wrap(3_141592653589793238);
uint256 constant uUNIT_3 = 1e18;
UD60x18 constant UNIT_4 = UD60x18.wrap(uUNIT_3);
UD60x18 constant ZERO_1 = UD60x18.wrap(0);
error PRBMath_UD60x18_Ceil_Overflow(UD60x18 x);
error PRBMath_UD60x18_Convert_Overflow(uint256 x);
error PRBMath_UD60x18_Exp_InputTooBig(UD60x18 x);
error PRBMath_UD60x18_Exp2_InputTooBig(UD60x18 x);
error PRBMath_UD60x18_Gm_Overflow(UD60x18 x, UD60x18 y);
error PRBMath_UD60x18_IntoSD1x18_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoSD59x18_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoUD2x18_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoUint128_Overflow(UD60x18 x);
error PRBMath_UD60x18_IntoUint40_Overflow(UD60x18 x);
error PRBMath_UD60x18_Log_InputTooSmall(UD60x18 x);
error PRBMath_UD60x18_Sqrt_Overflow(UD60x18 x);
function add_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) + unwrap_3(y));
}
function and_1(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) & bits);
}
function eq_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = unwrap_3(x) == unwrap_3(y);
}
function gt_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = unwrap_3(x) > unwrap_3(y);
}
function gte_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = unwrap_3(x) >= unwrap_3(y);
}
function isZero_1(UD60x18 x) pure returns (bool result) {
    result = unwrap_3(x) == 0;
}
function lshift_1(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) << bits);
}
function lt_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = unwrap_3(x) < unwrap_3(y);
}
function lte_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = unwrap_3(x) <= unwrap_3(y);
}
function mod_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) % unwrap_3(y));
}
function neq_1(UD60x18 x, UD60x18 y) pure returns (bool result) {
    result = unwrap_3(x) != unwrap_3(y);
}
function or_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) | unwrap_3(y));
}
function rshift_1(UD60x18 x, uint256 bits) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) >> bits);
}
function sub_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) - unwrap_3(y));
}
function uncheckedAdd_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3(unwrap_3(x) + unwrap_3(y));
    }
}
function uncheckedSub_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3(unwrap_3(x) - unwrap_3(y));
    }
}
function xor_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(unwrap_3(x) ^ unwrap_3(y));
}
function avg_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    uint256 yUint = unwrap_3(y);
    unchecked {
        result = wrap_3((xUint & yUint) + ((xUint ^ yUint) >> 1));
    }
}
function ceil_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    if (xUint > uMAX_WHOLE_UD60x18) {
        revert PRBMath_UD60x18_Ceil_Overflow(x);
    }
    assembly ("memory-safe") {
        let remainder := mod(x, uUNIT_3)
        let delta := sub(uUNIT_3, remainder)
        result := add(x, mul(delta, gt(remainder, 0)))
    }
}
function div_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(mulDiv(unwrap_3(x), uUNIT_3, unwrap_3(y)));
}
function exp_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    if (xUint >= 133_084258667509499441) {
        revert PRBMath_UD60x18_Exp_InputTooBig(x);
    }
    unchecked {
        uint256 doubleUnitProduct = xUint * uLOG2_E_1;
        result = exp2_1(wrap_3(doubleUnitProduct / uUNIT_3));
    }
}
function exp2_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    if (xUint >= 192e18) {
        revert PRBMath_UD60x18_Exp2_InputTooBig(x);
    }
    uint256 x_192x64 = (xUint << 64) / uUNIT_3;
    result = wrap_3(prbExp2(x_192x64));
}
function floor_1(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        let remainder := mod(x, uUNIT_3)
        result := sub(x, mul(remainder, gt(remainder, 0)))
    }
}
function frac_1(UD60x18 x) pure returns (UD60x18 result) {
    assembly ("memory-safe") {
        result := mod(x, uUNIT_3)
    }
}
function gm_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    uint256 yUint = unwrap_3(y);
    if (xUint == 0 || yUint == 0) {
        return ZERO_1;
    }
    unchecked {
        uint256 xyUint = xUint * yUint;
        if (xyUint / xUint != yUint) {
            revert PRBMath_UD60x18_Gm_Overflow(x, y);
        }
        result = wrap_3(prbSqrt(xyUint));
    }
}
function inv_1(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3(1e36 / unwrap_3(x));
    }
}
function ln_1(UD60x18 x) pure returns (UD60x18 result) {
    unchecked {
        result = wrap_3((unwrap_3(log2_1(x)) * uUNIT_3) / uLOG2_E_1);
    }
}
function log10_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    if (xUint < uUNIT_3) {
        revert PRBMath_UD60x18_Log_InputTooSmall(x);
    }
    assembly ("memory-safe") {
        switch x
        case 1 { result := mul(uUNIT_3, sub(0, 18)) }
        case 10 { result := mul(uUNIT_3, sub(1, 18)) }
        case 100 { result := mul(uUNIT_3, sub(2, 18)) }
        case 1000 { result := mul(uUNIT_3, sub(3, 18)) }
        case 10000 { result := mul(uUNIT_3, sub(4, 18)) }
        case 100000 { result := mul(uUNIT_3, sub(5, 18)) }
        case 1000000 { result := mul(uUNIT_3, sub(6, 18)) }
        case 10000000 { result := mul(uUNIT_3, sub(7, 18)) }
        case 100000000 { result := mul(uUNIT_3, sub(8, 18)) }
        case 1000000000 { result := mul(uUNIT_3, sub(9, 18)) }
        case 10000000000 { result := mul(uUNIT_3, sub(10, 18)) }
        case 100000000000 { result := mul(uUNIT_3, sub(11, 18)) }
        case 1000000000000 { result := mul(uUNIT_3, sub(12, 18)) }
        case 10000000000000 { result := mul(uUNIT_3, sub(13, 18)) }
        case 100000000000000 { result := mul(uUNIT_3, sub(14, 18)) }
        case 1000000000000000 { result := mul(uUNIT_3, sub(15, 18)) }
        case 10000000000000000 { result := mul(uUNIT_3, sub(16, 18)) }
        case 100000000000000000 { result := mul(uUNIT_3, sub(17, 18)) }
        case 1000000000000000000 { result := 0 }
        case 10000000000000000000 { result := uUNIT_3 }
        case 100000000000000000000 { result := mul(uUNIT_3, 2) }
        case 1000000000000000000000 { result := mul(uUNIT_3, 3) }
        case 10000000000000000000000 { result := mul(uUNIT_3, 4) }
        case 100000000000000000000000 { result := mul(uUNIT_3, 5) }
        case 1000000000000000000000000 { result := mul(uUNIT_3, 6) }
        case 10000000000000000000000000 { result := mul(uUNIT_3, 7) }
        case 100000000000000000000000000 { result := mul(uUNIT_3, 8) }
        case 1000000000000000000000000000 { result := mul(uUNIT_3, 9) }
        case 10000000000000000000000000000 { result := mul(uUNIT_3, 10) }
        case 100000000000000000000000000000 { result := mul(uUNIT_3, 11) }
        case 1000000000000000000000000000000 { result := mul(uUNIT_3, 12) }
        case 10000000000000000000000000000000 { result := mul(uUNIT_3, 13) }
        case 100000000000000000000000000000000 { result := mul(uUNIT_3, 14) }
        case 1000000000000000000000000000000000 { result := mul(uUNIT_3, 15) }
        case 10000000000000000000000000000000000 { result := mul(uUNIT_3, 16) }
        case 100000000000000000000000000000000000 { result := mul(uUNIT_3, 17) }
        case 1000000000000000000000000000000000000 { result := mul(uUNIT_3, 18) }
        case 10000000000000000000000000000000000000 { result := mul(uUNIT_3, 19) }
        case 100000000000000000000000000000000000000 { result := mul(uUNIT_3, 20) }
        case 1000000000000000000000000000000000000000 { result := mul(uUNIT_3, 21) }
        case 10000000000000000000000000000000000000000 { result := mul(uUNIT_3, 22) }
        case 100000000000000000000000000000000000000000 { result := mul(uUNIT_3, 23) }
        case 1000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 24) }
        case 10000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 25) }
        case 100000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 26) }
        case 1000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 27) }
        case 10000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 28) }
        case 100000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 29) }
        case 1000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 30) }
        case 10000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 31) }
        case 100000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 32) }
        case 1000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 33) }
        case 10000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 34) }
        case 100000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 35) }
        case 1000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 36) }
        case 10000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 37) }
        case 100000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 38) }
        case 1000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 39) }
        case 10000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 40) }
        case 100000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 41) }
        case 1000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 42) }
        case 10000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 43) }
        case 100000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 44) }
        case 1000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 45) }
        case 10000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 46) }
        case 100000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 47) }
        case 1000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 48) }
        case 10000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 49) }
        case 100000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 50) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 51) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 52) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 53) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 54) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 55) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 56) }
        case 1000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 57) }
        case 10000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 58) }
        case 100000000000000000000000000000000000000000000000000000000000000000000000000000 { result := mul(uUNIT_3, 59) }
        default {
            result := uMAX_UD60x18
        }
    }
    if (unwrap_3(result) == uMAX_UD60x18) {
        unchecked {
            result = wrap_3((unwrap_3(log2_1(x)) * uUNIT_3) / uLOG2_10_1);
        }
    }
}
function log2_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    if (xUint < uUNIT_3) {
        revert PRBMath_UD60x18_Log_InputTooSmall(x);
    }
    unchecked {
        uint256 n = msb(xUint / uUNIT_3);
        uint256 resultUint = n * uUNIT_3;
        uint256 y = xUint >> n;
        if (y == uUNIT_3) {
            return wrap_3(resultUint);
        }
        uint256 DOUBLE_UNIT = 2e18;
        for (uint256 delta = uHALF_UNIT_1; delta > 0; delta >>= 1) {
            y = (y * y) / uUNIT_3;
            if (y >= DOUBLE_UNIT) {
                resultUint += delta;
                y >>= 1;
            }
        }
        result = wrap_3(resultUint);
    }
}
function mul_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    result = wrap_3(mulDiv18(unwrap_3(x), unwrap_3(y)));
}
function pow_1(UD60x18 x, UD60x18 y) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    uint256 yUint = unwrap_3(y);
    if (xUint == 0) {
        result = yUint == 0 ? UNIT_4 : ZERO_1;
    } else {
        if (yUint == uUNIT_3) {
            result = x;
        } else {
            result = exp2_1(mul_1(log2_1(x), y));
        }
    }
}
function powu_1(UD60x18 x, uint256 y) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    uint256 resultUint = y & 1 > 0 ? xUint : uUNIT_3;
    for (y >>= 1; y > 0; y >>= 1) {
        xUint = mulDiv18(xUint, xUint);
        if (y & 1 > 0) {
            resultUint = mulDiv18(resultUint, xUint);
        }
    }
    result = wrap_3(resultUint);
}
function sqrt_1(UD60x18 x) pure returns (UD60x18 result) {
    uint256 xUint = unwrap_3(x);
    unchecked {
        if (xUint > uMAX_UD60x18 / uUNIT_3) {
            revert PRBMath_UD60x18_Sqrt_Overflow(x);
        }
        result = wrap_3(prbSqrt(xUint * uUNIT_3));
    }
}
type UD60x18 is uint256;
using { intoSD1x18_2, intoUD2x18_2, intoSD59x18_2, intoUint128_3, intoUint256_3, intoUint40_3, unwrap_3 } for UD60x18 global;
using {
    avg_1,
    ceil_1,
    div_1,
    exp_1,
    exp2_1,
    floor_1,
    frac_1,
    gm_1,
    inv_1,
    ln_1,
    log10_1,
    log2_1,
    mul_1,
    pow_1,
    powu_1,
    sqrt_1
} for UD60x18 global;
using {
    add_1,
    and_1,
    eq_1,
    gt_1,
    gte_1,
    isZero_1,
    lshift_1,
    lt_1,
    lte_1,
    mod_1,
    neq_1,
    or_1,
    rshift_1,
    sub_1,
    uncheckedAdd_1,
    uncheckedSub_1,
    xor_1
} for UD60x18 global;
function convert_1(int256 x) pure returns (SD59x18 result) {
    if (x < uMIN_SD59x18 / uUNIT_1) {
        revert PRBMath_SD59x18_Convert_Underflow(x);
    }
    if (x > uMAX_SD59x18 / uUNIT_1) {
        revert PRBMath_SD59x18_Convert_Overflow(x);
    }
    unchecked {
        result = SD59x18.wrap(x * uUNIT_1);
    }
}
function convert_0(SD59x18 x) pure returns (int256 result) {
    result = SD59x18.unwrap(x) / uUNIT_1;
}
function fromSD59x18(SD59x18 x) pure returns (int256 result) {
    result = convert_0(x);
}
function toSD59x18(int256 x) pure returns (SD59x18 result) {
    result = convert_1(x);
}
function convert_2(UD60x18 x) pure returns (uint256 result) {
    result = UD60x18.unwrap(x) / uUNIT_3;
}
function convert_3(uint256 x) pure returns (UD60x18 result) {
    if (x > uMAX_UD60x18 / uUNIT_3) {
        revert PRBMath_UD60x18_Convert_Overflow(x);
    }
    unchecked {
        result = UD60x18.wrap(x * uUNIT_3);
    }
}
function fromUD60x18_0(UD60x18 x) pure returns (uint256 result) {
    result = convert_2(x);
}
function toUD60x18(uint256 x) pure returns (UD60x18 result) {
    result = convert_3(x);
}
type UD34x4 is uint128;
error PRBMath_UD34x4_Convert_Overflow(uint128 x);
error PRBMath_UD34x4_fromUD60x18_Convert_Overflow(uint256 x);
uint128 constant uMAX_UD34x4 = 340282366920938463463374607431768211455;
uint128 constant uUNIT_4 = 1e4;
function intoUD60x18_3(UD34x4 x) pure returns (UD60x18 result) {
  uint256 xUint = uint256(UD34x4.unwrap(x)) * uint256(1e14);
  result = UD60x18.wrap(xUint);
}
function fromUD60x18_1(UD60x18 x) pure returns (UD34x4 result) {
  uint256 xUint = UD60x18.unwrap(x) / 1e14;
  if (xUint > uMAX_UD34x4) {
    revert PRBMath_UD34x4_fromUD60x18_Convert_Overflow(x.unwrap_3());
  }
  result = UD34x4.wrap(uint128(xUint));
}
function convert_5(UD34x4 x) pure returns (uint128 result) {
  result = UD34x4.unwrap(x) / uUNIT_4;
}
function convert_4(uint128 x) pure returns (UD34x4 result) {
  if (x > uMAX_UD34x4 / uUNIT_4) {
    revert PRBMath_UD34x4_Convert_Overflow(x);
  }
  unchecked {
    result = UD34x4.wrap(x * uUNIT_4);
  }
}
function fromUD34x4(UD34x4 x) pure returns (uint128 result) {
  result = convert_5(x);
}
function toUD34x4(uint128 x) pure returns (UD34x4 result) {
  result = convert_4(x);
}
error AddToDrawZero();
error DrawClosed(uint16 drawId, uint16 newestDrawId);
error InvalidDrawRange(uint16 startDrawId, uint16 endDrawId);
error InvalidDisbursedEndDrawId(uint16 endDrawId);
struct Observation {
  uint96 available;
  uint168 disbursed;
}
library DrawAccumulatorLib {
  uint24 internal constant MAX_CARDINALITY = 366;
  struct RingBufferInfo {
    uint16 nextIndex;
    uint16 cardinality;
  }
  struct Accumulator {
    RingBufferInfo ringBufferInfo;
    uint16[366] drawRingBuffer;
    mapping(uint256 => Observation) observations;
  }
  struct Pair32 {
    uint16 first;
    uint16 second;
  }
  function add(
    Accumulator storage accumulator,
    uint256 _amount,
    uint16 _drawId,
    SD59x18 _alpha
  ) internal returns (bool) {
    if (_drawId == 0) {
      revert AddToDrawZero();
    }
    RingBufferInfo memory ringBufferInfo = accumulator.ringBufferInfo;
    uint256 newestIndex = RingBufferLib.newestIndex(ringBufferInfo.nextIndex, MAX_CARDINALITY);
    uint16 newestDrawId_ = accumulator.drawRingBuffer[newestIndex];
    if (_drawId < newestDrawId_) {
      revert DrawClosed(_drawId, newestDrawId_);
    }
    Observation memory newestObservation_ = accumulator.observations[newestDrawId_];
    if (_drawId != newestDrawId_) {
      uint256 relativeDraw = _drawId - newestDrawId_;
      uint256 remainingAmount = integrateInf(_alpha, relativeDraw, newestObservation_.available);
      uint256 disbursedAmount = integrate(_alpha, 0, relativeDraw, newestObservation_.available);
      uint256 remainder = newestObservation_.available - (remainingAmount + disbursedAmount);
      accumulator.drawRingBuffer[ringBufferInfo.nextIndex] = _drawId;
      accumulator.observations[_drawId] = Observation({
        available: uint96(_amount + remainingAmount),
        disbursed: uint168(newestObservation_.disbursed + disbursedAmount + remainder)
      });
      uint16 nextIndex = uint16(RingBufferLib.nextIndex(ringBufferInfo.nextIndex, MAX_CARDINALITY));
      uint16 cardinality = ringBufferInfo.cardinality;
      if (ringBufferInfo.cardinality < MAX_CARDINALITY) {
        cardinality += 1;
      }
      accumulator.ringBufferInfo = RingBufferInfo({
        nextIndex: nextIndex,
        cardinality: cardinality
      });
      return true;
    } else {
      accumulator.observations[newestDrawId_] = Observation({
        available: uint96(newestObservation_.available + _amount),
        disbursed: newestObservation_.disbursed
      });
      return false;
    }
  }
  function getTotalRemaining(
    Accumulator storage accumulator,
    uint16 _startDrawId,
    SD59x18 _alpha
  ) internal view returns (uint256) {
    RingBufferInfo memory ringBufferInfo = accumulator.ringBufferInfo;
    if (ringBufferInfo.cardinality == 0) {
      return 0;
    }
    uint256 newestIndex = RingBufferLib.newestIndex(ringBufferInfo.nextIndex, MAX_CARDINALITY);
    uint16 newestDrawId_ = accumulator.drawRingBuffer[newestIndex];
    if (_startDrawId < newestDrawId_) {
      revert DrawClosed(_startDrawId, newestDrawId_);
    }
    Observation memory newestObservation_ = accumulator.observations[newestDrawId_];
    return integrateInf(_alpha, _startDrawId - newestDrawId_, newestObservation_.available);
  }
  function newestDrawId(Accumulator storage accumulator) internal view returns (uint256) {
    return
      accumulator.drawRingBuffer[
        RingBufferLib.newestIndex(accumulator.ringBufferInfo.nextIndex, MAX_CARDINALITY)
      ];
  }
  function newestObservation(
    Accumulator storage accumulator
  ) internal view returns (Observation memory) {
    return accumulator.observations[newestDrawId(accumulator)];
  }
  function getDisbursedBetween(
    Accumulator storage _accumulator,
    uint16 _startDrawId,
    uint16 _endDrawId,
    SD59x18 _alpha
  ) internal view returns (uint256) {
    if (_startDrawId > _endDrawId) {
      revert InvalidDrawRange(_startDrawId, _endDrawId);
    }
    RingBufferInfo memory ringBufferInfo = _accumulator.ringBufferInfo;
    if (ringBufferInfo.cardinality == 0) {
      return 0;
    }
    Pair32 memory indexes = computeIndices(ringBufferInfo);
    Pair32 memory drawIds = readDrawIds(_accumulator, indexes);
    if (_endDrawId < drawIds.second - 1) {
      revert InvalidDisbursedEndDrawId(_endDrawId);
    }
    if (_endDrawId < drawIds.first) {
      return 0;
    }
    uint16 lastObservationDrawIdOccurringAtOrBeforeEnd;
    if (_endDrawId >= drawIds.second) {
      lastObservationDrawIdOccurringAtOrBeforeEnd = drawIds.second;
    } else {
      lastObservationDrawIdOccurringAtOrBeforeEnd = _accumulator.drawRingBuffer[
        uint16(RingBufferLib.offset(indexes.second, 1, ringBufferInfo.cardinality))
      ];
    }
    uint16 observationDrawIdBeforeOrAtStart;
    uint16 firstObservationDrawIdOccurringAtOrAfterStart;
    if (_startDrawId >= drawIds.second) {
      observationDrawIdBeforeOrAtStart = drawIds.second;
    } else if (_startDrawId <= drawIds.first) {
      firstObservationDrawIdOccurringAtOrAfterStart = drawIds.first;
    } else {
      (
        ,
        observationDrawIdBeforeOrAtStart,
        ,
        firstObservationDrawIdOccurringAtOrAfterStart
      ) = binarySearch(
        _accumulator.drawRingBuffer,
        indexes.first,
        indexes.second,
        ringBufferInfo.cardinality,
        _startDrawId
      );
    }
    uint256 total;
    if (
      observationDrawIdBeforeOrAtStart > 0 &&
      firstObservationDrawIdOccurringAtOrAfterStart > 0 &&
      observationDrawIdBeforeOrAtStart != lastObservationDrawIdOccurringAtOrBeforeEnd
    ) {
      Observation memory beforeOrAtStart = _accumulator.observations[
        observationDrawIdBeforeOrAtStart
      ];
      uint16 headStartDrawId = _startDrawId - observationDrawIdBeforeOrAtStart;
      uint16 headEndDrawId = headStartDrawId +
        (firstObservationDrawIdOccurringAtOrAfterStart - _startDrawId);
      uint amount = integrate(_alpha, headStartDrawId, headEndDrawId, beforeOrAtStart.available);
      total += amount;
    }
    Observation memory atOrBeforeEnd;
    if (
      firstObservationDrawIdOccurringAtOrAfterStart > 0 &&
      firstObservationDrawIdOccurringAtOrAfterStart < lastObservationDrawIdOccurringAtOrBeforeEnd
    ) {
      Observation memory atOrAfterStart = _accumulator.observations[
        firstObservationDrawIdOccurringAtOrAfterStart
      ];
      atOrBeforeEnd = _accumulator.observations[lastObservationDrawIdOccurringAtOrBeforeEnd];
      uint amount = atOrBeforeEnd.disbursed - atOrAfterStart.disbursed;
      total += amount;
    }
    total += _computeTail(
      _accumulator,
      _startDrawId,
      _endDrawId,
      lastObservationDrawIdOccurringAtOrBeforeEnd,
      _alpha
    );
    return total;
  }
  function _computeTail(
    Accumulator storage accumulator,
    uint16 _startDrawId,
    uint16 _endDrawId,
    uint16 _lastObservationDrawIdOccurringAtOrBeforeEnd,
    SD59x18 _alpha
  ) internal view returns (uint256) {
    Observation memory lastObservation = accumulator.observations[
      _lastObservationDrawIdOccurringAtOrBeforeEnd
    ];
    uint16 tailRangeStartDrawId = (
      _startDrawId > _lastObservationDrawIdOccurringAtOrBeforeEnd
        ? _startDrawId
        : _lastObservationDrawIdOccurringAtOrBeforeEnd
    ) - _lastObservationDrawIdOccurringAtOrBeforeEnd;
    uint256 amount = integrate(
      _alpha,
      tailRangeStartDrawId,
      _endDrawId - _lastObservationDrawIdOccurringAtOrBeforeEnd + 1,
      lastObservation.available
    );
    return amount;
  }
  function computeIndices(
    RingBufferInfo memory ringBufferInfo
  ) internal pure returns (Pair32 memory) {
    return
      Pair32({
        first: uint16(
          RingBufferLib.oldestIndex(
            ringBufferInfo.nextIndex,
            ringBufferInfo.cardinality,
            MAX_CARDINALITY
          )
        ),
        second: uint16(
          RingBufferLib.newestIndex(ringBufferInfo.nextIndex, ringBufferInfo.cardinality)
        )
      });
  }
  function readDrawIds(
    Accumulator storage accumulator,
    Pair32 memory indices
  ) internal view returns (Pair32 memory) {
    return
      Pair32({
        first: uint16(accumulator.drawRingBuffer[indices.first]),
        second: uint16(accumulator.drawRingBuffer[indices.second])
      });
  }
  function integrateInf(SD59x18 _alpha, uint _x, uint _k) internal pure returns (uint256) {
    return uint256(fromSD59x18(computeC(_alpha, _x, _k)));
  }
  function integrate(
    SD59x18 _alpha,
    uint _start,
    uint _end,
    uint _k
  ) internal pure returns (uint256) {
    int start = unwrap_1(computeC(_alpha, _start, _k));
    int end = unwrap_1(computeC(_alpha, _end, _k));
    return uint256(fromSD59x18(sd(start - end)));
  }
  function computeC(SD59x18 _alpha, uint _x, uint _k) internal pure returns (SD59x18) {
    return toSD59x18(int(_k)).mul_0(_alpha.pow_0(toSD59x18(int256(_x))));
  }
  function binarySearch(
    uint16[366] storage _drawRingBuffer,
    uint16 _oldestIndex,
    uint16 _newestIndex,
    uint16 _cardinality,
    uint16 _targetLastClosedDrawId
  )
    internal
    view
    returns (
      uint16 beforeOrAtIndex,
      uint16 beforeOrAtDrawId,
      uint16 afterOrAtIndex,
      uint16 afterOrAtDrawId
    )
  {
    uint16 leftSide = _oldestIndex;
    uint16 rightSide = _newestIndex < leftSide ? leftSide + _cardinality - 1 : _newestIndex;
    uint16 currentIndex;
    while (true) {
      currentIndex = (leftSide + rightSide) / 2;
      beforeOrAtIndex = uint16(RingBufferLib.wrap(currentIndex, _cardinality));
      beforeOrAtDrawId = _drawRingBuffer[beforeOrAtIndex];
      afterOrAtIndex = uint16(RingBufferLib.nextIndex(currentIndex, _cardinality));
      afterOrAtDrawId = _drawRingBuffer[afterOrAtIndex];
      bool targetAtOrAfter = beforeOrAtDrawId <= _targetLastClosedDrawId;
      if (targetAtOrAfter && _targetLastClosedDrawId <= afterOrAtDrawId) {
        break;
      }
      if (!targetAtOrAfter) {
        rightSide = currentIndex - 1;
      } else {
        leftSide = currentIndex + 1;
      }
    }
  }
}
library TierCalculationLib {
  function getTierOdds(
    uint8 _tier,
    uint8 _numberOfTiers,
    uint16 _grandPrizePeriod
  ) internal pure returns (SD59x18) {
    SD59x18 _k = sd(1).div_0(sd(int16(_grandPrizePeriod))).ln_0().div_0(
      sd((-1 * int8(_numberOfTiers) + 1))
    );
    return E_1.pow_0(_k.mul_0(sd(int8(_tier) - (int8(_numberOfTiers) - 1))));
  }
  function estimatePrizeFrequencyInDraws(SD59x18 _tierOdds) internal pure returns (uint256) {
    return uint256(fromSD59x18(sd(1e18).div_0(_tierOdds).ceil_0()));
  }
  function prizeCount(uint8 _tier) internal pure returns (uint256) {
    uint256 _numberOfPrizes = 4 ** _tier;
    return _numberOfPrizes;
  }
  function canaryPrizeCount(
    uint8 _numberOfTiers,
    uint8 _canaryShares,
    uint8 _reserveShares,
    uint8 _tierShares
  ) internal pure returns (UD60x18) {
    uint256 numerator = uint256(_canaryShares) *
      ((_numberOfTiers + 1) * uint256(_tierShares) + _canaryShares + _reserveShares);
    uint256 denominator = uint256(_tierShares) *
      ((_numberOfTiers) * uint256(_tierShares) + _canaryShares + _reserveShares);
    UD60x18 multiplier = toUD60x18(numerator).div_1(toUD60x18(denominator));
    return multiplier.mul_1(toUD60x18(prizeCount(_numberOfTiers)));
  }
  function isWinner(
    uint256 _userSpecificRandomNumber,
    uint128 _userTwab,
    uint128 _vaultTwabTotalSupply,
    SD59x18 _vaultContributionFraction,
    SD59x18 _tierOdds
  ) internal pure returns (bool) {
    if (_vaultTwabTotalSupply == 0) {
      return false;
    }
    uint256 constrainedRandomNumber = _userSpecificRandomNumber % (_vaultTwabTotalSupply);
    uint256 winningZone = calculateWinningZone(_userTwab, _vaultContributionFraction, _tierOdds);
    return constrainedRandomNumber < winningZone;
  }
  function calculatePseudoRandomNumber(
    address _user,
    uint8 _tier,
    uint32 _prizeIndex,
    uint256 _winningRandomNumber
  ) internal pure returns (uint256) {
    return uint256(keccak256(abi.encode(_user, _tier, _prizeIndex, _winningRandomNumber)));
  }
  function calculateWinningZone(
    uint256 _userTwab,
    SD59x18 _vaultContributionFraction,
    SD59x18 _tierOdds
  ) internal pure returns (uint256) {
    return
      uint256(
        fromSD59x18(toSD59x18(int256(_userTwab)).mul_0(_tierOdds).mul_0(_vaultContributionFraction))
      );
  }
  function estimatedClaimCount(
    uint8 _numberOfTiers,
    uint16 _grandPrizePeriod
  ) internal pure returns (uint32) {
    uint32 count = 0;
    for (uint8 i = 0; i < _numberOfTiers; i++) {
      count += uint32(
        uint256(
          unwrap_1(sd(int256(prizeCount(i))).mul_0(getTierOdds(i, _numberOfTiers, _grandPrizePeriod)))
        )
      );
    }
    return count;
  }
}
struct Tier {
  uint16 drawId;
  uint96 prizeSize;
  UD34x4 prizeTokenPerShare;
}
error NumberOfTiersLessThanMinimum(uint8 numTiers);
error NumberOfTiersGreaterThanMaximum(uint8 numTiers);
error InsufficientLiquidity(uint104 requestedLiquidity);
contract TieredLiquidityDistributor {
  event ReserveConsumed(uint256 amount);
  uint8 internal constant MINIMUM_NUMBER_OF_TIERS = 3;
  uint8 internal constant MAXIMUM_NUMBER_OF_TIERS = 15;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_2_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_3_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_4_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_5_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_6_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_7_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_8_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_9_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_10_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_11_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_12_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_13_TIERS;
  UD60x18 internal immutable CANARY_PRIZE_COUNT_FOR_14_TIERS;
  uint16 internal constant GRAND_PRIZE_PERIOD_DRAWS = 365;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_2_TIERS = 4;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_3_TIERS = 16;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_4_TIERS = 66;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_5_TIERS = 270;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_6_TIERS = 1108;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_7_TIERS = 4517;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_8_TIERS = 18358;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_9_TIERS = 74435;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_10_TIERS = 301239;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_11_TIERS = 1217266;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_12_TIERS = 4912619;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_13_TIERS = 19805536;
  uint32 internal constant ESTIMATED_PRIZES_PER_DRAW_FOR_14_TIERS = 79777187;
  SD59x18 internal constant TIER_ODDS_0_3 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_3 = SD59x18.wrap(52342392259021369);
  SD59x18 internal constant TIER_ODDS_2_3 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_4 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_4 = SD59x18.wrap(19579642462506911);
  SD59x18 internal constant TIER_ODDS_2_4 = SD59x18.wrap(139927275620255366);
  SD59x18 internal constant TIER_ODDS_3_4 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_5 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_5 = SD59x18.wrap(11975133168707466);
  SD59x18 internal constant TIER_ODDS_2_5 = SD59x18.wrap(52342392259021369);
  SD59x18 internal constant TIER_ODDS_3_5 = SD59x18.wrap(228784597949733865);
  SD59x18 internal constant TIER_ODDS_4_5 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_6 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_6 = SD59x18.wrap(8915910667410451);
  SD59x18 internal constant TIER_ODDS_2_6 = SD59x18.wrap(29015114005673871);
  SD59x18 internal constant TIER_ODDS_3_6 = SD59x18.wrap(94424100034951094);
  SD59x18 internal constant TIER_ODDS_4_6 = SD59x18.wrap(307285046878222004);
  SD59x18 internal constant TIER_ODDS_5_6 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_7 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_7 = SD59x18.wrap(7324128348251604);
  SD59x18 internal constant TIER_ODDS_2_7 = SD59x18.wrap(19579642462506911);
  SD59x18 internal constant TIER_ODDS_3_7 = SD59x18.wrap(52342392259021369);
  SD59x18 internal constant TIER_ODDS_4_7 = SD59x18.wrap(139927275620255366);
  SD59x18 internal constant TIER_ODDS_5_7 = SD59x18.wrap(374068544013333694);
  SD59x18 internal constant TIER_ODDS_6_7 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_8 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_8 = SD59x18.wrap(6364275529026907);
  SD59x18 internal constant TIER_ODDS_2_8 = SD59x18.wrap(14783961098420314);
  SD59x18 internal constant TIER_ODDS_3_8 = SD59x18.wrap(34342558671878193);
  SD59x18 internal constant TIER_ODDS_4_8 = SD59x18.wrap(79776409602255901);
  SD59x18 internal constant TIER_ODDS_5_8 = SD59x18.wrap(185317453770221528);
  SD59x18 internal constant TIER_ODDS_6_8 = SD59x18.wrap(430485137687959592);
  SD59x18 internal constant TIER_ODDS_7_8 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_9 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_9 = SD59x18.wrap(5727877794074876);
  SD59x18 internal constant TIER_ODDS_2_9 = SD59x18.wrap(11975133168707466);
  SD59x18 internal constant TIER_ODDS_3_9 = SD59x18.wrap(25036116265717087);
  SD59x18 internal constant TIER_ODDS_4_9 = SD59x18.wrap(52342392259021369);
  SD59x18 internal constant TIER_ODDS_5_9 = SD59x18.wrap(109430951602859902);
  SD59x18 internal constant TIER_ODDS_6_9 = SD59x18.wrap(228784597949733865);
  SD59x18 internal constant TIER_ODDS_7_9 = SD59x18.wrap(478314329651259628);
  SD59x18 internal constant TIER_ODDS_8_9 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_10 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_10 = SD59x18.wrap(5277233889074595);
  SD59x18 internal constant TIER_ODDS_2_10 = SD59x18.wrap(10164957094799045);
  SD59x18 internal constant TIER_ODDS_3_10 = SD59x18.wrap(19579642462506911);
  SD59x18 internal constant TIER_ODDS_4_10 = SD59x18.wrap(37714118749773489);
  SD59x18 internal constant TIER_ODDS_5_10 = SD59x18.wrap(72644572330454226);
  SD59x18 internal constant TIER_ODDS_6_10 = SD59x18.wrap(139927275620255366);
  SD59x18 internal constant TIER_ODDS_7_10 = SD59x18.wrap(269526570731818992);
  SD59x18 internal constant TIER_ODDS_8_10 = SD59x18.wrap(519159484871285957);
  SD59x18 internal constant TIER_ODDS_9_10 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_11 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_11 = SD59x18.wrap(4942383282734483);
  SD59x18 internal constant TIER_ODDS_2_11 = SD59x18.wrap(8915910667410451);
  SD59x18 internal constant TIER_ODDS_3_11 = SD59x18.wrap(16084034459031666);
  SD59x18 internal constant TIER_ODDS_4_11 = SD59x18.wrap(29015114005673871);
  SD59x18 internal constant TIER_ODDS_5_11 = SD59x18.wrap(52342392259021369);
  SD59x18 internal constant TIER_ODDS_6_11 = SD59x18.wrap(94424100034951094);
  SD59x18 internal constant TIER_ODDS_7_11 = SD59x18.wrap(170338234127496669);
  SD59x18 internal constant TIER_ODDS_8_11 = SD59x18.wrap(307285046878222004);
  SD59x18 internal constant TIER_ODDS_9_11 = SD59x18.wrap(554332974734700411);
  SD59x18 internal constant TIER_ODDS_10_11 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_12 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_12 = SD59x18.wrap(4684280039134314);
  SD59x18 internal constant TIER_ODDS_2_12 = SD59x18.wrap(8009005012036743);
  SD59x18 internal constant TIER_ODDS_3_12 = SD59x18.wrap(13693494143591795);
  SD59x18 internal constant TIER_ODDS_4_12 = SD59x18.wrap(23412618868232833);
  SD59x18 internal constant TIER_ODDS_5_12 = SD59x18.wrap(40030011078337707);
  SD59x18 internal constant TIER_ODDS_6_12 = SD59x18.wrap(68441800379112721);
  SD59x18 internal constant TIER_ODDS_7_12 = SD59x18.wrap(117019204165776974);
  SD59x18 internal constant TIER_ODDS_8_12 = SD59x18.wrap(200075013628233217);
  SD59x18 internal constant TIER_ODDS_9_12 = SD59x18.wrap(342080698323914461);
  SD59x18 internal constant TIER_ODDS_10_12 = SD59x18.wrap(584876652230121477);
  SD59x18 internal constant TIER_ODDS_11_12 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_13 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_13 = SD59x18.wrap(4479520628784180);
  SD59x18 internal constant TIER_ODDS_2_13 = SD59x18.wrap(7324128348251604);
  SD59x18 internal constant TIER_ODDS_3_13 = SD59x18.wrap(11975133168707466);
  SD59x18 internal constant TIER_ODDS_4_13 = SD59x18.wrap(19579642462506911);
  SD59x18 internal constant TIER_ODDS_5_13 = SD59x18.wrap(32013205494981721);
  SD59x18 internal constant TIER_ODDS_6_13 = SD59x18.wrap(52342392259021369);
  SD59x18 internal constant TIER_ODDS_7_13 = SD59x18.wrap(85581121447732876);
  SD59x18 internal constant TIER_ODDS_8_13 = SD59x18.wrap(139927275620255366);
  SD59x18 internal constant TIER_ODDS_9_13 = SD59x18.wrap(228784597949733866);
  SD59x18 internal constant TIER_ODDS_10_13 = SD59x18.wrap(374068544013333694);
  SD59x18 internal constant TIER_ODDS_11_13 = SD59x18.wrap(611611432212751966);
  SD59x18 internal constant TIER_ODDS_12_13 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_14 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_14 = SD59x18.wrap(4313269422986724);
  SD59x18 internal constant TIER_ODDS_2_14 = SD59x18.wrap(6790566987074365);
  SD59x18 internal constant TIER_ODDS_3_14 = SD59x18.wrap(10690683906783196);
  SD59x18 internal constant TIER_ODDS_4_14 = SD59x18.wrap(16830807002169641);
  SD59x18 internal constant TIER_ODDS_5_14 = SD59x18.wrap(26497468900426949);
  SD59x18 internal constant TIER_ODDS_6_14 = SD59x18.wrap(41716113674084931);
  SD59x18 internal constant TIER_ODDS_7_14 = SD59x18.wrap(65675485708038160);
  SD59x18 internal constant TIER_ODDS_8_14 = SD59x18.wrap(103395763485663166);
  SD59x18 internal constant TIER_ODDS_9_14 = SD59x18.wrap(162780431564813557);
  SD59x18 internal constant TIER_ODDS_10_14 = SD59x18.wrap(256272288217119098);
  SD59x18 internal constant TIER_ODDS_11_14 = SD59x18.wrap(403460570024895441);
  SD59x18 internal constant TIER_ODDS_12_14 = SD59x18.wrap(635185461125249183);
  SD59x18 internal constant TIER_ODDS_13_14 = SD59x18.wrap(1000000000000000000);
  SD59x18 internal constant TIER_ODDS_0_15 = SD59x18.wrap(2739726027397260);
  SD59x18 internal constant TIER_ODDS_1_15 = SD59x18.wrap(4175688124417637);
  SD59x18 internal constant TIER_ODDS_2_15 = SD59x18.wrap(6364275529026907);
  SD59x18 internal constant TIER_ODDS_3_15 = SD59x18.wrap(9699958857683993);
  SD59x18 internal constant TIER_ODDS_4_15 = SD59x18.wrap(14783961098420314);
  SD59x18 internal constant TIER_ODDS_5_15 = SD59x18.wrap(22532621938542004);
  SD59x18 internal constant TIER_ODDS_6_15 = SD59x18.wrap(34342558671878193);
  SD59x18 internal constant TIER_ODDS_7_15 = SD59x18.wrap(52342392259021369);
  SD59x18 internal constant TIER_ODDS_8_15 = SD59x18.wrap(79776409602255901);
  SD59x18 internal constant TIER_ODDS_9_15 = SD59x18.wrap(121589313257458259);
  SD59x18 internal constant TIER_ODDS_10_15 = SD59x18.wrap(185317453770221528);
  SD59x18 internal constant TIER_ODDS_11_15 = SD59x18.wrap(282447180198804430);
  SD59x18 internal constant TIER_ODDS_12_15 = SD59x18.wrap(430485137687959592);
  SD59x18 internal constant TIER_ODDS_13_15 = SD59x18.wrap(656113662171395111);
  SD59x18 internal constant TIER_ODDS_14_15 = SD59x18.wrap(1000000000000000000);
  mapping(uint8 => Tier) internal _tiers;
  uint8 public immutable tierShares;
  uint8 public immutable canaryShares;
  uint8 public immutable reserveShares;
  UD34x4 public prizeTokenPerShare;
  uint8 public numberOfTiers;
  uint16 internal lastClosedDrawId;
  uint104 internal _reserve;
  constructor(uint8 _numberOfTiers, uint8 _tierShares, uint8 _canaryShares, uint8 _reserveShares) {
    numberOfTiers = _numberOfTiers;
    tierShares = _tierShares;
    canaryShares = _canaryShares;
    reserveShares = _reserveShares;
    CANARY_PRIZE_COUNT_FOR_2_TIERS = TierCalculationLib.canaryPrizeCount(
      2,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_3_TIERS = TierCalculationLib.canaryPrizeCount(
      3,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_4_TIERS = TierCalculationLib.canaryPrizeCount(
      4,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_5_TIERS = TierCalculationLib.canaryPrizeCount(
      5,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_6_TIERS = TierCalculationLib.canaryPrizeCount(
      6,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_7_TIERS = TierCalculationLib.canaryPrizeCount(
      7,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_8_TIERS = TierCalculationLib.canaryPrizeCount(
      8,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_9_TIERS = TierCalculationLib.canaryPrizeCount(
      9,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_10_TIERS = TierCalculationLib.canaryPrizeCount(
      10,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_11_TIERS = TierCalculationLib.canaryPrizeCount(
      11,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_12_TIERS = TierCalculationLib.canaryPrizeCount(
      12,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_13_TIERS = TierCalculationLib.canaryPrizeCount(
      13,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    CANARY_PRIZE_COUNT_FOR_14_TIERS = TierCalculationLib.canaryPrizeCount(
      14,
      _canaryShares,
      _reserveShares,
      _tierShares
    );
    if (_numberOfTiers < MINIMUM_NUMBER_OF_TIERS) {
      revert NumberOfTiersLessThanMinimum(_numberOfTiers);
    }
    if (_numberOfTiers > MAXIMUM_NUMBER_OF_TIERS) {
      revert NumberOfTiersGreaterThanMaximum(_numberOfTiers);
    }
  }
  function _nextDraw(uint8 _nextNumberOfTiers, uint96 _prizeTokenLiquidity) internal {
    if (_nextNumberOfTiers < MINIMUM_NUMBER_OF_TIERS) {
      revert NumberOfTiersLessThanMinimum(_nextNumberOfTiers);
    }
    uint8 numTiers = numberOfTiers;
    UD60x18 _prizeTokenPerShare = intoUD60x18_3(prizeTokenPerShare);
    (
      uint16 closedDrawId,
      uint104 newReserve,
      UD60x18 newPrizeTokenPerShare
    ) = _computeNewDistributions(
        numTiers,
        _nextNumberOfTiers,
        _prizeTokenPerShare,
        _prizeTokenLiquidity
      );
    uint8 start;
    uint8 end;
    if (_nextNumberOfTiers > numTiers) {
      start = numTiers - 1;
      end = _nextNumberOfTiers;
    } else {
      start = _nextNumberOfTiers - 1;
      end = _nextNumberOfTiers;
    }
    for (uint8 i = start; i < end; i++) {
      _tiers[i] = Tier({
        drawId: closedDrawId,
        prizeTokenPerShare: prizeTokenPerShare,
        prizeSize: uint96(
          _computePrizeSize(i, _nextNumberOfTiers, _prizeTokenPerShare, newPrizeTokenPerShare)
        )
      });
    }
    prizeTokenPerShare = fromUD60x18_1(newPrizeTokenPerShare);
    numberOfTiers = _nextNumberOfTiers;
    lastClosedDrawId = closedDrawId;
    _reserve += newReserve;
  }
  function _computeNewDistributions(
    uint8 _numberOfTiers,
    uint8 _nextNumberOfTiers,
    uint256 _prizeTokenLiquidity
  ) internal view returns (uint16 closedDrawId, uint104 newReserve, UD60x18 newPrizeTokenPerShare) {
    return
      _computeNewDistributions(
        _numberOfTiers,
        _nextNumberOfTiers,
        intoUD60x18_3(prizeTokenPerShare),
        _prizeTokenLiquidity
      );
  }
  function _computeNewDistributions(
    uint8 _numberOfTiers,
    uint8 _nextNumberOfTiers,
    UD60x18 _currentPrizeTokenPerShare,
    uint _prizeTokenLiquidity
  ) internal view returns (uint16 closedDrawId, uint104 newReserve, UD60x18 newPrizeTokenPerShare) {
    closedDrawId = lastClosedDrawId + 1;
    uint256 totalShares = _getTotalShares(_nextNumberOfTiers);
    UD60x18 deltaPrizeTokensPerShare = (toUD60x18(_prizeTokenLiquidity).div_1(toUD60x18(totalShares)))
      .floor_1();
    newPrizeTokenPerShare = _currentPrizeTokenPerShare.add_1(deltaPrizeTokensPerShare);
    uint reclaimed = _getTierLiquidityToReclaim(
      _numberOfTiers,
      _nextNumberOfTiers,
      _currentPrizeTokenPerShare
    );
    uint computedLiquidity = fromUD60x18_0(deltaPrizeTokensPerShare.mul_1(toUD60x18(totalShares)));
    uint remainder = (_prizeTokenLiquidity - computedLiquidity);
    newReserve = uint104(
      fromUD60x18_0(deltaPrizeTokensPerShare.mul_1(toUD60x18(reserveShares))) + 
        reclaimed + 
        remainder 
    );
  }
  function getTierPrizeSize(uint8 _tier) external view returns (uint96) {
    return _getTier(_tier, numberOfTiers).prizeSize;
  }
  function getTierPrizeCount(uint8 _tier) external view returns (uint32) {
    return _getTierPrizeCount(_tier, numberOfTiers);
  }
  function getTierPrizeCount(uint8 _tier, uint8 _numberOfTiers) external view returns (uint32) {
    return _getTierPrizeCount(_tier, _numberOfTiers);
  }
  function _getTierPrizeCount(uint8 _tier, uint8 _numberOfTiers) internal view returns (uint32) {
    return
      _isCanaryTier(_tier, _numberOfTiers)
        ? _canaryPrizeCount(_numberOfTiers)
        : uint32(TierCalculationLib.prizeCount(_tier));
  }
  function _getTier(uint8 _tier, uint8 _numberOfTiers) internal view returns (Tier memory) {
    Tier memory tier = _tiers[_tier];
    uint16 _lastClosedDrawId = lastClosedDrawId;
    if (tier.drawId != _lastClosedDrawId) {
      tier.drawId = _lastClosedDrawId;
      tier.prizeSize = uint96(
        _computePrizeSize(
          _tier,
          _numberOfTiers,
          intoUD60x18_3(tier.prizeTokenPerShare),
          intoUD60x18_3(prizeTokenPerShare)
        )
      );
    }
    return tier;
  }
  function getTotalShares() external view returns (uint256) {
    return _getTotalShares(numberOfTiers);
  }
  function _getTotalShares(uint8 _numberOfTiers) internal view returns (uint256) {
    return
      uint256(_numberOfTiers - 1) *
      uint256(tierShares) +
      uint256(canaryShares) +
      uint256(reserveShares);
  }
  function _computeShares(uint8 _tier, uint8 _numTiers) internal view returns (uint8) {
    return _isCanaryTier(_tier, _numTiers) ? canaryShares : tierShares;
  }
  function _consumeLiquidity(
    Tier memory _tierStruct,
    uint8 _tier,
    uint104 _liquidity
  ) internal returns (Tier memory) {
    uint8 _shares = _computeShares(_tier, numberOfTiers);
    uint104 remainingLiquidity = uint104(
      fromUD60x18_0(
        _getTierRemainingLiquidity(
          _shares,
          intoUD60x18_3(_tierStruct.prizeTokenPerShare),
          intoUD60x18_3(prizeTokenPerShare)
        )
      )
    );
    if (_liquidity > remainingLiquidity) {
      uint104 excess = _liquidity - remainingLiquidity;
      if (excess > _reserve) {
        revert InsufficientLiquidity(_liquidity);
      }
      _reserve -= excess;
      emit ReserveConsumed(excess);
      _tierStruct.prizeTokenPerShare = prizeTokenPerShare;
    } else {
      UD34x4 delta = fromUD60x18_1(toUD60x18(_liquidity).div_1(toUD60x18(_shares)));
      _tierStruct.prizeTokenPerShare = UD34x4.wrap(
        UD34x4.unwrap(_tierStruct.prizeTokenPerShare) + UD34x4.unwrap(delta)
      );
    }
    _tiers[_tier] = _tierStruct;
    return _tierStruct;
  }
  function _computePrizeSize(
    uint8 _tier,
    uint8 _numberOfTiers,
    UD60x18 _tierPrizeTokenPerShare,
    UD60x18 _prizeTokenPerShare
  ) internal view returns (uint256) {
    uint256 prizeSize;
    if (_prizeTokenPerShare.gt_1(_tierPrizeTokenPerShare)) {
      if (_isCanaryTier(_tier, _numberOfTiers)) {
        prizeSize = _computePrizeSize(
          _tierPrizeTokenPerShare,
          _prizeTokenPerShare,
          _canaryPrizeCountFractional(_numberOfTiers),
          canaryShares
        );
      } else {
        prizeSize = _computePrizeSize(
          _tierPrizeTokenPerShare,
          _prizeTokenPerShare,
          toUD60x18(TierCalculationLib.prizeCount(_tier)),
          tierShares
        );
      }
    }
    return prizeSize;
  }
  function _computePrizeSize(
    UD60x18 _tierPrizeTokenPerShare,
    UD60x18 _prizeTokenPerShare,
    UD60x18 _fractionalPrizeCount,
    uint8 _shares
  ) internal pure returns (uint256) {
    return
      fromUD60x18_0(
        _prizeTokenPerShare.sub_1(_tierPrizeTokenPerShare).mul_1(toUD60x18(_shares)).div_1(
          _fractionalPrizeCount
        )
      );
  }
  function _isCanaryTier(uint8 _tier, uint8 _numberOfTiers) internal pure returns (bool) {
    return _tier == _numberOfTiers - 1;
  }
  function _getTierLiquidityToReclaim(
    uint8 _numberOfTiers,
    uint8 _nextNumberOfTiers,
    UD60x18 _prizeTokenPerShare
  ) internal view returns (uint256) {
    UD60x18 reclaimedLiquidity;
    uint8 start;
    uint8 end;
    if (_nextNumberOfTiers < _numberOfTiers) {
      start = _nextNumberOfTiers - 1;
      end = _numberOfTiers;
    } else {
      start = _numberOfTiers - 1;
      end = _numberOfTiers;
    }
    for (uint8 i = start; i < end; i++) {
      Tier memory tierLiquidity = _tiers[i];
      uint8 shares = _computeShares(i, _numberOfTiers);
      UD60x18 liq = _getTierRemainingLiquidity(
        shares,
        intoUD60x18_3(tierLiquidity.prizeTokenPerShare),
        _prizeTokenPerShare
      );
      reclaimedLiquidity = reclaimedLiquidity.add_1(liq);
    }
    return fromUD60x18_0(reclaimedLiquidity);
  }
  function getTierRemainingLiquidity(uint8 _tier) external view returns (uint256) {
    uint8 _numTiers = numberOfTiers;
    return
      fromUD60x18_0(
        _getTierRemainingLiquidity(
          _computeShares(_tier, _numTiers),
          intoUD60x18_3(_getTier(_tier, _numTiers).prizeTokenPerShare),
          intoUD60x18_3(prizeTokenPerShare)
        )
      );
  }
  function _getTierRemainingLiquidity(
    uint256 _shares,
    UD60x18 _tierPrizeTokenPerShare,
    UD60x18 _prizeTokenPerShare
  ) internal pure returns (UD60x18) {
    if (_tierPrizeTokenPerShare.gte_1(_prizeTokenPerShare)) {
      return ud(0);
    }
    UD60x18 delta = _prizeTokenPerShare.sub_1(_tierPrizeTokenPerShare);
    return delta.mul_1(toUD60x18(_shares));
  }
  function getOpenDrawId() external view returns (uint16) {
    return lastClosedDrawId + 1;
  }
  function estimatedPrizeCount() external view returns (uint32) {
    return _estimatedPrizeCount(numberOfTiers);
  }
  function estimatedPrizeCount(uint8 numTiers) external pure returns (uint32) {
    return _estimatedPrizeCount(numTiers);
  }
  function canaryPrizeCountFractional(uint8 numTiers) external view returns (UD60x18) {
    return _canaryPrizeCountFractional(numTiers);
  }
  function canaryPrizeCount() external view returns (uint32) {
    return _canaryPrizeCount(numberOfTiers);
  }
  function _canaryPrizeCount(uint8 _numberOfTiers) internal view returns (uint32) {
    return uint32(fromUD60x18_0(_canaryPrizeCountFractional(_numberOfTiers).floor_1()));
  }
  function canaryPrizeCount(uint8 _numTiers) external view returns (uint32) {
    return _canaryPrizeCount(_numTiers);
  }
  function reserve() external view returns (uint256) {
    return _reserve;
  }
  function _estimatedPrizeCount(uint8 numTiers) internal pure returns (uint32) {
    if (numTiers == 3) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_2_TIERS;
    } else if (numTiers == 4) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_3_TIERS;
    } else if (numTiers == 5) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_4_TIERS;
    } else if (numTiers == 6) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_5_TIERS;
    } else if (numTiers == 7) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_6_TIERS;
    } else if (numTiers == 8) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_7_TIERS;
    } else if (numTiers == 9) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_8_TIERS;
    } else if (numTiers == 10) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_9_TIERS;
    } else if (numTiers == 11) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_10_TIERS;
    } else if (numTiers == 12) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_11_TIERS;
    } else if (numTiers == 13) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_12_TIERS;
    } else if (numTiers == 14) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_13_TIERS;
    } else if (numTiers == 15) {
      return ESTIMATED_PRIZES_PER_DRAW_FOR_14_TIERS;
    }
    return 0;
  }
  function _canaryPrizeCountFractional(uint8 numTiers) internal view returns (UD60x18) {
    if (numTiers == 3) {
      return CANARY_PRIZE_COUNT_FOR_2_TIERS;
    } else if (numTiers == 4) {
      return CANARY_PRIZE_COUNT_FOR_3_TIERS;
    } else if (numTiers == 5) {
      return CANARY_PRIZE_COUNT_FOR_4_TIERS;
    } else if (numTiers == 6) {
      return CANARY_PRIZE_COUNT_FOR_5_TIERS;
    } else if (numTiers == 7) {
      return CANARY_PRIZE_COUNT_FOR_6_TIERS;
    } else if (numTiers == 8) {
      return CANARY_PRIZE_COUNT_FOR_7_TIERS;
    } else if (numTiers == 9) {
      return CANARY_PRIZE_COUNT_FOR_8_TIERS;
    } else if (numTiers == 10) {
      return CANARY_PRIZE_COUNT_FOR_9_TIERS;
    } else if (numTiers == 11) {
      return CANARY_PRIZE_COUNT_FOR_10_TIERS;
    } else if (numTiers == 12) {
      return CANARY_PRIZE_COUNT_FOR_11_TIERS;
    } else if (numTiers == 13) {
      return CANARY_PRIZE_COUNT_FOR_12_TIERS;
    } else if (numTiers == 14) {
      return CANARY_PRIZE_COUNT_FOR_13_TIERS;
    } else if (numTiers == 15) {
      return CANARY_PRIZE_COUNT_FOR_14_TIERS;
    }
    return ud(0);
  }
  function getTierOdds(uint8 _tier, uint8 _numTiers) external pure returns (SD59x18) {
    return _tierOdds(_tier, _numTiers);
  }
  function _tierOdds(uint8 _tier, uint8 _numTiers) internal pure returns (SD59x18) {
    if (_numTiers == 3) {
      if (_tier == 0) return TIER_ODDS_0_3;
      else if (_tier == 1) return TIER_ODDS_1_3;
      else if (_tier == 2) return TIER_ODDS_2_3;
    } else if (_numTiers == 4) {
      if (_tier == 0) return TIER_ODDS_0_4;
      else if (_tier == 1) return TIER_ODDS_1_4;
      else if (_tier == 2) return TIER_ODDS_2_4;
      else if (_tier == 3) return TIER_ODDS_3_4;
    } else if (_numTiers == 5) {
      if (_tier == 0) return TIER_ODDS_0_5;
      else if (_tier == 1) return TIER_ODDS_1_5;
      else if (_tier == 2) return TIER_ODDS_2_5;
      else if (_tier == 3) return TIER_ODDS_3_5;
      else if (_tier == 4) return TIER_ODDS_4_5;
    } else if (_numTiers == 6) {
      if (_tier == 0) return TIER_ODDS_0_6;
      else if (_tier == 1) return TIER_ODDS_1_6;
      else if (_tier == 2) return TIER_ODDS_2_6;
      else if (_tier == 3) return TIER_ODDS_3_6;
      else if (_tier == 4) return TIER_ODDS_4_6;
      else if (_tier == 5) return TIER_ODDS_5_6;
    } else if (_numTiers == 7) {
      if (_tier == 0) return TIER_ODDS_0_7;
      else if (_tier == 1) return TIER_ODDS_1_7;
      else if (_tier == 2) return TIER_ODDS_2_7;
      else if (_tier == 3) return TIER_ODDS_3_7;
      else if (_tier == 4) return TIER_ODDS_4_7;
      else if (_tier == 5) return TIER_ODDS_5_7;
      else if (_tier == 6) return TIER_ODDS_6_7;
    } else if (_numTiers == 8) {
      if (_tier == 0) return TIER_ODDS_0_8;
      else if (_tier == 1) return TIER_ODDS_1_8;
      else if (_tier == 2) return TIER_ODDS_2_8;
      else if (_tier == 3) return TIER_ODDS_3_8;
      else if (_tier == 4) return TIER_ODDS_4_8;
      else if (_tier == 5) return TIER_ODDS_5_8;
      else if (_tier == 6) return TIER_ODDS_6_8;
      else if (_tier == 7) return TIER_ODDS_7_8;
    } else if (_numTiers == 9) {
      if (_tier == 0) return TIER_ODDS_0_9;
      else if (_tier == 1) return TIER_ODDS_1_9;
      else if (_tier == 2) return TIER_ODDS_2_9;
      else if (_tier == 3) return TIER_ODDS_3_9;
      else if (_tier == 4) return TIER_ODDS_4_9;
      else if (_tier == 5) return TIER_ODDS_5_9;
      else if (_tier == 6) return TIER_ODDS_6_9;
      else if (_tier == 7) return TIER_ODDS_7_9;
      else if (_tier == 8) return TIER_ODDS_8_9;
    } else if (_numTiers == 10) {
      if (_tier == 0) return TIER_ODDS_0_10;
      else if (_tier == 1) return TIER_ODDS_1_10;
      else if (_tier == 2) return TIER_ODDS_2_10;
      else if (_tier == 3) return TIER_ODDS_3_10;
      else if (_tier == 4) return TIER_ODDS_4_10;
      else if (_tier == 5) return TIER_ODDS_5_10;
      else if (_tier == 6) return TIER_ODDS_6_10;
      else if (_tier == 7) return TIER_ODDS_7_10;
      else if (_tier == 8) return TIER_ODDS_8_10;
      else if (_tier == 9) return TIER_ODDS_9_10;
    } else if (_numTiers == 11) {
      if (_tier == 0) return TIER_ODDS_0_11;
      else if (_tier == 1) return TIER_ODDS_1_11;
      else if (_tier == 2) return TIER_ODDS_2_11;
      else if (_tier == 3) return TIER_ODDS_3_11;
      else if (_tier == 4) return TIER_ODDS_4_11;
      else if (_tier == 5) return TIER_ODDS_5_11;
      else if (_tier == 6) return TIER_ODDS_6_11;
      else if (_tier == 7) return TIER_ODDS_7_11;
      else if (_tier == 8) return TIER_ODDS_8_11;
      else if (_tier == 9) return TIER_ODDS_9_11;
      else if (_tier == 10) return TIER_ODDS_10_11;
    } else if (_numTiers == 12) {
      if (_tier == 0) return TIER_ODDS_0_12;
      else if (_tier == 1) return TIER_ODDS_1_12;
      else if (_tier == 2) return TIER_ODDS_2_12;
      else if (_tier == 3) return TIER_ODDS_3_12;
      else if (_tier == 4) return TIER_ODDS_4_12;
      else if (_tier == 5) return TIER_ODDS_5_12;
      else if (_tier == 6) return TIER_ODDS_6_12;
      else if (_tier == 7) return TIER_ODDS_7_12;
      else if (_tier == 8) return TIER_ODDS_8_12;
      else if (_tier == 9) return TIER_ODDS_9_12;
      else if (_tier == 10) return TIER_ODDS_10_12;
      else if (_tier == 11) return TIER_ODDS_11_12;
    } else if (_numTiers == 13) {
      if (_tier == 0) return TIER_ODDS_0_13;
      else if (_tier == 1) return TIER_ODDS_1_13;
      else if (_tier == 2) return TIER_ODDS_2_13;
      else if (_tier == 3) return TIER_ODDS_3_13;
      else if (_tier == 4) return TIER_ODDS_4_13;
      else if (_tier == 5) return TIER_ODDS_5_13;
      else if (_tier == 6) return TIER_ODDS_6_13;
      else if (_tier == 7) return TIER_ODDS_7_13;
      else if (_tier == 8) return TIER_ODDS_8_13;
      else if (_tier == 9) return TIER_ODDS_9_13;
      else if (_tier == 10) return TIER_ODDS_10_13;
      else if (_tier == 11) return TIER_ODDS_11_13;
      else if (_tier == 12) return TIER_ODDS_12_13;
    } else if (_numTiers == 14) {
      if (_tier == 0) return TIER_ODDS_0_14;
      else if (_tier == 1) return TIER_ODDS_1_14;
      else if (_tier == 2) return TIER_ODDS_2_14;
      else if (_tier == 3) return TIER_ODDS_3_14;
      else if (_tier == 4) return TIER_ODDS_4_14;
      else if (_tier == 5) return TIER_ODDS_5_14;
      else if (_tier == 6) return TIER_ODDS_6_14;
      else if (_tier == 7) return TIER_ODDS_7_14;
      else if (_tier == 8) return TIER_ODDS_8_14;
      else if (_tier == 9) return TIER_ODDS_9_14;
      else if (_tier == 10) return TIER_ODDS_10_14;
      else if (_tier == 11) return TIER_ODDS_11_14;
      else if (_tier == 12) return TIER_ODDS_12_14;
      else if (_tier == 13) return TIER_ODDS_13_14;
    } else if (_numTiers == 15) {
      if (_tier == 0) return TIER_ODDS_0_15;
      else if (_tier == 1) return TIER_ODDS_1_15;
      else if (_tier == 2) return TIER_ODDS_2_15;
      else if (_tier == 3) return TIER_ODDS_3_15;
      else if (_tier == 4) return TIER_ODDS_4_15;
      else if (_tier == 5) return TIER_ODDS_5_15;
      else if (_tier == 6) return TIER_ODDS_6_15;
      else if (_tier == 7) return TIER_ODDS_7_15;
      else if (_tier == 8) return TIER_ODDS_8_15;
      else if (_tier == 9) return TIER_ODDS_9_15;
      else if (_tier == 10) return TIER_ODDS_10_15;
      else if (_tier == 11) return TIER_ODDS_11_15;
      else if (_tier == 12) return TIER_ODDS_12_15;
      else if (_tier == 13) return TIER_ODDS_13_15;
      else if (_tier == 14) return TIER_ODDS_14_15;
    }
    return sd(0);
  }
}
error DrawManagerAlreadySet();
error AlreadyClaimedPrize(
  address vault,
  address winner,
  uint8 tier,
  uint32 prizeIndex,
  address recipient
);
error InsufficientRewardsError(uint256 requested, uint256 available);
error DidNotWin(address vault, address winner, uint8 tier, uint32 prizeIndex);
error FeeTooLarge(uint256 fee, uint256 maxFee);
error SmoothingGTEOne(int64 smoothing);
error ContributionGTDeltaBalance(uint256 amount, uint256 available);
error InsufficientReserve(uint104 amount, uint104 reserve);
error RandomNumberIsZero();
error DrawNotFinished(uint64 drawEndsAt, uint64 errorTimestamp);
error InvalidPrizeIndex(uint32 invalidPrizeIndex, uint32 prizeCount, uint8 tier);
error NoClosedDraw();
error InvalidTier(uint8 tier, uint8 numberOfTiers);
error CallerNotDrawManager(address caller, address drawManager);
struct ConstructorParams {
  IERC20 prizeToken;
  TwabController twabController;
  address drawManager;
  uint32 drawPeriodSeconds;
  uint64 firstDrawStartsAt;
  uint8 numberOfTiers;
  uint8 tierShares;
  uint8 canaryShares;
  uint8 reserveShares;
  UD2x18 claimExpansionThreshold;
  SD1x18 smoothing;
}
contract PrizePool is TieredLiquidityDistributor {
  using SafeERC20 for IERC20;
  event ClaimedPrize(
    address indexed vault,
    address indexed winner,
    address indexed recipient,
    uint16 drawId,
    uint8 tier,
    uint32 prizeIndex,
    uint152 payout,
    uint96 fee,
    address feeRecipient
  );
  event DrawClosed(
    uint16 indexed drawId,
    uint256 winningRandomNumber,
    uint8 numTiers,
    uint8 nextNumTiers,
    uint104 reserve,
    UD34x4 prizeTokensPerShare,
    uint64 drawStartedAt
  );
  event WithdrawReserve(address indexed to, uint256 amount);
  event IncreaseReserve(address user, uint256 amount);
  event ContributePrizeTokens(address indexed vault, uint16 indexed drawId, uint256 amount);
  event WithdrawClaimRewards(address indexed to, uint256 amount, uint256 available);
  event IncreaseClaimRewards(address indexed to, uint256 amount);
  event DrawManagerSet(address indexed drawManager);
  mapping(address => DrawAccumulatorLib.Accumulator) internal vaultAccumulator;
  mapping(address => mapping(address => mapping(uint16 => mapping(uint8 => mapping(uint32 => bool)))))
    internal claimedPrizes;
  mapping(address => uint256) internal claimerRewards;
  SD1x18 public immutable smoothing;
  IERC20 public immutable prizeToken;
  TwabController public immutable twabController;
  address public drawManager;
  uint32 public immutable drawPeriodSeconds;
  UD2x18 public immutable claimExpansionThreshold;
  DrawAccumulatorLib.Accumulator internal totalAccumulator;
  uint256 internal _totalWithdrawn;
  uint256 internal _winningRandomNumber;
  uint32 public claimCount;
  uint32 public canaryClaimCount;
  uint8 public largestTierClaimed;
  uint64 internal _lastClosedDrawStartedAt;
  uint64 internal _lastClosedDrawAwardedAt;
  constructor(
    ConstructorParams memory params
  )
    TieredLiquidityDistributor(
      params.numberOfTiers,
      params.tierShares,
      params.canaryShares,
      params.reserveShares
    )
  {
    if (unwrap_0(params.smoothing) >= unwrap_0(UNIT_1)) {
      revert SmoothingGTEOne(unwrap_0(params.smoothing));
    }
    prizeToken = params.prizeToken;
    twabController = params.twabController;
    smoothing = params.smoothing;
    claimExpansionThreshold = params.claimExpansionThreshold;
    drawPeriodSeconds = params.drawPeriodSeconds;
    _lastClosedDrawStartedAt = params.firstDrawStartsAt;
    drawManager = params.drawManager;
    if (params.drawManager != address(0)) {
      emit DrawManagerSet(params.drawManager);
    }
  }
  modifier onlyDrawManager() {
    if (msg.sender != drawManager) {
      revert CallerNotDrawManager(msg.sender, drawManager);
    }
    _;
  }
  function setDrawManager(address _drawManager) external {
    if (drawManager != address(0)) {
      revert DrawManagerAlreadySet();
    }
    drawManager = _drawManager;
    emit DrawManagerSet(_drawManager);
  }
  function contributePrizeTokens(address _prizeVault, uint256 _amount) external returns (uint256) {
    uint256 _deltaBalance = prizeToken.balanceOf(address(this)) - _accountedBalance();
    if (_deltaBalance < _amount) {
      revert ContributionGTDeltaBalance(_amount, _deltaBalance);
    }
    DrawAccumulatorLib.add(
      vaultAccumulator[_prizeVault],
      _amount,
      lastClosedDrawId + 1,
      smoothing.intoSD59x18_0()
    );
    DrawAccumulatorLib.add(
      totalAccumulator,
      _amount,
      lastClosedDrawId + 1,
      smoothing.intoSD59x18_0()
    );
    emit ContributePrizeTokens(_prizeVault, lastClosedDrawId + 1, _amount);
    return _deltaBalance;
  }
  function withdrawReserve(address _to, uint104 _amount) external onlyDrawManager {
    if (_amount > _reserve) {
      revert InsufficientReserve(_amount, _reserve);
    }
    _reserve -= _amount;
    _transfer(_to, _amount);
    emit WithdrawReserve(_to, _amount);
  }
  function closeDraw(uint256 winningRandomNumber_) external onlyDrawManager returns (uint16) {
    if (winningRandomNumber_ == 0) {
      revert RandomNumberIsZero();
    }
    if (block.timestamp < _openDrawEndsAt()) {
      revert DrawNotFinished(_openDrawEndsAt(), uint64(block.timestamp));
    }
    uint8 _numTiers = numberOfTiers;
    uint8 _nextNumberOfTiers = _numTiers;
    if (lastClosedDrawId != 0) {
      _nextNumberOfTiers = _computeNextNumberOfTiers(_numTiers);
    }
    uint64 openDrawStartedAt_ = _openDrawStartedAt();
    _nextDraw(_nextNumberOfTiers, uint96(_contributionsForDraw(lastClosedDrawId + 1)));
    _winningRandomNumber = winningRandomNumber_;
    claimCount = 0;
    canaryClaimCount = 0;
    largestTierClaimed = 0;
    _lastClosedDrawStartedAt = openDrawStartedAt_;
    _lastClosedDrawAwardedAt = uint64(block.timestamp);
    emit DrawClosed(
      lastClosedDrawId,
      winningRandomNumber_,
      _numTiers,
      _nextNumberOfTiers,
      _reserve,
      prizeTokenPerShare,
      _lastClosedDrawStartedAt
    );
    return lastClosedDrawId;
  }
  function claimPrize(
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex,
    address _prizeRecipient,
    uint96 _fee,
    address _feeRecipient
  ) external returns (uint256) {
    Tier memory tierLiquidity = _getTier(_tier, numberOfTiers);
    if (_fee > tierLiquidity.prizeSize) {
      revert FeeTooLarge(_fee, tierLiquidity.prizeSize);
    }
    (SD59x18 _vaultPortion, SD59x18 _tierOdds, uint16 _drawDuration) = _computeVaultTierDetails(
      msg.sender,
      _tier,
      numberOfTiers,
      lastClosedDrawId
    );
    if (
      !_isWinner(msg.sender, _winner, _tier, _prizeIndex, _vaultPortion, _tierOdds, _drawDuration)
    ) {
      revert DidNotWin(msg.sender, _winner, _tier, _prizeIndex);
    }
    if (claimedPrizes[msg.sender][_winner][lastClosedDrawId][_tier][_prizeIndex]) {
      revert AlreadyClaimedPrize(msg.sender, _winner, _tier, _prizeIndex, _prizeRecipient);
    }
    claimedPrizes[msg.sender][_winner][lastClosedDrawId][_tier][_prizeIndex] = true;
    if (_isCanaryTier(_tier, numberOfTiers)) {
      canaryClaimCount++;
    } else {
      claimCount++;
    }
    if (largestTierClaimed < _tier) {
      largestTierClaimed = _tier;
    }
    _consumeLiquidity(tierLiquidity, _tier, tierLiquidity.prizeSize);
    if (_fee != 0) {
      emit IncreaseClaimRewards(_feeRecipient, _fee);
      claimerRewards[_feeRecipient] += _fee;
    }
    uint256 amount = tierLiquidity.prizeSize - _fee;
    emit ClaimedPrize(
      msg.sender,
      _winner,
      _prizeRecipient,
      lastClosedDrawId,
      _tier,
      _prizeIndex,
      uint152(amount),
      _fee,
      _feeRecipient
    );
    _transfer(_prizeRecipient, amount);
    return tierLiquidity.prizeSize;
  }
  function withdrawClaimRewards(address _to, uint256 _amount) external {
    uint256 _available = claimerRewards[msg.sender];
    if (_amount > _available) {
      revert InsufficientRewardsError(_amount, _available);
    }
    claimerRewards[msg.sender] -= _amount;
    _transfer(_to, _amount);
    emit WithdrawClaimRewards(_to, _amount, _available);
  }
  function increaseReserve(uint104 _amount) external {
    _reserve += _amount;
    prizeToken.safeTransferFrom(msg.sender, address(this), _amount);
    emit IncreaseReserve(msg.sender, _amount);
  }
  function getWinningRandomNumber() external view returns (uint256) {
    return _winningRandomNumber;
  }
  function getLastClosedDrawId() external view returns (uint256) {
    return lastClosedDrawId;
  }
  function getTotalContributedBetween(
    uint16 _startDrawIdInclusive,
    uint16 _endDrawIdInclusive
  ) external view returns (uint256) {
    return
      DrawAccumulatorLib.getDisbursedBetween(
        totalAccumulator,
        _startDrawIdInclusive,
        _endDrawIdInclusive,
        smoothing.intoSD59x18_0()
      );
  }
  function getContributedBetween(
    address _vault,
    uint16 _startDrawIdInclusive,
    uint16 _endDrawIdInclusive
  ) external view returns (uint256) {
    return
      DrawAccumulatorLib.getDisbursedBetween(
        vaultAccumulator[_vault],
        _startDrawIdInclusive,
        _endDrawIdInclusive,
        smoothing.intoSD59x18_0()
      );
  }
  function getTierAccrualDurationInDraws(uint8 _tier) external view returns (uint16) {
    return
      uint16(TierCalculationLib.estimatePrizeFrequencyInDraws(_tierOdds(_tier, numberOfTiers)));
  }
  function totalWithdrawn() external view returns (uint256) {
    return _totalWithdrawn;
  }
  function accountedBalance() external view returns (uint256) {
    return _accountedBalance();
  }
  function lastClosedDrawStartedAt() external view returns (uint64) {
    return lastClosedDrawId != 0 ? _lastClosedDrawStartedAt : 0;
  }
  function lastClosedDrawEndedAt() external view returns (uint64) {
    return lastClosedDrawId != 0 ? _lastClosedDrawStartedAt + drawPeriodSeconds : 0;
  }
  function lastClosedDrawAwardedAt() external view returns (uint64) {
    return lastClosedDrawId != 0 ? _lastClosedDrawAwardedAt : 0;
  }
  function hasOpenDrawFinished() external view returns (bool) {
    return block.timestamp >= _openDrawEndsAt();
  }
  function openDrawStartedAt() external view returns (uint64) {
    return _openDrawStartedAt();
  }
  function openDrawEndsAt() external view returns (uint64) {
    return _openDrawEndsAt();
  }
  function reserveForOpenDraw() external view returns (uint256) {
    uint8 _numTiers = numberOfTiers;
    uint8 _nextNumberOfTiers = _numTiers;
    if (lastClosedDrawId != 0) {
      _nextNumberOfTiers = _computeNextNumberOfTiers(_numTiers);
    }
    (, uint104 newReserve, ) = _computeNewDistributions(
      _numTiers,
      _nextNumberOfTiers,
      uint96(_contributionsForDraw(lastClosedDrawId + 1))
    );
    return newReserve;
  }
  function getTotalContributionsForClosedDraw() external view returns (uint256) {
    return _contributionsForDraw(lastClosedDrawId);
  }
  function wasClaimed(
    address _vault,
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex
  ) external view returns (bool) {
    return claimedPrizes[_vault][_winner][lastClosedDrawId][_tier][_prizeIndex];
  }
  function balanceOfClaimRewards(address _claimer) external view returns (uint256) {
    return claimerRewards[_claimer];
  }
  function isWinner(
    address _vault,
    address _user,
    uint8 _tier,
    uint32 _prizeIndex
  ) external view returns (bool) {
    (SD59x18 vaultPortion, SD59x18 tierOdds, uint16 drawDuration) = _computeVaultTierDetails(
      _vault,
      _tier,
      numberOfTiers,
      lastClosedDrawId
    );
    return _isWinner(_vault, _user, _tier, _prizeIndex, vaultPortion, tierOdds, drawDuration);
  }
  function calculateTierTwabTimestamps(
    uint8 _tier
  ) external view returns (uint64 startTimestamp, uint64 endTimestamp) {
    uint8 _numberOfTiers = numberOfTiers;
    _checkValidTier(_tier, _numberOfTiers);
    endTimestamp = _lastClosedDrawStartedAt + drawPeriodSeconds;
    SD59x18 tierOdds = _tierOdds(_tier, _numberOfTiers);
    uint256 durationInSeconds = TierCalculationLib.estimatePrizeFrequencyInDraws(tierOdds) * drawPeriodSeconds;
    startTimestamp = uint64(
      endTimestamp -
        durationInSeconds
    );
  }
  function getVaultUserBalanceAndTotalSupplyTwab(
    address _vault,
    address _user,
    uint256 _drawDuration
  ) external view returns (uint256, uint256) {
    return _getVaultUserBalanceAndTotalSupplyTwab(_vault, _user, _drawDuration);
  }
  function getVaultPortion(
    address _vault,
    uint16 _startDrawId,
    uint16 _endDrawId
  ) external view returns (SD59x18) {
    return _getVaultPortion(_vault, _startDrawId, _endDrawId, smoothing.intoSD59x18_0());
  }
  function nextNumberOfTiers() external view returns (uint8) {
    return _computeNextNumberOfTiers(numberOfTiers);
  }
  function _accountedBalance() internal view returns (uint256) {
    Observation memory obs = DrawAccumulatorLib.newestObservation(totalAccumulator);
    return (obs.available + obs.disbursed) - _totalWithdrawn;
  }
  function _openDrawStartedAt() internal view returns (uint64) {
    return _openDrawEndsAt() - drawPeriodSeconds;
  }
  function _checkValidTier(uint8 _tier, uint8 _numTiers) internal pure {
    if (_tier >= _numTiers) {
      revert InvalidTier(_tier, _numTiers);
    }
  }
  function _openDrawEndsAt() internal view returns (uint64) {
    uint64 _nextExpectedEndTime = _lastClosedDrawStartedAt +
      (lastClosedDrawId == 0 ? 1 : 2) *
      drawPeriodSeconds;
    if (block.timestamp > _nextExpectedEndTime) {
      _nextExpectedEndTime +=
        drawPeriodSeconds *
        (uint64((block.timestamp - _nextExpectedEndTime) / drawPeriodSeconds));
    }
    return _nextExpectedEndTime;
  }
  function _computeNextNumberOfTiers(uint8 _numTiers) internal view returns (uint8) {
    UD2x18 _claimExpansionThreshold = claimExpansionThreshold;
    uint8 _nextNumberOfTiers = largestTierClaimed + 2; 
    _nextNumberOfTiers = _nextNumberOfTiers > MINIMUM_NUMBER_OF_TIERS
      ? _nextNumberOfTiers
      : MINIMUM_NUMBER_OF_TIERS;
    if (_nextNumberOfTiers >= MAXIMUM_NUMBER_OF_TIERS) {
      return MAXIMUM_NUMBER_OF_TIERS;
    }
    if (
      _nextNumberOfTiers >= _numTiers &&
      canaryClaimCount >=
      fromUD60x18_0(
        intoUD60x18_2(_claimExpansionThreshold).mul_1(_canaryPrizeCountFractional(_numTiers).floor_1())
      ) &&
      claimCount >=
      fromUD60x18_0(
        intoUD60x18_2(_claimExpansionThreshold).mul_1(toUD60x18(_estimatedPrizeCount(_numTiers)))
      )
    ) {
      _nextNumberOfTiers = _numTiers + 1;
    }
    return _nextNumberOfTiers;
  }
  function _contributionsForDraw(uint16 _drawId) internal view returns (uint256) {
    return
      DrawAccumulatorLib.getDisbursedBetween(
        totalAccumulator,
        _drawId,
        _drawId,
        smoothing.intoSD59x18_0()
      );
  }
  function _transfer(address _to, uint256 _amount) internal {
    _totalWithdrawn += _amount;
    prizeToken.safeTransfer(_to, _amount);
  }
  function _isWinner(
    address _vault,
    address _user,
    uint8 _tier,
    uint32 _prizeIndex,
    SD59x18 _vaultPortion,
    SD59x18 _tierOdds,
    uint16 _drawDuration
  ) internal view returns (bool) {
    uint8 _numberOfTiers = numberOfTiers;
    uint32 tierPrizeCount = _getTierPrizeCount(_tier, _numberOfTiers);
    if (_prizeIndex >= tierPrizeCount) {
      revert InvalidPrizeIndex(_prizeIndex, tierPrizeCount, _tier);
    }
    uint256 userSpecificRandomNumber = TierCalculationLib.calculatePseudoRandomNumber(
      _user,
      _tier,
      _prizeIndex,
      _winningRandomNumber
    );
    (uint256 _userTwab, uint256 _vaultTwabTotalSupply) = _getVaultUserBalanceAndTotalSupplyTwab(
      _vault,
      _user,
      _drawDuration
    );
    return
      TierCalculationLib.isWinner(
        userSpecificRandomNumber,
        uint128(_userTwab),
        uint128(_vaultTwabTotalSupply),
        _vaultPortion,
        _tierOdds
      );
  }
  function _computeVaultTierDetails(
    address _vault,
    uint8 _tier,
    uint8 _numberOfTiers,
    uint16 _lastClosedDrawId
  ) internal view returns (SD59x18 vaultPortion, SD59x18 tierOdds, uint16 drawDuration) {
    if (_lastClosedDrawId == 0) {
      revert NoClosedDraw();
    }
    _checkValidTier(_tier, _numberOfTiers);
    tierOdds = _tierOdds(_tier, numberOfTiers);
    drawDuration = uint16(TierCalculationLib.estimatePrizeFrequencyInDraws(tierOdds));
    vaultPortion = _getVaultPortion(
      _vault,
      uint16(drawDuration > _lastClosedDrawId ? 0 : _lastClosedDrawId - drawDuration + 1),
      _lastClosedDrawId + 1,
      smoothing.intoSD59x18_0()
    );
  }
  function _getVaultUserBalanceAndTotalSupplyTwab(
    address _vault,
    address _user,
    uint256 _drawDuration
  ) internal view returns (uint256 twab, uint256 twabTotalSupply) {
    uint32 _endTimestamp = uint32(_lastClosedDrawStartedAt + drawPeriodSeconds);
    uint32 _startTimestamp = uint32(_endTimestamp - _drawDuration * drawPeriodSeconds);
    twab = twabController.getTwabBetween(_vault, _user, _startTimestamp, _endTimestamp);
    twabTotalSupply = twabController.getTotalSupplyTwabBetween(
      _vault,
      _startTimestamp,
      _endTimestamp
    );
  }
  function _getVaultPortion(
    address _vault,
    uint16 _startDrawId,
    uint16 _endDrawId,
    SD59x18 _smoothing
  ) internal view returns (SD59x18) {
    uint256 totalContributed = DrawAccumulatorLib.getDisbursedBetween(
      totalAccumulator,
      _startDrawId,
      _endDrawId,
      _smoothing
    );
    if (totalContributed != 0) {
      return
        sd(
          int256(
            DrawAccumulatorLib.getDisbursedBetween(
              vaultAccumulator[_vault],
              _startDrawId,
              _endDrawId,
              _smoothing
            )
          )
        ).div_0(sd(int256(totalContributed)));
    } else {
      return sd(0);
    }
  }
}
error TwabControllerZeroAddress();
error YieldVaultZeroAddress();
error PrizePoolZeroAddress();
error OwnerZeroAddress();
error DepositMoreThanMax(address receiver, uint256 amount, uint256 max);
error WithdrawMoreThanMax(address owner, uint256 amount, uint256 max);
error RedeemMoreThanMax(address owner, uint256 amount, uint256 max);
error MintMoreThanMax(address receiver, uint256 shares, uint256 max);
error LiquidationCallerNotLP(address caller, address liquidationPair);
error LiquidationTokenInNotPrizeToken(address tokenIn, address prizeToken);
error LiquidationTokenOutNotVaultShare(address tokenOut, address vaultShare);
error LiquidationAmountOutZero();
error LiquidationAmountOutGTYield(uint256 amountOut, uint256 availableYield);
error VaultUnderCollateralized();
error TargetTokenNotSupported(address token);
error CallerNotClaimer(address caller, address claimer);
error YieldFeeGTAvailable(uint256 shares, uint256 yieldFeeTotalSupply);
error LPZeroAddress();
error YieldFeePercentageGTPrecision(uint256 yieldFeePercentage, uint256 maxYieldFeePercentage);
contract Vault is ERC4626, ERC20Permit, ILiquidationSource, Ownable {
  using Math for uint256;
  using SafeERC20 for IERC20;
  event NewVault(
    IERC20 indexed asset,
    string name,
    string symbol,
    TwabController twabController,
    IERC4626 indexed yieldVault,
    PrizePool indexed prizePool,
    address claimer,
    address yieldFeeRecipient,
    uint256 yieldFeePercentage,
    address owner
  );
  event ClaimerSet(address previousClaimer, address newClaimer);
  event SetHooks(address account, VaultHooks hooks);
  event LiquidationPairSet(LiquidationPair newLiquidationPair);
  event MintYieldFee(address indexed caller, address indexed recipient, uint256 shares);
  event YieldFeeRecipientSet(address previousYieldFeeRecipient, address newYieldFeeRecipient);
  event YieldFeePercentageSet(uint256 previousYieldFeePercentage, uint256 newYieldFeePercentage);
  event Sponsor(address indexed caller, address indexed receiver, uint256 assets, uint256 shares);
  event RecordedExchangeRate(uint256 exchangeRate);
  TwabController private immutable _twabController;
  IERC4626 private immutable _yieldVault;
  PrizePool private immutable _prizePool;
  address private _claimer;
  LiquidationPair private _liquidationPair;
  uint256 private _assetUnit;
  uint256 private _lastRecordedExchangeRate;
  uint256 private _yieldFeePercentage;
  address private _yieldFeeRecipient;
  uint256 private _yieldFeeTotalSupply;
  uint256 private constant FEE_PRECISION = 1e9;
  mapping(address => VaultHooks) internal _hooks;
  constructor(
    IERC20 asset_,
    string memory name_,
    string memory symbol_,
    TwabController twabController_,
    IERC4626 yieldVault_,
    PrizePool prizePool_,
    address claimer_,
    address yieldFeeRecipient_,
    uint256 yieldFeePercentage_,
    address owner_
  ) ERC4626(asset_) ERC20(name_, symbol_) ERC20Permit(name_) Ownable(owner_) {
    if (address(twabController_) == address(0)) revert TwabControllerZeroAddress();
    if (address(yieldVault_) == address(0)) revert YieldVaultZeroAddress();
    if (address(prizePool_) == address(0)) revert PrizePoolZeroAddress();
    if (address(owner_) == address(0)) revert OwnerZeroAddress();
    _twabController = twabController_;
    _yieldVault = yieldVault_;
    _prizePool = prizePool_;
    _setClaimer(claimer_);
    _setYieldFeeRecipient(yieldFeeRecipient_);
    _setYieldFeePercentage(yieldFeePercentage_);
    _assetUnit = 10 ** super.decimals();
    asset_.safeApprove(address(yieldVault_), type(uint256).max);
    emit NewVault(
      asset_,
      name_,
      symbol_,
      twabController_,
      yieldVault_,
      prizePool_,
      claimer_,
      yieldFeeRecipient_,
      yieldFeePercentage_,
      owner_
    );
  }
  function availableYieldBalance() public view returns (uint256) {
    uint256 _assets = _totalAssets();
    uint256 _sharesToAssets = _convertToAssets(_totalShares(), Math.Rounding.Down);
    return _sharesToAssets > _assets ? 0 : _assets - _sharesToAssets;
  }
  function availableYieldFeeBalance() public view returns (uint256) {
    uint256 _availableYield = availableYieldBalance();
    if (_availableYield != 0 && _yieldFeePercentage != 0) {
      return _availableYieldFeeBalance(_availableYield);
    }
    return 0;
  }
  function balanceOf(
    address _account
  ) public view virtual override(ERC20, IERC20) returns (uint256) {
    return _twabController.balanceOf(address(this), _account);
  }
  function decimals() public view virtual override(ERC4626, ERC20) returns (uint8) {
    return super.decimals();
  }
  function totalAssets() public view virtual override returns (uint256) {
    return _totalAssets();
  }
  function totalSupply() public view virtual override(ERC20, IERC20) returns (uint256) {
    return _totalSupply();
  }
  function exchangeRate() public view returns (uint256) {
    return _currentExchangeRate();
  }
  function isVaultCollateralized() public view returns (bool) {
    return _isVaultCollateralized();
  }
  function maxDeposit(address) public view virtual override returns (uint256) {
    return _isVaultCollateralized() ? type(uint96).max : 0;
  }
  function maxMint(address) public view virtual override returns (uint256) {
    return _isVaultCollateralized() ? type(uint96).max : 0;
  }
  function mintYieldFee(uint256 _shares, address _recipient) external {
    _requireVaultCollateralized();
    if (_shares > _yieldFeeTotalSupply) revert YieldFeeGTAvailable(_shares, _yieldFeeTotalSupply);
    _yieldFeeTotalSupply -= _shares;
    _mint(_recipient, _shares);
    emit MintYieldFee(msg.sender, _recipient, _shares);
  }
  function deposit(uint256 _assets, address _receiver) public virtual override returns (uint256) {
    if (_assets > maxDeposit(_receiver))
      revert DepositMoreThanMax(_receiver, _assets, maxDeposit(_receiver));
    uint256 _shares = _convertToShares(_assets, Math.Rounding.Down);
    _deposit(msg.sender, _receiver, _assets, _shares);
    return _shares;
  }
  function depositWithPermit(
    uint256 _assets,
    address _receiver,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external returns (uint256) {
    _permit(IERC20Permit(asset()), msg.sender, address(this), _assets, _deadline, _v, _r, _s);
    return deposit(_assets, _receiver);
  }
  function mint(uint256 _shares, address _receiver) public virtual override returns (uint256) {
    uint256 _assets = _beforeMint(_shares, _receiver);
    _deposit(msg.sender, _receiver, _assets, _shares);
    return _assets;
  }
  function mintWithPermit(
    uint256 _shares,
    address _receiver,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external returns (uint256) {
    uint256 _assets = _beforeMint(_shares, _receiver);
    _permit(IERC20Permit(asset()), msg.sender, address(this), _assets, _deadline, _v, _r, _s);
    _deposit(msg.sender, _receiver, _assets, _shares);
    return _assets;
  }
  function sponsor(uint256 _assets, address _receiver) external returns (uint256) {
    return _sponsor(_assets, _receiver);
  }
  function sponsorWithPermit(
    uint256 _assets,
    address _receiver,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) external returns (uint256) {
    _permit(IERC20Permit(asset()), msg.sender, address(this), _assets, _deadline, _v, _r, _s);
    return _sponsor(_assets, _receiver);
  }
  function withdraw(
    uint256 _assets,
    address _receiver,
    address _owner
  ) public virtual override returns (uint256) {
    if (_assets > maxWithdraw(_owner))
      revert WithdrawMoreThanMax(_owner, _assets, maxWithdraw(_owner));
    uint256 _shares = _convertToShares(_assets, Math.Rounding.Up);
    _withdraw(msg.sender, _receiver, _owner, _assets, _shares);
    return _shares;
  }
  function redeem(
    uint256 _shares,
    address _receiver,
    address _owner
  ) public virtual override returns (uint256) {
    if (_shares > maxRedeem(_owner)) revert RedeemMoreThanMax(_owner, _shares, maxRedeem(_owner));
    uint256 _assets = _convertToAssets(_shares, Math.Rounding.Down);
    _withdraw(msg.sender, _receiver, _owner, _assets, _shares);
    return _assets;
  }
  function liquidatableBalanceOf(address _token) public view override returns (uint256) {
    return _liquidatableBalanceOf(_token);
  }
  function liquidate(
    address _account,
    address _tokenIn,
    uint256 _amountIn,
    address _tokenOut,
    uint256 _amountOut
  ) public virtual override returns (bool) {
    _requireVaultCollateralized();
    if (msg.sender != address(_liquidationPair))
      revert LiquidationCallerNotLP(msg.sender, address(_liquidationPair));
    if (_tokenIn != address(_prizePool.prizeToken()))
      revert LiquidationTokenInNotPrizeToken(_tokenIn, address(_prizePool.prizeToken()));
    if (_tokenOut != address(this))
      revert LiquidationTokenOutNotVaultShare(_tokenOut, address(this));
    if (_amountOut == 0) revert LiquidationAmountOutZero();
    uint256 _liquidableYield = _liquidatableBalanceOf(_tokenOut);
    if (_amountOut > _liquidableYield)
      revert LiquidationAmountOutGTYield(_amountOut, _liquidableYield);
    _prizePool.contributePrizeTokens(address(this), _amountIn);
    if (_yieldFeePercentage != 0) {
      _increaseYieldFeeBalance(
        (_amountOut * FEE_PRECISION) / (FEE_PRECISION - _yieldFeePercentage) - _amountOut
      );
    }
    uint256 _vaultAssets = IERC20(asset()).balanceOf(address(this));
    if (_vaultAssets != 0 && _amountOut >= _vaultAssets) {
      _yieldVault.deposit(_vaultAssets, address(this));
    }
    _mint(_account, _amountOut);
    return true;
  }
  function targetOf(address _token) external view returns (address) {
    if (_token != _liquidationPair.tokenIn()) revert TargetTokenNotSupported(_token);
    return address(_prizePool);
  }
  function claimPrizes(
    uint8 _tier,
    address[] calldata _winners,
    uint32[][] calldata _prizeIndices,
    uint96 _feePerClaim,
    address _feeRecipient
  ) external returns (uint256) {
    if (msg.sender != _claimer) revert CallerNotClaimer(msg.sender, _claimer);
    uint totalPrizes;
    for (uint w = 0; w < _winners.length; w++) {
      uint prizeIndicesLength = _prizeIndices[w].length;
      for (uint p = 0; p < prizeIndicesLength; p++) {
        totalPrizes += _claimPrize(
          _winners[w],
          _tier,
          _prizeIndices[w][p],
          _feePerClaim,
          _feeRecipient
        );
      }
    }
    return totalPrizes;
  }
  function setClaimer(address claimer_) external onlyOwner returns (address) {
    address _previousClaimer = _claimer;
    _setClaimer(claimer_);
    emit ClaimerSet(_previousClaimer, claimer_);
    return claimer_;
  }
  function setHooks(VaultHooks memory hooks) external {
    _hooks[msg.sender] = hooks;
    emit SetHooks(msg.sender, hooks);
  }
  function setLiquidationPair(
    LiquidationPair liquidationPair_
  ) external onlyOwner returns (address) {
    if (address(liquidationPair_) == address(0)) revert LPZeroAddress();
    IERC20 _asset = IERC20(asset());
    address _previousLiquidationPair = address(_liquidationPair);
    if (_previousLiquidationPair != address(0)) {
      _asset.safeApprove(_previousLiquidationPair, 0);
    }
    _asset.safeApprove(address(liquidationPair_), type(uint256).max);
    _liquidationPair = liquidationPair_;
    emit LiquidationPairSet(liquidationPair_);
    return address(liquidationPair_);
  }
  function setYieldFeePercentage(uint256 yieldFeePercentage_) external onlyOwner returns (uint256) {
    uint256 _previousYieldFeePercentage = _yieldFeePercentage;
    _setYieldFeePercentage(yieldFeePercentage_);
    emit YieldFeePercentageSet(_previousYieldFeePercentage, yieldFeePercentage_);
    return yieldFeePercentage_;
  }
  function setYieldFeeRecipient(address yieldFeeRecipient_) external onlyOwner returns (address) {
    address _previousYieldFeeRecipient = _yieldFeeRecipient;
    _setYieldFeeRecipient(yieldFeeRecipient_);
    emit YieldFeeRecipientSet(_previousYieldFeeRecipient, yieldFeeRecipient_);
    return yieldFeeRecipient_;
  }
  function yieldFeeRecipient() public view returns (address) {
    return _yieldFeeRecipient;
  }
  function yieldFeePercentage() public view returns (uint256) {
    return _yieldFeePercentage;
  }
  function yieldFeeTotalSupply() public view returns (uint256) {
    return _yieldFeeTotalSupply;
  }
  function twabController() public view returns (address) {
    return address(_twabController);
  }
  function yieldVault() public view returns (address) {
    return address(_yieldVault);
  }
  function liquidationPair() public view returns (address) {
    return address(_liquidationPair);
  }
  function prizePool() public view returns (address) {
    return address(_prizePool);
  }
  function claimer() public view returns (address) {
    return _claimer;
  }
  function getHooks(address _account) external view returns (VaultHooks memory) {
    return _hooks[_account];
  }
  function _totalAssets() internal view returns (uint256) {
    return _yieldVault.maxWithdraw(address(this)) + super.totalAssets();
  }
  function _totalSupply() internal view returns (uint256) {
    return _twabController.totalSupply(address(this));
  }
  function _totalShares() internal view returns (uint256) {
    return _totalSupply() + _yieldFeeTotalSupply;
  }
  function _liquidatableBalanceOf(address _token) internal view returns (uint256) {
    if (_token != address(this)) revert LiquidationTokenOutNotVaultShare(_token, address(this));
    uint256 _availableYield = availableYieldBalance();
    unchecked {
      return _availableYield -= _availableYieldFeeBalance(_availableYield);
    }
  }
  function _availableYieldFeeBalance(uint256 _availableYield) internal view returns (uint256) {
    return (_availableYield * _yieldFeePercentage) / FEE_PRECISION;
  }
  function _increaseYieldFeeBalance(uint256 _shares) internal {
    _yieldFeeTotalSupply += _shares;
  }
  function _convertToShares(
    uint256 _assets,
    Math.Rounding _rounding
  ) internal view virtual override returns (uint256) {
    uint256 _exchangeRate = _currentExchangeRate();
    return
      (_assets == 0 || _exchangeRate == 0)
        ? _assets
        : _assets.mulDiv(_assetUnit, _exchangeRate, _rounding);
  }
  function _convertToAssets(
    uint256 _shares,
    Math.Rounding _rounding
  ) internal view virtual override returns (uint256) {
    return _convertToAssets(_shares, _currentExchangeRate(), _rounding);
  }
  function _convertToAssets(
    uint256 _shares,
    uint256 _exchangeRate,
    Math.Rounding _rounding
  ) internal view returns (uint256) {
    return
      (_shares == 0 || _exchangeRate == 0)
        ? _shares
        : _shares.mulDiv(_exchangeRate, _assetUnit, _rounding);
  }
  function _deposit(
    address _caller,
    address _receiver,
    uint256 _assets,
    uint256 _shares
  ) internal virtual override {
    IERC20 _asset = IERC20(asset());
    uint256 _vaultAssets = _asset.balanceOf(address(this));
    if (_assets > _vaultAssets) {
      uint256 _assetsDeposit;
      unchecked {
        if (_vaultAssets != 0) {
          _assetsDeposit = _assets - _vaultAssets;
        }
      }
      SafeERC20.safeTransferFrom(
        _asset,
        _caller,
        address(this),
        _assetsDeposit != 0 ? _assetsDeposit : _assets
      );
    }
    _yieldVault.deposit(_assets, address(this));
    _mint(_receiver, _shares);
    emit Deposit(_caller, _receiver, _assets, _shares);
  }
  function _beforeMint(uint256 _shares, address _receiver) internal view returns (uint256) {
    if (_shares > maxMint(_receiver)) revert MintMoreThanMax(_receiver, _shares, maxMint(_receiver));
    return _convertToAssets(_shares, Math.Rounding.Up);
  }
  function _sponsor(uint256 _assets, address _receiver) internal returns (uint256) {
    uint256 _shares = deposit(_assets, _receiver);
    if (
      _twabController.delegateOf(address(this), _receiver) != _twabController.SPONSORSHIP_ADDRESS()
    ) {
      _twabController.sponsor(_receiver);
    }
    emit Sponsor(msg.sender, _receiver, _assets, _shares);
    return _shares;
  }
  function _withdraw(
    address _caller,
    address _receiver,
    address _owner,
    uint256 _assets,
    uint256 _shares
  ) internal virtual override {
    if (_caller != _owner) {
      _spendAllowance(_owner, _caller, _shares);
    }
    _burn(_owner, _shares);
    _yieldVault.withdraw(_assets, address(this), address(this));
    SafeERC20.safeTransfer(IERC20(asset()), _receiver, _assets);
    emit Withdraw(_caller, _receiver, _owner, _assets, _shares);
  }
  function _claimPrize(
    address _winner,
    uint8 _tier,
    uint32 _prizeIndex,
    uint96 _fee,
    address _feeRecipient
  ) internal returns (uint256) {
    VaultHooks memory hooks = _hooks[_winner];
    address recipient;
    if (hooks.useBeforeClaimPrize) {
      recipient = hooks.implementation.beforeClaimPrize(_winner, _tier, _prizeIndex);
    } else {
      recipient = _winner;
    }
    uint prizeTotal = _prizePool.claimPrize(
      _winner,
      _tier,
      _prizeIndex,
      recipient,
      _fee,
      _feeRecipient
    );
    if (hooks.useAfterClaimPrize) {
      hooks.implementation.afterClaimPrize(
        _winner,
        _tier,
        _prizeIndex,
        prizeTotal - _fee,
        recipient
      );
    }
    return prizeTotal;
  }
  function _permit(
    IERC20Permit _asset,
    address _owner,
    address _spender,
    uint256 _assets,
    uint256 _deadline,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) internal {
    _asset.permit(_owner, _spender, _assets, _deadline, _v, _r, _s);
  }
  function _updateExchangeRate() internal {
    _lastRecordedExchangeRate = _currentExchangeRate();
    emit RecordedExchangeRate(_lastRecordedExchangeRate);
  }
  function _mint(address _receiver, uint256 _shares) internal virtual override {
    _twabController.mint(_receiver, uint96(_shares));
    _updateExchangeRate();
    emit Transfer(address(0), _receiver, _shares);
  }
  function _burn(address _owner, uint256 _shares) internal virtual override {
    _twabController.burn(_owner, uint96(_shares));
    _updateExchangeRate();
    emit Transfer(_owner, address(0), _shares);
  }
  function _transfer(address _from, address _to, uint256 _shares) internal virtual override {
    _twabController.transfer(_from, _to, uint96(_shares));
    emit Transfer(_from, _to, _shares);
  }
  function _currentExchangeRate() internal view returns (uint256) {
    uint256 _totalSupplyAmount = _totalSupply();
    uint256 _totalSupplyToAssets = _convertToAssets(
      _totalSupplyAmount,
      _lastRecordedExchangeRate,
      Math.Rounding.Down
    );
    uint256 _withdrawableAssets = _yieldVault.maxWithdraw(address(this));
    if (_withdrawableAssets > _totalSupplyToAssets) {
      _withdrawableAssets = _withdrawableAssets - (_withdrawableAssets - _totalSupplyToAssets);
    }
    if (_totalSupplyAmount != 0 && _withdrawableAssets != 0) {
      return _withdrawableAssets.mulDiv(_assetUnit, _totalSupplyAmount, Math.Rounding.Down);
    }
    return _assetUnit;
  }
  function _isVaultCollateralized() internal view returns (bool) {
    return _currentExchangeRate() >= _assetUnit;
  }
  function _requireVaultCollateralized() internal view {
    if (!_isVaultCollateralized()) revert VaultUnderCollateralized();
  }
  function _setClaimer(address claimer_) internal {
    _claimer = claimer_;
  }
  function _setYieldFeePercentage(uint256 yieldFeePercentage_) internal {
    if (yieldFeePercentage_ > FEE_PRECISION) {
      revert YieldFeePercentageGTPrecision(yieldFeePercentage_, FEE_PRECISION);
    }
    _yieldFeePercentage = yieldFeePercentage_;
  }
  function _setYieldFeeRecipient(address yieldFeeRecipient_) internal {
    _yieldFeeRecipient = yieldFeeRecipient_;
  }
}