#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${SMOKE_BASE_URL:-http://127.0.0.1}"
# Defaults to localhost for local runs; CI overrides this via SMOKE_BASE_URL.

# Generic JSON contract helper used by endpoint-specific checks.
require_json_keys() {
  local file="$1"
  shift
  python3 - "$file" "$@" <<'PY'
import json
import sys

path = sys.argv[1]
keys = sys.argv[2:]

with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

missing = [k for k in keys if k not in data]
if missing:
    print(f"Missing required keys in {path}: {', '.join(missing)}", file=sys.stderr)
    sys.exit(1)
PY
}

check_flask_endpoint() {
  local name="$1"
  local url="$2"
  local out="/tmp/${name}-response.json"

  echo "Testing ${url}"
  curl -fsS "${url}" > "${out}"
  cat "${out}"
  # Homework contract for custom apps: must expose identity fields.
  require_json_keys "${out}" app_name pod_name pod_ip
}

check_podinfo_endpoint() {
  local url="$1"
  local out="/tmp/podinfo-response.json"

  echo "Testing ${url}"
  curl -fsS "${url}" > "${out}"
  cat "${out}"

  # Podinfo has a different runtime schema than the Flask app.
  # Validate JSON and require identity-ish fields expected from podinfo.
  python3 - "${out}" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

if "hostname" not in data and "pod_name" not in data:
    print("Podinfo response missing expected identity field (hostname or pod_name).", file=sys.stderr)
    sys.exit(1)
PY
}

echo "Running smoke tests..."

# Verify both custom Flask routes satisfy the required response contract.
echo "[1/3] Testing /app1"
check_flask_endpoint "app1" "${BASE_URL}/app1"

echo
echo "[2/3] Testing /app2"
check_flask_endpoint "app2" "${BASE_URL}/app2"

echo
# Verify podinfo is reachable and returns pod identity in its native schema.
echo "[3/3] Testing /podinfo"
check_podinfo_endpoint "${BASE_URL}/podinfo"

echo
echo "Smoke tests passed."