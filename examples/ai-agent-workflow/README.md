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

In your AI tool (Claude Code, Cursor, Codex, etc.), try these prompts. Agents connected through `apxy mcp` use the MCP tools named below; agents with the APXY skill run the CLI commands.

**Find errors:**
> "Show me all failed requests (4xx and 5xx status codes)"

The agent uses `search_traffic_logs` or `list_traffic_logs`, or runs `apxy logs list`.

**Inspect a specific request:**
> "Show me the full details of the last request to api.example.com"

The agent uses `get_traffic_log`, or runs `apxy logs show --id <id>`, to show headers, body, and timing.

**Compare requests:**
> "Compare the successful /users request with the failed one"

The agent runs `apxy logs diff --id-a <good-id> --id-b <bad-id>` to highlight differences.

**Extract data:**
> "What error message is in the response body of that 404 request?"

The agent runs `apxy logs jsonpath --id <id> --path <field>` to extract specific values.

### 4. Ask your AI to fix the issue

**Set up a mock while you fix:**
> "Mock /api/nonexistent to return a 200 with an empty array so the frontend doesn't crash"

The agent uses `create_mock_rule`, or runs `apxy mock add`, to create a temporary mock.

**Check the fix:**
> "Run the tests and check that the app now sends the right request"

The agent runs `apxy mark`, then your tests with `apxy run`, then `apxy wait --match ... --expect ...`. MCP clients use `set_mark` and `wait_for_request`.

**Replay after fixing:**
> "Replay the failed request to see if it works now"

The agent runs `apxy logs replay --id <id>` to re-send the original request.

**Export for sharing:**
> "Export that failing request as a curl command I can share with the backend team"

The agent runs `apxy logs export-curl --id <id>` to generate a reproducible command.

### 5. Advanced: find slow endpoints

> "Show me the top 10 slowest endpoints"

The agent runs:
```bash
apxy logs list --limit 1000 | jq '.items | group_by(.host + .path) | map({host: .[0].host, path: .[0].path, avg_ms: (map(.duration / 1e6) | add / length | round), count: length}) | sort_by(-.avg_ms) | .[:10]'
```

## What you learned

- How AI agents use MCP tools and CLI commands to inspect traffic
- Natural language debugging workflow
- Using `apxy logs diff` to compare good vs bad requests
- Creating temporary mocks during debugging
- Checking a fix with `apxy mark` and `apxy wait`
- Exporting requests for team collaboration
