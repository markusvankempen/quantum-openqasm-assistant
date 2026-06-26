# Quantum OpenQASM Assistant

<!--
SEO: Quantum OpenQASM Assistant | VS Code Extension | MCP Server | IBM Quantum | OpenQASM 2.0 | QASM | Qiskit
quantum computing, quantum computer, qubit, qubits, quantum circuit, quantum circuits, quantum hardware,
quantum lab, quantum programming, quantum physics, quantum experiment, quantum job, quantum backend,
ibm quantum, ibm cloud, ibm fez, ibm marrakesh, sampler v2, bell state, ghz state, cloud quantum,
openqasm, openqasm 2.0, qasm, .qasm, model context protocol, mcp, mcp server, cursor, vscode,
visual studio code, ibm bob, antigravity, copilot, ai assistant, ai agent, llm tools,
typescript, nodejs, histogram, job polling, code engine, sse, stdio, quantum simulator
-->

[![VS Code Extension](https://img.shields.io/badge/VS%20Code-Extension-007ACC?logo=visualstudiocode&logoColor=white)](https://marketplace.visualstudio.com/items?itemName=markusvankempen.quantum-openqasm-assistant)
[![npm MCP](https://img.shields.io/npm/v/@markusvankempen/quantum-openqasm-mcp.svg?label=npm%20MCP)](https://www.npmjs.com/package/@markusvankempen/quantum-openqasm-mcp)
[![GitHub release](https://img.shields.io/github/v/release/markusvankempen/quantum-openqasm-assistant?label=release)](https://github.com/markusvankempen/quantum-openqasm-assistant/releases)
[![Qiskit Ecosystem](https://qisk.it/e-bd91d04b)](https://qisk.it/e)
[![OpenQASM](https://img.shields.io/badge/OpenQASM-2.0-512BD4)](https://openqasm.com/)
[![MCP](https://img.shields.io/badge/MCP-Model%20Context%20Protocol-00A67E)](https://modelcontextprotocol.io/)
[![IBM Quantum](https://img.shields.io/badge/IBM-Quantum-0f62fe)](https://quantum.ibm.com/)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

<p align="center">
  <img src="extension/media/icon.png" alt="Quantum OpenQASM Assistant — atomic icon with cyan nucleus and purple orbits" width="128" />
</p>

> **Quantum OpenQASM Assistant** is a **VS Code extension** and **Model Context Protocol (MCP) server** for **IBM Quantum** — submit **OpenQASM 2.0** circuits to real **quantum hardware** and simulators from **Cursor**, **VS Code**, **IBM Bob**, and **Google Antigravity**. Includes **Quantum Lab** (interactive circuit editor), live **job polling**, measurement **histograms**, **Bell state** / **GHZ** examples, **SamplerV2** REST integration, and one-click **MCP setup** for AI coding assistants.

**Search terms:** `quantum computing` · `openqasm` · `qasm` · `ibm quantum` · `qiskit` · `quantum circuit` · `quantum hardware` · `mcp server` · `model context protocol` · `cursor mcp` · `vscode quantum` · `ai quantum assistant` · `quantum programming` · `qubit` · `bell state`

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*

---

## Overview

Quantum OpenQASM Assistant connects AI agents and developers to **IBM Quantum** through a pure TypeScript MCP server and VS Code extension. Submit OpenQASM 2.0 ISA circuits, poll job status, and view measurement histograms — locally via stdio or remotely via SSE on IBM Code Engine.

| Product | Identifier | Version |
|---------|------------|---------|
| **VS Code Extension** | [`markusvankempen.quantum-openqasm-assistant`](https://marketplace.visualstudio.com/items?itemName=markusvankempen.quantum-openqasm-assistant) | **1.9.2** |
| **NPM MCP Server** | [`@markusvankempen/quantum-openqasm-mcp`](https://www.npmjs.com/package/@markusvankempen/quantum-openqasm-mcp) | **1.9.2** |
| **MCP Registry** | [`io.github.markusvankempen/quantum-openqasm-mcp`](https://registry.modelcontextprotocol.io/servers/io.github.markusvankempen/quantum-openqasm-mcp) | **1.9.2** |
| **Public repo** | [quantum-openqasm-assistant](https://github.com/markusvankempen/quantum-openqasm-assistant) | tag `v1.9.2` |

```mermaid
graph TB
    subgraph clients [MCP Clients]
        Cursor[Cursor / VS Code]
        Bob[IBM Bob]
        AG[Antigravity]
        Lab[Quantum Lab Extension]
    end

    subgraph mcp [MCP Server]
        Local["server.ts stdio"]
        Remote["server-sse.ts SSE"]
    end

    IBM["IBM Quantum REST API<br/>SamplerV2 · OpenQASM 2.0"]

    Cursor -->|stdio| Local
    Bob -->|stdio| Local
    AG -->|stdio| Local
    Lab -->|stdio or SSE| Local
    Lab -->|SSE| Remote
    Local --> IBM
    Remote --> IBM
```

```mermaid
sequenceDiagram
    participant User
    participant Ext as VS Code Extension
    participant MCP as MCP Server
    participant IBM as IBM Quantum API

    User->>Ext: Submit .qasm circuit
    Ext->>MCP: submit_qasm_job
    MCP->>IBM: POST /jobs (SamplerV2)
    IBM-->>MCP: job id
    MCP-->>Ext: job id
    loop Poll every 15s
        Ext->>MCP: get_job_status
        MCP->>IBM: GET /jobs/{id}
        IBM-->>Ext: Queued → Running → Completed
    end
    Ext->>MCP: get_job_results
    MCP->>IBM: GET /jobs/{id}/results
    IBM-->>Ext: measurement histogram
```

📖 **[Documentation hub → docs/README.md](./docs/README.md)** · **[Project structure → docs/PROJECT-STRUCTURE.md](./docs/PROJECT-STRUCTURE.md)** · **[OpenQASM Primer → docs/OPENQASM-PRIMER.md](./docs/OPENQASM-PRIMER.md)** · **[Tips & Tricks → docs/TIPS-AND-TRICKS.md](./docs/TIPS-AND-TRICKS.md)** · **[Architecture → docs/ARCHITECTURE.md](./docs/ARCHITECTURE.md)** · **[Local MCP setup → docs/ide/LOCAL-MCP-SETUP.md](./docs/ide/LOCAL-MCP-SETUP.md)** · **[Qiskit Developer Pack → docs/ide/QISKIT-DEVELOPER-PACK.md](./docs/ide/QISKIT-DEVELOPER-PACK.md)** · **[Deployment → docs/deployments/DEPLOYMENT-SCENARIOS.md](./docs/deployments/DEPLOYMENT-SCENARIOS.md)** · **[Extension → extension/README.md](./extension/README.md)** · **[Contributing → CONTRIBUTING.md](./CONTRIBUTING.md)**

> **Repository policy:** This public GitHub repo publishes overview and setup documentation. Extension **source code**, scripts, and examples live in the **private dev repo** (use `.gitignore.private` when setting it up).

---

## Features

| Feature | Description |
|---------|-------------|
| **Quantum Lab** | Interactive panel with example circuits and histogram results |
| **OpenQASM 2.0** | IBM hardware ISA format (`rz`, `sx`, `cz` native gates) |
| **MCP tools** | `list_backends`, `submit_qasm_job`, `get_job_status`, `get_job_results`, and more |
| **Multi-IDE MCP** | One-click setup for Cursor, VS Code, Bob, Antigravity & Claude Desktop |
| **Qiskit Developer Pack** | Bundle Qiskit MCP servers + quantum-openqasm-mcp from Diagnostics |
| **Local / remote** | stdio MCP locally or SSE via IBM Code Engine |
| **Diagnostics** | Test IAM auth, list backends, save credentials from the UI |

---

## MCP tools

| Tool | Description |
|------|-------------|
| `list_backends` | Available IBM Quantum backends, status, queue |
| `get_backend` | Details for a specific backend |
| `submit_qasm_job` | Submit OpenQASM 2.0 circuit |
| `get_job_status` | Poll job state |
| `get_job_results` | Measurement counts / histogram data |
| `cancel_job` | Cancel a running job |

---

## Quick start

### Prerequisites

- Node.js 18+ ([mise](https://mise.jdx.dev/) recommended — see `mise.toml`)
- IBM Cloud API key + Quantum Service CRN — [cloud.ibm.com/iam/apikeys](https://cloud.ibm.com/iam/apikeys)

### Build (private dev repo)

```bash
mise run install
mise run build
```

### Configure

```bash
cp .env.example .env
# IBM_API_KEY, IBM_SERVICE_CRN, IBM_QUANTUM_ENDPOINT, IBM_QUANTUM_BACKEND
```

Or use **Quantum → Settings & Diagnostics** in the extension.

### Test

```bash
mise run test-e2e
# or: Press F5 in VS Code → Quantum Lab → Run on Hardware
```

### Install extension

```bash
mise run package
code --install-extension extension/quantum-openqasm-assistant-*.vsix
```

---

## Architecture at a glance

```
quantum-openqasm-assistant/
├── extension/              # VS Code extension + bundled MCP server
│   ├── src/extension.ts    # Extension entry, MCP client
│   ├── src/server.ts       # Local stdio MCP server
│   ├── src/server-sse.ts   # Remote SSE MCP server
│   └── out/                # esbuild output
├── packages/
│   └── quantum-openqasm-mcp/   # Standalone npm MCP package
├── scripts/                # MCP launcher, e2e tests, examples
├── docs/                   # Published documentation
│   └── QISKIT-INTEGRATION.md  # Qiskit → OpenQASM → IBM Quantum
├── examples/               # Qiskit export script (public)
├── deployments/            # Client modes + infrastructure
│   ├── README.md           # Hub: 5 client modes + 6 infra scenarios
│   ├── extension-only/     # Mode 1
│   ├── extension-mcp-local/# Mode 2
│   ├── mcp-npm/            # Mode 3
│   ├── extension-remote-mcp/# Mode 4
│   ├── mcp-remote-sse/     # Mode 5
│   ├── code-engine/        # IBM Code Engine
│   ├── local-bridge/       # Dev gateway
│   ├── docker-sse/         # Self-hosted
│   ├── secured-remote/     # Auth tiers
│   ├── wxo-orchestrate/    # Orchestrate agents
│   └── ci-cd/              # Pipeline smoke tests
└── Internal/               # Branding, publishing, status (gitignored)
```

See **[docs/PROJECT-STRUCTURE.md](./docs/PROJECT-STRUCTURE.md)** for the complete file map.

---

## Documentation

| Guide | Description |
|-------|-------------|
| [Documentation hub](./docs/README.md) | Index of all published guides |
| [Architecture](./docs/ARCHITECTURE.md) | System design, MCP, IBM API flow |
| [OpenQASM Primer](./docs/OPENQASM-PRIMER.md) | Learn OpenQASM 2.0 in plain English |
| [Qiskit integration](./docs/QISKIT-INTEGRATION.md) | Qiskit → export QASM → IBM hardware via MCP / Lab |
| [Tips & Tricks](./docs/TIPS-AND-TRICKS.md) | Backend selection, MCP workflows |
| [Project structure](./docs/PROJECT-STRUCTURE.md) | Complete repo layout |
| [Extension README](./extension/README.md) | VS Code extension features, commands |
| [Local MCP setup](./docs/ide/LOCAL-MCP-SETUP.md) | Cursor, VS Code, Bob, Antigravity |
| [Deployment hub](./deployments/README.md) | 5 client modes + infra (CE, Docker, WxO, CI) |
| [Deployment scenarios](./docs/deployments/DEPLOYMENT-SCENARIOS.md) | Local, Code Engine, Docker, hybrid |

---

## Qiskit Integration

Design circuits in **Qiskit**, export to **OpenQASM 2.0**, and run on IBM Quantum hardware via MCP or Quantum Lab:

```python
from qiskit import QuantumCircuit, qasm2

qc = QuantumCircuit(2, 2)
qc.h(0)
qc.cx(0, 1)
qc.measure([0, 1], [0, 1])

print(qasm2.dumps(qc))  # → submit via MCP or paste into Quantum Lab
```

```text
OPENQASM 2.0;
include "qelib1.inc";
qreg q[2]; creg c[2];
h q[0];
cx q[0],q[1];
measure q[0] -> c[0];
measure q[1] -> c[1];
```

**No Qiskit dependency at runtime** — the MCP server speaks OpenQASM + IBM Quantum REST directly.

- Full guide: [docs/QISKIT-INTEGRATION.md](./docs/QISKIT-INTEGRATION.md)
- **Qiskit Developer Pack** (Qiskit MCP + OpenQASM): [docs/ide/QISKIT-DEVELOPER-PACK.md](./docs/ide/QISKIT-DEVELOPER-PACK.md)
- Example script: [examples/qiskit-bell-export.py](./examples/qiskit-bell-export.py)

---

## Security

- API keys live in VS Code settings or `~/.quantum-openqasm-mcp/.env` — never in git
- `.env`, `Internal/`, and IDE `mcp.json` files are gitignored
- Report issues via [GitHub Issues](https://github.com/markusvankempen/quantum-openqasm-assistant/issues)

---

## Contributing

Contributions welcome! See **[CONTRIBUTING.md](./CONTRIBUTING.md)** for the two-repo model, mise tasks, and PR process.

Please read our **[CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)**.

---

## License

[Apache License 2.0](./LICENSE)

---

## Topics & keywords

`quantum-computing` · `quantum-computer` · `openqasm` · `openqasm-2` · `qasm` · `ibm-quantum` · `ibm-cloud` · `qiskit` · `quantum-circuit` · `quantum-hardware` · `quantum-lab` · `quantum-programming` · `quantum-physics` · `qubit` · `bell-state` · `quantum-job` · `quantum-backend` · `mcp` · `model-context-protocol` · `mcp-server` · `vscode-extension` · `cursor` · `ibm-bob` · `antigravity` · `copilot` · `ai-assistant` · `typescript` · `nodejs` · `histogram` · `sampler-v2` · `code-engine` · `cloud-quantum`

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*
