# Testing Error Handling in Your UI

Exercise every branch of your error UI by returning real HTTP error codes from mocks -- without touching the backend.

**Difficulty**: Beginner | **Time**: ~10 minutes | **Features used**: Mock rules, Status code simulation | **Requires**: Free

## Scenario

Your frontend already has toast components, retry buttons, and empty states for failures, but you have only ever seen 200 responses in development. You will point `https://api.myapp.com/api/users` through APXY and swap mock rules (or disable extras) so each run returns a different status: 400, 401, 403, 404, 429, 500, and 503. That lets you confirm copy, icons, and recovery flows for each case.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- Optional: `/etc/hosts` entry `127.0.0.1 api.myapp.com` for deterministic local resolution

**Free tier:** Only **three** mock rules may be active at once. This tutorial cycles through **seven** statuses by updating or replacing a single rule (recommended), or by disabling rules you no longer need. Follow the steps in order.

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

> Best for: agents that run CLI and report status lines and JSON bodies back to you.

### Step 1: Baseline -- 401 Unauthorized

**Tell your agent:**

> "Clear existing user mocks if any, then add a GET mock for https://api.myapp.com/api/users that returns 401 with a JSON error body about an invalid token."

**Your agent runs:**

```bash
apxy rules mock clear
apxy rules mock add --name "users-errors" --url "https://api.myapp.com/api/users" --method GET --match exact --status 401 --body '{"error":"unauthorized","message":"Invalid or expired token"}'
```

Agent confirms:

```
Rule created: users-errors (ID: ...)
```

**Tell your agent:**

> "Curl that URL and show me the status and body."

**Your agent runs:**

```bash
curl -sS -w "\nHTTP %{http_code}\n" "https://api.myapp.com/api/users"
```

Agent reports status **401** and your JSON error payload.

### Step 2: 400 Bad Request

**Tell your agent:**

> "Remove the last mock and add the same URL with 400 and a validation-style error body."

**Your agent runs:**

```bash
apxy rules mock list
apxy rules mock remove --id <previous-id>
apxy rules mock add --name "users-errors" --url "https://api.myapp.com/api/users" --method GET --match exact --status 400 --body '{"error":"bad_request","message":"Missing required query param: org_id"}'
```

Agent shows **400** on curl.

### Step 3: 403 Forbidden

**Tell your agent:**

> "Replace the mock with 403 and an insufficient permissions message."

**Your agent runs:**

```bash
apxy rules mock remove --all
apxy rules mock add --name "users-errors" --url "https://api.myapp.com/api/users" --method GET --match exact --status 403 --body '{"error":"forbidden","message":"You do not have access to this organization"}'
```

### Step 4: 404 Not Found

**Tell your agent:**

> "Replace the mock with 404 and a not-found message."

**Your agent runs:**

```bash
apxy rules mock remove --all
apxy rules mock add --name "users-errors" --url "https://api.myapp.com/api/users" --method GET --match exact --status 404 --body '{"error":"not_found","message":"Resource not found"}'
```

### Step 5: 429 Rate Limited

Include a hint header in the mock response if you want to test `Retry-After` parsing:

**Tell your agent:**

> "Replace the mock with 429 rate-limited and a Retry-After header."

**Your agent runs:**

```bash
apxy rules mock remove --all
apxy rules mock add --name "users-errors" --url "https://api.myapp.com/api/users" --method GET --match exact --status 429 --headers "Retry-After=30" --body '{"error":"rate_limited","message":"Too many requests; try again in 30 seconds"}'
```

### Step 6: 500 Internal Server Error

**Tell your agent:**

> "Replace the mock with 500 internal server error including a trace_id."

**Your agent runs:**

```bash
apxy rules mock remove --all
apxy rules mock add --name "users-errors" --url "https://api.myapp.com/api/users" --method GET --match exact --status 500 --body '{"error":"internal_error","message":"Unexpected failure","trace_id":"demo-trace"}'
```

### Step 7: 503 Service Unavailable

**Tell your agent:**

> "Replace the mock with 503 service unavailable."

**Your agent runs:**

```bash
apxy rules mock remove --all
apxy rules mock add --name "users-errors" --url "https://api.myapp.com/api/users" --method GET --match exact --status 503 --body '{"error":"unavailable","message":"Service temporarily unavailable"}'
```

### Step 8: List rules before teardown

**Tell your agent:**

> "List mock rules so I can see what is still active."

**Your agent runs:**

```bash
apxy rules mock list
```

Agent shows a single active rule (or your remaining experiments).

---

## Track B: Web UI Workflow

> Best for: editing status codes and bodies without retyping long JSON in the shell.

### Step 1: Proxy + Web UI

```bash
apxy proxy start --ssl-domains api.myapp.com
```

Open **http://localhost:8082**.

> screenshots/01-dashboard.png

### Step 2: Mock Rules editor

Go to **Rules → Mock Rules**. Clear old rules if needed (per-product UI: delete or disable each row).

> screenshots/02-mock-rules-cleared.png

### Step 3: Create or edit the GET /api/users rule

**Create Mock Rule** with:

- URL `https://api.myapp.com/api/users`, **Exact**, **GET**
- **Status** 401
- Inline body: `{"error":"unauthorized","message":"Invalid or expired token"}`

Save, then hit the URL from your app and confirm the UI.

> screenshots/03-mock-401.png

### Step 4: Walk the status ladder in the UI

Open the same rule and change **Status** and **Response Body** for 400, 403, 404, 429, 500, and 503 (optionally add **Response** headers such as `Retry-After` for 429). After each change, reload your frontend or trigger the fetch again.

> screenshots/04-mock-429-retry-after.png

### Step 5: Traffic tab

Open **Traffic** and select a failed request. Confirm **Mocked** appears where applicable and the status line matches your scenario.

> screenshots/05-traffic-error-mocked.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- CLI: one-rule swap pattern for seven statuses
- Web UI: editing status and body per scenario

---

## What You Learned

- How to return **400, 401, 403, 404, 429, 500, 503** from mocks on the same endpoint
- How to attach **response headers** (for example `Retry-After`) with `--headers` / the Web UI
- How to **remove** or **replace** rules so Free-tier limits stay manageable
- How to verify each scenario quickly with `curl` or the **Traffic** view

## Next Steps

- [Building UI Without a Backend](../mock-backend-for-frontend/) -- happy-path CRUD mocks
- [A/B Testing and Feature Flags via Mocks](../mock-with-header-conditions/) -- multiple responses without swapping rules
- [Serving Mock Responses from Files](../mock-large-responses-from-files/) -- large JSON fixtures
- [Replay and Diff](../../replay-and-diff/) -- compare before/after real responses
