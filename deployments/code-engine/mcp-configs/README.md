# Remote MCP client configs — Quantum OpenQASM MCP

Copy-paste `mcp.json` templates for connecting to the **Code Engine** gateway (`bridge.mjs` + dashboard).

**After deploy**, resolve your base URL (do not hardcode from docs):

```bash
export CE_ENDPOINT="$(ibmcloud ce app get --name quantum-mcp-remote --output json \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['status']['url'])")"
echo "$CE_ENDPOINT"
```

Replace `<CE_ENDPOINT>` in template files with that value (hostname only, no trailing slash).

📖 **Full walkthrough:** [../../docs/ide/REMOTE-MCP-SETUP.md](../../docs/ide/REMOTE-MCP-SETUP.md)  
⚡ **One command:** `../setup-remote-mcp.sh` · [IDE-SETUP.md](../IDE-SETUP.md)

---

## Files

| File | IDE | Transport |
|------|-----|-----------|
| `vscode-remote.json` | VS Code | Native SSE (`"type": "sse"`) |
| `cursor-remote-npx.json` | Cursor | `npx mcp-remote` (stdio bridge) |
| `cursor-remote-mcp-proxy.json` | Cursor | `uvx mcp-proxy` (recommended if SSE times out) |
| `bob-remote.json` | IBM Bob | `npx mcp-remote` |
| `antigravity-remote.json` | Antigravity | `npx mcp-remote` |
| `claude-desktop-remote.json` | Claude Desktop | `npx mcp-remote` |
| `workspace-vscode.json` | VS Code workspace | `.vscode/mcp.json.example` |
| `deployed/` | — | **Local generated output** from `generate-mcp-configs.sh` (gitignored) |

---

## Quick test (no IDE)

```bash
curl -sS "${CE_ENDPOINT}/health" | jq .
curl -sS -X POST "${CE_ENDPOINT}/test/api/run" | jq '.ok, .steps[].name'
```

Open **dashboard:** `${CE_ENDPOINT}/`  
Open **test UI:** `${CE_ENDPOINT}/test`

---

*No bug too small, no syntax too weird.*
