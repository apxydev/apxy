# Auto-Injecting Auth Headers with Scripts

Run a small JavaScript hook on every matching request so `Authorization` (or any header) is set consistently—no more pasting tokens into five different tools.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: JavaScript scripting, Request hooks, SSL interception | **Requires**: Pro

## Scenario

Every call to `https://api.myapp.com` must include `Authorization: Bearer <token>`. Postman, curl, the mobile app, and your integration tests each duplicate that setup. With an APXY **onRequest** script scoped by the match DSL, the proxy adds the header **after** the client sends the request but **before** it leaves to the origin, so one script covers all clients that route through APXY.

Use a short-lived dev token in examples; never commit real secrets. Prefer environment-specific tokens and rotate them often.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- **Pro** license (proxy scripts are a Pro capability)
- Node or any editor to create a `.js` file (the script runs inside APXY’s engine, not Node)

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

### Step 1: Create the script file

**Tell your agent:**

> "Create a file add-auth.js in this example folder with an onRequest hook that sets Authorization to a Bearer token for every request the script sees."

**Your agent runs** (or writes the file for you):

Save as `add-auth.js` next to this README:

```javascript
function onRequest(request) {
  request.headers["Authorization"] =
    "Bearer eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...";
  return request;
}
```

Replace the placeholder JWT with a **valid dev token** from your identity provider. If the API expects a different scheme, set the header value accordingly (`Basic …`, `Api-Key …`, etc.).

### Step 2: Register the script with APXY

**Tell your agent:**

> "Register add-auth.js as an onRequest script named inject-bearer, matching only host api.myapp.com."

**Your agent runs:**

```bash
apxy rules script add \
  --name "inject-bearer" \
  --file ./add-auth.js \
  --hook onRequest \
  --match 'host == "api.myapp.com"'
```

`--name` is required. `--match` uses the same DSL as breakpoints and other rules; tighten it with `&& path contains "/api/"` if you should not inject on static asset hosts.

### Step 3: Confirm the script is loaded

**Tell your agent:**

> "List all proxy scripts and confirm inject-bearer is present and enabled."

**Your agent runs:**

```bash
apxy rules script list
```

### Step 4: Generate traffic without client-side auth

**Tell your agent:**

> "I'll call the API through the proxy from curl **without** an Authorization header—the script should add it."

Example (adjust proxy port):

```bash
curl -x http://127.0.0.1:8080 -sS "https://api.myapp.com/api/me"
```

If the endpoint returns **200** (or your expected auth error changed), the header injection is working.

### Step 5: Verify in traffic inspection

**Tell your agent:**

> "Show the latest request to /api/me and confirm the Authorization header appears on the **outbound** request to the origin."

**Your agent runs:**

```bash
apxy traffic logs search --query "/api/me" --limit 3
apxy traffic logs show --id LOG_ID
```

Pick `LOG_ID` from the search results. Confirm the stored request reflects the injected header (some UIs show both client and forwarded views—use the one that represents what the upstream API received).

### Step 6: Disable or remove when switching users

**Tell your agent:**

> "Disable inject-bearer without deleting it—I want to test unauthenticated behavior."

**Your agent runs:**

```bash
apxy rules script list
apxy rules script disable --id SCRIPT_ID
```

Re-enable with `apxy rules script enable --id SCRIPT_ID`, or remove entirely:

```bash
apxy rules script remove --id SCRIPT_ID
```

---

## Track B: Web UI Workflow

1. **Dashboard** — proxy running, SSL trusted for `api.myapp.com`.
2. Navigate to **Scripts** (or **Rules** → **Scripts**).
3. Click **Add script** / **New script**.
4. Set:
   - **Name**: `inject-bearer`
   - **Hook**: `onRequest`
   - **Match expression**: `host == "api.myapp.com"`
   - **Source**: paste the same `onRequest` function body, or upload `add-auth.js` if the UI supports file upload.
5. Save and ensure the script shows as **enabled** in the list.
6. Open **Traffic**, issue a request from your client, then open the captured row and expand **Request headers**. Confirm `Authorization` is present.
7. Use **Disable** in the UI when you need to compare behavior with and without injection.

**Screenshot placeholders**

- `screenshots/01-scripts-empty.png` — Scripts list before adding.
- `screenshots/02-script-editor-onrequest.png` — Editor showing onRequest and match DSL.
- `screenshots/03-traffic-authorization-header.png` — Traffic detail with Authorization visible.

---

## Video Walkthrough

_Add a link or embed when the recording is ready._

- **Planned title**: Inject Bearer tokens automatically with APXY request scripts
- **Length**: ~6–10 minutes

---

## What You Learned

- `onRequest` scripts mutate the request object **before** forwarding; returning `request` is required.
- `--match` scopes scripts so you do not leak tokens to unrelated hosts.
- CLI `script add` requires `--name` and either `--file` or `--code`.
- Traffic inspection proves the origin saw the injected header, not just that curl omitted it client-side.

---

## Next Steps

- Move the token to a secure fetch: some teams use scripts that read from environment variables exposed only to the APXY process—follow your org’s secret policy.
- Add a sibling **onResponse** script—see [mask PII example](../script-transform-response/).
- Combine with [redirect rules](../redirect-api-to-staging/) to hit `api.myapp.com` in the client while the backend is local.
