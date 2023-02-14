// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// NOTE: Deploy this contract first
contract B {
    // NOTE: storage layout must be the same as contract A
    address public sender;
    uint public num;

    // uint public value;

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        // value = msg.value;
    }
}

contract A {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _contract, uint _num) public  returns (bool){
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSignature("setVars(uint256)", _num)
        );
        return success;
    }
}

interface IB {
    function setVars(uint _num) external;
}
contract AWithSelector {
    uint public num;
    address public sender;
    uint public value;

    function setVars(address _contract, uint _num) public  returns (bool){
        // A's storage is set, B is not modified.
        (bool success, bytes memory data) = _contract.delegatecall(
            abi.encodeWithSelector(IB.setVars.selector, _num)
        );
        return success;
    }

}