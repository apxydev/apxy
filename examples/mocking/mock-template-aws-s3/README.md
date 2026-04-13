# Mocking AWS S3 Operations

Develop upload, download, list, and delete flows against `s3.amazonaws.com` (or path-style URLs) without IAM keys or a live bucket. APXY returns XML or empty bodies that resemble S3's REST responses so your SDK or signed requests still exercise your code paths offline.

**Difficulty**: Advanced | **Time**: ~35 minutes | **Features used**: Mock rules, Mock templates, SSL interception | **Requires**: Free

## Scenario

Your application uses the S3 REST API: `PUT` objects, `GET` objects, `HEAD` for existence, `DELETE`, and `GET` on the bucket root for list-bucket results. You want deterministic errors such as `NoSuchKey` and `AccessDenied` for unhappy-path tests. There is no official `mock-templates/aws-s3/` bundle in-repo; compose rules with **`apxy mock add`** using wildcard URLs for bucket and key segments.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for s3.amazonaws.com"

**Your agent runs:**

```bash
apxy start --ssl-domains s3.amazonaws.com
```

If you use **virtual-hosted-style** buckets (`my-bucket.s3.amazonaws.com`), add those hostnames to `--ssl-domains` as well. If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

### What you will mock

| Operation | Typical request | Mock idea |
|-----------|-----------------|-----------|
| Upload | `PUT /bucket/key` | `200` / `204` with optional CopyObject-style XML |
| Download | `GET /bucket/key` | Object bytes or error XML |
| List bucket | `GET /bucket?list-type=2` | `ListBucketResult` XML |
| Delete | `DELETE /bucket/key` | `204` |
| Head | `HEAD /bucket/key` | `200` empty or `404` |
| Errors | — | `NoSuchKey`, `AccessDenied` XML bodies |

---

## Track A: Agent + CLI Workflow

> Adjust bucket name `my-bucket` and key paths to match your tests. S3 responses are often XML; keep bodies on one line in shell or use a `rules.json` file for readability.

### Step 1: Mock successful PUT (upload)

Tell your agent:

> "Add a PUT mock for object uploads to my-bucket with wildcard key."

Your agent runs:

```bash
apxy mock add \
  --name "S3: PUT object success" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard \
  --method PUT \
  --status 200 \
  --body '<?xml version="1.0" encoding="UTF-8"?><CopyObjectResult><ETag>&quot;mock-etag-abc123&quot;</ETag></CopyObjectResult>'
```

Plain PUT object often returns minimal XML or an `ETag` header only; your SDK may only check status—tune the body to match what your client parses.

### Step 2: Mock GET object

Tell your agent:

> "Add GET mock returning mock file contents."

Your agent runs:

```bash
apxy mock add \
  --name "S3: GET object" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard \
  --method GET \
  --status 200 \
  --body '{"mock":"This stands in for object bytes; use raw text or base64 per your client tests."}'
```

For true binary fidelity, prefer importing `rules.json` with escaped content or return short `text/plain` bodies.

### Step 3: Mock NoSuchKey

Tell your agent:

> "Add GET rule with X-APXY-Scenario missing_key returning 404 S3 error XML."

Your agent runs:

```bash
apxy mock add \
  --name "S3: NoSuchKey" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard \
  --method GET \
  --header-conditions "X-APXY-Scenario=missing_key" \
  --status 404 \
  --body '<?xml version="1.0" encoding="UTF-8"?><Error><Code>NoSuchKey</Code><Message>The specified key does not exist.</Message><Key>missing.bin</Key><RequestId>MOCKREQUESTID</RequestId><HostId>mockhostid</HostId></Error>'
```

### Step 4: Mock AccessDenied

Tell your agent:

> "Add GET rule for access_denied scenario returning 403 XML."

Your agent runs:

```bash
apxy mock add \
  --name "S3: AccessDenied" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard \
  --method GET \
  --header-conditions "X-APXY-Scenario=access_denied" \
  --status 403 \
  --body '<?xml version="1.0" encoding="UTF-8"?><Error><Code>AccessDenied</Code><Message>Access Denied</Message><RequestId>MOCKREQUESTID2</RequestId><HostId>mockhostid2</HostId></Error>'
```

### Step 5: List buckets (GET /)

Tell your agent:

> "Add GET on root listing buckets."

Your agent runs:

```bash
apxy mock add \
  --name "S3: list all buckets" \
  --url "https://s3.amazonaws.com/" \
  --match exact \
  --method GET \
  --status 200 \
  --body '<?xml version="1.0" encoding="UTF-8"?><ListAllMyBucketsResult xmlns="http://s3.amazonaws.com/doc/2006-03-01/"><Owner><ID>mock-owner</ID><DisplayName>mock</DisplayName></Owner><Buckets><Bucket><Name>my-bucket</Name><CreationDate>2026-01-01T00:00:00.000Z</CreationDate></Bucket></Buckets></ListAllMyBucketsResult>'
```

### Step 6: HEAD and DELETE

Tell your agent:

> "Add HEAD returning 200 empty and DELETE returning 204."

Your agent runs:

```bash
apxy mock add \
  --name "S3: HEAD object" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard \
  --method HEAD \
  --status 200 \
  --body ""

apxy mock add \
  --name "S3: DELETE object" \
  --url "https://s3.amazonaws.com/my-bucket/*" \
  --match wildcard \
  --method DELETE \
  --status 204 \
  --body ""
```

### Step 7: Curl checks

Tell your agent:

> "PUT and GET an object through the proxy."

Your agent runs:

```bash
curl -s -o /dev/null -w "%{http_code}\n" -X PUT "https://s3.amazonaws.com/my-bucket/test.txt" -d "hello"
curl -s "https://s3.amazonaws.com/my-bucket/test.txt"
```

Signed requests from AWS SDKs still hit the same hostnames—ensure the proxy is active and SSL trust is configured.

### Step 8: List and remove rules

**Tell your agent:**

> "List all mock rules and remove an S3 rule by id."

**Your agent runs:**

```bash
apxy mock list
apxy mock remove --id <RULE_ID>
```

---

## Track B: Web UI Workflow

### Step 1: Proxy + Web UI

Start with `s3.amazonaws.com` (and virtual hostnames if needed). Open **http://localhost:8082**.

> screenshots/01-dashboard-s3-mock.png

### Step 2: Upload row

Issue a `PUT`. Inspect method, path, and response XML in the detail view.

> screenshots/02-s3-put-object.png

### Step 3: Download vs error

Compare a normal `GET` with a `GET` that sends `X-APXY-Scenario: missing_key`.

> screenshots/03-s3-get-vs-nosuchkey.png

### Step 4: List buckets

Trigger `GET https://s3.amazonaws.com/` and verify `ListAllMyBucketsResult` in the response body.

> screenshots/04-s3-list-buckets.png

---

## Video Walkthrough

Watch the full walkthrough: *[YouTube link -- coming soon]*

- PUT/GET/HEAD/DELETE wiring: 0:00 - 12:00
- XML errors + virtual-hosted buckets: 12:00 - 26:00

---

## What You Learned

- How to mock core S3 verbs with wildcard paths per bucket
- How to return AWS-shaped XML for errors (`NoSuchKey`, `AccessDenied`)
- Why virtual-hosted bucket hostnames may need extra `--ssl-domains` entries
- How to validate requests in the Web UI when debugging SDK signing issues

## Next Steps

- Capture one real S3 response with APXY, then trim it into a static mock
- Add multipart upload parts if your app uses chunked uploads
- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) -- trust CA on additional machines
- [Replay and Diff](../../replay-and-diff/) -- compare mock vs captured real S3 traffic
- [API Mocking](../../api-mocking/) -- generic patterns
