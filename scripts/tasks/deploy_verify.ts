import "hardhat-deploy";
import "@nomiclabs/hardhat-ethers";
import { task } from "hardhat/config";

task("deploy-verify", "Deploys and verifies Safe contracts").setAction(
  async (_, hre) => {
    await hre.run("deploy");
    await hre.run("etherscan-verify", {
      forceLicense: true,
      license: "MIT",
    });
  }
);

export {};
