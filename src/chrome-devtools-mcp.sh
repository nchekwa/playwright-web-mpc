#!/bin/bash

# Chrome DevTools MCP Service startup script
# This script starts chrome-devtools-mcp with HTTP Streamable transport

# Default port if not set
PORT=${CHROME_DEVTOOLS_MCP_PORT:-8832}

echo "----------------------------------------------------"
echo "  Starting Chrome DevTools MCP Service"
echo "  Port: ${PORT}"
echo "  MCP Server: chrome-devtools-mcp@latest"
echo "  Transport: HTTP Streamable"
echo "----------------------------------------------------"
echo "Endpoints will be available at:"
echo "  - POST http://localhost:${PORT}/mcp/v1/sse (HTTP Streamable)"
echo "  - POST http://localhost:${PORT}/mcp/v1/messages (Alternative)"
echo "----------------------------------------------------"

# Start chrome-devtools-mcp with HTTP Streamable transport
exec npx -y supergateway \
  --stdio 'npx -y chrome-devtools-mcp@latest' \
  --outputTransport streamableHttp \
  --port ${PORT}
