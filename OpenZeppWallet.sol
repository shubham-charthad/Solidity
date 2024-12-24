// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Wallet is ERC20, Ownable {
    constructor() ERC20("WalletToken", "WTK") Ownable(msg.sender){
        
        _mint(msg.sender, 1000);  //inital supply
    }

    
    function mintTokens(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "Cannot mint to zero address");
        _mint(to, amount);
    }

    
    function transferTokens(address recipient, uint256 amount) public {
        require(balanceOf(msg.sender) >= amount, "Insufficient balance");
        transfer(recipient, amount);
    }

    
    function getBalance(address account) public view returns (uint256) {
        return balanceOf(account);
    }
}
