import {ethers} from "hardhat";
import { Vault, DevUSDC } from "../typechain-types";
import { assert, expect } from "chai";
import { BytesLike } from "ethers";
import { token } from "../typechain-types/@openzeppelin/contracts";

function delay(ms: number) {
    return new Promise( resolve => setTimeout(resolve, ms) );
}
const SECONDS_IN_A_YEAR = 31449600
describe("Staking Vault Testing", function () {
    let tokenContract: DevUSDC;
    let minterRoleHash: BytesLike;
    let vaultContract: Vault;
    let accounts: any[];
    beforeEach(async function(){
        accounts = await ethers.getSigners();
        const tokenFactory = await ethers.getContractFactory(
            "DevUSDC"
        );
        tokenContract = await tokenFactory.deploy();
        await tokenContract.deployed();
        minterRoleHash = await tokenContract.MINTER_ROLE();
        const mintTx = await tokenContract.mint(
            accounts[1].address,
            1000
          );
        await mintTx.wait();

        const vaultFactory = await ethers.getContractFactory("Vault");
        vaultContract = await  vaultFactory.deploy(tokenContract.address);
        await vaultContract.deployed();
        const approveTx = await tokenContract.approve(vaultContract.address,500);
        console.log("Vault and DevUSDC contracts deployed")
        

    })

    describe("when stake function is called", function () {
        it("should have amount in wei", async () =>{
            const stakeTx = await vaultContract.stake({value: ethers.utils.parseEther("15.0")});
            await stakeTx.wait(); 
            const checkBal = await vaultContract.balanceOf(accounts[0].address);
            const checkUserStakes = await vaultContract.userStakes(accounts[0].address);
            console.log(checkUserStakes);
            await delay(10000);
            const stakeTx2 = await vaultContract.stake({value: ethers.utils.parseEther("5.0")});
            await stakeTx2.wait();
            const checkUserStakes2 = await vaultContract.userStakes(accounts[0].address);
            console.log(checkUserStakes2);

        })
    })
});

