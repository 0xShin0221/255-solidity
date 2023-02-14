// SPDX-License-Identifier: MIT
pragma solidity ^0.4.17;


contract BytesOrStrings {
  string constant _string = "cryptopus.co Medium";
  bytes32 constant _bytes = "cryptopus.co Medium";

 //gas	24477 gas
  function  getAsString() public returns(string) {
    return _string;
  }
  // gas	24945 gas
  function  getAsBytes() public returns(bytes32) {
    return _bytes;
  }
}