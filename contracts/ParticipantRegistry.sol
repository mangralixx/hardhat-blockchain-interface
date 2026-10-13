// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;


contract ParticipantRegistry {
    
    struct Participant {
        address account; 
        uint256 registeredAt; 
        bool exists; 
    } 

    address public immutable organizer;
    mapping(address => Participant) private participants;
    address[] private participantList;
    event ParticipantRegistered(address indexed account, uint256 registeredAt);
    
    constructor() {
        organizer = msg.sender; 
    } 
    
    function register() external {
        require(!participants[msg.sender].exists, "Already registered"); 
        participants[msg.sender] = Participant(msg.sender, block.timestamp, true); 
        participantList.push(msg.sender); 
        emit ParticipantRegistered(msg.sender, block.timestamp); 
    } 
    
    function getParticipant(address account) external view returns (address, uint256, bool) {
        Participant memory participant = participants[account]; 
        return (participant.account, participant.registeredAt, participant.exists); 
    } 
    
    function getParticipantCount() external view returns (uint256) {
        return participantList.length; 
    } 
    
    function getParticipantAt(uint256 index) external view returns (address) {
        require(index < participantList.length, "Invalid index"); 
        return participantList[index]; 
    } 
} 