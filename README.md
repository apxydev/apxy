# APXY — Agent Proxy

[![Version](https://img.shields.io/badge/version-1.1.1-blue.svg)](https://github.com/apxydev/apxy/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-Proprietary-red.svg)](LICENSE.md)

**HTTPS debugging for humans and AI agents.**

APXY is a desktop network proxy that sits between your computer and the internet, letting you **inspect, mock, and debug** HTTP/HTTPS traffic. Use it through a **CLI** (30+ commands), a **Web GUI**, or through **MCP** (30 tools) so AI tools like Cursor, Claude, and VS Code Copilot can help you debug.

<!-- TODO: Add demo GIF here -->
<!-- ![APXY Demo](assets/demo.gif) -->

---

## Install

**macOS / Linux:**

```bash
curl -fsSL https://raw.githubusercontent.com/apxydev/apxy/main/scripts/install.sh | bash
```

Or download directly from [GitHub Releases](https://github.com/apxydev/apxy/releases).

| Binary | Platform |
|--------|----------|
| `apxy-darwin-arm64` | macOS (Apple Silicon — M1/M2/M3/M4) |
| `apxy-darwin-amd64` | macOS (Intel) |
| `apxy-linux-amd64` | Linux (x86_64) |

> macOS binaries are signed with Apple Developer ID and notarized. No Gatekeeper warnings.

---

## Quick Start

```bash
# 1. Start the proxy (auto-configures CA + system proxy on macOS)
apxy start

# 2. Make any request — it's captured automatically
curl https://httpbin.org/get

# 3. View captured traffic
apxy logs list --limit 10

# 4. Mock an API endpoint
apxy mock add --name "stub" --url "/api/users" --match exact --status 200 --body '{"users":[]}'

# 5. Stop
apxy stop
```

Web GUI auto-starts at `http://localhost:8082`.

---

## Features

### Traffic Capture & Inspection
Capture all HTTP/HTTPS traffic with full request/response details. Search by URL, host, method, or status. Export as cURL. Full-text body search and JSONPath queries.

### API Mocking
Intercept requests and return fake responses. Supports exact, wildcard, and regex URL matching. Add response delays to simulate slow APIs. Priority-based rule evaluation.

### URL Redirects (Map Remote)
Redirect requests from one URL to another without changing your application code. Route production traffic to staging.

### Network Simulation
Simulate latency, throttling, and poor network conditions to test your app's resilience.

### Export, Replay & Compose
Export captured requests as cURL commands. Replay any request. Compose and send custom HTTP requests from scratch.

### Traffic Filtering
Block or allow traffic by host pattern. Focus on the requests that matter.

### Dynamic Interceptors
Create runtime rules that modify requests/responses on the fly. Match by host, path, method, URL, or headers with AND/OR logic.

### API Diagnosis
Analyze traffic history to diagnose API issues. Batch request testing with historical comparison.

### SQL Queries
Run SQL queries directly against the traffic database for advanced analytics.

### GraphQL Support
Search and filter GraphQL operations by name and type.

### Web GUI
Full-featured React web interface with live traffic streaming, dark/light theme, mock rule management, and a command palette.

### SSL Management
Fine-grained control over which domains have HTTPS interception enabled. Tunnel-only mode by default for privacy.

---

## Three Interfaces

| Interface | Best for | Commands |
|-----------|----------|----------|
| **CLI** | Shell workflows, CI/CD, scripting | 30+ commands |
| **Web GUI** | Visual inspection, team demos | `http://localhost:8082` |
| **MCP** | AI agent integration | 30 tools via stdio |

### CLI

```bash
apxy logs list --limit 10 --format json
apxy mock add --name "stub" --url "/api/*" --match wildcard --status 200 --body '{}'
apxy sql query "SELECT host, COUNT(*) FROM traffic_logs GROUP BY host"
```

### MCP (AI Agent Integration)

APXY includes a built-in MCP server. AI tools launch `apxy mcp` as a subprocess via stdio.

```bash
# Interactive setup (picks your AI client, writes config automatically)
apxy mcp install
```

Supports: **Cursor**, **Claude Desktop**, **Claude Code**, **VS Code / Copilot**, **Windsurf**.

30 MCP tools across traffic inspection, mocking, filtering, export/replay, redirects, SSL, network simulation, interceptors, diagnosis, GraphQL, caching, and SQL.

---

## Documentation

- [Getting Started](docs/getting-started.md) — 5-minute quick start
- [User Guide](docs/user-guide.md) — Full feature reference
- [Troubleshooting](docs/troubleshooting.md) — Common issues and fixes
- [FAQ](docs/faq.md) — Frequently asked questions

---

## AI Agent Skill

APXY ships with an [AI agent skill](skills/SKILL.md) that teaches AI tools how to use the CLI. Drop it into your AI tool's skill/context directory.

---

## Contributing

We welcome community contributions in three areas:

- **Mock Templates** — Pre-built mock rules for popular APIs (Stripe, GitHub, OpenAI, etc.)
- **Usage Examples** — Step-by-step tutorials and workflow guides
- **AI Agent Skills** — Improved prompts and workflow recipes

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## Reporting Issues

Found a bug or have a feature request? [Open an issue](https://github.com/apxydev/apxy/issues).

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## License

APXY is proprietary software. See [LICENSE.md](LICENSE.md) for details.

Community contributions (mock-templates, examples) are licensed under [MIT](https://opensource.org/licenses/MIT).
