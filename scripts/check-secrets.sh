#!/usr/bin/env bash
# check-secrets.sh — Fail if tracked/staged files contain real API keys or secrets.
#
# Usage:
#   ./scripts/check-secrets.sh           # scan git index (tracked + staged)
#   ./scripts/check-secrets.sh --all     # also scan untracked files under repo (except .git)
#
# Run before publishing to GitHub or opening a PR.
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

# Files that are allowed to mention env var names / placeholders
is_allowlisted() {
  case "$1" in
    */.env.example|*/extension/.env.example|*/.gitignore|*/CONTRIBUTING.md|*/check-secrets.sh) return 0 ;;
  esac
  return 1
}

scan_file() {
  local f="$1"
  is_allowlisted "$f" && return 0
  [[ -f "$f" ]] || return 0

  # IBM / IBM Cloud API keys (long token after =, not a placeholder)
  if grep -qE 'IBM(_CLOUD)?_API_KEY[[:space:]]*=[[:space:]]*[^#"'\''[:space:]<][^#"'\''[:space:]]{19,}' "$f" 2>/dev/null; then
    if ! grep -qE 'IBM(_CLOUD)?_API_KEY[[:space:]]*=[[:space:]]*(your_|xxx|\.\.\.|placeholder|<|example)' "$f" 2>/dev/null; then
      report "$f may contain a real IBM_API_KEY value"
    fi
  fi

  # Quantum token
  if grep -qE 'IBM_QUANTUM_TOKEN[[:space:]]*=[[:space:]]*[^#"'\''[:space:]<][^#"'\''[:space:]]{19,}' "$f" 2>/dev/null; then
    if ! grep -qE 'IBM_QUANTUM_TOKEN[[:space:]]*=[[:space:]]*(your_|xxx|\.\.\.|placeholder|<|example)' "$f" 2>/dev/null; then
      report "$f may contain a real IBM_QUANTUM_TOKEN value"
    fi
  fi

  # Service CRN with real-looking account/instance segments (hex/uuid), not placeholders
  if grep -qE 'crn:v1:bluemix:public:quantum-computing:[^:]+:a/[a-f0-9]{8,}:[a-f0-9-]{8,}' "$f" 2>/dev/null; then
    if ! grep -qE 'your-account-id|your-instance-id|<|placeholder|example|\.\.\.' "$f" 2>/dev/null; then
      report "$f may contain a real IBM_SERVICE_CRN"
    fi
  fi

  # Resolved Code Engine hostnames (not templates)
  if grep -qE 'https://[a-z0-9.-]+\.[a-z0-9]{8,}\.[a-z0-9-]+\.codeengine\.appdomain\.cloud' "$f" 2>/dev/null; then
    if ! grep -qE '<CE_ENDPOINT>|<project-hash>|example\.com|your-' "$f" 2>/dev/null; then
      report "$f may contain a resolved Code Engine URL (use <CE_ENDPOINT> placeholders)"
    fi
  fi

  # Bridge admin secret literal (skip shell expansions like ${BRIDGE_ADMIN_SECRET})
  if grep -vE '\$\{|:-' "$f" 2>/dev/null | grep -qE 'BRIDGE_ADMIN_SECRET[[:space:]]*=[[:space:]]*[^#"'\''[:space:]<$][^#"'\''[:space:]]{8,}' 2>/dev/null; then
    if ! grep -qE 'BRIDGE_ADMIN_SECRET[[:space:]]*=[[:space:]]*(your_|xxx|\.\.\.|placeholder|<|test-secret|local-dev-secret|example)' "$f" 2>/dev/null; then
      report "$f may contain a real BRIDGE_ADMIN_SECRET value"
    fi
  fi
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

# Always block if .env is tracked
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 && git ls-files --error-unmatch .env >/dev/null 2>&1; then
  report ".env is tracked by git — remove it immediately"
fi

if [[ "$SCAN_UNTRACKED" == true ]]; then
  while IFS= read -r f; do
    case "$f" in
      */.git/*|*/node_modules/*) continue ;;
      */.env|*/.env.*) scan_file "$f" ;;
      */mcp-configs/deployed/*) scan_file "$f" ;;
      */.vscode/mcp.json) scan_file "$f" ;;
    esac
  done < <(find . -type f 2>/dev/null | sed 's|^\./||')
fi

if [[ "$fail" -ne 0 ]]; then
  echo "" >&2
  echo "Remove secrets, use placeholders (your_*, xxx, <CE_ENDPOINT>), and ensure .env stays gitignored." >&2
  exit 1
fi

echo "OK — no secrets detected in scanned files."
