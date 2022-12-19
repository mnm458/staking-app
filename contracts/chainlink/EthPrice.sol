// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract EthPrice {
    AggregatorV3Interface internal priceFeed;

    constructor(){
        priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    }

    function getPrice() public view returns (int){
        ( , int price, , ,) = priceFeed.latestRoundData();

        return price / 1e8;
    }
}
