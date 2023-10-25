// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";
import {BRR} from "src/BRR.sol";

contract BRRScript is Script {
    function run() public {
        vm.broadcast(vm.envUint("PRIVATE_KEY"));

        new BRR(vm.envAddress("OWNER"));
    }
}
