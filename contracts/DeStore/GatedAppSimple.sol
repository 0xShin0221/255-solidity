// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";

contract GateApp is ERC721Upgradeable {
    uint8 public tokenCount = 0;
    uint8 public maxTokens = 100;
    uint256 initialTokenPrice = 100000000000000000;

    // constructor() public {

    // }

    function initialize() public initializer {
        __ERC721_init("GateApp", "GA");
    }

    function claimToken() public payable returns (bool) {
        require(msg.value == initialTokenPrice);
        if ((tokenCount < maxTokens) && (balanceOf(msg.sender) == 0)) {
            _mint(msg.sender, tokenCount);
            tokenCount += 1;
        }
        return true;
    }

    function unclaimedTokens() public view returns (uint8) {
        return maxTokens - tokenCount;
    }

    function totalTokenOwners() public view returns (uint8) {
        return tokenCount;
    }
}
