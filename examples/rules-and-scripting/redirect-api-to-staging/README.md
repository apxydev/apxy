# Pointing Your App at Different Environments

Route traffic that still targets your production API hostname to a local or staging server—no rebuild, no feature flags, just a transparent rewrite at the proxy.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Redirect rules, SSL interception | **Requires**: Free

## Scenario

Your frontend is hardcoded to call `https://api.prod.com`, but you want to exercise the same UI against a server you control at `http://localhost:3000`. Changing env files or rebuilding for every experiment is slow and error-prone. With APXY **redirect rules**, the app keeps requesting `api.prod.com`; the proxy rewrites the URL before forwarding, so your browser and bundle never need to know you are not hitting production.

This pattern also scales to “prod hostname → staging cluster” or “versioned path → canary” once you are comfortable with wildcard patterns.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.prod.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.prod.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

You also need something listening on `localhost:3000` (or adjust the `--to` URL to match your dev server). The examples below assume your local API mirrors the same paths as production.

---

## Track A: Agent + CLI Workflow

### Step 1: Create a wildcard redirect from production to local

**Tell your agent:**

> "Add an APXY redirect rule: match all HTTPS requests to api.prod.com with wildcard paths, and rewrite them to the same path on http://localhost:3000."

**Your agent runs:**

```bash
apxy rewrite set \
  --name "prod-to-local" \
  --from "https://api.prod.com/*" \
  --to "http://localhost:3000/*" \
  --match wildcard
```

The `--match wildcard` mode treats `*` in `--from` / `--to` as a path segment wildcard so `/v1/users` on production maps to `/v1/users` on your machine.

### Step 2: Verify the rule exists

**Tell your agent:**

> "List all redirect rules so I can confirm the prod-to-local rule is registered."

**Your agent runs:**

```bash
apxy rewrite list
```

Agent should show your rule with an **id**, **from**, **to**, and **match** type. Keep the **id** handy for cleanup.

### Step 3: Exercise the app through the proxy

**Tell your agent:**

> "I'll use the browser or app with the system proxy pointed at APXY. Trigger a few API calls that normally go to https://api.prod.com."

Watch your local server logs: you should see the same paths you would have hit on production, but with traffic arriving from the proxy rewrite, not from a direct client→prod connection.

### Step 4: Confirm routing in captured traffic

**Tell your agent:**

> "Show recent traffic to localhost:3000 or search logs for api.prod.com so we can confirm the rewrite happened."

**Your agent runs** (adjust query to your CLI / traffic tools as needed):

```bash
apxy logs search --query "api.prod.com" --limit 10
```

You want to see requests whose **original** URL matched production while the **forwarded** target was your local stack.

### Step 5: Add a second rule for another environment (optional)

**Tell your agent:**

> "Add another redirect named staging-canary: from https://api.prod.com/v2/* to https://staging.internal.example.com/v2/* with wildcard match."

**Your agent runs:**

```bash
apxy rewrite set \
  --name "staging-canary" \
  --from "https://api.prod.com/v2/*" \
  --to "https://staging.internal.example.com/v2/*" \
  --match wildcard
```

More specific rules typically take precedence depending on your APXY version and ordering; if two patterns overlap, list rules and disable or remove the one you are not testing.

### Step 6: Clean up when finished

**Tell your agent:**

> "Remove the redirect rule with id RULE_ID" (paste the id from `apxy rewrite list`).

**Your agent runs:**

```bash
apxy rewrite remove --id RULE_ID
```

To clear everything quickly during a reset:

```bash
apxy rewrite remove --all
```

---

## Track B: Web UI Workflow

1. Open the APXY Web UI (default dashboard URL is shown when the proxy starts).
2. **Dashboard** — confirm the proxy is running and SSL is active for `api.prod.com`.
3. Navigate to **Redirect Rules** (or **Rules** → **Redirects**, depending on your UI version).
4. Click **Add Rule** (or **New redirect**).
5. Fill in:
   - **From pattern**: `https://api.prod.com/*`
   - **To pattern**: `http://localhost:3000/*`
   - **Match type**: Wildcard
   - Optional **Name**: `prod-to-local`
6. Save the rule and confirm it appears in the list with the same shape as the CLI output.
7. Open **Traffic** and reproduce a few API calls from your app. Select a row and verify the request URL / routing metadata shows the rewrite to your local origin.

**Screenshot placeholders**

- `screenshots/01-redirect-rules-empty.png` — Redirect Rules page before adding a rule.
- `screenshots/02-redirect-rule-form.png` — Add Rule form filled with from/to wildcard patterns.
- `screenshots/03-traffic-redirected.png` — Traffic tab showing a request that was rewritten to localhost.

---

## Video Walkthrough

_Add a link or embed when the recording is ready._

- **Planned title**: Redirect production API traffic to localhost with APXY
- **Length**: ~3–5 minutes

---

## What You Learned

- Redirect rules rewrite URLs **before** forwarding, so client code can keep hardcoded production hosts.
- Wildcard `--from` / `--to` pairs preserve path structure across environments.
- You can list, add, and remove rules from CLI or Web UI and validate behavior in **Traffic**.
- Overlapping rules require a clear testing plan so you always know which target wins.

---

## Next Steps

- Combine redirects with **mock rules** to stub only a subset of endpoints while the rest hit a real backend.
- Read traffic-rule docs for **regex** match types when path patterns are more complex than `*`.
- Try the [breakpoint example](../breakpoint-inspect-modify/) when you need to pause and edit individual requests instead of bulk rerouting.
