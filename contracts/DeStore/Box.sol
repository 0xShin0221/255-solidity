// contracts/Box.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 private value;

    mapping(uint256 => address) public tokens;
    /// @dev Set the purchase price for each Fake NFT
    uint256 nftPrice = 0.01 ether;

    address constant public timeLock =0xaA8f176c3F111597169a647D69520Bf4849286F8;

    modifier onlytimeLock()
    {
        require(msg.sender == address(timeLock), "Box::onlytimeLock::wrong_address");
        _;
    }
    // Emitted when the stored value changes
    event ValueChanged(uint256 newValue);

    // Stores a new value in the contract
    function store(uint256 newValue) public onlytimeLock {
        value = newValue;
        emit ValueChanged(newValue);
    }

    // Stores a new value in the contract
    function store2(uint256 newValue) public {
        value = newValue;
        emit ValueChanged(newValue);
    }

    function purchase(uint256 _tokenId) external payable {
        require(msg.value == nftPrice, "This NFT costs 0.01 ether");
        tokens[_tokenId] = msg.sender;
    }

    function purchase2(uint256 _tokenId) public payable {
        require(msg.value == nftPrice, "This NFT costs 0.01 ether");
        tokens[_tokenId] = msg.sender;
    }


    function purchase3(uint256 _tokenId) public payable onlytimeLock {
        require(msg.value == nftPrice, "This NFT costs 0.01 ether");
        tokens[_tokenId] = msg.sender;
    }

    // Reads the last stored value
    function retrieve() public view returns (uint256) {
        return value;
    }
}
