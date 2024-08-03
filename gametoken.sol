// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract GameToken {
    // Public variables to store the token name, symbol, and total supply
    string public name = "The NumWarrior";
    string public symbol = "TNWR";
    uint public totalSupply;

    // Mappings to store balances and allowances
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    // Events to log transfers and approvals
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    // Constructor to mint initial tokens to the contract creator
    constructor() {
        mint(msg.sender, 1000);
    }

    // Function to mint new tokens
    function mint(address to, uint amount) public {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    // Function to transfer tokens to another address
    function transfer(address to, uint amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    // Function to approve an allowance for another address
    function approve(address spender, uint amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Function to transfer tokens from one address to another using an allowance
    function transferFrom(address from, address to, uint amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(allowance[from][msg.sender] >= amount, "Allowance exceeded");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        allowance[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }
}
