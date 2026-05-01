# Example: Basic Debugging

Your first proxy session -- capture HTTP traffic and inspect requests.

## Prerequisites

- APXY installed (`apxy version` works)
- macOS or Linux

## Steps

### 1. Start the proxy

```bash
apxy start
```

On macOS, this automatically configures the system proxy. All traffic now flows through APXY.

### 2. Generate some traffic

Open a browser or run curl commands:

```bash
curl https://httpbin.org/get
curl -X POST https://httpbin.org/post -d '{"hello":"world"}'
curl https://httpbin.org/status/404
```

### 3. View captured traffic

```bash
# List recent requests
apxy logs list --limit 10

# Search for specific host
apxy logs search --query "httpbin"

# View detailed info for a specific request
apxy logs show --id <record-id-from-list>
```

### 4. Analyze traffic with jq

```bash
# Count requests by status code
apxy logs list --format json | jq '[group_by(.status_code)[] | {status_code: .[0].status_code, count: length}] | sort_by(-.count)'

# Find the slowest request
apxy logs list --format json | jq 'sort_by(-.duration_ms) | .[0] | {method, url, duration_ms}'
```

### 5. Export a request as cURL

```bash
apxy logs export-curl --id <record-id>
```

This gives you a reproducible curl command you can share with teammates.

### 6. Stop the proxy

```bash
apxy stop
```

## What you learned

- How to start and stop the APXY proxy
- How to capture and list traffic
- How to search and filter requests
- How to use SQL for traffic analysis
- How to export requests as cURL commands
