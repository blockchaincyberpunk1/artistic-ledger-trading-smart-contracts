// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title Counter
 * @dev Provides a counter that can only be incremented or decremented by one. The counter starts from zero.
 * This can be used for tracking IDs, counting contract interactions, etc.
 */
library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    /**
     * @dev Returns the current value of the counter.
     */
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    /**
     * @dev Increments the counter by one. This can't overflow because the max
     * value of a solidity uint256 is so large that it's practically impossible to
     * reach by incrementing one by one.
     */
    function increment(Counter storage counter) internal {
        unchecked {
            counter._value += 1;
        }
    }

    /**
     * @dev Decrements the counter by one. This function will revert if the
     * counter's value is 0, preventing underflow.
     */
    function decrement(Counter storage counter) internal {
        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }
}
