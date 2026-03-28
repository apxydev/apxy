# Handling API Rate Limits Gracefully

Practice 429 responses, `Retry-After`, and rate-limit headers against your real client code—no billing surprises from hammering a production quota.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Mock rules, Rate limiting simulation, SSL interception | **Requires**: Free

## Scenario

Your app calls a third-party API that rate-limits to 100 requests per minute. You need to verify your app handles 429 responses correctly—backing off, retrying, and showing appropriate UI feedback—without burning through real quota or waiting for organic throttling.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.example.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.example.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

Traffic to `https://api.example.com` must pass through the proxy. The mock rule below matches wildcard paths under `/api/` so multiple endpoints return the same rate-limit story until you remove or disable the rule.

### Step 1: Add a 429 mock with rate-limit headers

**Tell your agent:**

> "Add a mock that returns 429 for any https://api.example.com/api/* call, with Retry-After and rate-limit headers, plus a JSON error body."

**Your agent runs:**

```bash
apxy rules mock add \
  --name "example-rate-limit" \
  --url "https://api.example.com/api/*" \
  --match wildcard \
  --status 429 \
  --headers "Retry-After=30,X-RateLimit-Remaining=0,X-RateLimit-Reset=1700000000" \
  --body '{"error":"rate_limit_exceeded","message":"Too many requests. Please retry after 30 seconds."}'
```

Header values use the CLI’s `k=v` form (comma-separated pairs). Adjust `X-RateLimit-Reset` to a realistic Unix timestamp for your tests.

### Step 2: Exercise the client

**Tell your agent:**

> "I'll trigger the parts of my app that call api.example.com—list views, background sync, batch jobs—while you watch for duplicate retries or missing UI."

No command is required unless you also want captures:

```bash
apxy traffic logs search --query "api.example.com" --limit 20
```

Confirm: your client reads `Retry-After` (seconds or HTTP-date, per spec), backs off, surfaces a toast or inline message, and does not tight-loop.

### Step 3: Inspect and tune the mock

**Tell your agent:**

> "List mock rules so we can confirm the rate-limit rule is first in line and enabled."

**Your agent runs:**

```bash
apxy rules mock list
```

If you need a different window, remove and re-add with new headers or body. To simulate “one more call allowed” alongside a catch-all 429, add a narrower URL rule with a **smaller** `--priority` integer so it wins over the wildcard (in the Web UI: lower number = evaluated first).

### Step 4: Remove the mock and verify normal flow

**Tell your agent:**

> "Remove the rate-limit mock so real api.example.com responses flow again."

**Your agent runs:**

```bash
apxy rules mock list
apxy rules mock remove --id <MOCK_RULE_ID>
```

Or clear all mocks in this workspace:

```bash
apxy rules mock remove --all
```

**Tell your agent:**

> "Compose a test GET through the proxy to confirm we get a real 200 (or expected prod status)."

**Your agent runs:**

```bash
apxy tools request compose --method GET --url "https://api.example.com/api/v1/status"
```

---

## Track B: Web UI Workflow

### Step 1: Open Mock rules

Go to **Rules** → **Mock**. Start **Add rule** (wording may vary).

> screenshots/01-mock-rules-empty.png

### Step 2: Configure wildcard 429

- **URL / pattern**: `https://api.example.com/api/*`
- **Match type**: Wildcard
- **Status**: 429
- **Response headers**: `Retry-After`, `X-RateLimit-Remaining`, `X-RateLimit-Reset`
- **Body**: JSON message matching your product copy expectations

Save the rule.

> screenshots/02-mock-429-wildcard.png

### Step 3: Use Traffic to confirm 429s

Open **Traffic**. Filter or search for `api.example.com`. Each affected call should show status **429** and your mocked headers in the detail pane.

> screenshots/03-traffic-429-rows.png

### Step 4: Disable or delete the rule

Toggle the rule off or delete it, then refresh the app and confirm successful calls resume.

> screenshots/04-mock-rule-disabled.png

---

## Video Walkthrough

*[YouTube link -- coming soon]*

- 0:00 — Proxy + SSL for `api.example.com`
- 1:30 — CLI `apxy rules mock add` with headers and wildcard URL
- 4:00 — Client behavior: backoff and UI
- 6:00 — Web UI mock editor and **Traffic**
- 7:30 — Removing the mock and sanity check with Compose

---

## What You Learned

- Faking **429** responses with realistic **Retry-After** and vendor-style rate-limit headers
- Using **wildcard** URL matching for whole API subtrees (`/api/*`)
- Attaching response headers via `--headers` on `apxy rules mock add`
- Listing and removing mocks so staging behavior does not leak into the next task

## Next Steps

- [Simulate Network Failures](../simulate-network-failures/) — 503s and transport-level failure
- [Mock Template Stripe](../../mocking/mock-template-stripe/) — Structured third-party mocking patterns
- [API Mocking](../../api-mocking/) — Broader mock rule strategies
