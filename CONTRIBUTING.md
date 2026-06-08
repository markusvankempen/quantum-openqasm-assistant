# Contributing to Quantum OpenQASM Assistant

Thank you for considering contributing to Quantum OpenQASM Assistant.

This project exposes IBM Quantum OpenQASM 2.0 circuit operations as [Model Context Protocol (MCP)](https://modelcontextprotocol.io) tools for AI agents in Cursor, VS Code, IBM Bob, Google Antigravity, and the Quantum Lab VS Code extension.

## Repository model

We use a **two-repo distribution model**:

| Repo | URL | Purpose |
|------|-----|---------|
| **Public** | [markusvankempen/quantum-openqasm-assistant](https://github.com/markusvankempen/quantum-openqasm-assistant) | README, project structure, contributing guidelines — **no extension source** |
| **Private dev** | *(private repo — coming soon)* | Full source, CI, VSIX + npm publish |

- **End users** install the VS Code extension from the Marketplace or a `.vsix` file — do not clone GitHub to run the extension in production.
- **Code contributions** require access to the private dev repository. Open a [GitHub issue](https://github.com/markusvankempen/quantum-openqasm-assistant/issues) first to discuss changes.
- **Documentation fixes** can be proposed against the public repo via pull request.

---

## Tech stack

### VS Code extension (`extension/`)

| Area | Technology |
|------|------------|
| **Runtime** | Node.js 18+ |
| **Language** | TypeScript |
| **Build** | esbuild (bundled `out/extension.js`, `out/server.js`) |
| **API** | VS Code Extension API + `@modelcontextprotocol/sdk` |
| **Key libraries** | `axios` — IBM Quantum REST; `express` — remote SSE server |

### MCP server (`extension/src/server.ts` + `packages/quantum-openqasm-mcp`)

| Area | Technology |
|------|------------|
| **Transport** | stdio (local) or SSE (IBM Code Engine) |
| **Auth** | IBM Cloud IAM API key → bearer token |
| **API** | IBM Quantum SamplerV2, OpenQASM 2.0 ISA |

### Code Engine deployment (`deployments/code-engine`)

| Area | Technology |
|------|------------|
| **Bridge** | `server-sse.ts` — SSE MCP over Express |
| **Cloud** | IBM Code Engine + Container Registry |

---

## Environment setup

We use [mise](https://mise.jdx.dev/) for a consistent Node.js environment.

### 1. Clone the private dev repository

Maintainers and invited contributors:

```bash
git clone <private-repo-url>
cd quantum-openqasm-assistant
cp .gitignore.private .gitignore
```

### 2. Install runtimes (mise)

```bash
mise install    # Node 20 per mise.toml
mise trust
```

Or install Node 18+ manually.

### 3. Install dependencies

```bash
mise run install
# or: cd extension && npm install
```

### 4. Configure environment

```bash
cp .env.example .env
# Edit .env with IBM_API_KEY, IBM_SERVICE_CRN, IBM_QUANTUM_ENDPOINT, IBM_QUANTUM_BACKEND
```

For IDE MCP integration, use **Quantum: Setup MCP** in the extension or see `docs/ide/LOCAL-MCP-SETUP.md` in the private repo. **Never commit** `.env`, `.cursor/mcp.json`, or API keys.

---

## Development workflow

### Common tasks (mise)

```bash
mise run install      # npm install in extension/
mise run build        # esbuild bundle to extension/out/
mise run package      # Build .vsix
mise run test-e2e     # IBM Quantum end-to-end smoke test
mise run ci           # build + e2e
```

### Manual workflow

```bash
cd extension
npm install
node esbuild.js
# Press F5 in VS Code to launch Extension Development Host
```

### Coding standards

- Match existing TypeScript style in `extension/src/`.
- Use OpenQASM **2.0 ISA** format for IBM hardware circuits.
- Use placeholders in docs — never real API keys or CRNs.
- Keep MCP tool names stable: `list_backends`, `submit_qasm_job`, `get_job_results`, etc.

---

## Pull request process

1. **Discuss** — Open a [GitHub issue](https://github.com/markusvankempen/quantum-openqasm-assistant/issues) for non-trivial changes.
2. **Branch** — Create a feature branch (`feature/quantum-lab`, `fix/mcp-setup`).
3. **Implement** — Keep changes focused; rebuild with `mise run build`.
4. **Test** — `mise run test-e2e` against IBM Quantum (requires credentials).
5. **Document** — Update `docs/` and `extension/docs/` as needed.
6. **Review** — Open a PR against the **private dev** repository.

---

## Getting help

- **Issues:** [github.com/markusvankempen/quantum-openqasm-assistant/issues](https://github.com/markusvankempen/quantum-openqasm-assistant/issues)
- **Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)
- **Project structure:** [docs/PROJECT-STRUCTURE.md](./docs/PROJECT-STRUCTURE.md)

Happy coding!

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*
