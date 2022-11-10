import { namehash } from "ethers/lib/utils";

function getNamehash(name: string): string {
  return namehash(name);
}

exports.getNamehash = getNamehash;
