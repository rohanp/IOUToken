/*
var IOUTokenFiat = artifacts.require("IOUTokenFiat");

contract('IOUTokenFiat', accounts => {
	console.log(accounts);
	it("should put 100000 XRC in the first account", () => {
		return IOUTokenFiat.deployed().then(instance => {
			return instance.balanceOf(accounts[0]);
		}).then(balance => {
			assert.equal(balance.valueOf(), 100000, "100000 was not in the first account")
		})
	}
})
*/