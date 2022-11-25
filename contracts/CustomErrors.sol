// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

error Unauthorized();

contract VendingMachine {
    address payable owner = payable(msg.sender);

    function withdraw() public {
        if (msg.sender != owner)
            revert Unauthorized();

        owner.transfer(address(this).balance);
    }
}

/// Insufficient balance for transfer. Needed `required` but only
/// `available` available.
/// @param available balance available.
/// @param required requested amount to transfer.
error InsufficientBalance(uint256 available, uint256 required);

contract TestToken {
    mapping(address => uint) balance;
    function transfer(address to, uint256 amount) public {
        if (amount > balance[msg.sender])
            // Error call using named parameters. Equivalent to
            // revert InsufficientBalance(balance[msg.sender], amount);
            revert InsufficientBalance({
                available: balance[msg.sender],
                required: amount
            });
        balance[msg.sender] -= amount;
        balance[to] += amount;
    }
}


// ↓↓↓↓Decoding error data↓↓↓

// import { ethers } from "ethers";

// // As a workaround, we have a function with the
// // same name and parameters as the error in the abi.
// const abi = [
//     "function InsufficientBalance(uint256 available, uint256 required)"
// ];

// const interface = new ethers.utils.Interface(abi);
// const error_data =
//     "0xcf479181000000000000000000000000000000000000" +
//     "0000000000000000000000000100000000000000000000" +
//     "0000000000000000000000000000000000000100000000";

// const decoded = interface.decodeFunctionData(
//     interface.functions["InsufficientBalance(uint256,uint256)"],
//     error_data
// );
// // Contents of decoded:
// // [
// //   BigNumber { _hex: '0x0100', _isBigNumber: true },
// //   BigNumber { _hex: '0x0100000000', _isBigNumber: true },
// //   available: BigNumber { _hex: '0x0100', _isBigNumber: true },
// //   required: BigNumber { _hex: '0x0100000000', _isBigNumber: true }
// // ]
// console.log(
//     "Insufficient balance for transfer. " +
//     `Needed ${decoded.required.toString()} but only ` +
//     `${decoded.available.toString()} available.`
// );