// SPDX-License-Identifier: MIT
pragma solidity ^0.5.5;

contract Attack {
    function whatIsTheMeaningOfLife() public pure returns (uint256 ){
        return 42;
    }
}
 
contract DeployBytecode {
    
    // Create contract from bytecode
    function deployBytecode(bytes memory bytecode) public returns (address) {
        address retval;
        assembly{
            mstore(0x0, bytecode)
            retval := create(0,0xa0, calldatasize)
        }
        return retval;
   }
} 

// Solidity state
// 000 PUSH1 80
// 002 PUSH1 40
// 004 MSTORE
// 005 CALLVALUE
// 006 DUP1
// 007 ISZERO
// 008 PUSH1 0f
// 010 JUMPI
// 011 PUSH1 00
// 013 DUP1
// 014 REVERT
// 015 JUMPDEST
// 016 POP
// 017 PUSH1 87
// 019 DUP1
// 020 PUSH2 001e
// 023 PUSH1 00
// 025 CODECOPY
// 026 PUSH1 00
// 028 RETURN
// 029 INVALID