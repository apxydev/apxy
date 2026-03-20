# Stripe API Mock Templates

Mock rules for the [Stripe API](https://stripe.com/docs/api).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `https://api.stripe.com/v1/charges` | Create a charge |
| GET | `https://api.stripe.com/v1/charges/*` | Retrieve a charge |
| GET | `https://api.stripe.com/v1/charges*` | List charges |
| POST | `https://api.stripe.com/v1/payment_intents` | Create a payment intent |
| POST | `https://api.stripe.com/v1/payment_intents/*/confirm` | Confirm a payment intent |
| GET | `https://api.stripe.com/v1/payment_intents/*` | Retrieve a payment intent |
| GET | `https://api.stripe.com/v1/payment_intents*` | List payment intents |
| POST | `https://api.stripe.com/v1/customers` | Create a customer |
| GET | `https://api.stripe.com/v1/customers/*` | Retrieve a customer |
| GET | `https://api.stripe.com/v1/customers*` | List customers |

## Usage

```bash
# Add the default create-charge rule
apxy mock add --name "Stripe: Create Charge" \
  --url "https://api.stripe.com/v1/charges" --match exact --method POST \
  --headers "Content-Type=application/json,Request-Id=req_test_stripe_charge" \
  --status 200 --body '{"id":"ch_test_123","object":"charge","amount":2000,"currency":"usd","status":"succeeded"}'

# Add a scenario rule for declined cards
apxy mock add --name "Stripe: Confirm Payment Intent (Card Declined)" \
  --url "https://api.stripe.com/v1/payment_intents/*/confirm" \
  --match wildcard --method POST \
  --header-conditions "X-APXY-Scenario=card_declined" \
  --headers "Content-Type=application/json,Request-Id=req_test_stripe_decline" \
  --status 402 \
  --body '{"error":{"type":"card_error","code":"card_declined","message":"Your card was declined."}}'
```

## Scenarios

Use `X-APXY-Scenario` to activate alternate outcomes on the same endpoint:

| Scenario | Typical Endpoint | Result |
|----------|------------------|--------|
| `invalid_request_error` | Any `/v1/*` route | 400 Stripe error object |
| `card_declined` | `POST /v1/payment_intents/*/confirm` | 402 card error |
| `unauthorized` | Any `/v1/*` route | 401 invalid API key |
| `rate_limited` | Any `/v1/*` route | 429 rate limit error |
| `idempotency_conflict` | `POST /v1/payment_intents` | 409 idempotency conflict |
| `server_error` | Any `/v1/*` route | 500 API error |

## Notes

- Responses use full Stripe API URLs so HTTPS interception for `api.stripe.com` is enabled automatically.
- List endpoints follow Stripe's `object=list`, `data`, `has_more`, and `url` structure.
- Payment Intents are the primary flow; direct charge creation is included for compatibility with legacy integrations.
- These mocks are static. They do not persist created objects or branch on request bodies.
