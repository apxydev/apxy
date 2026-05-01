# APXY CLI Command Reference

Complete flag reference for 93 core commands across 15 groups.

Global flags available on every command: `--config`, `--error-format` (text\|json), `--help-format` (default\|agent), `--verbose`.

---

## 1. Proxy (5 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy start` | Start proxy server | `--port` (8080), `--ssl-domains`, `--mitm-all`, `--bypass-domains`, `--no-system-proxy`, `--upstream-proxy`, `--project-dir`, `--auto-validate`, `--max-body` (1048576), `--web-port`, `--control-port`, `--no-mdns`, `--cert-dir`, `--network-service` |
| `apxy stop` | Stop running proxy | |
| `apxy status` | Show proxy status | `--port` (8080), `--format` (json\|toon) |
| `apxy env` | Print proxy env vars for shell | `--port` (8080), `--lang` (all\|go\|node\|python\|ruby\|curl), `--open`, `--script`, `--bypass-domains`, `--no-cert`, `--cert-dir` |
| `apxy proxy browser` | Launch browser with proxy pre-configured | `--browser` (chrome\|firefox), `--port` (8080), `--cert-dir` |

---

## 2. Rules — Mock (7 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy mock add` | Create mock response rule | `--name`, `--url`, `--match` (exact\|wildcard\|regex), `--method`, `--header-conditions`, `--headers`, `--status` (200), `--body`, `--delay` (ms), `--priority`, `--control-url` |
| `apxy mock list` | List mock rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy mock enable` | Enable a mock rule | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy mock disable` | Disable a mock rule | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy mock remove` | Remove a mock rule | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy mock clear` | Delete all mock rules | `--dry-run`, `--control-url` |
| `apxy mock import` | Import mock rules from JSON template | `--file`, `--control-url` |

---

## 3. Rules — Redirect (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rewrite set` | Add URL rewrite rule | `--name`, `--from` (source pattern), `--to` (destination), `--match` (exact\|wildcard\|regex), `--control-url` |
| `apxy rewrite list` | List redirect rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy rewrite remove` | Remove redirect rule | `--id` or `--all`, `--dry-run`, `--control-url` |

---

## 4. Rules — Breakpoint (7 commands) *(Pro)*

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy breakpoint add` | Add breakpoint rule | `--name` (req), `--match` (DSL, req), `--phase` (request\|response\|both), `--timeout` (30000ms), `--control-url` |
| `apxy breakpoint list` | List breakpoint rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy breakpoint enable` | Enable breakpoint | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy breakpoint disable` | Disable breakpoint | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy breakpoint remove` | Remove breakpoint | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy breakpoint pending` | List paused requests | `--quiet`, `--control-url` |
| `apxy breakpoint resolve` | Resume paused request | `--id` (req), `--status`, `--headers` (JSON), `--body`, `--drop`, `--dry-run`, `--control-url` |

---

## 5. Rules — Script (5 commands) *(Pro)*

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy script add` | Add JS proxy script | `--name` (req), `--file` or `--code` (one req), `--hook` (onRequest\|onResponse), `--match` (DSL, default: *), `--control-url` |
| `apxy script list` | List scripts | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy script enable` | Enable script | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy script disable` | Disable script | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy script remove` | Remove script | `--id` or `--all`, `--dry-run`, `--control-url` |

---

## 6. Rules — Network (2 commands) *(Pro)*

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy network set` | Simulate network conditions | `--latency` (ms), `--bandwidth` (kbps), `--packet-loss` (0-100%), `--control-url` |
| `apxy network clear` | Clear simulated conditions | `--dry-run`, `--control-url` |

---

## 7. Rules — Caching (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy caching disable-cache` | Strip cache headers from proxied requests | `--host` (empty = all hosts), `--control-url` |
| `apxy caching enable-cache` | Restore normal upstream caching | `--control-url` |

---

## 8. Rules — Filter (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy filter set` | Add block/allow filter rule | `--type` (block\|allow), `--target` (domain pattern), `--control-url` |
| `apxy filter list` | List filter rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy filter remove` | Remove filter rule | `--id` or `--all`, `--dry-run`, `--control-url` |

---

## 9. Traffic — Logs (17 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy logs list` | List captured traffic records | `--limit` (50), `--offset`, `--format` (json\|markdown\|toon), `--quiet` |
| `apxy logs show` | Show one record in detail | `--id` (req), `--format` (json\|markdown\|toon) |
| `apxy logs search` | Search by URL/host/method | `--query`, `--limit` (20), `--format` (json\|markdown\|toon), `--quiet` |
| `apxy logs search-bodies` | Full-text body search | `--pattern`, `--scope` (request\|response\|both), `--limit` (20), `--format` (json\|markdown\|toon) |
| `apxy logs graphql` | Search GraphQL operations | `--operation-name`, `--operation-type` (query\|mutation\|subscription), `--limit` (20), `--format` (json\|markdown\|toon) |
| `apxy logs jsonpath` | Extract JSON via gjson path | `--id`, `--path` (gjson expression), `--scope` (request\|response) |
| `apxy logs diff` | Compare two traffic records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy logs label` | Label a traffic record | `--id` (req), `--color` (red\|green\|blue\|yellow\|purple), `--comment` |
| `apxy logs replay` | Replay captured request | `--id`, `--port` (8080) |
| `apxy logs export-curl` | Export as client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python) |
| `apxy logs export-har` | Export traffic as HAR 1.2 | `--file`, `--limit` (10000) |
| `apxy logs import-har` | Import from HAR file | `--file` (req) |
| `apxy logs tail` | Live-tail traffic from a running instance | `--format` (text\|json), `--host`, `--port`, `--sse` |
| `apxy logs sse-events` | List parsed SSE events for a traffic record | `--id`, `--limit`, `--format` (text\|json) |
| `apxy logs sse-merge` | Merge AI streaming SSE events into one response | `--id`, `--format` (text\|json) |
| `apxy logs stats` | Show traffic statistics | `--format` (json\|toon) |
| `apxy logs clear` | Delete all traffic records | `--dry-run` |

---

## 10. Traffic — Recording, Devices (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy recording start` | Start traffic capture | `--control-url` |
| `apxy recording stop` | Stop traffic capture | `--control-url` |
| `apxy traffic devices list` | List connected devices | `--format` (json\|markdown\|toon), `--mobile`, `--quiet`, `--web-url` |
---

## 11. Schema (6 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy schema import` | Import OpenAPI spec | `--name`, `--file` or `--url` (one req) |
| `apxy schema list` | List imported schemas | `--format` (json\|toon), `--quiet` |
| `apxy schema show` | Show schema details | `--id` (req) |
| `apxy schema validate` | Validate record against schema | `--record-id` (req), `--schema-id` (req) |
| `apxy schema validate-recent` | Validate recent traffic | `--limit` (20) |
| `apxy schema delete` | Delete imported schema | `--id` (req), `--dry-run` |

---

## 12. Setup (15 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy init` | Init project workspace | Creates `.apxy/` directory |
| `apxy certs generate` | Generate root CA certificate | `--cert-dir` |
| `apxy certs info` | Show CA certificate details | `--cert-dir` |
| `apxy certs trust` | Trust CA in system keychain | `--cert-dir` |
| `apxy certs custom add` | Add custom CA for domain | `--domain` (req), `--cert` (req), `--key` (req), `--label`, `--no-trust`, `--cert-dir`, `--control-url` |
| `apxy certs custom list` | List custom CAs | `--format` (json\|toon), `--quiet`, `--cert-dir`, `--control-url` |
| `apxy certs custom info` | Show custom CA details | `--domain` (req), `--cert-dir`, `--control-url` |
| `apxy certs custom remove` | Remove custom CA | `--domain` or `--all`, `--dry-run`, `--cert-dir`, `--control-url` |
| `apxy certs custom trust` | Trust custom CA in keychain | `--domain` (req), `--cert-dir`, `--control-url` |
| `apxy ssl enable` | Enable HTTPS interception | `--domain` (req), `--control-url` |
| `apxy ssl disable` | Disable HTTPS interception | `--domain` or `--all`, `--dry-run`, `--control-url` |
| `apxy ssl list` | List SSL-enabled domains | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy setup mobile setup` | Mobile device setup guide | `--platform` (ios\|android), `--port`, `--qr` |
| `apxy setup settings export` | Export settings to JSON | `--file`, `--control-url` |
| `apxy setup settings import` | Import settings from JSON | `--file` (req), `--dry-run`, `--control-url` |

---

## 13. Tools (9 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy tools request compose` | Send one-off HTTP request | `--method` (GET), `--url` (req), `--body`, `--headers` (JSON) |
| `apxy tools request batch` | Batch requests from file | `--file` (req), `--compare-history`, `--time-range` (60), `--timeout` (10000ms), `--format` (json\|markdown\|toon) |
| `apxy tools request diagnose` | Diagnose from traffic history | `--file` (req), `--time-range` (60), `--match-mode` (exact\|contains\|prefix), `--format` (json\|markdown\|toon) |
| `apxy tools protobuf add-schema` | Register proto schema | `--name`, `--file` or `--content` |
| `apxy tools protobuf list-schemas` | List proto schemas | |
| `apxy tools protobuf decode` | Decode proto body | `--id`, `--scope` (request\|response) |
| `apxy tools protobuf remove-schema` | Remove proto schema | `--id` |
| `apxy tools db info` | Show database info | |
| `apxy tools db clean` | Clean database tables | `--traffic`, `--rules`, `--all` |

---

## 14. Config (2) + License (3)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy config export` | Export config to JSON | `--file` (apxy-config.json) |
| `apxy config import` | Import config from JSON | `--file` (req) |
| `apxy license activate` | Activate license key | `--key` (req, format: APXY-XXXX-XXXX-XXXX) |
| `apxy license deactivate` | Deactivate license | |
| `apxy license status` | Show license status | |

---

