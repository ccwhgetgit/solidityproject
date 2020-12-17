pragma solidity ^0.7.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Tokencreation is Ownable{
    using SafeMath for uint;
    
    struct Player{
        uint totaltokens;
        uint bettokens;
        uint selectednr; 
        bool userparticipate;
    }
    
    struct Change{
        bool isChanged;
    }
    mapping(address => Player) playerinfo;
    mapping(address => Change) changes;
    
    
    address payable[] globallist;
    address payable[] temp_globallist;
    
    event changeEthertoToken(address account, uint amount);
    event changeTokentoEther(address account, uint amount);
    
    function EthertoToken() public payable{
        require (msg.value>=1 ether, "Need to change more than 1 Ether");
        require (msg.sender.balance>= msg.value/1 ether,"Not enough funds to convert to Tokens");
        playerinfo[msg.sender].totaltokens+=msg.value/1 ether;
        if(changes[msg.sender].isChanged == false){
            globallist.push(msg.sender);
            changes[msg.sender].isChanged = true;
        }
        emit changeEthertoToken(msg.sender, msg.value/1 ether);
    }
    
    function TokentoEther(uint _xchangetokens) public payable{
        require (_xchangetokens>0, "Need to change more than 1 Token");
        require (playerinfo[msg.sender].totaltokens>= _xchangetokens,"You cannot change out more tokens than you possess");
        playerinfo[msg.sender].totaltokens=playerinfo[msg.sender].totaltokens.sub(_xchangetokens);
        msg.sender.transfer(_xchangetokens*1 ether);
        emit changeTokentoEther(msg.sender, msg.value/1 ether);
    }    
    
    function Playertokens() public view returns (uint){
        return playerinfo[msg.sender].totaltokens;
    }
    
      
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    
    
    function checklength() public view returns (uint){
        return globallist.length;
    }

}

//Each contract will represent a gameplay instance. 
contract HollyRollyPolly is Tokencreation{
    using SafeMath for uint;
    
    
    enum GameState{NOTSTARTED, INPROGRESS, ENDED}
    //address payable owner;
    address payable[] playerlist;
    address payable[] temp_playerlist;
    address payable[] winnerlist;
    uint tokenpot;
    uint counter=1;
    uint betFixed = 0;
    GameState state = GameState.NOTSTARTED;
    
    // constructor() public{
    //     owner=msg.sender;
    // }
    
    event randomStart();
    event playerParticipate(address player, uint betAmount, uint guessNumber);
    event distributeWinnings(address player, uint winnings);
    event earnings(address player, uint winnings);
    event playerLeft(address player, bool participate);
    
    function rndGenerate(uint mod) internal returns(uint){
        counter++; //Cannot be view since we are modifying sth in the function.
        emit randomStart();
        return uint(keccak256(abi.encodePacked(counter, block.timestamp, block.difficulty, msg.sender))) % mod;
    }
    
    function participate(uint _nroftokens, uint _numselected) public payable {
        require(betFixed == 0 || _nroftokens == betFixed, "Please bet tokens according to the bet allocated to room.");
        require(_nroftokens>0,"Need to bet more than 0");
        require(!playerinfo[msg.sender].userparticipate,"Player is already inside the game");
        require(playerinfo[msg.sender].totaltokens>= _nroftokens,"You have bet more tokens than you have in your account");
        require(_numselected>=1 && _numselected<=6,"Choose a number from 1 to 6");
        if(betFixed == 0){ //Set the base template bet of the room.
            betFixed = _nroftokens;
        }
        playerlist.push(msg.sender);
        playerinfo[msg.sender].bettokens=_nroftokens;
        playerinfo[msg.sender].selectednr=_numselected;
        tokenpot=tokenpot.add(_nroftokens);
        playerinfo[msg.sender].totaltokens=playerinfo[msg.sender].totaltokens.sub(_nroftokens);
        playerinfo[msg.sender].userparticipate=true;
        emit playerParticipate(msg.sender, _nroftokens, _numselected);
    }
    
    function leave() public payable {
        require(msg.sender!=owner(),"The Owner cannot leave the lobby");
        
       //Common code whether in game or not in game 
        //remove from globallist (using a crude for loop method because pop functionality in solidity cannot pop specified element)
        for (uint j=0; j<globallist.length; j++){
            address payable userAddress=globallist[j];
            if (userAddress!=msg.sender){
            temp_globallist.push(userAddress);  
            }
        }
        globallist=temp_globallist;
        //isChanged part fix
        changes[msg.sender].isChanged = false;
        
        //User already inside the game 
        //if participate, wont get the betted tokens back to decentivise people from freely exiting after putting a bet
        //therefore I reactivated the if tokenpot!=0 part so the owner gets the tokens betted by the person who left despite participating
       if (playerinfo[msg.sender].userparticipate==true){
         //remove from playerlist 
        for (uint i=0; i<playerlist.length; i++){
            address payable userAddress=playerlist[i];
            if (userAddress!=msg.sender){
            temp_playerlist.push(userAddress);  
            }
        }
        playerlist=temp_playerlist;
        
        if (playerinfo[msg.sender].totaltokens!=0){
           TokentoEther(playerinfo[msg.sender].totaltokens); 
        }

        playerinfo[msg.sender].bettokens=0;
        playerinfo[msg.sender].selectednr=0;
        playerinfo[msg.sender].userparticipate=false;
        emit playerLeft(msg.sender,true); 
       }
       
       //User not in game
       else{
         TokentoEther(playerinfo[msg.sender].totaltokens);
         emit playerLeft(msg.sender,false); 
       }
        
        
    }
    //what happens if its the owner who tries to leave prematurely? --For now cos not sure about bot banker implementation I just prevent owner from leaving 
    
    function numberofplayers() public view returns (uint){
        return playerlist.length;
    }
    
    //Gives the addressess of the participants (fyi NOT globallist) 
    function displayPlayerList() public view returns (address payable[] memory){
        return globallist;
    }
    
    function check() public view returns(uint){
        return playerinfo[msg.sender].bettokens;
    }
    
    function potsize() public view returns (uint){
        return tokenpot;
    }
    
    //Only owner can start the game...
    function gameplay() public payable onlyOwner{
        require(playerlist.length>=1,"Not enough players");
        require(state == GameState.NOTSTARTED, "Game is either in progress or has ended. Please start a new game.");
        state = GameState.INPROGRESS;
        //uint answer = rndGenerate(6) + 1;
        uint answer = 2;
        
        uint winnertottokens;
        for (uint i=0; i<playerlist.length;i++){
            address payable playerAddress=playerlist[i];
            if (playerinfo[playerAddress].selectednr==answer){
                winnerlist.push(playerAddress);
                winnertottokens+=playerinfo[playerAddress].bettokens;
            }
        }
        if (winnerlist.length==0){
            for (uint i=0; i<globallist.length;i++){
            address payable playerAddress=globallist[i];
                if (playerinfo[playerAddress].totaltokens>0){
                    playerAddress.transfer(playerinfo[playerAddress].totaltokens*1 ether);
                }
            }
        }
        else{
           uint payout = tokenpot / winnerlist.length;
           for (uint j=0; j<winnerlist.length; j++){
              address payable winnerAddress=winnerlist[j];
              //uint payout=(tokenpot/winnertottokens)*playerinfo[winnerAddress].bettokens;
              tokenpot=tokenpot.sub(payout);
              playerinfo[winnerAddress].totaltokens=playerinfo[winnerAddress].totaltokens.add(payout);
           } 
           if (tokenpot!=0){
               playerinfo[payable(owner())].totaltokens=playerinfo[payable(owner())].totaltokens.add(tokenpot);
               tokenpot=0;
           }
           
            for (uint i=0; i<globallist.length;i++){
                address payable playerAddress=globallist[i];
                if (playerinfo[playerAddress].totaltokens>0){
                    playerAddress.transfer(playerinfo[playerAddress].totaltokens*1 ether);
                }
            }
        }
        state = GameState.ENDED;
        selfdestruct(payable(owner()));
    }
}
