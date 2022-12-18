// SPDX-License-Identifier: MIT
//Author: Mohak Malhotra
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract DevUSDC is ERC20, Ownable, ERC20Permit{


      constructor() ERC20("DevUSDC", "DUSDC") ERC20Permit("DevUSDC") {}

      function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}