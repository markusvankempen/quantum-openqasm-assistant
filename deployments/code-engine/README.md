# Quantum OpenQASM MCP — IBM Code Engine

Deploy the Quantum OpenQASM MCP server to [IBM Code Engine](https://www.ibm.com/products/code-engine) with **SSE transport**, a **web dashboard**, **connection test UI**, and **admin panel** (pattern from [code-engine-mcp-server](https://github.com/markusvankempen/code-engine-mcp-server) and Zendesk MCP).

**Live deployment:** resolve your URL after deploy — see [Deployment endpoint](./DEPLOYMENT-GUIDE.md#deployment-endpoint-ce_endpoint). **Do not hardcode** the hostname; it is project-specific.

📖 **[Complete deployment guide → DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)**

> **`bridge.mjs` is not in the public GitHub repo.** It is required for the Docker image (SSE gateway + dashboard). Keep it in your private dev checkout or obtain it from the author before running `docker build` / `./deploy.sh`.

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)

---

## Quick deploy

```bash
cd deployments/code-engine

IBMCLOUD_API_KEY=your_ibm_cloud_api_key \
IBM_API_KEY=your_quantum_api_key \
IBM_SERVICE_CRN=crn:v1:bluemix:public:quantum-computing:... \
./deploy.sh
```

Optional:

```bash
IBM_QUANTUM_ENDPOINT=https://us-east.quantum-computing.cloud.ibm.com
IBM_QUANTUM_BACKEND=ibm_fez
QUANTUM_MCP_NPM_VERSION=1.7.2
CE_PROJECT=your-ce-project
APP_NAME=quantum-mcp-remote
```

After deploy, open the **dashboard** at `CE_ENDPOINT/` and run **connection tests** at `/test`.

---

## Endpoints

| Path | Description |
|------|-------------|
| `/` | Dashboard UI — stats, tools, connect snippets |
| `/sse` | Open MCP SSE stream |
| `/message?sessionId=` | POST JSON-RPC to session |
| `/health` | Liveness JSON |
| `/stats` | Tool usage JSON |
| `/test` | Connection test UI |
| `/test/api/run` | Diagnostic suite (JSON) |
| `/admin` | Update IBM Quantum credentials at runtime |

---

## Credential model

IBM Quantum credentials (`IBM_API_KEY`, `IBM_SERVICE_CRN`) are stored as Code Engine secrets/env. **Clients connect to `/sse` without passing API keys.** The bridge spawns `@markusvankempen/quantum-openqasm-mcp` (stdio) per session with full **10 tools**.

---

## After deploy — MCP client configs

📖 **[Remote MCP setup guide (detailed)](../../docs/ide/REMOTE-MCP-SETUP.md)** — verify gateway, `mcp.json` per IDE, test checklist.

### Generate ready-to-use configs

```bash
cd deployments/code-engine
./generate-mcp-configs.sh
# writes mcp-configs/deployed/vscode-mcp.json, cursor-mcp.json, …
```

### Templates (`mcp-configs/`)

| File | Copy to |
|------|---------|
| `vscode-remote.json` | `~/Library/Application Support/Code/User/mcp.json` or `.vscode/mcp.json` |
| `cursor-remote-npx.json` | `~/.cursor/mcp.json` |
| `cursor-remote-mcp-proxy.json` | `~/.cursor/mcp.json` (if SSE times out) |
| `bob-remote.json` | `~/.bob/mcp.json` |
| `antigravity-remote.json` | `~/.gemini/antigravity/mcp.json` |
| `claude-desktop-remote.json` | Claude Desktop config |

Generated files land in `mcp-configs/deployed/` (gitignored). See `mcp-configs/deployed/README.md`.

**Workspace template:** copy `.vscode/mcp.json.example` → `.vscode/mcp.json`, then run `generate-mcp-configs.sh` or replace `<CE_ENDPOINT>`.

### Quick verify

```bash
cd deployments/code-engine
./check-remote-health.sh
```

Or resolve manually (from **repo root**):

```bash
export CE_ENDPOINT="$(ibmcloud ce app get --name quantum-mcp-remote --output json \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['status']['url'])")"
curl -sS "${CE_ENDPOINT}/health" | jq .
```

If you are already in `deployments/code-engine`, use `mcp-configs/deployed/CE_ENDPOINT.txt` — not `deployments/code-engine/...`.

**Extension remote mode:** `quantumAssistant.mcpMode` = `remote`, `remoteMcpUrl` = `https://<CE_ENDPOINT>/sse`.

---

## Local Docker test

```bash
cd deployments/code-engine
docker build -f Dockerfile -t quantum-mcp-local .

docker run --rm -p 8080:8080 \
  -e IBM_API_KEY=... \
  -e IBM_SERVICE_CRN=crn:v1:... \
  -e BRIDGE_ADMIN_SECRET=test-secret \
  quantum-mcp-local
```

Open http://localhost:8080/ for the dashboard.

---

## Files

| File | Purpose |
|------|---------|
| `bridge.mjs` | SSE bridge + dashboard + admin + test UI |
| `Dockerfile` | Published npm package + bridge |
| `deploy-ibmcloud.sh` | 9-step IBM Cloud deploy |
| `deploy.sh` | Wrapper |
| `mcp-configs/` | IDE templates (`<CE_ENDPOINT>` placeholder only) |
| `generate-mcp-configs.sh` | Write gitignored `deployed/*.json` from live CE URL |
| `.vscode/mcp.json.example` | Workspace template — copy to `mcp.json` locally |
| `mcp-client-*.json` | Legacy aliases → see `mcp-configs/` |

---

*No bug too small, no syntax too weird.*
