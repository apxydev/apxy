# Exporting Requests as cURL, Fetch, HTTPie, and Python

One captured request, four consumable snippets—match the tool your teammate
already uses without manually translating headers, cookies, or JSON bodies.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Multi-format export (cURL, Fetch, HTTPie, Python), SSL interception | **Requires**: Free

## Scenario

You captured an interesting API call to `https://api.myapp.com` and need to share
it with different teammates: someone lives in the terminal with **cURL**,
another copies **fetch()** into a Next.js route, DevOps prefers **HTTPie**, and
the data team wants **Python** `requests`. APXY stores the canonical request
once; you emit each format from the same record ID.

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
apxy proxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

Generate the request through your app or Compose so it appears in **Traffic**.

---

## Track A: Agent + CLI Workflow

> This example is primarily CLI-driven: all four formats share one subcommand
> with different `--format` values.

### Step 1: Identify the record ID

**Tell your agent:**

> "List the last 15 traffic records to api.myapp.com so I can pick the export
> target."

**Your agent runs:**

```bash
apxy traffic logs search --query "api.myapp.com" --limit 15
```

Pick the **ID** of the request you want to share (below we use `7` as a
placeholder—replace with your real ID).

### Step 2: Export as cURL

**Tell your agent:**

> "Export traffic record 7 as cURL."

**Your agent runs:**

```bash
apxy traffic logs export-curl --id 7 --format curl
```

**When to use:** shell scripts, backend engineers, CI snippets, and chat systems
where a single pasted command reproduces the call.

### Step 3: Export as fetch

**Tell your agent:**

> "Export record 7 as JavaScript fetch."

**Your agent runs:**

```bash
apxy traffic logs export-curl --id 7 --format fetch
```

**When to use:** browser or Node code paths, quick prototypes in devtools, and
frontend teams avoiding subprocess shells.

### Step 4: Export as HTTPie

**Tell your agent:**

> "Export record 7 as an HTTPie command."

**Your agent runs:**

```bash
apxy traffic logs export-curl --id 7 --format httpie
```

**When to use:** human-friendly CLI debugging (`http` is expressive and
readable in docs).

### Step 5: Export as Python

**Tell your agent:**

> "Export record 7 as Python requests code."

**Your agent runs:**

```bash
apxy traffic logs export-curl --id 7 --format python
```

**When to use:** notebooks, ETL scripts, load-test harnesses, and any ecosystem
where `requests` is the default HTTP client.

### Step 6: Sanity-check parity

**Tell your agent:**

> "Show record 7 in JSON so I can confirm method, URL, and major headers before
> I share exports."

**Your agent runs:**

```bash
apxy traffic logs show --id 7 --format json
```

All four exports derive from this single stored record, so they stay in sync
when you re-export after a capture refresh.

---

## Track B: Web UI Workflow

> Minimal path: confirm the row, then use the Export control.

### Step 1: Select the request

Open **http://localhost:8082**. Go to **Traffic**. Click the row for your
`api.myapp.com` request.

> screenshots/01-traffic-row-selected.png

### Step 2: Open Export

Use the **Export** button (or row action) in the Traffic detail toolbar. Choose
**cURL**, **fetch**, **HTTPie**, or **Python** from the format picker if
available; otherwise copy the default and switch formats from the CLI using the
steps above.

> screenshots/02-export-button-formats.png

### Step 3: Copy to clipboard

Copy the generated snippet into your doc, PR, or ticket. No screenshot is
required for text exports, but a cropped image of the Traffic row helps readers
find the same record by time and path.

> screenshots/03-export-copied-toast.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- CLI `--format` tour: 0:00–4:00
- Web UI Export button: 4:00–5:30

---

## What You Learned

- That `traffic logs export-curl` is the unified export entry point
- How `--format curl|fetch|httpie|python` maps to real team workflows
- How to pair `traffic logs show` with exports for verification
- Where the Web UI fits when you only need a quick copy action

## Next Steps

- [Creating a Reproducible Bug Report](../export-and-share-bug/) — search, show, and share a 500
- [Sharing a Debug Artifact with Your Team](../share-debug-artifact/) — export + rules + config
- [The Capture → Replay → Diff Loop](../README.md) — compare before/after responses
