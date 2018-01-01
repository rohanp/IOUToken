pragma solidity ^0.4.18;

contract Token {

    event Transfer(address indexed _from, address indexed _to, uint _value);

    struct Balance {
        uint amount;
        uint lastUpdated;
    }

    mapping (address => Balance) public balances;


    function _transfer(address _from, address _to, uint _amount) internal returns (bool success) {

            // check if sender has sufficient balance
            require(balances[_from].amount >= _amount);
            //check for uint overflow
            require(balances[_to].amount + _amount > balances[_to].amount);

            balances[_from].amount -= _amount;
            balances[_to].amount += _amount;

            Transfer(_from, _to, _amount);
            return true;
        }
}