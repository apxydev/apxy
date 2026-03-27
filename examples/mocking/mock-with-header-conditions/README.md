# A/B Testing and Feature Flags via Mocks

Serve different checkout experiences from the same URL by matching on a feature-flag header -- control vs experiment without two backends.

**Difficulty**: Intermediate | **Time**: ~10 minutes | **Features used**: Mock rules, Header conditions, SSL interception | **Requires**: Free

## Scenario

Your client sends `X-Feature-Flag: new-checkout` for users in an experiment bucket. Everyone else omits that header. You want `GET https://api.myapp.com/api/checkout` to return layout **v2** with express-pay when the header is present, and layout **v1** for everyone else. APXY evaluates **header conditions** before falling through to the default mock.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- Optional: `127.0.0.1 api.myapp.com` in `/etc/hosts`

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy proxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

> Best for: reproducing experiment-specific bugs your agent can toggle with curl flags.

### Step 1: Add the experiment mock (header required)

Put this rule at **lower** `--priority` (for example `0`) so APXY tries it before the fallback.

**Tell your agent:**

> "Add a GET mock for https://api.myapp.com/api/checkout that only matches when header X-Feature-Flag equals new-checkout, status 200, body describing layout v2."

**Your agent runs:**

```bash
apxy rules mock add --name "checkout-experiment" --url "https://api.myapp.com/api/checkout" --method GET --match exact --priority 0 --header-conditions "X-Feature-Flag=new-checkout" --status 200 --body '{"layout":"v2","features":["express-pay","one-click"]}'
```

Agent reports:

```
Rule created: checkout-experiment (ID: ...)
```

### Step 2: Add the control mock (no header)

**Tell your agent:**

> "Add a second GET mock for the same URL without header conditions, priority 10, returning layout v1."

**Your agent runs:**

```bash
apxy rules mock add --name "checkout-control" --url "https://api.myapp.com/api/checkout" --method GET --match exact --priority 10 --status 200 --body '{"layout":"v1","features":["standard"]}'
```

### Step 3: Prove both paths with curl

**Tell your agent:**

> "Curl checkout without the header, then with X-Feature-Flag: new-checkout, and show both JSON bodies."

**Your agent runs:**

```bash
curl -sS "https://api.myapp.com/api/checkout"
curl -sS -H "X-Feature-Flag: new-checkout" "https://api.myapp.com/api/checkout"
```

Agent shows:

- First response: `layout` **v1**, `features` **["standard"]**
- Second response: `layout` **v2**, `features` **["express-pay","one-click"]**

### Step 4: List rules for documentation

**Your agent runs:**

```bash
apxy rules mock list
```

Agent finds both rules with their `header_conditions` and priorities visible in JSON output.

### Step 5: Negative test -- wrong header value

**Tell your agent:**

> "Curl with X-Feature-Flag: off -- should still get control."

**Your agent runs:**

```bash
curl -sS -H "X-Feature-Flag: off" "https://api.myapp.com/api/checkout"
```

Agent confirms the **v1** body (experiment rule does not match).

---

## Track B: Web UI Workflow

> Best for: pairing product and engineering on flag names and copy.

### Step 1: Start proxy and open UI

```bash
apxy proxy start --ssl-domains api.myapp.com
```

Browse to **http://localhost:8082**.

> screenshots/01-dashboard.png

### Step 2: Create the experiment rule

**Rules → Mock Rules → Create Mock Rule**

- **Name:** `checkout-experiment`
- **URL Pattern:** `https://api.myapp.com/api/checkout`
- **Match Type:** Exact, **Method:** GET
- **Priority:** 0
- **Header conditions** (per UI field layout): `X-Feature-Flag` = `new-checkout`
- **Status:** 200
- **Response Source:** Inline Body
- **Body:** `{"layout":"v2","features":["express-pay","one-click"]}`

Save.

> screenshots/02-mock-checkout-experiment-header.png

### Step 3: Create the control rule

Add another rule with the same URL and method, **no** header conditions, **Priority** 10, and the v1 JSON body.

> screenshots/03-mock-checkout-control-fallback.png

### Step 4: Optional -- use Compose or external client

If your Web UI offers **Compose** or a replay tool, send two requests differing only by the flag header and compare responses in **Traffic**.

> screenshots/04-traffic-checkout-ab.png

### Step 5: Cleanup

```bash
apxy stop
```

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- CLI: `--header-conditions` and priority ordering
- Web UI: dual rules on one URL

---

## What You Learned

- How `--header-conditions` uses `Name=value` pairs (comma-separated for multiple headers, or JSON)
- Why **priority** matters when several rules share the same URL
- How to validate **control vs experiment** with simple `curl -H` variants
- How the same model maps to **Mock Rules** in the Web UI

## Next Steps

- [Building UI Without a Backend](../mock-backend-for-frontend/) -- REST shapes and delays
- [Testing Error Handling in Your UI](../mock-error-states/) -- status-code sweeps
- [Generating Mocks from an OpenAPI Spec](../mock-from-openapi-spec/) -- contract-aligned payloads
- [AI Agent Workflow](../../ai-agent-workflow/) -- deeper agent-driven debugging
