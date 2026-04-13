# Debugging Traffic from Docker Containers

Route container egress through APXY on the host so inter-service HTTPS shows up as normal captured traffic—no more “invisible” Docker bridge calls.

**Difficulty**: Intermediate | **Time**: ~15 minutes | **Features used**: Traffic capture, Traffic inspection, Filter rules, SSL interception | **Requires**: Free

## Scenario

You run microservices with `docker compose`. Service **A** calls **B** at `https://internal-api:8443` or a public hostname; packets stay on the Docker network and never touch your laptop’s browser proxy. For debugging, you need those HTTP clients inside containers to use an HTTP forward proxy on the host (`host.docker.internal` on Docker Desktop, or the host gateway on Linux) so APXY records method, URL, TLS metadata, and bodies the same way it does for local apps.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux with Docker
- AI coding agent with APXY skill installed

## Before You Start

Start the proxy with SSL enabled for **each HTTPS hostname** your containers call (hostnames differ per image and compose file).

**Tell your agent:**

> "Start APXY with SSL enabled for every HTTPS hostname my containers use—for example api.myapp.com and internal-api."

**Your agent runs:**

```bash
apxy start --ssl-domains api.myapp.com,internal-api
```

Replace the list with real hostnames from your `docker-compose.yml` or service URLs. If you haven't set up APXY's CA certificate yet, see [SSL Setup Guide](../../getting-started/ssl-setup-guide/) first. Containers must trust APXY’s CA for TLS interception—mount or install the CA cert inside images that perform HTTPS (advanced; often done via custom image or compose volume).

---

## Track A: Agent + CLI Workflow

### Step 1: Note host proxy port

**Tell your agent:**

> "What port is APXY listening on for the forward proxy? Default 8080 unless we changed it."

**Your agent runs:**

```bash
apxy status
```

Agent reports the **HTTP proxy** listen address (e.g. `127.0.0.1:8080`). Containers cannot use `127.0.0.1` for the host; they use `host.docker.internal` (Mac/Win Docker Desktop) or `172.17.0.1` / `host-gateway` (Linux).

### Step 2: Start a one-off container with proxy env vars

**Tell your agent:**

> "Run my service image with HTTP_PROXY and HTTPS_PROXY pointing at the host proxy."

**Your agent runs:**

```bash
docker run --rm \
  -e HTTP_PROXY=http://host.docker.internal:8080 \
  -e HTTPS_PROXY=http://host.docker.internal:8080 \
  -e NO_PROXY=localhost,127.0.0.1 \
  myservice:latest
```

On Linux, replace `host.docker.internal` with:

```bash
docker run --rm \
  --add-host=host.docker.internal:host-gateway \
  -e HTTP_PROXY=http://host.docker.internal:8080 \
  -e HTTPS_PROXY=http://host.docker.internal:8080 \
  myservice:latest
```

Some stacks need lowercase `http_proxy` / `https_proxy` as well—set both if libraries ignore uppercase.

### Step 3: Generate traffic between containers

**Tell your agent:**

> "I'll hit an endpoint that causes the container to call internal-api or api.myapp.com."

Trigger the code path that performs the HTTP client call.

### Step 4: List recent captures

**Tell your agent:**

> "List the latest captured traffic."

**Your agent runs:**

```bash
apxy logs list --limit 25
```

Agent shows rows whose host matches your external API or internal hostname, proving egress went through the proxy.

### Step 5: Search for internal service host

**Tell your agent:**

> "Search for internal-api or our service name in URLs."

**Your agent runs:**

```bash
apxy logs search --query "internal-api"
```

Adjust the query to match your compose service DNS name or public host.

### Step 6: Inspect a problematic call

**Tell your agent:**

> "Show the full record for the failing call id."

**Your agent runs:**

```bash
apxy logs show --id <ID>
```

### Step 7: Compose docker-compose snippet (optional)

**Tell your agent:**

> "Add environment variables to docker-compose for all services that use HTTP clients."

Example fragment (illustrative):

```yaml
services:
  worker:
    environment:
      HTTP_PROXY: http://host.docker.internal:8080
      HTTPS_PROXY: http://host.docker.internal:8080
      NO_PROXY: postgres,redis
    extra_hosts:
      - "host.docker.internal:host-gateway"
```

(Linux `extra_hosts` as needed.)

---

## Track B: Web UI Workflow

### Step 1: Confirm proxy up

**http://localhost:8082** — dashboard shows proxy running before containers start sending traffic.

> screenshots/01-dashboard-docker-debug.png

### Step 2: Traffic from containers

Go to **Traffic**. Run your workload; rows should appear for URLs your containers call (not only browser traffic).

> screenshots/02-traffic-from-containers.png

### Step 3: Filter by host

Identify host column entries matching `internal-api` or `api.myapp.com`.

> screenshots/03-filter-by-host.png

### Step 4: Inspect TLS and timing

**Traffic** -> click a row -> **Request** / **Response** / **Timing** tabs. Confirm **TLS** was intercepted (if applicable), inspect **Timing** for DNS/connect issues common in container egress setups.

> screenshots/04-container-request-detail.png

### Step 5: Verify NO_PROXY behavior

If some calls must bypass the proxy, confirm they do not appear in APXY (or appear as direct—depending on client).

> screenshots/05-direct-vs-proxied.png

---

## Video Walkthrough

*[Link TBD]*

- 0:00 — `host.docker.internal` vs Linux `host-gateway`
- 3:00 — `HTTP_PROXY` / `HTTPS_PROXY` for common runtimes
- 6:00 — Trusting APXY CA inside images (overview)
- 9:00 — Web UI verification

---

## What You Learned

- Sending Docker egress through APXY with `HTTP_PROXY` and `HTTPS_PROXY`
- Using `host.docker.internal` (and Linux equivalents) to reach the host’s proxy port
- Listing and searching container-generated rows with `apxy logs list` and `search`
- Planning `--ssl-domains` for every hostname containers resolve in HTTPS calls

## Next Steps

- [SSL Setup Guide](../../getting-started/ssl-setup-guide/) — CA trust for TLS inside containers
- [Debug Slow API](../debug-slow-api/) — Profile slow calls once they are visible
- [Basic Debugging](../../basic-debugging/) — Core capture workflow
