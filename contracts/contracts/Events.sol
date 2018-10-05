pragma solidity ^0.4.19;
import "./ValidatedAddresses.sol";
//TODO: getter ticket second market
//TODO: getter events
//TODO: cancel every ticket of a type from second markets
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
      mapping (bytes32 => bytes32[]) t;
      mapping (bytes32 => mapping (bytes32 => uint) ) ticketsID;
    }
    struct sellerSecMarket{
        address seller;
        mapping(bytes32 => uint) prices;//type->price
        mapping (bytes32 => uint) ticketsQuantity;//type->quantity
        uint nTickets;
    }
    struct eventObject{
      bytes32 id;
      bytes32 name;
      uint256 startTimeStamp;
      uint256 endTimeStamp;
      bytes32[] ticketsType;
      uint maxTicketPerson;
      uint[] ticketPrices;
      mapping (address => buyer) sold;
      address[] buyers;
      mapping (bytes32 => uint) ticketPricesMap;
      mapping (bytes32 => uint) ticketLeftMap;
      mapping (address => reseller) resellers;
      address[] resellersAddr;

      mapping (bytes32 => marketLimit) secMarketLimit;
      sellerSecMarket[] secondMarket;
    }
    struct reseller{
        uint nTickets;
    }
    struct marketLimit{
        uint lowerLimit;
        uint upperLimit;
    }

    function Events(address _userContract) public{
      ValidatedAddressesContract=_userContract;
      users=ValidatedAddresses(ValidatedAddressesContract);
      owner = msg.sender;
      fund=0;
    }

    function cancelSellingTicket(bytes32 _idEvent, bytes32 _ticketsType, uint _quantity, bytes32[] _t){
        uint cont=0;
        uint[] pos;
        for(uint i=0; i<eventStore[_idEvent].secondMarket.length;i++){
          if(eventStore[_idEvent].secondMarket[i].seller==msg.sender){
              if(eventStore[_idEvent].secondMarket[i].ticketsQuantity[_ticketsType]>0){
                  cont+=eventStore[_idEvent].secondMarket[i].ticketsQuantity[_ticketsType];
                  pos.push(i);
                  if(cont>_quantity){
                      for(uint k=0;k<pos.length;k++){
                          if(eventStore[_idEvent].secondMarket[i].ticketsQuantity[_ticketsType]<=cont){
                              cont-=eventStore[_idEvent].secondMarket[i].ticketsQuantity[_ticketsType];
                              eventStore[_idEvent].secondMarket[i].ticketsQuantity[_ticketsType]=0;
                          }else{
                              eventStore[_idEvent].secondMarket[i].ticketsQuantity[_ticketsType]-=cont;
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
            eventStore[_idEvent].sold[msg.sender].ticketsID[_ticketsType][_t[i]]++;
        }
    }

    function buySecond(bytes32 _idEvent, bytes32 _ticketsType, uint _quantity, uint _i, bytes32[] _t ) payable public{
      address sender=msg.sender;
      uint money = msg.value;
      uint onSale=0;
      uint i=0;
      if(users.isUserValidated(sender)==false){
        revert();
      }
      if(eventStore[_idEvent].ticketPricesMap[_ticketsType]*_quantity > money || _quantity==0){
        revert();
      }
      for(i=0;i<eventStore[_idEvent].secondMarket.length;i++){
          if(eventStore[_idEvent].secondMarket[i].seller==sender){
              onSale+=eventStore[_idEvent].secondMarket[i].nTickets;
          }
      }
      if(eventStore[_idEvent].sold[sender].nTickets+_quantity+onSale>eventStore[_idEvent].maxTicketPerson){
          revert();
      }
      if(eventStore[_idEvent].secondMarket[_i].ticketsQuantity[_ticketsType]<_quantity){
        revert();
      }
      if(_t.length!=_quantity){
          revert();
      }
      if(eventStore[_idEvent].secondMarket[_i].prices[_ticketsType]*_quantity==money ){
        eventStore[_idEvent].secondMarket[_i].ticketsQuantity[_ticketsType]-=_quantity;

        eventStore[_idEvent].sold[sender].ticketsQuantity[_ticketsType]+=_quantity;
        eventStore[_idEvent].sold[sender].nTickets+=_quantity;
        for (i=0;i<_quantity;i++){
            if(eventStore[_idEvent].sold[sender].ticketsID[_ticketsType][_t[i]]==0){
                eventStore[_idEvent].sold[sender].t[_ticketsType].push(_t[i]);
            }
            eventStore[_idEvent].sold[sender].ticketsID[_ticketsType][_t[i]]++;
        }
        bool already=false;
        for (i=0;i<eventStore[_idEvent].buyers.length;i++){
            if(eventStore[_idEvent].buyers[i]==sender){
                already=true;
            }
        }
        if(!already){
            eventStore[_idEvent].buyers.push(sender);
        }
        if(!eventStore[_idEvent].secondMarket[_i].seller.send(money)){
            revert();
        }
      }else{
        revert();
      }
    }

    //before can be useful to cancel every ticket of taht type on second market
    function setRefundByType(bytes32 _idEvent, bytes32 _ticketsType, uint _refundAmount) public{
        require(owner==msg.sender);
        address[] buyers=eventStore[_idEvent].buyers;
        for(uint i=0;i<buyers.length;i++){
            if(eventStore[_idEvent].sold[buyers[i]].ticketsQuantity[_ticketsType]>0){
                if(!buyers[i].send(_refundAmount*eventStore[_idEvent].sold[buyers[i]].ticketsQuantity[_ticketsType])){
                    revert();
                }
            }
        }
    }
    function setSingleRefund(bytes32 _idEvent, bytes32 _ticketsType, address _user, uint _quantity, uint refundAmount) public{
        require(owner==msg.sender);
        for(uint i=0;i<eventStore[_idEvent].buyers.length;i++){
            if(eventStore[_idEvent].sold[_user].ticketsQuantity[_ticketsType]>=_quantity){
                if(!_user.send(refundAmount*eventStore[_idEvent].sold[_user].ticketsQuantity[_ticketsType])){
                    revert();
                }
            }
        }
    }
    /*
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
    */

    function getEventsSize() public returns (uint){
      return events.length;
    }
    function getTicketPrice(bytes32 _idEvent, bytes32 _type) public returns (uint){
      return eventStore[_idEvent].ticketPricesMap[_type];
    }
    function getEventName(bytes32 _idEvent) public returns (bytes32){
      return eventStore[_idEvent].name;
    }
    function getEventTicketPerPerson(bytes32 _idEvent) public returns (uint){
      return eventStore[_idEvent].maxTicketPerson;
    }
    function getEventTicketBought(bytes32 _idEvent, address _addr) public returns (uint){
      return eventStore[_idEvent].sold[_addr].nTickets;
    }
    function addReseller(address _addr,  bytes32 _idEvent ) public{
        eventStore[_idEvent].resellers[_addr].nTickets=1;
        eventStore[_idEvent].resellersAddr.push(_addr);
    }
    function getResellerLength(bytes32 _idEvent) public returns (uint){
      return eventStore[_idEvent].resellersAddr.length;
    }
    function getResellerfirstAddr(bytes32 _idEvent, uint _resellerIndex) public returns (address){
      return eventStore[_idEvent].resellersAddr[_resellerIndex];
    }

    //add new object for every new sale
    //TODO: change old sale instead
    function sellTickets(bytes32 _idEvent, bytes32[] _t, uint[] _quantity, bytes32 _ticketsType, uint _ticketsPrice ) public{
        require(eventStore[_idEvent].secMarketLimit[_ticketsType].lowerLimit<=_ticketsPrice);
        require(eventStore[_idEvent].secMarketLimit[_ticketsType].upperLimit>=_ticketsPrice);
        require(eventStore[_idEvent].sold[msg.sender].ticketsQuantity[_ticketsType]>=_t.length);
        require(_t.length==_quantity.length);
        for(uint i =0; i<_t.length;i++){
            if(eventStore[_idEvent].sold[msg.sender].ticketsID[_ticketsType][_t[i]]<_quantity[i]){
                revert();
            }
            eventStore[_idEvent].sold[msg.sender].ticketsID[_ticketsType][_t[i]]-=_quantity[i];
        }

        eventStore[_idEvent].sold[msg.sender].ticketsQuantity[_ticketsType]-=_t.length;
        eventStore[_idEvent].sold[msg.sender].nTickets-=_t.length;

        //one price for every type of ticket on this sale
        sellerSecMarket tmp;
        tmp.seller=msg.sender;

        tmp.prices[_ticketsType]=_ticketsPrice; //modify or set price
        uint sum=0;
        for(i=0;i<_quantity.length;i++){
            sum+=_quantity[i];
        }
        tmp.ticketsQuantity[_ticketsType]+=sum;
        tmp.nTickets+=sum;
        eventStore[_idEvent].secondMarket.push(tmp);
    }
    function addEvent(bytes32 _idEvent, bytes32 _name, bytes32[] _ticketsType, uint _maxTicketPerson, uint[] _ticketsPrices, uint[] _ticketsLeft, uint256 _startTimeStamp, uint256 _endTimeStamp, uint[] _lowSecMarket, uint[] _upSecMarket) public
    {
        require(msg.sender==owner);
        require(_ticketsType.length==_ticketsPrices.length);
        require(_ticketsPrices.length==_ticketsLeft.length);
        require(_lowSecMarket.length==_ticketsType.length);
        require(_upSecMarket.length==_ticketsType.length);
        uint i=0;
        for (i=0;i<events.length;i++){
            require(events[i]!=_idEvent);
        }
        events.push(_idEvent);
        eventStore[_idEvent].id=_idEvent;
        eventStore[_idEvent].name=_name;
        eventStore[_idEvent].startTimeStamp=_startTimeStamp;
        eventStore[_idEvent].endTimeStamp=_endTimeStamp;
        eventStore[_idEvent].ticketsType=_ticketsType;
        eventStore[_idEvent].maxTicketPerson=_maxTicketPerson;
        eventStore[_idEvent].ticketPrices=_ticketsPrices;

        for (i=0;i<_ticketsType.length;i++){
            eventStore[_idEvent].ticketPricesMap[_ticketsType[i]]=_ticketsPrices[i];
            eventStore[_idEvent].ticketLeftMap[_ticketsType[i]]=_ticketsLeft[i];
            eventStore[_idEvent].secMarketLimit[_ticketsType[i]].lowerLimit=_lowSecMarket[i];
            eventStore[_idEvent].secMarketLimit[_ticketsType[i]].upperLimit=_upSecMarket[i];
        }

    }

   function buy(bytes32 _idEvent, bytes32 _ticketsType, uint _quantity, address _sentFrom, bytes32[] _t) payable public returns (uint) {
        uint money = msg.value;
        address sender;
        uint i=0;
        uint onSale=0;
        buyer eventBuyer;
        if(eventStore[_idEvent].ticketLeftMap[_ticketsType] < _quantity){
            revert();
        }
        if(_t.length>_quantity){
            revert();
        }

        if(eventStore[_idEvent].resellersAddr.length>0){
            if(eventStore[_idEvent].resellers[msg.sender].nTickets<1 || _quantity==0){
                revert();
            }
            sender=_sentFrom;
            eventStore[_idEvent].resellers[msg.sender].nTickets+=_quantity;
        }else{
            sender=msg.sender;
            if(block.timestamp < eventStore[_idEvent].startTimeStamp && block.timestamp > eventStore[_idEvent].endTimeStamp){
                revert();
            }
            if(eventStore[_idEvent].ticketPricesMap[_ticketsType]*_quantity > money || _quantity==0){
                revert();
            }

            eventBuyer=eventStore[_idEvent].sold[sender];
            for(i=0;i<eventStore[_idEvent].secondMarket.length;i++){
              if(eventStore[_idEvent].secondMarket[i].seller==sender){
                  onSale+=eventStore[_idEvent].secondMarket[i].nTickets;
              }
            }
        }

        if(eventBuyer.nTickets+_quantity+onSale>eventStore[_idEvent].maxTicketPerson){
            revert();
        }

        if(users.isUserValidated(sender)==false){
          revert();
        }
        bool already=false;
        for (i=0;i<eventStore[_idEvent].buyers.length;i++){
            if(eventStore[_idEvent].buyers[i]==sender){
                already=true;
            }
        }
        if(!already){
            eventStore[_idEvent].buyers.push(sender);
        }
        eventStore[_idEvent].ticketLeftMap[_ticketsType]-=_quantity;
        eventBuyer.ticketsQuantity[_ticketsType]+=_quantity;
        eventBuyer.nTickets+=_quantity;

        for (i=0;i<_quantity;i++){
            if(eventBuyer.ticketsID[_ticketsType][_t[i]]==0){
                eventBuyer.t[_ticketsType].push(_t[i]);
            }
            eventBuyer.ticketsID[_ticketsType][_t[i]]++;
        }
        eventStore[_idEvent].sold[sender]=eventBuyer;
        fund+=money;
  }
}
