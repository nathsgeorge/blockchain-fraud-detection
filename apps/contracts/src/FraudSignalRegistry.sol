// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract FraudSignalRegistry {
    struct FraudSignal {
        bytes32 signalId;
        address reporter;
        address wallet;
        uint256 scoreBps;
        uint256 timestamp;
        string chain;
        string reason;
    }

    mapping(bytes32 => FraudSignal) public signals;
    mapping(address => bool) public approvedReporters;
    address public owner;

    event ReporterUpdated(address indexed reporter, bool approved);
    event FraudSignalSubmitted(bytes32 indexed signalId, address indexed wallet, uint256 scoreBps, string chain);

    modifier onlyOwner() {
        require(msg.sender == owner, "not owner");
        _;
    }

    modifier onlyReporter() {
        require(approvedReporters[msg.sender], "not approved");
        _;
    }

    constructor() {
        owner = msg.sender;
        approvedReporters[msg.sender] = true;
    }

    function setReporter(address reporter, bool approved) external onlyOwner {
        approvedReporters[reporter] = approved;
        emit ReporterUpdated(reporter, approved);
    }

    function submitSignal(
        bytes32 signalId,
        address wallet,
        uint256 scoreBps,
        string calldata chain,
        string calldata reason
    ) external onlyReporter {
        require(signals[signalId].timestamp == 0, "signal exists");
        require(scoreBps <= 10000, "score invalid");

        signals[signalId] = FraudSignal({
            signalId: signalId,
            reporter: msg.sender,
            wallet: wallet,
            scoreBps: scoreBps,
            timestamp: block.timestamp,
            chain: chain,
            reason: reason
        });

        emit FraudSignalSubmitted(signalId, wallet, scoreBps, chain);
    }
}
