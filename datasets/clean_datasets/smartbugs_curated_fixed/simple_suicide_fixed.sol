pragma solidity ^0.4.0;
contract SimpleSuicide {
  address private owner;
  function SimpleSuicide() {
    owner = msg.sender;
  }  
  function sudicideAnyone() {
    require(msg.sender==owner);
    selfdestruct(msg.sender);
  }
}