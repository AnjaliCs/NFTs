// SPDX-License-Identifier : MIT
pragma solidity^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC721, ERC721URIStorage, Ownable {
    uint256 tokenIdCounter = 1;
    uint256 price = 1 ether;

    constructor() ERC721("DEPT Tokens", "DPT") {}

    function mint(string memory uri) public payable {
        require(msg.value == price, "Pay 1 ether to get the NFT");
        _safeMint(msg.sender, tokenIdCounter);
        _setTokenURI(tokenIdCounter, uri);
        tokenIdCounter ++;
    }

    function _burn(uint256 tokenid) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenid);
    }

    function tokenURI(uint256 tokenid) public override(ERC721, ERC721URIStorage) view returns(string memory){
        return super.tokenURI(tokenid);
    }
}
