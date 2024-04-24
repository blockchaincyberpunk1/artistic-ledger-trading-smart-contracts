// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./PaymentSplitter.sol";

/**
 * @title Royalty Management for ArtisticLedger Trading Platform
 * @dev Manages and distributes royalties to artists for secondary sales of their artworks. Utilizes OpenZeppelin's AccessControl for role management.
 */
contract RoyaltyManagement is AccessControl {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct RoyaltyInfo {
        address recipient;
        uint256 percentage; // Royalty percentage in basis points (100 basis points = 1%)
    }

    // Mapping from artwork hash to its royalty information
    mapping(string => RoyaltyInfo) public royalties;

    event RoyaltyInfoSet(string indexed artworkHash, address indexed recipient, uint256 percentage);
    event RoyaltiesDistributed(string indexed artworkHash, uint256 amount);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Sets the royalty information for an artwork.
     * @param artworkHash The unique identifier (hash) of the artwork.
     * @param recipient The address of the recipient entitled to receive the royalties.
     * @param percentage The royalty percentage in basis points.
     */
    function setRoyaltyInfo(string memory artworkHash, address recipient, uint256 percentage) public onlyRole(ADMIN_ROLE) {
        require(percentage <= 10000, "Percentage exceeds maximum."); // Ensuring percentage is within valid range
        royalties[artworkHash] = RoyaltyInfo(recipient, percentage);
        emit RoyaltyInfoSet(artworkHash, recipient, percentage);
    }

    /**
     * @notice Distributes royalties for a secondary sale of an artwork.
     * @param artworkHash The unique identifier (hash) of the artwork.
     * @param saleAmount The total amount of the sale.
     */
    function distributeRoyalties(string memory artworkHash, uint256 saleAmount) public payable {
        RoyaltyInfo memory info = royalties[artworkHash];
        require(info.recipient != address(0), "Royalty info not set.");
        require(msg.value == saleAmount, "Sale amount mismatch.");

        uint256 royaltyAmount = (saleAmount * info.percentage) / 10000;
        require(royaltyAmount <= saleAmount, "Royalty exceeds sale amount.");

        payable(info.recipient).transfer(royaltyAmount);
        emit RoyaltiesDistributed(artworkHash, royaltyAmount);

        // Refunding excess payment if any
        if (msg.value > royaltyAmount) {
            payable(msg.sender).transfer(msg.value - royaltyAmount);
        }
    }

    /**
     * @notice Gets the royalty information for an artwork.
     * @param artworkHash The unique identifier (hash) of the artwork.
     * @return recipient The address of the royalty recipient.
     * @return percentage The royalty percentage in basis points.
     */
    function getRoyaltyInfo(string memory artworkHash) public view returns (address recipient, uint256 percentage) {
        RoyaltyInfo memory info = royalties[artworkHash];
        return (info.recipient, info.percentage);
    }
}
