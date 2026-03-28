# AI Agent Analyzes Slow Endpoints

Latency problems hide in averages. Point your agent at APXY's SQLite-backed traffic store so it can rank URLs by mean and max duration, surface error hotspots, and approximate tail latency (P95) for paths like search -- all from repeatable queries you can paste into runbooks.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: SQL queries, Traffic inspection, SSL interception | **Requires**: Free

## Scenario

Your app is slow but you are not sure which API calls dominate wall time. Ask your agent to analyze APXY traffic using SQL aggregations: average and max latency per URL, status breakdowns for 4xx/5xx, and a percentile-style query for a critical path (for example `/api/search`). The agent returns a short performance profile you can act on (caching, N+1 removal, index fixes, or upstream timeouts).

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with the APXY skill installed (see [Using APXY as a Claude Code / Cursor Skill](../agent-skill-reference/))
- Enough captured traffic through the proxy to make aggregates meaningful (synthetic load or real usage)

### Plan note

In licensed APXY builds, **`apxy traffic sql`** is a **Pro** feature. If you are on **Free**, have the agent use **`apxy traffic logs search`** plus **`apxy traffic logs show`** for spot checks, or upgrade per [apxy.dev pricing](https://apxy.dev/#pricing). The queries below are still the canonical shape when SQL is available.

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

> The APXY database table for captures is **`traffic_logs`**. Key columns include **`url`**, **`path`**, **`host`**, **`method`**, **`status_code`**, and **`duration_ms`**.

### Step 1: Baseline -- slowest URLs by average latency

**Tell your agent:**

> "Show the top 10 URLs by average duration_ms with call count and max latency so we see chronic slowness, not one-off spikes."

**Your agent runs:**

```bash
apxy traffic sql query "SELECT url, COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs GROUP BY url ORDER BY avg_ms DESC LIMIT 10"
```

The agent interprets results: high **`avg_ms`** with large **`n`** is a priority; high **`max_ms`** with low **`n`** may be cold start or rare timeouts.

### Step 2: Error-weighted view -- which URLs return 4xx/5xx most

**Tell your agent:**

> "Group by url and status_code for status >= 400, ordered by how often each combination happens."

**Your agent runs:**

```bash
apxy traffic sql query "SELECT url, status_code, COUNT(*) AS n FROM traffic_logs WHERE status_code >= 400 GROUP BY url, status_code ORDER BY n DESC LIMIT 20"
```

The agent connects slow endpoints from Step 1 with error-heavy URLs here (retries, cascading failures).

### Step 3: Host-level sanity check (optional)

**Tell your agent:**

> "Break down average latency by host if we talk to more than api.myapp.com."

**Your agent runs:**

```bash
apxy traffic sql query "SELECT host, COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs GROUP BY host ORDER BY avg_ms DESC LIMIT 15"
```

Useful when the browser or mobile app hits both your API and CDNs or third parties through the same proxy.

### Step 4: Focus on one product-critical path

**Tell your agent:**

> "Restrict analysis to URLs containing /api/search -- show count, average, max."

**Your agent runs:**

```bash
apxy traffic sql query "SELECT COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs WHERE url LIKE '%/api/search%'"
```

### Step 5: Approximate P95 latency for /api/search

SQLite does not ship a built-in percentile function in all environments; a practical pattern is **sort descending by duration** and **`LIMIT 1 OFFSET`** roughly **`COUNT/20`** (about the slowest 5% tail when **`n`** is large).

**Tell your agent:**

> "Approximate P95 duration for /api/search using ORDER BY duration_ms DESC with OFFSET based on count/20."

**Your agent runs:**

```bash
apxy traffic sql query "SELECT duration_ms FROM traffic_logs WHERE url LIKE '%/api/search%' ORDER BY duration_ms DESC LIMIT 1 OFFSET (SELECT COUNT(*) / 20 FROM traffic_logs WHERE url LIKE '%/api/search%')"
```

The agent explains caveats: small **`n`** makes this unstable; for tiny samples, report min/max/mean instead of pretending P95 is precise.

### Step 6: Find the single slowest recent call (optional drill-down)

**Tell your agent:**

> "Give me id, method, url, duration_ms for the slowest request overall in the database."

**Your agent runs:**

```bash
apxy traffic sql query "SELECT id, method, url, duration_ms, status_code FROM traffic_logs ORDER BY duration_ms DESC LIMIT 5"
```

### Step 7: Deep inspect a suspect record

**Tell your agent:**

> "Open record id 88 in full detail -- I want request size, response size, and timing context."

**Your agent runs:**

```bash
apxy traffic logs show --id 88
```

### Step 8: Turn analysis into recommendations

**Tell your agent:**

> "Based on the SQL results, list the top three hypotheses (backend, network, payload size, N+1) and what we would change first."

No new APXY command is required; the agent synthesizes Steps 1--7 into engineering actions.

---

## Track B: Web UI Workflow

You can follow along in the Web UI: the **Traffic** table shows duration and status per row, which matches the per-request slice of what SQL aggregates. Sort by duration or filter by path to approximate Steps 1 and 4 without the terminal. For percentile intuition, sort slowest-first and eyeball the tail; the CLI query in Step 5 formalizes that when SQL is enabled. Use the record detail view as the counterpart to **`apxy traffic logs show`** when you click a slow row.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Agent + CLI: SQL aggregation ladder, P95 approximation, drill-down
- Web UI: sorting and filtering the traffic grid

---

## What You Learned

- How to profile APIs with **`GROUP BY url`** on **`duration_ms`** and **`status_code`**
- How a **DESC + LIMIT + OFFSET** pattern approximates tail latency without native **`percentile_cont`**
- How to pivot from aggregate SQL to **`apxy traffic logs show`** on a specific **id**
- Where the Web UI gives a visual parallel to the same data

---

## Next Steps

- [Let Your AI Agent Find and Fix Server Errors](../agent-debug-500-errors/) -- when slowness correlates with 500s
- [Debugging Slow API](../../debugging/debug-slow-api/) -- human-led variant with more narrative
- [Replay and Diff](../../replay-and-diff/) -- prove latency fixes with before/after captures
