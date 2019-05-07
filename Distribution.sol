pragma solidity ^ 0.5.7;

contract ERC20Token {
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract EraswapDistribution is Ownable {
     using SafeMath for uint256;
    
  ERC20Token public token;
    
    struct Rewarddetails{
        uint256 curatorreward;
        uint256 timetraderreward;
        uint256 dayswappersreward;
        uint256 powertokenreward;
        uint256 buzcaferewards;
        uint256 total;
    }
    event rewardrequested(address user);
    event rewardupdated(address user, uint totalreward);
    
    mapping(address => Rewarddetails) public distributionDetails;
    mapping(address => uint256) public lastrequestedtime;
    
        constructor(address _tokentobeused) public {
        token = ERC20Token(_tokentobeused);
    }
    
    function requestrewardupdate() public {
        require((lastrequestedtime[msg.sender] - now) > 30 days, "30 days not completed");
        lastrequestedtime[msg.sender] = now;
        emit rewardrequested(msg.sender);    
    }
    
    function updaterewarddetails(address _user, uint256[5] memory rewards) public onlyOwner returns(bool){
        distributionDetails[_user].curatorreward = distributionDetails[_user].curatorreward.add(rewards[0]);
        distributionDetails[_user].timetraderreward= distributionDetails[_user].timetraderreward.add(rewards[1]);
        distributionDetails[_user].dayswappersreward= distributionDetails[_user].dayswappersreward.add(rewards[2]);
        distributionDetails[_user].powertokenreward= distributionDetails[_user].powertokenreward.add(rewards[3]);
        distributionDetails[_user].buzcaferewards = distributionDetails[_user].buzcaferewards.add(rewards[4]);
        uint256 totaltoken = rewards[0].add(rewards[1]).add(rewards[2]).add(rewards[3]).add(rewards[4]);
        distributionDetails[_user].total = distributionDetails[_user].total.add(totaltoken);
        emit rewardupdated(_user, totaltoken);
        return true;
    }
    
    function claimrewards() public {
        require((now - lastrequestedtime[msg.sender]) > 30 days, "30 days not completed");
        uint256 totalrewards= distributionDetails[msg.sender].curatorreward.add(distributionDetails[msg.sender].timetraderreward).add(distributionDetails[msg.sender].dayswappersreward).add(distributionDetails[msg.sender].powertokenreward).add(distributionDetails[msg.sender].buzcaferewards);
        require(token.balanceOf(address(this)) >= totalrewards, "Insufficient funds");
        distributionDetails[msg.sender].curatorreward = 0;
        distributionDetails[msg.sender].timetraderreward = 0;
        distributionDetails[msg.sender].dayswappersreward= 0;
        distributionDetails[msg.sender].powertokenreward= 0;
        distributionDetails[msg.sender].buzcaferewards = 0;
        distributionDetails[msg.sender].total= 0;
        lastrequestedtime[msg.sender] = now;
        token.transfer(msg.sender, totalrewards);
    }
    
}
