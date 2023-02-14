// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Storage {
    uint public val;
    constructor(uint v)  {
            val = v;
        }
    function setValue(uint v) public {
            val = v;
        }
}
contract Machine {
    
    uint256 public calculateResult;
    
    address public user;

    Storage public s;

  
    event AddedValuesByDelegateCall(uint256 a, uint256 b, bool success);
    event AddedValuesByCall(uint256 a, uint256 b, bool success);
    
  
    constructor(Storage addrStorage)  {
            s = addrStorage;
            calculateResult = 0;
        }
        
    function saveValue(uint x) public returns (bool) {
        s.setValue(x);
        return true;
    }
    function getValue() public view returns (uint) {
            return s.val();
        }

    function addValuesWithDelegateCall(address calculator, uint256 a, uint256 b,string memory c) public payable returns  (uint256) {
        bytes memory encodedData = encodeData(b,c);
        (bool success, bytes memory result) = calculator.delegatecall(abi.encodeWithSignature("add(uint256,bytes)", a, encodedData));
        
        // encodeWithSelector
        // (bool success, bytes memory result) = calculator.delegatecall(abi.encodeWithSelector(ICalculator.add.selector, a, encodedData));
        
        emit AddedValuesByDelegateCall(a, b, success);
        // return abi.decode(result, (uint256));
    }

    // function addValuesWithCall(address calculator, uint256 a, uint256 b) public returns (uint256) {
    //     (bool success, bytes memory result) = calculator.call(abi.encodeWithSignature("add(uint256,bytes)", a, b));
    //     emit AddedValuesByCall(a, b, success);
    //     return abi.decode(result, (uint256));
    // }

    function encodeData(uint256 _b, string memory _c) internal pure returns (bytes memory) {
        return abi.encodePacked(_b,_c);
    }
}

interface ICalculator {
    function add(uint256, bytes calldata) external;
}

contract Calculator {
    uint256 public calculateResult;
    
    address public user;
    
    event Add(uint256 a, bytes b);
    
    function add(uint256 a, bytes memory b) public payable returns (uint256) {

        assert(calculateResult >= a);
        
        // emit Add(a, b);
        user = msg.sender;
        
        return calculateResult;
    }
}