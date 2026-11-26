# Setup, devices, and plans

## Web UI

`apxy start` serves a web UI at `http://127.0.0.1:8082` (proxy port + 2; `--web-port 0` turns it off). Pages: Traffic, Setup, Compose (build and send a request), Diff, Rules (mock, filters, redirects, SSL, network, scripts, breakpoints), Audit (what agents did), Protobuf, Schema, Settings, and Mobile. The temporary proxy from `apxy run` has no web UI.

## MCP

- `apxy mcp` runs the MCP server over stdio. `apxy setup mcp` prints the setup for one client (`--client codex|claude-code|claude-desktop|cursor|vscode|windsurf`, `--scope global|workspace` where the client has both) or every client (`--all`). It only previews. `--write` applies it, and only for Codex and Claude Code, through their own CLIs; for the others, the user pastes the printed JSON.
- While `apxy start` runs with its web UI, the same tools are served over HTTP at `http://127.0.0.1:<web-port>/mcp` (default `http://127.0.0.1:8082/mcp`).

## Phones and other devices

1. Start on the computer: `apxy start --ssl-domains api.myapp.com`. The proxy port listens on every interface by default (`--proxy-listen-addr 127.0.0.1` keeps it local). `--listen-addr 0.0.0.0` also opens the web UI and control API to the LAN.
2. On the device, set the Wi-Fi HTTP proxy to the computer's LAN IP and port 8080.
3. On the device, open `http://apxy.proxy/ssl`, then install and trust the APXY CA. The web UI's Mobile page walks through it.

- APXY advertises the proxy over mDNS (Bonjour). `--no-mdns` turns that off.
- `apxy start` blocks outgoing QUIC (UDP 443) and strips `Alt-Svc`, so apps fall back to TCP through the proxy. `--no-block-quic` turns that off, and HTTP/3 traffic then skips the proxy.
- Each record has `client_ip` and `client_app` (from the User-Agent), tunneled HTTPS `CONNECT` records included, so you can tell devices apart.

## Protocols

HTTP/1.1 and HTTP/2 work on both legs: a decrypted HTTP/2 client talks HTTP/2 to the origin too, and trailers are kept. gRPC gets no special handling. It shows as HTTP/2 `POST` requests with binary bodies.

## Project mode

`apxy init` creates `.apxy/` in the repo: a committed `settings.json` (mocks, SSL domains, scripts, breakpoints, custom CAs) and project CA, plus an ignored `data/` database. Any `apxy` command run below that folder uses it instead of `~/.apxy`; the two never merge. `--no-project` or `APXY_NO_PROJECT=1` forces `~/.apxy`. Rule changes made while a project proxy runs are written back to `settings.json`.

## Other start flags

| Flag | Use |
|------|-----|
| `--upstream-proxy http://proxy:3128` | Chain to a corporate proxy. DNS overrides are refused in this mode. |
| `--bypass-domains '*.openai.com,*.local'` | Always tunnel these hosts, even with `--mitm-all` |
| `--max-body <bytes>` | Largest body kept per record (default 10485760, 10 MiB) |
| `apxy certs custom add --domain '*.corp' --cert ca.crt --key ca.key` | Sign certificates for matching hosts with your own CA instead of the APXY CA (needs a running proxy) |

## Free and Pro

The Free plan stops each proxy session, `apxy start` or the temporary proxy of `apxy run`, after 10 minutes. A new proxy starts with empty traffic logs, so read what you need first. Pro removes the limit: `apxy license activate --key <KEY>`, check with `apxy license status`, and free the seat with `apxy license deactivate`.
