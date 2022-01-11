// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.11;

/**
 * @title Governance
 * @dev Store & retrieve value in a variable
 */
contract Governance {

    //section for declaring variables and constructor
    struct Investment {
        uint value;
        address payable targetReciever;
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

    uint public totalElections = 0;
    mapping(uint => Election) public elections;

    uint public totalApprovers;
    mapping(address => bool) public approvers;

    uint public totalInvestments = 0;
    mapping (uint => Investment) public investments;

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

    function holdElection() public contractParticipant {
        // require(block.timestamp > electionDate + leaderTerm);
        // require(block.timestamp > lastClosingMonthDate + 5 days);
        // require(block.timestamp < lastClosingMonthDate + 10 days);

        electionDate = block.timestamp;

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

    function createInvestment(uint value, address payable targetReciever) public restricted {
        Investment storage investment = investments[totalInvestments++];

        investment.value = value;
        investment.targetReciever = targetReciever;
        investment.closed = false;
        investment.approvalCount = 0;
    }

    function approveInvestment(uint index) public {
        Investment storage investment = investments[index];

        require(approvers[msg.sender]);
        require(!investment.approvals[msg.sender]);

        investment.approvals[msg.sender] = true;
        investment.approvalCount++;
    }

    function finalizeInvestment(uint index) public restricted {
        Investment storage investment = investments[index];

        require(investment.approvalCount > (totalApprovers / 2));
        require(!investment.closed);

        investment.targetReciever.transfer(investment.value);
        investment.closed = true;
    }

    //==================================================================

    //section for dealing with enter and exit from the contract
    
    function payContribution() public payable {
        require(msg.value > weiAmountToEnter); //default unit is wei
        contributorsInfo[msg.sender] = true;
        contributors.push(msg.sender);
    }

    //==================================================================

    //section for dealing with contract maintenance

    function closeMonth() public payable restricted {
        require(hasPassedOneMont());
        require(msg.value > .01 ether);
        
        for (uint256 index = 0; contributors.length < index; index++) {
            delete contributorsInfo[contributors[index]];
        }

        delete contributors;
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