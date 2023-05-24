// SPDX-LIcense-Identifier : MIT
pragma solidity^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC721, ERC721URIStorage, IERC721Receiver, Ownable {
    uint256 tokenId = 1;
    uint256 price = 1 ether;
    mapping(uint256 => bool) public listed;

    constructor() ERC721("Dept Tokens", "DPT") {}

    receive() external payable {}

    function earlyMint(address to, string memory uri) public onlyOwner {
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
        tokenId ++;
    }

    function _burn(uint256 tokenid) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenid);
    }

    function tokenURI(uint256 tokenid) public override(ERC721, ERC721URIStorage) view returns(string memory) {
        return super.tokenURI(tokenid);
    }

    function onERC721Received(address, address, uint256, bytes calldata) public pure override returns(bytes4) {
        return this.onERC721Received.selector;
    }

    function SellNFTs(uint256 tokenid) public {
        require(ownerOf(tokenid) == msg.sender, "You don't have the ownership!");
        approve(address(this), tokenid);
        safeTransferFrom(msg.sender, address(this), tokenid);
        listed[tokenid] = true;
    }

    function BuyNFTs(uint256 tokenid) public payable {
        require(ownerOf(tokenid) == address(this), "Contract doesn't own the NFT");
        require(msg.value == price, "Pay 1 ether to buy NFTs");
        require(listed[tokenid] == true, "NFT is not listed");
        approve(msg.sender, tokenid);
        // setApprovalForAll(msg.sender, true);
        safeTransferFrom(address(this), msg.sender, tokenid); 
        // transferFrom(address(this), msg.sender, tokenid); 
    }

    function checkBalance() public onlyOwner view returns(uint256) {
        uint256 amount = address(this).balance;
        return amount;
    }

    function withdraw() public onlyOwner{
        uint256 amount = address(this).balance;
        payable(msg.sender).transfer(amount);
    }
}
