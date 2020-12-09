pragma solidity ^0.7.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract oliver is Ownable {
    
    using SafeMath for uint;
    
    mapping (address => uint256) winnings;
    address payable creator;
    uint256 minbet;
    uint timestamp;
    uint256 balanceNeeded;
    
    
    constructor () public payable {
        creator = msg.sender;
        minbet = 1 ether;
        timestamp = block.timestamp;
        balanceNeeded = 0;
    }
    
    //create a class (either player or bet) and use the mapping of address to winnings for a user-account relationship
    struct Bet {
        address playerAddress;
        uint8 numberChosen;
        uint256 betAmount;
    }
    
    Bet[] public bets;
    Bet[] public winningBets;
    
    event RandomNumber(uint256 number);
    
    //create a bet function 
    //this function must allow users to place bets and ensure there is a sufficient amount in the bank
    //generate a random number 
    //check if user's number matches the random number generated 
    //credit the tokens to the user's account(mapping) with a multiplier of two 
    
    function addEther() public payable {}
    
    function bet(uint8 number, uint256 betAmount) payable public {
        require(msg.value >= minbet);
        require(betAmount == msg.value);
        
        //rolling a dice, so numbers from 1 - 6
        require(number >= 1 && number <= 6);
        
        //multiplier of 2 for the winner, can be changed to higher/lower multiplier
        uint256 payoutForBet = 2 * msg.value;
        uint256 provisionalBalance = balanceNeeded + payoutForBet;
        
        //see if there is enough ether in the contract to payout to the winners of the bet
        require(provisionalBalance < address(this).balance);
        balanceNeeded += payoutForBet;
        bets.push(Bet({
            playerAddress : msg.sender,
            numberChosen : number,
            betAmount : betAmount
        }));
    }
    
    function generateWinningNumber() public {
        //must have at least 1 person betting to play the game 
        require(bets.length > 0);
        require(block.timestamp > timestamp);
        
        //generate random number
        timestamp = block.timestamp;
        uint diff = block.difficulty;
        bytes32 hash = blockhash(block.number-1);
        Bet memory lb = bets[bets.length-1];
        uint number = uint(keccak256(abi.encodePacked(block.timestamp, diff, hash, lb.playerAddress, lb.numberChosen, lb.betAmount))) % 6;
        
        //check every bet to see if anyone won and add to an array of winners 
        for (uint i = 0; i < bets.length; i++) {
            if (bets[i].numberChosen == number) {
                winningBets.push(bets[i]);
            }
        }
        
        //add the amount won to a list of winnings
        for (uint i = 0; i < winningBets.length; i++) {
            winnings[winningBets[i].playerAddress] += 2 * winningBets[i].betAmount;
        }
        
        //reset everything (do I want to create a separate function for this)
        delete bets;
        delete winningBets;
        balanceNeeded = 0;
        emit RandomNumber(number);
        
    }

    //allows the creator of the game to take profits from the game
    function takeProfits() internal {
        uint amount = address(this).balance;
        if (amount > 0) creator.transfer(amount);
    }
    
    //function is self-explanatory from its name
    function cashOut() public {
        address payable player = msg.sender;
        uint256 amount = winnings[player];
        require(amount > 0);
        require(amount <= address(this).balance);
        winnings[player] = 0;
        player.transfer(amount);
    }
    
    //allows the creator to end the game 
    function killGame() public {
        require(creator == msg.sender);
        selfdestruct(creator);
    }
}
