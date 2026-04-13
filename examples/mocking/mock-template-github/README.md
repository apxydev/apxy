# Mocking GitHub's REST API

Build GitHub integrations (issues, repos, dashboards) without burning rate limits or provisioning private fixtures. APXY serves GitHub-shaped JSON for common REST paths while your code keeps calling `https://api.github.com`.

**Difficulty**: Intermediate | **Time**: ~22 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

You are writing a tool that calls GitHub's REST API: user lookup, repository metadata, issue lists, and pagination. During development you want stable responses, no OAuth dance for every run, and a way to force `404`, `403`, or validation errors. The bundled template mirrors several high-traffic endpoints and includes `Link` headers for paginated list responses. In this repository the JSON pack lives under **`mock-templates/github-api/`** (not `github/`).

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.github.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.github.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

### What this template covers

| Area | Behavior |
|------|----------|
| Users | `GET /users/:username` (wildcard path), `GET /user` |
| Repos | `GET /repos/:owner/:repo` |
| Issues | List issues, get issue, create issue; optional scenario-driven errors |
| Pagination | `Link` headers on list endpoints (e.g. issues, user repos) |
| Errors | `X-APXY-Scenario` values such as `unauthorized` (401), `not_found` (404), `rate_limited` (403), `validation_failed` (422) |

---

## Track A: Agent + CLI Workflow

> Commands assume the shell is at the **repository root** that contains `mock-templates/`.

### Step 1: Import the GitHub API mock rules

Tell your agent:

> "Import the GitHub REST mock template from mock-templates/github-api/rules.json."

Your agent runs:

```bash
apxy mock import --file mock-templates/github-api/rules.json
```

### Step 2: Confirm rules loaded

Tell your agent:

> "List mock rules and confirm GitHub rules are active."

Your agent runs:

```bash
apxy mock list
```

### Step 3: Look up a user

Tell your agent:

> "GET https://api.github.com/users/octocat through the proxy."

Your agent runs:

```bash
curl -s "https://api.github.com/users/octocat"
```

Expect `200` and a JSON body shaped like the Octocat profile (mocked content from the template).

### Step 4: Fetch a repository

Tell your agent:

> "GET a repository by owner and name."

Your agent runs:

```bash
curl -s "https://api.github.com/repos/octocat/hello-world"
```

The template returns a consistent mock repository object for matching paths.

### Step 5: List issues with pagination headers

Tell your agent:

> "GET issues for a repo and show response headers including Link."

Your agent runs:

```bash
curl -sI "https://api.github.com/repos/octocat/hello-world/issues"
curl -s "https://api.github.com/repos/octocat/hello-world/issues"
```

Inspect `Link` for `rel="next"` / `rel="last"` to test client pagination logic without GitHub.

### Step 6: Force errors with scenarios

Tell your agent:

> "Call an api.github.com URL with X-APXY-Scenario not_found and show the 404 body."

Your agent runs:

```bash
curl -s -o /dev/null -w "%{http_code}\n" \
  -H "X-APXY-Scenario: not_found" \
  "https://api.github.com/users/missing-user"
```

Repeat with `unauthorized` or `rate_limited` to exercise 401 and 403 handling in your integration.

### Step 7: Clean up a rule (optional)

Tell your agent:

> "Remove one mock rule by id."

Your agent runs:

```bash
apxy mock list
apxy mock remove --id <RULE_ID>
```

---

## Track B: Web UI Workflow

### Step 1: Proxy + Web UI

Start with `api.github.com` in `--ssl-domains`, then open the Web UI (default **http://localhost:8082**).

> screenshots/01-dashboard-github-mock.png

### Step 2: Generate GitHub traffic

Run the Track A curl commands. Rows should show `GET api.github.com/...` with JSON bodies visible.

> screenshots/02-github-traffic-list.png

### Step 3: Inspect pagination

Select a list-issues request and check **Response** headers for `Link` and rate-limit style headers copied from the template.

> screenshots/03-github-link-headers.png

### Step 4: Compare scenario errors

Send two requests to the same path: one without `X-APXY-Scenario` and one with `not_found` or `rate_limited`. Compare status and JSON side by side in the detail panel.

> screenshots/04-github-scenario-errors.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Import + user/repo/issues curls: 0:00 - 10:00
- Pagination headers + forced errors in Web UI: 10:00 - 20:00

---

## What You Learned

- Where the GitHub template file lives (`mock-templates/github-api/rules.json`) and how to import it
- How to mock user, repo, and issue endpoints with realistic list shapes and `Link` pagination
- How to trigger 401 / 404 / 403 style responses with `X-APXY-Scenario` without touching GitHub
- How to validate behavior in the Web UI against the same curls

## Next Steps

- Add rules for GraphQL or enterprise endpoints with `apxy mock add`
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- trust CA on additional machines
- [API Mocking](../../api-mocking/) -- baseline mock concepts
- [Replay and Diff](../../replay-and-diff/) -- diff mock vs captured real GitHub traffic
- Contribute extra scenarios to [apxy-public](https://github.com/apxydev/apxy-public) if you publish shared templates
