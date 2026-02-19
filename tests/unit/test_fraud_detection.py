from app.domain.services.fraud_detection_service import FraudDetectionService
from app.schemas.fraud import FraudRequest, TransactionInput


def test_fraud_detection_high_risk() -> None:
    service = FraudDetectionService()
    payload = FraudRequest(
        wallet_address="0xabc",
        chains=["ethereum", "bsc", "polygon"],
        transactions=[
            TransactionInput(
                tx_hash="0x1",
                chain="ethereum",
                from_address="0xabc",
                to_address="0xdef",
                value=1,
                timestamp=1,
            ),
            TransactionInput(
                tx_hash="0x2",
                chain="ethereum",
                from_address="0xdef",
                to_address="0xabc",
                value=10000,
                timestamp=2,
            ),
            TransactionInput(
                tx_hash="0x3",
                chain="bsc",
                from_address="0xabc",
                to_address="0xghi",
                value=9500,
                timestamp=3,
            ),
            TransactionInput(
                tx_hash="0x4",
                chain="polygon",
                from_address="0xghi",
                to_address="0xabc",
                value=5,
                timestamp=4,
            ),
        ],
    )

    result = service.analyze(payload)
    assert result.fraud_score >= 0
    assert result.risk_level in {"low", "medium", "high", "critical"}
