#!/usr/bin/env bash
# =============================================================================
# setup-remote-mcp.sh — Resolve CE endpoint, write mcp.json, verify connection
#
# Usage:
#   ./setup-remote-mcp.sh                    # interactive IDE picker
#   ./setup-remote-mcp.sh --ide cursor,vscode
#   ./setup-remote-mcp.sh --ide all --workspace
#   ./setup-remote-mcp.sh --check-only       # health check only
#   ./setup-remote-mcp.sh --dry-run --ide cursor
#
# Requires: ibmcloud (logged in), curl, python3
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
APP_NAME="${APP_NAME:-quantum-mcp-remote}"
OUT_DIR="${SCRIPT_DIR}/mcp-configs/deployed"

IDE=""
WORKSPACE=false
USE_PROXY=false
DRY_RUN=false
CHECK_ONLY=false
SKIP_HEALTH=false

log()  { echo "[setup] $*"; }
fail() { echo "[setup] ERROR: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Quantum OpenQASM — remote MCP IDE setup

  ./setup-remote-mcp.sh [options]

Options:
  --ide IDE         cursor | vscode | bob | antigravity | claude | all
                    (comma-separated, e.g. cursor,vscode)
  --workspace       Also write .vscode/mcp.json in repo root
  --proxy           Cursor: use uvx mcp-proxy (if npx mcp-remote times out)
  --check-only      Skip mcp.json install; run connection check only
  --skip-health     Install configs but skip /health and /test/api/run
  --dry-run         Show actions without writing files
  -h, --help        This help

Examples:
  ./setup-remote-mcp.sh --ide cursor,vscode --workspace
  ./setup-remote-mcp.sh --check-only

Docs: docs/ide/REMOTE-MCP-SETUP.md · deployments/code-engine/IDE-SETUP.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide) IDE="${2:-}"; shift 2 ;;
    --workspace) WORKSPACE=true; shift ;;
    --proxy) USE_PROXY=true; shift ;;
    --check-only) CHECK_ONLY=true; shift ;;
    --skip-health) SKIP_HEALTH=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1 (use --help)" ;;
  esac
done

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

require_cmd curl
require_cmd python3

resolve_endpoint() {
  if [[ -f "${OUT_DIR}/CE_ENDPOINT.txt" ]]; then
    CE_ENDPOINT="$(grep -v '^#' "${OUT_DIR}/CE_ENDPOINT.txt" | tail -1 | tr -d '[:space:]')"
  fi
  if [[ -z "${CE_ENDPOINT:-}" ]]; then
    require_cmd ibmcloud
    CE_ENDPOINT="$(ibmcloud ce app get --name "${APP_NAME}" --output json 2>/dev/null \
      | python3 -c "import sys,json; print(json.load(sys.stdin)['status']['url'])")" || true
  fi
  [[ -n "${CE_ENDPOINT:-}" ]] || fail "Could not resolve CE_ENDPOINT for app '${APP_NAME}'. Deploy first or run: ibmcloud login"
  export CE_ENDPOINT
  log "CE_ENDPOINT=${CE_ENDPOINT}"
}

generate_configs() {
  if [[ "${DRY_RUN}" == true ]]; then
    log "[dry-run] would run generate-mcp-configs.sh"
    return
  fi
  "${SCRIPT_DIR}/generate-mcp-configs.sh" >/dev/null
  log "Generated configs in ${OUT_DIR}/"
}

vscode_user_mcp() {
  case "$(uname -s)" in
    Darwin) echo "${HOME}/Library/Application Support/Code/User/mcp.json" ;;
    Linux)  echo "${HOME}/.config/Code/User/mcp.json" ;;
    MINGW*|MSYS*|CYGWIN*) echo "${APPDATA:-${HOME}/AppData/Roaming}/Code/User/mcp.json" ;;
    *) echo "${HOME}/.config/Code/User/mcp.json" ;;
  esac
}

claude_config() {
  case "$(uname -s)" in
    Darwin) echo "${HOME}/Library/Application Support/Claude/claude_desktop_config.json" ;;
    *) echo "${HOME}/.config/Claude/claude_desktop_config.json" ;;
  esac
}

merge_json_file() {
  local target="$1"
  local fragment_file="$2"
  local top_key="$3"
  python3 - "$target" "$fragment_file" "$top_key" "${DRY_RUN}" <<'PY'
import json, shutil, sys
from datetime import datetime, timezone
from pathlib import Path

target = Path(sys.argv[1])
fragment = json.loads(Path(sys.argv[2]).read_text())
top_key = sys.argv[3]
dry_run = sys.argv[4] == "true"

existing = {}
if target.exists():
    try:
        existing = json.loads(target.read_text())
    except json.JSONDecodeError as e:
        print(f"WARN: {target} is not valid JSON: {e}", file=sys.stderr)
        sys.exit(1)

merged = dict(existing)
merged.setdefault(top_key, {})
if not isinstance(merged[top_key], dict):
    print(f"WARN: {target} key '{top_key}' is not an object", file=sys.stderr)
    sys.exit(1)
merged[top_key].update(fragment[top_key])

if dry_run:
    print(f"[dry-run] would write {target}")
    print(json.dumps(merged, indent=2))
    sys.exit(0)

target.parent.mkdir(parents=True, exist_ok=True)
if target.exists():
    ts = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    backup = target.with_name(target.name + f".bak.{ts}")
    shutil.copy2(target, backup)
    print(f"Backup: {backup}")

target.write_text(json.dumps(merged, indent=2) + "\n")
print(f"Updated: {target}")
PY
}

install_cursor() {
  local src="${OUT_DIR}/cursor-mcp-proxy.json"
  [[ "${USE_PROXY}" != true ]] && src="${OUT_DIR}/cursor-mcp.json"
  merge_json_file "${HOME}/.cursor/mcp.json" "$src" "mcpServers"
}

install_vscode() {
  merge_json_file "$(vscode_user_mcp)" "${OUT_DIR}/vscode-mcp.json" "servers"
}

install_bob() {
  local src="${OUT_DIR}/cursor-mcp.json"
  merge_json_file "${HOME}/.bob/mcp.json" "$src" "mcpServers" || true
  merge_json_file "${HOME}/.bob/mcp_settings.json" "$src" "mcpServers" || true
}

install_antigravity() {
  local src="${OUT_DIR}/cursor-mcp.json"
  merge_json_file "${HOME}/.gemini/antigravity/mcp_config.json" "$src" "mcpServers" || true
  merge_json_file "${HOME}/.gemini/config/mcp_config.json" "$src" "mcpServers" || true
}

install_claude() {
  merge_json_file "$(claude_config)" "${OUT_DIR}/cursor-mcp.json" "mcpServers"
}

install_workspace() {
  merge_json_file "${REPO_ROOT}/.vscode/mcp.json" "${OUT_DIR}/vscode-mcp.json" "servers"
}

run_health() {
  if [[ "${SKIP_HEALTH}" == true ]]; then
    log "Skipping health check (--skip-health)"
    return
  fi
  log "Running connection check..."
  if [[ "${DRY_RUN}" == true ]]; then
    log "[dry-run] would run check-remote-health.sh"
    return
  fi
  "${SCRIPT_DIR}/check-remote-health.sh"
}

pick_ides_interactive() {
  echo ""
  echo "Which IDEs should receive quantum-openqasm-mcp-remote?"
  echo "  1) Cursor"
  echo "  2) VS Code (user mcp.json)"
  echo "  3) IBM Bob"
  echo "  4) Antigravity"
  echo "  5) Claude Desktop"
  echo "  6) All of the above"
  echo "  7) Check connection only (no mcp.json)"
  read -r -p "Choice [1-7] (default 6): " choice
  choice="${choice:-6}"
  case "$choice" in
    1) IDE="cursor" ;;
    2) IDE="vscode" ;;
    3) IDE="bob" ;;
    4) IDE="antigravity" ;;
    5) IDE="claude" ;;
    6) IDE="all" ;;
    7) CHECK_ONLY=true; return ;;
    *) fail "Invalid choice: $choice" ;;
  esac
  read -r -p "Also install workspace .vscode/mcp.json? [y/N]: " ws
  ws="$(echo "$ws" | tr '[:upper:]' '[:lower:]')"
  [[ "$ws" == "y" || "$ws" == "yes" ]] && WORKSPACE=true
  if [[ "$IDE" == *"cursor"* || "$IDE" == "all" ]]; then
    read -r -p "Cursor: use uvx mcp-proxy instead of npx mcp-remote? [y/N]: " px
    px="$(echo "$px" | tr '[:upper:]' '[:lower:]')"
    [[ "$px" == "y" || "$px" == "yes" ]] && USE_PROXY=true
  fi
}

install_for_ide() {
  local id
  for id in $(echo "$1" | tr ',' ' '); do
    case "$id" in
      cursor)      log "Installing Cursor ~/.cursor/mcp.json"; install_cursor ;;
      vscode)      log "Installing VS Code user mcp.json"; install_vscode ;;
      bob)         log "Installing IBM Bob mcp config"; install_bob ;;
      antigravity) log "Installing Antigravity mcp config"; install_antigravity ;;
      claude)      log "Installing Claude Desktop config"; install_claude ;;
      all)
        install_for_ide "cursor,vscode,bob,antigravity,claude"
        return
        ;;
      *) fail "Unknown IDE: $id" ;;
    esac
  done
}

main() {
  log "Quantum OpenQASM — remote MCP IDE setup"
  [[ -n "$IDE" ]] || pick_ides_interactive

  resolve_endpoint

  if [[ "${CHECK_ONLY}" == true ]]; then
    run_health
    exit 0
  fi

  generate_configs
  [[ -n "$IDE" ]] && install_for_ide "$IDE"
  [[ "${WORKSPACE}" == true ]] && { log "Installing workspace .vscode/mcp.json"; install_workspace; }
  run_health

  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  Remote MCP setup complete"
  echo ""
  echo "  CE_ENDPOINT=${CE_ENDPOINT}"
  echo "  SSE URL:      ${CE_ENDPOINT}/sse"
  echo "  Dashboard:    ${CE_ENDPOINT}/"
  echo ""
  echo "  Next steps:"
  echo "    1. Reload your IDE (MCP: List Servers / restart)"
  echo "    2. Enable quantum-openqasm-mcp-remote (expect 10 tools)"
  echo "    3. Test: ask agent to list_backends or check_credentials"
  echo ""
  echo "  Extension remote mode:"
  echo "    quantumAssistant.mcpMode = remote"
  echo "    quantumAssistant.remoteMcpUrl = ${CE_ENDPOINT}/sse"
  echo "════════════════════════════════════════════════════════"
}

main
