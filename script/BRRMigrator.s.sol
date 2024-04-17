// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {ERC20} from "solady/tokens/ERC20.sol";
import {BRR} from "src/BRR.sol";
import {BRRMigrator} from "src/BRRMigrator.sol";

contract BRRMigratorScript is Script {
    ERC20 private constant _OLD_BRR =
        ERC20(0x6d80d90ce251985bF41A98c6FDd6b7b975Fff884);

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        BRR brr = new BRR(vm.envAddress("OWNER"));
        address brrMigrator = address(new BRRMigrator(address(brr)));

        // Mint the current token supply to the migrator contract.
        brr.mint(brrMigrator, _OLD_BRR.totalSupply());

        vm.stopBroadcast();
    }
}
