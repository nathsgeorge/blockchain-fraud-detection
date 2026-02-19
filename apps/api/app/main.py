from fastapi import FastAPI
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from starlette.responses import Response

from app.api.routes import router
from app.core.logging import configure_logging

app = FastAPI(title="MultiChain Fraud Intelligence API", version="1.0.0")
configure_logging()
app.include_router(router)


@app.get("/metrics")
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
