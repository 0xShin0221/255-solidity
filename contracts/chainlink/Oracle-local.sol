// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SampleOracle is ChainlinkClient, Ownable {
    using Chainlink for Chainlink.Request;

    struct GetTimeResponse {
        string now;
        int256 timestamp;
    }
    GetTimeResponse public getTimeResponse;

    uint256 private fee;    
    address private oracleAddress;
    bytes32 private getTimeJobId;

    /**
     * Network: Goerli
     *
     * Link Token: 0x326C977E6efc84E512bB9C30f76E30c160eD06FB
     * Oracle Address: 0x00
     * GetTime JobId: 
     */
    constructor() {
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);

        fee = 1 * 10**18;
        oracleAddress = 0xfA1F42f6f2F0cA4B6038BAC97857B60cB72B7555; 
        getTimeJobId = 0x3833386531353236613939613461663061343238663136613932636563333431; 
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function setGetTimeJobId(bytes32 id) public onlyOwner {
        getTimeJobId = id;
    }

    function createGetTimeRequestTo()
        public
        onlyOwner
        returns (bytes32 requestId)
    {
        Chainlink.Request memory req = buildChainlinkRequest(
            getTimeJobId,
            address(this),
            this.fulfillGetTimeRequest.selector
        );
        req.add("params", "sample time adapter");
        requestId = sendChainlinkRequestTo(oracleAddress, req, fee);
    }

    function fulfillGetTimeRequest(
        bytes32 requestId,
        string memory _now,
        int256 _timestamp
    ) public recordChainlinkFulfillment(requestId) {
        getTimeResponse = GetTimeResponse({now: _now, timestamp: _timestamp});
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