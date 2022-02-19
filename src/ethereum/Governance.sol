// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.11;

/**
 * @title Governance
 * @dev Store & retrieve value in a variable
 */
contract Governance {

    //section for declaring variables and constructor
    struct Project {
        uint value;
        address payable targetReciever;
        string description;
        bool closed;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    struct Election {
        address winner;
        bool closed;
        address[] candidates;
        mapping(address => bool) voters;
        mapping(address => uint256) votes;
    }

    struct Backer {
        uint amountInvested;
        uint balance;
        address payable recipient;
    }

    mapping(address => Backer) public backers;
    uint256 totalBackers = 0;

    uint public totalElections = 0;
    mapping(uint => Election) public elections;

    uint public totalApprovers;
    mapping(address => bool) public approvers;

    uint public totalProjects = 0;
    mapping (uint => Project) public projects;

    uint256 public month = 30 days;

    uint256 public lastClosingMonthDate;

    uint256 public electionDate;
    uint256 public leaderTerm = 24 * month;

    address payable public contractAdress;
    uint256 weiAmountToEnter = 200;
    address public leader;

    mapping (address => bool) public contributorsInfo;
    address[] public contributors;

    

    constructor() {
        electionDate = block.timestamp;
        lastClosingMonthDate = block.timestamp;
        leader = msg.sender;
    }

    //==================================================================

    function invest(uint256 amount) public payable {
        require(msg.value > amount);
        require(backers[msg.sender].recipient == address(0x0));

        Backer memory backer;
        backer.amountInvested = amount;
        backer.balance = getBalance();
        backer.recipient = payable(msg.sender);

        backers[msg.sender] = backer;

        totalBackers++;
    }

    function endInvestment(uint256 finalAmount) public {
        require(backers[msg.sender].amountInvested > 0);

        backers[msg.sender].recipient.transfer(finalAmount);
        totalBackers--;
        delete backers[msg.sender];
    }

    function getBackerInfo() public view returns (Backer memory) {
        Backer memory backer = backers[msg.sender];

        return backer;
    }

    //==================================================================

    function holdElection() public contractParticipant {
        // require(block.timestamp > electionDate + leaderTerm);
        // require(block.timestamp > lastClosingMonthDate + 5 days);
        // require(block.timestamp < lastClosingMonthDate + 10 days);

        // electionDate = block.timestamp;

        Election storage election = elections[totalElections++];
        election.closed = false;
    }

    function candidate() public contractParticipant isElectionOpen {
        elections[totalElections - 1].candidates.push(msg.sender);
        elections[totalElections - 1].votes[msg.sender] = 0;
    }

    function vote(address candidateVote) public contractParticipant isElectionOpen {
        // require(elections[totalElections - 1].voters[msg.sender] == false);

        elections[totalElections - 1].voters[msg.sender] = true;
        elections[totalElections - 1].votes[candidateVote] = elections[totalElections - 1].votes[candidateVote]++;
    }

    function finishElection() public contractParticipant isElectionOpen {
        // require(block.timestamp > lastClosingMonthDate + 10 days);
        
        // if (block.timestamp > lastClosingMonthDate + 13 days) {
        //       elections[totalElections - 1].closed = true;
        //       return;
        // }
 
        address winner = elections[totalElections- 1].candidates[0];

        for( uint index = 1; index < elections[totalElections - 1].candidates.length ; index++) {
            if (elections[totalElections - 1].votes[elections[totalElections - 1].candidates[index]] > elections[totalElections - 1].votes[winner]) {
                winner = elections[totalElections - 1].candidates[index];
            }
        }

        leader = winner;
        elections[totalElections - 1].closed = true;
        elections[totalElections - 1].winner = winner;
    }


    //==================================================================

    function createProject(uint value, address payable targetReciever,string memory description) public restricted {
        Project storage project = projects[totalProjects++];

        project.value = value;
        project.description = description;
        project.targetReciever = targetReciever;
        project.closed = false;
        project.approvalCount = 0;
    }

    function approveProject(uint index) public {
        // Project storage project = projects[index];

        require(approvers[msg.sender]);
        // require(!project.approvals[msg.sender]);

        // projects[index].approvals[msg.sender] = true;
        // projects[index].approvalCount++;
    }

    function finalizeProject(uint index) public restricted {
        Project storage project = projects[index];

        require(project.approvalCount > (totalApprovers / 2));
        require(!project.closed);

        project.targetReciever.transfer(project.value);
        project.closed = true;
    }

    //==================================================================

    //section for dealing with enter and exit from the contract
    
    function payContribution() public payable {
        require(msg.value > weiAmountToEnter); //default unit is wei
        require(contributorsInfo[msg.sender] == false);

        contributorsInfo[msg.sender] = true;
        contributors.push(msg.sender);
    }

      function closeMonth() public payable restricted {
        // require(hasPassedOneMont());
        // require(msg.value > .01 ether);
        
        for (uint256 index = 0; contributors.length < index; index++) {
            contributorsInfo[contributors[index]] = false;
            delete contributorsInfo[contributors[index]];
        }

        delete contributors;
    }

    function isContributor() public view returns (bool) {
        if (msg.sender == leader || contributorsInfo[msg.sender] == true) {
            return true;
        } else {
            return false;
        }
    }
    //==================================================================

    //financial info from contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    modifier restricted() {
        require(msg.sender == leader);
        _;
    }

    function hasPassedOneMont() internal view returns (bool) {
        return block.timestamp > lastClosingMonthDate + month;
    }

    modifier contractParticipant() {
        require(msg.sender == leader || contributorsInfo[msg.sender] == true);
        _;
    }

    modifier isElectionOpen() {
        require(elections[totalElections - 1].closed == false);
        _;
    }
}