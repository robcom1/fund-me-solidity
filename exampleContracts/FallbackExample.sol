// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

contract FallbackExample {
    uint256 public result;

    // if we send eth to this contract without calling any function (calldata blank) the receive function get triggered
    receive() external payable {
        result = 1;
    }

    // similar but works if data is sended with the transaction
    fallback() external payable {
        result = 2;
    }
}
