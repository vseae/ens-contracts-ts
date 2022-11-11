import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
// import { getNamehash } from "../scripts/utils/get-namehash";
const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const ENSRegistryResult = await deploy("ENSRegistry", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
  if (ENSRegistryResult.newlyDeployed) {
    await deploy("ENSRegistryWithFallback", {
      from: deployer,
      args: [ENSRegistryResult.address],
      log: true,
      deterministicDeployment: false,
    });
  }
};
deploy.tags = ["registry"];
export default deploy;
