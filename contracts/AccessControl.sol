// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title AccessControl for ArtisticLedger Trading Platform
 * @dev Extends OpenZeppelin's AccessControl contract to manage permissions within the ArtisticLedger Trading platform, 
 * such as admin rights and validator roles. It allows for role-based access control, enabling the platform to assign 
 * specific permissions to different users.
 */
contract ArtisticLedgerAccessControl is AccessControl {
    /**
     * @dev Emitted when `roleId` is granted to `account`.
     */
    event RoleGranted(bytes32 indexed roleId, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `roleId` is revoked from `account`.
     */
    event RoleRevoked(bytes32 indexed roleId, address indexed account, address indexed sender);

    /**
     * @dev Grants `roleId` to `account`. Only accounts with the role's admin role can grant it.
     * Emits a {RoleGranted} event.
     * @param roleId The identifier of the role to be granted.
     * @param account The account to grant the role to.
     */
    function grantRole(bytes32 roleId, address account) public override {
        super.grantRole(roleId, account);
        emit RoleGranted(roleId, account, _msgSender());
    }

    /**
     * @dev Revokes `roleId` from `account`. Only accounts with the role's admin role can revoke it.
     * Emits a {RoleRevoked} event.
     * @param roleId The identifier of the role to be revoked.
     * @param account The account to revoke the role from.
     */
    function revokeRole(bytes32 roleId, address account) public override {
        super.revokeRole(roleId, account);
        emit RoleRevoked(roleId, account, _msgSender());
    }

    /**
     * @dev Checks if `account` has been assigned `roleId`.
     * @param roleId The identifier of the role.
     * @param account The account to check for the role.
     * @return bool True if `account` has been assigned `roleId`, false otherwise.
     */
    function hasRole(bytes32 roleId, address account) public view override returns (bool) {
        return super.hasRole(roleId, account);
    }

    /**
     * @dev Constructor that sets up the default admin role to the deploying account.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }
}
