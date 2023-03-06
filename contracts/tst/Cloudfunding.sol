//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StoreCloudfunding
 * @dev A contract for crowdfunding proposals.
 */
contract StoreCloudfunding is Ownable {
    /**
     * @dev Emitted when a new proposal is created.
     * @param proposalID ID of the newly created proposal.
     * @param name Name of the proposal.
     * @param projectCID IPFS Content Identifier of the proposal.
     * @param proposer Address of the proposer.
     * @param goalAmount Goal amount for the proposal.
     * @param daysUntilDeadline Deadline for the proposal.
     * @param raisedAmount Amount raised for the proposal.
     * @param votes Total votes for the proposal.
     * @param approved Whether the proposal is approved or not.
     * @param funded Whether the proposal is funded or not.
     */
    event ProposalCreated(
        uint256 proposalID,
        string name,
        string projectCID,
        address proposer,
        uint256 goalAmount,
        uint256 daysUntilDeadline,
        uint256 raisedAmount,
        uint256 votes,
        bool approved,
        bool funded
    );
    event ProposalVoted(uint256 proposalID, uint256 votes);
    event ProposalApproved(uint256 proposalID, bool approved);
    event ProposalFunded(uint256 proposalID, bool funded);
    event ProposalWithdrawn(uint256 proposalID, uint256 raisedAmount);
    event ProposalRefunded(uint256 proposalID, uint256 raisedAmount);
    event ProposalExpired(uint256 proposalID);
    event LogFallback(address sender, uint value);

    address admin;

    address[] public voters;

    mapping(address => bool) public isVoter;
    uint private requiredVotes;
    uint private requiredVotesPercentage;
    uint private totalVoters;

    uint[] public proposalIDs;

    struct fundProposal {
        string name;
        string description;
        string projectCID;
        address payable proposer;
        uint256 goalAmount;
        uint256 daysUntilDeadline;
        uint256 raisedAmount;
        uint256 votes;
        bool approved;
        bool funded;
        uint createdAt;
        bool paidOut;
        // mapping(address => bool) voted;
    }

    struct proposalFunders {
        address funder;
        uint256 amount;
    }

    mapping(uint => mapping(address => bool)) public hasVoted;

    mapping(uint256 => uint256) public fundersCount;
    mapping(uint256 => mapping(uint256 => proposalFunders)) public fundersList;
    // uint256 public proposalCount;

    fundProposal[] public proposalsArray;
    mapping(uint256 => fundProposal) public allProposalsMap;
    mapping(uint256 => fundProposal) public proposals;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }

    modifier onlyVoter() {
        require(isVoter[msg.sender], "Only voters can call this function");
        _;
    }

    modifier onlyProposer(uint256 _proposalID) {
        require(
            proposals[_proposalID].proposer == msg.sender,
            "Only proposer can call this function"
        );
        _;
    }

    modifier notApproved(uint256 _proposalID) {
        require(
            proposals[_proposalID].approved == false,
            "Proposal has already been approved"
        );
        _;
    }

    modifier approved(uint256 _proposalID) {
        require(
            proposals[_proposalID].approved == true,
            "Proposal has not been approved"
        );
        _;
    }

    modifier notVoted(uint256 _proposalID) {
        require(
            hasVoted[_proposalID][msg.sender] == false,
            "You have already voted"
        );
        _;
    }

    modifier notFunded(uint256 _proposalID) {
        require(
            proposals[_proposalID].funded == false,
            "Proposal has already been funded"
        );
        _;
    }

    modifier funded(uint256 _proposalID) {
        require(
            proposals[_proposalID].funded == true,
            "Proposal has not been funded"
        );
        _;
    }

    modifier notExpired(uint256 _proposalID) {
        require(
            block.timestamp <=
                (proposals[_proposalID].createdAt +
                    (proposals[_proposalID].daysUntilDeadline * 1 days)), //@
            "Proposal has expired"
        );
        _;
    }

    modifier expired(uint256 _proposalID) {
        require(
            block.timestamp >
                (proposals[_proposalID].createdAt +
                    (proposals[_proposalID].daysUntilDeadline * 1 days)),
            "Proposal has not expired"
        );
        _;
    }

    modifier notPaidOut(uint256 _proposalID) {
        require(
            proposals[_proposalID].paidOut == false,
            "Proposal has already been paid out"
        );
        _;
    }

    constructor(address _voter, uint _requiredVotesPercentage) {
        admin = msg.sender;

        requiredVotesPercentage = _requiredVotesPercentage;
        addVoter(msg.sender);
        addVoter(_voter);
        isVoter[msg.sender] = true;
        isVoter[_voter] = true;
    }

    function totalVotes() public returns (uint) {
        totalVoters = voters.length * 10;
        return totalVoters;
    }

    /**
     * @dev Creates a new proposal.todo: goal amount should be in wei
     * @param _name Name of the proposal.
     * @param _description Description of the proposal.
     * @param _projectCID CID of the project.
     * @param _goalAmount The goal amount of the proposal.
     * @param _daysUntilDeadline The daysUntilDeadline for the proposal.
     * @return uint256 The ID of the new proposal.
     */
    function createProposal(
        string memory _name,
        string memory _description,
        string memory _projectCID,
        uint256 _goalAmount,
        uint256 _daysUntilDeadline
    ) public returns (uint256) {
        uint max = 1000000000; // 10^10
        uint min = 100000000; // 10^9
        require(_goalAmount > 0, "Goal amount cannot be 0");
        require(_daysUntilDeadline > 0, "daysUntilDeadline cannot be 0");
        require(
            _daysUntilDeadline <= 100,
            "daysUntilDeadline cannot be more than 365 days"
        );
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(bytes(_projectCID).length > 0, "Project CID cannot be empty");

        uint256 proposalID = (uint256(
            keccak256(abi.encodePacked(block.timestamp, msg.sender))
        ) % (max - min)) + min; // @audit - check
        require(
            proposals[proposalID].proposer == address(0),
            "Proposal ID already exists"
        );
        fundProposal storage proposal = proposals[proposalID];
        proposal.name = _name;
        proposal.description = _description;
        proposal.projectCID = _projectCID;
        proposal.proposer = payable(msg.sender);
        proposal.goalAmount = _goalAmount;
        proposal.daysUntilDeadline = _daysUntilDeadline;
        proposal.raisedAmount = 0;
        proposal.votes = 0;
        proposal.approved = false;
        proposal.funded = false;
        proposal.createdAt = block.timestamp;
        proposal.paidOut = false;

        proposalsArray.push(
            fundProposal(
                _name,
                _description,
                _projectCID,
                payable(msg.sender),
                _goalAmount,
                _daysUntilDeadline,
                0,
                0,
                false,
                false,
                block.timestamp,
                false
            )
        );
        proposalIDs.push(proposalID);
        uint totalProposals = proposalIDs.length - 1;
        allProposalsMap[totalProposals] = fundProposal(
            _name,
            _description,
            _projectCID,
            payable(msg.sender),
            _goalAmount,
            _daysUntilDeadline,
            0,
            0,
            false,
            false,
            block.timestamp,
            false
        );

        emit ProposalCreated(
            proposalID,
            _name,
            _projectCID,
            msg.sender,
            _goalAmount,
            _daysUntilDeadline,
            0,
            0,
            false,
            false
        );
        return proposalID;
    }

    /**
     * @dev Returns the proposal at the given index in the `allProposalsMap` mapping.
     * @param _index The index of the proposal in the `allProposalsMap` mapping.
     * @return The proposal at the given index.
     */
    function getAllProposalMap(
        uint256 _index
    ) public view returns (fundProposal memory) {
        return allProposalsMap[_index];
    }

    /**
     * @dev Allows a voter to vote on a proposal.
     * @param _proposalID The ID of the proposal to vote on.
     * @return The number of votes the proposal has received.
     */
    function vote(
        uint256 _proposalID
    )
        public
        onlyVoter
        notVoted(_proposalID)
        notApproved(_proposalID)
        returns (uint)
    {
        fundProposal storage proposal = proposals[_proposalID];
        require(
            block.timestamp < proposal.createdAt + 3 days, // @todo - Specification review　：5 minutes
            "You can only vote on a proposal for 5 after it is created"
        );
        require(
            proposal.proposer != msg.sender,
            "You cannot vote on your own proposal"
        );

        hasVoted[_proposalID][msg.sender] = true;

        proposal.votes += 1;

        approveProposal(_proposalID);

        emit ProposalVoted(_proposalID, proposal.votes);
        return proposal.votes;
    }

    /**
     * @dev Checks if the proposal has received enough votes to be approved.
     * If it has, sets the proposal's `approved` field to true.
     * @param _proposalID The ID of the proposal to check for approval.
     */
    function approveProposal(uint256 _proposalID) internal {
        fundProposal storage proposal = proposals[_proposalID];

        if ((proposal.votes * 10) >= requiredVotes) {
            proposal.approved = true;
            emit ProposalApproved(_proposalID, proposal.approved);
        }
    }

    /**
     * @dev Allows a user to fund a proposal.
     * @param _proposalID The ID of the proposal to fund.
     * @return true if the proposal is funded successfully, false otherwise.
     */
    function fundProposals(
        uint256 _proposalID
    )
        public
        payable
        notFunded(_proposalID)
        approved(_proposalID)
        notExpired(_proposalID)
        returns (bool)
    {
        fundProposal storage proposal = proposals[_proposalID];

        require(
            proposal.raisedAmount < proposal.goalAmount,
            "Proposal has already reached its goal"
        );
        require(msg.value > 0, "You cannot fund a proposal with 0 ETH");

        fundersList[_proposalID][fundersCount[_proposalID]] = proposalFunders(
            msg.sender,
            msg.value
        );
        fundersCount[_proposalID] += 1;
        proposal.raisedAmount += msg.value;

        fullyFunded(_proposalID);

        emit ProposalFunded(_proposalID, proposal.funded);

        return true;
    }

    /**
     * @dev Checks if a proposal has received enough funding to be fully funded.
     * If it has, sets the proposal's `funded` field to true.
     * @param _proposalID The ID of the proposal to check if fully funded.
     */
    function fullyFunded(uint256 _proposalID) internal {
        fundProposal storage proposal = proposals[_proposalID];

        if (proposal.raisedAmount >= proposal.goalAmount) {
            proposal.funded = true;
            // proposal.proposer.transfer(proposal.raisedAmount);
            // proposal.paidOut = true;
        }
    }

    /**
     * @dev Gets the details of a proposal.
     * @param _proposalID The ID of the proposal to get.
     * @return name The name of the proposal.
     * @return description The description of the proposal.
     * @return projectCID The IPFS CID of the proposal's project.
     * @return proposer The address of the proposer of the proposal.
     * @return goalAmount The amount of wei the proposal is trying to raise.
     * @return daysUntilDeadline The daysUntilDeadline for the proposal, in days. // @todo - Specification review
     * @return raisedAmount The amount of wei raised for the proposal so far.
     * @return votes The number of votes the proposal has received.
     * @return approved Whether or not the proposal has been approved.
     * @return funded Whether or not the proposal has been fully funded.
     */
    function getProposal(
        uint256 _proposalID
    )
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            address,
            uint256,
            uint256,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        fundProposal storage proposal = proposals[_proposalID];
        return (
            proposal.name,
            proposal.description,
            proposal.projectCID,
            proposal.proposer,
            proposal.goalAmount,
            proposal.daysUntilDeadline,
            proposal.raisedAmount,
            proposal.votes,
            proposal.approved,
            proposal.funded
        );
    }

    /**
     * @dev Gets the number of votes a proposal has received.
     * @param _proposalID The ID of the proposal.
     * @return The number of votes the proposal has received.
     */
    function getProposalVotes(
        uint256 _proposalID
    ) public view returns (uint256) {
        fundProposal storage proposal = proposals[_proposalID];
        return proposal.votes;
    }

    /**
     * @dev Withdraws funds for a proposal if it has been fully funded and not already paid out.
     * @param _proposalID The ID of the proposal to withdraw funds from.
     */
    function withdrawFunds(
        uint256 _proposalID
    ) public funded(_proposalID) notPaidOut(_proposalID) {
        fundProposal storage proposal = proposals[_proposalID];
        proposal.paidOut = true;
        proposal.proposer.transfer(proposal.raisedAmount);
        emit ProposalWithdrawn(_proposalID, proposal.raisedAmount);
    }

    /**
     * @dev Refunds all funders of a proposal if it has not been fully funded and has expired.
     * @param _proposalID The ID of the proposal to refund funders for.
     */
    function refundFunders(
        uint256 _proposalID
    )
        public
        onlyAdmin
        approved(_proposalID)
        expired(_proposalID)
        notPaidOut(_proposalID)
    {
        fundProposal storage proposal = proposals[_proposalID];

        for (uint256 i = 0; i < fundersCount[_proposalID]; i++) {
            proposalFunders storage funders = fundersList[_proposalID][i];
            payable(funders.funder).transfer(funders.amount);
        }

        emit ProposalRefunded(_proposalID, proposal.raisedAmount);
    }

    /**
     * @dev Returns the list of funders and their corresponding contribution amounts for a given proposal.
     * @param _proposalID The ID of the proposal.
     * @return Two arrays: an array of funders' addresses and an array of their contribution amounts, both of which have the same length.
     */
    function getFunders(
        uint256 _proposalID
    ) public view returns (address[] memory, uint256[] memory) {
        address[] memory funders = new address[](fundersCount[_proposalID]);
        uint256[] memory amounts = new uint256[](fundersCount[_proposalID]);

        for (uint256 i = 0; i < fundersCount[_proposalID]; i++) {
            funders[i] = fundersList[_proposalID][i].funder;
            amounts[i] = fundersList[_proposalID][i].amount;
        }

        return (funders, amounts);
    }

    /**
     * @dev Returns an array of all proposal IDs.
     * @return An array of all proposal IDs.
     */
    function getProposalIDs() public view returns (uint256[] memory) {
        return proposalIDs;
    }

    /**
     * @dev Returns an array of all proposals.
     * @return An array of all proposals.
     */
    function getProposalsArray() public view returns (fundProposal[] memory) {
        return proposalsArray;
    }

    /**
     * @dev Returns the list of all voters.
     * @return An array of all voters' addresses.
     */
    function getVoters() public view returns (address[] memory) {
        return voters;
    }

    /**
     * @dev Returns the required number of votes for a proposal to be approved.
     * @return The required number of votes for a proposal to be approved.
     */
    function getRequiredVotes() public view returns (uint256) {
        return requiredVotes;
    }

    /**
     * @dev Returns the required percentage of voters for a proposal to be approved.
     * @return The required percentage of voters for a proposal to be approved.
     */
    function getRequiredVotesPercentage() public view returns (uint256) {
        return requiredVotesPercentage;
    }

    /**
     * @dev Returns the total number of registered voters.
     * @return The total number of registered voters.
     */
    function getTotalVoters() public view returns (uint256) {
        return totalVoters;
    }

    /**
     * @dev Returns the total number of proposals.
     * @return The total number of proposals.
     */
    function getProposalCount() public view returns (uint256) {
        return proposalIDs.length;
    }

    /**
     * @dev Returns the number of funders for a given proposal.
     * @param _proposalID The ID of the proposal.
     * @return The number of funders for the proposal.
     */

    function getFundersCount(
        uint256 _proposalID
    ) public view returns (uint256) {
        return fundersCount[_proposalID];
    }

    /**
     * @dev Removes a voter from the list of registered voters.
     * @param _voter The address of the voter to remove.
     */
    function removeVoter(address _voter) public onlyAdmin {
        for (uint256 i = 0; i < voters.length; i++) {
            if (voters[i] == _voter) {
                voters[i] = voters[voters.length - 1];
                voters.pop();
                totalVotes();
                requiredVotes = (totalVoters * requiredVotesPercentage) / 100;
            }
        }
        isVoter[_voter] = false;
    }

    /**
     * @notice Sets the required votes percentage for proposals to pass
     * @param _requiredVotesPercentage The new required votes percentage
     */
    function setRequiredVotesPercentage(
        uint256 _requiredVotesPercentage
    ) public onlyAdmin {
        require(
            _requiredVotesPercentage > 0,
            "Required votes percentage cannot be 0"
        );
        requiredVotesPercentage = _requiredVotesPercentage;
        requiredVotes = (totalVoters * requiredVotesPercentage) / 100;
    }

    /**
     * @notice Adds a voter to the list of eligible voters
     * @param _voter The address of the voter to add
     */
    function addVoter(address _voter) public onlyAdmin {
        isVoter[_voter] = true;
        voters.push(_voter);
        totalVotes();
        requiredVotes = (totalVoters * requiredVotesPercentage) / 100;
    }

    /**
     * @notice Returns an array of proposals submitted by a given user
     * @param _user The address of the user whose proposals to return
     * @return An array of proposals submitted by the given user
     */
    function getMyProposal(
        address _user
    ) public view returns (fundProposal[] memory) {
        fundProposal[] memory myProposals = new fundProposal[](
            proposalIDs.length
        );

        uint256 counter = 0;
        for (uint256 i = 0; i < proposalIDs.length; i++) {
            if (proposals[proposalIDs[i]].proposer == _user) {
                myProposals[counter] = proposals[proposalIDs[i]];
                counter++;
            }
        }

        assembly {
            mstore(myProposals, counter)
        }

        return myProposals;
    }

    // fallback() external payable {
    //     emit LogFallback(msg.sender, msg.value);
    // }
}
