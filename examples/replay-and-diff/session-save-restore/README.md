# Saving and Restoring Debug Sessions

After an hour of deep debugging—hundreds of captures, mock rules, and SSL
settings—you can freeze the entire session to a JSON file and let a teammate
thaw it on their laptop without re-enacting your steps.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Session export/import, Settings management, SSL interception | **Requires**: Pro

## Scenario

You have spent a long session chasing a complex issue. APXY now holds **200+**
requests against `api.myapp.com`, several **mock rules** that isolate flaky
dependencies, and possibly custom **project settings** you tuned for SSL or
device trust. You need to **save** that whole debugging context, send one file
to a colleague, and have them **restore** it so they continue exactly where you
left off.

Settings export/import is a **Pro** (or Personal) capability: it bundles the
parts of APXY state that live behind the control plane, not just raw SQLite
copies.

## Prerequisites

- APXY installed (`apxy version` works)
- **Pro** license (settings import/export is gated)
- macOS or Linux
- AI coding agent with APXY skill installed
- Proxy **running** when exporting/importing settings via the control API (use
  `apxy status` to confirm)

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

> Export captures **settings** that round-trip with the control server—mock
> rules and related configuration your team relies on during a joint debug. Raw
> traffic remains in your local SQLite database unless you also copy the DB or
> use other export paths (HAR, etc.); coordinate with your teammate if they need
> identical traffic rows.

### Step 1: Confirm the session you want to freeze

**Tell your agent:**

> "Show how many traffic records we have and list active mock rules—I want to
> snapshot this debugging session."

**Your agent runs:**

```bash
apxy logs stats
apxy mock list
```

Skim rule names and priorities so the export you share matches what you expect
in the ticket or Slack thread.

### Step 2: Export settings to a file

**Tell your agent:**

> "Export all current APXY settings to debug-session-2024.json on disk."

**Your agent runs:**

```bash
apxy setup settings export --file debug-session-2024.json
```

If your agent connects to a non-default control API, it may pass the same
`--control-url` you use elsewhere (for example when multiple proxies run).

The command writes JSON containing the settings bundle the control server
returns. Treat this file like credentials-adjacent data if it includes hostnames
or rule patterns your org considers sensitive.

### Step 3: Share the artifact

Upload `debug-session-2024.json` to your secure file share, or attach it to a
private ticket. In the message, list:

- APXY version you used (`apxy version`)
- Whether traffic replay requires the teammate to **also** receive a HAR export
  or DB copy
- Any upstream services or env vars still required (API keys, feature flags)

### Step 4: Teammate imports on a fresh machine

On the receiving side, after installing APXY and starting the proxy:

**Tell your agent:**

> "Import APXY settings from debug-session-2024.json. I understand this
> overwrites current settings."

**Your agent runs:**

```bash
apxy setup settings import --file debug-session-2024.json
```

Import **replaces** the current settings snapshot. Your teammate should export
their own settings first if they have local work worth keeping.

### Step 5: Verify restoration

**Tell your agent:**

> "List mock rules again and confirm they match the exported session."

**Your agent runs:**

```bash
apxy mock list
```

Have them hit a known mocked path through the proxy to confirm behavior before
resuming the investigation.

### Step 6: Optional traffic alignment

If diffs or replays require **the same record IDs**, pair settings import with:

- `apxy logs export-har --file session.har` on the sender side and HAR
  import on the receiver, or
- Copying the project SQLite path documented in your internal runbook

Document which approach you chose in the handoff message so nobody assumes IDs
match magically.

---

## Track B: Web UI Workflow

> Use the UI to sanity-check state before and after import.

### Step 1: Review current rules and traffic

Open **http://localhost:8082**. Visit **Rules** (or Mock rules view) and **Traffic**
to capture a mental picture of names and volume before export.

> screenshots/01-dashboard-rules-traffic.png

### Step 2: Export (CLI or future UI hook)

Today, **settings export** is invoked from the CLI (`setup settings export`).
Run the export from a terminal while the Web UI reflects the session you see.

> screenshots/02-terminal-settings-export.png

### Step 3: After import on teammate machine

Open the Web UI again. Confirm mock rules reappear with the same priorities and
that Traffic begins filling as they reproduce flows.

> screenshots/03-web-ui-after-import.png

### Step 4: Smoke-test a mocked endpoint

From **Compose**, send a request that should hit a mock rule imported from your
file. Verify the mocked response shape matches the saved session behavior.

> screenshots/04-compose-mock-smoke-test.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Export + file handoff: 0:00–4:00
- Import + verification: 4:00–8:30
- Web UI sanity checks: 8:30–10:30

---

## What You Learned

- Which operations require **Pro** for settings round-trip
- How `setup settings export --file` snapshots control-plane settings
- How `setup settings import --file` restores them—and overwrites local settings
- Why traffic identity may still need HAR/DB coordination
- How to validate restoration with `rules mock list` and Compose smoke tests

## Next Steps

- [Sharing a Debug Artifact with Your Team](../share-debug-artifact/) — lighter-weight bundle with `config export`
- [Catching API Regressions Before Deployment](../regression-testing-with-diff/) — replay + diff after restore
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) — align certificates on both machines
