// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MultiToken is ERC1155, Ownable {
    uint256[] supplies = [50, 80, 100];
    uint256[] minted = [0, 0, 0];
    uint256[] rates = [0.25 ether, 0.05 ether, 0.1 ether];

    constructor() ERC1155("https://my-multi-nft/tokens/") {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }
    

    function mint(uint256 id, uint256 amount) public payable{
        require(id <= supplies.length, "Token doesn't exist");
        require(id > 0, "Token doesn't exist");

        uint256 index = id-1;

        require(msg.value >= amount * rates[index], "Not enough ether sent");
        require(minted[index] +amount <= supplies[index], "Not enough supply");
        _mint(msg.sender, id, amount, "");
        minted[index] += amount;
    }
    

    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Balance is 0");
        payable(owner()).transfer(address(this).balance);
    }

}
