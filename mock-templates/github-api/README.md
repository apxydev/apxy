# GitHub API Mock Templates

Mock rules for the [GitHub REST API](https://docs.github.com/en/rest).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `https://api.github.com/user` | Get the authenticated user |
| GET | `https://api.github.com/users/*` | Get a user by username |
| GET | `https://api.github.com/user/repos*` | List repositories for the authenticated user |
| GET | `https://api.github.com/repos/*/*` | Get a repository |
| GET | `https://api.github.com/repos/*/*/issues*` | List repository issues |
| GET | `https://api.github.com/repos/*/*/issues/*` | Get an issue |
| POST | `https://api.github.com/repos/*/*/issues` | Create an issue |

## Usage

```bash
# Add the default authenticated-user rule
apxy mock add --name "GitHub: Get Authenticated User" \
  --url "https://api.github.com/user" --match exact --method GET \
  --headers "Content-Type=application/json; charset=utf-8,X-GitHub-Api-Version-Selected=2026-03-10" \
  --status 200 --body '{"login":"testuser","id":1,"name":"Test User"}'

# Add a scenario rule for rate limiting
apxy mock add --name "GitHub: Rate Limited" \
  --url "https://api.github.com/repos/*/*/issues" --match wildcard --method POST \
  --header-conditions "X-APXY-Scenario=rate_limited" \
  --headers "Content-Type=application/json; charset=utf-8,X-RateLimit-Remaining=0,Retry-After=60" \
  --status 403 \
  --body '{"message":"API rate limit exceeded for user ID 1.","documentation_url":"https://docs.github.com/rest/using-the-rest-api/troubleshooting-the-rest-api"}'
```

## Scenarios

Use `X-APXY-Scenario` to activate alternate outcomes:

| Scenario | Typical Endpoint | Result |
|----------|------------------|--------|
| `unauthorized` | Any `https://api.github.com/*` route | 401 bad credentials |
| `not_found` | Any `https://api.github.com/*` route | 404 resource not found |
| `validation_failed` | `POST /repos/*/*/issues` | 422 validation or spammed request |
| `rate_limited` | Any `https://api.github.com/*` route | 403 rate limit response |
| `issues_disabled` | `POST /repos/*/*/issues` | 410 gone |

## Notes

- Responses include common GitHub REST headers such as `X-GitHub-Api-Version-Selected`, `X-GitHub-Media-Type`, and `X-RateLimit-*`.
- List endpoints include pagination-style `Link` headers.
- Issue list responses include a `pull_request` object on one item because GitHub's Issues endpoints can return pull requests too.
- These mocks are static and do not persist newly created issues.
