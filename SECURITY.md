# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in APXY, please report it responsibly.

**Do NOT open a public issue.** Instead, email us at:

**security@apxy.dev**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Any suggested fixes (optional)

We will acknowledge receipt within 48 hours and aim to provide a fix or mitigation within 7 days for critical issues.

## Scope

This policy covers:
- The APXY binary (proxy, MCP server, CLI, Web GUI)
- The install script (`scripts/install.sh`)
- Any published release artifacts on GitHub Releases

This policy does **not** cover:
- Community-contributed mock templates or examples
- Third-party dependencies

## Security Design

- APXY generates a local CA certificate for HTTPS interception. The CA private key never leaves your machine.
- HTTPS interception is opt-in (tunnel-only mode by default).
- Telemetry is disabled by default and requires explicit user consent.
- The MCP server communicates via stdio (no network exposure).
- The Web GUI binds to localhost only.

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.0.x   | Yes       |
| < 1.0   | No        |
