# DSL Match Expressions

Used by breakpoint `--match`, script `--match`, interceptor `--match`, and filter `--target`.

## Fields

| Field | Description | Example |
|-------|-------------|---------|
| `host` | Request hostname | `host == api.example.com` |
| `path` | URL path component | `path contains /login` |
| `url` | Full request URL | `url startswith https://api.stripe.com` |
| `method` | HTTP method (GET, POST, etc.) | `method == POST` |
| `status` | Response status code (response-phase only) | `status >= 400` |
| `header:<Name>` | Value of a named request/response header | `header:Content-Type contains json` |

## Operators

| Operator | Description | Works With |
|----------|-------------|------------|
| `==` | Exact equality | All fields |
| `!=` | Not equal | All fields |
| `contains` | Substring match | `host`, `path`, `url`, `header:*` |
| `startswith` | Prefix match | `host`, `path`, `url`, `header:*` |
| `endswith` | Suffix match | `host`, `path`, `url`, `header:*` |
| `matches` | Regex match | `host`, `path`, `url`, `header:*` |
| `>=` | Greater than or equal | `status` |
| `<=` | Less than or equal | `status` |
| `>` | Greater than | `status` |
| `<` | Less than | `status` |

## Combinators

| Combinator | Description |
|------------|-------------|
| `&&` | Logical AND — both conditions must match |
| `\|\|` | Logical OR — either condition matches |
| `()` | Grouping — control evaluation order |

## Wildcard

`*` — matches all traffic. This is the default for `script --match` when not specified.

## Examples

```
# Match all POST requests to a specific host
"host == api.example.com && method == POST"

# Match any server error
"status >= 500"

# Match client errors OR server errors
"status >= 400"

# Match errors on a specific path
"path contains /api && status >= 500"

# Match by content type header
"header:Content-Type contains json"

# Match login requests
"path contains /login && method == POST"

# Match all Stripe API traffic
"url startswith https://api.stripe.com"

# Match GraphQL endpoints
"path endswith /graphql"

# Match non-GET requests to API paths
"method != GET && path contains /api"

# Match paths with regex
"path matches ^/api/v[0-9]+/users"

# Complex grouping: errors on API or auth paths
"(path contains /api || path contains /auth) && status >= 400"

# Match requests with a specific auth header
"header:Authorization startswith Bearer"

# Match slow responses (use with breakpoint on response phase)
"host == api.example.com && status >= 200"
```

## Usage by Command

| Command | Flag | Default |
|---------|------|---------|
| `apxy rules breakpoint add` | `--match` (required) | — |
| `apxy rules script add` | `--match` | `*` (all traffic) |
| `apxy rules interceptor set` | `--match` | — |
| `apxy traffic filter set` | `--target` | — |
