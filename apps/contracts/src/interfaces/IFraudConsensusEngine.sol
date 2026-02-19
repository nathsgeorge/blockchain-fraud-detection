// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IFraudConsensusEngine {
    function stateOf(bytes32 signalId)
        external
        view
        returns (
            address wallet,
            uint256 chainId,
            uint16 finalScoreBps,
            uint32 totalWeight,
            bytes32 reasonHash,
            bool finalized
        );
}
