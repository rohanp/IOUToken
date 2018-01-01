pragma solidity ^0.4.18;

/* An fungible ERC-20 token for personal bonds resolved via fiat */
contract IOUTokenFiat {

	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
	
	string public name;
	string public symbol;
	address public backer;
	uint public apr;
	uint public expiryDate;
	uint8 public decimals = 2;
	mapping (address => uint) public balances;
	mapping (address => uint) public lastUpdatedDates;
	mapping (address => mapping(address => uint)) public allowances;
	uint public totalSupply;

	/* Instantiates token */
	function IOUTokenFiat (
		string _name, string _symbol, uint _apr, uint _totalSupply, uint _yearsTillExpiry
		) public {

		backer = msg.sender;
		name = _name;
		symbol = _symbol;
		totalSupply = _totalSupply;
		apr = _apr;
		expiryDate = block.timestamp + _yearsTillExpiry * 1 years;
		balances[backer] = _totalSupply;

	}

	function calculateInterest(address _person) public view returns (uint interest) {
		return balances[_person] * (apr / (1 years)) ** (block.timestamp - lastUpdatedDates[_person]);
	}

	function updateBalance(address _person) internal returns (uint newBalance) {
		if (block.timestamp > expiryDate) {
			selfdestruct(backer);
		}

		require(_person != backer);

		uint interest = calculateInterest(_person);

		require(interest != 0);

		 balances[_person] += interest;
		 lastUpdatedDates[_person] = block.timestamp; 
		 totalSupply += interest;
		// Transfer(0x0, _person, interest); // tokens created
		return balances[_person];
	}

	function balanceOf(address _owner) public constant returns (uint){
		return balances[_owner] + calculateInterest(_owner);
	}

	function transfer(address _to, uint _amount) public returns (bool success){
		return _transfer(msg.sender, _to, _amount);
	}

	function _transfer(address _from, address _to, uint _amount) internal returns (bool success) {
		// update balance of sender in case the interest is necessary 
		// to have sufficient funds for transaction
		//updateBalance(_from);
		// update balance of receiver so that interest on old funds is brought up
		// to date and interest on added funds is calculated from current time 
		//updateBalance(_to);
		// check if sender has sufficient balance
		require(balances[_from] >= _amount);
		//check for uint overflow
		require(balances[_to] + _amount > balances[_to]);

		balances[_from] -= _amount;
		balances[_to] += _amount;

		Transfer(_from, _to, _amount);
		return true;
	}

	function repay(uint _amount) public returns (bool){
		updateBalance(msg.sender);
		require(balances[msg.sender] > _amount);

		balances[msg.sender] -= _amount;
		Transfer(msg.sender, 0x0, _amount);
		return true;
	}

	function transferFrom(address _from, address _to, uint _value) public returns (bool){
		// check if user has allowance to send from `_from`
		require(allowances[msg.sender][_from] >= _value); 
		allowances[msg.sender][_from] -= _value;

		return _transfer(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public returns (bool success){
		allowances[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns (uint remaining){
		return allowances[_owner][_spender];
	}

}
