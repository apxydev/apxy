# Mock Templates

Pre-built mock rules for popular APIs. Use these to quickly set up mock responses for development and testing.

## Available Templates

| API | Description |
|-----|-------------|
| [Stripe](stripe/) | Payment intents, charges, customers |
| [GitHub API](github-api/) | Repositories, users, issues |
| [OpenAI](openai/) | Chat completions, embeddings |

## How to Use

### Option 1: Import via CLI

```bash
# Download a template
curl -O https://raw.githubusercontent.com/apxydev/apxy/main/mock-templates/stripe/rules.json

# Import each rule
cat rules.json | jq -c '.[]' | while read rule; do
  apxy mock add \
    --name "$(echo $rule | jq -r '.name')" \
    --url "$(echo $rule | jq -r '.url_pattern')" \
    --match "$(echo $rule | jq -r '.match_type')" \
    --status "$(echo $rule | jq -r '.response_status')" \
    --body "$(echo $rule | jq -r '.response_body')"
done
```

### Option 2: Copy individual rules

Browse a template's `rules.json`, pick the rules you need, and add them manually:

```bash
apxy mock add --name "Mock Stripe Charge" \
  --url "/v1/charges" --match wildcard \
  --status 200 --body '{"id":"ch_test","status":"succeeded"}'
```

## Contributing a Template

1. Copy `_template/` to a new folder with the API name
2. Edit `rules.json` with your mock rules
3. Write a `README.md` describing what endpoints are covered
4. Open a pull request

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full MockRule JSON schema.
