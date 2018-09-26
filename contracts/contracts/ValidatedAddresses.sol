pragma solidity ^0.4.19;
contract ValidatedAddresses{
    mapping (address => bytes32) private usersChallange;
    mapping (address => uint) private validatedUsers; //1 active, 0 disabled
    address public owner;

    function ValidatedAddresses() public {
        owner = msg.sender;
    }
    function isUserValidated(address _account) public returns (bool) {
        return validatedUsers[_account]==1;
    }
    function getUserChallange(address _account) public returns (bytes32){
        return usersChallange[_account];
    }
    function setNewUser(address _account) public{
      require(msg.sender==owner);
      validatedUsers[_account]=1;
    }
    function challange(bytes32 response) public {
        usersChallange[msg.sender]=response;
    }
    function disableUser(address _account) public{
        require(msg.sender==owner);
        validatedUsers[_account]=0;
    }
}
