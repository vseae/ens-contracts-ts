import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
// import { getNamehash } from "../scripts/utils/get-namehash";

const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const registry = await deployments.get("ENSRegistryWithFallback");
  await deploy("PublicResolver", {
    from: deployer,
    args: [registry.address, ethers.constants.AddressZero],
    log: true,
    deterministicDeployment: false,
  });
};

deploy.tags = ["resolver"];
deploy.dependencies = ["registry"];
export default deploy;
