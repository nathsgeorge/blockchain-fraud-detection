from locust import HttpUser, task, between


class FraudAPIUser(HttpUser):
    wait_time = between(1, 3)

    @task
    def analyze(self) -> None:
        payload = {
            "wallet_address": "0xabc123",
            "chains": ["ethereum", "bsc", "polygon"],
            "transactions": [
                {
                    "tx_hash": "0x1",
                    "chain": "ethereum",
                    "from_address": "0xa",
                    "to_address": "0xabc123",
                    "value": 320.5,
                    "timestamp": 1710000100,
                },
                {
                    "tx_hash": "0x2",
                    "chain": "bsc",
                    "from_address": "0xabc123",
                    "to_address": "0xb",
                    "value": 12000.0,
                    "timestamp": 1710000200,
                },
                {
                    "tx_hash": "0x3",
                    "chain": "polygon",
                    "from_address": "0xc",
                    "to_address": "0xabc123",
                    "value": 10.0,
                    "timestamp": 1710000300,
                },
            ],
        }
        self.client.post("/v1/analyze", json=payload)
