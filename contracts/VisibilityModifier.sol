// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

contract Example {
    uint256 public publicNumber;  // 外部から読み取り/書き込み可能
    uint256 internal internalNumber;  // 内部からのみ読み取り/書き込み可能
    uint256 private privateNumber;  // このコントラクトの内部からのみ読み取り/書き込み可能

    function SetExample() public {
        publicNumber = 0;
        internalNumber = 0;
        privateNumber = 0;
    }

    function setPublicNumber(uint256 newValue) public {  // 外部から読み取り/書き込み可能
        publicNumber = newValue;
    }

    function setExternalNumber(uint256 newValue) external {  // 外部からのみ書き込み可能
        publicNumber = newValue;  // これは正しい修飾子ではありません。コンパイルエラーになる。
    }

    function getInternalNumber() internal view returns (uint256) {  // 内部からのみ読み取り可能
        return internalNumber;
    }

    function setPrivateNumber(uint256 newValue) private {  // このコントラクトの内部からのみ書き込み可能
        privateNumber = newValue;
    }
}

contract ChildExample is Example {
    function changeNumbers() public  {
        publicNumber = 1;  // OK
        internalNumber = 1;  // OK
        // privateNumber = 1;  // 失敗: プライベート関数を子クラスから呼び出せないため。
    }
}
