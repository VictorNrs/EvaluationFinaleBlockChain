    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.26;

    import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
    import {AccessControl} from "openzeppelin-contracts/contracts/access/AccessControl.sol";
    import {ERC721} from "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

    contract VoteNFT is ERC721 {
        uint256 public nextTokenId;
        constructor() ERC721("VoteNFT", "VOTE") {}
        function mint(address to) external {
            _mint(to, nextTokenId);
            nextTokenId++;
        }
        function hasNFT(address owner) external view returns (bool) {
            return balanceOf(owner) > 0;
        }
    }

    contract SimpleVotingSystem is Ownable, AccessControl {
            VoteNFT public voteNFT;
        enum WorkflowStatus { REGISTER_CANDIDATES, FOUND_CANDIDATES, VOTE, COMPLETED }
        WorkflowStatus public workflowStatus;

        modifier atStatus(WorkflowStatus _status) {
            require(workflowStatus == _status, "Function cannot be called at this time");
            _;
        }

        uint256 public voteStartTime;

        function setWorkflowStatus(WorkflowStatus _status) public onlyRole(ADMIN_ROLE) {
            workflowStatus = _status;
            if (_status == WorkflowStatus.VOTE) {
                voteStartTime = block.timestamp;
            }
        }

        bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
        bytes32 public constant FOUNDER_ROLE = keccak256("FOUNDER_ROLE");
        function sendFundsToCandidate(uint _candidateId) public payable onlyRole(FOUNDER_ROLE) {
            require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
            address payable recipient = payable(address(uint160(uint(keccak256(abi.encodePacked(_candidateId))))));
            require(msg.value > 0, "Amount must be greater than zero");
            (bool sent, ) = recipient.call{value: msg.value}("");
            require(sent, "Failed to send funds");
        }
    struct Candidate {
        uint id;
        string name;
        uint voteCount;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;
    uint[] private candidateIds;

    constructor() Ownable(msg.sender) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        workflowStatus = WorkflowStatus.REGISTER_CANDIDATES;
        voteNFT = new VoteNFT();
    }

    function addCandidate(string memory _name) public onlyRole(ADMIN_ROLE) atStatus(WorkflowStatus.REGISTER_CANDIDATES) {
        require(bytes(_name).length > 0, "Candidate name cannot be empty");
        uint candidateId = candidateIds.length + 1;
        candidates[candidateId] = Candidate(candidateId, _name, 0);
        candidateIds.push(candidateId);
    }

    function vote(uint _candidateId) public atStatus(WorkflowStatus.VOTE) {
        require(block.timestamp >= voteStartTime + 1 hours, "Voting not open yet");
        require(!voteNFT.hasNFT(msg.sender), "You already have a vote NFT");
        require(!voters[msg.sender], "You have already voted");
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");

        voters[msg.sender] = true;
        candidates[_candidateId].voteCount += 1;
        voteNFT.mint(msg.sender);
    }

    function getTotalVotes(uint _candidateId) public view atStatus(WorkflowStatus.COMPLETED) returns (uint) {
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        return candidates[_candidateId].voteCount;
    }

    function getCandidatesCount() public view returns (uint) {
        return candidateIds.length;
    }

    // Optional: Function to get candidate details by ID
    function getCandidate(uint _candidateId) public view returns (Candidate memory) {
        require(_candidateId > 0 && _candidateId <= candidateIds.length, "Invalid candidate ID");
        return candidates[_candidateId];
    }
}