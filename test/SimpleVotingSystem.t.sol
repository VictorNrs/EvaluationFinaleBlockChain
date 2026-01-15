// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {SimpleVotingSystem} from "../src/SimplevotingSystem.sol";

contract SimpleVotingSystemTest is Test {
	SimpleVotingSystem public votingSystem;
	address public admin;
	address public user1;
	address public user2;

	function setUp() public {
		admin = address(0xA11CE);
		user1 = address(0xB0B);
		user2 = address(0xC4C4);
		vm.startPrank(admin);
		votingSystem = new SimpleVotingSystem();
		vm.stopPrank();
	}

	function test_AdminCanAddCandidate() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		vm.stopPrank();
		assertEq(votingSystem.getCandidatesCount(), 1);
	}

	function test_NonAdminCannotAddCandidate() public {
		vm.startPrank(user1);
		vm.expectRevert();
		votingSystem.addCandidate("Bob");
		vm.stopPrank();
	}

	function test_GrantAndRevokeAdminRole() public {
		vm.startPrank(admin);
		votingSystem.grantRole(votingSystem.ADMIN_ROLE(), user1);
		vm.stopPrank();
		vm.startPrank(user1);
		votingSystem.addCandidate("Bob");
		vm.stopPrank();
		assertEq(votingSystem.getCandidatesCount(), 1);
		vm.startPrank(admin);
		votingSystem.revokeRole(votingSystem.ADMIN_ROLE(), user1);
		vm.stopPrank();
		vm.startPrank(user1);
		vm.expectRevert();
		votingSystem.addCandidate("Charlie");
		vm.stopPrank();
	}


	function test_VoteAndGetVotes() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		votingSystem.addCandidate("Bob");
		votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
		vm.stopPrank();
		vm.warp(block.timestamp + 1 hours);
		vm.startPrank(user1);
		votingSystem.vote(1);
		vm.stopPrank();
		vm.startPrank(user2);
		votingSystem.vote(2);
		vm.stopPrank();
		vm.startPrank(admin);
		votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.COMPLETED);
		vm.stopPrank();
		assertEq(votingSystem.getTotalVotes(1), 1);
		assertEq(votingSystem.getTotalVotes(2), 1);
	}

	function test_CannotVoteTwice() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
		vm.stopPrank();
		vm.warp(block.timestamp + 1 hours);
		vm.startPrank(user1);
		votingSystem.vote(1);
		vm.expectRevert("You already have a vote NFT");
		votingSystem.vote(1);
		vm.stopPrank();
	}
    function test_CannotAddCandidate_IfNotRegisterPhase() public {
        vm.startPrank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        vm.expectRevert("Function cannot be called at this time");
        votingSystem.addCandidate("Alice");
        vm.stopPrank();
    }

    function test_CannotVote_IfNotVotePhase() public {
        vm.startPrank(admin);
        votingSystem.addCandidate("Alice");
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.FOUND_CANDIDATES);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert("Function cannot be called at this time");
        votingSystem.vote(1);
        vm.stopPrank();
    }

    function test_CannotGetTotalVotes_IfNotCompletedPhase() public {
        vm.startPrank(admin);
        votingSystem.addCandidate("Alice");
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert("Function cannot be called at this time");
        votingSystem.getTotalVotes(1);
        vm.stopPrank();
    }

    function test_OnlyAdminCanChangeWorkflowStatus() public {
        vm.startPrank(user1);
        vm.expectRevert();
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        vm.stopPrank();
        vm.startPrank(admin);
        votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
        assertEq(uint(votingSystem.workflowStatus()), uint(SimpleVotingSystem.WorkflowStatus.VOTE));
        vm.stopPrank();
    }
    function test_FounderCanSendFundsToCandidate() public {
		address founder = address(0xF0F0);
		vm.deal(founder, 1 ether);
		vm.startPrank(admin);
		votingSystem.grantRole(votingSystem.FOUNDER_ROLE(), founder);
		votingSystem.addCandidate("Alice");
		vm.stopPrank();
		vm.startPrank(founder);
		votingSystem.sendFundsToCandidate{value: 0.1 ether}(1);
		vm.stopPrank();
	}

	function test_NonFounderCannotSendFunds() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		vm.stopPrank();
		vm.deal(user1, 1 ether);
		vm.startPrank(user1);
		vm.expectRevert();
		votingSystem.sendFundsToCandidate{value: 0.1 ether}(1);
		vm.stopPrank();
	}

	function test_SendFundsToInvalidCandidateFails() public {
		address founder = address(0xF0F0);
		vm.deal(founder, 1 ether);
		vm.startPrank(admin);
		votingSystem.grantRole(votingSystem.FOUNDER_ROLE(), founder);
		votingSystem.addCandidate("Alice");
		vm.stopPrank();
		vm.startPrank(founder);
		vm.expectRevert("Invalid candidate ID");
		votingSystem.sendFundsToCandidate{value: 0.1 ether}(2);
		vm.stopPrank();
	}

	function test_SendFundsWithZeroValueFails() public {
		address founder = address(0xF0F0);
		vm.deal(founder, 1 ether);
		vm.startPrank(admin);
		votingSystem.grantRole(votingSystem.FOUNDER_ROLE(), founder);
		votingSystem.addCandidate("Alice");
		vm.stopPrank();
		vm.startPrank(founder);
		vm.expectRevert("Amount must be greater than zero");
		votingSystem.sendFundsToCandidate{value: 0}(1);
		vm.stopPrank();
	}
    	function test_CannotVoteBeforeOneHourAfterVoteStatus() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
		vm.stopPrank();
		vm.startPrank(user1);
		vm.expectRevert("Voting not open yet");
		votingSystem.vote(1);
		vm.stopPrank();
	}

	function test_CanVoteAfterOneHour() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
		vm.stopPrank();
		// Avancer le temps d'une heure
		vm.warp(block.timestamp + 1 hours);
		vm.startPrank(user1);
		votingSystem.vote(1);
		vm.stopPrank();
		assertTrue(votingSystem.voters(user1));
	}
    	function test_NFTMintedAfterVote() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
		vm.stopPrank();
		vm.warp(block.timestamp + 1 hours);
		vm.startPrank(user1);
		votingSystem.vote(1);
		vm.stopPrank();
		// Vérifie que user1 possède bien le NFT
		assertTrue(votingSystem.voteNFT().hasNFT(user1));
	}

	function test_CannotVoteIfAlreadyHasNFT() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		votingSystem.setWorkflowStatus(SimpleVotingSystem.WorkflowStatus.VOTE);
		vm.stopPrank();
		vm.warp(block.timestamp + 1 hours);
		vm.startPrank(user1);
		votingSystem.vote(1);
		vm.expectRevert("You already have a vote NFT");
		votingSystem.vote(1);
		vm.stopPrank();
	}
}
