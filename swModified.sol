pragma solidity ^0.7.0;

//Using OpenZeppelin library for ownable
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract swModified is Ownable{
    //Player Game state
    uint constant STATUS_WIN = 1;
    uint constant STATUS_LOSE = 2;
    uint constant STATUS_TIE = 3;
    uint constant STATUS_PENDING = 4;
    
    //Game status
    uint constant STATUS_NOT_STARTED = 1;
    uint constant STATUS_STARTED = 2;
    uint constant STATUS_COMPLETE = 3;
    
    uint counter = 1; //Bookkeeping Count... Will keep increasing non-stop
    uint gamePlay = 0;
    
    struct Game{
        uint256 totalAmount;
        uint256 totalInitAmt;
        uint playerCount;
        uint outcome; //Allocate guess number
        uint status;
        address [] playerList;
        uint256 [] betAmount;
    }
    
    //If maximum 5 player
    struct PlayerInfo{
        uint guess;
        uint status;
        uint256 playerAmt; //Stores the wallet balance of this person
    }
    
    mapping(address => PlayerInfo) players;
    
    Game newGame;
    
    function isOwner() internal view returns(bool) {
        return owner() == msg.sender;
    }
    
    function getOwner() internal view returns(address){
        return owner();
    }
    
    function createGame() public onlyOwner{
        newGame = Game(0, 0, 0, 0, STATUS_NOT_STARTED, new address[](0), new uint256[](0));
    }
    
    function addFunds(address _to, uint amount) public onlyOwner{
        players[_to].playerAmt += amount; 
        //payable(_to).transfer(amount);
    } 
    
    modifier gameStartCheck(){
        require(isOwner(), "You do not have the required permission to start.");
        require(newGame.playerCount == 2, "Number of players in game is not met.");
        _;
    }
    
    modifier userAccCheck(address from, uint256 amount){
        require(msg.sender == from, "Unauthorized transaction. You are not the owner of the account");
        require(players[from].playerAmt >= amount, "Insufficient funds. Please top up.");
        _;
    }
    
    modifier fundsAdjust(){
        require(isOwner(), "Unauthorized transaction. Only Admins are allowed to modify funds.");
        _;
    }
    
    function placeBet(address from, uint256 amount, uint guess)public userAccCheck(from, amount){
        require(guess>=1 && guess<=6,"Choose a number from 1 to 6");
        players[from].guess = guess;
        players[from].status = STATUS_PENDING;
        players[from].playerAmt -= amount;
        newGame.playerList.push(from);
        newGame.betAmount.push(amount);
        newGame.totalAmount += amount;
        newGame.totalInitAmt += amount;
        newGame.playerCount++;
    }
    
    //GAME WINNINGS MODIFIED FROM ACTUAL RULE.
    //IF USER WINS, THE RATE WILL BE BONUS OF WHAT THEY CONTRIBUTE.
    function gameStart()public payable gameStartCheck{
        uint luckyNum = rndGenerate(6) + 1; //Since 0 can be generated...
        for(uint i = 0; i < newGame.playerList.length; i++){
            //Check individual bet...
            if(players[newGame.playerList[i]].guess == luckyNum){
                uint rate = newGame.betAmount[i] / newGame.totalInitAmt; //Contribution rate
                uint winnings = newGame.betAmount[i] * (1 + rate);
                newGame.totalAmount -= winnings; //This may result into negative amount if majority wins. 
                allocateFunds(payable(newGame.playerList[i]), winnings);
            } else{
                continue;
            }
        }
        if(newGame.totalAmount > 0){
            allocateFunds(payable(getOwner()), newGame.totalAmount);
        }
        gameEnds();
    }
    
    function renounceOwnership() public override onlyOwner{
        revert("Cannot renounce ownership.");
    }
    
    function gameEnds()internal onlyOwner{
        selfdestruct(payable(getOwner()));
    }
    
    function allocateFunds(address _to, uint amount) public payable fundsAdjust{
        players[_to].playerAmt += amount;
        payable(_to).transfer(amount);
    }
    
    function viewBalance(address acc)public view returns(uint256){
        return players[acc].playerAmt;
    }
    
    //RND Generate dice number
    function rndGenerate(uint mod) public returns(uint){
        counter++; //Cannot be view since we are modifying sth in the function. 
        return uint(keccak256(abi.encodePacked(counter, block.timestamp, block.difficulty, msg.sender))) % mod;
    }
    
    fallback() external payable {}
    //Fallback function
    receive() external payable{
        
    }
}
