pragma solidity ^0.7.5;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract Tokencreation{
    struct Player{
        uint totaltokens;
        uint bettokens;
        uint selectednr; 
        bool userexists;
    }
    
    mapping(address => Player) playerinfo;
    
    address payable[] globallist;
    
    function EthertoToken() public payable{
        require (msg.value>=1 ether, "Need to change more than 1 Ether");
        require (msg.sender.balance>= msg.value/1 ether,"Not enough funds to convert to Tokens");
        playerinfo[msg.sender].totaltokens+=msg.value/1 ether;
        globallist.push(msg.sender);

    }
    
    function Playertokens() public view returns (uint){
        return playerinfo[msg.sender].totaltokens;
    }
    
    /*   
    function getBalance() public view returns (uint){
        return address(this).balance;
    }
    */

}

contract HollyRollyPolly is Tokencreation{
    using SafeMath for uint;
    
    
    address payable owner;
    address payable[] playerlist;
    address payable[] winnerlist;
    uint tokenpot;
    
    constructor() public{
        owner=msg.sender;
    }
    
  
    
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
    
    function numberofplayers() public view returns (uint){
        return playerlist.length;
    }
    
    function potsize() public view returns (uint){
        return tokenpot;
    }
    
    function gameplay() public payable{
        require(playerlist.length>=1,"Not enough players");
        uint answer = (696969*block.number+block.timestamp)%6 + 1;
        
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
