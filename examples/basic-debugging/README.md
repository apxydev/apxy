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

### 4. Analyze with SQL

```bash
# Count requests by status code
apxy sql query "SELECT status_code, COUNT(*) FROM traffic_logs GROUP BY status_code"

# Find the slowest request
apxy sql query "SELECT method, url, duration_ms FROM traffic_logs ORDER BY duration_ms DESC LIMIT 1"
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
