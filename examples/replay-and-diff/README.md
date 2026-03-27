# The Capture -> Replay -> Diff Loop

Prove your code fix actually works -- capture a failing request, replay it after
your fix, and diff the before vs. after response.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Request replay, Traffic diff, Export as cURL, SSL interception | **Requires**: Free

## Scenario

Your `/api/orders` endpoint is returning a 500 error. A customer reported it,
and you think you've found the bug -- a nil pointer dereference when the
`shipping_address` field is missing. Before you push your fix, you want
concrete proof that the response changed from a 500 error to a valid 200.

This is APXY's killer workflow: **capture -> replay -> diff**. No other proxy
tool packages this loop end-to-end.

## Prerequisites

- APXY installed and proxy running (`apxy proxy start`)
- SSL enabled for your API domain (`apxy proxy start --ssl-domains api.myapp.com`)
- An AI coding agent with the APXY skill installed
- A local server running your API (e.g., `localhost:3000`)

---

## Track A: Agent + CLI Workflow

> Best for: Claude Code, Cursor, Codex, Copilot users.
> You talk to your AI agent in natural language. The agent runs APXY commands for you.

### Step 1: Ask your agent to find the failing request

Your app has been making requests through the proxy. Now ask your agent:

> "Search the APXY traffic for any requests that returned a 500 error."

Your agent runs:

```bash
apxy logs search --query "500"
```

Agent finds:

```
ID  METHOD  URL                                     STATUS  DURATION
7   POST    https://api.myapp.com/api/orders         500     45ms
```

### Step 2: Ask your agent to inspect the error

Tell your agent:

> "Show me the full details of request #7 -- I need to see the error message in the response body."

Your agent runs:

```bash
apxy logs show --id 7
```

Agent reports the response body:

```json
{
  "error": "internal_server_error",
  "message": "nil pointer dereference: shipping_address is nil",
  "trace_id": "abc-123-def"
}
```

You can also ask your agent to extract just the error message:

> "Extract the error message field from that response."

Your agent runs:

```bash
apxy logs jsonpath --id 7 --path "message"
```

Agent returns: `nil pointer dereference: shipping_address is nil`

### Step 3: Fix the bug

Now you know the root cause. Fix the nil pointer check in your code:

```go
// Before (broken):
city := order.ShippingAddress.City

// After (fixed):
if order.ShippingAddress != nil {
    city = order.ShippingAddress.City
}
```

Restart your local server with the fix applied.

### Step 4: Ask your agent to replay the request

Tell your agent:

> "Replay the exact same request that failed -- send another POST to /api/orders
> with the same body as request #7."

Your agent runs:

```bash
apxy tools request compose --method POST --url https://api.myapp.com/api/orders \
  --body '{"customer_id": "cust_42", "items": [{"sku": "WIDGET-1", "qty": 2}]}'
```

The new request goes through the proxy and gets captured as a new record (e.g., ID 12).

### Step 5: Ask your agent to diff the before and after

Tell your agent:

> "Diff the original failing request #7 against the new request #12.
> Show me what changed in the response."

Your agent runs:

```bash
apxy logs diff --id-a 7 --id-b 12 --scope response
```

Agent shows you the diff:

```diff
- Status: 500 Internal Server Error
+ Status: 200 OK

  Response Body:
- {
-   "error": "internal_server_error",
-   "message": "nil pointer dereference: shipping_address is nil",
-   "trace_id": "abc-123-def"
- }
+ {
+   "order_id": "ord_789",
+   "status": "confirmed",
+   "total": 29.98
+ }
```

The fix works. Status went from 500 to 200, and the error body is replaced with valid order data.

### Step 6: Export the evidence

Tell your agent:

> "Export both the original failing request and the fixed request as cURL commands.
> I want to include them in my PR description."

Your agent runs:

```bash
apxy logs export-curl --id 7
apxy logs export-curl --id 12
```

You now have reproducible cURL commands to paste into your pull request showing
the before and after.

---

## Track B: Web UI Workflow

> Best for: visual debugging, comparing responses side-by-side.

### Step 1: Find the failing request

Open **http://localhost:8082** and go to the **Traffic** tab.

Look for the request with a red **500** status badge. You can use the search bar
to filter by typing `500` or `api/orders`.

> screenshots/01-traffic-500-highlighted.png

### Step 2: Inspect the error

Click the failing request row. The detail panel opens.

Go to the **Response** tab. You'll see the formatted JSON error body:

```json
{
  "error": "internal_server_error",
  "message": "nil pointer dereference: shipping_address is nil"
}
```

> screenshots/02-response-error-body.png

### Step 3: Fix the bug

Apply the code fix (see Track A, Step 3) and restart your server.

### Step 4: Replay the request

Go to the **Compose** tab.

Click **Import from Traffic** and select the original failing request (#7).
This pre-fills the method, URL, headers, and body exactly as they were.

Click **Send**.

The new response appears in the right panel -- this time with a 200 status
and valid order data.

> screenshots/03-compose-replay-200.png

### Step 5: Diff the before and after

Go to the **Diff** tab.

- **Left side**: Select request #7 (the original 500)
- **Right side**: Select request #12 (the replayed 200)

The diff view highlights every change:
- Status: red 500 -> green 200
- Response body: error JSON removed, order JSON added

> screenshots/04-diff-side-by-side.png

This is the money shot -- visual proof your fix works.

### Step 6: Export the evidence

Go back to the **Traffic** tab. Right-click on request #7 and select **Copy as cURL**.
Repeat for request #12.

Paste both into your PR description.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*
- Agent + CLI demo: 0:00 - 4:00
- Web UI demo: 4:00 - 7:00

---

## What You Learned

- How to ask your AI agent to find and inspect failing requests
- How to replay the exact same request after a code change
- How to diff two responses to get concrete proof that a fix works
- How to do the full capture -> replay -> diff loop visually in the Web UI
- How to export before/after evidence for a pull request

## Why This Matters

The capture -> replay -> diff loop turns "I think my fix works" into "here's the
proof." No more manually comparing payloads in two terminal tabs. No more "it
works on my machine" without evidence.

This workflow is unique to APXY -- no other proxy tool packages capture, replay,
and diff into a single command chain that an AI agent can execute.

## Next Steps

- [Debugging CORS Errors](../debug-cors-errors/) -- Use APXY to diagnose CORS preflight issues
- [AI Agent: Mock While Fixing](../agent-mock-while-fixing/) -- Have your agent create temporary mocks to unblock teammates
- [Regression Testing with Diff](../regression-testing-with-diff/) -- Use replay + diff to catch API regressions before deployment
