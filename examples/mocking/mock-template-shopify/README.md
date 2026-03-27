# Mocking Shopify Storefront API

Build a headless storefront against GraphQL on `your-store.myshopify.com` without a paid dev store or live inventory. APXY returns Storefront API-shaped JSON for `POST /api/2024-01/graphql.json` (adjust API version string to match your client).

**Difficulty**: Advanced | **Time**: ~30 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

You query products, run cart mutations, and step through checkout-related fields using Shopify's **Storefront API**. Each request is typically a single `POST` with a JSON body containing `query` and `variables`. For local work you want stable products, carts, and controlled GraphQL errors (`userErrors`, throttling) without Shopify rate limits. There is no bundled `mock-templates/shopify/` yet; use **`apxy rules mock add`** with a wildcard path and optional header conditions to branch scenarios, or split into multiple rules with different body matchers if your APXY build supports them.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example. Replace `your-store` with your development shop subdomain.

**Tell your agent:**

> "Start APXY with SSL enabled for your-store.myshopify.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains your-store.myshopify.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

### What you will mock

| Concern | GraphQL operations (examples) |
|---------|-------------------------------|
| Catalog | `products` query, `product` by handle |
| Cart | `cartCreate`, `cartLinesAdd`, `cartLinesUpdate` |
| Checkout | Fields your client reads after checkout creation (mock minimal shapes) |
| Errors | Top-level `errors` array or `userErrors` on mutation payloads |

---

## Track A: Agent + CLI Workflow

> Storefront API version in the path (`2024-01`, `2025-01`, etc.) must match your client. Adjust the `--url` below accordingly.

### Step 1: Mock products query (happy path)

Tell your agent:

> "Add POST mock for graphql.json returning a products connection."

Your agent runs:

```bash
apxy rules mock add \
  --name "Shopify: products query" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact \
  --method POST \
  --status 200 \
  --body '{"data":{"products":{"edges":[{"node":{"id":"gid://shopify/Product/100","title":"Mock Tee","handle":"mock-tee","priceRange":{"minVariantPrice":{"amount":"19.99","currencyCode":"USD"}}}}]}}}'
```

Real responses are larger; grow this stub as your selection set requires.

### Step 2: Mock cart create

Tell your agent:

> "Add a second rule for cartCreate success (simplified payload)."

Your agent runs:

```bash
apxy rules mock add \
  --name "Shopify: cartCreate" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact \
  --method POST \
  --header-conditions "X-APXY-Scenario=cart_create" \
  --status 200 \
  --body '{"data":{"cartCreate":{"cart":{"id":"gid://shopify/Cart/mock-cart-id","checkoutUrl":"https://your-store.myshopify.com/cart/c/mock-cart-id","lines":{"edges":[]}},"userErrors":[]}}}'
```

Your client must send the scenario header during tests, **or** you rely on separate rules with body-based matching if available.

### Step 3: GraphQL top-level error

Tell your agent:

> "Add rule for throttled scenario returning 200 with errors array."

Your agent runs:

```bash
apxy rules mock add \
  --name "Shopify: GraphQL throttled" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact \
  --method POST \
  --header-conditions "X-APXY-Scenario=throttled" \
  --status 200 \
  --body '{"errors":[{"message":"Throttled","extensions":{"code":"THROTTLED"}}]}'
```

### Step 4: User errors on mutation

Tell your agent:

> "Add cart mutation failure with userErrors."

Your agent runs:

```bash
apxy rules mock add \
  --name "Shopify: cartLinesAdd userErrors" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact \
  --method POST \
  --header-conditions "X-APXY-Scenario=cart_line_error" \
  --status 200 \
  --body '{"data":{"cartLinesAdd":{"cart":null,"userErrors":[{"field":["lines","0","quantity"],"message":"Quantity must be positive"}]}}}'
```

### Step 5: Curl smoke test

Tell your agent:

> "POST a minimal GraphQL products query through the proxy."

Your agent runs:

```bash
curl -s -X POST "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  -H "Content-Type: application/json" \
  -H "X-Shopify-Storefront-Access-Token: mock-token" \
  -d '{"query":"{ products(first:1){ edges{ node{ title } } } }"}'
```

### Step 6: Unify with import JSON (recommended)

Maintaining many GraphQL branches as separate CLI one-liners gets unwieldy. Create `rules.json` in this folder (array of rule objects with `url_pattern`, `method`, `response_body`, optional `header_conditions`) and run:

**Tell your agent:**

> "Import all Shopify mock rules from rules.json."

**Your agent runs:**

```bash
apxy rules mock import --file rules.json
```

Align field names with `mock-templates/_template/rules.json` in the APXY repo.

### Step 7: List and remove rules

**Tell your agent:**

> "List all mock rules and remove a Shopify rule by id."

**Your agent runs:**

```bash
apxy rules mock list
apxy rules mock remove --id <RULE_ID>
```

---

## Track B: Web UI Workflow

### Step 1: Proxy + Web UI

Start with `your-store.myshopify.com` in `--ssl-domains`. Open **http://localhost:8082**.

> screenshots/01-dashboard-shopify-mock.png

### Step 2: GraphQL request body

Trigger a Storefront request from your app. In **Traffic**, open the POST row and read the **Request** JSON: `query` + `variables`.

> screenshots/02-shopify-graphql-request.png

### Step 3: Data vs errors

Compare a happy `data` response with a `throttled` scenario (top-level `errors`).

> screenshots/03-shopify-graphql-errors.png

### Step 4: Mutation userErrors

Run a cart mutation with `X-APXY-Scenario: cart_line_error` and verify `userErrors` in the response panel.

> screenshots/04-shopify-user-errors.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Single-endpoint GraphQL mocks + curl: 0:00 - 10:00
- Scenario headers + Web UI request inspection: 10:00 - 22:00

---

## What You Learned

- How to intercept TLS for a `*.myshopify.com` Storefront host
- Why one URL (`.../graphql.json`) often maps to **multiple** mock rules (headers / priorities / future body match)
- How to return both HTTP-level success with GraphQL `errors` and mutation `userErrors`
- How to graduate from CLI rules to `rules.json` for larger selection sets

## Next Steps

- Mirror Admin API on `admin.shopify.com` with a second domain in `--ssl-domains`
- Snapshot a real `products` response and trim to your selection set
- [API Mocking](../../api-mocking/) -- general mocking
- Share templates via [apxy-public](https://github.com/apxydev/apxy-public) when stable
