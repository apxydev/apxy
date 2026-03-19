# OpenAI API Mock Templates

Mock rules for the [OpenAI API](https://platform.openai.com/docs/api-reference).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v1/chat/completions` | Chat completions |
| POST | `/v1/embeddings` | Create embeddings |
| GET | `/v1/models` | List models |

## Usage

```bash
apxy mock add --name "OpenAI: Chat Completion" \
  --url "/v1/chat/completions" --match exact --method POST \
  --status 200 --body '{"id":"chatcmpl-test","object":"chat.completion","choices":[{"message":{"role":"assistant","content":"Hello! How can I help?"},"finish_reason":"stop","index":0}]}'
```

## Notes

- Mock responses follow OpenAI's API format
- Useful for testing LLM integrations without consuming API credits
- Adjust `content` in chat responses for your test scenarios
- Add `--delay 500` to simulate realistic API latency
