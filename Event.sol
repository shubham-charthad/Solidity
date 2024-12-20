// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EventContract{
    struct Event{
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping (uint=>Event) public events;
    mapping (address=>mapping(uint=>uint)) public tickets;
    uint public nextId;

    function createEvent(string memory _name,uint _date, uint _price, uint _ticketCount) public  {
    require(_date>block.timestamp,"you can organise event for future date");
    require(_ticketCount>0);

    events[nextId] = Event(msg.sender,_name,_date,_price,_ticketCount,_ticketCount);
    nextId++;
    }

    function BuyTickets(uint id, uint quantity) external payable  {
        require(events [id].date != 0,"Event does not exist");
        require(events [id].date>block.timestamp,"Event has already over ");
        Event storage _event = events[id];
        require(msg.value == (_event.price*quantity),"ETher not enough");
        require(_event.ticketRemain >= quantity, "not enough  tickets");
        _event.ticketRemain-=quantity;
        tickets[msg.sender][id] += quantity;
    }

    function TransferTicket(uint id, uint quantity, address to) external {
        require(events [id].date != 0,"Event does not exist");
        require(events [id].date>block.timestamp,"Event has already over ");
        require(tickets[msg.sender][id] >= quantity, "Not have enough tickets" );
        tickets[msg.sender][id]-=quantity;
        tickets[to][id]+=quantity;


    }
}
