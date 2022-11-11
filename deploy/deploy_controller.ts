import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
// import { getNamehash } from "../scripts/utils/get-namehash";
const deploy: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const registrar = await deployments.get("BaseRegistrarImplementation");
  const oracle = await deployments.get("FixedPriceOracle");
  await deploy("ETHRegistrarController", {
    from: deployer,
    args: [registrar.address, oracle.address, 60, 86400],
    log: true,
    deterministicDeployment: false,
  });
};
deploy.tags = ["controller"];
deploy.dependencies = ["registrar", "oracle", "resolver"];
export default deploy;
