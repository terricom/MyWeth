// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "erc721a/contracts/ERC721A.sol";

contract ERC721ANew is ERC721A {
    constructor(string memory _name, string memory _symbol) ERC721A(_name, _symbol) {
        
    }

    function mint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }

    function transfer(address from,address to, uint256 tokenId) public {
        transferFrom(from, to, tokenId);
    }
}