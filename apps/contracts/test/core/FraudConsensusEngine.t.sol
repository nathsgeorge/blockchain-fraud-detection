// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/core/FraudConsensusEngine.sol";

contract FraudConsensusEngineTest is Test {
    FraudConsensusEngine internal engine;
    address internal reporterA = address(0xA1);
    address internal reporterB = address(0xB2);
    bytes32 internal signalId = keccak256("sig-1");

    function setUp() public {
        engine = new FraudConsensusEngine(address(this), 8_000);
        engine.setReporter(reporterA, true);
        engine.setReporter(reporterB, true);
    }

    function testFinalizeAfterQuorum() public {
        vm.prank(reporterA);
        engine.submitVote(signalId, address(0xBEEF), 1, 9_000, 4_000, keccak256("rapid-bridge"));

        vm.prank(reporterB);
        engine.submitVote(signalId, address(0xBEEF), 1, 8_000, 4_000, keccak256("rapid-bridge"));

        (, , uint16 finalScoreBps, uint32 totalWeight, , bool finalized) = engine.stateOf(signalId);

        assertEq(finalized, true);
        assertEq(totalWeight, 8_000);
        assertEq(finalScoreBps, 8_500);
    }
}
