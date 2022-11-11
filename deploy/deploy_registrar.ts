import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { ethers } from "hardhat";
// import { getNamehash } from "../scripts/utils/get-namehash";
const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const registry = await deployments.get("ENSRegistryWithFallback");
  const baseNode = ethers.utils.namehash("pow");
  console.log("pow namehash: ", baseNode);
  await deploy("BaseRegistrarImplementation", {
    from: deployer,
    args: [registry.address, baseNode],
    log: true,
    deterministicDeployment: false,
  });
};
deploy.tags = ["registrar"];
deploy.dependencies = ["registry"];
export default deploy;
