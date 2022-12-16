// SPDX-License-Identifier: MIT
//Author: Mohak Malhotra
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
contract Vault {
    IERC20 public immutable DevUSDC;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "unauthorized");
        _;
    }

    constructor(address _devUSDC) {
        owner = msg.sender;
        DevUSDC = IERC20(_devUSDC);
    }

}