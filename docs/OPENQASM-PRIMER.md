# OpenQASM Primer — Plain English

<!--
SEO: OpenQASM tutorial | OpenQASM 2.0 beginner | qreg creg measure | quantum circuit guide
learn qasm, ibm quantum openqasm, qubit gates, bell state, binary encoding quantum
-->

> A beginner guide to reading **OpenQASM 2.0** circuits for **IBM Quantum** hardware. Explains `qreg`, `creg`, gates, and measurement in plain English — no physics degree required.

📖 **[Docs index](./README.md)** · **[Tips & Tricks](./TIPS-AND-TRICKS.md)** · **[Architecture](./ARCHITECTURE.md)** · **[Extension README](../extension/README.md)**

**Search terms:** `openqasm tutorial` · `learn qasm` · `qreg creg` · `quantum gates` · `openqasm 2.0 ibm`

---

## A complete example: store the number 2 (1 + 1)

This is the smallest “math story” after storing 1 — flip the **twos** bit so binary `010` reads as decimal **2**.

```qasm
OPENQASM 2.0;
include "qelib1.inc";
// 1 + 1 = 2  —  binary 010 → decimal 2
qreg q[3];
creg c[3];
x q[1];
measure q[0] -> c[0];
measure q[1] -> c[1];
measure q[2] -> c[2];
```

See also: `examples/simple/store-two.qasm` (in the private dev repo)

### Line-by-line

| Line | What it means |
|------|----------------|
| `OPENQASM 2.0;` | “This file uses OpenQASM version 2.0.” IBM hardware in this project expects this header. |
| `include "qelib1.inc";` | Load the standard gate library (`x`, `h`, `cx`, etc.). Like importing built-in functions. |
| `// …` | A comment — ignored by the computer; for humans only. |
| `qreg q[3];` | Create **3 quantum bits** named `q[0]`, `q[1]`, `q[2]`. Each starts as **0** (\|0⟩). |
| `creg c[3];` | Create **3 classical bits** named `c[0]`, `c[1]`, `c[2]`. These hold **measurement results** (0 or 1). |
| `x q[1];` | Apply an **X gate** (NOT) on qubit `q[1]`: flip 0 → 1. After this line, `q[1]` is **1**; others stay **0**. |
| `measure q[0] -> c[0];` | **Measure** qubit 0 and store the outcome (0 or 1) in classical bit `c[0]`. |
| `measure q[1] -> c[1];` | Measure qubit 1 → `c[1]`. |
| `measure q[2] -> c[2];` | Measure qubit 2 → `c[2]`. |

After measurement you read the classical register as a binary number:

```
c[2] c[1] c[0]  →  binary 010  →  decimal 2
  0     1     0
```

Bit positions: `c[0]` = **ones**, `c[1]` = **twos**, `c[2]` = **fours**.

---

## Core concepts

### Quantum register — `qreg`

```qasm
qreg q[3];
```

- **q** = your array of **qubits** (quantum memory).
- **`[3]`** = three of them, indexed `q[0]` … `q[2]`.
- Before any gates, each qubit is in state **\|0⟩** (think: stored value 0).

OpenQASM 3 uses `qubit[3] q;` instead — same idea, different spelling. Our IBM-ready files use **2.0** syntax.

### Classical register — `creg`

```qasm
creg c[3];
```

- **c** = **classical** bits — normal 0/1 values you can read after the job finishes.
- Measurements write into `c[…]`; they do not stay “quantum.”

### Gates — instructions that change qubits

| Gate | Example | Plain English |
|------|---------|----------------|
| **X** (NOT) | `x q[1];` | Flip: 0 becomes 1, 1 becomes 0. |
| **H** (Hadamard) | `h q[0];` | Make a **50/50 superposition** — like a fair coin before you look. |
| **CX** (CNOT) | `cx q[0], q[1];` | If control `q[0]` is 1, flip target `q[1]`. Used for entanglement. |
| **RZ / SX / CZ** | `rz(pi/2) q[0];` | Native IBM gates; often used instead of `h`/`cx` on real hardware. |

**Include line:** `include "qelib1.inc";` defines the common gates for OpenQASM 2.0.

### Measurement — `measure`

```qasm
measure q[0] -> c[0];
```

1. **Look at** qubit `q[0]`.
2. Collapse it to a definite **0** or **1**.
3. Save that bit in `c[0]`.

You must measure before the quantum computer can give you a classical result. Running the same circuit many times (**shots**) gives a histogram of bit strings (e.g. mostly `010`, sometimes noise on hardware).

---

## Storing numbers in binary {#storing-numbers-in-binary}

Three qubits encode a 3-bit unsigned integer:

| Decimal | Binary | Which qubits are 1? |
|---------|--------|---------------------|
| 1 | `001` | `q[0]` only → `x q[0];` |
| 2 | `010` | `q[1]` only → `x q[1];` |
| 5 | `101` | `q[0]` and `q[2]` → `x q[0]; x q[2];` |
| 6 | `110` | `q[1]` and `q[2]` → `x q[1]; x q[2];` |

Examples in the private dev repo (`examples/simple/`):

| File | Stores |
|------|--------|
| `store-one.qasm` | 1 (`001`) |
| `store-two.qasm` | 2 (`010`) — “1 + 1 = 2” |
| `store-five.qasm` | 5 (`101`) |
| `store-six.qasm` | 6 (`110`) |

Readable OpenQASM 3 versions with more comments live in `examples/simple/readable/`.

---

## OpenQASM 2.0 vs 3.0 in this project

| | OpenQASM 2.0 | OpenQASM 3 |
|---|--------------|------------|
| **Use for** | Submitting to IBM via this extension | Learning / reading |
| **Header** | `OPENQASM 2.0;` | `OPENQASM 3;` |
| **Qubits** | `qreg q[n];` | `qubit[n] q;` |
| **Classical** | `creg c[n];` | `bit[n] c;` |
| **Include** | `"qelib1.inc"` | `"stdgates.inc"` |
| **Measure** | `measure q[0] -> c[0];` | `c[0] = measure q[0];` |

IBM’s API for this project accepts **2.0** for execution. Keep `readable/*.qasm` for intuition; run the matching `*.qasm` in the parent folder on hardware.

---

## Other lines you will see

```qasm
OPENQASM 2.0;
include "qelib1.inc";
qreg q[1];
creg c[1];
x q[0];
measure q[0] -> c[0];
```

**Bit flip** — always measure **1**. Simplest program: `examples/simple/bit-flip.qasm`.

```qasm
h q[0];
measure q[0] -> c[0];
```

**Coin flip** — about 50% `0`, 50% `1`. See `examples/simple/coin-flip.qasm`.

```qasm
h q[0];
cx q[0], q[1];
measure q[0] -> c[0];
measure q[1] -> c[1];
```

**Bell state** — two qubits entangled; outcomes are mostly `00` and `11`. See `examples/simple/` Bell-state circuits.

---

## Quick reference card

| Syntax | Meaning |
|--------|---------|
| `OPENQASM 2.0;` | File format version |
| `include "qelib1.inc";` | Standard gates |
| `qreg q[n];` | n qubits, start at 0 |
| `creg c[n];` | n classical result bits |
| `x q[i];` | NOT on qubit i |
| `h q[i];` | Superposition / “coin flip” |
| `cx q[a], q[b];` | CNOT: control a, target b |
| `measure q[i] -> c[j];` | Read qubit i into classical bit j |
| `// comment` | Ignored — notes for you |

---

## Next steps

1. Read [Tips & Tricks](./TIPS-AND-TRICKS.md) for backend selection and MCP workflows.
2. Configure MCP — [Local MCP setup](./ide/LOCAL-MCP-SETUP.md).
3. Use **Quantum Lab** in the extension to load an example and **Run on Hardware**.
4. Ask AI: *“Explain this OpenQASM circuit line by line”* (paste your circuit).

---

## Topics & keywords

`openqasm` · `openqasm-2` · `qasm` · `qreg` · `creg` · `quantum-gates` · `measure` · `bell-state` · `ibm-quantum` · `beginner` · `tutorial`

---

**Author:** Markus van Kempen  
**Email:** [markus.van.kempen@gmail.com](mailto:markus.van.kempen@gmail.com) · [mvk@ca.ibm.com](mailto:mvk@ca.ibm.com)  
**Website:** [markusvankempen.github.io](https://markusvankempen.github.io/)  
*No bug too small, no syntax too weird.*

