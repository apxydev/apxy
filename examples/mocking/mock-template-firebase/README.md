# Mocking Firebase Auth & Firestore

Run mobile or web clients that call **Identity Toolkit** (email/password sign-in) and **Firestore REST** without a live Firebase project or outbound Google traffic. APXY intercepts two Google API hosts and returns JSON shaped like Firebase responses.

**Difficulty**: Advanced | **Time**: ~40 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

Your app uses `signInWithPassword` / `signUp` against `identitytoolkit.googleapis.com` and reads or writes documents via `firestore.googleapis.com`. You want integration tests and local dev that do not depend on project quotas, network flakiness, or real user accounts. There is no bundled `mock-templates/firebase/` directory yet; add one rule per endpoint (or maintain a single `rules.json` and import it).

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for **both** API hosts used in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for identitytoolkit.googleapis.com and firestore.googleapis.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains identitytoolkit.googleapis.com,firestore.googleapis.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

**Note:** Firebase clients may also call other hosts (e.g. securetoken, FCM). Add them to `--ssl-domains` when your traces show additional domains.

### What you will mock

| API | Example operation | Path fragment |
|-----|-------------------|---------------|
| Identity Toolkit | Email/password sign-in | `.../v1/accounts:signInWithPassword` |
| Identity Toolkit | Sign up | `.../v1/accounts:signUp` |
| Firestore | RunQuery / document read | `.../v1/projects/*/databases/(default)/documents/...` |

Exact URLs depend on your API key query string and project id. Wildcard rules keep templates stable across projects.

---

## Track A: Agent + CLI Workflow

> Replace `YOUR_API_KEY` and project segments in comments; use wildcards in `--url` where shown.

### Step 1: Mock signInWithPassword

Tell your agent:

> "Add a POST mock for Identity Toolkit signInWithPassword returning idToken and refreshToken."

Your agent runs:

```bash
apxy rules mock add \
  --name "Firebase: signInWithPassword" \
  --url "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword*" \
  --match wildcard \
  --method POST \
  --status 200 \
  --body '{"kind":"identitytoolkit#VerifyPasswordResponse","localId":"mock-local-id","email":"dev@example.com","idToken":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.mock","refreshToken":"mock-refresh-token","expiresIn":"3600","registered":true}'
```

### Step 2: Mock signUp

Tell your agent:

> "Add POST mock for accounts:signUp."

Your agent runs:

```bash
apxy rules mock add \
  --name "Firebase: signUp" \
  --url "https://identitytoolkit.googleapis.com/v1/accounts:signUp*" \
  --match wildcard \
  --method POST \
  --status 200 \
  --body '{"kind":"identitytoolkit#SignupNewUserResponse","localId":"mock-new-user","idToken":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.mock-new","refreshToken":"mock-refresh-new","expiresIn":"3600"}'
```

### Step 3: Mock email-already-in-use (optional)

Tell your agent:

> "Add signUp failure when X-APXY-Scenario is email_in_use."

Your agent runs:

```bash
apxy rules mock add \
  --name "Firebase: signUp email exists" \
  --url "https://identitytoolkit.googleapis.com/v1/accounts:signUp*" \
  --match wildcard \
  --method POST \
  --header-conditions "X-APXY-Scenario=email_in_use" \
  --status 400 \
  --body '{"error":{"code":400,"message":"EMAIL_EXISTS","errors":[{"message":"EMAIL_EXISTS","domain":"global","reason":"invalid"}]}}'
```

Tune priority relative to the success `signUp` rule.

### Step 4: Mock Firestore document GET

Tell your agent:

> "Add GET mock for Firestore document path with wildcard project and collection."

Your agent runs:

```bash
apxy rules mock add \
  --name "Firestore: get document" \
  --url "https://firestore.googleapis.com/v1/projects/*/databases/(default)/documents/users/*" \
  --match wildcard \
  --method GET \
  --status 200 \
  --body '{"name":"projects/mock-project/databases/(default)/documents/users/mock-doc","fields":{"title":{"stringValue":"Mock Title"},"count":{"integerValue":"42"}},"createTime":"2026-01-01T00:00:00.000000Z","updateTime":"2026-01-01T00:00:00.000000Z"}'
```

Firestore URLs encode `(default)` literally in the path; include it in the pattern as your client sends it.

### Step 5: Mock Firestore RunQuery (POST)

Tell your agent:

> "Add POST mock for :runQuery returning a single document result."

Your agent runs:

```bash
apxy rules mock add \
  --name "Firestore: runQuery" \
  --url "https://firestore.googleapis.com/v1/projects/*/databases/(default)/documents:runQuery*" \
  --match wildcard \
  --method POST \
  --status 200 \
  --body '[{"document":{"name":"projects/mock-project/databases/(default)/documents/items/item1","fields":{"name":{"stringValue":"alpha"}},"createTime":"2026-01-01T00:00:00Z","updateTime":"2026-01-01T00:00:00Z"}}]'
```

### Step 6: Exercise with curl (Identity Toolkit)

Tell your agent:

> "POST signInWithPassword with JSON key, email, password, and returnSecureToken."

Your agent runs:

```bash
curl -s -X POST \
  "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"email":"dev@example.com","password":"not-used-under-mock","returnSecureToken":true}'
```

### Step 7: List and maintain rules

Tell your agent:

> "List mock rules; remove or disable Firebase rules when done."

Your agent runs:

```bash
apxy rules mock list
apxy rules mock remove --id <RULE_ID>
```

---

## Track B: Web UI Workflow

### Step 1: Proxy + Web UI

Start with both domains in `--ssl-domains`. Open **http://localhost:8082**.

> screenshots/01-dashboard-firebase-mock.png

### Step 2: Auth traffic

Sign in from your app or curl. Open the `identitytoolkit.googleapis.com` row and verify tokens in the response (redact before sharing).

> screenshots/02-firebase-auth-signin.png

### Step 3: Firestore read

Trigger a document read. Confirm field map structure matches what your client deserializes.

> screenshots/03-firestore-get-document.png

### Step 4: Query response

Run a query; inspect array-shaped JSON in the response tab.

> screenshots/04-firestore-runquery.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Dual-domain SSL + Identity Toolkit: 0:00 - 12:00
- Firestore GET + runQuery + scenarios: 12:00 - 28:00

---

## What You Learned

- How to list **two** Google API hosts in one `apxy proxy start --ssl-domains` invocation
- How wildcard URL patterns cover API key query strings on Identity Toolkit
- How Firestore REST paths include `(default)` and project ids
- How to layer error scenarios for auth without touching Firebase Console

## Next Steps

- Add mocks for `token` refresh endpoints if your SDK calls `securetoken.googleapis.com`
- Export real responses once, anonymize, and convert to `rules.json` for team import
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- additional machines
- [Replay and Diff](../../replay-and-diff/) -- compare mock vs one captured Firebase response
