// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "contracts/ERC721EnumerableNew.sol";
import "contracts/ERC721ANew.sol";
import "erc721a/contracts/ERC721A.sol";
import "forge-std/Test.sol";

contract ERC721ATest is Test {

    ERC721ANew erc721a;
    ERC721EnumerableNew erc721Enumerable;
    address operator;
    address user;
    address receiver;
    uint tokenId;

    function setUp() public {
        erc721a = new ERC721ANew("TestToken", "TT");
        erc721Enumerable = new ERC721EnumerableNew("TestToken", "TT");
        user = makeAddr("user");
        receiver = makeAddr("receiver");
        operator = makeAddr("operator");
        tokenId = 0;
    }

    function testERC721AMintOnce() public {
        vm.startPrank(user);
        erc721a.mint(user, 1); // token amount
        erc721a.approve(operator, tokenId);
        vm.stopPrank();
        vm.startPrank(operator);
        erc721a.transfer(user, receiver, tokenId);
    }

    function testERC721EnumerableMintOnce() public {
        vm.startPrank(user);
        erc721Enumerable.mint(user, 0); // token id
        erc721Enumerable.approve(operator, tokenId);
        vm.stopPrank();
        vm.startPrank(operator);
        erc721Enumerable.transfer(user, receiver, tokenId);
    }

    function testERC721AMintThreeTimes() public {
        vm.startPrank(user);
        erc721a.mint(user, 3);
        vm.stopPrank();
    }

    function testERC721EnumerableMintThreeTimes() public {
        vm.startPrank(user);
        erc721Enumerable.mint(user, 0);
        erc721Enumerable.mint(user, 1);
        erc721Enumerable.mint(user, 2);
        vm.stopPrank();
    }
}