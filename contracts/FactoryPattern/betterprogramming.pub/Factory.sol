//SPDX-License-Identifier: MIT
pragma solidity ^0.4.0;

import './CloneFactory.sol';

contract Factory is CloneFactory {
     Child[] public children;
     address public masterContract;

     constructor(address _masterContract) public {
         masterContract = _masterContract;
     }

     function createChild(uint data) external{
        Child child = Child(createClone(masterContract));
        child.init(data);
        children.push(child);
     }

     function getChildren() external view returns(Child[] memory){
         return children;
     }
}

contract Child{
    uint public data;
    
    // use this function instead of the constructor
    // since creation will be done using createClone() function
    function init(uint _data) external {
        data = _data;
    }
}