// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IWalletIdentityResolver {
    function clusterOf(uint256 chainId, address wallet) external view returns (uint64 clusterId, uint16 confidenceBps);
}
