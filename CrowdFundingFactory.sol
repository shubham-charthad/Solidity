// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import{Crowdfunding} from "contracts/Crowdfunding.sol";

/**
 * @title CrowdfundingFactory
 * @dev This contract allows users to create and manage decentralized crowdfunding campaigns.
 * It serves as a factory for deploying individual Crowdfunding contracts and maintains a 
 * record of all created campaigns.
 
 * Features:
 * - Campaign Creation: Deploys new Crowdfunding contracts with specified name, goal, and duration.
 * - Campaign Tracking: Stores a global list of all campaigns and user-specific campaigns.
 * - Pause Functionality: Allows the owner to pause or resume campaign creation.
 * - Access Control: Restricts certain functions to the contract owner.
 */

contract CrowdfundingFactory {
    address public owner;
    bool public paused;

    struct Campaign {
        address campaignAddress;
        address owner;
        string name;
        uint256 creationTime;
    }

    Campaign[] public campaigns;
    mapping (address => Campaign[]) public userCampaigns;

    modifier onlyOwner() {
        require(msg.sender == owner,"Not Owner");
        _;
    }

    modifier notPaused() {
        require(!paused,"Factory is paused");
        _;
    }

    constructor(){
        owner = msg.sender;
    }

    function createCampaign(
        string memory _name,
        string memory _description,
        uint256 _goal,
        uint256 _durationInDays
    ) external notPaused {
        Crowdfunding newCampaign = new Crowdfunding(
            msg.sender,
            _name,
            _description,
            _goal,
            _durationInDays
        );
        address campaignAddress = address(newCampaign);

        Campaign memory campaign = Campaign({
            campaignAddress: campaignAddress,
            owner: msg.sender,
            name: _name,
            creationTime: block.timestamp
        });                                                   

        campaigns.push(campaign);
        userCampaigns[msg.sender].push(campaign);
    }

    function getUserCampaigns(address _user) external view returns (Campaign[] memory){
        return userCampaigns[_user];
    }

    function getAllCampaigns() external view returns (Campaign[] memory){
        return campaigns;
    } 

    function togglePaused() external onlyOwner {
        paused = !paused;
    }
}
