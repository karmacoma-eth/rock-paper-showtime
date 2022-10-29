// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IPlayer, Throw} from "src/interfaces/IPlayer.sol";

contract Reverty is IPlayer {
    function firstThrow(string calldata)
        external
        pure
        override
        returns (Throw)
    {
        revert("I'm a bad player");
    }

    function nextThrow(Throw) external pure override returns (Throw) {
        revert("I'm a bad player");
    }
}

contract GasGuzzler is IPlayer {
    function firstThrow(string calldata)
        external
        pure
        override
        returns (Throw)
    {
        assembly {
            mstore(not(0), 1)
        }
        return Throw.Paper;
    }

    function nextThrow(Throw) external pure override returns (Throw) {
        assembly {
            mstore(not(0), 1)
        }
        return Throw.Paper;
    }
}
