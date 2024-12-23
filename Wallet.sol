// Solidity-based Token Wallet for Local Blockchain

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TokenWallet {
    mapping(address => uint256) private balances;
    address public owner;

    error Not_Owner();

    event TokensSent(address indexed from, address indexed to, uint256 amount);
    event TokensReceived(address indexed from, uint256 amount);

    // Initialize the wallet with an initial balance
    constructor() {
        owner = msg.sender;
        balances[msg.sender] = 1000; // Assign initial tokens to contract deployer
    }

    modifier Owner(){
        if(msg.sender != owner)
        revert Not_Owner();
        //require(msg.sender == owner," you are not Owner");
        _;
    }

    // Function to send tokens to another address
    function sendTokens(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Cannot send to zero address");

        balances[msg.sender] -= amount;
        balances[to] += amount;

        emit TokensSent(msg.sender, to, amount);
    }

    // Function to receive tokens (add to Owner's balance)
    function receiveTokens(uint256 amount) Owner public {
        require(amount > 0, "Amount must be greater than zero");

        balances[msg.sender] += amount;

        emit TokensReceived(msg.sender, amount);
    }

    // Function to check the balance of an account
    function getBalance(address account) public view returns (uint256) {
        return balances[account];
    }

    // Function to fetch caller's balance
    function getMyBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    
}
