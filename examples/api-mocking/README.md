# Example: API Mocking

Mock a REST API so your frontend can develop independently of the backend.

## Scenario

You're building a frontend that calls `/api/users` and `/api/users/:id`. The backend isn't ready yet, so you want to mock the responses.

## Prerequisites

- APXY installed and proxy running (`apxy start`)

## Steps

### 1. Create mock rules

```bash
# Mock the user list endpoint
apxy mock add \
  --name "Mock User List" \
  --url "/api/users" \
  --match exact \
  --method GET \
  --status 200 \
  --body '{"users":[{"id":1,"name":"Alice","email":"alice@example.com"},{"id":2,"name":"Bob","email":"bob@example.com"}]}'

# Mock individual user endpoint (regex for any ID)
apxy mock add \
  --name "Mock User Detail" \
  --url "/api/users/\\d+" \
  --match regex \
  --method GET \
  --status 200 \
  --body '{"id":1,"name":"Alice","email":"alice@example.com","role":"admin"}'

# Mock creating a user
apxy mock add \
  --name "Mock Create User" \
  --url "/api/users" \
  --match exact \
  --method POST \
  --status 201 \
  --body '{"id":3,"name":"New User","created":true}'
```

### 2. Verify the mocks are active

```bash
apxy mock list
```

### 3. Test the mocked endpoints

```bash
# List users
curl https://your-api.com/api/users

# Get a specific user
curl https://your-api.com/api/users/42

# Create a user
curl -X POST https://your-api.com/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"New User"}'
```

All these requests return your mocked responses, regardless of what the real server would return.

### 4. Simulate a slow API

```bash
# Add a mock with 2-second delay
apxy mock add \
  --name "Slow Endpoint" \
  --url "/api/slow-data" \
  --match exact \
  --status 200 \
  --body '{"data":"loaded"}' \
  --delay 2000
```

This lets you test loading states and timeout handling in your frontend.

### 5. Clean up

```bash
# Remove a specific rule
apxy mock remove --id <rule-id>

# Or clear all mocks
apxy mock clear
```

## What you learned

- How to create mock rules with exact, wildcard, and regex matching
- How to mock different HTTP methods (GET, POST)
- How to simulate slow APIs with `--delay`
- How to manage (list, remove, clear) mock rules
