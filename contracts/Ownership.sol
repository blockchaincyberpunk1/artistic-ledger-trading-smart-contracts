// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Ownership Tracking for ArtisticLedger Trading Platform
 * @dev Contract to track ownership and provenance of artworks. It allows artworks' ownership to be transferred 
 * and records each artwork's ownership history.
 */
contract Ownership is AccessControl {
    bytes32 public constant TRANSFER_ROLE = keccak256("TRANSFER_ROLE");

    struct OwnershipRecord {
        address currentOwner;
        uint256 transferDate;
    }

    // Mapping from artwork hash to ownership history
    mapping(string => OwnershipRecord[]) private ownershipHistory;

    event OwnershipTransferred(string indexed artworkHash, address indexed from, address indexed to, uint256 transferDate);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /**
     * @notice Transfers ownership of an artwork from one party to another.
     * @dev Records the transfer of artwork ownership in the ownership history.
     * @param artworkHash The unique identifier (hash) of the artwork.
     * @param newOwner The address of the new owner.
     */
    function transferOwnership(string memory artworkHash, address newOwner) public onlyRole(TRANSFER_ROLE) {
        require(newOwner != address(0), "New owner cannot be the zero address.");
        // Assuming the existence of a function in ArtworkRegistry to verify artwork registration
        // require(artworkRegistry.isArtworkRegistered(artworkHash), "Artwork must be registered.");

        OwnershipRecord[] storage history = ownershipHistory[artworkHash];
        address previousOwner = history.length > 0 ? history[history.length - 1].currentOwner : address(0);

        ownershipHistory[artworkHash].push(OwnershipRecord(newOwner, block.timestamp));

        emit OwnershipTransferred(artworkHash, previousOwner, newOwner, block.timestamp);
    }

    /**
     * @notice Retrieves the ownership history of an artwork.
     * @dev Returns an array of ownership records for the specified artwork.
     * @param artworkHash The unique identifier (hash) of the artwork.
     * @return A dynamic array of `OwnershipRecord` structs representing the ownership history.
     */
    function getOwnershipHistory(string memory artworkHash) public view returns (OwnershipRecord[] memory) {
        return ownershipHistory[artworkHash];
    }

    /**
     * @dev Grants TRANSFER_ROLE to an account, allowing it to transfer artwork ownership.
     * @param account The address to be granted TRANSFER_ROLE.
     */
    function grantTransferRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(TRANSFER_ROLE, account);
    }

    /**
     * @dev Revokes TRANSFER_ROLE from an account, preventing it from transferring artwork ownership.
     * @param account The address to have TRANSFER_ROLE revoked.
     */
    function revokeTransferRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(TRANSFER_ROLE, account);
    }
}
