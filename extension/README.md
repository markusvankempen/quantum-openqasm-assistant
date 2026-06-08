# Quantum OpenQASM Assistant — VS Code Extension

<!--
SEO: VS Code Extension | Quantum OpenQASM | IBM Quantum | MCP | OpenQASM 2.0 | QASM
quantum computing, quantum lab, quantum circuit, submit qasm, job polling, histogram,
ibm quantum, ibm fez, bell state, cursor, vscode, bob, antigravity, mcp server,
model context protocol, ai assistant, quantum hardware, qiskit, quantum programming
-->

[![VS Code Extension](https://img.shields.io/badge/VS%20Code-Extension-007ACC?logo=visualstudiocode&logoColor=white)](https://marketplace.visualstudio.com/items?itemName=markusvankempen.quantum-openqasm-assistant)
[![OpenQASM](https://img.shields.io/badge/OpenQASM-2.0-512BD4)](https://openqasm.com/)
[![MCP](https://img.shields.io/badge/MCP-Model%20Context%20Protocol-00A67E)](https://modelcontextprotocol.io/)
[![IBM Quantum](https://img.shields.io/badge/IBM-Quantum-0f62fe)](https://quantum.ibm.com/)

> **VS Code / Cursor extension** for **IBM Quantum** — run **OpenQASM 2.0** `.qasm` circuits on real **quantum hardware** via the **Model Context Protocol (MCP)**. **Quantum Lab** panel, **job polling**, **histogram** results, **Diagnostics** UI, and one-click **MCP registration** for Cursor, VS Code, Bob & Antigravity.

**Publisher:** `markusvankempen` · **Extension ID:** `quantum-openqasm-assistant` · **NPM MCP:** `@markusvankempen/quantum-openqasm-mcp`

**Search terms:** `vscode quantum extension` · `openqasm vscode` · `ibm quantum vscode` · `quantum lab` · `submit qasm` · `mcp quantum` · `cursor quantum` · `bell state hardware`

---

## Features

| Feature | Description |
|---------|-------------|
| **Quantum Lab** | Interactive panel with built-in example circuits |
| **Load / Save circuits** | Open and save OpenQASM 2.0 `.qasm` files from Quantum Lab |
| **Submit .qasm files** | One-click submit from the editor title bar |
| **Live job polling** | Auto-polls job status every 15s with elapsed time |
| **Histogram results** | Measurement counts visualized as a bar chart with Bell-state fidelity |
| **Ask AI prompts** | Circuit-writing and MCP tool prompts sent to IDE AI chat |
| **MCP local/remote** | Connects to a local spawned server or a remote SSE URL |
| **Multi-IDE MCP setup** | One-click register `quantum-openqasm-mcp` in Cursor, VS Code, Bob & Antigravity |
| **Diagnostics panel** | Test auth, backends, and save all settings from the UI |

---

## Quick Start

### 1. Install

```bash
code --install-extension quantum-openqasm-assistant-1.7.0.vsix
```

Or install from the Extensions Marketplace by searching **Quantum OpenQASM Assistant** (publisher: **markusvankempen**).

### 2. Configure

Open **Settings** (`Cmd+,`) and search `quantumAssistant`, or use **Quantum: Open Diagnostics Panel** from the sidebar.

| Setting | Description |
|---------|-------------|
| `ibmApiKey` | IBM Cloud API Key — [cloud.ibm.com/iam/apikeys](https://cloud.ibm.com/iam/apikeys) |
| `ibmServiceCrn` | Service CRN from your IBM Quantum instance |
| `ibmEndpoint` | Default: `https://us-east.quantum-computing.cloud.ibm.com` |
| `defaultBackend` | `ibm_fez` / `ibm_marrakesh` / `ibm_kingston` |
| `mcpMode` | `local` (spawn server.js) or `remote` (SSE URL) |
| `remoteMcpUrl` | Remote MCP endpoint (when `mcpMode = remote`) |

### 3. Use

- Click the **⚛** atom icon in the Activity Bar → **Open Quantum Lab**
- Select an example circuit (Bell State, GHZ, etc.) or paste your own
- Click **▶ Run on Hardware**
- Results appear as a histogram once the job completes

---

## Commands

| Command | Description |
|---------|-------------|
| `Quantum: Open Quantum Lab` | Open the main Quantum Lab panel |
| `Quantum: Submit Current OpenQASM File` | Submit the active `.qasm` editor file |
| `Quantum: Check Job Status` | Fetch results for a known job ID |
| `Quantum: Open Diagnostics Panel` | Configure credentials and test connection |
| `Quantum: Setup MCP (Cursor / VS Code / Bob / Antigravity)` | Register local MCP in all supported AI IDEs |
| `Quantum: Load OpenQASM 2.0 Circuit` | Open a `.qasm` file into the editor and Quantum Lab |
| `Quantum: Save OpenQASM 2.0 Circuit` | Save the active `.qasm` file or circuit from Quantum Lab |

---

## MCP Server

The extension spawns `out/server.js` as a local MCP server (stdio transport) and passes IBM credentials via environment variables. For remote deployments, set `mcpMode = remote` and provide a `remoteMcpUrl` pointing to an SSE-compatible MCP server.

Standalone npm package: [`@markusvankempen/quantum-openqasm-mcp`](https://github.com/markusvankempen/quantum-openqasm-assistant)

### AI IDE MCP integration (Cursor, VS Code, Bob, Antigravity)

Use **Quantum: Setup MCP** (sidebar or Diagnostics panel) to register `quantum-openqasm-mcp` in all supported IDEs.

| Document | Description |
|----------|-------------|
| [Main README](../README.md) | Project overview, architecture, quick start |
| [Local MCP setup](../docs/ide/LOCAL-MCP-SETUP.md) | Cursor, VS Code, Bob, Antigravity stdio config |
| [Deployment scenarios](../docs/deployments/DEPLOYMENT-SCENARIOS.md) | Local, Code Engine, Docker, hybrid |
| [Project structure](../docs/PROJECT-STRUCTURE.md) | Full repo layout |

---

## Development

```bash
cd extension
npm install
node esbuild.js          # bundle to out/
npm run package          # build VSIX
```

Repository: [github.com/markusvankempen/quantum-openqasm-assistant](https://github.com/markusvankempen/quantum-openqasm-assistant)

---

## Topics & keywords

`vscode-extension` · `quantum-computing` · `openqasm` · `qasm` · `ibm-quantum` · `quantum-lab` · `quantum-circuit` · `mcp` · `model-context-protocol` · `cursor` · `ibm-bob` · `antigravity` · `job-polling` · `histogram` · `bell-state` · `qiskit` · `quantum-hardware` · `ai-assistant`

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*
