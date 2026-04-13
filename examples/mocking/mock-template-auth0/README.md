# Mocking Auth0 Authentication

Exercise login, token exchange, JWKS fetching, and OIDC discovery against fixed JSON while your app still targets your Auth0 tenant hostname. There is **no** first-party `mock-templates/auth0/rules.json` in the core repo yet; you either author rules locally or pull a community pack when one is published.

**Difficulty**: Advanced | **Time**: ~35 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

Your stack depends on Auth0 for OAuth2/OIDC: `POST /oauth/token` for tokens, `GET /userinfo` for profiles, `GET /.well-known/jwks.json` for key material, and `GET /.well-known/openid-configuration` for metadata. You want local development and automated tests that do not call Auth0's cloud or require a live tenant secret rotation. APXY can terminate TLS for `your-tenant.auth0.com` and return canned responses for each path. This guide shows **`apxy mock add`** invocations you can paste and tune; you can also maintain a single `rules.json` and use `apxy mock import --file` once the file exists.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example. Replace `your-tenant` with your dev tenant slug (or a fictional one if you only need string matching).

**Tell your agent:**

> "Start APXY with SSL enabled for your-tenant.auth0.com"

**Your agent runs:**

```bash
apxy start --ssl-domains your-tenant.auth0.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

**Template status:** Auth0 is a **community / bring-your-own-rules** example. Options:

1. Create `rules.json` beside this README (array of rule objects) and `apxy mock import --file ./rules.json`.
2. Watch [apxy-public](https://github.com/apxydev/apxy-public) for a shared Auth0 template and download it when available.

### What you will mock

| Endpoint | Typical use |
|----------|-------------|
| `POST /oauth/token` | Client credentials, refresh token, password grant (dev only) |
| `GET /userinfo` | Profile claims for the access token |
| `GET /.well-known/jwks.json` | Signing keys for JWT verification |
| `GET /.well-known/openid-configuration` | Issuer, endpoints, scopes |
| Errors | e.g. `invalid_grant`, `access_denied` via scenario headers or separate rules |

---

## Track A: Agent + CLI Workflow

> Replace `your-tenant` in every URL below. Use `--match exact` or `wildcard` consistently with how your SDK constructs URLs.

### Step 1: Mock token endpoint (success)

Tell your agent:

> "Add a mock POST rule for the Auth0 oauth token URL returning a JSON access_token."

Your agent runs:

```bash
apxy mock add \
  --name "Auth0: token success" \
  --url "https://your-tenant.auth0.com/oauth/token" \
  --match exact \
  --method POST \
  --status 200 \
  --body '{"access_token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock","token_type":"Bearer","expires_in":86400,"scope":"openid profile email"}'
```

### Step 2: Mock userinfo

Tell your agent:

> "Add GET userinfo returning mock claims."

Your agent runs:

```bash
apxy mock add \
  --name "Auth0: userinfo" \
  --url "https://your-tenant.auth0.com/userinfo" \
  --match exact \
  --method GET \
  --status 200 \
  --body '{"sub":"auth0|mock-user-1","email":"dev@example.com","email_verified":true,"name":"Mock User"}'
```

### Step 3: Mock JWKS

Tell your agent:

> "Add GET jwks.json with a minimal single-key JWKS."

Your agent runs:

```bash
apxy mock add \
  --name "Auth0: JWKS" \
  --url "https://your-tenant.auth0.com/.well-known/jwks.json" \
  --match exact \
  --method GET \
  --status 200 \
  --body '{"keys":[{"kty":"RSA","use":"sig","kid":"mock-key-1","n":"mock-n","e":"AQAB"}]}'
```

Use a real JWKS exported from your tenant if your verifier compares `kid` and modulus.

### Step 4: Mock OpenID configuration

Tell your agent:

> "Add openid-configuration discovery document pointing back to the same tenant host."

Your agent runs:

```bash
apxy mock add \
  --name "Auth0: OIDC discovery" \
  --url "https://your-tenant.auth0.com/.well-known/openid-configuration" \
  --match exact \
  --method GET \
  --status 200 \
  --body '{"issuer":"https://your-tenant.auth0.com/","authorization_endpoint":"https://your-tenant.auth0.com/authorize","token_endpoint":"https://your-tenant.auth0.com/oauth/token","userinfo_endpoint":"https://your-tenant.auth0.com/userinfo","jwks_uri":"https://your-tenant.auth0.com/.well-known/jwks.json","response_types_supported":["code","token","id_token"],"subject_types_supported":["public"],"id_token_signing_alg_values_supported":["RS256"]}'
```

### Step 5: Invalid grant error

Tell your agent:

> "Add a higher-priority POST oauth/token rule that triggers when X-APXY-Scenario is invalid_grant."

Your agent runs:

```bash
apxy mock add \
  --name "Auth0: invalid_grant" \
  --url "https://your-tenant.auth0.com/oauth/token" \
  --match exact \
  --method POST \
  --header-conditions "X-APXY-Scenario=invalid_grant" \
  --status 403 \
  --body '{"error":"invalid_grant","error_description":"Grant expired or revoked"}'
```

Give this rule a **higher priority** (lower numeric conflict — check `apxy mock add --help` for `--priority`) than the success rule so the scenario wins when the header is present.

### Step 6: Access denied (JSON error body)

Tell your agent:

> "Add a rule that returns access_denied when X-APXY-Scenario is access_denied on the token endpoint."

Your agent runs:

```bash
apxy mock add \
  --name "Auth0: access_denied" \
  --url "https://your-tenant.auth0.com/oauth/token" \
  --match exact \
  --method POST \
  --header-conditions "X-APXY-Scenario=access_denied" \
  --status 403 \
  --body '{"error":"access_denied","error_description":"The user denied the request"}'
```

Use a distinct URL or grant-type body matcher if you need both `invalid_grant` and `access_denied` on `POST /oauth/token` without ambiguity.

### Step 7: List and manage rules

Tell your agent:

> "List all mock rules and remove one by id."

Your agent runs:

```bash
apxy mock list
apxy mock remove --id <RULE_ID>
```

---

## Track B: Web UI Workflow

### Step 1: SSL + UI

Start the proxy with `your-tenant.auth0.com` in `--ssl-domains`. Open **http://localhost:8082**.

> screenshots/01-dashboard-auth0-mock.png

### Step 2: Run a token request

Use curl or your app to `POST /oauth/token`. Confirm the response body matches your mock token JSON.

> screenshots/02-auth0-token-traffic.png

### Step 3: Discovery chain

Trigger discovery (`openid-configuration`), then JWKS, then userinfo. In **Traffic**, verify order and bodies your SDK caches.

> screenshots/03-auth0-discovery-jwks.png

### Step 4: Error scenario

Repeat token exchange with `X-APXY-Scenario: invalid_grant` and confirm `403` + error JSON in the response tab.

> screenshots/04-auth0-invalid-grant.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- Inline `mock add` for token, userinfo, JWKS, discovery: 0:00 - 12:00
- Priority + scenario errors + Web UI: 12:00 - 24:00

---

## What You Learned

- How to enable TLS interception for a tenant-specific Auth0 hostname
- How to stub the four pillars of OIDC client setup: token, userinfo, JWKS, discovery
- How to layer success vs error responses using header conditions and priorities
- That a shared `rules.json` may land in [apxy-public](https://github.com/apxydev/apxy-public) later for one-command import

## Next Steps

- Export real tenant metadata once, trim secrets, and paste into stable mocks
- Add rules for `/oauth/revoke` or custom API audiences if your app uses them
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- team laptops and CI runners
- [API Mocking](../../api-mocking/) -- general mock patterns
