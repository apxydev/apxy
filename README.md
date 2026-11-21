# APXY

[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux-lightgrey.svg)](#install)

APXY is a local proxy for HTTP and HTTPS. It shows you every request your app sends and every response it gets back. You can also mock an endpoint, replay a request after a fix, and diff the two responses.

Use the CLI from your terminal or your AI coding agent. Use the Web UI when you want to click through traffic.

![APXY Web UI showing live traffic](assets/live-traffic.png)

## Install

Install with Homebrew on macOS or Linux:

```bash
brew tap apxydev/apxy https://github.com/apxydev/apxy
brew install apxy
```

Or install with the shell script:

```bash
curl -fsSL https://apxy.dev/install.sh | bash
```

## See your first request

This takes about two minutes. You start the proxy, send one request through it, and look at what APXY captured.

> [!NOTE]
> APXY records the full body of an HTTPS request only for domains that you turn on. Other HTTPS traffic shows up as a `CONNECT` line with the host name and no body. Turn on a domain with `--ssl-domains` when you start APXY, or later with `apxy ssl enable --domain <host>`.

1. Start the proxy and turn on HTTPS capture for `httpbin.org`:

   ```bash
   apxy start --ssl-domains httpbin.org
   ```

   On the first run on macOS, APXY creates a certificate and asks for your password to trust it. It also turns on the system proxy, so your browser and apps go through APXY.

2. In a second terminal, send a request through APXY:

   ```bash
   apxy run curl https://httpbin.org/get
   ```

   `apxy run` starts any command with the proxy settings and the certificate already set. Your shell stays unchanged.

3. Look at the request. Open the Web UI at <http://localhost:8082>, or list it in the terminal:

   ```bash
   apxy logs list --limit 5
   ```

   You see a `GET` to `https://httpbin.org:443/get` with status `200`.

4. Stop the proxy when you are done:

   ```bash
   apxy stop
   ```

   APXY turns the system proxy off again.

On Linux, start with `apxy start --no-system-proxy` and send traffic through `apxy run`.

## What else you can do

The [user guide](docs/user-guide.md) shows the commands for each of these:

- [Find and inspect requests](docs/user-guide.md#traffic-capture--inspection) by URL, header, or body.
- [Mock an API](docs/user-guide.md#mock-rules) that is broken or not built yet.
- [Replay a request](docs/user-guide.md#export--replay) after a fix, or export it as a curl command.
- [Diff two requests](docs/user-guide.md#diff) to see what your fix changed.
- [Slow down the network](docs/user-guide.md#network-conditions) to test loading states and timeouts.

## Use APXY with your AI coding agent

Your agent cannot see network traffic from your editor. APXY gives it the real requests and responses.

Install the APXY skill. It works with Claude Code, Cursor, Codex, Gemini CLI, GitHub Copilot, and other agents that support [skills](https://github.com/vercel-labs/skills).

```bash
npx skills add apxydev/apxy
```

Or connect APXY as an MCP server. This command sets up Claude Code:

```bash
apxy setup mcp --client claude-code --write
```

Then ask your agent things like:

> "Start APXY and show me every request to api.example.com that returned a 500."
>
> "Mock POST /api/payments to return a 402 card error so I can test the error screen."
>
> "Replay the failing checkout request and diff it against the one before my fix."

## Free and Pro

The Free plan has every feature and needs no account. Each Free proxy session stops after 10 minutes. Run `apxy start` again to start a new session. [APXY Pro](https://apxy.dev/license) removes the time limit.

## Learn more

- [Getting started](docs/getting-started.md) has the full install and first-run guide.
- [User guide](docs/user-guide.md) covers every feature.
- [Troubleshooting](docs/troubleshooting.md) and the [FAQ](docs/faq.md) answer common problems.
- [Examples](examples/README.md) walk through real debugging, mocking, and AI agent workflows.
- [Mock templates](mock-templates/README.md) give you ready-made mocks for Stripe, GitHub, and OpenAI.
- [apxy.dev/docs](https://apxy.dev/docs) has the online docs.

## Contribute and get help

- Read [CONTRIBUTING.md](CONTRIBUTING.md) to add a mock template, an example, or a fix.
- [Open an issue](https://github.com/apxydev/apxy/issues) to report a bug or ask for a feature.
- Read [SECURITY.md](SECURITY.md) to report a security problem.
- Email [support@apxy.dev](mailto:support@apxy.dev) for anything else.
