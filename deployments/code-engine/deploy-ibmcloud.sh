#!/usr/bin/env bash
# =============================================================================
# deploy-ibmcloud.sh — Deploy Quantum OpenQASM MCP to IBM Code Engine
#
# Author:  Markus van Kempen <markus.van.kempen@gmail.com> | <mvk@ca.ibm.com>
# Website: https://markusvankempen.github.io/
# Pattern: code-engine-mcp-server bridge + dashboard UI
#
# Usage:
#   IBMCLOUD_API_KEY=your_ibm_cloud_api_key \
#   IBM_API_KEY=your_quantum_api_key \
#   IBM_SERVICE_CRN=crn:v1:... \
#   ./deploy-ibmcloud.sh
#
# Optional:
#   IBM_QUANTUM_ENDPOINT=https://us-east.quantum-computing.cloud.ibm.com
#   IBM_QUANTUM_BACKEND=ibm_fez
#   QUANTUM_MCP_NPM_VERSION=1.7.2
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_CONTEXT="${BUILD_CONTEXT:-$SCRIPT_DIR}"

: "${IBMCLOUD_API_KEY:?'ERROR: IBMCLOUD_API_KEY must be set'}"
: "${IBM_API_KEY:?'ERROR: IBM_API_KEY must be set'}"
: "${IBM_SERVICE_CRN:?'ERROR: IBM_SERVICE_CRN must be set'}"

IBMCLOUD_REGION="${IBMCLOUD_REGION:-us-south}"
RESOURCE_GROUP="${RESOURCE_GROUP:-Default}"
CE_REGION="${CE_REGION:-ca-tor}"
CE_PROJECT="${CE_PROJECT:-markus-app-v2-toronto}"
APP_NAME="${APP_NAME:-quantum-mcp-remote}"
ICR_HOST="${ICR_HOST:-us.icr.io}"
ICR_NAMESPACE="${ICR_NAMESPACE:-mvk-code-engine}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
IMAGE_SECRET="${IMAGE_SECRET:-icr-pull-secret}"
APP_PORT="${APP_PORT:-8080}"
SCALE_MIN="${SCALE_MIN:-0}"
SCALE_MAX="${SCALE_MAX:-5}"
CPU_LIMIT="${CPU_LIMIT:-0.5}"
MEMORY_LIMIT="${MEMORY_LIMIT:-1G}"
QUANTUM_SECRET="${QUANTUM_SECRET:-quantum-api-key}"
ADMIN_SECRET_NAME="${ADMIN_SECRET_NAME:-bridge-admin-secret}"
BRIDGE_ADMIN_SECRET="${BRIDGE_ADMIN_SECRET:-$(openssl rand -hex 24 2>/dev/null || python3 -c 'import secrets; print(secrets.token_hex(24))')}"
IBM_QUANTUM_ENDPOINT="${IBM_QUANTUM_ENDPOINT:-https://us-east.quantum-computing.cloud.ibm.com}"
IBM_QUANTUM_BACKEND="${IBM_QUANTUM_BACKEND:-ibm_fez}"

IMAGE="${ICR_HOST}/${ICR_NAMESPACE}/${APP_NAME}:${IMAGE_TAG}"
DOCKERFILE="${DOCKERFILE:-$SCRIPT_DIR/Dockerfile}"
QUANTUM_MCP_NPM_VERSION="${QUANTUM_MCP_NPM_VERSION:-latest}"

log()  { echo "[$(date '+%H:%M:%S')] $*"; }
fail() { echo "[ERROR] $*" >&2; exit 1; }

if command -v docker >/dev/null 2>&1; then
  CONTAINER_RUNTIME="docker"
elif command -v podman >/dev/null 2>&1; then
  CONTAINER_RUNTIME="podman"
else
  fail "Neither Docker nor Podman found"
fi

log "=== Quantum OpenQASM MCP → IBM Code Engine ==="
log "Project:  ${CE_PROJECT} (${CE_REGION})"
log "App:      ${APP_NAME}"
log "Image:    ${IMAGE}"
log "Backend:  ${IBM_QUANTUM_BACKEND}"
log "Endpoint: ${IBM_QUANTUM_ENDPOINT}"

log "Step 1/9 — IBM Cloud login..."
ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${IBMCLOUD_REGION}" -q 2>/dev/null || \
  ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${IBMCLOUD_REGION}"
ibmcloud target -g "${RESOURCE_GROUP}" -q

if [ "${CONTAINER_RUNTIME}" = "podman" ] && ! podman info >/dev/null 2>&1; then
  log "Starting Podman machine..."
  podman machine start
fi

log "Step 2/9 — ICR login..."
ibmcloud cr login --client "${CONTAINER_RUNTIME}"

log "Step 3/9 — Building image (linux/amd64)..."
"${CONTAINER_RUNTIME}" build \
  --platform linux/amd64 \
  --build-arg "QUANTUM_MCP_NPM_VERSION=${QUANTUM_MCP_NPM_VERSION}" \
  -f "${DOCKERFILE}" \
  -t "${IMAGE}" \
  "${BUILD_CONTEXT}"

log "Step 4/9 — Pushing image..."
"${CONTAINER_RUNTIME}" push "${IMAGE}"

log "Step 5/9 — Targeting Code Engine project (${CE_REGION})..."
ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${CE_REGION}" -q 2>/dev/null || \
  ibmcloud login --apikey "${IBMCLOUD_API_KEY}" -r "${CE_REGION}"
ibmcloud target -g "${RESOURCE_GROUP}" -q
ibmcloud ce project select --name "${CE_PROJECT}"

log "Step 6/9 — Ensuring ICR pull secret..."
if ibmcloud ce secret get --name "${IMAGE_SECRET}" >/dev/null 2>&1; then
  ibmcloud ce secret delete --name "${IMAGE_SECRET}" --force
fi
ibmcloud ce secret create \
  --name "${IMAGE_SECRET}" \
  --format registry \
  --server "${ICR_HOST}" \
  --username iamapikey \
  --password "${IBMCLOUD_API_KEY}" \
  --email unused@example.com

log "Step 7/9 — Ensuring IBM API key secret..."
if ibmcloud ce secret get --name "${QUANTUM_SECRET}" >/dev/null 2>&1; then
  ibmcloud ce secret delete --name "${QUANTUM_SECRET}" --force
fi
ibmcloud ce secret create \
  --name "${QUANTUM_SECRET}" \
  --format generic \
  --from-literal "IBM_API_KEY=${IBM_API_KEY}"

log "Step 7b/9 — Ensuring bridge admin secret..."
if ibmcloud ce secret get --name "${ADMIN_SECRET_NAME}" >/dev/null 2>&1; then
  ibmcloud ce secret delete --name "${ADMIN_SECRET_NAME}" --force
fi
ibmcloud ce secret create \
  --name "${ADMIN_SECRET_NAME}" \
  --format generic \
  --from-literal "BRIDGE_ADMIN_SECRET=${BRIDGE_ADMIN_SECRET}"

DEPLOY_TIME="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
CE_PROJECT_ID="$(ibmcloud ce project get --name "${CE_PROJECT}" --output json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('metadata',{}).get('uid','n/a'))" 2>/dev/null || echo "n/a")"

APP_FLAGS=(
  --name "${APP_NAME}"
  --image "${IMAGE}"
  --registry-secret "${IMAGE_SECRET}"
  --port "${APP_PORT}"
  --min-scale "${SCALE_MIN}"
  --max-scale "${SCALE_MAX}"
  --cpu "${CPU_LIMIT}"
  --memory "${MEMORY_LIMIT}"
  --env "IBM_SERVICE_CRN=${IBM_SERVICE_CRN}"
  --env "IBM_QUANTUM_ENDPOINT=${IBM_QUANTUM_ENDPOINT}"
  --env "IBM_QUANTUM_BACKEND=${IBM_QUANTUM_BACKEND}"
  --env-from-secret "${QUANTUM_SECRET}"
  --env-from-secret "${ADMIN_SECRET_NAME}"
  --env "CE_REGION=${CE_REGION}"
  --env "CE_PROJECT_ID=${CE_PROJECT_ID}"
  --env "CE_APP=${APP_NAME}"
  --env "BRIDGE_DEPLOY_TIME=${DEPLOY_TIME}"
)

log "Step 8/9 — Deploying application..."
if ibmcloud ce app get --name "${APP_NAME}" >/dev/null 2>&1; then
  ibmcloud ce app update "${APP_FLAGS[@]}"
else
  ibmcloud ce app create "${APP_FLAGS[@]}"
fi

log "Step 9/9 — Waiting for ready (up to 3 min)..."
timeout=180
elapsed=0
while [ "${elapsed}" -lt "${timeout}" ]; do
  ready=$(ibmcloud ce app get --name "${APP_NAME}" --output json 2>/dev/null | python3 -c "
import sys, json
d = json.load(sys.stdin)
for c in d.get('status', {}).get('conditions', []):
    if c.get('type') == 'Ready' and c.get('status') == 'True':
        print('True')
        sys.exit(0)
print('False')
" 2>/dev/null || echo "False")
  if [ "${ready}" = "True" ]; then
    log "Application is Ready!"
    break
  fi
  sleep 10
  elapsed=$((elapsed + 10))
  log "  waiting... (${elapsed}s)"
done

endpoint=$(ibmcloud ce app get --name "${APP_NAME}" --output json 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('status',{}).get('url',''))" 2>/dev/null || echo "")

echo ""
echo "════════════════════════════════════════════════════════"
echo "  Quantum OpenQASM MCP deployed!"
echo ""
echo "  Dashboard:  ${endpoint}/"
echo "  SSE URL:    ${endpoint}/sse"
echo "  Health:     ${endpoint}/health"
echo "  Stats:      ${endpoint}/stats"
echo "  Test UI:    ${endpoint}/test"
echo "  Admin:      ${endpoint}/admin"
echo ""
echo "  CE_ENDPOINT (export for scripts/docs — URL is project-specific):"
echo "  export CE_ENDPOINT=${endpoint}"
echo ""
echo "  BRIDGE_ADMIN_SECRET (save this — shown once per deploy):"
echo "  ${BRIDGE_ADMIN_SECRET}"
echo ""
echo "  MCP client configs (local only — do not commit URLs to git):"
echo "    ./generate-mcp-configs.sh"
echo "  Or copy mcp-configs/vscode-remote.json and set url to: \${CE_ENDPOINT}/sse"
echo ""
echo "  Extension settings:"
echo "    quantumAssistant.mcpMode = remote"
echo "    quantumAssistant.remoteMcpUrl = \${CE_ENDPOINT}/sse"
echo "════════════════════════════════════════════════════════"
