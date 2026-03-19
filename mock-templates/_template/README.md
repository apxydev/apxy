# Template: [API Name]

Mock rules for **[API Name]** ([link to API docs]).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/v1/example` | List examples |
| POST | `/v1/example` | Create example |

## Usage

```bash
apxy mock add --name "List examples" \
  --url "/v1/example" --match exact \
  --status 200 --body '{"data":[]}'
```

## Notes

- These mocks return static responses for development and testing
- Adjust response bodies to match your test scenarios
