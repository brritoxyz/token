// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {Ownable} from "solady/auth/Ownable.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {BRR} from "src/BRR.sol";

contract BRRTest is Test {
    string private constant _NAME = "Fee printer go brr";
    string private constant _SYMBOL = "BRR";
    bytes32 private constant _TOTAL_SUPPLY_SLOT =
        bytes32(uint256(0x05345cdf77eb68f44c));

    BRR public immutable token = new BRR(address(this));

    event DecreaseMaxSupply(uint256 newMaxSupply);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                             transferOwnership
    //////////////////////////////////////////////////////////////*/

    function testCannotTransferOwnershipUnauthorized() external {
        vm.expectRevert(Ownable.Unauthorized.selector);

        token.transferOwnership(address(1));
    }

    /*//////////////////////////////////////////////////////////////
                             renounceOwnership
    //////////////////////////////////////////////////////////////*/

    function testCannotRenounceOwnershipUnauthorized() external {
        vm.expectRevert(Ownable.Unauthorized.selector);

        token.renounceOwnership();
    }

    /*//////////////////////////////////////////////////////////////
                             name
    //////////////////////////////////////////////////////////////*/

    function testName() external {
        assertEq(_NAME, token.name());
    }

    /*//////////////////////////////////////////////////////////////
                             symbol
    //////////////////////////////////////////////////////////////*/

    function testSymbol() external {
        assertEq(_SYMBOL, token.symbol());
    }

    /*//////////////////////////////////////////////////////////////
                             decreaseMaxSupply
    //////////////////////////////////////////////////////////////*/

    function testCannotDecreaseMaxSupplyUnauthorized() external {
        address msgSender = address(0);
        uint256 newMaxSupply = 0;

        assertTrue(msgSender != token.owner());

        vm.prank(msgSender);
        vm.expectRevert(Ownable.Unauthorized.selector);

        token.decreaseMaxSupply(newMaxSupply);
    }

    function testCannotDecreaseMaxSupplyCannotIncreaseMaxSupply() external {
        address msgSender = token.owner();
        uint256 newMaxSupply = token.maxSupply() + 1;

        vm.prank(msgSender);
        vm.expectRevert(BRR.CannotIncreaseMaxSupply.selector);

        token.decreaseMaxSupply(newMaxSupply);
    }

    function testCannotDecreaseMaxSupplyMaxSupplyLessThanTotal() external {
        uint256 totalSupply = 1;

        vm.store(address(token), _TOTAL_SUPPLY_SLOT, bytes32(totalSupply));

        assertEq(totalSupply, token.totalSupply());

        address msgSender = token.owner();
        uint256 newMaxSupply = totalSupply - 1;

        vm.prank(msgSender);
        vm.expectRevert(BRR.MaxSupplyLessThanTotal.selector);

        token.decreaseMaxSupply(newMaxSupply);
    }

    function testDecreaseMaxSupply() external {
        address msgSender = token.owner();
        uint256 newMaxSupply = token.maxSupply() - 1;

        assertTrue(newMaxSupply != token.maxSupply());

        vm.prank(msgSender);
        vm.expectEmit(false, false, false, true, address(token));

        emit DecreaseMaxSupply(newMaxSupply);

        token.decreaseMaxSupply(newMaxSupply);

        assertEq(newMaxSupply, token.maxSupply());
    }

    /*//////////////////////////////////////////////////////////////
                             mint
    //////////////////////////////////////////////////////////////*/

    function testCannotMintUnauthorized() external {
        address msgSender = address(0);
        address to = address(1);
        uint256 amount = 1;

        assertTrue(msgSender != token.owner());

        vm.prank(msgSender);
        vm.expectRevert(Ownable.Unauthorized.selector);

        token.mint(to, amount);
    }

    function testCannotMintTotalSupplyExceedsMax() external {
        address msgSender = token.owner();
        address to = address(1);
        uint256 amount = token.maxSupply() + 1;

        vm.prank(msgSender);
        vm.expectRevert(BRR.TotalSupplyExceedsMax.selector);

        token.mint(to, amount);
    }

    function testCannotMintTotalSupplyOverflow() external {
        address msgSender = token.owner();
        address to = address(1);
        uint256 amount = token.maxSupply();

        vm.startPrank(msgSender);

        token.mint(to, amount);

        vm.expectRevert(ERC20.TotalSupplyOverflow.selector);

        token.mint(to, type(uint256).max);

        vm.stopPrank();
    }

    function testMint() external {
        address msgSender = token.owner();
        address to = address(1);
        uint256 amount = 1;
        uint256 toBalanceBefore = token.balanceOf(to);
        uint256 totalSupplyBefore = token.totalSupply();

        vm.prank(msgSender);
        vm.expectEmit(true, true, false, true, address(token));

        emit Transfer(address(0), to, amount);

        token.mint(to, amount);

        assertEq(toBalanceBefore + amount, token.balanceOf(to));
        assertEq(totalSupplyBefore + amount, token.totalSupply());
    }

    function testMintFuzz(address to, uint96 amount) external {
        vm.assume(amount < token.maxSupply());

        address msgSender = token.owner();
        uint256 toBalanceBefore = token.balanceOf(to);
        uint256 totalSupplyBefore = token.totalSupply();

        vm.prank(msgSender);
        vm.expectEmit(true, true, false, true, address(token));

        emit Transfer(address(0), to, amount);

        token.mint(to, amount);

        assertEq(toBalanceBefore + amount, token.balanceOf(to));
        assertEq(totalSupplyBefore + amount, token.totalSupply());
    }
}
