# Changelog

User-facing changes in each APXY release, newest first.

## APXY 1.7.0: Replay, diff, and breakpoints over MCP, plus DNS overrides and a TLS key log (2026-11-23)

### ✨ New
- MCP: agents can now replay a captured request (`replay_request`), compare two requests (`diff_traffic_logs`), and export one as curl, fetch, HTTPie, or Python (`export_traffic_log`). Exported snippets always mask secrets.
- MCP: breakpoint tools `create_breakpoint_rule`, `list_breakpoint_rules`, `remove_breakpoint_rule`, `list_pending_breakpoints`, and `resolve_breakpoint` let an agent pause a request, change its status, headers, or body, and let it continue.
- MCP: `validate_recent_traffic` checks recent requests against an imported OpenAPI schema. It reports an error when no schema is imported, so an empty result is never mistaken for a pass.
- DNS overrides: `apxy dns set --host staging.example.com --ip 10.0.0.5` sends that host's traffic to another IP. The Host header and TLS SNI keep the original name. Wildcards such as `*.example.com` work. Use `apxy dns list` and `apxy dns remove` to manage overrides, or the `set_dns_override`, `list_dns_overrides`, and `remove_dns_override` MCP tools. Overrides persist across restarts. They are refused when `--upstream-proxy` is set, because the upstream proxy resolves DNS.
- TLS key log: `apxy start --tls-keylog <file>` writes TLS session keys for both the client and the upstream side of intercepted connections, so Wireshark can decrypt a packet capture. Without the flag, APXY uses `SSLKEYLOGFILE` when it is set. `apxy run --tls-keylog <file>` works too. The file holds session secrets, so keep it private.

### 🐞 Bug Fixes
- `apxy breakpoint add` and `apxy breakpoint remove` now take effect on a running proxy at once. Before, new rules applied only after a restart.
- `apxy mcp` now reaches a proxy started on a port other than 8080, such as `apxy start --port 9090`.
- WebSocket and HTTPS tunnels no longer lose the first byte a client sends right after the handshake. Under load this corrupted the first WebSocket frame through the proxy.
