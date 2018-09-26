pragma solidity ^0.4.19;
/*import "./Events.sol";
contract BuyTickets{
  address ticketsContract;
  address topOwner;
  address owner;
  uint ntickets;
  uint percTopOwner;
  bytes32 idEvent;
  Tickets tickets;
  uint fund;
  function withdraw() public returns (bool){
    uint amount=fund;
    require(msg.sender==owner);
    fund=0;
    if (!msg.sender.send(amount)) {
      fund = amount;
      return false;
    }
    return true;
  }
  function BuyTickets(address _ticketsContract, address reseller, uint _ntickets, uint _percTopOwner, bytes32 _idEvent) public{
    ticketsContract=_ticketsContract;
    owner=reseller;
    topOwner=msg.sender;
    ntickets=_ntickets;
    percTopOwner=_percTopOwner;
    idEvent=_idEvent;
    fund=0;
    tickets= Tickets(ticketsContract);
  }
  function getidEvent() public returns (bytes32){
    return idEvent;
  }
  function getntickets() public returns (uint){
    return ntickets;
  }
  function getENameFromTickets() public returns (bytes32){
    return tickets.getEventName(idEvent);
  }

  function buy(bytes32 typeTicket, uint quantity, bytes32 rnd2) payable public returns (uint) {
    uint pay = msg.value*100/percTopOwner/100;
    fund+=pay;
    tickets.buy.value(msg.value-pay)(idEvent, typeTicket, quantity, msg.sender, rnd2 );
  }
}*/
