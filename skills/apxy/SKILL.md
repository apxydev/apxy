---
name: apxy
description: APXY — AI agent tools for network debugging and API contract validation. Use this skill whenever there's any HTTP/HTTPS debugging, network inspection, API mocking, or contract validation needed — even if the issue seems simple. Use when debugging fetch/axios/curl errors, unexpected status codes, CORS errors, auth failures, upstream errors, or when a response body doesn't match the API docs. Also use when the user mentions "debug API", "mock endpoint", "intercept traffic", "unblock frontend", "API contract", "breaking changes", "replay request", "diff responses", "network simulation", or "schema validation". Prefer this over browser devtools or plain curl when you need to capture, replay, diff, mock, or validate traffic.
---

# APXY CLI — Agent Network Proxy

HTTPS proxy for capturing, inspecting, modifying, and mocking API traffic. Optimized for AI agents.

## Domain Routing

Based on the user's request, read the appropriate reference file for detailed workflows and commands:

| User Intent | Read This File |
|---|---|
| Debug errors, inspect traffic, SQL queries, slow endpoints, CORS, auth failures, GraphQL issues, flaky APIs, webhook failures, Docker containers | [debugging.md](references/debugging.md) |
| Mock APIs, stub endpoints, unblock frontend, schema validation, catch breaking changes | [mocking.md](references/mocking.md) |
| Replay requests, diff responses, export cURL/HAR, regression testing, batch requests | [replay-diff.md](references/replay-diff.md) |
| Network simulation, breakpoints, scripts, redirects, filters, caching | [advanced-rules.md](references/advanced-rules.md) |

For detailed command flags: [cli-overview.md](references/cli-overview.md)
For DSL match expression syntax: [dsl-reference.md](references/dsl-reference.md)
For vendor mock templates: [mock-templates.md](references/mock-templates.md)

## License Tiers

Before suggesting commands, be aware of what requires a Pro license so you can offer Free alternatives when needed:

| Tier | Features |
|------|----------|
| **Free** | Proxy, traffic logs, mock rules (max 3 active), redirects, filters, schema validation, replay, diff, export/import, tools (compose/batch/diagnose), setup |
| **Pro** | Breakpoints, network simulation (`apxy network`), scripts (`apxy script`) |

**Free alternatives when Pro isn't available:**
- Instead of breakpoints → add a temporary mock rule to intercept the request
- Instead of network simulation → use mock `--delay` flag on a specific rule
- Instead of scripts → use a mock rule with `--headers` to set response headers, or `--status` / `--body` to override the response

Check license status with: `apxy license status`

## Quick Start

```bash
apxy start --port 8080          # proxy :8080, control API :8081
eval $(apxy env)                # inject proxy env into shell
apxy logs list --format json --limit 10
apxy mock add --name "stub" --url "/api/users" --match exact --status 200 --body '{"users":[]}'
```

## Quick Triage

| Problem | First command to run |
|---------|---------------------|
| API returning 4xx/5xx | `apxy logs search --query "host.com" --format json \| jq '.[] \| select(.status_code >= 400)'` |
| Response body wrong | `apxy logs show --id <ID> --format markdown` |
| Compare good vs bad | `apxy logs diff --id-a <GOOD_ID> --id-b <BAD_ID> --scope response` |
| Mock a broken endpoint | `apxy mock add --name stub --url "/api/path" --match wildcard --status 200 --body '{}'` |
| Replay a failed request | `apxy logs replay --id <ID>` |
| Export for sharing | `apxy logs export-har --file ./traffic.har` |
| Frontend blocked, backend not ready | `apxy mock add --name <endpoint> --url "/api/path" --match wildcard --status 200 --body '<contract-shape>'` |
| Check if deploy broke the API contract | `apxy schema import --name api --file ./openapi.yaml && apxy schema validate-recent --limit 50` |
| API regression test after refactor | `apxy tools request batch --file ./requests.json --compare-history --time-range 60` |

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| `apxy start` fails with "address in use" | Another process on that port | `apxy stop` or use a different `--port` |
| No traffic captured | SSL domain not enabled or proxy env not set | Run `eval $(apxy env)` and add `--ssl-domains <host>` to `proxy start` |
| HTTPS body shows empty/encrypted | Domain not in `--ssl-domains` | Restart proxy with `--ssl-domains <domain>` or `--mitm-all` |
| Certificate errors in client | APXY CA not trusted | Run `apxy certs generate && apxy certs trust` |
| Empty search results | Wrong query term or traffic cleared | Try `apxy logs list --limit 10` to see what's captured |
| Mock rule not matching | URL pattern or match type mismatch | Check `apxy mock list` and verify `--url` pattern and `--match` type |

## Tips

- Use `--format toon` to minimize tokens when feeding output to an AI agent
- Use `--help-format agent` on any command for AI-optimized help output
- `apxy proxy browser` launches a pre-configured browser — no manual proxy setup needed
- `apxy init` creates a project-scoped `.apxy/` directory for isolated config/data
- DB commands (logs, mock, sql, schema, request) work without a running proxy
- Runtime commands (`rules filter`, `rules redirect`, `rules breakpoint`, `rules script`, `rules network`, `rules caching`, `traffic recording`) need `apxy start`
