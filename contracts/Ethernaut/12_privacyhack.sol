
pragma solidity ^0.8.10;

interface IPrivacy{
    function unlock(bytes16 ans) external;
}

contract PrivacyHack {
    IPrivacy public priv = IPrivacy(0xD7e40c3a4032E0e679744db21fcc1C5394Dc8E4E);
 
    function unlock (bytes32 i) public{
        priv.unlock(bytes16(i));
    }
}