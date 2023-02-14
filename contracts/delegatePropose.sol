// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// NOTE: Deploy this contract first
contract Gov {
    // NOTE: storage layout must be the same as contract A
    uint public num;
    address public sender;
    uint public value;
    string public desc;

    event CalledB(string);
    constructor ()payable {}

    function setVars(uint _num) public payable {
        num = _num;
        sender = msg.sender;
        value = msg.value;
    }
    // function propose(        
    //     address[] memory targets,
    //     uint256[] memory values,
    //     bytes[] memory calldatas,
    //     string memory description
    function propose(        
        // address[] memory targets,
        // uint256[] memory values,
        // bytes[] memory calldatas,
        string calldata _proposalDescription
    ) public  payable returns(string memory) {
       emit CalledB(_proposalDescription);
       desc = _proposalDescription;
       return "ok";
    }
}


interface IGov {
    function propose(
        // address[] memory targets,
        // uint256[] memory values,
        // bytes[] memory calldatas,
        string calldata _proposalDescription) external;

    struct QuestProposal {
        address rewardTokenAddress;
        uint256 endTime;
        uint256 startTime;
        uint256 totalParticipants;
        uint256 rewardAmountOrTokenId;
        string contractType;
        string questId;
    }
}
contract ProposeWithSelectorByDelegateCall {
    uint public num;
    address public sender;
    uint public value;
    string public desc;

    //@dev taget is governor
    //function setProposal(address _govContract, address _target,bytes memory _questData,string memory _proposalDescription) public  returns (bool){
   function setProposal(address _govContract, string memory _proposalDescription) public returns (bool){
        // A's storage is set, B is not modified.
        (bool success, bytes memory returnData) = _govContract.delegatecall(
            // abi.encodeWithSelector(IGov.propose.selector, [_target],[0],[_questData],_proposalDescription)
            abi.encodeWithSignature("propose(string)", _proposalDescription)
            //abi.encodeWithSelector(IGov.propose.selector,_proposalDescription)
        );
        if (returnData.length == 0) {
            revert("Create Proposal: delegate call failed");
        }
        assembly {
            let returnDataSize := mload(returnData)
            revert(add(32, returnData), returnDataSize)
        }
        return success;
    }
}

contract GetData {
    function getQuestProposalBytes() public pure returns (bytes memory) {
        address rewardTokenAddress = 0xeF356Fec500CcE6a8a8458605A82e82a41bd29BC;
        uint256 endTime = 1612867200;
        uint256 startTime = 1612681600;
        uint256 totalParticipants = 10;
        uint256 rewardAmountOrTokenId = 3;
        string memory contractType = "erc20";
        string memory questId = "3";

        bytes memory proposalBytes = abi.encodePacked(rewardTokenAddress, endTime, startTime, totalParticipants, rewardAmountOrTokenId, contractType, questId);
    return proposalBytes;
    }
}