# Decoding Protobuf API Traffic

gRPC and Protobuf-backed REST endpoints often ship bodies as binary on the wire. APXY captures those bytes; this walkthrough shows how to see the opaque blob in logs, register your `.proto`, decode wire-format fields into structured JSON, and hunt for the values you care about.

**Difficulty**: Advanced | **Time**: ~15 minutes | **Features used**: Protobuf decoding, Traffic inspection, SSL interception | **Requires**: Free

## Scenario

Your backend uses gRPC or Protobuf-encoded REST APIs. When you capture traffic, request and response bodies look like garbled binary or hex dumps in the inspector. You need a repeatable way to turn those payloads into something your team (and your coding agent) can read—without standing up a separate decoder toolchain for every capture session.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for the domains in this example:

**Tell your agent:**

> "Start APXY with SSL enabled for api.myapp.com"

**Your agent runs:**

```bash
apxy start --ssl-domains api.myapp.com
```

If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first.

---

## Track A: Agent + CLI Workflow

### Step 1: Start the proxy and capture Protobuf traffic

**Tell your agent:**

> "Proxy is up with SSL for api.myapp.com. I'll drive the client (mobile app, backend job, or browser) so traffic to that host flows through APXY."

Point the client at the system HTTP/HTTPS proxy APXY exposes. Trigger calls that hit your Protobuf or gRPC-style endpoints (for example `POST /v2/orders/status` with `Content-Type: application/x-protobuf` or `application/grpc`).

### Step 2: Find the record and confirm the body looks binary

**Tell your agent:**

> "Search recent traffic for my Protobuf order endpoint and show the newest matching record in full."

**Your agent runs:**

```bash
apxy logs search --query "api.myapp.com/v2/orders" --limit 5
```

Pick a record ID from the list (below we use `a1b2c3d4` as a placeholder—replace with your real ID).

**Tell your agent:**

> "Show record a1b2c3d4 so we can see request and response bodies."

**Your agent runs:**

```bash
apxy logs show --id a1b2c3d4
```

**Example (abbreviated) — what the agent highlights**

```text
GET https://api.myapp.com/v2/orders/status
Status: 200
Response Content-Type: application/x-protobuf

Response body (binary, 187 bytes):
0a124f52442d3838343231...  (hex / non-printable — not human-readable JSON)
```

That confirms you are dealing with encoded Protobuf rather than plain JSON.

### Step 3: Decode in the Web UI

The CLI has no Protobuf decoder. Note the record ID from Step 2 and continue with Track B: register your `.proto` file and decode the record in the Web UI. To narrow many captures down first, have your agent search:

```bash
apxy logs search --query "checkout" --limit 10
```

---

## Track B: Web UI Workflow

### Step 1: Register schemas (Analysis & Tools → Protobuf)

Open **http://localhost:8082** (or the port shown when you started the proxy). In the sidebar, go to **Analysis & Tools → Protobuf**. Upload the same **`.proto`** file you use in Track A (`./protos/orders.proto`). The decode dialog will remind you to do this first if no schemas are registered.

> screenshots/01-web-protobuf-schema-upload.png

### Step 2: Open Traffic

Go to **Traffic**. Scan the table for calls to **api.myapp.com** and your Protobuf paths (for example `/v2/orders/status`).

> screenshots/02-traffic-protobuf-rows.png

### Step 3: Inspect request and response

Click a row. Open the **Request** tab: headers should show `Content-Type` values such as `application/x-protobuf` or gRPC content types. Switch to the **Response** tab: the body may appear as hex, “binary”, or a non-printable blob—same symptom as Track A.

> screenshots/03-protobuf-response-binary.png

### Step 4: Decode Protobuf from the record

Open the row actions menu on the traffic detail view. Choose **Decode Protobuf** (this entry appears when the content type looks like Protobuf or gRPC). In the dialog, pick **Request** or **Response** scope, then click **Decode**. The panel shows the decoded fields.

> screenshots/04-decode-protobuf-dialog.png

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — Why Protobuf bodies look binary in capture tools
- 2:00 — SSL for api.myapp.com and reproducing a Protobuf call
- 5:00 — Finding the record with `apxy logs show`
- 9:00 — Registering `.proto` and mapping field numbers to names
- 12:00 — Web UI: Traffic → Response → Decode Protobuf

---

## What You Learned

- Recognizing Protobuf and gRPC traffic from `Content-Type` and non-printable bodies in **`apxy logs show`**
- Registering `.proto` files under **Analysis & Tools → Protobuf** in the Web UI
- Turning wire bytes into readable fields with **Decode Protobuf** on a traffic record
- Combining **`apxy logs search`** with decode to filter many captures down to the one message you need

---

## Next Steps

- [Extracting Specific Data from API Responses](../extract-data-with-jsonpath/) — Once JSON is back on the wire, pull single fields with JSONPath
- [Debugging GraphQL APIs](../../debugging/debug-graphql/) — Similar “big payload, one field” workflow for GraphQL JSON
