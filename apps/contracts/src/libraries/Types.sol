// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library Types {
    struct FinalizedSignal {
        bytes32 signalId;
        address wallet;
        uint256 chainId;
        uint16 scoreBps;
        uint64 timestamp;
        uint64 clusterId;
        bytes32 reasonHash;
        address finalizedBy;
    }

    struct VoteState {
        address wallet;
        uint256 chainId;
        uint64 createdAt;
        uint16 finalScoreBps;
        uint32 totalWeight;
        uint256 weightedScoreSum;
        bytes32 reasonHash;
        bool finalized;
    }
}
