pragma solidity ^0.4.19;
contract Users{
    mapping (address => bytes) public UserHash;
    address public owner;

    function Users() public {
        owner = msg.sender;
    }
    function getUserHash(address _account) public returns (bytes) {
      return UserHash[_account];
    }
    function setNewUser(address who, bytes hash) public{
      require(msg.sender==owner);
      UserHash[who]=hash;
    }

}
