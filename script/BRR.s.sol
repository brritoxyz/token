// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import {BRR} from "src/BRR.sol";

contract BRRScript is Script {
    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        BRR brr = new BRR(vm.envAddress("OWNER"));

        // Mint 1 BRR token (18 decimals) to the deployer for future testing and development.
        brr.mint(vm.envAddress("OWNER"), 1e18);

        vm.stopBroadcast();
    }
}
