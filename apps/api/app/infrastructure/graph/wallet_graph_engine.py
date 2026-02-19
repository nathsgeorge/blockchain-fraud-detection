import networkx as nx

from app.schemas.fraud import TransactionInput


class WalletGraphEngine:
    def risk_score(self, wallet: str, txs: list[TransactionInput]) -> float:
        graph = nx.DiGraph()
        for tx in txs:
            graph.add_edge(tx.from_address, tx.to_address, value=tx.value)

        if wallet not in graph:
            return 0.1

        pagerank = nx.pagerank(graph, alpha=0.9)
        centrality = nx.degree_centrality(graph)
        pr = pagerank.get(wallet, 0.0)
        dc = centrality.get(wallet, 0.0)
        return min(1.0, round(0.3 + pr * 2.5 + dc, 4))
