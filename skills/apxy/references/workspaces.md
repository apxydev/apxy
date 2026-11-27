# Workspaces: parallel agents on one proxy

Each git worktree is a workspace. Agents in parallel worktrees share one proxy, one web UI, and one traffic database (`~/.apxy/data/apxy.db`), but each one sees its own requests and gets answers from its own mocks. `apxy status` prints the workspace a command runs in, and every JSON envelope has a `workspace` field.

A command's workspace is `APXY_WORKSPACE` when it is set, else the git worktree of the current directory, else `CONDUCTOR_WORKSPACE_NAME`. A command outside any workspace reads every workspace's traffic and uses the global rules.

Name your workspace so people watching the web UI see what it does: `apxy workspace label "Fix checkout retries"` (MCP: `set_workspace_label`). The web UI shows the worktree's git branch without it.

| What | Scope |
|------|-------|
| Requests sent through `apxy run` | Tagged with the workspace ID, over HTTP, HTTPS, and plain HTTP inside a `CONNECT` tunnel (Node `fetch`). Java ignores the tag, so its requests are untagged. |
| `apxy wait`, `logs list`, `logs search`, `logs egress` | This workspace's requests and untagged requests |
| Marks | One set per workspace. Your `apxy mark` never moves another agent's `default` mark. |
| Mocks and rules | `<worktree>/.apxy/rules.json`. They answer this workspace's tagged requests first, then the global rules (`~/.apxy/rules.json`) apply. |
| `apxy browser` | A profile and a proxy port per workspace, so its requests are tagged |
| `apxy stop` | Stops only a proxy this workspace started |

## Prove a change from a worktree

Run the loop from inside your worktree:

```bash
cd /path/to/your/worktree
apxy mark
apxy run -- npm test -- checkout.spec.ts
apxy wait --match "POST /api/checkout" --expect "status == 200"
```

The same request from another worktree never matches. An untagged request can match. When it does while other workspaces are active, `data.warning` says so, because the request may come from another agent.

To read another agent's traffic, for example the requests its web app sent to your backend, pass its workspace ID or name: `apxy wait --from-workspace <id> ...`. `--all-workspaces` reads every workspace. `logs list`, `logs search`, and `logs egress` take the same two flags.

## MCP tools from a subagent

The MCP server's workspace is the directory it started in, usually the main checkout. A subagent in another worktree does one of these:

- Runs the CLI from inside its own worktree.
- Passes `workspace` (the absolute worktree path, the workspace ID, or its name) to `set_mark`, `wait_for_request`, `list_traffic_logs`, `search_traffic_logs`, and every rule tool. `"workspace": "all"` reads every workspace's traffic.

```json
{"match": "POST /api/checkout", "expect": ["status == 200"], "workspace": "/path/to/your/worktree"}
```

## Mocks and rules

- Make rules with the CLI or the MCP tools, not by writing `.apxy/rules.json` yourself. A rule command locks the file, writes it, and pushes it to the proxy.
- After a hand edit, or a `git checkout` that changes the file, run `apxy rules apply` (MCP: `apply_rules`). It checks the file and pushes it now. An invalid file exits non-zero with the line or rule to fix, and the proxy keeps the last valid rules. `apxy run` and `apxy mcp` also push a changed file within a second.
- Add `--global` (MCP: `"global": true`) for traffic that carries no workspace: browsers on the system proxy (Safari, Firefox), iOS simulators, Android emulators set up outside a workspace or before a proxy runs, webhooks, and Java clients. Global rules also apply to every workspace after its own rules.
- `apxy rules list` (MCP: `list_rules`) shows every rule that applies to this workspace, its file, and whether the running proxy applies it. `apxy rules clear` deletes this workspace's rules, and `apxy rules clear --global` deletes the global ones.
- `apxy init` adds `.apxy/rules.json` to `.gitignore` unless you pass `--commit-rules`. Without that line, the file shows in `git status`.

```bash
apxy mock add --name checkout-down --url /api/checkout --method POST --status 503
apxy mock add --global --name sim-config --url https://api.myapp.com/config --status 200 --body '{"flag":true}'
apxy rules list
```

## A pass on a mock

When a mock answered the matched request, `apxy wait` and `wait_for_request` return `mocked_by` (`id`, `name`, `source`, the rules file) and a `warning` that starts with `passed on a mocked response`. That pass proves your code handled the mock, not that the real API works. If the check must reach the real API, remove the mock (`apxy mock remove --id <id>`, plus `--global` for a global rule) and run the loop again. Otherwise say in your report that a mock answered.

## The shared proxy

- `apxy run` starts a temporary proxy when none runs, or uses the running one. The temporary proxy stops a few seconds after the last `apxy run` exits.
- The MCP `start_proxy` tool starts a proxy for this workspace on 127.0.0.1. It stops after the MCP session ends, unless an `apxy run` or `apxy browser` still uses it.
- `apxy stop` and `stop_proxy` stop only a proxy this workspace started that no other workspace still uses. Otherwise they fail with `stop_refused` and name who started it. Leave that proxy running. Never pass `apxy stop --force`: it is for people, and it cuts off other agents mid-task.
- `apxy status` shows `owner` (`user`, or `start:`, `run:`, `browser:`, `mcp:` and a workspace ID) and `other_active_workspaces`.
- A new proxy keeps earlier traffic for 24 hours, up to the newest 50000 records (`apxy start --log-retention`, `--log-max-records`).

## Web apps in a browser

```bash
apxy browser http://localhost:3000
```

For Chrome, Edge, Brave, and Arc, `apxy browser` starts a temporary proxy when none runs and holds it while the browser runs. Each workspace gets its own profile (`~/.apxy/<browser>-profile-<workspace-id>`) and its own proxy port, which tags every request, so this workspace's mocks answer the browser. The port is the same for a workspace every time, picked by its ID from `apxy start --workspace-ports` (default 20000-29999), and a restarted proxy reopens it, so an open browser keeps working. Safari and Firefox use the system proxy: their requests are untagged, so their mocks need `--global`.

## Simulators and emulators

```bash
apxy device list
apxy device setup --ios-simulator booted
apxy device setup --android-emulator booted
apxy device teardown --android-emulator booted
```

- iOS: `setup` installs the APXY CA into the simulator with `xcrun simctl`. The simulator's traffic goes through the macOS system proxy, which a person turns on by running `apxy start` in a terminal. Ask the user to do that.
- Android: `setup` copies the CA to the emulator and points its HTTP proxy at the host (`10.0.2.2`). In a workspace with a proxy running, that is the workspace's own port, which tags the traffic, so this workspace's mocks answer it. Setup holds the port for 8 hours; run it again to hold it longer. `teardown` clears the proxy and releases the port. `--system-store` installs the CA into the system store of an emulator started with `-writable-system`.
- An Android emulator set up outside a workspace or before a proxy runs gets the plain proxy port, and the output's `untagged_because` says why. Run setup again once a proxy runs to tag it.
- iOS simulator traffic is untagged, so its mocks need `--global`, as do an untagged emulator's.
- MCP: `list_devices`, `setup_device`, `teardown_device`.

## Web UI for the user

`apxy ui` serves the web UI at `http://127.0.0.1:8082` with no proxy running. It reads the shared database and every rules file. The picker in the top bar shows **All workspaces**, each workspace, or **Untagged**. Workspace rules are read-only there, with the path of their file, and global rules can be edited. Tell the user about it when they want to watch the agents' traffic.
