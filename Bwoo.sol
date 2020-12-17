pragma solidity ^0.7.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract Tokencreation is Ownable{
    using SafeMath for uint;
    
    struct Player{
        uint totaltokens;
        uint bettokens;
        uint selectednr; 
        bool userexists;
    }
    
    struct Change{
        bool isChanged;
    }
    mapping(address => Player) playerinfo;
    mapping(address => Change) changes;
    
    
    address payable[] globallist;
    
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
    
    function rndGenerate(uint mod) internal returns(uint){
        counter++; //Cannot be view since we are modifying sth in the function.
        emit randomStart();
        return uint(keccak256(abi.encodePacked(counter, block.timestamp, block.difficulty, msg.sender))) % mod;
    }
    
    function participate(uint _nroftokens, uint _numselected) public payable {
        require(betFixed == 0 || _nroftokens == betFixed, "Please bet tokens according to the bet allocated to room.");
        require(_nroftokens>0,"Need to bet more than 0");
        require(!playerinfo[msg.sender].userexists,"Player is already inside the game");
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
        playerinfo[msg.sender].userexists=true;
        emit playerParticipate(msg.sender, _nroftokens, _numselected);
    }
    
    function numberofplayers() public view returns (uint){
        return playerlist.length;
    }
    
    function potsize() public view returns (uint){
        return tokenpot;
    }
    
    //Only owner can start the game...
    function gameplay() public payable onlyOwner{
        require(playerlist.length>=3,"Not enough players");
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
        //   if (tokenpot!=0){
        //       playerinfo[owner].totaltokens=playerinfo[owner].totaltokens.add(tokenpot);
        //       tokenpot=0;
        //   }
           
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