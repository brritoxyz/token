// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {ERC20} from "solady/tokens/ERC20.sol";

contract BRR is ERC20 {
    function name() public pure override returns (string memory) {
        return "BRR (Brrito.xyz)";
    }

    function symbol() public pure override returns (string memory) {
        return "BRR";
    }
}
