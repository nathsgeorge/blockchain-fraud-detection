import logging

from worker.connectors.stream import FraudEventStream
from worker.core.config import config

logger = logging.getLogger(__name__)


def run_ingestion_loop() -> None:
    logging.basicConfig(level=logging.INFO)
    stream = FraudEventStream(config.redis_url, config.stream_name)
    last_id = "0-0"
    logger.info("worker started")
    while True:
        message = stream.read(last_id)
        if not message:
            continue
        last_id, data = message
        logger.info("received_event", extra={"event_id": last_id, "wallet": data.get("wallet_address")})
