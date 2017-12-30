pragma solidity ^0.4.19;

/* An fungible ERC-20 token for personal bonds resolved via fiat */
contract IOUTokenFiat {

	struct Balance {
		uint amount;
		uint lastUpdated;
	}
	
	string public name;
	string public symbol;
	address private backer;
	uint private apr;
	uint private expiryDate;
	mapping (address => Balance) private balances;
	uint private supply;

	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);

	/* Instantiates token */
	function IOUTokenFiat(
		string _name, string _symbol, uint _apr, uint _totalSupply, uint _yearsTillExpiry
		) public {

		backer = msg.sender;
		name = _name;
		symbol = _symbol;
		supply = _totalSupply;
		apr = _apr;
		expiryDate = block.timestamp + _yearsTillExpiry * 1 years;
		balances[backer] = Balance(_totalSupply, block.timestamp);

	}

	function updateBalance(address _person) internal returns (uint newBalance) {
		if (block.timestamp > expiryDate) {
			selfdestruct(backer);
		}

		require(_person != backer);

		Balance storage b = balances[_person];
		uint interest = b.amount * (apr / (1 years)) ** (block.timestamp - b.lastUpdated);

		require(interest != 0);

		b.amount += interest;
		b.lastUpdated = block.timestamp; 

		Transfer(0x0, _person, interest); // tokens created
		return balances[_person].amount;
	}

	function totalSupply() public constant returns (uint){
		return supply;
	}

	function balanceOf(address _owner) public returns (uint balance){
		updateBalance(_owner);
		return balances[_owner].amount;
	}

	function transfer(address _to, uint _amount) public returns (bool success){
		// update balance of sender in case the interest is necessary 
		// to have sufficient funds for transaction
		updateBalance(msg.sender);
		// update balance of receiver so that interest on old funds is brought up
		// to date and interest on added funds is calculated from current time 
		updateBalance(_to);
		// check if sender has sufficient balance
		require(balances[msg.sender].amount >= _amount);
		//check for uint overflow
		require(balances[_to].amount + _amount > balances[_to].amount);

		balances[msg.sender].amount -= _amount;
		balances[_to].amount += _amount;

		Transfer(msg.sender, _to, _amount);
		return true;
	}

	function repay(uint _amount) public returns (bool){
		updateBalance(msg.sender);
		require(balances[msg.sender].amount > _amount);

		balances[msg.sender].amount -= _amount;
		Transfer(msg.sender, 0x0, _amount);
		return true;
	}

	/*
	function transferFrom(address from, address to, uint value) public returns (bool){
		return false;
	}

	function allowance(address owner, address spender) public constant returns (uint remaining){
		return 0;
	}
	*/

}
