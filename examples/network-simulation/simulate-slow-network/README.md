# Testing Your App on Slow Connections

See how your product behaves when the network is not a gigabit fiber link—before real users on 3G, rural broadband, or satellite complain about spinners that never end.

**Difficulty**: Beginner | **Time**: ~10 minutes | **Features used**: Network simulation (latency, bandwidth), SSL interception | **Requires**: Pro

## Scenario

Your app works great on fast WiFi, but what about users on 3G mobile connections or in regions with high latency? Simulate slow network conditions to find UI/UX issues before your users do: missing skeleton states, double submissions, timeouts that feel arbitrary, and flows that assume instant JSON.

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

Point your browser or API client at traffic that flows through the proxy (system proxy or explicit `HTTP(S)_PROXY`), then layer simulated conditions on top of real `https://api.myapp.com` calls.

### Step 1: Apply a 3G-like profile

**Tell your agent:**

> "Enable network simulation similar to mobile 3G: a couple hundred ms RTT, a few hundred kbps cap, and light packet loss."

**Your agent runs:**

```bash
apxy rules network set --latency 200 --bandwidth 384 --packet-loss 1
```

Exercise your app: navigation, search, infinite scroll, file upload if relevant. Note where loading feedback is missing, where users might tap twice, and which screens block the whole UI.

### Step 2: Try a slower broadband profile

**Tell your agent:**

> "Ease up slightly—still degraded but closer to slow home DSL."

**Your agent runs:**

```bash
apxy rules network set --latency 80 --bandwidth 2048 --packet-loss 0
```

Compare the same flows. Some bugs only appear when requests overlap (waterfalls); others show up only under extreme throttling.

### Step 3: Stress with a very slow or satellite-like profile

**Tell your agent:**

> "Crank up latency and loss to mimic awful conditions—very slow mobile or high-latency satellite."

**Your agent runs:**

```bash
apxy rules network set --latency 500 --bandwidth 128 --packet-loss 5
```

Watch for hard-coded timeouts, optimistic UI that never reconciles, and error messages that blame the user instead of the network.

### Step 4: Confirm what is active and clear simulation

Network simulation in APXY is global for proxied traffic: each `set` replaces the previous profile. There is no separate `list` subcommand; your agent can confirm behavior by driving the app or by checking the **Network** page in the Web UI (Track B).

**Tell your agent:**

> "Turn off all network simulation so traffic is normal again."

**Your agent runs:**

```bash
apxy rules network clear
```

Re-run a critical path once to verify baseline performance and that no client-side state was corrupted during testing.

---

## Track B: Web UI Workflow

Assume the Web UI is served by your proxy (default is often **http://localhost:8082**—use whatever URL your `apxy proxy start` output shows).

### Step 1: Open Network controls

Navigate to **Rules** → **Network** (or the **Network** page if your build surfaces it directly). You should see controls for **latency**, **bandwidth**, and **packet loss**.

> screenshots/01-network-rules.png

### Step 2: Match the 3G-like preset with sliders

Set latency near **200 ms**, bandwidth near **384 kbps**, packet loss near **1%**. Save or apply if the UI requires it.

> screenshots/02-network-3g-preset.png

### Step 3: Observe live traffic timing

Open **Traffic** in another tab or split view. Trigger requests to `api.myapp.com` and watch **Duration** or timing columns move compared to an uncleared baseline.

> screenshots/03-traffic-slow-network.png

### Step 4: Sweep presets and reset

Repeat with harsher values (e.g. **500 ms**, **128 kbps**, **5%** loss), then use the UI control to **clear** or zero out simulation so you return to normal forwarding.

> screenshots/04-network-clear.png

---

## Video Walkthrough

*[YouTube link -- coming soon]*

- 0:00 — Start proxy with SSL for `api.myapp.com`
- 2:00 — CLI: 3G-like `rules network set`, exercise the app
- 5:00 — Web UI sliders and Traffic view
- 7:30 — `apxy rules network clear` and sanity check

---

## What You Learned

- Applying **latency**, **bandwidth**, and **packet loss** together to approximate real-world profiles (3G, slow broadband, satellite-ish)
- Replacing conditions with each `apxy rules network set` and removing them with `apxy rules network clear`
- Spotting UX gaps: skeletons, cancellation, duplicate actions, and timeout copy under stress
- Correlating simulated conditions with longer rows in **Traffic** timing

## Next Steps

- [Simulate Network Failures](../simulate-network-failures/) — Packet loss, HTTP errors, and timeout-style latency
- [Debug Slow API](../../debugging/debug-slow-api/) — When slowness is real, not simulated
- [Replay and Diff](../../replay-and-diff/) — Compare captures before and after fixes
