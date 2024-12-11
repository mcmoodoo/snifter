// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Snifter is ERC721, Ownable, ReentrancyGuard {
    IERC20 public paymentToken; // ERC-20 token used for payment
    uint256 public tokenPrice; // Price in ERC-20 tokens
    uint256 public nextTokenId; // Token ID counter

    constructor(address _paymentToken, uint256 _tokenPrice) ERC721("Snifter", "SNFT") Ownable(address(this)) {
        paymentToken = IERC20(_paymentToken);
        tokenPrice = _tokenPrice;
        nextTokenId = 1;
    }

    function mint() external {
        require(paymentToken.transferFrom(msg.sender, address(this), tokenPrice), "Payment failed");

        // Mint the NFT to the sender
        _safeMint(msg.sender, nextTokenId);

        // Increment the token ID for the next mint
        nextTokenId++;
    }

    // Owner function to withdraw the collected ERC-20 tokens
    function withdraw() external onlyOwner nonReentrant {
        uint256 balance = paymentToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");
        require(paymentToken.transfer(owner(), balance), "Withdraw failed");
    }

    // Owner function to set the price
    function setPrice(uint256 _price) external onlyOwner {
        tokenPrice = _price;
    }
}
