// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;
contract C {
    // (2**256 - 1) + 1 = 0
    uint256 public max;
    uint32 public lastTopHatId;

    mapping(uint256 => Hat) internal _hats; 

    struct Hat {
        // 1st storage slot
        uint256 number; 
    }

    function set() public  returns (uint256 _unoverflow) {
        max = 2**256 - 1;
        lastTopHatId = 2**32 -2;
        return max;
    }

    function overflow() public   {
        max = uint256(++lastTopHatId) << 224;
        _createHat(max);
    }
    
    function _createHat(uint256 id) internal returns (Hat memory hat){
        hat.number = id;
        _hats[id] = hat;
        return hat;
    }
}