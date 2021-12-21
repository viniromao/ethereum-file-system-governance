// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.8;

/**
 * @title Governance
 * @dev Store & retrieve value in a variable
 */
contract Governance {

    //section for declaring variables and constructor
    uint256 public month = 30 days;

    uint256 public lastClosingMonthDate;
    address payable public contractAdress;
    uint256 weiAmountToEnter = 200;
    address public leader;

    mapping (address => bool) public contributorsInfo;
    address[] public contributors;

    constructor() {
        lastClosingMonthDate = block.timestamp;
        leader = msg.sender;
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

}