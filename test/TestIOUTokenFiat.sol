pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/IOUTokenFiat.sol";

contract TestIOUTokenFiat {

	function testInitialBalanceUsingDeployedContract() {
    IOUTokenFiat token = IOUTokenFiat(DeployedAddresses.IOUTokenFiat());

    Assert.equal(token.balanceOf(tx.origin), 100000, "Owner should have 10000 MetaCoin initially");
  }

	function testInitialBalance() public {

		IOUTokenFiat token = new IOUTokenFiat("Rohan", "XRC", 5, 100000, 10);

		Assert.equal(token.balanceOf(tx.origin), 100000, "init balance");
	}


}