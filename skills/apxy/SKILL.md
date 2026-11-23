---
name: apxy
description: "Capture and check real HTTP traffic with the APXY proxy. Use after changing code that calls an API or serves HTTP, to prove the real request and response are right instead of trusting tests. Also for checking SSE, LLM, and WebSocket streams, debugging HTTP failures (status codes, CORS, auth, webhooks), DNS overrides, mocking, replaying or diffing requests, slow-network tests, OpenAPI validation, recording LLM API calls for replay in tests, LLM token cost, and listing which hosts a process contacted."
---

# APXY

APXY is a local proxy that records every HTTP and HTTPS request passing through it. A captured request is evidence of what the code actually sent, which reading the code or a passing unit test cannot give you.

## Before you start

- If `command -v apxy` prints nothing, ask the user before installing (it adds a binary and a CA certificate): `brew tap apxydev/apxy https://github.com/apxydev/apxy && brew install apxy`, then `/mcp` to reconnect the MCP server.
- The Free plan stops each proxy session after 10 minutes. A proxy that vanishes, or an MCP `session_expired` result, means the session ended: start again and tell the user.
- Trigger the code yourself (tests, scripts, curl)? Use the CLI with `apxy run`, which routes only that process. Triggered by someone else (a browser click, an incoming webhook)? Use a running proxy (`apxy start`) and the MCP tools or CLI. Both share data and marks.

## Prove a change works

```bash
apxy mark                                    # later waits ignore earlier attempts
apxy run -- npm test -- checkout.spec.ts     # temporary proxy for this one process
apxy wait --match "POST /api/checkout" --expect "status == 200" --expect "body.order.id exists"
echo $?
```

`apxy run` starts a temporary proxy on 127.0.0.1 when none runs, sets proxy and CA variables for that process only, and needs no sudo. To test a server, send the request through it: `apxy run -- curl -s -X POST http://localhost:3000/api/checkout -d '{"sku":"A1"}'`.

| Exit | Meaning | Do |
|------|---------|----|
| `0` | Matched, every `--expect` passed | Report success; quote the record ID as evidence |
| `7` | Matched, an `--expect` failed | Read `data.expectations[].actual`, fix, rerun the loop |
| `8` | Nothing matched before the timeout | See below |

MCP equivalent: `set_mark`, trigger the code, then `wait_for_request`. Its `outcome` is `passed`, `assertion_failed`, `timeout`, or `session_expired`; a failed check is a normal result, not a tool error.

`apxy wait` flags:
- `--match "METHOD /path"` (exact path) or a match expression like `'host == api.stripe.com && path startswith /v1/'` ([dsl-reference.md](references/dsl-reference.md)).
- `--expect` (repeatable): `status`, `header:<Name>`, `body.<gjson path>` (response), or `req.body.<gjson path>` (request) with `==`, `!=`, `contains`, `startswith`, `endswith`, `matches`, `>`, `>=`, `<`, `<=`, `exists`.
- **Streams** (v1.8.0 or later): `--expect` also reads SSE events and WebSocket frames, as in `'sse.data == "[DONE]"'`, `'sse.text contains "Hello"'` (LLM deltas joined), or `'ws.server.data.type == order_created'`. While the stream is open, `wait` keeps checking until it passes, the stream ends, or the timeout. See [streams](references/dsl-reference.md#stream-fields).
- `--since <mark>` reads from a named mark. `--timeout` defaults to 30s; `--timeout 0` checks once, for a command that already ran.

When nothing matches, run `apxy logs list --limit 20`, then:
- **HTTPS shows only `CONNECT`, no path:** the host was not decrypted. Add `--ssl-domains <host>` or `--mitm-all` before `--`.
- **Nothing captured:** the client ignored the proxy. Node before 22.21 and 24.0 to 24.4 do; upgrade. Go and Ruby skip `localhost`; for Go use `http://localhost.:<port>`.
- **TLS errors:** Go and Rust `native-tls` on macOS reject decrypted hosts. Drop `--mitm-all`, or (after asking) `apxy certs trust`.
- **`status` is 502 with header `X-Apxy-Error: upstream_certificate`:** APXY refused the origin's certificate (expired, self-signed, or wrong host; localhost is exempt). That is a real finding, so report it. Only for a server you trust, add `--insecure-upstream` before `--`.
- **Different method or path** than your `--match`: compare with the list.

## Output

Piped output is a JSON envelope: lists in `.items`, one record in `.data`, a next-step `hint`. Errors go to stderr with a non-zero exit. A record's `duration` is in nanoseconds. Auth headers, cookies, and emails are masked.

## Other tasks

| Task | Read |
|------|------|
| Debug failing requests: 4xx/5xx, CORS, auth, slow, webhooks, GraphQL, Docker | [debugging.md](references/debugging.md) |
| Mock endpoints, unblock a frontend, OpenAPI validation | [mocking.md](references/mocking.md) |
| Ready-made mocks: Stripe, GitHub, OpenAI, Auth0, Twilio, S3 | [mock-templates.md](references/mock-templates.md) |
| Replay or diff requests, export curl or HAR | [replay-diff.md](references/replay-diff.md) |
| Record and replay LLM calls in tests, LLM token cost, hosts contacted | [llm-and-agent-traffic.md](references/llm-and-agent-traffic.md) |
| Network simulation, DNS overrides, breakpoints, scripts, rewrites, filters, caching, TLS key log | [advanced-rules.md](references/advanced-rules.md) |
| Which MCP tool does what | [mcp-tools.md](references/mcp-tools.md) |
| Exact flags | [cli-overview.md](references/cli-overview.md) or `apxy <cmd> --help --help-format agent` |

## Gotchas

- **A new proxy starts with empty logs.** Read what you need before starting another.
- **`apxy start` runs in the foreground** and, on macOS, enables the system proxy and asks to trust the CA. In scripts: `apxy start --no-system-proxy --no-trust-ca --port P &`, then `until apxy status --quiet --port P; do sleep 0.2; done` (ready in about a second). Stop it with `apxy stop`.
- **Always keep `--help` when reading help.** Before v1.8.0, `--help-format agent` only formatted it, so `apxy start --help-format agent` started the proxy and turned on the system proxy.
- **Needs a running proxy:** `dns`, `filter`, `rewrite`, `breakpoint`, `script`, `network`, `caching`, `ssl`, `recording`, `mock import`, `logs replay`. Reading logs, `mock add`, and `schema` work without one.
- **Ports:** proxy 8080, control API 8081, web UI 8082 by default. "Address in use" means a proxy already runs.
- **Browser capture:** `apxy browser <url>`. **Teach the repo's agents this loop:** `apxy setup agents` (edits `AGENTS.md`/`CLAUDE.md`, so only when asked).
