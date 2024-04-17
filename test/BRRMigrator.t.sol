// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {SafeTransferLib} from "solady/utils/SafeTransferLib.sol";
import {BRR} from "src/BRR.sol";
import {IStakedBRR} from "src/interfaces/IStakedBRR.sol";
import {BRRMigrator} from "src/BRRMigrator.sol";

contract BRRMigratorTest is Test {
    using SafeTransferLib for address;

    address public constant OLD_TOKEN =
        0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884;
    address public constant OLD_STAKED_TOKEN =
        0x9A2a2E71071Caff506050bE6747B4E1369964933;
    uint256 public constant NEW_BRR_MIGRATION_AMOUNT = 1_000_000e18;
    uint256 public constant BRR_MINT_AMOUNT = 1_000_000e18;
    uint256 public constant STAKED_BRR_MINT_AMOUNT = 1_000_000e18;
    BRR public immutable token = new BRR(address(this));
    BRRMigrator public immutable migrator = new BRRMigrator(address(token));

    constructor() {
        token.mint(address(migrator), NEW_BRR_MIGRATION_AMOUNT);

        vm.prank(BRR(OLD_TOKEN).owner());

        BRR(OLD_TOKEN).mint(
            address(this),
            BRR_MINT_AMOUNT + STAKED_BRR_MINT_AMOUNT
        );
        address(OLD_TOKEN).safeApprove(address(migrator), type(uint256).max);
        address(OLD_TOKEN).safeApprove(OLD_STAKED_TOKEN, type(uint256).max);
        OLD_STAKED_TOKEN.safeApprove(address(migrator), type(uint256).max);
        IStakedBRR(OLD_STAKED_TOKEN).stake(
            address(this),
            STAKED_BRR_MINT_AMOUNT
        );
    }

    /*//////////////////////////////////////////////////////////////
                             migrate
    //////////////////////////////////////////////////////////////*/

    function testCannotMigrateTransferFromFailed() external {
        uint256 amount = BRR_MINT_AMOUNT + 1;

        vm.expectRevert(SafeTransferLib.TransferFromFailed.selector);

        migrator.migrate(amount);
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
        amount = bound(amount, 0, BRR_MINT_AMOUNT);
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

    /*//////////////////////////////////////////////////////////////
                             migrateStaked
    //////////////////////////////////////////////////////////////*/

    function testCannotMigrateStakedTransferFromFailed() external {
        uint256 amount = STAKED_BRR_MINT_AMOUNT + 1;

        vm.expectRevert(SafeTransferLib.TransferFromFailed.selector);

        migrator.migrateStaked(amount);
    }

    function testMigrateStaked() external {
        uint256 amount = 1;
        uint256 oldStakedTokenBalanceBefore = OLD_STAKED_TOKEN.balanceOf(
            address(this)
        );
        uint256 newTokenBalanceBefore = token.balanceOf(address(this));

        migrator.migrateStaked(amount);

        assertEq(
            oldStakedTokenBalanceBefore - amount,
            OLD_STAKED_TOKEN.balanceOf(address(this))
        );
        assertEq(
            newTokenBalanceBefore + amount,
            token.balanceOf(address(this))
        );
    }

    function testMigrateStakedFuzz(uint256 amount) external {
        amount = bound(amount, 0, STAKED_BRR_MINT_AMOUNT);
        uint256 oldStakedTokenBalanceBefore = OLD_STAKED_TOKEN.balanceOf(
            address(this)
        );
        uint256 newTokenBalanceBefore = token.balanceOf(address(this));

        migrator.migrateStaked(amount);

        assertEq(
            oldStakedTokenBalanceBefore - amount,
            OLD_STAKED_TOKEN.balanceOf(address(this))
        );
        assertEq(
            newTokenBalanceBefore + amount,
            token.balanceOf(address(this))
        );
    }
}
