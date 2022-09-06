// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

interface IGatekeeperOne{
    function enter(bytes8 key) external returns (bool);
}


contract GatekeeperHack{    
    IGatekeeperOne gateOne = IGatekeeperOne(0xC140E767819E2cdF09eAb3E1e8d9a23e13338899);
    
}