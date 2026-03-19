# GitHub API Mock Templates

Mock rules for the [GitHub REST API](https://docs.github.com/en/rest).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/user` | Get authenticated user |
| GET | `/users/*` | Get a user by username |
| GET | `/repos/*/*` | Get a repository |
| GET | `/repos/*/*/issues` | List repository issues |
| POST | `/repos/*/*/issues` | Create an issue |

## Usage

```bash
apxy mock add --name "GitHub: Get User" \
  --url "/user" --match exact --method GET \
  --status 200 --body '{"login":"testuser","id":1,"name":"Test User"}'
```

## Notes

- Responses follow the GitHub API v3 format
- Rate limit headers are included in responses
- Adjust `login`, `owner`, and `repo` values for your test scenarios
