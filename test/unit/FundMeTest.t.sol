// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    // Unit test - test specific code parts
    //Integration tests - test all parts as the work together
    //Forked tests - Test code on simulated real environment
    // Staging - Test code in real environment that is not production
    function testPriceFeedVersionISAccurate() public view {
        //fundMe Test deployed hence it is the owner
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundingFailsWithoutEnoughEth() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testOwnerCanWithdrawWithSingleFunder() public funded {
        //arrange arrange test
        address fundMeOwnerAddress = fundMe.getOwner();
        uint256 startingOwnerBalance = fundMeOwnerAddress.balance;
        address fundMeAdress = address(fundMe);
        uint256 startingFundMeBalance = fundMeAdress.balance;

        //Act action to test
        //uint256 gasStart = gasleft();
        //vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMeOwnerAddress);
        fundMe.withdraw();
        //uint256 gasEnd = gasleft();
        //uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;

        //assert action result is as expected
        uint256 endingOwnerBalance = fundMeOwnerAddress.balance;
        uint256 endingFundMeBalance = fundMeAdress.balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    // uint256 num = uint256(uint160(msg.sender)); uint160 has same number if bytes as an address
    function testOwnerCanWithdrawWithMultipleFunder() public funded {
        uint256 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //hoax address, send value
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        address fundMeOwnerAddress = fundMe.getOwner();
        uint256 startingOwnerBalance = fundMeOwnerAddress.balance;
        address fundMeAdress = address(fundMe);
        uint256 startingFundMeBalance = fundMeAdress.balance;

        //Act action to test
        vm.startPrank(fundMeOwnerAddress);
        fundMe.withdraw();
        vm.stopPrank();

        //assert action result is as expected
        uint256 endingOwnerBalance = fundMeOwnerAddress.balance;
        uint256 endingFundMeBalance = fundMeAdress.balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testOwnerCanWithdrawWithMultipleFunderCheaper() public funded {
        uint256 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            //hoax address, send value
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
        }
        address fundMeOwnerAddress = fundMe.getOwner();
        uint256 startingOwnerBalance = fundMeOwnerAddress.balance;
        address fundMeAdress = address(fundMe);
        uint256 startingFundMeBalance = fundMeAdress.balance;

        //Act action to test
        vm.startPrank(fundMeOwnerAddress);
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //assert action result is as expected
        uint256 endingOwnerBalance = fundMeOwnerAddress.balance;
        uint256 endingFundMeBalance = fundMeAdress.balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
