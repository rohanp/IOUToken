var token = artifacts.require('IOUTokenFiat');

contract('IOUTokenFiat', accounts => {

	it("should put 100000 iou in the first account", async () => {
		let t = await token.deployed();
		let balance = await t.balanceOf.call(accounts[0]);

		assert.equal(balance.valueOf(), 100000);
	})

	it("should send coin correctly", async () => {
		let t = await token.deployed();
		const amount = 1000;

		await t.transfer(accounts[1], 1000, {from: accounts[0]})
		let balance = await t.balanceOf.call(accounts[1]);
		
		// this might fail if the network is congested bc interest
		console.log(balance.valueOf());
		assert(balance.valueOf() == amount);
	})

	it("should compute interest properly", async () => {
		let t = await token.deployed();
		const amount = 1000;

		await t.transfer(accounts[1], amount, {from: accounts[0]})
		let interest = await t.calculateInterest.call(accounts[1]);

		console.log(interest.valueOf());
	})
	/*
	it("should should repay coin correctly", async () => {
		let t = await token.deployed();

		await t.transfer(accounts[1], 1000, {from: accounts[0]});
		await t.repay(1000, {from: accounts[1]});

		let balance = await t.balanceOf.call(accounts[1]);
		assert(balance.valueOf() < 5);

		let totalSupply = await t.totalSupply.call(accounts[0]);
		assert(totalSupply < 100000);
	})*/

})