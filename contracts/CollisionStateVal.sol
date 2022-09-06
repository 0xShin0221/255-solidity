// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// implementation contract: LostStorage
contract LostStorage { 
　　　　　　　　address public collisionAddress; 
    uint public someUint;

// 以下はsetter関数で、あまり気にしなくてよい
    function setAddress(address _address) public {
        collisionAddress = _address;
    }

    function setMyUint(uint _uint) public {
        someUint = _uint;
    }

}

//proxy contract: ProxyClash
contract ProxyClash { 
    address public aotherContractAddress;
    uint public anotherUint;
    
// proxy contractのconstructor、引数にimplementation contract addressと任意の数字を代入
    constructor(address _aotherContract, uint _num) {
        aotherContractAddress = _aotherContract;
        anotherUint = _num;
    }

// setter関数で、あまり気にしなくてよい
    function setOtherAddress(address _aotherContract) public {
        aotherContractAddress = _aotherContract;
    }

// proxy contractのfallback関数でcallをimplementation contractへdelegatecallするための内容が書かれている
  fallback() external {
    address _impl = aotherContractAddress;

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize())
      let result := delegatecall(gas(), _impl, ptr, calldatasize(), 0, 0)
      let size := returndatasize()
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}c