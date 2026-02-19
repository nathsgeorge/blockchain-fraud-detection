pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/FraudSignalRegistry.sol";

contract FraudSignalRegistryTest is Test {
    FraudSignalRegistry internal registry;

    function setUp() public {
        registry = new FraudSignalRegistry();
    }

    function testSubmitSignal() public {
        bytes32 signalId = keccak256("signal-1");
        registry.submitSignal(signalId, address(0xBEEF), 9000, "ethereum", "wash-trading");

        (
            bytes32 id,
            address reporter,
            address wallet,
            uint256 scoreBps,
            uint256 timestamp,
            string memory chain,
            string memory reason
        ) = registry.signals(signalId);

        assertEq(id, signalId);
        assertEq(reporter, address(this));
        assertEq(wallet, address(0xBEEF));
        assertEq(scoreBps, 9000);
        assertGt(timestamp, 0);
        assertEq(chain, "ethereum");
        assertEq(reason, "wash-trading");
    }
}
