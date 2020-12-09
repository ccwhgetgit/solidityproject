pragma solidity ^0.7.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

//Part 1: Creation of the Tokenisation system 

contract Tokencreation{
    struct Player{
        uint totaltokens;
        uint bettokens;
        uint selectednr; 
        bool userexists;
    }
    
    mapping(address => Player) playerinfo;
    
    //Globallist includes all users who have changed x amount of ether for y amount of tokens. May or may not be participating in the game 
    address payable[] globallist;
    
    //Function ethertotoken is to change ether to tokens 
    function EthertoToken() public payable{
        require (msg.value>=1 ether, "Need to change more than 1 Ether");
        require (msg.sender.balance>= msg.value/1 ether,"Not enough funds to convert to Tokens");
        playerinfo[msg.sender].totaltokens+=msg.value/1 ether;
        globallist.push(msg.sender);

    }
    
    //Function to check how many tokens the player has in his/her own "mini" token wallet  
    function Playertokens() public view returns (uint){
        return playerinfo[msg.sender].totaltokens;
    }
    
    //Just a debugging function to see total ethers in the smart contract (Dont mix up with total tokens bet in the tokenpot) 
    /*   
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    */

}

//Part 2: Actual implementation of the HollyRollyPolly Game 

contract HollyRollyPolly is Tokencreation{
    using SafeMath for uint;
    
    
    address payable owner;
    address payable[] playerlist;
    address payable[] winnerlist;
    uint tokenpot;
    uint counter=1;
    
    constructor() public{
        owner=msg.sender;
    }
    
    function rndGenerate(uint mod) internal returns(uint){
        counter++; //Cannot be view since we are modifying sth in the function. 
        return uint(keccak256(abi.encodePacked(counter, block.timestamp, block.difficulty, msg.sender))) % mod;
    }
    
    //Function for participation in the game. Player pushed to participating array
    function participate(uint _nroftokens, uint _numselected) public payable {
        require(_nroftokens>0 ,"Need to bet more than 0");
        require(!playerinfo[msg.sender].userexists,"Player is already inside the game");
        require(playerinfo[msg.sender].totaltokens>= _nroftokens,"You have bet more tokens than you have in your account");
        require(_numselected>=1 && _numselected<=6,"Choose a number from 1 to 6");
        playerlist.push(msg.sender);
        playerinfo[msg.sender].bettokens=_nroftokens;
        playerinfo[msg.sender].selectednr=_numselected;
        tokenpot=tokenpot.add(_nroftokens);
        playerinfo[msg.sender].totaltokens=playerinfo[msg.sender].totaltokens.sub(_nroftokens);
        playerinfo[msg.sender].userexists=true;
    }
    
    //numplayers and potsize are mainly debugging features. Can change out of public view subsequently/remove altogether
    function numberofplayers() public view returns (uint){
        return playerlist.length;
    }
    
    function potsize() public view returns (uint){
        return tokenpot;
    }
    
    function gameplay() public payable{
        require(playerlist.length>=5,"Not enough players");
        uint answer = rndGenerate(6) + 1;
        
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
        selfdestruct(owner);
        }
        else{
           for (uint j=0; j<winnerlist.length; j++){
              address payable winnerAddress=winnerlist[j];
              uint payout=(tokenpot/winnertottokens)*playerinfo[winnerAddress].bettokens;
              tokenpot=tokenpot.sub(payout);
              playerinfo[winnerAddress].totaltokens=playerinfo[winnerAddress].totaltokens.add(payout);
           } 
           if (tokenpot!=0){
               playerinfo[owner].totaltokens=playerinfo[owner].totaltokens.add(tokenpot);
               tokenpot=0;
           }
           
            for (uint i=0; i<globallist.length;i++){
            address payable playerAddress=globallist[i];
            if (playerinfo[playerAddress].totaltokens>0){
                playerAddress.transfer(playerinfo[playerAddress].totaltokens*1 ether);
            }
        }
        selfdestruct(owner);
           
        }
    }
    
   
  

}
