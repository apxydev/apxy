# APXY Examples

Learn APXY through hands-on tutorials. Each example has two tracks:
- **Track A: Agent + CLI** — tell your AI coding agent what to do, it runs APXY commands
- **Track B: Web UI** — follow along visually in the browser at `http://localhost:8082`

Pick the track that fits your workflow. Both cover the same material.

---

## Getting Started

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [Your First 5 Minutes with APXY](quickstart-5-minutes/) | Beginner | ~5 min | Free |
| [Setting Up HTTPS Interception](getting-started/ssl-setup-guide/) | Beginner | ~5 min | Free |
| [Exploring the Web UI](getting-started/web-ui-tour/) | Beginner | ~10 min | Free |
| [Debugging Mobile App Traffic](getting-started/mobile-device-setup/) | Beginner | ~10 min | Free |

## Debugging

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [Diagnosing and Fixing CORS Issues](debugging/debug-cors-errors/) | Beginner | ~10 min | Free |
| [Debugging OAuth/JWT Authentication Flows](debugging/debug-auth-tokens/) | Intermediate | ~15 min | Free |
| [Finding and Fixing Slow API Endpoints](debugging/debug-slow-api/) | Intermediate | ~10 min | Free |
| [Debugging Webhook Integrations](debugging/debug-webhook-delivery/) | Intermediate | ~15 min | Free |
| [Diagnosing Intermittent API Failures](debugging/debug-flaky-api/) | Intermediate | ~15 min | Free |
| [Debugging GraphQL APIs](debugging/debug-graphql/) | Intermediate | ~10 min | Free |
| [Debugging Traffic from Docker Containers](debugging/debug-docker-container/) | Intermediate | ~15 min | Free |

## Mocking

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [Building UI Without a Backend](mocking/mock-backend-for-frontend/) | Beginner | ~10 min | Free |
| [Testing Error Handling in Your UI](mocking/mock-error-states/) | Beginner | ~10 min | Free |
| [A/B Testing and Feature Flags via Mocks](mocking/mock-with-header-conditions/) | Intermediate | ~10 min | Free |
| [Generating Mocks from an OpenAPI Spec](mocking/mock-from-openapi-spec/) | Intermediate | ~15 min | Free |
| [Serving Mock Responses from Files](mocking/mock-large-responses-from-files/) | Beginner | ~5 min | Free |

### Mock Templates

| Example | API | Difficulty | Time | Tier |
|---------|-----|-----------|------|------|
| [Mocking Stripe's Payment API](mocking/mock-template-stripe/) | Stripe | Beginner | ~10 min | Free |
| [Mocking GitHub's REST API](mocking/mock-template-github/) | GitHub | Beginner | ~10 min | Free |
| [Mocking OpenAI's API for Development](mocking/mock-template-openai/) | OpenAI | Beginner | ~10 min | Free |
| [Mocking Auth0 Authentication](mocking/mock-template-auth0/) | Auth0 | Beginner | ~10 min | Free |
| [Mocking Twilio SMS & Voice API](mocking/mock-template-twilio/) | Twilio | Beginner | ~10 min | Free |
| [Mocking AWS S3 Operations](mocking/mock-template-aws-s3/) | AWS S3 | Intermediate | ~10 min | Free |
| [Mocking Firebase Auth & Firestore](mocking/mock-template-firebase/) | Firebase | Intermediate | ~10 min | Free |
| [Mocking Shopify Storefront API](mocking/mock-template-shopify/) | Shopify | Intermediate | ~10 min | Free |

## Replay & Diff

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [The Capture → Replay → Diff Loop](replay-and-diff/) | Intermediate | ~10 min | Free |
| [Catching API Regressions Before Deployment](replay-and-diff/regression-testing-with-diff/) | Intermediate | ~15 min | Free |
| [Creating a Reproducible Bug Report](replay-and-diff/export-and-share-bug/) | Beginner | ~5 min | Free |
| [Exporting Requests as cURL, Fetch, HTTPie, and Python](replay-and-diff/export-to-multiple-formats/) | Beginner | ~5 min | Free |
| [Saving and Restoring Debug Sessions](replay-and-diff/session-save-restore/) | Intermediate | ~10 min | Pro |
| [Sharing a Debug Artifact with Your Team](replay-and-diff/share-debug-artifact/) | Beginner | ~5 min | Free |

## AI Agent Workflows

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [Using APXY as a Claude Code / Cursor Skill](ai-agent/agent-skill-reference/) | Beginner | ~5 min | Free |
| [Let Your AI Agent Find and Fix Server Errors](ai-agent/agent-debug-500-errors/) | Intermediate | ~15 min | Free |
| [AI Agent Creates Mocks to Unblock While Fixing](ai-agent/agent-mock-while-fixing/) | Intermediate | ~10 min | Free |
| [AI Agent Validates a Fix with Replay+Diff](ai-agent/agent-compare-before-after/) | Intermediate | ~10 min | Free |
| [AI Agent Analyzes Slow Endpoints](ai-agent/agent-diagnose-api-performance/) | Intermediate | ~10 min | Free |
| [AI Agent Configures Mock Environment](ai-agent/agent-setup-test-environment/) | Advanced | ~15 min | Free |

## Network Simulation

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [Testing Your App on Slow Connections](network-simulation/simulate-slow-network/) | Beginner | ~10 min | Pro |
| [Testing Resilience to Network Problems](network-simulation/simulate-network-failures/) | Intermediate | ~10 min | Pro |
| [Handling API Rate Limits Gracefully](network-simulation/simulate-rate-limiting/) | Intermediate | ~10 min | Free |
| [Filtering Out Noisy Third-Party Traffic](network-simulation/block-third-party-requests/) | Beginner | ~5 min | Free |

## Rules & Scripting

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [Pointing Your App at Different Environments](rules-and-scripting/redirect-api-to-staging/) | Beginner | ~5 min | Free |
| [Pausing and Editing Live Requests](rules-and-scripting/breakpoint-inspect-modify/) | Intermediate | ~10 min | Pro |
| [Auto-Injecting Auth Headers with Scripts](rules-and-scripting/script-add-auth-header/) | Intermediate | ~10 min | Pro |
| [Modifying API Responses with Scripts](rules-and-scripting/script-transform-response/) | Advanced | ~15 min | Pro |

## Advanced

| Example | Difficulty | Time | Tier |
|---------|-----------|------|------|
| [Decoding Protobuf API Traffic](advanced/inspect-protobuf-traffic/) | Advanced | ~15 min | Free |
| [Extracting Specific Data from API Responses](advanced/extract-data-with-jsonpath/) | Beginner | ~5 min | Free |

---

## Legacy Examples

These examples predate the themed organization above. They still work but may overlap with newer tutorials.

| Example | Description |
|---------|-------------|
| [Basic Debugging](basic-debugging/) | Capture, search, inspect, SQL queries, export |
| [API Mocking](api-mocking/) | Mock endpoints with exact/regex/POST matching |
| [AI Agent Workflow](ai-agent-workflow/) | Agent-driven debugging with SQL analysis |

---

## How to Use These Examples

1. **Start with [Quickstart](quickstart-5-minutes/)** if you're new to APXY
2. **Set up SSL** with [SSL Setup Guide](getting-started/ssl-setup-guide/) for HTTPS debugging
3. **Pick your use case** from the categories above
4. **Choose your track** — Agent+CLI (Track A) or Web UI (Track B)

## Prerequisites

All examples assume:
- APXY is installed (`brew install apxy` or [download](https://apxy.dev))
- macOS or Linux
- For Agent+CLI examples: an AI coding agent (Claude Code, Cursor, Codex, or Copilot) with the [APXY skill](ai-agent/agent-skill-reference/) installed
