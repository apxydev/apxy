# Diagnosing and Fixing CORS Issues

See the browser’s CORS preflight and real responses side by side, then prove a fix by mocking the correct `Access-Control-*` headers before you ship a backend change.

**Difficulty**: Beginner | **Time**: ~10 minutes | **Features used**: Traffic search, Traffic inspection, Mock rules, SSL interception | **Requires**: Free

## Scenario

You are shipping a React app on `http://localhost:3000` that calls `https://api.myapp.com`. The browser console shows a red error: the request was blocked by CORS policy—often after an `OPTIONS` preflight fails or returns the wrong headers. You need to confirm whether the preflight ran, what the API returned, and which headers are missing so you can fix the server or unblock local development with a temporary mock.

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

> Best for: Cursor, Claude Code, Codex, or Copilot. You describe intent; the agent runs APXY commands.

### Step 1: Reproduce the failing call through the proxy

**Tell your agent:**

> "The proxy is running. I'll reload my app and trigger the API call that fails CORS—capture whatever hits api.myapp.com."

**Your agent runs:** (no command—waits for traffic; optionally confirms proxy status)

```bash
apxy status
```

Agent reports that the proxy is listening and that HTTPS to `api.myapp.com` will be decrypted because that host is in `--ssl-domains`.

### Step 2: Find the preflight `OPTIONS` request

**Tell your agent:**

> "Search captured traffic for OPTIONS requests to my API."

**Your agent runs:**

```bash
apxy logs search --query "OPTIONS"
```

Agent shows something like:

```
ID    METHOD   URL                                      STATUS
42    OPTIONS  https://api.myapp.com/v1/profile       404
41    OPTIONS  https://api.myapp.com/v1/profile       204
```

You are looking for the pair: `OPTIONS` (preflight) immediately before the real `GET`/`POST`.

### Step 3: Inspect response headers on the preflight

**Tell your agent:**

> "Show full details for OPTIONS record 42 (use the ID from search)."

**Your agent runs:**

```bash
apxy logs show --id 42
```

Agent reports the response status and headers. Typical CORS problems show up here: `204` or `200` but no `Access-Control-Allow-Origin`, wrong `Access-Control-Allow-Methods`, or missing `Access-Control-Allow-Headers` for `Authorization` / `Content-Type`. The follow-up `GET` or `POST` may show status `200` in APXY while the browser still blocks the page because the preflight failed.

### Step 4: Mock a correct CORS preflight response

**Tell your agent:**

> "Add a mock rule so OPTIONS to https://api.myapp.com/* returns 204 with proper CORS headers for localhost:3000."

**Your agent runs:**

```bash
apxy mock add --name "cors-preflight-localhost" \
  --url "https://api.myapp.com/*" \
  --match wildcard \
  --method OPTIONS \
  --status 204 \
  --headers '{"Access-Control-Allow-Origin":"http://localhost:3000","Access-Control-Allow-Methods":"GET, POST, PUT, DELETE, OPTIONS","Access-Control-Allow-Headers":"Content-Type, Authorization","Access-Control-Max-Age":"86400"}'
```

Agent confirms the rule was created (rule id and summary). This does not replace a real production fix; it unblocks local dev or proves that missing CORS headers are the root cause.

### Step 5: Reload the app and verify

**Tell your agent:**

> "I'll reload the browser. List recent traffic to api.myapp.com and confirm OPTIONS is mocked and the real request succeeds."

**Your agent runs:**

```bash
apxy logs search --query "api.myapp.com" --limit 10
```

Agent finds the new `OPTIONS` row, `mocked` true if your UI surfaces that, and the subsequent `GET`/`POST` with status 200. In the browser, the CORS error should disappear for the mocked preflight path.

### Step 6: Clean up

**Tell your agent:**

> "Remove the CORS mock rule when we're done testing."

**Your agent runs:**

```bash
apxy mock list
apxy mock remove --id <RULE_ID>
```

(Use the id from `list`.)

---

## Track B: Web UI Workflow

> Best for: visual inspection of headers and status without memorizing CLI flags.

### Step 1: Open the dashboard

**Home → Web UI:** start the proxy (same as Track A), then open **http://localhost:8082**. Confirm the proxy status shows running.

> screenshots/01-dashboard-cors.png

### Step 2: Open Traffic and filter mentally by host

Go to **Traffic**. Wait for rows while you reproduce the issue from `localhost:3000`. Sort or scan for `api.myapp.com` and method **OPTIONS**.

> screenshots/02-traffic-options-row.png

### Step 3: Inspect the preflight record

**Traffic** -> click the **OPTIONS** row -> **Response** tab. Compare headers with what the browser needs: `Access-Control-Allow-Origin`, `Access-Control-Allow-Methods`, `Access-Control-Allow-Headers`.

> screenshots/03-options-response-headers.png

### Step 4: Inspect the follow-up request

**Traffic** -> click the related **GET** or **POST** row -> **Request** / **Response** tabs. Confirm request headers (`Origin`, `Authorization`) and response headers. A “good” API response still fails in-browser if the preflight was wrong.

> screenshots/04-followup-get-detail.png

### Step 5: Rules (optional)

If you added a mock from Track A, go to **Rules** -> find **cors-preflight-localhost** and confirm it is active. Toggle off to compare behavior.

> screenshots/05-mock-rule-cors.png

---

## Video Walkthrough

*[Link TBD — e.g. YouTube]*

- 0:00 — Scenario and starting the proxy with `--ssl-domains`
- 2:00 — Finding `OPTIONS` and reading CORS headers in CLI + Web UI
- 4:00 — Mock preflight and verifying in the browser

---

## What You Learned

- How CORS preflights show up as real `OPTIONS` records in APXY, not as a black box
- How to correlate browser errors with missing or incorrect `Access-Control-*` headers
- How to use `apxy logs search` and `apxy logs show` for header-level debugging
- How to temporarily mock an `OPTIONS` response with `apxy mock add` to unblock local development or validate a hypothesis

## Next Steps

- [API Mocking](../../api-mocking/) — Broader mock patterns for APIs under construction
- [Replay and Diff](../../replay-and-diff/) — Compare responses before and after backend fixes
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) — Trust APXY’s CA so HTTPS inspection is reliable
