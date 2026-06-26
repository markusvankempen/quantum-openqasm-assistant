#!/usr/bin/env bash
# One-time setup: private dev repo as origin, public repo as 'public' remote.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PUBLIC_URL="${PUBLIC_REMOTE_URL:-https://github.com/markusvankempen/quantum-openqasm-assistant.git}"
PRIVATE_URL="${PRIVATE_REMOTE_URL:-git@github.com:markusvankempen/quantum-openqasm-assistant-dev.git}"

echo "=== Quantum OpenQASM Assistant — dev repo setup ==="
echo ""
echo "Public:  $PUBLIC_URL"
echo "Private: $PRIVATE_URL"
echo ""

# Ensure private gitignore
if [[ ! -f .gitignore.private ]]; then
  echo "ERROR: .gitignore.private missing" >&2
  exit 1
fi

if ! grep -q 'extension/src/' .gitignore 2>/dev/null; then
  echo "Switching to private .gitignore…"
  bash "$ROOT/scripts/use-private-gitignore.sh"
fi

# Remotes: origin = private, public = public mirror
CURRENT_ORIGIN=""
if git remote get-url origin &>/dev/null; then
  CURRENT_ORIGIN="$(git remote get-url origin)"
fi

if [[ "$CURRENT_ORIGIN" == *"quantum-openqasm-assistant.git"* ]] && [[ "$CURRENT_ORIGIN" != *"-dev"* ]]; then
  echo "Renaming origin → public (was public repo URL)"
  git remote rename origin public
  CURRENT_ORIGIN=""
fi

if git remote get-url public &>/dev/null; then
  echo "✓ remote 'public' → $(git remote get-url public)"
else
  git remote add public "$PUBLIC_URL"
  echo "✓ Added remote 'public' → $PUBLIC_URL"
fi

if git remote get-url origin &>/dev/null; then
  echo "✓ remote 'origin' → $(git remote get-url origin)"
  echo ""
  echo "If origin should be the private repo, run:"
  echo "  git remote set-url origin $PRIVATE_URL"
else
  git remote add origin "$PRIVATE_URL"
  echo "✓ Added remote 'origin' → $PRIVATE_URL"
fi

echo ""
echo "=== Done ==="
echo ""
echo "1. Create the private GitHub repo if needed:"
echo "   https://github.com/new  →  quantum-openqasm-assistant-dev  (private)"
echo ""
echo "2. Stage and push full source:"
echo "   git add -A"
echo "   git status"
echo "   git commit -m \"Initial private dev repo — full source\""
echo "   git push -u origin master"
echo ""
echo "3. After doc/release updates, sync to public:"
echo "   bash scripts/sync-to-public.sh \"Release vX.Y.Z docs\""
