# Debugging — Traffic Inspection & Analysis

## Prerequisites

Ensure the proxy is running and capturing traffic:

```bash
apxy proxy status
```

If not running:

```bash
apxy proxy start --port 8080 --ssl-domains <your-api-domain>
```

Replace `<your-api-domain>` with the HTTPS host(s) you need to inspect (comma-separated for multiple). SSL interception requires the APXY CA certificate trusted on the client.

## Core Workflow

```
search  ->  inspect  ->  extract  ->  correlate
```

1. **Search** — find relevant traffic by URL, body content, GraphQL operation, or SQL query
2. **Inspect** — open the full record (headers, bodies, timing)
3. **Extract** — pull specific JSON fields with jsonpath
4. **Correlate** — diff two records, aggregate with SQL, or search bodies for patterns

## Traffic Commands

### Logs (14 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic logs list` | List captured traffic records | `--limit` (50), `--offset`, `--format` (json\|markdown\|toon), `-q`/`--quiet` |
| `apxy traffic logs show` | Show one record in full detail | `--id` (required), `--format` (json\|markdown\|toon) |
| `apxy traffic logs search` | Search by URL, host, or method | `--query`, `--limit` (20), `--format`, `-q`/`--quiet` |
| `apxy traffic logs search-bodies` | Full-text search in request/response bodies | `--pattern`, `--scope` (request\|response\|both), `--limit` (20), `--format` |
| `apxy traffic logs graphql` | Search GraphQL operations | `--operation-name`, `--operation-type` (query\|mutation\|subscription), `--limit` (20), `--format` |
| `apxy traffic logs jsonpath` | Extract JSON fields via gjson path | `--id`, `--path`, `--scope` (request\|response) |
| `apxy traffic logs diff` | Compare two captured records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy traffic logs label` | Add color label and comment to a record | `--id` (required), `--color` (red\|green\|blue\|yellow\|purple), `--comment` |
| `apxy traffic logs replay` | Replay a captured request through the proxy | `--id`, `--port` (8080) |
| `apxy traffic logs export-curl` | Export as client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python) |
| `apxy traffic logs export-har` | Export captured traffic as HAR 1.2 | `--file`, `--limit` (10000) |
| `apxy traffic logs import-har` | Import traffic from a HAR file | `--file` (required) |
| `apxy traffic logs stats` | Show aggregate traffic statistics | `--format` (json\|toon) |
| `apxy traffic logs clear` | Delete all captured records | `--dry-run` |

### Recording (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic recording start` | Start traffic capture on the running proxy | `--control-url` (http://localhost:8081) |
| `apxy traffic recording stop` | Stop traffic capture | `--control-url` (http://localhost:8081) |

### Devices (1 command)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic devices list` | List connected devices | `--format` (json\|markdown\|toon), `--mobile`, `-q`/`--quiet`, `--web-url` |

### SQL (1 command)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic sql query "<SQL>"` | Run read-only SQL against SQLite | Tables: `traffic_logs`, `mock_rules` |

## Common SQL Patterns

Count requests by status code:

```bash
apxy traffic sql query "SELECT status_code, COUNT(*) AS count FROM traffic_logs GROUP BY status_code ORDER BY count DESC"
```

Slowest endpoints by average latency:

```bash
apxy traffic sql query "SELECT url, COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs GROUP BY url ORDER BY avg_ms DESC LIMIT 10"
```

Error rate by host:

```bash
apxy traffic sql query "SELECT host, COUNT(*) AS total, SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) AS errors FROM traffic_logs GROUP BY host"
```

All 5xx errors with method and path:

```bash
apxy traffic sql query "SELECT id, method, path, status_code, duration_ms FROM traffic_logs WHERE status_code >= 500 ORDER BY id DESC LIMIT 20"
```

Group by method + path + status:

```bash
apxy traffic sql query "SELECT host, path, method, COUNT(*) AS cnt FROM traffic_logs GROUP BY host, path, method ORDER BY cnt DESC LIMIT 20"
```

Requests slower than a threshold (e.g. 2000ms):

```bash
apxy traffic sql query "SELECT method, url, duration_ms, status_code FROM traffic_logs WHERE duration_ms > 2000 ORDER BY duration_ms DESC LIMIT 10"
```

Requests per minute (approximate):

```bash
apxy traffic sql query "SELECT strftime('%Y-%m-%d %H:%M', timestamp) AS minute, COUNT(*) AS rpm FROM traffic_logs GROUP BY minute ORDER BY minute DESC LIMIT 30"
```

Large response bodies (by status and URL):

```bash
apxy traffic sql query "SELECT id, method, url, status_code, length(response_body) AS body_bytes FROM traffic_logs WHERE length(response_body) > 100000 ORDER BY body_bytes DESC LIMIT 10"
```

Approximate P95 latency for a specific path:

```bash
apxy traffic sql query "SELECT duration_ms FROM traffic_logs WHERE url LIKE '%/api/search%' ORDER BY duration_ms DESC LIMIT 1 OFFSET (SELECT COUNT(*) / 20 FROM traffic_logs WHERE url LIKE '%/api/search%')"
```

Status breakdown for a flaky endpoint:

```bash
apxy traffic sql query "SELECT status_code, COUNT(*) AS count FROM traffic_logs WHERE url LIKE '%/api/search%' GROUP BY status_code ORDER BY count DESC"
```

## JSONPath Extraction Patterns

Extract an error message from a response:

```bash
apxy traffic logs jsonpath --id <ID> --path "error.message" --scope response
```

Extract a nested data field (e.g. GraphQL response):

```bash
apxy traffic logs jsonpath --id <ID> --path "data.user.profile" --scope response
```

Extract request variables (e.g. GraphQL):

```bash
apxy traffic logs jsonpath --id <ID> --path "variables" --scope request
```

Extract a stack trace from an error response:

```bash
apxy traffic logs jsonpath --id <ID> --path "error.stack" --scope response
```

Extract an access token from an OAuth response:

```bash
apxy traffic logs jsonpath --id <ID> --path "access_token" --scope response
```

Extract an array of error details:

```bash
apxy traffic logs jsonpath --id <ID> --path "errors.#.message" --scope response
```

## Agent Workflow: Debug a Broken API

```bash
apxy traffic logs search --query "api.example.com" --format json | jq '.[] | select(.status_code >= 400)'
apxy traffic logs show --id <ID> --format markdown
apxy traffic logs jsonpath --id <ID> --path "error.message"
apxy traffic logs diff --id-a <GOOD_ID> --id-b <BAD_ID> --scope response
```

Steps:
1. Search for the target host and filter for 4xx/5xx status codes
2. Open the full record to read headers, request body, and response body
3. Extract the error message or stack trace with jsonpath
4. Diff a known-good response against the failure to isolate what changed

## Agent Workflow: SQL Traffic Analysis

```bash
apxy traffic sql query "SELECT host, path, method, COUNT(*) as cnt FROM traffic_logs GROUP BY host, path, method ORDER BY cnt DESC LIMIT 20"
apxy traffic sql query "SELECT host, COUNT(*) as total, SUM(CASE WHEN status_code >= 400 THEN 1 ELSE 0 END) as errors FROM traffic_logs GROUP BY host"
apxy traffic sql query "SELECT method, url, duration_ms, status_code FROM traffic_logs WHERE duration_ms > 2000 ORDER BY duration_ms DESC LIMIT 10"
```

Steps:
1. Identify the most-called endpoints by host, path, and method
2. Calculate error rates per host to find problematic upstreams
3. Surface slow requests that exceed a latency threshold
4. Drill into specific records with `apxy traffic logs show --id <ID>`

## Agent Workflow: GraphQL Debugging

```bash
apxy traffic logs graphql --operation-type query --limit 20
apxy traffic logs graphql --operation-name "GetUser" --limit 10
apxy traffic logs show --id <ID>
apxy traffic logs jsonpath --id <ID> --path "data.user.profile" --scope response
apxy traffic logs jsonpath --id <ID> --path "errors.#.message" --scope response
apxy traffic logs graphql --operation-type mutation --limit 15
```

Steps:
1. List all captured GraphQL queries to see which operations ran
2. Filter by operation name to find the specific query under investigation
3. Open the full record to inspect `query`, `variables`, and the response `data`/`errors`
4. Extract a nested response path with jsonpath to check for unexpected nulls
5. Check the `errors` array for partial failures or resolver errors
6. List mutations if the bug may stem from a write operation

## Note: Paid Features

SQL queries (`apxy traffic sql query`) require a Pro license. On Free, use `apxy traffic logs search` and `apxy traffic logs show` for equivalent spot-check workflows.

## See Also

- For detailed debug pattern recipes: [debug-patterns.md](debug-patterns.md)
