# Playwright MCP on Docker & VNC

> Run Playwright MCP in WebUI mode inside a Docker container with visual browser access via VNC/noVNC.

## Overview

This project provides a containerized environment for running [Playwright MCP](https://github.com/microsoft/playwright-mcp) in **WebUI mode** (not headless). You can view and interact with the browser in real-time through a web-based VNC client, making it ideal for debugging, testing, and demonstrations.


## Quick Start

### 1. Clone and start the container

```bash
git clone <your-repo-url>
cd playwright-web-mpc
docker compose up -d
```

### 2. Access the browser UI

Open your browser and navigate to:

```
http://localhost:6901
```

You'll see the Playwright browser running inside the container.

### 3. Connect your MCP client

Configure your MCP client to connect to the Playwright MCP server:

**Option 1 - SSE Endpoint:**
- **Endpoint:** `http://localhost:8831/sse`
- **Protocol:** SSE (Server-Sent Events)

**Option 2 - HTTP Streamable:**
- **Endpoint:** `http://localhost:8831/mcp`
- **Protocol:** HTTP Streamable

## Configuration

### MCP Client Setup

Add the following configuration to your MCP client's settings:

**For SSE connection:**

```json
{
  "mcpServers": {
    "playwright-mcp-docker": {
      "disabled": false,
      "timeout": 30,
      "url": "http://localhost:8831/sse",
      "type": "sse"
    }
  }
}
```

**For HTTP Streamable connection:**

```json
{
  "mcpServers": {
    "playwright-mcp-docker": {
      "disabled": false,
      "timeout": 30,
      "url": "http://localhost:8831/mcp",
      "type": "http"
    }
  }
}
```

### Customizing Playwright

Edit [src/config/config.json](src/config/config.json) to customize browser settings:

```json
{
  "browser": {
    "browserName": "chromium",
    "launchOptions": {
      "executablePath": "/usr/local/bin/chrome-wrapper.sh"
    },
    "contextOptions": {
      "viewport": {
        "width": 1920,
        "height": 1080
      }
    }
  },
  "server": {
    "host": "0.0.0.0",
    "port": 8831
  },
  "outputDir": "/config/output",
  "imageResponses": "omit"
}
```

See the [official Playwright MCP documentation](https://github.com/microsoft/playwright-mcp?tab=readme-ov-file#configuration-file) for all available options.

### Environment Variables

Customize the container behavior by modifying environment variables in [docker-compose.yml](docker-compose.yml):

```yaml
environment:
  - VNC_RESOLUTION=1920x1080          # Desktop resolution (default: 1280x720)
  - PLAYWRIGHT_VIEWPORT_SIZE=1920,1080  # Browser viewport (default: 1024,720)
  - VNC_PASSWORD=secret               # VNC password (default: no password)
  - NOVNC_PORT=6901                   # noVNC web interface port
  - CHROME_DEVTOOLS_MCP_ENABLED=true  # Enable Chrome DevTools MCP service
  - CHROME_DEVTOOLS_MCP_PORT=8832     # Chrome DevTools MCP service port
```

**Available variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `VNC_RESOLUTION` | VNC desktop size | `1280x720` |
| `PLAYWRIGHT_VIEWPORT_SIZE` | Browser window size | `1024,720` |
| `VNC_PASSWORD` | VNC authentication password | (none) |
| `NOVNC_PORT` | Port for web-based VNC | `6901` |
| `CHROME_DEVTOOLS_MCP_ENABLED` | Enable Chrome DevTools MCP service | `true` |
| `CHROME_DEVTOOLS_MCP_PORT` | Port for Chrome DevTools MCP service | `8832` |

> **Note:** If you change `NOVNC_PORT` or `CHROME_DEVTOOLS_MCP_PORT`, update the port mapping in the `ports` section of `docker-compose.yml` accordingly.

## Common Commands

```bash
# Start the container in detached mode
docker compose up -d

# View container logs
docker compose logs -f

# Stop the container
docker compose down

# Restart the container
docker compose restart

# Access shell inside the container
docker compose exec playwright bash
```

## How It Works

This setup uses:

1. **Docker** - Isolates the Playwright environment with all dependencies
2. **VNC Server** - Provides remote display access to the container's desktop
3. **noVNC** - HTML5 VNC client that you access through your web browser
4. **Playwright MCP** - Runs in WebUI mode and exposes an SSE endpoint for MCP clients

The architecture allows you to watch Playwright actions in real-time while controlling it programmatically through your MCP client.

## Chrome DevTools MCP Service

This container includes the Chrome DevTools MCP service.

### Configuration

The service is enabled by default and can be configured via environment variables in [docker-compose.yml](docker-compose.yml):

```yaml
environment:
  - CHROME_DEVTOOLS_MCP_ENABLED=true  # Set to false to disable
  - CHROME_DEVTOOLS_MCP_PORT=8832     # Default port

ports:
  - "8832:8832" # Map host port to container port
```

### Endpoints

When enabled, the service exposes:

- **POST** `http://localhost:8832/mcp/v1/sse` - HTTP Streamable endpoint (standard MCP path)
- **POST** `http://localhost:8832/mcp/v1/messages` - Alternative endpoint

### Usage

The service automatically starts `chrome-devtools-mcp@latest` with default settings:
- Headless mode: enabled by default
- Isolated mode: can be configured

To customize chrome-devtools-mcp options, modify the `--stdio` command in [src/chrome-devtools-mcp.sh](src/chrome-devtools-mcp.sh).

### Testing

Test the endpoint:

```bash
curl -X POST http://localhost:8832/mcp/v1/sse \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"roots":{"listChanged":true},"sampling":{}}}}'
```

### Technical Details

- **Transport**: HTTP Streamable (SSE-based)
- **Auto-reconnect**: Managed automatically
- **Process management**: Background service with graceful shutdown

## License

MIT License

```
MIT License

Copyright (c) 2025 moyashi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
