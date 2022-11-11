import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
// import { getNamehash } from "../scripts/utils/get-namehash";
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
