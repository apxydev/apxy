# Advanced Rules -- Network, Scripts, Breakpoints, Redirects, Filters

## Prerequisites

Ensure proxy is running: `apxy proxy status`
Most features in this section require a Pro license.

## Network Simulation

Simulate degraded network conditions globally for all proxied traffic.

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules network set` | Apply simulated network conditions | `--latency` (ms), `--bandwidth` (kbps, 0 = unlimited), `--packet-loss` (0-100%) |
| `apxy rules network clear` | Remove all conditions, restore normal throughput | `--dry-run` |

Examples:

```bash
# Add 200ms latency to every request
apxy rules network set --latency 200

# Simulate a slow 3G connection
apxy rules network set --latency 500 --bandwidth 256 --packet-loss 5

# Remove all network simulation
apxy rules network clear
```

## Script Rules

Run JavaScript on matching requests or responses. Provide code inline (`--code`) or from a file (`--file`). Scripts execute at a hook point: `onRequest` (before forwarding) or `onResponse` (before returning to client). The `--match` flag accepts a DSL expression to scope which traffic the script applies to (default: `*` matches all).

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules script add` | Add a JS proxy script | `--name` (req), `--file` or `--code` (one req), `--hook` (onRequest\|onResponse), `--match` (DSL, default `*`) |
| `apxy rules script list` | List all scripts | `--format` (json\|toon), `--quiet` |
| `apxy rules script enable` | Re-enable a disabled script | `--id` or `--all`, `--dry-run` |
| `apxy rules script disable` | Disable without removing | `--id` or `--all`, `--dry-run` |
| `apxy rules script remove` | Remove a script | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Inline: rewrite response body
apxy rules script add --name "rewrite-body" \
  --code 'response.body = response.body.replace("foo","bar")' \
  --match "host == api.example.com" --hook onResponse

# File: inject auth token on every request to /api
apxy rules script add --name "add-auth" \
  --file ./scripts/inject-token.js --hook onRequest \
  --match "path contains /api"

# List and remove
apxy rules script list
apxy rules script remove --id <ID>
```

## Breakpoint Rules

Pause matching requests or responses for manual inspection before forwarding. Use `--phase` to control when the breakpoint fires: `request` (before upstream), `response` (before client), or `both`. Paused traffic auto-resumes after `--timeout` milliseconds (default 30000). Use `pending` to see what is paused, and `resolve` to resume (optionally modifying status, headers, or body).

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules breakpoint add` | Add a breakpoint rule | `--name` (req), `--match` (DSL, req), `--phase` (request\|response\|both), `--timeout` (ms, default 30000) |
| `apxy rules breakpoint list` | List all breakpoints | `--format` (json\|toon), `--quiet` |
| `apxy rules breakpoint enable` | Re-enable a disabled breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy rules breakpoint disable` | Disable without removing | `--id` or `--all`, `--dry-run` |
| `apxy rules breakpoint remove` | Remove a breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy rules breakpoint pending` | List requests currently paused | `--quiet` |
| `apxy rules breakpoint resolve` | Resume a paused request | `--id` (req), `--status`, `--headers` (JSON), `--body`, `--drop`, `--dry-run` |

Resolve options:

- Resume as-is: `apxy rules breakpoint resolve --id <ID>`
- Modify and resume: `apxy rules breakpoint resolve --id <ID> --status 200 --body '{"ok":true}' --headers '{"X-Debug":"true"}'`
- Drop the request: `apxy rules breakpoint resolve --id <ID> --drop`

## Redirect Rules

Rewrite request URLs before forwarding. The `--match` flag controls pattern type: `exact` (full URL match), `wildcard` (glob patterns with `*`), or `regex`.

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules redirect set` | Add a redirect rule | `--name`, `--from` (source pattern), `--to` (destination), `--match` (exact\|wildcard\|regex) |
| `apxy rules redirect list` | List all redirects | `--format` (json\|toon), `--quiet` |
| `apxy rules redirect remove` | Remove a redirect | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Redirect production API to staging
apxy rules redirect set --name "staging" \
  --from "https://api.example.com" --to "https://staging.example.com" --match exact

# Redirect all v1 paths to v2
apxy rules redirect set --name "v2-api" \
  --from "https://api.example.com/v1/*" --to "https://api.example.com/v2/*" --match wildcard

# List and remove
apxy rules redirect list
apxy rules redirect remove --id <ID>
```

## Filter Rules

Block or allow traffic by domain pattern. Use `--type block` to drop matching requests, `--type allow` to permit only matching requests (implicit deny for everything else).

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules filter set` | Add a block/allow rule | `--type` (block\|allow), `--target` (domain pattern, req) |
| `apxy rules filter list` | List all filter rules | `--format` (json\|toon), `--quiet` |
| `apxy rules filter remove` | Remove a filter | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Block ad tracking domains
apxy rules filter set --type block --target "ads.example.com"

# Allow only internal traffic
apxy rules filter set --type allow --target "*.internal.corp"

# List and remove
apxy rules filter list
apxy rules filter remove --all
```

## Caching Rules

Control upstream caching behavior for proxied traffic.

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules caching disable-cache` | Strip cache headers to force fresh responses | `--host` (empty = all hosts) |
| `apxy rules caching enable-cache` | Restore normal caching behavior | |

Examples:

```bash
# Disable caching for a specific API host
apxy rules caching disable-cache --host "api.example.com"

# Disable caching globally
apxy rules caching disable-cache

# Re-enable caching
apxy rules caching enable-cache
```

## DSL Match Expressions (Quick Reference)

Fields: `host`, `path`, `url`, `method`, `status`, `header:<Name>`
Operators: `==`, `!=`, `contains`, `startswith`, `endswith`, `matches`
Combinators: `&&`, `||`, `()`

Examples:

```
path contains /api && method == POST
host == api.example.com || host == staging.example.com
status >= 400
header:Content-Type contains json
(path startswith /v2 || path startswith /v3) && method != OPTIONS
```

Full reference: [dsl-reference.md](dsl-reference.md)

## Agent Workflow: Breakpoint Debugging

```bash
apxy rules breakpoint add --name "pause-login" --match "path contains /login && method == POST" --phase request
# trigger the request from your app or curl
apxy rules breakpoint pending                              # see paused request ID
apxy rules breakpoint resolve --id <ID>                    # resume as-is
apxy rules breakpoint resolve --id <ID> --status 200 --body '{"token":"test"}' --headers '{"X-Debug":"true"}'  # modify and resume
apxy rules breakpoint remove --all
```

## Agent Workflow: Script-Based Modification

```bash
apxy rules script add --name "rewrite-body" --code 'response.body = response.body.replace("foo","bar")' --match "host == api.example.com" --hook onResponse
apxy rules script add --name "add-auth" --file ./scripts/inject-token.js --hook onRequest --match "path contains /api"
apxy rules script list
apxy rules script remove --id <ID>
```

## Agent Workflow: Simulate Error Scenarios for Resilience Testing

Test how your app handles 3rd-party outages, rate limiting, and timeout conditions -- without actually breaking the real service.

```bash
# Simulate payment provider outage
apxy rules mock add --name "stripe-down" --url "*/v1/*" --match wildcard --status 503 \
  --body '{"error":{"message":"Service temporarily unavailable"}}'

# Simulate rate limiting
apxy rules mock add --name "rate-limit" --url "/api/*" --match wildcard --status 429 \
  --body '{"error":"Too Many Requests","retry_after":60}'

# Simulate slow upstream (2s latency) to test timeouts
apxy rules network set --latency 2000

# Simulate auth token expiry mid-session
apxy rules interceptor set --name "expire-token" --match "path contains /api" \
  --set-response-status 401 --set-response-body '{"error":"Token expired"}'

# Clear all simulated conditions when done
apxy rules mock clear
apxy rules network clear
apxy rules interceptor remove --all
```

## Common Patterns

### Redirect production to staging for safe testing

```bash
apxy rules redirect set --name "staging" \
  --from "https://api.example.com" --to "https://staging.example.com" --match exact
# Test your app -- all requests go to staging
apxy rules redirect remove --all   # restore production routing
```

### Block noisy third-party domains during debugging

```bash
apxy rules filter set --type block --target "analytics.example.com"
apxy rules filter set --type block --target "ads.tracker.io"
# Now your traffic logs only show your API calls
```

### Disable caching to always see fresh responses

```bash
apxy rules caching disable-cache --host "api.example.com"
# Debug with guaranteed fresh data
apxy rules caching enable-cache   # restore when done
```

### Inspect a specific request before it reaches the server

```bash
apxy rules breakpoint add --name "check-payload" \
  --match "path contains /orders && method == POST" --phase request
# Trigger the request from your app
apxy rules breakpoint pending          # see the paused request
# Inspect, then resume or modify:
apxy rules breakpoint resolve --id <ID>
apxy rules breakpoint remove --all
```

## Cleanup

Always remove rules when done debugging to avoid unexpected behavior:

```bash
apxy rules breakpoint remove --all
apxy rules script remove --all
apxy rules redirect remove --all
apxy rules filter remove --all
apxy rules network clear
apxy rules caching enable-cache
```

## Paid Features

Breakpoints, network simulation, and scripts require a Pro license.
Redirect and filter rules are available on the Free tier.
