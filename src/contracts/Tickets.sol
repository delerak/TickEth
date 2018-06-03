pragma solidity ^0.4.19;
import "./Users.sol";
contract Tickets {
    address usersContract;
    struct buyer{
      mapping (bytes32 => uint) ticketQuantity;//type->quantity
      uint nticket;
    }
    struct eventObject{
      bytes32 nome;
      bytes32 descrizione;
      uint startTimeStamp;
      uint endTimeStamp;
      bytes32[] ticketsType;
      uint maxTicketPerson;
      uint[] ticketPrices;
      uint[] ticketLeft;
      mapping (address => buyer) sold;
      mapping (bytes32 => uint) ticketPricesMap;
    }
    eventObject[] events;
    Users users = Users(usersContract);

    function addEvent(bytes32 _nome, bytes32 _descrizione, uint _startTimeStamp, uint _endTimeStamp, bytes32[] _ticketsType, uint _maxTicketPerson, uint[] _ticketPrices, uint[] _ticketLeft) public
    {
        eventObject memory myStruct = eventObject({
          nome:_nome,
          descrizione:_descrizione,
          startTimeStamp:_startTimeStamp,
          endTimeStamp:_endTimeStamp,
          ticketsType:_ticketsType,
          maxTicketPerson:_maxTicketPerson,
          ticketPrices:_ticketPrices,
          ticketLeft:_ticketLeft
          });
        events.push(myStruct);

    }
    function Tickets(address _userContract) public{
      usersContract=_userContract;
    }


   function buy(uint idEvent, bytes32 typeTicket, uint quantity) payable public returns (uint) {
    eventObject evento=events[idEvent];
    uint money = msg.value;
    require (users.getUserHash(msg.sender)!=0);
    //require (block.timestamp > evento.startTimeStamp);
    //require (block.timestamp < evento.endTimeStamp);
    require(evento.ticketPricesMap[typeTicket]*quantity == money);

    require(quantity <= evento.maxTicketPerson);
    require(evento.sold[msg.sender].nticket+quantity<=evento.maxTicketPerson);
    if(evento.sold[msg.sender].nticket>0){
      evento.sold[msg.sender].ticketQuantity[typeTicket]+=quantity;
      evento.sold[msg.sender].nticket+=quantity;
    }else{
      evento.sold[msg.sender].ticketQuantity[typeTicket]=quantity;
      evento.sold[msg.sender].nticket=quantity;
    }

  }


}
