# Testing Resilience to Network Problems

Push your client and server integration past the happy path: dropped packets, unavailable backends, and agonizing delays so retries, circuit breakers, and error UI earn their keep.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Network simulation (packet loss), Mock rules, SSL interception | **Requires**: Pro

## Scenario

Your app needs to handle network failures gracefully—timeouts, dropped connections, server errors. Simulate these conditions to verify your retry logic, error messages, and fallback behavior without deploying broken infrastructure or firewall rules you will forget to remove.

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

Use **network** rules for transport-level chaos and **mock** rules for deterministic HTTP status bodies when you need a specific API to “go red.”

### Step 1: Simulate heavy packet loss

**Tell your agent:**

> "Turn on severe packet loss so many requests fail at the transport layer—I want to see how my app handles flaky networks."

**Your agent runs:**

```bash
apxy rules network set --packet-loss 50
```

Drive flows that depend on multiple parallel calls (dashboards, checkout). Expect intermittent failures, partial loads, and race conditions between retries. Note whether your UI surfaces “try again” vs. silent failure.

### Step 2: Simulate a 503 from a critical endpoint

**Tell your agent:**

> "Return 503 with a JSON body for the health check URL so I can test service-unavailable handling."

**Your agent runs:**

```bash
apxy rules mock add --name "health-503" --url "https://api.myapp.com/api/health" --status 503 --body '{"error":"service_unavailable"}'
```

Confirm the client treats 503 differently from 404/401, respects any backoff, and does not cache the error as success. List or remove mocks when finished:

```bash
apxy rules mock list
apxy rules mock remove --id <MOCK_RULE_ID>
```

### Step 3: Simulate extreme latency (timeout pressure)

**Tell your agent:**

> "Add thirty seconds of artificial latency so client-side timeouts fire— I need to verify my timeout and retry policy."

**Your agent runs:**

```bash
apxy rules network set --latency 30000
```

This does not guarantee your HTTP client will wait exactly 30 seconds; stacks differ. The goal is to force **your** configured timeouts to trigger. After the exercise, clear simulation:

```bash
apxy rules network clear
```

### Step 4: Combine failure modes carefully

**Tell your agent:**

> "Stack a mock 503 on `/api/health` while keeping moderate packet loss, then clear mocks and network when done."

**Your agent runs:**

```bash
apxy rules network set --packet-loss 20 --latency 100
apxy rules mock add --name "health-503" --url "https://api.myapp.com/api/health" --status 503 --body '{"error":"service_unavailable"}'
```

Document what you observed, then tear down:

```bash
apxy rules mock remove --all
apxy rules network clear
```

### Step 5: Verify retry behavior explicitly

**Tell your agent:**

> "With normal network (cleared), replay a captured failing request or compose a GET to health and confirm 200 again."

**Your agent runs:**

```bash
apxy rules network clear
apxy tools request compose --method GET --url "https://api.myapp.com/api/health"
```

---

## Track B: Web UI Workflow

### Step 1: Packet loss from the Network page

Open **Rules** → **Network**. Raise **packet loss** toward **50%**. Save/apply. In **Traffic**, trigger actions that fan out to many requests.

> screenshots/01-network-packet-loss.png

### Step 2: Add a mock for 503

Navigate to **Rules** → **Mock** (or equivalent). Create a rule: URL `https://api.myapp.com/api/health`, status **503**, body `{"error":"service_unavailable"}`.

> screenshots/02-mock-503-health.png

### Step 3: Extreme latency slider

On **Network**, set **latency** into the tens of seconds range if the UI allows, or the maximum your build supports. Watch **Traffic** for stalled requests and client-side aborts.

> screenshots/03-network-extreme-latency.png

### Step 4: Clean up in the UI

Disable or delete the mock rule. Reset **Network** sliders or use **clear** so the proxy forwards normally.

> screenshots/04-rules-cleanup.png

---

## Video Walkthrough

*[YouTube link -- coming soon]*

- 0:00 — SSL proxy for `api.myapp.com`
- 2:00 — High packet loss and reading **Traffic**
- 4:30 — Mock 503 on `/api/health`
- 6:30 — 30s latency and timeout behavior
- 8:30 — Clearing mocks and network simulation

---

## What You Learned

- Using `apxy rules network set` with **packet loss** and **latency** to stress transport behavior
- Returning precise **503** bodies with `apxy rules mock add` for API-level failure injection
- Listing and removing mock rules with `apxy rules mock list` / `apxy rules mock remove`
- Resetting global simulation with `apxy rules network clear` so you do not pollute the next debugging session

## Next Steps

- [Simulate Slow Network](../simulate-slow-network/) — Throttle bandwidth for UX testing
- [Simulate Rate Limiting](../simulate-rate-limiting/) — 429 and `Retry-After` without vendor sandboxes
- [Debug Flaky API](../../debugging/debug-flaky-api/) — When failures are environmental, not mocked
