// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {IStakedBRR} from "src/interfaces/IStakedBRR.sol";

contract BRRMigrator {
    using SafeTransferLib for address;

    address private constant _BURN_ADDRESS = address(0xdead);

    // Old BRR tokens which can be converted 1:1 into the new BRR token.
    address private constant _OLD_TOKEN =
        0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    address private constant _OLD_STAKED_TOKEN =
        0x9A2a2E71071Caff506050bE6747B4E1369964933;

    /// @notice The new and final BRR token.
    address public immutable newToken;

    constructor(address _newToken) {
        newToken = _newToken;
    }

    /**
     * @notice Migrate the old BRR token to the new BRR token.
     * @param  amount  uint256  Token amount.
     */
    function migrate(uint256 amount) external {
        if (amount == 0) return;

        // Burn the old token, and transfer the new token to `msg.sender`.
        _OLD_TOKEN.safeTransferFrom(msg.sender, _BURN_ADDRESS, amount);

        newToken.safeTransfer(msg.sender, amount);
    }

    /**
     * @notice Migrate the old staked BRR token to the new BRR token.
     * @param  amount  uint256  Token amount.
     */
    function migrateStaked(uint256 amount) external {
        if (amount == 0) return;

        // Take custody of the old staked BRR token and unstake to the burn address.
        _OLD_STAKED_TOKEN.safeTransferFrom(msg.sender, address(this), amount);
        IStakedBRR(_OLD_STAKED_TOKEN).unstake(_BURN_ADDRESS, amount);

        newToken.safeTransfer(msg.sender, amount);
    }
}
