# Advanced Rules -- Network, Scripts, Breakpoints, Redirects, Filters

Ensure proxy is running: `apxy status`. Most features in this section require a Pro license.

## Network Simulation *(Pro)*

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

## Script Rules *(Pro)*

Run JavaScript on matching requests or responses. Provide code inline (`--code`) or from a file (`--file`). Scripts execute at a hook point: `onRequest` (before forwarding) or `onResponse` (before returning to client). The `--match` flag accepts a DSL expression to scope which traffic the script applies to (default: `*` matches all).

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy script add` | Add a JS proxy script | `--name` (req), `--file` or `--code` (one req), `--hook` (onRequest\|onResponse), `--match` (DSL, default `*`) |
| `apxy script list` | List all scripts | `--format` (json\|toon), `--quiet` |
| `apxy script enable` | Re-enable a disabled script | `--id` or `--all`, `--dry-run` |
| `apxy script disable` | Disable without removing | `--id` or `--all`, `--dry-run` |
| `apxy script remove` | Remove a script | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Inline: rewrite response body
apxy script add --name "rewrite-body" \
  --code 'response.body = response.body.replace("foo","bar")' \
  --match "host == api.example.com" --hook onResponse

# File: inject auth token on every request to /api
apxy script add --name "add-auth" \
  --file ./scripts/inject-token.js --hook onRequest \
  --match "path contains /api"

# List and remove
apxy script list
apxy script remove --id <ID>
```

## Breakpoint Rules *(Pro)*

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

## Redirect Rules

Rewrite request URLs before forwarding. The `--match` flag controls pattern type: `exact` (full URL match), `wildcard` (glob patterns with `*`), or `regex`.

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rewrite set` | Add a redirect rule | `--name`, `--from` (source pattern), `--to` (destination), `--match` (exact\|wildcard\|regex) |
| `apxy rewrite list` | List all redirects | `--format` (json\|toon), `--quiet` |
| `apxy rewrite remove` | Remove a redirect | `--id` or `--all`, `--dry-run` |

Examples:

```bash
# Redirect production API to staging
apxy rewrite set --name "staging" \
  --from "https://api.example.com" --to "https://staging.example.com" --match exact

# Redirect all v1 paths to v2
apxy rewrite set --name "v2-api" \
  --from "https://api.example.com/v1/*" --to "https://api.example.com/v2/*" --match wildcard

# List and remove
apxy rewrite list
apxy rewrite remove --id <ID>
```

## Filter Rules

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

## Caching Rules

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

## Agent Workflow: Breakpoint Debugging

```bash
apxy breakpoint add --name "pause-login" --match "path contains /login && method == POST" --phase request
# trigger the request from your app or curl
apxy breakpoint pending                              # see paused request ID
apxy breakpoint resolve --id <ID>                    # resume as-is
apxy breakpoint resolve --id <ID> --status 200 --body '{"token":"test"}' --headers '{"X-Debug":"true"}'  # modify and resume
apxy breakpoint remove --all
```

## Agent Workflow: Script-Based Modification

```bash
apxy script add --name "rewrite-body" --code 'response.body = response.body.replace("foo","bar")' --match "host == api.example.com" --hook onResponse
apxy script add --name "add-auth" --file ./scripts/inject-token.js --hook onRequest --match "path contains /api"
apxy script list
apxy script remove --id <ID>
```

## Agent Workflow: Simulate Error Scenarios for Resilience Testing

Test how your app handles 3rd-party outages, rate limiting, and timeout conditions -- without actually breaking the real service.

```bash
# Simulate payment provider outage
apxy mock add --name "stripe-down" --url "*/v1/*" --match wildcard --status 503 \
  --body '{"error":{"message":"Service temporarily unavailable"}}'

# Simulate rate limiting
apxy mock add --name "rate-limit" --url "/api/*" --match wildcard --status 429 \
  --body '{"error":"Too Many Requests","retry_after":60}'

# Simulate slow upstream (2s latency) to test timeouts
apxy network set --latency 2000

# Simulate auth token expiry mid-session
apxy mock add --name "expire-token" --url "/api/*" --match wildcard \
  --status 401 --body '{"error":"Token expired"}'

# Clear all simulated conditions when done
apxy mock clear
apxy network clear
```

## Common Patterns

### Redirect production to staging for safe testing

```bash
apxy rewrite set --name "staging" \
  --from "https://api.example.com" --to "https://staging.example.com" --match exact
# Test your app -- all requests go to staging
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
```

## Free Alternatives

If the user is on Free tier:
- **Instead of breakpoints** → use `apxy mock add` to return a synthetic response for the matching path
- **Instead of network simulation** → use `--delay <ms>` on a mock rule to slow specific endpoints
- **Instead of scripts** → use `apxy mock add --headers / --status / --body` for static response overrides (mock rules are Free)

## See Also

- For DSL match expression syntax used by `--match` flags: [dsl-reference.md](dsl-reference.md)
