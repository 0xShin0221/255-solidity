// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

contract Confidential {
    string public firstUser = "ALICE";
    uint public alice_age = 24;
	bytes32 private ALICE_PRIVATE_KEY; //Super Secret Key
    bytes32 public ALICE_DATA = "QWxpY2UK";
    bytes32 private aliceHash = hash(ALICE_PRIVATE_KEY, ALICE_DATA);

    string public secondUser = "BOB";
    uint public bob_age = 21;
    bytes32 private BOB_PRIVATE_KEY; // Super Secret Key
    bytes32 public BOB_DATA = "Qm9iCg";
    bytes32 private bobHash = hash(BOB_PRIVATE_KEY, BOB_DATA);
		
	constructor() {}

    function hash(bytes32 key1, bytes32 key2) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(key1, key2));
    }

    function checkthehash(bytes32 _hash) public view returns(bool){
        require (_hash == hash(aliceHash, bobHash));
        return true;
    }
}

// https://dev.to/erhant/quillctf-2-confidential-hash-5h0b

// ❯❯❯ cast storage -r https://rpc.ankr.com/eth_goerli 0xf8E9327E38Ceb39B1Ec3D26F5Fad09E426888E66 0
// 0x414c49434500000000000000000000000000000000000000000000000000000a
// ❯❯❯ cast --format-bytes32-string "ALICE"
// 0x414c494345000000000000000000000000000000000000000000000000000000
// ❯❯❯ cast storage -r https://rpc.ankr.com/eth_goerli 0xf8E9327E38Ceb39B1Ec3D26F5Fad09E426888E66 2
// 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
// ❯❯❯ cast storage -r https://rpc.ankr.com/eth_goerli 0xf8E9327E38Ceb39B1Ec3D26F5Fad09E426888E66 4
// 0x448e5df1a6908f8d17fae934d9ae3f0c63545235f8ff393c6777194cae281478
// ❯❯❯ cast storage -r https://rpc.ankr.com/eth_goerli 0xf8E9327E38Ceb39B1Ec3D26F5Fad09E426888E66 9
// 0x98290e06bee00d6b6f34095a54c4087297e3285d457b140128c1c2f3b62a41bd

// cast keccak 0x412f9cac448e5df1a6908f8d17fae934d9ae3f0c63545235f8ff393c6777194cae28147898290e06bee00d6b6f34095a54c4087297e3285d457b140128c1c2f3b62a41bd
// 0x0e03d6e215ec72db4ce22dffcf0d82ba287d8e04b5a65e823aef448e22e5a08
