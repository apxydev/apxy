#!/usr/bin/env bash
# APXY Skill Integration Test Runner
#
# Runs each scenario in tests/scenarios/ against a real APXY instance.
# Usage:
#   ./tests/run-tests.sh                    # run all scenarios
#   ./tests/run-tests.sh debug-500-errors   # run one scenario by name
#
# Requirements: apxy, claude, python3, curl, jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
SCENARIOS_DIR="$SCRIPT_DIR/scenarios"
RESULTS_DIR="$SCRIPT_DIR/results"
SKILL_FILE="$REPO_DIR/skills/apxy/SKILL.md"

TIMEOUT="${APXY_TEST_TIMEOUT:-180}"

# macOS doesn't have `timeout` by default; use gtimeout (from coreutils) or a bash fallback
if command -v timeout &>/dev/null; then
    TIMEOUT_CMD="timeout"
elif command -v gtimeout &>/dev/null; then
    TIMEOUT_CMD="gtimeout"
else
    # Pure bash fallback: run command in background, kill after timeout
    _bash_timeout() {
        local secs="$1"; shift
        "$@" &
        local pid=$!
        ( sleep "$secs" && kill "$pid" 2>/dev/null ) &
        local watchdog=$!
        wait "$pid" 2>/dev/null
        local rc=$?
        kill "$watchdog" 2>/dev/null
        wait "$watchdog" 2>/dev/null
        # If killed by our watchdog, return 124 (same as GNU timeout)
        if [ $rc -eq 137 ] || [ $rc -eq 143 ]; then
            return 124
        fi
        return $rc
    }
    TIMEOUT_CMD="_bash_timeout"
fi
FIXTURE_PID=""
APXY_PID=""
PROXY_STARTED=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

cleanup() {
    if [ -n "$FIXTURE_PID" ] && kill -0 "$FIXTURE_PID" 2>/dev/null; then
        kill "$FIXTURE_PID" 2>/dev/null || true
        wait "$FIXTURE_PID" 2>/dev/null || true
    fi
    if [ -n "$APXY_PID" ] && kill -0 "$APXY_PID" 2>/dev/null; then
        kill "$APXY_PID" 2>/dev/null || true
        wait "$APXY_PID" 2>/dev/null || true
    fi
    if $PROXY_STARTED; then
        apxy traffic logs clear 2>/dev/null || true
    fi
    FIXTURE_PID=""
    APXY_PID=""
    PROXY_STARTED=false
}

trap cleanup EXIT

check_deps() {
    local missing=()
    for cmd in apxy claude python3 curl jq; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo -e "${RED}Missing dependencies: ${missing[*]}${NC}" >&2
        exit 1
    fi
}

run_scenario() {
    local scenario_file="$1"
    local name
    name=$(jq -r '.name' "$scenario_file")

    local result_dir="$RESULTS_DIR/$name"
    mkdir -p "$result_dir"

    echo -e "${YELLOW}━━━ $name ━━━${NC}"

    local fixture_port
    fixture_port=$(jq -r '.setup.fixture_server.port' "$scenario_file")
    local proxy_port
    proxy_port=$(jq -r '.setup.apxy.port' "$scenario_file")

    # Step 1: Start fixture server
    echo "  Starting fixture server on :$fixture_port..."
    python3 "$LIB_DIR/fixture-server.py" --scenario "$scenario_file" &
    FIXTURE_PID=$!
    sleep 1

    if ! kill -0 "$FIXTURE_PID" 2>/dev/null; then
        echo -e "  ${RED}FAIL: fixture server failed to start${NC}"
        return 1
    fi

    # Step 2: Start APXY proxy (runs in background — it blocks in foreground)
    echo "  Starting APXY proxy on :$proxy_port..."
    apxy proxy stop 2>/dev/null || true
    apxy traffic logs clear 2>/dev/null || true
    apxy proxy start --port "$proxy_port" --no-system-proxy >/dev/null 2>&1 &
    APXY_PID=$!

    PROXY_STARTED=true
    sleep 2

    if ! kill -0 "$APXY_PID" 2>/dev/null; then
        echo -e "  ${RED}FAIL: APXY proxy failed to start${NC}"
        return 1
    fi

    # Step 3: Seed traffic
    echo "  Seeding traffic..."
    bash "$LIB_DIR/seed-traffic.sh" "$scenario_file" "$proxy_port"

    # Step 4: Run agent
    local prompt
    prompt=$(jq -r '.prompt' "$scenario_file")
    local skill_content
    skill_content=$(cat "$SKILL_FILE")

    echo "  Running claude agent (timeout: ${TIMEOUT}s)..."
    local exit_code=0
    $TIMEOUT_CMD "$TIMEOUT" claude -p \
        --output-format stream-json --verbose \
        --allowedTools "Bash(apxy*)" \
        --append-system-prompt "You have access to the APXY skill. Here is the skill content:

$skill_content

Use the APXY CLI to help the user. Read the appropriate reference file from skills/apxy/references/ based on the user's request before running commands." \
        --dangerously-skip-permissions \
        --model sonnet \
        --max-turns 15 \
        "$prompt" \
        > "$result_dir/transcript.jsonl" 2>/dev/null || exit_code=$?

    if [ $exit_code -eq 124 ]; then
        echo -e "  ${RED}FAIL: agent timed out after ${TIMEOUT}s${NC}"
        cleanup
        return 1
    fi

    # Step 5: Grade results
    echo "  Grading..."
    local grade_exit=0
    python3 "$LIB_DIR/grader.py" \
        --scenario "$scenario_file" \
        --transcript "$result_dir/transcript.jsonl" \
        --output "$result_dir/report.json" || grade_exit=$?

    # Step 6: Print results
    if [ $grade_exit -eq 0 ]; then
        echo -e "  ${GREEN}PASS${NC}"
        jq -r '.checkpoints[] | "    ✓ \(.id): \(.matched_command // "n/a" | .[0:80])"' "$result_dir/report.json" 2>/dev/null || true
    else
        echo -e "  ${RED}FAIL${NC}"
        jq -r '.checkpoints[] | if .pass then "    ✓ \(.id)" else "    ✗ \(.id): \(.description)" end' "$result_dir/report.json" 2>/dev/null || true
        if [ "$(jq -r '.outcome.pass // true' "$result_dir/report.json" 2>/dev/null)" = "false" ]; then
            echo -e "    ${RED}✗ outcome: $(jq -r '.outcome.description' "$result_dir/report.json" 2>/dev/null)${NC}"
        fi
    fi

    cleanup
    return $grade_exit
}

main() {
    check_deps

    local filter="${1:-}"
    local total=0
    local passed=0
    local failed=0
    local failed_names=()

    echo ""
    echo "APXY Skill Integration Tests"
    echo "============================="
    echo ""

    for scenario_file in "$SCENARIOS_DIR"/*.json; do
        [ -f "$scenario_file" ] || continue

        local name
        name=$(jq -r '.name' "$scenario_file")

        if [ -n "$filter" ] && [ "$name" != "$filter" ]; then
            continue
        fi

        total=$((total + 1))
        if run_scenario "$scenario_file"; then
            passed=$((passed + 1))
        else
            failed=$((failed + 1))
            failed_names+=("$name")
        fi
        echo ""
    done

    echo "============================="
    echo -e "Results: ${GREEN}$passed passed${NC}, ${RED}$failed failed${NC}, $total total"
    if [ ${#failed_names[@]} -gt 0 ]; then
        echo -e "${RED}Failed: ${failed_names[*]}${NC}"
    fi

    mkdir -p "$RESULTS_DIR"
    jq -n \
        --argjson passed "$passed" \
        --argjson failed "$failed" \
        --argjson total "$total" \
        '{passed: $passed, failed: $failed, total: $total}' \
        > "$RESULTS_DIR/summary.json"

    [ $failed -eq 0 ]
}

main "$@"
