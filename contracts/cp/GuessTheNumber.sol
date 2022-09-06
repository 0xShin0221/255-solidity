// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IGuessTheNumber{
    function GuessTheNumberChallenge() external payable;
    function isComplete() external returns(bool);
    function guess(uint8 n) external payable;
}

contract SolutionGuessTheNumber{
    address target = 0xa361754cC42f718204D8E2266dfCDade004C2b9E;
    IGuessTheNumber instance = IGuessTheNumber(target);

    function askComplete() public  returns (bool) {
        return instance.isComplete();
    }

    function guess(uint8 n) public {
        instance.guess(n);
    }

}