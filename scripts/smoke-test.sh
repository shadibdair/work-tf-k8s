#!/usr/bin/env bash
set -euo pipefail

echo "Running smoke tests..."

echo "[1/3] Testing /app1"
curl -fsS http://127.0.0.1/app1 > /tmp/app1-response.json
cat /tmp/app1-response.json

echo
echo "[2/3] Testing /app2"
curl -fsS http://127.0.0.1/app2 > /tmp/app2-response.json
cat /tmp/app2-response.json

echo
echo "[3/3] Testing /podinfo"
curl -fsS http://127.0.0.1/podinfo > /tmp/podinfo-response.json
cat /tmp/podinfo-response.json

echo
echo "Smoke tests passed."