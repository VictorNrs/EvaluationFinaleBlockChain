// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import {SimpleVotingSystem} from "../src/SimplevotingSystem.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        new SimpleVotingSystem();
        vm.stopBroadcast();
    }
}
