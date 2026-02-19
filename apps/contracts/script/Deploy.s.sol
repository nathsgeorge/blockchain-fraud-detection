// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/core/FraudConsensusEngine.sol";
import "../src/core/WalletIdentityResolver.sol";
import "../src/core/MultiChainFraudRegistry.sol";

contract Deploy is Script {
    function run() external {
        uint256 deployerPk = vm.envUint("DEPLOYER_PRIVATE_KEY");
        vm.startBroadcast(deployerPk);

        address owner = vm.addr(deployerPk);
        FraudConsensusEngine engine = new FraudConsensusEngine(owner, 7000);
        WalletIdentityResolver resolver = new WalletIdentityResolver(owner);
        MultiChainFraudRegistry registry = new MultiChainFraudRegistry(owner, engine, resolver);

        vm.stopBroadcast();

        console2.log("FraudConsensusEngine", address(engine));
        console2.log("WalletIdentityResolver", address(resolver));
        console2.log("MultiChainFraudRegistry", address(registry));
    }
}
