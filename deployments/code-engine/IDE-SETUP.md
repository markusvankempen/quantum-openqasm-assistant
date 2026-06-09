# Remote MCP IDE Setup — Procedure

Step-by-step procedure to connect your IDE to the **Quantum OpenQASM MCP** on IBM Code Engine.

📖 **[Full guide](../../docs/ide/REMOTE-MCP-SETUP.md)** · **[Deploy](./README.md)** · **[Deployment guide](./DEPLOYMENT-GUIDE.md)**

---

## Prerequisites

| Requirement | Check |
|-------------|-------|
| Code Engine app deployed | `ibmcloud ce app get --name quantum-mcp-remote` |
| IBM Cloud CLI logged in | `ibmcloud target` |
| `curl`, `python3` | `curl --version` |
| Cursor only: `npx` or `uvx` | `npx --version` or `uvx --version` |

IBM Quantum credentials live on the **server** — you do **not** put `IBM_API_KEY` in `mcp.json`.

---

## One-command setup (recommended)

From the repo (or `deployments/code-engine/`):

```bash
cd deployments/code-engine
./setup-remote-mcp.sh
```

Interactive menu: pick IDE(s), optional workspace config, run health check.

### Non-interactive examples

```bash
# Cursor + VS Code + workspace mcp.json
./setup-remote-mcp.sh --ide cursor,vscode --workspace

# All supported IDEs
./setup-remote-mcp.sh --ide all

# Cursor with mcp-proxy (SSE timeout workaround)
./setup-remote-mcp.sh --ide cursor --proxy

# Connection check only (no file changes)
./setup-remote-mcp.sh --check-only

# Preview without writing
./setup-remote-mcp.sh --dry-run --ide vscode
```

### What the script does

1. Resolves `CE_ENDPOINT` via `ibmcloud` (or `mcp-configs/deployed/CE_ENDPOINT.txt`)
2. Runs `generate-mcp-configs.sh` → local configs in `mcp-configs/deployed/` (gitignored)
3. Merges `quantum-openqasm-mcp-remote` into your IDE `mcp.json` (backs up existing file as `.bak.<timestamp>`)
4. Optionally writes `.vscode/mcp.json` in the repo workspace
5. Runs `check-remote-health.sh` (`/health` + `/test/api/run`)

---

## Manual procedure (per IDE)

If you prefer not to use the script:

### Step 1 — Generate configs

```bash
cd deployments/code-engine
./generate-mcp-configs.sh
./check-remote-health.sh
```

### Step 2 — Install config

| IDE | Config path | Source file |
|-----|-------------|-------------|
| **VS Code** | `~/Library/Application Support/Code/User/mcp.json` (macOS) | `mcp-configs/deployed/vscode-mcp.json` |
| **VS Code workspace** | `<repo>/.vscode/mcp.json` | same |
| **Cursor** | `~/.cursor/mcp.json` | `mcp-configs/deployed/cursor-mcp.json` |
| **IBM Bob** | `~/.bob/mcp.json` or `~/.bob/mcp_settings.json` | `cursor-mcp.json` shape |
| **Antigravity** | `~/.gemini/antigravity/mcp_config.json` | `cursor-mcp.json` shape |
| **Claude Desktop** | `~/Library/Application Support/Claude/claude_desktop_config.json` | `cursor-mcp.json` shape |

Merge into existing JSON — do not replace other `mcpServers` / `servers` entries.

### Step 3 — Reload IDE

- **VS Code:** Command Palette → `MCP: List Servers` → enable **quantum-openqasm-mcp-remote** (10 tools)
- **Cursor:** Restart or `MCP: List Servers` → enable server

### Step 4 — Test in chat

- *"Use quantum-openqasm-mcp-remote to list IBM Quantum backends."*
- *"Run check_credentials on the quantum MCP server."*

---

## VS Code native SSE config

```json
{
  "servers": {
    "quantum-openqasm-mcp-remote": {
      "type": "sse",
      "url": "https://<CE_ENDPOINT>/sse"
    }
  }
}
```

Template: `mcp-configs/vscode-remote.json`

---

## Cursor config (npx mcp-remote)

```json
{
  "mcpServers": {
    "quantum-openqasm-mcp-remote": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://<CE_ENDPOINT>/sse"]
    }
  }
}
```

If Cursor times out after 30s, use `cursor-remote-mcp-proxy.json` (`uvx mcp-proxy`).

---

## Quantum VS Code extension (remote mode)

| Setting | Value |
|---------|-------|
| `quantumAssistant.mcpMode` | `remote` |
| `quantumAssistant.remoteMcpUrl` | `https://<CE_ENDPOINT>/sse` |

Set via **Quantum → Settings & Diagnostics** or Settings UI.

---

## Troubleshooting

| Issue | Action |
|-------|--------|
| `Could not resolve CE_ENDPOINT` | `ibmcloud login` + deploy app, or set `APP_NAME` |
| Health OK but IDE shows 0 tools | Warm gateway: `curl -sS "${CE_ENDPOINT}/health"`; retry |
| Cursor MCP timeout | `./setup-remote-mcp.sh --ide cursor --proxy` |
| Wrong URL in config | Re-run `./setup-remote-mcp.sh` (never commit URLs to git) |
| Merge broke JSON | Restore `mcp.json.bak.<timestamp>` next to config file |

---

## Scripts reference

| Script | Purpose |
|--------|---------|
| `setup-remote-mcp.sh` | **All-in-one** — resolve URL, install mcp.json, health check |
| `generate-mcp-configs.sh` | Write gitignored `mcp-configs/deployed/*.json` |
| `check-remote-health.sh` | `/health` + diagnostic summary |
| `deploy.sh` | Deploy gateway to Code Engine |

---

**Author:** Markus van Kempen  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)
