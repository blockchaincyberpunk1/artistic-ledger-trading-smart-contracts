// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title Artwork Validation Contract for ArtisticLedger Trading Platform
 * @dev Enables third-party validators to authenticate artworks, ensuring their authenticity.
 * Utilizes OpenZeppelin's AccessControl for managing validator roles and permissions.
 */
contract ArtworkValidation is AccessControl {
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");

    struct ValidationRequest {
        address requester;
        bool isVerified;
    }

    // Mapping of artwork hash to its validation request
    mapping(string => ValidationRequest) private _validationRequests;

    event ValidationRequested(string indexed artworkHash, address indexed requester);
    event ArtworkValidated(string indexed artworkHash, bool isVerified, address indexed validator);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(VALIDATOR_ROLE, _msgSender());
    }

    /**
     * @notice Requests the validation of an artwork.
     * @dev Registers a request for artwork validation. Emits a ValidationRequested event.
     * @param artworkHash The unique identifier (hash) of the artwork to be validated.
     */
    function requestValidation(string memory artworkHash) public {
        _validationRequests[artworkHash] = ValidationRequest({
            requester: _msgSender(),
            isVerified: false
        });

        emit ValidationRequested(artworkHash, _msgSender());
    }

    /**
     * @notice Validates an artwork as authentic or not.
     * @dev Submits the result of artwork validation. Restricted to validators only.
     * Emits an ArtworkValidated event.
     * @param artworkHash The unique identifier (hash) of the artwork to validate.
     * @param isVerified The validation result, true if the artwork is authenticated, false otherwise.
     */
    function validateArtwork(string memory artworkHash, bool isVerified) public onlyRole(VALIDATOR_ROLE) {
        require(_validationRequests[artworkHash].requester != address(0), "Validation request not found.");
        _validationRequests[artworkHash].isVerified = isVerified;

        emit ArtworkValidated(artworkHash, isVerified, _msgSender());
    }

    /**
     * @notice Retrieves the validation status of an artwork.
     * @dev Returns whether the artwork has been validated as authentic.
     * @param artworkHash The unique identifier (hash) of the artwork.
     * @return isVerified True if the artwork is verified as authentic, false otherwise.
     */
    function getValidationStatus(string memory artworkHash) public view returns (bool isVerified) {
        return _validationRequests[artworkHash].isVerified;
    }

    /**
     * @dev Grants the VALIDATOR_ROLE to an account.
     * @param account The account to grant the validator role.
     */
    function grantValidatorRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(VALIDATOR_ROLE, account);
    }

    /**
     * @dev Revokes the VALIDATOR_ROLE from an account.
     * @param account The account to revoke the validator role.
     */
    function revokeValidatorRole(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(VALIDATOR_ROLE, account);
    }
}
