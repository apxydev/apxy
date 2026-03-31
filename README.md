# APXY — Network Debugging and API Mocking for Developers and AI Coding Agents

[![Version](https://img.shields.io/badge/version-1.0.7-blue.svg)](https://github.com/apxydev/apxy/releases)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)]()

**Capture, inspect, mock, replay, and diff HTTP/HTTPS traffic from a CLI and Web UI. Built for developers and AI coding agents.**

APXY sits between your app and the network so you can see every HTTP/HTTPS request and response. Use the **CLI** for scripting, automation, and AI-assisted debugging, or the **Web UI** for visual inspection and rule management. Mock APIs, replay requests, diff responses, and simulate bad networks from one local proxy.

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

## AI Coding Agent Skill

Give your AI coding agent full knowledge of APXY's CLI so it can debug traffic, mock APIs, and validate schemas with real network evidence instead of guesswork.

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

## Templates And Examples

APXY already ships with reusable public assets you can use as starting points or contribute to:

- [Mock Templates](mock-templates/README.md) — reusable rules for Stripe, GitHub, and OpenAI
- [Examples](examples/README.md) — debugging, mocking, and AI-agent workflow walkthroughs
- [Website Templates](https://apxy.dev/templates) — fast install paths for public mock kits
- [Website Examples](https://apxy.dev/examples) — artifact-style workflow pages built for discovery

These assets are the fastest way to learn APXY from a real use case instead of a generic setup guide.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to contribute.

## Reporting Issues

Found a bug or have a feature request? [Open an issue](https://github.com/apxydev/apxy/issues).
