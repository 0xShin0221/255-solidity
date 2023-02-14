// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ShopifyProductOracle is ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;

    struct GetProductCreateResponse {
        string now;
        int256 timestamp;
        string productId;
    }
    GetProductCreateResponse public getProductCreateResponse;

    uint256 private fee;
    address private oracleAddress;
    bytes32 private createProductJobId;

    struct CreateProductRequest {
        string shopName;
        string title;
        string vendor;
        string productType;
        string tag;
        string bodyHtml; //Better to BYTES ALLAY, etc.
    }

    /**
     * Network: Goerli
     *
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle Address: 0x00
     * ProductJobId: 
     */
    constructor(address _oracleAddress,bytes32 _jobId) {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);

        fee = 1 * 10**18;
        oracleAddress = _oracleAddress; 
        createProductJobId = _jobId; 
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function setJobId(bytes32 id) public onlyOwner {
        createProductJobId = id;
    }
    
    function createProductRequest(CreateProductRequest calldata _product)
        public
        onlyOwner
        returns (bytes32 requestId)
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            createProductJobId,
            address(this),
            this.fulfillProductCreateRequest.selector
        );
        req.add("shop_name",_product.shopName);
        req.add("title", _product.title);
        req.add("body_html", _product.bodyHtml);
        req.add("vendor", _product.vendor);
        req.add("product_type", _product.productType);
        req.add("tag",_product.tag);
        requestId = sendChainlinkRequestTo(oracleAddress, req, fee);
    }

    function fulfillProductCreateRequest(
        bytes32 requestId,
        string memory _now,
        int256 _timestamp,
        string calldata _productId
    ) public recordChainlinkFulfillment(requestId) {
        getProductCreateResponse = GetProductCreateResponse({now: _now, timestamp: _timestamp, productId:_productId});
    }

    function cancelRequest(
        bytes32 requestId,
        bytes4 callbackFunctionId,
        uint256 expiration
    ) public onlyOwner {
        cancelChainlinkRequest(requestId, fee, callbackFunctionId, expiration);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer"
        );
    }
}