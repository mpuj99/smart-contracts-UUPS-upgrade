// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {BoxV1} from "../src/BoxV1.sol";
import {BoxV2} from "../src/BoxV2.sol";
import {Script} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";



contract UpgradeBox is Script {
    function run() external returns (address) {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ERC1967Proxy", block.chainid);
        
        vm.startBroadcast();
        BoxV2 newBox = new BoxV2();
        vm.stopBroadcast();
        address proxy = upgradeBox(address(mostRecentlyDeployed), address(newBox));
        return proxy;
    
    
    }


    function upgradeBox(address proxyAddress, address newBox) public returns (address) {
        vm.startBroadcast();
        // We use teh proxy address already deployed to put it into type BoxV1 to then (in the line below) upgrade the contract to BoxV2, because we doing a UUPS upgrade,
        // the upgrade functions are in the implementation, so we need the type BoxV1 to call te upgrades.
        BoxV1 proxy = BoxV1(proxyAddress); 
        proxy.upgradeToAndCall(address(newBox), ""); // proxy contract now points to this new address
        vm.stopBroadcast();
        return address(proxy);
    }
}