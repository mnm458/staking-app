// SPDX-License-Identifier: MIT
//Author: Mohak Malhotra
pragma solidity ^0.8.9;

// TODO
// Transfer optimization
// General optimization
// Exponent optimization
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IComptroller.sol";
import "./interfaces/ICEth.sol";

contract Vault {
    IERC20 public immutable DevUSDC;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorized");
        _;
    }

    uint public duration;
    uint public finishAt;
    uint public updatedAt;
    uint public rewardRate;
    uint public rewardPerTokenStored;

    mapping(address => uint) public userRewardPaid;

    mapping(address => uint) public rewards;

    uint public totalSupply;

    mapping(address => uint) public balanceOf;

    event Received(address, uint);

    constructor(address _devUSDC,address _cEth, address _comptroller) {
        owner = msg.sender;
        DevUSDC = IERC20(_devUSDC);
        
    }

     modifier updateReward(address _account) {
        rewardPerTokenStored = rewardPerToken();
        updatedAt = lastTimeRewardApplicable();

        if (_account != address(0)) {
            rewards[_account] = earned(_account);
            userRewardPaid[_account] = rewardPerTokenStored;
        }

        _;
    }

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

    }

    function withdraw(uint _amount) external updateReward(msg.sender) {
        require(_amount > 0, "amount = 0");
        uint weiAmount = _amount * 1e18;
        balanceOf[msg.sender] -= weiAmount;
        totalSupply -= weiAmount;
        address(msg.sender).transfer(weiAmount);
    }

    function earned(address _account) public view returns (uint) {
        return
            ((balanceOf[_account] *
                (rewardPerToken() - userRewardPaid[_account])) / 1e18) +
            rewards[_account];
    }

    function getReward() external updateReward(msg.sender) {
        uint reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            DevUSDC.transfer(msg.sender, reward);
        }
    }

    function setRewardsDuration(uint _duration) external onlyOwner {
        require(finishAt < block.timestamp, "reward duration not finished");
        duration = _duration;
    }

    function notifyRewardAmount(uint _amount)
        external
        onlyOwner
        updateReward(address(0))
    {
        if (block.timestamp >= finishAt) {
            rewardRate = _amount / duration;
        } else {
            uint remainingRewards = (finishAt - block.timestamp) * rewardRate;
            rewardRate = (_amount + remainingRewards) / duration;
        }

        require(rewardRate > 0, "reward rate = 0");
        require(
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
