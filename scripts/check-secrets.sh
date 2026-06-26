#!/usr/bin/env bash
# check-secrets.sh — Fail if tracked/staged files contain real API keys or secrets.
#
# Usage:
#   ./scripts/check-secrets.sh           # scan git index (tracked + staged)
#   ./scripts/check-secrets.sh --all     # also scan untracked sensitive paths
#
# Run before publishing to GitHub, npm, or opening a PR.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

SCAN_UNTRACKED=false
[[ "${1:-}" == "--all" ]] && SCAN_UNTRACKED=true

fail=0
report() {
  echo "SECRET CHECK FAILED: $1" >&2
  fail=1
}

# Files that are allowed to mention env var names / placeholders only
is_allowlisted() {
  case "$1" in
    */.env.example|*/extension/.env.example|*/.gitignore|*/.gitignore.*|*/CONTRIBUTING.md|*/check-secrets.sh) return 0 ;;
  esac
  return 1
}

# True if line looks like a placeholder or code reference, not a literal secret
is_placeholder_line() {
  local line="$1"
  [[ "$line" =~ (your_|your-|xxx|\.\.\.|placeholder|<|example|iamapikey|\$\{input:|\$\{[A-Za-z_][A-Za-z0-9_.]*\}|\$[A-Z_][A-Z0-9_]*) ]] && return 0
  [[ "$line" =~ ^[[:space:]]*# ]] && return 0
  [[ "$line" =~ (promptSecret|escapeEnvValue|process\.env\.|getenv|os\.environ) ]] && return 0
  return 1
}

scan_file() {
  local f="$1"
  local line val
  is_allowlisted "$f" && return 0
  [[ -f "$f" ]] || return 0

  while IFS= read -r line || [[ -n "$line" ]]; do
    is_placeholder_line "$line" && continue

    # IBM / IBM Cloud API keys (literal value after =, not a placeholder)
    if [[ "$line" =~ IBM(_CLOUD)?_API_KEY[[:space:]]*=[[:space:]]*(.+) ]]; then
      val="${BASH_REMATCH[2]%%#*}"
      val="${val#"${val%%[![:space:]]*}"}"
      val="${val%"${val##*[![:space:]]}"}"
      if [[ ${#val} -ge 20 && ! "$val" =~ ^(\$|\$\{) && ! "$val" =~ (your_|your-|xxx|placeholder|iamapikey) ]]; then
        report "$f may contain a real IBM_API_KEY value"
        break
      fi
    fi

    # Quantum token
    if [[ "$line" =~ IBM_QUANTUM_TOKEN[[:space:]]*=[[:space:]]*(.+) ]]; then
      val="${BASH_REMATCH[2]%%#*}"
      val="${val#"${val%%[![:space:]]*}"}"
      val="${val%"${val##*[![:space:]]}"}"
      if [[ ${#val} -ge 20 && ! "$val" =~ ^(\$|\$\{) && ! "$val" =~ (your_|your-|xxx|placeholder) ]]; then
        report "$f may contain a real IBM_QUANTUM_TOKEN value"
        break
      fi
    fi

    # Service CRN with real-looking account/instance segments
    if [[ "$line" =~ crn:v1:bluemix:public:quantum-computing:[^:]+:a/[a-f0-9]{8,}:[a-f0-9-]{8,} ]]; then
      report "$f may contain a real IBM_SERVICE_CRN"
      break
    fi

    # Resolved Code Engine hostnames (not templates)
    if [[ "$line" =~ https://[a-z0-9.-]+\.[a-z0-9]{8,}\.[a-z0-9-]+\.codeengine\.appdomain\.cloud ]]; then
      report "$f may contain a resolved Code Engine URL (use <CE_ENDPOINT> placeholders)"
      break
    fi

    # Bridge admin secret literal (skip shell expansions)
    if [[ "$line" =~ BRIDGE_ADMIN_SECRET[[:space:]]*=[[:space:]]*(.+) ]]; then
      val="${BASH_REMATCH[2]%%#*}"
      val="${val#"${val%%[![:space:]]*}"}"
      val="${val%"${val##*[![:space:]]}"}"
      if [[ ${#val} -ge 8 && ! "$val" =~ ^(\$|\$\{) && ! "$val" =~ (your_|your-|xxx|placeholder|secret) ]]; then
        report "$f may contain a real BRIDGE_ADMIN_SECRET value"
        break
      fi
    fi

    # GitHub / npm tokens
    if [[ "$line" =~ (ghp_[A-Za-z0-9]{20,}|npm_[A-Za-z0-9]{20,}|sk-[A-Za-z0-9]{20,}) ]]; then
      report "$f may contain a GitHub/npm/AI API token"
      break
    fi
  done < "$f"
}

echo "Scanning for secrets in ${ROOT}…"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r f; do
    [[ -n "$f" ]] && scan_file "$f"
  done < <(git ls-files -z | tr '\0' '\n')

  while IFS= read -r f; do
    [[ -n "$f" ]] && scan_file "$f"
  done < <(git diff --cached --name-only --diff-filter=ACM 2>/dev/null || true)
else
  echo "WARN: not a git repo — scanning common paths only" >&2
fi

# Block tracked .env files
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r envf; do
    [[ -n "$envf" ]] && report "$envf is tracked by git — remove it immediately"
  done < <(git ls-files '.env' '**/.env' 'extension/.env' 2>/dev/null || true)
fi

# Block MCP registry token files if ever tracked
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  while IFS= read -r tf; do
    [[ -n "$tf" ]] && report "$tf is tracked — MCP registry tokens must stay local"
  done < <(git ls-files '**/.mcpregistry_*' 2>/dev/null || true)
fi

if [[ "$SCAN_UNTRACKED" == true ]]; then
  while IFS= read -r f; do
    case "$f" in
      */.git/*|*/node_modules/*|*/.public-sync/*) continue ;;
      */.env|*/.env.*|*/extension/.env) scan_file "$f" ;;
      */mcp-configs/deployed/*) scan_file "$f" ;;
      */.vscode/mcp.json|*/.cursor/mcp.json) scan_file "$f" ;;
      */.mcpregistry_*) scan_file "$f" ;;
    esac
  done < <(find . -type f 2>/dev/null | sed 's|^\./||')
fi

# npm package sanity — dist/ must not contain literal keys
if [[ -d packages/quantum-openqasm-mcp/dist ]]; then
  if rg -q 'IBM_API_KEY=[A-Za-z0-9_-]{20,}' packages/quantum-openqasm-mcp/dist/ 2>/dev/null; then
    report "packages/quantum-openqasm-mcp/dist/ may contain a hardcoded IBM_API_KEY"
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "" >&2
  echo "Remove secrets, use placeholders (your_*, xxx, <CE_ENDPOINT>), and ensure .env stays gitignored." >&2
  exit 1
fi

echo "OK — no secrets detected in scanned files."
