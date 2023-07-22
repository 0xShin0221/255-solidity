// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../ERC1155Vote.sol";

contract Voting is ERC1155Vote {
    string public name;
    string public symbol;
    uint256 private _currentTokenId = 0;
    address public owner;
    uint256 public multiplier = 1;
    ProductCandidate[] public productCandidates;

    struct ProductCandidate {
        address owner;
        uint256 cost;
        uint256 sellPrice;
        string imageUrl;
        uint256 votedPoints;
    }

    struct Proposal {
        uint256[] candidateIds;
        uint256 endTime;
    }

    Proposal[] public proposals;
    mapping(uint256 => mapping(address => bool)) public votes;

    event ProposalCreated(uint256 proposalId);
    event CandidateAdded(uint256 proposalId, uint256 candidateId);
    event Voted(uint256 proposalId, uint256 candidateId, address voter);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, _currentTokenId, amount, "");
        _currentTokenId++;
    }

    function burn(
        address owner,
        uint256 tokenId,
        uint256 amount
    ) public onlyOwner {
        _burn(owner, tokenId, amount);
    }

    function delegateVoteTo(uint256 fromTokenId, uint256 toTokenId) public {
        delegateVote(fromTokenId, toTokenId);
    }

    function retrieveVote(uint256 tokenId) public {
        recoverVote(tokenId);
    }

    function createProposal() public onlyOwner {
        uint256[] memory candidateIds; // Define an empty array of type uint256
        uint256 endTime = getNextMonday(block.timestamp); // Define the endTime to be 7 days from now

        // Define the proposal
        Proposal memory newProposal;
        newProposal.candidateIds = candidateIds;
        newProposal.endTime = endTime;

        // Add the new proposal to the array of proposals
        proposals.push(newProposal);

        // Emit the ProposalCreated event with the id of the new proposal
        emit ProposalCreated(proposals.length - 1);
    }

    function getProposal(
        uint256 proposalId
    ) public view returns (uint256[] memory, uint256) {
        require(proposalId < proposals.length, "Invalid proposalId");
        Proposal memory proposal = proposals[proposalId];
        return (proposal.candidateIds, proposal.endTime);
    }

    function getNextMonday(uint timestamp) public pure returns (uint) {
        uint dayOfWeek = (timestamp / 1 days + 4) % 7;
        return timestamp + (8 - (dayOfWeek % 7)) * 1 days;
    }

    function addProductCandidate(
        uint256 proposalId,
        address _owner,
        uint256 _cost,
        uint256 _sellPrice,
        string memory _imageUrl
    ) public onlyOwner {
        require(proposalId < proposals.length, "Invalid proposalId");
        Proposal storage proposal = proposals[proposalId];
        uint256 candidateId = productCandidates.length;
        productCandidates.push(
            ProductCandidate({
                owner: _owner,
                cost: _cost,
                sellPrice: _sellPrice,
                imageUrl: _imageUrl,
                votedPoints: 0
            })
        );
        proposal.candidateIds.push(candidateId);

        emit CandidateAdded(proposalId, candidateId);
    }

    function vote(uint256 proposalId, uint256 candidateId) public {
        require(proposalId < proposals.length, "Invalid proposalId");
        ProductCandidate storage candidate = productCandidates[candidateId];
        Proposal storage proposal = proposals[proposalId];
        require(
            block.timestamp <= proposal.endTime,
            "The voting period for this proposal has ended"
        );
        require(candidateId < productCandidates.length, "Invalid candidateId");
        require(
            !votes[proposalId][msg.sender],
            "You already voted for this proposal"
        );

        candidate.votedPoints +=
            multiplier *
            balanceOf(msg.sender, _currentTokenId);

        votes[proposalId][msg.sender] = true;
        emit Voted(proposalId, candidateId, msg.sender);
    }

    function setMultiplier(uint256 _multiplier) public onlyOwner {
        multiplier = _multiplier;
    }

    function changeTokenId(uint256 tokenId) public onlyOwner {
        _currentTokenId = tokenId;
    }
}
