# Debugging OAuth/JWT Authentication Flows

Capture login, token refresh, and API calls in one place so you can see whether access tokens expire early, refresh fails silently, or the wrong scope reaches your backend.

**Difficulty**: Intermediate | **Time**: ~15 minutes | **Features used**: Traffic search, JSONPath extraction, SSL interception | **Requires**: Free

## Scenario

Users report being “randomly” logged out of your product. You suspect the JWT access token lifetime is shorter than the refresh cadence, or the refresh endpoint returns an error only on some paths. You need a trustworthy trace of `auth.myapp.com` traffic plus downstream API calls that carry `Authorization` headers—without pasting tokens into random log aggregators.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for auth.myapp.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains auth.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

> Best for: agent-driven investigation with precise CLI steps you can paste into runbooks.

### Step 1: Reproduce login and a “random logout” path

**Tell your agent:**

> "I'll log in and use the app until I get logged out—or run through login and token refresh once. Search captured traffic for auth.myapp.com."

**Your agent runs:**

```bash
apxy traffic logs search --query "auth.myapp.com"
```

Agent shows matching rows, for example:

```
ID    METHOD   URL                                              STATUS
88    POST     https://auth.myapp.com/oauth/token             200
87    POST     https://auth.myapp.com/oauth/token             400
86    GET      https://auth.myapp.com/.well-known/openid-configuration 200
```

Note IDs for token and refresh calls.

### Step 2: Inspect the token response body

**Tell your agent:**

> "Show full record 88 and call out expires_in, token_type, and any error fields."

**Your agent runs:**

```bash
apxy traffic logs show --id 88
```

Agent reports JSON fields such as `access_token`, `refresh_token`, `expires_in`, and `scope`. A common bug is `expires_in` in seconds vs what the client assumes (ms), or missing `refresh_token` on silent renew.

### Step 3: Pull a field with jsonpath (access token snippet)

**Tell your agent:**

> "Extract access_token from record 88’s response without dumping the whole JWT to chat if possible—show jsonpath result length or prefix only."

**Your agent runs:**

```bash
apxy traffic logs jsonpath --id 88 --path "access_token" --scope response
```

Agent finds:

```
eyJhbGciOiJIUzI1NiIs...
```

(Decode JWTs offline or in a trusted tool; do not post production secrets into public LLM threads.)

### Step 4: Decode expiration mentally or with a local JWT tool

**Tell your agent:**

> "From the JWT payload (middle segment), confirm exp vs iat and compare to client refresh timing."

Agent guides you to base64-decode the payload locally or uses a script on your machine—still no exfiltration of secrets.

### Step 5: Find refresh-token traffic

**Tell your agent:**

> "Search logs for refresh-related paths or bodies."

**Your agent runs:**

```bash
apxy traffic logs search --query "refresh"
```

Agent lists rows hitting `/oauth/token` with `grant_type=refresh_token` or similar. Open any suspicious row with `apxy traffic logs show --id <ID>` to see 400/401 and error JSON (`invalid_grant`, `invalid_client`).

### Step 6: Correlate with an API call that started failing

**Tell your agent:**

> "Search for the API host and inspect a 401 right after a failed refresh."

**Your agent runs:**

```bash
apxy traffic logs search --query "401" --limit 15
```

Then:

```bash
apxy traffic logs show --id <API_CALL_ID>
```

Agent correlates timestamps: refresh failed at T+0, API calls return 401 at T+1s.

---

## Track B: Web UI Workflow

> Best for: scanning many auth records and reading JSON bodies with formatting.

### Step 1: Dashboard and Traffic

Open **http://localhost:8082** after `apxy proxy start --ssl-domains auth.myapp.com`. Go to **Traffic**

> screenshots/01-dashboard-auth.png

### Step 2: Filter by host

In the traffic list, focus on host **auth.myapp.com**. Sort by time and identify the login `POST`, any `GET` to discovery or JWKS, and repeat `POST` to token.

> screenshots/02-traffic-auth-host.png

### Step 3: Inspect token response

**Traffic** -> click the successful token row -> **Response** tab: formatted JSON with `access_token`, `expires_in`, `refresh_token`. Check **Timing** tab if you care about slow IdP.

> screenshots/03-token-response-body.png

### Step 4: Inspect failed refresh

**Traffic** -> click a row with status **400** or **401** on the token endpoint -> **Request** / **Response** tabs. Read error payload and request body (form fields).

> screenshots/04-refresh-error.png

### Step 5: Follow Authorization on API calls

**Traffic** -> click a call to your API with header **Authorization: Bearer** -> **Request** tab. Confirm whether the header disappears or changes after refresh failures.

> screenshots/05-api-bearer-header.png

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — SSL for auth host and privacy notes
- 3:00 — `search` + `show` + `jsonpath` workflow
- 6:00 — Web UI inspection of token vs refresh errors

---

## What You Learned

- How to isolate IdP traffic with `apxy traffic logs search --query "auth.myapp.com"`
- How to inspect OAuth/OIDC token payloads with `apxy traffic logs show` and targeted `jsonpath`
- How to trace `refresh` failures and tie them to downstream **401** responses
- Operational hygiene: treat tokens as secrets even when debugging locally

## Next Steps

- [Basic Debugging](../../basic-debugging/) — Foundation for capture and inspection
- [Debug Slow API](../debug-slow-api/) — If auth is fine but APIs are slow
- [Replay and Diff](../../replay-and-diff/) — Replay token or API calls after server fixes
