# Mocking Stripe's Payment API

Develop payment flows against realistic Stripe-shaped JSON without flipping every workspace into Stripe test mode or burning API calls. APXY's Stripe mock template returns canned charges, payment intents, customers, and error paths while your app still talks to `https://api.stripe.com`.

**Difficulty**: Intermediate | **Time**: ~25 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

You are integrating Stripe (checkout, subscriptions, or custom charges) and want fast iteration: your SDK or HTTP client should hit the real hostname, but responses should be deterministic and work offline. Apply the bundled Stripe template so `POST /v1/charges`, `POST /v1/payment_intents`, and customer endpoints succeed with mock bodies, while optional `X-APXY-Scenario` headers let you exercise `card_declined` and other failure modes. The template does not include every Stripe error code (for example `expired_card`); you can clone a rule and adjust the JSON in a follow-up step.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.stripe.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.stripe.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

### What this template covers

| Area | Endpoints / behavior |
|------|----------------------|
| Charges | `POST /v1/charges`, list/get charges |
| Payment intents | Create, confirm (success), list/get |
| Customers | Create, list, retrieve |
| Errors | Scenario-driven responses including `card_declined` on confirm (via `X-APXY-Scenario: card_declined`), plus unauthorized, rate limit, idempotency conflict, and more |

---

## Track A: Agent + CLI Workflow

> Best for: reproducible steps and scripting. Commands assume your shell's current directory is the **root of the APXY examples repo** (where `mock-templates/` lives).

### Step 1: Import the Stripe mock rules

Tell your agent:

> "Import the Stripe mock template from mock-templates/stripe/rules.json into APXY."

Your agent runs:

```bash
apxy mock import --file mock-templates/stripe/rules.json
```

### Step 2: Verify rules are loaded

Tell your agent:

> "List mock rules and confirm the Stripe rules are present."

Your agent runs:

```bash
apxy mock list
```

### Step 3: Create a charge through the proxy

Tell your agent:

> "Send a POST to Stripe's charges API through the proxy with amount 2000 and currency usd, using a dummy Bearer token."

Your agent runs:

```bash
curl -X POST https://api.stripe.com/v1/charges \
  -H "Authorization: Bearer sk_test_mock" \
  -d amount=2000 \
  -d currency=usd
```

You should receive a `200` JSON body with a mock `ch_test_*` id and `succeeded` status.

### Step 4: Create a payment intent and test card decline

Tell your agent:

> "POST to create a payment intent, then POST to confirm it with header X-APXY-Scenario set to card_declined to simulate a declined card."

Your agent runs:

```bash
curl -X POST https://api.stripe.com/v1/payment_intents \
  -H "Authorization: Bearer sk_test_mock" \
  -d amount=2000 \
  -d currency=usd

curl -X POST "https://api.stripe.com/v1/payment_intents/pi_test_123/confirm" \
  -H "Authorization: Bearer sk_test_mock" \
  -H "X-APXY-Scenario: card_declined"
```

The confirm call should return `402` with a Stripe-style `card_error` and `code: card_declined`. To practice an `expired_card`-style response later, duplicate that rule in the template or add a new rule with `apxy mock add` and a different scenario header value.

### Step 5: Fetch a customer

Tell your agent:

> "GET a customer by id through the proxy."

Your agent runs:

```bash
curl -s "https://api.stripe.com/v1/customers/cus_test_123" \
  -H "Authorization: Bearer sk_test_mock"
```

### Step 6: Customize or remove rules

Tell your agent:

> "Show how to remove one mock rule by id after listing rules."

Your agent runs:

```bash
apxy mock list
apxy mock remove --id <RULE_ID>
```

Use `apxy mock add` with `--header-conditions` when you need new branches (for example a dedicated `expired_card` scenario) without editing JSON on disk.

---

## Track B: Web UI Workflow

> Best for: seeing traffic and mock hits side by side.

### Step 1: Start the proxy and open the Web UI

With SSL enabled for `api.stripe.com` (see **Before You Start**), open **http://localhost:8082** (or your configured Web UI port).

> screenshots/01-dashboard-stripe-mock.png

### Step 2: Run the same curl requests as Track A

Execute the charge and payment-intent requests from a terminal. Each request should appear in the traffic list with decrypted HTTPS bodies.

### Step 3: Inspect a mocked response

Open **Traffic**, click a `POST .../v1/charges` row, and confirm the **Response** tab shows your mock JSON (not a live Stripe error).

> screenshots/02-stripe-mock-response.png

### Step 4: Compare success vs scenario header

Send one normal confirm (no scenario header) and one with `X-APXY-Scenario: card_declined`. In the detail view, compare status codes and error payloads.

> screenshots/03-stripe-scenario-compare.png

### Step 5: Optional — rules overview

If your build exposes mock rules in the UI, locate the Stripe rules and note priorities; otherwise use `apxy mock list` in parallel.

> screenshots/04-mock-rules-stripe.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Import template + first charge: 0:00 - 8:00
- Scenario headers + Web UI traffic: 8:00 - 18:00

---

## What You Learned

- How to enable TLS interception for `api.stripe.com` and route SDK traffic through APXY
- How to import the official `mock-templates/stripe/rules.json` pack and list or remove rules
- How to exercise happy-path charges and payment intents plus a declined-card path via `X-APXY-Scenario`
- How to correlate CLI tests with rows in the Web UI traffic list

## Next Steps

- Add a custom `apxy mock add` rule for `expired_card` or other decline codes
- [API Mocking](../../api-mocking/) -- generic mock patterns
- [Replay and Diff](../../replay-and-diff/) -- capture real Stripe traffic once, then replay against mocks
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- trust CA on additional machines
