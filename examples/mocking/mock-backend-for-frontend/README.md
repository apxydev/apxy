# Building UI Without a Backend

Stand up a realistic REST API with mock rules so you can build and test a dashboard before the backend ships.

**Difficulty**: Beginner | **Time**: ~10 minutes | **Features used**: Mock rules, Delay simulation, SSL interception | **Requires**: Free

## Scenario

You are a frontend developer building a user dashboard. The backend team has not finished the API yet, but you already know the expected endpoints and JSON shapes. You will mock the full users resource -- list, read, create, update, and delete -- with small delays so loading states feel real. Traffic goes to `https://api.myapp.com`, which you map through APXY with SSL interception enabled.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- Optional but recommended: add `127.0.0.1 api.myapp.com` to `/etc/hosts` so your app and `curl` resolve the mock host to your machine through the proxy

**Free tier:** You can have up to **three active** mock rules at once on the Free plan. This walkthrough defines five rules for a complete CRUD story. Either upgrade to Pro for unlimited rules, or keep only the three rules you are actively testing and `apxy rules mock disable` the rest (see Step 7).

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

> Best for: Claude Code, Cursor, Codex, Copilot users. You describe intent; the agent runs APXY commands.

### Step 1: Mock GET /api/users (collection)

**Tell your agent:**

> "Add a mock rule: GET https://api.myapp.com/api/users returns 200 with a JSON array of two users, id and name, and a 200 ms delay."

**Your agent runs:**

```bash
apxy rules mock add --name "users-list" --url "https://api.myapp.com/api/users" --method GET --match exact --status 200 --delay 200 --priority 10 --body '[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]'
```

Agent reports something like:

```
Rule created: users-list (ID: ...)
```

### Step 2: Mock GET /api/users/:id (single user)

Use a **wildcard** URL so any numeric id matches. Give this rule a **lower** `--priority` than the list rule so `GET .../api/users/42` does not fall through to the collection pattern incorrectly (more specific / id routes should win).

**Tell your agent:**

> "Add a mock for GET https://api.myapp.com/api/users/* returning one user object with id 42 and name Carol, priority 0."

**Your agent runs:**

```bash
apxy rules mock add --name "users-by-id" --url "https://api.myapp.com/api/users/*" --method GET --match wildcard --status 200 --priority 0 --body '{"id":42,"name":"Carol","email":"carol@example.com"}'
```

### Step 3: Mock POST /api/users (create)

**Tell your agent:**

> "Mock POST /api/users with 201 and a created user body including id 99."

**Your agent runs:**

```bash
apxy rules mock add --name "users-create" --url "https://api.myapp.com/api/users" --method POST --match exact --status 201 --body '{"id":99,"name":"New User","email":"new@example.com"}'
```

### Step 4: Mock PUT /api/users/:id

**Tell your agent:**

> "Mock PUT for https://api.myapp.com/api/users/* with 200 and an updated user JSON."

**Your agent runs:**

```bash
apxy rules mock add --name "users-update" --url "https://api.myapp.com/api/users/*" --method PUT --match wildcard --status 200 --body '{"id":42,"name":"Carol Updated","email":"carol@example.com"}'
```

### Step 5: Mock DELETE /api/users/:id

**Tell your agent:**

> "Mock DELETE https://api.myapp.com/api/users/* with 204 and an empty body."

**Your agent runs:**

```bash
apxy rules mock add --name "users-delete" --url "https://api.myapp.com/api/users/*" --method DELETE --match wildcard --status 204 --body ''
```

### Step 6: List rules and hit the API through the proxy

**Tell your agent:**

> "Show all mock rules, then curl the list and single-user endpoints through the proxy."

**Your agent runs:**

```bash
apxy rules mock list
curl -sS "https://api.myapp.com/api/users"
curl -sS "https://api.myapp.com/api/users/42"
```

Agent shows JSON matching your rules and may show traffic in `apxy logs list` if logging is enabled.

### Step 7 (Free tier): Rotate active rules

If you hit the active-rule limit, pause rules you are not testing:

**Tell your agent:**

> "Disable the PUT and DELETE mock rules so I stay within the Free tier limit."

**Your agent runs:**

```bash
apxy rules mock list
apxy rules mock disable --id <put-rule-id>
apxy rules mock disable --id <delete-rule-id>
```

---

## Track B: Web UI Workflow

> Best for: clicking through the Rules Lab and visually confirming matchers, status codes, and bodies.

### Step 1: Start proxy and open the Web UI

Run (or ask your agent):

```bash
apxy proxy start --ssl-domains api.myapp.com
```

Open **http://localhost:8082**. Confirm the dashboard shows the proxy as running.

> screenshots/01-dashboard-ssl-domain.png

### Step 2: Open Mock Rules

In the sidebar, expand **Rules**, then choose **Mock Rules** (`/rules/mock`).

> screenshots/02-mock-rules-empty.png

### Step 3: Create the list rule

Click **Create Mock Rule** (or use the shortcut your build documents). Fill in:

- **Name:** `users-list`
- **URL Pattern:** `https://api.myapp.com/api/users`
- **Match Type:** Exact
- **Method:** GET
- **Status:** 200
- **Delay (ms):** 200
- **Priority:** 10
- **Response Source:** Inline Body
- **Response Body:** `[{"id":1,"name":"Alice"},{"id":2,"name":"Bob"}]`

Save the rule.

> screenshots/03-mock-users-list.png

### Step 4: Add wildcard rules for id-shaped paths

Repeat for **GET** `https://api.myapp.com/api/users/*` (wildcard), **PUT** and **DELETE** on the same pattern, and **POST** on the exact collection URL, matching the CLI example above.

> screenshots/04-mock-rules-table-crud.png

### Step 5: Verify in Traffic

Open **Traffic**, perform requests from your app or from **Compose** if available, and confirm responses show as **Mocked** where expected.

> screenshots/05-traffic-mocked-users.png

### Step 6: Stop when finished

In the terminal:

```bash
apxy stop
```

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Agent + CLI: mock CRUD rules, list, curl checks
- Web UI: Rules → Mock Rules, create rules, Traffic verification

---

## What You Learned

- How to map `https://api.myapp.com` through APXY with `--ssl-domains`
- How to combine **exact** and **wildcard** URL patterns for collection vs resource paths
- How `--priority` orders overlapping patterns (lower number is tried first)
- How `--delay` simulates network latency for UI loading states
- How the Free plan limits concurrent active mocks and how to disable rules you are not using
- How to mirror the same setup in **Rules → Mock Rules** in the Web UI

## Next Steps

- [Testing Error Handling in Your UI](../mock-error-states/) -- mock 4xx/5xx responses
- [A/B Testing and Feature Flags via Mocks](../mock-with-header-conditions/) -- header-conditioned responses
- [API Mocking](../../api-mocking/) -- broader mocking overview
- [Quickstart: First 5 Minutes](../../quickstart-5-minutes/) -- capture and inspect traffic
