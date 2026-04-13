# Let Your AI Agent Find and Fix Server Errors

Production is returning 500s and log aggregation is noisy. Route traffic through APXY, then have your coding agent query captured traffic, pull error payloads with jsonpath, and turn that into a concrete fix you can ship.

**Difficulty**: Intermediate | **Time**: ~15 minutes | **Features used**: SQL queries, Traffic inspection, JSONPath extraction, SSL interception | **Requires**: Free

## Scenario

Your app is throwing 500 errors in production. Instead of manually digging through logs, tell your AI agent to use APXY to find all server errors, inspect the payloads, identify the root cause, and suggest a fix. You stay in the loop for the actual code change; the agent does the forensic work across SQL, full record views, structured extraction, and a verification replay.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with the APXY skill installed (see [Using APXY as a Claude Code / Cursor Skill](../agent-skill-reference/))

### Plan note

**`apxy sql`** is a **Pro** feature in licensed builds. On **Free**, have your agent use **`apxy logs search --query "500"`** (or status tokens your UI surfaces) instead of SQL, then **`apxy logs show`** on each candidate id. Upgrade or use Pro for ad-hoc aggregates.

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

Generate traffic through the proxy (your app, integration tests, or `curl`) so there are real 500 responses in the database before you begin Track A.

---

## Track A: Agent + CLI Workflow

> Primary path: natural language to your agent; the agent runs APXY CLI commands and reports back.

### Step 1: List recent server errors with SQL

**Tell your agent:**

> "Use APXY's read-only SQL to list recent requests with status 500 or higher for api.myapp.com. I want id, method, full url, status, and duration_ms, newest first."

**Your agent runs:**

```bash
apxy sql query "SELECT id, method, url, status_code, duration_ms FROM traffic_logs WHERE status_code >= 500 ORDER BY id DESC LIMIT 50"
```

The agent picks the most relevant row (for example the one matching `/api/orders` or the latest customer-facing failure) and notes its `id` for the next steps.

### Step 2: Open the full record

**Tell your agent:**

> "Show me the complete captured record for traffic id 42 -- request and response, headers and bodies."

**Your agent runs:**

```bash
apxy logs show --id 42
```

(Replace `42` with the id from Step 1.) The agent reads the response body and headers, looking for stack traces, upstream error envelopes, or validation failures.

### Step 3: Extract the error message with jsonpath

**Tell your agent:**

> "From record 42's response JSON, extract only the user-facing or API error message field."

**Your agent runs:**

```bash
apxy logs jsonpath --id 42 --path "error.message"
```

If your API nests errors differently, the agent adjusts the path (for example `message` or `errors.0.detail`).

### Step 4: Extract stack or diagnostic fields

**Tell your agent:**

> "If there is a stack trace or internal detail in the response body, extract it so we can see the failing line or service."

**Your agent runs:**

```bash
apxy logs jsonpath --id 42 --path "error.stack"
```

If the body is not JSON or the path misses, the agent falls back to the full `apxy logs show` output from Step 2.

### Step 5: Correlate pattern across multiple 500s

**Tell your agent:**

> "Run SQL again to see if other 500s share the same path or host, and summarize whether this looks like one bug or many."

**Your agent runs:**

```bash
apxy sql query "SELECT path, status_code, COUNT(*) AS n FROM traffic_logs WHERE status_code >= 500 GROUP BY path, status_code ORDER BY n DESC"
```

The agent explains the pattern (for example "all 500s are POST /api/orders with the same error.message").

### Step 6: You apply the fix

Based on the agent's summary (nil dereference, constraint violation, timeout from a dependency, etc.), you change application code or configuration. Restart or redeploy as needed. The agent does not need to run commands in this step unless you ask it to edit files.

### Step 7: Replay a representative request

**Tell your agent:**

> "After my fix, send the same kind of request that used to 500 -- POST to orders with a body like the failing capture."

**Your agent runs:**

```bash
apxy tools request compose --method POST --url https://api.myapp.com/api/orders \
  --body '{"customer_id":"cust_42","items":[{"sku":"WIDGET-1","qty":2}]}'
```

The agent uses the real body from `apxy logs show` when available so the replay matches production. The new exchange appears as a new traffic id (for example `58`).

### Step 8: Diff old failure vs new success

**Tell your agent:**

> "Diff the original failing record against the new one -- focus on the response only."

**Your agent runs:**

```bash
apxy logs diff --id-a 42 --id-b 58 --scope response
```

The agent summarizes: status code change, error object removed, expected success payload present.

---

## Track B: Web UI Workflow

You can follow the same investigation in the Web UI while the proxy runs. Open the local dashboard (default **http://localhost:8082** unless you changed the port), go to **Traffic**, and sort or filter for status **500** to match the SQL from Track A.

Click a row to inspect the full request and response side by side; the UI is equivalent to `apxy logs show`. When you need structured fields, the agent can still run `apxy logs jsonpath` for you, or you can read the formatted JSON in the response panel. After your fix, use **Compose** to replay a request and **Diff** to compare two records visually -- the same before/after story as `apxy logs diff` on the CLI.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Agent + CLI: finding 500s, jsonpath, replay, diff
- Web UI: traffic table, detail view, compose and diff

---

## What You Learned

- How to drive APXY from an agent using **read-only SQL** on `traffic_logs` for status and latency-aware listings
- How **`apxy logs show`** and **`apxy logs jsonpath`** narrow huge responses to the fields that explain failures
- How to **replay** with **`apxy tools request compose`** and prove a fix with **`apxy logs diff --scope response`**
- That the Web UI mirrors the same capture data for visual confirmation

---

## Next Steps

- [AI Agent Creates Mocks to Unblock While Fixing](../agent-mock-while-fixing/) -- temporary mocks while backend catches up
- [AI Agent Validates a Fix with Replay+Diff](../agent-compare-before-after/) -- shorter variant focused on the proof loop
- [Replay and Diff (full tutorial)](../../replay-and-diff/) -- deeper narrative on capture, replay, and diff
