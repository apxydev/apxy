# Extracting Specific Data from API Responses

Large JSON responses bury the signal—user names, error codes, first cart line items—in thousands of lines. APXY’s JSONPath helper lets you pull exactly the paths you need from captured traffic so your agent never pastes megabytes of JSON into chat.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: JSONPath extraction, Traffic inspection, SSL interception | **Requires**: Free

## Scenario

Your API returns massive JSON payloads: nested user profiles, product catalogs, feature-flag blobs, or configuration objects. You already captured the exchange in APXY, but scrolling the full response is slow and noisy. You want a few concrete fields—top-level, deeply nested, or inside arrays—without exporting the whole body.

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

---

## Track A: Agent + CLI Workflow

JSONPath in APXY is primarily a **CLI** feature: you pass a traffic record ID and a path expression (gjson-style paths). The examples below use record ID `k9m8n7p6`—substitute the ID from your own `apxy logs list` or `search`.

> **Command prefix:** Use **`apxy logs jsonpath`** (some older notes may say `apxy logs jsonpath`; the `traffic` group is the supported path).

### Step 1: Capture a request with a large JSON response

**Tell your agent:**

> "I'll use the app against api.myapp.com through the proxy. List the last few traffic records so we can pick one with a fat JSON response."

**Your agent runs:**

```bash
apxy logs list --limit 15
```

**Example (abbreviated)**

```text
ID         Method  Path                      Status
k9m8n7p6   GET     /v1/users/me/profile      200
...
```

### Step 2: Extract a top-level field

**Tell your agent:**

> "From record k9m8n7p6’s response, show only the top-level `display_name` field."

**Your agent runs:**

```bash
apxy logs jsonpath --id k9m8n7p6 --path "display_name" --scope response
```

**Example output**

```text
"Avery Chen"
```

### Step 3: Extract a nested field

**Tell your agent:**

> "Same record—pull the city from the nested address object."

**Your agent runs:**

```bash
apxy logs jsonpath --id k9m8n7p6 --path "address.city" --scope response
```

**Example output**

```text
"Austin"
```

### Step 4: Extract from an array (first element)

**Tell your agent:**

> "The profile includes a `recent_orders` array. I need the product name from the first order only."

**Your agent runs:**

```bash
apxy logs jsonpath --id k9m8n7p6 --path "recent_orders.0.product_name" --scope response
```

**Example output**

```text
"APXY Pro License"
```

> **Path syntax note:** APXY uses gjson-style paths, not bracket syntax. Prefer `items.0.name` instead of `items[0].name`, and `items.#.price` instead of `items[*].price` (see Step 5).

### Step 5: Extract from every element in an array

**Tell your agent:**

> "List the `price` field for all items in the `cart.items` array."

**Your agent runs:**

```bash
apxy logs jsonpath --id k9m8n7p6 --path "cart.items.#.price" --scope response
```

**Example output**

```text
[29, 49, 9.99]
```

### Step 6: Compare multiple fields in one session

**Tell your agent:**

> "For the same record, print `account_tier`, then `usage.api_calls_this_month`, so we can compare plan vs usage."

**Your agent runs:**

```bash
apxy logs jsonpath --id k9m8n7p6 --path "account_tier" --scope response
apxy logs jsonpath --id k9m8n7p6 --path "usage.api_calls_this_month" --scope response
```

**Example output**

```text
"pro"
18432
```

To read from the **request** body instead (for example posted JSON), set `--scope request`:

```bash
apxy logs jsonpath --id k9m8n7p6 --path "filters.query" --scope request
```

**Example output**

```text
"status:active"
```

---

## Track B: Web UI Workflow

JSONPath is most powerful on the CLI; the Web UI is still useful to **pick the record** and **eyeball context** before you copy an ID for `jsonpath`.

### Step 1: Traffic list

Open **http://localhost:8082** → **Traffic**. Click the row whose JSON response you want to mine.

> screenshots/01-traffic-pick-json-record.png

### Step 2: Response tab and JSONPath bar

Open the **Response** tab. Scroll the formatted JSON if needed, or use the **JSONPath** / search control (when available) to type a path such as `address.city` or `items.0.sku` and see the matching fragment inline.

> screenshots/02-response-jsonpath-bar.png

### Step 3: Copy the record ID for the agent

Note the record identifier shown in the detail panel (or row). Paste it to your agent with the path you care about so it can run `apxy logs jsonpath` for repeatable, log-friendly output.

> screenshots/03-record-id-for-cli.png

That keeps large bodies out of chat while preserving exact values for debugging.

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — Why huge JSON is painful in proxies and chat logs
- 1:00 — Capture + pick a record ID from list or search
- 2:00 — Top-level vs nested paths (`address.city`)
- 3:00 — Arrays: first item vs `#` wildcards
- 4:00 — Web UI: Response tab + JSONPath helper

---

## What You Learned

- Pulling scalar and nested values with **`apxy logs jsonpath`** and **`--scope request|response`**
- Addressing array elements with gjson-style paths (`.0`, `.1`, `.#`)
- Using the Web UI to choose a record, then the CLI for precise, copy-paste extracts

---

## Next Steps

- [Debugging GraphQL APIs](../../debugging/debug-graphql/) — JSONPath on `data.*` and request `variables`
- [Debug Slow API](../../debugging/debug-slow-api/) — Large payloads, latency, and redundant fields
- [Agent Debug 500 Errors](../../ai-agent/agent-debug-500-errors/) — Combine search, `show`, and jsonpath on error bodies
