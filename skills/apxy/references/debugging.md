# Debugging — Traffic Inspection & Analysis

Ensure proxy is running: `apxy proxy status`. If not: `apxy proxy start --port 8080 --ssl-domains <your-api-domain>`.

## Note: SQL Requires Pro

`apxy traffic sql query` requires a Pro license. On Free, use `apxy traffic logs search --query <term> --format json | jq <filter>` for equivalent spot-checking. All other commands in this file are available on Free.

## Core Workflow

```
search  ->  inspect  ->  extract  ->  correlate
```

1. **Search** — find relevant traffic by URL, body content, GraphQL operation, or SQL query
2. **Inspect** — open the full record (headers, bodies, timing)
3. **Extract** — pull specific JSON fields with jsonpath
4. **Correlate** — diff two records, aggregate with SQL, or search bodies for patterns

## Traffic Commands

### Logs (17 commands)

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
| `apxy traffic logs tail` | Live-tail traffic from a running instance | `--format` (text\|json), `--host`, `--port`, `--sse` |
| `apxy traffic logs sse-events` | List parsed SSE events for a traffic record | `--id`, `--limit`, `--format` (text\|json) |
| `apxy traffic logs sse-merge` | Merge AI streaming SSE events into one response | `--id`, `--format` (text\|json) |
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

## Debug Pattern Recipes

### CORS Errors

**Symptoms:** Browser console shows "blocked by CORS policy". Preflight `OPTIONS` request fails or returns without `Access-Control-Allow-Origin` header.

**Steps:**

1. Search for preflight requests:
   ```bash
   apxy traffic logs search --query "OPTIONS"
   ```
2. Inspect the preflight response headers:
   ```bash
   apxy traffic logs show --id <OPTIONS_ID>
   ```
3. Check for missing `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, and `Access-Control-Allow-Headers` in the response.
4. Verify the follow-up request exists and its status:
   ```bash
   apxy traffic logs search --query "<api-host>" --limit 10
   ```
5. Temporary fix — mock a correct preflight response:
   ```bash
   apxy rules mock add --name "cors-preflight" \
     --url "https://api.myapp.com/*" --match wildcard --method OPTIONS \
     --status 204 \
     --headers '{"Access-Control-Allow-Origin":"http://localhost:3000","Access-Control-Allow-Methods":"GET, POST, PUT, DELETE, OPTIONS","Access-Control-Allow-Headers":"Content-Type, Authorization","Access-Control-Max-Age":"86400"}'
   ```

**Fix:** Add correct CORS headers on the server. Remove the mock rule after deploying: `apxy rules mock remove --id <RULE_ID>`.

### Auth Token Failures

**Symptoms:** Users randomly logged out. API returns 401 after a period of normal use. Refresh token flow may be silently failing.

**Steps:**

1. Search for auth/token traffic:
   ```bash
   apxy traffic logs search --query "auth.myapp.com"
   ```
2. Inspect the token response to check `expires_in` and `refresh_token` presence:
   ```bash
   apxy traffic logs show --id <TOKEN_ID>
   ```
3. Extract the token lifetime:
   ```bash
   apxy traffic logs jsonpath --id <TOKEN_ID> --path "expires_in" --scope response
   ```
4. Search for failed refresh attempts:
   ```bash
   apxy traffic logs search --query "refresh" --limit 15
   ```
5. Correlate with downstream 401s:
   ```bash
   apxy traffic logs search --query "401" --limit 15
   ```

**Fix:** Align refresh interval with `expires_in`. Ensure refresh endpoint returns a new `refresh_token`. Check for `invalid_grant` errors in failed refresh responses.

### Slow API Endpoints

**Symptoms:** Spinners hang, dashboards take seconds to load. Users report "the site is slow" without specifics.

**Steps:**

1. Rank endpoints by latency with SQL:
   ```bash
   apxy traffic sql query "SELECT url, COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs GROUP BY url ORDER BY avg_ms DESC LIMIT 10"
   ```
2. Inspect the slowest record:
   ```bash
   apxy traffic logs search --query "<slow-url>" --limit 5
   apxy traffic logs show --id <SLOW_ID>
   ```
3. Replay after optimization to measure improvement:
   ```bash
   apxy tools request compose --method GET --url "https://api.myapp.com/api/users"
   ```
4. Diff before and after:
   ```bash
   apxy traffic logs diff --id-a <BEFORE_ID> --id-b <AFTER_ID> --scope both
   ```

**Fix:** Add database indexes, fix N+1 queries, add caching, or reduce response payload size. Verify with replay + diff.

### Webhook Delivery Failures

**Symptoms:** Provider dashboard (Stripe, GitHub, etc.) shows failed deliveries. Your server returns 500 on webhook POST. No clear error in application logs.

**Steps:**

1. Search for webhook traffic:
   ```bash
   apxy traffic logs search --query "webhook"
   ```
2. Inspect the failed delivery — check request headers (e.g. `Stripe-Signature`) and response body:
   ```bash
   apxy traffic logs show --id <FAIL_ID>
   ```
3. Diff a failed delivery against a successful one:
   ```bash
   apxy traffic logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope request
   ```
4. Replay a test payload after fixing:
   ```bash
   apxy tools request compose --method POST \
     --url "https://api.myapp.com/webhooks/stripe" \
     --body '{"id":"evt_test","type":"customer.subscription.updated","data":{"object":{}}}' \
     --headers '{"Content-Type":"application/json"}'
   ```
5. Confirm new delivery returns 200:
   ```bash
   apxy traffic logs search --query "webhook" --limit 5
   ```

**Fix:** Fix handler validation, signature verification, or database constraint. Redeploy and trigger "Resend" from provider.

### Flaky / Intermittent API Errors

**Symptoms:** Endpoint returns 200 most of the time but occasionally 503 or 500. Cannot reproduce on demand.

**Steps:**

1. Capture a volume of traffic, then quantify failure rate:
   ```bash
   apxy traffic sql query "SELECT status_code, COUNT(*) AS count FROM traffic_logs WHERE url LIKE '%/api/search%' GROUP BY status_code ORDER BY count DESC"
   ```
2. List failing rows with IDs:
   ```bash
   apxy traffic sql query "SELECT id, status_code, duration_ms FROM traffic_logs WHERE url LIKE '%/api/search%' AND status_code >= 500 ORDER BY id DESC LIMIT 20"
   ```
3. Diff a failure against a success — requests first:
   ```bash
   apxy traffic logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope request
   ```
4. If requests match, diff responses to find upstream error signatures:
   ```bash
   apxy traffic logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope response
   ```
5. Search response bodies for error fingerprints:
   ```bash
   apxy traffic logs search-bodies --pattern "upstream" --scope response --limit 10
   ```

**Fix:** If requests are identical but responses differ, the issue is upstream (load balancer, replica lag, timeout). If requests differ (e.g. different query params), investigate the data-dependent code path.

### GraphQL Debugging

**Symptoms:** UI field shows `null` but should have data. Network tab only shows `POST /graphql 200` with a large blob.

**Steps:**

1. List captured GraphQL queries:
   ```bash
   apxy traffic logs graphql --operation-type query --limit 20
   ```
2. Filter by the specific operation:
   ```bash
   apxy traffic logs graphql --operation-name "GetUser" --limit 10
   ```
3. Inspect the full record — check `query` string, `variables`, and response `data`/`errors`:
   ```bash
   apxy traffic logs show --id <ID>
   ```
4. Extract the specific nested field:
   ```bash
   apxy traffic logs jsonpath --id <ID> --path "data.user.profile" --scope response
   ```
5. Check for partial errors in the response:
   ```bash
   apxy traffic logs jsonpath --id <ID> --path "errors.#.message" --scope response
   ```
6. Verify request variables were correct:
   ```bash
   apxy traffic logs jsonpath --id <ID> --path "variables" --scope request
   ```

**Fix:** If `data.field` is null and no `errors` array, the query likely omits the field in its selection set. If `errors` contains resolver failures, fix the backend resolver. If `variables` are wrong, fix the client query builder.

### Docker Container Traffic

**Symptoms:** Microservice-to-microservice calls are invisible. Containers talk over the Docker bridge network and never touch the host proxy.

**Steps:**

1. Confirm the proxy is running and note the port:
   ```bash
   apxy proxy status
   ```
2. Run the container with proxy environment variables:
   ```bash
   docker run --rm \
     -e HTTP_PROXY=http://host.docker.internal:8080 \
     -e HTTPS_PROXY=http://host.docker.internal:8080 \
     -e NO_PROXY=localhost,127.0.0.1 \
     myservice:latest
   ```
   On Linux, add `--add-host=host.docker.internal:host-gateway`.
3. Trigger the inter-service call, then list captures:
   ```bash
   apxy traffic logs list --limit 25
   ```
4. Search for the internal service hostname:
   ```bash
   apxy traffic logs search --query "internal-api"
   ```
5. Inspect a problematic call:
   ```bash
   apxy traffic logs show --id <ID>
   ```

**Fix:** For persistent debugging, add `HTTP_PROXY` / `HTTPS_PROXY` to your `docker-compose.yml` environment section. Mount the APXY CA cert into containers that make HTTPS calls. Use `NO_PROXY` to exclude services that should not be proxied (e.g. databases).

## See Also

- For replay, diff, and regression testing after a fix: [replay-diff.md](replay-diff.md)
- For API contract validation and catching breaking changes: [mocking.md](mocking.md)
