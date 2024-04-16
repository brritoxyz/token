// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {BRR} from "src/BRR.sol";
import {BRRMigrator} from "src/BRRMigrator.sol";

contract BRRMigratorTest is Test {
    using SafeTransferLib for address;

    address public constant OLD_TOKEN =
        0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    uint256 public constant TEST_SUPPLY = 1_000_000e18;
    BRR public immutable token = new BRR(address(this));
    BRRMigrator public immutable migrator = new BRRMigrator(address(token));

    constructor() {
        token.mint(address(migrator), TEST_SUPPLY);

        vm.prank(BRR(OLD_TOKEN).owner());

        BRR(OLD_TOKEN).mint(address(this), TEST_SUPPLY);
        address(OLD_TOKEN).safeApprove(address(migrator), type(uint256).max);
    }

    function testCannotMigrateTransferFromFailed() external {
        uint256 amount = TEST_SUPPLY + 1;

        vm.expectRevert(SafeTransferLib.TransferFromFailed.selector);

        migrator.migrate(amount);
    }

    function testMigrateZero() external {
        uint256 amount = 0;
        uint256 oldTokenBalanceBefore = OLD_TOKEN.balanceOf(address(this));
        uint256 newTokenBalanceBefore = token.balanceOf(address(this));

        migrator.migrate(amount);

        // Should be unchanged if `amount` is zero.
        assertEq(oldTokenBalanceBefore, OLD_TOKEN.balanceOf(address(this)));
        assertEq(newTokenBalanceBefore, token.balanceOf(address(this)));
    }

    function testMigrate() external {
        uint256 amount = 1;
        uint256 oldTokenBalanceBefore = OLD_TOKEN.balanceOf(address(this));
        uint256 newTokenBalanceBefore = token.balanceOf(address(this));

        migrator.migrate(amount);

        assertEq(
            oldTokenBalanceBefore - amount,
            OLD_TOKEN.balanceOf(address(this))
        );
        assertEq(
            newTokenBalanceBefore + amount,
            token.balanceOf(address(this))
        );
    }

    function testMigrateFuzz(uint256 amount) external {
        amount = bound(amount, 0, TEST_SUPPLY);
        uint256 oldTokenBalanceBefore = OLD_TOKEN.balanceOf(address(this));
        uint256 newTokenBalanceBefore = token.balanceOf(address(this));

        migrator.migrate(amount);

        assertEq(
            oldTokenBalanceBefore - amount,
            OLD_TOKEN.balanceOf(address(this))
        );
        assertEq(
            newTokenBalanceBefore + amount,
            token.balanceOf(address(this))
        );
    }
}
