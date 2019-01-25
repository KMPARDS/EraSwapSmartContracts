# EraSwapSmartContract

All Smart Contracts are used in Era Swap projects.

<b>Preface</b>

The smart contract for TimeAlly staking platform is completed which
includes
● Eraswap Token Contract
● NRTManager Contract ( which distributes NRT to different actors)
● Staking Contract Softwares and General Info Prior testing.
● Firefox or Chrome with metamask
● Remix
● The contracts can be deployed to any testnet (rinkeby / ropsten)
● Etherscan can be used to see the corresponding transactions.
● You can pass in the deployed contract address into ropsten.etherscan.io / rinkeby.etherscan.io according to the testnet you deployed.
● You can also see the NRTReleased by watching each address which is fed into etherscan.

<b>EraSwapToken.sol</b><br>
 
Name: Era Swap Token
Initial Supply : 910000000 EST
Total supply( in 50 years ) : 9100000000 EST
Decimals: 18
NRTManager.sol
Newly Released Tokens : Every year a amount of tokens will be released and this amount will be 10% less than the NRT of preceding year.
The amount will then be splitted into different wallet addresses reserved for different rewards
and it gets distributed.

<b>Staking.sol</b><br>
Currently we are supporting one year and two year investment plans

1. One year investment plan: user will be getting 13% return in one year on the amount they
vest in timeally contract. This 13% will be splited in 12 months so, 13%/12 = 1.0833% per
month. Remaining 2% must go to the luck pool.

2. Two year investment plan: user will be getting 15% return on the amount vested in timeally
contract per year splited in 12 months so, 15%/12 = 1.25% per month.

In the end of two year user will be getting 30% return.

Let suppose there are 100 members who staked, out of which 60 staked for 2 year program and 40 stakes for 1 year program. So 60% out of 15% reserved for stakers of two year program and 40% is reserved for stakers of one year program.
So these 60 will get 15% advantage whereas rest 40 will get 13% benefit and the remaining 2% will go to the luck pool.

<b>NRTManager</b>

NRTManager is responsible for distributing the different tokens to different actors. Inorder to release NRT, you have to invoke receiveMonthlyNRT function to distribute the tokens. You can only invoke this function only once during every month (5 minutes for testing). You can see various NRT released in etherscan. As requested , we have included functionalities for changing different pool addresses , changing ownership and many more. 

You can play around those functions in remix and see the different working.

Some of the functionalities includes
● releaseMontlyNRT
● addSigner
● setBuzzCafe
● setContigencyFunds
● setKmpards
● setMarketingAndRNR



