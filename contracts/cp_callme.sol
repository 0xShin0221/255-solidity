// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface ICallMe{
    function callme() external;
}


contract GatekeeperHack{    
    ICallMe calltarget = ICallMe(0x54Fc41653F1945BeDceFd375DE60514067ff6C43);

    function callme() public{
        calltarget.callme();
    }
}