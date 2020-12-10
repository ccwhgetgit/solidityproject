pragma solidity ^0.7.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//Update Rev 1.01
//Resolved: 
//Remove use of GlobalList since playerInfo is similar to that.
//Implement Game Structure such that each room will have its own history.
//Implemented additional checks such that room is not overloaded and room owner can only start the game.
//
//NOT RESOLVED:
//Previous game data will be overwritten if a new game is being created. Need to think of a way to store this history.
//Payout can be in decimal places, hence players may not be creditted correctly.

//Part 1: Creation of the Tokenisation system 

contract Tokencreation is Ownable{
    struct Player{
        uint totaltokens;
        uint bettokens;
        uint selectednr; 
        bool userexists;
    }
    
    mapping(address => Player) playerinfo; //This will simulate all players. 
    
    //Function ethertotoken is to change ether to tokens 
    function exchangeToken() public payable{
        require (msg.value>=1 ether, "Need to change more than 1 Ether");
        require (msg.sender.balance>= msg.value/1 ether,"Not enough funds to convert to Tokens");
        playerinfo[msg.sender].totaltokens+=msg.value/1 ether;
        //globallist.push(msg.sender);
    }
    
    //Function to check how many tokens the player has in his/her own "mini" token wallet  
    function viewBalance() public view returns (uint){
        return playerinfo[msg.sender].totaltokens;
    }
}

//Part 2: Actual implementation of the HollyRollyPolly Game 

contract HollyRollyPolly is Tokencreation{
    using SafeMath for uint;
    
    bool gameExist = false;
    enum GameState{NOTSTARTED, INPROGRESS, ENDED}
    struct Game{
        address owner; //Game Admin of that room
        address [] playerlist;
        address [] winnerlist;
        uint tokenpot;
        uint counter;
        uint luckyNumber;
        GameState gamestate;
    }
    
    Game newGame;
    
    function createGame()public onlyOwner{ 
        newGame = Game(owner(), new address[](0), new address[](0), 0, 0, 0, GameState.NOTSTARTED);
        gameExist = true;
    }
    
    function rndGenerate(uint mod) internal returns(uint){
        newGame.counter++; //Cannot be view since we are modifying sth in the function. 
        return uint(keccak256(abi.encodePacked(newGame.counter, block.timestamp, block.difficulty, msg.sender))) % mod;
    }
    
    function showLuckyNumber()public view returns(uint){
        return newGame.luckyNumber;
    }
    
    function checkGameState()internal view returns(GameState){
        return newGame.gamestate;
    }
    
    //Function for participation in the game. Player pushed to participating array.
    //Due to high computation for array load, number of players in a room cannot be large. 
    function participate(uint _nroftokens, uint _numselected) public payable {
        require(gameExist == true, "No game exist. Please create a new game.");
        require(newGame.playerlist.length < 5, "Maximum number of players reached. Please join another room.");
        require(newGame.gamestate == GameState.NOTSTARTED, "Game is either in progress or has ended. Please start a new game.");
        require(_nroftokens>0 ,"Need to bet more than 0");
        require(!playerinfo[msg.sender].userexists,"Player is already inside the game");
        require(playerinfo[msg.sender].totaltokens>= _nroftokens,"You have bet more tokens than you have in your account");
        require(_numselected>=1 && _numselected<=6,"Choose a number from 1 to 6");
        newGame.playerlist.push(msg.sender);
        playerinfo[msg.sender].bettokens=_nroftokens;
        playerinfo[msg.sender].selectednr=_numselected;
        newGame.tokenpot=newGame.tokenpot.add(_nroftokens);
        playerinfo[msg.sender].totaltokens=playerinfo[msg.sender].totaltokens.sub(_nroftokens);
        playerinfo[msg.sender].userexists=true;
    }
    
    //numplayers and potsize are mainly debugging features. Can change out of public view subsequently/remove altogether
    function numberofplayers() public view returns (uint){
        return newGame.playerlist.length;
    }
    
    function potsize() public view returns (uint){
        return newGame.tokenpot;
    }
    
    //Only owner can start the room. If this room has started before, it cannot be started again! Create a new game! 
    function gameplay() public payable onlyOwner{
        require(newGame.playerlist.length>=3,"Not enough players");
        require(newGame.gamestate == GameState.NOTSTARTED, "Game is either in progress or has ended. Please start a new game.");
        newGame.gamestate = GameState.INPROGRESS;
        uint answer = rndGenerate(1) + 1;
        newGame.luckyNumber = answer;
        uint winnertottokens;
        //Check for guess number matching RND number
        for (uint i=0; i<newGame.playerlist.length;i++){
            address payable playerAddress=payable(newGame.playerlist[i]);
            if (playerinfo[playerAddress].selectednr==answer){
                newGame.winnerlist.push(playerAddress);
                winnertottokens+=playerinfo[playerAddress].bettokens;
            }
        }
        //If there is no winner in the list, winnings will be given to owner...  
        if (newGame.winnerlist.length==0){
            payable(newGame.owner).transfer(newGame.tokenpot * 1 ether);
            playerinfo[payable(newGame.owner)].totaltokens = playerinfo[payable(newGame.owner)].totaltokens.add(newGame.tokenpot);
        }
        else{
            //Temporary measure where winners will be assigned equally if they win. 
            uint payout = newGame.tokenpot / newGame.winnerlist.length;
            for (uint j=0; j<newGame.winnerlist.length; j++){
              address payable winnerAddress=payable(newGame.winnerlist[j]);
              //uint payout=(newGame.tokenpot/winnertottokens)*playerinfo[winnerAddress].bettokens;
              newGame.tokenpot=newGame.tokenpot.sub(payout);
              //if (newGame.tokenpot!=0){
              //playerinfo[payable(owner())].totaltokens=playerinfo[payable(owner())].totaltokens.add(newGame.tokenpot);
                //newGame.tokenpot=0;
              //}
              playerinfo[winnerAddress].totaltokens=playerinfo[winnerAddress].totaltokens.add(payout);
              winnerAddress.transfer(playerinfo[winnerAddress].totaltokens*1 ether);
           }
        }
        newGame.gamestate = GameState.ENDED;
        gameExist = false;
    }
}