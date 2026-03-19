# Changelog

## [1.0.1] - 2026-03-03

### Security & Privacy
- HTTPS MITM is now opt-in (tunnel-only by default for privacy)
- 3-tier HTTPS modes: tunnel (no inspection), metadata (headers only), deep (full MITM)
- Proxy bypass support for excluded hosts

### New Features
- `apxy env` command for automatic proxy environment injection (Proxyman-style)
  - `--open` flag to launch a pre-configured terminal
  - `--script` flag to export env setup as a shell script
  - Multi-language support (Node.js, Python, Ruby, Java, Go, etc.)
- Proxyman-style app grouping in Web UI (traffic organized by process/app)
- Mobile device setup and discovery
- Manual MCP install option (`apxy mcp install --manual`)

### Web UI Improvements
- Full UI refresh with Proxyman-style design
- Body-not-captured indicator for tunnel/metadata HTTPS modes
- Fixed WebSocket real-time stream disconnecting after 4-10 minutes

### Telemetry & Observability
- Opt-in telemetry with Sentry error tracking and PostHog analytics
- Privacy-first: disabled by default, explicit user consent required

### Release Infrastructure
- Apple code signing and notarization for macOS binaries
- Cross-platform release pipeline (macOS ARM64/AMD64, Linux AMD64)

---

## [2.0.0] - 2026-03-02

### API Diagnosis
- API diagnoser with history-based analysis
- HTTP client for live probe requests
- MCP `diagnose_apis` and `batch_request` tools
- Diagnosis report with actionable recommendations

### Session Control & Filtering
- Recording toggle (pause/resume traffic capture)
- MCP `toggle_recording` and `clear_traffic` tools
- Filter rules (block/allow) for host-based traffic control

### Export & Replay
- MCP `export_as_curl` tool for sharing reproducible requests
- MCP `replay_request` tool for re-sending captured traffic
- MCP `compose_request` tool for building requests from scratch

### Map Remote & SSL Management
- Redirect rules for URL rewriting (map remote)
- Per-domain SSL proxying toggle

### Body Search & JSONPath
- Full-text body search across request/response payloads
- MCP `query_json_path` tool for extracting values from JSON responses

### Diff & Network Conditions
- MCP `diff_records` tool for comparing two traffic records
- Network condition simulation (latency, throttle, packet loss)

### Dynamic Interceptors
- Interceptor engine for request/response modification
- Match DSL with AND/OR logic for host, path, method, URL, headers

### Web GUI
- Embedded React + TypeScript + Tailwind SPA
- WebSocket real-time traffic streaming
- Dashboard, traffic viewer, mock rules, filters, redirects, SSL, network, interceptors
- Dark/light theme toggle and command palette

### GraphQL & Caching
- GraphQL-aware traffic search by operation name/type
- MCP `set_no_caching` tool for disabling upstream caches

---

## [1.1.0] - 2026-03-01

### Initial Release
- Domain layer with NetworkRecord, MockRule structs
- Certificate management (CA generation, leaf certificates, trust)
- HTTP/HTTPS MITM proxy with concurrent request handling
- SQLite storage with WAL mode
- Mock rule engine (exact, wildcard, regex matching)
- Token optimization (trim, markdown, toon formats)
- MCP server with 7 tools for AI agent integration
- CLI with 30+ commands via Cobra
- System proxy management on macOS
