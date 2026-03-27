# Using APXY as a Claude Code / Cursor Skill

Give your coding agent first-class access to APXY: install the skill once, verify **`apxy version`**, then describe traffic problems in plain English while the agent runs the right CLI commands autonomously.

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Agent skill setup, Traffic search, Traffic inspection | **Requires**: Free

## Scenario

You want your AI coding agent to use APXY for HTTP/HTTPS debugging: searching captures, showing full records, diffing responses, adding mocks, and (when licensed) running SQL. This guide installs the **APXY skill** so the model knows command names, flags, and safe patterns. Every other tutorial under **`examples/ai-agent/`** assumes you completed this step.

## Prerequisites

- APXY installed on your machine -- the **`apxy`** binary on **`PATH`**
- macOS or Linux (Windows agents can work with WSL; paths may differ)
- Claude Code, Cursor, Codex, Copilot, or another agent runtime that loads project or user **skills** / **rules** from markdown

## Before You Start

No proxy is required **only** to verify the binary. For real traffic capture you will still run:

```bash
apxy proxy start --ssl-domains api.example.com
```

Replace **`api.example.com`** with your actual target domain(s). See [SSL Setup Guide](../../getting-started/ssl-setup-guide/) before intercepting HTTPS.

---

## Track A: Agent + CLI Workflow

> Skills are plain markdown the agent reads as tool documentation. Placement depends on your product; below are representative patterns.

### Step 1: Install the APXY skill file

Copy the official APXY skill markdown into the location your agent expects:

| Product | Typical location |
|--------|------------------|
| Cursor | `.cursor/rules/` or project **`AGENTS.md`** / **`CLAUDE.md`** with an `@` reference to the skill |
| Claude Code | User or repo **`.claude/skills/`** or documented skills directory |
| Other | Any path referenced from your repo's agent instructions |

**Tell your agent:**

> "I've added the APXY skill to this repo under [path]. Read it before running any apxy commands."

Use the path you actually created. If your org ships skills from **`apxy-public`** or the main **`apxy`** repo, clone or submodule that file so it stays updated with releases.

### Step 2: Wire the skill into your agent bootstrap

Ensure your project's agent entry file mentions APXY explicitly, for example in **`AGENTS.md`**:

```markdown
## Network debugging
When debugging HTTP/HTTPS traffic, use APXY. Follow the APXY skill for exact CLI syntax.
```

**Tell your agent:**

> "From now on, prefer APXY (`apxy` CLI) for proxy capture, mocks, replay, and diffs instead of guessing curl-only workflows."

### Step 3: Verify the binary

**Tell your agent:**

> "Confirm APXY is installed and report the version string."

**Your agent runs:**

```bash
apxy version
```

If this fails, install from [apxy.dev](https://apxy.dev) or your package manager, then retry.

### Step 4: Smoke-test help output

**Tell your agent:**

> "Show the top-level apxy help so we know subcommands are visible."

**Your agent runs:**

```bash
apxy --help
```

The agent should see command groups such as **`proxy`**, **`traffic`**, **`logs`**, **`rules`**, and **`tools`**.

### Step 5: Example interaction -- search traffic

After **`apxy proxy start --ssl-domains api.example.com`** and a few requests through the proxy:

**Tell your agent:**

> "Search captured traffic for the word 'error' and summarize the last three hits."

**Your agent runs:**

```bash
apxy logs search --query "error"
```

### Step 6: Example interaction -- inspect one record

**Tell your agent:**

> "Show full details for traffic id 3."

**Your agent runs:**

```bash
apxy logs show --id 3
```

### Step 7: Example interaction -- temporary mock

**Tell your agent:**

> "Add a mock that returns 200 JSON for GET https://api.example.com/health."

**Your agent runs:**

```bash
apxy rules mock add --name "skill-demo-health" \
  --url "https://api.example.com/health" \
  --method GET \
  --status 200 \
  --body '{"status":"ok"}'
```

### Step 8: Example interaction -- cleanup

**Tell your agent:**

> "Remove the demo health mock by id after listing rules."

**Your agent runs:**

```bash
apxy rules mock list
apxy rules mock remove --id RULE_ID_FROM_LIST
```

### Step 9: Keep the skill version-aligned

When you upgrade APXY, diff release notes for new commands (for example additional **`traffic`** or **`tools`** subcommands) and update the skill markdown so the agent does not hallucinate flags.

---

## Track B: Web UI Workflow

The Web UI is optional for skill setup. After the agent can run CLI commands, open the local dashboard (default **http://localhost:8082**) to **see the same captures** the agent manipulates. Many teams use the UI for screenshots while the agent uses the CLI for reproducible steps in chat logs. You do not need Track B to consider the skill installed.

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Dropping the skill into Cursor / Claude Code
- `apxy version` and first `apxy logs search` from natural language

---

## What You Learned

- Where to place an APXY **skill** file so your agent loads it reliably
- How to **`apxy version`** gate every other tutorial
- Concrete prompt shapes for **search**, **show**, **mock add**, and **mock remove**
- That the Web UI complements but does not replace CLI-first agent workflows

---

## Next Steps

- [Let Your AI Agent Find and Fix Server Errors](../agent-debug-500-errors/) -- SQL + jsonpath incident flow
- [AI Agent Creates Mocks to Unblock While Fixing](../agent-mock-while-fixing/) -- team unblocking pattern
- [AI Agent Validates a Fix with Replay+Diff](../agent-compare-before-after/) -- proof after your patch
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- required before HTTPS bodies are visible
