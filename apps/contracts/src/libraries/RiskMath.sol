// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

library RiskMath {
    uint256 internal constant BPS_DENOMINATOR = 10_000;

    error InvalidBps();

    function validateBps(uint256 bps) internal pure {
        if (bps > BPS_DENOMINATOR) revert InvalidBps();
    }

    function weightedAverage(uint256 weightedSum, uint256 totalWeight) internal pure returns (uint16) {
        if (totalWeight == 0) {
            return 0;
        }

        uint256 avg = weightedSum / totalWeight;
        if (avg > BPS_DENOMINATOR) {
            avg = BPS_DENOMINATOR;
        }
        return uint16(avg);
    }
}
