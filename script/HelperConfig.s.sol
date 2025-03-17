//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";


contract HelperConfig is Script {

    NetworkConfig public activeNetworkConfig; 
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig { //create new object of type network config
        address priceFeed; // ETH/USD price feed address .
    }

    constructor() {
        if (block.chainid == 11155111) { //11155111 is Sepolia's chsin Id
            activeNetworkConfig = getSepoliaETHConfig(); //we are activating the sepoliaconfig if we are on the Sepolia chain
        } else if (block.chainid == 1) {  
            activeNetworkConfig = getMainnetETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig(); 
        }  
    }
    

        

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) { 
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 });
        return sepoliaConfig;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) { 
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 });
        return ethConfig; //a way to get ethConfig
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {//if its  not default or 0 addres therefore we hv alresady set it
            return activeNetworkConfig;
        }

        // NetworkConfig memory anvilConfig = NetworkConfig({
        // }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); //cos it takes 2 parameter from MockV3Aggregator.sol   
        vm.stopBroadcast(); 
    

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed) });
            return anvilConfig;
         }   
}



