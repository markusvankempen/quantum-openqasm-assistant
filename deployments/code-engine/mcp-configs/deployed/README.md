# Generated MCP configs (local only — not committed)

This folder is populated by **`generate-mcp-configs.sh`** after deploy. Files here contain your **project-specific** `CE_ENDPOINT` and must **not** be committed to git.

```bash
cd deployments/code-engine
./generate-mcp-configs.sh
```

Creates (gitignored):

- `CE_ENDPOINT.txt` — resolved base URL
- `vscode-mcp.json` — copy to VS Code `mcp.json`
- `cursor-mcp.json` — copy to `~/.cursor/mcp.json`
- `cursor-mcp-proxy.json` — Cursor with `uvx mcp-proxy`

**Templates with `<CE_ENDPOINT>` placeholder:** see parent folder `mcp-configs/*.json`.

📖 [Remote MCP setup](../../../docs/ide/REMOTE-MCP-SETUP.md)
