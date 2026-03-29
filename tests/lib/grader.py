#!/usr/bin/env python3
"""
Grader for APXY skill integration tests.

Reads JSONL stream output from `claude -p --output-format stream-json --verbose`
and evaluates checkpoint and outcome assertions from scenario definitions.

Also accepts the legacy {messages: [...]} JSON format for self-tests.

CLI:
    python grader.py --scenario scenario.json --transcript transcript.jsonl [--output report.json]
    python grader.py --self-test
"""

import argparse
import json
import sys


def load_transcript(path):
    """Load a transcript from either JSONL stream format or legacy JSON format.

    JSONL (stream-json --verbose): one JSON object per line, assistant events
    contain message.content[] with tool_use and text blocks.

    Legacy JSON: {messages: [...]} or {result: {messages: [...]}}.

    Returns a normalized dict: {messages: [{role: "assistant", content: [...]}]}
    """
    with open(path) as f:
        raw = f.read()

    # Try legacy single JSON object first
    try:
        data = json.loads(raw)
        if isinstance(data, dict):
            return data
    except json.JSONDecodeError:
        pass

    # JSONL stream format (one JSON object per line)
    messages = []
    for line in raw.splitlines():
        line = line.strip()
        if not line:
            continue
        event = json.loads(line)
        if event.get("type") == "assistant":
            msg = event.get("message", {})
            content = msg.get("content", [])
            if content:
                messages.append({"role": "assistant", "content": content})
    return {"messages": messages}


def extract_commands(transcript):
    """Extract Bash commands from a Claude transcript.

    Handles both {messages: [...]} and {result: {messages: [...]}} formats.
    Returns list of command strings in order.
    """
    messages = transcript.get("messages") or transcript.get("result", {}).get("messages", [])
    commands = []
    for msg in messages:
        if msg.get("role") != "assistant":
            continue
        for block in msg.get("content", []):
            if (
                block.get("type") == "tool_use"
                and block.get("name") == "Bash"
                and isinstance(block.get("input"), dict)
            ):
                cmd = block["input"].get("command", "")
                if cmd:
                    commands.append(cmd)
    return commands


def extract_agent_text(transcript):
    """Extract all agent text blocks from a Claude transcript.

    Returns list of text strings.
    """
    messages = transcript.get("messages") or transcript.get("result", {}).get("messages", [])
    texts = []
    for msg in messages:
        if msg.get("role") != "assistant":
            continue
        for block in msg.get("content", []):
            if block.get("type") == "text" and block.get("text"):
                texts.append(block["text"])
    return texts


def match_command(commands, rule):
    """Find the first command index matching a rule.

    Returns (index, command) or (None, None).
    """
    if "command_contains" in rule:
        substr = rule["command_contains"]
        for i, cmd in enumerate(commands):
            if substr in cmd:
                return i, cmd
    elif "command_contains_any" in rule:
        for i, cmd in enumerate(commands):
            for substr in rule["command_contains_any"]:
                if substr in cmd:
                    return i, cmd
    return None, None


def grade_checkpoints(commands, checkpoints):
    """Grade a list of checkpoints against extracted commands.

    Returns list of checkpoint result dicts.
    """
    # Map checkpoint id -> match index for ordering checks
    id_to_index = {}
    results = []

    for cp in checkpoints:
        cp_id = cp["id"]
        description = cp["description"]
        match = cp.get("match", {})
        after = cp.get("after")

        idx, matched_cmd = match_command(commands, match)

        passed = idx is not None

        # Check ordering constraint
        if passed and after is not None:
            predecessor_idx = id_to_index.get(after)
            if predecessor_idx is None or idx <= predecessor_idx:
                passed = False

        if passed:
            id_to_index[cp_id] = idx

        results.append({
            "id": cp_id,
            "description": description,
            "pass": passed,
            "match_index": idx,
            "matched_command": matched_cmd,
        })

    return results


def grade_outcome(agent_texts, outcome):
    """Grade outcome assertion against agent text.

    Returns outcome result dict. If no outcome defined, returns a default pass.
    """
    if outcome is None:
        return {"pass": True, "description": "No outcome defined", "matched_terms": []}

    description = outcome.get("description", "")
    terms = outcome.get("transcript_contains_any", [])
    all_text = "\n".join(agent_texts).lower()

    matched = [t for t in terms if t.lower() in all_text]

    return {
        "pass": len(matched) > 0,
        "description": description,
        "matched_terms": matched,
    }


def grade(scenario, transcript):
    """Run full grading. Returns report dict."""
    commands = extract_commands(transcript)
    agent_texts = extract_agent_text(transcript)

    checkpoints = scenario.get("checkpoints", [])
    outcome_def = scenario.get("outcome")

    cp_results = grade_checkpoints(commands, checkpoints)
    outcome_result = grade_outcome(agent_texts, outcome_def)

    all_cp_pass = all(r["pass"] for r in cp_results)
    overall = all_cp_pass and outcome_result["pass"]

    return {
        "scenario": scenario.get("name", "unknown"),
        "pass": overall,
        "commands_found": len(commands),
        "checkpoints": cp_results,
        "outcome": outcome_result,
    }


# ---------------------------------------------------------------------------
# Self-test
# ---------------------------------------------------------------------------

def _make_transcript(commands, texts=None):
    """Build a minimal transcript with Bash tool_use blocks and optional text blocks."""
    content = []
    for cmd in commands:
        content.append({"type": "tool_use", "name": "Bash", "input": {"command": cmd}})
    for t in (texts or []):
        content.append({"type": "text", "text": t})
    return {"messages": [{"role": "assistant", "content": content}]}


def _make_transcript_result_format(commands, texts=None):
    """Build transcript using {result: {messages: [...]}} format."""
    content = []
    for cmd in commands:
        content.append({"type": "tool_use", "name": "Bash", "input": {"command": cmd}})
    for t in (texts or []):
        content.append({"type": "text", "text": t})
    return {"result": {"messages": [{"role": "assistant", "content": content}]}}


def self_test():
    failures = []

    # --- Test 1: All checkpoints passing with correct ordering ---
    scenario1 = {
        "name": "test_all_pass",
        "checkpoints": [
            {"id": "cp1", "description": "Run curl", "match": {"command_contains": "curl"}},
            {"id": "cp2", "description": "Run grep after curl", "match": {"command_contains": "grep"}, "after": "cp1"},
        ],
        "outcome": {"description": "Should mention success", "transcript_contains_any": ["success", "ok"]},
    }
    transcript1 = _make_transcript(
        ["curl http://example.com", "grep pattern file.txt"],
        ["The operation was a success."],
    )
    report1 = grade(scenario1, transcript1)
    if not report1["pass"]:
        failures.append("Test 1 (all pass): expected overall pass=True")
    if not all(cp["pass"] for cp in report1["checkpoints"]):
        failures.append("Test 1 (all pass): expected all checkpoints pass")
    if report1["checkpoints"][0]["match_index"] != 0:
        failures.append("Test 1: cp1 should match index 0")
    if report1["checkpoints"][1]["match_index"] != 1:
        failures.append("Test 1: cp2 should match index 1")

    # --- Test 2: Ordering violation (checkpoint matched before predecessor) ---
    scenario2 = {
        "name": "test_ordering_violation",
        "checkpoints": [
            {"id": "cp1", "description": "Run grep", "match": {"command_contains": "grep"}},
            {"id": "cp2", "description": "Run curl after grep", "match": {"command_contains": "curl"}, "after": "cp1"},
        ],
    }
    # curl appears before grep, so cp2 (curl after grep) should fail
    transcript2 = _make_transcript(["curl http://example.com", "grep pattern"])
    report2 = grade(scenario2, transcript2)
    if report2["checkpoints"][0]["pass"] is not True:
        failures.append("Test 2: cp1 (grep) should pass")
    if report2["checkpoints"][1]["pass"] is not False:
        failures.append("Test 2: cp2 (curl after grep) should fail due to ordering violation")
    if report2["pass"]:
        failures.append("Test 2: overall should fail")

    # --- Test 3: Missing command ---
    scenario3 = {
        "name": "test_missing_cmd",
        "checkpoints": [
            {"id": "cp1", "description": "Run apxy", "match": {"command_contains": "apxy start"}},
        ],
    }
    transcript3 = _make_transcript(["ls -la", "cat file.txt"])
    report3 = grade(scenario3, transcript3)
    if report3["checkpoints"][0]["pass"] is not False:
        failures.append("Test 3: should fail when command not found")
    if report3["checkpoints"][0]["match_index"] is not None:
        failures.append("Test 3: match_index should be None")
    if report3["pass"]:
        failures.append("Test 3: overall should fail")

    # --- Test 4: Outcome failure (no matching terms) ---
    scenario4 = {
        "name": "test_outcome_fail",
        "checkpoints": [
            {"id": "cp1", "description": "Run ls", "match": {"command_contains": "ls"}},
        ],
        "outcome": {"description": "Should mention error", "transcript_contains_any": ["error", "failure"]},
    }
    transcript4 = _make_transcript(["ls -la"], ["Everything went fine, no issues."])
    report4 = grade(scenario4, transcript4)
    if report4["checkpoints"][0]["pass"] is not True:
        failures.append("Test 4: checkpoint should pass")
    if report4["outcome"]["pass"] is not False:
        failures.append("Test 4: outcome should fail (no matching terms)")
    if report4["pass"]:
        failures.append("Test 4: overall should fail due to outcome")

    # --- Test 5: Outcome success with partial matches ---
    scenario5 = {
        "name": "test_outcome_partial",
        "checkpoints": [],
        "outcome": {
            "description": "Should find some terms",
            "transcript_contains_any": ["alpha", "beta", "gamma"],
        },
    }
    transcript5 = _make_transcript([], ["This has Alpha and gamma but not the other."])
    report5 = grade(scenario5, transcript5)
    if not report5["outcome"]["pass"]:
        failures.append("Test 5: outcome should pass with partial matches")
    matched = report5["outcome"]["matched_terms"]
    if "alpha" not in matched or "gamma" not in matched:
        failures.append(f"Test 5: expected alpha and gamma in matched_terms, got {matched}")
    if "beta" in matched:
        failures.append("Test 5: beta should not be in matched_terms")

    # --- Test 6: command_contains_any matching ---
    scenario6 = {
        "name": "test_contains_any",
        "checkpoints": [
            {
                "id": "cp1",
                "description": "Run network tool",
                "match": {"command_contains_any": ["ping", "traceroute", "nslookup"]},
            },
        ],
    }
    transcript6 = _make_transcript(["echo hello", "traceroute 8.8.8.8"])
    report6 = grade(scenario6, transcript6)
    if not report6["checkpoints"][0]["pass"]:
        failures.append("Test 6: command_contains_any should match traceroute")
    if report6["checkpoints"][0]["match_index"] != 1:
        failures.append("Test 6: should match at index 1")

    # --- Test 7: result format transcript ---
    transcript7 = _make_transcript_result_format(["curl http://test.com"], ["Done"])
    commands7 = extract_commands(transcript7)
    if len(commands7) != 1 or "curl" not in commands7[0]:
        failures.append("Test 7: result format should extract commands correctly")

    # --- Test 8: No outcome defined passes by default ---
    scenario8 = {"name": "test_no_outcome", "checkpoints": []}
    transcript8 = _make_transcript([])
    report8 = grade(scenario8, transcript8)
    if not report8["pass"]:
        failures.append("Test 8: no outcome and no checkpoints should pass")

    # --- Test 9: JSONL stream format via load_transcript ---
    import tempfile, os
    jsonl_lines = [
        '{"type":"system","subtype":"init"}',
        '{"type":"assistant","message":{"content":[{"type":"tool_use","name":"Bash","input":{"command":"apxy traffic logs list"}}]}}',
        '{"type":"user","message":{"content":[{"type":"tool_result","content":"some output"}]}}',
        '{"type":"assistant","message":{"content":[{"type":"text","text":"Found 500 errors in the logs."}]}}',
        '{"type":"result","subtype":"success"}',
    ]
    with tempfile.NamedTemporaryFile(mode='w', suffix='.jsonl', delete=False) as tmp:
        tmp.write('\n'.join(jsonl_lines))
        tmp_path = tmp.name
    try:
        loaded = load_transcript(tmp_path)
        cmds9 = extract_commands(loaded)
        texts9 = extract_agent_text(loaded)
        if len(cmds9) != 1 or "apxy traffic logs list" not in cmds9[0]:
            failures.append(f"Test 9: JSONL should extract 1 command, got {cmds9}")
        if len(texts9) != 1 or "500 errors" not in texts9[0]:
            failures.append(f"Test 9: JSONL should extract text, got {texts9}")
    finally:
        os.unlink(tmp_path)

    if failures:
        for f in failures:
            print(f"FAIL: {f}", file=sys.stderr)
        print(f"\n{len(failures)} self-test(s) failed.", file=sys.stderr)
        sys.exit(1)
    else:
        print("All grader self-tests passed.")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="APXY integration test grader")
    parser.add_argument("--scenario", help="Path to scenario JSON file")
    parser.add_argument("--transcript", help="Path to transcript JSON file")
    parser.add_argument("--output", help="Path to write report JSON (optional)")
    parser.add_argument("--self-test", action="store_true", help="Run built-in self-tests")
    args = parser.parse_args()

    if args.self_test:
        self_test()
        return

    if not args.scenario or not args.transcript:
        parser.error("--scenario and --transcript are required (or use --self-test)")

    with open(args.scenario) as f:
        scenario = json.load(f)
    transcript = load_transcript(args.transcript)

    report = grade(scenario, transcript)

    if args.output:
        with open(args.output, "w") as f:
            json.dump(report, f, indent=2)
    else:
        print(json.dumps(report, indent=2))

    sys.exit(0 if report["pass"] else 1)


if __name__ == "__main__":
    main()
