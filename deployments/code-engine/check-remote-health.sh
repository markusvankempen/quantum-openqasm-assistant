#!/usr/bin/env bash
# Health check for remote Quantum MCP — works from any cwd.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="${APP_NAME:-quantum-mcp-remote}"
ENDPOINT_FILE="${SCRIPT_DIR}/mcp-configs/deployed/CE_ENDPOINT.txt"

if [ -f "${ENDPOINT_FILE}" ]; then
  CE_ENDPOINT="$(grep -v '^#' "${ENDPOINT_FILE}" | tail -1 | tr -d '[:space:]')"
fi

if [ -z "${CE_ENDPOINT:-}" ]; then
  CE_ENDPOINT="$(ibmcloud ce app get --name "${APP_NAME}" --output json 2>/dev/null \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['status']['url'])")"
fi

if [ -z "${CE_ENDPOINT}" ]; then
  echo "ERROR: Could not resolve CE_ENDPOINT. Run ./generate-mcp-configs.sh first." >&2
  exit 1
fi

echo "CE_ENDPOINT=${CE_ENDPOINT}"
echo ""
echo "=== /health ==="
curl -sS "${CE_ENDPOINT}/health" | python3 -m json.tool
echo ""
echo "=== /test/api/run (summary) ==="
curl -sS -X POST "${CE_ENDPOINT}/test/api/run" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print('ok:', d.get('ok'))
for s in d.get('steps', []):
    print(f\"  {'✓' if s.get('ok') else '✗'} {s.get('name')}\")
"
