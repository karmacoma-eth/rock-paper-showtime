// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IPlayer, Throw} from "src/interfaces/IPlayer.sol";
import {Judge} from "src/Judge.sol";

// TODO: PseudoRandomPlayer

contract Mirror is IPlayer {
    function firstThrow(string calldata)
        external
        pure
        override
        returns (Throw)
    {
        return Throw.Paper;
    }

    function nextThrow(Throw prevOpponentThrow)
        external
        pure
        override
        returns (Throw)
    {
        return prevOpponentThrow;
    }
}

contract Cheater is IPlayer {
    Judge judge;
    IPlayer opponent;
    Throw myPrevMove;

    constructor(address _judge) {
        judge = Judge(_judge);
    }

    function firstThrow(string calldata opponentName)
        external
        override
        returns (Throw)
    {
        // judge = Judge(msg.sender);
        opponent = IPlayer(judge.players(opponentName));
        Throw opponentThrow = opponent.firstThrow("Cheater");
        myPrevMove = winningAgainst(opponentThrow);
        return myPrevMove;
    }

    function nextThrow(Throw) external override returns (Throw) {
        Throw opponentThrow = opponent.nextThrow(myPrevMove);
        myPrevMove = winningAgainst(opponentThrow);
        return myPrevMove;
    }

    function winningAgainst(Throw t) internal pure returns (Throw) {
        if (t == Throw.Rock) {
            return Throw.Paper;
        } else if (t == Throw.Paper) {
            return Throw.Scissors;
        } else {
            return Throw.Rock;
        }
    }
}
