# Remove `apxy sql query` from Documentation

**Date:** 2026-05-01
**Status:** Approved

## Problem

`apxy sql query` is being removed from the product. All documentation and examples that reference it must be updated to use existing commands, or flagged for a keep/remove decision.

## Scope

12 files, ~37 occurrences across:
- `docs/user-guide.md`
- `examples/basic-debugging/README.md`
- `examples/debugging/debug-slow-api/README.md`
- `examples/debugging/debug-flaky-api/README.md`
- `examples/getting-started/web-ui-tour/README.md`
- `examples/replay-and-diff/regression-testing-with-diff/README.md`
- `examples/ai-agent/agent-diagnose-api-performance/README.md`
- `examples/ai-agent/agent-debug-500-errors/README.md`
- `examples/ai-agent/agent-setup-test-environment/README.md`
- `skills/apxy/SKILL.md`
- `skills/apxy/references/cli-overview.md`
- `skills/apxy/references/debugging.md`

## Replacement Strategy

No new commands are being added. Replacements use only existing commands.

### Tier 1 — Simple lookups
Replace with `apxy logs search --query <term>`.

Example:
```bash
# Before
apxy sql query "SELECT id, method, url, status_code FROM traffic_logs WHERE host = 'api.myapp.com' LIMIT 20"

# After
apxy logs search --query api.myapp.com --limit 20
```

### Tier 2 — Aggregations
Replace with `apxy logs list --format json | jq` or `apxy logs search --format json | jq`.

Canonical jq patterns:

```bash
# Count by status code
apxy logs list --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'

# Slowest endpoints by average latency
apxy logs list --format json | jq '[group_by(.url)[] | {url: .[0].url, n: length, avg_ms: (map(.duration_ms) | add / length | round), max_ms: (map(.duration_ms) | max)}] | sort_by(-.avg_ms) | .[:10]'

# Error rate by host
apxy logs list --format json | jq '[group_by(.host)[] | {host: .[0].host, total: length, errors: (map(select(.status_code >= 400)) | length)}]'

# All 5xx errors
apxy logs list --format json | jq '[.[] | select(.status_code >= 500)] | sort_by(-.id) | .[:20][] | {id, method, path, status_code, duration_ms}'

# Group by host + path + method
apxy logs list --format json | jq '[group_by(.host, .path, .method)[] | {host: .[0].host, path: .[0].path, method: .[0].method, cnt: length}] | sort_by(-.cnt) | .[:20]'

# Requests slower than threshold
apxy logs list --format json | jq '[.[] | select(.duration_ms > 2000)] | sort_by(-.duration_ms) | .[:10][] | {method, url, duration_ms, status_code}'

# Status breakdown for a specific endpoint
apxy logs search --query /api/search --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'
```

### Tier 3 — No clean replacement (flag for user decision)

These SQL queries have no clean equivalent using existing commands:

1. **Requests per minute** — requires `strftime` time bucketing, no jq equivalent
   ```sql
   SELECT strftime('%Y-%m-%d %H:%M', timestamp) AS minute, COUNT(*) AS rpm FROM traffic_logs GROUP BY minute ORDER BY minute DESC LIMIT 30
   ```

2. **Large response bodies** — `response_body` field availability in `logs list` output is uncertain
   ```sql
   SELECT id, method, url, status_code, length(response_body) AS body_bytes FROM traffic_logs WHERE length(response_body) > 100000 ORDER BY body_bytes DESC LIMIT 10
   ```

3. **P95 latency (percentile)** in `agent-diagnose-api-performance/README.md`
   ```sql
   SELECT duration_ms FROM traffic_logs WHERE url LIKE '%/api/search%' ORDER BY duration_ms DESC LIMIT 1 OFFSET (SELECT COUNT(*) / 20 FROM traffic_logs WHERE url LIKE '%/api/search%')
   ```

User will decide whether to remove each Tier 3 example or keep it in another form.

## Per-File Changes

### `docs/user-guide.md`
- Replace `### SQL Queries` section with `### Traffic Analysis with jq` showing host-count and slow-request patterns.

### `examples/basic-debugging/README.md`
- Replace `### 4. Analyze with SQL` step with jq equivalents for status-code count and slowest request.

### `examples/debugging/debug-slow-api/README.md`
- Replace SQL block (sort by duration) with jq equivalent.
- Update inline text mention on line 166.

### `examples/debugging/debug-flaky-api/README.md`
- Replace both SQL blocks (status breakdown, 5xx filter) with jq equivalents using `apxy logs search`.

### `examples/getting-started/web-ui-tour/README.md`
- Replace SQL block (count by status code) with jq equivalent.

### `examples/replay-and-diff/regression-testing-with-diff/README.md`
- Replace SQL lookup with `apxy logs search --query api.myapp.com --limit 20`.

### `examples/ai-agent/agent-diagnose-api-performance/README.md`
- Replace 5 of 6 SQL queries with jq equivalents.
- Flag the P95 percentile query (Tier 3) for user decision.

### `examples/ai-agent/agent-debug-500-errors/README.md`
- Replace both SQL queries (5xx filter, group by path+status) with jq equivalents.

### `examples/ai-agent/agent-setup-test-environment/README.md`
- Replace SQL query (group by host+mocked) with jq equivalent.

### `skills/apxy/SKILL.md`
- Remove `SQL queries (\`apxy sql query\`)` from the Pro feature row.

### `skills/apxy/references/cli-overview.md`
- Remove `apxy sql query` table row.
- Remove entire `## SQL Schema Reference` section.

### `skills/apxy/references/debugging.md`
- Remove Pro license note referencing `apxy sql query`.
- Remove `apxy sql query` from critical ordering rule text (lines 15, 258).
- Remove `### SQL (1 command)` section from command table.
- Replace `## Common SQL Patterns` section with `## Common jq Patterns` using Tier 2 equivalents.
- Remove requests-per-minute and large-response-body patterns entirely (Tier 3, no replacement).
- Replace inline SQL examples in workflow steps (lines 276, 329, 333) with jq equivalents.
