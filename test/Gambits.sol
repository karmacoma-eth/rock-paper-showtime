// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IPlayer, Throw} from "src/interfaces/IPlayer.sol";

contract Bureaucrat is IPlayer {
    function firstThrow(string calldata)
        external
        pure
        override
        returns (Throw)
    {
        return Throw.Paper;
    }

    function nextThrow(Throw) external pure override returns (Throw) {
        return Throw.Paper;
    }
}

contract Avalanche is IPlayer {
    function firstThrow(string calldata)
        external
        pure
        override
        returns (Throw)
    {
        return Throw.Rock;
    }

    function nextThrow(Throw) external pure override returns (Throw) {
        return Throw.Rock;
    }
}

contract PaperDolls is IPlayer {
    function firstThrow(string calldata)
        external
        pure
        override
        returns (Throw)
    {
        return Throw.Paper;
    }

    function nextThrow(Throw) external pure override returns (Throw) {
        return Throw.Scissors;
    }
}

// stateful!
contract Crescendo is IPlayer {
    uint256 round = 1;

    function firstThrow(string calldata) external override returns (Throw) {
        round = 1;
        return Throw.Paper;
    }

    function nextThrow(Throw) external override returns (Throw) {
        if (round == 1) {
            round = 2;
            return Throw.Scissors;
        }

        return Throw.Rock;
    }
}
