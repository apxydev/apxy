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

### Option 1: Import with the CLI

```bash
# Download a template
curl -O https://raw.githubusercontent.com/apxydev/apxy/main/mock-templates/stripe/rules.json

# Import every rule in the file
apxy mock import --file rules.json

# Or import a subset: keep only the rules you want, then import that file
jq '[.[] | select(.name | test("charge"; "i"))]' rules.json > charges.json
apxy mock import --file charges.json
```

### Option 2: Copy individual rules

Browse a template's `rules.json`, pick the rules you need, and add them manually:

```bash
apxy mock add --name "Mock Stripe Charge" \
  --url "https://api.stripe.com/v1/charges" --match exact --method POST \
  --headers "Content-Type=application/json,Request-Id=req_test_123" \
  --status 200 --body '{"id":"ch_test_123","object":"charge","status":"succeeded"}'
```

### Scenario Rules

Some templates include alternate outcomes on the same endpoint by matching a request header:

```bash
apxy mock add --name "Stripe: Card Declined" \
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
