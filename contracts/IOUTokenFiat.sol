pragma solidity ^0.4.18;

/* An fungible ERC-20 token for personal bonds resolved via fiat */
contract IOUTokenFiat {

	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);

	struct Balance {
		uint amount;
		uint lastUpdated;
	}
	
	string public name;
	string public symbol;
	address public backer;
	uint public apr;
	uint public expiryDate;
	uint8 public decimals = 2;
	mapping (address => Balance) public balances;
	mapping (address => mapping(address => uint)) public allowances;
	uint public totalSupply;

	/* Instantiates token */
	function IOUTokenFiat (
		string _name, string _symbol, uint _apr, uint _totalSupply, uint _yearsTillExpiry
		) public {

		backer = tx.origin;
		name = _name;
		symbol = _symbol;
		totalSupply = _totalSupply;
		apr = _apr;
		expiryDate = block.timestamp + _yearsTillExpiry * 1 years;
		balances[backer] = Balance(_totalSupply, block.timestamp);

	}

	// Computes `k * (1+1/q) ^ n`, with precision `p`. The higher
	// the precision, the higher the gas cost. It should be
	// something around the log of `n`. When `p == n`, the
	// precision is absolute (sans possible integer overflows).
	// Much smaller values are sufficient to get a great approximation.

	/* Approximates `k * (1 + 1/q)^n` through laurent series expansion 
		 with p terms. Centered at infty, converges for all q != 0. Error of 


	*/ 
	function _fracExp(uint k, uint q, uint n, uint p) internal pure returns (uint) {
	  uint s = 0;
	  uint N = 1;
	  uint B = 1;
	  for (uint i = 0; i < p; ++i){
	    s += k * N / B / (q**i);
	    N  = N * (n-i);
	    B  = B * (i+1);
	  }
	  return s;
	}

	function calculateInterest(address _person) public view returns (uint interest) {
		Balance memory b = balances[_person];
			
		uint inverseRate = 365 * 100 / apr;
		uint numCompounds = (block.timestamp - b.lastUpdated) / (1 days);
		uint precision;

		if (numCompounds < 10)
			precision = numCompounds;
		else if (numCompounds < 1000)
			precision = numCompounds / 10;
		else
			precision = numCompounds / 100;

		return _fracExp(b.amount, inverseRate, numCompounds, 20) - b.amount;
	}

	function updateBalance(address _person) internal returns (uint newBalance) {
		if (block.timestamp > expiryDate) {
			selfdestruct(backer);
		}

		if (_person == backer){
			return balances[_person].amount;
		}

		uint interest = calculateInterest(_person);

		balances[_person].amount += interest;
		balances[_person].lastUpdated = block.timestamp; 
		totalSupply += interest;
		Transfer(0x0, _person, interest); // tokens created
		return balances[_person].amount;
	}

	function balanceOf(address _owner) public constant returns (uint){
		if (_owner == backer)
			return balances[_owner].amount;

		return balances[_owner].amount + calculateInterest(_owner);
	}

	function transfer(address _to, uint _amount) public returns (bool success){
		return _transfer(msg.sender, _to, _amount);
	}

	function _transfer(address _from, address _to, uint _amount) internal returns (bool success) {
		// update balance of sender in case the interest is necessary 
		// to have sufficient funds for transaction
		updateBalance(_from);
		// update balance of receiver so that interest on old funds is brought up
		// to date and interest on added funds is calculated from current time 
		updateBalance(_to);
		// check if sender has sufficient balance
		require(balances[_from].amount >= _amount);
		//check for uint overflow
		require(balances[_to].amount + _amount >= balances[_to].amount);

		balances[_from].amount -= _amount;
		balances[_to].amount += _amount;

		Transfer(_from, _to, _amount);
		return true;
	}

	function repay(uint _amount) public returns (bool){
		require(msg.sender != backer);
		updateBalance(msg.sender);
		require(balances[msg.sender].amount >= _amount);

		balances[msg.sender].amount -= _amount;
		totalSupply -= _amount;
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
