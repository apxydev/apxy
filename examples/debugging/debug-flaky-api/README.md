# Diagnosing Intermittent API Failures

Aggregate many `/api/search` calls, group by status, then diff a **503** against a **200** to spot header, body, or timing differences that explain “works most of the time.”

**Difficulty**: Intermediate | **Time**: ~15 minutes | **Features used**: SQL queries, Traffic diff, Body search, SSL interception | **Requires**: Free

## Scenario

Your `/api/search` endpoint returns **200** most of the time but occasionally **503**. Support tickets are vague; you cannot reproduce on demand. You need APXY to record a volume of real traffic from testers or staging, then use SQL to quantify how often each status appears and pull concrete **500-series** rows for side-by-side comparison with successes.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

### Step 1: Run an extended soak

**Tell your agent:**

> "I'll run searches, filters, and background polling for several minutes—or run a load script—while the proxy captures everything to api.myapp.com."

Encourage varied query strings and auth states so failures are not all identical.

### Step 2: Group by status for the flaky path

**Tell your agent:**

> "How often does each HTTP status occur for URLs containing /api/search?"

**Your agent runs:**

```bash
apxy logs search --query /api/search --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```

Agent reports:

```
200   184
503   12
499   2
```

That ratio turns “sometimes” into a metric you can attach to a ticket.

### Step 3: List failing rows with identifiers

**Tell your agent:**

> "Give me ids, status, and duration for 503s on that path."

**Your agent runs:**

```bash
apxy logs search --query /api/search --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:20][] | {id, status_code, duration_ms}'
```

Pick one `id` as **FAIL_ID** and find a nearby **200** with similar query params (search `logs` by `url`).

### Step 4: Show full failure and success records

**Tell your agent:**

> "Show FAIL_ID and SUCCESS_ID in full."

**Your agent runs:**

```bash
apxy logs show --id <FAIL_ID>
apxy logs show --id <SUCCESS_ID>
```

Agent compares:

- Request: same `Authorization`? same query string? different `Idempotency-Key`?
- Response: `retry-after`, provider error JSON, HTML error pages from a gateway
- Timing: spikes on failures (timeouts morphing into **503**)

### Step 5: Diff request line and body only

**Tell your agent:**

> "Diff only the request portions—ignore response noise for a first pass."

**Your agent runs:**

```bash
apxy logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope request
```

If requests match byte-for-byte, the flakiness is likely upstream (load balancer, DB replica lag). If they differ (e.g. `cursor` or `page` param), you may have a data-dependent bug.

### Step 6: Diff responses when requests match

**Tell your agent:**

> "If requests matched, diff responses."

**Your agent runs:**

```bash
apxy logs diff --id-a <FAIL_ID> --id-b <SUCCESS_ID> --scope response
```

Agent surfaces error message fields or empty bodies typical of gateway resets.

### Step 7: Search for provider fingerprints

**Tell your agent:**

> "Search bodies for 'upstream' or our error codes."

**Your agent runs:**

```bash
apxy logs search-bodies --pattern "upstream" --scope response --limit 10
```

Adjust pattern to your stack.

---

## Track B: Web UI Workflow

### Step 1: Capture window

Open **http://localhost:8082**. Confirm proxy running on the dashboard. Go to **Traffic** and reproduce searches for several minutes.

> screenshots/01-traffic-soak.png

### Step 2: Filter path mentally or via search

Locate rows whose URL contains `/api/search`. Note color or status badges for **503**.

> screenshots/02-filter-search-path.png

### Step 3: Stats (if available)

Go to **Traffic** -> **Stats** (or summary widgets)—distribution of status codes for the session.

> screenshots/03-status-distribution.png

### Step 4: Open a 503

**Traffic** -> click the 503 row -> **Response** tab for body, **Timing** tab (did it run full duration or cut off early?).

> screenshots/04-503-detail.png

### Step 5: Open a nearby 200

**Traffic** -> click a nearby 200 row with same params if possible -> **Request** tab. Compare side by side.

> screenshots/05-200-vs-503-compare.png

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — Capturing enough volume for intermittent bugs
- 3:00 — SQL `GROUP BY status_code` pattern
- 6:00 — `diff` with `--scope request` then `response`
- 9:00 — Web UI correlation

---

## What You Learned

- Quantifying flakiness with `GROUP BY status_code` on `traffic_logs`
- Selecting concrete failure rows with SQL (`id`, `duration_ms`)
- Using `apxy logs diff` to separate “bad request” from “bad infrastructure”
- Optional `search-bodies` to grep captured responses for error tokens

## Next Steps

- [Debug Slow API](../debug-slow-api/) — When failures correlate with timeouts/slowness
- [Replay and Diff](../../replay-and-diff/) — Replay a captured 503 after fixes
- [Basic Debugging](../../basic-debugging/) — Refresh capture/inspect basics
