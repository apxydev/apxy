# Mock Templates

Pre-built mock rules for popular APIs. Use these as realistic starting points for development and testing.

## Available Templates

| API | Description |
|-----|-------------|
| [Stripe](stripe/) | Charges, payment intents, customers, list responses, common errors |
| [GitHub API](github-api/) | Users, repositories, issues, pagination headers, common REST failures |
| [OpenAI](openai/) | Responses, chat completions, embeddings, models, common API failures |

## How to Use

Templates are plain `MockRule` arrays. You can inspect them, import a subset, or copy individual rules into your own config.

### Option 1: Import Selected Rules Via CLI

```bash
# Download a template
curl -O https://raw.githubusercontent.com/apxydev/apxy/main/mock-templates/stripe/rules.json

# Import a subset. On the Free plan, keep it to 3 active rules at a time.
jq -c '.[]' rules.json | while read -r rule; do
  args=(
    apxy rules mock add
    --name "$(echo "$rule" | jq -r '.name')"
    --url "$(echo "$rule" | jq -r '.url_pattern')"
    --match "$(echo "$rule" | jq -r '.match_type')"
    --status "$(echo "$rule" | jq -r '.response_status')"
    --body "$(echo "$rule" | jq -r '.response_body')"
    --delay "$(echo "$rule" | jq -r '.delay_ms // 0')"
    --priority "$(echo "$rule" | jq -r '.priority // 0')"
  )

  method="$(echo "$rule" | jq -r '.method // empty')"
  response_headers="$(echo "$rule" | jq -c '.response_headers // {}')"
  header_conditions="$(echo "$rule" | jq -c '.header_conditions // {}')"

  if [ -n "$method" ]; then
    args+=(--method "$method")
  fi
  if [ "$response_headers" != "{}" ]; then
    args+=(--headers "$response_headers")
  fi
  if [ "$header_conditions" != "{}" ]; then
    args+=(--header-conditions "$header_conditions")
  fi

  "${args[@]}"
done
```

### Option 2: Copy individual rules

Browse a template's `rules.json`, pick the rules you need, and add them manually:

```bash
apxy rules mock add --name "Mock Stripe Charge" \
  --url "https://api.stripe.com/v1/charges" --match exact --method POST \
  --headers "Content-Type=application/json,Request-Id=req_test_123" \
  --status 200 --body '{"id":"ch_test_123","object":"charge","status":"succeeded"}'
```

### Scenario Rules

Some templates include alternate outcomes on the same endpoint by matching a request header:

```bash
apxy rules mock add --name "Stripe: Card Declined" \
  --url "https://api.stripe.com/v1/payment_intents/*/confirm" \
  --match wildcard --method POST \
  --header-conditions "X-APXY-Scenario=card_declined" \
  --status 402 \
  --body '{"error":{"type":"card_error","code":"card_declined"}}'
```

Send the request with `X-APXY-Scenario: card_declined` to activate that rule.

## Contributing a Template

1. Copy `_template/` to a new folder with the API name
2. Edit `rules.json` with your mock rules
3. Write a `README.md` describing what endpoints are covered
4. Open a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full MockRule JSON schema.
