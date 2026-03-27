# Setting Up HTTPS Interception

APXY can decrypt HTTPS for domains you choose, but only after you install and trust its certificate authority on your machine. This guide walks you through generating the CA, trusting it, and starting the proxy with SSL interception enabled.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: SSL setup, Certificate management | **Requires**: Free

## Scenario

You are debugging an API or web app over HTTPS. Without TLS interception, the proxy only sees encrypted tunnels -- no JSON bodies, no headers beyond the CONNECT handshake. You need APXY's CA on your system so the proxy can terminate TLS for specific hostnames, log plaintext, and let you mock or rewrite responses safely on your own machine.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux (certificate trust steps differ slightly; the commands below cover both paths)
- An AI coding agent (Claude Code, Cursor, Codex, or Copilot) with the APXY skill installed -- optional for Track B, recommended for Track A
- Ability to run elevated trust commands when prompted (`sudo` on Linux, or macOS Keychain approval)

---

## Track A: Agent + CLI Workflow

> Best for: agent-driven setup, reproducible steps in terminal history.

### Step 1: Generate the APXY CA certificate

Tell your agent:

> "Generate APXY's certificate authority so it can issue TLS certificates for intercepted domains."

Your agent runs:

```bash
apxy setup certs generate
```

Agent shows something like:

```
CA certificate generated successfully.
Certificate path: ~/.apxy/certs/apxy-ca.crt
Private key path:   ~/.apxy/certs/apxy-ca.key
```

If the files already exist, APXY reports that and skips regeneration unless you force it -- that is normal.

### Step 2: Trust the CA on your operating system

Tell your agent:

> "Trust the APXY CA on my system so browsers and CLI tools accept proxied HTTPS."

Your agent runs:

```bash
apxy setup certs trust
```

On macOS this typically adds the CA to the login keychain and may prompt for Touch ID or password. On Linux, the command installs into the system trust store where supported (distribution-dependent). If automatic trust fails, agent shows the manual path to `apxy-ca.crt` for you to import via system settings.

Agent reports:

```
Trust step completed (or: follow on-screen prompts).
Re-open browsers / terminal sessions if they were open during trust.
```

### Step 3: Start the proxy with SSL for specific domains

Tell your agent:

> "Start APXY and enable HTTPS interception only for api.example.com."

Your agent runs:

```bash
apxy proxy start --ssl-domains api.example.com
```

Startup output includes the Web UI URL (default **http://localhost:8082**) and confirms SSL proxying for the listed domains. Multiple hosts use commas, with optional wildcards where supported:

```bash
apxy proxy start --ssl-domains api.example.com,*.staging.example.com
```

### Step 4: Verify decryption with a real HTTPS request

Tell your agent:

> "Send a GET to https://api.example.com through the proxy and confirm APXY captured the decrypted response."

Your agent runs:

```bash
curl -sS https://api.example.com/health
apxy traffic logs list --limit 5
```

Agent shows recent rows where the URL matches your target and status/duration are populated. Then:

```bash
apxy traffic logs show --id <latest-id>
```

Agent reports full **request** and **response** bodies (JSON, HTML, etc.) -- not a raw TLS stream. If you still see tunnel-only metadata, the hostname may not match `--ssl-domains`, or the client is not using the system proxy.

### Step 5 (optional): Intercept all HTTPS with MITM-all mode

Tell your agent:

> "Restart the proxy with MITM enabled for every domain so I can capture bodies everywhere during this session."

Your agent runs:

```bash
apxy stop
apxy proxy start --mitm-all
```

Agent shows a warning-style line that all HTTPS is subject to deep inspection. Use this only on trusted networks and for short debugging windows; prefer `--ssl-domains` for day-to-day work. You can narrow exceptions later with `--bypass-domains` if needed.

```bash
apxy proxy start --mitm-all --bypass-domains "*.bank.com,*.openai.com"
```

### Step 6: Stop when finished

Tell your agent:

> "Stop the APXY proxy."

Your agent runs:

```bash
apxy stop
```

---

## Track B: Web UI Workflow

> Best for: visual confirmation of CA files, trust status, and domain list.

### Step 1: Open the Web UI

Start the proxy (or ask your agent to):

```bash
apxy proxy start --ssl-domains api.example.com
```

Open **http://localhost:8082** in your browser.

> screenshots/01-dashboard-ssl-partial.png

### Step 2: Open the SSL page and generate the CA

Go to **SSL** -> click **Generate Certificate** (or equivalent) if the UI shows the CA is missing. Wait for the success toast or status badge.

> screenshots/02-ssl-generate-ca.png

### Step 3: Trust the CA from the UI

Use the **Trust** or **Install CA** action on the same page. Follow the OS-specific panel or deep link the UI provides. Complete any macOS Keychain or Linux trust wizard steps.

> screenshots/03-ssl-trust-ca.png

### Step 4: Configure interception domains

In the SSL domain list, add `api.example.com` (and any wildcards your team uses). Save or apply changes. Confirm the list matches what you would pass to `--ssl-domains` on the CLI.

> screenshots/04-ssl-domain-list.png

### Step 5: Verify traffic is decrypted

Go to **Traffic**, generate a request to your HTTPS host (browser or `curl`), **Traffic** -> click a row -> **Response** tab to confirm readable body content.

> screenshots/05-traffic-decrypted-body.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- CA generate + trust: 0:00 - 2:00
- Domain-scoped proxy start + verification: 2:00 - 4:30
- Optional `--mitm-all`: 4:30 - 5:00

---

## What You Learned

- How APXY's CA fits into HTTPS interception and why trust is required
- How to run `apxy setup certs generate` and `apxy setup certs trust`
- How to scope interception with `--ssl-domains` versus broad `--mitm-all`
- How to confirm decryption via `apxy traffic logs list` / `apxy traffic logs show` or the Web UI Traffic view
- When to prefer narrow domain lists over full MITM for safety and noise control

## Next Steps

- [Your First 5 Minutes with APXY](../../quickstart-5-minutes/) -- capture and inspect HTTP/S traffic end-to-end
- [Exploring the Web UI](../web-ui-tour/) -- tour every dashboard tab after SSL works
- [Debug CORS Errors](../../debug-cors-errors/) -- use decrypted traffic to fix browser/API mismatches
