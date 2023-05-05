// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract ERC721EnumerableNew is ERC721Enumerable {

    constructor(string memory _name, string memory _symbol) ERC721(_name, _symbol) {
        
    }

    function mint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }

    function transfer(address from,address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
    }
}