// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ReporterRegistry} from "./ReporterRegistry.sol";
import {RiskMath} from "../libraries/RiskMath.sol";

contract WalletIdentityResolver is ReporterRegistry {
    struct Identity {
        uint64 clusterId;
        uint16 confidenceBps;
        uint64 updatedAt;
    }

    uint64 public nextClusterId = 1;

    mapping(bytes32 => Identity) private identities;

    event WalletLinked(uint256 indexed chainId, address indexed wallet, uint64 indexed clusterId, uint16 confidenceBps);

    constructor(address owner_) ReporterRegistry(owner_) {}

    function linkWallet(uint256 chainId, address wallet, uint64 clusterId, uint16 confidenceBps) external onlyReporter {
        RiskMath.validateBps(confidenceBps);

        uint64 useClusterId = clusterId;
        if (useClusterId == 0) {
            useClusterId = nextClusterId++;
        }

        bytes32 key = keccak256(abi.encode(chainId, wallet));
        identities[key] = Identity({clusterId: useClusterId, confidenceBps: confidenceBps, updatedAt: uint64(block.timestamp)});

        emit WalletLinked(chainId, wallet, useClusterId, confidenceBps);
    }

    function clusterOf(uint256 chainId, address wallet) external view returns (uint64 clusterId, uint16 confidenceBps) {
        Identity memory id = identities[keccak256(abi.encode(chainId, wallet))];
        return (id.clusterId, id.confidenceBps);
    }
}
