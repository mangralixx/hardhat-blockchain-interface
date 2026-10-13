// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;


interface IEventFund {
    function cancel() external; 
    function releaseToOrganizer(address payable recipient) external; 
} 


contract EventManager {
    address public immutable organizer;
    address public immutable registry;
    IEventFund public immutable fund;
    bool public eventStarted;
    bool public eventCancelled;
    event EventStarted(address indexed organizer, uint256 timestamp);
    event EventCancelled(address indexed organizer, uint256 timestamp);
    
    constructor(address registryAddress, address fundAddress) {
        require(registryAddress != address(0), "Invalid registry"); 
        require(fundAddress != address(0), "Invalid fund"); 
        organizer = msg.sender; 
        registry = registryAddress; 
        fund = IEventFund(fundAddress); 
    } 
    
    function startEvent() external {
        require(msg.sender == organizer, "Only organizer"); 
        require(!eventStarted && !eventCancelled, "Event already closed"); 
        eventStarted = true; 
        fund.releaseToOrganizer(payable(organizer)); 
        emit EventStarted(organizer, block.timestamp); 
    } 
    
    function cancelEvent() external {
        require(msg.sender == organizer, "Only organizer"); 
        require(!eventStarted && !eventCancelled, "Event already closed"); 
        eventCancelled = true; 
        fund.cancel(); 
        emit EventCancelled(organizer, block.timestamp); 
    } 
} 