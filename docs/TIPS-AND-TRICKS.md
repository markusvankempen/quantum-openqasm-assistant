# Tips & Tricks

<!--
SEO: IBM Quantum tips | MCP workflows | backend selection | bell state | free tier
quantum openqasm tips, list_backends, ibm_fez, quantum lab, cursor mcp quantum
-->

> Practical workflows for the **Quantum OpenQASM Assistant** and **quantum-openqasm-mcp** MCP server — backend selection, simulators, free tier, and job monitoring on **IBM Quantum**.

📖 **[Docs index](./README.md)** · **[OpenQASM Primer](./OPENQASM-PRIMER.md)** · **[Local MCP setup](./ide/LOCAL-MCP-SETUP.md)** · **[Extension README](../extension/README.md)**

Each tip has a `./linkto` path used in the extension sidebar (Quantum activity bar → **Tips & Tricks**).

| Tip | `./linkto` |
|-----|------------|
| Pick a backend for Bell states | `./docs/TIPS-AND-TRICKS.md#pick-backend-for-bell-states` |
| Start with the simulator | `./docs/TIPS-AND-TRICKS.md#start-with-the-simulator` |
| Stay within free tier limits | `./docs/TIPS-AND-TRICKS.md#stay-within-free-tier-limits` |
| Monitor jobs on IBM Quantum | `./docs/TIPS-AND-TRICKS.md#monitor-jobs-on-ibm-quantum` |

---

## Pick a backend for Bell states {#pick-backend-for-bell-states}

**When:** You want to run a 2-qubit Bell-state circuit on real IBM hardware.

**Workflow:**

1. In Cursor Agent chat (with **quantum-openqasm-mcp** enabled), call `list_backends`.
2. Compare **name**, **qubit count**, **status**, and **queue length**.
3. Pick an **active** backend with **queue 0** (or the shortest queue) and at least 2 qubits.

**Example result (typical Heron fleet):**

| Backend | Qubits | Status | Queue |
|---------|--------|--------|-------|
| ibm_fez | 156 | active | 0 |
| ibm_marrakesh | 156 | active | 0 |
| ibm_kingston | 156 | active | 0 |

**Recommendation:** Use **ibm_fez** when all three show queue 0 and status active — they are equivalent on these metrics, so default transpilation on `ibm_fez` is a solid first choice.

**Why it works for Bell states:**

- Native gate set includes `cz`, `rx`, `rz`, `sx`, `x` — enough to decompose H + entangling gates.
- 156 qubits gives the transpiler many connected pairs; you only need 2.
- Zero queue means minimal wait time.

**Next steps:**

- Call `get_backend_configuration` for your chosen backend to inspect coupling map and basis gates.
- Decompose `h` and `cx` into native gates before submit (see Ask AI → **Write Bell state circuit** in the sidebar).
- Submit via `submit_qasm_job` or **Run on Hardware** in Quantum Lab.

**Ask AI shortcut:** Sidebar → Ask AI → **List backends** (sends the MCP prompt automatically).

---

## Start with the simulator {#start-with-the-simulator}

Start with the free **`ibmq_qasm_simulator`** backend when testing new circuits or debugging transpilation. Switch to hardware (`ibm_fez`, etc.) once the circuit runs cleanly in simulation.

---

## Stay within free tier limits {#stay-within-free-tier-limits}

Keep circuits small (few qubits, modest shot counts) to stay within IBM Quantum free-tier limits. Bell-state and other 2–3 qubit demos are ideal starting points.

---

## Monitor jobs on IBM Quantum {#monitor-jobs-on-ibm-quantum}

Use the [IBM Quantum dashboard](https://quantum.ibm.com/jobs) to monitor usage, queue position, and job history alongside the extension’s live polling in Quantum Lab.

Related: [Local MCP setup](./ide/LOCAL-MCP-SETUP.md) for Cursor, VS Code, Bob, and Antigravity.

---

## Topics & keywords

`tips` · `ibm-quantum` · `list-backends` · `ibm-fez` · `bell-state` · `simulator` · `free-tier` · `mcp-workflow` · `quantum-lab`

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*

