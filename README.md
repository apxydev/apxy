# APXY — Agent Proxy

[![Version](https://img.shields.io/badge/version-1.1.1-blue.svg)](https://github.com/apxydev/apxy/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)]()

**HTTPS debugging for humans and AI agents.**

APXY is a desktop network proxy that sits between your computer and the internet, letting you **inspect, mock, and debug** HTTP/HTTPS traffic. Use it through a **CLI** (100+ commands) or a **Web GUI**.

<!-- TODO: Add demo GIF here -->
<!-- ![APXY Demo](assets/demo.gif) -->

## Install

**Homebrew** (macOS / Linux):

```bash
brew tap apxydev/apxy https://github.com/apxydev/apxy
brew install apxy
```

**Shell script**:

```bash
curl -fsSL https://raw.githubusercontent.com/apxydev/apxy/main/scripts/install.sh | bash
```

## AI Agent Skill

Give your AI coding agent full knowledge of APXY's CLI — every command, flag, and workflow — so it can debug traffic, mock APIs, and validate schemas on your behalf.

Works with **Claude Code**, **Cursor**, **Codex**, **Gemini CLI**, **GitHub Copilot**, and other agents that support the [skills](https://github.com/vercel-labs/skills) ecosystem.

**Install the skill:**

```bash
npx skills add apxydev/apxy
```

Once installed, your agent understands how to:

- Start/stop the proxy and configure HTTPS interception
- Create mock rules, redirects, interceptors, breakpoints, and scripts
- Search, filter, diff, replay, and export captured traffic
- Import OpenAPI schemas and validate traffic against them
- Run SQL queries on captured requests
- Set up certificates and mobile device debugging
- Simulate network conditions (latency, bandwidth, packet loss)

**Example prompts you can give your agent:**

> "Start APXY and capture all traffic to api.example.com"
>
> "Mock the /api/payments endpoint to return a 200 with a test response"
>
> "Find all requests that returned 500 errors in the last hour"
>
> "Import my OpenAPI spec and validate recent traffic against it"
>
> "Set a breakpoint on POST /api/login so I can inspect the request before it's sent"

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.

## Reporting Issues

Found a bug or have a feature request? [Open an issue](https://github.com/apxydev/apxy/issues).
