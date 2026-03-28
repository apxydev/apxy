# AI Agent Configures Mock Environment

Shipping a feature that touches Stripe, GitHub, and your internal API usually means three sets of credentials, flaky sandboxes, and rate limits. Point your agent at APXY mock templates plus a few **`rules mock add`** calls to stand up a coherent fake backend on your laptop.

**Difficulty**: Advanced | **Time**: ~15 minutes | **Features used**: Mock rules, Mock templates, Multi-domain SSL interception | **Requires**: Free

## Scenario

You are starting a feature that depends on **Stripe**, **GitHub**, and **api.myapp.com**. Instead of wiring three live services on day one, you ask your agent to configure a **mock environment**: import curated template rules for the external vendors, add bespoke mocks for internal JSON shapes, list rules to confirm precedence, and verify each hostname returns what your client code expects.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with the APXY skill installed (see [Using APXY as a Claude Code / Cursor Skill](../agent-skill-reference/))
- This repository (or a copy of its **`mock-templates/`** files) on disk so import paths resolve

### Plan note

**`apxy rules mock import`** is a **Pro** feature in licensed builds. On **Free**, open the same JSON under **`mock-templates/`** and have your agent create each rule with **`apxy rules mock add --name ... --url ...`** using the URL, method, status, and body from each template entry. **`apxy traffic sql`** (if used for verification) is also **Pro**; use **`apxy traffic logs search`** on Free.

## Before You Start

Start the proxy with SSL enabled for **all** hostnames this feature will call:

**Tell your agent:**

> "Start APXY with SSL enabled for api.stripe.com, api.github.com, and api.myapp.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.stripe.com,api.github.com,api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

Run commands from the **`apxy`** repository root so relative paths like **`mock-templates/...`** match this monorepo layout. If you use a global install without the repo, pass absolute **`--file`** paths to your checkout.

---

## Track A: Agent + CLI Workflow

> Order matters: import broad vendor templates first, then add **higher-priority** or more specific internal mocks if needed (see **`apxy rules mock add --priority`**).

### Step 1: Confirm proxy and SSL host list

**Tell your agent:**

> "Confirm the proxy is running and SSL domains include Stripe, GitHub, and our API."

**Your agent runs:**

```bash
apxy proxy status
```

If SSL was not started with all three hosts, restart **`apxy proxy start`** with the comma-separated list from **Before You Start**.

### Step 2: Import Stripe template rules

**Tell your agent:**

> "Import the Stripe mock template from this repo's mock-templates directory."

**Your agent runs:**

```bash
apxy rules mock import --file mock-templates/stripe/rules.json
```

Each imported rule prints a line; the agent notes rule names for later cleanup.

### Step 3: Import GitHub API template rules

The repository uses **`github-api`** as the template folder name.

**Tell your agent:**

> "Import the GitHub API mock template rules next."

**Your agent runs:**

```bash
apxy rules mock import --file mock-templates/github-api/rules.json
```

### Step 4: Add internal API mocks your feature needs

Templates rarely know your private routes. Add explicit mocks for **`api.myapp.com`** endpoints your UI will call.

**Tell your agent:**

> "Mock GET https://api.myapp.com/api/users with a 200 JSON list of two fake users for local UI work."

**Your agent runs:**

```bash
apxy rules mock add --name "local-users" \
  --url "https://api.myapp.com/api/users" \
  --method GET \
  --status 200 \
  --body '{"users":[{"id":"u1","name":"Ada"},{"id":"u2","name":"Bob"}]}'
```

Repeat with additional **`apxy rules mock add`** commands for other internal routes (orders, feature flags, etc.) using bodies that match your OpenAPI or fixtures.

### Step 5: List and review mock rules

**Tell your agent:**

> "List all mock rules so we see IDs, names, URL patterns, and priorities."

**Your agent runs:**

```bash
apxy rules mock list
```

The agent checks for duplicates, wrong **`--match`** type (exact vs wildcard), and accidental overlaps between Stripe/GitHub templates and your internal URLs.

### Step 6: Verify Stripe-shaped traffic

**Tell your agent:**

> "Make a request through the proxy to a Stripe URL covered by the template and confirm we get a mocked status and JSON."

**Your agent runs:**

```bash
curl -x http://127.0.0.1:8080 https://api.stripe.com/v1/customers/cus_mock
```

(Adjust path to a route your imported rules actually match.) Then:

```bash
apxy traffic logs search --query "stripe"
```

### Step 7: Verify GitHub and internal mocks

**Tell your agent:**

> "Hit a GitHub API path we mocked, then hit /api/users on our host, both through the proxy."

**Your agent runs:**

```bash
curl -x http://127.0.0.1:8080 https://api.github.com/user
curl -x http://127.0.0.1:8080 https://api.myapp.com/api/users
apxy traffic logs search --query "github"
apxy traffic logs search --query "users"
```

Optional SQL sanity check when licensed:

```bash
apxy traffic sql query "SELECT host, mocked, COUNT(*) FROM traffic_logs GROUP BY host, mocked"
```

### Step 8: Document teardown for the team

**Tell your agent:**

> "Summarize which rules came from imports vs manual add, and how to remove them after the feature merges."

**Your agent runs:**

```bash
apxy rules mock list
```

Removal is per id:

```bash
apxy rules mock remove --id RULE_ID
```

Or reset everything in a scratch environment:

```bash
apxy rules mock clear
```

(Use **`clear`** only when you intend to drop **all** mocks.)

---

## Track B: Web UI Workflow

You can follow along in the Web UI: mock rules appear alongside traffic captures, so you can visually confirm that requests to **api.stripe.com**, **api.github.com**, and **api.myapp.com** show as **mocked** in the traffic list. The detail panel shows canned response bodies matching your templates. Editing or toggling rules in the UI is optional; the CLI remains the source of truth for repeatable agent scripts.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Agent + CLI: multi-host SSL, double import, internal adds, verification
- Web UI: mocked badge and response inspection

---

## What You Learned

- How one **`apxy proxy start --ssl-domains`** line terminates TLS for multiple vendors at once
- How **`apxy rules mock import`** loads curated **`mock-templates`** packs for Stripe and GitHub
- How **`apxy rules mock add`** fills gaps for private **`api.myapp.com`** contracts
- How **`apxy rules mock list`**, **`search`**, and **`curl`** through the proxy prove the environment before you write feature code

---

## Next Steps

- [Mock template: Stripe](../../mocking/mock-template-stripe/) -- human-oriented deep dive on the Stripe pack
- [AI Agent Creates Mocks to Unblock While Fixing](../agent-mock-while-fixing/) -- single-endpoint temp mocks
- [API Mocking](../../api-mocking/) -- general mocking concepts
