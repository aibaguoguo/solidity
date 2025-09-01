// contracts/GameItem.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract MyNFT is ERC721URIStorage {
    uint256 private _nextTokenId;

    constructor() ERC721("QuickQuick", "QKQK") {}
    /**
     * tokenURI:https://ipfs.io/ipfs/bafkreihfh2lv7bbte2he7bseb6xvuu45usud6b2avz4ah72xsluxtulmqm
     * https://ipfs.io/ipfs/bafkreice63b3f2cgfub25ynocgewlssuefiulzdxb4yhb7rmgmi4xzuuhq
     */
    function awardItem(address player, string memory tokenURI) public returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(player, tokenId);
        _setTokenURI(tokenId, tokenURI);

        return tokenId;
    }
}