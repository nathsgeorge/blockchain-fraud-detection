.PHONY: install lint test run-api run-worker up down load-test forge-test forge-build rust-test rust-run-risk rust-run-indexer

install:
	pip install -e .[dev]

lint:
	ruff check apps ml tests

format:
	ruff format apps ml tests

test:
	pytest -q

run-api:
	uvicorn app.main:app --app-dir apps/api --reload --host 0.0.0.0 --port 8000

run-worker:
	python -m worker.main

up:
	docker compose -f infra/docker/docker-compose.yml up --build

down:
	docker compose -f infra/docker/docker-compose.yml down

load-test:
	locust -f load_test.py --host http://localhost:8000

forge-build:
	cd apps/contracts && forge build

forge-test:
	cd apps/contracts && forge test -vv

rust-test:
	cargo test --workspace

rust-run-risk:
	echo '{"graph_score":0.9,"timeseries_score":0.8,"cross_chain_score":0.7,"reporter_confidence_bps":9000}' | cargo run -p rust-risk-engine --bin risk-cli

rust-run-indexer:
	cargo run -p rust-indexer
