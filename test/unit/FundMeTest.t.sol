// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    DeployFundMe deployFundMe;

    address TEST_USER = makeAddr("user"); //create an address for test
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTTING_BALANCE = 10 ether;
    uint8 constant GAS_PRICE = 1;

    modifier funded() {
        vm.prank(TEST_USER); //this user will run the next function
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function setUp() external {
        deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(TEST_USER, STARTTING_BALANCE); //add balance to an address for test
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.getMinimumUSD(), 5e18);
    }

    function testOwnerIsSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        console.log(address(this));
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // to success the next function call need to revert
        fundMe.fund(); //send 0 value
    }

    function testFundUpdatesFundersData() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(TEST_USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testFundAddFunder() public funded {
        address funder = fundMe.getfunders(0);
        assertEq(TEST_USER, funder);
    }

    function testWithdrawFailNotOwner() public funded {
        vm.prank(TEST_USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawFromOneFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); //In Anvil gas price is 0, can use vm.txGasPrice(GAS_PRICE) to set a gas price for next operation.

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(endingOwnerBalance, startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1; // start in 1 for not use address(0), 160 is the size of an address
        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTTING_BALANCE); //prank + deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assert(endingFundMeBalance == 0);
        assert(endingOwnerBalance == startingOwnerBalance + startingFundMeBalance);
    }

    function testWithdrawFromMultipleFundersCheaper() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFundersIndex = 1; // start in 1 for not use address(0), 160 is the size of an address
        for (uint160 i = startingFundersIndex; i < numberOfFunders; i++) {
            hoax(address(i), STARTTING_BALANCE); //prank + deal
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assert(endingFundMeBalance == 0);
        assert(endingOwnerBalance == startingOwnerBalance + startingFundMeBalance);
    }
}
