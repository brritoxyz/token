// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "solady/auth/Ownable.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

contract BRR is Ownable, ERC20 {
    string private constant _NAME = "Brrito";
    string private constant _SYMBOL = "BRR";

    /// @notice Maximum amount of tokens which can be minted.
    uint256 public maxSupply = 1_000_000_000e18;

    error MaxSupplyExceeded();

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert NewOwnerIsZeroAddress();

        _initializeOwner(initialOwner);
    }

    /// @notice Overridden to enforce 2-step ownership transfers.
    function transferOwnership(address) public payable override {
        revert Unauthorized();
    }

    /// @notice Overridden to enforce 2-step ownership transfers.
    function renounceOwnership() public payable override {
        revert Unauthorized();
    }

    /// @notice Token name.
    function name() public pure override returns (string memory) {
        return _NAME;
    }

    /// @notice Token symbol.
    function symbol() public pure override returns (string memory) {
        return _SYMBOL;
    }

    /**
     * @notice Mint BRR.
     * @param  to      address  Token recipient.
     * @param  amount  uint256  Token amount.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        if (totalSupply() + amount > maxSupply) revert MaxSupplyExceeded();

        _mint(to, amount);
    }
}
