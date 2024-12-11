// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Snifter} from "../src/Snifter.sol";
import {PaymentToken} from "./mocks/PaymentToken.sol";
import {NftReceiver} from "./mocks/NftReceiver.sol";
import {FakePeople} from "./mocks/FakePeople.sol";

contract TestSnifter is Test {
    Snifter public snifter;
    PaymentToken public token;
    NftReceiver public nftReceiver;

    function setUp() public {
        token = new PaymentToken();
        snifter = new Snifter(address(token), 2);
        nftReceiver = new NftReceiver();
        token.transfer(address(nftReceiver), 10);
        token.transfer(address(FakePeople.Jessy), 10);
    }

    function testInitialState() public view {
      assertEq(address(snifter.paymentToken()), address(token));
      assertEq(token.balanceOf(address(this)), 80);
      assertEq(token.balanceOf(address(nftReceiver)), 10);
      assertEq(token.balanceOf(address(FakePeople.Jessy)), 10);
      assertEq(snifter.tokenPrice(), 2);
      assertEq(snifter.nextTokenId(), 1);
    }

    function testMintToContract() public {
      assertEq(snifter.nextTokenId(), 1);

      vm.startPrank(address(nftReceiver));
      token.approve(address(snifter), 2);
      snifter.mint();
      vm.stopPrank();

      assertEq(snifter.nextTokenId(), 2);
    }

    function testMintToEoa() public {
      assertEq(snifter.nextTokenId(), 1);

      vm.startPrank(FakePeople.Jessy);
      token.approve(address(snifter), 2);
      snifter.mint();
      vm.stopPrank();

      assertEq(snifter.nextTokenId(), 2);
    }
}
