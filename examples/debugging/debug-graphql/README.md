# Debugging GraphQL APIs

Go beyond “POST /graphql 200”: list operations by type and name, open one record, and pull `data.user.profile` (or any path) with jsonpath to explain unexpected nulls.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: GraphQL filtering, Traffic inspection, SSL interception | **Requires**: Free

## Scenario

Your React app uses Apollo or urql against `https://api.myapp.com/graphql`. In the UI, `user.profile.bio` is `null` but you expected a string. The network tab only shows POST 200 with a large JSON blob. You need APXY to surface GraphQL operation names, variables, and response paths so you can tell whether the server returned null, the query omitted the field, or variables were wrong.

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
apxy proxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

### Step 1: Drive the app through the proxy

**Tell your agent:**

> "I'll navigate screens that run GraphQL queries and mutations while traffic is captured."

Ensure the browser or client uses the system proxy so POSTs hit APXY.

### Step 2: List recent query operations

**Tell your agent:**

> "List captured GraphQL operations of type query."

**Your agent runs:**

```bash
apxy traffic logs graphql --operation-type query --limit 20
```

Agent shows rows tying record IDs to operation names and endpoints, for example **GetUser** and **GetDashboard**.

### Step 3: Narrow by operation name

**Tell your agent:**

> "Filter to the GetUser operation."

**Your agent runs:**

```bash
apxy traffic logs graphql --operation-name "GetUser" --limit 10
```

If your client aliases operations, use the exact name the server sees (check one `show` first).

### Step 4: Inspect one record in full

**Tell your agent:**

> "Show record id from the GetUser hit—request body with query + variables, response JSON."

**Your agent runs:**

```bash
apxy traffic logs show --id <ID>
```

Agent highlights:

- `query` string: does it request `profile { bio }`?
- `variables`: is `id` correct?
- `errors` array: partial failures with null data
- `data.user` shape

### Step 5: Extract a single path with jsonpath

**Tell your agent:**

> "Extract data.user.profile from the response."

**Your agent runs:**

```bash
apxy traffic logs jsonpath --id <ID> --path "data.user.profile" --scope response
```

Agent prints `null`, `{}`, or the nested object—fast confirmation without scrolling megabytes of JSON.

### Step 6: Check the request body for the same path (advanced)

**Tell your agent:**

> "If the issue is variables, extract from request scope."

**Your agent runs:**

```bash
apxy traffic logs jsonpath --id <ID> --path "variables" --scope request
```

### Step 7: Capture a mutation path (optional)

**Tell your agent:**

> "List mutations that might update profile."

**Your agent runs:**

```bash
apxy traffic logs graphql --operation-type mutation --limit 15
```

---

## Track B: Web UI Workflow

### Step 1: Traffic list

Open **http://localhost:8082**. Go to **Traffic**. Filter or scan for **POST** to `/graphql` (or your path).

> screenshots/01-traffic-graphql-posts.png

### Step 2: Open a GraphQL request

**Traffic** -> click a row -> **Request** tab: formatted JSON with `query`, `variables`, `operationName`.

> screenshots/02-graphql-request-body.png

### Step 3: Response tab

**Traffic** -> click the row -> **Response** tab. Inspect `data` vs `errors`. Expand the path that maps to your UI bug.

> screenshots/03-graphql-response-data.png

### Step 4: Compare two operations

**Traffic** -> click **GetUser** row and another query row; confirm field sets differ if one screen shows bio and another does not.

> screenshots/04-two-operations-compare.png

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — SSL + why POST /graphql needs body inspection
- 2:30 — `graphql` filters for type and name
- 5:00 — `jsonpath` for deep fields
- 6:30 — Web UI formatted bodies

---

## What You Learned

- Using `apxy traffic logs graphql --operation-type` and `--operation-name` to find the right records
- Reading `query`, `variables`, and `errors` via `apxy traffic logs show`
- Pulling nested JSON with `apxy traffic logs jsonpath` on `data.*` paths
- Separating “server returned null” from “client never asked for the field”

## Next Steps

- [Debug Slow API](../debug-slow-api/) — Heavy GraphQL responses and N+1 patterns
- [Debug Flaky API](../debug-flaky-api/) — Intermittent GraphQL errors or partial data
- [Replay and Diff](../../replay-and-diff/) — Replay the same operation after a schema fix
