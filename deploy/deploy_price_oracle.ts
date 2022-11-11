import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
// import { getNamehash } from "../scripts/utils/get-namehash";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const basePrice = ethers.utils.parseEther("0.01");
  const BaseOracleResult = await deploy("BaseOracle", {
    from: deployer,
    args: [basePrice],
    log: true,
    deterministicDeployment: false,
  });
  if (BaseOracleResult.newlyDeployed) {
    await deploy("FixedPriceOracle", {
      from: deployer,
      args: [BaseOracleResult.address, [1, 1, 1, 1, 1]],
      log: true,
      deterministicDeployment: false,
    });
  }
};

deploy.tags = ["oracle"];
export default deploy;
