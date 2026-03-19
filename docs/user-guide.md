# User Guide

**Version 1.0.1** | [Getting Started](getting-started.md) | [Troubleshooting](troubleshooting.md) | [FAQ](faq.md) | [Changelog](../CHANGELOG.md)

---

## What is APXY?

APXY (Agent Proxy) is a desktop tool that sits between your computer and the internet, letting you **inspect, mock, and debug** HTTP/HTTPS traffic. Think of it as a network debugger -- you can see every API call your apps make, fake server responses, replay requests, and diagnose API issues.

What makes APXY unique is that it's built for both **humans and AI agents**. You can use it through a CLI, a Web GUI in your browser, or through MCP (Model Context Protocol) so AI tools like Cursor, Claude Desktop, and VS Code Copilot can inspect your network traffic and help you debug.

---

## Web GUI

When the proxy starts, a Web GUI is available at `http://localhost:<proxy-port + 2>` (default: `http://localhost:8082`).

```bash
apxy start                    # Web GUI on port 8082
apxy start --web-port 9090    # Custom port
apxy start --web-port 0       # Disable Web GUI
```

### Pages

| Page | What it does |
|------|-------------|
| **Dashboard** | Proxy status, recording toggle, traffic charts |
| **Traffic** | Live traffic table with WebSocket updates, search and filter, click any row for details |
| **Compose** | Build and send HTTP requests from scratch |
| **Diff** | Compare two traffic records side-by-side |
| **Mock Rules** | Create, edit, enable/disable, and delete mock rules |
| **Filters** | Block or allow traffic by host pattern |
| **Redirects** | Rewrite URLs (map remote) |
| **SSL** | Enable/disable HTTPS interception per domain |
| **Network** | Simulate latency, throttling, and packet loss |
| **Interceptors** | Dynamic request/response modification rules |
| **Sessions** | Pause/resume recording, clear traffic |

Supports dark/light theme toggle and a command palette for quick navigation.

---

## Core Features

### Traffic Capture & Inspection

```bash
apxy logs list --limit 20
apxy logs show --id <record-id>
apxy logs search --query "api.example.com"
apxy logs stats

# Output formats
apxy logs list --format markdown    # Human-readable tables
apxy logs list --format json        # For piping to jq
apxy logs list --format toon        # Ultra-compact for AI agents
```

### Mock Rules

Intercept matching requests and return fake responses.

```bash
# Exact match
apxy mock add --name "Mock Users" --url "/api/users" --match exact \
  --status 200 --body '{"users": [{"id": 1, "name": "Test"}]}'

# Wildcard
apxy mock add --name "Mock All API" --url "/api/*" --match wildcard \
  --status 200 --body '{"mocked": true}'

# Regex
apxy mock add --name "Mock User by ID" --url "/api/users/\\d+" --match regex \
  --status 200 --body '{"id": 42}'

# With delay (simulate slow API)
apxy mock add --name "Slow" --url "/api/slow" --match exact \
  --status 200 --body '{"data": "delayed"}' --delay 2000

apxy mock list
apxy mock remove --id <rule-id>
apxy mock clear
```

### Traffic Filtering

```bash
apxy filter set --type block --target "analytics.google.com"
apxy filter set --type allow --target "api.myapp.com"
apxy filter list
apxy filter remove --id <rule-id>
```

### URL Redirects (Map Remote)

```bash
apxy redirect set --name "Prod to Staging" \
  --from "https://api.production.com" --to "https://api.staging.com"
apxy redirect list
apxy redirect remove --id <rule-id>
```

### Export & Replay

```bash
apxy logs export-curl --id <record-id>    # Export as cURL
apxy logs replay --id <record-id>         # Re-send the request
apxy request compose --method POST --url "https://api.example.com/data" \
  --body '{"key": "value"}'
```

### Network Conditions

```bash
apxy network set --latency 500         # 500ms delay
apxy network set --bandwidth 50000     # Throttle bandwidth
apxy network clear
```

### Recording Control

```bash
apxy recording start
apxy recording stop
```

### SSL Management

```bash
apxy ssl enable --domain "api.example.com"    # Enable MITM for domain
apxy ssl disable --domain "api.example.com"   # Tunnel only (no inspection)
apxy ssl list
```

### SQL Queries

```bash
apxy sql query "SELECT host, COUNT(*) as cnt FROM traffic_logs GROUP BY host ORDER BY cnt DESC"
apxy sql query "SELECT method, url, duration_ms FROM traffic_logs WHERE duration_ms > 1000"
```

### Body Search & JSONPath

```bash
apxy logs search-bodies --pattern "error" --scope response
apxy logs jsonpath --id <record-id> --path "data.users.#.name"
```

### Diff

```bash
apxy logs diff --id-a <record-1> --id-b <record-2> --scope response
```

### GraphQL

```bash
apxy logs graphql --operation-name "GetUser" --limit 10
```

### Dynamic Interceptors

```bash
apxy interceptor set --name "Add header" \
  --match 'host == "api.example.com"' \
  --action modify --description "Add auth header"
apxy interceptor list
apxy interceptor remove --id <rule-id>
```

---

## MCP Integration (for AI Agents)

APXY includes a built-in MCP server with 30 tools, allowing AI tools to inspect traffic, create mock rules, and debug APIs.

### Quick setup

```bash
apxy mcp install
```

This interactive command asks you to pick your AI client and scope, then writes the config automatically.

### Supported AI clients

- Cursor
- Claude Desktop
- Claude Code
- VS Code / Copilot
- Windsurf

### Manual setup

Add APXY to your AI client's MCP config:

**Cursor** (`.cursor/mcp.json` or `~/.cursor/mcp.json`):
```json
{
  "mcpServers": {
    "apxy": {
      "command": "/path/to/apxy",
      "args": ["mcp", "--db", "/path/to/data/apxy.db"]
    }
  }
}
```

**Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "apxy": {
      "command": "/path/to/apxy",
      "args": ["mcp", "--db", "/path/to/data/apxy.db"]
    }
  }
}
```

**Claude Code** (`.mcp.json` or `~/.claude.json`):
```json
{
  "mcpServers": {
    "apxy": {
      "command": "/path/to/apxy",
      "args": ["mcp", "--db", "/path/to/data/apxy.db"]
    }
  }
}
```

**VS Code / Copilot** (`.vscode/mcp.json`):
```json
{
  "servers": {
    "apxy": {
      "type": "stdio",
      "command": "/path/to/apxy",
      "args": ["mcp", "--db", "/path/to/data/apxy.db"]
    }
  }
}
```

**Windsurf** (`~/.codeium/windsurf/mcp_config.json`):
```json
{
  "mcpServers": {
    "apxy": {
      "command": "/path/to/apxy",
      "args": ["mcp", "--db", "/path/to/data/apxy.db"]
    }
  }
}
```

Replace `/path/to/apxy` and `/path/to/data/apxy.db` with actual paths.

### How it works

```
┌──────────────┐  stdio   ┌──────────────┐  SQLite DB   ┌──────────────┐
│  AI Client   │◄────────►│  apxy mcp    │◄────────────►│  apxy start  │
│ (Cursor,     │          │  (MCP srv)   │              │  (proxy)     │
│  Claude, ..) │          │              │              │              │
└──────────────┘          └──────────────┘              └──────────────┘
```

1. Start the proxy: `apxy start`
2. Your AI client launches `apxy mcp` as a subprocess via stdio
3. Both processes share the same SQLite database

### MCP tools (30 tools)

| Category | Tools |
|----------|-------|
| **Traffic** | `get_traffic_logs`, `get_traffic_detail`, `search_traffic`, `get_proxy_status` |
| **Mocking** | `set_mock_rule`, `remove_mock_rule`, `list_mock_rules` |
| **Session** | `toggle_recording`, `clear_traffic` |
| **Filtering** | `set_filter_rule`, `remove_filter_rule`, `list_filter_rules` |
| **Export/Replay** | `export_as_curl`, `replay_request`, `compose_request` |
| **Redirects** | `set_redirect_rule`, `remove_redirect_rule`, `list_redirect_rules` |
| **SSL** | `enable_ssl_domain`, `disable_ssl_domain`, `list_ssl_domains` |
| **Body Search** | `search_bodies`, `query_json_path` |
| **Diff** | `diff_records` |
| **Network** | `set_network_condition`, `clear_network_condition` |
| **Interceptors** | `set_interceptor`, `remove_interceptor`, `list_interceptors` |
| **Diagnosis** | `diagnose_apis`, `batch_request` |
| **GraphQL** | `search_graphql` |
| **Caching** | `set_no_caching` |
| **Database** | `query_sql` |

### Example AI prompts

- *"Show me the last 10 API calls"*
- *"Find all failed requests (status 4xx or 5xx)"*
- *"Mock /api/users to return an empty array"*
- *"Compare records abc123 and def456"*
- *"Export that request as a curl command"*
- *"What's wrong with the requests to api.example.com?"*

---

## Proxy Configuration

### Start flags

| Flag | Default | Description |
|------|---------|-------------|
| `--port` | `8080` | Proxy listen port |
| `--web-port` | proxy+2 | Web GUI port (`0` to disable) |
| `--cert-dir` | `./certs` | Directory for CA and leaf certificates |
| `--max-body` | `1048576` | Max request/response body capture (bytes) |
| `--verbose` | `false` | Enable detailed logging |
| `--no-system-proxy` | `false` | Skip automatic system proxy setup |
| `--network-service` | *(auto)* | macOS network service to configure |

### Linux setup

```bash
apxy start --no-system-proxy
export http_proxy=http://localhost:8080
export https_proxy=http://localhost:8080
```

### Proxy environment injection

```bash
eval $(apxy env)                    # Inject into current shell
apxy env --open                     # Open new terminal with env set
eval $(apxy env --lang node)        # Node.js only
apxy env --script ./proxy-env.sh    # Write to file
```

---

## Uninstall

```bash
# If installed via install.sh
~/.apxy/bin/install.sh uninstall

# Or manually
rm $(which apxy)
rm -rf ~/.apxy
```
