pragma solidity ^0.8.0;

contract Box {
    uint256 private _value;

    function store(uint256 value) public {
        _value = value;
    }

    function retrieve() public view returns (uint256) {
        return _value;
    }
}

contract BoxProxy {

     function _delegate(address implementation) internal virtual {
         // delegating logic call to boxImpl...
     }

     function getImplementationAddress() public view returns (address) {
         // Returns the address of the implementation contract
     }

     fallback() external {
         _delegate(getImplementationAddress());
     }
}
