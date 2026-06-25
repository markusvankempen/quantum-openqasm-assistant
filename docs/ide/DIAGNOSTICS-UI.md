# Diagnostics UI Guide

The Quantum Assistant includes a comprehensive diagnostics panel for testing connectivity and managing configuration.

## 🎯 Features

### 1. Configuration Management
- **Save IBM Cloud API Key** - Securely store your API key in VS Code settings
- **Load Configuration** - Retrieve saved settings
- **Password-protected input** - API key is masked in the UI

### 2. Connection Testing
- **Test IBM Cloud Connection** - Validates API key and IAM authentication
- **Test Backend Access** - Lists available quantum backends with status

### 3. System Information
- Extension version
- MCP protocol status
- Supported providers
- OpenQASM version

## 🚀 Opening the Diagnostics Panel

### Method 1: Command Palette
1. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows/Linux)
2. Type "Quantum: Open Diagnostics Panel"
3. Press Enter

### Method 2: First-Time Welcome
- On first activation, the extension shows a welcome message
- Click "Open Diagnostics" to launch the panel

## 🔑 Getting Your IBM Cloud API Key

### Step 1: Create IBM Cloud Account
1. Visit [IBM Cloud](https://cloud.ibm.com/)
2. Sign up for a free account
3. Verify your email

### Step 2: Generate API Key
1. Go to [IBM Cloud IAM API Keys](https://cloud.ibm.com/iam/apikeys)
2. Click "Create +"
3. Enter a name (e.g., "Quantum Assistant")
4. Click "Create"
5. **Important:** Copy the API key immediately (you won't see it again!)

### Step 3: Configure Extension
1. Open Diagnostics Panel
2. Paste your API key in the input field
3. Click "💾 Save Configuration"

## 🧪 Testing Your Connection

### Test 1: IBM Cloud Authentication

```
1. Enter your API key
2. Click "🔌 Test IBM Cloud Connection"
3. Wait for result:
   ✅ Success: "Successfully authenticated with IBM Cloud"
   ❌ Error: Shows specific error message
```

**Common Errors:**
- "Invalid API key" - Check if key was copied correctly
- "Authentication failed" - Verify account is active
- "Network error" - Check internet connection

### Test 2: Backend Access

```
1. After successful authentication
2. Click "🖥️ Test Backend Access"
3. View available backends:
   - Backend name
   - Number of qubits
   - Current status
   - Queue depth
```

**Example Output:**
```
ibmq_qasm_simulator (32 qubits, online)
ibm_brisbane (127 qubits, online) - Queue: 3 jobs
ibm_kyoto (127 qubits, online) - Queue: 5 jobs
```

## 📊 Understanding Backend Information

### Backend Properties

| Property | Description |
|----------|-------------|
| **Name** | Unique identifier (e.g., `ibm_brisbane`) |
| **Qubits** | Number of quantum bits available |
| **Status** | `online`, `offline`, `maintenance` |
| **Queue** | Number of jobs waiting to execute |

### Choosing a Backend

**For Testing:**
- Use `ibmq_qasm_simulator` (free, unlimited)
- No queue time
- Perfect for development

**For Real Hardware:**
- Check queue depth (lower is better)
- Consider qubit count for your circuit
- Free tier: 10 minutes/month runtime

## 🔧 Troubleshooting

### Issue: "API key missing from environment"

**Solution:**
1. Open Diagnostics Panel
2. Enter your API key
3. Click "Save Configuration"
4. Restart VS Code

### Issue: "Failed to fetch backends"

**Possible Causes:**
1. Invalid API key
2. Network connectivity issues
3. IBM Cloud service outage

**Steps to Resolve:**
1. Test connection first
2. Check [IBM Cloud Status](https://cloud.ibm.com/status)
3. Verify firewall settings

### Issue: "Token expired"

**Solution:**
- The extension automatically refreshes tokens
- If error persists, clear cache by restarting VS Code

## 🎨 UI Components

### Configuration Section
```
┌─────────────────────────────────────┐
│ Configuration                       │
├─────────────────────────────────────┤
│ IBM Cloud API Key:                  │
│ [••••••••••••••••••••••••••••••]   │
│                                     │
│ [💾 Save] [📂 Load]                │
└─────────────────────────────────────┘
```

### Connection Tests Section
```
┌─────────────────────────────────────┐
│ Connection Tests                    │
├─────────────────────────────────────┤
│ [🔌 Test Connection]                │
│ [🖥️ Test Backends]                  │
│                                     │
│ ✅ Successfully authenticated       │
│                                     │
│ Backends:                           │
│ • ibmq_qasm_simulator (32 qubits)  │
│ • ibm_brisbane (127 qubits)        │
└─────────────────────────────────────┘
```

### System Information Section
```
┌─────────────────────────────────────┐
│ System Information                  │
├─────────────────────────────────────┤
│ Extension Version: 1.0.0            │
│ MCP Protocol: Enabled               │
│ Supported Providers:                │
│   • IBM Quantum                     │
│   • Open Quantum (planned)          │
│ OpenQASM Version: 3.0               │
└─────────────────────────────────────┘
```

## 🔐 Security Notes

### API Key Storage
- Stored in VS Code user settings
- Not included in workspace settings
- Not committed to version control
- Encrypted by VS Code's secure storage

### Token Management
- Access tokens cached for performance
- Automatically refreshed before expiry
- Cleared on VS Code restart
- Never logged or displayed

### Best Practices
1. **Never share your API key**
2. **Rotate keys regularly** (every 90 days)
3. **Use separate keys** for different projects
4. **Delete unused keys** from IBM Cloud console

## 📱 Keyboard Shortcuts

| Action | Shortcut |
|--------|----------|
| Open Diagnostics | `Cmd+Shift+P` → "Quantum: Open Diagnostics" |
| Save Config | Click button or `Enter` in input field |
| Close Panel | `Cmd+W` (Mac) or `Ctrl+W` (Windows/Linux) |

## 🎯 Quick Start Workflow

```
1. Open Diagnostics Panel
   └─ Command Palette → "Quantum: Open Diagnostics"

2. Get IBM Cloud API Key
   └─ Visit https://cloud.ibm.com/iam/apikeys

3. Configure Extension
   └─ Paste key → Save Configuration

4. Test Connection
   └─ Click "Test IBM Cloud Connection"

5. View Backends
   └─ Click "Test Backend Access"

6. Start Coding!
   └─ Open .qasm file → Submit Circuit
```

## 🆘 Getting Help

### Extension Issues
- Check VS Code Developer Console (`Help` → `Toggle Developer Tools`)
- Look for error messages in Console tab

### IBM Cloud Issues
- Visit [IBM Quantum Support](https://quantum.ibm.com/support)
- Check [IBM Cloud Status](https://cloud.ibm.com/status)

### Community Support
- GitHub Issues: [Report bugs]
- Documentation: [See README.md](../README.md)

## 🔄 Updates

The diagnostics panel automatically reflects:
- Configuration changes
- Backend availability updates
- System status changes

No manual refresh needed!

## 📚 Related Documentation

- [Documentation index](../README.md)
- [Main README](../../README.md) — project overview
- [Local MCP setup](./LOCAL-MCP-SETUP.md) — Cursor, VS Code, Bob, Antigravity
- [IBM OpenAPI Tools](../reference/IBM-OPENAPI-TOOLS.md) — extending functionality
- [Architecture](../ARCHITECTURE.md) — technical details

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*

