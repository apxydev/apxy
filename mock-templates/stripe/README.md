# Stripe API Mock Templates

Mock rules for the [Stripe API](https://stripe.com/docs/api).

## Covered Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/v1/charges` | Create a charge |
| GET | `/v1/charges/*` | Retrieve a charge |
| POST | `/v1/payment_intents` | Create a payment intent |
| GET | `/v1/payment_intents/*` | Retrieve a payment intent |
| GET | `/v1/customers/*` | Retrieve a customer |
| POST | `/v1/customers` | Create a customer |

## Usage

```bash
# Add all Stripe mocks
apxy mock add --name "Stripe: Create Charge" \
  --url "/v1/charges" --match exact --method POST \
  --status 200 --body '{"id":"ch_test_123","object":"charge","amount":2000,"currency":"usd","status":"succeeded"}'

apxy mock add --name "Stripe: Create Payment Intent" \
  --url "/v1/payment_intents" --match exact --method POST \
  --status 200 --body '{"id":"pi_test_123","object":"payment_intent","amount":2000,"currency":"usd","status":"requires_payment_method"}'
```

## Notes

- All IDs use `_test_` prefix to distinguish from real Stripe objects
- Amounts are in cents (Stripe convention)
- Adjust `status` fields to test different payment scenarios (e.g., `failed`, `requires_action`)
