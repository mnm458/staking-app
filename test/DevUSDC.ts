import {ethers} from "hardhat";
import { DevUSDC } from "../typechain-types";
import { expect } from "chai";


describe("DevUSDC", function () {
    let tokenContract: DevUSDC;
    let accounts: any[];
    beforeEach(async function(){
        accounts = await ethers.getSigners();
        const contractFactory = await ethers.getContractFactory("DevUSDC");
        tokenContract = await  contractFactory.deploy(1000000);
        await tokenContract.deployed();
    })

    describe("when the contract is deployed", function () {
        it("has an total supply of 1000000", async () =>{
            const totalSupply = await tokenContract.totalSupply();
            expect(totalSupply).to.eq(1000000);
        })
    })
});

