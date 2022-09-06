// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10;

contract cutByte32 {

  //"0xa9c40ddcb43ebbc83add97b8f9f361f12b19bceff2f76b68f66b5bb1812365a9"
  //use this as remix command
    event trace (bytes32 sha,bytes16 half1,bytes16 half2);
    function cut(bytes32 sha) public returns (bytes16 half1, bytes16 half2) {
        assembly {
        let freemem_pointer := mload(0x40) // 0x40 (solidity definition) the pointer (/address) for the next free slot on the memory is stored
        mstore(add(freemem_pointer,0x00), sha)
        half1 := mload(add(freemem_pointer,0x00))
        half2 := mload(add(freemem_pointer,0x10))
        }
    }
}