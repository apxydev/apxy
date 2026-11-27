# MCP tools

The APXY MCP server (`apxy mcp`, set up with `apxy setup mcp`) has 45 tools. They share traffic, rules, and marks with the CLI. The server's workspace is the directory it started in. A subagent in another worktree passes `workspace` (its worktree path, workspace ID, or name) to the mark, traffic, and rule tools; see [workspaces.md](workspaces.md). `*` marks a required argument. Returned traffic has secrets masked.

## Prove a change works

| Tool | Arguments | Use |
|------|-----------|-----|
| `set_mark` | `name`, `workspace` | Call it before triggering the code, so earlier attempts never match |
| `wait_for_request` | `match`*, `expect`, `since`, `timeout_seconds`, `workspace` | Wait for a request and check it, streams included. Read `outcome`, `expectations`, and `stream`. `mocked_by` and a `warning` mean a mock answered, not the origin. A `warning` also flags an untagged match while other workspaces are active. `proxy_running: false` means no proxy runs: run the code through `apxy run -- <command>`. `rules_errors` names a rules file that does not parse or validate. |
| `replay_request` | `id`* | Send a captured request again. Needs a running proxy. |
| `diff_traffic_logs` | `id_a`*, `id_b`*, `scope` | Compare the record from before the fix with the one after |
| `validate_recent_traffic` | `limit` | Check recent traffic against imported OpenAPI schemas. It is an error when none is imported. |

## Read traffic

| Tool | Arguments | Use |
|------|-----------|-----|
| `list_traffic_logs` | `limit`, `offset`, `host_filter`, `method_filter`, `status_filter`, `session_id`, `from_time`, `to_time`, `include_bodies`, `workspace` | List records. `"workspace": "all"` lists every workspace. |
| `search_traffic_logs` | `query`*, `limit`, `workspace` | Free-text search |
| `get_traffic_log` | `id`*, `include_bodies` | One record in detail |
| `get_ws_frames` | `record_id`*, `limit` | WebSocket frames of a record |
| `export_traffic_log` | `id`*, `format` | Snippet as curl, fetch, httpie, or python |
| `get_ai_usage` | `since`, `until` | LLM tokens and estimated cost |
| `egress_summary` | `since`, `allow` | Hosts contacted, checked against an allowlist |

## Proxy

| Tool | Arguments | Use |
|------|-----------|-----|
| `get_proxy_status` | | Is it running, and what it holds |
| `start_proxy`, `stop_proxy` | | `start_proxy` starts a proxy for this workspace on 127.0.0.1 that never touches the system proxy or trust store, or reports the one running and who started it, and says when its Free session ends. The proxy `start_proxy` starts stops after this MCP session ends, unless an `apxy run` or `apxy browser` still uses it. `stop_proxy` stops only a proxy this workspace started that no other workspace uses; when it refuses with `stop_refused`, leave the proxy running. Prefer `apxy run` for code you trigger yourself. |
| `set_recording` | `enabled`* | Pause or resume capture |
| `list_ssl_domains`, `enable_ssl_domain`, `disable_ssl_domain` | `domain`* (enable, disable) | Choose which hosts are decrypted |
| `set_workspace_label` | `label`*, `workspace` | Say what this workspace is doing (one line, at most 80 characters; empty clears it). The web UI shows it, else the git branch, else the name. `workspace` arguments never take a label. |

## Change traffic

Every rule tool takes `workspace` and `global`. A rule goes to the workspace's `.apxy/rules.json` and answers only its tagged traffic. `"global": true` writes `~/.apxy/rules.json` for untagged traffic: browsers on the system proxy, iOS simulators, and Android emulators set up with no workspace or no proxy running.

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
| `list_rules` | `workspace`, `global` | Every rule of every kind that applies to the workspace, its file, and whether the running proxy applies it. An invalid file shows its line or rule. |
| `apply_rules` | `workspace`, `global` | Validate the rules file and push it now, after editing it by hand or by git checkout. An invalid file is an error with its line or rule, and nothing is pushed. |
| `clear_rules` | `workspace`, `global` | Delete every rule in the workspace's file (or the global file) |

## Breakpoints

| Tool | Arguments | Use |
|------|-----------|-----|
| `create_breakpoint_rule` | `name`*, `match_expr`*, `phase`, `timeout_ms` | Pause matching requests or responses |
| `list_pending_breakpoints` | | What is paused now |
| `resolve_breakpoint` | `id`*, `status`, `headers`, `body`, `drop` | Continue, change, or drop it. An unresolved one continues after its timeout. |
| `list_breakpoint_rules`, `remove_breakpoint_rule` | `id`* (remove) | Manage rules |

## Simulators and emulators

| Tool | Arguments | Use |
|------|-----------|-----|
| `list_devices` | | Booted iOS simulators and running Android emulators |
| `setup_device` | `ios_simulator`, `android_emulator`, `system_store` | Install the APXY CA. Pass `booted` for the only one. iOS traffic is untagged, so mocks for it need `global`. For Android, also point the emulator's HTTP proxy at the proxy: with one running, at this workspace's port, which tags the traffic and is held for 8 hours (call again to hold it longer); with none, at the plain port, untagged (`untagged_because` says why; call again after `start_proxy`). |
| `teardown_device` | `android_emulator`* | Clear the proxy `setup_device` set on an Android emulator and release its workspace port |
