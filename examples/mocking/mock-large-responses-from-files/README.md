# Serving Mock Responses from Files

Return multi-hundred-line JSON from files on disk instead of pasting megabytes into the terminal (optional **Directory (Map Local)** in the Web UI for wildcard trees).

**Difficulty**: Beginner | **Time**: ~5 minutes | **Features used**: Mock rules, File-based responses, SSL interception | **Requires**: Free

## Scenario

Your product catalog and remote-config endpoints return **large JSON** documents. Pasting them into `--body` is fragile and blows up shell history. You will store fixtures under `./fixtures/`, then point APXY at a **file path** for each heavy endpoint (for example `GET /api/products` and `GET /api/config/bundle`). The CLI command `apxy rules mock add` supports **inline** bodies only; **file** (and **directory**) response sources are available from the **Web UI** and the **HTTP API**, so Track A uses `curl` against the local Web UI API for file-backed rules.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed
- Create fixtures before you begin, for example:
  - `./fixtures/products.json` -- large array of products
  - `./fixtures/config-bundle.json` -- large config document

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

> Best for: automation-friendly JSON posts to `http://localhost:8082/api/v1/mock-rules`.

### Step 1: Create fixture files

**Tell your agent:**

> "Create fixtures/products.json and fixtures/config-bundle.json with realistic large JSON."

**Your agent runs:**

```bash
mkdir -p fixtures
printf '%s\n' '{"products":[...]}' > fixtures/products.json
printf '%s\n' '{"theme":"dark","feature_flags":{...}}' > fixtures/config-bundle.json
```

(Replace with your real data.)

### Step 2: Map GET /api/products to a single file

Paths must be readable by the APXY process (**absolute paths** are safest).

**Tell your agent:**

> "POST a mock rule to the Web API that serves fixtures/products.json for GET https://api.myapp.com/api/products"

**Your agent runs** (replace `ABS_PRODUCTS` with the real absolute path to `fixtures/products.json`):

```bash
ABS_PRODUCTS="$(pwd)/fixtures/products.json"
curl -sS -X POST "http://localhost:8082/api/v1/mock-rules" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"products-file\",\"url_pattern\":\"https://api.myapp.com/api/products\",\"match_type\":\"exact\",\"method\":\"GET\",\"status\":200,\"file_path\":\"$ABS_PRODUCTS\"}"
```

Agent shows:

```json
{"result":"Rule created: products-file (ID: ...)"}
```

### Step 3: Map GET /api/config/bundle to a second file

**Tell your agent:**

> "POST another mock rule that serves config-bundle.json for GET https://api.myapp.com/api/config/bundle"

**Your agent runs:**

```bash
ABS_CFG="$(pwd)/fixtures/config-bundle.json"
curl -sS -X POST "http://localhost:8082/api/v1/mock-rules" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"config-bundle-file\",\"url_pattern\":\"https://api.myapp.com/api/config/bundle\",\"match_type\":\"exact\",\"method\":\"GET\",\"status\":200,\"file_path\":\"$ABS_CFG\"}"
```

### Step 4: Verify with curl

**Tell your agent:**

> "Curl both endpoints through the proxy and show the first 200 bytes of each response."

**Your agent runs:**

```bash
curl -sS "https://api.myapp.com/api/products" | head -c 200
curl -sS "https://api.myapp.com/api/config/bundle" | head -c 200
```

Agent shows the start of each file-backed JSON body.

### Step 5: List rules via CLI

**Tell your agent:**

> "List all mock rules and confirm the file-backed rules are present."

**Your agent runs:**

```bash
apxy rules mock list
```

Agent finds rules listing `file_path` (and `dir_path` if you add directory-backed rules) in the JSON output.

### Alternative: inline body from file without the API

If you only need a one-off and the payload fits in argv limits, your agent can still run:

```bash
BODY=$(cat ./fixtures/products.json)
apxy rules mock add --name "products-inline" --url "https://api.myapp.com/api/products" --method GET --match exact --status 200 --body "$BODY"
```

Prefer **file_path** via the API or Web UI when the document is large or shared with other tools.

---

## Track B: Web UI Workflow

> Best for: browsing the filesystem with **Map Local** pickers.

### Step 1: Open Mock Rules

```bash
apxy proxy start --ssl-domains api.myapp.com
```

Go to **http://localhost:8082** → **Rules → Mock Rules**.

> screenshots/01-mock-rules-page.png

### Step 2: File-backed catalog rule

**Create Mock Rule**

- **Name:** `products-file`
- **URL Pattern:** `https://api.myapp.com/api/products`
- **Match Type:** Exact, **Method:** GET
- **Response Source:** **File (Map Local)**
- Choose **Browse** and select `fixtures/products.json`

Save.

> screenshots/02-response-source-file.png

### Step 3: Second file-backed rule

Add **config-bundle-file** for `https://api.myapp.com/api/config/bundle`, **Response Source:** **File (Map Local)**, path `fixtures/config-bundle.json`.

> screenshots/03-mock-config-bundle-file.png

### Step 4 (optional): Directory (Map Local)

The dialog also offers **Directory (Map Local)** for wildcard URLs when you want many paths served from one folder tree. Layout and path resolution depend on your APXY version; if responses 404, read the `file not found` text in **Traffic** and align on-disk paths with what the proxy attempted.

> screenshots/03b-response-source-directory.png

### Step 5: Confirm in Traffic

Trigger requests from your app or from a terminal; open **Traffic** and confirm responses are **Mocked** and bodies match file contents.

> screenshots/04-traffic-large-mock.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- REST API `curl` with `file_path`
- Web UI **File (Map Local)** (and optional **Directory (Map Local)**)

---

## What You Learned

- When to prefer **fixtures on disk** over inline CLI strings
- How to create **file_path** rules via **POST /api/v1/mock-rules** with absolute paths
- How **Response Source → File (Map Local)** in **Create Mock Rule** maps to the same field
- A shell fallback: `--body "$(cat file)"` for medium-sized JSON
- Where **Directory (Map Local)** fits for advanced wildcard layouts

## Next Steps

- [Building UI Without a Backend](../mock-backend-for-frontend/) -- REST layout and priorities
- [Generating Mocks from an OpenAPI Spec](../mock-from-openapi-spec/) -- contract validation
- [Testing Error Handling in Your UI](../mock-error-states/) -- status-code coverage
- [Web UI Tour](../../getting-started/web-ui-tour/) -- full product orientation
