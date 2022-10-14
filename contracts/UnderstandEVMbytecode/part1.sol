// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.8;

contract EnMagicNumberAttack {
    function whatIsTheMeaningOfLife() public returns(uint256){
        return 42;
    }
}

contract EnMagicNumber {
  uint public balance;
  
  function add(uint value) public returns (uint256) {
        balance = balance + value;
        return balance;
    }
}