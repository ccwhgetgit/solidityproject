pragma solidity ^0.7.0;

//Using OpenZeppelin library for ownable
import "@openzeppelin/contracts/access/Ownable.sol";

//In this contract, owner of the contract will simulate as the banker.
//Features to Improve: 
// - Use payable to send money
// - Implement Separate Classes
// - Implement Events

contract swContract is Ownable{
    
    uint minBet = 10;
    uint counter = 0;
    uint winningMultiplier = 1;
    uint randNo = 0;
    // Oracle oracle;
    
    // constructor(address oracleAdd) public{
    //     oracle = Oracle(oracleAdd);
    // }
    
    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;   
    }
    
    function getOwner() internal view returns(address){
        return owner();
    }
    
    //DEBUGGING PURPOSE
    function viewRandom() public view returns(uint){
        return randNo;
    }
    
    //DEBUGGING PURPOSE
    function viewMultiplier()public view returns(uint){
        return winningMultiplier;
    }
    
    mapping(address => uint) public accountAmt;
    
    modifier accOwnerFundCheck(address _from, uint _amount) {
        require(msg.sender == _from && accountAmt[_from] >= _amount, "Transaction failed. Pls check if you are the account ownerand have sufficient funds.");
        _; 
    }
    
    function changeBetAmt(uint _newAmt) public onlyOwner{
        minBet = _newAmt;
    }
    
    //Function is to simulate user adding tokens into their account. Currently user have to go through owner to add. 
    //Possible improvement: Allow user to add themselves. 
    function addAmount(address _who, uint _amount) public onlyOwner{ 
        accountAmt[_who] += _amount;        
    }
    
    //Function is to reduce amount per account after bet. 
    function reduceAmount(address _who, uint _amount) public accOwnerFundCheck(_who, _amount){
        accountAmt[_who] -= _amount;   
    }
    
    //Temp: If a user wins a bet, he win double his amount he bet. Otherwise, he win nth. 
    function bet(address _from, uint _amount, uint luckyNumber) public accOwnerFundCheck(_from, _amount){ //Simulate user betting amount
        require(_amount >= minBet && _from == msg.sender, "Minimum betting amount not met.");
        if(!isOwner()){
            reduceAmount(_from, _amount);
        }
        //Initially transfer account to banker
        accountAmt[getOwner()] += _amount;
        randNo = rndGenerate(6); //Assuming a game of dice, can change overtime for other context.
        if(randNo + 1 == luckyNumber){ //User has own the bet...
            winningMultiplier = rndGenerate(3); //Multiplier is generated when user wins. 
            _amount = _amount * (winningMultiplier + 1);
            //Now transfer winning amount back to user. 
            accountAmt[getOwner()] -= _amount;
            accountAmt[_from] += _amount;
        } else{
            return;
        }
    }
    
    
    //NOT SECURE since it is deterministic... 
    function rndGenerate(uint mod) public returns(uint){
        counter++; //Cannot be view since we are modifying sth in the function. 
        return uint(keccak256(abi.encodePacked(counter, block.timestamp, block.difficulty, msg.sender))) % mod;
    }
    
    function renounceOwnership() public override onlyOwner{
        revert("Cannot renounce ownership.");
    }
    
    receive() external payable{
        
    }
}

// contract Oracle{
//     address admin;
//     uint public rand;
    
//     constructor() public{
//         admin = msg.sender;
//     } 
    
//     function createRandomness(uint _rand) external{
//         require(msg.sender == admin, "Unauthorized access.");
//         rand = _rand;
//     }
// }