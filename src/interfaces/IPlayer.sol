// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

enum Throw {
    Rock,
    Paper,
    Scissors
}

interface IPlayer {
    function firstThrow(string calldata opponentName) external returns (Throw);

    function nextThrow(Throw prevOpponentThrow) external returns (Throw);
}
