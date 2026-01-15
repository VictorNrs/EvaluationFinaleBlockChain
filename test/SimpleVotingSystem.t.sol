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
		// Grant ADMIN_ROLE to user1
		vm.startPrank(admin);
		votingSystem.grantRole(votingSystem.ADMIN_ROLE(), user1);
		vm.stopPrank();
		// user1 can now add a candidate
		vm.startPrank(user1);
		votingSystem.addCandidate("Bob");
		vm.stopPrank();
		assertEq(votingSystem.getCandidatesCount(), 1);
		// Revoke ADMIN_ROLE from user1
		vm.startPrank(admin);
		votingSystem.revokeRole(votingSystem.ADMIN_ROLE(), user1);
		vm.stopPrank();
		// user1 cannot add a candidate anymore
		vm.startPrank(user1);
		vm.expectRevert();
		votingSystem.addCandidate("Charlie");
		vm.stopPrank();
	}

	function test_VoteAndGetVotes() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		votingSystem.addCandidate("Bob");
		vm.stopPrank();
		vm.startPrank(user1);
		votingSystem.vote(1);
		vm.stopPrank();
		vm.startPrank(user2);
		votingSystem.vote(2);
		vm.stopPrank();
		assertEq(votingSystem.getTotalVotes(1), 1);
		assertEq(votingSystem.getTotalVotes(2), 1);
	}

	function test_CannotVoteTwice() public {
		vm.startPrank(admin);
		votingSystem.addCandidate("Alice");
		vm.stopPrank();
		vm.startPrank(user1);
		votingSystem.vote(1);
		vm.expectRevert("You have already voted");
		votingSystem.vote(1);
		vm.stopPrank();
	}
}
