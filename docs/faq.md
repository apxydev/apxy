# Frequently Asked Questions

## General

### What is APXY?

APXY is an AI agent tool for HTTPS debugging and API mocking. It's a desktop network proxy designed for both human developers and AI agents.

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

# Import selected rules. Templates may use response headers and header conditions.
jq -c '.[]' rules.json | while read -r rule; do
  args=(
    apxy mock add
    --name "$(echo "$rule" | jq -r '.name')"
    --url "$(echo "$rule" | jq -r '.url_pattern')"
    --match "$(echo "$rule" | jq -r '.match_type')"
    --status "$(echo "$rule" | jq -r '.response_status')"
    --body "$(echo "$rule" | jq -r '.response_body')"
  )

  method="$(echo "$rule" | jq -r '.method // empty')"
  response_headers="$(echo "$rule" | jq -c '.response_headers // {}')"
  header_conditions="$(echo "$rule" | jq -c '.header_conditions // {}')"

  if [ -n "$method" ]; then args+=(--method "$method"); fi
  if [ "$response_headers" != "{}" ]; then args+=(--headers "$response_headers"); fi
  if [ "$header_conditions" != "{}" ]; then args+=(--header-conditions "$header_conditions"); fi

  "${args[@]}"
done
```

On the Free plan, only keep a few rules active at once. For provider-specific notes and scenario headers like `X-APXY-Scenario`, see [mock-templates/README.md](../mock-templates/README.md).
