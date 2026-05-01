# Finding and Fixing Slow API Endpoints

Rank captured requests by duration, open the slowest ones, then replay through the proxy to confirm improvements after you optimize code or queries.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: SQL queries, Request replay, Traffic diff, SSL interception | **Requires**: Free

## Scenario

Your web app feels sluggish: spinners hang, dashboards take seconds to paint. Support hears “the site is slow” but engineering needs facts—which `https://api.myapp.com` endpoints dominate latency, and are they slow on the wire or slow server-side? You want a top-N list from real traffic, not a one-off curl from a dev laptop.

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

### Step 1: Generate realistic traffic

**Tell your agent:**

> "I'll use the app normally while the proxy runs—pages, filters, exports—so we capture a representative mix of API calls."

No command required until capture exists.

### Step 2: Query the slowest requests with SQL

**Tell your agent:**

> "List the 10 slowest captured requests by duration_ms."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[sort_by(-.duration_ms) | .[:10][] | {method, url, status_code, duration_ms}]'
```

Agent shows a table, for example:

```
GET   https://api.myapp.com/api/users?expand=orders   200   8420
GET   https://api.myapp.com/api/reports/summary     200   3100
POST  https://api.myapp.com/api/search              200   1200
```

Pick an ID from a follow-up `list` if needed, or note the URL to search.

### Step 3: Inspect the slowest record

**Tell your agent:**

> "Search for that slow URL and show the heaviest record in full."

**Your agent runs:**

```bash
apxy logs search --query "api.myapp.com/api/users" --limit 5
apxy logs show --id <SLOW_ID>
```

Agent reports response size, headers (`content-encoding`, pagination), and timing breakdown if available. Large JSON or N+1 patterns often show up as huge bodies or repeated parallel calls you can correlate with multiple rows.

### Step 4: Compose a focused request to retest

**Tell your agent:**

> "Send a fresh GET to the slow endpoint through the proxy to measure after a code change."

**Your agent runs:**

```bash
apxy tools request compose --method GET --url "https://api.myapp.com/api/users"
```

Agent prints status, timing, and a truncated body. Run again after deploy or DB index change.

### Step 5: Diff before and after captures

**Tell your agent:**

> "Compare record IDs from before and after optimization—request and response shape and timing."

**Your agent runs:**

```bash
apxy logs diff --id-a <BEFORE_ID> --id-b <AFTER_ID> --scope both
```

Agent highlights header and body differences. If only duration improved, bodies may match while user-visible performance still changes.

### Step 6 (optional): Replay the captured slow request

**Tell your agent:**

> "Replay the original captured request through the live proxy."

**Your agent runs:**

```bash
apxy logs replay --id <SLOW_ID> --port 8080
```

Use your actual proxy port if not `8080`.

---

## Track B: Web UI Workflow

### Step 1: Start proxy and open Traffic

Open **http://localhost:8082**. Go to **Traffic**. Confirm new rows appear as you drive the app.

> screenshots/01-traffic-live.png

### Step 2: Sort by duration

Use the column sort on **Duration** (or equivalent) so the slowest calls rise to the top. Identify `api.myapp.com` rows.

> screenshots/02-sort-by-duration.png

### Step 3: Open a slow row

**Traffic** -> click the slowest request -> **Timing** tab (TLS, TTFB, total), **Response** tab for size, and status.

> screenshots/03-slow-request-timing.png

### Step 4: Use Compose (if exposed in UI)

Go to **Tools** -> **Compose**, paste the URL, send **GET**, compare duration to the captured row.

> screenshots/04-compose-retest.png

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — `traffic sql query` for top slow URLs
- 3:00 — Deep dive with `logs show` and replay/compose
- 5:30 — Web UI sort and timing panel

---

## What You Learned

- Using `apxy logs list --format json | jq` with `.duration_ms` to rank real user-driven traffic
- Connecting aggregate slowness to a single `apxy logs show` story (body size, status, timing)
- Retesting with `apxy tools request compose` and comparing runs via `apxy logs diff`
- Optional `replay` for byte-for-byte reproduction of a slow call

## Next Steps

- [Replay and Diff](../../replay-and-diff/) — Systematic before/after verification
- [Debug Flaky API](../debug-flaky-api/) — When slowness is intermittent, not monotonic
- [AI Agent Workflow](../../ai-agent-workflow/) — Deeper agent + SQL patterns
