// SPDX-LIcense-Identifier : MIT
pragma solidity^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Auction is ERC721, ERC721URIStorage {
    uint256 public _tokenId = 0;
    uint256 public _listingId = 0;

    address public owner;

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => uint256) public highestBid;
    mapping(uint256 => address) public highestBidder;
    mapping(uint256 => mapping(address => uint256)) public bids;

    constructor() ERC721("Crypto Dev", "CDV") {
        owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(owner == msg.sender, "You are not the owner");
        _;
    }

    struct Listing {
        address seller;
        uint256 tokenid;
        uint256 price;
        uint256 startAt;
        uint256 endAt;
    }


    function createNFT(string memory uri) public {
        _tokenId++;
        _safeMint(msg.sender, _tokenId);
        _setTokenURI(_tokenId, uri);
    }

    function _burn(uint256 tokenid) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenid);
    }

    function tokenURI(uint256 tokenid) public view override(ERC721, ERC721URIStorage) returns(string memory) {
        return super.tokenURI(tokenid);
    }

    function startAuction(uint256 _tokenid, uint256 _price, uint256 _endAt) public returns(uint256) {
        require(ownerOf(_tokenid) == msg.sender, "You don't have the ownership");
        _listingId++;

        listings[_listingId] = Listing({
            seller : msg.sender,
            tokenid : _tokenid,
            price : _price,
            startAt : block.timestamp,
            endAt : _endAt
        });

        return _listingId;
    }

    function bid(uint256 listingid, uint256 amount) public payable {
        require(amount >= listings[listingid].price, "Price cannot be less than start bid amount");
        require(listings[listingid].seller != msg.sender, "You cannot bid on your own auction");
        require(isAuctionOpen(listingid) == true, "Auction not started yet");
        highestBid[listingid] = amount;
        highestBidder[listingid] = msg.sender;
        bids[listingid][msg.sender] += amount;
    } 

    function isAuctionOpen(uint256 listingid) public view returns(bool) { 
        if(block.timestamp >= listings[listingid].endAt) {
            return false;
        }
        else {
            return true;
        }
    }

    function endAuction(uint256 listingid, uint256 tokenid) public {
        require(block.timestamp >= listings[listingid].endAt, "Auction is not ended");
        address winner = highestBidder[listingid];
        address seller = listings[listingid].seller;
        uint256 amount = highestBid[listingid];
        require(winner != address(0), "Invalid address");
        transferFrom(seller, winner, tokenid);
        payable(seller).transfer(amount);
    }

    function checkBalance() public view returns(uint256) {
        return address(this).balance;
    }

    function withdrawBid(uint256 listingid) public {
        uint256 amount = bids[listingid][msg.sender];
        payable(msg.sender).transfer(amount);
    }
}
