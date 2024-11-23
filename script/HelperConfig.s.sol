//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";



contract HelperConfig is Script {
//if we on local anvil, deploy mocks
//otherwise  grab existing address from live network

    NetworkConfig public activeNetworkConfig; //will set this to the onewe are on

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig { //create new object of type network config
        address priceFeed; // ETH/USD price feed address .
    }

    constructor() {
        if (block.chainid == 11155111) { //11155111 is id Sepolia 
            activeNetworkConfig = getSepoliaETHConfig();//we activating the sepoliaconfig if we in sep chain
        } else if (block.chainid == 1) {  
            activeNetworkConfig = getMainnetETHConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilETHConfig();//otherwise use anvil config
        }  
        }
    

        
    

    function getSepoliaETHConfig() public pure returns (NetworkConfig memory) { //this whole thing is to grab existing address and use it
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 });
        return sepoliaConfig;
    }

    function getMainnetETHConfig() public pure returns (NetworkConfig memory) { //this whole thing is to grab existing address and use it
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306 });
        return ethConfig; //a way to get ethConfig
    }

    function getOrCreateAnvilETHConfig() public returns (NetworkConfig memory) {//use meory keywords xos its a special object

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



