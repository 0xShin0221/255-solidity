// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract MyContract {
    address immutable template;

    constructor() {
        
    }

    function createClone(string calldata word) external returns (string) {
        return word;
    }
} 