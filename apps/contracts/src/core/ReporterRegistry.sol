// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "../access/Ownable.sol";

contract ReporterRegistry is Ownable {
    error ReporterNotApproved();

    mapping(address => bool) public approvedReporters;

    event ReporterUpdated(address indexed reporter, bool approved);

    modifier onlyReporter() {
        if (!approvedReporters[msg.sender]) revert ReporterNotApproved();
        _;
    }

    constructor(address owner_) Ownable(owner_) {
        approvedReporters[owner_] = true;
        emit ReporterUpdated(owner_, true);
    }

    function setReporter(address reporter, bool approved) external onlyOwner {
        approvedReporters[reporter] = approved;
        emit ReporterUpdated(reporter, approved);
    }
}
