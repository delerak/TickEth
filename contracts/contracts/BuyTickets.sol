pragma solidity ^0.4.19;
import "./Events.sol";
contract BuyTickets{
    address ticketsContract;
    address topOwner;
    address owner;
    bytes32 idEvent;
    Events tickets;
    uint fund;
    mapping(bytes32 => uint) ticketsCost;
    mapping(bytes32 => marketLimit) ticketsPricesRange;
    mapping(bytes32 => uint) ticketsPrices;
    struct marketLimit{
      uint lowerLimit;
      uint upperLimit;
    }
    function withdraw() public returns (bool){
        uint amount=fund;
        require(msg.sender==owner);
        fund=0;
        if (!msg.sender.send(amount)) {
          revert();
        }
        return true;
    }
    function BuyTickets(address _ticketsContract, address _reseller,  bytes32 _idEvent, bytes32[] _types, uint[] _lowerPrices, uint[] _upperPrices, uint[] _cost) public{
        ticketsContract=_ticketsContract;
        owner=_reseller;
        topOwner=msg.sender;
        idEvent=_idEvent;
        fund=0;
        tickets= Events(_ticketsContract);

        for(uint i=0;i<_types.length;i++){
            ticketsCost[_types[i]]=_cost[i];
            ticketsPricesRange[_types[i]].lowerLimit=_lowerPrices[i];
            ticketsPricesRange[_types[i]].upperLimit=_upperPrices[i];
        }
    }
    function setPrices(bytes32[] _types, uint[] _prices) public{
        require(msg.sender==owner);
        for (uint i=0;i<_types.length;i++){
            require(ticketsPricesRange[_types[i]].lowerLimit<=_prices[i] && ticketsPricesRange[_types[i]].upperLimit>=_prices[i]);
            ticketsPrices[_types[i]]=_prices[i];
        }
    }
    function getidEvent() public returns (bytes32){
        return idEvent;
    }
    function getENameFromTickets() public returns (bytes32){
        return tickets.getEventName(idEvent);
    }

    function buy(bytes32 _ticketsType, uint _quantity,  bytes32[] _t) payable public returns (uint) {
        if(msg.value<ticketsPrices[_ticketsType]*_quantity || ticketsPrices[_ticketsType]==0){
            revert();
        }
        uint pay = msg.value-(ticketsCost[_ticketsType]*_quantity);
        fund+=pay;
        tickets.buy.value(ticketsCost[_ticketsType]*_quantity)(idEvent, _ticketsType, _quantity, msg.sender, _t );
    }
}
