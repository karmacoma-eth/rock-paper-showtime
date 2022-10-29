// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Throw, IPlayer} from "src/interfaces/IPlayer.sol";

contract Judge {
    event PlayerAdded(string name, address code);
    event GameStart(string player1, string player2);
    event Round(uint256 number, string player1Throw, string player2Throw);
    event Winner(string name);
    event Draw();

    uint256 constant GAS_STIPEND = 50000;

    mapping(string => address) public players;

    function register(string calldata _name, address _addr) external {
        require(bytes(_name).length > 0, "must provide a name");
        require(bytes(_name).length <= 20, "name too long");
        require(_addr.code.length > 0, "must be a contract");
        require(players[_name] == address(0), "name already taken");

        players[_name] = _addr;
    }

    /// Play a best of 3 rounds game
    /// The game stops with a draw if there is still no winner after 5 rounds
    function play(string calldata player1, string calldata player2)
        external
        returns (string memory winner)
    {
        IPlayer p1 = _fetchPlayer(player1);
        IPlayer p2 = _fetchPlayer(player2);

        emit GameStart(player1, player2);
        uint256 round = 1;

        Throw p1Throw = p1.firstThrow{gas: GAS_STIPEND}(player2);
        Throw p2Throw = p2.firstThrow{gas: GAS_STIPEND}(player1);
        emit Round(round, toString(p1Throw), toString(p2Throw));

        (uint256 p1Score, uint256 p2Score) = _gradeRound(p1Throw, p2Throw);

        while (round <= 5) {
            unchecked {
                round++;

                (p1Throw, p2Throw) = (
                    p1.nextThrow{gas: GAS_STIPEND}(p2Throw),
                    p2.nextThrow{gas: GAS_STIPEND}(p1Throw)
                );

                emit Round(round, toString(p1Throw), toString(p2Throw));

                (uint256 p1RoundScore, uint256 p2RoundScore) = _gradeRound(
                    p1Throw,
                    p2Throw
                );

                p1Score += p1RoundScore;
                if (p1Score >= 2) {
                    emit Winner(player1);
                    return player1;
                }

                p2Score += p2RoundScore;
                if (p2Score >= 2) {
                    emit Winner(player2);
                    return player2;
                }
            }
        }

        emit Draw();
        return "";
    }

    function _gradeRound(Throw p1Throw, Throw p2Throw)
        internal
        pure
        returns (uint256 p1Score, uint256 p2Score)
    {
        if (p1Throw == p2Throw) {
            return (0, 0);
        } else if (p1Throw == Throw.Rock && p2Throw == Throw.Scissors) {
            return (1, 0);
        } else if (p1Throw == Throw.Paper && p2Throw == Throw.Rock) {
            return (1, 0);
        } else if (p1Throw == Throw.Scissors && p2Throw == Throw.Paper) {
            return (1, 0);
        } else {
            return (0, 1);
        }
    }

    function _fetchPlayer(string calldata playerName)
        internal
        view
        returns (IPlayer player)
    {
        player = IPlayer(players[playerName]);
        require(address(player) != address(0), "unknown player");
    }
}

function toString(Throw t) pure returns (string memory) {
    if (t == Throw.Rock) {
        return "Rock";
    } else if (t == Throw.Paper) {
        return "Paper";
    } else if (t == Throw.Scissors) {
        return "Scissors";
    } else {
        revert("Invalid throw");
    }
}
