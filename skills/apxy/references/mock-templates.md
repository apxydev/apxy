# Vendor Mock Templates

## Vendors with Pre-built Templates

These vendors have complete `rules.json` files. Read the file and create each rule using `apxy rules mock add`, or import the whole file at once with `apxy rules mock import --file <path>`.

### Stripe (api.stripe.com)

SSL: `apxy proxy start --ssl-domains api.stripe.com`

**Pre-built template:** `apxy/mock-templates/stripe/rules.json` (15 rules)

**Quick start (3 key rules):**

```bash
# Create charge -- 200 with charge object
apxy rules mock add --name "stripe-create-charge" \
  --url "https://api.stripe.com/v1/charges" \
  --match exact --method POST --status 200 \
  --body '{"id":"ch_test_123","object":"charge","amount":2000,"currency":"usd","status":"succeeded","paid":true,"captured":true,"created":1770000000,"customer":"cus_test_123","payment_intent":"pi_test_123"}' \
  --delay 100 --priority 50

# Create payment intent -- 200 with client_secret
apxy rules mock add --name "stripe-create-pi" \
  --url "https://api.stripe.com/v1/payment_intents" \
  --match exact --method POST --status 200 \
  --body '{"id":"pi_test_123","object":"payment_intent","amount":2000,"currency":"usd","status":"requires_payment_method","client_secret":"pi_test_123_secret_abc","created":1770000200,"payment_method_types":["card"]}' \
  --delay 100 --priority 50

# Confirm payment intent -- 200 succeeded
apxy rules mock add --name "stripe-confirm-pi" \
  --url "https://api.stripe.com/v1/payment_intents/*/confirm" \
  --match wildcard --method POST --status 200 \
  --body '{"id":"pi_test_123","object":"payment_intent","amount":2000,"currency":"usd","status":"succeeded","client_secret":"pi_test_123_secret_abc","created":1770000200,"charges":{"object":"list","data":[{"id":"ch_test_123","object":"charge","amount":2000,"currency":"usd","status":"succeeded","paid":true}],"has_more":false,"url":"/v1/charges?payment_intent=pi_test_123"}}' \
  --delay 120 --priority 50
```

**Error scenarios** (use `X-APXY-Scenario` header to trigger):

- `card_declined` -- 402 on `POST .../payment_intents/*/confirm`
- `rate_limited` -- 429 on any Stripe path
- `unauthorized` -- 401 on any Stripe path
- `idempotency_conflict` -- 409 on `POST .../payment_intents`

### GitHub (api.github.com)

SSL: `apxy proxy start --ssl-domains api.github.com`

**Pre-built template:** `apxy/mock-templates/github-api/rules.json` (12 rules)

**Quick start (3 key rules):**

```bash
# Get authenticated user
apxy rules mock add --name "github-get-user" \
  --url "https://api.github.com/user" \
  --match exact --method GET --status 200 \
  --body '{"login":"testuser","id":1,"node_id":"MDQ6VXNlcjE=","avatar_url":"https://avatars.githubusercontent.com/u/1?v=4","html_url":"https://github.com/testuser","name":"Test User","email":"test@example.com","public_repos":10,"followers":100,"following":50}' \
  --delay 50 --priority 50

# List user repositories (includes Link pagination header)
apxy rules mock add --name "github-list-repos" \
  --url "https://api.github.com/user/repos*" \
  --match wildcard --method GET --status 200 \
  --body '[{"id":1001,"node_id":"R_kgDOA-test1","name":"alpha-service","full_name":"testuser/alpha-service","private":false,"owner":{"login":"testuser","id":1},"html_url":"https://github.com/testuser/alpha-service","description":"Core service repo","fork":false,"default_branch":"main"},{"id":1002,"node_id":"R_kgDOA-test2","name":"beta-worker","full_name":"testuser/beta-worker","private":true,"owner":{"login":"testuser","id":1},"html_url":"https://github.com/testuser/beta-worker","description":"Worker repo","fork":false,"default_branch":"main"}]' \
  --delay 50 --priority 50

# Create issue -- 201
apxy rules mock add --name "github-create-issue" \
  --url "https://api.github.com/repos/*/*/issues" \
  --match wildcard --method POST --status 201 \
  --body '{"id":2003,"node_id":"I_kwDOA-test3","number":3,"title":"New issue","state":"open","user":{"login":"testuser","id":1},"comments":0,"created_at":"2026-03-05T00:00:00Z","updated_at":"2026-03-05T00:00:00Z"}' \
  --delay 100 --priority 50
```

**Error scenarios** (use `X-APXY-Scenario` header to trigger):

- `unauthorized` -- 401 on any GitHub path
- `not_found` -- 404 on any GitHub path
- `rate_limited` -- 403 with `Retry-After` header
- `validation_failed` -- 422 on issue create
- `issues_disabled` -- 410 on issue create

### OpenAI (api.openai.com)

SSL: `apxy proxy start --ssl-domains api.openai.com`

**Pre-built template:** `apxy/mock-templates/openai/rules.json` (10 rules)

**Quick start (3 key rules):**

```bash
# Chat completion
apxy rules mock add --name "openai-chat" \
  --url "https://api.openai.com/v1/chat/completions" \
  --match exact --method POST --status 200 \
  --body '{"id":"chatcmpl_test123","object":"chat.completion","created":1770001010,"model":"gpt-5.4","choices":[{"index":0,"message":{"role":"assistant","content":"Hello! How can I help you today?"},"finish_reason":"stop"}],"usage":{"prompt_tokens":10,"completion_tokens":8,"total_tokens":18}}' \
  --delay 220 --priority 50

# Embeddings
apxy rules mock add --name "openai-embeddings" \
  --url "https://api.openai.com/v1/embeddings" \
  --match exact --method POST --status 200 \
  --body '{"object":"list","data":[{"object":"embedding","embedding":[0.0023064255,-0.009327292,0.015797347,-0.0077780345,0.0012345678],"index":0}],"model":"text-embedding-3-small","usage":{"prompt_tokens":5,"total_tokens":5}}' \
  --delay 120 --priority 50

# List models
apxy rules mock add --name "openai-models" \
  --url "https://api.openai.com/v1/models" \
  --match exact --method GET --status 200 \
  --body '{"object":"list","data":[{"id":"gpt-5.4","object":"model","created":1770000000,"owned_by":"openai"},{"id":"gpt-5-mini","object":"model","created":1770000000,"owned_by":"openai"},{"id":"gpt-5-nano","object":"model","created":1770000000,"owned_by":"openai"},{"id":"text-embedding-3-small","object":"model","created":1750000000,"owned_by":"openai"}]}' \
  --delay 50 --priority 50
```

**Error scenarios** (use `X-APXY-Scenario` header to trigger):

- `unauthorized` -- 401 invalid API key
- `rate_limited` -- 429 with `Retry-After`
- `server_error` -- 500 internal error
- `invalid_request` -- 400 on chat/embeddings/responses
- `not_found` -- 404 on model retrieval

## Vendors with Inline Templates

These vendors do not have bundled `rules.json` files yet. Use the `apxy rules mock add` commands below to create rules manually.

### Auth0 (*.auth0.com)

SSL: `apxy proxy start --ssl-domains your-tenant.auth0.com`

Replace `your-tenant` with your dev tenant slug.

```bash
# Token endpoint -- returns access_token
apxy rules mock add \
  --name "auth0-token" \
  --url "https://your-tenant.auth0.com/oauth/token" \
  --match exact --method POST --status 200 \
  --body '{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock","token_type":"Bearer","expires_in":86400,"scope":"openid profile email"}'

# Userinfo -- returns profile claims
apxy rules mock add \
  --name "auth0-userinfo" \
  --url "https://your-tenant.auth0.com/userinfo" \
  --match exact --method GET --status 200 \
  --body '{"sub":"auth0|mock-user-1","email":"dev@example.com","email_verified":true,"name":"Mock User"}'

# JWKS -- signing keys for JWT verification
apxy rules mock add \
  --name "auth0-jwks" \
  --url "https://your-tenant.auth0.com/.well-known/jwks.json" \
  --match exact --method GET --status 200 \
  --body '{"keys":[{"kty":"RSA","use":"sig","kid":"mock-key-1","n":"mock-n","e":"AQAB"}]}'

# OpenID configuration discovery
apxy rules mock add \
  --name "auth0-oidc-config" \
  --url "https://your-tenant.auth0.com/.well-known/openid-configuration" \
  --match exact --method GET --status 200 \
  --body '{"issuer":"https://your-tenant.auth0.com/","authorization_endpoint":"https://your-tenant.auth0.com/authorize","token_endpoint":"https://your-tenant.auth0.com/oauth/token","userinfo_endpoint":"https://your-tenant.auth0.com/userinfo","jwks_uri":"https://your-tenant.auth0.com/.well-known/jwks.json","response_types_supported":["code","token","id_token"],"subject_types_supported":["public"],"id_token_signing_alg_values_supported":["RS256"]}'
```

### Twilio (api.twilio.com)

SSL: `apxy proxy start --ssl-domains api.twilio.com`

Replace `ACxxxxxxxx` with your dev Account SID.

```bash
# Create message -- 201 queued
apxy rules mock add \
  --name "twilio-create-message" \
  --url "https://api.twilio.com/2010-04-01/Accounts/*/Messages.json" \
  --match wildcard --method POST --status 201 \
  --body '{"sid":"SMaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","status":"queued","to":"+1234567890","from":"+1987654321","date_created":"Mon, 01 Jan 2026 12:00:00 +0000","uri":"/2010-04-01/Accounts/ACxxxxxxxx/Messages/SMaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.json"}'

# Fetch message -- 200 delivered
apxy rules mock add \
  --name "twilio-get-message" \
  --url "https://api.twilio.com/2010-04-01/Accounts/*/Messages/*.json" \
  --match wildcard --method GET --status 200 \
  --body '{"sid":"SMaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa","status":"delivered","to":"+1234567890","from":"+1987654321","error_code":null,"date_sent":"Mon, 01 Jan 2026 12:00:05 +0000"}'

# Send failure -- 400 invalid phone number (use X-APXY-Scenario: send_failed)
apxy rules mock add \
  --name "twilio-send-failed" \
  --url "https://api.twilio.com/2010-04-01/Accounts/*/Messages.json" \
  --match wildcard --method POST \
  --status 400 \
  --body '{"code":21211,"message":"Invalid To Phone Number","status":400}' \
  --priority 10
```

### AWS S3 (*.s3.amazonaws.com)

SSL: `apxy proxy start --ssl-domains s3.amazonaws.com`

For virtual-hosted-style buckets, add those hostnames too (e.g. `my-bucket.s3.amazonaws.com`).

```bash
# PUT object -- 200 upload success
apxy rules mock add \
  --name "s3-put-object" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard --method PUT --status 200 \
  --body '<?xml version="1.0" encoding="UTF-8"?><CopyObjectResult><ETag>&quot;mock-etag-abc123&quot;</ETag></CopyObjectResult>'

# GET object -- 200 download
apxy rules mock add \
  --name "s3-get-object" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard --method GET --status 200 \
  --body '{"mock":"This stands in for object bytes; use raw text or base64 per your client tests."}'

# NoSuchKey -- 404 (use X-APXY-Scenario: missing_key)
apxy rules mock add \
  --name "s3-nosuchkey" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard --method GET \
  --status 404 \
  --body '<?xml version="1.0" encoding="UTF-8"?><Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>missing.bin</Key><RequestId>MOCKREQUESTID</RequestId><HostId>mockhostid</HostId></Error>' \
  --priority 10

# DELETE object -- 204
apxy rules mock add \
  --name "s3-delete-object" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard --method DELETE --status 204 --body ""

# List all buckets -- 200 XML
apxy rules mock add \
  --name "s3-list-buckets" \
  --url "https://s3.amazonaws.com/" \
  --match exact --method GET --status 200 \
  --body '<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>mock-owner</ID><DisplayName>mock</DisplayName></Owner><Buckets><Bucket><Name>my-bucket</Name><CreationDate>2026-01-01T00:00:00.000Z</CreationDate></Bucket></Buckets></ListAllMyBucketsResult>'
```

### Firebase (*.googleapis.com)

SSL: `apxy proxy start --ssl-domains identitytoolkit.googleapis.com,firestore.googleapis.com`

```bash
# Sign in with password -- 200 with idToken
apxy rules mock add \
  --name "firebase-signin" \
  --url "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword*" \
  --match wildcard --method POST --status 200 \
  --body '{"kind":"identitytoolkit#VerifyPasswordResponse","localId":"mock-local-id","email":"dev@example.com","idToken":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.mock","refreshToken":"mock-refresh-token","expiresIn":"3600","registered":true}'

# Sign up -- 200 new user
apxy rules mock add \
  --name "firebase-signup" \
  --url "https://identitytoolkit.googleapis.com/v1/accounts:signUp*" \
  --match wildcard --method POST --status 200 \
  --body '{"kind":"identitytoolkit#SignupNewUserResponse","localId":"mock-new-user","idToken":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.mock-new","refreshToken":"mock-refresh-new","expiresIn":"3600"}'

# Firestore get document -- 200
apxy rules mock add \
  --name "firestore-get-doc" \
  --url "https://firestore.googleapis.com/v1/projects/*/databases/(default)/documents/users/*" \
  --match wildcard --method GET --status 200 \
  --body '{"name":"projects/mock-project/databases/(default)/documents/users/mock-doc","fields":{"title":{"stringValue":"Mock Title"},"count":{"integerValue":"42"}},"createTime":"2026-01-01T00:00:00.000000Z","updateTime":"2026-01-01T00:00:00.000000Z"}'

# Firestore runQuery -- 200 single document result
apxy rules mock add \
  --name "firestore-runquery" \
  --url "https://firestore.googleapis.com/v1/projects/*/databases/(default)/documents:runQuery*" \
  --match wildcard --method POST --status 200 \
  --body '[{"document":{"name":"projects/mock-project/databases/(default)/documents/items/item1","fields":{"name":{"stringValue":"alpha"}},"createTime":"2026-01-01T00:00:00Z","updateTime":"2026-01-01T00:00:00Z"}}]'
```

### Shopify (*.myshopify.com)

SSL: `apxy proxy start --ssl-domains your-store.myshopify.com`

Replace `your-store` with your dev shop subdomain. Adjust API version (`2024-01`) to match your client.

```bash
# Products query -- 200 with product connection
apxy rules mock add \
  --name "shopify-products" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact --method POST --status 200 \
  --body '{"data":{"products":{"edges":[{"node":{"id":"gid://shopify/Product/100","title":"Mock Tee","handle":"mock-tee","priceRange":{"minVariantPrice":{"amount":"19.99","currencyCode":"USD"}}}}]}}}'

# Cart create (use X-APXY-Scenario: cart_create)
apxy rules mock add \
  --name "shopify-cart-create" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact --method POST --status 200 \
  --body '{"data":{"cartCreate":{"cart":{"id":"gid://shopify/Cart/mock-cart-id","checkoutUrl":"https://your-store.myshopify.com/cart/c/mock-cart-id","lines":{"edges":[]}},"userErrors":[]}}}' \
  --priority 10

# GraphQL throttled error (use X-APXY-Scenario: throttled)
apxy rules mock add \
  --name "shopify-throttled" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact --method POST --status 200 \
  --body '{"errors":[{"message":"Throttled","extensions":{"code":"THROTTLED"}}]}' \
  --priority 10

# Cart mutation userErrors (use X-APXY-Scenario: cart_line_error)
apxy rules mock add \
  --name "shopify-cart-error" \
  --url "https://your-store.myshopify.com/api/2024-01/graphql.json" \
  --match exact --method POST --status 200 \
  --body '{"data":{"cartLinesAdd":{"cart":null,"userErrors":[{"field":["lines","0","quantity"],"message":"Quantity must be positive"}]}}}' \
  --priority 10
```

**Note:** Shopify Storefront API funnels all operations through a single GraphQL endpoint. Use `X-APXY-Scenario` headers or priorities to branch between query and mutation responses. For larger setups, maintain a `rules.json` file and import with `apxy rules mock import --file rules.json`.
