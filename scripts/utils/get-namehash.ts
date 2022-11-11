import { namehash } from "ethers/lib/utils";

function getNamehash(name: string): string {
  console.log("namehash: ", namehash(name));
  return namehash(name);
}
getNamehash("addr.reverse");
exports.getNamehash = getNamehash;
