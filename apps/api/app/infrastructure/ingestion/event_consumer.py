import json
import redis


class EventConsumer:
    def __init__(self, redis_url: str, stream_name: str = "fraud-events") -> None:
        self.client = redis.Redis.from_url(redis_url)
        self.stream = stream_name

    def publish(self, payload: dict) -> bytes:
        return self.client.xadd(self.stream, {"payload": json.dumps(payload)})
