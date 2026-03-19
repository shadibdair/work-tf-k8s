#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${SMOKE_BASE_URL:-http://127.0.0.1}"
# Defaults to localhost for local runs; CI overrides this via SMOKE_BASE_URL.

echo "Running smoke tests..."

echo "[1/3] Testing /app1"
curl -fsS "${BASE_URL}/app1" > /tmp/app1-response.json
cat /tmp/app1-response.json

echo
echo "[2/3] Testing /app2"
curl -fsS "${BASE_URL}/app2" > /tmp/app2-response.json
cat /tmp/app2-response.json

echo
echo "[3/3] Testing /podinfo"
curl -fsS "${BASE_URL}/podinfo" > /tmp/podinfo-response.json
cat /tmp/podinfo-response.json

echo
echo "Smoke tests passed."