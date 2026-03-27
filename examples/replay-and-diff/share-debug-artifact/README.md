# Sharing a Debug Artifact with Your Team

Package the failing request, your mock rules, and portable proxy configuration
into one shareable bundle so onboarding a helper takes minutes, not meetings.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Export as cURL, Mock rules, Config export, SSL interception | **Requires**: Free

## Scenario

You captured a tricky API issue: a **checkout** call fails only when specific
headers and a large cart body combine. You already mocked upstream inventory to
stay unblocked. Now you want a **single artifact**—cURL repro, rule summary, and
exported config—that anyone can drop into a ticket or repo folder to continue
the investigation.

This pattern mixes **per-request export** (`traffic logs export-curl`) with
**database-backed config export** (`config export`) so recipients rebuild proxy
behavior without retyping JSON.

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

---

## Track A: Agent + CLI Workflow

> Build a three-part bundle: **repro command**, **rules inventory**, **config
> JSON**. Adjust filenames to match your issue tracker conventions.

### Step 1: Find and export the failing request

**Tell your agent:**

> "Search traffic for checkout failures and give me the record ID of the 500."

**Your agent runs:**

```bash
apxy traffic logs search --query "checkout 500"
```

Suppose the ID is `88`.

**Tell your agent:**

> "Export record 88 as cURL for the bug bundle."

**Your agent runs:**

```bash
apxy traffic logs export-curl --id 88 --format curl > repro-checkout.sh
```

Optional: add fetch/Python variants the same way as in the multi-format guide.

### Step 2: Capture mock rules for context

**Tell your agent:**

> "List all mock rules so I can paste them into README-BUG.md."

**Your agent runs:**

```bash
apxy rules mock list
```

For a compact handoff, use markdown or toon format:

```bash
apxy rules mock list --format markdown
```

Paste the output under a **Mock rules** section in your bundle doc so reviewers
know which upstream calls are stubbed.

### Step 3: Export proxy configuration

**Tell your agent:**

> "Export APXY config to bug-repro.json for teammates."

**Your agent runs:**

```bash
apxy config export --file bug-repro.json
```

The default filename is `apxy-config.json` if you omit `--file`; using a
descriptive name keeps downloads from colliding in `Downloads/`.

### Step 4: Write the mini README for your team

Create `README-BUG.md` (or a ticket body) containing:

1. **Symptom** — 500 on checkout when cart > 10 items and header `X-Experiment`
   is present
2. **repro-checkout.sh** — the cURL from Step 1
3. **Mock rules** — output from Step 2
4. **Import instructions**:

**Tell your agent:**

> "Show the command to import config from bug-repro.json."

**Your agent runs:**

```bash
apxy config import --file bug-repro.json
```

Remind readers that import mutates local proxy configuration; they should back
up first if needed.

### Step 5: Optional replay shortcut

**Tell your agent:**

> "Give me replay for record 88."

**Your agent runs:**

```bash
apxy traffic logs replay --id 88
```

Add that line to the README for teammates who keep the same SQLite database you
used during capture.

---

## Track B: Web UI Workflow

> Screenshots anchor the narrative; CLI files carry the bytes.

### Step 1: Show the failing row

**Traffic** tab → filter `checkout` → highlight the **500** row with unusual
headers visible in the summary if possible.

> screenshots/01-traffic-checkout-500-row.png

### Step 2: Document mock rules visually

Open the **Rules** / **Mocks** screen. Capture active rules that affect checkout
or inventory.

> screenshots/02-mock-rules-active.png

### Step 3: Export evidence from Traffic detail

Open the request, expand headers, screenshot the **Request** + **Response**
panes, then use **Export → cURL** to mirror the CLI bundle.

> screenshots/03-traffic-detail-export.png

### Step 4: Note config export path

Run `apxy config export --file bug-repro.json` from a terminal (or your team’s
automation) and attach the JSON alongside the screenshots.

> screenshots/04-artifact-files-in-folder.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- CLI bundle assembly: 0:00–4:30
- Web UI screenshots + export: 4:30–6:30

---

## What You Learned

- How to combine `traffic logs export-curl` with `rules mock list` for human-readable context
- How `config export` / `config import` moves proxy configuration between machines
- How to structure a ticket or folder so repro, rules, and config stay together
- When to add `traffic logs replay` for same-database collaborators

## Next Steps

- [Exporting Requests as cURL, Fetch, HTTPie, and Python](../export-to-multiple-formats/) — more export formats
- [Saving and Restoring Debug Sessions](../session-save-restore/) — full Pro settings round-trip
- [Creating a Reproducible Bug Report](../export-and-share-bug/) — minimal single-request handoff
