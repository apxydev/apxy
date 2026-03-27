# APXY CLI Command Reference

Complete flag reference for all 99 commands across 15 groups.

Global flags available on every command: `--config`, `--error-format` (text|json), `--help-format` (default|agent), `--verbose`.

---

## 1. Proxy (5 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy proxy start` | Start proxy server | `--port` (8080), `--ssl-domains`, `--mitm-all`, `--bypass-domains`, `--no-system-proxy`, `--upstream-proxy`, `--project-dir`, `--auto-validate`, `--max-body` (1048576), `--web-port`, `--control-port`, `--no-mdns`, `--cert-dir`, `--network-service` |
| `apxy proxy stop` | Stop running proxy | |
| `apxy proxy status` | Show proxy status | `--port` (8080), `--format` (json\|toon) |
| `apxy proxy env` | Print proxy env vars for shell | `--port` (8080), `--lang` (all\|go\|node\|python\|ruby\|curl), `--open`, `--script`, `--bypass-domains`, `--no-cert`, `--cert-dir` |
| `apxy proxy browser` | Launch browser with proxy pre-configured | `--browser` (chrome\|firefox), `--port` (8080), `--cert-dir` |

---

## 2. Rules — Mock (6 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules mock add` | Create mock response rule | `--name`, `--url`, `--match` (exact\|wildcard\|regex), `--method`, `--status` (200), `--body`, `--delay` (ms), `--priority`, `--control-url` |
| `apxy rules mock list` | List mock rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy rules mock enable` | Enable a mock rule | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules mock disable` | Disable a mock rule | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules mock remove` | Remove a mock rule | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules mock clear` | Delete all mock rules | `--dry-run`, `--control-url` |

---

## 3. Rules — Redirect (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules redirect set` | Add URL rewrite rule | `--name`, `--from` (source pattern), `--to` (destination), `--match` (exact\|wildcard\|regex), `--control-url` |
| `apxy rules redirect list` | List redirect rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy rules redirect remove` | Remove redirect rule | `--id` or `--all`, `--dry-run`, `--control-url` |

---

## 4. Rules — Interceptor (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules interceptor set` | Add dynamic interceptor | `--name`, `--match` (DSL), `--action` (mock\|modify\|observe), `--description`, `--add-request-headers` (k=v), `--set-request-headers` (k=v), `--set-response-headers` (k=v), `--remove-headers`, `--set-response-status`, `--set-response-body`, `--delay-ms`, `--control-url` |
| `apxy rules interceptor list` | List interceptors | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy rules interceptor remove` | Remove interceptor | `--id` or `--all`, `--dry-run`, `--control-url` |

---

## 5. Rules — Breakpoint (7 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules breakpoint add` | Add breakpoint rule | `--name` (req), `--match` (DSL, req), `--phase` (request\|response\|both), `--timeout` (30000ms), `--control-url` |
| `apxy rules breakpoint list` | List breakpoint rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy rules breakpoint enable` | Enable breakpoint | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules breakpoint disable` | Disable breakpoint | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules breakpoint remove` | Remove breakpoint | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules breakpoint pending` | List paused requests | `--quiet`, `--control-url` |
| `apxy rules breakpoint resolve` | Resume paused request | `--id` (req), `--status`, `--headers` (JSON), `--body`, `--drop`, `--dry-run`, `--control-url` |

---

## 6. Rules — Script (5 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules script add` | Add JS proxy script | `--name` (req), `--file` or `--code` (one req), `--hook` (onRequest\|onResponse), `--match` (DSL, default: *), `--control-url` |
| `apxy rules script list` | List scripts | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy rules script enable` | Enable script | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules script disable` | Disable script | `--id` or `--all`, `--dry-run`, `--control-url` |
| `apxy rules script remove` | Remove script | `--id` or `--all`, `--dry-run`, `--control-url` |

---

## 7. Rules — Network (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules network set` | Simulate network conditions | `--latency` (ms), `--bandwidth` (kbps), `--packet-loss` (0-100%), `--control-url` |
| `apxy rules network clear` | Clear simulated conditions | `--dry-run`, `--control-url` |

---

## 8. Rules — Caching (2 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy rules caching disable-cache` | Strip cache headers from proxied requests | `--host` (empty = all hosts), `--control-url` |
| `apxy rules caching enable-cache` | Restore normal upstream caching | `--control-url` |

---

## 9. Traffic — Filter (3 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic filter set` | Add block/allow filter rule | `--type` (block\|allow), `--target` (domain pattern), `--control-url` |
| `apxy traffic filter list` | List filter rules | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy traffic filter remove` | Remove filter rule | `--id` or `--all`, `--dry-run`, `--control-url` |

---

## 10. Traffic — Logs (14 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic logs list` | List captured traffic records | `--limit` (50), `--offset`, `--format` (json\|markdown\|toon), `--quiet` |
| `apxy traffic logs show` | Show one record in detail | `--id` (req), `--format` (json\|markdown\|toon) |
| `apxy traffic logs search` | Search by URL/host/method | `--query`, `--limit` (20), `--format` (json\|markdown\|toon), `--quiet` |
| `apxy traffic logs search-bodies` | Full-text body search | `--pattern`, `--scope` (request\|response\|both), `--limit` (20), `--format` (json\|markdown\|toon) |
| `apxy traffic logs graphql` | Search GraphQL operations | `--operation-name`, `--operation-type` (query\|mutation\|subscription), `--limit` (20), `--format` (json\|markdown\|toon) |
| `apxy traffic logs jsonpath` | Extract JSON via gjson path | `--id`, `--path` (gjson expression), `--scope` (request\|response) |
| `apxy traffic logs diff` | Compare two traffic records | `--id-a`, `--id-b`, `--scope` (request\|response\|both) |
| `apxy traffic logs label` | Label a traffic record | `--id` (req), `--color` (red\|green\|blue\|yellow\|purple), `--comment` |
| `apxy traffic logs replay` | Replay captured request | `--id`, `--port` (8080) |
| `apxy traffic logs export-curl` | Export as client snippet | `--id`, `--format` (curl\|fetch\|httpie\|python) |
| `apxy traffic logs export-har` | Export traffic as HAR 1.2 | `--file`, `--limit` (10000) |
| `apxy traffic logs import-har` | Import from HAR file | `--file` (req) |
| `apxy traffic logs stats` | Show traffic statistics | `--format` (json\|toon) |
| `apxy traffic logs clear` | Delete all traffic records | `--dry-run` |

---

## 11. Traffic — Recording, Devices, SQL (4 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy traffic recording start` | Start traffic capture | `--control-url` |
| `apxy traffic recording stop` | Stop traffic capture | `--control-url` |
| `apxy traffic devices list` | List connected devices | `--format` (json\|markdown\|toon), `--mobile`, `--quiet`, `--web-url` |
| `apxy traffic sql query "<SQL>"` | Run read-only SQL query | Tables: `traffic_logs`, `mock_rules` |

---

## 12. Schema (6 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy schema import` | Import OpenAPI spec | `--name`, `--file` or `--url` (one req) |
| `apxy schema list` | List imported schemas | `--format` (json\|toon), `--quiet` |
| `apxy schema show` | Show schema details | `--id` (req) |
| `apxy schema validate` | Validate record against schema | `--record-id` (req), `--schema-id` (req) |
| `apxy schema validate-recent` | Validate recent traffic | `--limit` (20) |
| `apxy schema delete` | Delete imported schema | `--id` (req), `--dry-run` |

---

## 13. Setup (15 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy setup init` | Init project workspace | Creates `.apxy/` directory |
| `apxy setup certs generate` | Generate root CA certificate | `--cert-dir` |
| `apxy setup certs info` | Show CA certificate details | `--cert-dir` |
| `apxy setup certs trust` | Trust CA in system keychain | `--cert-dir` |
| `apxy setup certs custom add` | Add custom CA for domain | `--domain` (req), `--cert` (req), `--key` (req), `--label`, `--no-trust`, `--cert-dir`, `--control-url` |
| `apxy setup certs custom list` | List custom CAs | `--format` (json\|toon), `--quiet`, `--cert-dir`, `--control-url` |
| `apxy setup certs custom info` | Show custom CA details | `--domain` (req), `--cert-dir`, `--control-url` |
| `apxy setup certs custom remove` | Remove custom CA | `--domain` or `--all`, `--dry-run`, `--cert-dir`, `--control-url` |
| `apxy setup certs custom trust` | Trust custom CA in keychain | `--domain` (req), `--cert-dir`, `--control-url` |
| `apxy setup ssl enable` | Enable HTTPS interception | `--domain` (req), `--control-url` |
| `apxy setup ssl disable` | Disable HTTPS interception | `--domain` or `--all`, `--dry-run`, `--control-url` |
| `apxy setup ssl list` | List SSL-enabled domains | `--format` (json\|toon), `--quiet`, `--control-url` |
| `apxy setup mobile setup` | Mobile device setup guide | `--platform` (ios\|android), `--port`, `--qr` |
| `apxy setup settings export` | Export settings to JSON | `--file`, `--control-url` |
| `apxy setup settings import` | Import settings from JSON | `--file` (req), `--dry-run`, `--control-url` |

---

## 14. Tools (9 commands)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy tools request compose` | Send one-off HTTP request | `--method` (GET), `--url` (req), `--body`, `--headers` (JSON) |
| `apxy tools request batch` | Batch requests from file | `--file` (req), `--compare-history`, `--time-range` (60), `--timeout` (10000ms), `--format` (markdown) |
| `apxy tools request diagnose` | Diagnose from traffic history | `--file` (req), `--time-range` (60), `--match-mode` (exact\|contains\|prefix), `--format` (markdown) |
| `apxy tools protobuf add-schema` | Register proto schema | `--name`, `--file` or `--content` |
| `apxy tools protobuf list-schemas` | List proto schemas | |
| `apxy tools protobuf decode` | Decode proto body | `--id`, `--scope` (request\|response) |
| `apxy tools protobuf remove-schema` | Remove proto schema | `--id` |
| `apxy tools db info` | Show database info | |
| `apxy tools db clean` | Clean database tables | `--traffic`, `--rules`, `--all` |

---

## 15. Config (2) + License (3)

| Command | Description | Key Flags |
|---------|-------------|-----------|
| `apxy config export` | Export config to JSON | `--file` (apxy-config.json) |
| `apxy config import` | Import config from JSON | `--file` (req) |
| `apxy license activate` | Activate license key | `--key` (req, format: APXY-XXXX-XXXX-XXXX) |
| `apxy license deactivate` | Deactivate license | |
| `apxy license status` | Show license status | |

---

## SQL Schema Reference

The `apxy traffic sql query` command supports read-only SELECT queries against these tables:

**traffic_logs**: `id`, `timestamp`, `method`, `url`, `host`, `path`, `status_code`, `duration_ms`, `tls`, `mocked`, request/response headers and bodies.

**mock_rules**: `id`, `name`, `priority`, `active`, `url_pattern`, `match_type`, `method`, and rule configuration fields.
