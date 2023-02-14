//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;
import "@chainlink/contracts/src/v0.7/Operator.sol";

// TODO: Change the contract name to ChainlinkOperator
contract ChainlinkOperator is Operator {
    constructor(address operatorAddress)
        Operator(operatorAddress, msg.sender)
    {}
}