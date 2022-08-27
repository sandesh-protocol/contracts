import { ethers } from "hardhat";

async function main() {
  const Sandesh = await ethers.getContractFactory("Sandesh");
  const sandeshk = await Sandesh.deploy();

  await sandeshk.deployed();

  console.log(`Sandesh contracts are deployed at address ${sandeshk.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
