// SPDX-License-Identifier: MIT
//Author: Mohak Malhotra
pragma solidity ^0.8.9;

// TODO
// Transfer optimization
// General optimization
// Exponent optimization
// Rename events
// Fix ceth addr
// Deal with the yield from Compound, it should go into the Vault's reserves which needs to be separate from the staked balance pool

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IComptroller.sol";
import "./interfaces/ICEth.sol";
import "./chainlink/EthPrice.sol";

contract Vault {
    IERC20 public immutable DevUSDC;
    EthPrice public ethPrice;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorized");
        _;
    }


    // Duration = duration of the reward
    // finishAt = time the reward finishes
    // updatedAt = last time this contract was updated
    // rewardRate = reward the user earns per second
    // rewardPerTokenStored = (sum of the reward rate * duration )/Total supply

    // rewardPerTokenStored mapping = keeping track of the same thing but for each user

    // rewards mapping = keeps track of the reward the user earns

    // totalSupply = total supply of staking token not the reward token

    // balanceOf mapping = amount of stake per user

    //reward rate per hour = 0.00114155251% per hour
    // 1000 = 0.001
    // 10   = 0.00001
    uint public duration;
    uint public finishAt;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;
    uint public totalSupply;
    uint256 internal rewardPerHour = 10;

    CEth cEth;
    ComptrollerInterface comptroller;

    mapping(address => uint) public userRewardPaid;

    mapping(address => uint) public rewards;

    mapping(address => uint) public balanceOf;

    event Received(address, uint);
    event LogService(string, uint256);

    constructor(address _devUSDC,address _cEth, address _comptroller) {
        owner = msg.sender;
        DevUSDC = IERC20(_devUSDC);
        cEth = CEth(_cEth);
        comptroller = ComptrollerInterface(_comptroller);
        
    }
    //This is called when a user stakes and withdraws   
     modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

    //Returns the time stamp when the last time reward was applicable
    function lastTimeRewardApplicable() public view returns (uint) {
        return _min(finishAt, block.timestamp);
    }

    function rewardPerToken() public view returns (uint) {
        if (totalSupply == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            (rewardRate * (lastTimeRewardApplicable() - updatedAt) * 1e18) /
            totalSupply;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function stake(uint _amount) external payable updateReward(msg.sender) {
        require(_amount >= 5, "Minimum 5 eth needs to be staked");
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
        //FIX
        uint currentEthPrice = uint(ethPrice.getPrice());
        _supplyEthToCompound();
    }

    function _supplyEthToCompound() public payable returns (bool) {
        uint256  exchangeRate = cEth.exchangeRateCurrent();
        emit LogService("Exchange Rate (scaled up by 1e18): ", exchangeRate);
        uint256 supplyRate = cEth.supplyRatePerBlock();
        emit LogService("Supply Rate (scaled up by 1e18): ", supplyRate);
        cEth.mint { value: msg.value, gas: 25000}();
        return true;
    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        _redeemCEth(_amount, false);
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        //address(msg.sender).transfer(_amount);
    }

     function _redeemCEth(uint256 _amount, bool _requestedInCToken) public returns (bool) {
        uint256 redeemResult;
        if(_requestedInCToken == true) {
            redeemResult = cEth.redeem(_amount);
        } else {
            redeemResult = cEth.redeemUnderlying(_amount);
        }

        emit LogService("If this is not 0, there was an error", redeemResult);

        return true;
    }

    //address is of the staker
    //Returns: the amount of rewards earned by the account
    function earned(address _account) public view returns (uint) {
        return
            ((balanceOf[_account] *
                (rewardPerToken() - userRewardPaid[_account])) / 1e18) +
            rewards[_account];
    }

    //Claim rewards
    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            DevUSDC.transfer(msg.sender, reward);
        }
    }

    //The owner of the contract can set the duration as long as the finish time of the reward is less than current duration has finished
    function setRewardsDuration(uint _duration) external onlyOwner {
        //We dont want the owner to change the duration while the contract is still earning rewards. The time the current reward will end 
        //will be stored at finishAt
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    //This function sets the reward rate. They will send the reward tokens into this contract and set the reward rate
    //This function takes one input: the amount of rewards to be paid for the duration 
    function notifyRewardAmount(uint _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        //if current reward duration has expired or not started
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            // reamining rewards = rewardrate * time left until current rewards end
            uint remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
            //checking there's enough rewards to be paid out
            rewardRate * duration <= DevUSDC.balanceOf(address(this)),
            "reward amount > balance"
        );

        finishAt = block.timestamp + duration;
        updatedAt = block.timestamp;
    }

    function _min(uint x, uint y) private pure returns (uint) {
        return x <= y ? x : y;
    }

}
