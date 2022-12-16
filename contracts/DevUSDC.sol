// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DevUSDC is ERC20{

    mapping(address => uint) public staked;
    mapping(address => uint) private stakedFromTS;

      constructor(uint256 initialSupply) ERC20("Gold", "GLD") {
        _mint(msg.sender, initialSupply);
    }

    // function stake(uint amount) external {
    //     require(amount > 0, "amount is <= 0");
    //     require(balanceOf(msg.sender) >= amount, "balance is <= amount");
    //     transfer( address(this), amount);
    //     if (staked[msg.sender] > 0) {
    //         claim();
    //     }
    //     stakedFromTS[msg.sender] = block.timestamp;
    //     staked[msg.sender] += amount;
    // }

    // function unstake(uint amount) external {
    //     require(amount > 0, "amount is <= 0");
    //     require(staked[msg.sender] >= amount, "amount is > staked");
    //     claim();
    //     staked[msg.sender] -= amount;
    //     transfer( msg.sender, amount);
    // }

    // function claim() public {
    //     require(staked[msg.sender] > 0, "staked is <= 0");
    //     uint secondsStaked = block.timestamp - stakedFromTS[msg.sender];
    //     uint rewards = staked[msg.sender] * secondsStaked / 3.154e7;
    //     _mint(msg.sender,rewards);
    //     stakedFromTS[msg.sender] = block.timestamp;
    // }
}