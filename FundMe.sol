// SPDX-License-Identifier: MIT

// Get Funds From User
// Withdraw Funds
// Set a Minimum funding value in USD

pragma solidity ^0.8.8;

import "./PriceConverter.sol";

// to save gas on the requires we define this error:
error NotOwner();

contract FundMe {
    using PriceConverter for uint256;
    // cheaper gas if it's a constant variable, so if we plan not to change it better use it
    uint256 public constant MINIMUM_USD = 50 * 1e18; // 1 * 10 ** 18
    // 21,415 gas - constant
    // 21,515 gas - non constant

    // track the funders:
    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    // if we set one time not in the same line we can use immutable and it saves gas too
    address public immutable i_owner;

    // 21,508 gas - immutable
    // 21,644 gas - non_immutable

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        // Want to be able to set a minimun in USD
        // 1. How do we send ETH to this contract:
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't send enough!"
        ); //1e18 == 1 *10 ** 18 == 100000000000000000
        // we don't pass anything in getConv because the first parameter (msg.value) is considered the argument

        // if less than minimum = > REVERT
        // undo any action before and send remeaning gas back

        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public onlyOwner {
        for (uint256 i = 0; i < funders.length; i++) {
            address funder = funders[i];
            addressToAmountFunded[funder] = 0;
        }
        // reset array
        funders = new address[](0);
        // actually withdraw the funds, three way:

        // 1 transfer (casting to payable to make the possiblity to sent ETH
        // if dont' succed ut reverts transaction
        //payable(msg.sender).transfer(address(this).balance);

        // 2 send
        // with send it doesn't revert, but it gives back a boolean
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed");

        // 3 call
        // it returns 2 variable (it doesn't have a capped gas)
        // reccomented way!
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner, "Sender is not the owner!");
        // to save gas we use this synthax:
        if (msg.sender != i_owner) {
            revert NotOwner();
        }
        _;
    }

    // What happens if someone sends this contract ETH without calling fund()?
    // we keep track using two special functions, receive and fallback:

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }
    // if somebody send accidentally money without fund
    //we can process the transaction in this way, it's routed on fund function
    // so if not send enough money it get reverted!

    // explained in solidity by examples:
    // Explainer from: https://solidity-by-example.org/fallback/
    // Ether is sent to contract
    //      is msg.data empty?
    //          /   \
    //         yes  no
    //         /     \
    //    receive()?  fallback()
    //     /   \
    //   yes   no
    //  /        \
    //receive()  fallback()
}
