#!/bin/sh
# Streams one line per new mark, "MARK <json>", for a tool that reads a process's output line by line.
f="${MARKS_FILE:-./marks/marks.jsonl}"
mkdir -p "$(dirname "$f")"; touch "$f"
tail -n 0 -F "$f" 2>/dev/null | while IFS= read -r line; do echo "MARK $line"; done
