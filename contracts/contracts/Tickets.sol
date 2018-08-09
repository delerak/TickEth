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
      bool refund;
    }
    struct sellingTicket{
      bytes32 type;
      uint quantity;
      address user;
      uint price;
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
      bool refund;
      uint refundPerc;
      //user sell their tickets
      uint sellingPerc;
      sellingTicket[] selling;
    }
    function sellTicket(bytes32 id, bytes32 type, uint price, uint quantity ){
      //l'utente ha la quantità
      require(eventStore[id].sold[msg.sender].ticketQuantity[type]>=quantity);
      //il prezzo è nel range corretto
      uint i;
      for(i=0; i<eventStore[id].ticketsType.length;i++){
        if(eventStore[id].ticketsType[i]==type)
        break;
      }

      uint priceperc = eventStore[id].ticketsprice[i]*100/eventStore[id].sellingPerc/100;
      require(eventStore[id].ticketsprice[i]-priceperc>=price);
      require(eventStore[id].ticketsprice[i]+priceperc<=price);
      //diminuisce quantità all'Utente
      eventStore[id].sold[msg.sender].ticketQuantity[type]-=quantity;
      //inserisce biglietti in vendita

      sellingTicket item= sellingTicket({type:type, quantity:quantity, user:msg.sender, price:price});
      eventStore[id].selling.push(item);
    }
    function cancelSellingTicket(bytes32 id, bytes32 type, uint quantity){
      //rimuove dalla vendita i biglietti

      for(uint i=0;i<eventStore[id].selling.length;i++){
        if(eventStore[id].selling[i].user==msg.sender && eventStore[id].selling[i].type==type){
          if(eventStore[id].selling[i].quantity>=quantity){
            eventStore[id].selling[i].quantity-=quantity;
            eventStore[id].sold[msg.sender].ticketQuantity[type]+=quantity;
            return;
          }else{
            uint tmp=quantity;
            quantity-=eventStore[id].selling[i].quantity;
            eventStore[id].selling[i].quantity=0;
            eventStore[id].sold[msg.sender].ticketQuantity[type]+=tmp;
          }

        }
      }

    }

    function buySecond(bytes32 id, bytes32 type, uint quantity, uint i ) payable public{
      //se autorizzato, se prezzo giusto, ecc...
      //rimuovi biglietti dalla vendita
      //aggiungi biglietti al nuovo proprietario
      if(users.getUserHash(sender)==0){
        revert();
      }
      if(eventStore[id].maxTicketPerson<quantity){
        revert();
      }
      if(eventStore[id].selling[i].quantity<quantity){
        revert();
      }

      if(eventStore[id].selling[i].price*quantity==msg.value ){
        eventStore[id].selling[i].quantity-=quantity;
        eventStore[id].sold[msg.sender].ticketQuantity[type]+=quantity;
        eventStore[id].sold[msg.sender].nTickets+=quantity;
        fund+=money;
      }else{
        revert();
      }


    }
    function setEventRefund(bytes32 id, uint perc){

    }
    function setUserRefund(bytes32 EventId, address user, uint perc){

    }
    function getRefund(bytes32 idEvento){
      require(eventStore[idEvento].sold[msg.sender].refund);
      uint quantityRef=0;
      for(uint i=0;i<ticketsType.length;i++){
        if(eventStore[idEvento].sold[msg.sender].ticketQuantity[ticketsType[i]]>0){
          quantityRef+=ticketPrices[i]*eventStore[idEvento].sold[msg.sender].ticketQuantity[ticketsType[i]];
          eventStore[idEvento].sold[msg.sender].nTickets-=eventStore[idEvento].sold[msg.sender].ticketQuantity[ticketsType[i]];
          eventStore[idEvento].sold[msg.sender].ticketQuantity[ticketsType[i]]=0;
        }
      }
      if(quantityRef>0){
        msg.sender.send(quantityRef);
      }

    }
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
      eventStore[_id].refund=False;

    }
    function Tickets(address _userContract) public{
      usersContract=_userContract;
      users=Users(usersContract);
      owner = msg.sender;
      fund=0;
    }

   function buy(bytes32 idEvent, bytes32 typeTicket, uint quantity, address sendFrom) payable public returns (uint) {
    uint money = msg.value;
    address sender;
    //if revert()
    //TICKETS LEFT!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //require(quantity <= evento.maxTicketPerson);
    //require(evento.sold[msg.sender].nticket+quantity<=evento.maxTicketPerson);
    if(eventStore[idEvent].resellersAddr.length>0){
      if(eventStore[idEvent].resellers[msg.sender].nTickets<quantity || quantity==0){
        revert();
      }
      sender=sendFrom;
      eventStore[idEvent].resellers[msg.sender].nTickets-=quantity;//va spostato in caso una require vada male
    }else{
      //require (block.timestamp > evento.startTimeStamp);
      //require (block.timestamp < evento.endTimeStamp);
      if(eventStore[idEvent].ticketPricesMap[typeTicket]*quantity > money || quantity==0){
        revert();
      }
      sender=msg.sender;
    }
    if(eventStore[idEvent].sold[sender].nTickets>0){
      if(eventStore[idEvent].sold[sender].nTickets+quantity>eventStore[idEvent].maxTicketPerson){//scazza
          revert();
      }
    }else{
      if(quantity>eventStore[idEvent].maxTicketPerson){
          revert();
      }

    }
    if(users.getUserHash(sender)==0){
      revert();
    }
    eventStore[idEvent].sold[sender].ticketQuantity[typeTicket]+=quantity;
    eventStore[idEvent].sold[sender].nTickets+=quantity;
    fund+=money;
  }
  function sell(uint quantity, uint price){

  }

}
