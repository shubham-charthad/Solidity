// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title Crowdfunding
 * @dev This contract allows users to create a decentralized crowdfunding campaign with goal-based funding and tiered rewards.
 
 * Features:
 * - Campaign Management: Create a campaign with a funding goal, description, and deadline.
 * - Tier-Based Funding: Add or remove funding tiers with specific amounts and track tier-specific backers.
 * - Funding and Withdrawal: Accept funds, check campaign status, and allow withdrawals when the goal is met.
 * - Refund Mechanism: Refund contributions if the campaign fails to meet the goal.
 * - State Management: Tracks the campaign state (Active, Successful, Failed) with automatic updates.
 * - Access Control: Restricts critical functions to the contract owner using `onlyOwner` modifier.
 * - Pause and Resume: Allows pausing of the contract to temporarily disable funding.
 
 * Additional Features:
 * - Extend Deadline: Enables the campaign owner to extend the funding deadline.
 * - Balance Query: Provides the current balance of the campaign contract.
 */

contract Crowdfunding {
    string public name;
    string public description;
    uint256 public goal;
    uint256 public deadline ;
    address public owner; 
    bool public paused;

    enum CampaignState { Active, Successful, Failed }  
    CampaignState public state;

    struct Tier{
        string name;
        uint256 amount;
        uint256 backers;
    }

    struct Backer {
        uint256 totalContribution;
        mapping(uint256 => bool) fundedTiers;
    }

    Tier[] public tiers;
    mapping(address => Backer) public backers;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the Owner");
        _;
    }

    modifier campaignOpen() {
        require(state == CampaignState.Active, "Campaign is not Open");
        _;
    }

    modifier notPaused() {
        require(!paused,"Contract is paused");
        _;
    }


    constructor(
        address _owner,
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationinDays
    ) {
        name = _name;
        description = _description;
        goal = _goal;
        deadline = block.timestamp + (_durationinDays * 1 days);
        owner = _owner;
        state = CampaignState.Active;
      }

    function checkAndUpdateCampaignState() internal {
        if(state == CampaignState.Active){
            if(block.timestamp >= deadline){
                state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;
            } else { 
                state = address(this).balance >= goal ? CampaignState.Successful : CampaignState.Active;
            }       
        }
    }

    function fund(uint256 _tierIndex) public payable campaignOpen notPaused {
        //require(block.timestamp < deadline,"campaign is ended");
        require(_tierIndex < tiers.length,"Invalid Tier");
        require(msg.value == tiers[_tierIndex].amount,"Incorrect amount");

        tiers[_tierIndex].backers++;
        backers[msg.sender].totalContribution += msg.value;
        backers[msg.sender].fundedTiers[_tierIndex] = true;

        checkAndUpdateCampaignState();
    }

    function addTier( 
        string memory _name,
        uint256 _amount
    ) public onlyOwner {
        require(_amount > 0,"Amount be greater than 0");
        tiers.push(Tier(_name,_amount,0));
    }

    function removeTier(uint256 _index) public onlyOwner{
        require(_index < tiers.length,"Tier does not exist");        
        tiers[_index] = tiers[tiers.length - 1];
        tiers.pop();

    }

    

    function withdraw() public onlyOwner {
        //require(address(this).balance >= goal, "Goal had not been reached"); 
        checkAndUpdateCampaignState();
        require(state == CampaignState.Successful,"Campaign Is not Yet Successful");
        
        uint256 balance = address(this).balance;
        require(balance > 0,"No balance to withdraw");

        payable(owner).transfer(balance);

    }

    function getContractbalance() public view returns(uint256) {
        return address(this).balance;
    }

    function refund() public {
        checkAndUpdateCampaignState();
        require(state == CampaignState.Failed,"Refunds not available");
        uint256 amount = backers[msg.sender].totalContribution;
        require(amount > 0,"No Contribution to refund");                                                    

        backers[msg.sender].totalContribution = 0;
        payable(msg.sender).transfer(amount);
    }
            
    function hasFundedTier(address _backer, uint256 _tierIndex) public view returns (bool){
        return backers[_backer].fundedTiers[_tierIndex];
    }

    function getTiers() public view returns(Tier[] memory){
        return tiers;
    }

    function togglePaused() public onlyOwner{
        paused = !paused;
    }

    function getCampaignStatus() public view returns(CampaignState){
        if(state == CampaignState.Active && block.timestamp > deadline){
            return address(this).balance >= goal ? CampaignState.Successful : CampaignState.Failed;
        }
        return state;
    }

    function extenDeadline(uint256 _daysToAdd) public onlyOwner campaignOpen {
        deadline += _daysToAdd * 1 days;
    }
}
