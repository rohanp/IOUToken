var IOUTokenFiat = artifacts.require("IOUTokenFiat");

module.exports = function(deployer) {
	deployer.deploy(IOUTokenFiat, 
								"RohanCoin", "XRC", 5, 100000, 10);
}