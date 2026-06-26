#!/usr/bin/env bash
# Switch to public-mirror gitignore (docs only — current public GitHub layout).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .gitignore.public ]]; then
  echo "ERROR: .gitignore.public not found" >&2
  exit 1
fi

cp .gitignore.public .gitignore
echo "✓ Using public .gitignore (docs + deployment metadata only)"
echo ""
echo "Extension source (extension/src/, packages/) will be hidden from git status."
echo "To develop with full source, run: bash scripts/use-private-gitignore.sh"
