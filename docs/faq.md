# Frequently Asked Questions

## General

### What is APXY?

APXY (Agent Proxy) is a desktop network proxy for HTTPS debugging and API mocking. It's designed for both human developers and AI agents.

### How is APXY different from Charles Proxy or Proxyman?

APXY offers a full CLI (30+ commands), SQL queries over traffic data, and a Web GUI — all designed for both human developers and AI agents.

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
curl -fsSL https://raw.githubusercontent.com/apxydev/apxy/main/scripts/install.sh | bash
```

Or download from [GitHub Releases](https://github.com/apxydev/apxy/releases).

### Where is APXY installed?

The install script places the binary at `~/.apxy/bin/apxy` and adds it to your PATH.

### How do I update APXY?

Run the install script again -- it will replace the existing binary.

### How do I uninstall APXY?

```bash
~/.apxy/bin/install.sh uninstall
```

Or manually: `rm $(which apxy) && rm -rf ~/.apxy`

---

## Usage

### Does APXY capture all traffic on my machine?

On macOS, `apxy proxy start` configures the system-wide proxy, so all HTTP/HTTPS traffic flows through APXY. You can skip this with `--no-system-proxy` for manual mode.

### Is HTTPS traffic readable?

APXY generates a local CA certificate and uses it to create leaf certificates on-the-fly (MITM). HTTPS interception is opt-in per domain. By default, HTTPS traffic is tunneled without inspection for privacy.

### Can I use APXY in CI/CD?

Yes. Run `apxy proxy start --no-system-proxy` and set `http_proxy`/`https_proxy` environment variables. Use `apxy env` for automatic proxy injection.

### How do I use mock templates from this repo?

```bash
# Download a template
curl -O https://raw.githubusercontent.com/apxydev/apxy/main/mock-templates/stripe/rules.json

# Import each rule (or use the Web GUI to import)
cat rules.json | jq -c '.[]' | while read rule; do
  apxy mock add \
    --name "$(echo $rule | jq -r '.name')" \
    --url "$(echo $rule | jq -r '.url_pattern')" \
    --match "$(echo $rule | jq -r '.match_type')" \
    --status "$(echo $rule | jq -r '.response_status')" \
    --body "$(echo $rule | jq -r '.response_body')"
done
```

