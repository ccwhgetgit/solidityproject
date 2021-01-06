pragma solidity ^0.7.0;
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery {
  using SafeMath for uint;
  address public manager;
  address[] public players;

  constructor() public {
    manager = msg.sender;
  }

  function enter() public payable {
    require(msg.value > .01 ether);
    players.push(msg.sender);
  }

  function random() private view returns (uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
  }

  function pickWinner() public {
    uint index = random() % players.length;
    payable(players[index]).transfer(address(this).balance);
    players = new address[](0);
  }

  function getPlayers() public view returns (address[] memory) {
    return players;
  }
}