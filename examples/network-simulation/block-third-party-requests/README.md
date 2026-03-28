# Filtering Out Noisy Third-Party Traffic

Stop wading through analytics pixels and support widgets in your capture list—block or allow-list host patterns so APXY shows the API surface you actually own.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Filter rules, SSL interception | **Requires**: Free

## Scenario

Your proxy is capturing everything—Google Analytics, Facebook pixel, Sentry errors, Intercom widgets. You only care about your own API traffic. Use filter rules to block the noise and focus on what matters, or flip to allow-list mode when only `api.myapp.com` should pass through.

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

Filter rules use **type** (`block` or `allow`) and a **target** domain pattern. Blocking drops matching hosts early; allow rules are useful when you want only specific domains to traverse the proxy while everything else is denied (exact semantics depend on how your project stacks rules—start with block rules for analytics noise).

### Step 1: Block Google Analytics hosts

**Tell your agent:**

> "Block traffic to Google Analytics domains so they never clutter captures."

**Your agent runs:**

```bash
apxy rules filter set --type block --target "*.google-analytics.com"
```

Reload your app; confirm fewer rows in traffic logs and that your first-party flows still work.

### Step 2: Block Facebook and Sentry

**Tell your agent:**

> "Also block Facebook pixel endpoints and Sentry ingest."

**Your agent runs:**

```bash
apxy rules filter set --type block --target "*.facebook.com"
apxy rules filter set --type block --target "*.sentry.io"
```

If your SDKs use region-specific subdomains, add another `--target` line per pattern (e.g. `o123.ingest.sentry.io`).

### Step 3: List filters and remove mistakes

**Tell your agent:**

> "Show all filter rules so I can copy IDs and verify patterns."

**Your agent runs:**

```bash
apxy rules filter list
```

Remove one rule by ID:

```bash
apxy rules filter remove --id <FILTER_RULE_ID>
```

Or clear every filter:

```bash
apxy rules filter remove --all
```

### Step 4 (optional): Allow-list only your API

**Tell your agent:**

> "Instead of blocking trackers, allow only api.myapp.com through this filter style—I'll remove conflicting block rules first."

**Your agent runs:**

```bash
apxy rules filter remove --all
apxy rules filter set --type allow --target "api.myapp.com"
```

Allow-listing is powerful and easy to misconfigure: you may block OAuth, CDNs, or websockets your app needs. Prefer **block** rules for known noise until you are sure of the full host inventory.

---

## Track B: Web UI Workflow

### Step 1: Open Filter rules

Navigate to **Rules** → **Filter** (or **Traffic filters** depending on build).

> screenshots/01-filter-rules.png

### Step 2: Add block rows for analytics

Create a **block** rule with target `*.google-analytics.com`. Repeat for `*.facebook.com` and `*.sentry.io`.

> screenshots/02-filter-block-analytics.png

### Step 3: Validate Traffic

Open **Traffic**, hard-refresh the app, and confirm blocked hosts no longer appear (or show as blocked per your UI). Scroll a page that used to fire dozens of pixel requests.

> screenshots/03-traffic-after-filters.png

### Step 4: Allow-only experiment (advanced)

Remove block rules, add a single **allow** rule for `api.myapp.com`, and reload. If the app breaks, note which third-party host you forgot—either add another allow rule or revert to block-list mode.

> screenshots/04-filter-allow-api-only.png

---

## Video Walkthrough

*[YouTube link -- coming soon]*

- 0:00 — Proxy with SSL for `api.myapp.com`
- 1:00 — CLI: three `apxy rules filter set --type block` calls
- 2:30 — `apxy rules filter list` and selective `remove`
- 3:30 — Web UI filter table and Traffic diff
- 4:30 — Optional allow-list pitfall callout

---

## What You Learned

- Creating host-pattern **block** filters with `apxy rules filter set --type block --target "pattern"`
- Listing and removing rules via `apxy rules filter list` and `apxy rules filter remove`
- Optional **allow** filtering for API-only focus—and why it requires a complete host map
- Pairing filters with SSL capture so decrypted first-party traffic stays visible while noise stays out

## Next Steps

- [Debug Slow API](../../debugging/debug-slow-api/) — Once noise is gone, rank what remains
- [Simulate Slow Network](../simulate-slow-network/) — Throttle the API you kept
- [Quickstart 5 Minutes](../../quickstart-5-minutes/) — Full proxy + UI orientation
