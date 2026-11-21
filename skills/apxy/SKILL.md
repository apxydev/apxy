---
name: apxy
description: Capture, inspect, mock, and replay HTTP and HTTPS traffic with the APXY proxy. Use after you change code that sends or serves HTTP requests, to verify the fix with real traffic instead of trusting unit tests alone. Use when debugging fetch, axios, or curl errors, unexpected status codes, CORS errors, auth failures, webhook failures, or a response body that does not match the API docs. Use when the user asks to intercept traffic, mock an endpoint, unblock a frontend, replay or diff a request, slow down the network, or validate traffic against an OpenAPI spec.
---

# APXY

APXY is a local HTTP and HTTPS proxy. It records every request and response that passes through it. You read the records with the CLI or the MCP tools, and you can mock, rewrite, replay, and diff them.

## Install the binary

Run `command -v apxy`. If it prints nothing, install APXY with Homebrew on macOS or Linux:

```bash
brew tap apxydev/apxy https://github.com/apxydev/apxy
brew install apxy
```

Or install it with the shell script:

```bash
curl -fsSL https://apxy.dev/install.sh | bash
```

The MCP server runs `apxy mcp`, so it cannot start until the binary is on your `PATH`. After you install it, run `/mcp` in Claude Code to reconnect the server.

## Prove a change works

Use this loop after you change code that sends or serves HTTP requests. Each attempt checks one real request and returns an exit code.

1. Set a mark with `apxy mark`. `apxy wait` then ignores traffic from earlier attempts.
2. Trigger the code through APXY with `apxy run -- <cmd>`. It runs one process with the proxy and CA variables set. When no proxy is running, it starts a temporary one on 127.0.0.1. It does not change the system proxy or the system trust store, and it needs no sudo.
3. Run `apxy wait` with the request to match and the conditions it must meet.
4. Read the exit code.

```bash
apxy mark
apxy run -- npm test -- checkout.spec.ts
apxy wait --match "POST /api/checkout" --expect "status == 200" --expect "body.order.id exists"
echo $?
```

When the code you changed is a server, send the request through APXY. curl, Python, and Java clients are captured when they call localhost.

```bash
apxy mark
apxy run -- curl -s -X POST http://localhost:3000/api/checkout -d '{"sku":"A1"}'
apxy wait --match "POST /api/checkout" --expect "status == 201" --expect "req.body.sku == A1"
```

| Exit code | Meaning | Next step |
|-----------|---------|-----------|
| `0` | A request matched and every `--expect` passed. | The change works. Quote the record ID from the output as proof. |
| `7` | A request matched, but an `--expect` failed. | Read `data.expectations[].actual` in the output. Fix the code and run the loop again. |
| `8` | No request matched before the timeout. | Run `apxy logs list --limit 20` to see what APXY captured. |

How `apxy wait` reads its flags:

- `--match "METHOD /path"` matches the method and the exact path. It also takes a match expression such as `'host == api.stripe.com && path startswith /v1/charges'`.
- `--expect` is repeatable. Each one is a condition on `status`, `header:<Name>`, `body.<gjson path>`, or `req.body.<gjson path>`. The operators are `==`, `!=`, `contains`, `startswith`, `endswith`, `matches`, `>`, `>=`, `<`, `<=`, and `exists`.
- `--since <name>` uses a named mark from `apxy mark <name>`. Without it, `wait` uses the default mark, or the time it started.
- `--timeout` defaults to 30s. `--timeout 0` checks captured traffic once without blocking.

When `apxy wait` exits with 8, check these causes:

- The request went to HTTPS and APXY only recorded a `CONNECT` tunnel with no path. Pass `--ssl-domains <host>` or `--mitm-all` before the `--`, as in `apxy run --ssl-domains api.example.com -- npm test`.
- Node before 22.21, and Node 24.0 to 24.4, ignore the proxy variables. Upgrade Node.
- Go and Ruby clients skip the proxy for localhost. For Go, call `http://localhost.:<port>` with a trailing dot.
- Go and Rust `native-tls` clients on macOS reject decrypted hosts. Run without `--mitm-all`, or trust the CA once with `apxy certs trust`.

MCP clients get the same loop through the tools `set_mark` and `wait_for_request`. Those tools ship in the next release. The CLI loop works today in APXY v1.4.0 and later.

## Read output as an agent

When stdout is not a terminal, every command prints a JSON envelope. Lists are in `.items` and single records are in `.data`:

```json
{"ok": true, "operation": "logs_list", "items": [ ... ], "count": 3, "hint": "apxy logs show --id <id>"}
```

- `--format` (json, markdown, toon) only changes human output. Agent output ignores it.
- Pass `--output agent` or `--output human` to force a mode.
- The `duration` field of a record is in nanoseconds.
- Agent output masks `Authorization`, `Cookie`, `Set-Cookie`, `X-Api-Key`, and `X-Auth-Token` headers, and email addresses.
- Errors print as text on stderr, with a non-zero exit code.

## Domain routing

Read the reference file that matches the request:

| User intent | Read this file |
|---|---|
| Debug errors, inspect traffic, slow endpoints, CORS, auth failures, GraphQL, flaky APIs, webhooks, Docker | [debugging.md](references/debugging.md) |
| Mock APIs, stub endpoints, unblock a frontend, schema validation, breaking changes | [mocking.md](references/mocking.md) |
| Replay requests, diff responses, export curl or HAR, regression checks | [replay-diff.md](references/replay-diff.md) |
| Network simulation, breakpoints, scripts, rewrites, filters, caching | [advanced-rules.md](references/advanced-rules.md) |

For command flags, read [cli-overview.md](references/cli-overview.md).
For match expression syntax, read [dsl-reference.md](references/dsl-reference.md).
For vendor mock templates, read [mock-templates.md](references/mock-templates.md).

## Quick start

`apxy run` captures one process and needs no setup. Use `apxy start` when you need a long-running proxy for a browser or for many processes.

```bash
apxy run --ssl-domains api.example.com -- npm run dev    # capture one process
apxy start --ssl-domains api.example.com                 # proxy :8080, control API :8081, web UI :8082
apxy logs list --limit 10
apxy mock add --name stub --url "/api/users" --match wildcard --status 200 --body '{"users":[]}'
apxy stop
```

On macOS, `apxy start` turns on the system proxy and asks for a password to trust the CA. Pass `--no-system-proxy --no-trust-ca` to skip both.

## Quick triage

| Problem | First command |
|---------|---------------|
| API returns 4xx or 5xx | `apxy logs search --query "api.example.com" \| jq '.items[] \| select(.status_code >= 400)'` |
| Response body is wrong | `apxy logs show --id <ID>` |
| Compare a good and a bad request | `apxy logs diff --id-a <GOOD_ID> --id-b <BAD_ID> --scope response` |
| Mock a broken endpoint | `apxy mock add --name stub --url "/api/path" --match wildcard --status 200 --body '{}'` |
| Replay a failed request | `apxy logs replay --id <ID>` |
| Export traffic to share | `apxy logs export-har --file ./traffic.har` |
| Frontend blocked, backend not ready | `apxy mock add --name <endpoint> --url "/api/path" --match wildcard --status 200 --body '<contract-shape>'` |
| Check a deploy against the API contract | `apxy schema import --name api --file ./openapi.yaml && apxy schema validate-recent --limit 50` |
| Check a fix after a refactor | `apxy mark && apxy run -- npm test && apxy wait --match "GET /api/users" --expect "status == 200"` |

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `apxy start` fails with "address in use" | Another process uses the port | Run `apxy stop`, or pass another `--port` |
| No traffic captured | The client does not use the proxy | Run the client with `apxy run -- <cmd>`, or load the variables with `eval $(apxy env)` |
| HTTPS record has no path or body | The domain is not decrypted | Start with `--ssl-domains <domain>` or `--mitm-all`, or run `apxy ssl enable --domain <domain>` |
| Certificate errors in the client | The client does not trust the APXY CA | Use `apxy run`, which sets the CA variables, or run `apxy certs trust` |
| Search returns nothing | Wrong query, or a new proxy cleared the logs | Run `apxy logs list --limit 10` to see what is captured |
| Mock rule does not match | URL pattern or match type is wrong | Run `apxy mock list` and compare the rule's URL and match type with the request |

## Tips

- Pass `--help-format agent` to any command for help written for agents.
- `apxy browser <url>` opens a browser that routes through APXY.
- `apxy init` creates a project `.apxy/` directory with its own config, certs, and traffic.
- A new proxy from `apxy start` or `apxy run` starts with empty traffic logs. Read old traffic before you start another one.
- `apxy logs replay` sends the request through a running proxy. Start one with `apxy start` first.
- `logs`, `mock`, and `schema` commands work without a running proxy. `apxy mock import` and `apxy logs replay` are the exceptions.
- `filter`, `rewrite`, `breakpoint`, `script`, `network`, `caching`, `ssl`, and `recording` commands need a running proxy.
- On the Free plan, each proxy session stops after 10 minutes, including the temporary proxy from `apxy run`. Run the command again to start a new session.
