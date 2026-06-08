# Quantum OpenQASM Assistant

VS Code extension and MCP server for IBM Quantum OpenQASM development.

> **Repository policy:** This public GitHub repo publishes **only** [`README.md`](README.md) and [`docs/PROJECT-STRUCTURE.md`](docs/PROJECT-STRUCTURE.md). All other source, docs, and configs remain local until the full project is pushed to a **private** GitHub repo. For the private repo, use `.gitignore.private` as your `.gitignore`.

| Product | Identifier |
|---------|------------|
| **VS Code Extension** | `markusvankempen.quantum-openqasm-assistant` |
| **NPM MCP Server** | `@markusvankempen/quantum-openqasm-mcp` |
| **Extension repo** | [vscode-quantum-openqasm-assistant](https://github.com/markusvankempen/vscode-quantum-openqasm-assistant) |
| **MCP server repo** | [quantum-openqasm-mcp](https://github.com/markusvankempen/quantum-openqasm-mcp) |

---

## VS Code Extension

A first-of-its-kind VS Code extension that enables quantum computing development using **OpenQASM 2.0 ISA** (for IBM hardware) and the Model Context Protocol (MCP). This extension provides a pure TypeScript implementation that communicates directly with quantum cloud providers' REST APIs.

**Quantum Lab** includes **Load** and **Save** for `.qasm` circuits. Full documentation: [docs/README.md](docs/README.md).

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        VS Code IDE                               │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                  Quantum Assistant Extension               │  │
│  │                                                            │  │
│  │  ┌──────────────┐         ┌─────────────────────────┐    │  │
│  │  │   User UI    │────────▶│   MCP Client            │    │  │
│  │  │  (Commands)  │         │  (extension.ts)         │    │  │
│  │  └──────────────┘         └───────────┬─────────────┘    │  │
│  │                                        │                   │  │
│  │                                        │ stdio             │  │
│  │                                        ▼                   │  │
│  │                           ┌─────────────────────────┐     │  │
│  │                           │   MCP Server            │     │  │
│  │                           │   (server.ts)           │     │  │
│  │                           │                         │     │  │
│  │                           │  • submit_qasm_job      │     │  │
│  │                           │  • Provider routing     │     │  │
│  │                           └───────────┬─────────────┘     │  │
│  └───────────────────────────────────────┼───────────────────┘  │
└────────────────────────────────────────────┼──────────────────────┘
                                            │ HTTPS/REST
                                            ▼
                    ┌───────────────────────────────────────┐
                    │     Quantum Cloud Providers           │
                    │                                       │
                    │  ┌─────────────┐  ┌───────────────┐  │
                    │  │ IBM Quantum │  │ Open Quantum  │  │
                    │  │  (Primary)  │  │   (Planned)   │  │
                    │  └─────────────┘  └───────────────┘  │
                    └───────────────────────────────────────┘
```

## 🔄 Data Flow Diagram

```
┌──────────┐
│  User    │
│  Action  │
└────┬─────┘
     │
     │ 1. Opens OpenQASM file
     │ 2. Runs "Submit Circuit" command
     ▼
┌─────────────────────┐
│  VS Code Extension  │
│  (extension.ts)     │
└─────────┬───────────┘
          │
          │ 3. Reads QASM code from editor
          │ 4. Calls MCP tool via client
          ▼
┌─────────────────────┐
│   MCP Server        │
│   (server.ts)       │
└─────────┬───────────┘
          │
          │ 5. Routes to provider (IBM/Open Quantum)
          │ 6. Formats REST API request
          ▼
┌─────────────────────┐
│  IBM Quantum API    │
│  REST Endpoint      │
└─────────┬───────────┘
          │
          │ 7. Submits job to quantum backend
          │ 8. Returns Job ID
          ▼
┌─────────────────────┐
│   User receives     │
│   Job ID & Status   │
└─────────────────────┘
```

## 🌟 Features

- **Pure TypeScript Architecture**: No Python dependencies required
- **MCP Integration**: Uses Model Context Protocol for AI-assisted quantum programming
- **Multi-Provider Support**: Currently supports IBM Quantum (with Open Quantum planned)
- **OpenQASM 3**: Industry-standard quantum assembly language
- **Free Tier Access**: Works with IBM Quantum's free tier (10 minutes/month)

## 📋 Prerequisites

- Node.js (v18 or higher)
- VS Code (v1.85.0 or higher)
- IBM Quantum account (free tier available at [quantum.ibm.com](https://quantum.ibm.com))

## 🚀 Installation & Setup

### 1. Install Dependencies

```bash
cd extension
npm install
node esbuild.js
```

### 2. Compile the Extension

```bash
cd extension && node esbuild.js
```

### 3. Get Your IBM Cloud API Key

1. Sign up for a free account at [IBM Cloud](https://cloud.ibm.com)
2. Go to [IAM API Keys](https://cloud.ibm.com/iam/apikeys)
3. Click "Create +" and name your key
4. **Copy the API key immediately** (you won't see it again!)

### 4. Configure the Extension

**Option A: Using Diagnostics Panel (Recommended)**
1. Open the **quantum-openqasm-assistant** project root in VS Code or Cursor
2. Press `F5` to launch the Extension Development Host
3. In the new VS Code window:
   - Open Command Palette (`Cmd+Shift+P` or `Ctrl+Shift+P`)
   - Run "Quantum: Open Diagnostics Panel"
   - Paste your IBM Cloud API key
   - Click "💾 Save Configuration"
   - Click "🔌 Test IBM Cloud Connection" to verify

**Option B: Manual Configuration**
1. Open Settings (`Cmd+,` or `Ctrl+,`)
2. Search for "Quantum Assistant"
3. Paste your IBM Cloud API key in `quantumAssistant.ibmApiKey`

## 📖 Usage

### Diagnostics Panel

Open the diagnostics panel to:
- Test your IBM Cloud connection
- View available quantum backends
- Check system status
- Manage configuration

**Command:** `Quantum: Open Diagnostics Panel`

See [Diagnostics UI Guide](docs/ide/DIAGNOSTICS-UI.md) for detailed instructions.

### Submit a Quantum Circuit

1. Open the included `test.qasm` file (or create your own OpenQASM 3 file)
2. Open the Command Palette (`Cmd+Shift+P` or `Ctrl+Shift+P`)
3. Run the command: **"Quantum: Submit Current OpenQASM File"**
4. The extension will submit your circuit to IBM Quantum's simulator
5. You'll receive a Job ID confirmation

## 📐 OpenQASM 3 Circuit Structure

```
┌─────────────────────────────────────────────────────────┐
│                    OpenQASM 3 File                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  OPENQASM 3;                    ← Version declaration   │
│  include "stdgates.inc";        ← Standard gate library │
│                                                         │
│  qubit[2] q;                    ← Qubit allocation      │
│  bit[2] c;                      ← Classical bit storage │
│                                                         │
│  // Quantum Operations                                  │
│  h q[0];                        ← Hadamard gate         │
│  cx q[0], q[1];                 ← CNOT (entanglement)   │
│                                                         │
│  // Measurement                                         │
│  c = measure q;                 ← Collapse to classical │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Example: Bell State Circuit

The included `test.qasm` demonstrates quantum entanglement:

```qasm
OPENQASM 3;
include "stdgates.inc";

qubit[2] q;
bit[2] c;

// Create entanglement (Bell State)
h q[0];
cx q[0], q[1];

// Measure
c = measure q;
```

### Quantum State Visualization

```
Initial State:        After Hadamard:      After CNOT:
|00⟩                  |00⟩ + |10⟩          |00⟩ + |11⟩
                      ─────────────         ─────────────
q[0]: |0⟩             √2                   √2
q[1]: |0⟩
                      (Superposition)      (Entangled!)
```

## 🏗️ Architecture Details

### Component Breakdown

1. **MCP Server** (`src/server.ts`): Standalone Node.js process that exposes quantum REST APIs via MCP
2. **VS Code Extension** (`src/extension.ts`): Client that spawns the MCP server and provides UI integration
3. **OpenQASM Files**: Quantum circuits written in OpenQASM 3 format

### MCP Protocol Communication

```
┌─────────────────────────────────────────────────────────────┐
│                    MCP Communication Flow                    │
└─────────────────────────────────────────────────────────────┘

Extension (Client)                    Server (MCP)
─────────────────                    ─────────────

1. Initialize Connection
   ├─ spawn('node', ['server.js'])
   └─ StdioClientTransport ────────▶ StdioServerTransport
                                     
2. List Available Tools
   ├─ listTools() ─────────────────▶ ListToolsRequestSchema
   └◀─────────────────────────────── { tools: [...] }

3. Execute Tool
   ├─ callTool({
   │    name: 'submit_qasm_job',
   │    arguments: {
   │      qasm_string: "...",
   │      provider: "ibm_quantum",
   │      backend_name: "..."
   │    }
   │  }) ───────────────────────────▶ CallToolRequestSchema
   │                                  │
   │                                  ├─ Route to provider
   │                                  ├─ Format REST request
   │                                  └─ POST to IBM API
   │
   └◀─────────────────────────────── { content: [...], isError: false }

4. Display Result
   └─ showInformationMessage()
```

### REST API Integration

```
MCP Server                          IBM Quantum Cloud
───────────                         ─────────────────

POST Request:
{
  "program_id": "sampler",          ┌─────────────────┐
  "backend": "ibm_brisbane",        │  API Gateway    │
  "params": {                       └────────┬────────┘
    "pubs": [[                               │
      "OPENQASM 3;                           ▼
       include 'stdgates.inc';      ┌─────────────────┐
       qubit[2] q;                  │ Job Scheduler   │
       ..."                         └────────┬────────┘
    ]]                                       │
  }                                          ▼
}                                   ┌─────────────────┐
                                    │ Quantum Backend │
Response:                           │  (Simulator or  │
{                                   │   Real QPU)     │
  "id": "job_abc123",               └────────┬────────┘
  "status": "queued"                         │
}                                            ▼
                                    ┌─────────────────┐
                                    │ Results Storage │
                                    └─────────────────┘
```

## 🔧 Development

### Build Commands

- `npm run compile` - Compile TypeScript to JavaScript
- `npm run watch` - Watch mode for development
- `npm run package` - Package extension as .vsix file

### Project Structure

```
quantum-openqasm-assistant/
├── extension/
│   ├── src/            # extension.ts, server.ts, panels
│   └── out/            # Compiled JavaScript (esbuild)
├── scripts/            # MCP launcher, example runners
├── docs/               # Documentation
├── examples/           # Sample .qasm circuits
└── README.md
```

## 🌐 Supported Providers

### IBM Quantum (Primary)
- **Free Tier**: 10 minutes of quantum runtime per month
- **Simulators**: Free unlimited access
- **Hardware**: Access to real quantum processors
- **Backend Example**: `ibmq_qasm_simulator` (free simulator)

### Open Quantum (Planned)
- **Free Tier**: $50 in compute credits every 90 days
- **Providers**: IonQ, Rigetti, IQM

## 🔐 Security Notes

- API tokens are stored in VS Code settings (user-level)
- Tokens are passed to the MCP server via environment variables
- Never commit your API tokens to version control

## 📚 Resources

**[Documentation index](docs/README.md)** — full map of guides, API reference, and deployment docs.

### Learn OpenQASM (plain English)

- **[OpenQASM Primer](docs/OPENQASM-PRIMER.md)** — what `qreg`, `creg`, `x`, `measure`, and friends mean, with a line-by-line walkthrough of `1 + 1 = 2`
- **[Simple examples](examples/simple/README.md)** — beginner circuits with readable OpenQASM 3 versions
- **[Tips & Tricks](docs/TIPS-AND-TRICKS.md)** — MCP workflows and backend selection
- **[Local MCP setup](docs/ide/LOCAL-MCP-SETUP.md)** — Cursor, VS Code, Bob, Antigravity

### External links

- [IBM Quantum Documentation](https://quantum.ibm.com/docs)
- [OpenQASM 3 Specification](https://openqasm.com/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
- [Qiskit Documentation](https://qiskit.org/documentation/)

## 🤝 Contributing

This is a first-of-its-kind integration! Contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

MIT License - See LICENSE file for details

## 🎯 Roadmap

- [ ] Add support for Open Quantum provider
- [ ] Implement job status polling
- [ ] Add circuit visualization
- [ ] Support for AWS Braket
- [ ] LLM integration for AI-assisted circuit generation
- [ ] Circuit optimization suggestions
- [ ] Real-time backend status checking

## 🐛 Troubleshooting

### "MCP Client not initialized"
- Ensure the extension compiled successfully (`npm run compile`)
- Check that your IBM token is configured in settings

### "Failed to start Quantum MCP Server"
- Verify Node.js is installed and accessible
- Check the VS Code Developer Console for detailed errors

### TypeScript Errors
- Run `npm install` to ensure all dependencies are installed
- The TypeScript errors shown before compilation are expected (dependencies not yet installed)

## 💡 Tips

See **[Tips & Tricks](docs/TIPS-AND-TRICKS.md)** for workflows with `./linkto` paths wired into the extension sidebar.

- **[Pick a backend for Bell states](docs/TIPS-AND-TRICKS.md#pick-backend-for-bell-states)** — call `list_backends` via MCP; prefer `ibm_fez` when queue is 0
- Start with the free `ibmq_qasm_simulator` backend for testing
- Keep circuits small to stay within the free tier limits
- Use the IBM Quantum dashboard to monitor your usage and job history

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*

