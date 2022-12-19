// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.9;

interface CEth {
    function mint() external payable;

    function exchangeRateCurrent() external returns (uint);

    function exchangeRateStored() external returns (uint);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint) external returns (uint);

    function redeemUnderlying(uint) external returns (uint);

    function balanceOf(address owner) external view returns (uint);
    
}
