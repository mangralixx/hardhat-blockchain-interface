// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.34;

interface IParticipantRegistry {
    function getParticipant(address account) external view returns (address, uint256, bool); 
}
contract EventFund {
    address public immutable owner;
    IParticipantRegistry public immutable registry;
    address public manager;
    bool public managerConfigured;
    bool public cancelled;
    bool public released;
    mapping(address => uint256) public contributions;
    uint256 public totalContributions;
    event ContributionReceived(address indexed account, uint256 amount);
    event ContributionRefunded(address indexed account, uint256 amount);
    event FundsReleased(address indexed recipient, uint256 amount);
    constructor(address registryAddress) {
        require(registryAddress != address(0), "Invalid registry");
        owner = msg.sender;
        registry = IParticipantRegistry(registryAddress);
    }

    function setManager(address managerAddress) external {
        require(msg.sender == owner, "Only owner");
        require(!managerConfigured, "Manager already set");
        require(managerAddress != address(0), "Invalid manager");
        manager = managerAddress;
        managerConfigured = true;
    }
	
    function contribute() external payable {
        require(managerConfigured, "Manager not configured");
        require(!cancelled && !released, "Fund is closed");
        require(msg.value > 0, "Contribution must be positive");
        (,, bool exists) = registry.getParticipant(msg.sender);
        require(exists, "Register first");
        contributions[msg.sender] += msg.value;
        totalContributions += msg.value;
        emit ContributionReceived(msg.sender, msg.value);
    }

    function cancel() external {
        require(msg.sender == manager, "Only manager");
        require(!released, "Already released");
        cancelled = true;
    }

    function refund() external {
        require(cancelled, "Event not cancelled"); 
        uint256 amount = contributions[msg.sender]; 
        require(amount > 0, "Nothing to refund"); 
        contributions[msg.sender] = 0; 
        totalContributions -= amount; 
        (bool success, ) = payable(msg.sender).call{value: amount}(""); 
        require(success, "Refund failed"); 
        emit ContributionRefunded(msg.sender, amount); 
    } 

    
    function releaseToOrganizer(address payable recipient) external {
        require(msg.sender == manager, "Only manager"); 
        require(!cancelled && !released, "Fund is closed"); 
        require(recipient != address(0), "Invalid recipient"); 
        released = true; 
        uint256 amount = address(this).balance; 
        totalContributions = 0; 
        (bool success, ) = recipient.call{value: amount}(""); 
        require(success, "Transfer failed"); 
        emit FundsReleased(recipient, amount); 
    } 

    
    function getBalance() external view returns (uint256) {
        return address(this).balance; 
    } 

    
    receive() external payable {
        revert("Use contribute()"); 
    } 
}