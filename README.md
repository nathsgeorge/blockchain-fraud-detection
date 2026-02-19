# MultiChain Fraud Intelligence system

Solidity-first and Rust-accelerated multi-chain fraud intelligence stack for Ethereum, BSC, and Polygon.

## Project Summary
This repository models a startup-grade fraud platform where canonical risk consensus and identity linkage are on-chain, while low-latency scoring and indexing are handled by Rust services and Python adapters.

## Business Problem
Fraud campaigns distribute activity across chains and wallets. Pure off-chain systems lack shared trust guarantees and often create inconsistent partner risk decisions.

## Solution
- Solidity contracts finalize fraud consensus and anchor immutable signals
- Rust risk engine computes deterministic weighted fraud score artifacts
- Rust indexer ingests anchored signal events for compliance/search pipelines
- Python API/worker acts as integration adapter for ingestion and ML feature prep

## Multi-Chain Architecture
```mermaid
flowchart LR
E[Ethereum] --> I[Ingestion]
B[BSC] --> I
P[Polygon] --> I
I --> RUST1[rust-risk-engine]
RUST1 --> C[FraudConsensusEngine.sol]
I --> C
C --> A[MultiChainFraudRegistry.sol]
A --> RUST2[rust-indexer]
A --> API[FastAPI adapter]
```

## Graph ML Explanation
Graph and temporal features are computed off-chain, then transformed into reporter votes. The Rust risk engine provides reproducible scoring logic before publishing scores to Solidity consensus.

## Cross-Chain Identity Resolution
`WalletIdentityResolver.sol` maps `(chainId, wallet)` to cluster identities, enabling signal propagation to related addresses across chains.

## Smart Contract Design
- `ReporterRegistry.sol`
- `FraudConsensusEngine.sol`
- `WalletIdentityResolver.sol`
- `MultiChainFraudRegistry.sol`
- `FraudSignalRegistry.sol`

## Scalability Considerations
- Solidity contracts are minimal and event-centric
- Rust services support high-throughput event decoding/scoring
- Python services remain stateless and horizontally scalable

## Security Considerations
- Reporter allowlist and ownership controls
- Quorum-weighted voting with bounded score math
- Immutable anchoring and event replay

## Observability
- Contract events for every vote/finalization/anchor
- Prometheus endpoint in API adapter
- Rust service logs for scoring/indexing pipelines

## Simulated Throughput Metrics
- 150 reporter votes/minute
- <2-block finalization after quorum
- Rust indexing throughput target: 4k events/sec per instance

## Deployment Instructions
### Contracts
```bash
cd apps/contracts
forge build
forge test -vv
forge script script/Deploy.s.sol:Deploy --rpc-url $RPC_URL --broadcast
```

### Rust
```bash
cargo test --workspace
make rust-run-risk
make rust-run-indexer
```

### Full stack
```bash
./scripts/bootstrap.sh
make up
```

## API Documentation
- `POST /v1/analyze`
- `GET /v1/health`
- `GET /metrics`

## Repository Structure
```text
blockchain-fraud-detection
├── apps
│   ├── contracts
│   ├── rust-risk-engine
│   ├── rust-indexer
│   ├── api
│   └── worker
├── infra
├── ml
├── tests
├── Cargo.toml
├── Makefile
└── README.md
```

## Future Improvements
- Add slashing-enabled reporter staking
- Add Rust gRPC index/query plane
- Add zero-knowledge reporter attestations
