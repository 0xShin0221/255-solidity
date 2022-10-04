// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract NestedStruct {
    
    struct Identity {
        uint age;
        string name;
    }
    
    struct NestedIdentity {
        Identity identity;
    }

    mapping(uint => NestedIdentity) Identities;
    
    Identity identity = Identity(29, '@go');
    Identity identity2 = Identity(35, '@sintaro');
    
    NestedIdentity nested_identity = NestedIdentity(identity);
    
    function valueFromStruct() public view returns(uint age, string memory name) {
        return (nested_identity.identity.age, nested_identity.identity.name);
    }

    function getFromId(uint id) public view returns(uint age, string memory name) {
        return(Identities[id].identity.age, Identities[id].identity.name);
    }
}

contract Nest {

  struct IpfsHash {
    bytes32 hash;
    uint hashSize;
  }

  struct Member {
    IpfsHash ipfsHash;
  }

  mapping(uint => Member) members;

  function addMember(uint id, bytes32 hash, uint size) public returns(bool success) {
    members[id].ipfsHash.hash = hash;
    members[id].ipfsHash.hashSize = size;
    return true;
  }

  function getMember(uint id) public view returns(bytes32 hash, uint hashSize) {
    return(members[id].ipfsHash.hash, members[id].ipfsHash.hashSize);
  }
}

