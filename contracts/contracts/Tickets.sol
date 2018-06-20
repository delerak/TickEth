pragma solidity ^0.4.19;
import "./Users.sol";
contract Tickets {
    address usersContract;
    address public owner;
    bytes32[] events;
    mapping(bytes32 => eventObject) eventStore;
    Users users;
    struct buyer{
      mapping (bytes32 => uint) ticketQuantity;//type->quantity
      uint nTickets;
    }
    struct seller{
      uint percReturn;
      uint nTickets;
    }
    struct eventObject{
      bytes32 id;
      bytes32 name;
      //uint startTimeStamp;
      //uint endTimeStamp;
      bytes32[] ticketsType;
      uint maxTicketPerson;
      uint[] ticketPrices;
      uint[] ticketLeft;
      mapping (address => seller) resellers;
      address[] resellersAddr;
      mapping (address => buyer) sold;
      mapping (bytes32 => uint) ticketPricesMap;
    }
    //mapping (uint=> eventObject) public eventsmap;
    function getUserHash(address user) public returns (bytes32){
      return users.getUserHash(user);
    }
    function getEventsSize() public returns (uint){
      return events.length;
    }
    function getTicketPrice(bytes32 id) public returns (uint){
      return eventStore[id].ticketPrices[0];
    }
    function getEventName(bytes32 id) public returns (bytes32){
      return eventStore[id].name;
    }
    function getEventTicketPerPerson(bytes32 id) public returns (uint){
      return eventStore[id].maxTicketPerson;
    }
    function getEventTicketBought(bytes32 id, address addr) public returns (uint){
      return eventStore[id].sold[addr].nTickets;
    }
    function addReseller(address addr, uint perc, uint ntickets, bytes32 id ) public{
      eventStore[id].resellers[addr].percReturn=perc;
      eventStore[id].resellers[addr].nTickets=ntickets;
      eventStore[id].resellersAddr.push(addr);
    }
    function getResellerLength(bytes32 id) public returns (uint){
      return eventStore[id].resellersAddr.length;
    }
    function getResellerfirstAddr(bytes32 id) public returns (address){
      return eventStore[id].resellersAddr[0];
    }
    function getResellerTicketsAv(bytes32 id) public returns (uint){
      return eventStore[id].resellers[msg.sender].nTickets;
    }
    function addEvent(bytes32 _id, bytes32 _name, bytes32[] _ticketsType, uint _maxTicketPerson, uint[] _ticketPrices, uint[] _ticketLeft) public
    {
      events.push(_id);
      eventStore[_id].id=_id;
      eventStore[_id].name=_name;
      //eventStore[_id].startTimeStamp=_startTimeStamp;
      //eventStore[_id].endTimeStamp=_endTimeStamp;
      eventStore[_id].ticketsType=_ticketsType;
      eventStore[_id].maxTicketPerson=_maxTicketPerson;
      eventStore[_id].ticketPrices=_ticketPrices;
      eventStore[_id].ticketLeft=_ticketLeft;

    }
    function Tickets(address _userContract) public{
      usersContract=_userContract;
      users=Users(usersContract);
      owner = msg.sender;
    }

   function buy(bytes32 idEvent, bytes32 typeTicket, uint quantity, address sendFrom) payable public returns (uint) {
    uint money = msg.value;
    address sender;
    //require(quantity <= evento.maxTicketPerson);
    //require(evento.sold[msg.sender].nticket+quantity<=evento.maxTicketPerson);
    if(eventStore[idEvent].resellersAddr.length>0){
      require(eventStore[idEvent].resellers[msg.sender].nTickets>=quantity);
      sender=sendFrom;
      eventStore[idEvent].resellers[msg.sender].nTickets-=quantity;
    }else{
      //require (block.timestamp > evento.startTimeStamp);
      //require (block.timestamp < evento.endTimeStamp);
      require(eventStore[idEvent].ticketPricesMap[typeTicket]*quantity <= money);
      sender=msg.sender;
    }
    require(eventStore[idEvent].sold[sender].nTickets+quantity<=eventStore[idEvent].maxTicketPerson);
    require (users.getUserHash(sender)!=0);
    eventStore[idEvent].sold[sender].ticketQuantity[typeTicket]+=quantity;
    eventStore[idEvent].sold[sender].nTickets+=quantity;

  }


}
