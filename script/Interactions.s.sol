//Fund
//withdraw

//SPDX-License-Identifier:MIT

pragma solidity ^0.8.18;

import {Script,console} from "forge-std/Script.sol";
import {DevOpsTools} from  "../lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";



contract FundFundMe is Script { //script for funding FundMe Contract 

    uint256 constant SEND_VALUE = 0.1 ether; //1e17

    function fundFundMe(address mostRecentlyDeployed) public {
        //vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        //vm.stopBroadcast();
        //console.log("Funded FundMe with %s" , 1 ether);       
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);//goes to broadcast and run-latest to pick most recent file     
    
        vm.startBroadcast();
        fundFundMe(mostRecentlyDeployed); // run function will call mostRecentDeployed
        vm.stopBroadcast();
    }
}


contract WithdrawFundMe is Script {

     function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();         
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);//goes to broadcast and run-latest to pick most recent file     
    
        vm.startBroadcast();
        withdrawFundMe(mostRecentlyDeployed); // run function will call mostRecentDeployed
        vm.stopBroadcast();
    }
}