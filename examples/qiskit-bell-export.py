#!/usr/bin/env python3
"""
Export a Bell-state circuit from Qiskit to OpenQASM 2.0 for Quantum OpenQASM Assistant.

Requires: pip install qiskit

Note: logical gates (h, cx) are not IBM-hardware-ready — use
examples/qiskit-bell-transpile-export.py before submit_qasm_job on real QPUs.

Usage:
    python examples/qiskit-bell-export.py
    # writes bell-from-qiskit.qasm in the current directory

See: docs/QISKIT-INTEGRATION.md
"""

from pathlib import Path

from qiskit import QuantumCircuit, qasm2

OUTPUT = Path("bell-from-qiskit.qasm")


def main() -> None:
    qc = QuantumCircuit(2, 2)
    qc.h(0)
    qc.cx(0, 1)
    qc.measure([0, 1], [0, 1])

    print(qasm2.dumps(qc))
    qasm2.dump(qc, OUTPUT)
    print(f"\nWrote {OUTPUT.resolve()}")
    print("Next: open in Quantum Lab or submit via MCP — see docs/QISKIT-INTEGRATION.md")


if __name__ == "__main__":
    main()
