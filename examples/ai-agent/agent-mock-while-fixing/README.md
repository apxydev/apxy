# AI Agent Creates Mocks to Unblock While Fixing

When a backend endpoint is broken, waiting on a fix should not freeze the frontend. Have your agent locate the bad traffic, shape a correct mock response, add a rule, verify it, then tear the rule down after the real API is healthy again.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Mock rules, Traffic search, Traffic inspection, SSL interception | **Requires**: Free

## Scenario

The `/api/inventory` endpoint is broken, and the frontend team is blocked. Your agent identifies the broken endpoint from captured traffic, inspects what the response should look like (from docs, a prior successful capture, or an agreed contract), creates a temporary mock with the expected JSON so the frontend can keep working, then removes the mock after you fix the real endpoint and verifies the live API again.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with the APXY skill installed (see [Using APXY as a Claude Code / Cursor Skill](../agent-skill-reference/))

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

Reproduce the broken call at least once through the proxy so the agent has something to search and inspect.

---

## Track A: Agent + CLI Workflow

> The agent finds reality in the log, defines the contract as JSON, adds a mock rule, validates, then cleans up after you ship the backend fix.

### Step 1: Search traffic for the inventory endpoint

**Tell your agent:**

> "Search APXY logs for anything related to inventory on api.myapp.com so we can see failing or empty responses."

**Your agent runs:**

```bash
apxy traffic logs search --query "inventory"
```

The agent records the traffic **id** of a representative failure (timeout, 500, or wrong shape).

### Step 2: Inspect the broken response

**Tell your agent:**

> "Show the full record for that inventory request -- I need method, URL, status, and response body."

**Your agent runs:**

```bash
apxy traffic logs show --id 15
```

(Replace `15` with the id from Step 1.) Together you decide what the **correct** successful response should look like (for example `{ "items": [...], "updated_at": "..." }`).

### Step 3: Add a temporary mock rule

APXY creates mocks with **`apxy rules mock add`** (named rule, URL, method, status, body).

**Tell your agent:**

> "Add a mock that returns 200 for GET https://api.myapp.com/api/inventory with a JSON body that matches our contract so the frontend can develop against it."

**Your agent runs:**

```bash
apxy rules mock add --name "temp-inventory-unblock" \
  --url "https://api.myapp.com/api/inventory" \
  --method GET \
  --status 200 \
  --body '{"items":[{"sku":"A1","qty":12,"warehouse":"east"}],"updated_at":"2025-03-27T12:00:00Z"}'
```

The agent pastes JSON that matches your real schema so UI code does not need hacks.

### Step 4: Confirm the rule is active

**Tell your agent:**

> "List mock rules and confirm our inventory mock is present and will match first."

**Your agent runs:**

```bash
apxy rules mock list
```

The agent copies the rule **id** from the list for removal later.

### Step 5: Verify the mock is hit

**Tell your agent:**

> "Trigger a GET to inventory through the proxy again and confirm we see 200 and the mocked body, and that APXY marks it as mocked if visible in logs."

**Your agent runs:**

```bash
curl -x http://127.0.0.1:8080 https://api.myapp.com/api/inventory
```

(Adjust proxy address/port to match your `apxy proxy start` settings.) Then:

```bash
apxy traffic logs search --query "inventory"
```

The newest row should show success and reflect the canned payload.

### Step 6: You fix the real endpoint

Implement the backend fix, deploy or restart, and tell the agent when the real service is ready. No APXY command is required for this step.

### Step 7: Remove the temporary mock

**Tell your agent:**

> "Remove the temporary inventory mock rule now that the real API is fixed."

**Your agent runs:**

```bash
apxy rules mock remove --id RULE_ID_FROM_LIST
```

Use the id from Step 4. If multiple temp rules exist, the agent removes by explicit id rather than `--all`.

### Step 8: Verify the real endpoint through the proxy

**Tell your agent:**

> "Hit inventory again through the proxy and show the latest log line so we confirm status and that the body is no longer the mock."

**Your agent runs:**

```bash
curl -x http://127.0.0.1:8080 https://api.myapp.com/api/inventory
apxy traffic logs search --query "inventory"
```

Optionally the agent runs **`apxy traffic logs show --id ...`** on the newest id to prove the response matches production data, not the static mock.

---

## Track B: Web UI Workflow

You can follow along in the Web UI: open the dashboard, use **Traffic** to find `/api/inventory` the same way the agent used `apxy traffic logs search`. The detail panel matches **`apxy traffic logs show`**. Mock rules created on the CLI appear in the rules section of the UI; you can confirm names, URLs, and priority there instead of only running **`apxy rules mock list`**. After your backend fix, disable or delete the rule in the UI if you prefer not to use **`apxy rules mock remove`** from the terminal.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Agent + CLI: search, inspect, add mock, list, remove, verify
- Web UI: traffic inspection and rule overview

---

## What You Learned

- How **`apxy traffic logs search`** and **`apxy traffic logs show`** ground mocks in real failing traffic
- How **`apxy rules mock add`** supplies a **named** temporary contract for the frontend
- How **`apxy rules mock list`** and **`apxy rules mock remove --id`** keep cleanup explicit and safe
- How to verify behavior end-to-end with a proxied **`curl`** plus a fresh log search

---

## Next Steps

- [AI Agent Configures Mock Environment](../agent-setup-test-environment/) -- multiple third-party and internal mocks together
- [API Mocking tutorial](../../api-mocking/) -- broader mocking patterns
- [Let Your AI Agent Find and Fix Server Errors](../agent-debug-500-errors/) -- when the outage is 5xx instead of a missing contract
