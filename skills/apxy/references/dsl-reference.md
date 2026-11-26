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

## Stream fields

Only `apxy wait --expect` and the MCP `wait_for_request` tool read these. `sse.*` needs an SSE response, and `ws.*` a WebSocket. HTTPS streams must be decrypted (`--ssl-domains` or `--mitm-all`).

| Field | Description |
|-------|-------------|
| `sse.count` | Number of events |
| `sse.event`, `sse.data` | Type or data of any event. An event without a type is `message`. |
| `sse.data.<gjson path>` | A JSON field in any event's data |
| `sse.last.event`, `sse.last.data`, `sse.last.data.<gjson path>` | The last event |
| `sse.text` | All event data joined into one text. OpenAI, Anthropic, and Gemini deltas become the full answer. |
| `ws.count`, `ws.client.count`, `ws.server.count` | Number of data frames: both directions, sent by the client, or sent by the server |
| `ws.client.data`, `ws.server.data`, with optional `.<gjson path>` | Any frame in that direction |
| `ws.client.last.data`, `ws.server.last.data`, with optional `.<gjson path>` | The last frame in that direction |

- **Any and none.** A field over many events or frames holds when any of them satisfies the condition. `!=` holds when none equals the value, so `sse.event != error` means no error event, and it also holds on an empty stream.
- **Waiting.** A failing expectation is checked again while the stream is open. It fails for good (exit 7) once the stream ends or `--timeout` passes. A check for something that must not happen passes as soon as it holds, so pair it with one that marks the end: `--expect 'sse.event != error' --expect 'sse.last.data == "[DONE]"'`.
- **Frames are separate.** A WebSocket message split across continuation frames is not joined.

## Operators

| Operator | Description | Works With |
|----------|-------------|------------|
| `==` | Equality, ignoring case | All fields |
| `!=` | Not equal | All fields |
| `contains` | Substring match, ignoring case | All fields |
| `startswith` | Prefix match, ignoring case | All fields |
| `endswith` | Suffix match, ignoring case | All fields |
| `matches` | Regex match | All fields |
| `>=` | Greater than or equal | Fields with a whole-number value |
| `<=` | Less than or equal | Fields with a whole-number value |
| `>` | Greater than | Fields with a whole-number value |
| `<` | Less than | Fields with a whole-number value |
| `exists` | The field is present. Takes no value. | `header:*`, `body.*`, `req.body.*`, and stream event and data fields (not counts or `sse.text`) |

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

# apxy wait --expect: the LLM stream finished and said the right thing
"sse.last.data == [DONE]"
"sse.text contains refund"

# apxy wait --expect: the server pushed the event over the WebSocket
"ws.server.data.type == order_created"
```

## Usage by command

| Command | Flag | Default |
|---------|------|---------|
| `apxy wait` | `--match` (required) | none |
| `apxy wait` | `--expect` (repeatable) | none |
| `apxy breakpoint add` | `--match` (required) | none |
| `apxy script add` | `--match` | `*` (all traffic) |

`apxy filter set --target` takes a domain pattern such as `*.example.com`, not a match expression.
