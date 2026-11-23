# APXY CLI command reference

This file lists all 105 APXY commands and their flags. It is generated from the CLI help text.

Global flags work on every command: `--config`, `--error-format` (text|json, default text), `--help-format` (default|agent, default default; shows JSON help; add `--help` too for versions before v1.8.0), `--no-project`, `--output` (agent|human), `--verbose`.

`--control-url` points a command at the control API of a running proxy. The default is `http://127.0.0.1:8081`.

## Capture and verify

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy start` | Start the local APXY proxy | `--auto-validate`, `--bypass-domains`, `--cert-dir` (default ~/.apxy/certs), `--control-port`, `--insecure-upstream`, `--listen-addr` (default 127.0.0.1), `--max-body` (default 10485760), `--mitm-all`, `--network-service`, `--no-block-quic`, `--no-mdns`, `--no-system-proxy`, `--no-trust-ca`, `--port` (default 8080), `--project-dir`, `--proxy-listen-addr`, `--ssl-domains`, `--tls-keylog`, `--upstream-proxy`, `--web-port` |
| `apxy stop` | Stop the local APXY proxy and disable system proxy settings |  |
| `apxy status` | Show whether the local APXY proxy is running | `--format` (json\|toon, default json), `--port` (default 8080), `--quiet` |
| `apxy run` | Run a command with proxy + CA env vars routed through APXY | `apxy start` flags before `--`, such as `--port`, `--ssl-domains`, `--mitm-all` |
| `apxy shell` | Start an interactive shell with proxy env vars set | `--lang` (default all) |
| `apxy env` | Print proxy environment variables for shell sessions | `--bypass-domains`, `--cert-dir` (default ~/.apxy/certs), `--lang` (default all), `--no-cert`, `--port` (default 8080), `--script` |
| `apxy browser` | Open a URL in a browser configured to route through APXY | `--arc`, `--brave`, `--chrome`, `--edge`, `--firefox`, `--safari` |
| `apxy mark` | Record a point in time for apxy wait --since |  |
| `apxy wait` | Block until a matching request is captured, then check expectations | `--expect`, `--match`, `--since`, `--timeout` (default 30s) |
| `apxy recording start` | Start capturing traffic on the running proxy |  |
| `apxy recording stop` | Stop capturing traffic on the running proxy |  |

## Traffic logs

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy logs ai-usage` | Show LLM token usage and estimated cost from captured AI traffic | `--since`, `--until` |
| `apxy logs clear` | Delete all captured traffic records | `--dry-run` |
| `apxy logs diff` | Compare two captured traffic records | `--id-a`, `--id-b`, `--scope` (request\|response\|both, default both) |
| `apxy logs egress` | Summarize captured traffic by host and check it against an allowlist | `--allowlist`, `--quiet`, `--since` (default all) |
| `apxy logs export-curl` | Export one traffic record as a reusable client snippet | `--format` (curl\|fetch\|httpie\|python, default curl), `--id`, `--redact`, `--safe` |
| `apxy logs export-har` | Export captured traffic as a HAR 1.2 file | `--file`, `--limit` (default 10000), `--redact`, `--safe` |
| `apxy logs graphql` | Search captured GraphQL requests | `--format` (json\|markdown\|toon, default json), `--limit` (default 20), `--operation-name`, `--operation-type` (query\|mutation\|subscription) |
| `apxy logs import-har` | Import traffic records from a HAR file | `--file` |
| `apxy logs jsonpath` | Extract JSON fields from captured traffic bodies | `--id`, `--path`, `--scope` (request\|response, default response) |
| `apxy logs label` | Add a label and comment to a traffic record | `--color`, `--comment`, `--id` |
| `apxy logs list` | List captured traffic records | `--format` (json\|markdown\|toon, default json), `--limit` (default 50), `--offset`, `--quiet`, `--raw` |
| `apxy logs replay` | Replay one captured request against the live upstream | `--id`, `--port` (default 8080) |
| `apxy logs search` | Search captured traffic records | `--format` (json\|markdown\|toon, default json), `--limit` (default 20), `--query`, `--quiet`, `--raw` |
| `apxy logs search-bodies` | Search request and response bodies in captured traffic | `--format` (json\|markdown\|toon, default json), `--limit` (default 20), `--pattern`, `--scope` (request\|response\|both, default both) |
| `apxy logs show` | Show one captured traffic record by ID | `--format` (json\|markdown\|toon, default json), `--id`, `--raw` |
| `apxy logs sse-events` | List parsed SSE events for a traffic record | `--format` (default text), `--id`, `--limit` (default 100) |
| `apxy logs sse-merge` | Merge AI streaming SSE events into a single response | `--format` (default text), `--id` |
| `apxy logs stats` | Show summary statistics for captured traffic |  |
| `apxy logs tail` | Live-tail traffic from a running apxy instance | `--format` (default text), `--host`, `--port` (default 8082), `--sse` |
| `apxy logs ws-frames` | List WebSocket connections or inspect frames for one connection | `--id`, `--limit` (default 50), `--quiet`, `--raw` |

## Mock rules

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy mock add` | Add a mock response rule | `--body`, `--delay`, `--header-conditions`, `--headers`, `--match` (exact\|wildcard\|regex, default exact), `--method`, `--name`, `--priority`, `--status` (default 200), `--url` |
| `apxy mock clear` | Delete all mock rules | `--dry-run` |
| `apxy mock disable` | Disable a mock rule | `--all`, `--dry-run`, `--id` |
| `apxy mock edit` | Edit a mock response rule | `--body`, `--delay`, `--header-conditions`, `--headers`, `--match` (exact\|wildcard\|regex), `--method`, `--name`, `--priority`, `--status`, `--url` |
| `apxy mock enable` | Enable a mock rule | `--all`, `--dry-run`, `--id` |
| `apxy mock from-traffic` | Turn captured traffic into replay mock rules (record once, replay in tests) | `--file`, `--host`, `--id`, `--ignore-field` (default [metadata,user]), `--limit` (default 200), `--miss` (fail\|passthrough, default fail) |
| `apxy mock import` | Import mock rules from a JSON template file | `--file` |
| `apxy mock list` | List mock rules | `--format` (json\|toon, default json), `--quiet` |
| `apxy mock remove` | Remove a mock rule by ID or all mock rules | `--all`, `--dry-run`, `--id` |

## Rewrite rules

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy rewrite disable` | Disable a rewrite rule | `--all`, `--dry-run`, `--id` |
| `apxy rewrite edit` | Edit a rewrite rule | `--from`, `--match` (exact\|wildcard\|regex), `--name`, `--to` |
| `apxy rewrite enable` | Enable a rewrite rule | `--all`, `--dry-run`, `--id` |
| `apxy rewrite list` | List rewrite rules | `--format` (json\|toon, default json), `--quiet` |
| `apxy rewrite remove` | Remove a rewrite rule by ID or all rewrite rules | `--all`, `--dry-run`, `--id` |
| `apxy rewrite set` | Add a rewrite rule that rewrites matching request URLs | `--from`, `--match` (exact\|wildcard\|regex, default exact), `--name`, `--to` |

## DNS overrides

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy dns list` | List DNS overrides | `--quiet` |
| `apxy dns remove` | Remove the DNS override for a hostname | `--host` |
| `apxy dns set` | Point a hostname at an IP address | `--host`, `--ip` |

## Filter rules

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy filter disable` | Disable a traffic filter rule | `--all`, `--dry-run`, `--id` |
| `apxy filter edit` | Edit a traffic filter rule | `--target`, `--type` (block\|allow) |
| `apxy filter enable` | Enable a traffic filter rule | `--all`, `--dry-run`, `--id` |
| `apxy filter list` | List traffic filter rules | `--format` (json\|toon, default json), `--quiet` |
| `apxy filter remove` | Remove a traffic filter rule by ID or all filter rules | `--all`, `--dry-run`, `--id` |
| `apxy filter set` | Add a traffic filter rule to allow or block requests | `--target`, `--type` (block\|allow, default block) |

## Breakpoints

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy breakpoint add` | Add a breakpoint rule | `--match`, `--name`, `--phase` (default both), `--timeout` (default 30000) |
| `apxy breakpoint disable` | Disable a breakpoint rule | `--all`, `--dry-run`, `--id` |
| `apxy breakpoint edit` | Edit a breakpoint rule | `--match`, `--name`, `--phase`, `--timeout` |
| `apxy breakpoint enable` | Enable a breakpoint rule | `--all`, `--dry-run`, `--id` |
| `apxy breakpoint list` | List breakpoint rules | `--format` (json\|toon, default json), `--quiet` |
| `apxy breakpoint pending` | List requests currently paused at breakpoints | `--quiet` |
| `apxy breakpoint remove` | Remove a breakpoint rule by ID or all breakpoint rules | `--all`, `--dry-run`, `--id` |
| `apxy breakpoint resolve` | Resume a paused request at a breakpoint | `--body`, `--drop`, `--dry-run`, `--headers`, `--id`, `--status` |

## Scripts

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy script add` | Add a proxy script | `--code`, `--file`, `--hook` (default onResponse), `--match` (default *), `--name` |
| `apxy script disable` | Disable a proxy script | `--all`, `--dry-run`, `--id` |
| `apxy script edit` | Edit a proxy script | `--code`, `--file`, `--hook`, `--match`, `--name` |
| `apxy script enable` | Enable a proxy script | `--all`, `--dry-run`, `--id` |
| `apxy script list` | List proxy scripts | `--format` (json\|toon, default json), `--quiet` |
| `apxy script remove` | Remove a proxy script by ID or all scripts | `--all`, `--dry-run`, `--id` |

## Network conditions

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy network clear` | Clear simulated network conditions | `--dry-run` |
| `apxy network set` | Apply simulated network conditions to proxied traffic | `--bandwidth`, `--latency`, `--packet-loss` |

## Caching

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy caching disable-cache` | Disable upstream caching for proxied traffic | `--host` |
| `apxy caching enable-cache` | Re-enable normal upstream caching behavior |  |

## Schemas

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy schema delete` | Delete a schema | `--dry-run`, `--id` |
| `apxy schema import` | Import an OpenAPI schema from a file or URL | `--file`, `--name`, `--url` |
| `apxy schema list` | List all imported schemas | `--format` (json\|toon, default json), `--quiet` |
| `apxy schema show` | Show details of a specific schema | `--id` |
| `apxy schema validate` | Validate a traffic record against a schema | `--record-id`, `--schema-id` |
| `apxy schema validate-recent` | Validate recent traffic against all schemas | `--limit` (default 20) |

## Certificates and HTTPS

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy certs custom add` | Add a custom CA for a domain pattern | `--cert`, `--domain`, `--key`, `--label`, `--no-trust` |
| `apxy certs custom info` | Show details for a custom CA | `--domain` |
| `apxy certs custom list` | List all custom CAs | `--format` (json\|toon, default json), `--quiet` |
| `apxy certs custom remove` | Remove a custom CA by domain pattern or all custom CAs | `--all`, `--domain`, `--dry-run` |
| `apxy certs custom trust` | Trust a previously added custom CA in the system keychain | `--domain` |
| `apxy certs generate` | Generate the APXY root CA certificate |  |
| `apxy certs info` | Show details for the APXY root CA certificate |  |
| `apxy certs trust` | Trust the APXY root CA in the system keychain |  |
| `apxy ssl disable` | Disable HTTPS interception for a domain or all domains | `--all`, `--domain`, `--dry-run` |
| `apxy ssl enable` | Enable HTTPS interception for a domain | `--domain` |
| `apxy ssl list` | List domains with HTTPS interception enabled | `--format` (json\|toon, default json), `--quiet` |

## Setup and config

| Command | Description | Flags |
|---------|-------------|-------|
| `apxy init` | Initialize a project-scoped APXY workspace |  |
| `apxy setup agents` | Add the APXY verify section to AGENTS.md and CLAUDE.md | `--dir`, `--dry-run`, `--remove`, `--target`, `--yes` |
| `apxy setup mcp` | Configure MCP clients to use APXY | `--all`, `--client`, `--scope`, `--write` |
| `apxy mcp` | Run the APXY MCP server for AI clients |  |
| `apxy config export` | Export all configuration to a JSON file | `--file` (default apxy-config.json) |
| `apxy config import` | Import configuration from a JSON file | `--file` |
| `apxy config telemetry` | View or change telemetry consent |  |
| `apxy license activate` | Activate a license key on this machine | `--key` |
| `apxy license deactivate` | Deactivate the license on this machine |  |
| `apxy license status` | Show the current license status |  |
| `apxy upgrade` | Upgrade apxy to the latest version |  |
| `apxy audit clear` | Delete all audit log entries | `--dry-run` |
| `apxy audit export` | Export audit log entries as JSONL |  |
| `apxy audit list` | List audit log entries | `--category`, `--format` (default table), `--limit` (default 50), `--source` |
| `apxy audit stats` | Show audit log statistics |  |

