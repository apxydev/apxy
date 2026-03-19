# APXY CLI — Agent Network Proxy Command Line Tool

Use this skill when the user asks to debug network traffic, set up mock rules, test API endpoints, or manage proxy behavior using the `apxy` binary. This skill provides the full CLI reference so you can operate APXY without MCP.

## When to Use CLI vs MCP

- **CLI**: Shell-only agents, CI/CD pipelines, piping output through `jq`, scripting, or when MCP is not available.
- **MCP**: Structured agent workflows where the AI client supports Model Context Protocol.

Both interfaces share the same underlying operations and produce identical results.

## Quick Start

```bash
# Start proxy with control API (control API auto-starts on port+1)
apxy start --port 8080                    # proxy on :8080, control API on :8081

# Inject proxy env for terminal tools (Proxyman-style)
eval $(apxy env)

# View traffic
apxy logs list --format json --limit 10
apxy logs search --query "api.example.com" --format markdown

# Add mock rules
apxy mock add --name "stub-users" --url "/api/users" --match exact --status 200 --body '{"users":[]}'

# Run SQL queries
apxy sql query "SELECT host, COUNT(*) as cnt FROM traffic_logs GROUP BY host ORDER BY cnt DESC LIMIT 10"
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `APXY_CONTROL_URL` | URL of the running proxy's control API | `http://localhost:8081` |
| `APXY_DB` | Path to SQLite database | `./data/apxy.db` |

## Two Types of Commands

| Type | Requires proxy? | How it works | Commands |
|------|----------------|--------------|----------|
| **Database-backed** | No | Connects directly to SQLite | logs, mock, sql, status, request |
| **Runtime** | Yes (`apxy start`) | Calls the proxy's HTTP control API | filter, redirect, ssl, network, interceptor, recording, caching |

Database-backed commands accept `--db` (default: `./data/apxy.db`). Runtime commands accept `--control-url` (default: `http://localhost:8081`).

## Command Reference

### Traffic Inspection

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy logs list` | List captured traffic | `--limit`, `--offset`, `--format`, `--db` |
| `apxy logs show` | Show single record detail | `--id`, `--format`, `--db` |
| `apxy logs search` | Search by URL/host/method | `--query`, `--limit`, `--format`, `--db` |
| `apxy logs stats` | Traffic statistics | `--db` |
| `apxy logs clear` | Delete all traffic logs | `--db` |
| `apxy logs search-bodies` | Full-text search in bodies | `--pattern`, `--scope`, `--limit`, `--format` |
| `apxy logs jsonpath` | Extract JSON values via gjson | `--id`, `--path`, `--scope` |
| `apxy logs graphql` | Search GraphQL operations | `--operation-name`, `--operation-type`, `--limit` |
| `apxy logs diff` | Compare two records | `--id-a`, `--id-b`, `--scope` |
| `apxy logs export-curl` | Export as curl command | `--id` |
| `apxy logs replay` | Re-send a captured request | `--id` |

### Mock Rules

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy mock add` | Create mock rule | `--name`, `--url`, `--match`, `--method`, `--status`, `--body`, `--delay`, `--priority` |
| `apxy mock remove` | Remove rule | `--id` |
| `apxy mock list` | List all rules | |
| `apxy mock enable` | Enable a rule | `--id` |
| `apxy mock disable` | Disable a rule | `--id` |
| `apxy mock clear` | Remove all rules | |

### HTTP Requests

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy request compose` | Send custom HTTP request | `--method`, `--url`, `--body`, `--headers` |
| `apxy request batch` | Batch requests from file | `--file`, `--compare-history`, `--format` |
| `apxy request diagnose` | Diagnose APIs from history | `--file`, `--time-range`, `--match-mode`, `--format` |

### SQL Queries

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy sql query "SQL"` | Run read-only SQL query | First positional arg is the SQL |

### Status

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy status` | Proxy stats and rule counts | `--db`, `--port` |

### Environment Setup (Proxyman-style)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy env` | Output proxy env vars for terminal processes | `--port`, `--cert-dir`, `--lang`, `--open`, `--no-cert`, `--bypass-domains`, `--script` |

```bash
eval $(apxy env)                    # inject into current shell
apxy env --open                     # open new terminal with env set
eval $(apxy env --lang node)        # Node-only
apxy env --script ./proxy-env.sh    # write script to file
```

### Runtime Commands (require running proxy)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy filter set` | Block/allow traffic | `--type`, `--target` |
| `apxy filter remove` | Remove filter rule | `--id` |
| `apxy filter list` | List filter rules | |
| `apxy redirect set` | Redirect URLs | `--name`, `--from`, `--to`, `--match` |
| `apxy redirect remove` | Remove redirect | `--id` |
| `apxy redirect list` | List redirects | |
| `apxy ssl enable` | Enable HTTPS interception | `--domain` |
| `apxy ssl disable` | Disable HTTPS interception | `--domain` |
| `apxy ssl list` | List SSL domains | |
| `apxy network set` | Simulate slow network | `--latency`, `--bandwidth` |
| `apxy network clear` | Clear network conditions | |
| `apxy interceptor set` | Create interceptor | `--name`, `--match`, `--action`, `--description` |
| `apxy interceptor remove` | Remove interceptor | `--id` |
| `apxy interceptor list` | List interceptors | |
| `apxy recording start` | Start recording | |
| `apxy recording stop` | Stop recording | |
| `apxy caching disable-cache` | Strip cache headers | `--host` |
| `apxy caching enable-cache` | Restore caching | |

## Output Formats

All traffic commands accept `--format`:

- **json** (default): Machine-readable, pipe through `jq`
- **markdown**: Human-readable, good for agent display
- **toon**: Compact token-optimized notation, minimal tokens for AI context

## Common Agent Workflows

### Debug a broken API screen

```bash
# 1. Check recent errors
apxy logs search --query "api.example.com" --format json | jq '.[] | select(.status_code >= 400)'

# 2. Get details of a failing request
apxy logs show --id <ID> --format markdown

# 3. Extract error from response body
apxy logs jsonpath --id <ID> --path "error.message"

# 4. Compare with a previously working request
apxy logs diff --id-a <GOOD_ID> --id-b <BAD_ID> --scope response
```

### Set up mock for testing

```bash
# 1. Create a mock rule
apxy mock add --name "stub-payment" --url "https://api.stripe.com/v1/charges" \
  --match wildcard --status 200 --body '{"id":"ch_test","status":"succeeded"}'

# 2. Verify the mock is active
apxy mock list

# 3. Test via compose
apxy request compose --method POST --url "https://api.stripe.com/v1/charges" \
  --body '{"amount":1000}'

# 4. Clean up
apxy mock remove --id <RULE_ID>
```

### Test a fix (replay + diff)

```bash
# 1. Export the failing request as curl
apxy logs export-curl --id <FAIL_ID>

# 2. After fix, replay the same request
apxy logs replay --id <FAIL_ID>

# 3. Compare old vs new
apxy logs diff --id-a <FAIL_ID> --id-b <NEW_ID> --scope response
```

### Route terminal traffic through proxy

```bash
# 1. Start proxy
apxy start --port 8080

# 2. In another terminal, inject env so cURL/Node/Python/Go use proxy
eval $(apxy env)

# 3. All requests from this shell are now captured
curl https://api.example.com
```

### Analyze traffic patterns with SQL

```bash
apxy sql query "SELECT host, path, method, COUNT(*) as cnt FROM traffic_logs GROUP BY host, path, method ORDER BY cnt DESC LIMIT 20"
apxy sql query "SELECT host, COUNT(*) as total, SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) as errors FROM traffic_logs GROUP BY host"
apxy sql query "SELECT method, url, duration_ms, status_code FROM traffic_logs WHERE duration_ms > 2000 ORDER BY duration_ms DESC LIMIT 10"
```

### Simulate network conditions

```bash
apxy network set --latency 2000
apxy request compose --method GET --url "https://api.example.com/health"
apxy network clear
```

## Tips

- Use `--format json` and pipe through `jq` for programmatic processing
- Use `--format toon` to minimize tokens when feeding output to an AI agent
- Database-backed commands (logs, mock, sql, status, request) work without a running proxy
- Runtime commands (filter, redirect, ssl, network, interceptor, recording, caching) require `apxy start`
- The `--db` flag defaults to `./data/apxy.db`
- The `--control-url` flag defaults to `http://localhost:8081`
- Use `apxy env` when terminal tools must route through APXY
