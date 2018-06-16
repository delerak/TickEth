pragma solidity ^0.4.19;
contract Users{
    mapping (address => bytes32) public UserHash;
    address public owner;

    function Users() public {
        owner = msg.sender;
    }
    function getUserHash(address _account) public returns (bytes32) {
      return UserHash[_account];
    }
    function setNewUser(address who, bytes32 hash) public{
      require(msg.sender==owner);
      UserHash[who]=hash;
    }
}
