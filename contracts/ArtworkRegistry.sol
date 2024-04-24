// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Artwork Registry for ArtisticLedger Trading Platform
 * @dev This contract allows for the registration, verification, and retrieval of artworks' metadata. It uses OpenZeppelin's Ownable and AccessControl for permission management.
 */
contract ArtworkRegistry is Ownable, AccessControl {
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");

    struct Artwork {
        string title;
        string creator;
        uint256 creationDate;
        string hash;
    }

    mapping(string => Artwork) private _artworks;

    event ArtworkRegistered(string indexed hash, string title, string creator, uint256 creationDate);
    event ArtworkVerified(string indexed hash, bool isValid);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(VALIDATOR_ROLE, _msgSender());
    }

    /**
     * @dev Registers a new artwork along with its metadata.
     * @param title The title of the artwork.
     * @param creator The creator of the artwork.
     * @param creationDate The creation date of the artwork.
     * @param hash A unique identifier (hash) for the artwork.
     */
    function registerArtwork(string memory title, string memory creator, uint256 creationDate, string memory hash) public onlyRole(VALIDATOR_ROLE) {
        require(_artworks[hash].creationDate == 0, "Artwork already registered.");
        _artworks[hash] = Artwork(title, creator, creationDate, hash);
        emit ArtworkRegistered(hash, title, creator, creationDate);
    }

    /**
     * @dev Verifies the authenticity of an artwork by checking its stored hash.
     * @param hash The hash of the artwork to verify.
     * @return isValid True if the artwork is registered, false otherwise.
     */
    function verifyArtwork(string memory hash) public view returns (bool isValid) {
        return _artworks[hash].creationDate != 0;
    }

    /**
     * @dev Retrieves the metadata of a registered artwork.
     * @param hash The hash of the artwork to retrieve.
     * @return title The title of the artwork.
     * @return creator The creator of the artwork.
     * @return creationDate The creation date of the artwork.
     */
    function getArtworkDetails(string memory hash) public view returns (string memory title, string memory creator, uint256 creationDate) {
        require(_artworks[hash].creationDate != 0, "Artwork not registered.");
        Artwork memory artwork = _artworks[hash];
        return (artwork.title, artwork.creator, artwork.creationDate);
    }

    /**
     * @dev Grants VALIDATOR_ROLE to an account.
     * @param account The account to grant VALIDATOR_ROLE.
     */
    function grantValidatorRole(address account) public onlyOwner {
        grantRole(VALIDATOR_ROLE, account);
    }

    /**
     * @dev Revokes VALIDATOR_ROLE from an account.
     * @param account The account to revoke VALIDATOR_ROLE.
     */
    function revokeValidatorRole(address account) public onlyOwner {
        revokeRole(VALIDATOR_ROLE, account);
    }
}
