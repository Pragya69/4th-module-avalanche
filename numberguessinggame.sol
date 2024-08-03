// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./gametoken.sol";

contract NumberGuessingGame {
    GameToken public token; // Reference to the GameToken contract
    uint private secretNumber; // The secret number to guess
    address public admin; // The admin who can control the game
    mapping(address => uint) public attempts; // Track attempts for each player

    // Events to log game activities
    event Guess(address indexed player, bool success, uint remainingAttempts);
    event Reward(address indexed player, uint amount);
    event Penalty(address indexed player, uint amount);

    // Only admin can call functions with this modifier
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    // Constructor sets up the token and admin, and generates a secret number
    constructor(address tokenAddress) {
        token = GameToken(tokenAddress);
        admin = msg.sender;
        generateSecretNumber();
    }

    // Function to generate a new secret number (1 to 10)
    function generateSecretNumber() public onlyAdmin {
        secretNumber = (uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao))) % 10) + 1;
    }

    // Function for players to guess the secret number
    function guessNumber(uint guessedNumber) public {
        // Ensure the guess is valid and the player has attempts left
        require(guessedNumber >= 1 && guessedNumber <= 10, "Guess must be between 1 and 10");
        require(attempts[msg.sender] < 3, "No attempts left");

        attempts[msg.sender]++; // Increment the player's attempt count

        if (guessedNumber == secretNumber) {
            token.mint(msg.sender, 5); // Reward the player with tokens
            emit Reward(msg.sender, 5);
            attempts[msg.sender] = 0;  // Reset attempts after a correct guess
        } else if (attempts[msg.sender] == 3) {
            require(token.balanceOf(msg.sender) >= 1, "Insufficient tokens to deduct");
            token.transferFrom(msg.sender, admin, 1); // Penalize the player with token deduction
            emit Penalty(msg.sender, 1);
            attempts[msg.sender] = 0; // Reset attempts after 3 wrong guesses
        }

        // Log the guess result
        emit Guess(msg.sender, guessedNumber == secretNumber, 3 - attempts[msg.sender]);
    }

    // Function for admin to reset attempts for a player
    function resetAttempts(address player) public onlyAdmin {
        attempts[player] = 0;
    }
}
