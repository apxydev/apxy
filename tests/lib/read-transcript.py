#!/usr/bin/env python3
"""
Pretty-print a Claude stream-json transcript.

Usage:
    python tests/lib/read-transcript.py tests/results/debug-500-errors/transcript.jsonl
    python tests/lib/read-transcript.py tests/results/debug-500-errors/transcript.jsonl --no-thinking
    python tests/lib/read-transcript.py tests/results/debug-500-errors/transcript.jsonl --commands-only
"""

import argparse
import json
import sys


def print_transcript(path, show_thinking=True, commands_only=False):
    with open(path) as f:
        lines = f.readlines()

    if not lines:
        print("(empty transcript)")
        return

    step = 0
    for line in lines:
        line = line.strip()
        if not line:
            continue
        event = json.loads(line)
        t = event.get("type", "")
        st = event.get("subtype", "")

        if t == "assistant":
            msg = event.get("message", {})
            for block in msg.get("content", []):
                bt = block.get("type", "")

                if bt == "thinking" and show_thinking and not commands_only:
                    text = block.get("thinking", "")
                    print(f"\033[2m[thinking] {text}\033[0m")
                    print()

                elif bt == "tool_use":
                    name = block.get("name", "")
                    inp = block.get("input", {})
                    step += 1
                    if name == "Bash":
                        cmd = inp.get("command", "")
                        desc = inp.get("description", "")
                        if commands_only:
                            print(f"{step}. {cmd}")
                        else:
                            print(f"\033[33m[step {step}] $ {cmd}\033[0m")
                            if desc:
                                print(f"  # {desc}")
                            print()
                    elif not commands_only:
                        print(f"\033[33m[step {step}] {name}: {json.dumps(inp)[:200]}\033[0m")
                        print()

                elif bt == "text" and not commands_only:
                    print(f"\033[36m[agent]\033[0m {block.get('text', '')}")
                    print()

        elif t == "user" and not commands_only:
            msg = event.get("message", {})
            for block in msg.get("content", []):
                bt = block.get("type", "")
                if bt == "tool_result":
                    content = str(block.get("content", ""))
                    # Truncate long results
                    if len(content) > 500:
                        content = content[:500] + "..."
                    print(f"\033[2m[output] {content}\033[0m")
                    print()

        elif t == "result" and not commands_only:
            print(f"\033[32m[done] {st}\033[0m")


def main():
    parser = argparse.ArgumentParser(description="Pretty-print Claude transcript")
    parser.add_argument("transcript", help="Path to transcript.jsonl file")
    parser.add_argument(
        "--no-thinking", action="store_true", help="Hide thinking blocks"
    )
    parser.add_argument(
        "--commands-only",
        action="store_true",
        help="Show only Bash commands (numbered list)",
    )
    args = parser.parse_args()

    print_transcript(
        args.transcript,
        show_thinking=not args.no_thinking,
        commands_only=args.commands_only,
    )


if __name__ == "__main__":
    main()
