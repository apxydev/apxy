# MCP tools

The APXY MCP server (`apxy mcp`, set up with `apxy setup mcp`) has 38 tools. They share traffic, rules, and marks with the CLI. `*` marks a required argument. Returned traffic has secrets masked.

## Prove a change works

| Tool | Arguments | Use |
|------|-----------|-----|
| `set_mark` | `name` | Call it before triggering the code, so earlier attempts never match |
| `wait_for_request` | `match`*, `expect`, `since`, `timeout_seconds` | Wait for a request and check it, streams included. Read `outcome`, `expectations`, and `stream`. |
| `replay_request` | `id`* | Send a captured request again. Needs a running proxy. |
| `diff_traffic_logs` | `id_a`*, `id_b`*, `scope` | Compare the record from before the fix with the one after |
| `validate_recent_traffic` | `limit` | Check recent traffic against imported OpenAPI schemas. It is an error when none is imported. |

## Read traffic

| Tool | Arguments | Use |
|------|-----------|-----|
| `list_traffic_logs` | `limit`, `offset`, `host_filter`, `method_filter`, `status_filter`, `session_id`, `from_time`, `to_time`, `include_bodies` | List records |
| `search_traffic_logs` | `query`*, `limit` | Free-text search |
| `get_traffic_log` | `id`*, `include_bodies` | One record in detail |
| `get_ws_frames` | `record_id`*, `limit` | WebSocket frames of a record |
| `export_traffic_log` | `id`*, `format` | Snippet as curl, fetch, httpie, or python |
| `get_ai_usage` | `since`, `until` | LLM tokens and estimated cost |
| `egress_summary` | `since`, `allow` | Hosts contacted, checked against an allowlist |

## Proxy

| Tool | Arguments | Use |
|------|-----------|-----|
| `get_proxy_status` | | Is it running, and what it holds |
| `start_proxy`, `stop_proxy` | | `start_proxy` uses the default CLI behavior, which can change system settings. Prefer `apxy run` for code you trigger yourself. |
| `set_recording` | `enabled`* | Pause or resume capture |
| `list_ssl_domains`, `enable_ssl_domain`, `disable_ssl_domain` | `domain`* (enable, disable) | Choose which hosts are decrypted |

## Change traffic

| Tool | Arguments | Use |
|------|-----------|-----|
| `create_mock_rule` | `name`*, `url_pattern`*, `match_type`, `method`, `response_status`, `response_headers`, `response_body`, `delay_ms`, `priority`, `header_conditions`, `file_path`, `dir_path` | Mock a response |
| `create_redirect_rule` | `from_url`*, `to_url`*, `name`, `match_type` | Rewrite the URL |
| `create_filter_rule` | `type`*, `pattern`* | Block or allow hosts |
| `set_dns_override` | `host`*, `ip`* | Connect to another IP for a hostname |
| `set_network_condition`, `clear_network_condition` | `latency_ms`, `bandwidth_kbps`, `packet_loss_pct` | Simulate a slow network |
| `list_mock_rules`, `list_redirect_rules`, `list_filter_rules`, `list_dns_overrides` | | List rules |
| `remove_mock_rule`, `remove_redirect_rule`, `remove_filter_rule` | `id`* | Remove a rule |
| `remove_dns_override` | `host`* | Remove an override |

## Breakpoints

| Tool | Arguments | Use |
|------|-----------|-----|
| `create_breakpoint_rule` | `name`*, `match_expr`*, `phase`, `timeout_ms` | Pause matching requests or responses |
| `list_pending_breakpoints` | | What is paused now |
| `resolve_breakpoint` | `id`*, `status`, `headers`, `body`, `drop` | Continue, change, or drop it. An unresolved one continues after its timeout. |
| `list_breakpoint_rules`, `remove_breakpoint_rule` | `id`* (remove) | Manage rules |