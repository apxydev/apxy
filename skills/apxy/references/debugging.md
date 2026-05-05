# Debugging — Traffic Inspection & Analysis

Ensure proxy is running: `apxy status`. If not: `apxy start --port 8080 --ssl-domains <your-api-domain>`.

## Core Workflow

```
search/list  ->  show  ->  extract/correlate
```

**Critical ordering rule:** Your first traffic command must always be `apxy logs search` or `apxy logs list`. Do not run `apxy logs stats` as your first traffic command — it is an analysis tool that comes after you've used search or list to locate specific records. Even when checking license status beforehand, ensure the first actual traffic inspection command is `search` or `list`.

1. **Search/List** — find relevant traffic by URL, body content, GraphQL operation, or status code
2. **Show (Inspect)** — open the full record (headers, bodies, timing) — **always use `show` on a specific record, even when search results look sufficient; search truncates headers and bodies**
3. **Extract** — pull specific JSON fields with jsonpath
4. **Correlate** — diff two records, aggregate with jq, or search bodies for patterns — **always complete this step; even when the issue is obvious from inspect, diffing a failing vs successful record confirms the diagnosis and reveals related patterns**

## Traffic Commands

### Logs (17 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy logs list` | List captured traffic records | `--limit` (50), `--offset`, `--format` (json\|markdown\|toon), `-q`/`--quiet` |
| `apxy logs show` | Show one record in full detail | `--id` (required), `--format` (json\|markdown\|toon) |
| `apxy logs search` | Search by URL, host, or method | `--query`, `--limit` (20), `--format`, `-q`/`--quiet` |
| `apxy logs search-bodies` | Full-text search in request/response bodies | `--pattern`, `--scope` (request\|response\|both), `--limit` (20), `--format` |
| `apxy logs graphql` | Search GraphQL operations | `--operation-name`, `--operation-type` (query\|mutation\|subscription), `--limit` (20), `--format` |
| `apxy logs jsonpath` | Extract JSON fields via gjson path | `--id`, `--path`, `--scope` (request\|response) |
| `apxy logs diff` | Compare two captured records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy logs label` | Add color label and comment to a record | `--id` (required), `--color` (red\|green\|blue\|yellow\|purple), `--comment` |
| `apxy logs replay` | Replay a captured request through the proxy | `--id`, `--port` (8080) |
| `apxy logs export-curl` | Export as client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python) |
| `apxy logs export-har` | Export captured traffic as HAR 1.2 | `--file`, `--limit` (10000) |
| `apxy logs import-har` | Import traffic from a HAR file | `--file` (required) |
| `apxy logs tail` | Live-tail traffic from a running instance | `--format` (text\|json), `--host`, `--port`, `--sse` |
| `apxy logs sse-events` | List parsed SSE events for a traffic record | `--id`, `--limit`, `--format` (text\|json) |
| `apxy logs sse-merge` | Merge AI streaming SSE events into one response | `--id`, `--format` (text\|json) |
| `apxy logs stats` | Show aggregate traffic statistics | `--format` (json\|toon) |
| `apxy logs clear` | Delete all captured records | `--dry-run` |

### Recording (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy recording start` | Start traffic capture on the running proxy | `--control-url` (http://localhost:8081) |
| `apxy recording stop` | Stop traffic capture | `--control-url` (http://localhost:8081) |

### Devices (1 command)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic devices list` | List connected devices | `--format` (json\|markdown\|toon), `--mobile`, `-q`/`--quiet`, `--web-url` |

## Common jq Patterns

Count requests by status code:

```bash
apxy logs list --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```

Slowest endpoints by average latency:

```bash
apxy logs list --format json | jq '[group_by(.url)[] | {url: .[0].url, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:10]'
```

Error rate by host:

```bash
apxy logs list --format json | jq '[group_by(.host)[] | {host: .[0].host, total: length, errors: (map(select(.status_code >= 400)) | length)}]'
```

All 5xx errors with method and path:

```bash
apxy logs list --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:20][] | {id, method, path, status_code, duration_ms}'
```

Group by host + path + method:

```bash
apxy logs list --format json | jq '[group_by(.host, .path, .method)[] | {host: .[0].host, path: .[0].path, method: .[0].method, cnt: length}] | sort_by(-.cnt) | .[:20]'
```

Requests slower than a threshold (e.g. 2000ms):

```bash
apxy logs list --format json | jq '[.[] | select(.duration_ms > 2000)] | sort_by(-.duration_ms) | .[:10][] | {method, url, duration_ms, status_code}'
```

Status breakdown for a flaky endpoint:

```bash
apxy logs search --query /api/search --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```

## JSONPath Extraction Patterns

Extract an error message from a response:

```bash
apxy logs jsonpath --id <ID> --path "error.message" --scope response
```

Extract a nested data field (e.g. GraphQL response):

```bash
apxy logs jsonpath --id <ID> --path "data.user.profile" --scope response
```

Extract request variables (e.g. GraphQL):

```bash
apxy logs jsonpath --id <ID> --path "variables" --scope request
```

Extract a stack trace from an error response:

```bash
apxy logs jsonpath --id <ID> --path "error.stack" --scope response
```

Extract an access token from an OAuth response:

```bash
apxy logs jsonpath --id <ID> --path "access_token" --scope response
```

Extract an array of error details:

```bash
apxy logs jsonpath --id <ID> --path "errors.#.message" --scope response
```

## Debug Pattern Recipes

### CORS Errors

**Symptoms:** Browser console shows "blocked by CORS policy". Preflight `OPTIONS` request fails or returns without `Access-Control-Allow-Origin` header.

**Steps:**

1. Search to locate the preflight request and get its ID:
   ```bash
   apxy logs search --query "OPTIONS"
   ```
2. Inspect the specific preflight record — `show` is the step that reveals the actual response headers returned by the server. Search results only show status codes and metadata; the response headers (where CORS headers live) require `show` to see:
   ```bash
   apxy logs show --id <OPTIONS_ID>
   ```
3. Confirm which CORS headers are present or missing in the response: `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`. Only after this step do you have the full picture to diagnose the issue.
4. Verify the follow-up GET/POST request exists and its status:
   ```bash
   apxy logs search --query "<api-host>" --limit 10
   ```
5. Temporary fix — mock a correct preflight response:
   ```bash
   apxy mock add --name "cors-preflight" \
     --url "https://api.myapp.com/*" --match wildcard --method OPTIONS \
     --status 204 \
     --headers '{"Access-Control-Allow-Origin":"http://localhost:3000","Access-Control-Allow-Methods":"GET, POST, PUT, DELETE, OPTIONS","Access-Control-Allow-Headers":"Content-Type, Authorization","Access-Control-Max-Age":"86400"}'
   ```

**Fix:** Add correct CORS headers on the server. Remove the mock rule after deploying: `apxy mock remove --id <RULE_ID>`.

### Auth Token Failures

**Symptoms:** Users randomly logged out. API returns 401 after a period of normal use. Refresh token flow may be silently failing.

**Steps:**

1. Search for auth/token traffic:
   ```bash
   apxy logs search --query "auth.myapp.com"
   ```
2. Inspect the token response to check `expires_in` and `refresh_token` presence:
   ```bash
   apxy logs show --id <TOKEN_ID>
   ```
3. Extract the token lifetime:
   ```bash
   apxy logs jsonpath --id <TOKEN_ID> --path "expires_in" --scope response
   ```
4. Search for failed refresh attempts:
   ```bash
   apxy logs search --query "refresh" --limit 15
   ```
5. Correlate with downstream 401s:
   ```bash
   apxy logs search --query "401" --limit 15
   ```

**Fix:** Align refresh interval with `expires_in`. Ensure refresh endpoint returns a new `refresh_token`. Check for `invalid_grant` errors in failed refresh responses.

### 5xx Server Errors

**Symptoms:** API returns 500 / 502 / 503. Error message in response body. Some requests succeed, others fail intermittently.

**Steps:**

1. Search for the failing endpoint to get a list of record IDs and status codes:
   ```bash
   apxy logs search --query "/api/endpoint" --format json
   ```
2. Inspect a failing record in full — `show` gives you the complete request headers, response headers, and response body. You need this before extracting specific fields, because you must see the full response to know what JSON paths or patterns to target:
   ```bash
   apxy logs show --id <FAIL_ID>
   ```
3. After seeing the full record, extract the specific error field to confirm the message:
   ```bash
   apxy logs jsonpath --id <FAIL_ID> --path "error.message" --scope response
   ```
4. If you see a mix of 500 and 200 responses, diff a failing record against a successful one to understand what's different in the response:
   ```bash
   apxy logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope response
   ```
5. Search response bodies for error fingerprints across all records:
   ```bash
   apxy logs search-bodies --pattern "error" --scope response --limit 10
   ```

**Fix:** Read the error message from step 3 — common causes: connection pool exhausted, database down, upstream timeout. Diff (step 4) reveals whether failing requests differ in any request parameter. Deploy fix then replay: `apxy logs replay --id <FAIL_ID>`.

### Slow API Endpoints

**Symptoms:** Spinners hang, dashboards take seconds to load. Users report "the site is slow" without specifics.

**⚠️ Order matters:** Your first traffic command must be `apxy logs search` or `apxy logs list`. Do not start with `apxy logs stats` — run it only after the initial search/list step.

**Steps:**

1. **First:** search or list traffic to locate the relevant records. If the user described which feature is slow (e.g. "search is slow"), search for it by keyword:
   ```bash
   apxy logs search --query "<feature-or-path-keyword>" --format json
   ```
   If you don't know the specific path, list recent traffic:
   ```bash
   apxy logs list --format json --limit 50
   ```
2. **Then:** inspect a specific record from the suspected slow endpoint to check its `duration_ms` and response size:
   ```bash
   apxy logs show --id <ID>
   ```
3. **Optionally:** for latency rankings across all endpoints:
   ```bash
   apxy logs list --format json | jq '[group_by(.url)[] | {url: .[0].url, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:10]'
   ```
3. Replay after optimization to measure improvement:
   ```bash
   apxy tools request compose --method GET --url "https://api.myapp.com/api/users"
   ```
4. Diff before and after:
   ```bash
   apxy logs diff --id-a <BEFORE_ID> --id-b <AFTER_ID> --scope both
   ```

**Fix:** Add database indexes, fix N+1 queries, add caching, or reduce response payload size. Verify with replay + diff.

### Webhook Delivery Failures

**Symptoms:** Provider dashboard (Stripe, GitHub, etc.) shows failed deliveries. Your server returns 500 on webhook POST. No clear error in application logs.

**Steps:**

1. Search for webhook traffic:
   ```bash
   apxy logs search --query "webhook"
   ```
2. Inspect the failed delivery — check request headers (e.g. `Stripe-Signature`) and response body:
   ```bash
   apxy logs show --id <FAIL_ID>
   ```
3. Diff a failed delivery against a successful one:
   ```bash
   apxy logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope request
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
   apxy logs search --query "webhook" --limit 5
   ```

**Fix:** Fix handler validation, signature verification, or database constraint. Redeploy and trigger "Resend" from provider.

### Flaky / Intermittent API Errors

**Symptoms:** Endpoint returns 200 most of the time but occasionally 503 or 500. Cannot reproduce on demand.

**Steps:**

1. Capture a volume of traffic, then quantify failure rate:
   ```bash
   apxy logs search --query /api/search --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
   ```
2. List failing rows with IDs:
   ```bash
   apxy logs search --query /api/search --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:20][] | {id, status_code, duration_ms}'
   ```
3. Diff a failure against a success — requests first:
   ```bash
   apxy logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope request
   ```
4. If requests match, diff responses to find upstream error signatures:
   ```bash
   apxy logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope response
   ```
5. Search response bodies for error fingerprints:
   ```bash
   apxy logs search-bodies --pattern "upstream" --scope response --limit 10
   ```

**Fix:** If requests are identical but responses differ, the issue is upstream (load balancer, replica lag, timeout). If requests differ (e.g. different query params), investigate the data-dependent code path.

### GraphQL Debugging

**Symptoms:** UI field shows `null` but should have data. Network tab only shows `POST /graphql 200` with a large blob.

**Steps:**

1. List captured GraphQL queries:
   ```bash
   apxy logs graphql --operation-type query --limit 20
   ```
2. Filter by the specific operation:
   ```bash
   apxy logs graphql --operation-name "GetUser" --limit 10
   ```
3. Inspect the full record — check `query` string, `variables`, and response `data`/`errors`:
   ```bash
   apxy logs show --id <ID>
   ```
4. Extract the specific nested field:
   ```bash
   apxy logs jsonpath --id <ID> --path "data.user.profile" --scope response
   ```
5. Check for partial errors in the response:
   ```bash
   apxy logs jsonpath --id <ID> --path "errors.#.message" --scope response
   ```
6. Verify request variables were correct:
   ```bash
   apxy logs jsonpath --id <ID> --path "variables" --scope request
   ```

**Fix:** If `data.field` is null and no `errors` array, the query likely omits the field in its selection set. If `errors` contains resolver failures, fix the backend resolver. If `variables` are wrong, fix the client query builder.

### Docker Container Traffic

**Symptoms:** Microservice-to-microservice calls are invisible. Containers talk over the Docker bridge network and never touch the host proxy.

**Steps:**

1. Confirm the proxy is running and note the port:
   ```bash
   apxy status
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
   apxy logs list --limit 25
   ```
4. Search for the internal service hostname:
   ```bash
   apxy logs search --query "internal-api"
   ```
5. Inspect a problematic call:
   ```bash
   apxy logs show --id <ID>
   ```

**Fix:** For persistent debugging, add `HTTP_PROXY` / `HTTPS_PROXY` to your `docker-compose.yml` environment section. Mount the APXY CA cert into containers that make HTTPS calls. Use `NO_PROXY` to exclude services that should not be proxied (e.g. databases).

## See Also

- For replay, diff, and regression testing after a fix: [replay-diff.md](replay-diff.md)
- For API contract validation and catching breaking changes: [mocking.md](mocking.md)
