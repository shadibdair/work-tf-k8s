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

validate_endpoint_contract() {
  local url="$1"
  local out="$2"

  # Validate JSON identity contract required by the homework:
  # Every application must return at least:
  # - pod_name
  # - pod_ip
  python3 - "${out}" <<'PY'
import json
import sys

path = sys.argv[1]
with open(path, "r", encoding="utf-8") as f:
    data = json.load(f)

required = ["pod_name", "pod_ip"]
missing = [k for k in required if k not in data]
if missing:
    print(f"Response missing required keys: {', '.join(missing)}", file=sys.stderr)
    sys.exit(1)
PY

  echo "Validated contract for ${url}"
}

split_words() {
  # Split a whitespace-separated string into bash words safely.
  # Usage: split_words "$VAR" ; then read words from "$@".
  printf "%s" "$1" | tr -s '[:space:]' ' '
}

echo "Running smoke tests..."

SMOKE_URLS="${SMOKE_URLS:-}"
SMOKE_PATHS="${SMOKE_PATHS:-}"

declare -a urls=()

if [[ -n "${SMOKE_URLS}" ]]; then
  # Caller provided explicit URLs.
  for u in $(split_words "${SMOKE_URLS}"); do
    urls+=("${u}")
  done
elif [[ -n "${SMOKE_PATHS}" ]]; then
  # Caller provided ingress paths (e.g. "/app1 /podinfo").
  for p in $(split_words "${SMOKE_PATHS}"); do
    urls+=("${BASE_URL}${p}")
  done
else
  # Backward-compatible default for older setups.
  urls+=("${BASE_URL}/app1" "${BASE_URL}/app2" "${BASE_URL}/podinfo")
fi

idx=1
total="${#urls[@]}"
for url in "${urls[@]}"; do
  out="/tmp/smoke-$(echo "${url}" | sed 's#[/:]#_#g').json"
  echo "[${idx}/${total}] Testing ${url}"
  curl -fsS "${url}" > "${out}"
  cat "${out}"
  validate_endpoint_contract "${url}" "${out}"
  echo
  idx=$((idx + 1))
done

echo "Smoke tests passed."