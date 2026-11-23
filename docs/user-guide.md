# User Guide

[Getting Started](getting-started.md) | [Troubleshooting](troubleshooting.md) | [FAQ](faq.md) | [Changelog](../CHANGELOG.md)

---

## What is APXY?

APXY is a network debugging and API mocking proxy that sits between your computer and the internet, letting you **inspect, mock, and debug** HTTP/HTTPS traffic. Think of it as a local network debugger: you can see every API call your apps make, fake server responses, replay requests, and diagnose API issues.

What makes APXY unique is that it's built for both **developers and AI coding agents**. You can use it through a CLI or a Web UI in your browser.

---

## Web UI

When the proxy starts, a Web UI is available at `http://localhost:<proxy-port + 2>` (default: `http://localhost:8082`).

```bash
apxy start                    # Web UI on port 8082
apxy start --web-port 9090    # Custom port
apxy start --web-port 0       # Disable Web UI
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
| **Breakpoints** | Pause a matching request or response, edit it, then resume or drop it |
| **Scripts** | JavaScript that changes requests or responses as they pass through |
| **Protobuf** | Upload `.proto` schemas and decode Protobuf bodies |
| **Schema** | Import an OpenAPI schema and check captured traffic against it |
| **Agent Activity** | What your AI coding agent did through APXY |
| **Mobile Setup** | QR code and steps to route a phone through APXY |
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
apxy rewrite set --name "Prod to Staging" \
  --from "https://api.production.com" --to "https://api.staging.com"
apxy rewrite list
apxy rewrite remove --id <rule-id>
```

### Export & Replay

```bash
apxy logs export-curl --id <record-id>    # Export as cURL
apxy logs replay --id <record-id>         # Re-send the request
apxy run -- curl -X POST "https://api.example.com/data" \
  -H "Content-Type: application/json" -d '{"key": "value"}'   # Send a new request through APXY
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

### Traffic Analysis with jq

```bash
# Count requests by host
apxy logs list --limit 1000 | jq '.items | [group_by(.host)[] | {host: .[0].host, count: length}] | sort_by(-.count)'

# Find requests slower than 1000ms
apxy logs list --limit 1000 | jq '.items | [.[] | select(.duration > 1e9) | {method, url, ms: (.duration / 1e6 | round)}] | sort_by(-.ms)'
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

### Scripts

A script defines `handle(ctx)`, changes `ctx.headers` or `ctx.body`, and returns `ctx`.

```bash
apxy script add --name "add-auth-header" --hook onRequest \
  --match "host == api.example.com" \
  --code 'function handle(ctx) { ctx.headers["Authorization"] = "Bearer test-token"; return ctx; }'
apxy script list
apxy script remove --id <script-id>
```

---

## Proxy Configuration

### Start flags

| Flag | Default | Description |
|------|---------|-------------|
| `--port` | `8080` | Proxy listen port |
| `--web-port` | proxy+2 | Web UI port (`0` to disable) |
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
apxy shell                          # Open a shell with env set
eval $(apxy env --lang node)        # Node.js only
apxy env --script ./proxy-env.sh    # Write to file
```

---

## Uninstall

```bash
# If installed via install.sh
curl -fsSL https://apxy.dev/install.sh | bash -s -- uninstall

# Or manually
rm $(which apxy)
rm -rf ~/.apxy
```
