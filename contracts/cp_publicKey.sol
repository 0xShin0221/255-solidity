// SPDX-License-Identifier: MIT
pragma solidity ^0.4.21;

contract CpPublicKey {

    address owner = 0x92b28647ae1f3264661f72fb2eb9625a89d88a31;
    bool public isComplete;
    
    function authenticate(bytes publicKey) public {
        require(address(keccak256(publicKey)) == owner);
        isComplete = true;
    }

    function genKey()public returns (address){
        return publicKey;
    }
}
