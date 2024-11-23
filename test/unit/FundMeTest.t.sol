//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {FundMe} from "src/FundMe.sol";
import {console} from "forge-std/console.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test {
    FundMe fundMe;

    address user = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //1x 10^18
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();//create new deployfundMe\
        fundMe = deployFundMe.run();//cos run will now return a fundme contract
        vm.deal(user, STARTING_BALANCE);  
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsMsgSender() public {
        console.log("Hi there!");
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    //wanna test the fund function
    function testFundFailWithoutEnoughETH() public {
        vm.expectRevert(); //next line should revert
        fundMe.fund(); //diid not add fund {} .this is equiv to us sending 0 ETH therefore will REVERT and pass forge test
    }

    //wanna test data structures
    function testFundMeUpdatesFundedDataStructures() public {
        vm.prank(user); //next tx will be sent bu user
        fundMe.fund{value: SEND_VALUE}(); //we sending 10 eth(bigger than minumum)

        //uint256 amountFunded = fundMe.getAddressToAmountFunded(address(this)); //remove this address for updated "USER's"
        uint256 amountFunded = fundMe.getAddressToAmountFunded(user);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(user);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); //should be user as we only hv one funder
        assertEq(funder, user); //we checking whether funder === user
        
    }

    modifier funded() { //any test we write after this ,we can add "funded" to function
        vm.prank(user);
        fundMe.fund{value: SEND_VALUE}();
        _;  
    }


    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(user); //this line and next is to fund it
        //fundMe.fund{value: SEND_VALUE}();

        vm.expectRevert(); //this will skip next line 
        //vm.prank(user); //will revert if its user cos user is not owner
        fundMe.withdraw(); //user will try to withdraw
    }

    function testWithdrawWithASingleFunder() public funded {
        //arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;   //will get balance of owner before withdraw
        uint256 startingFundMeBalance = address(fundMe).balance;    //will get balance of fundMe in wei
        
        //act
        //uint256 gasStart = gasleft(); //1k
       // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner()); //200
        fundMe.withdraw(); //what we are testing

        //uint256 gasEnd = gasleft(); 800
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; //1k- 200
        //console.log(gasUsed)   ;         

        //assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance; //will get balance of owner after withdraw
        uint256 endingFundMeBalance = address(fundMe).balance;  //will get balance of fundMe in wei after withdraw
        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);    
    }


    function testWithdrawFromMultipleFundersCheaper() public funded {
        //ARRANGE
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1; //we start at index 1 ad not 0 coz it might REVERT 

        for(uint160 i = startingFunderIndex; i < numberOfFunders ; i++) {
            //vm.prank new address
            //vm.deal new address money
            hoax(address(i), SEND_VALUE); //creating blank address at index i and sending funds to it
            //fund the fundMe contract
            fundMe.fund{value: SEND_VALUE}();//will fund the fundMe contract from all these addresses 
        }

        //ACT   
        uint256 startingOwnerBalance = fundMe.getOwner().balance;   //will get balance of owner before withdraw
        uint256 startingFundMeBalance = address(fundMe).balance;    //will get balance of fundMe in wei


        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); //what we are testing

        //ASSERT
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        //ARRANGE
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex =1; //we start at index 1 ad not 0 coz it might REVERT 

        for(uint160 i = startingFunderIndex; i < numberOfFunders ; i++) {
            //vm.prank new address
            //vm.deal new address money
            hoax(address(i), SEND_VALUE); //creating blank address at index i and sending funds to it
            //fund the fundMe contract
            fundMe.fund{value: SEND_VALUE}();//will fund the fundMe contract from all these addresses 
        }

        //ACT   
        uint256 startingOwnerBalance = fundMe.getOwner().balance;   //will get balance of owner before withdraw
        uint256 startingFundMeBalance = address(fundMe).balance;    //will get balance of fundMe in wei


        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw(); //what we are testing
        vm.stopPrank();

        //ASSERT
        assert(address(fundMe).balance == 0);
        assert(startingFundMeBalance + startingOwnerBalance == fundMe.getOwner().balance);
    }

}


