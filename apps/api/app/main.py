from fastapi import FastAPI
from prometheus_client import CONTENT_TYPE_LATEST, generate_latest
from starlette.responses import HTMLResponse, RedirectResponse, Response

from app.api.routes import router
from app.core.logging import configure_logging

app = FastAPI(title="MultiChain Fraud Intelligence API", version="1.0.0")
configure_logging()
app.include_router(router)


@app.get("/", include_in_schema=False)
def root() -> RedirectResponse:
    return RedirectResponse(url="/dashboard")


@app.get("/dashboard", response_class=HTMLResponse, include_in_schema=False)
def dashboard() -> str:
    return """
<!doctype html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\" />
  <meta name=\"viewport\" content=\"width=device-width,initial-scale=1\" />
  <title>MultiChain Fraud Intelligence Dashboard</title>
  <style>
    body { font-family: Inter, Arial, sans-serif; margin: 0; background: #0b1020; color: #e7ecff; }
    .container { max-width: 1000px; margin: 0 auto; padding: 24px; }
    .grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; margin-top: 16px; }
    .card { background: #151d35; border: 1px solid #2f3a60; border-radius: 12px; padding: 16px; }
    .label { color: #9aa8d6; font-size: 12px; text-transform: uppercase; letter-spacing: .08em; }
    .value { font-size: 28px; font-weight: 700; margin-top: 8px; }
    .ok { color: #5cf2a5; }
    a { color: #8ab4ff; }
  </style>
</head>
<body>
  <div class=\"container\">
    <h1>MultiChain Fraud Intelligence Dashboard</h1>
    <p>Operational snapshot for Ethereum, BSC, and Polygon fraud monitoring.</p>
    <div class=\"grid\">
      <div class=\"card\"><div class=\"label\">API Health</div><div class=\"value ok\">ONLINE</div></div>
      <div class=\"card\"><div class=\"label\">Supported Chains</div><div class=\"value\">3</div></div>
      <div class=\"card\"><div class=\"label\">Risk Engine</div><div class=\"value\">ACTIVE</div></div>
    </div>
    <p style=\"margin-top:20px\">Quick links: <a href=\"/docs\">API Docs</a> · <a href=\"/metrics\">Prometheus Metrics</a> · <a href=\"/v1/health\">Health Endpoint</a></p>
  </div>
</body>
</html>
"""


@app.get("/metrics")
def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
