CORE LOGICS

Index

Preface
Contract description
EraSwapToken.sol
Timeally
TimeAlly.sol
TimeAllyCore.sol
Staking.sol
LoanAndRefund.sol
Eralot.sol
Toss.sol
Distribution.sol
Escrow.sol

Contract description

 EraSwapToken.sol

Source Code:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/EraswapToken/EraswapToken.sol

Dependencies: https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/EraswapToken/Documentation/Dependencies

Tree parse:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/EraswapToken/Documentation/EraswapToken%20Tree%20Parse

Description Report: 
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/EraswapToken/Documentation/EraswapTokenMDReport.md

Graph:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/EraswapToken/Documentation/EraswapTokengraph.png

Structure:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/EraswapToken/Documentation/EraswapToken.png




Rules to be followed:

EraSwapToken is a ERC20 token.
Maximum supply of EST is 9100000000
Initial supply is 91000000
Every year 10% token less than the preceding years gets added up to the supply( if X tokens is the Total supply of a year X-10% will be NRT for next month) 
Every month the Monthly NRT is added to the total supply(Annual NRT divided by 12).
Separate pool address of different heads
Pool address can be updated.
The monthly NRT tokens must be divided into specific percentages and transferred to the specified pool address
2% of the current supply is the maximum that can be burnt in a month if there are more tokens to be bunt it will be carried forward to the next month burning.

 Timeally

Timeally consists of 4 smart contracts:

TimeAlly.sol
TimeAllyCore.sol
Staking.sol
LoanAndRefund.sol

TimeAlly.sol

Source Code: 
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/TimeAlly.sol

Tree:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/TimeAlly/TimeAlly%20Tree

Graph: 
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/TimeAlly/TimeAllyGraph.png

Description Report:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/TimeAlly/TimeAllyMDReport.md

Structure:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/TimeAlly/TimeAlly.png


TimeAllyCore.sol

Tree:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/TimeAlly/TimeAllyCore/TimeAllyCore%20Tree

Graph:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/TimeAlly/TimeAllyCore/TimeAllyCoreGraph.png

Description Report
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/TimeAlly/TimeAllyCore/TimeAllyCoreMDReport.md

Staking.sol

The constructor is used to add the TimeAlly address to the conrtact. └ Public exclamation stop_sign
The contract can be used to create, pause and resume a stake. A function to add a batch of stake. When stake is added, it is also added to the active planlist and activeplanamount is also updated. When a stake is paused, it is removed from activeplanlist and activeplanamount. └ AddStake OnlyTimeAlly └ BatchAddStake OnlyTimeAlly └ Pause OnlyTimeAlly └ Resume OnlyTimeAlly
The contract provides functions to view details of stake. └ ViewStake OnlyTimeAlly └ ViewStakedAmount OnlyTimeAlly
The contract has two functions to perform the monthly updation.
The function can recieve an NRT amount and which will be divided among different plans and luckpool balance will also be allocated. └ MonthlyNRTHandler Public exclamation stop_sign OnlyTimeAlly
This NRT balance of each plan is divided to its users. 50% of the amount a user receives is added back as principal to stake and 50% is released to accounts. The contract keeps track of when each principal is added and releases the corresponding amount when its reaches the plan time. This continues forever. eg: Lets suppose the plan period is 12 months. In month 0, the initial stake was added and will be relesed exactly after 12 months. In month 1, 50% of the first interest will be added as principal and will be released after 12 months from this day. The function also handles the release of principals if the plan period of the corresponding principal has reached. └ MonthlyPlanHandler Public exclamation stop_sign OnlyTimeAlly
This is an internal function used to remove a stake from ActiveplanList. └ DeleteActivePlanListElement Internal lock stop_sign
 
 

Tree:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/Staking/Staking%20Tree

Description Report:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/Staking/StakingMDReport.md

Graph:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/Staking/Stakinggraph.png

LoanAndRefund.sol


The function provides a constructor to add the timeAlly address to the contract. └ Public exclamation stop_sign
The contract provides function to add and remove a loan. The functions add it to active loanlista and removes from it respectively. └ AddLoan Public exclamation stop_sign OnlyTimeAlly └ RemoveLoan Public exclamation stop_sign OnlyTimeAlly
The contract provides function to add refund and add it to refundlist. └ AddRefund Public exclamation stop_sign OnlyTimeAlly
The contract provides functions to view the loan and refund details └ ViewLoan Public exclamation OnlyTimeAlly └ ViewRefund Public exclamation OnlyTimeAlly
The contract has 2 functions to perform monthly operations on loan and refund.
The function issues the refund amount to contracts in the refundlist. It also updtaes the refund count. If the refund count reaches the numberof months of refund of the plan, it'll be removed from the refunlist.
└ MonthlyRefundHandler Public exclamation stop_sign OnlyTimeAlly
The function checks whether the loantime has exceed the loan period of the plan. If so, it removes the contract from loanlist and addsthe amount to defaultlist. └ MonthlyLoanHandler Public exclamation stop_sign OnlyTimeAlly
The function has two internal functions to remove the contract from the activeloanlist and activerefundlist. └ DeleteRefundListElement Internal lock stop_sign └ DeleteLoanListElement Internal lock stop_sign

Tree:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/LoanAndRefund/LoanAndRefund%20Tree%20Parse

Graph:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/LoanAndRefund/LoanAndRefundGraph.png
Description Report:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Projects/Eraswap/contracts/TimeAlly/Documentation/LoanAndRefund/LoanAndRefundMDReport.md

Rules to be followed in TimeAlly

One year stakers must get 13% annually 1.08333% per month
Two year stakers must get 15% annually 1.25% per month
50% of the staking rewards must again be vested into timeally
Loan can be taken upto 50% of the staked amount
Loan cannot be taken after tenure of the investment(one year or two year)
Loan must be paid back in 60 days by the borrower with 1% interest
If loan is not paid back in 60 days all remaining funds in timeally must be burnt.
Loan can only be reapplied after one year
In loan period time user will not get any rewards from the NRT
Owner can create multiple staking instances in one transaction
User must be able to change his/her staking address.
If a staking instance is terminated the principle will split into 104 equal parts and will be distributed in 104 weeks
We can add new tenure plans with plan percentage


Eralot.sol


Details
https://github.com/KMPARDS/EraSwapSmartContracts/blob/master/Eralot.pdf

Toss.sol

Details
https://github.com/KMPARDS/EraSwapSmartContracts/blob/master/Functions%20-%20Toss.pdf

Distribution.sol

This smart contract consists of all reward distribution logic of Timeswappers, including TimeTraders, Curators, Dayswappers, Powertoken and buzcafe.

A user when requests to update his rewards by calling requestrewardupdate(), a event rewardrequested() is broadcasted and using oracle the user’s rewards are updated by updaterewarddetails() which only owner can initiate.

Once rewards are updated user can withdraw his funds using claimrewards().

Source Code:
https://github.com/KMPARDS/EraSwapSmartContracts/blob/latestfiles/Distribution.sol


Escrow.sol

Escrow smart contract will hold the users payment in the smart contract and once buyer releases the funds it will be updated to the seller address. Dispute can be raised by buyer or seller anyone at anytime by calling EscrowEscalation(). The resolution of that dispute will be solved by voting in central servers and result will be updated by owner using escrowDecision()
User can create a escrow using NewEscrow()  

