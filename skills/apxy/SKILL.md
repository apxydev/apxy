---
name: apxy
description: APXY — AI agent tools for network debugging and API contract validation. Use this skill whenever there's any HTTP/HTTPS debugging, network inspection, API mocking, or contract validation needed — even if the issue seems simple. Use when debugging fetch/axios/curl errors, unexpected status codes, CORS errors, 401/403 auth failures, 502/503 upstream errors, or when a response body doesn't match the API docs. Also use when the user says "debug API", "check network request", "why is this request failing", "prod regression", "compare API responses", "mock this endpoint", "intercept traffic", "why did this start failing after deploy", "frontend is blocked waiting for backend", "unblock frontend dev", "mock the backend", "validate against OpenAPI", "catch breaking changes", "API contract", "field naming changed", "response schema mismatch", "regression test API", "design-first", or "parallel frontend backend development". Prefer this over browser devtools or plain curl when you need to capture, replay, diff, mock, or validate traffic — APXY logs everything automatically and lets you query history.
metadata:
  priority: 8
  bashPatterns:
    - "apxy\\b"
    - "\\bapxy\\s+(proxy|rules|traffic|schema|setup|tools|config|license)"
    - "\\bapxy\\s+rules\\s+(mock|breakpoint|script|interceptor|redirect|filter|caching|network)"
    - "\\bapxy\\s+traffic\\s+(logs|recording|devices|sql)"
    - "\\bapxy\\s+tools\\s+(request|protobuf|db)"
    - "\\bapxy\\s+proxy\\s+(start|stop|status|env|browser)"
    - "eval\\s+\\$\\(apxy\\s+proxy\\s+env"
  promptSignals:
    - "network proxy"
    - "mock api"
    - "debug traffic"
    - "intercept https"
    - "capture requests"
    - "api mocking"
    - "http debugging"
    - "proxy start"
    - "traffic inspection"
    - "breakpoint request"
    - "schema validation"
    - "har export"
    - "ssl interception"
    - "network throttling"
    - "api contract"
    - "breaking change"
    - "openapi validation"
    - "frontend blocked"
    - "unblock frontend"
    - "mock backend"
    - "parallel development"
    - "regression test api"
    - "contract violation"
    - "field naming"
    - "response schema"
    - "design first api"
    - "api drift"
  docs: https://github.com/apxydev/apxy
retrieval:
  aliases:
    - apxy
    - apxy-cli
    - agent proxy
    - https proxy
  intents:
    - debug api traffic
    - mock http responses
    - intercept and modify requests
    - validate api against openapi schema
    - capture network traffic for analysis
    - set breakpoints on http requests
    - simulate slow network conditions
    - replay captured requests
    - export traffic as HAR
    - run sql queries on captured traffic
    - unblock frontend development by mocking backend endpoints
    - detect breaking api changes between deploys
    - validate api contract compliance against openapi spec
    - catch field naming regressions in api responses
    - run api regression tests with batch requests
    - simulate error scenarios for resilience testing
  entities:
    - proxy
    - mock rule
    - breakpoint
    - interceptor
    - script
    - schema
    - traffic log
    - filter
    - redirect
    - HAR file
  examples:
    - apxy proxy start --port 8080
    - apxy rules mock add --name stub --url "/api/users" --match exact --status 200 --body '{"users":[]}'
    - apxy traffic logs search --query "api.example.com" --format json
    - apxy rules breakpoint add --name "pause-login" --match "path contains /login"
    - apxy schema import --name my-api --file ./openapi.yaml
    - apxy rules script add --name rewrite --code 'response.body = response.body.replace("foo","bar")'
allowed-tools: Bash, Read, Grep, Glob
---

# APXY CLI — Agent Network Proxy

HTTPS proxy for capturing, inspecting, modifying, and mocking API traffic. Optimized for AI agents.

## Domain Routing

Based on the user's request, read the appropriate reference file for detailed workflows and commands:

| User Intent | Read This File |
|---|---|
| Debug errors, inspect traffic, SQL queries, slow endpoints, CORS, auth failures | [debugging.md](references/debugging.md) |
| Mock APIs, stub endpoints, unblock frontend, interceptors, schema validation | [mocking.md](references/mocking.md) |
| Replay requests, diff responses, export cURL/HAR, regression testing | [replay-diff.md](references/replay-diff.md) |
| Network simulation, breakpoints, scripts, redirects, filters, caching | [advanced-rules.md](references/advanced-rules.md) |

For detailed command flags: [cli-overview.md](references/cli-overview.md)
For DSL match expression syntax: [dsl-reference.md](references/dsl-reference.md)
For debug pattern recipes: [debug-patterns.md](references/debug-patterns.md)
For vendor mock templates: [mock-templates.md](references/mock-templates.md)

## Quick Start

```bash
apxy proxy start --port 8080          # proxy :8080, control API :8081
eval $(apxy proxy env)                # inject proxy env into shell
apxy traffic logs list --format json --limit 10
apxy rules mock add --name "stub" --url "/api/users" --match exact --status 200 --body '{"users":[]}'
apxy traffic sql query "SELECT host, COUNT(*) as cnt FROM traffic_logs GROUP BY host ORDER BY cnt DESC LIMIT 10"
```

## Quick Triage

| Problem | First command to run |
|---------|---------------------|
| API returning 4xx/5xx | `apxy traffic logs search --query "host.com" --format json \| jq '.[] \| select(.status_code >= 400)'` |
| Response body wrong | `apxy traffic logs show --id <ID> --format markdown` |
| Compare good vs bad | `apxy traffic logs diff --id-a <GOOD_ID> --id-b <BAD_ID> --scope response` |
| Mock a broken endpoint | `apxy rules mock add --name stub --url "/api/path" --match wildcard --status 200 --body '{}'` |
| Add/remove request headers | `apxy rules interceptor set --name fix --match "host == api.com" --action modify --set-request-headers Authorization="Bearer test"` |
| Pause and inspect a request | `apxy rules breakpoint add --name pause --match "path contains /login && method == POST" --phase request` |
| Simulate slow network | `apxy rules network set --latency 2000` |
| SQL query on traffic | `apxy traffic sql query "SELECT host, status_code, COUNT(*) FROM traffic_logs GROUP BY host, status_code ORDER BY COUNT(*) DESC"` |
| Replay a failed request | `apxy traffic logs replay --id <ID>` |
| Export for sharing | `apxy traffic logs export-har --file ./traffic.har` |
| Frontend blocked, backend not ready | `apxy rules mock add --name <endpoint> --url "/api/path" --match wildcard --status 200 --body '<contract-shape>'` |
| Check if deploy broke the API contract | `apxy schema import --name api --file ./openapi.yaml && apxy schema validate-recent --limit 50` |
| Field name silently changed (user_id → userId) | `apxy traffic logs search-bodies --pattern "userId" --scope response --limit 20` |
| Simulate 3rd-party outage / 500 errors | `apxy rules mock add --name outage --url "*/api/*" --match wildcard --status 503 --body '{"error":"service unavailable"}'` |
| API regression test after refactor | `apxy tools request batch --file ./requests.json --compare-history --time-range 60` |

## Proxy Lifecycle

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy proxy start` | Start proxy server | `--port` (8080), `--ssl-domains`, `--mitm-all`, `--bypass-domains`, `--no-system-proxy`, `--upstream-proxy`, `--project-dir`, `--auto-validate`, `--max-body`, `--web-port`, `--control-port`, `--no-mdns`, `--cert-dir` |
| `apxy proxy stop` | Stop running proxy | |
| `apxy proxy status` | Show proxy status | `--port`, `--format` |
| `apxy proxy env` | Print proxy env vars | `--port`, `--lang` (all\|go\|node\|python\|ruby\|curl), `--open`, `--script`, `--bypass-domains`, `--no-cert` |
| `apxy proxy browser` | Launch proxied browser | `--browser` (chrome\|firefox), `--port`, `--cert-dir` |

### Three-Tier HTTPS Handling

| Tier | Behavior | Control |
|------|----------|---------|
| **TUNNEL** | Cert-pinned domains tunneled as-is, no inspection | `--bypass-domains '*.openai.com,*.local'` |
| **SKIP** | Non-enabled domains forwarded, headers only (no body) | Default for unlisted domains |
| **DEEP** | Full MITM with request/response body capture | `--ssl-domains 'api.example.com'` or `--mitm-all` |

Key `proxy start` patterns:
```bash
apxy proxy start --port 8080 --ssl-domains "api.example.com,*.stripe.com"   # deep inspect specific domains
apxy proxy start --mitm-all --bypass-domains "*.openai.com"                 # inspect all except pinned
apxy proxy start --no-system-proxy --port 9090                              # manual proxy, no system config
apxy proxy start --upstream-proxy http://corp-proxy:3128                    # proxy chaining
apxy proxy start --project-dir ./my-project --auto-validate                 # scoped + schema validation
```

## Setup Essentials

```bash
# Certificate setup (required for HTTPS interception)
apxy setup certs generate        # generate root CA certificate
apxy setup certs trust           # trust CA in system keychain (may need sudo)

# Enable HTTPS body capture for specific domains
apxy setup ssl enable --domain api.example.com

# Project-scoped isolation (own DB, certs, mock rules per project)
apxy setup init                  # creates .apxy/ directory in current project

# Mobile device debugging
apxy setup mobile setup --platform ios --qr    # scan QR to configure device

# Settings portability
apxy setup settings export --file settings.json
apxy setup settings import --file settings.json
```

## Output Formats

All traffic/list commands accept `--format`:
- **json** — machine-readable, pipe through `jq`
- **markdown** — human-readable tables
- **toon** — compact token-optimized notation, minimal tokens for AI context

## Tips

- Use `--help-format agent` on any command for AI-optimized help output
- Use `--error-format json` for programmatic error handling
- `apxy proxy browser` launches a pre-configured browser — no manual proxy setup needed
- `apxy setup init` creates a project-scoped `.apxy/` directory for isolated config/data
- `--format toon` minimizes tokens when feeding output to an AI agent
- DB commands (logs, mock, sql, schema, request) work without a running proxy
- Runtime commands (`rules filter`, `rules redirect`, `rules interceptor`, `rules breakpoint`, `rules script`, `rules network`, `rules caching`, `traffic recording`) need `apxy proxy start`
