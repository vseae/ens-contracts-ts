pragma solidity ^0.8.4;
pragma experimental ABIEncoderV2;

import "../root/Ownable.sol";
import "./PublicSuffixList.sol";

contract SimplePublicSuffixList is PublicSuffixList, Ownable {
    mapping(bytes => bool) suffixes;

    function addPublicSuffixes(bytes[] memory names) public onlyOwner {
        for (uint256 i; i < names.length;) {
            suffixes[names[i]] = true;
            unchecked {
                ++i;
            }
        }
    }

    function isPublicSuffix(bytes calldata name) external view override returns (bool) {
        return suffixes[name];
    }
}
