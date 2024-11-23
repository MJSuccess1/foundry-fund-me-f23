//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";//coz we using script
import {FundMe} from "../src/FundMe.sol"; //cos we deploying FundMe
import {HelperConfig} from "./HelperConfig.s.sol";


contract DeployFundMe is Script {
    
    function run() external returns (FundMe) {

        //beorefe vm.broadcat == not real tx(simulate environment)
        HelperConfig helperConfig = new HelperConfig(); //create new helperconfig 
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();//get address like this

        //anything in here will be broadcast === real tx
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethUsdPriceFeed);
        vm.stopBroadcast();
        return fundMe;
        }   

    }
