# Match expressions

`apxy wait --match`, `apxy wait --expect`, `apxy breakpoint add --match`, and `apxy script add --match` take these expressions.

## Fields

| Field | Description | Example |
|-------|-------------|---------|
| `host` | Request hostname | `host == api.example.com` |
| `path` | URL path component | `path contains /login` |
| `url` | Full request URL | `url startswith https://api.stripe.com` |
| `method` | HTTP method (GET, POST, etc.) | `method == POST` |
| `status` | Response status code (response-phase only) | `status >= 400` |
| `header:<Name>` | Value of a named request or response header | `header:Content-Type contains json` |
| `body.<gjson path>` | A field in the response body. Used by `apxy wait`. | `body.order.id exists` |
| `req.body.<gjson path>` | A field in the request body. Used by `apxy wait`. | `req.body.sku == A1` |

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
| `exists` | The field is present. Takes no value. | `header:*`, `body.*`, `req.body.*` |

## Combinators

| Combinator | Description |
|------------|-------------|
| `&&` | Logical AND. Both conditions must match. |
| `\|\|` | Logical OR. Either condition matches. |
| `()` | Grouping. Controls the order of evaluation. |

## Wildcard

`*` matches all traffic. It is the default for `apxy script add --match`.

## Method and path shorthand

`apxy wait --match` also takes `"METHOD /path"`, such as `"POST /api/checkout"`. It matches when the method and the path are equal.

## Examples

```
# Match all POST requests to a specific host
"host == api.example.com && method == POST"

# Match any server error
"status >= 500"

# Match client errors or server errors
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

# Match error responses on a specific host (use with a response-phase breakpoint)
"host == api.example.com && status >= 500"

# apxy wait --expect: a response field is present
"body.order.id exists"

# apxy wait --expect: the request sent the right value
"req.body.currency == usd"
```

## Usage by command

| Command | Flag | Default |
|---------|------|---------|
| `apxy wait` | `--match` (required) | none |
| `apxy wait` | `--expect` (repeatable) | none |
| `apxy breakpoint add` | `--match` (required) | none |
| `apxy script add` | `--match` | `*` (all traffic) |

`apxy filter set --target` takes a domain pattern such as `*.example.com`, not a match expression.
