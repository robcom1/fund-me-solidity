// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

// no more used in solidity 0.8.0

contract SafeMathTester {
    uint8 public bigNumber = 255; // unchecked in 0.6.0 , if you pass the limit it wraps around

    function add() public {
        bigNumber = bigNumber + 1;
    }
}
