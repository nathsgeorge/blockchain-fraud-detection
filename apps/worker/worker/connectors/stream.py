import json
import redis


class FraudEventStream:
    def __init__(self, redis_url: str, stream_name: str) -> None:
        self.client = redis.Redis.from_url(redis_url)
        self.stream_name = stream_name

    def read(self, last_id: str = "0-0") -> tuple[str, dict] | None:
        records = self.client.xread({self.stream_name: last_id}, block=1000, count=1)
        if not records:
            return None
        _, entries = records[0]
        event_id, payload = entries[0]
        data = json.loads(payload[b"payload"].decode("utf-8"))
        return event_id.decode("utf-8"), data
