// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/core/FraudConsensusEngine.sol";
import "../../src/core/WalletIdentityResolver.sol";
import "../../src/core/MultiChainFraudRegistry.sol";

contract MultiChainFraudRegistryTest is Test {
    FraudConsensusEngine internal engine;
    WalletIdentityResolver internal resolver;
    MultiChainFraudRegistry internal registry;

    address internal reporterA = address(0xA1);
    address internal reporterB = address(0xB2);
    address internal wallet = address(0xBEEF);

    function setUp() public {
        engine = new FraudConsensusEngine(address(this), 7_000);
        resolver = new WalletIdentityResolver(address(this));
        registry = new MultiChainFraudRegistry(address(this), engine, resolver);

        engine.setReporter(reporterA, true);
        engine.setReporter(reporterB, true);

        resolver.setReporter(reporterA, true);
        vm.prank(reporterA);
        resolver.linkWallet(137, wallet, 44, 9_100);
    }

    function testAnchorFinalizedSignalWithIdentityCluster() public {
        bytes32 signalId = keccak256("cross-chain-drain");

        vm.prank(reporterA);
        engine.submitVote(signalId, wallet, 137, 9_000, 4_000, keccak256("cross-chain-drain"));

        vm.prank(reporterB);
        engine.submitVote(signalId, wallet, 137, 8_000, 3_500, keccak256("cross-chain-drain"));

        registry.anchorSignal(signalId);

        (
            bytes32 id,
            address signalWallet,
            uint256 chainId,
            uint16 scoreBps,
            uint64 timestamp,
            uint64 clusterId,
            bytes32 reasonHash,
            address finalizedBy
        ) = registry.finalizedSignals(signalId);

        assertEq(id, signalId);
        assertEq(signalWallet, wallet);
        assertEq(chainId, 137);
        assertEq(scoreBps, 8_533);
        assertGt(timestamp, 0);
        assertEq(clusterId, 44);
        assertEq(reasonHash, keccak256("cross-chain-drain"));
        assertEq(finalizedBy, address(this));
    }
}
