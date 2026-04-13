# Example: AI Agent Workflow

Use an AI agent (Cursor, Claude, VS Code Copilot) to debug network issues through APXY's CLI.

## Scenario

Your app is making API calls that sometimes fail. Instead of manually inspecting traffic, you ask your AI agent to help you debug.

## Prerequisites

- APXY installed and proxy running (`apxy start`)

## Steps

### 1. Start the proxy

```bash
apxy start
```

### 2. Generate some traffic

Use your app normally, or simulate traffic:

```bash
curl https://api.example.com/users
curl https://api.example.com/orders
curl https://api.example.com/nonexistent    # This will 404
```

### 3. Ask your AI agent to investigate

In your AI tool (Cursor, Claude Desktop, etc.), try these prompts:

**Find errors:**
> "Show me all failed requests (4xx and 5xx status codes)"

The AI uses `search_traffic` to find error responses.

**Inspect a specific request:**
> "Show me the full details of the last request to api.example.com"

The AI uses `get_traffic_detail` to show headers, body, timing.

**Compare requests:**
> "Compare the successful /users request with the failed one"

The AI uses `diff_records` to highlight differences.

**Extract data:**
> "What error message is in the response body of that 404 request?"

The AI uses `query_json_path` to extract specific values.

### 4. Ask your AI to fix the issue

**Set up a mock while you fix:**
> "Mock /api/nonexistent to return a 200 with an empty array so the frontend doesn't crash"

The AI uses `set_mock_rule` to create a temporary mock.

**Replay after fixing:**
> "Replay the failed request to see if it works now"

The AI uses `replay_request` to re-send the original request.

**Export for sharing:**
> "Export that failing request as a curl command I can share with the backend team"

The AI uses `export_as_curl` to generate a reproducible command.

### 5. Advanced: SQL analysis

> "Show me the top 10 slowest endpoints from the last hour"

The AI uses `query_sql` to run:
```sql
SELECT host, path, AVG(duration_ms) as avg_ms, COUNT(*) as count
FROM traffic_logs
GROUP BY host, path
ORDER BY avg_ms DESC
LIMIT 10
```

## What you learned

- How AI agents use CLI commands to inspect traffic
- Natural language debugging workflow
- Using `diff_records` to compare good vs bad requests
- Creating temporary mocks during debugging
- Exporting requests for team collaboration
