var Lottery = artifacts.require("./HollyRollyPolly.sol");

module.exports = function(deployer){
    deployer.deploy(Lottery);
}