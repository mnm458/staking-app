import { ethers } from "ethers";
import "dotenv/config";

const EXPOSED_KEY = "loremipsum";

function convertStringArraytoBytes32(strings: string[]): string[] {
  return strings.map((string) => ethers.utils.formatBytes32String(string));
}

async function main() {

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
})