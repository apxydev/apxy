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

High-value ideas:
- APIs used heavily in AI products, payments, auth, or internal tooling
- Templates paired with a concrete example or bug workflow
- Mock kits that help frontend teams develop without live backend dependencies

**MockRule JSON schema:**

```json
[
  {
    "name": "Description of the mock",
    "url_pattern": "https://api.example.com/v1/endpoint",
    "match_type": "exact|wildcard|regex",
    "method": "GET|POST|PUT|DELETE",
    "header_conditions": {
      "X-APXY-Scenario": "error_case"
    },
    "response_status": 200,
    "response_headers": {
      "Content-Type": "application/json"
    },
    "response_body": "{\"key\": \"value\"}",
    "delay_ms": 0,
    "priority": 0,
    "file_path": "",
    "dir_path": ""
  }
]
```

Fields:
- `name` (required): Human-readable description
- `url_pattern` (required): URL to match
- `match_type` (required): `exact`, `wildcard`, or `regex`
- `method` (optional): HTTP method filter. Empty = match all methods
- `header_conditions` (optional): Request headers that must match for the rule to apply
- `response_status` (required): HTTP status code to return
- `response_headers` (optional): Response headers
- `response_body` (required): Response body string
- `delay_ms` (optional): Simulated response delay in milliseconds
- `priority` (optional): Lower numeric values match first (default: 0)
- `file_path` / `dir_path` (optional): Serve the response from a file or directory instead of inline `response_body`

Template guidance:
- Prefer full provider URLs instead of path-only patterns so HTTPS host sync works automatically.
- If you need multiple outcomes on the same endpoint, prefer `header_conditions` over inventing fake URLs.
- Keep responses structurally close to the provider’s docs, but stay honest about static-template limits such as no server-side state or request-body branching.

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

High-value ideas:
- "Debug a real 4xx/5xx failure with an AI coding agent"
- "Replay a request after a fix and diff the response"
- "Use a mock kit to unblock frontend work"

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
- Guidance that pairs a skill prompt with a template or example from this repo

---

## Pull Request Guidelines

- Keep PRs focused on a single contribution
- Follow the existing file structure and naming conventions
- Include a clear description of what you're adding/changing
- For mock templates: test representative rules with `apxy mock add` before submitting

---

## Questions?

Open a [discussion](https://github.com/apxydev/apxy/discussions) or [issue](https://github.com/apxydev/apxy/issues).
