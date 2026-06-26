#!/usr/bin/env bash
# Push docs-only snapshot to the public GitHub repo (no extension source).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

PUBLIC_REMOTE="${PUBLIC_REMOTE:-public}"
PUBLIC_BRANCH="${PUBLIC_BRANCH:-master}"
COMMIT_MSG="${1:-Sync public mirror from private dev repo}"
FILTER_FILE="$ROOT/.public-rsync-filter"
WORK_DIR="$ROOT/.public-sync"

if [[ ! -f "$FILTER_FILE" ]]; then
  echo "ERROR: $FILTER_FILE not found" >&2
  exit 1
fi

if [[ ! -f "$ROOT/.gitignore.public" ]]; then
  echo "ERROR: .gitignore.public not found" >&2
  exit 1
fi

if ! git remote get-url "$PUBLIC_REMOTE" &>/dev/null; then
  echo "ERROR: git remote '$PUBLIC_REMOTE' not configured." >&2
  echo "Run: bash scripts/setup-dev-repo.sh" >&2
  exit 1
fi

PUBLIC_URL="$(git remote get-url "$PUBLIC_REMOTE")"

echo "=== Sync to public repo ==="
echo "Remote:  $PUBLIC_REMOTE ($PUBLIC_URL)"
echo "Branch:  $PUBLIC_BRANCH"
echo ""

echo "Running secrets scan…"
bash "$ROOT/scripts/check-secrets.sh"

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

if git ls-remote --heads "$PUBLIC_URL" "$PUBLIC_BRANCH" | grep -q .; then
  git clone --depth 1 -b "$PUBLIC_BRANCH" "$PUBLIC_URL" "$WORK_DIR/repo"
else
  git clone --depth 1 "$PUBLIC_URL" "$WORK_DIR/repo"
fi

DEST="$WORK_DIR/repo"

echo "Rsync public allowlist…"
rsync -a --delete --exclude '.git' --exclude '.public-sync' --filter="merge $FILTER_FILE" "$ROOT/" "$DEST/"

# Public repo always uses the public gitignore
cp "$ROOT/.gitignore.public" "$DEST/.gitignore"

cd "$DEST"
git add -A

if git diff --staged --quiet; then
  echo "No changes to publish — public repo is up to date."
  rm -rf "$WORK_DIR"
  exit 0
fi

echo ""
echo "Changes to publish:"
git diff --staged --stat
echo ""

if [[ "${SYNC_DRY_RUN:-}" == "1" ]]; then
  echo "SYNC_DRY_RUN=1 — skipping commit/push"
  rm -rf "$WORK_DIR"
  exit 0
fi

git commit -m "$COMMIT_MSG"
git push origin "HEAD:$PUBLIC_BRANCH"

rm -rf "$WORK_DIR"
echo ""
echo "✓ Published to $PUBLIC_URL ($PUBLIC_BRANCH)"
