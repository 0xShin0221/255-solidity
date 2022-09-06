// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./library_solidity101.sol";


contract Calcurator{
    using MathUtils for uint;
    function getSum(uint firstNumber, uint secondNumber) public pure returns(uint) {
        return firstNumber.add(secondNumber);
    }
}