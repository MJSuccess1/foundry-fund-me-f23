//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {console} from "forge-std/console.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe,WithdrawFundMe} from "../../script/Interactions.s.sol";


contract InteractionsTest is Test {
    FundMe fundMe;  

    address user = makeAddr("user");
    uint256 constant SEND_VALUE = 0.01 ether; //1x 10^18vm.deal(user, SEND_VALUE);vvm.deal(
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;



    function setUp() external {
        DeployFundMe deploy = new DeployFundMe();
        fundMe = deploy.run(); //cos run will now return a fundme contract
        vm.deal(user, STARTING_BALANCE); 
    }

    function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        //vm.prank(user);
        vm.deal(user, SEND_VALUE);

        //fund.fundFundMe(address(fundMe));// fund using script 
        fundFundMe.fundFundMe(address(fundMe));
        
        

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe)); // withdrae using script

        //address funder = fundMe.getFunder(0); //should be user as we only hv one funder
        //assertEq(funder, user);

        assert(address(fundMe).balance == 0);


    }
}



