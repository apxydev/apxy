# Mocking Twilio SMS & Voice API

Build SMS notifications, status callbacks, and message lookups without sending real texts or paying per segment. APXY returns Twilio-shaped JSON for `Messages.json` while your HTTP client keeps using `https://api.twilio.com`.

**Difficulty**: Advanced | **Time**: ~30 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

You integrate Twilio's 2010 REST API: create messages, poll message status, and later verify your webhook handler receives Twilio-style `POST` callbacks. Real SMS tests cost money and clutter devices. By intercepting TLS for `api.twilio.com`, you can return `201` creates with a fake `sid`, `200` fetches for `GET .../Messages/{Sid}.json`, and optional mock callbacks to your local server URL (captured as outbound traffic or mocked on the Twilio side if your app calls Twilio-hosted URLs). There is no bundled `mock-templates/twilio/` pack yet; define rules with **`apxy mock add`** (or maintain a local `rules.json` and `apxy mock import`).

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.twilio.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.twilio.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

### What you will mock

| Operation | Example path pattern |
|-----------|----------------------|
| Create message | `POST /2010-04-01/Accounts/{AccountSid}/Messages.json` |
| Fetch message | `GET /2010-04-01/Accounts/{AccountSid}/Messages/{MessageSid}.json` |
| Callbacks | Your app may `POST` to Twilio; reverse direction uses your own URL mocks or captured traffic |

Twilio uses form-encoded bodies; mocks return JSON or `application/x-www-form-urlencoded` depending on what your client parses—match the `Content-Type` your code expects.

---

## Track A: Agent + CLI Workflow

> Replace `ACxxxxxxxx` with your dev Account SID string (or a placeholder your tests use).

### Step 1: Mock message create (201)

Tell your agent:

> "Add a wildcard mock for POST Messages.json under Accounts returning 201 Twilio-shaped JSON."

Your agent runs:

```bash
apxy mock add \
  --name "Twilio: create message" \
  --url "https://api.twilio.com/2010-04-01/Accounts/*/Messages.json" \
  --match wildcard \
  --method POST \
  --status 201 \
  --body '{"sid":"SMaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","status":"queued","to":"+1234567890","from":"+1987654321","date_created":"Mon, 01 Jan 2026 12:00:00 +0000","uri":"/2010-04-01/Accounts/ACxxxxxxxx/Messages/SMaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.json"}'
```

### Step 2: Mock message fetch (200)

Tell your agent:

> "Add GET mock for a specific message Sid."

Your agent runs:

```bash
apxy mock add \
  --name "Twilio: get message" \
  --url "https://api.twilio.com/2010-04-01/Accounts/*/Messages/*.json" \
  --match wildcard \
  --method GET \
  --status 200 \
  --body '{"sid":"SMaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","status":"delivered","to":"+1234567890","from":"+1987654321","error_code":null,"date_sent":"Mon, 01 Jan 2026 12:00:05 +0000"}'
```

### Step 3: Simulate send failure (optional)

Tell your agent:

> "Add a second POST rule with header X-APXY-Scenario=send_failed that returns 400 with Twilio error JSON."

Your agent runs:

```bash
apxy mock add \
  --name "Twilio: message create failed" \
  --url "https://api.twilio.com/2010-04-01/Accounts/*/Messages.json" \
  --match wildcard \
  --method POST \
  --header-conditions "X-APXY-Scenario=send_failed" \
  --status 400 \
  --body '{"code":21211,"message":"Invalid To Phone Number","status":400}'
```

Set **priority** so the scenario rule wins over the default `201` rule when the header is present.

### Step 4: Exercise with curl

Tell your agent:

> "POST a form body like Twilio expects to create a message."

Your agent runs:

```bash
curl -s -X POST "https://api.twilio.com/2010-04-01/Accounts/ACxxxxxxxx/Messages.json" \
  -u "ACxxxxxxxx:fake_auth_token" \
  -d "To=%2B1234567890" \
  -d "From=%2B1987654321" \
  -d "Body=hello"
```

Then:

```bash
curl -s -u "ACxxxxxxxx:fake_auth_token" \
  "https://api.twilio.com/2010-04-01/Accounts/ACxxxxxxxx/Messages/SMaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.json"
```

### Step 5: Callback webhooks (architecture note)

Inbound webhooks from Twilio hit **your** public URL, not `api.twilio.com`. To test locally:

- Use a tunnel (ngrok, etc.) and capture real callbacks once, or
- Mock your own `/sms/status` route with APXY rules on your app hostname, or
- Unit-test the handler with static payloads from Twilio docs.

APXY still helps you **inspect** outbound `POST` from your service if it calls Twilio APIs.

### Step 6: List and remove rules

Tell your agent:

> "List mock rules and remove a Twilio rule by id."

Your agent runs:

```bash
apxy mock list
apxy mock remove --id <RULE_ID>
```

---

## Track B: Web UI Workflow

### Step 1: Proxy + Web UI

Start with `api.twilio.com` in `--ssl-domains`. Open **http://localhost:8082**.

> screenshots/01-dashboard-twilio-mock.png

### Step 2: Create message traffic

Run the `POST Messages.json` curl. Expand the row: verify Basic auth headers are visible (treat as sensitive in screenshots).

> screenshots/02-twilio-create-message.png

### Step 3: Status transition

Run `GET .../Messages/{Sid}.json` and confirm `delivered` (or `queued`) in the response body panel.

> screenshots/03-twilio-get-message.png

### Step 4: Failure scenario

Repeat `POST` with `X-APXY-Scenario: send_failed` and confirm `400` + error code in the UI.

> screenshots/04-twilio-send-failed.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Wildcard mocks for create/get: 0:00 - 10:00
- Scenario errors + Web UI: 10:00 - 22:00

---

## What You Learned

- How to terminate TLS for `api.twilio.com` and keep Twilio SDKs working
- How wildcard URL patterns map to Account SID segments in the Twilio REST path
- How to return `201` creates and `200` reads with stable fake Sids
- How webhook testing differs (your URL vs Twilio API host)

## Next Steps

- Add mocks for `Calls.json` or `IncomingPhoneNumbers` using the same pattern
- Share a `rules.json` in [apxy-public](https://github.com/apxydev/apxy-public) when your team stabilizes payloads
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- trust CA on additional machines
- [API Mocking](../../api-mocking/) -- general mock patterns
- [Replay and Diff](../../replay-and-diff/) -- diff a captured real Twilio response against your mock
