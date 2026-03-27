# Mocking OpenAI's API for Development

Ship AI features without paying per token on every save. APXY's OpenAI template returns plausible `chat.completion`, `embeddings`, and `models` payloads (plus `/v1/responses`) so your HTTP client or SDK can target `https://api.openai.com` while staying fully offline.

**Difficulty**: Intermediate | **Time**: ~20 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

You are wiring up chat, RAG embeddings, or model listing in your app. Real calls are slow, cost money, and complicate CI. Import the OpenAI mock pack to get deterministic JSON for `POST /v1/chat/completions`, `POST /v1/embeddings`, and `GET /v1/models`, and use `X-APXY-Scenario` headers to exercise `invalid_api_key`, `rate_limit_exceeded`, and other error shapes without touching OpenAI's servers.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.openai.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.openai.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

### What this template covers

| Endpoint | Notes |
|----------|--------|
| `POST /v1/chat/completions` | Mock assistant message + usage block |
| `POST /v1/embeddings` | Mock embedding vector list |
| `GET /v1/models` | Mock model catalog |
| `GET /v1/models/*` | Single model; optional `not_found` scenario |
| `POST /v1/responses` | Responses API-shaped success payload |
| Errors | e.g. `X-APXY-Scenario: unauthorized` → `invalid_api_key`; `rate_limited` → 429 |

---

## Track A: Agent + CLI Workflow

> Run imports from the repository root that contains `mock-templates/`.

### Step 1: Import OpenAI mocks

Tell your agent:

> "Import mock-templates/openai/rules.json into APXY."

Your agent runs:

```bash
apxy rules mock import --file mock-templates/openai/rules.json
```

### Step 2: List rules

Tell your agent:

> "List mock rules to verify OpenAI rules."

Your agent runs:

```bash
apxy rules mock list
```

### Step 3: Chat completion

Tell your agent:

> "POST a minimal chat completion to api.openai.com with Authorization Bearer sk-mock."

Your agent runs:

```bash
curl -s -X POST https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer sk-mock" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-4","messages":[{"role":"user","content":"Hello"}]}'
```

Expect `200` and a `choices[0].message.content` string from the template.

### Step 4: Embeddings

Tell your agent:

> "POST to the embeddings endpoint with a short input string."

Your agent runs:

```bash
curl -s -X POST https://api.openai.com/v1/embeddings \
  -H "Authorization: Bearer sk-mock" \
  -H "Content-Type: application/json" \
  -d '{"model":"text-embedding-3-small","input":"hello world"}'
```

### Step 5: List models

Tell your agent:

> "GET /v1/models through the proxy."

Your agent runs:

```bash
curl -s https://api.openai.com/v1/models \
  -H "Authorization: Bearer sk-mock"
```

### Step 6: Error handling drills

Tell your agent:

> "Call chat completions with X-APXY-Scenario unauthorized to simulate invalid API key."

Your agent runs:

```bash
curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer sk-bad" \
  -H "X-APXY-Scenario: unauthorized" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-4","messages":[{"role":"user","content":"x"}]}'
```

Repeat with `rate_limited` on any matching `v1` path per template rules to practice backoff and user messaging.

### Step 7: Remove or extend rules

Tell your agent:

> "Remove a single mock rule by id."

Your agent runs:

```bash
apxy rules mock list
apxy rules mock remove --id <RULE_ID>
```

Add new branches with `apxy rules mock add` if you need tool-calls or streaming-specific test doubles.

---

## Track B: Web UI Workflow

### Step 1: Start proxy + Web UI

Use `--ssl-domains api.openai.com`, then open **http://localhost:8082**.

> screenshots/01-dashboard-openai-mock.png

### Step 2: Fire chat and embedding requests

Run the Track A curls. Traffic should show full JSON bodies for requests and responses.

> screenshots/02-openai-traffic-chat-embed.png

### Step 3: Inspect rate-limit headers

Open a completion row and review response headers (`x-ratelimit-*`) supplied by the mock.

> screenshots/03-openai-rate-limit-headers.png

### Step 4: Compare error scenario

Send one successful chat request and one with `X-APXY-Scenario: unauthorized`. Compare status and error JSON in the detail view.

> screenshots/04-openai-error-scenario.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Import + chat/embeddings/models: 0:00 - 9:00
- Scenario errors + Web UI inspection: 9:00 - 18:00

---

## What You Learned

- How to intercept TLS for `api.openai.com` and keep using the real hostname in code
- How the bundled `mock-templates/openai/rules.json` maps to chat, embeddings, and models
- How to rehearse auth and rate-limit failures with scenario headers
- How to use the Web UI to verify payloads your app parses (choices, usage, embedding arrays)

## Next Steps

- Mirror streaming endpoints with dedicated rules if your client uses SSE
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- trust CA on additional machines
- [API Mocking](../../api-mocking/) -- custom URL patterns
- [Replay and Diff](../../replay-and-diff/) -- compare mock output to a captured real completion once
