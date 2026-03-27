# Mocking -- API Stubs, Interceptors & Schema Validation

## Prerequisites

Ensure proxy is running:

```bash
apxy proxy status
```

If not running:

```bash
apxy proxy start --port 8080 --ssl-domains <target-domain>
```

SSL is required for HTTPS endpoints (Stripe, GitHub, OpenAI, etc.). Add comma-separated domains: `--ssl-domains api.stripe.com,api.github.com`.

## Mock Rule Commands

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules mock add` | Create mock rule | `--name`, `--url`, `--match` (exact\|wildcard\|regex), `--method`, `--status` (200), `--body`, `--delay`, `--priority` |
| `apxy rules mock list` | List rules | `--format` (json\|toon), `--quiet` |
| `apxy rules mock enable` | Enable rule | `--id` or `--all`, `--dry-run` |
| `apxy rules mock disable` | Disable rule | `--id` or `--all`, `--dry-run` |
| `apxy rules mock remove` | Remove rule | `--id` or `--all`, `--dry-run` |
| `apxy rules mock clear` | Delete all rules | `--dry-run` |

## Mock Rule Key Flags (Detailed)

**--url** -- URL pattern to match against incoming requests.

```bash
--url "https://api.stripe.com/v1/charges"       # exact URL
--url "https://api.example.com/users/*"          # wildcard (use with --match wildcard)
--url "^https://api\\.example\\.com/v[0-9]+/.*$" # regex (use with --match regex)
```

**--match** -- Match type: `exact` (default), `wildcard`, or `regex`.

- `exact` -- URL must match character-for-character.
- `wildcard` -- `*` matches any substring within a path segment or across segments.
- `regex` -- Full Go-flavored regex.

**--method** -- HTTP method filter (e.g. GET, POST, PUT, DELETE). If omitted, the rule matches any method.

```bash
--method POST
```

**--status** -- Response status code. Defaults to 200.

```bash
--status 201    # created
--status 429    # rate limited
--status 500    # server error
```

**--body** -- Response body string (typically JSON).

```bash
--body '{"id":"ch_test","status":"succeeded"}'
```

**--delay** -- Artificial response delay in milliseconds. Simulates slow APIs.

```bash
--delay 2000    # 2-second delay
```

**--priority** -- Higher values match first. Use to layer scenario-specific rules above default happy-path rules.

```bash
--priority 10   # scenario rules (checked first)
--priority 50   # default rules (checked if no scenario matches)
```

## Interceptor Commands

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules interceptor set` | Add interceptor | `--name`, `--match` (DSL), `--action` (mock\|modify\|observe), `--description`, `--add-request-headers`, `--set-request-headers`, `--set-response-headers`, `--remove-headers`, `--set-response-status`, `--set-response-body`, `--delay-ms` |
| `apxy rules interceptor list` | List interceptors | `--format` (json\|toon), `--quiet` |
| `apxy rules interceptor remove` | Remove interceptor | `--id` or `--all`, `--dry-run` |

**--action values:**

- `observe` (default) -- Pass-through; can add delay or log headers without changing the request/response.
- `modify` -- Alter headers, status, or body on requests or responses in transit.
- `mock` -- Short-circuit the request entirely and return a synthetic response (similar to mock rules but with DSL matching).

**Header manipulation flags:**

```bash
# Add a header to the request if not already present
--add-request-headers Authorization="Bearer tok"

# Overwrite request headers unconditionally
--set-request-headers X-Debug=true

# Set or overwrite response headers
--set-response-headers Cache-Control=no-store

# Remove headers from request or response
--remove-headers X-Powered-By,Server
```

**Examples:**

```bash
# Inject auth header into all requests to a host
apxy rules interceptor set --name "add-auth" \
  --match "host == api.example.com" --action modify \
  --add-request-headers Authorization="Bearer tok"

# Simulate slow search responses
apxy rules interceptor set --name "slow-search" \
  --match "path contains /search" --action observe --delay-ms 500
```

## Schema Validation Commands

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy schema import` | Import OpenAPI spec | `--name`, `--file` or `--url` (one required) |
| `apxy schema list` | List schemas | `--format` (json\|toon), `--quiet` |
| `apxy schema show` | Show schema details | `--id` (required) |
| `apxy schema validate` | Validate record vs schema | `--record-id` (required), `--schema-id` (required) |
| `apxy schema validate-recent` | Validate recent traffic | `--limit` (default 20) |
| `apxy schema delete` | Delete schema | `--id` (required), `--dry-run` |

## Agent Workflow: Mock for Testing

```bash
apxy rules mock add --name "stub-payment" --url "https://api.stripe.com/v1/charges" \
  --match wildcard --status 200 --body '{"id":"ch_test","status":"succeeded"}'
apxy rules mock list
apxy tools request compose --method POST --url "https://api.stripe.com/v1/charges" --body '{"amount":1000}'
apxy rules mock remove --id <RULE_ID>
```

## Agent Workflow: Unblock Frontend (Design-First)

Frontend teams shouldn't wait for backend -- mock every endpoint from the agreed API contract so parallel development can start immediately.

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
# Frontend hits the proxy -- gets realistic responses without any backend running
```

## Agent Workflow: Catch Breaking Changes

Compare real API responses against your OpenAPI spec -- surface contract violations before users hit them.

```bash
# Import the spec that the team agreed on
apxy schema import --name "my-api" --file ./openapi.yaml
# Run with live validation so every request is checked as it happens
apxy proxy start --port 8080 --auto-validate
eval $(apxy env)
# Exercise the app (or run your test suite) -- violations are flagged automatically
apxy schema validate-recent --limit 50
# Validate a specific suspicious response manually
apxy schema validate --record-id <ID> --schema-id <SCHEMA_ID>
```

## Agent Workflow: API Schema Validation

```bash
apxy schema import --name "my-api" --file ./openapi.yaml
apxy schema list
apxy proxy start --port 8080 --auto-validate         # live validation
apxy schema validate-recent --limit 50               # check recent traffic
apxy schema validate --record-id <ID> --schema-id <SID>  # validate one record
```

## Agent Workflow: Mock While Fixing

When a backend endpoint is broken, create a temporary mock so the frontend can keep working while you fix the real service.

**Step 1: Find the broken endpoint in traffic**

```bash
apxy traffic logs search --query "inventory"
apxy traffic logs show --id <ID>
```

The agent records the traffic ID of a representative failure (timeout, 500, or wrong shape) and inspects what the correct response should look like.

**Step 2: Add a temporary mock rule**

```bash
apxy rules mock add --name "temp-inventory-unblock" \
  --url "https://api.myapp.com/api/inventory" \
  --method GET \
  --status 200 \
  --body '{"items":[{"sku":"A1","qty":12,"warehouse":"east"}],"updated_at":"2025-03-27T12:00:00Z"}'
```

**Step 3: Confirm the rule is active**

```bash
apxy rules mock list
```

Copy the rule ID for cleanup later.

**Step 4: Verify the mock is serving traffic**

```bash
curl -x http://127.0.0.1:8080 https://api.myapp.com/api/inventory
apxy traffic logs search --query "inventory"
```

The newest row should show 200 with the mocked payload.

**Step 5: Fix the real backend, then remove the mock**

```bash
apxy rules mock remove --id <RULE_ID>
```

**Step 6: Verify the real endpoint works**

```bash
curl -x http://127.0.0.1:8080 https://api.myapp.com/api/inventory
apxy traffic logs search --query "inventory"
```

Confirm the response is live data, not the static mock.

## Free Tier Limits

- Maximum 3 active mock rules on Free tier
- Rotate rules: disable old then add new, or remove then add

```bash
# Disable an old rule to make room
apxy rules mock disable --id <OLD_RULE_ID>
# Add the new rule
apxy rules mock add --name "new-rule" --url "..." --status 200 --body '...'
```

## See Also

- For vendor-specific mock templates: [mock-templates.md](mock-templates.md)
