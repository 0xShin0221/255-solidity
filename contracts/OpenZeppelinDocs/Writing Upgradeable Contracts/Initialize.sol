pragma solidity ^0.8.0;

contract Initialize {
    uint256 public x;
    bool private initialized;

    function initialize(uint256 _x) public {
        require(!initialized, "Contract instance has already been initialized");
        initialized = true;
        x = _x;
    }
}

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract InitializeContract is Initializable {
    uint256 public x;

    function initialize(uint256 _x) public initializer {
        x = _x;
    }
}
//Another difference between a constructor and a regular function is that Solidity takes care of 
//automatically invoking the constructors of all ancestors of a contract. When writing an initializer,
// you need to take special care to manually call the initializers of all parent contracts. 
//Note that the initializer modifier can only be called once even when using inheritance, so parent contracts should use the onlyInitializing modifier:
contract BaseContract is Initializable {
    uint256 public y;

    function initialize() public onlyInitializing {
        y = 42;
    }
}

contract MyContract is BaseContract {
    uint256 public x;

    function initialize(uint256 _x) public initializer {
        BaseContract.initialize(); // Do not forget this call!
        x = _x;
    }
}

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract NGERC20Upgradeable is Initializable {
    ERC20 public token;

    function initialize() public initializer {
        token = new ERC20("Test", "TST"); // This contract will not be upgradeable
    }
}

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract OKERC20Upgradeable is Initializable {
    IERC20Upgradeable public token;

    function initialize(IERC20Upgradeable _token) public initializer {
        token = _token;
    }
}

