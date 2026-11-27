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
- In a git worktree, run every `apxy` command from inside it: agents in other worktrees share the proxy, and the worktree keeps your requests, marks, and mocks apart from theirs.

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
- **Streams**: `--expect` also reads SSE events and WebSocket frames, as in `'sse.data == "[DONE]"'`, `'sse.text contains "Hello"'` (LLM deltas joined), or `'ws.server.data.type == order_created'`. While the stream is open, `wait` keeps checking until it passes, the stream ends, or the timeout. See [streams](references/dsl-reference.md#stream-fields).
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
| Parallel agents in worktrees: whose traffic `wait` sees, `--global` rules, `mocked_by`, the shared proxy, `apxy browser`, simulators and emulators, `apxy ui` | [workspaces.md](references/workspaces.md) |
| Which MCP tool does what | [mcp-tools.md](references/mcp-tools.md) |
| Web UI, MCP over HTTP, `apxy setup mcp`, phones and devices, HTTP/2 and gRPC, project mode, upstream proxy, Free vs Pro | [setup-and-devices.md](references/setup-and-devices.md) |
| Exact flags | [cli-overview.md](references/cli-overview.md) or `apxy <cmd> --help --help-format agent` |

## Gotchas

- **`apxy start` runs in the foreground** and, on macOS, enables the system proxy and asks to trust the CA. In scripts: `apxy start --no-system-proxy --no-trust-ca --port P &`, then `until apxy status --quiet --port P; do sleep 0.2; done` (ready in about a second: it exits 0 once `apxy start` has written its PID file and the port answers, the proxy `apxy run` joins). Stop it with `apxy stop`. It stops only a proxy this workspace started that no other workspace uses. When it refuses (`stop_refused`), leave the proxy running. Never pass `--force`.
- **Needs a running proxy:** `recording`, `breakpoint pending` and `resolve`, `certs custom`, `logs replay`. Rule commands (`mock`, `dns`, `filter`, `rewrite`, `script`, `breakpoint add`, `ssl`, `caching`, `network`) save the rule when no proxy runs (`apply_mode: persistent_offline`), and the next proxy applies it. For a proxy on a non-default port, pass `--control-url http://127.0.0.1:<port+1>`, or the rule only waits for the next start.
- **Parallel agents** (worktrees): `wait` sees this worktree's requests and untagged ones. A subagent that uses the MCP tools from another worktree passes `workspace` (its worktree path). Mocks and rules go to the worktree's `.apxy/rules.json` and answer only its traffic. Make them with the CLI or MCP tools, run `apxy rules apply` after a hand edit, and add `--global` for untagged traffic: browsers on the system proxy, iOS simulators, and an Android emulator set up outside a workspace or before a proxy runs (`untagged_because` says why). `mocked_by` in the `wait` output means a mock answered, not the real API. See [workspaces.md](references/workspaces.md).
- **Ports:** proxy 8080, control API 8081, web UI 8082 by default. "Address in use" means a proxy already runs.
- **Browser capture:** `apxy browser <url>` (a profile and a tagged proxy port per worktree). **Simulators and emulators:** `apxy device setup` (an Android emulator set up in a worktree while a proxy runs gets the worktree's tagged port, held for 8 hours). **Teach the repo's agents this loop:** `apxy setup agents` (edits `AGENTS.md`/`CLAUDE.md`, so only when asked).
