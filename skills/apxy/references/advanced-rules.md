# Advanced rules: network, DNS, scripts, breakpoints, rewrites, filters

With a running proxy, these commands change it at once. With none, the rule is saved and applies when the next proxy starts. `network`, `breakpoint pending`, and `breakpoint resolve` need a running proxy (`apxy start`; check it with `apxy status`).

## Network simulation

Simulate degraded network conditions globally for all proxied traffic.

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy network set` | Apply simulated network conditions | `--latency` (ms), `--bandwidth` (kbps, 0 = unlimited), `--packet-loss` (0-100%) |
| `apxy network clear` | Remove all conditions, restore normal throughput | `--dry-run` |

Examples:

```bash
# Add 200ms latency to every request
apxy network set --latency 200

# Simulate a slow 3G connection
apxy network set --latency 500 --bandwidth 256 --packet-loss 5

# Remove all network simulation
apxy network clear
```

## DNS overrides

Send a hostname's traffic to another IP without editing `/etc/hosts`. The Host header and TLS SNI keep the original name, so the server behaves as if it were the real one. Use it to run a client against staging or a local build.

```bash
apxy dns set --host api.example.com --ip 10.0.0.5
apxy dns set --host "*.staging.example.com" --ip 10.0.0.6   # an exact host wins over a wildcard
apxy dns list
apxy dns remove --host api.example.com
```

- Overrides persist across proxy restarts, so remove them when you finish.
- The origin's certificate is still checked against the original name. A local server with a self-signed certificate needs `--insecure-upstream`.
- They are refused when the proxy runs with `--upstream-proxy`, because the upstream proxy resolves names.
- To change the URL instead of the IP, use a rewrite rule.

## TLS key log

`apxy start --tls-keylog keys.log` (or `apxy run --tls-keylog keys.log -- <cmd>`) writes TLS session secrets for both sides of decrypted connections, so Wireshark can read a packet capture. `SSLKEYLOGFILE` works too. The file holds secrets: keep it private and delete it when you finish.

## Script rules

Run JavaScript on matching requests or responses. Provide code inline (`--code`) or from a file (`--file`). The script must define `function handle(ctx)` and return `ctx`. APXY calls it for each matching request and applies the fields you changed. A script without `handle` changes nothing, and no error says so. `--hook` picks when it runs (default `onResponse`), and `--match` takes a match expression (default `*`, all traffic).

| Hook | `ctx` fields to read | Fields you can change |
|------|---------------------|-----------------------|
| `onRequest`, before forwarding | `method`, `url`, `host`, `path`, `headers`, `body` | `headers`, `body` |
| `onResponse`, before the client gets it | `method`, `url`, `host`, `path`, `request_headers`, `request_body`, `status_code`, `response_headers`, `response_body` | `response_headers`, `response_body`, `status_code` |

Bodies are strings. Headers can be added or changed, not removed. The helpers `jsonParse`, `jsonStringify`, `base64Encode`, and `base64Decode` exist; `require` does not. A script stops after 5 seconds.

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy script add` | Add a JS proxy script | `--name` (req), `--file` or `--code` (one req), `--hook` (onRequest\|onResponse), `--match` (DSL, default `*`) |
| `apxy script list` | List all scripts | `--format` (json\|toon), `--quiet` |
| `apxy script enable` | Re-enable a disabled script | `--id` or `--all`, `--dry-run` |
| `apxy script disable` | Disable without removing | `--id` or `--all`, `--dry-run` |
| `apxy script remove` | Remove a script | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Inline: rewrite the response body
apxy script add --name "rewrite-body" --hook onResponse --match "host == api.example.com" \
  --code 'function handle(ctx) { ctx.response_body = ctx.response_body.replace("foo", "bar"); return ctx }'

# Inline: answer 503 for one path
apxy script add --name "fail-health" --hook onResponse --match "path == /health" \
  --code 'function handle(ctx) { ctx.status_code = 503; return ctx }'

# File: add an auth header to every request under /api
cat > ./inject-token.js <<'EOF'
function handle(ctx) {
  ctx.headers["Authorization"] = "Bearer dev-token";
  return ctx;
}
EOF
apxy script add --name "add-auth" --file ./inject-token.js --hook onRequest --match "path contains /api"

# List and remove
apxy script list
apxy script remove --id <ID>
```

## Breakpoint rules

Pause matching requests or responses for manual inspection before forwarding. Use `--phase` to control when the breakpoint fires: `request` (before upstream), `response` (before client), or `both`. Paused traffic auto-resumes after `--timeout` milliseconds (default 30000). Use `pending` to see what is paused, and `resolve` to resume (optionally modifying status, headers, or body).

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy breakpoint add` | Add a breakpoint rule | `--name` (req), `--match` (DSL, req), `--phase` (request\|response\|both), `--timeout` (ms, default 30000) |
| `apxy breakpoint list` | List all breakpoints | `--format` (json\|toon), `--quiet` |
| `apxy breakpoint enable` | Re-enable a disabled breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy breakpoint disable` | Disable without removing | `--id` or `--all`, `--dry-run` |
| `apxy breakpoint remove` | Remove a breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy breakpoint pending` | List requests currently paused | `--quiet` |
| `apxy breakpoint resolve` | Resume a paused request | `--id` (req), `--status`, `--headers` (JSON), `--body`, `--drop`, `--dry-run` |

Resolve options:

- Resume as-is: `apxy breakpoint resolve --id <ID>`
- Modify and resume: `apxy breakpoint resolve --id <ID> --status 200 --body '{"ok":true}' --headers '{"X-Debug":"true"}'`
- Drop the request: `apxy breakpoint resolve --id <ID> --drop`

## Rewrite rules

Rewrite request URLs before forwarding. `--match` sets how `--from` is read: `exact` (the full URL, or only its scheme and host to catch every path), `wildcard` (`*` matches any characters, `/` included), or `regex`.

`--to` is used as written. A `--to` with only a scheme and host keeps the request's path and query. A `--to` with a path replaces the whole path and keeps the query. `*` and `$1` in `--to` are not substituted, so `--to https://api.example.com/v2/*` sends every match to the literal path `/v2/*`. An HTTPS `--from` needs its host decrypted (`--ssl-domains` or `--mitm-all`).

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rewrite set` | Add a rewrite rule | `--name`, `--from` (source pattern), `--to` (destination), `--match` (exact\|wildcard\|regex) |
| `apxy rewrite list` | List all rewrite rules | `--format` (json\|toon), `--quiet` |
| `apxy rewrite remove` | Remove a rewrite rule | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Redirect production API to staging
apxy rewrite set --name "staging" \
  --from "https://api.example.com" --to "https://staging.example.com" --match exact

# Send every /v1/ request to a local build; the path and query stay the same
apxy rewrite set --name "local-v1" \
  --from "https://api.example.com/v1/*" --to "http://localhost:3000" --match wildcard

# Send every /v1/ request to one fixed URL; the path is replaced, the query kept
apxy rewrite set --name "v2-users" \
  --from "https://api.example.com/v1/*" --to "https://api.example.com/v2/users" --match wildcard

# List and remove
apxy rewrite list
apxy rewrite remove --id <ID>
```

## Filter rules

Block or allow traffic by domain pattern. Use `--type block` to drop matching requests, `--type allow` to permit only matching requests (implicit deny for everything else).

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy filter set` | Add a block/allow rule | `--type` (block\|allow), `--target` (domain pattern, req) |
| `apxy filter list` | List all filter rules | `--format` (json\|toon), `--quiet` |
| `apxy filter remove` | Remove a filter | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Block ad tracking domains
apxy filter set --type block --target "ads.example.com"

# Allow only internal traffic
apxy filter set --type allow --target "*.internal.corp"

# List and remove
apxy filter list
apxy filter remove --all
```

## Caching rules

Control upstream caching behavior for proxied traffic.

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy caching disable-cache` | Strip cache headers to force fresh responses | `--host` (empty = all hosts) |
| `apxy caching enable-cache` | Restore normal caching behavior | |

Examples:

```bash
# Disable caching for a specific API host
apxy caching disable-cache --host "api.example.com"

# Disable caching globally
apxy caching disable-cache

# Re-enable caching
apxy caching enable-cache
```

## Agent workflow: breakpoint debugging

```bash
apxy breakpoint add --name "pause-login" --match "path contains /login && method == POST" --phase request
# trigger the request from your app or curl
apxy breakpoint pending                              # see paused request ID
apxy breakpoint resolve --id <ID>                    # resume as-is
apxy breakpoint resolve --id <ID> --status 200 --body '{"token":"test"}' --headers '{"X-Debug":"true"}'  # modify and resume
apxy breakpoint remove --all
```

## Agent workflow: change traffic with a script

```bash
apxy script add --name "rewrite-body" --hook onResponse --match "host == api.example.com" \
  --code 'function handle(ctx) { ctx.response_body = ctx.response_body.replace("foo", "bar"); return ctx }'
apxy script list
apxy script remove --id <ID>
```

## Agent workflow: simulate errors for resilience tests

Test how your app handles third-party outages, rate limits, and timeouts. The real service stays untouched.

```bash
# Simulate payment provider outage
apxy mock add --name "stripe-down" --url "^https://api\.stripe\.com/v1/" --match regex --status 503 \
  --body '{"error":{"message":"Service temporarily unavailable"}}'

# Simulate rate limiting
apxy mock add --name "rate-limit" --url "^/api/" --match regex --status 429 \
  --body '{"error":"Too Many Requests","retry_after":60}'

# Simulate slow upstream (2s latency) to test timeouts
apxy network set --latency 2000

# Simulate auth token expiry mid-session
apxy mock add --name "expire-token" --url "^/api/" --match regex \
  --status 401 --body '{"error":"Token expired"}'

# Clear all simulated conditions when done
apxy mock clear
apxy network clear
```

## Common patterns

### Redirect production to staging for safe testing

```bash
apxy rewrite set --name "staging" \
  --from "https://api.example.com" --to "https://staging.example.com" --match exact
# Test your app. All requests go to staging.
apxy rewrite remove --all   # restore production routing
```

### Block noisy third-party domains during debugging

```bash
apxy filter set --type block --target "analytics.example.com"
apxy filter set --type block --target "ads.tracker.io"
# Now your traffic logs only show your API calls
```

### Disable caching to always see fresh responses

```bash
apxy caching disable-cache --host "api.example.com"
# Debug with guaranteed fresh data
apxy caching enable-cache   # restore when done
```

### Inspect a specific request before it reaches the server

```bash
apxy breakpoint add --name "check-payload" \
  --match "path contains /orders && method == POST" --phase request
# Trigger the request from your app
apxy breakpoint pending          # see the paused request
# Inspect, then resume or modify:
apxy breakpoint resolve --id <ID>
apxy breakpoint remove --all
```

## Cleanup

Always remove rules when done debugging to avoid unexpected behavior:

```bash
apxy breakpoint remove --all
apxy script remove --all
apxy rewrite remove --all
apxy filter remove --all
apxy network clear
apxy caching enable-cache
apxy dns list | jq -r '.items[].host' | xargs -n1 apxy dns remove --host
```

## See also

- For DSL match expression syntax used by `--match` flags: [dsl-reference.md](dsl-reference.md)
