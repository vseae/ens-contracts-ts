// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;
import "@openzeppelin/contracts/access/Ownable.sol";

contract BaseOracle is Ownable {
    uint256 internal basePrice;

    // 0.01 ether 1e16
    constructor(uint256 _price) {
        basePrice = _price;
    }

    function setPrice(uint256 _price) public onlyOwner {
        basePrice = _price;
    }

    function latestAnswer() public view returns (uint256) {
        return basePrice;
    }
}
