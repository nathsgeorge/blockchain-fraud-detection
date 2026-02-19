import networkx as nx

from app.infrastructure.graph.wallet_graph_engine import WalletGraphEngine
from app.schemas.fraud import TransactionInput


def test_risk_score_falls_back_when_pagerank_fails(monkeypatch) -> None:
    engine = WalletGraphEngine()

    def fail_pagerank(*_args, **_kwargs):
        raise nx.PowerIterationFailedConvergence(100)

    monkeypatch.setattr(nx, "pagerank", fail_pagerank)

    score = engine.risk_score(
        "0xabc",
        [
            TransactionInput(
                tx_hash="0x1",
                chain="ethereum",
                from_address="0xabc",
                to_address="0xdef",
                value=100,
                timestamp=1,
            ),
            TransactionInput(
                tx_hash="0x2",
                chain="ethereum",
                from_address="0xdef",
                to_address="0xabc",
                value=200,
                timestamp=2,
            ),
        ],
    )

    assert 0.0 <= score <= 1.0
