// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "../access/Ownable.sol";
import {Types} from "../libraries/Types.sol";
import {IFraudConsensusEngine} from "../interfaces/IFraudConsensusEngine.sol";
import {IWalletIdentityResolver} from "../interfaces/IWalletIdentityResolver.sol";

contract MultiChainFraudRegistry is Ownable {
    IFraudConsensusEngine public immutable consensusEngine;
    IWalletIdentityResolver public immutable identityResolver;

    mapping(bytes32 => Types.FinalizedSignal) public finalizedSignals;

    event SignalAnchored(
        bytes32 indexed signalId,
        address indexed wallet,
        uint256 indexed chainId,
        uint16 scoreBps,
        uint64 clusterId,
        bytes32 reasonHash
    );

    constructor(address owner_, IFraudConsensusEngine consensus_, IWalletIdentityResolver resolver_) Ownable(owner_) {
        consensusEngine = consensus_;
        identityResolver = resolver_;
    }

    function anchorSignal(bytes32 signalId) external {
        require(finalizedSignals[signalId].timestamp == 0, "already anchored");

        (
            address wallet,
            uint256 chainId,
            uint16 finalScoreBps,
            ,
            bytes32 reasonHash,
            bool finalized
        ) = consensusEngine.stateOf(signalId);

        require(finalized, "not finalized");
        (uint64 clusterId,) = identityResolver.clusterOf(chainId, wallet);

        finalizedSignals[signalId] = Types.FinalizedSignal({
            signalId: signalId,
            wallet: wallet,
            chainId: chainId,
            scoreBps: finalScoreBps,
            timestamp: uint64(block.timestamp),
            clusterId: clusterId,
            reasonHash: reasonHash,
            finalizedBy: msg.sender
        });

        emit SignalAnchored(signalId, wallet, chainId, finalScoreBps, clusterId, reasonHash);
    }
}
