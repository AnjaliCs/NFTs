// SPDX-License-Identifier: MIT
pragma solidity^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";


contract MyCollectibles is ERC721Enumerable, Ownable {

    using SafeMath for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenId;

    uint256 public constant MAX_Supply = 100;
    uint256 public constant MAX_Per_Mint = 5;
    uint256 public constant PRICE = 0.2 ether;

    string public baseTokenURI;

   
   constructor(string memory _baseTokenURI) ERC721("NFTCollectibles", "NCT") {
        setBaseURI(_baseTokenURI);
    }

    
    function reserveNFTs() public onlyOwner {
        uint totalMinted = _tokenId.current();

        require(totalMinted.add(10) < MAX_Supply, "Not enough NFTs left to reserve");

        for(uint i; i< 10; i++) {
            _mintSingleNFT();
        }
    }

    
    function _baseURI() internal view virtual override returns(string memory) {
        return baseTokenURI;
    }

    
    function setBaseURI(string memory _baseTokenURI) public onlyOwner {
        baseTokenURI = _baseTokenURI;
    }

    
    function mintNFTs(uint amount) public payable {
        uint totalMinted = _tokenId.current();

        require(amount > 0 && amount <= MAX_Per_Mint, "Can't mint NFTs");
        require(msg.value >= PRICE.mul(amount), "Put the required ether");
        require(totalMinted.add(amount) <= MAX_Supply, "Not enough NFTs left");

        for(uint i = 0; i < amount; i++) {
            _mintSingleNFT();
        }
    }

    
    function _mintSingleNFT() private {
        uint newTokenID = _tokenId.current();
        _safeMint(msg.sender, newTokenID);
        _tokenId.increment();
    }

    
    function tokensOfOwner(address _owner) external view returns(uint[] memory) {
        uint tokenCount = balanceOf(_owner);
        uint[] memory tokensId = new uint[](tokenCount);

        for(uint i=0; i < tokenCount; i++){
            tokensId[i] = tokenOfOwnerByIndex(_owner, i);
        }
        
        return tokensId;
    }

    
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "No ethers left to withdraw");
        payable(owner()).transfer(address(this).balance);
    }
}
