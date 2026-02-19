from dataclasses import dataclass


@dataclass(slots=True)
class WalletFingerprint:
    wallet: str
    avg_gas_price: float
    active_hours_entropy: float
    bridge_counterparties: int


def similarity(a: WalletFingerprint, b: WalletFingerprint) -> float:
    gas_score = 1 - min(abs(a.avg_gas_price - b.avg_gas_price) / 300, 1)
    entropy_score = 1 - min(abs(a.active_hours_entropy - b.active_hours_entropy), 1)
    bridge_score = 1 - min(abs(a.bridge_counterparties - b.bridge_counterparties) / 25, 1)
    return round((gas_score + entropy_score + bridge_score) / 3, 4)
