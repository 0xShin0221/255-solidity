// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/* Graph of inheritance
    A
   / \
  B   C
 / \ /
F  D,E

*/

contract A {
    mapping(uint256=>bool) private addressBool;
    function foo() internal virtual returns (string memory) {
        return "A";
    }
}
// TypeError: Definition of base has to precede definition of derived contract 
// contract G is B {
//     function foo() public pure virtual override returns (string memory) {
//         return "G";
//     }
// }
// Contracts inherit other contracts by using the keyword 'is'.
contract B is A {
    // Override A.foo()
    // function foo() public pure virtual override returns (string memory) {
    //     return "B";
    // }
}

contract ExtenderA is A{
    mapping(uint256=>bool) private addressBool2;
    function foo() internal virtual override  returns (string memory){
    }
}

contract Origin is ExtenderA,B {
    function foo() internal virtual override(ExtenderA,A) returns (string memory) {
        return "Origin";
    }

}


// contract C is A {
//     // Override A.foo()
//     function foo() public pure virtual override returns (string memory) {
//         return "C";
//     }
// }

//TypeError: Function needs to specify overridden contract "C".
// contract G is B,C {
//     function foo() public pure virtual override(B) returns (string memory) {
//         return "G";
//     }
// }

// Contracts can inherit from multiple parent contracts.
// When a function is called that is defined multiple times in
// different contracts, parent contracts are searched from
// right to left, and in depth-first manner.

// contract D is B, C {
//     // D.foo() returns "C"
//     // since C is the right most parent contract with function foo()
//     function foo() public pure override(B, C) returns (string memory) {
//         return super.foo();
//     }
// }

// contract E is C, B {
//     // E.foo() returns "B"
//     // since B is the right most parent contract with function foo()
//     function foo() public pure override(C, B) returns (string memory) {
//         return super.foo();
//     }
// }

// // Inheritance must be ordered from “most base-like” to “most derived”.
// // Swapping the order of A and B will throw a compilation error.
// contract F is A, B {
//     function foo() public pure override(A, B) returns (string memory) {
//         return super.foo();
//     }
// }

// // Inheritance must be ordered from “most base-like” to “most derived”.
// // Swapping the order of A and B will throw a compilation error.
// // contract G is B, A {
// //     function foo() public pure override(B, A) returns (string memory) {
// //         return super.foo();
// //     }
// // }



