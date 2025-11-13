pragma solidity 0.8.15;
library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);
	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}
	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}
	function logInt(int256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int256)", p0));
	}
	function logUint(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}
	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}
	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}
	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}
	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}
	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}
	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}
	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}
	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}
	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}
	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}
	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}
	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}
	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}
	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}
	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}
	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}
	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}
	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}
	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}
	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}
	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}
	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}
	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}
	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}
	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}
	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}
	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}
	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}
	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}
	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}
	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}
	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}
	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}
	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}
	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}
	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}
	function log(uint256 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256)", p0));
	}
	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}
	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}
	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}
	function log(uint256 p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256)", p0, p1));
	}
	function log(uint256 p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string)", p0, p1));
	}
	function log(uint256 p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool)", p0, p1));
	}
	function log(uint256 p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address)", p0, p1));
	}
	function log(string memory p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256)", p0, p1));
	}
	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}
	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}
	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}
	function log(bool p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256)", p0, p1));
	}
	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}
	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}
	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}
	function log(address p0, uint256 p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256)", p0, p1));
	}
	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}
	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}
	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}
	function log(uint256 p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256)", p0, p1, p2));
	}
	function log(uint256 p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string)", p0, p1, p2));
	}
	function log(uint256 p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool)", p0, p1, p2));
	}
	function log(uint256 p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address)", p0, p1, p2));
	}
	function log(uint256 p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256)", p0, p1, p2));
	}
	function log(uint256 p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string)", p0, p1, p2));
	}
	function log(uint256 p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool)", p0, p1, p2));
	}
	function log(uint256 p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address)", p0, p1, p2));
	}
	function log(uint256 p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256)", p0, p1, p2));
	}
	function log(uint256 p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string)", p0, p1, p2));
	}
	function log(uint256 p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool)", p0, p1, p2));
	}
	function log(uint256 p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address)", p0, p1, p2));
	}
	function log(uint256 p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256)", p0, p1, p2));
	}
	function log(uint256 p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string)", p0, p1, p2));
	}
	function log(uint256 p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool)", p0, p1, p2));
	}
	function log(uint256 p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address)", p0, p1, p2));
	}
	function log(string memory p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256)", p0, p1, p2));
	}
	function log(string memory p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string)", p0, p1, p2));
	}
	function log(string memory p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool)", p0, p1, p2));
	}
	function log(string memory p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address)", p0, p1, p2));
	}
	function log(string memory p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256)", p0, p1, p2));
	}
	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}
	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}
	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}
	function log(string memory p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256)", p0, p1, p2));
	}
	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}
	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}
	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}
	function log(string memory p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256)", p0, p1, p2));
	}
	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}
	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}
	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}
	function log(bool p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256)", p0, p1, p2));
	}
	function log(bool p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string)", p0, p1, p2));
	}
	function log(bool p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool)", p0, p1, p2));
	}
	function log(bool p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address)", p0, p1, p2));
	}
	function log(bool p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256)", p0, p1, p2));
	}
	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}
	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}
	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}
	function log(bool p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256)", p0, p1, p2));
	}
	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}
	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}
	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}
	function log(bool p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256)", p0, p1, p2));
	}
	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}
	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}
	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}
	function log(address p0, uint256 p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256)", p0, p1, p2));
	}
	function log(address p0, uint256 p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string)", p0, p1, p2));
	}
	function log(address p0, uint256 p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool)", p0, p1, p2));
	}
	function log(address p0, uint256 p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address)", p0, p1, p2));
	}
	function log(address p0, string memory p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256)", p0, p1, p2));
	}
	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}
	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}
	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}
	function log(address p0, bool p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256)", p0, p1, p2));
	}
	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}
	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}
	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}
	function log(address p0, address p1, uint256 p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256)", p0, p1, p2));
	}
	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}
	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}
	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}
	function log(uint256 p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,uint256,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,string,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,bool,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,uint256,address,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,uint256,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,string,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,bool,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,string,address,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,uint256,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,string,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,bool,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,bool,address,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,uint256,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,string,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,bool,address)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,uint256)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,string)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,bool)", p0, p1, p2, p3));
	}
	function log(uint256 p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint256,address,address,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,uint256,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,string,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,bool,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint256,address,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint256,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint256,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint256,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint256)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}
	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,string)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,uint256,address)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,string)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,string,address)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,string)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,bool,address)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,string)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint256,address,address)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,string)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint256,address)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,string)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint256,address)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,string)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint256,address)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint256)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}
	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,string)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,bool)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,uint256,address)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,string)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,bool)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,string,address)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,string)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,bool)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,bool,address)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,string)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,bool)", p0, p1, p2, p3));
	}
	function log(address p0, uint256 p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint256,address,address)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,string)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,bool)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint256,address)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}
	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,string)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,bool)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint256,address)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}
	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, uint256 p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, uint256 p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,string)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, uint256 p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,bool)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, uint256 p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint256,address)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, string memory p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, bool p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, address p2, uint256 p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint256)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}
	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}
}
abstract contract TensorpricerInterface {
    bool public constant isTensorpricer = true;
    function mintAllowed(address levToken, address minter) virtual external returns (uint);
    function redeemAllowed(address levToken, address redeemer, uint redeemTokens) virtual external returns (uint);
    function transferAllowed(address levToken, address src, address dst, uint transferTokens) virtual external returns (uint);
    function getFx(string memory fxname) virtual external view returns (uint);
    function _setMintPausedLev(address levToken, bool state) virtual public returns (bool);
    function _setRedeemPausedLev(address levToken, bool state) virtual public returns (bool);
}
abstract contract InterestRateModel {
    bool public constant isInterestRateModel = true;
    function getBorrowRate(uint iur, uint cRatePerBlock) virtual external view returns (uint);
    function getSupplyRate(uint iur, uint cRatePerBlock) virtual external view returns (uint);
}
abstract contract MatrixpricerInterface {
    bool public constant isMatrixpricer = true;
    function mintAllowed(address depToken, address minter) virtual external returns (uint);
    function redeemAllowed(address depToken, address redeemer, uint redeemTokens) virtual external returns (uint);
    function borrowAllowed(address depToken, address borrower) virtual external returns (uint);
    function repayBorrowAllowed(
        address depToken,
        address borrower) virtual external returns (uint);
    function transferAllowed(address depToken, address src, address dst, uint transferTokens) virtual external returns (uint);
}
interface EIP20NonStandardInterface {
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address dst, uint256 amount) external;
    function transferFrom(address src, address dst, uint256 amount) external;
    function approve(address spender, uint256 amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
contract managerErrorReporter {
    enum Error {
        NO_ERROR,
        UNAUTHORIZED,
        MATRIXPRICER_MISMATCH,
        INSUFFICIENT_SHORTFALL,
        INSUFFICIENT_LIQUIDITY,
        INVALID_CLOSE_FACTOR,
        INVALID_COLLATERAL_FACTOR,
        INVALID_LIQUIDATION_INCENTIVE,
        MARKET_NOT_ENTERED, 
        MARKET_NOT_LISTED,
        MARKET_ALREADY_LISTED,
        MATH_ERROR,
        NONZERO_BORROW_BALANCE,
        PRICE_ERROR,
        REJECTION,
        SNAPSHOT_ERROR,
        TOO_MANY_ASSETS,
        TOO_MUCH_REPAY
    }
    enum FailureInfo {
        ACCEPT_ADMIN_PENDING_ADMIN_CHECK,
        ACCEPT_PENDING_IMPLEMENTATION_ADDRESS_CHECK,
        EXIT_MARKET_BALANCE_OWED,
        EXIT_MARKET_REJECTION,
        SET_CLOSE_FACTOR_OWNER_CHECK,
        SET_CLOSE_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_OWNER_CHECK,
        SET_COLLATERAL_FACTOR_NO_EXISTS,
        SET_COLLATERAL_FACTOR_VALIDATION,
        SET_COLLATERAL_FACTOR_WITHOUT_PRICE,
        SET_IMPLEMENTATION_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_OWNER_CHECK,
        SET_LIQUIDATION_INCENTIVE_VALIDATION,
        SET_MAX_ASSETS_OWNER_CHECK,
        SET_PAUSE_GUARDIAN_OWNER_CHECK,
        SET_PENDING_ADMIN_OWNER_CHECK,
        SET_PENDING_IMPLEMENTATION_OWNER_CHECK,
        SET_PRICE_ORACLE_OWNER_CHECK,
        SUPPORT_MARKET_EXISTS,
        SUPPORT_MARKET_OWNER_CHECK
    }
    event Failure(uint error, uint info, uint detail);
    function fail(Error err, FailureInfo info) internal returns (uint) {
        emit Failure(uint(err), uint(info), 0);
        return uint(err);
    }
    function failOpaque(Error err, FailureInfo info, uint opaqueError) internal returns (uint) {
        emit Failure(uint(err), uint(info), opaqueError);
        return uint(err);
    }
}
contract TokenErrorReporter {
    uint public constant NO_ERROR = 0; 
    error TransferMatrixpricerRejection(uint256 errorCode);
    error TransferTensorpricerRejection(uint256 errorCode);
    error TransferNotAllowed();
    error TransferNotEnough();
    error TransferNotEnoughAllowance();
    error TransferTooMuch();
    error MintMatrixpricerRejection(uint256 errorCode);
    error MintTensorpricerRejection(uint256 errorCode);
    error MintFreshnessCheck();
    error RedeemMatrixpricerRejection(uint256 errorCode);
    error RedeemTensorpricerRejection(uint256 errorCode);
    error RedeemFreshnessCheck();
    error RedeemTransferOutNotPossible();
    error BorrowMatrixpricerRejection(uint256 errorCode);
    error BorrowFreshnessCheck();
    error BorrowCashNotAvailable();
    error RepayBorrowMatrixpricerRejection(uint256 errorCode);
    error RepayBorrowFreshnessCheck();
    error LiquidateMatrixpricerRejection(uint256 errorCode);
    error LiquidateFreshnessCheck();
    error LiquidateCollateralFreshnessCheck();
    error LiquidateAccrueBorrowInterestFailed(uint256 errorCode);
    error LiquidateAccrueCollateralInterestFailed(uint256 errorCode);
    error LiquidateLiquidatorIsBorrower();
    error LiquidateCloseAmountIsZero();
    error LiquidateCloseAmountIsUintMax();
    error LiquidateRepayBorrowFreshFailed(uint256 errorCode);
    error LiquidateSeizeMatrixpricerRejection(uint256 errorCode);
    error LiquidateSeizeLiquidatorIsBorrower();
    error AcceptAdminPendingAdminCheck();
    error SetMatrixpricerOwnerCheck();
    error SetTensorpricerOwnerCheck();
    error SetPendingAdminOwnerCheck();
    error SetReserveFactorAdminCheck();
    error SetReserveFactorFreshCheck();
    error SetReserveFactorBoundsCheck();
    error AddReservesFactorFreshCheck(uint256 actualAddAmount);
    error ReduceReservesAdminCheck();
    error ReduceReservesFreshCheck();
    error ReduceReservesCashNotAvailable();
    error ReduceReservesCashValidation();
    error SetInterestRateModelOwnerCheck();
    error SetInterestRateModelFreshCheck();
}
contract DepTokenStorage {
    bool internal _notEntered;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint internal constant reserveFactorMaxMantissa = 1e18;
    address payable public admin;
    address payable public pendingAdmin;
    MatrixpricerInterface public matrixpricer;
    InterestRateModel public interestRateModel;
    LevErc20Interface public levErc20;
    uint internal initialExchangeRateMantissa;  
    uint public reserveFactorMantissa;  
    uint public accrualBlockNumber;
    uint public borrowIndex;
    uint public totalBorrows;   
    uint public totalReserves;   
    uint public totalSupply;    
    mapping (address => uint) internal accountTokens;
    mapping (address => mapping (address => uint)) internal transferAllowances;
    uint internal constant minTransferAmtUSDT = 50000e6;
    uint internal constant thresholdUSDT = 300000e6;
    uint internal constant extraUSDT = 100000e6;
    struct BorrowSnapshot {
        uint principal;
        uint interestIndex;
    }
    mapping(address => BorrowSnapshot) internal accountBorrows;
    uint public constant protocolSeizeShareMantissa = 2.8e16; 
}
abstract contract DepTokenInterface is DepTokenStorage {
    bool public constant isDepToken = true;
    event AccrueInterest(uint cashPrior, uint interestAccumulated, uint borrowIndex, uint totalBorrows);
    event Mint(address minter, uint mintAmount, uint mintTokens, uint apy);
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens, uint apy);
    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);
    event RepayBorrow(address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows, bool liquidate);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewMatrixpricer(MatrixpricerInterface oldMatrixpricer, MatrixpricerInterface newMatrixpricer);
    event NewReserveFactor(uint oldReserveFactorMantissa, uint newReserveFactorMantissa);
    event ReservesAdded(address benefactor, uint addAmount, uint newTotalReserves);
    event ReservesReduced(address admin, uint reduceAmount, uint newTotalReserves);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    function transfer(address dst, uint amount) virtual external returns (bool);
    function transferFrom(address src, address dst, uint amount) virtual external returns (bool);
    function approve(address spender, uint amount) virtual external returns (bool);
    function allowance(address owner, address spender) virtual external view returns (uint);
    function balanceOf(address owner) virtual external view returns (uint);
    function balanceOfUnderlying(address owner) virtual external returns (uint);
    function balanceOfUnderlyingView(address owner) virtual external view returns (uint);
    function getAccountSnapshot(address account) virtual external view returns (uint, uint, uint, uint);
    function borrowRatePerBlock() virtual external view returns (uint);
    function supplyRatePerBlock() virtual public view returns (uint);
    function totalBorrowsCurrent() virtual external returns (uint);
    function exchangeRateCurrent() virtual external returns (uint);
    function exchangeRateStored() virtual external view returns (uint);
    function getCash() virtual external view returns (uint);
    function getCompoundBalance() virtual external view returns (uint);
    function accrueInterest() virtual external returns (uint);
    function _setPendingAdmin(address payable newPendingAdmin) virtual external returns (uint);
    function _acceptAdmin() virtual external returns (uint);
    function _setMatrixpricer(MatrixpricerInterface newMatrixpricer) virtual external returns (uint);
    function _setReserveFactor(uint newReserveFactorMantissa) virtual external returns (uint);
    function _reduceReserves(uint reduceAmount) virtual external returns (uint);
    function _setInterestRateModel(InterestRateModel newInterestRateModel) virtual external returns (uint);
}
contract DepErc20Storage {
    address public underlying;
}
abstract contract DepErc20Interface is DepErc20Storage {
    function mint(uint mintAmount) virtual external returns (uint);
    function redeem(uint redeemTokens, uint redeemAmount) virtual external returns (uint);
    function borrow(uint borrowAmount) virtual external returns (uint);
    function repayBorrow(uint repayAmount, bool liquidate) virtual external returns (uint);
    function getUnborrowedUSDTBalance() virtual external view returns (uint);
    function getTotalBorrows() virtual external view returns (uint);    
    function getTotalBorrowsAfterAccrueInterest() virtual external returns (uint);    
    function _addReserves(uint addAmount) virtual external returns (uint);
}
interface ICompoundV2 {
    function mint(uint mintAmount) external returns (uint);
    function redeem(uint redeemTokens) external returns (uint);
    function redeemUnderlying(uint redeemAmount) external returns (uint);
    function balanceOf(address owner) external view returns (uint256);
    function borrowRatePerBlock() external view returns (uint);
    function supplyRatePerBlock() external view returns (uint);
    function exchangeRateStored() external view returns (uint);
}
interface INNERIERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
}
interface DepositWithdrawInterface {
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
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
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
contract DepositWithdraw is DepositWithdrawInterface {
    using SafeERC20 for IERC20;
    address internal compoundV2cUSDCAddress;
    address internal compoundV2cUSDTAddress;
    address internal USDCAddress;
    address internal USDTAddress;
    function setAddresses(address compoundV2cUSDCAddress_, address compoundV2cUSDTAddress_, address USDCAddress_, address USDTAddress_) internal {
        compoundV2cUSDCAddress = compoundV2cUSDCAddress_;
        compoundV2cUSDTAddress = compoundV2cUSDTAddress_;
        USDCAddress = USDCAddress_;
        USDTAddress = USDTAddress_;
    }
    function getCUSDTNumber() internal view returns (uint) {
        uint value = ICompoundV2(compoundV2cUSDTAddress).balanceOf(address(this));
        return value;
    }
    function getCmpUSDTExchRate() public virtual view returns (uint) {
        uint value = ICompoundV2(compoundV2cUSDTAddress).exchangeRateStored();
        return value;
    }
    function getCUSDCNumber() internal view returns (uint) {
        uint value = ICompoundV2(compoundV2cUSDCAddress).balanceOf(address(this));
        return value;
    }
    function getCmpUSDCExchRate() internal view returns (uint) {
        uint value = ICompoundV2(compoundV2cUSDCAddress).exchangeRateStored();
        return value;
    }
    function getCmpUSDTSupplyRate() virtual public view returns (uint) {
        return ICompoundV2(compoundV2cUSDTAddress).supplyRatePerBlock();
    }
    function supplyUSDC(uint amount) internal {
        IERC20(USDCAddress).safeApprove(compoundV2cUSDCAddress, amount);
        ICompoundV2(compoundV2cUSDCAddress).mint(amount);
    }
    function withdrawcUSDC(uint amount) internal {
        ICompoundV2(compoundV2cUSDCAddress).redeem(amount);
    }
    function withdrawUSDCfromCmp(uint amount) internal {
        ICompoundV2(compoundV2cUSDCAddress).redeemUnderlying(amount);
    }   
    function supplyUSDT2Cmp(uint amount) internal {
        IERC20(USDTAddress).safeApprove(compoundV2cUSDTAddress, amount);
        ICompoundV2(compoundV2cUSDTAddress).mint(amount);
    }
    function withdrawcUSDT(uint amount) internal {
        ICompoundV2(compoundV2cUSDTAddress).redeem(amount);
    }   
    function withdrawUSDTfromCmp(uint amount) internal {
        ICompoundV2(compoundV2cUSDTAddress).redeemUnderlying(amount);
    }    
}
interface ICurveFi {
    function exchange_underlying(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
    function exchange(int128 i, int128 j, uint256 dx, uint256 min_dy) external;
}
interface IRegistry {
    function get_decimals(address pool) external view returns (uint[8] memory);
    function exchange(address _pool, address _from, address _to, uint _amound, uint _expected, address _receiver) external returns (uint);
    function get_exchange_amount(address _pool, address _from, address _to, uint _amount) external view returns (uint);
}
interface IAddressProvider {
    function get_registry() external view;
    function get_address(uint id) external view returns (address);
}
interface CurveContractInterface {
}
contract CurveSwap is CurveContractInterface{
    using SafeERC20 for IERC20;
    address public TriPool;
    address public ADDRESSPROVIDER;
    address public USDC_ADDRESS;
    address public USDT_ADDRESS;
    function setAddressesCurve(address TriPool_, address ADDRESSPROVIDER_, address USDC_ADDRESS_, address USDT_ADDRESS_) internal {
        TriPool = TriPool_;
        ADDRESSPROVIDER = ADDRESSPROVIDER_;
        USDC_ADDRESS = USDC_ADDRESS_;
        USDT_ADDRESS = USDT_ADDRESS_;
    }
    function QueryAddressProvider(uint id) internal view returns (address) {
        return IAddressProvider(ADDRESSPROVIDER).get_address(id);
    }
    function PerformExchange(address _from, address _to, uint _amount, uint _expected, address _receiver) internal returns (uint256) {
        address Registry = QueryAddressProvider(2);
        uint receToken = IRegistry(Registry).exchange(TriPool, _from, _to, _amount, _expected, _receiver);
        return receToken;
    }
    function changeUSDT2USDC(uint _amount, uint _expected, address _receiver) virtual internal returns (uint256) {
        address Registry = QueryAddressProvider(2);
        approveToken(USDT_ADDRESS, Registry, _amount);
        uint receToken = IRegistry(Registry).exchange(TriPool, USDT_ADDRESS, USDC_ADDRESS, _amount, _expected, _receiver);
        return receToken;
    }
    function changeUSDC2USDT(uint _amount, uint _expected, address _receiver) internal returns (uint256) {
        address Registry = QueryAddressProvider(2);
        approveToken(USDC_ADDRESS, Registry, _amount);
        uint receToken = IRegistry(Registry).exchange(TriPool, USDC_ADDRESS, USDT_ADDRESS, _amount, _expected, _receiver);
        return receToken;
    }
    function approveToken(address token, address spender, uint _amount) public returns (bool) {
        IERC20(token).safeApprove(spender, _amount);
        return true;
    }
}
contract LevTokenStorage {
    bool internal _notEntered;
    string public name;
    string public symbol;
    uint8 public decimals;
    address payable public admin;
    address payable public pendingAdmin;
    TensorpricerInterface public tensorpricer;
    DepErc20Interface public depErc20;
    uint internal constant initialNetAssetValueMantissa = 1e18;  
    uint internal constant initialTargetLevRatio = 5e18;
    uint public totalSupply;    
    uint public borrowBalanceUSDT;  
    uint public borrowBalanceUSDC;  
    uint public totalAssetValue;  
    uint public netAssetValue;  
    uint public levRatio;   
    uint public extraBorrowDemand;  
    uint public extraBorrowSupply;  
    uint public targetLevRatio; 
    mapping (address => uint) internal accountTokens;
    mapping (address => mapping (address => uint)) internal transferAllowances;
    uint internal constant minTransferAmtUSDC = 50000e6;
    uint internal constant thresholdUSDC = 300000e6;
    uint internal constant extraUSDC = 100000e6;
    struct checkRebalanceRes {
        uint res;
        uint targetLevRatio;
        uint tmpBorrowBalanceUSDC;
        uint tmpTotalAssetValue;
        uint tmpLevRatio;
    }
    uint internal hisHighNav;
    uint internal levReserve;   
    uint internal constant redeemFeePC = 1e15;
    uint internal constant perfPC = 1e17;
    uint internal redeemAmountInUSDC;
}
abstract contract LevTokenInterface is LevTokenStorage {
    bool public constant isLevToken = true;
    event Mint(address minter, uint mintAmount, uint mintTokens, uint nav);
    event Redeem(address redeemer, uint redeemAmount, uint redeemTokens, uint nav);
    event ForceRepay(address forcer, uint repayAmount);
    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);
    event NewAdmin(address oldAdmin, address newAdmin);
    event NewTensorpricer(TensorpricerInterface oldTensorpricer, TensorpricerInterface newTensorpricer);
    event Transfer(address indexed from, address indexed to, uint amount);
    event Approval(address indexed owner, address indexed spender, uint amount);
    event ReservesReduced(address admin, uint reduceAmount, uint newLevReserve);
    function transfer(address dst, uint amount) virtual external returns (bool);
    function transferFrom(address src, address dst, uint amount) virtual external returns (bool);
    function approve(address spender, uint amount) virtual external returns (bool);
    function allowance(address owner, address spender) virtual external view returns (uint);
    function balanceOf(address owner) virtual external view returns (uint);
    function getNAV(address owner) virtual external view returns (uint);
    function getAccountSnapshot(address account) virtual external view returns (uint, uint);
    function getCash() virtual external view returns (uint);
    function getCompoundBalance() virtual external view returns (uint);
    function getLevReserve() virtual external view returns (uint);
    function getHisHighNav() virtual external view returns (uint);
    function _setPendingAdmin(address payable newPendingAdmin) virtual external returns (uint);
    function _acceptAdmin() virtual external returns (uint);
    function _setTensorpricer(TensorpricerInterface newTensorpricer) virtual external returns (uint);
    function _reduceReserves(uint reduceAmount) virtual external returns (uint);
}
contract LevErc20Storage {
    address public underlying;  
    address public borrowUnderlying;    
}
abstract contract LevErc20Interface is LevErc20Storage {
    function getAdmin() virtual external returns (address payable);
    function mint(uint mintAmount) virtual external returns (uint);
    function redeem(uint redeemTokens) virtual external returns (uint);
    function sweepToken(EIP20NonStandardInterface token) virtual external;
    function getExtraBorrowDemand() virtual external view returns (uint256);
    function getExtraBorrowSupply() virtual external view returns (uint256);
    function forceRepay(uint256 repayAmount) virtual external returns (uint);
    function updateLedger() virtual external;
}
interface EIP20Interface {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address owner) external view returns (uint256 balance);
    function transfer(address dst, uint256 amount) external returns (bool success);
    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);
    function approve(address spender, uint256 amount) external returns (bool success);
    function allowance(address owner, address spender) external view returns (uint256 remaining);
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}
contract ExponentialNoError {
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale/2;
    uint constant mantissaOne = expScale;
    struct Exp {
        uint mantissa;
    }
    struct Double {
        uint mantissa;
    }
    function truncate(Exp memory exp) pure internal returns (uint) {
        return exp.mantissa / expScale;
    }
    function mul_ScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return truncate(product);
    }
    function mul_ScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {
        Exp memory product = mul_(a, scalar);
        return add_(truncate(product), addend);
    }
    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa < right.mantissa;
    }
    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa <= right.mantissa;
    }
    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {
        return left.mantissa > right.mantissa;
    }
    function isZeroExp(Exp memory value) pure internal returns (bool) {
        return value.mantissa == 0;
    }
    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {
        require(n < 2**224, errorMessage);
        return uint224(n);
    }
    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {
        require(n < 2**32, errorMessage);
        return uint32(n);
    }
    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: add_(a.mantissa, b.mantissa)});
    }
    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: add_(a.mantissa, b.mantissa)});
    }
    function add_(uint a, uint b) pure internal returns (uint) {
        return a + b;
    }
    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: sub_(a.mantissa, b.mantissa)});
    }
    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: sub_(a.mantissa, b.mantissa)});
    }
    function sub_(uint a, uint b) pure internal returns (uint) {
        return a - b;
    }
    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b.mantissa) / expScale});
    }
    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: mul_(a.mantissa, b)});
    }
    function mul_(uint a, Exp memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / expScale;
    }
    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b.mantissa) / doubleScale});
    }
    function mul_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: mul_(a.mantissa, b)});
    }
    function mul_(uint a, Double memory b) pure internal returns (uint) {
        return mul_(a, b.mantissa) / doubleScale;
    }
    function mul_(uint a, uint b) pure internal returns (uint) {
        return a * b;
    }
    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(mul_(a.mantissa, expScale), b.mantissa)});
    }
    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {
        return Exp({mantissa: div_(a.mantissa, b)});
    }
    function div_(uint a, Exp memory b) pure internal returns (uint) {
        return div_(mul_(a, expScale), b.mantissa);
    }
    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }
    function div_(Double memory a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(a.mantissa, b)});
    }
    function div_(uint a, Double memory b) pure internal returns (uint) {
        return div_(mul_(a, doubleScale), b.mantissa);
    }
    function div_(uint a, uint b) pure internal returns (uint) {
        return a / b;
    }
    function fraction(uint a, uint b) pure internal returns (Double memory) {
        return Double({mantissa: div_(mul_(a, doubleScale), b)});
    }
}
library AddressUpgradeable {
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
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
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
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
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
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
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
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
    function _isInitializing() internal view returns (bool) {
        return _initializing;
    }
}
abstract contract LevToken is LevTokenInterface, DepositWithdraw, CurveSwap, ExponentialNoError, TokenErrorReporter, Initializable {
    function setDepErc20(DepErc20Interface depErc20_) public virtual{
        require(msg.sender == admin, "only admin may set depErc20");
        depErc20 = depErc20_;
    }
    function initialize(address underlying_,
                        address borrowUnderlying_,
                        TensorpricerInterface tensorpricer_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_) public virtual onlyInitializing {
        require(msg.sender == admin, "only admin may initialize the market");
        uint err = _setTensorpricer(tensorpricer_);
        require(err == NO_ERROR, "setting tensorpricer failed");
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        _notEntered = true;
    }
    function setAddressesForCompound(address compoundV2cUSDCAddress_, address compoundV2cUSDTAddress_, address USDCAddress_, address USDTAddress_) public {
        require(msg.sender==admin, "only admin can set addresses in general");
        setAddresses(compoundV2cUSDCAddress_, compoundV2cUSDTAddress_, USDCAddress_, USDTAddress_);
    }
    function setAddressesForCurve(address TriPool_, address ADDRESSPROVIDER_, address USDC_ADDRESS_, address USDT_ADDRESS_) public {
        require(msg.sender==admin, "only admin can set addresses in general");
        setAddressesCurve(TriPool_, ADDRESSPROVIDER_, USDC_ADDRESS_, USDT_ADDRESS_);
    }
    function transferTokens(address spender, address src, address dst, uint tokens) internal returns (uint) {
        uint allowed = tensorpricer.transferAllowed(address(this), src, dst, tokens);
        if (allowed != 0) {
            revert TransferTensorpricerRejection(allowed);   
        }
        if (src == dst) {
            revert TransferNotAllowed();
        }
        uint startingAllowance = 0;
        if (spender == src) {
            startingAllowance = type(uint).max;
        } else {
            startingAllowance = transferAllowances[src][spender];
            if(startingAllowance < tokens){
                revert TransferNotEnoughAllowance();
            }
        }
        uint allowanceNew = startingAllowance - tokens;
        uint srLevTokensNew = accountTokens[src] - tokens;
        uint dstTokensNew = accountTokens[dst] + tokens;
        accountTokens[src] = srLevTokensNew;
        accountTokens[dst] = dstTokensNew;
        if (startingAllowance != type(uint).max) {
            transferAllowances[src][spender] = allowanceNew;
        }
        emit Transfer(src, dst, tokens);
        return NO_ERROR;
    }
    function transfer(address dst, uint256 amount) override external nonReentrant returns (bool) {
        return transferTokens(msg.sender, msg.sender, dst, amount) == NO_ERROR;
    }
    function transferFrom(address src, address dst, uint256 amount) override external nonReentrant returns (bool) {
        return transferTokens(msg.sender, src, dst, amount) == NO_ERROR;
    }
    function approve(address spender, uint256 amount) override external returns (bool) {
        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }
    function allowance(address owner, address spender) override external view returns (uint256) {
        return transferAllowances[owner][spender];
    }
    function balanceOf(address owner) override external view returns (uint256) {
        return accountTokens[owner];
    }
    function getNAV(address owner) override external view returns (uint) {
        Exp memory nav = Exp({mantissa: netAssetValue});
        return mul_ScalarTruncate(nav, accountTokens[owner]);
    }
    function getAccountSnapshot(address account) override external view returns (uint, uint) {
        return (
            NO_ERROR,
            accountTokens[account]
        );
    }
    function getCash() override external view returns (uint) {
        return getCashPrior();
    }
    function getCompoundBalance() override external view returns (uint) {
        return getCmpBalanceInternal();
    }
    function getCmpBalanceInternal() internal view returns (uint) {
        Exp memory exchangeRate = Exp({mantissa: getCmpUSDCExchRate()});
        return mul_ScalarTruncate(exchangeRate, getCUSDCNumber());
    }
    function getLevReserve() override external view returns (uint) {
        return levReserve;
    }
    function getHisHighNav() override external view returns (uint) {
        return hisHighNav;
    }
    function updateNetAssetValue(uint latestBorrowBalanceUSDC, uint offset) internal {
        netAssetValue = calcNetAssetValue(latestBorrowBalanceUSDC, offset);
    }
    function calcNetAssetValue(uint latestBorrowBalanceUSDC, uint offset) internal view returns (uint){
        uint _totalSupply = totalSupply;
        if (_totalSupply == 0) {
            return initialNetAssetValueMantissa;
        } else {
            uint balanceUSDCExReserves = getCashExReserves() + getCmpBalanceInternal();
            if(balanceUSDCExReserves > latestBorrowBalanceUSDC + offset){
                return (balanceUSDCExReserves - latestBorrowBalanceUSDC - offset) * expScale / _totalSupply;
            }else{
                return 0;
            }
        }
    }
    function updateStats(bool recalc, uint tmpTotalAssetValue, uint tmpLevRatio, uint redeemTokensIn) internal {
        if(recalc){
            uint availCash = getCashExReserves() + getCmpBalanceInternal();
            if(redeemTokensIn > 0){
                uint currTotalAssetValue;
                uint amtToSubtract;
                if(availCash > borrowBalanceUSDC){
                    currTotalAssetValue = availCash - borrowBalanceUSDC;
                    uint currNav = currTotalAssetValue * expScale / totalSupply;
                    redeemAmountInUSDC = currNav * redeemTokensIn / expScale;
                    amtToSubtract = borrowBalanceUSDC + redeemAmountInUSDC;
                }else{
                    currTotalAssetValue = 0;
                    amtToSubtract = borrowBalanceUSDC;
                }
                if(availCash > amtToSubtract){
                    totalAssetValue = availCash - amtToSubtract;
                    levRatio = borrowBalanceUSDC*expScale / totalAssetValue;
                }else{
                    totalAssetValue = 0;
                    levRatio = 0;
                }
            }else{
                uint amtToSubtract = borrowBalanceUSDC;
                if(availCash > amtToSubtract){
                    totalAssetValue = availCash - amtToSubtract;
                    levRatio = borrowBalanceUSDC*expScale / totalAssetValue;
                }else{
                    totalAssetValue = 0;
                    levRatio = 0;
                }
            }
        }else{
            if(redeemTokensIn > 0){
                uint availCash = getCashExReserves() + getCmpBalanceInternal();
                uint currNav = tmpTotalAssetValue * expScale / (totalSupply - redeemTokensIn);
                redeemAmountInUSDC = currNav * redeemTokensIn / expScale;
                uint amtToSubtract = borrowBalanceUSDC + redeemAmountInUSDC;
                if(availCash > amtToSubtract){
                    totalAssetValue = availCash - amtToSubtract;
                    levRatio = borrowBalanceUSDC*expScale / totalAssetValue;
                }else{
                    totalAssetValue = 0;
                    levRatio = 0;
                }
            }else{  
                totalAssetValue = tmpTotalAssetValue;
                levRatio = tmpLevRatio; 
            }
        }
    }
    function refreshTargetLevRatio(uint fx_USDTUSDC_Mantissa) public pure returns (uint, uint, uint) {
        if(fx_USDTUSDC_Mantissa < 6e17 || fx_USDTUSDC_Mantissa > 14e17){
            return (1e18, 0, 2e18);
        }else if(fx_USDTUSDC_Mantissa < 9e17 || fx_USDTUSDC_Mantissa > 11e17){
            return (3e18, 2e18, 4e18);
        }else{
            return (5e18, 4e18, 6e18);
        }
    }
    function updateExtraBorrow(Exp memory fx_USDTUSDC, uint tmpTotalAssetValue, uint targetLevRatio) internal {
        uint targetBorrowUSDT = div_(targetLevRatio*tmpTotalAssetValue/expScale, fx_USDTUSDC);
        if(targetBorrowUSDT > borrowBalanceUSDT){
            extraBorrowDemand = targetBorrowUSDT - borrowBalanceUSDT;
            extraBorrowSupply = 0;
        }else{
            extraBorrowDemand = 0;
            extraBorrowSupply = borrowBalanceUSDT - targetBorrowUSDT;
        }
    }
    function updateBorrowBalances(uint fxToUse, uint newBorrowBalanceUSDT) internal {
        borrowBalanceUSDT = newBorrowBalanceUSDT;
        borrowBalanceUSDC = newBorrowBalanceUSDT * fxToUse / expScale;
    }
    function releverage(uint newBorrowDemand) internal {
        uint transFx = depErc20.borrow(newBorrowDemand);
        updateBorrowBalances(transFx, depErc20.getTotalBorrows());  
    }
    function deleverage(Exp memory fx_USDTUSDC, uint newBorrowSupply, bool isRedeemAll) internal returns (bool) {
        uint amtUSDC = mul_(newBorrowSupply, fx_USDTUSDC);
        if(isRedeemAll){
            amtUSDC = amtUSDC * 105 / 100;  
            withdrawUSDCfromCmp(getCmpBalanceInternal());  
        }else{
            uint cashOnBook = getCashExReserves();
            if(amtUSDC > cashOnBook){   
                uint amtUSDCmissing = amtUSDC - cashOnBook;
                uint compoundBalance = getCmpBalanceInternal();
                if(compoundBalance > (amtUSDCmissing + extraUSDC)){
                    withdrawUSDCfromCmp(amtUSDCmissing + extraUSDC);
                }else{
                    withdrawUSDCfromCmp(compoundBalance);  
                }
            }
        }
        uint latestCashOnBook = getCashExReserves();
        uint finalRepayAmount;
        if(latestCashOnBook >= amtUSDC){ 
            finalRepayAmount = changeUSDC2USDT(amtUSDC, 0, address(depErc20));
            uint transFx = amtUSDC * expScale / finalRepayAmount;
            depErc20.repayBorrow(finalRepayAmount, false);
            updateBorrowBalances(transFx, depErc20.getTotalBorrows());  
        }else{
            finalRepayAmount = changeUSDC2USDT(latestCashOnBook, 0, address(depErc20)); 
            uint transFx = latestCashOnBook * expScale / finalRepayAmount;
            if(isRedeemAll){
                uint depTotalBorrows = depErc20.getTotalBorrows();
                if(depTotalBorrows > finalRepayAmount){ 
                    updateBorrowBalances(transFx, depTotalBorrows - finalRepayAmount);
                }else{
                    updateBorrowBalances(transFx, 0); 
                }
                depErc20.repayBorrow(finalRepayAmount, true);
                return true;    
            }else{
                depErc20.repayBorrow(finalRepayAmount, false);
                updateBorrowBalances(transFx, depErc20.getTotalBorrows());  
            }
        }
        return false;
    }
    function deleverageAll() internal returns (bool) {
        uint cashOnBook = getCashExReserves();
        uint compoundBalance = getCmpBalanceInternal();
        if(compoundBalance > 0) {
            withdrawUSDCfromCmp(compoundBalance);  
        }
        cashOnBook = getCashExReserves();   
        if(cashOnBook > 0){
            uint finalRepayAmount = changeUSDC2USDT(cashOnBook, 0, address(depErc20));
            uint transFx = cashOnBook * expScale / finalRepayAmount;
            uint origBorrowBalanceUSDT = depErc20.getTotalBorrowsAfterAccrueInterest();    
            extraBorrowDemand = 0;
            extraBorrowSupply = 0;
            if(origBorrowBalanceUSDT > finalRepayAmount){
                updateBorrowBalances(transFx, origBorrowBalanceUSDT - finalRepayAmount);  
                depErc20.repayBorrow(finalRepayAmount, true);
                updateStats(false, 0, 0, 0);
                tensorpricer._setMintPausedLev(address(this), true);
                tensorpricer._setRedeemPausedLev(address(this), true);
            }else{  
                updateBorrowBalances(transFx, 0);
                depErc20.repayBorrow(finalRepayAmount, false);
                updateStats(true, 0, 0, 0);
                return false;
            }
        }
        return true;
    }
    function checkRebalanceExt() external view returns (checkRebalanceRes memory) {
        return checkRebalance(2, 0);
    }
    function checkRebalance(uint callingSrc, uint tmpRedeemAmountInUSDC) internal view returns (checkRebalanceRes memory) {
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        (uint targetLevRatio, uint releverageTrigger, uint deleverageTrigger) = refreshTargetLevRatio(fx_USDTUSDC_Mantissa);
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        if(callingSrc==0){   
            uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
            uint tmpBalanceUSDC = getCashExReserves() + getCmpBalanceInternal();
            if(tmpBalanceUSDC > tmpBorrowBalanceUSDC){
                uint tmpTotalAssetValue = tmpBalanceUSDC - tmpBorrowBalanceUSDC;
                uint tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
                if(tmpLevRatio < releverageTrigger){    
                    return checkRebalanceRes({res:1, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                }else if(tmpLevRatio > deleverageTrigger){
                    return checkRebalanceRes({res:2, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                }else{  
                    return checkRebalanceRes({res:0, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                }
            }else{
                return checkRebalanceRes({res:3, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:0, tmpLevRatio:0});
            }
        }else if (callingSrc==1){  
            if(totalSupply > 0){
                uint tmpBalanceUSDC = getCashExReserves() + getCmpBalanceInternal() - tmpRedeemAmountInUSDC;
                uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
                if(tmpBalanceUSDC > tmpBorrowBalanceUSDC){
                    uint tmpTotalAssetValue = tmpBalanceUSDC - tmpBorrowBalanceUSDC;
                    uint tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
                    if(tmpLevRatio > deleverageTrigger){ 
                        return checkRebalanceRes({res:2, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else if(tmpLevRatio < releverageTrigger){
                        return checkRebalanceRes({res:1, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else{  
                        return checkRebalanceRes({res:0, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }
                }else{
                    return checkRebalanceRes({res:3, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:0, tmpLevRatio:0});
                }
            }else{
                return checkRebalanceRes({res:0, targetLevRatio:0, tmpBorrowBalanceUSDC:0, tmpTotalAssetValue:0, tmpLevRatio:0});
            }
        }else{  
            if(totalSupply > 0){
                uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
                uint tmpBalanceUSDC = getCashExReserves() + getCmpBalanceInternal();
                if(tmpBalanceUSDC > tmpBorrowBalanceUSDC){
                    uint tmpTotalAssetValue = tmpBalanceUSDC - tmpBorrowBalanceUSDC;
                    uint tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
                    if(tmpLevRatio < releverageTrigger){    
                        return checkRebalanceRes({res:1, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else if(tmpLevRatio > deleverageTrigger){ 
                        return checkRebalanceRes({res:2, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }else{
                        return checkRebalanceRes({res:0, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:tmpTotalAssetValue, tmpLevRatio:tmpLevRatio});
                    }
                }else{
                    return checkRebalanceRes({res:3, targetLevRatio:targetLevRatio, tmpBorrowBalanceUSDC:tmpBorrowBalanceUSDC, tmpTotalAssetValue:0, tmpLevRatio:0});
                }
            }else{
                return checkRebalanceRes({res:0, targetLevRatio:0, tmpBorrowBalanceUSDC:0, tmpTotalAssetValue:0, tmpLevRatio:0});
            }
        }
    }
    function doRebalanceExt() public {
        checkRebalanceRes memory myRes = checkRebalance(2, 0);
        doRebalance(2, myRes, 0);
    }
    function doRebalance(uint callingSrc, checkRebalanceRes memory myRes, uint redeemTokensIn) internal {
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        targetLevRatio = myRes.targetLevRatio;  
        if(myRes.res == 3){ 
            if(deleverageAll()){
                netAssetValue = 0;
            }else{
                updateNetAssetValue(borrowBalanceUSDC, 0);
            }
        }else{
            if(callingSrc==0){   
                if(myRes.res==1){    
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowDemand > 0) {
                        releverage(extraBorrowDemand);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, 0);
                }else if(myRes.res==2){
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowSupply > 0){
                        deleverage(fx_USDTUSDC, extraBorrowSupply, false);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, 0);
                }else if(myRes.res==0){  
                    borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    updateStats(false, myRes.tmpTotalAssetValue, myRes.tmpLevRatio, 0);
                    extraBorrowDemand = 0;
                    extraBorrowSupply = 0;
                }
            }else if (callingSrc==1){  
                if(myRes.res==2){ 
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowSupply > 0){
                        deleverage(fx_USDTUSDC, extraBorrowSupply, false);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, redeemTokensIn);
                }else if(myRes.res==1){
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowDemand > 0) {
                        releverage(extraBorrowDemand);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, redeemTokensIn);
                }else if(myRes.res==0){  
                    borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    updateStats(false, myRes.tmpTotalAssetValue, myRes.tmpLevRatio, redeemTokensIn);
                    extraBorrowDemand = 0;
                    extraBorrowSupply = 0;
                }
            }else{  
                if(myRes.res==1){    
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowDemand > 0) {
                        releverage(extraBorrowDemand);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    uint currUSDCBalance = getCashExReserves();
                    if(checkCompound(currUSDCBalance)){
                        supplyUSDC(currUSDCBalance - thresholdUSDC);
                    }
                    updateStats(true, 0, 0, 0);
                    updateNetAssetValue(borrowBalanceUSDC, 0);  
                }else if(myRes.res==2){ 
                    updateExtraBorrow(fx_USDTUSDC, myRes.tmpTotalAssetValue, myRes.targetLevRatio);
                    if(extraBorrowSupply > 0){
                        deleverage(fx_USDTUSDC, extraBorrowSupply, false);
                    }else{
                        borrowBalanceUSDC = myRes.tmpBorrowBalanceUSDC;
                    }
                    updateStats(true, 0, 0, 0);
                    updateNetAssetValue(borrowBalanceUSDC, 0);
                }
            }
        }
    }
    function redeemAllRebalance() internal returns (uint){
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        extraBorrowDemand = 0;
        extraBorrowSupply = borrowBalanceUSDT;
        bool isLiquidate = deleverage(fx_USDTUSDC, extraBorrowSupply, true);    
        if(isLiquidate){
            updateStats(false, 0, 0, 0);
            netAssetValue = 0;
            tensorpricer._setMintPausedLev(address(this), true);
            tensorpricer._setRedeemPausedLev(address(this), true);
            return 0;
        }else{
            uint currUSDCBalance = getCashExReserves(); 
            uint redeemFeeBeforeLevRatio = (redeemFeePC * currUSDCBalance) / expScale;
            uint redeemFee = (targetLevRatio * redeemFeeBeforeLevRatio) / expScale;
            if(currUSDCBalance <= redeemFee){
                redeemFee = currUSDCBalance;
                currUSDCBalance = 0;
            }else{
                currUSDCBalance = currUSDCBalance - redeemFee;
            }
            levReserve = levReserve + redeemFee;
            updateStats(false, 0, 0, 0);
            netAssetValue = initialNetAssetValueMantissa;
            return currUSDCBalance;
        }
    }
    function checkCompound(uint currUSDCBalance) internal pure returns (bool) {
        if(currUSDCBalance > minTransferAmtUSDC+thresholdUSDC){
            return true;
        }else{
            return false;
        }
    }
    function checkLeveragibility(Exp memory fx_USDTUSDC, uint mintAmount) internal view returns (bool) {
        uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
        uint availCash = getCashExReserves() + getCmpBalanceInternal();
        uint tmpLevRatio = 0;
        if(availCash > tmpBorrowBalanceUSDC){   
            uint tmpTotalAssetValue = availCash - tmpBorrowBalanceUSDC;
            tmpLevRatio = tmpBorrowBalanceUSDC*expScale / tmpTotalAssetValue;
        }else{  
            (uint initLevRatio,,) = refreshTargetLevRatio(fx_USDTUSDC.mantissa);
            tmpLevRatio = initLevRatio;
        }
        uint loanNeeded = tmpLevRatio * div_(mintAmount, fx_USDTUSDC) / expScale;
        uint unborrowedCashAtDep = depErc20.getUnborrowedUSDTBalance();
        return unborrowedCashAtDep > loanNeeded;
    }
    function payback(address minter, uint _totalAssetValue) internal {
        if(_totalAssetValue > 0){
            uint compoundBalance = getCmpBalanceInternal();
            if(compoundBalance > 0){
                withdrawUSDCfromCmp(compoundBalance);  
            }
            doTransferOut(payable(minter), _totalAssetValue);
            emit Transfer(minter, address(this), 0);
        }
        updateStats(false, 0, 0, 0);
        extraBorrowDemand = 0;
        extraBorrowSupply = 0;
        netAssetValue = 0;
        tensorpricer._setMintPausedLev(address(this), true);
        tensorpricer._setRedeemPausedLev(address(this), true);
    }
    function mintInternal(uint mintAmount) internal nonReentrant {
        address minter = msg.sender;   
        uint allowed = tensorpricer.mintAllowed(address(this), minter);
        if (allowed != 0) {
            revert MintTensorpricerRejection(allowed);
        }
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        Exp memory fx_USDTUSDC = Exp({mantissa: fx_USDTUSDC_Mantissa});
        if(!checkLeveragibility(fx_USDTUSDC, mintAmount)){
            return;
        }
        uint actualMintAmount = doTransferIn(minter, mintAmount);
        uint mintTokens;
        uint navAfterTradeMantissa;
        Exp memory tmpNav;
        uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, fx_USDTUSDC);
        uint tmpNavMantissa = calcNetAssetValue(tmpBorrowBalanceUSDC, actualMintAmount);
        bool skipRebalance = false;
        if(tmpNavMantissa == 0){
            if(deleverageAll()){
                return;
            }
            skipRebalance = true;
        }
        tmpNav = Exp({mantissa: takePerfFee(tmpNavMantissa)});
        checkRebalanceRes memory myRes;
        if(!skipRebalance){
            myRes = checkRebalance(0, 0);
            doRebalance(0, myRes, 0);    
        }
        if(!skipRebalance && myRes.res==0){   
            mintTokens = div_(actualMintAmount, tmpNav);
        }else{  
            uint _totalSupply = totalSupply;
            if(_totalSupply == 0){
                navAfterTradeMantissa = initialNetAssetValueMantissa;
                mintTokens = div_(actualMintAmount, Exp({mantissa: navAfterTradeMantissa}));
            }else{
                uint _totalAssetValue = totalAssetValue;
                if(_totalAssetValue > actualMintAmount){
                    navAfterTradeMantissa = (_totalAssetValue - actualMintAmount) * expScale / _totalSupply;
                    mintTokens = div_(actualMintAmount, Exp({mantissa: navAfterTradeMantissa}));
                }else{
                    payback(minter, _totalAssetValue);
                    return;
                }
            }
        }
        uint currUSDCBalance = getCashExReserves();
        if(checkCompound(currUSDCBalance)){
            supplyUSDC(currUSDCBalance - thresholdUSDC);
        }
        totalSupply = totalSupply + mintTokens;
        accountTokens[minter] = accountTokens[minter] + mintTokens;
        updateNetAssetValue(borrowBalanceUSDC, 0);
        emit Mint(minter, actualMintAmount, mintTokens, netAssetValue);
        emit Transfer(address(this), minter, mintTokens);
    }
    function redeemInternal(uint redeemTokensIn) internal nonReentrant {
        address payable redeemer = payable(msg.sender);
        uint allowed = tensorpricer.redeemAllowed(address(this), redeemer, redeemTokensIn);
        if (allowed != 0) {
            revert RedeemTensorpricerRejection(allowed);
        }
        uint fx_USDTUSDC_Mantissa = tensorpricer.getFx('USDTUSDC');
        uint tmpBorrowBalanceUSDC = mul_(borrowBalanceUSDT, Exp({mantissa: fx_USDTUSDC_Mantissa}));
        uint tmpNetAssetValue = calcNetAssetValue(tmpBorrowBalanceUSDC, 0);
        (uint targetLevRatio,,) = refreshTargetLevRatio(fx_USDTUSDC_Mantissa);
        uint updatedTmpNavMantissa = takePerfFee(tmpNetAssetValue);  
        uint tmpRedeemAmount = mul_ScalarTruncate(Exp({mantissa: updatedTmpNavMantissa}), redeemTokensIn);
        uint trueRedeemAmount;
        if(totalSupply == redeemTokensIn){  
            trueRedeemAmount = redeemAllRebalance();
            totalSupply = 0;
        }else{
            redeemAmountInUSDC = 0; 
            if(tmpNetAssetValue > 0){
                doRebalance(1, checkRebalance(1, tmpRedeemAmount), redeemTokensIn);    
            }else{
                if(deleverageAll()){
                    emit Redeem(redeemer, 0, redeemTokensIn, netAssetValue);
                    return;
                }
            }
            uint redeemFeeBeforeLevRatio = (redeemFeePC * redeemAmountInUSDC) / expScale;
            uint redeemFee = (targetLevRatio * redeemFeeBeforeLevRatio) / expScale;
            trueRedeemAmount = redeemAmountInUSDC - redeemFee;
            levReserve = levReserve + redeemFee;
            uint currUSDCBalance = getCashExReserves();
            if (redeemAmountInUSDC > currUSDCBalance) { 
                uint amtNeeded = redeemAmountInUSDC - currUSDCBalance;
                uint compoundBalance = getCmpBalanceInternal();
                if(compoundBalance > (amtNeeded + extraUSDC)){
                    withdrawUSDCfromCmp(amtNeeded + extraUSDC);
                }else{
                    withdrawUSDCfromCmp(compoundBalance);  
                }
            }
            totalSupply = totalSupply - redeemTokensIn;
            updateNetAssetValue(borrowBalanceUSDC, trueRedeemAmount); 
        }
        accountTokens[redeemer] = accountTokens[redeemer] - redeemTokensIn;
        if(trueRedeemAmount > 0){
            doTransferOut(redeemer, trueRedeemAmount);
            emit Transfer(redeemer, address(this), redeemTokensIn);
            emit Redeem(redeemer, trueRedeemAmount, redeemTokensIn, netAssetValue);
        }else{
            emit Redeem(redeemer, 0, redeemTokensIn, netAssetValue);
        }
    }
    function forceRepayInternal(uint repayAmountInUSDT) internal nonReentrant returns (uint) {
        Exp memory fx_USDTUSDC = Exp({mantissa: tensorpricer.getFx('USDTUSDC')});
        uint amtUSDC = mul_(repayAmountInUSDT, fx_USDTUSDC);
        amtUSDC = (amtUSDC * 105) / 100;    
        uint availCash = getCashExReserves();
        if(amtUSDC > availCash){
            uint amtUSDCmissing = amtUSDC - availCash; 
            uint compoundBalance = getCmpBalanceInternal();
            if(compoundBalance > (amtUSDCmissing + extraUSDC)){
                withdrawUSDCfromCmp(amtUSDCmissing + extraUSDC);
            }else{
                withdrawUSDCfromCmp(compoundBalance);  
            }
        }
        uint netForceRepayAmount = changeUSDC2USDT(amtUSDC, 0, address(depErc20));
        return netForceRepayAmount;
    }
    function updateLedgerInternal() internal {
        updateBorrowBalances(tensorpricer.getFx('USDTUSDC'), depErc20.getTotalBorrows());   
        updateStats(true, 0, 0, 0);
        updateNetAssetValue(borrowBalanceUSDC, 0);
    }
    function takePerfFee(uint navMantissa) internal returns (uint) {
        uint perfFee = 0;
        if(navMantissa > hisHighNav && totalSupply > 0){
            uint gain = (navMantissa-hisHighNav) * totalSupply / expScale;    
            hisHighNav = navMantissa;
            perfFee = gain * perfPC / expScale;
            uint tmpTotalAssetValue = navMantissa * totalSupply / expScale;
            console.log("tmpTotalAssetValue,perffee,gain = %d,%d,%d",tmpTotalAssetValue,perfFee,gain);
            levReserve = levReserve + perfFee;
            uint updatedNavMantissa = (tmpTotalAssetValue - perfFee)*expScale / totalSupply;  
            console.log("updatedNavMantissa = ",updatedNavMantissa);
            return updatedNavMantissa;  
        }else{
            return navMantissa;
        }
    }
    function _setPendingAdmin(address payable newPendingAdmin) override external returns (uint) {
        if (msg.sender != admin) {
            revert SetPendingAdminOwnerCheck();
        }
        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
        return NO_ERROR;
    }
    function _acceptAdmin() override external returns (uint) {
        if (msg.sender != pendingAdmin || msg.sender == address(0)) {
            revert AcceptAdminPendingAdminCheck();
        }
        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;
        admin = pendingAdmin;
        pendingAdmin = payable(address(0));
        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
        return NO_ERROR;
    }
    function _reduceReserves(uint reduceAmount) override external nonReentrant returns (uint) {
        return _reduceReservesFresh(reduceAmount);
    }
    function _reduceReservesFresh(uint reduceAmount) internal returns (uint) {
        uint levReserveNew;
        if (msg.sender != admin) {
            revert ReduceReservesAdminCheck();
        }
        if (getCashPrior() < reduceAmount) {
            revert ReduceReservesCashNotAvailable();
        }
        if (reduceAmount > levReserve) {
            revert ReduceReservesCashValidation();
        }
        levReserveNew = levReserve - reduceAmount;
        levReserve = levReserveNew;
        doTransferOut(admin, reduceAmount);
        emit ReservesReduced(admin, reduceAmount, levReserveNew);
        return NO_ERROR;
    }
    function _setTensorpricer(TensorpricerInterface newTensorpricer) override public returns (uint) {
        if (msg.sender != admin) {
            revert SetTensorpricerOwnerCheck();
        }
        TensorpricerInterface oldTensorpricer = tensorpricer;
        require(newTensorpricer.isTensorpricer(), "marker method returned false");
        tensorpricer = newTensorpricer;
        emit NewTensorpricer(oldTensorpricer, newTensorpricer);
        return NO_ERROR;
    }
    function getCashExReserves() internal view returns (uint) {
        uint allCash = getCashPrior();
        if(allCash > levReserve){
            return allCash - levReserve;
        }else{
            return 0;
        }
    }
    function getCashPrior() virtual internal view returns (uint);
    function doTransferIn(address from, uint amount) virtual internal returns (uint);
    function doTransferOut(address payable to, uint amount) virtual internal;
    modifier nonReentrant() {
        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true; 
    }
}
contract LevErc20 is LevToken, LevErc20Interface {
    string public prologue;
    function setDepErc20(DepErc20Interface depErc20_) public override{
        super.setDepErc20(depErc20_);
    }
    function initialize(address underlying_,
                        address borrowUnderlying_,
                        TensorpricerInterface tensorpricer_,
                        string memory name_,
                        string memory symbol_,
                        uint8 decimals_) public override initializer {
        admin = payable(msg.sender);
        super.initialize(underlying_, borrowUnderlying_, tensorpricer_, name_, symbol_, decimals_);
        underlying = underlying_;
        EIP20Interface(underlying).totalSupply();
        borrowUnderlying = borrowUnderlying_;
        EIP20Interface(borrowUnderlying).totalSupply();
        netAssetValue = initialNetAssetValueMantissa;
        hisHighNav = initialNetAssetValueMantissa;
        targetLevRatio = initialTargetLevRatio;
    }
    function setPrologue() public {
        require(msg.sender == admin, "only admin may set prologue");
        prologue = 'leverc20 success';
    }
    function getAdmin() override external view returns (address payable) {
        return admin;
    }
    function mint(uint mintAmount) override external returns (uint) {
        require(mintAmount > 0, "cannot mint <= 0");
        mintInternal(mintAmount);
        return NO_ERROR;
    }
    function redeem(uint redeemTokens) override external returns (uint) {
        redeemInternal(redeemTokens);
        return NO_ERROR;
    }
    function sweepToken(EIP20NonStandardInterface token) override external {
        require(msg.sender == admin, "DepErc20::sweepToken: only admin can sweep tokens");
        require(address(token) != underlying, "DepErc20::sweepToken: can not sweep underlying token");
        uint256 balance = token.balanceOf(address(this));
        token.transfer(admin, balance);
    }
    function getExtraBorrowDemand() override external view returns (uint256){
        return extraBorrowDemand;
    }
    function getExtraBorrowSupply() override external view returns (uint256){
        return extraBorrowSupply;
    }
    function forceRepay(uint256 repayAmountInUSDT) override virtual external returns (uint) {
        require(msg.sender==address(depErc20), "only depToken can call forceRepay");
        return forceRepayInternal(repayAmountInUSDT);
    }
    function updateLedger() override virtual external {
        require(msg.sender==address(depErc20), "only depToken can call updateLedger");
        return updateLedgerInternal();
    }
    function getCashPrior() virtual override internal view returns (uint) {
        EIP20Interface token = EIP20Interface(underlying);
        return token.balanceOf(address(this));
    }
    function doTransferIn(address from, uint amount) virtual override internal returns (uint) {
        address underlying_ = underlying;
        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying_);
        uint balanceBefore = EIP20Interface(underlying_).balanceOf(address(this));
        token.transferFrom(from, address(this), amount);
        bool success;
        assembly {
            switch returndatasize()
                case 0 {                       
                    success := not(0)          
                }
                case 32 {                      
                    returndatacopy(0, 0, 32)
                    success := mload(0)        
                }
                default {                      
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_IN_FAILED");
        uint balanceAfter = EIP20Interface(underlying_).balanceOf(address(this));
        return balanceAfter - balanceBefore;   
    }
    function doTransferOut(address payable to, uint amount) virtual override internal {
        EIP20NonStandardInterface token = EIP20NonStandardInterface(underlying);
        token.transfer(to, amount);
        bool success;
        assembly {
            switch returndatasize()
                case 0 {                      
                    success := not(0)          
                }
                case 32 {                     
                    returndatacopy(0, 0, 32)
                    success := mload(0)        
                }
                default {                     
                    revert(0, 0)
                }
        }
        require(success, "TOKEN_TRANSFER_OUT_FAILED");
    }
}