import numpy as np
from sklearn.ensemble import IsolationForest


def make_windows(series: np.ndarray, window: int = 5) -> np.ndarray:
    return np.array([series[idx:idx + window] for idx in range(0, len(series) - window + 1)])


def train_detector() -> IsolationForest:
    rng = np.random.default_rng(42)
    baseline = rng.normal(loc=100, scale=8, size=500)
    spikes = rng.normal(loc=300, scale=20, size=30)
    series = np.concatenate([baseline, spikes])
    windows = make_windows(series)
    model = IsolationForest(contamination=0.06, random_state=42)
    model.fit(windows)
    return model


if __name__ == "__main__":
    model = train_detector()
    print("offset", model.offset_)
