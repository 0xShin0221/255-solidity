// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.16;

import './SampleGovernor.sol';
// import './QuestFactory.sol';

interface IGov {
    function propose(
        address[] calldata _targets,
        uint256[] calldata values,
        bytes[] calldata _callDatas,
        string calldata _desc
    ) external;

    function delegate(address _to) external;
}

contract QuestBooster {
    address governer;

    bytes[] questDatas;

    constructor(IGovernor _governer) {
        _initGoverner(_governer);
    }

    struct QuestProposal {
        address rewardTokenAddress;
        uint256 endTime;
        uint256 startTime;
        uint256 totalParticipants;
        uint256 rewardAmountOrTokenId;
        string contractType;
        string questId;
    }

    function createQustProposal(
        address[] memory _target,
        uint256[] memory _values,
        string memory _description
    ) public returns (bool) {
        // require(_hasVote(), 'You have not delegated yet');
        QuestProposal memory _questProposal;
        _tmpGetQuestProposalBytes();
        (bool success, bytes memory result) = governer.call(
            abi.encodeWithSelector(IGov.propose.selector, _target, _values, questDatas, _description)
        );
        if (result.length == 0) {
            revert('Create Proposal: call failed');
            assembly {
                let returnDataSize := mload(result)
                revert(add(32, result), returnDataSize)
            }
        }
        return success;
    }

    function _tmpGetQuestProposalBytes() internal {
        address rewardTokenAddress = 0xeF356Fec500CcE6a8a8458605A82e82a41bd29BC;
        uint256 endTime = 1612867200;
        uint256 startTime = 1612681600;
        uint256 totalParticipants = 10;
        uint256 rewardAmountOrTokenId = 3;
        string memory contractType = 'erc20';
        string memory questId = '3';
        bytes memory proposalBytes1 = abi.encodePacked(
            rewardTokenAddress,
            endTime,
            startTime,
            totalParticipants,
            rewardAmountOrTokenId,
            contractType,
            questId
        );
        questDatas.push(proposalBytes1);
    }

    function _initGoverner(IGovernor _governer) internal {
        governer = address(_governer);
    }

    function _encodeSampleCalldata(
        address rewardTokenAddress_,
        uint256 endTime_,
        uint256 startTime_,
        uint256 totalParticipants_,
        uint256 rewardAmountOrTokenId_,
        string memory contractType_,
        string memory questId_
    ) public returns (bytes memory) {
        return
            abi.encodePacked(
                rewardTokenAddress_,
                endTime_,
                startTime_,
                totalParticipants_,
                rewardAmountOrTokenId_,
                contractType_,
                questId_
            );
    }

    // function _hasVoteByDelegate() public {}

    // function _hasVote(uint256 _proposalId, address _account) internal view returns (bool) {
    //     (bool success, bytes memory result) = governer.call(
    //         abi.encodeWithSelector(IGov.hasVited.selector, _proposalId, _account)
    //     );
    //     require(!success, 'Create Proposal: call failed');
    //     return success;
    // }
}
