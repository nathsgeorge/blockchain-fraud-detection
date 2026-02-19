from dataclasses import dataclass

import networkx as nx
import numpy as np
from sklearn.ensemble import RandomForestClassifier


@dataclass
class GraphSample:
    wallet: str
    in_degree: int
    out_degree: int
    pagerank: float
    label: int


def synthetic_graph_samples(size: int = 1000) -> list[GraphSample]:
    graph = nx.scale_free_graph(size, seed=42).to_directed()
    pagerank = nx.pagerank(graph)
    samples: list[GraphSample] = []
    for node in list(graph.nodes())[:size]:
        indeg = graph.in_degree(node)
        outdeg = graph.out_degree(node)
        pr = pagerank[node]
        label = int((indeg + outdeg) > 20 or pr > 0.005)
        samples.append(GraphSample(str(node), indeg, outdeg, pr, label))
    return samples


def train() -> RandomForestClassifier:
    data = synthetic_graph_samples()
    x = np.array([[d.in_degree, d.out_degree, d.pagerank] for d in data])
    y = np.array([d.label for d in data])
    model = RandomForestClassifier(n_estimators=150, random_state=42)
    model.fit(x, y)
    return model


if __name__ == "__main__":
    trained = train()
    print("trained_estimators", len(trained.estimators_))
