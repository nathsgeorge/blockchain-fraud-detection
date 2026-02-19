from dataclasses import dataclass
from datetime import datetime


@dataclass(slots=True)
class Transaction:
    tx_hash: str
    chain: str
    from_address: str
    to_address: str
    value: float
    timestamp: datetime
