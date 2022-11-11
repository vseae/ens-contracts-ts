import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
// import { getNamehash } from "../scripts/utils/get-namehash";
const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const registry = await deployments.get("ENSRegistryWithFallback");
  const resolver = await deployments.get("PublicResolver");
  await deploy("ReverseRegistrar", {
    from: deployer,
    args: [registry.address, resolver.address],
    log: true,
    deterministicDeployment: false,
  });
};
deploy.tags = ["reverse"];
deploy.dependencies = ["registry,resolver"];
export default deploy;
