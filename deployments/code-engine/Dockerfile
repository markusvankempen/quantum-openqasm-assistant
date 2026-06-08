# Quantum OpenQASM MCP — npm package + SSE bridge (IBM Code Engine)
# Build from deployments/code-engine:
#   docker build -f Dockerfile -t quantum-mcp-remote .
#
# Installs the published npm package — no monorepo source required.

FROM node:20-slim
WORKDIR /app

ARG QUANTUM_MCP_NPM_VERSION=
RUN if [ -n "$QUANTUM_MCP_NPM_VERSION" ] && [ "$QUANTUM_MCP_NPM_VERSION" != "latest" ]; then \
      npm install --omit=dev "@markusvankempen/quantum-openqasm-mcp@${QUANTUM_MCP_NPM_VERSION}"; \
    else \
      npm install --omit=dev @markusvankempen/quantum-openqasm-mcp; \
    fi

COPY bridge.mjs ./bridge.mjs

ENV MCP_BIN="node node_modules/@markusvankempen/quantum-openqasm-mcp/dist/cli.js"
ENV HOST=0.0.0.0
ENV PORT=8080

EXPOSE 8080

HEALTHCHECK --interval=15s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:8080/health').then(r=>r.json().then(j=>process.exit(j.status==='ok'?0:1))).catch(()=>process.exit(1))"

USER node

CMD ["node", "bridge.mjs"]
