import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  await deploy("ETHRegistrarController", {
    from: deployer,
    args: [],
    log: true,
    deterministicDeployment: false,
  });
};
deploy.tags = ["ETHRegistrarController"];
export default deploy;
