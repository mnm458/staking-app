import { ethers } from "ethers";
import "dotenv/config";
import * as vaultJson from "../artifacts/contracts/Vault.sol/Vault.json";
import * as devUSDCJson from "../artifacts/contracts/DevUSDC.sol/DevUSDC.json";

const EXPOSED_KEY = "loremipsum";
const DUSDC_ADDR = "0x81F1D8930adf53dd52c2Ca95Cd89783Ed369eBD7";
const CETH_ADDR = "0x64078a6189Bf45f80091c6Ff2fCEe1B15Ac8dbde";
const COMPTROLLER_ADDR = "0x05Df6C772A563FfB37fD3E04C1A279Fb30228621";


async function main() {
  const wallet =
  process.env.MNEMONIC && process.env.MNEMONIC.length > 0
    ? ethers.Wallet.fromMnemonic(process.env.MNEMONIC)
    : new ethers.Wallet(process.env.PRIVATE_KEY ?? EXPOSED_KEY);
  console.log(`Using address ${wallet.address}`);
  const provider = ethers.providers.getDefaultProvider("goerli");
  const signer = wallet.connect(provider);
  const balanceBN = await signer.getBalance();
  const balance = Number(ethers.utils.formatEther(balanceBN));
  console.log(`Wallet balance ${balance}`);
  if (balance < 0.01) {
    throw new Error("Not enough ether");
  }
  // console.log("Deploying DevUSDC");

  // const devUSDCFactory = new ethers.ContractFactory(
  //   devUSDCJson.abi,
  //   devUSDCJson.bytecode,
  //   signer
  // );
  // const devUSDContract = await devUSDCFactory.deploy();
  // console.log("Awaiting confirmations");
  // await devUSDContract.deployed();
  // console.log("Completed");
  // console.log(`Contract deployed at ${devUSDContract.address}`);

  console.log("Deploying Vault contract");
  const vaultFactory = new ethers.ContractFactory(
    vaultJson.abi,
    vaultJson.bytecode,
    signer
  );
  const vaultContract = await vaultFactory.deploy(
   ethers.utils.getAddress(DUSDC_ADDR),
   ethers.utils.getAddress(CETH_ADDR)
  );
  console.log("Awaiting confirmations");
  await vaultContract.deployed();
  console.log("Completed");
  console.log(`Contract deployed at ${vaultContract.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})