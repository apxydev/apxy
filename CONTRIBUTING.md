# Contributing to APXY

Thank you for your interest in contributing to APXY! While the core product is proprietary, we welcome community contributions in three areas.

---

## Contribution Areas

### 1. Mock Templates (lowest barrier)

Pre-built mock rules for popular APIs that anyone can import into APXY.

**How to contribute:**

1. Fork this repo
2. Copy `mock-templates/_template/` to `mock-templates/<api-name>/`
3. Edit `rules.json` with your mock rules (see schema below)
4. Write a `README.md` describing what the template covers
5. Open a pull request

**MockRule JSON schema:**

```json
[
  {
    "name": "Description of the mock",
    "url_pattern": "/v1/endpoint",
    "match_type": "exact|wildcard|regex",
    "method": "GET|POST|PUT|DELETE",
    "response_status": 200,
    "response_headers": {
      "Content-Type": "application/json"
    },
    "response_body": "{\"key\": \"value\"}",
    "delay_ms": 0,
    "priority": 0
  }
]
```

Fields:
- `name` (required): Human-readable description
- `url_pattern` (required): URL to match
- `match_type` (required): `exact`, `wildcard`, or `regex`
- `method` (optional): HTTP method filter. Empty = match all methods
- `response_status` (required): HTTP status code to return
- `response_headers` (optional): Response headers
- `response_body` (required): Response body string
- `delay_ms` (optional): Simulated response delay in milliseconds
- `priority` (optional): Higher priority rules match first (default: 0)

### 2. Usage Examples (medium barrier)

Step-by-step tutorials showing how to use APXY for real-world scenarios.

**How to contribute:**

1. Fork this repo
2. Create a new folder under `examples/<your-example-name>/`
3. Write a `README.md` with:
   - What the example demonstrates
   - Prerequisites
   - Step-by-step instructions with shell commands
   - Expected output
4. Open a pull request

### 3. AI Agent Skills (medium barrier)

Improvements to the APXY skill file that teaches AI agents how to use the tool.

**How to contribute:**

1. Fork this repo
2. Edit `skills/SKILL.md` with your improvements
3. Open a pull request explaining what you changed and why

Ideas for skill contributions:
- Better workflow recipes for specific debugging scenarios
- Translations to other languages
- Tips for specific AI tools (Cursor, Claude Code, Windsurf, etc.)

---

## Pull Request Guidelines

- Keep PRs focused on a single contribution
- Follow the existing file structure and naming conventions
- Include a clear description of what you're adding/changing
- For mock templates: test your rules with `apxy mock add` before submitting

---

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

---

## Questions?

Open a [discussion](https://github.com/apxydev/apxy/discussions) or [issue](https://github.com/apxydev/apxy/issues).
