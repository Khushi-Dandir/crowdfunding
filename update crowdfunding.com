// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Crowdfunding {
    address public owner;
    uint public goal;
    uint public deadline;
    mapping(address => uint) public contributions;

    constructor(uint _goal, uint _durationInDays) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + (_durationInDays * 1 days);
    }

    // 1️⃣ Contribute to the campaign
    function contribute() external payable {
        require(block.timestamp < deadline, "Campaign ended");
        require(msg.value > 0, "Contribution must be > 0");
        contributions[msg.sender] += msg.value;
    }

    // 2️⃣ Check if funding goal has been reached
    function isGoalReached() public view returns (bool) {
        return address(this).balance >= goal;
    }

    // 3️⃣ Withdraw funds if goal is reached
    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(block.timestamp > deadline, "Campaign still running");
        require(isGoalReached(), "Goal not reached");
        payable(owner).transfer(address(this).balance);
    }
}
