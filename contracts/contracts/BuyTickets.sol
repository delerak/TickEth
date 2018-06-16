pragma solidity ^0.4.19;
import "./Tickets.sol";
contract BuyTickets{
  address ticketsContract;
  address topOwner;
  address owner;
  uint ntickets;
  uint percTopOwner;
  bytes32 idEvent;
  function BuyTickets(address _ticketsContract, address reseller, uint _ntickets, uint _percTopOwner, bytes32 _idEvent) public{
    ticketsContract=_ticketsContract;
    owner=reseller;
    topOwner=msg.sender;
    ntickets=_ntickets;
    percTopOwner=_percTopOwner;
    idEvent=_idEvent;
  }
  function getidEvent() public returns (bytes32){
    return idEvent;
  }
  function getntickets() public returns (uint){
    return ntickets;
  }
  Tickets tickets = Tickets(ticketsContract);
  function buy(bytes32 typeTicket, uint quantity) payable public returns (uint) {
    //uint pay = msg.value*100/percTopOwner/100;
    tickets.buy.value(msg.value)(idEvent, typeTicket, quantity, msg.sender );
    //return money if doesn't works
  }
}
