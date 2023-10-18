// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {BRR} from "src/BRR.sol";

contract BRRTest is Test {
    bytes32 private constant _TOTAL_SUPPLY_SLOT =
        bytes32(uint256(0x05345cdf77eb68f44c));

    BRR public immutable token = new BRR(address(this));

    event SetMaxSupply(uint256 newMaxSupply);

    /*//////////////////////////////////////////////////////////////
                             setMaxSupply
    //////////////////////////////////////////////////////////////*/

    function testCannotSetMaxSupplyUnauthorized() external {
        address msgSender = address(0);
        uint256 newMaxSupply = 0;

        assertTrue(msgSender != token.owner());

        vm.prank(msgSender);
        vm.expectRevert(Ownable.Unauthorized.selector);

        token.setMaxSupply(newMaxSupply);
    }

    function testCannotSetMaxSupplyCannotIncreaseMaxSupply() external {
        address msgSender = token.owner();
        uint256 newMaxSupply = token.maxSupply() + 1;

        vm.prank(msgSender);
        vm.expectRevert(BRR.CannotIncreaseMaxSupply.selector);

        token.setMaxSupply(newMaxSupply);
    }

    function testCannotSetMaxSupplyMaxSupplyTooLow() external {
        uint256 totalSupply = 1;

        vm.store(address(token), _TOTAL_SUPPLY_SLOT, bytes32(totalSupply));

        assertEq(totalSupply, token.totalSupply());

        address msgSender = token.owner();
        uint256 newMaxSupply = totalSupply - 1;

        vm.prank(msgSender);
        vm.expectRevert(BRR.MaxSupplyTooLow.selector);

        token.setMaxSupply(newMaxSupply);
    }

    function testSetMaxSupply() external {
        address msgSender = token.owner();
        uint256 newMaxSupply = token.maxSupply() - 1;

        assertTrue(newMaxSupply != token.maxSupply());

        vm.prank(msgSender);
        vm.expectEmit(false, false, false, true, address(token));

        emit SetMaxSupply(newMaxSupply);

        token.setMaxSupply(newMaxSupply);

        assertEq(newMaxSupply, token.maxSupply());
    }
}
