# Replay and diff: verify fixes, export, regression checks

`apxy logs replay` sends a request through a running proxy. Start one with `apxy start` and keep it running from the first capture until the last replay. A new proxy clears the traffic logs, so the record you want to replay would be gone.

## Core loop

```
capture -> fix code -> mark -> replay -> wait -> diff
```

1. Capture the request while the bug is live. This is the "before" record.
2. Fix the code and restart your server.
3. Run `apxy mark`, then replay the "before" record with `apxy logs replay --id <ID>`.
4. Check the new request with `apxy wait --match "<METHOD> <path>" --expect ...`. Exit code 0 means the fix works. The output holds the "after" record ID.
5. Diff the two records with `apxy logs diff --scope response` to see what changed.

## Commands

| Command | Description | Key flags |
|---------|-------------|-----------|
| `apxy logs replay` | Send a captured request again through the running proxy | `--id`, `--port` (8080) |
| `apxy mark` | Record a point in time for `apxy wait` | optional mark name |
| `apxy wait` | Block until a matching request lands, then check it | `--match`, `--expect`, `--since`, `--timeout` (30s) |
| `apxy logs diff` | Compare two records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy logs export-curl` | Export one record as a client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python), `--redact` |
| `apxy logs export-har` | Export traffic as a HAR 1.2 file | `--file` (stdout if omitted), `--limit` (10000), `--redact` |
| `apxy logs import-har` | Import records from a HAR file | `--file` |

## Export formats

```bash
apxy logs export-curl --id <ID> --format <FORMAT>
```

| Format | Use |
|--------|-----|
| `curl` | Terminal, CI scripts, PR descriptions |
| `fetch` | Browser console, frontend debugging |
| `httpie` | HTTPie command line |
| `python` | Python scripts and test suites |

Exports mask secrets such as `Authorization` headers when stdout is not a terminal. In a terminal, pass `--redact` to get the same masking.

## Replay or send a new request

- `apxy logs replay --id <ID>` sends the captured request again with the same method, URL, headers, and body.
- To change the request, export it with `apxy logs export-curl --id <ID>`, edit the curl command, and run it with `apxy run -- curl ...`.

Both create a new record that you can diff against the original.

## Diff scopes

| Scope | What it compares |
|-------|------------------|
| `request` | Method, URL, headers, and body of the request |
| `response` | Status code, headers, and body of the response |
| `both` | The full request and response (default) |

Use `--scope response` when you verify a fix. The request did not change, so only the response matters.

## Regression check after a change

Run the test suite or a script through APXY. Then check each endpoint that matters with one `apxy wait` per request:

```bash
apxy mark
apxy run -- npm test
apxy wait --match "GET /api/users" --expect "status == 200" --expect "body.users exists" --timeout 0
apxy wait --match "POST /api/orders" --expect "status == 201" --expect "body.order.id exists" --timeout 0
```

`--timeout 0` checks the captured traffic once without blocking, because the tests already finished. Any exit code other than 0 is a regression.

To find renamed fields, search bodies for the old and the new name:

```bash
apxy logs search-bodies --pattern "old_name" --scope response --limit 10
apxy logs search-bodies --pattern "new_name" --scope response --limit 10
```

## HAR import and export

HAR (HTTP Archive) is the standard file format for sharing captured traffic between tools.

```bash
# Export to a file
apxy logs export-har --file ./traffic.har --limit 5000

# Export to stdout
apxy logs export-har
```

Import loads a HAR file into the current APXY traffic database:

```bash
apxy logs import-har --file ./colleague-traffic.har
```

Imported records work with search, show, diff, and export like captured ones.

## Common patterns

### Prove a bug fix before pushing

1. Start the proxy with `apxy start` and reproduce the bug.
2. Find the failing record: `apxy logs search --query "api.myapp.com" | jq '.items[] | select(.status_code >= 500) | .id'`
3. Note the record ID, for example `a1b2c3`.
4. Fix the code and restart your server.
5. Run `apxy mark`, then `apxy logs replay --id a1b2c3`.
6. Check it: `apxy wait --match "POST /api/checkout" --expect "status == 200"`. Note the new record ID from the output, for example `d4e5f6`.
7. Diff: `apxy logs diff --id-a a1b2c3 --id-b d4e5f6 --scope response`
8. Export proof for the PR: `apxy logs export-curl --id d4e5f6 --redact`

### Share a reproducible bug report

1. Run `apxy logs export-curl --id <ID> --format curl --redact` to get one command anyone can run.
2. Or export a HAR file for the full headers and timing.

## Tips

- Diff with `--scope response` when you prove a bug fix.
- Share HAR files with teammates who use APXY or any HAR viewer.
