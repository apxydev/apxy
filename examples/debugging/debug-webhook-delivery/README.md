# Debugging Webhook Integrations

See the exact HTTP Stripe (or any provider) sends to your handler, your status code and body in return, and replay a failed delivery to prove the fix.

**Difficulty**: Intermediate | **Time**: ~15 minutes | **Features used**: Traffic search, Request replay, Traffic diff, SSL interception | **Requires**: Free

## Scenario

Stripe reports failed webhook deliveries to `https://api.myapp.com/webhooks/stripe`. Your logs say “500” but not why. You need the raw signing secret verification inputs, payload JSON, response body your app returned, and a safe way to replay one delivery after you patch the handler—all visible in APXY without adding println debugging to production.

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

### Step 1: Ensure webhook traffic hits the machine running APXY

**Tell your agent:**

> "I'll trigger a test webhook from the provider dashboard or use Stripe CLI forwarding so traffic passes through the proxy—confirm we're capturing."

For local dev, common patterns include `stripe listen --forward-to https://api.myapp.com/...` with hosts file / tunnel, or pointing a staging URL through your proxy—adapt to your setup.

### Step 2: Search for webhook requests

**Tell your agent:**

> "Search captured traffic for webhook-related URLs or bodies."

**Your agent runs:**

```bash
apxy logs search --query "webhook"
```

Agent finds rows such as:

```
ID    METHOD   URL                                           STATUS
55    POST     https://api.myapp.com/webhooks/stripe         500
54    POST     https://api.myapp.com/webhooks/stripe         200
```

### Step 3: Inspect the failed delivery

**Tell your agent:**

> "Show record 55 in full—request headers (especially Stripe-Signature), body, and response."

**Your agent runs:**

```bash
apxy logs show --id 55
```

Agent reports:

- Request headers: `Stripe-Signature`, `Content-Type`, idempotency keys if present
- Body: event `type`, `id`, nested object
- Response: your **500** body and stack trace fragment if your framework returns it

Redact secrets before sharing externally.

### Step 4: Compose a replay POST with a trimmed body

**Tell your agent:**

> "Replay a POST to the webhook URL with the same JSON shape as capture (I'll paste from show output or use export)."

**Your agent runs:**

```bash
apxy tools request compose --method POST \
  --url "https://api.myapp.com/webhooks/stripe" \
  --body '{"id":"evt_test_123","type":"customer.subscription.updated","data":{"object":{}}}' \
  --headers '{"Content-Type":"application/json","Stripe-Signature":"t=...,v1=..."}'
```

Use a **test** signature from Stripe docs or regenerate via Stripe CLI; do not reuse production signing secrets in chat logs.

Agent prints the new status—expect **200** after the fix.

### Step 5: Diff failed vs successful delivery

**Tell your agent:**

> "Compare the failed 500 row with a known-good 200 row—request scope first."

**Your agent runs:**

```bash
apxy logs diff --id-a 55 --id-b 54 --scope request
```

Then optionally `--scope response` to see how error payloads differ.

Agent highlights header or body differences (e.g. missing `customer` expansion, wrong API version header).

### Step 6: Re-run provider delivery

After deploying, trigger “Resend” from the provider UI or CLI and confirm a new row shows **200** in `apxy logs search --query "webhook"`.

---

## Track B: Web UI Workflow

### Step 1: Traffic filtered by path

Open **http://localhost:8082**. Go to **Traffic**. Scan for **POST** to `/webhooks/stripe` (or your path).

> screenshots/01-traffic-webhook-rows.png

### Step 2: Open the 500 row

**Traffic** -> click the failed delivery -> **Request** tab: verify JSON payload and signature header.

> screenshots/02-webhook-request-headers.png

### Step 3: Response tab

**Traffic** -> click the failed delivery -> **Response** tab. Read your server’s **500** body—often the fastest way to see validation vs DB errors.

> screenshots/03-webhook-500-response.png

### Step 4: Compare with a 200 row

Open a successful row side-by-side (two windows or sequential). Compare event `type` and critical fields.

> screenshots/04-webhook-200-vs-500.png

### Step 5: Compose in UI

Go to **Compose** -> POST a test body after fixes; confirm new row is **200**.

> screenshots/05-compose-webhook-replay.png

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — SSL + capturing inbound provider traffic
- 4:00 — CLI: `search`, `show`, `compose`, `diff`
- 8:00 — Web UI walkthrough of signature + payload

---

## What You Learned

- Using `apxy logs search --query "webhook"` to isolate integration traffic
- Reading provider headers and JSON bodies with `apxy logs show`
- Reproducing failures with `apxy tools request compose` (with test credentials)
- Using `apxy logs diff` to contrast failing vs succeeding deliveries

## Next Steps

- [API Mocking](../../api-mocking/) — Stub external calls while you harden webhooks
- [Debug Auth Tokens](../debug-auth-tokens/) — If webhooks call authenticated internal APIs
- [Replay and Diff](../../replay-and-diff/) — Formal regression after handler changes
