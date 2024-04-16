// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Ownable} from "solady/auth/Ownable.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

contract BRR is Ownable, ERC20 {
    string private constant _NAME = "Brrito";
    string private constant _SYMBOL = "BRR";

    // 1 billion (18 decimals)
    uint256 public maxSupply = 1_000_000_000e18;

    event DecreaseMaxSupply(uint256 newMaxSupply);

    error CannotIncreaseMaxSupply();
    error MaxSupplyLessThanTotal();
    error MaxSupplyExceeded();

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert NewOwnerIsZeroAddress();

        _initializeOwner(initialOwner);
    }

    /**
     * @notice Overridden to enforce 2-step ownership transfers.
     */
    function transferOwnership(address) public payable override {
        revert Unauthorized();
    }

    /**
     * @notice Overridden to enforce 2-step ownership transfers.
     */
    function renounceOwnership() public payable override {
        revert Unauthorized();
    }

    /**
     * @notice Token name.
     */
    function name() public pure override returns (string memory) {
        return _NAME;
    }

    /**
     * @notice Token symbol.
     */
    function symbol() public pure override returns (string memory) {
        return _SYMBOL;
    }

    /**
     * @notice Decrease the BRR max supply.
     * @param  newMaxSupply  uint256  New max supply.
     */
    function decreaseMaxSupply(uint256 newMaxSupply) external onlyOwner {
        if (newMaxSupply > maxSupply) revert CannotIncreaseMaxSupply();
        if (newMaxSupply < totalSupply()) revert MaxSupplyLessThanTotal();

        maxSupply = newMaxSupply;

        emit DecreaseMaxSupply(newMaxSupply);
    }

    /**
     * @notice Mint BRR.
     * @param  to      address  Token recipient.
     * @param  amount  uint256  Token amount.
     */
    function mint(address to, uint256 amount) external onlyOwner {
        // Safe since `_mint` throws if `totalSupply` overflows.
        unchecked {
            if (totalSupply() + amount > maxSupply)
                revert MaxSupplyExceeded();
        }

        _mint(to, amount);
    }
}
