#!/usr/bin/env bash
# Generate local MCP configs from live CE app URL (gitignored — never commit).
# Resolves CE_ENDPOINT via ibmcloud; do not hardcode URLs in repo templates.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="${APP_NAME:-quantum-mcp-remote}"
OUT_DIR="${SCRIPT_DIR}/mcp-configs/deployed"

CE_ENDPOINT="$(ibmcloud ce app get --name "${APP_NAME}" --output json 2>/dev/null \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['status']['url'])")"

if [ -z "${CE_ENDPOINT}" ]; then
  echo "ERROR: Could not resolve CE_ENDPOINT for app ${APP_NAME}" >&2
  exit 1
fi

SSE_URL="${CE_ENDPOINT}/sse"
mkdir -p "${OUT_DIR}"

cat > "${OUT_DIR}/CE_ENDPOINT.txt" <<EOF
# Resolved $(date -u +"%Y-%m-%dT%H:%M:%SZ")
${CE_ENDPOINT}
EOF

cat > "${OUT_DIR}/vscode-mcp.json" <<EOF
{
  "servers": {
    "quantum-openqasm-mcp-remote": {
      "type": "sse",
      "url": "${SSE_URL}"
    }
  }
}
EOF

cat > "${OUT_DIR}/cursor-mcp.json" <<EOF
{
  "mcpServers": {
    "quantum-openqasm-mcp-remote": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "${SSE_URL}"]
    }
  }
}
EOF

cat > "${OUT_DIR}/cursor-mcp-proxy.json" <<EOF
{
  "mcpServers": {
    "quantum-openqasm-mcp-remote": {
      "command": "uvx",
      "args": ["mcp-proxy", "${SSE_URL}"]
    }
  }
}
EOF

echo ""
echo "Generated local configs (gitignored — do not commit):"
echo "  CE_ENDPOINT=${CE_ENDPOINT}"
echo "  ${OUT_DIR}/CE_ENDPOINT.txt"
echo "  ${OUT_DIR}/vscode-mcp.json      → copy to VS Code mcp.json"
echo "  ${OUT_DIR}/cursor-mcp.json        → copy to ~/.cursor/mcp.json"
echo "  ${OUT_DIR}/cursor-mcp-proxy.json"
echo ""
echo "Verify (works from any directory):"
echo "  ${SCRIPT_DIR}/check-remote-health.sh"
echo ""
echo "Or use templates in mcp-configs/*.json and replace <CE_ENDPOINT> manually."
