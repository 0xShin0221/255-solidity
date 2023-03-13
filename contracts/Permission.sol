// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract Permission {

    mapping(bytes32 => address) public permissionHashed;


    function permissionHash(
        address _where,
        address _who,
        bytes32 _permissionId
    ) internal pure virtual returns (bytes32) {
        return keccak256(abi.encodePacked("PERMISSION", _who, _where, _permissionId));
    }

    function registHash(        
        address _where,
        address _who,
        bytes32 _permissionId
        ) public view returns(address){
            bytes32  hash = permissionHash(_where, _who, _permissionId);
            address ch = permissionHashed[hash];
            return ch;
        }
    
}