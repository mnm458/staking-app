<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>





<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://pbs.twimg.com/profile_images/1587621911181271040/q3dXdQFZ_400x400.jpg" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Staking Vault Dapp Contracts</h3>

  <p align="center">
    A simple staking vault that uses stake as collateral on compound to generate yield
    <br />
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

⊛ Users can stake their ETH in the vault (Constant APR 10%) <br><br>
⊛ User gets rewarded in devUSDC which is an Erc20 token <br><br>
⊛ We assume that devUSDC is always worth $1 <br><br>
⊛ When a user stakes ETH: all of that ETH will be put as collateral in Compound (v2).<br><br>
⊛ When a user wants to Withdraw their ETH, the vault will take out the ETH the user staked (without the yields) from Compound and will give it back to the   user with the devUSDC rewards <br><br>
⊛ Minimum amount to stake is 5 ETH <br> <br>
⊛ To get the price of ETH you will need to use a price oracle from chainlink <br><br>

<p align="right">(<a href="#readme-top">back to top</a>)</p>



### Built With

* **Solidity**
* **Hardhat**
* **OpenZeppelin**
* **Chainlink**
* **Chai + Mocha.js**
* **Typescript**


<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- GETTING STARTED -->
## Getting Started

All the contracts have been deployed on Goerli Network and are verified.

* DevUSDC Contract Address
  ```sh
  0x81F1D8930adf53dd52c2Ca95Cd89783Ed369eBD7
  ```
  
* Vault Contract Address
  ```sh
  0x81F1D8930adf53dd52c2Ca95Cd89783Ed369eBD7
  ```
  
* CEth Contract Address
  ```sh
  0x64078a6189Bf45f80091c6Ff2fCEe1B15Ac8dbde
  ```

### Prerequisites

You need a package manage like yarn or npm. I used yarn. After cloning repo: 
* yarn
  ```sh
  yarn install
  yarn hardhat compile
  yarn hardhat test
  ```
  
  You also need your .env file set up as such: 
* .env
  ```sh
  ETHERSCAN_API_KEY=[Etherscan key]
  GOERLI_URL=[Alchemy or Infura Url]
  PRIVATE_KEY=[Your goerli private key]
  ```


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>




