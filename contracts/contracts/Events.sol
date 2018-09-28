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
      mapping (bytes32 => uint[]) ticketsQuantity;//type->quantity
      uint nTickets;
      bool refund;
      mapping (bytes32 => bytes32[]) t;
      mapping (bytes32 => mapping (bytes32 => uint) ) ticketsID;
    }
    struct buyerSecMarket{
        address seller;
        mapping(bytes32 => uint) prices;//type->price
        mapping (bytes32 => uint) ticketsQuantity;//type->quantity
    }
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
      //bool refund;
      //uint[] refundQuantity;
      //user sell their tickets
      //uint sellingPerc;
      //sellingTicket[] selling;
      mapping (bytes32 => secondMarketLimit) secMarketLimit;
      buyerSecMarket[] secondMarket;
    }
    struct secondMarketLimit{
        uint lowerLimit;
        uint upperLimit;
    }

    function Events(address _userContract) public{
      ValidatedAddressesContract=_userContract;
      users=ValidatedAddresses(ValidatedAddressesContract);
      owner = msg.sender;
      fund=0;
    }


    function cancelSellingTicket(bytes32 _id, bytes32 _ticketsType, uint _quantity, bytes32[] _t){
        uint cont=0;
        uint pos[];
        for(uint i=0; i<eventObject[_id].secondMarket.length;i++){
          if(eventObject[_id].secondMarket[i].seller==msg.sender){
              if(eventObject[_id].ticketsQuantity[_ticketsType]>0){
                  cont+=eventObject[_id].ticketsQuantity[_ticketsType];
                  pos.push(i);
                  if(cont>_quantity){
                      for(uint k=0;k<pos.length;k++){
                          if(eventObject[_id].secondMarket[i].ticketsQuantity[_ticketsType]<=cont){
                              cont-=eventObject[_id].secondMarket[i].ticketsQuantity[_ticketsType];
                              eventObject[_id].secondMarket[i].ticketsQuantity[_ticketsType]=0;
                          }else{
                              eventObject[_id].secondMarket[i].ticketsQuantity[_ticketsType]-=cont;
                          }
                      }
                      break;
                  }
              }
          }
        }
        eventStore[_idEvent].sold[msg.sender].ticketsQuantity[_ticketsType]+=_quantity;
        eventStore[_idEvent].sold[msg.sender].nTickets+=_quantity;
        for (i=0;i<_quantity;i++){
            if(eventStore[_idEvent].sold[msg.sender].ticketsID[_ticketsType][_t[i]]==0){
                eventStore[_idEvent].sold[msg.sender].t[_ticketsType].push(_t[i]);
            }
            eventStore[_idEvent].sold[sender].ticketsID[_ticketsType][_t[i]]++;
        }
    }
    /*
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
    function sellTickets(bytes32 _id, bytes32 _t[], uint[] _quantities, bytes32 _ticketsType, uint _ticketsPrice ) public{
        require(eventStore[_id].secMarketLimit[_ticketsPrice].lowerLimit<=_ticketsPrice);
        require(eventStore[_id].secMarketLimit[_ticketsPrice].upperLimit>=_ticketsPrice);
        require(eventStore[_id].buyer[msg.sender].ticketsQuantity[_ticketsType]>=_t.length);
        require(_t.length==quantity.length);
        for(uint i =0; i<_t.length;i++){
            if(eventStore[_id].buyer[msg.sender].ticketsID[_ticketsType][_t[i]]<_quantity[i]){
                revert();
            };
            eventStore[_id].buyer[msg.sender].ticketsID[_ticketsType][_t[i]]-=_quantity[i];
        }

        eventStore[_id].buyer[msg.sender].ticketsQuantity[_ticketsType]-=_t.length;
        eventStore[_id].buyer[msg.sender].nTickets-=_t.length;

        //one price for every type of ticket on this sale
        buyerSecMarket tmp=buyerSecMarket();
        tmp.seller=msg.sender;
        tmp.prices[_ticketsType]=_ticketsPrice; //modify or set price
        tmp.ticketsQuantity[_ticketsType]=_quantity;
        eventStore[_id].secondMarket.push(tmp);
    }
    function addEvent(bytes32 _id, bytes32 _name, bytes32[] _ticketsType, uint _maxTicketPerson, uint[] _ticketsPrices, uint[] _ticketsLeft, uint256 _startTimeStamp, uint256 _endTimeStamp, uint[] _lowSecMarket, uint[] _upSecMarket) public
    {
        require(msg.sender==owner);
        require(_ticketsType.length==_ticketsPrices.length);
        require(_ticketsPrices.length==_ticketsLeft.length);
        require(_lowSecMarket.length==_ticketsType.length);
        require(_upSecMarket.length==_ticketsType.length);
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
            eventStore[_id].ticketLeftMap[_ticketsType[i]]=_ticketsLeft[i];
            eventStore[_id].secMarketLimit[_ticketsType[i]].lowerLimit=_lowSecMarket[i];
            eventStore[_id].secMarketLimit[_ticketsType[i]].upperLimit=_upSecMarket[i];
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
          if(block.timestamp < eventStore[_idEvent].startTimeStamp && block.timestamp > eventStore[_idEvent].endTimeStamp){
            revert();
          }
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

        for (i=0;i<_quantity;i++){
            if(eventStore[_idEvent].sold[sender].ticketsID[_ticketsType][_t[i]]==0){
                eventStore[_idEvent].sold[sender].t[_ticketsType].push(_t[i]);
            }
            eventStore[_idEvent].sold[sender].ticketsID[_ticketsType][_t[i]]++;
        }

        fund+=money;
  }
}
