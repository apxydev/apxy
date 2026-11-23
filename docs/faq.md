# Frequently Asked Questions

## General

### What is APXY?

APXY is a network debugging and API mocking proxy for HTTPS traffic. It is designed for developers who want a CLI and Web UI, plus workflows that also fit AI coding agents.

### How is APXY different from Charles Proxy or Proxyman?

APXY offers a full CLI, an MCP server, and a Web UI, all built around repeatable debugging workflows for developers and AI coding agents.

### What platforms are supported?

- macOS (Apple Silicon and Intel)
- Linux (x86_64)

### Is APXY free?

See the current release for pricing and licensing information.

### Is APXY open source?

The core product is proprietary. This GitHub repository hosts the installer, documentation, community mock templates, and usage examples.

---

## Installation

### How do I install APXY?

```bash
curl -fsSL https://apxy.dev/install.sh | bash
```

Or download from [GitHub Releases](https://github.com/apxydev/apxy/releases).

### Where is APXY installed?

The install script places the binary at `~/.apxy/bin/apxy` and adds it to your PATH.

### How do I update APXY?

Run the install script again -- it will replace the existing binary.

### How do I uninstall APXY?

```bash
curl -fsSL https://apxy.dev/install.sh | bash -s -- uninstall
```

Or manually: `rm $(which apxy) && rm -rf ~/.apxy`

---

## Usage

### Does APXY capture all traffic on my machine?

On macOS, `apxy start` configures the system-wide proxy, so all HTTP/HTTPS traffic flows through APXY. You can skip this with `--no-system-proxy` for manual mode.

### Is HTTPS traffic readable?

APXY generates a local CA certificate and uses it to create leaf certificates on-the-fly (MITM). HTTPS interception is opt-in per domain. By default, HTTPS traffic is tunneled without inspection for privacy.

### Can I use APXY in CI/CD?

Yes. Run `apxy start --no-system-proxy` and set `http_proxy`/`https_proxy` environment variables. Use `apxy env` for automatic proxy injection.

### How do I use mock templates from this repo?

```bash
# Download a template
curl -O https://raw.githubusercontent.com/apxydev/apxy/main/mock-templates/stripe/rules.json

# Import every rule in the file
apxy mock import --file rules.json

# Or import a subset: keep only the rules you want, then import that file
jq '[.[] | select(.name | test("charge"; "i"))]' rules.json > charges.json
apxy mock import --file charges.json
```

For provider-specific notes and scenario headers like `X-APXY-Scenario`, see [mock-templates/README.md](../mock-templates/README.md).
