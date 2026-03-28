# Pausing and Editing Live Requests

Stop an HTTP request in place, inspect headers and body like a debugger, tweak the values that matter, then resume—ideal when reproducing a bad client payload without redeploying.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Breakpoints, Traffic inspection, SSL interception | **Requires**: Pro

## Scenario

You suspect a header (for example a bad `Content-Type`, stale `Idempotency-Key`, or malformed `Authorization`) is causing a **400** from `https://api.myapp.com/api/orders`, but patching the mobile or web client is slow. An APXY **breakpoint** on the **request** phase pauses matching traffic so you can read the full message, edit the problematic fields, and **resume** with the corrected request flowing to the server.

Because editing paused payloads is highly interactive, **Track B (Web UI)** is the primary path; Track A shows how to define the breakpoint and resume from the CLI once you know the pending id.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- **Pro** license (breakpoints are a Pro capability)

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

Point your client (browser, mobile simulator, or API client) at the proxy so HTTPS to `api.myapp.com` is decrypted and visible to APXY.

---

## Track A: Agent + CLI Workflow

Breakpoints are created with `apxy rules breakpoint add` (a name and match expression are required). The match DSL supports expressions like `path contains "/api/orders"` combined with host checks.

### Step 1: Add a request-phase breakpoint

**Tell your agent:**

> "Add a breakpoint named orders-inspect that pauses requests in the request phase when the path contains /api/orders on api.myapp.com traffic."

**Your agent runs:**

```bash
apxy rules breakpoint add \
  --name "orders-inspect" \
  --match 'host == "api.myapp.com" && path contains "/api/orders"' \
  --phase request \
  --timeout 120000
```

`--timeout` is in milliseconds; increase it if you need more time to inspect slow manual workflows. Default is shorter—adjust so the pause does not auto-resume before you finish.

### Step 2: Trigger the failing call

**Tell your agent:**

> "I'll reproduce the POST to /api/orders through the proxy. Tell me when you see a pending breakpoint."

Reproduce from your app or:

```bash
curl -x http://127.0.0.1:8080 -X POST "https://api.myapp.com/api/orders" \
  -H "Content-Type: application/json" \
  -d '{"sku":"demo"}'
```

(Replace proxy host/port with your APXY listen address.)

### Step 3: List paused sessions

**Tell your agent:**

> "List pending breakpoints and give me the pending id for the paused orders request."

**Your agent runs:**

```bash
apxy rules breakpoint pending
```

Note the **pending** id (not the rule id from `breakpoint list`). You need this for `resolve`.

### Step 4: Inspect the paused request

**Tell your agent:**

> "Show full details for the paused request: method, URL, headers, and body."

Use Web UI (recommended) or ask the agent to open the breakpoint inspector modal. From the CLI alone you rely on `pending` JSON plus **Traffic** / log views for the frozen snapshot—if your build surfaces request bodies there, use:

```bash
apxy traffic logs show --id LOG_ID
```

…after identifying `LOG_ID` from the pending payload or Traffic tab.

### Step 5: Modify headers or body (interactive)

**Tell your agent:**

> "I fixed the bad header in the Web UI breakpoint editor" **or** "Apply this header override when resuming: Authorization: Bearer <valid-token>."

For **request** edits, the Web UI modal is the straightforward place to change headers and body before resume.

If you are only **resuming without edits** after visual inspection:

**Your agent runs:**

```bash
apxy rules breakpoint resolve --id PENDING_ID
```

When the product supports applying header overrides from CLI for paused **requests**, your agent may instead run:

```bash
apxy rules breakpoint resolve --id PENDING_ID \
  --headers '{"Authorization":"Bearer <token>","Content-Type":"application/json"}'
```

Consult `apxy rules breakpoint resolve --help` for your version’s exact flags; response-phase breakpoints use `--status` / `--body` for synthetic responses.

### Step 6: Verify the server response

**Tell your agent:**

> "After resume, show the latest traffic row for /api/orders and confirm we got 200 instead of 400."

**Your agent runs:**

```bash
apxy traffic logs search --query "/api/orders" --limit 5
```

### Step 7: Remove or disable the breakpoint

**Tell your agent:**

> "Remove the orders-inspect breakpoint rule—list first to get the rule id."

**Your agent runs:**

```bash
apxy rules breakpoint list
apxy rules breakpoint remove --id RULE_ID
```

---

## Track B: Web UI Workflow (primary)

This example is **Web UI–first**: editing a paused **request** is naturally point-and-click.

1. **Dashboard** — confirm proxy + SSL for `api.myapp.com`.
2. Open **Breakpoints** (or **Rules** → **Breakpoints**).
3. Click **Add breakpoint**.
4. Configure:
   - **Name**: `orders-inspect`
   - **Phase**: Request
   - **Match**: expression equivalent to `host == "api.myapp.com" && path contains "/api/orders"` (use the UI’s match builder if available).
   - **Timeout**: high enough for manual edits (e.g. 120000 ms).
5. Save, then trigger the client request. The UI should show a **pending** state or modal.
6. When the editor opens, inspect **Headers** and **Body**. Fix the suspect header (or body field), then click **Resume** (or **Continue**) so the request proceeds to the origin.
7. Open **Traffic**, select the completed row, and confirm status code and response body match expectations.

**Screenshot placeholders**

- `screenshots/01-breakpoints-list.png` — Breakpoints page with Add breakpoint visible.
- `screenshots/02-breakpoint-editor-paused.png` — Modal or panel showing paused request with editable headers.
- `screenshots/03-after-resume-traffic.png` — Traffic row showing successful response after edit.

---

## Video Walkthrough

_Add a link or embed when the recording is ready._

- **Planned title**: Pause, edit, and resume HTTP requests with APXY breakpoints
- **Length**: ~8–12 minutes (Web UI walkthrough + one CLI tip)

---

## What You Learned

- **Request-phase** breakpoints pause before the origin sees the bytes you care about.
- **Pending ids** (for `resolve`) differ from **rule ids** (for `remove` / `disable`).
- Interactive editing belongs in the **Web UI**; CLI is best for automation, listing, and scripted resume when flags match your version.
- Tight **match** expressions avoid pausing unrelated traffic on the same host.

---

## Next Steps

- Add a **response-phase** breakpoint to freeze 500 responses before they reach the client.
- Pair with [redirect rules](../redirect-api-to-staging/) to point traffic at a local mock while still using production hostnames in the client.
- Explore [request scripts](../script-add-auth-header/) when the same header fix should apply to every call without manual pauses.
