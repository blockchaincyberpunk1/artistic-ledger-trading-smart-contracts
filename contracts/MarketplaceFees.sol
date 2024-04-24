// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Marketplace Fees Management
 * @dev Contract to handle the collection of marketplace fees for transactions on the ArtisticLedger Trading platform.
 * Allows setting and collecting fees for transactions, enhancing platform revenue streams.
 */
contract MarketplaceFees is Ownable {
    uint256 private _feePercentage; // Fee percentage in basis points (100 basis points = 1%)

    event FeePercentageSet(uint256 feePercentage);
    event FeeCollected(address indexed from, uint256 amount);

    /**
     * @dev Sets the marketplace transaction fee percentage.
     * @param feePercentage Fee percentage in basis points.
     */
    function setFeePercentage(uint256 feePercentage) public onlyOwner {
        require(feePercentage <= 10000, "Fee percentage exceeds maximum.");
        _feePercentage = feePercentage;
        emit FeePercentageSet(feePercentage);
    }

    /**
     * @dev Collects fees on a transaction within the marketplace.
     * @param amount The total amount of the transaction from which the fee is to be calculated.
     * @return feeAmount The amount of the fee collected based on the transaction amount and the fee percentage.
     */
    function collectFee(uint256 amount) public payable returns (uint256 feeAmount) {
        feeAmount = (amount * _feePercentage) / 10000;
        require(msg.value >= feeAmount, "Insufficient fee amount sent.");

        // Transfer the fee amount to the marketplace owner
        payable(owner()).transfer(feeAmount);

        emit FeeCollected(msg.sender, feeAmount);

        // Refund any excess fee amount sent
        if (msg.value > feeAmount) {
            payable(msg.sender).transfer(msg.value - feeAmount);
        }

        return feeAmount;
    }

    /**
     * @dev Returns the current fee percentage.
     * @return The fee percentage in basis points.
     */
    function getFeePercentage() public view returns (uint256) {
        return _feePercentage;
    }
}
