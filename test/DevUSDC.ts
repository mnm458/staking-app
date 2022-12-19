import { expect } from "chai";
// eslint-disable-next-line node/no-unpublished-import
import { BigNumber, BytesLike } from "ethers";
import { ethers } from "hardhat";
// eslint-disable-next-line node/no-missing-import
import { DevUSDC } from "../typechain-types";
import * as dotenv from "dotenv";

const TEST_MINT_VALUE = ethers.utils.parseUnits("1000");
const DUSDC_ADDR = process.env.DUSD_ADDR;

describe("Testing DevUSDC ERC20 Token", () => {
  let tokenContract: DevUSDC;
  let account1: any;
  let account2: any;
  let minterRoleHash: BytesLike;

  beforeEach(async () => {
    [account1, account2] = await ethers.getSigners();
    const devUsdc = await ethers.getContractFactory("DevUSDC");
    tokenContract = devUsdc.attach(DUSDC_ADDR !== undefined ? DUSDC_ADDR : "");
    minterRoleHash = await tokenContract.MINTER_ROLE();
  });

  describe("when the contract is deployed", async () => {

    it("sets the deployer as minter", async () => {
      const hasRole = await tokenContract.hasRole(
        minterRoleHash,
        account1.address
      );
      expect(hasRole).to.eq(true);
    });

    describe("when the minter call the mint function", async () => {
      beforeEach(async () => {
        const mintTx = await tokenContract.mint(
          account1.address,
          TEST_MINT_VALUE
        );
        await mintTx.wait();
      });

      it("updates the total supply", async () => {
        let totalSupply = await tokenContract.totalSupply();
        let denom =  BigNumber.from(10).pow(18);
        let NumtotalSupply = totalSupply.div(denom).toNumber();
        const expectedValue = Number(TEST_MINT_VALUE);
        const diff = NumtotalSupply - expectedValue;
        expect(diff).to.eq(0);
      });
    });
  });
});