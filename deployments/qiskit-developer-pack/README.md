# Qiskit Developer Pack

One-shot MCP bundle: **[Qiskit MCP Servers](https://github.com/Qiskit/mcp-servers)** + **[@markusvankempen/quantum-openqasm-mcp](https://www.npmjs.com/package/@markusvankempen/quantum-openqasm-mcp)** for Cursor, VS Code, IBM Bob, Antigravity, and Claude Desktop.

📖 **[Full guide](../../docs/ide/QISKIT-DEVELOPER-PACK.md)** · **[Deployments hub](../README.md)** · **[Qiskit integration](../../docs/QISKIT-INTEGRATION.md)**

---

## What you get

| MCP server | Role | Auth |
|------------|------|------|
| **qiskit-docs** | Search Qiskit documentation | None |
| **qiskit** | Build circuits, transpile, export QASM3/QPY | None |
| **quantum-openqasm-mcp** | Submit **OpenQASM 2.0** to IBM **Sampler V2** | `~/.quantum-openqasm-mcp/.env` |
| **qiskit-ibm-runtime** *(full tier)* | Qiskit primitives on IBM hardware | `QISKIT_IBM_TOKEN` |

**Complement, not duplicate:** Qiskit MCP helps agents **write Qiskit Python**. Quantum OpenQASM Assistant helps **run OpenQASM on IBM Quantum** (including exports from Qiskit) with a lighter TypeScript runtime.

---

## Quick setup

### Prerequisites

- **uv** / **uvx** — [install uv](https://docs.astral.sh/uv/) (runs Qiskit MCP servers)
- **Node.js 18+** / **npx** — for `quantum-openqasm-mcp`
- **IBM credentials** — see [Local MCP setup](../../docs/ide/LOCAL-MCP-SETUP.md)
- **Python** *(optional, for transpile scripts)* — `qiskit` + `qiskit-ibm-runtime` in `~/.quantum-openqasm-mcp/qiskit-venv` (setup script offers install)

### Run the script

```bash
# Core bundle (docs + qiskit + openqasm execution)
./deployments/qiskit-developer-pack/setup-qiskit-developer-pack.sh --ide cursor

# Install Python transpile deps without prompt
./deployments/qiskit-developer-pack/setup-qiskit-developer-pack.sh --install-python-deps --yes --ide cursor

# Full bundle (+ IBM Runtime MCP)
QISKIT_IBM_TOKEN=your_token ./deployments/qiskit-developer-pack/setup-qiskit-developer-pack.sh \
  --tier full --ide all
```

Interactive mode (no flags):

```bash
./deployments/qiskit-developer-pack/setup-qiskit-developer-pack.sh
```

Reload your IDE after install.

---

## Tiers

| Tier | Servers | When to use |
|------|---------|-------------|
| **core** (default) | docs + qiskit + openqasm | Learn Qiskit, build circuits, run OQ2 on hardware |
| **full** | core + ibm-runtime | Also run Qiskit Runtime primitives via MCP |
| **agent** | full + code-assistant + ibm-transpiler | **Phase 2b** — AI write, transpile, run, submit (recommended) |

Optional extras (manual): `qiskit-gym-mcp-server` — see [Qiskit MCP Servers](https://github.com/Qiskit/mcp-servers).

---

## Extension (coming)

The Quantum OpenQASM Assistant VS Code extension will add **Quantum → Setup Qiskit Developer Pack** (same merge logic as this script). Until then, use the script or copy templates from `mcp-configs/`.

---

## Files

```
deployments/qiskit-developer-pack/
├── README.md
├── setup-qiskit-developer-pack.sh
└── mcp-configs/
    ├── cursor-developer-pack-core.json
    ├── cursor-developer-pack-full.json
    ├── vscode-developer-pack-core.json
    └── vscode-developer-pack-full.json
```

Generated locally (gitignored): `mcp-configs/deployed/`

---

## Roadmap

**Phase 1 (now):** Developer Pack script + docs  
**Phase 2:** Extension button + unified **Qiskit Lab** (Aer sim → export → hardware)

See `Internal/QISKIT-DEVELOPER-PACK.md` (private dev repo) for strategy.
