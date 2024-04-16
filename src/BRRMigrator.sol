// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";

contract BRRMigrator {
    using SafeTransferLib for address;

    // The old BRR token which can be converted 1:1 into the new BRR token.
    address private constant _OLD_TOKEN =
        0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;

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
        // Burn the old token, and transfer the new token to `msg.sender`.
        _OLD_TOKEN.safeTransferFrom(msg.sender, address(0xdead), amount);

        newToken.safeTransfer(msg.sender, amount);
    }
}
