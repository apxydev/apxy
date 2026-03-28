# Your First 5 Minutes with APXY

Capture your first HTTP request, inspect it, and export it -- in under 5 minutes.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Traffic capture, Traffic inspection, Export as cURL | **Requires**: Free

## Scenario

You just installed APXY and want to see it in action. You'll start the proxy,
generate some traffic, let your AI agent investigate it, and also explore
the same traffic visually in the Web UI.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- APXY's SSL interception enabled for HTTPS traffic. If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](getting-started/ssl-setup-guide/) first.
- An AI coding agent (Claude Code, Cursor, Codex, or Copilot) with the APXY skill installed -- see [AI Agent Skill Setup](../ai-agent-workflow/)

---

## Track A: Agent + CLI Workflow

> Best for: Claude Code, Cursor, Codex, Copilot users.
> You talk to your AI agent in natural language. The agent runs APXY commands for you.

### Step 1: Ask your agent to start the proxy

Tell your agent:

> "Start the APXY proxy so we can capture network traffic."

Your agent runs:

```bash
apxy proxy start --ssl-domains httpbin.org
```

On macOS, this automatically configures the system proxy. All HTTP/HTTPS traffic now flows through APXY, with SSL interception enabled for httpbin.org.

### Step 2: Generate some traffic

Open a browser and visit a few pages, or tell your agent:

> "Send a few test requests to httpbin.org -- a GET, a POST with a JSON body, and a request that returns a 404."

Your agent runs:

```bash
curl https://httpbin.org/get
curl -X POST https://httpbin.org/post -d '{"hello":"world"}'
curl https://httpbin.org/status/404
```

### Step 3: Ask your agent what was captured

Tell your agent:

> "List the last 10 requests APXY captured."

Your agent runs:

```bash
apxy traffic logs list --limit 10
```

Agent shows you something like:

```
ID  METHOD  URL                             STATUS  DURATION
3   GET     https://httpbin.org/status/404   404     89ms
2   POST    https://httpbin.org/post         200     145ms
1   GET     https://httpbin.org/get          200     112ms
```

### Step 4: Ask your agent to inspect a specific request

Tell your agent:

> "Show me the full details of the POST request to httpbin."

Your agent runs:

```bash
apxy traffic logs show --id 2
```

Agent reports the complete request and response -- method, URL, headers, request body `{"hello":"world"}`, response body with the echoed data, status 200, timing, and more.

### Step 5: Ask your agent to export it

Tell your agent:

> "Export that POST request as a cURL command I can share with my teammate."

Your agent runs:

```bash
apxy traffic logs export-curl --id 2
```

Agent gives you a ready-to-paste cURL command:

```bash
curl -X POST 'https://httpbin.org/post' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -d '{"hello":"world"}'
```

### Step 6: Stop the proxy

Tell your agent:

> "Stop the APXY proxy."

Your agent runs:

```bash
apxy proxy stop
```

---

## Track B: Web UI Workflow

> Best for: visual exploration, first-time users who want to click around.

### Step 1: Start the proxy and open the Web UI

Run in your terminal (or ask your agent to do it):

```bash
apxy proxy start --ssl-domains httpbin.org
```

Open your browser to **http://localhost:8082**. The dashboard shows the proxy is running.

> screenshots/01-dashboard-running.png

### Step 2: Generate traffic

Open another browser tab and visit:
- `https://httpbin.org/get`
- `https://httpbin.org/status/404`

Or run the curl commands from Track A in a separate terminal.

### Step 3: View captured traffic

Go to the **Traffic** tab. You'll see requests appearing in real-time as they're captured.

Each row shows: method, URL, status code, duration, and content type.

> screenshots/02-traffic-list.png

### Step 4: Inspect a request

Click any request row to expand the detail panel. You'll see:
- **Request** tab: method, URL, headers, body
- **Response** tab: status, headers, response body (formatted JSON)
- **Timing** tab: connection time, TLS handshake, response time

> screenshots/03-request-detail.png

### Step 5: Export a request

Right-click a request row (or use the action menu) and select **Copy as cURL**.

The cURL command is copied to your clipboard, ready to share.

> screenshots/04-export-curl.png

### Step 6: Stop the proxy

Go back to your terminal and run:

```bash
apxy proxy stop
```

Or close the Web UI -- the proxy continues running until explicitly stopped.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*
- Agent + CLI demo: 0:00 - 2:30
- Web UI demo: 2:30 - 5:00

---

## What You Learned

- How to start and stop the APXY proxy
- How to ask your AI agent to capture, inspect, and export traffic
- How to browse captured traffic visually in the Web UI
- How to export a request as a shareable cURL command

## Next Steps

- [API Mocking](mocking/mock-backend-for-frontend/) -- Mock API endpoints to unblock frontend development
- [The Capture -> Replay -> Diff Loop](replay-and-diff/regression-testing-with-diff/) -- Verify code fixes by replaying and diffing requests
- [AI Agent Workflow](ai-agent/agent-debug-500-errors/) -- Advanced agent-driven debugging with SQL analysis
