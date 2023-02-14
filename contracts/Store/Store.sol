// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;
import "openzeppelin-solidity/contracts/access/Ownable.sol";

contract Store is Ownable {
    struct StoreOnSquare{
        string storeName;  // storeName - Square: Location.name
        string addressLine1; // addressLine1 - Square: Address.address_line_1
        string country; // country - Square: Address.country
        string postalCode; // postalCode - Square: Address.postal_code
    }
    
    struct Square {
        StoreOnSquare squareId;
    }
    mapping(uint =>Square) squareStores;

    function registSquare(uint squareId, StoreOnSquare memory _store) public onlyOwner returns(bool success){
        squareStores[squareId].squareId.storeName = _store.storeName;
        squareStores[squareId].squareId.addressLine1 = _store.addressLine1;
        squareStores[squareId].squareId.country = _store.country;
        squareStores[squareId].squareId.postalCode = _store.postalCode;
        return true;
    }

    function getStore(uint squareId) public view returns(Square memory _stores){
        return squareStores[squareId];
    }

    function getStores() public pure returns(StoreOnSquare[] memory _stores){
        return _stores;
    }
}