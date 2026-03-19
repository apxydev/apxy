---
name: apxy
description: APXY — HTTPS debugging proxy and API mocking CLI optimized for AI agents. Captures, inspects, modifies, mocks, and validates API traffic.
metadata:
  priority: 8
  bashPatterns:
    - "apxy\\b"
    - "\\bapxy\\s+(proxy|rules|traffic|schema|setup|tools|config|license)"
    - "\\bapxy\\s+(mock|breakpoint|script|interceptor|redirect|filter|logs|sql)"
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
    - apxy mock add --name stub --url "/api/users" --match exact --status 200 --body '{"users":[]}'
    - apxy logs search --query "api.example.com" --format json
    - apxy breakpoint add --name "pause-login" --match "path contains /login"
    - apxy schema import --name my-api --file ./openapi.yaml
    - apxy script add --name rewrite --code 'response.body = response.body.replace("foo","bar")'
---

# APXY CLI — Agent Network Proxy

HTTPS proxy for capturing, inspecting, modifying, and mocking API traffic. Optimized for AI agents.

## Quick Start

```bash
apxy proxy start --port 8080          # proxy :8080, control API :8081
eval $(apxy env)                      # inject proxy env into shell
apxy logs list --format json --limit 10
apxy mock add --name "stub" --url "/api/users" --match exact --status 200 --body '{"users":[]}'
apxy sql query "SELECT host, COUNT(*) as cnt FROM traffic_logs GROUP BY host ORDER BY cnt DESC LIMIT 10"
```

## Environment & Globals

| Variable | Default | Description |
|----------|---------|-------------|
| `APXY_CONTROL_URL` | `http://localhost:8081` | Running proxy control API |
| `APXY_DB` | `./data/apxy.db` | SQLite database path |

**Global flags** (available on all commands, omitted from tables below):
`--config <file>`, `--error-format text|json`, `--help-format default|agent`, `--verbose`, `--help`

**Two command types:**
- **DB-backed** (no proxy needed): logs, mock, sql, status, request, schema — use `--db`
- **Runtime** (proxy required): filter, redirect, ssl, network, interceptor, recording, caching, breakpoint, script — use `--control-url`

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
| `apxy mock add` | Create mock rule | `--name`, `--url`, `--match` (exact\|wildcard\|regex), `--method`, `--status` (200), `--body`, `--delay`, `--priority` |
| `apxy mock list` | List rules | `--format`, `--quiet` |
| `apxy mock enable` | Enable rule | `--id` or `--all` |
| `apxy mock disable` | Disable rule | `--id` or `--all`, `--dry-run` |
| `apxy mock remove` | Remove rule | `--id` or `--all`, `--dry-run` |
| `apxy mock clear` | Delete all rules | `--dry-run` |

## 3. Rules — Redirect (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy redirect set` | Add redirect rule | `--name`, `--from`, `--to`, `--match` (exact\|wildcard\|regex) |
| `apxy redirect list` | List redirects | `--format`, `--quiet` |
| `apxy redirect remove` | Remove redirect | `--id` or `--all`, `--dry-run` |

## 4. Rules — Interceptor (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy interceptor set` | Add interceptor | `--name`, `--match` (DSL), `--action` (mock\|modify\|observe), `--description`, `--add-request-headers`, `--set-request-headers`, `--set-response-headers`, `--remove-headers`, `--set-response-status`, `--set-response-body`, `--delay-ms` |
| `apxy interceptor list` | List interceptors | `--format`, `--quiet` |
| `apxy interceptor remove` | Remove interceptor | `--id` or `--all`, `--dry-run` |

## 5. Rules — Breakpoint (7 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy breakpoint add` | Add breakpoint rule | `--name` (req), `--match` (DSL, req), `--phase` (request\|response\|both), `--timeout` (30000ms) |
| `apxy breakpoint list` | List breakpoints | `--format`, `--quiet` |
| `apxy breakpoint enable` | Enable breakpoint | `--id` or `--all` |
| `apxy breakpoint disable` | Disable breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy breakpoint remove` | Remove breakpoint | `--id` or `--all`, `--dry-run` |
| `apxy breakpoint pending` | List paused requests | `--quiet` |
| `apxy breakpoint resolve` | Resume paused request | `--id` (req), `--status`, `--headers` (JSON), `--body`, `--drop`, `--dry-run` |

## 6. Rules — Script (5 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy script add` | Add JS proxy script | `--name` (req), `--file` or `--code` (one req), `--hook` (onRequest\|onResponse), `--match` (DSL, default: *) |
| `apxy script list` | List scripts | `--format`, `--quiet` |
| `apxy script enable` | Enable script | `--id` or `--all` |
| `apxy script disable` | Disable script | `--id` or `--all`, `--dry-run` |
| `apxy script remove` | Remove script | `--id` or `--all`, `--dry-run` |

## 7. Rules — Network (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy network set` | Simulate network conditions | `--latency` (ms), `--bandwidth` (kbps), `--packet-loss` (0-100%) |
| `apxy network clear` | Clear conditions | `--dry-run` |

## 8. Rules — Caching (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy caching disable-cache` | Strip cache headers | `--host` (empty = all) |
| `apxy caching enable-cache` | Restore caching | |

## 9. Traffic — Logs (14 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy logs list` | List traffic records | `--limit` (50), `--offset`, `--format`, `--quiet` |
| `apxy logs show` | Show record detail | `--id` (req), `--format` |
| `apxy logs search` | Search by URL/host/method | `--query`, `--limit` (20), `--format`, `--quiet` |
| `apxy logs search-bodies` | Full-text body search | `--pattern`, `--scope` (request\|response\|both), `--limit`, `--format` |
| `apxy logs graphql` | Search GraphQL ops | `--operation-name`, `--operation-type` (query\|mutation\|subscription), `--limit`, `--format` |
| `apxy logs jsonpath` | Extract JSON via gjson | `--id`, `--path`, `--scope` (request\|response) |
| `apxy logs diff` | Compare two records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy logs label` | Label a record | `--id` (req), `--color` (red\|green\|blue\|yellow\|purple), `--comment` |
| `apxy logs replay` | Replay captured request | `--id`, `--port` (8080) |
| `apxy logs export-curl` | Export as client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python) |
| `apxy logs export-har` | Export as HAR 1.2 | `--file`, `--limit` (10000) |
| `apxy logs import-har` | Import from HAR file | `--file` (req) |
| `apxy logs stats` | Traffic statistics | `--format` |
| `apxy logs clear` | Delete all records | `--dry-run` |

## 10. Traffic — Filter, Recording, Devices, SQL (8 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy filter set` | Add block/allow rule | `--type` (block\|allow), `--target` (domain pattern, req) |
| `apxy filter list` | List filter rules | `--format`, `--quiet` |
| `apxy filter remove` | Remove filter | `--id` or `--all`, `--dry-run` |
| `apxy recording start` | Start traffic capture | |
| `apxy recording stop` | Stop traffic capture | |
| `apxy devices list` | List connected devices | `--format`, `--mobile`, `--quiet`, `--web-url` |
| `apxy sql query "<SQL>"` | Run read-only SQL | Tables: `traffic_logs`, `mock_rules` |

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
| `apxy request compose` | Send HTTP request | `--method` (GET), `--url` (req), `--body`, `--headers` (JSON) |
| `apxy request batch` | Batch from file | `--file` (req), `--compare-history`, `--time-range` (60), `--timeout` (10000), `--format` |
| `apxy request diagnose` | Diagnose from history | `--file` (req), `--time-range` (60), `--match-mode` (exact\|contains\|prefix), `--format` |
| `apxy protobuf add-schema` | Register proto schema | `--name`, `--file` or `--content` |
| `apxy protobuf list-schemas` | List proto schemas | |
| `apxy protobuf decode` | Decode proto body | `--id`, `--scope` (request\|response) |
| `apxy protobuf remove-schema` | Remove proto schema | `--id` |
| `apxy db info` | Database info | |
| `apxy db clean` | Clean database | `--traffic`, `--rules`, `--all` |

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
apxy logs search --query "api.example.com" --format json | jq '.[] | select(.status_code >= 400)'
apxy logs show --id <ID> --format markdown
apxy logs jsonpath --id <ID> --path "error.message"
apxy logs diff --id-a <GOOD_ID> --id-b <BAD_ID> --scope response
```

### 2. Mock for Testing

```bash
apxy mock add --name "stub-payment" --url "https://api.stripe.com/v1/charges" \
  --match wildcard --status 200 --body '{"id":"ch_test","status":"succeeded"}'
apxy mock list
apxy request compose --method POST --url "https://api.stripe.com/v1/charges" --body '{"amount":1000}'
apxy mock remove --id <RULE_ID>
```

### 3. Replay and Diff

```bash
apxy logs export-curl --id <FAIL_ID>
apxy logs replay --id <FAIL_ID>
apxy logs diff --id-a <FAIL_ID> --id-b <NEW_ID> --scope response
```

### 4. Route Terminal Traffic

```bash
apxy proxy start --port 8080
eval $(apxy env)              # in another terminal
curl https://api.example.com  # captured
```

### 5. SQL Traffic Analysis

```bash
apxy sql query "SELECT host, path, method, COUNT(*) as cnt FROM traffic_logs GROUP BY host, path, method ORDER BY cnt DESC LIMIT 20"
apxy sql query "SELECT host, COUNT(*) as total, SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) as errors FROM traffic_logs GROUP BY host"
apxy sql query "SELECT method, url, duration_ms, status_code FROM traffic_logs WHERE duration_ms > 2000 ORDER BY duration_ms DESC LIMIT 10"
```

### 6. Breakpoint Debugging

```bash
apxy breakpoint add --name "pause-login" --match "path contains /login && method == POST" --phase request
# trigger the request from your app or curl
apxy breakpoint pending                              # see paused request ID
apxy breakpoint resolve --id <ID>                    # resume as-is
apxy breakpoint resolve --id <ID> --status 200 --body '{"token":"test"}' --headers '{"X-Debug":"true"}'  # modify and resume
apxy breakpoint remove --all
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
apxy script add --name "rewrite-body" --code 'response.body = response.body.replace("foo","bar")' --match "host == api.example.com" --hook onResponse
apxy script add --name "add-auth" --file ./scripts/inject-token.js --hook onRequest --match "path contains /api"
apxy script list
apxy script remove --id <ID>
```

### 9. Mobile Device Debugging

```bash
apxy setup certs generate
apxy setup certs trust
apxy proxy start --port 8080
apxy setup mobile setup --platform ios --qr          # scan QR to configure device
apxy devices list --mobile
```

### 10. HAR Import/Export

```bash
apxy logs export-har --file ./traffic.har --limit 5000   # export for sharing
apxy logs import-har --file ./colleague-traffic.har       # import in different env
```

## Tips

- Use `--help-format agent` on any command for AI-optimized help output
- Use `--error-format json` for programmatic error handling
- Shorthand aliases: `apxy breakpoint add` = `apxy rules breakpoint add`, `apxy mock add` = `apxy rules mock add`, `apxy logs list` = `apxy traffic logs list`
- `apxy proxy browser` launches a pre-configured browser — no manual proxy setup needed
- `apxy setup init` creates a project-scoped `.apxy/` directory for isolated config/data
- `--format toon` minimizes tokens when feeding output to an AI agent
- DB commands (logs, mock, sql, schema, request) work without a running proxy
- Runtime commands (filter, redirect, interceptor, breakpoint, script, network, caching, recording) need `apxy proxy start`
