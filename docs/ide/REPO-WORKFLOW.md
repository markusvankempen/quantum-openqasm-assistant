# Repository workflow — public vs private dev

Quantum OpenQASM Assistant uses a **two-repo model**: full source in a private GitHub repo, docs and deployment metadata in the public repo.

| Repo | GitHub | Contents |
|------|--------|----------|
| **Public** | [quantum-openqasm-assistant](https://github.com/markusvankempen/quantum-openqasm-assistant) | README, docs, deployment scripts, MCP JSON templates, extension README + icons |
| **Private dev** | `quantum-openqasm-assistant-dev` *(private)* | `extension/src/`, `packages/quantum-openqasm-mcp/`, webview JS, CI, VSIX/npm publish |

**End users** install via VS Code Marketplace, `.vsix`, or `npx @markusvankempen/quantum-openqasm-mcp` — not by cloning source from GitHub.

---

## Files in this checkout

| File | Purpose |
|------|---------|
| `.gitignore.public` | Allowlist for public mirror (docs only) |
| `.gitignore.private` | Standard dev ignore (secrets, `node_modules`, `out/`) |
| `.gitignore` | Active mode — switch with scripts below |
| `.public-rsync-filter` | Rsync rules for `sync-to-public.sh` |

---

## One-time setup (maintainers)

1. **Create private repo** on GitHub: `quantum-openqasm-assistant-dev` (private).

2. **Configure remotes and private gitignore:**

```bash
bash scripts/setup-dev-repo.sh
```

This renames `origin` → `public` if it pointed at the public repo, adds `origin` → private dev, and activates `.gitignore.private`.

3. **Push full source to private repo:**

```bash
git add -A
git status                    # should show extension/src/, packages/, etc.
git commit -m "Private dev repo — full source"
git push -u origin master
```

---

## Daily development

```bash
# Ensure private mode (tracks all source)
bash scripts/use-private-gitignore.sh

mise run build
mise run package          # VSIX in extension/
mise run test-e2e         # optional IBM smoke test

git add -A && git commit -m "…"
git push origin master    # private only
```

---

## Publish docs to public GitHub

After updating README, docs, or deployment scripts:

```bash
bash scripts/check-secrets.sh
bash scripts/sync-to-public.sh "Release v1.9.2 — docs and deployment updates"
```

Dry run (rsync + diff, no push):

```bash
SYNC_DRY_RUN=1 bash scripts/sync-to-public.sh
```

The script clones the public repo to `.public-sync/`, rsyncs the allowlisted tree, commits, and pushes to the `public` remote.

---

## Release checklist

1. **Private repo** — merge features, bump versions in `extension/package.json` and `packages/quantum-openqasm-mcp/package.json`.
2. **Build & publish artifacts:**
   - `mise run package` → VSIX
   - `cd packages/quantum-openqasm-mcp && npm publish`
   - VS Code Marketplace / Open VSX (optional)
3. **GitHub release** — attach VSIX to public repo release (or private if preferred).
4. **Sync public docs:**

```bash
bash scripts/sync-to-public.sh "Release vX.Y.Z"
git tag vX.Y.Z && git push origin vX.Y.Z   # tag on private repo
```

5. **Public release tag** — create matching tag on public repo if you tag releases there.

---

## What never goes to public GitHub

- `extension/src/`, `extension/media/*.js`, `extension/out/`
- `extension/package.json`, esbuild, tsconfig
- `packages/quantum-openqasm-mcp/src/`
- `deployments/code-engine/bridge.mjs`
- `Internal/`, `.env`, MCP registry tokens
- Resolved `mcp-configs/deployed/*.json`

---

## Switch back to public-only mode

For doc-only edits without full source visible in `git status`:

```bash
bash scripts/use-public-gitignore.sh
```

---

## Remotes reference

```bash
git remote -v
# origin   → git@github.com:markusvankempen/quantum-openqasm-assistant-dev.git
# public   → https://github.com/markusvankempen/quantum-openqasm-assistant.git
```

Override URLs when running setup:

```bash
PRIVATE_REMOTE_URL=git@github.com:you/quantum-openqasm-assistant-dev.git \
PUBLIC_REMOTE_URL=https://github.com/markusvankempen/quantum-openqasm-assistant.git \
bash scripts/setup-dev-repo.sh
```
