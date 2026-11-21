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
curl -fsSL https://apxy.dev/install.sh | bash
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

Verify that the install works. The command prints the installed version.

```bash
apxy version
```

---

## Step 2: Start the proxy

APXY records the full body of an HTTPS request only for domains that you turn on. Other HTTPS traffic shows up as a `CONNECT` line with the host name and no body. Turn on `httpbin.org` for this guide:

```bash
apxy start --ssl-domains httpbin.org
```

To turn on another domain later, run `apxy ssl enable --domain <host>`.

On macOS, `apxy start` does these things:
1. Generates a root CA certificate (first run only)
2. Trusts the CA in your system keychain (prompts for password once)
3. Enables the system-wide HTTP and HTTPS proxy
4. Starts the Web UI at `http://localhost:8082`

Browsers and apps that use the system proxy now go through APXY.

On Linux, start without the system proxy:

```bash
apxy start --ssl-domains httpbin.org --no-system-proxy
```

---

## Step 3: Make a request

Many terminal tools, curl included, ignore the macOS system proxy. In a second terminal, send the request through `apxy run`. It sets the proxy and the CA certificate for that one command:

```bash
apxy run curl https://httpbin.org/get
```

To route every command in the current shell through APXY, run `eval "$(apxy env)"` first.

---

## Step 4: View captured traffic

**Web UI:** Open `http://localhost:8082` in your browser.

**CLI:**

```bash
# List recent traffic
apxy logs list --limit 10

# Search for specific requests
apxy logs search --query "httpbin"

# View a specific record
apxy logs show --id <record-id>
```

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

APXY turns the system proxy off again.

If you ran `eval "$(apxy env)"`, that shell still sends traffic to the stopped proxy. Open a new terminal to get a clean shell.

---

## Next Steps

- [User Guide](user-guide.md) — Full feature reference
- [Troubleshooting](troubleshooting.md) — Common issues
- [FAQ](faq.md) — Frequently asked questions
