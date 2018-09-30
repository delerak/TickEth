pragma solidity ^0.4.19;
contract test{
uint fund;
address owner;
function test() public{
    fund=0;
    owner=msg.sender;
}

function buy() payable public{
    fund+=msg.value;
}
function getMoney() public{
    if(!msg.sender.send(fund)){
        revert();
    }
    fund=0;
}
}
