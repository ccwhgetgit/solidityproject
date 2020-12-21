pragma solidity ^0.7.5;

import "./SafeMath.sol";
import "./Ownable.sol";

//Basic Contract Room creation + Limit seems to be working. Pending implementation for playerJoinRoom...
contract Factory{
    HollyRollyPolly [] public rooms; //Using pointers
    HollyRollyPolly [] public tempRooms; //Used as temporary storage for closing rooms. 
    uint maxFacLimit = 2;
    HollyRollyPolly [] public historyRooms; //Rooms that are self-destructed.
    
    struct PlayerInfo{
        bool inRoom;
    }
    
    modifier clearTempList{
        if(tempRooms.length!=0){
            delete tempRooms;
        }
        _;
    }
    
    function createRooms()public{
        require(rooms.length < maxFacLimit, "Maximum Capacity reached. Please wait...");
        HollyRollyPolly newRm = new HollyRollyPolly();
        rooms.push(newRm);
    }
    
    //Not sure for this to put in procedure of HRP 
    function playerJoinRoom(HollyRollyPolly rm) public{
        
    }
    
    //Close room.
    function closeRoom(HollyRollyPolly rm)public clearTempList{ //Runs in O(n) time. 
        for(uint i = 0; i < maxFacLimit; i++){
            if(rm == rooms[i]){
                historyRooms.push(rm);
                continue; //Skip this because this is going to be stored in history. 
            } else{
                tempRooms.push(rooms[i]);
            }
        }
        rooms = tempRooms; //Overwrite existing rooms with temp rooms. 
    }
    
    //Display all available rooms in lobby.
    function dispLobby() public view returns(HollyRollyPolly [] memory hrp){
        return rooms;
    } 
    
    //Display total number of existing rooms.     
    function getTotalRooms() public view returns (uint){
        return rooms.length;
    }
    
}

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
    uint startTime;
    GameState state = GameState.NOTSTARTED;
    
    // constructor(address newOwner) public{
    //     owner = newOwner;
    // }
    
    event randomStart();
    event playerParticipate(address player, uint betAmount, uint guessNumber);
    event distributeWinnings(address player, uint winnings);
    event earnings(address player, uint winnings);
    event playerLeft(address player, bool participate);
    
    modifier tempListClear(){
        if(temp_playerlist.length!=0){
            delete temp_playerlist;
        }
        if(temp_globallist.length!=0){
            delete temp_globallist;
        }
        _;
    }
    
    function rndGenerate(uint mod) internal returns(uint){
        counter++; //Cannot be view since we are modifying sth in the function.
        emit randomStart();
        return uint(keccak256(abi.encodePacked(counter, block.timestamp, block.difficulty, msg.sender))) % mod;
    }
    
    function changeRmOwner(address newOwner) public onlyOwner{
        require(!playerinfo[payable(newOwner)].userparticipate, "The new owner cannot participate in-game. Ensure that bet is removed before switching owner.");
        transferOwnership(newOwner);
    }
    
    function removeBet() public tempListClear{
        require(playerinfo[msg.sender].userparticipate,"Cannot remove bet if user not in game");
        tokenpot = tokenpot.sub(playerinfo[msg.sender].bettokens);
        playerinfo[msg.sender].totaltokens=playerinfo[msg.sender].totaltokens.add(playerinfo[msg.sender].bettokens);
        playerinfo[msg.sender].bettokens = 0;
        playerinfo[msg.sender].selectednr= 0;
        playerinfo[msg.sender].userparticipate=false;
        for (uint i=0; i<playerlist.length; i++){
            address payable userAddress=playerlist[i];
            if (userAddress!=msg.sender){
                temp_playerlist.push(userAddress);  
            }
        }
        playerlist=temp_playerlist;
    }
    
    //Banker is not inclusive of no. of players. They either win all of players bet or win nth. 
    function participate(uint _nroftokens, uint _numselected) public payable {
        require(msg.sender != owner(), "Room owner cannot participate in a bet.");
        require(betFixed == 0 || _nroftokens == betFixed, "Please bet tokens according to the bet allocated to room.");
        require(_nroftokens>0,"Need to bet more than 0");
        require(!playerinfo[msg.sender].userparticipate,"Player is already inside the game");
        require(playerinfo[msg.sender].totaltokens>= _nroftokens,"You have bet more tokens than you have in your account");
        require(_numselected>=1 && _numselected<=6,"Choose a number from 1 to 6");
        if(betFixed == 0){ //Set the base template bet of the room.
            betFixed = _nroftokens;
            startTime=block.timestamp;
        }
        playerlist.push(msg.sender);
        playerinfo[msg.sender].bettokens=_nroftokens;
        playerinfo[msg.sender].selectednr=_numselected;
        tokenpot=tokenpot.add(_nroftokens);
        playerinfo[msg.sender].totaltokens=playerinfo[msg.sender].totaltokens.sub(_nroftokens);
        playerinfo[msg.sender].userparticipate=true;
        emit playerParticipate(msg.sender, _nroftokens, _numselected);
    }
    
    function leave() public payable tempListClear{
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
       if (playerinfo[msg.sender].userparticipate==true){
        removeBet();
        emit playerLeft(msg.sender,true); 
       }
       
       //User not in game
       else{
         TokentoEther(playerinfo[msg.sender].totaltokens);
         emit playerLeft(msg.sender,false); 
       }
        
        
    }
    
    function numberofplayers() public view returns (uint){
        return playerlist.length;
    }
    
    //Gives the addressess of the participants (fyi NOT globallist) 
    function displayPlayerList() public view returns (address payable[] memory){
        return playerlist;
    }
    
    //function check() public view returns(uint){
        //return playerinfo[msg.sender].bettokens;
    //}
    
    function potsize() public view returns (uint){
        return tokenpot;
    }
    
    //Only owner can start the game...
    function gameplay() public payable onlyOwner{
        //remember to change settings, currently set for debugging purposes 
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
           //if (tokenpot!=0){
           //   playerinfo[payable(owner())].totaltokens=playerinfo[payable(owner())].totaltokens.add(tokenpot);
           //   tokenpot=0;
           //}
           
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
    
    //function startTimeCheck() public view returns (uint){
    //    return startTime;
    //}
    
    function contractExpiry() public payable onlyOwner{
        require(block.timestamp>startTime+30 minutes && startTime!=0 ,"Contract has not expired");
        for (uint i=0; i<globallist.length;i++){
            address payable playerAddress=globallist[i];
            if (playerinfo[playerAddress].totaltokens>0){
                playerAddress.transfer(playerinfo[playerAddress].totaltokens*1 ether);
            }
        }
        selfdestruct(payable(owner()));
    }
    
}