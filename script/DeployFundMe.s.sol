// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // Before broadcast == simulation not real transactions
        HelperConfig helperConfig = new HelperConfig();
        address ethUSdPricefeed = helperConfig.activeNetworkConfig();
        //After broadcast == real transaction
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUSdPricefeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
