# What is IOUToken? 
A class of fungible, ERC-20 tokens derived from P2P loans. Each token corresponds to a dollar of a loan; its value is backed by the token-holders' belief that the loaner will pay them back, and features interest through constant-rate inflation distributed to holders. All tokens are destroyed after a set expiry date. [Documentation](#documentation)

### wat
IOUToken allows a person to get a loan from the people they know in exchange for tokens in personal cryptocurrency created for that person, backed by the security and decentralization of the Ethereum blockchain. Within a set amount of time, the issuer pays back the loan (plus interest!) to the holders of the currency and then it is destroyed. Say, you created an IOUToken for yourself called BobCoin. You would specify how many BobCoin could be issued (if you wanted a loan for $10,000 this number would be 10,000), and what the interest rate would be on owning BobCoin (say 5%). If your friend lent you $100, they would get 100 BobCoins. Where it gets interesting is that BobCoins are a currency and are therefore tradable—so your friend could sell their BobCoins to someone else if they wanted. People are incentivized to buy the tokens because they increase in number at a constant interest rate (eg. if the interest rate is set to 10% and someone has 100 tokens, after a year they will have 110 tokens). The issuer of BobCoins agrees to buy back all BobCoins within a set timeframe (say 5 years). If they do not do so, all BobCoins are destroyed and lose their value. These features are all enforced by the blockchain and are verifiable by anyone—[here](https://ropsten.etherscan.io/verifyContract?a=0x1658859f77e0d184f2f3594b6beb0de8d8d7d79b) is my IOUToken on the Ethereum blockchain.

### why
The motivation here is that people you know would have a better understanding of your ability to repay than a bank—for example, if you were a college student studying CS, it is highly likely that you will be able to repay your debt post-graduation. This allows for loanworthy people who are turned down by banks to get a loan, and for others to get lower interest rates. It is similar in this sense to corporate/government bonds.

### How is issuing IOUToken different from just getting a loan?
Tokenizing the loan provides liquidity, meaning if you lent money and got tokens, you could sell your tokens at any time.

### Will buying IOUToken make me rich???
Maybe. Probably not. The price of the token is capped at $1 and can only go down (because the backer will only pay back $1 for each token, and the probability that they do so is < 1), so the only money lenders (token-holders) can make off it is through interest and trading. 

### Why would I buy IOUTokens then
It gives you the ability to give your friend a loan (and get interest in the process), but sell it if you need money or you lose faith in your friend's ability to pay it back. 

### How do I use IOUToken?
Issuer (I want to create my own IOUToken)
1) Create a [Metamask Ethereum wallet](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn) 
2) Copy contract in this repo, (`IOUTokenFiat.sol`) to [remix](remix.ethereum.org/#optimize=true&version=soljson-v0.4.19+commit.c4cbbb05.js)
3) Deploy the code by clicking run, entering in the arguments (eg. "RohanCoin", "XRC", 10, 10000000, 10 would create a currency called RohanCoin with symbol XRC, with 10% interest per year, a maximum supply of $100,000.00 and 10 years to repay it) and clicking "Create". This will cost you Ethereum, which you can buy with USD [here](gemini.com). If you just want to try it out, you can deploy your coin on a testnet. You can enable it by clicking on the topleft corner of the MetaMask chrome extension and switching the network to "Ropsten Test Network".  This is a test version of Ethereum where all the ether are worthless—you can get them for free [here](https://faucet.metamask.io/). Okay now go back to Remix, enter in your arguments, and click create. 
4) Congrats! You have your own cryptocurrency. Copy the contract address (listed under Contract Instances, just click on it) and share it with your friends. 


Buyer (I want to buy my friend's token to finance their loan)
1) Create a [Metamask Ethereum wallet](https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn) 
2) Find out the address of the friend's IOUToken you want
3) Click on the Metamask chrome extension > Tokens > Add Token
4) Enter in the address
5) Ask your friend to send you some in exchange for $ (at some point you will be able to do this automatically with ether)


My test IOUToken is called RohanCoin and is deployed on the [Ropsten Testnet](https://ropsten.etherscan.io/token/0x1658859f77e0d184f2f3594b6beb0de8d8d7d79b) at address  `0x1658859f77e0d184f2f3594b6beb0de8d8d7d79b`. DM me your address and I'll send you some for ~free~


## Documentation
```
/*
Initializes IOUToken instance. 

Params
------
_name : string
     Name of currency (eg. "RohanCoin")
     
_symbol : string
     Symbol of currency (eg. "XRC")
     
_apr : uint
     A 5% rate would be expressed as 5. Currently no support for decimal rates.
     
_totalSupply : uint
      Total quantity of currency that can be issued. Solidity does not currently
      support floating point numbers, so this number is 100x the amount of your loan
      (eg. if you wanted a loan for $100.50 you would put 10050)

_yearsTillExpiry : uint
      Number of years in which the currency will expire and be destroyed.
      You are supposed to buy back all the currency in this time. 
*/
function IOUTokenFiat (
		string _name, string _symbol, uint _apr, uint _totalSupply, uint _yearsTillExpiry
		) public 

/* 
	Calculates interest owed to a given address, but doesn't
	update it on blockchain.
*/
	function calculateInterest(address _person) public view returns (uint interest)
  
/* 
	Updates balance of address on blockchain with interest owed
*/
	function updateBalance(address _person) internal returns (uint newBalance)

/* 
	Returns balance + interest owed to a given address, but doesn't
	update it on blockchain.
*/
	function balanceOf(address _owner) public constant returns (uint)
  
/* 
        Gives `_amount` tokens back to issuer
*/
        function repay(uint _amount) public returns (bool)
```





