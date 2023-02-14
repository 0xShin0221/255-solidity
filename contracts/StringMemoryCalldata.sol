pragma solidity 0.5.11;

contract Test {
    
    string stringTest;
    //calldata is allocated by the caller, while memory is allocated by the callee.
    
    function memoryTest(string memory _exampleString) public returns (string memory) {
        _exampleString = "example";  // You can modify memory
        string memory newString = _exampleString;  // You can use memory within a function's logic
        return newString;  // You can return memory
    }
    
    function calldataTest(string calldata _exampleString) external returns (string memory) {
        // cannot modify _exampleString
        // but can return it
        return _exampleString;
    }
}