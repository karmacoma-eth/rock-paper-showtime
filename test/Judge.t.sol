// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Judge} from "src/Judge.sol";

import {Avalanche, Bureaucrat, Crescendo, PaperDolls, Denouement} from "test/Gambits.sol";
import {GasGuzzler, Reverty} from "test/BadPlayers.sol";
import {Mirror, Cheater} from "test/MiscPlayers.sol";

contract JudgeTest is Test {
    event PlayerAdded(string name, address code);
    event GameStart(string player1, string player2);
    event Round(uint256 number, string player1Throw, string player2Throw);
    event Winner(string name);
    event Draw();

    Judge public judge;

    function setUp() public {
        judge = new Judge();

        judge.register("Bureaucrat", address(new Bureaucrat()));
        judge.register("Avalanche", address(new Avalanche()));
        judge.register("Crescendo", address(new Crescendo()));
        judge.register("Denouement", address(new Denouement()));
        judge.register("PaperDolls", address(new PaperDolls()));
        judge.register("Reverty", address(new Reverty()));
        judge.register("GasGuzzler", address(new GasGuzzler()));
        judge.register("Mirror", address(new Mirror()));
        judge.register("Cheater", address(new Cheater(address(judge))));
    }

    function testDraw() public {
        vm.expectEmit(true, true, true, true);
        emit Draw();
        string memory winner = judge.play("Bureaucrat", "Bureaucrat");

        assertEq(winner, "");
    }

    function testWin() public {
        vm.expectEmit(true, true, true, true);
        emit Winner("Bureaucrat");
        string memory winner = judge.play("Bureaucrat", "Avalanche");

        assertEq(winner, "Bureaucrat");
    }

    function testWinnerDoesNotDependOnPlayerOrder() public {
        vm.expectEmit(true, true, true, true);
        emit Winner("Bureaucrat");
        string memory winner = judge.play("Avalanche", "Bureaucrat");

        assertEq(winner, "Bureaucrat");
    }

    function testStateful() public {
        vm.expectEmit(true, true, true, true);
        emit Winner("Crescendo");
        string memory winner = judge.play("Crescendo", "PaperDolls");

        assertEq(winner, "Crescendo");
    }

    function testBadPlayer() public {
        vm.expectRevert("I'm a bad player");
        judge.play("Bureaucrat", "Reverty");
    }

    function testGasGuzzler() public {
        vm.expectRevert();
        judge.play("Bureaucrat", "GasGuzzler");
    }

    function testCrescendoVsMirror() public {
        string memory winner = judge.play("Crescendo", "Mirror");
        // the previous play is weaker, so it loses against Crescendo
        assertEq(winner, "Crescendo");
    }

    function testDenouementVsMirror() public {
        string memory winner = judge.play("Denouement", "Mirror");
        // the previous play is stronger, so it wins against Denouement
        assertEq(winner, "Mirror");
    }

    function testCheater() public {
        // the cheater should be able to win against any static strategy
        assertEq(judge.play("Cheater", "Bureaucrat"), "Cheater");
        assertEq(judge.play("Cheater", "Avalanche"), "Cheater");
        assertEq(judge.play("Cheater", "Crescendo"), "Cheater");
        assertEq(judge.play("Cheater", "PaperDolls"), "Cheater");
        assertEq(judge.play("Cheater", "Mirror"), "Cheater");
    }
}
