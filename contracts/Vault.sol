// SPDX-License-Identifier: MIT
//Author: Mohak Malhotra
pragma solidity ^0.8.9;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {CEth} from "./interfaces/ICEth.sol";
import {IERC20} from "./interfaces/IERC20.sol";
 
contract Vault {
    IERC20 public immutable DevUSDC;

    address payable public immutable cEthAddr;

    //EthPrice public ethPrice;
    address public owner;

    uint public vaultReserve;

    //Seconds in a year
    uint32 public immutable secYear = 31449600;

    uint public immutable ethPrice = 1234*1e18;

    uint public vaultReserves;


    struct StakeObj {
        uint stakedAmount;
        uint lastUpdatedTimeStamp;
        uint pendingRewards;
        uint cEthBalance;
    }

    mapping (address => StakeObj) public userStakes; 

    // Total staked
    uint public totalSupply;

    event Received(address, uint);
    event MyLog(string, uint256);
    AggregatorV3Interface internal priceFeed;

    constructor( address _rewardToken, address payable _cEthContract) {
        owner = msg.sender;
        DevUSDC = IERC20(_rewardToken);
        cEthAddr = _cEthContract;
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    modifier updateReward(address _account, uint _amount, bool unstaked) {
        StakeObj memory userStake = userStakes[_account];
        uint previousStake = userStake.stakedAmount;
        uint timeDiff = block.timestamp - userStake.lastUpdatedTimeStamp;
        uint timeRatio = (timeDiff*1e18) / (secYear);
        uint currEthPrice = uint(getPrice());
        if(unstaked == false){
            if(previousStake != 0){
                
                uint reward = ((timeRatio / 10) *  currEthPrice * (previousStake/1e18))/1e18;
                //later
                userStakes[_account].pendingRewards += reward;
            } 
            userStakes[_account].stakedAmount += _amount;
        } else{
            uint reward = ((timeRatio / 10) * currEthPrice  * (previousStake/1e18))/1e18;
            userStakes[_account].pendingRewards += reward;
            userStakes[_account].stakedAmount -= _amount;
        }
         userStakes[_account].lastUpdatedTimeStamp = block.timestamp;
        _;
    }

    function getPrice() public view returns (int){
        ( , int price, , ,) = priceFeed.latestRoundData();

        return price;
    }

    function balanceOf(address _account) public view returns(uint){
        return userStakes[_account].stakedAmount;
    }

    function stake() external payable updateReward(msg.sender, msg.value, false) {
        require(msg.value > 0, "amount = 0");
        totalSupply += msg.value;
        supplyEthToCompound(msg.value, msg.sender);
    }

    function unstake(uint _amount) external updateReward(msg.sender, _amount ,true) {
        uint initialBalance = balanceOf(address(this));
        redeemCEth(userStakes[msg.sender].cEthBalance);
        uint newBalance = balanceOf(address(this));
        vaultReserve += (newBalance - initialBalance) - userStakes[msg.sender].stakedAmount;
        require(_amount > 0, "amount = 0");
        totalSupply -= _amount;
        address payable receiver = payable(msg.sender);
        receiver.transfer(_amount);
    }
        receive() external payable {
        emit Received(msg.sender, msg.value);
       
    }

    function redeemRewards() external{
        require(userStakes[msg.sender].pendingRewards > 0, "You don't have any rewards to redeem");
        require(userStakes[msg.sender].stakedAmount == 0, "You can't redeem rewards before unstaking all your stake");
        DevUSDC.transfer(msg.sender, userStakes[msg.sender].pendingRewards);
        userStakes[msg.sender].pendingRewards = 0;
    }

    function redeemableRewards(address _account )  external view returns(uint){
        return userStakes[_account].pendingRewards;
    }

        function supplyEthToCompound(uint _amount, address _account)
        internal
        returns (bool)
    {
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(cEthAddr);
        uint initialBalance = cToken.balanceOf(address(this));
        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        cToken.mint{ value: _amount, gas: 250000 }();

        uint newBalance = cToken.balanceOf(address(this));

        userStakes[_account].cEthBalance += newBalance - initialBalance;
        return true;
    }

     function redeemCEth(
        uint256 amount
    ) public returns (bool) {
        // Create a reference to the corresponding cToken contract
        CEth cToken = CEth(cEthAddr);

        // `amount` is scaled up by 1e18 to avoid decimals

        uint256 redeemResult;

        // Retrieve your asset based on a cToken amount
        redeemResult = cToken.redeem(amount);
        // Error codes are listed here:
        // https://compound.finance/docs/ctokens#error-codes
        emit MyLog("If this is not 0, there was an error", redeemResult);

        return true;
    }
}

