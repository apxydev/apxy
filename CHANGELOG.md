# Changelog

User-facing changes in each APXY release, newest first.

## APXY 1.10.0: Your agent knows APXY as soon as it connects (2026-11-26)

### ✨ New
- `apxy mcp` now serves the apxy skill over MCP. Claude Code (2.1.331 or later) loads it as `apxy:apxy` as soon as you add the APXY MCP server, with nothing else to install, and the skill always matches your apxy version.
- `apxy setup skills` installs the same skill as files for agents that don't load skills over MCP, such as Codex, Cursor, `claude -p`, and CI. `apxy setup mcp --client codex --write` now installs it too, and installed copies update themselves when apxy updates.
- `apxy mcp --no-skills` serves tools only, for setups that already ship the skill as files.

### 🐞 Bug Fixes
- `apxy rewrite remove --all`, `apxy filter remove --all`, and `apxy breakpoint remove --all` work while a proxy is running, instead of failing with an internal server error.
- Removing, enabling, or disabling breakpoints now takes effect on the running proxy right away. Before, a removed breakpoint could still pause requests until the next start.
- Next-step hints and the Free session message now name commands that exist.
- The skill's script, rewrite, and mock examples now work as written.

## APXY 1.9.1: Phones show up under Devices (2026-11-26)

### 🐞 Bug Fixes
- A phone or app that only uses HTTPS now shows up under Devices, and selecting it lists its requests.
- Import cURL in Compose reads the request body correctly, including commands copied from a browser.

## APXY 1.9.0: Redesign UI (2026-11-25)

### ✨ New
- Redesign UI

## APXY 1.8.1: Pro licenses renew on their own (2026-11-25)

### ⚡ Improvements
- `apxy start` and `apxy license status` renew your Pro license when they run, and a running proxy checks it about once a day. You stay on Pro for up to 7 days offline.
- When the server rejects a license (revoked, expired, or removed from this device), APXY tells you why. A network or server error no longer counts as a rejection.

### ⚠️ Changed
- APXY only accepts licenses signed for the device they are used on. If Pro turns into Free after you update, run `apxy license activate --key "<key>"` once. Your key is in the [Polar customer portal](https://polar.sh/qnc/portal).

### 🐞 Bug Fixes
- Pro no longer turns into Free 7 days after activation.

## APXY 1.8.0: Check SSE and WebSocket streams, HTTP/2, and verified server certificates (2026-11-23)

### ✨ New
- `apxy wait --expect` and the `wait_for_request` MCP tool can check streams. For SSE: `sse.data`, `sse.event`, `sse.count`, `sse.last.data`, and `sse.text`, which joins OpenAI, Anthropic, and Gemini deltas into the full answer. For WebSocket: `ws.server.data`, `ws.client.data`, their `.last` forms, and frame counts. JSON paths work in both, as in `--expect 'ws.server.data.type == order_created'`. While the stream is open, APXY keeps checking until every expectation passes, the stream ends, or the timeout passes.
- HTTP/2: when the client and the server both support it, APXY uses HTTP/2 on both sides of a decrypted connection. Captures, mocks, and streams work over it.
- `apxy start --insecure-upstream` and `apxy run --insecure-upstream` accept any server certificate.

### ⚠️ Changed
- APXY now checks the certificate of each server whose traffic it decrypts, except on localhost. A bad certificate returns a `502` with `X-Apxy-Error: upstream_certificate` and the reason. Before, APXY accepted any certificate, so a check could pass on a server that real clients reject. Use `--insecure-upstream` for a server you trust.

### 🐞 Bug Fixes
- `--help-format agent` shows help and never runs the command. Before, `apxy start --help-format agent` without `--help` started the proxy and turned on the system proxy.
- `apxy run --port` no longer takes the control API or web UI port of a running APXY for a proxy.
- WebSocket frames captured in the same millisecond keep their order.

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
