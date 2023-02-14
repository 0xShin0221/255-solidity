// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// "abstract" keyword denotes abstraction
abstract contract BaseContract {
  int public baseX;
  
  constructor() {
    baseX = 10;
  }

  // "virtual" must be used in an abstract class for a function whether it is implemented or not
  function setX() virtual public;
}

// "is" keyword denotes inheritance
contract ChildContract is BaseContract {
  int public childX;
  
  constructor() {
    childX = 20;
  }
  
  function setX() override public {
      baseX = 100;
  }
}


contract BaseContract2 {
  int public baseX;
  
  constructor() {
    baseX = 10;
  }
  
  // base class fn must be marked with virtual when it is overridden in the child class
  function setX(int _x) virtual public {

      // Called child setX(5) but this is not work
      baseX = 100;
  }
}

// "is" keyword denotes inheritance
contract ChildContract2 is BaseContract2 {
  int public childX;
  
  constructor() {
    childX = 20;
  }

  // override the base class fn
  function setX(int _x) override public {
      childX = _x;
      
      // call the base class fn using one of the following ways
      super.setX(_x);
      // BaseContract.setX(_x);
  }

  function setY(int256 _y) public pure returns (int256){
      return _y;
  }
}


// Intefaces have a lot more limitations compared to abstract classes:

// cannot implement any functions
// cannot inherit any other classes but interfaces
// cannot declare constructor or state variables
// all declared functions must be external
// This is an example of how an interface is implemented:



interface Interface3 {
    // fns in interfaces are VIRTUAL BY DEFAULT
    // fns in interfaces must be marked external
    function setX(uint _x) external;
}

contract ChildContract3 is Interface3 ,ChildContract2 {
    uint public x;

    function setX(uint _x) public override {
        x = _x;
    }
}