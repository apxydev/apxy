# OpenAI API Mock Templates

Mock rules for the [OpenAI API](https://developers.openai.com/api/reference/overview).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `https://api.openai.com/v1/responses` | Create a model response |
| POST | `https://api.openai.com/v1/chat/completions` | Chat completions compatibility endpoint |
| POST | `https://api.openai.com/v1/embeddings` | Create embeddings |
| GET | `https://api.openai.com/v1/models` | List models |
| GET | `https://api.openai.com/v1/models/*` | Retrieve a model |

## Usage

```bash
# Add the current Responses API success case
apxy rules mock add --name "OpenAI: Create Response" \
  --url "https://api.openai.com/v1/responses" --match exact --method POST \
  --headers "Content-Type=application/json,x-request-id=req_openai_test_123,openai-version=2020-10-01" \
  --status 200 \
  --body '{"id":"resp_test_123","object":"response","status":"completed"}'

# Add a scenario rule for rate limiting
apxy rules mock add --name "OpenAI: Rate Limited" \
  --url "https://api.openai.com/v1/responses" --match exact --method POST \
  --header-conditions "X-APXY-Scenario=rate_limited" \
  --headers "Content-Type=application/json,x-request-id=req_openai_rate_limit,x-ratelimit-remaining-requests=0,Retry-After=60" \
  --status 429 \
  --body '{"error":{"message":"Rate limit reached for requests","type":"rate_limit_error","code":"rate_limit_exceeded"}}'
```

## Scenarios

Use `X-APXY-Scenario` to activate alternate outcomes:

| Scenario | Typical Endpoint | Result |
|----------|------------------|--------|
| `invalid_request` | `POST /v1/responses`, `/v1/chat/completions`, or `/v1/embeddings` | 400 invalid request error |
| `unauthorized` | Any `https://api.openai.com/v1/*` route | 401 invalid API key |
| `rate_limited` | Any `https://api.openai.com/v1/*` route | 429 rate limit error |
| `server_error` | Any `https://api.openai.com/v1/*` route | 500 server error |
| `not_found` | `GET /v1/models/*` | 404 model not found |

## Notes

- `POST /v1/responses` is the primary current endpoint. `POST /v1/chat/completions` is included for compatibility with existing integrations.
- Response headers include common OpenAI debugging and rate-limit fields such as `x-request-id`, `openai-version`, `openai-processing-ms`, and `x-ratelimit-*`.
- The model list uses current examples such as `gpt-5.4`, `gpt-5-mini`, `gpt-5-nano`, `gpt-4.1`, `text-embedding-3-small`, and `text-embedding-3-large`.
- These mocks are static. They do not stream SSE events or branch on request bodies.
