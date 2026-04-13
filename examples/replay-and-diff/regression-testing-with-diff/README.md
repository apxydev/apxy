# Catching API Regressions Before Deployment

Ship with confidence by replaying a curated slice of real traffic against your
candidate build and diffing every response against a known-good baseline.

**Difficulty**: Intermediate | **Time**: ~15 minutes | **Features used**: Request replay, Traffic diff, SQL queries, SSL interception | **Requires**: Free

## Scenario

You are about to deploy a new version of your API. Before pushing to production,
you want to replay a set of captured requests against the new version and diff
the responses to catch any unintended changes: status codes that drift, fields
that disappear, or error payloads that appear where success used to be.

This workflow combines SQL-style traffic selection, deterministic replay (via
Compose or built-in replay), and pairwise diffs so regressions show up as
concrete text, not gut feel.

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

You also need traffic captured for `https://api.myapp.com` while your **current
production-like** (or last-known-good) build is running, then a way to point the
same URLs at your **candidate** build (staging URL, local port, or feature flag)
before you replay.

---

## Track A: Agent + CLI Workflow

> Best for: Claude Code, Cursor, Codex, Copilot users. You describe intent; the
> agent runs APXY commands.

### Step 1: List candidate records for your API host

**Tell your agent:**

> "Show me up to 20 captured traffic records for api.myapp.com: id, URL, and
> status. I want to pick endpoints to regression-test."

**Your agent runs:**

```bash
apxy sql query "SELECT id, method, url, status_code FROM traffic_logs WHERE host = 'api.myapp.com' LIMIT 20"
```

Note the record IDs you care about (for example `1` for `GET /api/users` and
`5` for `POST /api/orders`). Adjust the `WHERE` clause if you need a path
prefix, method filter, or time window.

### Step 2: Establish baseline responses (before the new version)

With the **old** (baseline) server reachable through the proxy, ensure each
selected request has been captured at least once. If you need to re-hit an
endpoint explicitly:

**Tell your agent:**

> "Send GET https://api.myapp.com/api/users through the proxy so we have a
> fresh baseline capture."

**Your agent runs:**

```bash
apxy tools request compose --method GET --url https://api.myapp.com/api/users
```

Repeat with the right method, URL, headers, and body for each endpoint in your
regression set. Write down the **baseline** record IDs (for example user list =
`1`, order create = `3`).

### Step 3: Deploy or switch to the new version

Restart your API, flip DNS or hosts, or change upstream routing so the **same
URLs** now hit the candidate build. Do not clear APXY traffic yet; you need
both eras in one database for diffing.

### Step 4: Replay the same traffic against the new version

For each baseline record, either replay it exactly or compose an equivalent
request.

**Tell your agent:**

> "Replay traffic record 1 against the live upstream through the proxy."

**Your agent runs:**

```bash
apxy logs replay --id 1
```

Alternatively, for a hand-tuned replay:

**Tell your agent:**

> "Compose the same GET as before to https://api.myapp.com/api/users."

**Your agent runs:**

```bash
apxy tools request compose --method GET --url https://api.myapp.com/api/users
```

Note the **new** record IDs after each replay (for example baseline `1` → new
`21`).

### Step 5: Diff baseline vs new for each pair

**Tell your agent:**

> "Diff traffic record 1 vs 21 focusing on the response body and status."

**Your agent runs:**

```bash
apxy logs diff --id-a 1 --id-b 21 --scope response
```

To include headers and line-level request changes:

```bash
apxy logs diff --id-a 1 --id-b 21 --scope both
```

### Step 6: Repeat and triage

Repeat Steps 4–5 for every endpoint in your regression set. Flag any diff where:

- `status_code` changed unexpectedly
- Required JSON fields vanished or types changed
- Error envelopes appeared on previously successful paths

**Tell your agent:**

> "Show full details for record 21 so I can see the new response body."

**Your agent runs:**

```bash
apxy logs show --id 21
```

---

## Track B: Web UI Workflow

> Best for: scanning many pairs visually and sharing screenshots with the team.

### Step 1: Confirm baseline traffic

Open **http://localhost:8082** (or your configured Web UI port). Go to the
**Traffic** tab. Filter or search for `api.myapp.com` and verify rows from the
baseline run (method, path, green or expected status).

> screenshots/01-traffic-baseline-api-myapp.png

### Step 2: Capture candidate traffic

After switching to the new API version, use **Compose** to resend key requests,
or trigger your app so the same flows run again. Confirm new rows appear with
matching paths but newer timestamps.

> screenshots/02-traffic-candidate-rows.png

### Step 3: Open the Diff view

Go to the **Diff** tab. Select **Left** = baseline record, **Right** = candidate
record for the same logical operation. Scan highlighted changes in status,
headers, and body.

> screenshots/03-diff-regression-response.png

### Step 4: Drill into suspicious rows

Click into a traffic row whose status or size changed unexpectedly. Inspect
**Request** and **Response** tabs to decide whether the delta is intentional
(schema bump) or a regression.

> screenshots/04-traffic-detail-regression.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Selecting records with SQL: 0:00–3:00
- Replay + diff loop: 3:00–10:00
- Web UI diff review: 10:00–14:00

---

## What You Learned

- How to narrow captured traffic to one host (and beyond) with `traffic sql query`
- How to establish baseline captures, switch builds, and replay the same calls
- How to compare arbitrary record pairs with `traffic logs diff` and `--scope`
- How to use the Web UI Traffic + Diff tabs for regression review
- How to treat diff output as release evidence, not anecdotal “looks fine”

## Next Steps

- [The Capture → Replay → Diff Loop](../README.md) — single-bug proof with before/after
- [Creating a Reproducible Bug Report](../export-and-share-bug/) — export one failing request for teammates
- [Saving and Restoring Debug Sessions](../session-save-restore/) — hand off full context (Pro)
