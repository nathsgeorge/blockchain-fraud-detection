// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReporterRegistry} from "./ReporterRegistry.sol";
import {Types} from "../libraries/Types.sol";
import {RiskMath} from "../libraries/RiskMath.sol";

contract FraudConsensusEngine is ReporterRegistry {
    error SignalAlreadyFinalized();
    error ReporterAlreadyVoted();
    error WalletMismatch();
    error ChainMismatch();

    uint32 public immutable quorumWeight;

    mapping(bytes32 => Types.VoteState) private states;
    mapping(bytes32 => mapping(address => bool)) public hasVoted;

    event VoteSubmitted(
        bytes32 indexed signalId,
        address indexed reporter,
        address indexed wallet,
        uint256 chainId,
        uint16 scoreBps,
        uint16 confidenceBps
    );
    event SignalFinalized(bytes32 indexed signalId, uint16 finalScoreBps, uint32 totalWeight, bytes32 reasonHash);

    constructor(address owner_, uint32 quorumWeight_) ReporterRegistry(owner_) {
        quorumWeight = quorumWeight_;
    }

    function submitVote(
        bytes32 signalId,
        address wallet,
        uint256 chainId,
        uint16 scoreBps,
        uint16 confidenceBps,
        bytes32 reasonHash
    ) external onlyReporter {
        RiskMath.validateBps(scoreBps);
        RiskMath.validateBps(confidenceBps);

        Types.VoteState storage st = states[signalId];
        if (st.finalized) revert SignalAlreadyFinalized();
        if (hasVoted[signalId][msg.sender]) revert ReporterAlreadyVoted();

        if (st.createdAt == 0) {
            st.wallet = wallet;
            st.chainId = chainId;
            st.createdAt = uint64(block.timestamp);
            st.reasonHash = reasonHash;
        } else {
            if (st.wallet != wallet) revert WalletMismatch();
            if (st.chainId != chainId) revert ChainMismatch();
        }

        hasVoted[signalId][msg.sender] = true;

        st.totalWeight += confidenceBps;
        st.weightedScoreSum += uint256(scoreBps) * confidenceBps;

        emit VoteSubmitted(signalId, msg.sender, wallet, chainId, scoreBps, confidenceBps);

        if (st.totalWeight >= quorumWeight) {
            _finalize(signalId, st);
        }
    }

    function finalize(bytes32 signalId) external onlyReporter {
        Types.VoteState storage st = states[signalId];
        if (st.finalized) revert SignalAlreadyFinalized();
        _finalize(signalId, st);
    }

    function _finalize(bytes32 signalId, Types.VoteState storage st) internal {
        st.finalized = true;
        st.finalScoreBps = RiskMath.weightedAverage(st.weightedScoreSum, st.totalWeight);
        emit SignalFinalized(signalId, st.finalScoreBps, st.totalWeight, st.reasonHash);
    }

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
        )
    {
        Types.VoteState memory st = states[signalId];
        return (st.wallet, st.chainId, st.finalScoreBps, st.totalWeight, st.reasonHash, st.finalized);
    }
}
