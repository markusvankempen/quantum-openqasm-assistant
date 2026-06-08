# Remote MCP Setup — Quantum OpenQASM on Code Engine

<!--
SEO: Quantum MCP remote | Code Engine SSE | mcp.json | Cursor | VS Code
remote quantum mcp, code engine openqasm, mcp-remote, server-side credentials
-->

> Connect **Cursor**, **VS Code**, **IBM Bob**, **Antigravity**, and **Claude Desktop** to the **remote Quantum OpenQASM MCP** on IBM Code Engine. Credentials stay on the server — clients only need the **SSE URL**.

> **Do not hardcode** Code Engine URLs in committed files. Hostnames are **project-specific** (`<project-hash>` in the path). Always resolve `CE_ENDPOINT` after deploy or run `generate-mcp-configs.sh` for local configs.

📖 **[Local MCP (stdio)](./LOCAL-MCP-SETUP.md)** · **[Deployment scenarios](../deployments/DEPLOYMENT-SCENARIOS.md)** · **[Extension README](../../extension/README.md)**

**Supported IDEs:** Cursor · VS Code · IBM Bob · Google Antigravity · Claude Desktop · Quantum VS Code extension (remote mode)

---

## What you get

| Feature | Remote (Code Engine) | Local (stdio) |
|---------|---------------------|---------------|
| IBM credentials on client | **No** — server-side only | Yes (`~/.quantum-openqasm-mcp/.env`) |
| MCP tools | **10** (full npm package) | 10 |
| Dashboard / test UI | `CE_ENDPOINT/` and `/test` | Extension Diagnostics only |
| Share with team | One URL | Per-machine setup |

**Gateway routes** (append to `CE_ENDPOINT`):

| Path | Purpose |
|------|---------|
| `/` | Dashboard — tools, stats, copy-paste configs |
| `/sse` | MCP SSE stream |
| `/health` | Liveness JSON |
| `/test` | Connection test UI |
| `/admin` | Rotate IBM credentials (`BRIDGE_ADMIN_SECRET`) |

---

## Step 0 — Resolve `CE_ENDPOINT`

Code Engine URLs are **project-specific**. Never copy a hostname from old docs without verifying.

```bash
export APP_NAME=quantum-mcp-remote   # default from deploy script
export CE_ENDPOINT="$(ibmcloud ce app get --name "${APP_NAME}" --output json \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['status']['url'])")"

echo "CE_ENDPOINT=${CE_ENDPOINT}"
```

**Example shape** (your hash will differ unless same CE project):

```text
https://quantum-mcp-remote.<project-hash>.ca-tor.codeengine.appdomain.cloud
```

Generate **local** configs with your resolved URL (gitignored — never commit):

```bash
cd deployments/code-engine
./generate-mcp-configs.sh
# → mcp-configs/deployed/vscode-mcp.json, cursor-mcp.json, … (local only)
```

Or use templates below and replace `<CE_ENDPOINT>` manually.

---

## Step 1 — Verify gateway (before any IDE)

### Health

```bash
curl -sS "${CE_ENDPOINT}/health" | jq .
```

Expected:

```json
{
  "status": "ok",
  "credentials": true,
  "tools": 10,
  "sessions": 0
}
```

### Full diagnostic suite

```bash
curl -sS -X POST "${CE_ENDPOINT}/test/api/run" | jq .
```

All five steps should show `"ok": true`:

1. IBM Quantum credentials present  
2. IBM IAM token (API key)  
3. MCP server `tools/list` probe  
4. MCP `check_credentials`  
5. MCP `list_backends`  

### Browser

| URL | Action |
|-----|--------|
| `${CE_ENDPOINT}/` | Open dashboard — confirm **10 tools** |
| `${CE_ENDPOINT}/test` | Click **Run all tests** |

---

## Step 2 — VS Code (native SSE) — recommended

VS Code uses `"servers"` (not `"mcpServers"`) and supports **native SSE** without a proxy.

### Config file locations

| Scope | macOS path |
|-------|------------|
| **User (global)** | `~/Library/Application Support/Code/User/mcp.json` |
| **Workspace** | `<project>/.vscode/mcp.json` |

Linux: `~/.config/Code/User/mcp.json`  
Windows: `%APPDATA%\Code\User\mcp.json`

### `mcp.json`

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

Replace `<CE_ENDPOINT>` with your resolved hostname (no trailing slash before `/sse`).

**Template:** `deployments/code-engine/mcp-configs/vscode-remote.json`  
**Workspace example:** `.vscode/mcp.json.example` → copy to `.vscode/mcp.json`  
**Generated locally:** `mcp-configs/deployed/vscode-mcp.json` (via `generate-mcp-configs.sh`)

### Enable in VS Code

1. **Command Palette** → `MCP: List Servers`
2. Confirm **`quantum-openqasm-mcp-remote`** — expect **10 tools**
3. Enable tools for **GitHub Copilot Chat** / agent mode

### Test prompts

Ask Copilot Chat:

- *"Use quantum-openqasm-mcp-remote to list available IBM Quantum backends."*
- *"Check quantum MCP credentials status."*
- *"What is the status of backend ibm_fez?"*

---

## Step 3 — Cursor

Cursor uses `"mcpServers"`. Two reliable patterns:

### Option A — `npx mcp-remote` (simple)

**File:** `~/.cursor/mcp.json` or `<workspace>/.cursor/mcp.json`

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

**Template:** `mcp-configs/cursor-remote-npx.json`  
**Generated locally:** `mcp-configs/deployed/cursor-mcp.json`

### Option B — `uvx mcp-proxy` (if SSE times out)

If Cursor reports `MCP IPC timeout … exceeded 30000ms`, use `mcp-proxy`:

```bash
# Install uv if needed
curl -LsSf https://astral.sh/uv/install.sh | sh
which uvx
```

```json
{
  "mcpServers": {
    "quantum-openqasm-mcp-remote": {
      "command": "uvx",
      "args": ["mcp-proxy", "https://<CE_ENDPOINT>/sse"]
    }
  }
}
```

**Template:** `mcp-configs/cursor-remote-mcp-proxy.json`  
**Generated locally:** `mcp-configs/deployed/cursor-mcp-proxy.json`

### Warm gateway before first connect

```bash
curl -sS "${CE_ENDPOINT}/health"
```

Cold start (scale-to-zero) can add ~10–30s on first SSE session.

### Reload Cursor

1. **Command Palette** → `MCP: List Servers` (or restart Cursor)
2. Enable **`quantum-openqasm-mcp-remote`**
3. Confirm **10 tools**

---

## Step 4 — IBM Bob

Bob uses the same `mcpServers` shape as Cursor.

**Typical path:** `~/.bob/mcp.json` (or Bob settings → MCP)

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

**Template:** `mcp-configs/bob-remote.json`

---

## Step 5 — Google Antigravity

**Typical path:** `~/.gemini/antigravity/mcp.json`

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

**Template:** `mcp-configs/antigravity-remote.json`

---

## Step 6 — Claude Desktop

**macOS:** `~/Library/Application Support/Claude/claude_desktop_config.json`

Merge `mcpServers` (do not duplicate the top-level key):

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

**Template:** `mcp-configs/claude-desktop-remote.json`  
Restart Claude Desktop after saving.

---

## Step 7 — Quantum VS Code extension (remote mode)

Use the extension **without** local stdio when the gateway is deployed:

| Setting | Value |
|---------|-------|
| `quantumAssistant.mcpMode` | `remote` |
| `quantumAssistant.remoteMcpUrl` | `https://<CE_ENDPOINT>/sse` |

**Via UI:** Quantum → **Settings & Diagnostics** → set MCP mode **Remote** → paste SSE URL → **Save Configuration**.

The extension connects via `SSEClientTransport` to the same gateway as IDE MCP clients.

---

## MCP tools available remotely

All **10 tools** from `@markusvankempen/quantum-openqasm-mcp`:

| Tool | Purpose |
|------|---------|
| `check_credentials` | Verify IBM_API_KEY / IBM_SERVICE_CRN / IAM |
| `list_backends` | List quantum backends |
| `get_backend` | Backend details |
| `get_backend_configuration` | Backend config JSON |
| `list_jobs` | Recent jobs |
| `submit_qasm_job` | Submit OpenQASM 2.0 circuit |
| `get_job_status` | Poll job state |
| `get_job_results` | Fetch results |
| `get_job_result` | Single result payload |
| `cancel_job` | Cancel a job |

---

## End-to-end test checklist

| # | Check | Command / action |
|---|-------|------------------|
| 1 | App Ready | `ibmcloud ce app get --name quantum-mcp-remote` |
| 2 | Health OK | `curl -sS "${CE_ENDPOINT}/health"` → `tools: 10` |
| 3 | Diagnostics | `curl -sS -X POST "${CE_ENDPOINT}/test/api/run"` → all `ok: true` |
| 4 | Dashboard | Browser → `${CE_ENDPOINT}/` shows 10 tools |
| 5 | VS Code / Cursor | MCP server lists 10 tools |
| 6 | `list_backends` | Ask agent to call tool — returns backend names |
| 7 | `check_credentials` | Returns masked keys + IAM OK |
| 8 | Optional job | Submit small Bell-state QASM on `ibm_fez` (uses quota) |

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `/health` → `credentials: false` | Redeploy with `IBM_API_KEY` + `IBM_SERVICE_CRN`; or use `/admin` |
| `tools: 0` on dashboard | Check CE logs: `ibmcloud ce app logs --name quantum-mcp-remote` |
| Cursor MCP timeout | Use `uvx mcp-proxy`; warm with `curl …/health` first |
| VS Code server not listed | Confirm `"servers"` key; reload **MCP: List Servers** |
| 503 on `/sse` | Credentials missing on server — run `/test` UI |
| Wrong region / endpoint | Set `IBM_QUANTUM_ENDPOINT` on CE app to match your instance |
| URL changed after redeploy | Re-run `generate-mcp-configs.sh`; update IDE configs |

---

## Security notes

- **Do not** put `IBM_API_KEY` in remote `mcp.json` — credentials live on Code Engine only.
- **Do** save `BRIDGE_ADMIN_SECRET` from deploy output for `/admin`.
- Rotate keys via IBM Quantum console if exposed; update CE secrets and redeploy.
- Remote SSE is **public HTTPS** — use network policies / private CE if your org requires it.

---

## Related files (private dev repo)

| Path | Description |
|------|-------------|
| `deployments/code-engine/mcp-configs/` | Templates (`<CE_ENDPOINT>` only) |
| `deployments/code-engine/generate-mcp-configs.sh` | Write gitignored `deployed/*.json` |
| `.vscode/mcp.json.example` | Workspace template |
| `deployments/code-engine/DEPLOYMENT-GUIDE.md` | Deploy pipeline & ops |
| `deployments/code-engine/README.md` | Quick deploy reference |

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*
