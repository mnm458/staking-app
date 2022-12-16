// SPDX-License-Identifier: MIT
//Author: Mohak Malhotra
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract DevUSDC is ERC20, Ownable, ERC20Permit{

    mapping(address => uint) public staked;
    mapping(address => uint) private stakedFromTS;

      constructor() ERC20("DevUSDC", "DUSDC") ERC20Permit("DevUSDC") {}

      function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
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