pragma solidity ^0.4.19;
import "./ValidatedAddresses.sol";
contract Events {
    address ValidatedAddressesContract;
    address public owner;
    bytes32[] events;
    uint fund;
    mapping(bytes32 => eventObject) eventStore;
    ValidatedAddresses users;
    struct buyer{
      mapping (bytes32 => uint) ticketsQuantity;//type->quantity
      uint nTickets;
      bool refund;
      mapping(bytes32 => bytes32[]) ticketsID; //type->t[]
      bytes32[] t;
    }
    /*struct sellingTicket{
      bytes32 ticketType;
      uint quantity;
      address user;
      uint price;
    }
    struct seller{
      uint percReturn;
      uint nTickets;
    }*/
    struct eventObject{
      bytes32 id;
      bytes32 name;
      uint256 startTimeStamp;
      uint256 endTimeStamp;
      bytes32[] ticketsType;
      uint maxTicketPerson;
      uint[] ticketPrices;
      //mapping (address => seller) resellers;
      //address[] resellersAddr;
      mapping (address => buyer) sold;
      mapping (bytes32 => uint) ticketPricesMap;
      mapping (bytes32 => uint) ticketLeftMap;
      bool refund;
      uint[] refundQuantity;
      //user sell their tickets
      //uint sellingPerc;
      //sellingTicket[] selling;
    }
    function Events(address _userContract) public{
      ValidatedAddressesContract=_userContract;
      users=ValidatedAddresses(ValidatedAddressesContract);
      owner = msg.sender;
      fund=0;
    }

    /*function sellTicket(bytes32 id, bytes32 ticketType, uint price, uint quantity ){
      //l'utente ha la quantità
      require(eventStore[id].sold[msg.sender].ticketsQuantity[ticketType]>=quantity);
      //il prezzo è nel range corretto
      uint i;
      for(i=0; i<eventStore[id].ticketsType.length;i++){
        if(eventStore[id].ticketsType[i]==ticketType)
        break;
      }

      uint priceperc = eventStore[id].ticketPrices[i]*100/eventStore[id].sellingPerc/100;
      require(eventStore[id].ticketPrices[i]-priceperc>=price);
      require(eventStore[id].ticketPrices[i]+priceperc<=price);
      //diminuisce quantità all'Utente
      eventStore[id].sold[msg.sender].ticketsQuantity[ticketType]-=quantity;
      //inserisce biglietti in vendita

      sellingTicket memory item= sellingTicket({ticketType:ticketType, quantity:quantity, user:msg.sender, price:price});
      eventStore[id].selling.push(item);
    }
    function cancelSellingTicket(bytes32 id, bytes32 ticketType, uint quantity){
      //rimuove dalla vendita i biglietti
      uint i;
      for(i=0;i<eventStore[id].selling.length;i++){
        if(eventStore[id].selling[i].user==msg.sender && eventStore[id].selling[i].ticketType==ticketType){
          if(eventStore[id].selling[i].quantity>=quantity){
            eventStore[id].selling[i].quantity-=quantity;
            eventStore[id].sold[msg.sender].ticketsQuantity[ticketType]+=quantity;
            return;
          }else{
            uint tmp=quantity;
            quantity-=eventStore[id].selling[i].quantity;
            eventStore[id].selling[i].quantity=0;
            eventStore[id].sold[msg.sender].ticketsQuantity[ticketType]+=tmp;
          }

        }
      }

    }

    function buySecond(bytes32 id, bytes32 ticketType, uint quantity, uint i ) payable public{
      //se autorizzato, se prezzo giusto, ecc...
      //rimuovi biglietti dalla vendita
      //aggiungi biglietti al nuovo proprietario
      address sender=msg.sender;
      uint money = msg.value;
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
        eventStore[id].sold[msg.sender].ticketsQuantity[ticketType]+=quantity;
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
      for(uint i=0;i<eventStore[idEvento].ticketsType.length;i++){
        if(eventStore[idEvento].sold[msg.sender].ticketsQuantity[eventStore[idEvento].ticketsType[i]]>0){
          quantityRef+=eventStore[idEvento].ticketPrices[i]*eventStore[idEvento].sold[msg.sender].ticketsQuantity[eventStore[idEvento].ticketsType[i]];
          eventStore[idEvento].sold[msg.sender].nTickets-=eventStore[idEvento].sold[msg.sender].ticketsQuantity[eventStore[idEvento].ticketsType[i]];
          eventStore[idEvento].sold[msg.sender].ticketsQuantity[eventStore[idEvento].ticketsType[i]]=0;
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
    //mapping (uint=> eventObject) public eventsmap;*/

    function getEventsSize() public returns (uint){
      return events.length;
    }
    function getTicketPrice(bytes32 _id, bytes32 _type) public returns (uint){
      return eventStore[_id].ticketPricesMap[_type];
    }
    function getEventName(bytes32 _id) public returns (bytes32){
      return eventStore[_id].name;
    }
    function getEventTicketPerPerson(bytes32 _id) public returns (uint){
      return eventStore[_id].maxTicketPerson;
    }
    function getEventTicketBought(bytes32 _id, address _addr) public returns (uint){
      return eventStore[_id].sold[_addr].nTickets;
    }
    /*function addReseller(address addr, uint perc, uint ntickets, bytes32 id ) public{
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
    }*/
    function addEvent(bytes32 _id, bytes32 _name, bytes32[] _ticketsType, uint _maxTicketPerson, uint[] _ticketsPrices, uint[] _ticketsLeft, uint256 _startTimeStamp, uint256 _endTimeStamp) public
    {
        require(msg.sender==owner);
        require(_ticketsType.length==_ticketsPrices.length);
        require(_ticketsPrices.length==_ticketsLeft.length);
        uint i=0;
        for (i=0;i<events.length;i++){
            require(events[i]!=_id);
        }
        events.push(_id);
        eventStore[_id].id=_id;
        eventStore[_id].name=_name;
        eventStore[_id].startTimeStamp=_startTimeStamp;
        eventStore[_id].endTimeStamp=_endTimeStamp;
        eventStore[_id].ticketsType=_ticketsType;
        eventStore[_id].maxTicketPerson=_maxTicketPerson;
        eventStore[_id].ticketPrices=_ticketsPrices;
        eventStore[_id].refund=false;
        for (i=0;i<_ticketsType.length;i++){
            eventStore[_id].ticketPricesMap[_ticketsType[i]]=_ticketsPrices[i];
        }
        for (i=0;i<_ticketsType.length;i++){
            eventStore[_id].ticketLeftMap[_ticketsType[i]]=_ticketsLeft[i];
        }
    }

   function buy(bytes32 _idEvent, bytes32 _ticketsType, uint _quantity, address _sendFrom, bytes32[] _t) payable public returns (uint) {
        uint money = msg.value;
        address sender;
        uint i=0;

        if(eventStore[_idEvent].ticketLeftMap[_ticketsType] < _quantity){
            revert();
        }
        if(_t.length>_quantity){
            revert();
        }
        /*if(eventStore[_idEvent].resellersAddr.length>0){
          if(eventStore[_idEvent].resellers[msg.sender].nTickets<_quantity || _quantity==0){
            revert();
          }*/
        //sender=sendFrom;
        //eventStore[idEvent].resellers[msg.sender].nTickets-=quantity;//va spostato in caso una require vada male
        //}else{
          require (block.timestamp > eventStore[_idEvent].startTimeStamp);
          require (block.timestamp < eventStore[_idEvent].endTimeStamp);
          if(eventStore[_idEvent].ticketPricesMap[_ticketsType]*_quantity > money || _quantity==0){
            revert();
          }
          sender=msg.sender;
        //}

          if(eventStore[_idEvent].sold[sender].nTickets+_quantity>eventStore[_idEvent].maxTicketPerson){
              revert();
          }

        if(users.isUserValidated(sender)==false){
          revert();
        }

        eventStore[_idEvent].ticketLeftMap[_ticketsType]-=_quantity;
        eventStore[_idEvent].sold[sender].ticketsQuantity[_ticketsType]+=_quantity;
        eventStore[_idEvent].sold[sender].nTickets+=_quantity;
        //eventStore[_idEvent].sold[sender].t=_t;
        for (i=0;i<_quantity;i++){
            eventStore[_idEvent].sold[sender].ticketsID[_ticketsType].push()
        }
        fund+=money;
  }
}
