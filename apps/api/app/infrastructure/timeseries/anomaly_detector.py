import numpy as np
from sklearn.ensemble import IsolationForest


class TimeSeriesAnomalyDetector:
    def anomaly_score(self, values: list[float]) -> float:
        if len(values) < 4:
            return 0.2
        arr = np.array(values, dtype=float).reshape(-1, 1)
        model = IsolationForest(random_state=42, contamination=0.15)
        model.fit(arr)
        preds = model.predict(arr)
        anomalies = (preds == -1).sum()
        return round(min(1.0, anomalies / len(values) + np.std(arr) / (np.mean(arr) + 1e-6) * 0.1), 4)
