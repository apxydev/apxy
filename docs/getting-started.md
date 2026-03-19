# Getting Started

Get up and running with APXY in under 5 minutes.

---

## Step 1: Install

```bash
curl -fsSL https://raw.githubusercontent.com/apxydev/apxy/main/scripts/install.sh | bash
```

Or download manually from [GitHub Releases](https://github.com/apxydev/apxy/releases):

| Binary | Platform |
|--------|----------|
| `apxy-darwin-arm64` | macOS (Apple Silicon — M1/M2/M3/M4) |
| `apxy-darwin-amd64` | macOS (Intel) |
| `apxy-linux-amd64` | Linux (x86_64) |

```bash
chmod +x apxy-darwin-arm64
mv apxy-darwin-arm64 apxy
sudo mv apxy /usr/local/bin/
```

Verify:

```bash
apxy version
# APXY v1.0.1
```

---

## Step 2: Start the proxy

```bash
apxy start
```

On macOS, this automatically:
1. Generates a root CA certificate (first run only)
2. Trusts the CA in your system keychain (prompts for password once)
3. Enables system-wide HTTP/HTTPS proxy
4. Starts the Web GUI at `http://localhost:8082`

All traffic on your machine now flows through APXY.

On Linux, set proxy environment variables manually:

```bash
apxy start --no-system-proxy
export http_proxy=http://localhost:8080
export https_proxy=http://localhost:8080
```

---

## Step 3: Make a request

Open any app, browser, or run a curl command:

```bash
curl https://httpbin.org/get
```

---

## Step 4: View captured traffic

**Web GUI:** Open `http://localhost:8082` in your browser.

**CLI:**

```bash
# List recent traffic
apxy logs list --limit 10

# Search for specific requests
apxy logs search --query "httpbin"

# View a specific record
apxy logs show --id <record-id>
```

**AI agent:** If you have MCP configured, ask your AI: *"Show me the last 10 requests captured by the proxy."*

---

## Step 5: Mock an API

```bash
apxy mock add \
  --name "Mock Users" \
  --url "/api/users" \
  --match exact \
  --status 200 \
  --body '{"users": [{"id": 1, "name": "Test User"}]}'
```

Now any request to `/api/users` returns your fake response instead of hitting the real server.

---

## Step 6: Stop the proxy

Press `Ctrl+C` in the terminal, or from another terminal:

```bash
apxy stop
```

This restores your original network settings automatically.

---

## Next Steps

- [User Guide](user-guide.md) — Full feature reference
- [Troubleshooting](troubleshooting.md) — Common issues
- [FAQ](faq.md) — Frequently asked questions
- [AI Agent Skill](../skills/SKILL.md) — Set up MCP for your AI tool
