# Getting Started

Get up and running with APXY in under 5 minutes, then choose the CLI or Web UI that fits your workflow.

---

## Step 1: Install

### Option A: Homebrew (recommended)

```bash
brew tap apxydev/apxy https://github.com/apxydev/apxy
brew install apxy
```

### Option B: Shell script

```bash
curl -fsSL https://raw.githubusercontent.com/apxydev/apxy/main/scripts/install.sh | bash
```

### Option C: Manual download

Download from [GitHub Releases](https://github.com/apxydev/apxy/releases):

| Archive | Platform |
|--------|----------|
| `apxy-<version>-darwin-arm64.tar.gz` | macOS (Apple Silicon — M1/M2/M3/M4) |
| `apxy-<version>-darwin-amd64.tar.gz` | macOS (Intel) |
| `apxy-<version>-linux-amd64.tar.gz` | Linux (x86_64) |
| `apxy-<version>-linux-arm64.tar.gz` | Linux (ARM64) |

```bash
tar -xzf apxy-<version>-darwin-arm64.tar.gz
sudo mv apxy /usr/local/bin/
```

Verify:

```bash
apxy version
# APXY v1.0.0
```

---

## Step 2: Start the proxy

```bash
apxy proxy start
```

On macOS, this automatically:
1. Generates a root CA certificate (first run only)
2. Trusts the CA in your system keychain (prompts for password once)
3. Enables system-wide HTTP/HTTPS proxy
4. Starts the Web UI at `http://localhost:8082`

All traffic on your machine now flows through APXY.

On Linux, set proxy environment variables manually:

```bash
apxy proxy start --no-system-proxy
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

**Web UI:** Open `http://localhost:8082` in your browser.

**CLI:**

```bash
# List recent traffic
apxy traffic logs list --limit 10

# Search for specific requests
apxy traffic logs search --query "httpbin"

# View a specific record
apxy traffic logs show --id <record-id>
```

---

## Step 5: Mock an API

```bash
apxy rules mock add \
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
apxy proxy stop
```

This restores your original network settings automatically.

---

## Next Steps

- [User Guide](user-guide.md) — Full feature reference
- [Troubleshooting](troubleshooting.md) — Common issues
- [FAQ](faq.md) — Frequently asked questions
