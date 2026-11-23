# LLM and agent traffic

Four jobs that come up when code calls LLM APIs or when a coding agent runs commands: check a streamed answer, replay LLM responses in tests, see what LLM calls cost, and see which hosts a process contacted. Checking a streamed answer needs APXY v1.8.0 or later, and the others v1.6.0. Each one works on traffic that is already captured, so start by capturing the run with `apxy mark` and `apxy run`.

LLM APIs are HTTPS, so APXY must decrypt the provider's host to see bodies and token counts. Pass `--ssl-domains <host>` (or `--mitm-all`) to `apxy run` or `apxy start`.

## Check a streamed answer

Prove that a chat endpoint streamed a complete, correct answer, not only that it returned 200.

```bash
apxy mark
apxy run -- npm test -- chat.spec.ts
apxy wait --match "POST /api/chat" \
  --expect "status == 200" \
  --expect 'sse.last.data == "[DONE]"' \
  --expect 'sse.text contains "refund"'
```

`sse.text` joins the OpenAI, Anthropic, or Gemini deltas into the full answer, so a phrase split across chunks still matches. `sse.data.<gjson path>` reads one JSON field of any event. The output has a `stream` summary with the kind, the number of events, and `closed`. A `closed: false` with exit 7 means the stream was still open at the timeout. All fields: [dsl-reference.md](dsl-reference.md#stream-fields). To read the events themselves: `apxy logs sse-events --id <ID>`, or `apxy logs sse-merge --id <ID>` for the joined answer.

## Record LLM calls once, replay them in tests

Tests that call a real LLM are slow, cost money, and give different answers each run. Record the real responses once, then replay them from a cassette file so the test is fast, free, and deterministic. This works for any language, because the replay happens in the proxy.

```bash
# 1. Record: run the code once against the real provider
apxy mark record
apxy run --ssl-domains api.anthropic.com -- pytest tests/test_summarize.py

# 2. Turn the captured calls into a cassette (commit it with the tests)
apxy mock from-traffic --host api.anthropic.com --file tests/cassettes/anthropic.json

# 3. Replay: load the cassette into a running proxy and run the tests
apxy start --no-system-proxy --no-trust-ca --ssl-domains api.anthropic.com &
until apxy status --quiet; do sleep 0.2; done
apxy mock import --file tests/cassettes/anthropic.json
apxy run -- pytest tests/test_summarize.py
apxy stop
```

`mock import` needs the running proxy, which is why replay uses `apxy start` rather than the temporary proxy from `apxy run`. With a non-default port, pass `--port P` to `start`, `status`, and `run`, and `--control-url http://127.0.0.1:<P+1>` to `mock import`.

What to know:

- **Matching.** Each recorded response is matched on method, URL, and a hash of the request body. `--ignore-field` lists JSON paths left out of the hash (default `metadata,user`). Add fields that change on every run, such as a random `seed` or a timestamp, or every request will miss.
- **A miss fails loudly.** By default a request to a recorded host that matches no recording gets HTTP 404 with error type `apxy_replay_miss` and header `X-Apxy-Replay: miss`, and never reaches the real provider. That is deliberate: a test should not silently spend money or change behavior. If a test fails with `apxy_replay_miss`, the prompt changed; record again. `--miss passthrough` forwards misses to the real provider instead.
- **Streaming.** SSE streams replay with their event boundaries intact and no delay between events.
- **Secrets stay out.** The cassette never stores request headers, so API keys are not written to it. It also drops `Set-Cookie` and query strings that carry a key, such as `?key=`.
- **Pick records precisely** with `--id <id1>,<id2>` (IDs from `apxy logs list`) instead of `--host`.

## Token usage and cost of LLM calls

```bash
apxy mark session
apxy run --ssl-domains api.anthropic.com,api.openai.com -- ./run-agent.sh
apxy logs ai-usage --since session
```

The report breaks tokens and estimated USD cost down by provider, model, and client app, for streamed Anthropic, OpenAI, and Gemini responses. MCP tool: `get_ai_usage`.

- Prompt tokens include cache reads and cache writes, which are listed separately. For agents like Claude Code most of the prompt arrives as cache reads, so a large prompt count with a small cost is normal.
- Prices come from tables built into APXY, and `price_sources` in the output gives each table's URL and date. Treat the cost as an estimate and say so when you report it.
- A model with no price shows `cost_usd: null` and is counted in `unpriced_records`. Report it as unknown, not as zero.
- Without `--since` the window is the current UTC week. `--until` closes the window.
- Non-streamed responses are not counted yet.

Intercepting an LLM provider's traffic may be restricted by that provider's terms. Mention this if the user plans to inspect a third-party agent rather than their own code.

## Which hosts a process or agent contacted

```bash
apxy mark agent-run
apxy run --mitm-all -- ./agent-task.sh
apxy logs egress --since agent-run                    # table: host, requests, bytes, status, app
apxy logs egress --since agent-run -q > egress.allow  # draft allowlist, one host per line
apxy logs egress --since agent-run --allowlist egress.allow
```

With `--allowlist`, the command exits `0` when every host is allowed and `9` when at least one is not, so it works as a CI step. MCP tool: `egress_summary`, which takes the patterns inline as `allow` and reports `passed` and `denied`.

- **Allowlist format:** one host pattern per line, `#` starts a comment. `*.github.com` matches `api.github.com` but not `github.com`, so list the apex too if it is used.
- **Tunneled hosts show no bytes or app.** Without `--mitm-all` or `--ssl-domains`, an HTTPS host appears as tunneled: you see that it was contacted and how often, but not how much data was sent. Use `--mitm-all` when data volume matters.
- **The app column is a guess** from the User-Agent header.
- **The default window is all history.** Pass `--since <mark>` to report on one run.
- **Blocked requests are not recorded.** A filter rule that blocks a host (see [advanced-rules.md](advanced-rules.md)) stops the request before it is stored, so blocked attempts do not appear in this report.
