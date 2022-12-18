import {ethers} from "hardhat";
import { DevUSDC } from "../typechain-types";
import { expect } from "chai";

const PREMINT = ethers.utils.parseEther("0");

describe("Testing DevUSDC", function () {
    let tokenContract: DevUSDC;
    let accounts: any[];
    beforeEach(async function(){
        accounts = await ethers.getSigners();
        const contractFactory = await ethers.getContractFactory("DevUSDC");
        tokenContract = await  contractFactory.deploy(1000000);
        await tokenContract.deployed();
    });

    describe("when the contract is deployed", function () {
        it("has zero total supply", async () => {
            const totalSupplyBN = await tokenContract.totalSupply();
            const expectedValueBN = PREMINT;
            const diffBN = totalSupplyBN.gt(expectedValueBN)
              ? totalSupplyBN.sub(expectedValueBN)
              : expectedValueBN.sub(totalSupplyBN);
            const diff = Number(diffBN);
            expect(diff).to.eq(0);
          });
    });
});