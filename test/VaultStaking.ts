import {ethers} from "hardhat";
import { Vault, DevUSDC } from "../typechain-types";
import { expect } from "chai";
import { BytesLike, BigNumber } from "ethers";
import * as dotenv from "dotenv";


const CETH_ADDR = process.env.CETH_ADDR;
function delay(ms: number) {
    return new Promise( resolve => setTimeout(resolve, ms) );
}
const SECONDS_IN_A_YEAR = 31449600;
const STAKE_AMOUNT = "5";
const REWARD_RATE = 10;
describe("Staking Vault Testing", function () {
    let tokenContract: DevUSDC;
    let minterRoleHash: BytesLike;
    let vaultContract: Vault;
    let account1: any;
    let account2: any;
    before(async function(){
        [account1, account2] = await ethers.getSigners();
        const devUsdc = await ethers.getContractFactory("DevUSDC");
        tokenContract = await devUsdc.attach("0x64078a6189Bf45f80091c6Ff2fCEe1B15Ac8dbde");
        const vault = await ethers.getContractFactory("Vault");
        vaultContract = await vault.attach("0x8cEC7779132A5a1cB1271e20751715ed70bcb021");
        
        describe("When contract gets deployed", function () {
            it("should have a constant 10% reward rate", async () =>{
                const rewardRate = await vaultContract.rewardrate();
                expect(rewardRate).to.eq(REWARD_RATE);
            })

        })

    })

    describe("when stake function is called", function () {
        let initialStake: any;
        before(async function(){
            initialStake =  await vaultContract.balanceOf(account1.address);
            initialStake = BigNumber.from(initialStake);
            console.log("Initial stake: ", initialStake);
            const stakeTx = await vaultContract.stake({value: ethers.utils.parseEther(STAKE_AMOUNT)});
            await stakeTx.wait(1);
        })
        it(" should not allow less than 5 ether to be staked", async () =>{
            await expect( vaultContract.stake({value: ethers.utils.parseEther("4.0")})).to.be.revertedWith("Please stake 5 or more eth");
        })

        it("should increase the user's staked amount", async () =>{
            let newStake: any;
            newStake = await vaultContract.balanceOf(account1.address);
            newStake = BigNumber.from(newStake);
            console.log("New stake: ", newStake);
            const difference = newStake.sub(initialStake);
            expect(difference).to.eq(ethers.utils.parseEther(STAKE_AMOUNT));
        })
        it("should not allow user to redeem rewards without unstaking", async () =>{
            await expect( vaultContract.redeemRewards()).to.be.revertedWith("You don't have any rewards to redeem");
        })
    })

    describe("When two users stake and unstake simulatneously", function () {
        let initialStakeAcc1: any;
        let initialStakeAcc2: any;
        let acc1Signer: any;
        let acc2Signer: any;
        before(async function(){
            initialStakeAcc1 =  await vaultContract.balanceOf(account1.address);
            initialStakeAcc1 = BigNumber.from(initialStakeAcc1);
            console.log("Initial stake acc`1: ", initialStakeAcc1);
            initialStakeAcc2 =  await vaultContract.balanceOf(account2.address);
            initialStakeAcc2 = BigNumber.from(initialStakeAcc2);
            console.log("Initial stake acc2: ", initialStakeAcc2);

            acc1Signer = vaultContract.connect(account1);
            acc2Signer = vaultContract.connect(account2);
            
            const stakeTx1 = await acc1Signer.stake({value: ethers.utils.parseEther(STAKE_AMOUNT)});
            const stakeTx2 = await acc2Signer.stake({value: ethers.utils.parseEther(STAKE_AMOUNT)});
            await stakeTx1.wait(1);
            await stakeTx2.wait(1);
        })

        it("should increase both user's staked amount", async () =>{
                    let newStake1: any;
                    newStake1 = await vaultContract.balanceOf(account1.address);
                    newStake1 = BigNumber.from(newStake1);
                    console.log("New stake: ", newStake1);
                    const difference1 = newStake1.sub(initialStakeAcc1);
                    expect(difference1).to.eq(ethers.utils.parseEther(STAKE_AMOUNT));

                    let newStake2: any;
                    newStake2 = await vaultContract.balanceOf(account2.address);
                    newStake1 = BigNumber.from(newStake2);
                    console.log("New stake: ", newStake2);
                    const difference2 = newStake2.sub(initialStakeAcc2);
                    expect(difference2).to.eq(ethers.utils.parseEther(STAKE_AMOUNT));
                })
        

        
        it("should allow the users to unstake at any time", async () =>{
            await delay(1000);
            let unstake1 = await acc1Signer.unstake();
            let unstake2 = await acc2Signer.unstake();
            await unstake1.wait(1);
            await unstake2.wait(1);
            expect(await acc1Signer.redeemRewards()).to.be.greaterThan(0);
            expect(await acc1Signer.redeemRewards()).to.be.greaterThan(0);
            expect(await vaultContract.balanceOf(account1.address)).to.be.greaterThan(0);
            expect(await vaultContract.balanceOf(account2.address)).to.be.greaterThan(0);
        })

    })

    describe("When Chainlink oracle is called", function () {
        let ethPrice: any;
        before(async function(){
            ethPrice = await vaultContract.getPrice();
            await ethPrice.wait(1);
            console.log(`latest price of ETH/USD: ${ethPrice * 10**-8} USD`);
        })

    })

});
   

