// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "solady/auth/Ownable.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

contract BRR is Ownable, ERC20 {
    uint256 public maxSupply = 1e9;

    event SetMaxSupply(uint256 newMaxSupply);

    error CannotIncreaseMaxSupply();
    error MaxSupplyTooLow();

    constructor(address initialOwner) {
        _initializeOwner(initialOwner);
    }

    function name() public pure override returns (string memory) {
        return "BRR (Brrito.xyz)";
    }

    function symbol() public pure override returns (string memory) {
        return "BRR";
    }

    function setMaxSupply(uint256 newMaxSupply) external onlyOwner {
        // We are only allowing the max supply to be set to a lower value as a
        // commitment to the community that we won't mint more tokens than needed.
        if (newMaxSupply > maxSupply) revert CannotIncreaseMaxSupply();

        if (newMaxSupply < totalSupply()) revert MaxSupplyTooLow();

        maxSupply = newMaxSupply;

        emit SetMaxSupply(newMaxSupply);
    }
}
