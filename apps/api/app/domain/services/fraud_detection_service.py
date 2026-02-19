from statistics import mean

from app.infrastructure.graph.wallet_graph_engine import WalletGraphEngine
from app.infrastructure.timeseries.anomaly_detector import TimeSeriesAnomalyDetector
from app.schemas.fraud import FraudRequest, FraudResponse


class FraudDetectionService:
    def __init__(self) -> None:
        self.graph_engine = WalletGraphEngine()
        self.ts_detector = TimeSeriesAnomalyDetector()

    def analyze(self, request: FraudRequest) -> FraudResponse:
        graph_score = self.graph_engine.risk_score(request.wallet_address, request.transactions)
        anomaly_score = self.ts_detector.anomaly_score([tx.value for tx in request.transactions])
        cross_chain_score = self._cross_chain_score(request.chains)
        final_score = round(mean([graph_score, anomaly_score, cross_chain_score]), 4)

        reasons = []
        if graph_score > 0.7:
            reasons.append("Wallet has suspicious graph centrality and high-risk neighbors")
        if anomaly_score > 0.7:
            reasons.append("Transaction sequence exhibits anomalous spikes")
        if cross_chain_score > 0.7:
            reasons.append("Cross-chain behavior indicates rapid bridge-and-drain pattern")

        return FraudResponse(
            wallet_address=request.wallet_address,
            fraud_score=final_score,
            risk_level=self._risk_level(final_score),
            reasons=reasons,
        )

    @staticmethod
    def _cross_chain_score(chains: list[str]) -> float:
        chain_factor = len(set(chains)) / 3
        return min(1.0, round(0.35 + chain_factor * 0.65, 4))

    @staticmethod
    def _risk_level(score: float) -> str:
        if score >= 0.8:
            return "critical"
        if score >= 0.6:
            return "high"
        if score >= 0.4:
            return "medium"
        return "low"
