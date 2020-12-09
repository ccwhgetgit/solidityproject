pragma solidity ^0.5;
contract lotteryGame {
    
    address payable owner; //sets up address of the house
    
    uint minWager = 1 ether; //min amount to be betted
    
    uint totalBetted = 0; //total pool of money 
    
    uint numberOfWagers = 0;
    
    uint constant maxPlayers = 5; //max number of players allowed in each game 
    
    uint winningNumber = uint(keccak256(abi.encodePacked(block.timestamp))) % maxNumber;
    uint constant maxNumber = 10; //range
    
    address payable [] playerAddresses;
   
   
     struct Player {
        uint amountBetted;
        uint numberBetted;
    }
    
    mapping(address => Player) playerDetails;
    
     constructor(uint _minWager) public {
        owner = msg.sender;
        if (_minWager >0) minWager = _minWager;
        }
 
    function bet(uint number) public payable {
     
   
        require(number >=1 && number <= maxNumber, "bet within the range ");
             
        require( msg.value  >= minWager, "dont be stingy, the min bet is higher" );
       
        playerDetails[msg.sender].amountBetted = msg.value;
        playerDetails[msg.sender].numberBetted = number;
       
    
        numberOfWagers++;
        totalBetted += msg.value;
        
         if (numberOfWagers >= maxPlayers) {
            announceWinners();
         }
         
}

    function announceWinners() private {
    
       
        address payable[maxPlayers] memory winners;
        uint winnerCount = 0;
        uint totalWinningWager = 0;
      
        for (uint i=0; i < playerAddresses.length; i++) {
           
            address payable playerAddress = playerAddresses[i];
        
            if (playerDetails[playerAddress].numberBetted == winningNumber) {
                winners[winnerCount] = playerAddress;
                
                totalWinningWager += playerDetails[playerAddress].amountBetted;
                winnerCount++;
} }
        // make payments to each winning player
        for (uint j=0; j<winnerCount; j++) {
            winners[j].transfer((playerDetails[winners[j]].amountBetted /totalWinningWager) * totalBetted);
} }

    function kill() public {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
}
//end the contract 

    function getWinningNumber() view public returns (uint) {
        return winningNumber;
}
 

    
}
