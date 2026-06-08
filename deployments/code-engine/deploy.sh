#!/usr/bin/env bash
# Deploy Quantum OpenQASM MCP to IBM Code Engine (wrapper)
# See deploy-ibmcloud.sh for full pipeline with dashboard UI.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$SCRIPT_DIR/deploy-ibmcloud.sh" "$@"
