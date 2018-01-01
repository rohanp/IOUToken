pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/IOUTokenFiat.sol";

contract TestIOUTokenFiat {

	function testInitialBalance() public {

		IOUTokenFiat token = new IOUTokenFiat("Rohan", "XRC", 5, 100000, 10);

		Assert.equal(token.balanceOf(0x627306090abaB3A6e1400e9345bC60c78a8BEf57), 100000, "init balance");



	}
}