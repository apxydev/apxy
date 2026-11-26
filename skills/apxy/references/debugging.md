# Debugging: traffic inspection and analysis

Capture the client with `apxy run -- <cmd>`, or start a proxy with `apxy start --ssl-domains <your-api-domain>`. Check a running proxy with `apxy status`. `apxy logs replay` sends the request through a running proxy, so start one with `apxy start` before you replay.

## Contents

- [Core workflow](#core-workflow)
- [Traffic commands](#traffic-commands)
- [Common jq patterns](#common-jq-patterns)
- [JSONPath extraction patterns](#jsonpath-extraction-patterns)
- [Debug recipes](#debug-recipes)
  - [CORS errors](#cors-errors)
  - [Auth token failures](#auth-token-failures)
  - [5xx server errors](#5xx-server-errors)
  - [Slow API endpoints](#slow-api-endpoints)
  - [Webhook delivery failures](#webhook-delivery-failures)
  - [Flaky API errors](#flaky-api-errors)
  - [GraphQL debugging](#graphql-debugging)
  - [Docker container traffic](#docker-container-traffic)
  - [SSE and WebSocket streams](#sse-and-websocket-streams)
  - [Origin certificate errors](#origin-certificate-errors)
- [See also](#see-also)

## Core workflow

1. Search or list. Find the traffic by URL, body content, GraphQL operation, or status code with `apxy logs search` or `apxy logs list`. Run `apxy logs stats` only after this step.
2. Show. Open the full record with `apxy logs show --id <ID>`. Search results leave out headers and bodies, so always open the record.
3. Extract. Pull single JSON fields with `apxy logs jsonpath`.
4. Correlate. Diff a failing record against a passing one, aggregate with jq, or search bodies for a pattern. Do this even when the cause looks obvious. The diff confirms the cause and shows related changes.
5. Verify. After the fix, run the loop in [SKILL.md](../SKILL.md#prove-a-change-works): `apxy mark`, trigger the code, then `apxy wait --match ... --expect ...`.

## Traffic commands

| Command | Description | Key flags |
|---------|-------------|-----------|
| `apxy logs list` | List captured records | `--limit` (50), `--offset`, `--quiet` |
| `apxy logs show` | Show one record in full | `--id` (required) |
| `apxy logs search` | Search by URL, host, or method | `--query`, `--limit` (20), `--quiet` |
| `apxy logs search-bodies` | Search request and response bodies | `--pattern`, `--scope` (request\|response\|both), `--limit` (20) |
| `apxy logs graphql` | Search GraphQL operations | `--operation-name`, `--operation-type` (query\|mutation\|subscription), `--limit` (20) |
| `apxy logs jsonpath` | Extract JSON fields with a gjson path | `--id`, `--path`, `--scope` (request\|response) |
| `apxy logs diff` | Compare two records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy logs label` | Add a color label and comment to a record | `--id`, `--color` (red\|green\|blue\|yellow\|purple), `--comment` |
| `apxy logs replay` | Send a captured request again | `--id`, `--port` (8080) |
| `apxy logs export-curl` | Export a record as a client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python), `--redact` |
| `apxy logs export-har` | Export traffic as HAR 1.2 | `--file`, `--limit` (10000), `--redact` |
| `apxy logs import-har` | Import traffic from a HAR file | `--file` |
| `apxy logs tail` | Stream new traffic from a running proxy | `--host`, `--port`, `--sse` |
| `apxy logs sse-events` | List the SSE events of a record | `--id`, `--limit` |
| `apxy logs sse-merge` | Merge streamed AI SSE events into one response | `--id` |
| `apxy logs ws-frames` | List the WebSocket frames of a record | `--id` |
| `apxy logs stats` | Show traffic counts by method and status | |
| `apxy logs clear` | Delete all captured records | `--dry-run` |
| `apxy recording start` | Resume capture on the running proxy | |
| `apxy recording stop` | Pause capture on the running proxy | |
| `apxy wait` | Block until a matching request lands, then check it | `--match`, `--expect`, `--since`, `--timeout` (30s) |

## Common jq patterns

Agent output puts records in `.items`. The `duration` field is in nanoseconds, so divide by 1e6 for milliseconds. Pass a large `--limit`, because `apxy logs list` returns 50 records by default.

Count requests by status code:

```bash
apxy logs list --limit 1000 | jq '.items | group_by(.status_code) | map({status_code: .[0].status_code, count: length}) | sort_by(-.count)'
```

Slowest endpoints by average latency:

```bash
apxy logs list --limit 1000 | jq '.items | group_by(.url) | map({url: .[0].url, n: length, avg_ms: (map(.duration / 1e6) | add / length | round), max_ms: (map(.duration / 1e6) | max | round)}) | sort_by(-.avg_ms) | .[:10]'
```

Error rate by host:

```bash
apxy logs list --limit 1000 | jq '.items | group_by(.host) | map({host: .[0].host, total: length, errors: (map(select(.status_code >= 400)) | length)})'
```

The 20 newest 5xx errors with method and path:

```bash
apxy logs list --limit 1000 | jq '[.items[] | select(.status_code >= 500)] | sort_by(.timestamp) | reverse | .[:20][] | {id, method, path, status_code, ms: (.duration / 1e6 | round)}'
```

Group by host, path, and method:

```bash
apxy logs list --limit 1000 | jq '.items | group_by(.host, .path, .method) | map({host: .[0].host, path: .[0].path, method: .[0].method, cnt: length}) | sort_by(-.cnt) | .[:20]'
```

Requests slower than 2000 ms:

```bash
apxy logs list --limit 1000 | jq '[.items[] | select(.duration > 2e9)] | sort_by(-.duration) | .[:10][] | {method, url, ms: (.duration / 1e6 | round), status_code}'
```

Status breakdown for a flaky endpoint:

```bash
apxy logs search --query /api/search --limit 500 | jq '.items | group_by(.status_code) | map({status_code: .[0].status_code, count: length}) | sort_by(-.count)'
```

## JSONPath extraction patterns

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

## Debug recipes

### CORS errors

**Symptoms:** Browser console shows "blocked by CORS policy". Preflight `OPTIONS` request fails or returns without `Access-Control-Allow-Origin` header.

**Steps:**

1. Search to locate the preflight request and get its ID:
   ```bash
   apxy logs search --query "OPTIONS"
   ```
2. Open the preflight record. Search results show only status codes and metadata. The CORS headers are in the response headers, which only `show` prints:
   ```bash
   apxy logs show --id <OPTIONS_ID>
   ```
3. Confirm which CORS headers are present or missing in the response: `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`. Only after this step do you have the full picture to diagnose the issue.
4. Verify the follow-up GET/POST request exists and its status:
   ```bash
   apxy logs search --query "<api-host>" --limit 10
   ```
5. As a temporary fix, mock a correct preflight response:
   ```bash
   apxy mock add --name "cors-preflight" \
     --url "^https://api\.myapp\.com/" --match regex --method OPTIONS \
     --status 204 \
     --headers '{"Access-Control-Allow-Origin":"http://localhost:3000","Access-Control-Allow-Methods":"GET, POST, PUT, DELETE, OPTIONS","Access-Control-Allow-Headers":"Content-Type, Authorization","Access-Control-Max-Age":"86400"}'
   ```

**Fix:** Add correct CORS headers on the server. Remove the mock rule after deploying: `apxy mock remove --id <RULE_ID>`.

### Auth token failures

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

### 5xx server errors

**Symptoms:** API returns 500 / 502 / 503. Error message in response body. Some requests succeed, others fail intermittently.

**Steps:**

1. Search for the failing endpoint to get a list of record IDs and status codes:
   ```bash
   apxy logs search --query "/api/endpoint"
   ```
2. Open a failing record in full. `show` prints the request headers, response headers, and response body. Read it before you extract fields, so you know which JSON paths to target:
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

**Fix:** Read the error message from step 3. Common causes are an exhausted connection pool, a database outage, or an upstream timeout. The diff from step 4 shows whether failing requests differ in a request parameter. After the fix, run `apxy mark`, replay with `apxy logs replay --id <FAIL_ID>`, and check it with `apxy wait --match "<METHOD> <path>" --expect "status < 500"`.

### Slow API endpoints

**Symptoms:** Spinners hang, dashboards take seconds to load. Users report "the site is slow" without specifics.

**Steps:**

1. Search or list traffic to find the records. If the user named the slow feature, such as "search is slow", search for it by keyword:
   ```bash
   apxy logs search --query "<feature-or-path-keyword>"
   ```
   If you do not know the path, list recent traffic:
   ```bash
   apxy logs list --limit 50
   ```
2. Open a record from the slow endpoint and check its `duration` (nanoseconds) and `response_body_size`:
   ```bash
   apxy logs show --id <ID>
   ```
3. Rank all endpoints by latency:
   ```bash
   apxy logs list --limit 1000 | jq '.items | group_by(.url) | map({url: .[0].url, n: length, avg_ms: (map(.duration / 1e6) | add / length | round)}) | sort_by(-.avg_ms) | .[:10]'
   ```
4. After the change, replay the slow request and check its latency. `--expect` has no duration field, so read `duration` from the record:
   ```bash
   apxy mark
   apxy logs replay --id <BEFORE_ID>
   apxy wait --match "GET /api/users" --expect "status == 200" | jq '.data.record.duration / 1e6'
   ```
5. Diff before and after:
   ```bash
   apxy logs diff --id-a <BEFORE_ID> --id-b <AFTER_ID> --scope both
   ```

**Fix:** Add database indexes, fix N+1 queries, add caching, or shrink the response. Verify with replay and diff.

### Webhook delivery failures

**Symptoms:** Provider dashboard (Stripe, GitHub, etc.) shows failed deliveries. Your server returns 500 on webhook POST. No clear error in application logs.

**Steps:**

1. Search for webhook traffic:
   ```bash
   apxy logs search --query "webhook"
   ```
2. Open the failed delivery. Check the request headers, such as `Stripe-Signature`, and the response body:
   ```bash
   apxy logs show --id <FAIL_ID>
   ```
3. Diff a failed delivery against a successful one:
   ```bash
   apxy logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope request
   ```
4. After the fix, replay the failed delivery and check that it returns 200:
   ```bash
   apxy mark
   apxy logs replay --id <FAIL_ID>
   apxy wait --match "POST /webhooks/stripe" --expect "status == 200"
   ```

**Fix:** Fix handler validation, signature verification, or database constraint. Redeploy and trigger "Resend" from provider.

### Flaky API errors

**Symptoms:** Endpoint returns 200 most of the time but occasionally 503 or 500. Cannot reproduce on demand.

**Steps:**

1. Capture enough traffic, then count the failures:
   ```bash
   apxy logs search --query /api/search --limit 500 | jq '.items | group_by(.status_code) | map({status_code: .[0].status_code, count: length}) | sort_by(-.count)'
   ```
2. List failing rows with IDs:
   ```bash
   apxy logs search --query /api/search --limit 500 | jq '[.items[] | select(.status_code >= 500)] | .[:20][] | {id, status_code, ms: (.duration / 1e6 | round)}'
   ```
3. Diff a failure against a success. Start with the requests:
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

### GraphQL debugging

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
3. Open the full record. Check the `query` string, the `variables`, and the response `data` and `errors`:
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

### Docker container traffic

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

### SSE and WebSocket streams

1. Find the record: `apxy logs list`, then read what it carried with `apxy logs sse-events --id <ID>` or `apxy logs ws-frames --id <ID>`.
2. Assert on it: `apxy wait --match "GET /ws" --expect 'ws.server.data.type == order_created' --expect "ws.server.count >= 2"`. Fields: [dsl-reference.md](dsl-reference.md#stream-fields).
3. Exit 7 prints the last event or frame as the actual value, and whether the stream ended. An open stream that never sends the event points at the server. An ended one points at whoever closed it.

### Origin certificate errors

APXY checks the origin's certificate the way a browser does, except for localhost. A failed check returns 502 with header `X-Apxy-Error: upstream_certificate`, and the body names the host and the reason.

```bash
apxy wait --match 'header:X-Apxy-Error == upstream_certificate' --since 5m --timeout 0
```

The same request fails without APXY too, so report the certificate problem. For a staging server with a known self-signed certificate, pass `--insecure-upstream` to `apxy run` or `apxy start`. Never use it to hide an unexpected failure.

## See also

- Replay, diff, and regression checks after a fix: [replay-diff.md](replay-diff.md)
- API contract validation and breaking changes: [mocking.md](mocking.md)
