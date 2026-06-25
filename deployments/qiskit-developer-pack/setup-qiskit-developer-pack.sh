#!/usr/bin/env bash
# =============================================================================
# setup-qiskit-developer-pack.sh — Merge Qiskit MCP + quantum-openqasm-mcp into IDEs
#
# Bundles official Qiskit MCP servers with Quantum OpenQASM Assistant:
#   core: qiskit-docs, qiskit, quantum-openqasm-mcp
#   full: + qiskit-ibm-runtime (needs QISKIT_IBM_TOKEN)
#
# Usage:
#   ./setup-qiskit-developer-pack.sh
#   ./setup-qiskit-developer-pack.sh --tier full --ide cursor,vscode
#   QISKIT_IBM_TOKEN=xxx ./setup-qiskit-developer-pack.sh --tier full
#
# Requires: python3, curl; uv/uvx recommended (pip install uv)
# Docs: docs/ide/QISKIT-DEVELOPER-PACK.md
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
CONFIG_DIR="${SCRIPT_DIR}/mcp-configs"
OUT_DIR="${CONFIG_DIR}/deployed"

TIER="core"
IDE=""
WORKSPACE=false
DRY_RUN=false
SKIP_CHECKS=false
INSTALL_PYTHON_DEPS=false
AUTO_YES=false

QISKIT_VENV="${QISKIT_VENV:-${HOME}/.quantum-openqasm-mcp/qiskit-venv}"
QISKIT_PYTHON="${QISKIT_VENV}/bin/python"

log()  { echo "[qiskit-pack] $*"; }
fail() { echo "[qiskit-pack] ERROR: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Qiskit Developer Pack — MCP bundle setup

  ./setup-qiskit-developer-pack.sh [options]

Options:
  --tier TIER       core (default) | full
                    core = qiskit-docs + qiskit + quantum-openqasm-mcp
                    full = core + qiskit-ibm-runtime
  --ide IDE         cursor | vscode | bob | antigravity | claude | all
                    (comma-separated)
  --workspace       Also merge into repo .vscode/mcp.json
  --dry-run         Print merged JSON without writing
  --skip-checks     Skip uvx/npx prerequisite checks
  --install-python-deps
                    Install qiskit + qiskit-ibm-runtime (no prompt)
  --yes             Auto-confirm install prompts
  -h, --help        This help

Python (transpile / export scripts):
  Optional venv: ~/.quantum-openqasm-mcp/qiskit-venv
  Packages: qiskit, qiskit-ibm-runtime
  Example: examples/qiskit-bell-transpile-export.py

Credentials:
  quantum-openqasm-mcp  → ~/.quantum-openqasm-mcp/.env (IBM_API_KEY, IBM_SERVICE_CRN)
  qiskit-ibm-runtime    → QISKIT_IBM_TOKEN env var or edit mcp.json after install

Examples:
  ./setup-qiskit-developer-pack.sh --ide cursor
  QISKIT_IBM_TOKEN=... ./setup-qiskit-developer-pack.sh --tier full --ide all

Docs: docs/ide/QISKIT-DEVELOPER-PACK.md
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --tier) TIER="${2:-}"; shift 2 ;;
    --ide) IDE="${2:-}"; shift 2 ;;
    --workspace) WORKSPACE=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    --skip-checks) SKIP_CHECKS=true; shift ;;
    --install-python-deps) INSTALL_PYTHON_DEPS=true; shift ;;
    --yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown option: $1 (use --help)" ;;
  esac
done

[[ "$TIER" == "core" || "$TIER" == "full" ]] || fail "--tier must be core or full"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || fail "Missing required command: $1"
}

require_cmd python3

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

generate_deployed_configs() {
  mkdir -p "${OUT_DIR}"
  local cursor_src="${CONFIG_DIR}/cursor-developer-pack-${TIER}.json"
  local vscode_src="${CONFIG_DIR}/vscode-developer-pack-${TIER}.json"
  [[ -f "$cursor_src" ]] || fail "Missing template: $cursor_src"
  [[ -f "$vscode_src" ]] || fail "Missing template: $vscode_src"

  if [[ -n "${QISKIT_IBM_TOKEN:-}" && "$TIER" == "full" ]]; then
    python3 - "$cursor_src" "${OUT_DIR}/cursor-developer-pack.json" "$vscode_src" "${OUT_DIR}/vscode-developer-pack.json" <<'PY'
import json, sys
from pathlib import Path

token = __import__("os").environ["QISKIT_IBM_TOKEN"]
cursor_src, cursor_out, vscode_src, vscode_out = sys.argv[1:5]

for src, out, key in [
    (cursor_src, cursor_out, "mcpServers"),
    (vscode_src, vscode_out, "servers"),
]:
    data = json.loads(Path(src).read_text())
    entry = data[key].get("qiskit-ibm-runtime")
    if entry and "env" in entry:
        entry["env"]["QISKIT_IBM_TOKEN"] = token
    Path(out).write_text(json.dumps(data, indent=2) + "\n")
    print(f"Generated (token injected): {out}")
PY
  else
    cp "$cursor_src" "${OUT_DIR}/cursor-developer-pack.json"
    cp "$vscode_src" "${OUT_DIR}/vscode-developer-pack.json"
    log "Generated ${OUT_DIR}/cursor-developer-pack.json"
    log "Generated ${OUT_DIR}/vscode-developer-pack.json"
    if [[ "$TIER" == "full" && -z "${QISKIT_IBM_TOKEN:-}" ]]; then
      log "WARN: full tier — set QISKIT_IBM_TOKEN before run, or edit qiskit-ibm-runtime env in mcp.json"
    fi
  fi
}

check_mcp_prerequisites() {
  if ! command -v uvx >/dev/null 2>&1; then
    log "WARN: uvx not found — Qiskit MCP servers use 'uvx'. Install: https://docs.astral.sh/uv/"
    log "      Alternative: pip install qiskit-mcp-servers && use module commands in mcp.json"
  fi
  if ! command -v npx >/dev/null 2>&1; then
    log "WARN: npx not found — needed for quantum-openqasm-mcp"
  fi
  if [[ ! -f "${HOME}/.quantum-openqasm-mcp/.env" ]]; then
    log "WARN: ~/.quantum-openqasm-mcp/.env not found — create before using quantum-openqasm-mcp"
    log "      Run: npx @markusvankempen/quantum-openqasm-mcp --setup"
  fi
}

check_prerequisites() {
  [[ "${SKIP_CHECKS}" == true ]] || check_mcp_prerequisites
  check_python_qiskit_stack || prompt_install_python_deps
}

python_has_qiskit_stack() {
  local py="$1"
  [[ -x "$py" ]] || return 1
  "$py" -c "import qiskit; import qiskit_ibm_runtime" >/dev/null 2>&1
}

check_python_qiskit_stack() {
  if python_has_qiskit_stack "${QISKIT_PYTHON}"; then
    log "Python Qiskit stack: OK (${QISKIT_VENV})"
    report_python_versions "${QISKIT_PYTHON}"
    return 0
  fi
  if python3 -c "import qiskit; import qiskit_ibm_runtime" >/dev/null 2>&1; then
    log "Python Qiskit stack: OK (system python3)"
    report_python_versions "python3"
    return 0
  fi
  log "WARN: qiskit + qiskit-ibm-runtime not found (needed to transpile Qiskit → OpenQASM for IBM hardware)"
  return 1
}

report_python_versions() {
  local py="$1"
  "$py" -c "import qiskit, qiskit_ibm_runtime; print(f'  qiskit {qiskit.__version__}, qiskit-ibm-runtime {qiskit_ibm_runtime.__version__}')" 2>/dev/null || true
}

prompt_install_python_deps() {
  if [[ "${INSTALL_PYTHON_DEPS}" == true ]]; then
    install_python_qiskit_stack
    return
  fi
  if [[ "${AUTO_YES}" == true ]]; then
    install_python_qiskit_stack
    return
  fi
  echo ""
  echo "Install qiskit + qiskit-ibm-runtime for transpile/export scripts?"
  echo "  Venv: ${QISKIT_VENV}"
  read -r -p "Install now? [y/N]: " answer
  answer="$(echo "${answer:-n}" | tr '[:upper:]' '[:lower:]')"
  if [[ "$answer" == "y" || "$answer" == "yes" ]]; then
    install_python_qiskit_stack
  else
    log "Skipped Python install — run with --install-python-deps or: pip install qiskit qiskit-ibm-runtime"
  fi
}

install_python_qiskit_stack() {
  if [[ "${DRY_RUN}" == true ]]; then
    log "[dry-run] would create venv at ${QISKIT_VENV} and install qiskit qiskit-ibm-runtime"
    return
  fi
  log "Installing qiskit + qiskit-ibm-runtime into ${QISKIT_VENV} ..."
  if command -v uv >/dev/null 2>&1; then
    uv venv "${QISKIT_VENV}" --quiet
    uv pip install --python "${QISKIT_PYTHON}" qiskit qiskit-ibm-runtime -q
  else
    python3 -m venv "${QISKIT_VENV}"
    "${QISKIT_PYTHON}" -m pip install -U pip -q
    "${QISKIT_PYTHON}" -m pip install qiskit qiskit-ibm-runtime -q
  fi
  if python_has_qiskit_stack "${QISKIT_PYTHON}"; then
    log "Python Qiskit stack installed."
    report_python_versions "${QISKIT_PYTHON}"
    echo ""
    echo "  Run export example:"
    echo "    ${QISKIT_PYTHON} examples/qiskit-bell-transpile-export.py"
  else
    fail "Install failed — could not import qiskit_ibm_runtime in ${QISKIT_VENV}"
  fi
}

install_cursor() {
  merge_json_file "${HOME}/.cursor/mcp.json" "${OUT_DIR}/cursor-developer-pack.json" "mcpServers"
}

install_vscode() {
  merge_json_file "$(vscode_user_mcp)" "${OUT_DIR}/vscode-developer-pack.json" "servers"
}

install_bob() {
  merge_json_file "${HOME}/.bob/mcp.json" "${OUT_DIR}/cursor-developer-pack.json" "mcpServers" || true
  merge_json_file "${HOME}/.bob/mcp_settings.json" "${OUT_DIR}/cursor-developer-pack.json" "mcpServers" || true
}

install_antigravity() {
  merge_json_file "${HOME}/.gemini/antigravity/mcp_config.json" "${OUT_DIR}/cursor-developer-pack.json" "mcpServers" || true
  merge_json_file "${HOME}/.gemini/config/mcp_config.json" "${OUT_DIR}/cursor-developer-pack.json" "mcpServers" || true
}

install_claude() {
  merge_json_file "$(claude_config)" "${OUT_DIR}/cursor-developer-pack.json" "mcpServers"
}

install_workspace() {
  merge_json_file "${REPO_ROOT}/.vscode/mcp.json" "${OUT_DIR}/vscode-developer-pack.json" "servers"
}

pick_ides_interactive() {
  echo ""
  echo "Qiskit Developer Pack — tier: ${TIER}"
  if [[ "$TIER" == "full" ]]; then
    echo "  Servers: qiskit-docs, qiskit, quantum-openqasm-mcp, qiskit-ibm-runtime"
  else
    echo "  Servers: qiskit-docs, qiskit, quantum-openqasm-mcp"
  fi
  echo ""
  echo "Which IDEs should receive the bundle?"
  echo "  1) Cursor"
  echo "  2) VS Code (user mcp.json)"
  echo "  3) IBM Bob"
  echo "  4) Antigravity"
  echo "  5) Claude Desktop"
  echo "  6) All of the above"
  read -r -p "Choice [1-6] (default 6): " choice
  choice="${choice:-6}"
  case "$choice" in
    1) IDE="cursor" ;;
    2) IDE="vscode" ;;
    3) IDE="bob" ;;
    4) IDE="antigravity" ;;
    5) IDE="claude" ;;
    6) IDE="all" ;;
    *) fail "Invalid choice: $choice" ;;
  esac
  read -r -p "Also install workspace .vscode/mcp.json? [y/N]: " ws
  ws="$(echo "$ws" | tr '[:upper:]' '[:lower:]')"
  [[ "$ws" == "y" || "$ws" == "yes" ]] && WORKSPACE=true
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
  log "Qiskit Developer Pack setup (tier=${TIER})"
  [[ -n "$IDE" ]] || pick_ides_interactive
  check_prerequisites
  generate_deployed_configs
  install_for_ide "$IDE"
  [[ "${WORKSPACE}" == true ]] && { log "Installing workspace .vscode/mcp.json"; install_workspace; }

  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "  Qiskit Developer Pack installed (tier=${TIER})"
  echo ""
  echo "  MCP servers merged:"
  echo "    • qiskit-docs          (Qiskit documentation search)"
  echo "    • qiskit               (circuit build, QASM3/QPY)"
  echo "    • quantum-openqasm-mcp (OpenQASM 2.0 → IBM Sampler V2)"
  if [[ "$TIER" == "full" ]]; then
    echo "    • qiskit-ibm-runtime   (Qiskit primitives on IBM hardware)"
  fi
  echo ""
  echo "  Next steps:"
  echo "    1. Ensure ~/.quantum-openqasm-mcp/.env has IBM_API_KEY + IBM_SERVICE_CRN"
  if [[ "$TIER" == "full" ]]; then
    echo "    2. Set QISKIT_IBM_TOKEN for qiskit-ibm-runtime (if not injected)"
  fi
  echo "    3. Reload IDE (MCP: List Servers / restart)"
  echo "    4. Ask agent (see docs/ide/QISKIT-DEVELOPER-PACK.md#worked-example-bell-state-on-ibm-hardware):"
  echo "       search Qiskit docs → build Bell → transpile → export QASM → submit"
  if [[ -x "${QISKIT_PYTHON}" ]]; then
    echo "    5. Or run: ${QISKIT_PYTHON} examples/qiskit-bell-transpile-export.py"
  fi
  echo ""
  echo "  Docs: docs/ide/QISKIT-DEVELOPER-PACK.md"
  echo "════════════════════════════════════════════════════════"
}

main
