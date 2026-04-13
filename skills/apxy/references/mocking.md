# Mocking — API Stubs & Schema Validation

Ensure proxy is running: `apxy status`. If not: `apxy start --port 8080 --ssl-domains <target-domain>`.

## Mock Rule Commands

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy mock add` | Create mock rule | `--name`, `--url`, `--match` (exact\|wildcard\|regex), `--method`, `--header-conditions`, `--headers`, `--status` (200), `--body`, `--delay`, `--priority` |
| `apxy mock list` | List rules | `--format` (json\|toon), `--quiet` |
| `apxy mock enable` | Enable rule | `--id` or `--all`, `--dry-run` |
| `apxy mock disable` | Disable rule | `--id` or `--all`, `--dry-run` |
| `apxy mock remove` | Remove rule | `--id` or `--all`, `--dry-run` |
| `apxy mock clear` | Delete all rules | `--dry-run` |
| `apxy mock import` | Import rules from JSON template | `--file`, `--control-url` |

> **Free tier:** Maximum 3 active mock rules. To rotate: `apxy mock disable --id <OLD>` then add the new rule.

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

**--header-conditions** -- Request header matchers as JSON or `k=v` pairs. Useful for scenario-specific mocks.

```bash
--header-conditions 'X-APXY-Scenario=card_declined'
--header-conditions '{"X-APXY-Scenario":"rate_limited"}'
```

**--headers** -- Response headers as JSON or `k=v` pairs.

```bash
--headers 'Content-Type=application/json,Cache-Control=no-store'
--headers '{"Access-Control-Allow-Origin":"http://localhost:3000"}'
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

**--priority** -- Lower values match first. Use to layer scenario-specific rules above default happy-path rules.

```bash
--priority 10   # scenario rules (checked first)
--priority 50   # default rules (checked after scenario rules)
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
apxy mock add --name "stub-payment" --url "https://api.stripe.com/v1/charges" \
  --match wildcard --status 200 --body '{"id":"ch_test","status":"succeeded"}'
apxy mock list
apxy tools request compose --method POST --url "https://api.stripe.com/v1/charges" --body '{"amount":1000}'
apxy mock remove --id <RULE_ID>
```

## Agent Workflow: Unblock Frontend (Design-First)

Frontend teams shouldn't wait for backend -- mock every endpoint from the agreed API contract so parallel development can start immediately.

```bash
apxy start --port 8080
eval $(apxy env)
# Mock each endpoint from the OpenAPI contract
apxy mock add --name "get-users" --url "/api/users" --match wildcard --status 200 \
  --body '{"users":[{"id":1,"name":"Alice"}]}'
apxy mock add --name "create-user" --url "/api/users" --match wildcard --method POST \
  --status 201 --body '{"id":2,"name":"Bob"}'
apxy mock add --name "auth-login" --url "/api/auth/login" --match wildcard --method POST \
  --status 200 --body '{"token":"eyJ...","expires_in":3600}'
apxy mock list
# Frontend hits the proxy -- gets realistic responses without any backend running
```

## Agent Workflow: Catch Breaking Changes

Compare real API responses against your OpenAPI spec -- surface contract violations before users hit them.

```bash
# Import the spec that the team agreed on
apxy schema import --name "my-api" --file ./openapi.yaml
# Run with live validation so every request is checked as it happens
apxy start --port 8080 --auto-validate
eval $(apxy env)
# Exercise the app (or run your test suite) -- violations are flagged automatically
apxy schema validate-recent --limit 50
# Validate a specific suspicious response manually
apxy schema validate --record-id <ID> --schema-id <SCHEMA_ID>
```

## Agent Workflow: Mock While Fixing

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
curl -x http://127.0.0.1:8080 https://api.myapp.com/api/inventory
apxy logs search --query "inventory"
```

The newest row should show 200 with the mocked payload.

**Step 5: Fix the real backend, then remove the mock**

```bash
apxy mock remove --id <RULE_ID>
```

**Step 6: Verify the real endpoint works**

```bash
curl -x http://127.0.0.1:8080 https://api.myapp.com/api/inventory
apxy logs search --query "inventory"
```

Confirm the response is live data, not the static mock.

## See Also

- For vendor-specific mock templates: [mock-templates.md](mock-templates.md)
