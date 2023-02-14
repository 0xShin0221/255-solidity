// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "hardhat/console.sol";
// NOTE: Deploy this contract first
contract B {
    // NOTE: storage layout must be the same as contract A
    address public sender;
    string public desc;
    address[] public targets;
    uint256[] public values;
    bytes[] public calldatas;

    // uint public value;

    // function propose(address[] calldata _targets,uint256[]  calldata _values,string calldata _desc) public payable {
    function propose(address[] memory _targets,uint256[] memory _values,bytes[] memory _callDatas,string memory _desc) public payable  returns(string memory){
        desc = _desc;
        sender = msg.sender;
        calldatas = _callDatas;
        values = _values;
        targets = _targets;
        // value = msg.value;
        return "ok";
    }
}


interface IGov {
    function propose
        (address[] calldata _targets,
        uint256[] calldata values,
        bytes[] calldata _callDatas,
        string calldata _desc) external;
    
    function delegate(address _to) external;
}
contract AWithSelector {
    address public sender;
    string public desc;
    uint public value;

    bytes[] questDatas;

    function setProposal(address _contract, address[] memory _target,uint256[] memory _values,string memory _description) public  returns (bool){
        // A's storage is set, B is not modified.
        _getQuestProposalBytes();
        (bool success, bytes memory returnData) = _contract.call(
            abi.encodeWithSelector(IGov.propose.selector,_target ,_values,questDatas,_description)
        );
        if (returnData.length == 0) {
            revert("Create Proposal: call failed");
            assembly {
                let returnDataSize := mload(returnData)
                revert(add(32, returnData), returnDataSize)
            }
        }
        return success;
    }

    function delegateToContract(address _governorContract) public returns (bool){
        console.log(address(this),"address this");
        (bool success, bytes memory returnData) = _governorContract.delegatecall(
            abi.encodeWithSelector(IGov.delegate.selector, address(this))
        );
        if (!success) {
            revert("Delegate: call failed");
            assembly {
                let returnDataSize := mload(returnData)
                revert(add(32, returnData), returnDataSize)
            }
        }
        console.log("ss",success);
        return success;
    }

    function _getQuestProposalBytes() public {

        address rewardTokenAddress = 0xeF356Fec500CcE6a8a8458605A82e82a41bd29BC;
        uint256 endTime = 1612867200;
        uint256 startTime = 1612681600;
        uint256 totalParticipants = 10;
        uint256 rewardAmountOrTokenId = 3;
        string memory contractType = "erc20";
        string memory questId = "3";
        bytes memory proposalBytes1 = abi.encodePacked(rewardTokenAddress, endTime, startTime, totalParticipants, rewardAmountOrTokenId, contractType, questId);
        questDatas.push(proposalBytes1);

        address rewardTokenAddress2 = 0xeF356Fec500CcE6a8a8458605A82e82a41bd29BC;
        uint256 endTime2 = 1612867250;
        uint256 startTime2 = 1612681650;
        uint256 totalParticipants2 = 20;
        uint256 rewardAmountOrTokenId2 = 10;
        string memory contractType2 = "erc20";
        string memory questId2 = "4";

        bytes memory proposalBytes2 = abi.encodePacked(rewardTokenAddress2, endTime2, startTime2, totalParticipants2, rewardAmountOrTokenId2, contractType2, questId2);
        questDatas.push(proposalBytes2);
    }
}

