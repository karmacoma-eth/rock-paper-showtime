// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/console2.sol";
import "forge-std/Script.sol";

import {Judge} from "src/Judge.sol";

contract DeployJudge is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
        Judge judge = new Judge();
        console2.log("Deployed to", address(judge));
    }
}
