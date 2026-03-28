# AI Agent Validates a Fix with Replay+Diff

After a bug fix, "it should work" is not enough. Have your agent keep the failing capture, replay the same request post-fix, and run a response-scoped diff so you have evidence without manual copy-paste in two terminals.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Request replay, Traffic diff, Export as cURL, SSL interception | **Requires**: Free

## Scenario

Your agent (or you) found a bug in the order creation endpoint. After you fix it, the agent replays the original failing request and diffs the responses to provide concrete evidence the fix works -- without you running ad-hoc manual tests. This example assumes the bad request was already captured while traffic flowed through APXY with SSL termination for your API host.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with the APXY skill installed (see [Using APXY as a Claude Code / Cursor Skill](../agent-skill-reference/))

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

Identify the traffic **id** of the failing **POST /api/orders** (or capture one before fixing).

---

## Track A: Agent + CLI Workflow

> Capture id **A** is the before state; after replay, id **B** is the after state. The diff command compares them.

### Step 1: Confirm the failing capture

**Tell your agent:**

> "Show me the full details of the failing order creation request so we know exact method, URL, headers, and body for replay."

**Your agent runs:**

```bash
apxy traffic logs show --id 7
```

(Replace `7` with your failing record id.) The agent extracts the JSON body and any auth headers you must preserve for a fair replay.

### Step 2: You implement the fix

Apply your code or config change and restart the service. Tell the agent when the server is ready to accept the same request again.

### Step 3: Replay the same request through the proxy

**Tell your agent:**

> "Send the same POST to https://api.myapp.com/api/orders with the same body as record 7."

**Your agent runs:**

```bash
apxy tools request compose --method POST --url https://api.myapp.com/api/orders \
  --body '{"customer_id":"cust_42","items":[{"sku":"WIDGET-1","qty":2}]}'
```

Use the exact body from Step 1. If the original used headers (for example `Authorization`), the agent adds the appropriate flags supported by `request compose` for your APXY version. The response is captured as a **new** id (for example `12`).

### Step 4: Diff response only

**Tell your agent:**

> "Diff record 7 against record 12, only the response -- I want to see status and body changes."

**Your agent runs:**

```bash
apxy traffic logs diff --id-a 7 --id-b 12 --scope response
```

### Step 5: Agent summarizes what changed

**Tell your agent:**

> "In plain language, summarize the diff: status code, error fields removed, and success fields added."

The agent reads the CLI diff output and reports whether the fix removes the failure mode (for example 500 with `error.message` replaced by 200 with `order_id`).

### Step 6 (optional): Export cURL for the PR

**Tell your agent:**

> "Export both records as cURL so I can paste before/after into the pull request."

**Your agent runs:**

```bash
apxy traffic logs export-curl --id 7
apxy traffic logs export-curl --id 12
```

### Step 7 (optional): Re-run diff if you iterate

If a second fix is needed, replay again to get a new id and diff `7` vs the new id the same way.

**Tell your agent:**

> "Replay once more and diff against the original failure to confirm the latest commit."

**Your agent runs:**

```bash
apxy tools request compose --method POST --url https://api.myapp.com/api/orders \
  --body '{"customer_id":"cust_42","items":[{"sku":"WIDGET-1","qty":2}]}'
apxy traffic logs diff --id-a 7 --id-b <new-id> --scope response
```

### Common pitfalls

- **Auth drift**: If the original capture used a bearer token that expired, replay may 401 even though your business logic is fixed. Refresh credentials or strip auth only when you are isolating pure handler behavior.
- **Idempotency and side effects**: POST that creates rows twice can confuse diff output (new ids each time). Prefer comparing **error vs success shape**, or replay against a throwaway database.
- **Wrong record id**: Always diff the **original failure** as **`--id-a`**. Swapping A/B makes the diff psychologically harder to read.
- **TLS not intercepted**: If bodies are empty in `logs show`, confirm **`--ssl-domains api.myapp.com`** and CA trust per the SSL guide.

---

## Track B: Web UI Workflow

You can follow along in the Web UI: locate the failing row under **Traffic**, open it for the same detail you get from **`apxy traffic logs show`**. After deploying your fix, open **Compose**, import from the original failing request, send it, then open **Diff** and select the old and new rows with **response** scope -- equivalent to **`apxy traffic logs diff --scope response`**. This is useful when you want a visual side-by-side while the agent still runs CLI commands for scripting or PR artifacts.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Agent + CLI: show, compose, diff, optional export-curl
- Web UI: compose from traffic and visual diff

---

## What You Learned

- How **`apxy traffic logs show`** pins the canonical failing request for replay
- How **`apxy tools request compose`** reproduces the call after your fix
- How **`apxy traffic logs diff --id-a ... --id-b ... --scope response`** turns subjective "fixed" into a concrete comparison
- How optional **`apxy traffic logs export-curl`** shares evidence with reviewers

---

## Next Steps

- [Replay and Diff (full tutorial)](../../replay-and-diff/) -- extended narrative and UI screenshots
- [Let Your AI Agent Find and Fix Server Errors](../agent-debug-500-errors/) -- SQL and jsonpath-led diagnosis before the fix
- [AI Agent Analyzes Slow Endpoints](../agent-diagnose-api-performance/) -- when the bug is latency, not status codes
