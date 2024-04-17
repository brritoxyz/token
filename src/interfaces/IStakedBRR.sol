// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IStakedBRR {
    function stake(address to, uint256 amount) external;

    function unstake(address to, uint256 amount) external;
}
