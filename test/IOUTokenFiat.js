var token = artifacts.require('IOUTokenFiat');

const initialAmount = 100000; // set in migrations
const amount = 1000;
const daysToAdv = 100;
const apr = 5;

contract('IOUTokenFiat', accounts => {

	it("should put 100000 iou in the first account", async () => {
		let t = await token.deployed();
		let balance = await t.balanceOf.call(accounts[0]);
		assert.equal(balance.valueOf(), initialAmount); 
	})

})

contract('IOUTokenFiat', accounts => {
	it("should send coin correctly", async () => {
		let t = await token.deployed();
		let balance1Before = await t.balanceOf.call(accounts[1]);

		await t.transfer(accounts[1], amount, {from: accounts[0]})
		let balance1 = await t.balanceOf.call(accounts[1]);
		let balance0 = await t.balanceOf.call(accounts[0]);
		
		// this may fail if there is large time gap between transfer
		// and balanceOf calls 
		assert.equal(balance1Before.valueOf(), 0);
		assert.equal(balance1.valueOf(), amount);
		assert.equal(balance0.valueOf(), initialAmount - amount);
	})
})

contract('IOUTokenFiat', accounts => {

	it("should repay coin correctly", async () => {
		let t = await token.deployed();

		await t.transfer(accounts[1], amount, {from: accounts[0]});
		await t.repay(amount, {from: accounts[1]});

		let balance = await t.balanceOf.call(accounts[1]);
		assert.equal(balance.valueOf(), 0);

		let totalSupply = await t.totalSupply.call();
		assert.equal(totalSupply, initialAmount - amount);
	})

})

contract('IOUTokenFiat', accounts => {

	let interest;

	it("should compute interest approximately correctly", async () => {
		let t = await token.deployed();
		const daysToAdv = 100;
		const expectedInterest = amount * (1 + 5/100/365) ** daysToAdv - amount;

		await t.transfer(accounts[1], amount, {from: accounts[0]});
		//console.log("timestamp: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp)
		await timeTravel(60 * 60 * 24 * daysToAdv);
		// need too mine block to adv time
		await t.transfer(accounts[3], 10, {from: accounts[0]});

		//console.log("timestamp: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp)
		interest = await t.calculateInterest.call(accounts[1]);
		//console.log("interest: " + interest.valueOf())
		//console.log("expectedInterest: " + expectedInterest)

		assert(Math.abs(expectedInterest - interest.valueOf()) < 1);
		//balance = await t.calculateInterest.call(accounts[1]);
		//console.log(balance.valueOf());
	})

})


contract('IOUTokenFiat', accounts => {

	let balance;

	it("should put 100000 iou in the first account", async () => {
		let t = await token.deployed();
		balance = await t.balanceOf.call(accounts[0]);
		assert.equal(balance.valueOf(), initialAmount); 
	})

	it("should send coin correctly", async () => {
		let t = await token.deployed();

		await t.transfer(accounts[1], amount, {from: accounts[0]})
		let balance1 = await t.balanceOf.call(accounts[1]);
		let balance0 = await t.balanceOf.call(accounts[0]);
		
		// this may fail if there is large time gap between transfer
		// and balanceOf calls 
		assert.equal(balance1.valueOf(), amount);
		assert.equal(balance0.valueOf(), initialAmount - amount);
	})

	it("should add interest approximately correctly", async () => {
		let t = await token.deployed();
		const expectedInterest = getInterest(amount, daysToAdv);

		//console.log("timestamp: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp)
		await timeTravel(60 * 60 * 24 * daysToAdv);
		// need too mine block to adv time
		await t.transfer(accounts[3], 10, {from: accounts[0]});

		//console.log("timestamp: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp)
		interest = await t.calculateInterest.call(accounts[1]);
		balance = await t.balanceOf.call(accounts[1]);
		//console.log("interest: " + interest.valueOf())
		//console.log("expectedInterest: " + expectedInterest)

		assert(Math.abs(expectedInterest - interest.valueOf()) < 1);
		assert(Math.abs(balance.valueOf() - (amount + expectedInterest)) < 1);

		//balance = await t.calculateInterest.call(accounts[1]);
		//console.log(balance.valueOf());
	})

	it("should repay coin correctly", async () => {
		let t = await token.deployed();

		await t.repay(balance, {from: accounts[1]});

		balance = await t.balanceOf.call(accounts[1]);
		assert.equal(balance.valueOf(), 0);

		let totalSupply = await t.totalSupply.call();
		assert.equal(totalSupply, initialAmount - amount);
	})

	it("should not award interest after funds have left", async () => {
		let t = await token.deployed();

		balance = await t.balanceOf.call(accounts[1]);
		assert.equal(balance.valueOf(), 0);

		await timeTravel(60 * 60 * 24 * daysToAdv);
		// need too mine block to adv time
		await t.transfer(accounts[3], 10, {from: accounts[0]});

		balance = await t.balanceOf.call(accounts[1]);
		assert.equal(balance.valueOf(), 0);
	})

	it("should add interest correctly across multiple transations", async () => {
		let t = await token.deployed();
		const daysToAdv1 = 800; 
		const amount1 = 100;
		const daysToAdv2 = 200
		const amount2 =  5000;
		let expectedBalance = amount1;


		await t.transfer(accounts[1], amount1, {from: accounts[0]});
		//console.log("timestamp: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp)
		await timeTravel(60 * 60 * 24 * daysToAdv1);
		// need too mine block to adv time
		await t.transfer(accounts[3], 10, {from: accounts[0]});

		await t.transfer(accounts[1], amount2, {from: accounts[0]});
		//console.log("timestamp: " + web3.eth.getBlock(web3.eth.blockNumber).timestamp)
		await timeTravel(60 * 60 * 24 * daysToAdv2);
		// need too mine block to adv time
		await t.transfer(accounts[3], 10, {from: accounts[0]});

		balance = await t.balanceOf(accounts[1]);
		expectedBalance += getInterest(expectedBalance, daysToAdv1);
		expectedBalance += amount2
		expectedBalance += getInterest(expectedBalance, daysToAdv2);

		assert(Math.abs(expectedBalance - balance.valueOf()) < 1);
	})
})


const getInterest = (principal, days) => {
	return principal * (1 + apr / 100 / 365) ** days - principal;
}

const timeTravel = (time) => {
  return new Promise((resolve, reject) => {
    web3.currentProvider.sendAsync({
      jsonrpc: "2.0",
      method: "evm_increaseTime",
      params: [time], 
      id: new Date().getTime()
    }, (err, result) => {
      if(err){ return reject(err) }
      return resolve(result)
    });
  })
}