pragma solidity 0.8.13;

contract Gas_Test{
    uint[] public arrayFunds;
    uint public totalFunds;

    constructor() {
        arrayFunds = [1,2,3,4,5,6,7,8,9,10,11,12,13];
    }

    function optionA() external {
        for (uint i =0; i < arrayFunds.length; i++){
            totalFunds = totalFunds + arrayFunds[i];
        }
    }
    // optionA
    // gas	96467 gas
    // transaction cost	83884 gas 
    // execution cost	83884 gas 

    function optionB() external {
        uint _totalFunds;
        for (uint i =0; i < arrayFunds.length; i++){
            _totalFunds = _totalFunds + arrayFunds[i];
        }
        totalFunds = _totalFunds;
    }
    // optionB
    // gas	70738 gas
    // transaction cost	61511 gas 
    // execution cost	61511 gas 

   function optionC() external {
        uint _totalFunds;
        uint[] memory _arrayFunds = arrayFunds;
        for (uint i =0; i < _arrayFunds.length; i++){
            _totalFunds = _totalFunds + _arrayFunds[i];
        }
        totalFunds = _totalFunds;
    }
    // optionC
    // gas	68376 gas
    // transaction cost	59457 gas 
    // execution cost	59457 gas 

    function unsafe_inc(uint x) private pure returns (uint) {
        unchecked { return x + 1; }
    }

    function optionD() external {
        uint _totalFunds;
        uint[] memory _arrayFunds = arrayFunds;
        for (uint i =0; i < _arrayFunds.length; i = unsafe_inc(i)){
            _totalFunds = _totalFunds + _arrayFunds[i];
        }
        totalFunds = _totalFunds;
    }
    // optionD
    // gas	90035 gas
    // transaction cost	78291 gas 
    // execution cost	78291 gas 
}