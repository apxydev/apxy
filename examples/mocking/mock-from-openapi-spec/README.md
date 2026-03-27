# Generating Mocks from an OpenAPI Spec

Import your team's OpenAPI document into APXY so traffic can be validated against the contract while you add mocks that match the same paths and schemas.

**Difficulty**: Intermediate | **Time**: ~15 minutes | **Features used**: Mock rules, Schema validation, SSL interception | **Requires**: Free

## Scenario

Backend published `openapi.yaml` for the new **Orders** API under `https://api.myapp.com`. You want APXY to **understand** that contract (import), **check** captured requests and responses against it, and **mock** key operations (`GET /api/orders`, `GET /api/orders/{id}`, `POST /api/orders`) with bodies that match the documented models. This example uses the real CLI command `apxy schema import` (there is no `schema load` subcommand).

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- An OpenAPI 3 file in this folder or nearby, for example `./openapi.yaml`, describing `https://api.myapp.com` paths
- Optional: `/etc/hosts` mapping for `api.myapp.com`

**Note:** `apxy rules mock import` from a JSON template is a **Pro** feature. On Free, add mocks with `apxy rules mock add` as shown below.

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

> Best for: tying schema IDs to validate commands and hand-authored mocks.

### Step 1: Import the OpenAPI spec

**Tell your agent:**

> "Import the OpenAPI file openapi.yaml as schema name orders-api."

**Your agent runs:**

```bash
apxy schema import --name "orders-api" --file ./openapi.yaml
```

Agent shows a success line with import metadata (exact wording varies by version).

### Step 2: List schemas and copy the schema id

**Tell your agent:**

> "List imported schemas in JSON and tell me the id for orders-api."

**Your agent runs:**

```bash
apxy schema list
```

Agent finds something like:

```json
[
  {
    "id": "a1b2c3d4",
    "name": "orders-api",
    ...
  }
]
```

Use that **id** as `<schema-id>` below.

### Step 3: Generate traffic (or use mocks) for validation

**Tell your agent:**

> "Add mocks for GET /api/orders and POST /api/orders that look like the spec, then curl them so we have traffic."

**Your agent runs:**

```bash
apxy rules mock add --name "orders-list" --url "https://api.myapp.com/api/orders" --method GET --match exact --status 200 --body '{"orders":[{"id":"ord_1","status":"open","total_cents":4999}],"next_cursor":null}'
apxy rules mock add --name "orders-create" --url "https://api.myapp.com/api/orders" --method POST --match exact --status 201 --body '{"id":"ord_new","status":"open","total_cents":0}'
curl -sS "https://api.myapp.com/api/orders"
curl -sS -X POST "https://api.myapp.com/api/orders" -H "Content-Type: application/json" -d '{"customer_id":"cus_123"}'
```

### Step 4: Find a traffic record id

**Tell your agent:**

> "List the last few APXY logs and pick the POST /api/orders record id."

**Your agent runs:**

```bash
apxy logs list --limit 10
```

Agent reports an **id** column value to use as `<record-id>`.

### Step 5: Validate the record against the schema

**Tell your agent:**

> "Validate record <record-id> against schema <schema-id>."

**Your agent runs:**

```bash
apxy schema validate --record-id <record-id> --schema-id <schema-id>
```

Agent shows validation output: pass/fail and, on failure, paths and messages that point to contract drift.

### Step 6: Optional -- batch check recent traffic

**Tell your agent:**

> "Validate the most recent 20 traffic records against all imported schemas."

**Your agent runs:**

```bash
apxy schema validate-recent --limit 20
```

Agent summarizes how recent captures align with **all** imported schemas.

### Step 7: Mock GET /api/orders/{id} with wildcard

Align the JSON fields with your spec's `Order` schema.

**Tell your agent:**

> "Add a wildcard GET mock for /api/orders/* returning a single order with line items, matching the spec's Order schema."

**Your agent runs:**

```bash
apxy rules mock add --name "orders-by-id" --url "https://api.myapp.com/api/orders/*" --method GET --match wildcard --priority 0 --status 200 --body '{"id":"ord_1","status":"shipped","line_items":[{"sku":"SKU-1","qty":2}],"total_cents":4999}'
```

### Step 8: List mocks

**Tell your agent:**

> "List all mock rules to confirm the orders mocks are active."

**Your agent runs:**

```bash
apxy rules mock list
```

---

## Track B: Web UI Workflow

> Best for: browsing schema details and validation results side by side with traffic.

### Step 1: Proxy + dashboard

```bash
apxy proxy start --ssl-domains api.myapp.com
```

Open **http://localhost:8082**.

> screenshots/01-dashboard.png

### Step 2: Import schema from the UI (if your build exposes it)

Navigate to the **Schemas** (or **Settings → Schemas**) area, **Import** from `./openapi.yaml`, name it `orders-api`. If the Web UI does not expose import yet, run `apxy schema import` from Track A and refresh.

> screenshots/02-schema-imported-orders.png

### Step 3: Create mocks from the contract

**Rules → Mock Rules**: add rules for list, create, and get-by-id as in Track A, pasting example payloads from the OpenAPI **Examples** section when available.

> screenshots/03-mock-rules-orders.png

### Step 4: Traffic and validation

Open **Traffic**, select a captured **GET** or **POST** to `/api/orders`, and use any **Validate against schema** action your UI provides; otherwise run `apxy schema validate` from the CLI with ids copied from the list views.

> screenshots/04-traffic-schema-validate.png

### Step 5: Stop

```bash
apxy stop
```

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- `schema import` → `schema list` → capture → `schema validate`
- Web UI schema + mock + traffic flow

---

## What You Learned

- `apxy schema import --file` / `--url` registers OpenAPI for offline validation
- `apxy schema list` and `apxy schema show --id` discover **schema-id**
- `apxy schema validate --record-id --schema-id` checks one capture; `validate-recent` batches
- Mocks are still created with `apxy rules mock add` on Free (import-from-template is Pro)
- Wildcard URLs model `{id}` path segments the same way as other mocking guides

## Next Steps

- [Serving Mock Responses from Files](../mock-large-responses-from-files/) -- huge example payloads
- [Building UI Without a Backend](../mock-backend-for-frontend/) -- full CRUD patterns
- [Replay and Diff](../../replay-and-diff/) -- regression testing with captured traffic
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- trust and domains
