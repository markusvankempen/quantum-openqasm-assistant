# Project Structure

Complete overview of the Quantum OpenQASM Assistant project organization.

## 📁 Directory Layout

```
quantum-openqasm-assistant/              # Project root (open this folder in VS Code / Cursor)
├── extension/                    # VS Code extension (Quantum Lab, MCP client)
│   ├── src/                      # TypeScript source
│   │   ├── extension.ts          # Extension entry point
│   │   ├── server.ts             # MCP server (local stdio)
│   │   ├── quantum-panel.ts      # Quantum Lab webview
│   │   └── …
│   ├── out/                      # Compiled JavaScript (esbuild)
│   ├── media/                    # Webview client scripts
│   ├── docs/                     # Docs bundled in VSIX
│   └── package.json
│
├── packages/
│   └── quantum-openqasm-mcp/     # Standalone npm MCP package
│
├── scripts/
│   ├── run-mcp-server.mjs        # Dev MCP launcher (repo root)
│   └── examples/                 # Run example circuits on IBM
│
├── docs/                         # Public documentation (see docs/README.md)
│   ├── ide/                      # MCP & Diagnostics guides
│   ├── reference/                # IBM Quantum API reference
│   └── deployments/              # Cloud deployment scenarios
├── Internal/                     # Private maintainer docs (gitignored)
├── examples/                     # Sample OpenQASM circuits
├── resources/config/             # MCP config templates
├── deployments/                  # Code Engine scripts & manifests
│
├── .env                          # IBM credentials (gitignored)
└── README.md
```

## 📄 File Descriptions

### Core Source Files

#### `src/extension.ts` (82 lines)
VS Code extension entry point with integrated MCP client.

**Key Components:**
- Extension activation/deactivation
- MCP client initialization
- Command registration (`quantum.submitCircuit`)
- Configuration management
- Child process spawning for MCP server

**Dependencies:**
- `vscode` - VS Code Extension API
- `@modelcontextprotocol/sdk/client` - MCP client SDK

#### `src/server.ts` (70 lines)
Standalone MCP server exposing quantum computing tools.

**Key Components:**
- MCP server initialization
- Tool registration (`submit_qasm_job`)
- Provider routing (IBM Quantum, Open Quantum)
- REST API integration
- Error handling

**Dependencies:**
- `@modelcontextprotocol/sdk/server` - MCP server SDK
- `axios` - HTTP client for REST APIs

### Configuration Files

#### `package.json`
NPM package manifest and VS Code extension configuration.

**Key Sections:**
- Extension metadata (name, version, publisher)
- VS Code engine compatibility
- Command contributions
- Configuration schema (IBM token settings)
- Build scripts
- Dependencies

#### `tsconfig.json`
TypeScript compiler configuration.

**Settings:**
- Module: NodeNext (ESM support)
- Target: ES2022
- Output directory: `out/`
- Source maps enabled
- Strict mode enabled
- Skip lib check for faster compilation

#### `config/mcp-server-only.json`
Template for using MCP server without VS Code extension.

**Usage:**
- Cursor IDE configuration
- Roo Cline (Bob) setup
- Antigravity IDE integration
- Claude Desktop integration

### Documentation Files

Public docs are indexed in [`docs/README.md`](./README.md).

| Location | Purpose |
|----------|---------|
| `README.md` | Project overview, quick start, architecture diagram |
| `docs/ARCHITECTURE.md` | Technical architecture and data flow |
| `docs/DEPLOYMENT.md` | Local build, test, VSIX install |
| `docs/PROJECT-STRUCTURE.md` | This file — repo layout |
| `docs/OPENQASM-PRIMER.md` | Beginner OpenQASM guide |
| `docs/TIPS-AND-TRICKS.md` | MCP workflows and backend tips |
| `docs/ide/LOCAL-MCP-SETUP.md` | Cursor, VS Code, Bob, Antigravity MCP |
| `docs/ide/DIAGNOSTICS-UI.md` | Credentials and connection testing |
| `docs/reference/API-ENDPOINTS.md` | IBM Quantum REST API reference |
| `docs/reference/IBM-QUANTUM-API-RESEARCH.md` | API discovery notes |
| `docs/reference/IBM-OPENAPI-TOOLS.md` | Extending MCP tools |
| `docs/deployments/DEPLOYMENT-SCENARIOS.md` | Cloud deployment scenarios |
| `extension/docs/` | Bundled copies for VSIX `linkto` paths |
| `Internal/` | Private: branding, publishing, status, funding (gitignored) |

### Example Files

#### `test.qasm` (12 lines)
Quick test circuit for development.

**Circuit:** Bell State (2-qubit entanglement)

#### `examples/bell-state.qasm` (16 lines)
Documented Bell State example with comments.

**Purpose:** Demonstrates quantum entanglement

#### `examples/ghz-state.qasm` (18 lines)
3-qubit GHZ state example.

**Purpose:** Multi-qubit entanglement demonstration

## 🔧 Build Artifacts

### Generated Files (not in git)

```
out/
├── extension.js          # Compiled extension code
├── extension.js.map      # Source map for debugging
├── server.js            # Compiled MCP server
└── server.js.map        # Source map for debugging

node_modules/            # NPM dependencies (262 packages)

*.vsix                   # Packaged extension (from npm run package)
```

## 📊 File Statistics

```
Source Code:
- TypeScript: 2 files, ~152 lines
- Configuration: 3 files (JSON)
- Examples: 3 files (OpenQASM)

Documentation:
- Markdown: 6 files, ~1,800 lines
- Diagrams: ASCII art embedded in docs

Total Project Size:
- Source: ~2 KB
- Documentation: ~100 KB
- Dependencies: ~50 MB (node_modules)
- Compiled: ~10 KB (out/)
```

## 🎯 Key Entry Points

### For Users

1. **Install Extension:** Open the `quantum-openqasm-assistant/` project root in VS Code
2. **Read Docs:** Start with `README.md`
3. **Try Examples:** Open `examples/bell-state.qasm`

### For Developers

1. **Main Code:** `extension/src/extension.ts` and `extension/src/server.ts`
2. **Build:** `cd extension && node esbuild.js`
3. **Architecture:** `docs/ARCHITECTURE.md`

### For AI IDE Integration

1. **MCP Config:** `resources/config/mcp-server-only.json`
2. **Setup Guide:** `docs/ide/LOCAL-MCP-SETUP.md`
3. **Server Binary:** `extension/out/server.js` (after esbuild)

## 🔄 Development Workflow

```
1. Edit source files
   └─ src/*.ts

2. Compile TypeScript
   └─ npm run compile
   └─ Generates out/*.js

3. Test in VS Code
   └─ Press F5
   └─ Extension Development Host launches

4. Package for distribution
   └─ npm run package
   └─ Generates *.vsix file
```

## 📦 Distribution Files

### VS Code Marketplace Package

```
quantum-openqasm-assistant-1.6.0.vsix
├── extension.js
├── server.js
├── package.json
├── README.md
└── examples/
```

### Standalone MCP Server

```
packages/quantum-openqasm-mcp/
├── server.js
├── package.json
└── config/mcp-server-only.json
```

## 🔐 Sensitive Files (.gitignore)

```
node_modules/           # Dependencies
out/                   # Build artifacts
*.vsix                 # Packaged extensions
.env                   # Environment variables
.vscode-test/          # Test artifacts
*.log                  # Log files
```

## 📚 Documentation Map

```
Start Here:
└─ README.md
   └─ docs/README.md (index)
      ├─ Quick Start → docs/DEPLOYMENT.md
      ├─ Architecture → docs/ARCHITECTURE.md
      ├─ Multi-IDE Setup → docs/ide/LOCAL-MCP-SETUP.md
      ├─ Diagnostics → docs/ide/DIAGNOSTICS-UI.md
      └─ Extend Tools → docs/reference/IBM-OPENAPI-TOOLS.md

Private (Internal/):
├─ Branding → Internal/BRANDING.md
├─ Publishing → Internal/PUBLISHING.md
├─ Status → Internal/STATUS.md
└─ Funding & issues → Internal/OUTSTANDING-FUNDING-AND-ISSUES.md
```

## 🎓 Learning Path

### Beginner
1. Read `README.md`
2. Try `examples/bell-state.qasm`
3. Follow `docs/DEPLOYMENT.md` quick start

### Intermediate
1. Study `docs/ARCHITECTURE.md`
2. Review `extension/src/extension.ts` and `extension/src/server.ts`
3. Configure MCP using `docs/ide/LOCAL-MCP-SETUP.md`

### Advanced
1. Extend tools using `docs/reference/IBM-OPENAPI-TOOLS.md`
2. Implement additional providers
3. Contribute to project

## 🤝 Contributing

### Adding New Features

1. **New MCP Tool:**
   - Add to `extension/src/server.ts`
   - Document in `docs/reference/IBM-OPENAPI-TOOLS.md`
   - Add example usage

2. **New Example Circuit:**
   - Create in `examples/`
   - Add comments explaining the circuit
   - Reference in `README.md`

3. **New Documentation:**
   - Add to `docs/`
   - Update this file
   - Link from `README.md`

### File Naming Conventions

- **Source:** `kebab-case.ts`
- **Docs:** `SCREAMING-KEBAB.md`
- **Config:** `kebab-case.json`
- **Examples:** `kebab-case.qasm`

## 📞 Quick Reference

| Need | File |
|------|------|
| Install extension | `README.md` |
| Doc index | `docs/README.md` |
| Build project | `docs/DEPLOYMENT.md` |
| Understand architecture | `docs/ARCHITECTURE.md` |
| Setup MCP in IDEs | `docs/ide/LOCAL-MCP-SETUP.md` |
| Add IBM API tools | `docs/reference/IBM-OPENAPI-TOOLS.md` |
| Publish release | `Internal/PUBLISHING.md` |
| Example circuits | `examples/` |
| MCP server config | `resources/config/mcp-server-only.json` |
| Extension code | `extension/src/extension.ts` |
| Server code | `extension/src/server.ts` |

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*

