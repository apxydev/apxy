#!/usr/bin/env python3
"""
Configurable HTTP fixture server for APXY integration tests.

Reads route configuration from a scenario JSON file and serves canned responses.
Routes are checked top-to-bottom; first match wins.

Supports:
  - Static responses with configurable status, body, headers
  - after_request: route activates only after N prior requests to the same method+path
  - delay_ms: artificial latency before responding
  - Thread-safe request counting
"""

import argparse
import json
import sys
import threading
import time
from http.server import HTTPServer, BaseHTTPRequestHandler
from io import BytesIO


def load_scenario(path):
    with open(path) as f:
        data = json.load(f)
    cfg = data["setup"]["fixture_server"]
    return cfg["port"], cfg["routes"]


class FixtureHandler(BaseHTTPRequestHandler):
    """Handler that matches incoming requests against a ordered route table."""

    # Silences per-request log lines so test output stays clean.
    def log_message(self, fmt, *args):
        pass

    # ---- unified dispatch for every HTTP method ----
    def _handle(self):
        method = self.command
        path = self.path

        routes = self.server.routes
        counter = self.server.request_counter
        lock = self.server.counter_lock

        key = (method, path)

        # --- atomically read-and-increment the counter for this key ---
        with lock:
            prev_count = counter.get(key, 0)
            counter[key] = prev_count + 1

        # Two-pass matching: eligible after_request routes take priority
        # over default (no after_request) routes for the same path/method.
        fallback = None
        for route in routes:
            if route["path"] != path or route["method"] != method:
                continue

            after = route.get("after_request")
            if after is not None:
                if prev_count >= after:
                    # after_request route is eligible — use it (wins over fallback)
                    fallback = route
                    break
                # not yet eligible — skip
                continue

            # Normal route (no after_request) — save as fallback
            if fallback is None:
                fallback = route

        if fallback is not None:
            delay = fallback.get("delay_ms")
            if delay:
                time.sleep(delay / 1000.0)

            status = fallback["status"]
            body = fallback.get("body", "")
            headers = fallback.get("headers", {})

            self.send_response(status)
            for hdr_name, hdr_val in headers.items():
                self.send_header(hdr_name, hdr_val)
            if "Content-Type" not in headers:
                self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body.encode())))
            self.end_headers()
            self.wfile.write(body.encode())
            return

        # No route matched → 404
        msg = json.dumps({"error": "no matching route"}).encode()
        self.send_response(404)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(msg)))
        self.end_headers()
        self.wfile.write(msg)

    # Map every standard method through _handle.
    def do_GET(self):      self._handle()
    def do_POST(self):     self._handle()
    def do_PUT(self):      self._handle()
    def do_PATCH(self):    self._handle()
    def do_DELETE(self):   self._handle()
    def do_OPTIONS(self):  self._handle()
    def do_HEAD(self):     self._handle()


def make_server(port, routes, bind="127.0.0.1"):
    server = HTTPServer((bind, port), FixtureHandler)
    server.routes = routes
    server.request_counter = {}
    server.counter_lock = threading.Lock()
    return server


# ---------------------------------------------------------------------------
# Self-test
# ---------------------------------------------------------------------------

def _self_test():
    import http.client
    import os
    import tempfile

    passed = 0
    failed = 0

    def check(name, condition):
        nonlocal passed, failed
        if condition:
            passed += 1
        else:
            failed += 1
            print(f"FAIL: {name}")

    # Build a temporary scenario file
    scenario = {
        "setup": {
            "fixture_server": {
                "port": 0,  # not used directly — we pick a free port below
                "routes": [
                    {
                        "path": "/health",
                        "method": "GET",
                        "status": 200,
                        "body": '{"status":"ok"}',
                        "headers": {"X-Custom": "yes"}
                    },
                    {
                        "path": "/flaky",
                        "method": "GET",
                        "status": 500,
                        "body": '{"error":"boom"}'
                    },
                    {
                        "path": "/flaky",
                        "method": "GET",
                        "status": 200,
                        "body": '{"status":"recovered"}',
                        "after_request": 2
                    },
                    {
                        "path": "/slow",
                        "method": "GET",
                        "status": 200,
                        "body": '{"waited":true}',
                        "delay_ms": 200
                    },
                    {
                        "path": "/cors",
                        "method": "OPTIONS",
                        "status": 204,
                        "body": "",
                        "headers": {"Access-Control-Allow-Origin": "*"}
                    },
                    {
                        "path": "/post-it",
                        "method": "POST",
                        "status": 201,
                        "body": '{"created":true}'
                    }
                ]
            }
        }
    }

    routes = scenario["setup"]["fixture_server"]["routes"]

    # Use port 0 so the OS assigns a free port.
    server = make_server(0, routes)
    port = server.server_address[1]

    t = threading.Thread(target=server.serve_forever, daemon=True)
    t.start()

    def req(method, path):
        conn = http.client.HTTPConnection("127.0.0.1", port, timeout=5)
        conn.request(method, path)
        resp = conn.getresponse()
        body = resp.read().decode()
        hdrs = {k.lower(): v for k, v in resp.getheaders()}
        conn.close()
        return resp.status, body, hdrs

    # 1. Basic GET routing
    status, body, hdrs = req("GET", "/health")
    check("GET /health status", status == 200)
    check("GET /health body", '"ok"' in body)
    check("GET /health custom header", hdrs.get("x-custom") == "yes")

    # 2. 404 for unknown path
    status, body, _ = req("GET", "/nonexistent")
    check("unknown path 404", status == 404)

    # 3. 404 for wrong method on known path
    status, _, _ = req("DELETE", "/health")
    check("wrong method 404", status == 404)

    # 4. after_request fallthrough logic
    #    First two GETs to /flaky should return 500, third should return 200.
    s1, _, _ = req("GET", "/flaky")
    check("flaky req 1 -> 500", s1 == 500)
    s2, _, _ = req("GET", "/flaky")
    check("flaky req 2 -> 500", s2 == 500)
    s3, b3, _ = req("GET", "/flaky")
    check("flaky req 3 -> 200", s3 == 200)
    check("flaky req 3 body", '"recovered"' in b3)

    # 5. OPTIONS method
    status, _, hdrs = req("OPTIONS", "/cors")
    check("OPTIONS status", status == 204)
    check("OPTIONS CORS header", hdrs.get("access-control-allow-origin") == "*")

    # 6. POST method
    status, body, _ = req("POST", "/post-it")
    check("POST status 201", status == 201)
    check("POST body", '"created"' in body)

    # 7. delay_ms — verify it actually delays
    t0 = time.monotonic()
    status, body, _ = req("GET", "/slow")
    elapsed_ms = (time.monotonic() - t0) * 1000
    check("delay_ms status", status == 200)
    check("delay_ms actual delay >= 180ms", elapsed_ms >= 180)

    server.shutdown()

    if failed:
        print(f"\n{passed} passed, {failed} failed")
        sys.exit(1)
    else:
        print("All fixture server self-tests passed.")


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="APXY fixture HTTP server")
    parser.add_argument("--scenario", help="Path to scenario JSON file")
    parser.add_argument("--self-test", action="store_true", help="Run built-in self-tests")
    args = parser.parse_args()

    if args.self_test:
        _self_test()
        return

    if not args.scenario:
        parser.error("--scenario is required unless running --self-test")

    port, routes = load_scenario(args.scenario)
    server = make_server(port, routes)
    print(f"Fixture server listening on 127.0.0.1:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        server.shutdown()
        print("\nShutdown.")


if __name__ == "__main__":
    main()
