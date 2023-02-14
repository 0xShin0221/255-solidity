
// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract ERC20_Token_Sample is ERC20, ERC20Burnable {
    constructor() ERC20("ERC20 Token Sample1", "Sample 1") {
        _mint(msg.sender, 100_000_000_000 * 10**18 );
    }
}
contract DAY6UnSecureAttack {
    
    ERC20_Token_Sample bbb;

    event Response(bool success, bytes data);

    constructor(ERC20_Token_Sample _bbb) {
        bbb = _bbb;
    }

    function attack(address _token) public payable {
         (bool success, bytes memory data)= address(bbb).call(
            abi.encodeWithSignature("deposit(uint _amount, address _token, bool _isETH)", 100,_token,false)
        );
        require(success, "call failed");
        emit Response(success, data);
         (bool success2, bytes memory data2)=address(bbb).call(
            abi.encodeWithSignature("withdraw(address _to,uint _amount,bool _isETH,address _token)",address(this),10,false,_token)
        );
        require(success2, "call failed2");
        emit Response(success2, data2);
    }
}

