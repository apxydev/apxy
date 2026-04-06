# User Guide

**Version 1.0.0** | [Getting Started](getting-started.md) | [Troubleshooting](troubleshooting.md) | [FAQ](faq.md) | [Changelog](../CHANGELOG.md)

---

## What is APXY?

APXY is a network debugging and API mocking proxy that sits between your computer and the internet, letting you **inspect, mock, and debug** HTTP/HTTPS traffic. Think of it as a local network debugger: you can see every API call your apps make, fake server responses, replay requests, and diagnose API issues.

What makes APXY unique is that it's built for both **developers and AI coding agents**. You can use it through a CLI or a Web UI in your browser.

---

## Web UI

When the proxy starts, a Web UI is available at `http://localhost:<proxy-port + 2>` (default: `http://localhost:8082`).

```bash
apxy proxy start                    # Web UI on port 8082
apxy proxy start --web-port 9090    # Custom port
apxy proxy start --web-port 0       # Disable Web UI
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
apxy traffic logs list --limit 20
apxy traffic logs show --id <record-id>
apxy traffic logs search --query "api.example.com"
apxy traffic logs stats

# Output formats
apxy traffic logs list --format markdown    # Human-readable tables
apxy traffic logs list --format json        # For piping to jq
apxy traffic logs list --format toon        # Ultra-compact for AI agents
```

### Mock Rules

Intercept matching requests and return fake responses.

```bash
# Exact match
apxy rules mock add --name "Mock Users" --url "/api/users" --match exact \
  --status 200 --body '{"users": [{"id": 1, "name": "Test"}]}'

# Wildcard
apxy rules mock add --name "Mock All API" --url "/api/*" --match wildcard \
  --status 200 --body '{"mocked": true}'

# Regex
apxy rules mock add --name "Mock User by ID" --url "/api/users/\\d+" --match regex \
  --status 200 --body '{"id": 42}'

# With delay (simulate slow API)
apxy rules mock add --name "Slow" --url "/api/slow" --match exact \
  --status 200 --body '{"data": "delayed"}' --delay 2000

apxy rules mock list
apxy rules mock remove --id <rule-id>
apxy rules mock clear
```

### Traffic Filtering

```bash
apxy rules filter set --type block --target "analytics.google.com"
apxy rules filter set --type allow --target "api.myapp.com"
apxy rules filter list
apxy rules filter remove --id <rule-id>
```

### URL Redirects (Map Remote)

```bash
apxy rules redirect set --name "Prod to Staging" \
  --from "https://api.production.com" --to "https://api.staging.com"
apxy rules redirect list
apxy rules redirect remove --id <rule-id>
```

### Export & Replay

```bash
apxy traffic logs export-curl --id <record-id>    # Export as cURL
apxy traffic logs replay --id <record-id>         # Re-send the request
apxy tools request compose --method POST --url "https://api.example.com/data" \
  --body '{"key": "value"}'
```

### Network Conditions

```bash
apxy rules network set --latency 500         # 500ms delay
apxy rules network set --bandwidth 50000     # Throttle bandwidth
apxy rules network clear
```

### Recording Control

```bash
apxy traffic recording start
apxy traffic recording stop
```

### SSL Management

```bash
apxy setup ssl enable --domain "api.example.com"    # Enable MITM for domain
apxy setup ssl disable --domain "api.example.com"   # Tunnel only (no inspection)
apxy setup ssl list
```

### SQL Queries

```bash
apxy traffic sql query "SELECT host, COUNT(*) as cnt FROM traffic_logs GROUP BY host ORDER BY cnt DESC"
apxy traffic sql query "SELECT method, url, duration_ms FROM traffic_logs WHERE duration_ms > 1000"
```

### Body Search & JSONPath

```bash
apxy traffic logs search-bodies --pattern "error" --scope response
apxy traffic logs jsonpath --id <record-id> --path "data.users.#.name"
```

### Diff

```bash
apxy traffic logs diff --id-a <record-1> --id-b <record-2> --scope response
```

### GraphQL

```bash
apxy traffic logs graphql --operation-name "GetUser" --limit 10
```

### Dynamic Interceptors

```bash
apxy rules interceptor set --name "Add header" \
  --match 'host == "api.example.com"' \
  --action modify --description "Add auth header"
apxy rules interceptor list
apxy rules interceptor remove --id <rule-id>
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
apxy proxy start --no-system-proxy
export http_proxy=http://localhost:8080
export https_proxy=http://localhost:8080
```

### Proxy environment injection

```bash
eval $(apxy proxy env)                    # Inject into current shell
apxy proxy env --open                     # Open new terminal with env set
eval $(apxy proxy env --lang node)        # Node.js only
apxy proxy env --script ./proxy-env.sh    # Write to file
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
