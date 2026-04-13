# Replay & Diff -- Verify Fixes, Export, Regression Test

Ensure proxy is running: `apxy status`. Need existing captured traffic (at least 1 record): `apxy logs list --limit 1`.

## Core Loop

```
capture -> fix code -> replay -> diff -> prove the fix works
```

1. Traffic is captured while the bug is live (the "before" record).
2. You fix the code and restart the server.
3. Replay the original request to get a "after" record.
4. Diff the two records to see exactly what changed in the response.

## Commands

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy logs replay` | Replay one captured request against the live upstream | `--id` (record ID), `--port` (default 8080) |
| `apxy logs diff` | Compare two captured traffic records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy logs export-curl` | Export one traffic record as a reusable client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python) |
| `apxy logs export-har` | Export captured traffic as a HAR 1.2 file | `--file` (path, stdout if omitted), `--limit` (default 10000) |
| `apxy logs import-har` | Import traffic records from a HAR file | `--file` (HAR file path) |
| `apxy tools request compose` | Send a one-off HTTP request through the proxy | `--method` (default GET), `--url` (req), `--body`, `--headers` (JSON) |
| `apxy tools request batch` | Send multiple HTTP requests from a JSON file | `--file` (req), `--compare-history`, `--time-range` (min, default 60), `--timeout` (ms, default 10000), `--format` (json\|markdown\|toon) |
| `apxy tools request diagnose` | Diagnose endpoints using historical traffic records | `--file` (req), `--time-range` (min, default 60), `--match-mode` (exact\|contains\|prefix), `--format` (json\|markdown\|toon) |

## Export Formats

```bash
apxy logs export-curl --id <ID> --format <FORMAT>
```

| Format | Use Case |
|--------|----------|
| `curl` | Terminal replay, CI scripts, PR descriptions |
| `fetch` | Browser console, frontend debugging |
| `httpie` | Human-readable CLI alternative to curl |
| `python` | Python scripts, Jupyter notebooks, test suites |

Each format produces a ready-to-run snippet you can paste into a terminal, browser console, script, or PR description.

## Replay vs Compose

- **Replay** (`traffic logs replay --id <ID>`) re-sends the exact captured request (method, URL, headers, body) against the live upstream. Fastest way to reproduce.
- **Compose** (`tools request compose --method ... --url ... --body ...`) builds a new request from scratch. Use when you need to tweak headers or body before sending.

Both produce a new traffic record that can be diffed against the original.

## Diff Scopes

| Scope | What it compares |
|-------|-----------------|
| `request` | Method, URL, headers, body of the request |
| `response` | Status code, headers, body of the response |
| `both` | Full request and response (default) |

Use `--scope response` when verifying a fix -- you care about what the server returned, not what was sent.

## Batch Replay with History Comparison

```bash
apxy tools request batch --file ./requests.json --compare-history --time-range 60 --format json
```

The `--compare-history` flag replays every request in the JSON file and compares live results against historical traffic within `--time-range` minutes. Useful for regression testing multiple endpoints at once.

## Diagnose Endpoints

```bash
apxy tools request diagnose --file ./endpoints.json --time-range 120 --match-mode contains
```

Analyzes historical traffic for each endpoint in the file and produces a diagnostic report (error rates, latency percentiles, status code distribution).

## HAR Import/Export Details

HAR (HTTP Archive) is the standard format for sharing captured traffic between tools and team members.

**Export** captures up to `--limit` records (default 10000) into a HAR 1.2 file:

```bash
# Export to file
apxy logs export-har --file ./traffic.har --limit 5000

# Export to stdout (pipe to other tools)
apxy logs export-har
```

**Import** loads a HAR file into the current APXY traffic database:

```bash
apxy logs import-har --file ./colleague-traffic.har
```

After import, all records are available for replay, diff, SQL queries, and search -- just like locally captured traffic.

## Compose Request Details

Build and send a custom request through the proxy:

```bash
# Simple GET
apxy tools request compose --url "https://api.example.com/health"

# POST with body and headers
apxy tools request compose --method POST \
  --url "https://api.example.com/data" \
  --body '{"key":"value"}' \
  --headers '{"Authorization":"Bearer tok"}'
```

The response is captured as a new traffic record that can be diffed, exported, or analyzed.

## Batch Request File Format

The `--file` flag for `request batch` and `request diagnose` expects a JSON array of endpoint specs:

```json
[
  {"method": "GET",  "url": "https://api.example.com/users"},
  {"method": "POST", "url": "https://api.example.com/orders", "body": "{\"item\":\"widget\"}"}
]
```

## Common Patterns

### Prove a bug fix before pushing

1. Find the failing record: `apxy logs search --query "api.myapp.com" --format json | jq '.[] | select(.status_code >= 500)'`
2. Note the record ID (e.g., 7).
3. Fix the code, restart the server.
4. Replay: `apxy logs replay --id 7` -- note new ID (e.g., 12).
5. Diff: `apxy logs diff --id-a 7 --id-b 12 --scope response`
6. Export evidence: `apxy logs export-curl --id 7` and `--id 12` for the PR.

### Regression test before deploy

1. Capture baseline with `traffic recording start/stop` + `export-har`.
2. Deploy candidate build.
3. Batch replay: `request batch --file ./requests.json --compare-history`.
4. Search for field name drift: `search-bodies --pattern "old_name"` vs `"new_name"`.
5. SQL query for new error codes.

### Share a reproducible bug report

1. `apxy logs export-curl --id <ID> --format curl` -- one command anyone can run.
2. Or export as HAR for full context including headers and timing.

## Tips

- Always diff with `--scope response` when proving a bug fix -- the request did not change.
- Export HAR files to share full traffic context with teammates who have APXY installed.
- The `request batch` JSON file format matches the output of `export-har` endpoint entries, so you can round-trip between them.
