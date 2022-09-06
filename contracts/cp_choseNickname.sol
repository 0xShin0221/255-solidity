// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract CaptureTheEther {
    mapping (address => bytes32) public nicknameOf;

    function setNickname(bytes32 nickname) public {
        nicknameOf[msg.sender] = nickname;
    }
}