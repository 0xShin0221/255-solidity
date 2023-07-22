// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./MyContract.sol";

contract MyFactory {
    address immutable template;

    constructor(address _template) {
        template = _template;
    }

    function createClone(string calldata _name) external returns (address) {
        address clone = Clones.clone(template);
        MyContract(clone).initialize(_name);
        return clone;
    }
}