# Creating a Reproducible Bug Report

Turn a flaky or hard-to-describe API failure into a copy-paste artifact: the
exact request your teammate can replay without writing prose reproduction steps.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Export as cURL, Traffic inspection, SSL interception | **Requires**: Free

## Scenario

You found a bug where `/api/checkout` returns **500** when the cart has more than
ten items. Your teammate needs to reproduce it on their machine. Instead of
writing “add 11 items, then…” and hoping the payload matches, you export the
**exact** failing request from APXY—in multiple formats if your team splits
across shells, browsers, and scripts.

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

Route your app (or API client) through the proxy, reproduce the checkout with
more than ten items, and wait until the failing response appears in traffic.

---

## Track A: Agent + CLI Workflow

> Best for: agents that search, show, and export in one thread.

### Step 1: Find the failing request

**Tell your agent:**

> "Search captured traffic for checkout-related requests; I need the one that
> returned 500."

**Your agent runs:**

```bash
apxy logs search --query "checkout"
```

Scan the results for `POST` (or the method you use) to
`https://api.myapp.com/.../checkout` and a `500` status. Note the record **ID**
(for example `42`).

If search returns too much noise, narrow with a path fragment or status:

```bash
apxy logs search --query "api.myapp.com checkout 500"
```

### Step 2: Inspect the record

**Tell your agent:**

> "Show me full details for traffic record 42—request headers, body, and
> response."

**Your agent runs:**

```bash
apxy logs show --id 42
```

Confirm the cart payload shows more than ten items and the response body
contains the server error you saw in the app.

### Step 3: Export as cURL (universal shell repro)

**Tell your agent:**

> "Export record 42 as a cURL command I can paste into Slack."

**Your agent runs:**

```bash
apxy logs export-curl --id 42 --format curl
```

`export-curl` accepts a `--format` flag; `curl` is the default and matches what
most backend engineers expect.

### Step 4: Export as fetch (frontend teammate)

**Tell your agent:**

> "Export the same record as JavaScript fetch() for our frontend dev."

**Your agent runs:**

```bash
apxy logs export-curl --id 42 --format fetch
```

### Step 5: Export as Python (scripts / data team)

**Tell your agent:**

> "Export record 42 as a Python requests snippet."

**Your agent runs:**

```bash
apxy logs export-curl --id 42 --format python
```

### Step 6: Package the bug report

Paste into your issue tracker:

1. The record ID (`42`) so others can `show` / `replay` if they share the DB
2. One primary export (usually cURL) as the “official” repro
3. Optional: fetch or Python variants in collapsible sections
4. Link to this example if teammates are new to APXY

**Tell your agent:**

> "Give me a one-line command to replay record 42 through the proxy."

**Your agent runs:**

```bash
apxy logs replay --id 42
```

---

## Track B: Web UI Workflow

> Best for: quick visual confirmation before exporting.

### Step 1: Locate checkout traffic

Open **http://localhost:8082**. Open the **Traffic** tab. Use the search bar
with `checkout` or filter by host `api.myapp.com`. Click the row with status
**500**.

> screenshots/01-traffic-checkout-500.png

### Step 2: Verify request and response

In the detail panel, open **Request** and confirm body fields (item count >
10). Open **Response** and capture the error payload for the ticket description.

> screenshots/02-request-response-checkout.png

### Step 3: Export from the UI

Use the **Export** action (or context menu, depending on build) to copy **cURL**
or another format. Paste into your bug tracker alongside the screenshot of the
response tab.

> screenshots/03-export-menu-curl.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Search + show + export: 0:00–3:30
- Web UI export: 3:30–5:30

---

## What You Learned

- How to find a needle request with `traffic logs search`
- How to inspect headers and bodies with `traffic logs show`
- How to emit the same capture as cURL, fetch, or Python via `--format`
- How to offer `traffic logs replay` as a one-shot repro for teammates on APXY
- How to attach evidence from the Web UI without retyping payloads

## Next Steps

- [Exporting Requests as cURL, Fetch, HTTPie, and Python](../export-to-multiple-formats/) — side-by-side format tour
- [Sharing a Debug Artifact with Your Team](../share-debug-artifact/) — add rules + config to the bundle
- [The Capture → Replay → Diff Loop](../README.md) — prove a fix with diff
