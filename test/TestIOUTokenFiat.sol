pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/IOUTokenFiat.sol";

contract TestIOUTokenFiat {

	function testInitialBalance() public {

		uint initialBalance = 100000;

		IOUTokenFiat token = new IOUTokenFiat("Rohan", "XRC", 5, initialBalance, 10);

		Assert.equal(token.balanceOf(tx.origin), initialBalance, "init balance");



	}
}