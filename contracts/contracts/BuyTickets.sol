pragma solidity ^0.4.19;
import "./Tickets.sol";
contract BuyTickets{
  address ticketsContract;
  address topOwner;
  address owner;
  uint ntickets;
  uint percTopOwner;
  Tickets tickets = Tickets(ticketsContract);
  function BuyTickets(address _ticketsContract, address reseller, uint _ntickets, uint _percTopOwner) public{
    usersContract=_ticketsContract;
    owner=reseller;
    topOwner=msg.sender;
    nticket=_ntickets;
    percTopOwner=_percTopOwner;
  }
  function buy(bytes32 idEvent, bytes32 typeTicket, uint quantity) payable public returns (uint) {
    tickets.buy(bytes32 idEvent, bytes32 typeTicket, uint quantity);
  }
}
