// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";

import {Judge} from "src/Judge.sol";

import {Avalanche, Bureaucrat, Crescendo, PaperDolls} from "test/Gambits.sol";
import {GasGuzzler, Reverty} from "test/BadPlayers.sol";

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
        judge.register("PaperDolls", address(new PaperDolls()));
        judge.register("Reverty", address(new Reverty()));
        judge.register("GasGuzzler", address(new GasGuzzler()));
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
}
