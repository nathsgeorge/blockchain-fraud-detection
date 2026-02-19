from pydantic import BaseModel, Field


class TransactionInput(BaseModel):
    tx_hash: str
    chain: str
    from_address: str
    to_address: str
    value: float = Field(ge=0)
    timestamp: int


class FraudRequest(BaseModel):
    wallet_address: str
    chains: list[str]
    transactions: list[TransactionInput]


class FraudResponse(BaseModel):
    wallet_address: str
    fraud_score: float
    risk_level: str
    reasons: list[str]
