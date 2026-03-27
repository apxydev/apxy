# Modifying API Responses with Scripts

Strip or mask sensitive fields in JSON responses before they reach your browser or app—keep real backends, hide PII during demos and screen shares.

**Difficulty**: Advanced | **Time**: ~15 minutes | **Features used**: JavaScript scripting, Response hooks, SSL interception | **Requires**: Pro

## Scenario

`GET https://api.myapp.com/api/users/123` returns email and phone numbers you do not want on every developer laptop or in every recorded HAR file. Changing the server for every environment is heavy; an APXY **onResponse** script parses JSON, redacts fields, and serializes the body back so the client still sees a coherent payload with placeholders.

This walkthrough uses a minimal mask. Production-grade masking might recurse nested objects, handle non-JSON bodies, and log redaction events—grow the script as your API surface grows.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- **Pro** license (proxy scripts are a Pro capability)
- Familiarity with JSON and basic JavaScript error handling

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

### Step 1: Author the response script

**Tell your agent:**

> "Create mask-pii.js with onResponse that parses JSON, masks top-level email and phone, and returns the modified response."

**Your agent runs** (or writes the file):

Save as `mask-pii.js`:

```javascript
function onResponse(response) {
  let body = JSON.parse(response.body);
  if (body.email) body.email = "***@***.com";
  if (body.phone) body.phone = "***-***-****";
  response.body = JSON.stringify(body);
  return response;
}
```

**Hardening ideas** (apply when you move past the tutorial):

- Wrap `JSON.parse` in try/catch; if parsing fails, return `response` unchanged.
- Walk nested `user` / `profile` objects instead of only top-level keys.
- Preserve `Content-Length` behavior—many stacks recalculate length when you assign `response.body`; if something breaks, check APXY docs for your version.

### Step 2: Register the script on the response hook

**Tell your agent:**

> "Add mask-pii.js as onResponse script named redact-user-pii, matching URLs under /api/users on api.myapp.com."

**Your agent runs:**

```bash
apxy rules script add \
  --name "redact-user-pii" \
  --file ./mask-pii.js \
  --hook onResponse \
  --match 'host == "api.myapp.com" && path contains "/api/users"'
```

The match DSL supports predicates such as `path contains "/api/users"` and `url matches "…"` (regex)—see APXY traffic-rules documentation for the full set.

A narrower match avoids running JSON logic on binary downloads or HTML error pages.

### Step 3: List and validate registration

**Tell your agent:**

> "List scripts; confirm redact-user-pii uses hook onResponse."

**Your agent runs:**

```bash
apxy rules script list
```

### Step 4: Issue a request that returns PII

**Tell your agent:**

> "I'll GET /api/users/123 through the proxy while the script is enabled."

Example:

```bash
curl -x http://127.0.0.1:8080 -sS "https://api.myapp.com/api/users/123" | jq .
```

You should see masked `email` / `phone` values in the curl output because the script ran on the response path.

### Step 5: Verify via traffic inspection

**Tell your agent:**

> "Find the latest traffic id for /api/users/123 and show the response body as stored by APXY."

**Your agent runs:**

```bash
apxy traffic logs search --query "/api/users" --limit 5
apxy traffic logs show --id LOG_ID
```

Confirm the **response** section in the log shows redacted values. If you still see raw PII, check: script disabled, match expression too narrow/wide, or response not JSON.

### Step 6: Compare with script disabled

**Tell your agent:**

> "Disable redact-user-pii, repeat the same GET, then re-enable."

**Your agent runs:**

```bash
apxy rules script disable --id SCRIPT_ID
# repeat curl
apxy rules script enable --id SCRIPT_ID
```

The before/after diff proves the script is responsible for the transformation, not the backend.

### Step 7: Remove when done

**Tell your agent:**

> "Remove the redact-user-pii script."

**Your agent runs:**

```bash
apxy rules script remove --id SCRIPT_ID
```

---

## Track B: Web UI Workflow

1. **Dashboard** — ensure proxy + SSL for `api.myapp.com`.
2. Go to **Scripts** → **Add script**.
3. Configure:
   - **Name**: `redact-user-pii`
   - **Hook**: `onResponse`
   - **Match**: `host == "api.myapp.com" && path contains "/api/users"` (or equivalent in the UI).
   - **Code**: paste the `onResponse` function from `mask-pii.js`.
4. Save; confirm the script is **enabled**.
5. Open **Traffic** in a second tab; trigger `GET /api/users/123` from your app or curl.
6. Click the new traffic row → **Response** tab / body viewer. Verify masked fields.
7. Toggle **Disable** on the script and refresh the same request path to see raw data return (use only in safe environments).

**Screenshot placeholders**

- `screenshots/01-script-onresponse.png` — Script editor with hook onResponse selected.
- `screenshots/02-match-path-users.png` — Match expression scoped to paths containing /api/users.
- `screenshots/03-traffic-response-masked.png` — Response body showing placeholder email/phone.

---

## Video Walkthrough

_Add a link or embed when the recording is ready._

- **Planned title**: Redact PII from JSON API responses with APXY
- **Length**: ~12–18 minutes (includes error-handling discussion)

---

## What You Learned

- `onResponse` runs after the origin responds but before the client receives bytes—ideal for shaping JSON.
- Match DSL scopes heavy parsing to relevant hosts/paths.
- Always validate with **Traffic** logs: clients, caches, and compression can confuse you if you only watch curl.
- Disabling scripts is the fastest A/B test when debugging “why is my body empty?”

---

## Next Steps

- Extend the script to handle **arrays** of users and nested `contact` objects.
- Add logging (within script limits) for keys you redact, without printing real values.
- Pair with [auth injection](../script-add-auth-header/) so protected user endpoints still receive tokens while responses stay safe to display.
- For wholesale environment swaps instead of body surgery, prefer [redirect rules](../redirect-api-to-staging/).
