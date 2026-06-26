#!/usr/bin/env bash
# Switch to private-dev gitignore (track full source in quantum-openqasm-assistant-dev).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ ! -f .gitignore.private ]]; then
  echo "ERROR: .gitignore.private not found" >&2
  exit 1
fi

if [[ ! -f .gitignore.public ]]; then
  cp .gitignore .gitignore.public
  echo "Saved current .gitignore → .gitignore.public"
fi

cp .gitignore.private .gitignore
echo "✓ Using private .gitignore (full source tracked)"
echo ""
echo "Next steps:"
echo "  1. bash scripts/setup-dev-repo.sh   # configure remotes (once)"
echo "  2. git add -A && git status          # review newly visible files"
echo "  3. git commit && git push origin     # push to private dev repo"
echo ""
echo "Publish docs to public GitHub:"
echo "  bash scripts/sync-to-public.sh \"Release vX.Y.Z docs\""
