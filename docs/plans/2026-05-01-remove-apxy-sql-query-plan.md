# Remove `apxy sql query` from Documentation — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Remove all `apxy sql query` references from documentation and replace them with equivalent `apxy logs` + `jq` commands, flagging Tier 3 queries that have no clean replacement for user decision.

**Architecture:** Pure documentation edits across 12 files. No code changes. Each file is an independent task. Tier 3 queries (P95 percentile) are flagged at the end for a user keep/remove decision before that file is finalized.

**Tech Stack:** Markdown, bash, jq

---

### Task 1: docs/user-guide.md — Replace SQL Queries section

**Files:**
- Modify: `docs/user-guide.md:137-142`

**Step 1: Make the edit**

Replace:
```markdown
### SQL Queries

```bash
apxy sql query "SELECT host, COUNT(*) as cnt FROM traffic_logs GROUP BY host ORDER BY cnt DESC"
apxy sql query "SELECT method, url, duration_ms FROM traffic_logs WHERE duration_ms > 1000"
```
```

With:
```markdown
### Traffic Analysis with jq

```bash
# Count requests by host
apxy logs list --format json | jq '[group_by(.host)[] | {host: .[0].host, count: length}] | sort_by(-.count)'

# Find requests slower than 1000ms
apxy logs list --format json | jq '[.[] | select(.duration_ms > 1000)] | sort_by(-.duration_ms)[] | {method, url, duration_ms}'
```
```

**Step 2: Verify no sql query remains**

Run: `grep "apxy sql query" docs/user-guide.md`
Expected: no output

**Step 3: Commit**

```bash
git add docs/user-guide.md
git commit -m "docs: replace apxy sql query with jq in user-guide"
```

---

### Task 2: examples/basic-debugging/README.md — Replace Analyze with SQL step

**Files:**
- Modify: `examples/basic-debugging/README.md:43-51`

**Step 1: Make the edit**

Replace:
```markdown
### 4. Analyze with SQL

```bash
# Count requests by status code
apxy sql query "SELECT status_code, COUNT(*) FROM traffic_logs GROUP BY status_code"

# Find the slowest request
apxy sql query "SELECT method, url, duration_ms FROM traffic_logs ORDER BY duration_ms DESC LIMIT 1"
```
```

With:
```markdown
### 4. Analyze traffic with jq

```bash
# Count requests by status code
apxy logs list --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'

# Find the slowest request
apxy logs list --format json | jq 'sort_by(-.duration_ms) | .[0] | {method, url, duration_ms}'
```
```

**Step 2: Verify**

Run: `grep "apxy sql query" examples/basic-debugging/README.md`
Expected: no output

**Step 3: Commit**

```bash
git add examples/basic-debugging/README.md
git commit -m "docs: replace apxy sql query with jq in basic-debugging example"
```

---

### Task 3: examples/debugging/debug-slow-api/README.md — Replace SQL block and text mention

**Files:**
- Modify: `examples/debugging/debug-slow-api/README.md:49-55` (SQL block)
- Modify: `examples/debugging/debug-slow-api/README.md:166` (text mention)

**Step 1: Replace the SQL block**

Replace:
```markdown
> "Run SQL to list the 10 slowest captured requests by duration_ms."

**Your agent runs:**

```bash
apxy sql query "SELECT method, url, status_code, duration_ms FROM traffic_logs ORDER BY duration_ms DESC LIMIT 10"
```
```

With:
```markdown
> "List the 10 slowest captured requests by duration_ms."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[sort_by(-.duration_ms) | .[:10][] | {method, url, status_code, duration_ms}]'
```
```

**Step 2: Replace the text mention on line 166**

Replace:
```markdown
- Using `apxy sql query` with `traffic_logs.duration_ms` to rank real user-driven traffic
```

With:
```markdown
- Using `apxy logs list --format json | jq` with `.duration_ms` to rank real user-driven traffic
```

**Step 3: Verify**

Run: `grep "apxy sql query" examples/debugging/debug-slow-api/README.md`
Expected: no output

**Step 4: Commit**

```bash
git add examples/debugging/debug-slow-api/README.md
git commit -m "docs: replace apxy sql query with jq in debug-slow-api example"
```

---

### Task 4: examples/debugging/debug-flaky-api/README.md — Replace both SQL blocks

**Files:**
- Modify: `examples/debugging/debug-flaky-api/README.md:49-55` (Step 2 SQL)
- Modify: `examples/debugging/debug-flaky-api/README.md:72-77` (Step 3 SQL)
- Modify: `examples/debugging/debug-flaky-api/README.md:79` (text mention)

**Step 1: Replace Step 2 SQL block**

Replace:
```markdown
> "How often does each HTTP status occur for URLs containing /api/search?"

**Your agent runs:**

```bash
apxy sql query "SELECT status_code, COUNT(*) AS count FROM traffic_logs WHERE url LIKE '%/api/search%' GROUP BY status_code ORDER BY count DESC"
```
```

With:
```markdown
> "How often does each HTTP status occur for URLs containing /api/search?"

**Your agent runs:**

```bash
apxy logs search --query /api/search --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```
```

**Step 2: Replace Step 3 SQL block**

Replace:
```markdown
> "Give me ids, status, and duration for 503s on that path."

**Your agent runs:**

```bash
apxy sql query "SELECT id, status_code, duration_ms FROM traffic_logs WHERE url LIKE '%/api/search%' AND status_code >= 500 ORDER BY id DESC LIMIT 20"
```
```

With:
```markdown
> "Give me ids, status, and duration for 503s on that path."

**Your agent runs:**

```bash
apxy logs search --query /api/search --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:20][] | {id, status_code, duration_ms}'
```
```

**Step 3: Update text mention on line 79**

Replace:
```markdown
Pick one `id` as **FAIL_ID** and find a nearby **200** with similar query params (search `logs` or SQL on `url`).
```

With:
```markdown
Pick one `id` as **FAIL_ID** and find a nearby **200** with similar query params (search `logs` by `url`).
```

**Step 4: Verify**

Run: `grep "apxy sql query" examples/debugging/debug-flaky-api/README.md`
Expected: no output

**Step 5: Commit**

```bash
git add examples/debugging/debug-flaky-api/README.md
git commit -m "docs: replace apxy sql query with jq in debug-flaky-api example"
```

---

### Task 5: examples/getting-started/web-ui-tour/README.md — Replace SQL block

**Files:**
- Modify: `examples/getting-started/web-ui-tour/README.md:107-113`

**Step 1: Make the edit**

Replace:
```markdown
> "Run a SQL query to count requests grouped by status code."

Your agent runs:

```bash
apxy sql query "SELECT status_code, COUNT(*) AS count FROM traffic_logs GROUP BY status_code ORDER BY count DESC"
```
```

With:
```markdown
> "Count requests grouped by status code."

Your agent runs:

```bash
apxy logs list --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```
```

**Step 2: Verify**

Run: `grep "apxy sql query" examples/getting-started/web-ui-tour/README.md`
Expected: no output

**Step 3: Commit**

```bash
git add examples/getting-started/web-ui-tour/README.md
git commit -m "docs: replace apxy sql query with jq in web-ui-tour example"
```

---

### Task 6: examples/replay-and-diff/regression-testing-with-diff/README.md — Replace lookup with logs search

**Files:**
- Modify: `examples/replay-and-diff/regression-testing-with-diff/README.md:57-68`

**Step 1: Make the edit**

Replace:
```markdown
> "Show me up to 20 captured traffic records for api.myapp.com: id, URL, and
> status. I want to pick endpoints to regression-test."

**Your agent runs:**

```bash
apxy sql query "SELECT id, method, url, status_code FROM traffic_logs WHERE host = 'api.myapp.com' LIMIT 20"
```

Note the record IDs you care about (for example `1` for `GET /api/users` and
`5` for `POST /api/orders`). Adjust the `WHERE` clause if you need a path
prefix, method filter, or time window.
```

With:
```markdown
> "Show me up to 20 captured traffic records for api.myapp.com: id, URL, and
> status. I want to pick endpoints to regression-test."

**Your agent runs:**

```bash
apxy logs search --query api.myapp.com --limit 20
```

Note the record IDs you care about (for example `1` for `GET /api/users` and
`5` for `POST /api/orders`). Use `apxy logs list --format json | jq` if you need to filter by path prefix, method, or time window.
```

**Step 2: Verify**

Run: `grep "apxy sql query" examples/replay-and-diff/regression-testing-with-diff/README.md`
Expected: no output

**Step 3: Commit**

```bash
git add examples/replay-and-diff/regression-testing-with-diff/README.md
git commit -m "docs: replace apxy sql query with logs search in regression-testing example"
```

---

### Task 7: examples/ai-agent/agent-debug-500-errors/README.md — Replace both SQL blocks

**Files:**
- Modify: `examples/ai-agent/agent-debug-500-errors/README.md:49-55` (Step 1)
- Modify: `examples/ai-agent/agent-debug-500-errors/README.md:101-111` (Step 5)

**Step 1: Replace Step 1 SQL block**

Replace:
```markdown
> "Use APXY's read-only SQL to list recent requests with status 500 or higher for api.myapp.com. I want id, method, full url, status, and duration_ms, newest first."

**Your agent runs:**

```bash
apxy sql query "SELECT id, method, url, status_code, duration_ms FROM traffic_logs WHERE status_code >= 500 ORDER BY id DESC LIMIT 50"
```
```

With:
```markdown
> "List recent requests with status 500 or higher. I want id, method, full url, status, and duration_ms, newest first."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:50][] | {id, method, url, status_code, duration_ms}'
```
```

**Step 2: Replace Step 5 prompt and SQL block**

Replace:
```markdown
> "Run SQL again to see if other 500s share the same path or host, and summarize whether this looks like one bug or many."

**Your agent runs:**

```bash
apxy sql query "SELECT path, status_code, COUNT(*) AS n FROM traffic_logs WHERE status_code >= 500 GROUP BY path, status_code ORDER BY n DESC"
```
```

With:
```markdown
> "Check if other 500s share the same path or host, and summarize whether this looks like one bug or many."

**Your agent runs:**

```bash
apxy logs list --format json | jq '[.[] | select(.status_code >= 500)] | group_by(.path) | map({path: .[0].path, status_code: .[0].status_code, n: length}) | sort_by(-.n)'
```
```

**Step 3: Verify**

Run: `grep "apxy sql query" examples/ai-agent/agent-debug-500-errors/README.md`
Expected: no output

**Step 4: Commit**

```bash
git add examples/ai-agent/agent-debug-500-errors/README.md
git commit -m "docs: replace apxy sql query with jq in agent-debug-500-errors example"
```

---

### Task 8: examples/ai-agent/agent-setup-test-environment/README.md — Remove optional SQL block

**Files:**
- Modify: `examples/ai-agent/agent-setup-test-environment/README.md:154-159`

**Step 1: Make the edit**

Remove the entire optional SQL block (keep surrounding content intact):
```markdown
Optional SQL sanity check when licensed:

```bash
apxy sql query "SELECT host, mocked, COUNT(*) FROM traffic_logs GROUP BY host, mocked"
```
```

Delete those 5 lines entirely. The paragraph before (`apxy logs search --query "users"`) and the heading after (`### Step 8: Document teardown for the team`) should remain adjacent.

**Step 2: Verify**

Run: `grep "apxy sql query" examples/ai-agent/agent-setup-test-environment/README.md`
Expected: no output

**Step 3: Commit**

```bash
git add examples/ai-agent/agent-setup-test-environment/README.md
git commit -m "docs: remove optional apxy sql query block from agent-setup-test-environment example"
```

---

### Task 9: examples/ai-agent/agent-diagnose-api-performance/README.md — Replace 5 SQL blocks, flag P95

**Files:**
- Modify: `examples/ai-agent/agent-diagnose-api-performance/README.md`

**Step 1: Replace Step 1 SQL (top 10 by avg latency)**

Replace:
```markdown
```bash
apxy sql query "SELECT url, COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs GROUP BY url ORDER BY avg_ms DESC LIMIT 10"
```
```

With:
```markdown
```bash
apxy logs list --format json | jq '[group_by(.url)[] | {url: .[0].url, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:10]'
```
```

**Step 2: Replace Step 2 SQL (errors by url + status_code)**

Replace:
```markdown
```bash
apxy sql query "SELECT url, status_code, COUNT(*) AS n FROM traffic_logs WHERE status_code >= 400 GROUP BY url, status_code ORDER BY n DESC LIMIT 20"
```
```

With:
```markdown
```bash
apxy logs list --format json | jq '[.[] | select(.status_code >= 400)] | group_by(.url + " " + (.status_code | tostring)) | map({url: .[0].url, status_code: .[0].status_code, n: length}) | sort_by(-.n) | .[:20]'
```
```

**Step 3: Replace Step 3 SQL (avg latency by host)**

Replace:
```markdown
```bash
apxy sql query "SELECT host, COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs GROUP BY host ORDER BY avg_ms DESC LIMIT 15"
```
```

With:
```markdown
```bash
apxy logs list --format json | jq '[group_by(.host)[] | {host: .[0].host, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:15]'
```
```

**Step 4: Replace Step 4 SQL (count/avg/max for /api/search)**

Replace:
```markdown
```bash
apxy sql query "SELECT COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs WHERE url LIKE '%/api/search%'"
```
```

With:
```markdown
```bash
apxy logs search --query /api/search --format json | jq '{n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}'
```
```

**Step 5: FLAG Step 5 (P95 percentile) — present to user before editing**

Step 5 of this example is the P95 latency calculation using a SQL subquery OFFSET. There is no clean jq equivalent. Before making any edit here, show the user the following block and ask whether to remove the entire Step 5 section or keep it in another form:

```markdown
### Step 5: Approximate P95 latency for /api/search

SQLite does not ship a built-in percentile function in all environments; a practical pattern is **sort descending by duration** and **`LIMIT 1 OFFSET`** roughly **`COUNT/20`** (about the slowest 5% tail when **`n`** is large).

**Tell your agent:**

> "Approximate P95 duration for /api/search using ORDER BY duration_ms DESC with OFFSET based on count/20."

**Your agent runs:**

```bash
apxy sql query "SELECT duration_ms FROM traffic_logs WHERE url LIKE '%/api/search%' ORDER BY duration_ms DESC LIMIT 1 OFFSET (SELECT COUNT(*) / 20 FROM traffic_logs WHERE url LIKE '%/api/search%')"
```

The agent explains caveats: small **`n`** makes this unstable; for tiny samples, report min/max/mean instead of pretending P95 is precise.
```

Wait for user decision before proceeding with this step.

**Step 6: Replace Step 6 SQL (slowest 5 requests)**

Replace:
```markdown
```bash
apxy sql query "SELECT id, method, url, duration_ms, status_code FROM traffic_logs ORDER BY duration_ms DESC LIMIT 5"
```
```

With:
```markdown
```bash
apxy logs list --format json | jq '[sort_by(-.duration_ms) | .[:5][] | {id, method, url, duration_ms, status_code}]'
```
```

**Step 7: Verify (after Tier 3 decision is made)**

Run: `grep "apxy sql query" examples/ai-agent/agent-diagnose-api-performance/README.md`
Expected: no output (or one remaining occurrence if user chose to keep Step 5)

**Step 8: Commit**

```bash
git add examples/ai-agent/agent-diagnose-api-performance/README.md
git commit -m "docs: replace apxy sql query with jq in agent-diagnose-api-performance example"
```

---

### Task 10: skills/apxy/SKILL.md — Remove SQL from Pro tier

**Files:**
- Modify: `skills/apxy/SKILL.md:32-35`

**Step 1: Update Pro tier row**

Replace:
```markdown
| **Pro** | SQL queries (`apxy sql query`), breakpoints, network simulation (`apxy network`), scripts (`apxy script`) |
```

With:
```markdown
| **Pro** | Breakpoints, network simulation (`apxy network`), scripts (`apxy script`) |
```

**Step 2: Remove the "Instead of SQL" free alternative bullet**

Replace:
```markdown
**Free alternatives when Pro isn't available:**
- Instead of SQL → use `apxy logs search` + `jq` filters
- Instead of breakpoints → add a temporary mock rule to intercept the request
- Instead of network simulation → use mock `--delay` flag on a specific rule
```

With:
```markdown
**Free alternatives when Pro isn't available:**
- Instead of breakpoints → add a temporary mock rule to intercept the request
- Instead of network simulation → use mock `--delay` flag on a specific rule
```

**Step 3: Verify**

Run: `grep "apxy sql query" skills/apxy/SKILL.md`
Expected: no output

**Step 4: Commit**

```bash
git add skills/apxy/SKILL.md
git commit -m "docs: remove apxy sql query from Pro tier in SKILL.md"
```

---

### Task 11: skills/apxy/references/cli-overview.md — Remove SQL row and SQL Schema Reference

**Files:**
- Modify: `skills/apxy/references/cli-overview.md:130` (table row)
- Modify: `skills/apxy/references/cli-overview.md:197-203` (SQL Schema Reference section)

**Step 1: Remove the SQL table row**

Delete this line entirely:
```markdown
| `apxy sql query "<SQL>"` | Run read-only SQL query | Tables: `traffic_logs`, `mock_rules` |
```

**Step 2: Remove the SQL Schema Reference section**

Delete these lines entirely:
```markdown
## SQL Schema Reference

The `apxy sql query` command supports read-only SELECT queries against these tables:

**traffic_logs**: `id`, `timestamp`, `method`, `url`, `host`, `path`, `status_code`, `duration_ms`, `tls`, `mocked`, request/response headers and bodies.

**mock_rules**: `id`, `name`, `priority`, `active`, `url_pattern`, `match_type`, `method`, and rule configuration fields.
```

**Step 3: Verify**

Run: `grep "apxy sql query" skills/apxy/references/cli-overview.md`
Expected: no output

**Step 4: Commit**

```bash
git add skills/apxy/references/cli-overview.md
git commit -m "docs: remove apxy sql query row and SQL schema reference from cli-overview"
```

---

### Task 12: skills/apxy/references/debugging.md — Major overhaul

This is the most involved file. Make changes in order.

**Files:**
- Modify: `skills/apxy/references/debugging.md`

**Step 1: Remove the "Note: SQL Requires Pro" section (lines 5-7)**

Delete these lines entirely:
```markdown
## Note: SQL Requires Pro

`apxy sql query` requires a Pro license. On Free, use `apxy logs search --query <term> --format json | jq <filter>` for equivalent spot-checking. All other commands in this file are available on Free.
```

**Step 2: Update the Critical ordering rule (line 15)**

Replace:
```markdown
**Critical ordering rule:** Your first traffic command must always be `apxy logs search` or `apxy logs list`. Do not run `apxy logs stats` or `apxy sql query` as your first traffic command — those are analysis tools that come after you've used search or list to locate specific records. Even when checking license status beforehand, ensure the first actual traffic inspection command is `search` or `list`.
```

With:
```markdown
**Critical ordering rule:** Your first traffic command must always be `apxy logs search` or `apxy logs list`. Do not run `apxy logs stats` as your first traffic command — it is an analysis tool that comes after you've used search or list to locate specific records. Even when checking license status beforehand, ensure the first actual traffic inspection command is `search` or `list`.
```

**Step 3: Update the Correlate step description (line 20)**

Replace:
```markdown
4. **Correlate** — diff two records, aggregate with SQL, or search bodies for patterns — **always complete this step; even when the issue is obvious from inspect, diffing a failing vs successful record confirms the diagnosis and reveals related patterns**
```

With:
```markdown
4. **Correlate** — diff two records, aggregate with jq, or search bodies for patterns — **always complete this step; even when the issue is obvious from inspect, diffing a failing vs successful record confirms the diagnosis and reveals related patterns**
```

**Step 4: Remove the SQL command table section**

Delete these lines:
```markdown
### SQL (1 command)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy sql query "<SQL>"` | Run read-only SQL against SQLite | Tables: `traffic_logs`, `mock_rules` |
```

**Step 5: Replace Common SQL Patterns section with Common jq Patterns**

Replace the entire `## Common SQL Patterns` section (from the heading through the last SQL block) with:

```markdown
## Common jq Patterns

Count requests by status code:

```bash
apxy logs list --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```

Slowest endpoints by average latency:

```bash
apxy logs list --format json | jq '[group_by(.url)[] | {url: .[0].url, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:10]'
```

Error rate by host:

```bash
apxy logs list --format json | jq '[group_by(.host)[] | {host: .[0].host, total: length, errors: (map(select(.status_code >= 400)) | length)}]'
```

All 5xx errors with method and path:

```bash
apxy logs list --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:20][] | {id, method, path, status_code, duration_ms}'
```

Group by host + path + method:

```bash
apxy logs list --format json | jq '[group_by(.host, .path, .method)[] | {host: .[0].host, path: .[0].path, method: .[0].method, cnt: length}] | sort_by(-.cnt) | .[:20]'
```

Requests slower than a threshold (e.g. 2000ms):

```bash
apxy logs list --format json | jq '[.[] | select(.duration_ms > 2000)] | sort_by(-.duration_ms) | .[:10][] | {method, url, duration_ms, status_code}'
```

Status breakdown for a flaky endpoint:

```bash
apxy logs search --query /api/search --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```
```

**Step 6: Update the "Order matters" note in Slow API Endpoints section (line 258)**

Replace:
```markdown
**⚠️ Order matters:** Your first traffic command must be `apxy logs search` or `apxy logs list`. Do not start with `apxy logs stats` or `apxy sql query` — run those only after the initial search/list step.
```

With:
```markdown
**⚠️ Order matters:** Your first traffic command must be `apxy logs search` or `apxy logs list`. Do not start with `apxy logs stats` — run that only after the initial search/list step.
```

**Step 7: Replace optional SQL step in Slow API Endpoints (lines 274-277)**

Replace:
```markdown
3. **Optionally:** if Pro is available and you need latency rankings across all endpoints:
   ```bash
   apxy sql query "SELECT url, COUNT(*) AS n, AVG(duration_ms) AS avg_ms, MAX(duration_ms) AS max_ms FROM traffic_logs GROUP BY url ORDER BY avg_ms DESC LIMIT 10"
   ```
```

With:
```markdown
3. **Optionally:** for latency rankings across all endpoints:
   ```bash
   apxy logs list --format json | jq '[group_by(.url)[] | {url: .[0].url, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:10]'
   ```
```

**Step 8: Replace both SQL steps in Flaky / Intermittent API Errors section (lines 327-333)**

Replace:
```markdown
1. Capture a volume of traffic, then quantify failure rate:
   ```bash
   apxy sql query "SELECT status_code, COUNT(*) AS count FROM traffic_logs WHERE url LIKE '%/api/search%' GROUP BY status_code ORDER BY count DESC"
   ```
2. List failing rows with IDs:
   ```bash
   apxy sql query "SELECT id, status_code, duration_ms FROM traffic_logs WHERE url LIKE '%/api/search%' AND status_code >= 500 ORDER BY id DESC LIMIT 20"
   ```
```

With:
```markdown
1. Capture a volume of traffic, then quantify failure rate:
   ```bash
   apxy logs search --query /api/search --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
   ```
2. List failing rows with IDs:
   ```bash
   apxy logs search --query /api/search --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:20][] | {id, status_code, duration_ms}'
   ```
```

**Step 9: Verify**

Run: `grep "apxy sql query" skills/apxy/references/debugging.md`
Expected: no output

**Step 10: Commit**

```bash
git add skills/apxy/references/debugging.md
git commit -m "docs: replace apxy sql query with jq patterns in debugging.md skill reference"
```

---

### Final verification

Run: `grep -r "apxy sql query" --include="*.md" .`
Expected: no output (or only the design doc in `docs/plans/`)
