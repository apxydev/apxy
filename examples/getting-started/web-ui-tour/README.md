# Exploring the Web UI

You can drive APXY entirely from the CLI or an AI agent -- but the Web UI brings live traffic, visual rule editors, request composition, and diffing into one place. This tour walks every major surface so you know where to click when you want speed over terminal commands.

**Difficulty**: Beginner | **Time**: ~10 minutes | **Features used**: Traffic inspection, Mock rules, Filter rules, Redirect rules, Compose, Diff, SSL settings, SQL queries | **Requires**: Free

## Scenario

You already run `apxy start` and occasionally ask your agent to list logs. You want the full picture: the live traffic stream, how mock and filter rules look in a table editor, redirect rules, the compose panel for ad-hoc requests, side-by-side diffs, SSL settings, and the extras (network simulation, breakpoints, scripts, SQL). After this tour you can choose CLI or UI per task without hunting for features.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for httpbin.org"

**Your agent runs:**

```bash
apxy start --ssl-domains httpbin.org
```

If you haven't set up APXY's CA certificate yet, see
[SSL Setup Guide](../ssl-setup-guide/) first.

**Free tier note:** Traffic, mock/filter/redirect rules, Compose, Diff, and SSL work on Free. **Breakpoints**, **Network** simulation, **Scripts**, and **SQL** may prompt for a Pro upgrade in the UI -- if so, skim those steps to see where they live and continue with the rest of the tour.

---

## Track A: Agent + CLI Workflow

> Best for: ensuring the proxy is running and exploring core features from the terminal.

### Step 1: Start the proxy for the tour

Tell your agent:

> "Start APXY with the Web UI and SSL interception for httpbin.org so I can follow the UI tour."

Your agent runs:

```bash
apxy start --ssl-domains httpbin.org
```

Agent shows:

```
Web UI: http://localhost:8082
Proxy listening on ...
```

### Step 2: View live traffic logs

Tell your agent:

> "List the most recent captured traffic."

Your agent runs:

```bash
apxy logs list --limit 20
```

Agent shows rows with method, URL, status, and duration for each captured request.

### Step 3: List mock rules

Tell your agent:

> "Show me all active mock rules."

Your agent runs:

```bash
apxy mock list
```

Agent shows a table of active mock rules (empty if none have been created yet).

### Step 4: Compose an ad-hoc request

Tell your agent:

> "Send a POST to httpbin.org/post with a JSON body through the proxy."

Your agent runs:

```bash
apxy tools request compose --method POST --url "https://httpbin.org/post" --body '{"hello":"world"}' --headers '{"Content-Type":"application/json"}'
```

Agent prints status, timing, and a truncated response body. The same exchange appears in traffic logs.

### Step 5: Query traffic with SQL

Tell your agent:

> "Run a SQL query to count requests grouped by status code."

Your agent runs:

```bash
apxy sql query "SELECT status_code, COUNT(*) AS count FROM traffic_logs GROUP BY status_code ORDER BY count DESC"
```

Agent shows a table of status codes and their frequencies from captured traffic.

### Step 6: Continue in the browser or stop

Keep this terminal session open while you use Track B for the visual tour, or stop the proxy when done:

Tell your agent:

> "Stop the APXY proxy."

Your agent runs:

```bash
apxy stop
```

---

## Track B: Web UI Workflow

> Best for: visual learners; primary track for this example.

### Step 1: Open the dashboard

Browse to **http://localhost:8082**. Confirm the status indicator shows the proxy is running and note the sidebar navigation.

> screenshots/01-dashboard-overview.png

### Step 2: Traffic tab -- live stream, search, inspect

Go to **Traffic**. Trigger a few requests (e.g. visit `https://httpbin.org/get` in a browser or run `curl https://httpbin.org/uuid` in another terminal). Rows should appear in near real time.

Use the search or filter box to narrow by host, path, or status. **Traffic** -> click a row -> **Request** / **Response** / **Timing** tabs and related sub-panels.

> screenshots/02-traffic-live-search.png

### Step 3: Mock Rules tab -- create and list a mock

Go to **Mock Rules** -> click **Add Rule**. Add a simple rule: match `GET https://httpbin.org/status/418` (or a path pattern your build supports) and return a fixed JSON body with status `200`. Save the rule and confirm it appears in the list with priority/order visible.

Send a matching request; the **Traffic** row should show your mocked status and body.

> screenshots/03-mock-rules-create.png

### Step 4: Filter Rules tab -- block a domain

Go to **Filter Rules** -> click **Add Rule**. Create a rule that **blocks** traffic to a safe test host (e.g. `httpbin.org` or a dedicated staging hostname your team uses). Apply changes.

Attempt a request to that host through the proxy; it should fail fast or show a blocked state in **Traffic**. Remove or disable the rule when done so you do not break normal browsing.

> screenshots/04-filter-rules-block.png

### Step 5: Redirect Rules tab -- rewrite an endpoint

Go to **Redirect Rules** -> click **Add Rule**. Add a redirect from one URL prefix to another (for example, send `/legacy/*` to a new API base). Save and verify the rule summary in the table.

Hit the original path through the proxy and confirm **Traffic** shows the redirected upstream URL and response.

> screenshots/05-redirect-rules.png

### Step 6: Network tab -- latency and error simulation

Go to **Network**. Apply a profile such as high latency or partial packet loss against a narrow host filter. Run a few requests and compare timings in the Traffic detail **Timing** panel.

> screenshots/06-network-simulation.png

### Step 7: Breakpoints tab -- pause and edit in flight

Go to **Breakpoints** -> click **Add Breakpoint**. Define a breakpoint on a specific method + path (e.g. `POST /post` on httpbin). Trigger that request; the UI should surface a pause or breakpoint queue where you can inspect or modify before continue (exact controls depend on your APXY version).

> screenshots/07-breakpoints.png

### Step 8: Scripts tab -- hook traffic with scripts

Go to **Scripts**. Skim the script list or template entry points; attach a trivial script if your build offers samples (log header, add a header on response). Save and confirm it appears active in the summary.

> screenshots/08-scripts.png

### Step 9: Compose tab -- send a custom request

Go to **Compose**. Build a `POST https://httpbin.org/post` with custom headers and a JSON body. **Send** the request. The response appears in the compose result panel; the same exchange should appear in **Traffic**.

> screenshots/09-compose-request.png

### Step 10: Diff tab -- compare two responses

Go to **Diff**. Pick two captured responses (from **Traffic** or from saved artifacts, depending on UI flow). Run a diff and scan added/removed lines in headers or body.

> screenshots/10-diff-two-responses.png

### Step 11: SSL page -- configured domains

Go to **SSL**. Confirm `httpbin.org` (or your `--ssl-domains` entries) appear in the interception list. This is the same logical state as `apxy start --ssl-domains ...` but editable while running where supported.

> screenshots/11-ssl-domains.png

### Step 12: SQL tab -- query captured metadata

Go to **SQL**. Run a read-only query such as counting rows from the requests table or filtering by `host` (use the schema hints in the UI sidebar if present). Confirm results align with what you see in **Traffic**.

> screenshots/12-sql-query.png

### Step 13: Stop the proxy

Tell your agent:

> "Stop the APXY proxy."

Your agent runs:

```bash
apxy stop
```

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Dashboard + Traffic deep dive: 0:00 - 3:00
- Rules (mock, filter, redirect) + Compose + Diff: 3:00 - 7:00
- SSL, Network, Breakpoints, Scripts, SQL: 7:00 - 10:00

---

## What You Learned

- Where to monitor live traffic and drill into request/response detail
- How mock, filter, and redirect rules are represented and validated in the UI
- How to send one-off requests from **Compose** and compare responses in **Diff**
- Where SSL interception domains are reviewed alongside CLI flags
- That **Network**, **Breakpoints**, **Scripts**, and **SQL** exist for advanced workflows without leaving the browser

## Next Steps

- [Your First 5 Minutes with APXY](../../quickstart-5-minutes/) -- minimal path from install to first export
- [Mock Backend for Frontend](../../mock-backend-for-frontend/) -- unblock UI work when the real API is slow or missing
- [The Capture → Replay → Diff Loop](../../replay-and-diff/) -- regression-check API behavior after code changes
