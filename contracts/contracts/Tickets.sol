pragma solidity ^0.4.19;
import "./Users.sol";
contract Tickets {
    address usersContract;
    struct buyer{
      mapping (bytes32 => uint) ticketQuantity;//type->quantity
      uint nticket;
    }
    struct eventObject{
      bytes32 id;
      bytes32 nome;
      //uint startTimeStamp;
      //uint endTimeStamp;
      bytes32[] ticketsType;
      uint maxTicketPerson;
      uint[] ticketPrices;
      uint[] ticketLeft;
      mapping (address => buyer) sold;
      mapping (bytes32 => uint) ticketPricesMap;
    }
    //mapping (uint=> eventObject) public eventsmap;
    bytes32[] events;
    mapping(bytes32 => eventObject) eventStore;
    Users users = Users(usersContract);
    function getEventsSize(uint i) public returns (uint){
      return events.length;
    }
    function getEventName(uint i) public returns (bytes32){
      return eventStore[events[i]].nome;
    }
    function getEventTicketPerPerson(uint i) public returns (uint){
      return eventStore[events[i]].maxTicketPerson;
    }
    function getEventTicketBought(uint i) public returns (uint){
      return eventStore[events[i]].sold[msg.sender].nticket;
    }
    function addEvent(bytes32 _id, bytes32 _nome, bytes32[] _ticketsType, uint _maxTicketPerson, uint[] _ticketPrices, uint[] _ticketLeft) public
    //function addEvent(bytes32 _id, bytes32 _nome,  uint _maxTicketPerson) public

    {
      events.push(_id);
      eventStore[_id].id=_id;
      eventStore[_id].nome=_nome;
      //eventStore[_id].startTimeStamp=_startTimeStamp;
      //eventStore[_id].endTimeStamp=_endTimeStamp;
      eventStore[_id].ticketsType=_ticketsType;
      eventStore[_id].maxTicketPerson=_maxTicketPerson;
      eventStore[_id].ticketPrices=_ticketPrices;
      eventStore[_id].ticketLeft=_ticketLeft;

        /*eventObject myStruct = new eventObject({
          id:_id,
          nome:_nome,
          startTimeStamp:_startTimeStamp,
          endTimeStamp:_endTimeStamp,
          ticketsType:_ticketsType,
          maxTicketPerson:_maxTicketPerson,
          ticketPrices:_ticketPrices,
          ticketLeft:_ticketLeft
          });*/
        //eventsmap[events.length-1]=myStruct;




    }
    function Tickets(address _userContract) public{
      usersContract=_userContract;
    }


   function buy(bytes32 idEvent, bytes32 typeTicket, uint quantity) payable public returns (uint) {
    uint money = msg.value;
    //require (users.getUserHash(msg.sender)!=0);
    //require (block.timestamp > evento.startTimeStamp);
    //require (block.timestamp < evento.endTimeStamp);
    //require(evento.ticketPricesMap[typeTicket]*quantity == money);

    //require(quantity <= evento.maxTicketPerson);
    //require(evento.sold[msg.sender].nticket+quantity<=evento.maxTicketPerson);
    if(eventStore[idEvent].sold[msg.sender].nticket>0){
      eventStore[idEvent].sold[msg.sender].ticketQuantity[typeTicket]+=quantity;
      eventStore[idEvent].sold[msg.sender].nticket+=quantity;
    }else{
      eventStore[idEvent].sold[msg.sender].ticketQuantity[typeTicket]=quantity;
      eventStore[idEvent].sold[msg.sender].nticket=quantity;
    }

  }


}
