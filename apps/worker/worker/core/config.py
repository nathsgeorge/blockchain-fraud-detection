from dataclasses import dataclass
import os


@dataclass(slots=True)
class WorkerConfig:
    redis_url: str = os.getenv("MFI_REDIS_URL", "redis://redis:6379/0")
    stream_name: str = os.getenv("MFI_STREAM_NAME", "fraud-events")


config = WorkerConfig()
