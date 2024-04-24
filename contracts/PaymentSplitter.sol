// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PaymentSplitter
 * @dev This contract can be used when payments need to be received by a group of people and split proportionately
 * according to the number of shares they own.
 */
contract PaymentSplitter {
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    uint256 private _totalShares;
    uint256 private _totalReleased;

    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _released;
    address[] private _payees;

    /**
     * @dev Constructor
     * @param initPayees Array of payee addresses.
     * @param initShares Array of share allocations corresponding to each payee.
     */
    constructor(address[] memory initPayees, uint256[] memory initShares) {
        require(initPayees.length == initShares.length, "PaymentSplitter: payees and shares length mismatch");
        require(initPayees.length > 0, "PaymentSplitter: no payees");

        for (uint256 i = 0; i < initPayees.length; i++) {
            _addPayee(initPayees[i], initShares[i]);
        }
    }

    /**
     * @dev Fallback function receives funds and emits a notification event.
     */
    receive() external payable {
        emit PaymentReceived(msg.sender, msg.value);
    }

    /**
     * @return the total shares of the contract.
     */
    function totalShares() public view returns(uint256) {
        return _totalShares;
    }

    /**
     * @return the total amount already released.
     */
    function totalReleased() public view returns(uint256) {
        return _totalReleased;
    }

    /**
     * @return the shares of an account.
     */
    function shares(address account) public view returns(uint256) {
        return _shares[account];
    }

    /**
     * @return the amount already released to an account.
     */
    function released(address account) public view returns(uint256) {
        return _released[account];
    }

    /**
     * @return the address of a payee.
     */
    function payee(uint256 index) public view returns(address) {
        require(index < _payees.length, "PaymentSplitter: index out of bounds");
        return _payees[index];
    }

    /**
     * @dev Release one of the payee's proportional payment.
     * @param account Whose payments will be released.
     */
    function release(address payable account) public {
        require(_shares[account] > 0, "PaymentSplitter: account has no shares");

        uint256 totalReceived = address(this).balance + _totalReleased;
        uint256 payment = (totalReceived * _shares[account]) / _totalShares - _released[account];

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _released[account] += payment;
        _totalReleased += payment;

        account.transfer(payment);
        emit PaymentReleased(account, payment);
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _addPayee(address account, uint256 shares_) private {
        require(account != address(0), "PaymentSplitter: account is the zero address");
        require(shares_ > 0, "PaymentSplitter: shares are 0");
        require(_shares[account] == 0, "PaymentSplitter: account already has shares");

        _payees.push(account);
        _shares[account] = shares_;
        _totalShares += shares_;
        emit PayeeAdded(account, shares_);
    }
}
