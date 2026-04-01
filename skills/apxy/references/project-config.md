# Project Configuration — `.apxy/config.json`

APXY supports team-shared project configurations committed to Git. When
`apxy proxy start` runs inside a project directory, it auto-discovers
`.apxy/config.json` and loads all rules and settings into the global database.

## Quick Commands

| Task | Command |
|------|---------|
| Initialize a project | `apxy init` |
| Validate config | `apxy config validate` |
| Validate (machine-readable) | `apxy config validate --format json` |
| Start proxy (loads config) | `apxy proxy start` |
| Start + trust scripts (CI) | `apxy proxy start --trust` |
| Start without hot-reload | `apxy proxy start --no-watch` |
| Export DB state to file | `apxy config export --project` |

## Directory Layout

```
my-project/
  .apxy/
    config.json          # team shared — commit to Git
    config.local.json    # personal overrides — DO NOT commit
    .gitignore           # auto-created by `apxy init`
  src/
  ...
```

## Config Precedence (highest → lowest)

1. CLI flags (`--port 9090`, `--mitm-all`, etc.)
2. `.apxy/config.local.json` (personal overrides, git-ignored)
3. `.apxy/config.json` (team shared)
4. `~/.apxy/config.json` (user global defaults)
5. Built-in defaults

## Full Schema Reference

### Top-Level Structure

```json
{
  "version": 1,
  "proxy_defaults": { ... },
  "ssl_domains": ["api.example.com"],
  "bypass_domains": ["*.internal"],
  "mock_rules": [ ... ],
  "breakpoint_rules": [ ... ],
  "filter_rules": [ ... ],
  "redirect_rules": [ ... ],
  "network_condition": { ... },
  "no_caching": { ... },
  "custom_cas": [ ... ]
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `version` | `int` | Yes | Must be `1` |
| `proxy_defaults` | `ProxyDefaults` | No | Proxy startup options |
| `ssl_domains` | `string[]` | No | Domains to SSL-intercept |
| `bypass_domains` | `string[]` | No | Domains to tunnel (no MITM) |
| `mock_rules` | `MockRule[]` | No | Mock/stub rules |
| `breakpoint_rules` | `BreakpointRule[]` | No | Pause-and-edit rules (Pro) |
| `filter_rules` | `FilterRule[]` | No | Traffic drop/log filters |
| `redirect_rules` | `RedirectRule[]` | No | URL redirect rules |
| `network_condition` | `NetworkConditionConfig` | No | Latency/packet-loss simulation (Pro) |
| `no_caching` | `NoCachingConfig` | No | Strip cache headers |
| `custom_cas` | `CustomCA[]` | No | Inject custom CA certs |

---

### `proxy_defaults`

```json
{
  "proxy_defaults": {
    "port": 8080,
    "mitm_all": false,
    "max_body_bytes": 1048576,
    "upstream_proxy": "http://proxy.corp.com:3128"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `port` | `int` | Proxy listen port (1–65535) |
| `mitm_all` | `bool` | MITM all HTTPS traffic |
| `max_body_bytes` | `int` | Max body capture size in bytes |
| `upstream_proxy` | `string` | Corporate/upstream proxy URL |

---

### `mock_rules`

```json
{
  "mock_rules": [
    {
      "id": "stub-users",
      "name": "Stub users list",
      "enabled": true,
      "url": "https://api.example.com/users",
      "match": "exact",
      "method": "GET",
      "status": 200,
      "body": "{\"users\":[]}",
      "headers": {"Content-Type": "application/json"},
      "delay_ms": 0,
      "priority": 0
    }
  ]
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `string` | Yes | Unique ID (no spaces, ASCII) |
| `name` | `string` | Yes | Human-readable name |
| `enabled` | `bool` | No | Active by default (`true`) |
| `url` | `string` | Yes | URL pattern to match |
| `match` | `string` | No | `exact` (default), `wildcard`, `regex` |
| `method` | `string` | No | HTTP method filter (empty = all) |
| `status` | `int` | No | Response status code (default: `200`) |
| `body` | `string` | No | Response body |
| `headers` | `object` | No | Response headers |
| `header_conditions` | `object` | No | Request header match conditions |
| `delay_ms` | `int` | No | Artificial response delay |
| `priority` | `int` | No | Rule priority (higher = checked first) |

---

### `breakpoint_rules` (Pro)

```json
{
  "breakpoint_rules": [
    {
      "id": "bp-checkout",
      "name": "Pause checkout",
      "enabled": true,
      "url": "https://api.example.com/checkout",
      "match": "exact",
      "method": "POST",
      "pause_request": true,
      "pause_response": false
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique ID |
| `name` | `string` | Human-readable name |
| `url` | `string` | URL pattern |
| `match` | `string` | `exact`, `wildcard`, `regex` |
| `pause_request` | `bool` | Pause before sending to server |
| `pause_response` | `bool` | Pause before returning to client |

---

### `filter_rules`

```json
{
  "filter_rules": [
    {
      "id": "drop-analytics",
      "name": "Drop analytics",
      "enabled": true,
      "url": "*.analytics.com/*",
      "match": "wildcard",
      "action": "drop"
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique ID |
| `url` | `string` | URL pattern |
| `match` | `string` | `exact`, `wildcard`, `regex` |
| `action` | `string` | `drop` or `log` |

---

### `redirect_rules`

```json
{
  "redirect_rules": [
    {
      "id": "redirect-staging",
      "name": "Production → staging",
      "enabled": true,
      "from_url": "https://api.example.com/*",
      "match": "wildcard",
      "to_url": "https://staging.example.com/$1"
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique ID |
| `from_url` | `string` | Source URL pattern |
| `match` | `string` | `exact`, `wildcard`, `regex` |
| `to_url` | `string` | Destination URL (can use `$1` for capture groups) |

---

### `network_condition` (Pro)

```json
{
  "network_condition": {
    "enabled": true,
    "latency_ms": 200,
    "download_kbps": 1000,
    "upload_kbps": 500,
    "packet_loss_pct": 1.0
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `enabled` | `bool` | Activate simulation |
| `latency_ms` | `int` | Added RTT in milliseconds |
| `download_kbps` | `int` | Download bandwidth limit |
| `upload_kbps` | `int` | Upload bandwidth limit |
| `packet_loss_pct` | `float` | Packet loss percentage (0–100) |

---

### `no_caching`

```json
{
  "no_caching": {
    "enabled": true,
    "url_pattern": "*.example.com/*",
    "match": "wildcard"
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `enabled` | `bool` | Activate cache stripping |
| `url_pattern` | `string` | URL pattern to apply to (empty = all) |
| `match` | `string` | `exact`, `wildcard`, `regex` |

---

### `custom_cas`

```json
{
  "custom_cas": [
    {
      "id": "corp-ca",
      "name": "Corporate CA",
      "pem": "-----BEGIN CERTIFICATE-----\n..."
    }
  ]
}
```

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Unique ID |
| `name` | `string` | Human-readable label |
| `pem` | `string` | PEM-encoded certificate content |

---

## Array Merge Semantics

- **Absent array** (key not in file): inherited from lower-priority config
- **Empty array `[]`**: explicitly clears inherited values
- **Non-empty array**: replaces inherited values entirely

```json
// config.json defines 2 mock rules
// config.local.json omits mock_rules → inherits both rules
// config.local.json sets mock_rules: [] → clears all mock rules
// config.local.json sets mock_rules: [{...}] → replaces with just that rule
```

---

## Trust Model (Scripts)

If any `mock_rule` or `breakpoint_rule` contains JavaScript in a `script` field,
APXY computes a SHA-256 hash of the config and checks `~/.apxy/trusted-projects.json`.

- **New or changed config**: prompts the user to trust it
- `--trust` flag: skips the prompt (for CI/automation)
- **Already trusted, unchanged**: loads silently

---

## Hot-Reload

Config file changes are detected automatically with a 500ms debounce.
Hot-reloadable: rules, SSL domains, bypass domains, network conditions.
Not hot-reloadable: `proxy_defaults.port`, `proxy_defaults.mitm_all` (require restart).

Disable with `apxy proxy start --no-watch`.

---

## Validation

```bash
apxy config validate                   # text output
apxy config validate --format json     # JSON output for CI / agent use
```

JSON output format:

```json
{
  "valid": false,
  "errors": [
    {"field": "mock_rules[0].id", "message": "id is required"}
  ]
}
```

---

## Generating a Config as an AI Agent

1. Start from the minimal template above
2. Add only the fields the user needs
3. Validate: `apxy config validate --format json`
4. Fix any reported errors and re-validate
5. Commit `config.json`; add `config.local.json` to `.gitignore`
