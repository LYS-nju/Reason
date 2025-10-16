
//added prgma version
pragma solidity ^0.4.0;

contract SimpleSuicide {
  address private owner;

  function SimpleSuicide() {
    owner = msg.sender;
  }  
  
  function sudicideAnyone() {
    // fixed
    require(msg.sender==owner);
    selfdestruct(msg.sender);
  }

}
