pragma solidity ^0.5.0;

// File: contracts/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);


  function burn(uint256 value) external;

 
  function burnFrom(address from, uint256 value) external;

  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/Staking.sol

// contract to manage staking of one year and two year stakers

contract NRTManager{

    uint256 public stakersBal; 

    function resetStaking() external returns(bool);

    function updateLuckpool(uint256 amount) external returns(bool);

    function updateBurnBal(uint256 amount) external returns(bool);
}

// Database Design based on CRUD by Rob Hitchens . Refer : https://medium.com/@robhitchens/solidity-crud-part-1-824ffa69509a

contract Staking {
    using SafeMath for uint256;
    
    address public NRTManagerAddr;
    NRTManager NRTContract;

    // Event to watch staking creations
    event stakeCreation(
    uint256 orderid,
    address indexed ownerAddress,
    uint256 value
    );

    // Event to watch loans repayed taken
    event loanTaken(
    uint256 orderid
    );

    // Event to watch wind up of contracts
    event windupContract(
    uint256 orderid
    );

    IERC20   tokenContract;  // Defining conract address so as to interact with EraswapToken
    address public eraswapToken;  // address of EraswapToken

    uint256 public luckPoolBal;    // Luckpool Balance

     // Counts of different stakers
    uint256 public  OneYearStakerCount;
    uint256 public TwoYearStakerCount;

    // Total staked amounts
    uint256 public OneYearStakedAmount;
    uint256 public TwoYearStakedAmount;

    // Burn away token count
    uint256[] public delList;

    // Total staking balances after NRT release
    uint256 public OneYearStakersBal;
    uint256 public TwoYearStakersBal;

   
    uint256 OrderId=100000;  // orderID to uniquely identify the staking order


    struct Staker {
        bool isTwoYear;         // to check whether its one or two year
        bool loan;              // to check whether loan is taken
        bool windUp;            // to check if windup initiated
        uint8 loanCount;      // to check limit of loans that can be taken
        uint256 index;          // index
        uint256 orderID;        // unique orderid to uniquely identify the order
        uint256 stakedAmount;   // amount Staked
        uint256 stakedTime;     // Time at which the user staked
        uint256 loanStartTime;  // to keep a check in loan period

    }

    mapping (uint256 => address) public  StakingOwnership; // orderid ==> address of user
    mapping (uint256 => Staker) public StakingDetails;     //orderid ==> order details
    mapping (uint256 => uint256[]) public cumilativeStakedDetails; // orderid ==> to store the cumilative amount of NRT stored per month
    mapping (uint256 => uint256) public totalNrtMonthCount; // orderid ==> to keep tab on how many times NRT was received

    uint256[] public OrderList;  // to store all active orders in which the state need to be changed monthly

   /**
   * @dev Throws if not times up to close a contract
   * @param orderID to identify the unique staking contract
   */
    modifier isWithinPeriod(uint256 orderID) {
        if (StakingDetails[orderID].isTwoYear) {
        require(now <= StakingDetails[orderID].stakedTime + 730 days,"Contract can only be ended after 2 years");
        }else {
        require(now <= StakingDetails[orderID].stakedTime + 365 days,"Contract can only be ended after 1 years");
        }
        _;
    }

   /**
   * @dev To check if loan is initiated
   * @param orderID to identify the unique staking contract
   */
   modifier isNoLoanTaken(uint256 orderID) {
        require(StakingDetails[orderID].loan != true,"Loan is present");
        _;
    }

   /**
   * @dev To check whether its valid staker 
   * @param orderID to identify the unique staking contract
   */
   modifier onlyStakeOwner(uint256 orderID) {
        require(StakingOwnership[orderID] == msg.sender,"Staking owner should be valid");
        _;
    }

   /**
   * @dev should send tokens to the user
   * @param orderId to identify unique staking contract
   * @param amount amount to be send
   * @return true if success
   */

  function sendTokens(uint256 orderId, uint256 amount) internal returns (bool) {
      // todo: check this transfer, it may not be doing as expected

      require(tokenContract.transfer(StakingOwnership[orderId], amount),"The contract should send from its balance to the user");
      return true;
  }

   /**
   * @dev should send tokens to the user
   * @param orderId to identify unique staking contract
   * @param amount amount to be send
   * @return true if success
   */

  function receiveTokens(uint256 orderId ,uint256 amount) internal returns (bool) {
        require(tokenContract.transferFrom(StakingOwnership[orderId],address(this), amount), "The token transfer should be done");
        return true;
  } 

   /**
   * @dev Function to delete a particular order
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function deleteRecord(uint256 orderId) internal returns (bool) {
      require(isOrderExist(orderId) == true,"The orderId should exist");
      uint256 rowToDelete = StakingDetails[orderId].index;
      uint256 orderToMove = OrderList[OrderList.length-1];
      OrderList[rowToDelete] = orderToMove;
      StakingDetails[orderToMove].index = rowToDelete;
      OrderList.length--; 
      return true;
  }

 
  /**
   * @dev Should delete unwanted orders
   * @return true if success
   */
// todo recheck the limit for this
function deleteList() internal returns (bool){
    if(delList.length == 0)
    {
        return true;
    }
      for (uint j = delList.length - 1;j > 0;j--)
      {
          deleteRecord(delList[j]);
          delList.length--;
      }
      return true;
}

   /**
   * @dev Function to check whether a partcicular order exists
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function isOrderExist(uint256 orderId) public view returns(bool) {
      return OrderList[StakingDetails[orderId].index] == orderId;
 }
  
   /**
   * @dev To repay the leased loan
   * @param orderId to identify unique staking contract
   * @return total repayment
   */

  function calculateRepaymentTotalPayment(uint256 orderId)  public view returns (uint256) {
          uint temp;
          if((isOrderExist(orderId) == false) || (StakingDetails[orderId].loan == false) || (StakingDetails[orderId].loanStartTime.add(60 days) < now)){
              return 0;
          }
          temp = ((StakingDetails[orderId].stakedAmount).div(200)).mul(101);
          return temp;
      
  }
   /**
   * @dev To update burn token in NRT manager
   * @param amount amount to be burned
   * @return true if everything went right
   */

  function updateBurnToken(uint256 amount) internal returns (bool){
      if(amount == 0){
          return true;
      }
      else{
          require(tokenContract.increaseAllowance(NRTManagerAddr,amount),"the allowance should be incresed inorder to send token");
          require(NRTContract.updateBurnBal(amount),"Burn should be updated");
      }
      return true;
  }

     /**
   * @dev To update luck pool in NRT manager
   * @param amount amount to be updated in luck pool
   * @return true if everything went right
   */

  function updateLuckPool(uint256 amount) internal returns (bool){
      if(amount == 0){
          return true;
      }
      else{
          require(tokenContract.increaseAllowance(NRTManagerAddr,amount),"the allowance should be incresed inorder to send token");
          require(NRTContract.updateLuckpool(amount),"Luckpool should be updated");
      }
      return true;
  }

    
   /**
   * @dev To check if eligible for repayment
   * @param orderId to identify unique staking contract
   * @return total repayment
   */
  function isEligibleForRepayment(uint256 orderId)  public view returns (bool) {
          require(isOrderExist(orderId) == true,"The orderId should exist");
          require(StakingDetails[orderId].loan == true,"User should have taken loan");
          require((now.sub(StakingDetails[orderId].loanStartTime)) < 60 days,"Loan repayment should be done on time");
          return true;
  }

   /**
   * @dev To Transfer Staking Ownership
   * @param orderId to identify unique staking contract
   * @return bool true if ownership successfully transffered
   */
  function transferOwnership(uint256 orderId) external returns (bool) {
          require(isOrderExist(orderId) == true,"The orderId should exist");
          require(msg.sender == StakingOwnership[orderId],"should only be invoked by current owner");
          StakingOwnership[orderId] = msg.sender;
          return true;
  }

   /**
   * @dev To create staking contract
   * @param amount Total Est which is to be Staked
   * @return orderId of created 
   */

    function createStakingContract(uint256 amount,bool isTwoYear) external returns (uint256) { 
            OrderId = OrderId + 1;
            StakingOwnership[OrderId] = msg.sender;
            uint256 index = OrderList.push(OrderId).sub(1);
            cumilativeStakedDetails[OrderId].push(amount);

            if (isTwoYear) {
            TwoYearStakerCount = TwoYearStakerCount.add(1);
            TwoYearStakedAmount = TwoYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(true,false,false,0,index,OrderId,amount, now,0);
            }else {
            OneYearStakerCount = OneYearStakerCount.add(1);
            OneYearStakedAmount = OneYearStakedAmount.add(amount);
            StakingDetails[OrderId] = Staker(false,false,false,0,index,OrderId,amount, now,0);
            }

            require(receiveTokens(OrderId, amount), "The token transfer should be done");
            emit stakeCreation(OrderId,StakingOwnership[OrderId], amount);
            return OrderId;
        }


 
    /**
   * @dev To check if loan is initiated
   * @param orderId to identify unique staking contract
   * @return orderId of created 
   */
  function takeLoan(uint256 orderId) onlyStakeOwner(orderId) isNoLoanTaken(orderId) isWithinPeriod(orderId) external returns (bool) {
    require(isOrderExist(orderId),"The orderId should exist");
    if (StakingDetails[orderId].isTwoYear) {
          require(((StakingDetails[orderId].stakedTime).add(730 days)).sub(now) >= 60 days,"Contract End is near");
          require(StakingDetails[orderId].loanCount <= 1,"only one loan per year is allowed");        
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakedAmount = TwoYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }else {
          require(((StakingDetails[orderId].stakedTime).add(365 days)).sub(now) >= 60 days,"Contract End is near");
          require(StakingDetails[orderId].loanCount == 0,"only one loan per year is allowed");        
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakedAmount = OneYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }
          StakingDetails[orderId].loan = true;
          StakingDetails[orderId].loanStartTime = now;
          StakingDetails[orderId].loanCount = StakingDetails[orderId].loanCount + 1;
          // todo: check this transfer, it may not be doing as expected
          require(sendTokens(orderId,(StakingDetails[orderId].stakedAmount).div(2)),"Tokens should be succesfully send");
          emit loanTaken(orderId);
          return true;
      }
      

   /**
   * @dev To repay the leased loan
   * @param orderId to identify unique staking contract
   * @return true if success
   */
  function rePayLoan(uint256 orderId) onlyStakeOwner(orderId) isWithinPeriod(orderId) external returns (bool) {
      require(isEligibleForRepayment(orderId) == true,"The user should be eligible for repayment");
      require(receiveTokens(orderId, calculateRepaymentTotalPayment(orderId)), "The contract should receive loan amount with interest");
      StakingDetails[orderId].loan = false;
      StakingDetails[orderId].loanStartTime = 0;
      luckPoolBal = luckPoolBal.add((StakingDetails[orderId].stakedAmount).div(200));
      if (StakingDetails[orderId].isTwoYear) {  
          TwoYearStakerCount = TwoYearStakerCount.add(1);
          TwoYearStakedAmount = TwoYearStakedAmount.add(StakingDetails[orderId].stakedAmount);
      }else {  
          OneYearStakerCount = OneYearStakerCount.add(1);
          OneYearStakedAmount = OneYearStakedAmount.add(StakingDetails[orderId].stakedAmount);
      }
          // todo: check this transfer, it may not be doing as expected
          require(updateLuckPool(luckPoolBal),"updating luckpool balance");
          luckPoolBal = 0;
          return true;
  }



  
/**
   * @dev Function to windup an active contact
   * @param orderId to identify unique staking contract
   * @return true if success
   */

  function windUpContract(uint256 orderId) onlyStakeOwner(orderId)  external returns (bool) {
      require(isOrderExist(orderId) == true,"The orderId should exist");
      require(StakingDetails[orderId].loan == false,"There should be no loan currently");
      require(StakingDetails[orderId].windUp == false,"Windup Shouldn't be initiated currently");
      StakingDetails[orderId].windUp = true;
      StakingDetails[orderId].loanStartTime = (StakingDetails[orderId].stakedAmount).div(26); // amount to be transferred each month
      totalNrtMonthCount[orderId] = 0; // to keep a tab on amount refunded , will get funds in 26 NRT
      if (StakingDetails[orderId].isTwoYear) {      
          TwoYearStakerCount = TwoYearStakerCount.sub(1);
          TwoYearStakedAmount = TwoYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }else {     
          OneYearStakerCount = OneYearStakerCount.sub(1);
          OneYearStakedAmount = OneYearStakedAmount.sub(StakingDetails[orderId].stakedAmount);
    }
      emit windupContract( orderId);
      return true;
  }

function preStakingDistribution() internal returns(bool){
    require(deleteList(),"should update lists");
    uint256 temp = NRTContract.stakersBal();
    require(temp > 0,"It should happen after NRT distribution");
    uint256 TotalStakerCount = OneYearStakerCount.add(TwoYearStakerCount);
     if(OneYearStakerCount>0){
        OneYearStakersBal = (temp.mul(OneYearStakerCount)).div(TotalStakerCount);
        TwoYearStakersBal = (temp.mul(TwoYearStakerCount)).div(TotalStakerCount);
        luckPoolBal = (OneYearStakersBal.mul(2)).div(15);
        OneYearStakersBal = OneYearStakersBal.sub(luckPoolBal);
        } else{
            TwoYearStakersBal = temp;
        }
        require(NRTContract.resetStaking(),"It should be successfully reset");
        require(updateLuckPool(luckPoolBal),"updating burnable token");
        luckPoolBal = 0;
        return true;
}

    /**
   * @dev Should update all the stakers state
   * @return true if success
   */
//todo should send burn tokens to nrt and update burn balance
  function updateStakers() external returns(bool) {
      uint256 temp;
      uint256 temp1;
      uint256 burnTokenBal;
      require(preStakingDistribution(),"pre staking disribution should be done");
      for (uint i = 0;i < OrderList.length; i++) {
          if (StakingDetails[OrderList[i]].windUp == true) {
                // should distribute 104th of staked amount
                // loanStartTime ==> consist of amount to be transffered each month during windup
                // todo recheck this, using now might lead to problems
                if(totalNrtMonthCount[OrderList[i]] == 26){
                delList.push(OrderList[i]);
                }else{
                totalNrtMonthCount[OrderList[i]] = totalNrtMonthCount[OrderList[i]].add(1);
                sendTokens(OrderList[i],StakingDetails[OrderList[i]].loanStartTime);
                }
          }else if (StakingDetails[OrderList[i]].loan && (now.sub(StakingDetails[OrderList[i]].loanStartTime) > 60 days) ) {
              burnTokenBal = burnTokenBal.add((StakingDetails[OrderList[i]].stakedAmount).div(2));
              delList.push(OrderList[i]);
          }else if(StakingDetails[OrderList[i]].loan){
              continue;
          }
          else if (StakingDetails[OrderList[i]].isTwoYear) {
                // transfers half of the NRT received back to user and half is staked back to pool
                totalNrtMonthCount[OrderList[i]] = totalNrtMonthCount[OrderList[i]].add(1);
                temp = (((StakingDetails[OrderList[i]].stakedAmount).mul(TwoYearStakersBal)).div(TwoYearStakedAmount)).div(2);
                if(cumilativeStakedDetails[OrderList[i]].length < 24){
                cumilativeStakedDetails[OrderList[i]].push(temp);
                sendTokens(OrderList[i],temp);
                }
                else{
                    temp1 = temp;
                    temp = temp.add(cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]].mod(24)]); 
                    cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]].mod(24)] = temp1; 
                    sendTokens(OrderList[i],temp);
                }
          }else {
              // should distribute the proporsionate amount of staked value for one year
              totalNrtMonthCount[OrderList[i]] = totalNrtMonthCount[OrderList[i]].add(1);
              temp = (((StakingDetails[OrderList[i]].stakedAmount).mul(OneYearStakersBal)).div(OneYearStakedAmount)).div(2);
              if(cumilativeStakedDetails[OrderList[i]].length < 12){
              cumilativeStakedDetails[OrderList[i]].push(temp);
              sendTokens(OrderList[i],temp);
              }
              else{
                    temp1 = temp;
                    temp = temp.add(cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]].mod(12)]); 
                    cumilativeStakedDetails[OrderList[i]][totalNrtMonthCount[OrderList[i]].mod(12)] = temp1; 
                    sendTokens(OrderList[i],temp);
                }
          }
      }
      
      require(updateBurnToken(burnTokenBal),"updating burnable token");
      return true;
  }

     /**
    * @dev Constructor
    * @param token Address of eraswaptoken
    * @param NRT Address of NRTcontract
    */

    constructor (address token,address NRT) public{
        require(token != address(0),"address should be valid");
        eraswapToken = token;
        tokenContract = IERC20(eraswapToken);
        NRTManagerAddr = NRT;
        NRTContract = NRTManager(NRTManagerAddr);
    }

}
