var IOUTokenFiat = artifacts.require("IOUTokenFiat");

module.exports = function(deployer) {
	deployer.deploy(IOUTokenFiat, 
								"RohanCoin", "XRC", 5, 100000, 10,
								{
									from: "0x627306090abaB3A6e1400e9345bC60c78a8BEf57",
									gas: 200000,
									gasPrice: 5
								});
}