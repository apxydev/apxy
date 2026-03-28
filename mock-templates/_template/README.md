# Template: [API Name]

Mock rules for **[API Name]** ([link to API docs]).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `https://api.example.com/v1/example*` | List examples |
| POST | `https://api.example.com/v1/example` | Create example |

## Usage

```bash
apxy rules mock add --name "List examples" \
  --url "https://api.example.com/v1/example*" --match wildcard --method GET \
  --headers "Content-Type=application/json" \
  --status 200 --body '{"object":"list","data":[],"has_more":false}'
```

## Notes

- These mocks return static responses for development and testing
- Prefer full URLs so HTTPS host sync works automatically
- Use `header_conditions` when you need multiple outcomes on the same endpoint
- Adjust response bodies to match your test scenarios
