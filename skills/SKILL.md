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
    - "\\bapxy\\s+(start|stop|status|env|browser)"
    - "eval\\s+\\$\\(apxy"
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
  docs: https://github.com/nicepkg/apxy
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
---

# APXY CLI — Agent Network Proxy

HTTPS proxy for capturing, inspecting, modifying, and mocking API traffic. Optimized for AI agents.

## Quick Start

```bash
apxy proxy start --port 8080          # proxy :8080, control API :8081
eval $(apxy env)                      # inject proxy env into shell
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
| Add/remove request headers | `apxy rules interceptor set --name fix --match "host == api.com" --set-request-headers '{"Authorization":"Bearer test"}'` |
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


## DSL Match Expressions

Used by breakpoint `--match`, script `--match`, interceptor `--match`, and filter `--target`.

| Field | Example |
|-------|---------|
| `host` | `host == api.example.com` |
| `path` | `path contains /login` |
| `url` | `url startswith https://api.stripe.com` |
| `method` | `method == POST` |
| `status` | `status >= 400` |
| `header:<Name>` | `header:Content-Type contains json` |

**Operators:** `==`, `!=`, `contains`, `startswith`, `endswith`, `matches` (regex), `>=`, `<=`, `>`, `<`
**Combinators:** `&&` (AND), `||` (OR), `()` (grouping)
**Wildcard:** `*` matches all traffic

Examples: `"host == api.example.com && method == POST"`, `"status >= 400 || path contains /error"`, `"path contains /api && status >= 500"`

---

## 1. Proxy (5 commands)

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

## 2. Rules — Mock (6 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules mock add` | Create mock rule | `--name`, `--url`, `--match` (exact\|wildcard\|regex), `--method`, `--status` (200), `--body`, `--delay`, `--priority` |
| `apxy rules mock list` | List rules | `--format`, `--quiet` |
| `apxy rules mock enable` | Enable rule | `--id` or `--all` |
| `apxy rules mock disable` | Disable rule | `--id` or `--all`, `--dry-run` |
| `apxy rules mock remove` | Remove rule | `--id` or `--all`, `--dry-run` |
| `apxy rules mock clear` | Delete all rules | `--dry-run` |

## 3. Rules — Redirect (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules redirect set` | Add redirect rule | `--name`, `--from`, `--to`, `--match` (exact\|wildcard\|regex) |
| `apxy rules redirect list` | List redirects | `--format`, `--quiet` |
| `apxy rules redirect remove` | Remove redirect | `--id` or `--all`, `--dry-run` |

## 4. Rules — Interceptor (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules interceptor set` | Add interceptor | `--name`, `--match` (DSL), `--action` (mock\|modify\|observe), `--description`, `--add-request-headers`, `--set-request-headers`, `--set-response-headers`, `--remove-headers`, `--set-response-status`, `--set-response-body`, `--delay-ms` |
| `apxy rules interceptor list` | List interceptors | `--format`, `--quiet` |
| `apxy rules interceptor remove` | Remove interceptor | `--id` or `--all`, `--dry-run` |

## 5. Rules — Breakpoint (7 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules breakpoint add` | Add breakpoint rule | `--name` (req), `--match` (DSL, req), `--phase` (request\|response\|both), `--timeout` (30000ms) |
| `apxy rules breakpoint list` | List breakpoints | `--format`, `--quiet` |
| `apxy rules breakpoint enable` | Enable breakpoint | `--id` or `--all` |
| `apxy rules breakpoint disable` | Disable breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy rules breakpoint remove` | Remove breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy rules breakpoint pending` | List paused requests | `--quiet` |
| `apxy rules breakpoint resolve` | Resume paused request | `--id` (req), `--status`, `--headers` (JSON), `--body`, `--drop`, `--dry-run` |

## 6. Rules — Script (5 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules script add` | Add JS proxy script | `--name` (req), `--file` or `--code` (one req), `--hook` (onRequest\|onResponse), `--match` (DSL, default: *) |
| `apxy rules script list` | List scripts | `--format`, `--quiet` |
| `apxy rules script enable` | Enable script | `--id` or `--all` |
| `apxy rules script disable` | Disable script | `--id` or `--all`, `--dry-run` |
| `apxy rules script remove` | Remove script | `--id` or `--all`, `--dry-run` |

## 7. Rules — Network (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules network set` | Simulate network conditions | `--latency` (ms), `--bandwidth` (kbps), `--packet-loss` (0-100%) |
| `apxy rules network clear` | Clear conditions | `--dry-run` |

## 8. Rules — Caching (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules caching disable-cache` | Strip cache headers | `--host` (empty = all) |
| `apxy rules caching enable-cache` | Restore caching | |

## 9b. Rules — Filter (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules filter set` | Add block/allow rule | `--type` (block\|allow), `--target` (domain pattern, req) |
| `apxy rules filter list` | List filter rules | `--format`, `--quiet` |
| `apxy rules filter remove` | Remove filter | `--id` or `--all`, `--dry-run` |

## 9. Traffic — Logs (14 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic logs list` | List traffic records | `--limit` (50), `--offset`, `--format`, `--quiet` |
| `apxy traffic logs show` | Show record detail | `--id` (req), `--format` |
| `apxy traffic logs search` | Search by URL/host/method | `--query`, `--limit` (20), `--format`, `--quiet` |
| `apxy traffic logs search-bodies` | Full-text body search | `--pattern`, `--scope` (request\|response\|both), `--limit`, `--format` |
| `apxy traffic logs graphql` | Search GraphQL ops | `--operation-name`, `--operation-type` (query\|mutation\|subscription), `--limit`, `--format` |
| `apxy traffic logs jsonpath` | Extract JSON via gjson | `--id`, `--path`, `--scope` (request\|response) |
| `apxy traffic logs diff` | Compare two records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy traffic logs label` | Label a record | `--id` (req), `--color` (red\|green\|blue\|yellow\|purple), `--comment` |
| `apxy traffic logs replay` | Replay captured request | `--id`, `--port` (8080) |
| `apxy traffic logs export-curl` | Export as client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python) |
| `apxy traffic logs export-har` | Export as HAR 1.2 | `--file`, `--limit` (10000) |
| `apxy traffic logs import-har` | Import from HAR file | `--file` (req) |
| `apxy traffic logs stats` | Traffic statistics | `--format` |
| `apxy traffic logs clear` | Delete all records | `--dry-run` |

## 10. Traffic — Recording, Devices, SQL (4 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic recording start` | Start traffic capture | |
| `apxy traffic recording stop` | Stop traffic capture | |
| `apxy traffic devices list` | List connected devices | `--format`, `--mobile`, `--quiet`, `--web-url` |
| `apxy traffic sql query "<SQL>"` | Run read-only SQL | Tables: `traffic_logs`, `mock_rules` |

## 11. Schema (6 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy schema import` | Import OpenAPI spec | `--name`, `--file` or `--url` (one req) |
| `apxy schema list` | List schemas | `--format`, `--quiet` |
| `apxy schema show` | Show schema details | `--id` (req) |
| `apxy schema validate` | Validate record vs schema | `--record-id` (req), `--schema-id` (req) |
| `apxy schema validate-recent` | Validate recent traffic | `--limit` (20) |
| `apxy schema delete` | Delete schema | `--id` (req), `--dry-run` |

## 12. Setup (15 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy setup init` | Init project workspace | Creates `.apxy/` directory |
| `apxy setup certs generate` | Generate root CA cert | |
| `apxy setup certs info` | Show CA details | |
| `apxy setup certs trust` | Trust CA in keychain | |
| `apxy setup certs custom add` | Add custom CA | `--domain` (req), `--cert` (req), `--key` (req), `--label`, `--no-trust` |
| `apxy setup certs custom list` | List custom CAs | `--format`, `--quiet` |
| `apxy setup certs custom info` | Show custom CA | `--domain` (req) |
| `apxy setup certs custom remove` | Remove custom CA | `--domain` or `--all`, `--dry-run` |
| `apxy setup certs custom trust` | Trust custom CA | `--domain` (req) |
| `apxy setup ssl enable` | Enable HTTPS intercept | `--domain` (req) |
| `apxy setup ssl disable` | Disable HTTPS intercept | `--domain` or `--all`, `--dry-run` |
| `apxy setup ssl list` | List SSL domains | `--format`, `--quiet` |
| `apxy setup mobile setup` | Mobile setup instructions | `--platform` (ios\|android), `--port`, `--qr` |
| `apxy setup settings export` | Export settings | `--file` |
| `apxy setup settings import` | Import settings | `--file` (req), `--dry-run` |

## 13. Tools (9 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy tools request compose` | Send HTTP request | `--method` (GET), `--url` (req), `--body`, `--headers` (JSON) |
| `apxy tools request batch` | Batch from file | `--file` (req), `--compare-history`, `--time-range` (60), `--timeout` (10000), `--format` |
| `apxy tools request diagnose` | Diagnose from history | `--file` (req), `--time-range` (60), `--match-mode` (exact\|contains\|prefix), `--format` |
| `apxy tools protobuf add-schema` | Register proto schema | `--name`, `--file` or `--content` |
| `apxy tools protobuf list-schemas` | List proto schemas | |
| `apxy tools protobuf decode` | Decode proto body | `--id`, `--scope` (request\|response) |
| `apxy tools protobuf remove-schema` | Remove proto schema | `--id` |
| `apxy tools db info` | Database info | |
| `apxy tools db clean` | Clean database | `--traffic`, `--rules`, `--all` |

## 14. Config (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy config export` | Export config to JSON | `--file` (apxy-config.json) |
| `apxy config import` | Import config from JSON | `--file` (req) |

## 15. License (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy license activate` | Activate license | `--key` (req, format: APXY-XXXX-XXXX-XXXX) |
| `apxy license deactivate` | Deactivate license | |
| `apxy license status` | Show license status | |

---

## Output Formats

All traffic/list commands accept `--format`:
- **json** — machine-readable, pipe through `jq`
- **markdown** — human-readable tables
- **toon** — compact token-optimized notation, minimal tokens for AI context

## Agent Workflows

### 1. Debug a Broken API

```bash
apxy traffic logs search --query "api.example.com" --format json | jq '.[] | select(.status_code >= 400)'
apxy traffic logs show --id <ID> --format markdown
apxy traffic logs jsonpath --id <ID> --path "error.message"
apxy traffic logs diff --id-a <GOOD_ID> --id-b <BAD_ID> --scope response
```

### 2. Mock for Testing

```bash
apxy rules mock add --name "stub-payment" --url "https://api.stripe.com/v1/charges" \
  --match wildcard --status 200 --body '{"id":"ch_test","status":"succeeded"}'
apxy rules mock list
apxy tools request compose --method POST --url "https://api.stripe.com/v1/charges" --body '{"amount":1000}'
apxy rules mock remove --id <RULE_ID>
```

### 3. Replay and Diff

```bash
apxy traffic logs export-curl --id <FAIL_ID>
apxy traffic logs replay --id <FAIL_ID>
apxy traffic logs diff --id-a <FAIL_ID> --id-b <NEW_ID> --scope response
```

### 4. Route Terminal Traffic

```bash
apxy proxy start --port 8080
eval $(apxy env)              # in another terminal
curl https://api.example.com  # captured
```

### 5. SQL Traffic Analysis

```bash
apxy traffic sql query "SELECT host, path, method, COUNT(*) as cnt FROM traffic_logs GROUP BY host, path, method ORDER BY cnt DESC LIMIT 20"
apxy traffic sql query "SELECT host, COUNT(*) as total, SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) as errors FROM traffic_logs GROUP BY host"
apxy traffic sql query "SELECT method, url, duration_ms, status_code FROM traffic_logs WHERE duration_ms > 2000 ORDER BY duration_ms DESC LIMIT 10"
```

### 6. Breakpoint Debugging

```bash
apxy rules breakpoint add --name "pause-login" --match "path contains /login && method == POST" --phase request
# trigger the request from your app or curl
apxy rules breakpoint pending                              # see paused request ID
apxy rules breakpoint resolve --id <ID>                    # resume as-is
apxy rules breakpoint resolve --id <ID> --status 200 --body '{"token":"test"}' --headers '{"X-Debug":"true"}'  # modify and resume
apxy rules breakpoint remove --all
```

### 7. API Schema Validation

```bash
apxy schema import --name "my-api" --file ./openapi.yaml
apxy schema list
apxy proxy start --port 8080 --auto-validate         # live validation
apxy schema validate-recent --limit 50               # check recent traffic
apxy schema validate --record-id <ID> --schema-id <SID>  # validate one record
```

### 8. Script-Based Modification

```bash
apxy rules script add --name "rewrite-body" --code 'response.body = response.body.replace("foo","bar")' --match "host == api.example.com" --hook onResponse
apxy rules script add --name "add-auth" --file ./scripts/inject-token.js --hook onRequest --match "path contains /api"
apxy rules script list
apxy rules script remove --id <ID>
```

### 9. Mobile Device Debugging

```bash
apxy setup certs generate
apxy setup certs trust
apxy proxy start --port 8080
apxy setup mobile setup --platform ios --qr          # scan QR to configure device
apxy traffic devices list --mobile
```

### 10. HAR Import/Export

```bash
apxy traffic logs export-har --file ./traffic.har --limit 5000   # export for sharing
apxy traffic logs import-har --file ./colleague-traffic.har       # import in different env
```

### 11. Unblock Frontend with Backend Mocks (Design-First)

Frontend teams shouldn't wait for backend — mock every endpoint from the agreed API contract so parallel development can start immediately.

```bash
apxy proxy start --port 8080
eval $(apxy env)
# Mock each endpoint from the OpenAPI contract
apxy rules mock add --name "get-users" --url "/api/users" --match wildcard --status 200 \
  --body '{"users":[{"id":1,"name":"Alice"}]}'
apxy rules mock add --name "create-user" --url "/api/users" --match wildcard --method POST \
  --status 201 --body '{"id":2,"name":"Bob"}'
apxy rules mock add --name "auth-login" --url "/api/auth/login" --match wildcard --method POST \
  --status 200 --body '{"token":"eyJ...","expires_in":3600}'
apxy rules mock list
# Frontend hits the proxy — gets realistic responses without any backend running
```

### 12. Catch Breaking Changes Before Deploy

Compare real API responses against your OpenAPI spec — surface contract violations before users hit them.

```bash
# Import the spec that the team agreed on
apxy schema import --name "my-api" --file ./openapi.yaml
# Run with live validation so every request is checked as it happens
apxy proxy start --port 8080 --auto-validate
eval $(apxy env)
# Exercise the app (or run your test suite) — violations are flagged automatically
apxy schema validate-recent --limit 50
# Validate a specific suspicious response manually
apxy schema validate --record-id <ID> --schema-id <SCHEMA_ID>
```

### 13. API Regression Testing After Refactor

Replay a known-good batch of requests through the refactored API and compare responses to history. Catches field renames, missing fields, or changed status codes that unit tests miss.

```bash
# Capture a baseline before the refactor
apxy traffic recording start
# ... run your test suite or manual flows ...
apxy traffic recording stop
apxy traffic logs export-har --file ./baseline.har

# After refactor: batch replay and compare to history
apxy tools request batch --file ./requests.json --compare-history --time-range 60 --format json

# Check for field naming regressions (e.g. user_id silently became userId)
apxy traffic logs search-bodies --pattern "userId" --scope response --limit 20
apxy traffic logs search-bodies --pattern "user_id" --scope response --limit 20

# SQL to surface any new error codes that weren't there before
apxy traffic sql query "SELECT path, status_code, COUNT(*) as cnt FROM traffic_logs WHERE status_code >= 400 GROUP BY path, status_code ORDER BY cnt DESC"
```

### 14. Simulate Error Scenarios for Resilience Testing

Test how your app handles 3rd-party outages, rate limiting, and timeout conditions — without actually breaking the real service.

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

## Tips

- Use `--help-format agent` on any command for AI-optimized help output
- Use `--error-format json` for programmatic error handling
- `apxy proxy browser` launches a pre-configured browser — no manual proxy setup needed
- `apxy setup init` creates a project-scoped `.apxy/` directory for isolated config/data
- `--format toon` minimizes tokens when feeding output to an AI agent
- DB commands (logs, mock, sql, schema, request) work without a running proxy
- Runtime commands (`rules filter`, `rules redirect`, `rules interceptor`, `rules breakpoint`, `rules script`, `rules network`, `rules caching`, `traffic recording`) need `apxy proxy start`
