# Mocking and schema validation

`apxy mock add`, `list`, `enable`, `disable`, `remove`, and `clear` work without a running proxy. A rule you add while no proxy runs applies when the next proxy starts. `apxy mock import` needs a running proxy. For an HTTPS URL, the proxy must decrypt that host, so start it with `--ssl-domains <host>` or `--mitm-all`.

## Mock rule commands

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy mock add` | Create mock rule | `--name`, `--url`, `--match` (exact\|wildcard\|regex), `--method`, `--header-conditions`, `--headers`, `--status` (200), `--body`, `--delay`, `--priority` |
| `apxy mock list` | List rules | `--format` (json\|toon), `--quiet` |
| `apxy mock enable` | Enable rule | `--id` or `--all`, `--dry-run` |
| `apxy mock disable` | Disable rule | `--id` or `--all`, `--dry-run` |
| `apxy mock remove` | Remove rule | `--id` or `--all`, `--dry-run` |
| `apxy mock clear` | Delete all rules | `--dry-run` |
| `apxy mock import` | Import rules from JSON template | `--file`, `--control-url` |

## Mock rule flags

`--url` is the URL pattern to match.

```bash
--url "https://api.stripe.com/v1/charges"       # exact URL
--url "https://api.example.com/users/*"          # wildcard (use with --match wildcard)
--url "^https://api\\.example\\.com/v[0-9]+/.*$" # regex (use with --match regex)
```

`--match` is the match type: `exact` (default), `wildcard`, or `regex`.

- `exact` matches the URL character for character.
- `wildcard` lets `*` match any characters except `/`, so it stays inside one path segment: `/users/*` matches `/users/42` but not `/users/42/orders`.
- `regex` takes a Go regular expression and is not anchored. Use it to match any depth: `--url "^/api/" --match regex` catches every path under `/api/`.

The pattern is checked against the full URL, the path, and the path with its query, so `/api/users` matches a request to any host.

`--method` limits the rule to one HTTP method, such as GET or POST. Without it, the rule matches any method.

```bash
--method POST
```

`--header-conditions` matches request headers, as JSON or `k=v` pairs. Use it to serve a different mock per test scenario.

```bash
--header-conditions 'X-APXY-Scenario=card_declined'
--header-conditions '{"X-APXY-Scenario":"rate_limited"}'
```

`--headers` sets response headers, as JSON or `k=v` pairs.

```bash
--headers 'Content-Type=application/json,Cache-Control=no-store'
--headers '{"Access-Control-Allow-Origin":"http://localhost:3000"}'
```

`--status` sets the response status code. The default is 200.

```bash
--status 201    # created
--status 429    # rate limited
--status 500    # server error
```

`--body` sets the response body, usually JSON.

```bash
--body '{"id":"ch_test","status":"succeeded"}'
```

`--delay` holds the response for that many milliseconds, to test a slow API.

```bash
--delay 2000    # 2-second delay
```

`--priority` orders rules. Lower values match first, so scenario rules can sit above the default rules.

```bash
--priority 10   # scenario rules (checked first)
--priority 50   # default rules (checked after scenario rules)
```

## Schema validation commands

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy schema import` | Import OpenAPI spec | `--name`, `--file` or `--url` (one required) |
| `apxy schema list` | List schemas | `--format` (json\|toon), `--quiet` |
| `apxy schema show` | Show schema details | `--id` (required) |
| `apxy schema validate` | Validate record vs schema | `--record-id` (required), `--schema-id` (required) |
| `apxy schema validate-recent` | Validate recent traffic | `--limit` (default 20) |
| `apxy schema delete` | Delete schema | `--id` (required), `--dry-run` |

## Agent workflow: mock for testing

```bash
apxy mock add --name "stub-payment" --url "https://api.stripe.com/v1/charges" \
  --method POST --status 200 --body '{"id":"ch_test","status":"succeeded"}'
apxy mock list
apxy mark
apxy run --ssl-domains api.stripe.com -- curl -s -X POST https://api.stripe.com/v1/charges -d amount=1000
apxy wait --match "POST /v1/charges" --expect "status == 200" --expect "body.status == succeeded"
apxy mock remove --id <RULE_ID>
```

`apxy wait` exits with 0 when the mock served the request. The record in its output has `"mocked": true`, `data.mocked_by` names the rule and its rules file, and `data.warning` says the pass was on a mocked response. In a git worktree the mock answers only that worktree's traffic; see [workspaces.md](workspaces.md#mocks-and-rules).

## Agent workflow: unblock a frontend

Mock each endpoint from the agreed API contract. The frontend can then run before the backend exists.

```bash
apxy start --port 8080
eval $(apxy env)
# Mock each endpoint from the OpenAPI contract
apxy mock add --name "get-users" --url "/api/users" --match wildcard --method GET --status 200 \
  --body '{"users":[{"id":1,"name":"Alice"}]}'
apxy mock add --name "create-user" --url "/api/users" --match wildcard --method POST \
  --status 201 --body '{"id":2,"name":"Bob"}'
apxy mock add --name "auth-login" --url "/api/auth/login" --match wildcard --method POST \
  --status 200 --body '{"token":"eyJ...","expires_in":3600}'
apxy mock list
# The frontend now gets these responses through the proxy, with no backend running
```

Give each rule a `--method` when two rules share a URL. A rule without one matches every method, so it can answer the POST meant for the other rule.

## Agent workflow: catch breaking changes

Compare real API responses with your OpenAPI spec to find contract violations.

```bash
# Import the spec that the team agreed on
apxy schema import --name "my-api" --file ./openapi.yaml
# Run with live validation so every request is checked as it happens
apxy start --port 8080 --auto-validate
eval $(apxy env)
# Exercise the app or run the test suite. APXY flags each violation as it happens.
apxy schema validate-recent --limit 50
# Validate a specific suspicious response manually
apxy schema validate --record-id <ID> --schema-id <SCHEMA_ID>
```

## Agent workflow: mock while fixing

When a backend endpoint is broken, create a temporary mock so the frontend can keep working while you fix the real service.

**Step 1: Find the broken endpoint in traffic**

```bash
apxy logs search --query "inventory"
apxy logs show --id <ID>
```

The agent records the traffic ID of a representative failure (timeout, 500, or wrong shape) and inspects what the correct response should look like.

**Step 2: Add a temporary mock rule**

```bash
apxy mock add --name "temp-inventory-unblock" \
  --url "https://api.myapp.com/api/inventory" \
  --method GET \
  --status 200 \
  --body '{"items":[{"sku":"A1","qty":12,"warehouse":"east"}],"updated_at":"2025-03-27T12:00:00Z"}'
```

**Step 3: Confirm the rule is active**

```bash
apxy mock list
```

Copy the rule ID for cleanup later.

**Step 4: Verify the mock is serving traffic**

```bash
apxy mark
apxy run --ssl-domains api.myapp.com -- curl -s https://api.myapp.com/api/inventory
apxy wait --match "GET /api/inventory" --expect "status == 200" --expect "body.items exists"
```

Exit code 0 means the mock served the request. `apxy run` decrypts the host and makes curl trust the APXY CA. A plain `curl -x` does neither, so it never reaches the mock. If a proxy already runs, `apxy run` reuses it and ignores `--ssl-domains`; run `apxy ssl enable --domain api.myapp.com` first.

**Step 5: Fix the real backend, then remove the mock**

```bash
apxy mock remove --id <RULE_ID>
```

**Step 6: Verify the real endpoint works**

```bash
apxy mark
apxy run --ssl-domains api.myapp.com -- curl -s https://api.myapp.com/api/inventory
apxy wait --match "GET /api/inventory" --expect "status == 200" --expect "body.updated_at != 2025-03-27T12:00:00Z"
```

Exit code 0 means the real backend answered, not the mock.

## See also

- For vendor-specific mock templates: [mock-templates.md](mock-templates.md)
- To record real LLM API responses and replay them in tests: [llm-and-agent-traffic.md](llm-and-agent-traffic.md)
