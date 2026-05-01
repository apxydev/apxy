# AI Agent Analyzes Slow Endpoints

Latency problems hide in averages. Point your agent at APXY's traffic logs so it can rank URLs by mean and max duration, surface error hotspots, and focus on critical paths like search -- all from repeatable commands you can paste into runbooks.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Traffic inspection, SSL interception | **Requires**: Free

## Scenario

Your app is slow but you are not sure which API calls dominate wall time. Ask your agent to analyze APXY traffic logs using `jq` aggregations: average and max latency per URL, status breakdowns for 4xx/5xx, and a focused count/average/max for a critical path (for example `/api/search`). The agent returns a short performance profile you can act on (caching, N+1 removal, index fixes, or upstream timeouts).

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with the APXY skill installed (see [Using APXY as a Claude Code / Cursor Skill](../agent-skill-reference/))
- Enough captured traffic through the proxy to make aggregates meaningful (synthetic load or real usage)

### Plan note

All steps below use **`apxy logs`** commands available on the **Free** tier. No SQL or Pro features are required.

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

> APXY log entries include the fields **`url`**, **`path`**, **`host`**, **`method`**, **`status_code`**, and **`duration_ms`**. The `jq` commands below work against `apxy logs list --format json` output.

### Step 1: Baseline -- slowest URLs by average latency

**Tell your agent:**

> "Show the top 10 URLs by average duration_ms with call count and max latency so we see chronic slowness, not one-off spikes."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[group_by(.url)[] | {url: .[0].url, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:10]'
```

The agent interprets results: high **`avg_ms`** with large **`n`** is a priority; high **`max_ms`** with low **`n`** may be cold start or rare timeouts.

### Step 2: Error-weighted view -- which URLs return 4xx/5xx most

**Tell your agent:**

> "Group by url and status_code for status >= 400, ordered by how often each combination happens."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[.[] | select(.status_code >= 400)] | group_by(.url + " " + (.status_code | tostring)) | map({url: .[0].url, status_code: .[0].status_code, n: length}) | sort_by(-.n) | .[:20]'
```

The agent connects slow endpoints from Step 1 with error-heavy URLs here (retries, cascading failures).

### Step 3: Host-level sanity check (optional)

**Tell your agent:**

> "Break down average latency by host if we talk to more than api.myapp.com."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[group_by(.host)[] | {host: .[0].host, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:15]'
```

Useful when the browser or mobile app hits both your API and CDNs or third parties through the same proxy.

### Step 4: Focus on one product-critical path

**Tell your agent:**

> "Restrict analysis to URLs containing /api/search -- show count, average, max."

**Your agent runs:**

```bash
apxy logs search --query /api/search --format json | jq '{n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}'
```

### Step 5: Find the single slowest recent call (optional drill-down)

**Tell your agent:**

> "Give me id, method, url, duration_ms for the slowest request overall in the database."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[sort_by(-.duration_ms) | .[:5][] | {id, method, url, duration_ms, status_code}]'
```

### Step 6: Deep inspect a suspect record

**Tell your agent:**

> "Open record id 88 in full detail -- I want request size, response size, and timing context."

**Your agent runs:**

```bash
apxy logs show --id 88
```

### Step 7: Turn analysis into recommendations

**Tell your agent:**

> "Based on the analysis results, list the top three hypotheses (backend, network, payload size, N+1) and what we would change first."

No new APXY command is required; the agent synthesizes Steps 1--6 into engineering actions.

---

## Track B: Web UI Workflow

You can follow along in the Web UI: the **Traffic** table shows duration and status per row, which matches the per-request slice of what the `jq` aggregations produce. Sort by duration or filter by path to approximate Steps 1 and 4 without the terminal. Use the record detail view as the counterpart to **`apxy logs show`** when you click a slow row.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Agent + CLI: jq aggregation ladder, drill-down
- Web UI: sorting and filtering the traffic grid

---

## What You Learned

- How to profile APIs by grouping and sorting on **`duration_ms`** and **`status_code`** with `jq`
- How to pivot from aggregate analysis to **`apxy logs show`** on a specific **id**
- Where the Web UI gives a visual parallel to the same data

---

## Next Steps

- [Let Your AI Agent Find and Fix Server Errors](../agent-debug-500-errors/) -- when slowness correlates with 500s
- [Debugging Slow API](../../debugging/debug-slow-api/) -- human-led variant with more narrative
- [Replay and Diff](../../replay-and-diff/) -- prove latency fixes with before/after captures
